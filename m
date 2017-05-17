From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 5/6] net: phy: marvell: Add helpers to get/set page
Date: Wed, 17 May 2017 03:26:03 +0200
Message-ID: <1494984364-19496-6-git-send-email-andrew@lunn.ch>
References: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32789 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751104AbdEQB00 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 21:26:26 -0400
In-Reply-To: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes the code a bit more readable, and solves quite a few checkpatch
warnings of lines longer than 80 characters.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 115 ++++++++++++++++++++++++----------------------
 1 file changed, 59 insertions(+), 56 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index b84380db945e..d510eda92af5 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -189,6 +189,16 @@ struct marvell_priv {
 	struct device *hwmon_dev;
 };
 
+static int marvell_get_page(struct phy_device *phydev)
+{
+	return phy_read(phydev, MII_MARVELL_PHY_PAGE);
+}
+
+static int marvell_set_page(struct phy_device *phydev, int page)
+{
+	return phy_write(phydev, MII_MARVELL_PHY_PAGE, page);
+}
+
 static int marvell_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -385,7 +395,7 @@ static int marvell_of_reg_init(struct phy_device *phydev)
 	if (!paddr || len < (4 * sizeof(*paddr)))
 		return 0;
 
-	saved_page = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+	saved_page = marvell_get_page(phydev);
 	if (saved_page < 0)
 		return saved_page;
 	current_page = saved_page;
@@ -393,15 +403,15 @@ static int marvell_of_reg_init(struct phy_device *phydev)
 	ret = 0;
 	len /= sizeof(*paddr);
 	for (i = 0; i < len - 3; i += 4) {
-		u16 reg_page = be32_to_cpup(paddr + i);
+		u16 page = be32_to_cpup(paddr + i);
 		u16 reg = be32_to_cpup(paddr + i + 1);
 		u16 mask = be32_to_cpup(paddr + i + 2);
 		u16 val_bits = be32_to_cpup(paddr + i + 3);
 		int val;
 
-		if (reg_page != current_page) {
-			current_page = reg_page;
-			ret = phy_write(phydev, MII_MARVELL_PHY_PAGE, reg_page);
+		if (page != current_page) {
+			current_page = page;
+			ret = marvell_set_page(phydev, page);
 			if (ret < 0)
 				goto err;
 		}
@@ -423,7 +433,7 @@ static int marvell_of_reg_init(struct phy_device *phydev)
 	}
 err:
 	if (current_page != saved_page) {
-		i = phy_write(phydev, MII_MARVELL_PHY_PAGE, saved_page);
+		i = marvell_set_page(phydev, saved_page);
 		if (ret == 0)
 			ret = i;
 	}
@@ -440,10 +450,9 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
 
-	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+	oldpage = marvell_get_page(phydev);
 
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
-			MII_88E1121_PHY_MSCR_PAGE);
+	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
 	if (err < 0)
 		return err;
 
@@ -464,7 +473,7 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 			return err;
 	}
 
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+	marvell_set_page(phydev, oldpage);
 
 	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
 	if (err < 0)
@@ -482,10 +491,9 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
 
-	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+	oldpage = marvell_get_page(phydev);
 
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
-			MII_88E1121_PHY_MSCR_PAGE);
+	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
 	if (err < 0)
 		return err;
 
@@ -496,7 +504,7 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+	err = marvell_set_page(phydev, oldpage);
 	if (err < 0)
 		return err;
 
@@ -596,7 +604,7 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 {
 	int err;
 
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	err = marvell_set_page(phydev, MII_M1111_COPPER);
 	if (err < 0)
 		goto error;
 
@@ -606,7 +614,7 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 		goto error;
 
 	/* Then the fiber link */
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+	err = marvell_set_page(phydev, MII_M1111_FIBER);
 	if (err < 0)
 		goto error;
 
@@ -614,10 +622,10 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		goto error;
 
-	return phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return marvell_set_page(phydev, MII_M1111_COPPER);
 
 error:
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	marvell_set_page(phydev, MII_M1111_COPPER);
 	return err;
 }
 
