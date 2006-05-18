From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 05/10] [RFT] bcm43xx: wireless core initialization for PCI-E devices
Date: Fri, 19 May 2006 00:00:05 +0200
Message-ID: <20060519155703.281042000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:54650 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932370AbWESP5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:57:06 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-80211init.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix wireless core initialization in order to work with PCI-E devices.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2832,16 +2832,11 @@ static int bcm43xx_wireless_core_init(st
 	u32 sbimconfiglow;
 	u8 limit;
 
-	if (bcm->chip_rev < 5) {
+	if (bcm->core_pci.rev <= 5 && bcm->core_pci.id != BCM43xx_COREID_PCIE) {
 		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
-			sbimconfiglow |= 0x32;
-		else if (bcm->bustype == BCM43xx_BUSTYPE_SB)
-			sbimconfiglow |= 0x53;
-		else
-			assert(0);
+		sbimconfiglow |= 0x32;
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
 	}
 

--
Ciao
Stefano
