From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/7] net: phy: marvell: Use core genphy_soft_reset()
Date: Sun, 30 Jul 2017 22:41:45 +0200
Message-ID: <1501447310-24101-3-git-send-email-andrew@lunn.ch>
References: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45262 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754442AbdG3Umu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 16:42:50 -0400
In-Reply-To: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than using an open coded equivalent, use the core
genphy_soft_reset() function.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 47 ++++++++++++-----------------------------------
 1 file changed, 12 insertions(+), 35 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 6a5256ceb11e..33a52532fac6 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -292,17 +292,11 @@ static int marvell_config_aneg(struct phy_device *phydev)
 		return err;
 
 	if (phydev->autoneg != AUTONEG_ENABLE) {
-		int bmcr;
-
 		/* A write to speed/duplex bits (that is performed by
 		 * genphy_config_aneg() call above) must be followed by
 		 * a software reset. Otherwise, the write has no effect.
 		 */
-		bmcr = phy_read(phydev, MII_BMCR);
-		if (bmcr < 0)
-			return bmcr;
-
-		err = phy_write(phydev, MII_BMCR, bmcr | BMCR_RESET);
+		err = genphy_soft_reset(phydev);
 		if (err < 0)
 			return err;
 	}
@@ -318,8 +312,7 @@ static int m88e1101_config_aneg(struct phy_device *phydev)
 	 * that certain registers get written in order
 	 * to restart autonegotiation
 	 */
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
-
+	err = genphy_soft_reset(phydev);
 	if (err < 0)
 		return err;
 
@@ -354,7 +347,7 @@ static int m88e1111_config_aneg(struct phy_device *phydev)
 	 * that certain registers get written in order
 	 * to restart autonegotiation
 	 */
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	err = genphy_soft_reset(phydev);
 
 	err = marvell_set_polarity(phydev, phydev->mdix_ctrl);
 	if (err < 0)
@@ -370,17 +363,11 @@ static int m88e1111_config_aneg(struct phy_device *phydev)
 		return err;
 
 	if (phydev->autoneg != AUTONEG_ENABLE) {
-		int bmcr;
-
 		/* A write to speed/duplex bits (that is performed by
 		 * genphy_config_aneg() call above) must be followed by
 		 * a software reset. Otherwise, the write has no effect.
 		 */
-		bmcr = phy_read(phydev, MII_BMCR);
-		if (bmcr < 0)
-			return bmcr;
-
-		err = phy_write(phydev, MII_BMCR, bmcr | BMCR_RESET);
+		err = genphy_soft_reset(phydev);
 		if (err < 0)
 			return err;
 	}
@@ -493,7 +480,7 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 
 	marvell_set_page(phydev, oldpage);
 
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	err = genphy_soft_reset(phydev);
 	if (err < 0)
 		return err;
 
@@ -656,9 +643,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	int temp;
 	int err;
 
-	temp = phy_read(phydev, MII_BMCR);
-	temp |= BMCR_RESET;
-	err = phy_write(phydev, MII_BMCR, temp);
+	err = genphy_soft_reset(phydev);
 	if (err < 0)
 		return err;
 
@@ -689,14 +674,10 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	temp = phy_read(phydev, MII_BMCR);
-	temp |= BMCR_RESET;
-	err = phy_write(phydev, MII_BMCR, temp);
+	err = genphy_soft_reset(phydev);
 	if (err < 0)
 		return err;
 
-	mdelay(500);
-
 	return marvell_config_init(phydev);
 }
 
@@ -804,14 +785,10 @@ static int m88e1111_config_init_rtbi(struct phy_device *phydev)
 		return err;
 
 	/* soft reset */
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	err = genphy_soft_reset(phydev);
 	if (err < 0)
 		return err;
 
-	do
-		temp = phy_read(phydev, MII_BMCR);
-	while (temp & BMCR_RESET);
-
 	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
 	if (temp < 0)
 		return temp;
@@ -850,7 +827,7 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	return phy_write(phydev, MII_BMCR, BMCR_RESET);
+	return genphy_soft_reset(phydev);
 }
 
 static int m88e1121_config_init(struct phy_device *phydev)
@@ -912,7 +889,7 @@ static int m88e1118_config_aneg(struct phy_device *phydev)
 {
 	int err;
 
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	err = genphy_soft_reset(phydev);
 	if (err < 0)
 		return err;
 
@@ -961,7 +938,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	return phy_write(phydev, MII_BMCR, BMCR_RESET);
+	return genphy_soft_reset(phydev);
 }
 
 static int m88e1149_config_init(struct phy_device *phydev)
@@ -987,7 +964,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	return phy_write(phydev, MII_BMCR, BMCR_RESET);
+	return genphy_soft_reset(phydev);
 }
 
 static int m88e1145_config_init_rgmii(struct phy_device *phydev)
-- 
2.13.2