@@ -640,7 +648,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 
 	mdelay(500);
 
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
+	err = marvell_set_page(phydev, 0);
 	if (err < 0)
 		return err;
 
@@ -652,7 +660,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 2);
+	err = marvell_set_page(phydev, 2);
 	if (err < 0)
 		return err;
 	temp = phy_read(phydev, MII_M1116R_CONTROL_REG_MAC);
@@ -661,7 +669,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	err = phy_write(phydev, MII_M1116R_CONTROL_REG_MAC, temp);
 	if (err < 0)
 		return err;
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
+	err = marvell_set_page(phydev, 0);
 	if (err < 0)
 		return err;
 
@@ -837,9 +845,9 @@ static int m88e1121_config_init(struct phy_device *phydev)
 {
 	int err, oldpage;
 
-	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+	oldpage = marvell_get_page(phydev);
 
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_88E1121_PHY_LED_PAGE);
+	err = marvell_set_page(phydev, MII_88E1121_PHY_LED_PAGE);
 	if (err < 0)
 		return err;
 
@@ -849,7 +857,7 @@ static int m88e1121_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+	marvell_set_page(phydev, oldpage);
 
 	/* Set marvell,reg-init configuration from device tree */
 	return marvell_config_init(phydev);
@@ -863,7 +871,7 @@ static int m88e1510_config_init(struct phy_device *phydev)
 	/* SGMII-to-Copper mode initialization */
 	if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
 		/* Select page 18 */
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 18);
+		err = marvell_set_page(phydev, 18);
 		if (err < 0)
 			return err;
 
@@ -882,7 +890,7 @@ static int m88e1510_config_init(struct phy_device *phydev)
 			return err;
 
 		/* Reset page selection */
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
+		err = marvell_set_page(phydev, 0);
 		if (err < 0)
 			return err;
 	}
@@ -912,7 +920,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 	int err;
 
 	/* Change address */
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0002);
+	err = marvell_set_page(phydev, 2);
 	if (err < 0)
 		return err;
 
@@ -922,7 +930,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Change address */
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0003);
+	err = marvell_set_page(phydev, 3);
 	if (err < 0)
 		return err;
 
@@ -939,7 +947,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Reset address */
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0);
+	err = marvell_set_page(phydev, 0);
 	if (err < 0)
 		return err;
 
@@ -951,7 +959,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 	int err;
 
 	/* Change address */
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0002);
+	err = marvell_set_page(phydev, 2);
 	if (err < 0)
 		return err;
 
@@ -965,7 +973,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Reset address */
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0);
+	err = marvell_set_page(phydev, 0);
 	if (err < 0)
 		return err;
 
@@ -1268,7 +1276,7 @@ static int marvell_read_status(struct phy_device *phydev)
 	/* Check the fiber mode first */
 	if (phydev->supported & SUPPORTED_FIBRE &&
 	    phydev->interface != PHY_INTERFACE_MODE_SGMII) {
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+		err = marvell_set_page(phydev, MII_M1111_FIBER);
 		if (err < 0)
 			goto error;
 
@@ -1287,7 +1295,7 @@ static int marvell_read_status(struct phy_device *phydev)
 			return 0;
 
 		/* If fiber link is down, check and save copper mode state */
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+		err = marvell_set_page(phydev, MII_M1111_COPPER);
 		if (err < 0)
 			goto error;
 	}
@@ -1295,7 +1303,7 @@ static int marvell_read_status(struct phy_device *phydev)
 	return marvell_read_status_page(phydev, MII_M1111_COPPER);
 
 error:
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	marvell_set_page(phydev, MII_M1111_COPPER);
 	return err;
 }
 
@@ -1310,7 +1318,7 @@ static int marvell_suspend(struct phy_device *phydev)
 
 	/* Suspend the fiber mode first */
 	if (!(phydev->supported & SUPPORTED_FIBRE)) {
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+		err = marvell_set_page(phydev, MII_M1111_FIBER);
 		if (err < 0)
 			goto error;
 
@@ -1320,7 +1328,7 @@ static int marvell_suspend(struct phy_device *phydev)
 			goto error;
 
 		/* Then, the copper link */
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+		err = marvell_set_page(phydev, MII_M1111_COPPER);
 		if (err < 0)
 			goto error;
 	}
