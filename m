From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH v2 2/4] net/phy: Add VSC8574 support
Date: Mon, 18 Nov 2013 13:05:14 -0600
Message-ID: <1384801516-19595-2-git-send-email-Shruti@Freescale.com>
References: <1384801516-19595-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: shaohui xie <Shaohui.Xie@Freescale.com>,
	Andy Fleming <afleming@gmail.com>,
	Shruti Kanetkar <Shruti@Freescale.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:12028
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904Ab3KRTFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:05:23 -0500
In-Reply-To: <1384801516-19595-1-git-send-email-Shruti@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: shaohui xie <Shaohui.Xie@freescale.com>

The VSC8574 is a quad-port Gigabit Ethernet transceiver with four SerDes
interfaces for quad-port dual media capability.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Shruti Kanetkar <Shruti@freescale.com>
---
 drivers/net/phy/vitesse.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 59e3b58..31b3148 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -56,6 +56,7 @@
 
 #define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
+#define PHY_ID_VSC8574			0x000704a0
 #define PHY_ID_VSC8221			0x000fc550
 #define PHY_ID_VSC8211			0x000fc4b0
 
@@ -120,7 +121,8 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
 		err = phy_write(phydev, MII_VSC8244_IMASK,
 			(phydev->drv->phy_id == PHY_ID_VSC8234 ||
-			 phydev->drv->phy_id == PHY_ID_VSC8244) ?
+			 phydev->drv->phy_id == PHY_ID_VSC8244 ||
+			 phydev->drv->phy_id == PHY_ID_VSC8574) ?
 				MII_VSC8244_IMASK_MASK :
 				MII_VSC8221_IMASK_MASK);
 	else {
@@ -178,6 +180,18 @@ static struct phy_driver vsc82xx_driver[] = {
 	.config_intr	= &vsc82xx_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	.phy_id         = PHY_ID_VSC8574,
+	.name           = "Vitesse VSC8574",
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
 	/* Vitesse 8221 */
 	.phy_id		= PHY_ID_VSC8221,
 	.phy_id_mask	= 0x000ffff0,
@@ -223,6 +237,7 @@ module_exit(vsc82xx_exit);
 static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8234, 0x000ffff0 },
 	{ PHY_ID_VSC8244, 0x000fffc0 },
+	{ PHY_ID_VSC8574, 0x000ffff0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
 	{ PHY_ID_VSC8211, 0x000ffff0 },
 	{ }
-- 
1.8.3.1
