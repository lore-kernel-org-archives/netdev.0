From: <shh.xie@gmail.com>
Subject: [PATCH] phy: Add Vitesse 8514 phy ID
Date: Mon, 25 Nov 2013 12:40:49 +0800
Message-ID: <1385354449-2943-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 Shaohui Xie <Shaohui.Xie@freescale.com>
To: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Phy is compatible with Vitesse 82xx

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/vitesse.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 508e435..14372c6 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -64,6 +64,7 @@
 
 #define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
+#define PHY_ID_VSC8514			0x00070670
 #define PHY_ID_VSC8574			0x000704a0
 #define PHY_ID_VSC8662			0x00070660
 #define PHY_ID_VSC8221			0x000fc550
@@ -131,6 +132,7 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
 		err = phy_write(phydev, MII_VSC8244_IMASK,
 			(phydev->drv->phy_id == PHY_ID_VSC8234 ||
 			 phydev->drv->phy_id == PHY_ID_VSC8244 ||
+			 phydev->drv->phy_id == PHY_ID_VSC8514 ||
 			 phydev->drv->phy_id == PHY_ID_VSC8574) ?
 				MII_VSC8244_IMASK_MASK :
 				MII_VSC8221_IMASK_MASK);
@@ -246,6 +248,18 @@ static struct phy_driver vsc82xx_driver[] = {
 	.config_intr	= &vsc82xx_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	.phy_id		= PHY_ID_VSC8514,
+	.name		= "Vitesse VSC8514",
+	.phy_id_mask	= 0x000ffff0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &vsc824x_config_init,
+	.config_aneg	= &vsc82x4_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc824x_ack_interrupt,
+	.config_intr	= &vsc82xx_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id         = PHY_ID_VSC8574,
 	.name           = "Vitesse VSC8574",
 	.phy_id_mask    = 0x000ffff0,
@@ -315,6 +329,7 @@ module_exit(vsc82xx_exit);
 static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8234, 0x000ffff0 },
 	{ PHY_ID_VSC8244, 0x000fffc0 },
+	{ PHY_ID_VSC8514, 0x000ffff0 },
 	{ PHY_ID_VSC8574, 0x000ffff0 },
 	{ PHY_ID_VSC8662, 0x000ffff0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
-- 
1.8.4.1
