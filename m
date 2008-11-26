From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 07/14] e2100: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:26 -0800
Message-ID: <20081126011545.758013100@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58799 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbYKZBSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:51 -0500
Content-Disposition: inline; filename=e2100-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/e2100.c	2008-11-25 16:23:37.000000000 -0800
+++ b/drivers/net/e2100.c	2008-11-25 16:50:20.000000000 -0800
@@ -107,7 +107,7 @@ static void e21_block_output(struct net_
 							 const unsigned char *buf, int start_page);
 static void e21_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 							int ring_page);
-
+static int e21_open(struct net_device *dev);
 static int e21_close(struct net_device *dev);
 
 
@@ -160,6 +160,21 @@ out:
 }
 #endif
 
+static const struct net_device_ops e21_netdev_ops = {
+	.ndo_open		= e21_open,
+	.ndo_stop		= e21_close,
+
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
 static int __init e21_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, status, retval;
@@ -265,11 +280,8 @@ static int __init e21_probe1(struct net_
 	ei_status.block_input = &e21_block_input;
 	ei_status.block_output = &e21_block_output;
 	ei_status.get_8390_hdr = &e21_get_8390_hdr;
-	dev->open = &e21_open;
-	dev->stop = &e21_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+
+	dev->netdev_ops = &e21_netdev_ops;
 	NS8390_init(dev, 0);
 
 	retval = register_netdev(dev);


