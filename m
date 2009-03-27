From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 16/30] netdev: smc-ultra32 convert to net_device_ops
Date: Thu, 26 Mar 2009 18:11:30 -0700
Message-ID: <20090327011256.098534938@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49168 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761503AbZC0B37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:29:59 -0400
Content-Disposition: inline; filename=smc-ultra32.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/smc-ultra32.c	2009-03-21 12:37:00.000000000 -0700
+++ b/drivers/net/smc-ultra32.c	2009-03-26 16:06:20.737381984 -0700
@@ -153,6 +153,22 @@ out:
 	return ERR_PTR(err);
 }
 
+
+static const struct net_device_ops ultra32_netdev_ops = {
+	.ndo_open 		= ultra32_open,
+	.ndo_stop 		= ultra32_close,
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
 static int __init ultra32_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, edge, media, retval;
@@ -273,11 +289,8 @@ static int __init ultra32_probe1(struct 
 	ei_status.block_output = &ultra32_block_output;
 	ei_status.get_8390_hdr = &ultra32_get_8390_hdr;
 	ei_status.reset_8390 = &ultra32_reset_8390;
-	dev->open = &ultra32_open;
-	dev->stop = &ultra32_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+
+	dev->netdev_ops = &ultra32_netdev_ops;
 	NS8390_init(dev, 0);
 
 	return 0;


