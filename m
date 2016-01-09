From: Joshua Henderson <joshua.henderson@microchip.com>
Subject: [PATCH v2] net: phy: Add support for SMSC LAN8740 PHY
Date: Sat, 9 Jan 2016 04:54:21 -0700
Message-ID: <1452340461-5763-1-git-send-email-joshua.henderson@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Joshua Henderson <joshua.henderson@microchip.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LAN8740 has a different phy_id than LAN8710/LAN8720.

Signed-off-by: Joshua Henderson <joshua.henderson@microchip.com>
---
Changes from v1:
	+ Remove explicitly setting .driver and apply against net-next

 drivers/net/phy/smsc.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index ddb0613..e485f26 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -254,6 +254,27 @@ static struct phy_driver smsc_phy_driver[] = {

 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
+}, {
+	.phy_id		= 0x0007c110,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "SMSC LAN8740",
+
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
+
+	/* basic functions */
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= lan87xx_read_status,
+	.config_init	= smsc_phy_config_init,
+	.soft_reset	= smsc_phy_reset,
+
+	/* IRQ related */
+	.ack_interrupt	= smsc_phy_ack_interrupt,
+	.config_intr	= smsc_phy_config_intr,
+
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 } };

 module_phy_driver(smsc_phy_driver);
@@ -268,6 +289,7 @@ static struct mdio_device_id __maybe_unused smsc_tbl[] = {
 	{ 0x0007c0c0, 0xfffffff0 },
 	{ 0x0007c0d0, 0xfffffff0 },
 	{ 0x0007c0f0, 0xfffffff0 },
+	{ 0x0007c110, 0xfffffff0 },
 	{ }
 };
