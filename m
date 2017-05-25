From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 4/4] net: phy: marvell: Uniform page names
Date: Thu, 25 May 2017 21:42:08 +0200
Message-ID: <1495741328-25001-5-git-send-email-andrew@lunn.ch>
References: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44916 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762536AbdEYTnI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 15:43:08 -0400
In-Reply-To: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bring all the page names together, remove the repeats, and make them
uniform.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 94 +++++++++++++++++++++++------------------------
 1 file changed, 46 insertions(+), 48 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index ed338af61cdd..2bd83920f565 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -41,6 +41,12 @@
 #include <linux/uaccess.h>
 
 #define MII_MARVELL_PHY_PAGE		22
+#define MII_MARVELL_COPPER_PAGE		0x00
+#define MII_MARVELL_FIBER_PAGE		0x01
+#define MII_MARVELL_MSCR_PAGE		0x02
+#define MII_MARVELL_LED_PAGE		0x03
+#define MII_MARVELL_MISC_TEST_PAGE	0x06
+#define MII_MARVELL_WOL_PAGE		0x11
 
 #define MII_M1011_IEVENT		0x13
 #define MII_M1011_IEVENT_CLEAR		0x0000
@@ -82,16 +88,11 @@
 #define MII_M1111_HWCFG_FIBER_COPPER_AUTO	0x8000
 #define MII_M1111_HWCFG_FIBER_COPPER_RES	0x2000
 
-#define MII_M1111_COPPER		0
-#define MII_M1111_FIBER			1
-
-#define MII_88E1121_PHY_MSCR_PAGE	2
 #define MII_88E1121_PHY_MSCR_REG	21
 #define MII_88E1121_PHY_MSCR_RX_DELAY	BIT(5)
 #define MII_88E1121_PHY_MSCR_TX_DELAY	BIT(4)
 #define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(0x3 << 4))
 
-#define MII_88E1121_MISC_TEST_PAGE			6
 #define MII_88E1121_MISC_TEST				0x1a
 #define MII_88E1510_MISC_TEST_TEMP_THRESHOLD_MASK	0x1f00
 #define MII_88E1510_MISC_TEST_TEMP_THRESHOLD_SHIFT	8
@@ -112,7 +113,6 @@
 #define MII_88E1318S_PHY_CSIER_WOL_EIE                      BIT(7)
 
 /* LED Timer Control Register */
-#define MII_88E1318S_PHY_LED_PAGE                           0x03
 #define MII_88E1318S_PHY_LED_TCR                            0x12
 #define MII_88E1318S_PHY_LED_TCR_FORCE_INT                  BIT(15)
 #define MII_88E1318S_PHY_LED_TCR_INTn_ENABLE                BIT(7)
@@ -123,13 +123,11 @@
 #define MII_88E1318S_PHY_MAGIC_PACKET_WORD1                 0x18
 #define MII_88E1318S_PHY_MAGIC_PACKET_WORD0                 0x19
 
-#define MII_88E1318S_PHY_WOL_PAGE                           0x11
 #define MII_88E1318S_PHY_WOL_CTRL                           0x10
 #define MII_88E1318S_PHY_WOL_CTRL_CLEAR_WOL_STATUS          BIT(12)
 #define MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE BIT(14)
 
 #define MII_88E1121_PHY_LED_CTRL	16
-#define MII_88E1121_PHY_LED_PAGE	3
 #define MII_88E1121_PHY_LED_DEF		0x0030
 
 #define MII_M1011_PHY_STATUS		0x11
@@ -465,7 +463,7 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
 
-	oldpage = marvell_get_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
+	oldpage = marvell_get_set_page(phydev, MII_MARVELL_MSCR_PAGE);
 	if (oldpage < 0)
 		return oldpage;
 
@@ -504,7 +502,7 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
 
-	oldpage = marvell_get_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
+	oldpage = marvell_get_set_page(phydev, MII_MARVELL_MSCR_PAGE);
 	if (oldpage < 0)
 		return oldpage;
 
@@ -615,7 +613,7 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 {
 	int err;
 
-	err = marvell_set_page(phydev, MII_M1111_COPPER);
+	err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	if (err < 0)
 		goto error;
 
@@ -625,7 +623,7 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 		goto error;
 
 	/* Then the fiber link */
-	err = marvell_set_page(phydev, MII_M1111_FIBER);
+	err = marvell_set_page(phydev, MII_MARVELL_FIBER_PAGE);
 	if (err < 0)
 		goto error;
 
@@ -633,10 +631,10 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		goto error;
 
-	return marvell_set_page(phydev, MII_M1111_COPPER);
+	return marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 
 error:
-	marvell_set_page(phydev, MII_M1111_COPPER);
+	marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	return err;
 }
 
@@ -659,7 +657,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 
 	mdelay(500);
 
