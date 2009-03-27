From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 29/30] netdev: convert cs89x0 to net_device_ops
Date: Thu, 26 Mar 2009 18:11:43 -0700
Message-ID: <20090327011257.031146206@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46973 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754034AbZC0Bgm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:36:42 -0400
Content-Disposition: inline; filename=cs89x0.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/cs89x0.c	2009-03-26 17:33:56.530589221 -0700
+++ b/drivers/net/cs89x0.c	2009-03-26 17:41:12.972344319 -0700
@@ -501,6 +501,21 @@ static void net_poll_controller(struct n
 }
 #endif
 
+static const struct net_device_ops net_ops = {
+	.ndo_open		= net_open,
+	.ndo_stop		= net_close,
+	.ndo_tx_timeout		= net_timeout,
+	.ndo_start_xmit 	= net_send_packet,
+	.ndo_get_stats		= net_get_stats,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_mac_address 	= set_mac_address,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= net_poll_controller,
+#endif
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* This is the real probe routine.  Linux has a history of friendly device
    probes on the ISA bus.  A good device probes avoids doing writes, and
    verifies that the correct device exists and functions.
@@ -843,17 +858,8 @@ cs89x0_probe1(struct net_device *dev, in
 	/* print the ethernet address. */
 	printk(", MAC %pM", dev->dev_addr);
 
-	dev->open		= net_open;
-	dev->stop		= net_close;
-	dev->tx_timeout		= net_timeout;
-	dev->watchdog_timeo	= HZ;
-	dev->hard_start_xmit 	= net_send_packet;
-	dev->get_stats		= net_get_stats;
-	dev->set_multicast_list = set_multicast_list;
-	dev->set_mac_address 	= set_mac_address;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller	= net_poll_controller;
-#endif
+	dev->netdev_ops	= &net_ops;
+	dev->watchdog_timeo = HZ;
 
 	printk("\n");
 	if (net_debug)


