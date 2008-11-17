From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 33/33] acenic: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:40 -0800
Message-ID: <20081117234357.601250213@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55129 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398AbYKRAAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:25 -0500
Content-Disposition: inline; filename=acenic-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/acenic.c	2008-11-17 14:16:13.000000000 -0800
+++ b/drivers/net/acenic.c	2008-11-17 14:18:52.000000000 -0800
@@ -450,6 +450,17 @@ static const struct ethtool_ops ace_etht
 
 static void ace_watchdog(struct net_device *dev);
 
+static const struct net_device_ops ace_netdev_ops = {
+	.open = ace_open,
+	.stop = ace_close,
+	.tx_timeout = ace_watchdog,
+	.get_stats = ace_get_stats,
+	.set_multicast_list = ace_set_multicast_list,
+	.set_mac_address = ace_set_mac_addr,
+	.change_mtu = ace_change_mtu,
+	.vlan_rx_register = ace_vlan_rx_register,
+};
+
 static int __devinit acenic_probe_one(struct pci_dev *pdev,
 		const struct pci_device_id *id)
 {
@@ -473,20 +484,13 @@ static int __devinit acenic_probe_one(st
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 #if ACENIC_DO_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register = ace_vlan_rx_register;
 #endif
 
-	dev->tx_timeout = &ace_watchdog;
 	dev->watchdog_timeo = 5*HZ;
 
-	dev->open = &ace_open;
-	dev->stop = &ace_close;
+	dev->netdev_ops = &ace_netdev_ops;
 	dev->hard_start_xmit = &ace_start_xmit;
-	dev->get_stats = &ace_get_stats;
-	dev->set_multicast_list = &ace_set_multicast_list;
 	SET_ETHTOOL_OPS(dev, &ace_ethtool_ops);
-	dev->set_mac_address = &ace_set_mac_addr;
-	dev->change_mtu = &ace_change_mtu;
 
 	/* we only display this string ONCE */
 	if (!boards_found)

-- 

