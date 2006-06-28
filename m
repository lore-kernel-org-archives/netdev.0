From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: fix mac_suspend refcount
Date: Wed, 28 Jun 2006 20:38:50 +0200
Message-ID: <200606282038.50903.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:29339
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750907AbWF1SjE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 14:39:04 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes mac_suspend reference counting for
ifconfig up
ifconfig down
ifconfig up

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-17 22:51:20.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-28 20:37:15.000000000 +0200
@@ -3756,6 +3756,8 @@
 	bcm43xx_lock_noirq(bcm);
 	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
 
+	bcm->mac_suspended = 1;
+
 	err = bcm43xx_pctl_set_crystal(bcm, 1);
 	if (err)
 		goto out;
@@ -4383,7 +4385,6 @@
 
 	bcm->ieee = ieee;
 	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
-	bcm->mac_suspended = 1;
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;


-- 
Greetings Michael.
