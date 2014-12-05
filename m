From: Alessio Igor Bogani <alessio.bogani@elettra.eu>
Subject: [PATCH] broadcom: Add BCM54616S phy support
Date: Fri,  5 Dec 2014 10:16:00 +0100
Message-ID: <1417770960-4578-1-git-send-email-alessio.bogani@elettra.eu>
Cc: netdev@vger.kernel.org,
	Alessio Igor Bogani <alessio.bogani@elettra.eu>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m2.elettra.trieste.it ([140.105.206.202]:35259 "EHLO elettra.eu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750749AbaLEKQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 05:16:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alessio Igor Bogani <alessio.bogani@elettra.eu>
---
 drivers/net/phy/Kconfig    |  4 ++--
 drivers/net/phy/broadcom.c | 14 ++++++++++++++
 include/linux/brcmphy.h    |  1 +
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 75472cf7..eb35dcb 100644
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
index 854f2c9..74cbf45 100644
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
@@ -673,6 +686,7 @@ static struct mdio_device_id __maybe_unused broadcom_tbl[] = {
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
2.1.3
