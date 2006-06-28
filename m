From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: fix mac_suspend refcount
Date: Wed, 28 Jun 2006 20:35:17 +0200
Message-ID: <200606282035.17736.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:25754
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750907AbWF1SgA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 14:36:00 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes mac_suspend reference counting for
ifconfig up
ifconfig down
ifconfig up

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-28 20:12:03.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-28 20:31:22.000000000 +0200
@@ -3288,6 +3288,8 @@
 	bcm43xx_lock_noirq(bcm);
 	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
 
+	bcm->mac_suspended = 1;
+
 	err = bcm43xx_pctl_set_crystal(bcm, 1);
 	if (err)
 		goto out;
@@ -3793,7 +3795,6 @@
 	bcm->softmac->set_channel = bcm43xx_ieee80211_set_chan;
 
 	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
-	bcm->mac_suspended = 1;
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;

-- 
Greetings Michael.
