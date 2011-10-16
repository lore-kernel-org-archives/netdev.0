From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] phy: Add support for VSC8234
Date: Sun, 16 Oct 2011 01:49:49 -0500
Message-ID: <E1UJ1fR-0004hp-2j@swissweb.swissdisk.com>
Cc: Kumar Gala <kumar.gala@freescale.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No functional changes other than to recognize this PHYID.

Signed-off-by: Andy Fleming <afleming@freescale.com>
Signed-off-by: Kumar Gala <kumar.gala@freescale.com>
Signed-off-by: Ben Collins <ben.c@servergy.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/phy/vitesse.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 2585c38..b760ba1 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -54,6 +54,7 @@
 #define MII_VSC8221_AUXCONSTAT_INIT	0x0004 /* need to set this bit? */
 #define MII_VSC8221_AUXCONSTAT_RESERVED	0x0004
 
+#define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8221			0x000fc550
 
@@ -119,7 +120,8 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
 		err = phy_write(phydev, MII_VSC8244_IMASK,
-			phydev->drv->phy_id == PHY_ID_VSC8244 ?
+			((phydev->drv->phy_id == PHY_ID_VSC8234) ||
+			 (phydev->drv->phy_id == PHY_ID_VSC8244)) ?
 				MII_VSC8244_IMASK_MASK :
 				MII_VSC8221_IMASK_MASK);
 	else {
@@ -165,6 +167,19 @@ static struct phy_driver vsc82xx_driver[] = {
 	.config_intr	= &vsc82xx_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	/* Vitesse 8234 */
+	.phy_id		= PHY_ID_VSC8234,
+	.phy_id_mask	= 0x000ffff0,
+	.name		= "Vitesse VSC8234",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &vsc8221_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc824x_ack_interrupt,
+	.config_intr	= &vsc82xx_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	/* Vitesse 8221 */
 	.phy_id		= PHY_ID_VSC8221,
 	.phy_id_mask	= 0x000ffff0,
-- 
1.8.1.2
