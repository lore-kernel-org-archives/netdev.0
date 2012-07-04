From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH 1/2] [sky2] Added support for Optima EEE
Date: Wed, 04 Jul 2012 11:38:41 +0200
Message-ID: <1341394721.14972.40.camel@mlindner-lin.skd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:57148 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932826Ab2GDJis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 05:38:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds support for the Optima EEE chipset.


Signed-off-by: Mirko Lindner <mlindner@marvell.com>
---
 drivers/net/ethernet/marvell/sky2.c |   14 +++++++++++++-
 drivers/net/ethernet/marvell/sky2.h |    5 +++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 28a5445..f1163b2 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -141,6 +141,7 @@ static DEFINE_PCI_DEVICE_TABLE(sky2_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4370) }, /* 88E8075 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4380) }, /* 88E8057 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4381) }, /* 88E8059 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4382) }, /* 88E8079 */
 	{ 0 }
 };
 
@@ -3349,6 +3350,17 @@ static void sky2_reset(struct sky2_hw *hw)
 			sky2_pci_write16(hw, pdev->pcie_cap + PCI_EXP_LNKCTL,
 					 reg);
 
+		if (hw->chip_id == CHIP_ID_YUKON_PRM &&
+			hw->chip_rev == CHIP_REV_YU_PRM_A0) {
+			/* change PHY Interrupt polarity to low active */
+			reg = sky2_read16(hw, GPHY_CTRL);
+			sky2_write16(hw, GPHY_CTRL, reg | GPC_INTPOL);
+
+			/* adapt HW for low active PHY Interrupt */
+			reg = sky2_read16(hw, Y2_CFG_SPC + PCI_LDO_CTRL);
+			sky2_write16(hw, Y2_CFG_SPC + PCI_LDO_CTRL, reg | PHY_M_UNDOC1);
+		}
+
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 		/* re-enable PEX PM in PEX PHY debug reg. 8 (clear bit 12) */
@@ -4871,7 +4883,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
 		"UL 2",		/* 0xba */
 		"Unknown",	/* 0xbb */
 		"Optima",	/* 0xbc */
-		"Optima Prime", /* 0xbd */
+		"OptimaEEE",    /* 0xbd */
 		"Optima 2",	/* 0xbe */
 	};
 
diff --git a/drivers/net/ethernet/marvell/sky2.h b/drivers/net/ethernet/marvell/sky2.h
index 3c896ce..615ac63 100644
--- a/drivers/net/ethernet/marvell/sky2.h
+++ b/drivers/net/ethernet/marvell/sky2.h
@@ -23,6 +23,7 @@ enum {
 	PSM_CONFIG_REG3  = 0x164,
 	PSM_CONFIG_REG4  = 0x168,
 
+	PCI_LDO_CTRL    = 0xbc,
 };
 
 /* Yukon-2 */
@@ -586,6 +587,10 @@ enum yukon_supr_rev {
 	CHIP_REV_YU_SU_B1    = 3,
 };
 
+enum yukon_prm_rev {
+	CHIP_REV_YU_PRM_Z1   = 1,
+	CHIP_REV_YU_PRM_A0   = 2,
+};
 
 /*	B2_Y2_CLK_GATE	 8 bit	Clock Gating (Yukon-2 only) */
 enum {
-- 
1.7.10.4
