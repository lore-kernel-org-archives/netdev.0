From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net-next 4/4] net: phy: Fix the mdix_ctrl changes
Date: Tue, 29 Nov 2016 15:16:49 +0530
Message-ID: <1480412809-6122-5-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0089.outbound.protection.outlook.com ([104.47.42.89]:15784
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753150AbcK2KWP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 05:22:15 -0500
In-Reply-To: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

PHY drivers to have an eth_tp_mdix_ctrl to indicate what is the configured
MDI setting, and read eth_tp_mdi to indicate what is the current status,

Add new parameter mdix_ctrl in phy_device structure and fix driver.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/marvell.c   | 4 ++--
 drivers/net/phy/microchip.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index fa31f50..e269262 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -268,7 +268,7 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = marvell_set_polarity(phydev, phydev->mdix);
+	err = marvell_set_polarity(phydev, phydev->mdix_ctrl);
 	if (err < 0)
 		return err;
 
@@ -311,7 +311,7 @@ static int m88e1111_config_aneg(struct phy_device *phydev)
 	 */
 	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
 
-	err = marvell_set_polarity(phydev, phydev->mdix);
+	err = marvell_set_polarity(phydev, phydev->mdix_ctrl);
 	if (err < 0)
 		return err;
 
diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index eb4db22..12825a5 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -111,7 +111,7 @@ static void lan88xx_set_mdix(struct phy_device *phydev)
 	int buf;
 	int val;
 
-	switch (phydev->mdix) {
+	switch (phydev->mdix_ctrl) {
 	case ETH_TP_MDI:
 		val = LAN88XX_EXT_MODE_CTRL_MDI_;
 		break;
-- 
2.7.4
