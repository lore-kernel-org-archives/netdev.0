From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/42] plip: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:23 -0800
Message-ID: <20090107003346.232090962@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59000 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755318AbZAGAxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:23 -0500
Content-Disposition: inline; filename=plip.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/plip.c	2009-01-05 16:54:45.381820105 -0800
+++ b/drivers/net/plip.c	2009-01-05 16:59:08.254569570 -0800
@@ -265,6 +265,13 @@ static const struct header_ops plip_head
 	.cache  = plip_hard_header_cache,
 };
 
+static const struct net_device_ops plip_netdev_ops = {
+	.ndo_open		 = plip_open,
+	.ndo_stop		 = plip_close,
+	.ndo_start_xmit		 = plip_tx_packet,
+	.ndo_do_ioctl		 = plip_ioctl,
+};
+
 /* Entry point of PLIP driver.
    Probe the hardware, and register/initialize the driver.
 
@@ -280,15 +287,11 @@ plip_init_netdev(struct net_device *dev)
 	struct net_local *nl = netdev_priv(dev);
 
 	/* Then, override parts of it */
-	dev->hard_start_xmit	 = plip_tx_packet;
-	dev->open		 = plip_open;
-	dev->stop		 = plip_close;
-	dev->do_ioctl		 = plip_ioctl;
-
 	dev->tx_queue_len 	 = 10;
 	dev->flags	         = IFF_POINTOPOINT|IFF_NOARP;
 	memset(dev->dev_addr, 0xfc, ETH_ALEN);
 
+	dev->netdev_ops		 = &plip_netdev_ops;
 	dev->header_ops          = &plip_header_ops;
 
 

-- 

