From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v2 10/11] DM9000: Show Mbps on link change if using simple polling
Date: Sun, 22 Jun 2008 21:16:55 +0100
Message-ID: <20080622201906.526940817@fluff.org.uk>
References: <20080622201645.041001353@fluff.org.uk>
Cc: jeff@garzik.org, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:56686 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754876AbYFVUTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:19:08 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-show-mbits.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show the 10/100Mbps status on link status change if using
the simpler polling code.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-16 00:18:38.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-16 00:22:16.000000000 +0100
@@ -577,10 +577,11 @@ dm9000_poll_work(struct work_struct *w)
 		if (old_carrier != new_carrier) {
 			if (netif_msg_link(db))
 				dev_info(db->dev,
-					 "%s: link changed from %s to %s\n",
+					 "%s: link changed from %s to %s, %dMbps\n",
 					 ndev->name,
 					 dm9000_conv_carrier(old_carrier),
-					 dm9000_conv_carrier(new_carrier));
+					 dm9000_conv_carrier(new_carrier),
+					 (status & NSR_SPEED) ? 10 : 100);
 
 			if (!new_carrier)
 				netif_carrier_off(ndev);

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
