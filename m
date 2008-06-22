From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v2 06/11] DM9000: Use NSR to determine link-status on internal PHY
Date: Sun, 22 Jun 2008 21:16:51 +0100
Message-ID: <20080622201905.634022675@fluff.org.uk>
References: <20080622201645.041001353@fluff.org.uk>
Cc: jeff@garzik.org, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:56674 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753886AbYFVUTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:19:08 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-linkstatus1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DM9000_NSR register contains a copy of the internal PHY's
link status which we can use to determine if the link is up
or down. This eliminates the more costly (and sleeping) PHY
read when using the DM9000's own PHY.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-15 23:31:41.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-15 23:38:55.000000000 +0100
@@ -473,7 +473,14 @@ static int dm9000_nway_reset(struct net_
 static u32 dm9000_get_link(struct net_device *dev)
 {
 	board_info_t *dm = to_dm9000_board(dev);
-	return mii_link_ok(&dm->mii);
+	u32 ret;
+
+	if (dm->flags & DM9000_PLATF_EXT_PHY)
+		ret = mii_link_ok(&dm->mii);
+	else
+		ret = dm9000_read_locked(dm, DM9000_NSR) & NSR_LINKST ? 1 : 0;
+
+	return ret;
 }
 
 #define DM_EEPROM_MAGIC		(0x444D394B)

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
