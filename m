From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] sky2: add XL revisions
Date: Mon, 29 Mar 2010 10:36:19 -0700
Message-ID: <20100329173712.700822747@vyatta.com>
References: <20100329173617.765470658@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44276 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754905Ab0C2Rkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 13:40:45 -0400
Content-Disposition: inline; filename=sky2-xl-rev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add definitions for Yukon XL revisions.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.h	2010-03-29 09:25:32.122900699 -0700
+++ b/drivers/net/sky2.h	2010-03-29 09:27:47.582049092 -0700
@@ -548,6 +548,14 @@ enum {
 	CHIP_ID_YUKON_UL_2 = 0xba, /* YUKON-2 Ultra 2 */
 	CHIP_ID_YUKON_OPT  = 0xbc, /* YUKON-2 Optima */
 };
+
+enum yukon_xl_rev {
+	CHIP_REV_YU_XL_A0  = 0,
+	CHIP_REV_YU_XL_A1  = 1,
+	CHIP_REV_YU_XL_A2  = 2,
+	CHIP_REV_YU_XL_A3  = 3,
+};
+
 enum yukon_ec_rev {
 	CHIP_REV_YU_EC_A1    = 0,  /* Chip Rev. for Yukon-EC A1/A0 */
 	CHIP_REV_YU_EC_A2    = 1,  /* Chip Rev. for Yukon-EC A2 */
--- a/drivers/net/sky2.c	2010-03-29 09:27:44.992064516 -0700
+++ b/drivers/net/sky2.c	2010-03-29 09:27:47.582049092 -0700
@@ -226,7 +226,7 @@ static void sky2_power_on(struct sky2_hw
 	/* disable Core Clock Division, */
 	sky2_write32(hw, B2_Y2_CLK_CTRL, Y2_CLK_DIV_DIS);
 
-	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > CHIP_REV_YU_XL_A1)
 		/* enable bits are inverted */
 		sky2_write8(hw, B2_Y2_CLK_GATE,
 			    Y2_PCI_CLK_LNK1_DIS | Y2_COR_CLK_LNK1_DIS |
@@ -268,7 +268,7 @@ static void sky2_power_on(struct sky2_hw
 
 static void sky2_power_aux(struct sky2_hw *hw)
 {
-	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > CHIP_REV_YU_XL_A1)
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 	else
 		/* enable bits are inverted */
@@ -651,7 +651,7 @@ static void sky2_phy_power_up(struct sky
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	reg1 &= ~phy_power[port];
 
-	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > CHIP_REV_YU_XL_A1)
 		reg1 |= coma_mode[port];
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
@@ -823,7 +823,9 @@ static void sky2_mac_init(struct sky2_hw
 
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
 
-	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev == 0 && port == 1) {
+	if (hw->chip_id == CHIP_ID_YUKON_XL &&
+	    hw->chip_rev == CHIP_REV_YU_XL_A0 &&
+	    port == 1) {
 		/* WA DEV_472 -- looks like crossed wires on port 2 */
 		/* clear GMAC 1 Control reset */
 		sky2_write8(hw, SK_REG(0, GMAC_CTRL), GMC_RST_CLR);

-- 

