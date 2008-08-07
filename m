From: Ben Dooks <ben-linux@fluff.org>
Subject: AX88796: Fix locking in ethtool support
Date: Thu, 07 Aug 2008 17:21:09 +0100
Message-ID: <20080807162109.360877609@fluff.org.uk>
Cc: jeff@garzik.org, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:62199 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752491AbYHGQVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 12:21:16 -0400
Content-Disposition: inline; filename=simtec/sparse/sparse-ax88796-locking.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a pair of nasty locking problems in the ax88796 driver
spotted by a sparse check:

warning: context imbalance in 'ax_get_settings' - wrong count at exit
warning: context imbalance in 'ax_set_settings' - wrong count at exit

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.27-rc2-quilt1/drivers/net/ax88796.c
===================================================================
--- linux-2.6.27-rc2-quilt1.orig/drivers/net/ax88796.c	2008-08-07 17:15:01.000000000 +0100
+++ linux-2.6.27-rc2-quilt1/drivers/net/ax88796.c	2008-08-07 17:17:45.000000000 +0100
@@ -554,7 +554,7 @@ static int ax_get_settings(struct net_de
 
 	spin_lock_irqsave(&ax->mii_lock, flags);
 	mii_ethtool_gset(&ax->mii, cmd);
-	spin_lock_irqsave(&ax->mii_lock, flags);
+	spin_unlock_irqrestore(&ax->mii_lock, flags);
 
 	return 0;
 }
@@ -567,7 +567,7 @@ static int ax_set_settings(struct net_de
 
 	spin_lock_irqsave(&ax->mii_lock, flags);
 	rc = mii_ethtool_sset(&ax->mii, cmd);
-	spin_lock_irqsave(&ax->mii_lock, flags);
+	spin_unlock_irqrestore(&ax->mii_lock, flags);
 
 	return rc;
 }

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
