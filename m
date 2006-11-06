From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx: Add error checking in bcm43xx_sprom_write()
Date: Mon, 06 Nov 2006 09:48:48 -0600
Message-ID: <454F5960.mailHVB136L2I@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.rdc-kc.rr.com ([24.94.166.129]:63724 "EHLO
	ms-smtp-03.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1753264AbWKFPt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 10:49:28 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

The Coverity checker noted that these "if (err)"'s couldn't ever be 
true.

It seems the intention was to check the return values of the 
bcm43xx_pci_write_config32()'s?

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -750,7 +750,7 @@ int bcm43xx_sprom_write(struct bcm43xx_p
 	if (err)
 		goto err_ctlreg;
 	spromctl |= 0x10; /* SPROM WRITE enable. */
-	bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
+	err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
 	if (err)
 		goto err_ctlreg;
 	/* We must burn lots of CPU cycles here, but that does not
@@ -772,7 +772,7 @@ int bcm43xx_sprom_write(struct bcm43xx_p
 		mdelay(20);
 	}
 	spromctl &= ~0x10; /* SPROM WRITE enable. */
-	bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
+	err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
 	if (err)
 		goto err_ctlreg;
 	mdelay(500);