-	err = marvell_set_page(phydev, MII_M1111_COPPER);
+	err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	if (err < 0)
 		return err;
 
@@ -671,7 +669,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
+	err = marvell_set_page(phydev, MII_MARVELL_MSCR_PAGE);
 	if (err < 0)
 		return err;
 	temp = phy_read(phydev, MII_M1116R_CONTROL_REG_MAC);
@@ -680,7 +678,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	err = phy_write(phydev, MII_M1116R_CONTROL_REG_MAC, temp);
 	if (err < 0)
 		return err;
-	err = marvell_set_page(phydev, MII_M1111_COPPER);
+	err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	if (err < 0)
 		return err;
 
@@ -769,7 +767,7 @@ static int m88e1111_config_init_sgmii(struct phy_device *phydev)
 		return err;
 
 	/* make sure copper is selected */
-	return marvell_set_page(phydev, MII_M1111_COPPER);
+	return marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 }
 
 static int m88e1111_config_init_rtbi(struct phy_device *phydev)
@@ -852,7 +850,7 @@ static int m88e1121_config_init(struct phy_device *phydev)
 {
 	int err, oldpage;
 
-	oldpage = marvell_get_set_page(phydev, MII_88E1121_PHY_LED_PAGE);
+	oldpage = marvell_get_set_page(phydev, MII_MARVELL_LED_PAGE);
 	if (oldpage < 0)
 		return oldpage;
 
@@ -895,7 +893,7 @@ static int m88e1510_config_init(struct phy_device *phydev)
 			return err;
 
 		/* Reset page selection */
-		err = marvell_set_page(phydev, MII_M1111_COPPER);
+		err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 		if (err < 0)
 			return err;
 	}
@@ -925,7 +923,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 	int err;
 
 	/* Change address */
-	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
+	err = marvell_set_page(phydev, MII_MARVELL_MSCR_PAGE);
 	if (err < 0)
 		return err;
 
@@ -935,7 +933,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Change address */
-	err = marvell_set_page(phydev, MII_88E1318S_PHY_LED_PAGE);
+	err = marvell_set_page(phydev, MII_MARVELL_LED_PAGE);
 	if (err < 0)
 		return err;
 
@@ -952,7 +950,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Reset address */
-	err = marvell_set_page(phydev, MII_M1111_COPPER);
+	err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	if (err < 0)
 		return err;
 
@@ -964,7 +962,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 	int err;
 
 	/* Change address */
-	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
+	err = marvell_set_page(phydev, MII_MARVELL_MSCR_PAGE);
 	if (err < 0)
 		return err;
 
@@ -978,7 +976,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Reset address */
-	err = marvell_set_page(phydev, MII_M1111_COPPER);
+	err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	if (err < 0)
 		return err;
 
@@ -1248,7 +1246,7 @@ static int marvell_read_status_page(struct phy_device *phydev, int page)
 	/* Detect and update the link, but return if there
 	 * was an error
 	 */
-	if (page == MII_M1111_FIBER)
+	if (page == MII_MARVELL_FIBER_PAGE)
 		fiber = 1;
 	else
 		fiber = 0;
@@ -1281,11 +1279,11 @@ static int marvell_read_status(struct phy_device *phydev)
 	/* Check the fiber mode first */
 	if (phydev->supported & SUPPORTED_FIBRE &&
 	    phydev->interface != PHY_INTERFACE_MODE_SGMII) {
-		err = marvell_set_page(phydev, MII_M1111_FIBER);
+		err = marvell_set_page(phydev, MII_MARVELL_FIBER_PAGE);
 		if (err < 0)
 			goto error;
 
-		err = marvell_read_status_page(phydev, MII_M1111_FIBER);
+		err = marvell_read_status_page(phydev, MII_MARVELL_FIBER_PAGE);
 		if (err < 0)
 			goto error;
 
@@ -1300,15 +1298,15 @@ static int marvell_read_status(struct phy_device *phydev)
 			return 0;
 
 		/* If fiber link is down, check and save copper mode state */
-		err = marvell_set_page(phydev, MII_M1111_COPPER);
+		err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 		if (err < 0)
 			goto error;
 	}
 
-	return marvell_read_status_page(phydev, MII_M1111_COPPER);
+	return marvell_read_status_page(phydev, MII_MARVELL_COPPER_PAGE);
 
 error:
-	marvell_set_page(phydev, MII_M1111_COPPER);
+	marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	return err;
 }
 
@@ -1323,7 +1321,7 @@ static int marvell_suspend(struct phy_device *phydev)
 
 	/* Suspend the fiber mode first */
 	if (!(phydev->supported & SUPPORTED_FIBRE)) {
-		err = marvell_set_page(phydev, MII_M1111_FIBER);
+		err = marvell_set_page(phydev, MII_MARVELL_FIBER_PAGE);
 		if (err < 0)
 			goto error;
 
@@ -1333,7 +1331,7 @@ static int marvell_suspend(struct phy_device *phydev)
 			goto error;
 
 		/* Then, the copper link */
-		err = marvell_set_page(phydev, MII_M1111_COPPER);
+		err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 		if (err < 0)
 			goto error;
 	}
