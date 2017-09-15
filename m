From: Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>
Subject: [PATCH net] net: phy: Fix mask value write on gmii2rgmii converter speed register
Date: Fri, 15 Sep 2017 12:01:58 +0530
Message-ID: <1505457118-3933-1-git-send-email-fahad.kunnathadi@dexceldesigns.com>
Cc: michal.simek@xilinx.com, davem@davemloft.net, andrew@lunn.ch,
        appanad@xilinx.com, soren.brinkmann@xilinx.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To clear Speed Selection in MDIO control register(0x10),
ie, clear bits 6 and 13 to zero while keeping other bits same.
Before AND operation,The Mask value has to be perform with bitwise NOT
operation (ie, ~ operator)

This patch clears current speed selection before writing the
new speed settings to gmii2rgmii converter

Fixes: f411a6160bd4 ("net: phy: Add gmiitorgmii converter support")

Signed-off-by: Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/xilinx_gmii2rgmii.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
index d15dd39..2e5150b 100644
--- a/drivers/net/phy/xilinx_gmii2rgmii.c
+++ b/drivers/net/phy/xilinx_gmii2rgmii.c
@@ -44,7 +44,7 @@ static int xgmiitorgmii_read_status(struct phy_device *phydev)
 	priv->phy_drv->read_status(phydev);
 
 	val = mdiobus_read(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG);
-	val &= XILINX_GMII2RGMII_SPEED_MASK;
+	val &= ~XILINX_GMII2RGMII_SPEED_MASK;
 
 	if (phydev->speed == SPEED_1000)
 		val |= BMCR_SPEED1000;
-- 
1.9.1
