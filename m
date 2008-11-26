From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 02/14] wd: use net_device_ops
Date: Tue, 25 Nov 2008 17:14:21 -0800
Message-ID: <20081126011545.351440268@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58783 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539AbYKZBSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:46 -0500
Content-Disposition: inline; filename=wd-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another driver converted to net_device_ops; Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/wd.c	2008-11-25 16:23:38.000000000 -0800
+++ b/drivers/net/wd.c	2008-11-25 16:24:48.000000000 -0800
@@ -147,6 +147,20 @@ out:
 }
 #endif
 
+static const struct net_device_ops wd_netdev_ops = {
+	.ndo_open		= wd_open,
+	.ndo_stop		= wd_close,
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller 	= ei_poll,
+#endif
+};
+
 static int __init wd_probe1(struct net_device *dev, int ioaddr)
 {
 	int i;
@@ -331,11 +345,8 @@ static int __init wd_probe1(struct net_d
 	ei_status.block_input = &wd_block_input;
 	ei_status.block_output = &wd_block_output;
 	ei_status.get_8390_hdr = &wd_get_8390_hdr;
-	dev->open = &wd_open;
-	dev->stop = &wd_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+
+	dev->netdev_ops = &wd_netdev_ops;
 	NS8390_init(dev, 0);
 
 #if 1
@@ -365,8 +376,7 @@ wd_open(struct net_device *dev)
 	  outb(ei_status.reg5, ioaddr+WD_CMDREG5);
   outb(ei_status.reg0, ioaddr); /* WD_CMDREG */
 
-  ei_open(dev);
-  return 0;
+  return ei_open(dev);
 }
 
 static void