@@ -1342,7 +1340,7 @@ static int marvell_suspend(struct phy_device *phydev)
 	return genphy_suspend(phydev);
 
 error:
-	marvell_set_page(phydev, MII_M1111_COPPER);
+	marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	return err;
 }
 
@@ -1357,7 +1355,7 @@ static int marvell_resume(struct phy_device *phydev)
 
 	/* Resume the fiber mode first */
 	if (!(phydev->supported & SUPPORTED_FIBRE)) {
-		err = marvell_set_page(phydev, MII_M1111_FIBER);
+		err = marvell_set_page(phydev, MII_MARVELL_FIBER_PAGE);
 		if (err < 0)
 			goto error;
 
@@ -1367,7 +1365,7 @@ static int marvell_resume(struct phy_device *phydev)
 			goto error;
 
 		/* Then, the copper link */
-		err = marvell_set_page(phydev, MII_M1111_COPPER);
+		err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 		if (err < 0)
 			goto error;
 	}
@@ -1376,7 +1374,7 @@ static int marvell_resume(struct phy_device *phydev)
 	return genphy_resume(phydev);
 
 error:
-	marvell_set_page(phydev, MII_M1111_COPPER);
+	marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 	return err;
 }
 
@@ -1405,14 +1403,14 @@ static void m88e1318_get_wol(struct phy_device *phydev,
 	wol->supported = WAKE_MAGIC;
 	wol->wolopts = 0;
 
-	if (marvell_set_page(phydev, MII_88E1318S_PHY_WOL_PAGE) < 0)
+	if (marvell_set_page(phydev, MII_MARVELL_WOL_PAGE) < 0)
 		return;
 
 	if (phy_read(phydev, MII_88E1318S_PHY_WOL_CTRL) &
 	    MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE)
 		wol->wolopts |= WAKE_MAGIC;
 
-	if (marvell_set_page(phydev, MII_M1111_COPPER) < 0)
+	if (marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE) < 0)
 		return;
 }
 
@@ -1425,7 +1423,7 @@ static int m88e1318_set_wol(struct phy_device *phydev,
 
 	if (wol->wolopts & WAKE_MAGIC) {
 		/* Explicitly switch to page 0x00, just to be sure */
-		err = marvell_set_page(phydev, MII_M1111_COPPER);
+		err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
 		if (err < 0)
 			return err;
 
@@ -1436,7 +1434,7 @@ static int m88e1318_set_wol(struct phy_device *phydev,
 		if (err < 0)
 			return err;
 
-		err = marvell_set_page(phydev, MII_88E1318S_PHY_LED_PAGE);
+		err = marvell_set_page(phydev, MII_MARVELL_LED_PAGE);
 		if (err < 0)
 			return err;
 
@@ -1449,7 +1447,7 @@ static int m88e1318_set_wol(struct phy_device *phydev,
 		if (err < 0)
 			return err;
 
-		err = marvell_set_page(phydev, MII_88E1318S_PHY_WOL_PAGE);
+		err = marvell_set_page(phydev, MII_MARVELL_WOL_PAGE);
 		if (err < 0)
 			return err;
 
@@ -1478,7 +1476,7 @@ static int m88e1318_set_wol(struct phy_device *phydev,
 		if (err < 0)
 			return err;
 	} else {
-		err = marvell_set_page(phydev, MII_88E1318S_PHY_WOL_PAGE);
+		err = marvell_set_page(phydev, MII_MARVELL_WOL_PAGE);
 		if (err < 0)
 			return err;
 
@@ -1564,7 +1562,7 @@ static int m88e1121_get_temp(struct phy_device *phydev, long *temp)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
+	oldpage = marvell_get_set_page(phydev, MII_MARVELL_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
@@ -1682,7 +1680,7 @@ static int m88e1510_get_temp(struct phy_device *phydev, long *temp)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
+	oldpage = marvell_get_set_page(phydev, MII_MARVELL_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
@@ -1710,7 +1708,7 @@ int m88e1510_get_temp_critical(struct phy_device *phydev, long *temp)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
+	oldpage = marvell_get_set_page(phydev, MII_MARVELL_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
@@ -1739,7 +1737,7 @@ int m88e1510_set_temp_critical(struct phy_device *phydev, long temp)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
+	oldpage = marvell_get_set_page(phydev, MII_MARVELL_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
@@ -1771,7 +1769,7 @@ int m88e1510_get_temp_alarm(struct phy_device *phydev, long *alarm)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
+	oldpage = marvell_get_set_page(phydev, MII_MARVELL_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
-- 
2.11.0
