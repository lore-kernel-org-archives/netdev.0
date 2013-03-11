From: Hector Palacios <hector.palacios@digi.com>
Subject: [PATCH 1/2] phy/micrel: Add support for KSZ8031
Date: Mon, 11 Mar 2013 09:50:02 +0100
Message-ID: <1362991803-4610-1-git-send-email-hector.palacios@digi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <marex@denx.de>,
	<davem@davemloft.net>, Hector Palacios <hector.palacios@digi.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micrel PHY KSZ8031 is similar to KSZ8021 and also requires the special
initialization of "Operation Mode Strap Override" in reg 0x16
introduced in 212ea99 (phy/micrel: Implement support for KSZ8021).

Signed-off-by: Hector Palacios <hector.palacios@digi.com>
---
 drivers/net/phy/micrel.c   |   14 ++++++++++++++
 include/linux/micrel_phy.h |    1 +
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index b983596..1ab6743 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -187,6 +187,19 @@ static struct phy_driver ksphy_driver[] = {
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	.phy_id		= PHY_ID_KSZ8031,
+	.phy_id_mask	= 0x00ffffff,
+	.name		= "Micrel KSZ8031",
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= ksz8021_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= PHY_ID_KSZ8041,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KSZ8041",
@@ -273,6 +286,7 @@ static struct mdio_device_id __maybe_unused micrel_tbl[] = {
 	{ PHY_ID_KSZ8001, 0x00ffffff },
 	{ PHY_ID_KS8737, 0x00fffff0 },
 	{ PHY_ID_KSZ8021, 0x00ffffff },
+	{ PHY_ID_KSZ8031, 0x00ffffff },
 	{ PHY_ID_KSZ8041, 0x00fffff0 },
 	{ PHY_ID_KSZ8051, 0x00fffff0 },
 	{ PHY_ID_KSZ8873MLL, 0x00fffff0 },
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index adfe8c0..b1ffaa4 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -19,6 +19,7 @@
 #define PHY_ID_KSZ9021		0x00221610
 #define PHY_ID_KS8737		0x00221720
 #define PHY_ID_KSZ8021		0x00221555
+#define PHY_ID_KSZ8031		0x00221556
 #define PHY_ID_KSZ8041		0x00221510
 #define PHY_ID_KSZ8051		0x00221550
 /* both for ks8001 Rev. A/B, and for ks8721 Rev 3. */
-- 
1.7.9.5
