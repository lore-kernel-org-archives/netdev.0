From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 27/30] netdev: convert ac3200 to net_device_ops
Date: Thu, 26 Mar 2009 18:11:41 -0700
Message-ID: <20090327011256.899179433@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46967 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763193AbZC0Bfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:35:41 -0400
Content-Disposition: inline; filename=ac3200.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ac3200.c	2009-03-21 12:36:56.000000000 -0700
+++ b/drivers/net/ac3200.c	2009-03-26 17:27:06.650598956 -0700
@@ -143,6 +143,22 @@ out:
 }
 #endif
 
+static const struct net_device_ops ac_netdev_ops = {
+	.ndo_open		= ac_open,
+	.ndo_stop 		= ac_close_card,
+
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ei_poll,
+#endif
+};
+
 static int __init ac_probe1(int ioaddr, struct net_device *dev)
 {
 	int i, retval;
@@ -253,11 +269,7 @@ static int __init ac_probe1(int ioaddr, 
 	ei_status.block_output = &ac_block_output;
 	ei_status.get_8390_hdr = &ac_get_8390_hdr;
 
-	dev->open = &ac_open;
-	dev->stop = &ac_close_card;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+	dev->netdev_ops = &ac_netdev_ops;
 	NS8390_init(dev, 0);
 
 	retval = register_netdev(dev);


