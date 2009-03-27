From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 28/30] netdev: convert lp486e to net_device_ops
Date: Thu, 26 Mar 2009 18:11:42 -0700
Message-ID: <20090327011256.955660005@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46970 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763264AbZC0BgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:36:11 -0400
Content-Disposition: inline; filename=lp486e.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/lp486e.c	2009-03-21 12:36:59.000000000 -0700
+++ b/drivers/net/lp486e.c	2009-03-26 17:34:26.362370494 -0700
@@ -952,6 +952,17 @@ static void print_eth(char *add)
 		(unsigned char) add[12], (unsigned char) add[13]);
 }
 
+static const struct net_device_ops i596_netdev_ops = {
+	.ndo_open		= i596_open,
+	.ndo_stop		= i596_close,
+	.ndo_start_xmit		= i596_start_xmit,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_tx_timeout		= i596_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init lp486e_probe(struct net_device *dev) {
 	struct i596_private *lp;
 	unsigned char eth_addr[6] = { 0, 0xaa, 0, 0, 0, 0 };
@@ -1014,12 +1025,8 @@ static int __init lp486e_probe(struct ne
 	printk("\n");
 
 	/* The LP486E-specific entries in the device structure. */
-	dev->open = &i596_open;
-	dev->stop = &i596_close;
-	dev->hard_start_xmit = &i596_start_xmit;
-	dev->set_multicast_list = &set_multicast_list;
+	dev->netdev_ops = &i596_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
-	dev->tx_timeout = i596_tx_timeout;
 
 #if 0
 	/* selftest reports 0x320925ae - don't know what that means */


