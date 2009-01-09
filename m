From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 31/45] 6pack: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:28 -0800
Message-ID: <20090109230139.002167454@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, ajk@iehk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42243 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466AbZAIXSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:05 -0500
Content-Disposition: inline; filename=6pack.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/hamradio/6pack.c	2009-01-09 10:16:50.000000000 -0800
+++ b/drivers/net/hamradio/6pack.c	2009-01-09 10:17:52.000000000 -0800
@@ -322,23 +322,25 @@ static const struct header_ops sp_header
 	.rebuild	= sp_rebuild_header,
 };
 
+static const struct net_device_ops sp_netdev_ops = {
+	.ndo_open		= sp_open_dev,
+	.ndo_stop		= sp_close,
+	.ndo_start_xmit		= sp_xmit,
+	.ndo_set_mac_address    = sp_set_mac_address,
+};
+
 static void sp_setup(struct net_device *dev)
 {
 	/* Finish setting up the DEVICE info. */
-	dev->mtu		= SIXP_MTU;
-	dev->hard_start_xmit	= sp_xmit;
-	dev->open		= sp_open_dev;
+	dev->netdev_ops		= &sp_netdev_ops;
 	dev->destructor		= free_netdev;
-	dev->stop		= sp_close;
-
-	dev->set_mac_address    = sp_set_mac_address;
+	dev->mtu		= SIXP_MTU;
 	dev->hard_header_len	= AX25_MAX_HEADER_LEN;
 	dev->header_ops 	= &sp_header_ops;
 
 	dev->addr_len		= AX25_ADDR_LEN;
 	dev->type		= ARPHRD_AX25;
 	dev->tx_queue_len	= 10;
-	dev->tx_timeout		= NULL;
 
 	/* Only activated in AX.25 mode */
 	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);


