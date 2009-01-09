From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 44/45] dmascc: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:41 -0800
Message-ID: <20090109230140.010301729@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42282 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754801AbZAIXSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:11 -0500
Content-Disposition: inline; filename=mkiss-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/hamradio/mkiss.c	2009-01-09 12:57:32.000000000 -0800
+++ b/drivers/net/hamradio/mkiss.c	2009-01-09 12:58:45.000000000 -0800
@@ -667,19 +667,23 @@ static const struct header_ops ax_header
 	.rebuild   = ax_rebuild_header,
 };
 
+static const struct net_device_ops ax_netdev_ops = {
+	.ndo_open            = ax_open_dev,
+	.ndo_stop            = ax_close,
+	.ndo_start_xmit	     = ax_xmit,
+	.ndo_set_mac_address = ax_set_mac_address,
+};
+
 static void ax_setup(struct net_device *dev)
 {
 	/* Finish setting up the DEVICE info. */
 	dev->mtu             = AX_MTU;
-	dev->hard_start_xmit = ax_xmit;
-	dev->open            = ax_open_dev;
-	dev->stop            = ax_close;
-	dev->set_mac_address = ax_set_mac_address;
 	dev->hard_header_len = 0;
 	dev->addr_len        = 0;
 	dev->type            = ARPHRD_AX25;
 	dev->tx_queue_len    = 10;
 	dev->header_ops      = &ax_header_ops;
+	dev->netdev_ops	     = &ax_netdev_ops;
 
 
 	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);


