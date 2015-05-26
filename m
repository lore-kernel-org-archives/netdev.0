From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: phy: Utilize phy_interface_is_rgmii
Date: Tue, 26 May 2015 12:19:59 -0700
Message-ID: <1432667999-11563-3-git-send-email-f.fainelli@gmail.com>
References: <1432667999-11563-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, dmurphy@ti.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33250 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbbEZTUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 15:20:36 -0400
Received: by padbw4 with SMTP id bw4so99699091pad.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 12:20:35 -0700 (PDT)
In-Reply-To: <1432667999-11563-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update all open-coded tests for all 4 PHY_INTERFACE_MODE_RGMII* values
to use the newly introduced helper: phy_interface_is_rgmii.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/icplus.c  |  5 +----
 drivers/net/phy/marvell.c | 10 ++--------
 drivers/net/phy/phy.c     |  3 +--
 3 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 8644f039d922..0dbc445a5fa0 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -139,10 +139,7 @@ static int ip1001_config_init(struct phy_device *phydev)
 	if (c < 0)
 		return c;
 
-	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
+	if (phy_interface_is_rgmii(phydev)) {
 
 		c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
 		if (c < 0)
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 1b1698f98818..f721444c2b0a 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -317,10 +317,7 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
+	if (phy_interface_is_rgmii(phydev)) {
 
 		mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
 			MII_88E1121_PHY_MSCR_DELAY_MASK;
@@ -469,10 +466,7 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	int err;
 	int temp;
 
-	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
+	if (phy_interface_is_rgmii(phydev)) {
 
 		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
 		if (temp < 0)
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 377d2db04d33..b2197b506acb 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1093,8 +1093,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 	if ((phydev->duplex == DUPLEX_FULL) &&
 	    ((phydev->interface == PHY_INTERFACE_MODE_MII) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_GMII) ||
-	    (phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
-	     phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID) ||
+	     phy_interface_is_rgmii(phydev) ||
 	     phy_is_internal(phydev))) {
 		int eee_lp, eee_cap, eee_adv;
 		u32 lp, cap, adv;
-- 
2.1.0
