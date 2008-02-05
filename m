From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 22/24 for-2.6.25] DM9000: Add support for MII ioctl() calls
Date: Tue, 05 Feb 2008 00:02:21 +0000
Message-ID: <20080205000818.947078834@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58740 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758856AbYBEAIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:25 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-mii-ioctl.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add entry to handle the MII ioctl() calls via the
generic_mii_ioctl call.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -142,6 +142,7 @@ static int dm9000_probe(struct platform_
 static int dm9000_open(struct net_device *);
 static int dm9000_start_xmit(struct sk_buff *, struct net_device *);
 static int dm9000_stop(struct net_device *);
+static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd);
 
 static void dm9000_init_dm9000(struct net_device *);
 
@@ -332,6 +333,16 @@ static void dm9000_poll_controller(struc
 }
 #endif
 
+static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
+}
+
 /* ethtool ops */
 
 static void dm9000_get_drvinfo(struct net_device *dev,
@@ -661,6 +672,7 @@ dm9000_probe(struct platform_device *pde
 	ndev->stop		 = &dm9000_stop;
 	ndev->set_multicast_list = &dm9000_hash_table;
 	ndev->ethtool_ops	 = &dm9000_ethtool_ops;
+	ndev->do_ioctl		 = &dm9000_ioctl;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller	 = &dm9000_poll_controller;

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
