From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 5/5] phylib: m88e1111: enable SGMII mode
Date: Fri, 11 May 2007 18:25:18 -0500
Message-ID: <20070511182518.6e31784a.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:63911 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761315AbXEKXZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 19:25:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kapil Juneja <Kapil.Juneja@freescale.com>

If connected via SGMII, initialize with SGMII mode configured.

Signed-off-by: Kapil Juneja <Kapil.Juneja@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/phy/marvell.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index b87f8d2..fbe1104 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -60,6 +60,7 @@
 #define MII_M1111_PHY_EXT_SR		0x1b
 #define MII_M1111_HWCFG_MODE_MASK	0xf
 #define MII_M1111_HWCFG_MODE_RGMII	0xb
+#define MII_M1111_HWCFG_MODE_SGMII_NO_CLK	0x4
 
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -169,6 +170,21 @@ static int m88e1111_config_init(struct phy_device *phydev)
 			return err;
 	}
 
+	if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
+		int temp;
+
+		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
+		if (temp < 0)
+			return temp;
+
+		temp &= ~(MII_M1111_HWCFG_MODE_MASK);
+		temp |= MII_M1111_HWCFG_MODE_SGMII_NO_CLK;
+
+		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
+		if (err < 0)
+			return err;
+	}
+
 	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
 	if (err < 0)
 		return err;
-- 
1.5.0.3

