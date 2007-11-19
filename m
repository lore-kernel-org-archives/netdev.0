From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 20/22] NET: DM9000: Add support for MII ioctl() calls
Date: Mon, 19 Nov 2007 20:39:30 +0000
Message-ID: <20071119204016.148267229@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61661 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751762AbXKSVOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:14:25 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-mii-ioctl.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add entry to handle the MII ioctl() calls via the
generic_mii_ioctl call.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -148,6 +148,8 @@ static int dm9000_mii_thread(void *data)
 
 static void dm9000_init_dm9000(struct net_device *);
 
+static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd);
+
 static struct net_device_stats *dm9000_get_stats(struct net_device *);
 
 static irqreturn_t dm9000_interrupt(int, void *);
@@ -337,6 +339,16 @@ static void dm9000_poll_controller(struc
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
@@ -669,6 +681,7 @@ dm9000_probe(struct platform_device *pde
 	ndev->get_stats		 = &dm9000_get_stats;
 	ndev->set_multicast_list = &dm9000_hash_table;
 	ndev->ethtool_ops	 = &dm9000_ethtool_ops;
+	ndev->do_ioctl		 = &dm9000_ioctl;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller	 = &dm9000_poll_controller;

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
