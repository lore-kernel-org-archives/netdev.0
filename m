From: Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>
Subject: [PATCH] net: phy: Fix mask value write on gmii2rgmii converter speed
 register.
Date: Thu, 14 Sep 2017 12:46:31 +0530
Message-ID: <1505373391-18697-1-git-send-email-fahad.kunnathadi@dexceldesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michal.simek@xilinx.com,
 linux-kernel@vger.kernel.org,
 Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>,
 soren.brinkmann@xilinx.com, linux-arm-kernel@lists.infradead.org
To: f.fainelli@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

To clear Speed Selection in MDIO control register(0x10),
ie, clear bits 6 and 13 to zero while keeping other bits same.
Before AND operation,The Mask value has to be perform with bitwise NOT
operation (ie, ~ operator)

This patch clears current speed selection before writing the
new speed settings to gmii2rgmii converter

Signed-off-by: Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>
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
