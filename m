From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH] phy/marvell: rename 88ec048 to 88e1318s and fix mscr1 addr
Date: Thu, 28 Oct 2010 11:35:12 -0400
Message-ID: <1288280112-622-1-git-send-email-cyril@ti.com>
Cc: Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:50808 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665Ab0J1PfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 11:35:15 -0400
Received: from dlep36.itg.ti.com ([157.170.170.91])
	by devils.ext.ti.com (8.13.7/8.13.7) with ESMTP id o9SFZFsb019651
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 10:35:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The marvell 88ec048's official part number is 88e1318s.  This patch renames
definitions in the driver to reflect this.

In addition, a minor bug fix has been added to write back the MSCR1 register
value properly.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 drivers/net/phy/marvell.c   |   18 +++++++++---------
 include/linux/marvell_phy.h |    2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 0101f2b..e6ef44c 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -74,8 +74,8 @@
 #define MII_88E1121_PHY_MSCR_TX_DELAY	BIT(4)
 #define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(0x3 << 4))
 
-#define MII_88EC048_PHY_MSCR1_REG	16
-#define MII_88EC048_PHY_MSCR1_PAD_ODD	BIT(6)
+#define MII_88E1318S_PHY_MSCR1_REG	16
+#define MII_88E1318S_PHY_MSCR1_PAD_ODD	BIT(6)
 
 #define MII_88E1121_PHY_LED_CTRL	16
 #define MII_88E1121_PHY_LED_PAGE	3
@@ -233,7 +233,7 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 	return err;
 }
 
-static int m88ec048_config_aneg(struct phy_device *phydev)
+static int m88e1318_config_aneg(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
 
@@ -244,10 +244,10 @@ static int m88ec048_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	mscr = phy_read(phydev, MII_88EC048_PHY_MSCR1_REG);
-	mscr |= MII_88EC048_PHY_MSCR1_PAD_ODD;
+	mscr = phy_read(phydev, MII_88E1318S_PHY_MSCR1_REG);
+	mscr |= MII_88E1318S_PHY_MSCR1_PAD_ODD;
 
-	err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
+	err = phy_write(phydev, MII_88E1318S_PHY_MSCR1_REG, mscr);
 	if (err < 0)
 		return err;
 
@@ -652,12 +652,12 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-		.phy_id = MARVELL_PHY_ID_88EC048,
+		.phy_id = MARVELL_PHY_ID_88E1318S,
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
-		.name = "Marvell 88EC048",
+		.name = "Marvell 88E1318S",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
-		.config_aneg = &m88ec048_config_aneg,
+		.config_aneg = &m88e1318_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
index d0f0801..1ff81b5 100644
--- a/include/linux/marvell_phy.h
+++ b/include/linux/marvell_phy.h
@@ -12,7 +12,7 @@
 #define MARVELL_PHY_ID_88E1121R		0x01410cb0
 #define MARVELL_PHY_ID_88E1145		0x01410cd0
 #define MARVELL_PHY_ID_88E1240		0x01410e30
-#define MARVELL_PHY_ID_88EC048		0x01410e90
+#define MARVELL_PHY_ID_88E1318S		0x01410e90
 
 /* struct phy_device dev_flags definitions */
 #define MARVELL_PHY_M1145_FLAGS_RESISTANCE	0x00000001
-- 
1.7.0.4

