From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 7/8] r6040: define and use bits of register PHY_CC
Date: Wed, 11 Apr 2012 19:18:42 +0200
Message-ID: <1334164723-9627-8-git-send-email-florian@openwrt.org>
References: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45812 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760777Ab2DKRUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 13:20:14 -0400
In-Reply-To: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define and use the bits of the PHY_CC (status change configuration) register.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index afa4186..050cf59 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -128,6 +128,9 @@
 #define MID_3M		0x82	/* MID3 Medium */
 #define MID_3H		0x84	/* MID3 High */
 #define PHY_CC		0x88	/* PHY status change configuration register */
+#define  SCEN		0x8000	/* PHY status change enable */
+#define  PHYAD_SHIFT	8	/* PHY address shift */
+#define  TMRDIV_SHIFT	0	/* Timer divider shift */
 #define PHY_ST		0x8A	/* PHY status register */
 #define MAC_SM		0xAC	/* MAC status machine */
 #define  MAC_SM_RST	0x0002	/* MAC status machine reset */
@@ -1132,10 +1135,15 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 		err = -EIO;
 		goto err_out_free_res;
 	}
+
 	/* If PHY status change register is still set to zero it means the
-	 * bootloader didn't initialize it */
+	 * bootloader didn't initialize it, so we set it to:
+	 * - enable phy status change
+	 * - enable all phy addresses
+	 * - set to lowest timer divider */
 	if (ioread16(ioaddr + PHY_CC) == 0)
-		iowrite16(0x9f07, ioaddr + PHY_CC);
+		iowrite16(SCEN | PHY_MAX_ADDR << PHYAD_SHIFT |
+				7 << TMRDIV_SHIFT, ioaddr + PHY_CC);
 
 	/* Init system & device */
 	lp->base = ioaddr;
-- 
1.7.5.4