@@ -1329,7 +1337,7 @@ static int marvell_suspend(struct phy_device *phydev)
 	return genphy_suspend(phydev);
 
 error:
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	marvell_set_page(phydev, MII_M1111_COPPER);
 	return err;
 }
 
@@ -1344,7 +1352,7 @@ static int marvell_resume(struct phy_device *phydev)
 
 	/* Resume the fiber mode first */
 	if (!(phydev->supported & SUPPORTED_FIBRE)) {
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+		err = marvell_set_page(phydev, MII_M1111_FIBER);
 		if (err < 0)
 			goto error;
 
@@ -1354,7 +1362,7 @@ static int marvell_resume(struct phy_device *phydev)
 			goto error;
 
 		/* Then, the copper link */
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+		err = marvell_set_page(phydev, MII_M1111_COPPER);
 		if (err < 0)
 			goto error;
 	}
@@ -1363,7 +1371,7 @@ static int marvell_resume(struct phy_device *phydev)
 	return genphy_resume(phydev);
 
 error:
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	marvell_set_page(phydev, MII_M1111_COPPER);
 	return err;
 }
 
@@ -1391,15 +1399,14 @@ static void m88e1318_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *
 	wol->supported = WAKE_MAGIC;
 	wol->wolopts = 0;
 
-	if (phy_write(phydev, MII_MARVELL_PHY_PAGE,
-		      MII_88E1318S_PHY_WOL_PAGE) < 0)
+	if (marvell_set_page(phydev, MII_88E1318S_PHY_WOL_PAGE) < 0)
 		return;
 
 	if (phy_read(phydev, MII_88E1318S_PHY_WOL_CTRL) &
 	    MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE)
 		wol->wolopts |= WAKE_MAGIC;
 
-	if (phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x00) < 0)
+	if (marvell_set_page(phydev, 0x00) < 0)
 		return;
 }
 
@@ -1407,11 +1414,11 @@ static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *w
 {
 	int err, oldpage, temp;
 
-	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+	oldpage = marvell_get_page(phydev);
 
 	if (wol->wolopts & WAKE_MAGIC) {
 		/* Explicitly switch to page 0x00, just to be sure */
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x00);
+		err = marvell_set_page(phydev, 0x00);
 		if (err < 0)
 			return err;
 
@@ -1422,8 +1429,7 @@ static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *w
 		if (err < 0)
 			return err;
 
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
-				MII_88E1318S_PHY_LED_PAGE);
+		err = marvell_set_page(phydev, MII_88E1318S_PHY_LED_PAGE);
 		if (err < 0)
 			return err;
 
@@ -1436,8 +1442,7 @@ static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *w
 		if (err < 0)
 			return err;
 
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
-				MII_88E1318S_PHY_WOL_PAGE);
+		err = marvell_set_page(phydev, MII_88E1318S_PHY_WOL_PAGE);
 		if (err < 0)
 			return err;
 
@@ -1466,8 +1471,7 @@ static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *w
 		if (err < 0)
 			return err;
 	} else {
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
-				MII_88E1318S_PHY_WOL_PAGE);
+		err = marvell_set_page(phydev, MII_88E1318S_PHY_WOL_PAGE);
 		if (err < 0)
 			return err;
 
@@ -1480,7 +1484,7 @@ static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *w
 			return err;
 	}
 
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+	err = marvell_set_page(phydev, oldpage);
 	if (err < 0)
 		return err;
 
@@ -1515,9 +1519,8 @@ static u64 marvell_get_stat(struct phy_device *phydev, int i)
 	int err, oldpage, val;
 	u64 ret;
 
-	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
-			stat.page);
+	oldpage = marvell_get_page(phydev);
+	err = marvell_set_page(phydev, stat.page);
 	if (err < 0)
 		return UINT64_MAX;
 
@@ -1530,7 +1533,7 @@ static u64 marvell_get_stat(struct phy_device *phydev, int i)
 		ret = priv->stats[i];
 	}
 
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+	marvell_set_page(phydev, oldpage);
 
 	return ret;
 }
-- 
2.11.0
