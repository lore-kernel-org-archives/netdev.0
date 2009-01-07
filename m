From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/42] tlan: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:24 -0800
Message-ID: <20090107003346.352148671@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Sakari Ailus <sakari.ailus@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59017 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755762AbZAGAxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:31 -0500
Content-Disposition: inline; filename=tlan.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tlan.c	2009-01-05 17:21:57.919070541 -0800
+++ b/drivers/net/tlan.c	2009-01-05 22:45:26.054570112 -0800
@@ -831,6 +831,21 @@ static void TLan_Poll(struct net_device 
 }
 #endif
 
+static const struct net_device_ops TLan_netdev_ops = {
+	.ndo_open 		= TLan_Open,
+	.ndo_stop		= TLan_Close,
+	.ndo_start_xmit		= TLan_StartTx,
+	.ndo_tx_timeout		= TLan_tx_timeout,
+	.ndo_get_stats		= TLan_GetStats,
+	.ndo_set_multicast_list = TLan_SetMulticastList,
+	.ndo_do_ioctl		= TLan_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	 = TLan_Poll,
+#endif
+};
 
 
 
@@ -892,16 +907,7 @@ static int TLan_Init( struct net_device 
 	netif_carrier_off(dev);
 
 	/* Device methods */
-	dev->open = &TLan_Open;
-	dev->hard_start_xmit = &TLan_StartTx;
-	dev->stop = &TLan_Close;
-	dev->get_stats = &TLan_GetStats;
-	dev->set_multicast_list = &TLan_SetMulticastList;
-	dev->do_ioctl = &TLan_ioctl;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = &TLan_Poll;
-#endif
-	dev->tx_timeout = &TLan_tx_timeout;
+	dev->netdev_ops = &TLan_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	return 0;

-- 

