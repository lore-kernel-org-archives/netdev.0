From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 03/10] [RFT] bcm43xx: fix reading core ID and revision from sb_id_hi
Date: Fri, 19 May 2006 00:00:03 +0200
Message-ID: <20060519155641.412138000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:18805 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932360AbWESP4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:56:43 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-find_core_id.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix reading core ID and revision from sb_id_hi.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2565,8 +2565,8 @@ static int bcm43xx_probe_cores(struct bc
 	/* fetch sb_id_hi from core information registers */
 	sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
 
-	core_id = (sb_id_hi & 0xFFF0) >> 4;
-	core_rev = (sb_id_hi & 0xF);
+	core_id = (sb_id_hi & 0x8FF0) >> 4;
+	core_rev = (sb_id_hi & 0x7000) >> 8 | (sb_id_hi & 0xF);
 	core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
 	/* if present, chipcommon is always core 0; read the chipid from it */

--
Ciao
Stefano
