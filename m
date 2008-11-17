From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/33] bridge: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:14 -0800
Message-ID: <20081117234355.375416878@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55052 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990AbYKRAAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:01 -0500
Content-Disposition: inline; filename=bridge-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops function table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_device.c	2008-11-17 10:23:18.000000000 -0800
+++ b/net/bridge/br_device.c	2008-11-17 10:25:05.000000000 -0800
@@ -147,7 +147,7 @@ static int br_set_tx_csum(struct net_dev
 	return 0;
 }
 
-static struct ethtool_ops br_ethtool_ops = {
+static const struct ethtool_ops br_ethtool_ops = {
 	.get_drvinfo    = br_getinfo,
 	.get_link	= ethtool_op_get_link,
 	.get_tx_csum	= ethtool_op_get_tx_csum,
@@ -160,21 +160,25 @@ static struct ethtool_ops br_ethtool_ops
 	.get_flags	= ethtool_op_get_flags,
 };
 
+static const struct net_device_ops br_netdev_ops = {
+	.open		 = br_dev_open,
+	.stop		 = br_dev_stop,
+	.set_mac_address = br_set_mac_address,
+	.set_multicast_list = br_dev_set_multicast_list,
+	.change_mtu	 = br_change_mtu,
+	.do_ioctl	= br_dev_ioctl,
+};
+
 void br_dev_setup(struct net_device *dev)
 {
 	random_ether_addr(dev->dev_addr);
 	ether_setup(dev);
 
-	dev->do_ioctl = br_dev_ioctl;
+	dev->netdev_ops = &br_netdev_ops;
 	dev->hard_start_xmit = br_dev_xmit;
-	dev->open = br_dev_open;
-	dev->set_multicast_list = br_dev_set_multicast_list;
-	dev->change_mtu = br_change_mtu;
 	dev->destructor = free_netdev;
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
-	dev->stop = br_dev_stop;
 	dev->tx_queue_len = 0;
-	dev->set_mac_address = br_set_mac_address;
 	dev->priv_flags = IFF_EBRIDGE;
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |

-- 

