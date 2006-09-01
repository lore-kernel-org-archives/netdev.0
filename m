From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC] Patch to add board revision to the WLAN chip_id printout
Date: Fri, 01 Sep 2006 10:28:07 -0500
Message-ID: <44F85187.3010707@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefano Brivio <st3@riseup.net>, netdev@vger.kernel.org,
	Broadcom Linux <bcm43xx-dev@lists.berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:40377 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751349AbWIAP2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 11:28:11 -0400
To: Michael Buesch <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

This patch includes the board revision in the chip_id printk for the ssb version of bcm43xx-d80211 
and is meant to be applied to wireless-dev. As we have seen, behavior of the chips can be dependent 
on the rev level, thus a need to have it in the log.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3346,7 +3346,8 @@ static int bcm43xx_attach_board(struct b
  	if (err)
  		goto err_chipset_detach;

-	printk(KERN_INFO PFX "Broadcom %04X WLAN found\n", bcm->ssb.chip_id);
+	printk(KERN_INFO PFX "Broadcom %04X WLAN, Revision %d found\n",
+		bcm->ssb.chip_id, bcm->board_revision);

  	/* Attach all IO cores to the backplane. */
  	coremask = 0;
