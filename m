From: Alessio Igor Bogani <alessio.bogani@elettra.eu>
Subject: [PATCH] net: phy: broadcom: Add BCM54616S phy entry
Date: Wed,  8 Apr 2015 12:15:18 +0200
Message-ID: <1428488118-14953-1-git-send-email-alessio.bogani@elettra.eu>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alessio Igor Bogani <alessio.bogani@elettra.eu>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alessio Igor Bogani <alessio.bogani@elettra.eu>
---
This phy is used in the MVME2500 powerpc system
(arch/powerpc/boot/dts/mvme2500.dts)

 drivers/net/phy/Kconfig    |  4 ++--
 drivers/net/phy/broadcom.c | 14 ++++++++++++++
 include/linux/brcmphy.h    |  1 +
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 16adbc4..8fadaa1 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -68,8 +68,8 @@ config SMSC_PHY
 config BROADCOM_PHY
 	tristate "Drivers for Broadcom PHYs"
 	---help---
-	  Currently supports the BCM5411, BCM5421, BCM5461, BCM5464, BCM5481
-	  and BCM5482 PHYs.
+	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
+	  BCM5481 and BCM5482 PHYs.
 
 config BCM63XX_PHY
 	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index a52afb2..9c71295 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -549,6 +549,19 @@ static struct phy_driver broadcom_drivers[] = {
 	.config_intr	= bcm54xx_config_intr,
 	.driver		= { .owner = THIS_MODULE },
 }, {
+	.phy_id		= PHY_ID_BCM54616S,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM54616S",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm54xx_ack_interrupt,
+	.config_intr	= bcm54xx_config_intr,
+	.driver		= { .owner = THIS_MODULE },
+}, {
 	.phy_id		= PHY_ID_BCM5464,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5464",
@@ -660,6 +673,7 @@ static struct mdio_device_id __maybe_unused broadcom_tbl[] = {
 	{ PHY_ID_BCM5411, 0xfffffff0 },
 	{ PHY_ID_BCM5421, 0xfffffff0 },
 	{ PHY_ID_BCM5461, 0xfffffff0 },
+	{ PHY_ID_BCM54616S, 0xfffffff0 },
 	{ PHY_ID_BCM5464, 0xfffffff0 },
 	{ PHY_ID_BCM5482, 0xfffffff0 },
 	{ PHY_ID_BCM5482, 0xfffffff0 },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 7ccd928..1c9920b 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -11,6 +11,7 @@
 #define PHY_ID_BCM5421			0x002060e0
 #define PHY_ID_BCM5464			0x002060b0
 #define PHY_ID_BCM5461			0x002060c0
+#define PHY_ID_BCM54616S		0x03625d10
 #define PHY_ID_BCM57780			0x03625d90
 
 #define PHY_ID_BCM7250			0xae025280
-- 
2.3.5
