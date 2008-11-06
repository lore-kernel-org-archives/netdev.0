From: Ron Madrid <ron_madrid@sbcglobal.net>
Subject: [PATCH] Add support for Marvell 88E1118 PHY
Date: Thu,  6 Nov 2008 11:05:26 -0800
Message-ID: <1225998326-4367-1-git-send-email-ron_madrid@sbcglobal.net>
Cc: Ron Madrid <ron_madrid@sbcglobal.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:35504 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751080AbYKFTJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 14:09:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch will add support for the Marvell 88E1118 PHY which supports gigabit ethernet among other things.

Signed-off-by: Ron Madrid <ron_madrid@sbcglobal.net>
---
 drivers/net/phy/marvell.c |   66 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 4aa5479..eb6411c 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -227,6 +227,59 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int m88e1118_config_aneg(struct phy_device *phydev)
+{
+	int err;
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
+	err = genphy_config_aneg(phydev);
+	return 0;
+}
+
+static int m88e1118_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	/* Change address */
+	err = phy_write(phydev, 0x16, 0x0002);
+	if (err < 0)
+		return err;
+
+	/* Enable 1000 Mbit */
+	err = phy_write(phydev, 0x15, 0x1070);
+	if (err < 0)
+		return err;
+
+	/* Change address */
+	err = phy_write(phydev, 0x16, 0x0003);
+	if (err < 0)
+		return err;
+
+	/* Adjust LED Control */
+	err = phy_write(phydev, 0x10, 0x021e);
+	if (err < 0)
+		return err;
+
+	/* Reset address */
+	err = phy_write(phydev, 0x16, 0x0);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
 static int m88e1145_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -416,6 +469,19 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
+		.phy_id = 0x01410e10,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1118",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1118_config_init,
+		.config_aneg = &m88e1118_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	},
+	{
 		.phy_id = 0x01410cd0,
 		.phy_id_mask = 0xfffffff0,
 		.name = "Marvell 88E1145",
-- 
1.5.5.1

