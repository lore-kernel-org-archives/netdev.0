From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 39/42] slip: convert to net_device_ops
Date: Tue, 06 Jan 2009 16:33:55 -0800
Message-ID: <20090107003349.686816790@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60722 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755901AbZAGAyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:16 -0500
Content-Disposition: inline; filename=slip.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/slip.c	2009-01-05 17:15:19.435319615 -0800
+++ b/drivers/net/slip.c	2009-01-05 17:15:54.926064690 -0800
@@ -603,7 +603,6 @@ static int sl_init(struct net_device *de
 	dev->mtu		= sl->mtu;
 	dev->type		= ARPHRD_SLIP + sl->mode;
 #ifdef SL_CHECK_TRANSMIT
-	dev->tx_timeout		= sl_tx_timeout;
 	dev->watchdog_timeo	= 20*HZ;
 #endif
 	return 0;
@@ -617,19 +616,26 @@ static void sl_uninit(struct net_device 
 	sl_free_bufs(sl);
 }
 
+static const struct net_device_ops sl_netdev_ops = {
+	.ndo_init		= sl_init,
+	.ndo_uninit	  	= sl_uninit,
+	.ndo_open		= sl_open,
+	.ndo_stop		= sl_close,
+	.ndo_start_xmit		= sl_xmit,
+	.ndo_get_stats	        = sl_get_stats,
+	.ndo_change_mtu		= sl_change_mtu,
+	.ndo_tx_timeout		= sl_tx_timeout,
+#ifdef CONFIG_SLIP_SMART
+	.ndo_do_ioctl		= sl_ioctl,
+#endif
+};
+
+
 static void sl_setup(struct net_device *dev)
 {
-	dev->init		= sl_init;
-	dev->uninit	  	= sl_uninit;
-	dev->open		= sl_open;
+	dev->netdev_ops		= &sl_netdev_ops;
 	dev->destructor		= free_netdev;
-	dev->stop		= sl_close;
-	dev->get_stats	        = sl_get_stats;
-	dev->change_mtu		= sl_change_mtu;
-	dev->hard_start_xmit	= sl_xmit;
-#ifdef CONFIG_SLIP_SMART
-	dev->do_ioctl		= sl_ioctl;
-#endif
+
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
 	dev->tx_queue_len	= 10;

-- 

