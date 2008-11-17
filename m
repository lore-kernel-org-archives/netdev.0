From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/33] macvlan: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:16 -0800
Message-ID: <20081117234355.542288294@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55057 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081AbYKRAAC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:02 -0500
Content-Disposition: inline; filename=macvlan-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops function table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/macvlan.c	2008-11-04 13:58:06.000000000 -0800
+++ b/drivers/net/macvlan.c	2008-11-17 10:25:18.000000000 -0800
@@ -361,17 +361,22 @@ static const struct ethtool_ops macvlan_
 	.get_flags		= macvlan_ethtool_get_flags,
 };
 
+static const struct net_device_ops macvlan_netdev_ops = {
+	.init		= macvlan_init,
+	.open		= macvlan_open,
+	.stop		= macvlan_stop,
+	.change_mtu	= macvlan_change_mtu,
+	.change_rx_flags= macvlan_change_rx_flags,
+	.set_mac_address= macvlan_set_mac_address,
+	.set_multicast_list= macvlan_set_multicast_list,
+	.validate_addr = eth_validate_addr,
+};
+
 static void macvlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
-	dev->init		= macvlan_init;
-	dev->open		= macvlan_open;
-	dev->stop		= macvlan_stop;
-	dev->change_mtu		= macvlan_change_mtu;
-	dev->change_rx_flags	= macvlan_change_rx_flags;
-	dev->set_mac_address	= macvlan_set_mac_address;
-	dev->set_multicast_list	= macvlan_set_multicast_list;
+	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->hard_start_xmit	= macvlan_hard_start_xmit;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops,

-- 

