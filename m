From: Stef van Os <stef.van.os@prodrive.nl>
Subject: [PATCH 1/1] phy/marvell: remove fiber/copper autoselect on 88e1111
Date: Thu, 17 Jan 2013 16:36:18 +0100
Message-ID: <1358436978-7504-1-git-send-email-stef.van.os@prodrive.nl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Stef van Os <stef.van.os@prodrive.nl>
To: <chohnstaedt@innominate.com>, <davem@davemloft.net>,
	<srinivas.kandagatla@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the code that always enables copper/fiber autoselect,
ignoring the DIS_FC strapping pin. The default value for this
register is autoselect on anyway, and if you explicitly disable
autoselect via strapping you probably really don't want
autoselect.

Signed-off-by: Stef van Os <stef.van.os@prodrive.nl>
---
 drivers/net/phy/marvell.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 5d2a3f2..22dec9c 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -353,15 +353,6 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	int err;
 	int temp;
 
-	/* Enable Fiber/Copper auto selection */
-	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
-	temp &= ~MII_M1111_HWCFG_FIBER_COPPER_AUTO;
-	phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
-
-	temp = phy_read(phydev, MII_BMCR);
-	temp |= BMCR_RESET;
-	phy_write(phydev, MII_BMCR, temp);
-
 	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
-- 
1.7.2.5
