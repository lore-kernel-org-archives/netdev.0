From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH 1/4] net/phy: Add VSC8234 support
Date: Fri, 15 Nov 2013 16:58:22 -0600
Message-ID: <1384556305-17133-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Fleming <afleming@gmail.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Shruti Kanetkar <Shruti@Freescale.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:18830
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751837Ab3KOW6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 17:58:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@gmail.com>

Vitesse VSC8234 is quad port 10/100/1000BASE-T PHY
with SGMII and SERDES MAC interfaces.

Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
Signed-off-by: Shruti Kanetkar <Shruti@freescale.com>
---
 drivers/net/phy/vitesse.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 69b482b..59e3b58 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -54,6 +54,7 @@
 #define MII_VSC8221_AUXCONSTAT_INIT	0x0004 /* need to set this bit? */
 #define MII_VSC8221_AUXCONSTAT_RESERVED	0x0004
 
+#define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8221			0x000fc550
 #define PHY_ID_VSC8211			0x000fc4b0
@@ -118,7 +119,8 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
 		err = phy_write(phydev, MII_VSC8244_IMASK,
-			phydev->drv->phy_id == PHY_ID_VSC8244 ?
+			(phydev->drv->phy_id == PHY_ID_VSC8234 ||
+			 phydev->drv->phy_id == PHY_ID_VSC8244) ?
 				MII_VSC8244_IMASK_MASK :
 				MII_VSC8221_IMASK_MASK);
 	else {
@@ -149,9 +151,21 @@ static int vsc8221_config_init(struct phy_device *phydev)
 	 */
 }
 
-/* Vitesse 824x */
+/* Vitesse 82xx */
 static struct phy_driver vsc82xx_driver[] = {
 {
+	.phy_id         = PHY_ID_VSC8234,
+	.name           = "Vitesse VSC8234",
+	.phy_id_mask    = 0x000ffff0,
+	.features       = PHY_GBIT_FEATURES,
+	.flags          = PHY_HAS_INTERRUPT,
+	.config_init    = &vsc824x_config_init,
+	.config_aneg    = &genphy_config_aneg,
+	.read_status    = &genphy_read_status,
+	.ack_interrupt  = &vsc824x_ack_interrupt,
+	.config_intr    = &vsc82xx_config_intr,
+	.driver         = { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= PHY_ID_VSC8244,
 	.name		= "Vitesse VSC8244",
 	.phy_id_mask	= 0x000fffc0,
@@ -207,6 +221,7 @@ module_init(vsc82xx_init);
 module_exit(vsc82xx_exit);
 
 static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
+	{ PHY_ID_VSC8234, 0x000ffff0 },
 	{ PHY_ID_VSC8244, 0x000fffc0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
 	{ PHY_ID_VSC8211, 0x000ffff0 },
-- 
1.8.3.1
