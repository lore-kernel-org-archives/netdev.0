From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH 1/3] phylib: Basic support for the M88E1121R Marvell chip
Date: Mon, 16 Feb 2009 21:53:49 +0100
Message-ID: <1234817631-7981-1-git-send-email-agust@denx.de>
Cc: Sergei Poselenov <sposelenov@emcraft.com>,
	Yuri Tikhonov <yur@emcraft.com>,
	Anatolij Gustschin <agust@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33615 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbZBPUxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 15:53:54 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Poselenov <sposelenov@emcraft.com>

Signed-off-by: Yuri Tikhonov <yur@emcraft.com>
Signed-off-by: Sergei Poselenov <sposelenov@emcraft.com>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/phy/marvell.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 4aa5479..1d282b0 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -69,6 +69,12 @@
 #define MII_M1111_COPPER		0
 #define MII_M1111_FIBER			1
 
+#define MII_88E1121_PHY_LED_CTRL	16
+#define MII_88E1121_PHY_LED_PAGE	3
+#define MII_88E1121_PHY_LED_DEF		0x0030
+
+#define MII_88E1121_PHY_PAGE		22
+
 #define MII_M1011_PHY_STATUS		0x11
 #define MII_M1011_PHY_STATUS_1000	0x8000
 #define MII_M1011_PHY_STATUS_100	0x4000
@@ -154,6 +160,30 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	return err;
 }
 
+static int m88e1121_config_aneg(struct phy_device *phydev)
+{
+	int err, temp;
+
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, MII_M1011_PHY_SCR,
+			MII_M1011_PHY_SCR_AUTO_CROSS);
+	if (err < 0)
+		return err;
+
+	temp = phy_read(phydev, MII_88E1121_PHY_PAGE);
+
+	phy_write(phydev, MII_88E1121_PHY_PAGE, MII_88E1121_PHY_LED_PAGE);
+	phy_write(phydev, MII_88E1121_PHY_LED_CTRL, MII_88E1121_PHY_LED_DEF);
+	phy_write(phydev, MII_88E1121_PHY_PAGE, temp);
+
+	err = genphy_config_aneg(phydev);
+
+	return err;
+}
+
 static int m88e1111_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -416,6 +446,18 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
+		.phy_id = 0x01410cb0,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1121R",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_aneg = &m88e1121_config_aneg,
+		.read_status = &marvell_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = { .owner = THIS_MODULE },
+	},
+	{
 		.phy_id = 0x01410cd0,
 		.phy_id_mask = 0xfffffff0,
 		.name = "Marvell 88E1145",
-- 
1.5.4.3

