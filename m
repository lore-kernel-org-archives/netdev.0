From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 17/45] 3c509: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:14 -0800
Message-ID: <20090109230137.965536962@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42192 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753903AbZAIXR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:56 -0500
Content-Disposition: inline; filename=3c509.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c509.c	2009-01-09 10:01:47.000000000 -0800
+++ b/drivers/net/3c509.c	2009-01-09 10:08:58.000000000 -0800
@@ -537,6 +537,21 @@ static struct mca_driver el3_mca_driver 
 static int mca_registered;
 #endif /* CONFIG_MCA */
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open 		= el3_open,
+	.ndo_stop	 	= el3_close,
+	.ndo_start_xmit 	= el3_start_xmit,
+	.ndo_get_stats 		= el3_get_stats,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_tx_timeout 	= el3_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= el3_poll_controller,
+#endif
+};
+
 static int __devinit el3_common_init(struct net_device *dev)
 {
 	struct el3_private *lp = netdev_priv(dev);
@@ -553,16 +568,8 @@ static int __devinit el3_common_init(str
 	}
 
 	/* The EL3-specific entries in the device structure. */
-	dev->open = &el3_open;
-	dev->hard_start_xmit = &el3_start_xmit;
-	dev->stop = &el3_close;
-	dev->get_stats = &el3_get_stats;
-	dev->set_multicast_list = &set_multicast_list;
-	dev->tx_timeout = el3_tx_timeout;
+	dev->netdev_ops = &netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = el3_poll_controller;
-#endif
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 
 	err = register_netdev(dev);


