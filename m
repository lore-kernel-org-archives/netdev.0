From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 32/33] niu: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:39 -0800
Message-ID: <20081117234357.517904432@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55127 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369AbYKRAAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:24 -0500
Content-Disposition: inline; filename=niu-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only (give me hw!)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/niu.c	2008-11-17 13:45:41.000000000 -0800
+++ b/drivers/net/niu.c	2008-11-17 13:48:46.000000000 -0800
@@ -8618,19 +8618,24 @@ static struct net_device * __devinit niu
 	return dev;
 }
 
+static const struct net_device_ops niu_netdev_ops = {
+	.open			= niu_open,
+	.stop			= niu_close,
+	.get_stats		= niu_get_stats,
+	.set_multicast_list	= niu_set_rx_mode,
+	.validate_addr		= eth_validate_addr,
+	.set_mac_address	= niu_set_mac_addr,
+	.do_ioctl		= niu_ioctl,
+	.tx_timeout		= niu_tx_timeout,
+	.change_mtu		= niu_change_mtu,
+};
+
 static void __devinit niu_assign_netdev_ops(struct net_device *dev)
 {
-	dev->open = niu_open;
-	dev->stop = niu_close;
-	dev->get_stats = niu_get_stats;
-	dev->set_multicast_list = niu_set_rx_mode;
-	dev->set_mac_address = niu_set_mac_addr;
-	dev->do_ioctl = niu_ioctl;
-	dev->tx_timeout = niu_tx_timeout;
+	dev->netdev_ops = &niu_netdev_ops;
 	dev->hard_start_xmit = niu_start_xmit;
 	dev->ethtool_ops = &niu_ethtool_ops;
 	dev->watchdog_timeo = NIU_TX_TIMEOUT;
-	dev->change_mtu = niu_change_mtu;
 }
 
 static void __devinit niu_device_announce(struct niu *np)

-- 

