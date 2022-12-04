#connects to AZ
connect-azaccount

#imports CSV file and sets as variable
$vngcsv = import-csv $psscriptroot\vngcsv.csv 

#gets azure virtual network and assigns it to a variable, then creates a gatewaysubnet
$vnet = get-azvirtualnetwork -name $vngcsv.vnetname -resourcegroupname $vngcsv.resourcegroup
add-azvirtualnetworksubnetconfig -name GatewaySubnet -AddressPrefix $vngcsv.addresssize -virtualnetwork $vnet
$vnet | set-azvirtualnetwork

#Creates a public IP address to assign to the VNG
$gatewayIP = new-azpublicipaddress -name $vngcsv.publicipname -resourcegroupname $vngcsv.resourcegroup -location $vngcsv.location -allocationmethod dynamic

#Creates virtualnetwork gateway IPconfig
$GatewayIPConfig = new-azvirtualnetworkgatewayipconfig -name $vngcsv.publicipname -subnetid (get-azvirtualnetworksubnetconfig -name GatewaySubnet -Virtualnetwork $vnet.id -publicipaddress $gatewayIP)

#Creates Virtual Network Gateway
$VirtualNetworkGateway=New-AzVirtualNetworkGateway -Name ($vnet.name+='VNG') -ResourceGroupName $vngcsv.resourcegroup -Location $vngcsv.location -IpConfigurations $gatewayipconfig -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw1

#Creates Local Network Gateway
$localnetworkgateway = New-AzLocalNetworkGateway -Name ($vnet.name+='LNG')-ResourceGroupName $vngcsv.resourcegroup -Location $vngcsv.location -GatewayIpAddress $vngcsv.remoteIP -AddressPrefix @($vngcsv.localsubnets)

#Creates connection with autonegotiation
new-azvirtualnetworkgatewayconnection -name $vngcsv.connectionname -resourcegroupname $vngcsv.resourcegroup -location $vngcsv.location -virtualnetworkgateway $virtualnetworkgateway -localnetworkgateway $localnetworkgateway -connectiontype IPsec -sharedkey $vngcsv.sharedsecretkey

#Tests the New Connection
get-azvirtualnetworkgatewayconnection -name $vngcsv.connectionname -resourcegroupname $vngcsv.ResourceGroup
