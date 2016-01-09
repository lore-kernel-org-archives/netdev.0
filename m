From: Joshua Henderson <joshua.henderson@microchip.com>
Subject: [PATCH] net: phy: Add support for SMSC LAN8740 PHY
Date: Fri, 8 Jan 2016 17:57:20 -0700
Message-ID: <1452301040-4392-1-git-send-email-joshua.henderson@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Joshua Henderson <joshua.henderson@microchip.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:36296 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752236AbcAIAuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 19:50:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LAN8740 has a different phy_id than LAN8710/LAN8720.

Signed-off-by: Joshua Henderson <joshua.henderson@microchip.com>
---
 drivers/net/phy/smsc.c |   24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index dc2da87..34021a5 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -264,6 +264,29 @@ static struct phy_driver smsc_phy_driver[] = {
 	.resume		= genphy_resume,
 
 	.driver		= { .owner = THIS_MODULE, }
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
+
+	.driver		= { .owner = THIS_MODULE, }
 } };
 
 module_phy_driver(smsc_phy_driver);
@@ -278,6 +301,7 @@ static struct mdio_device_id __maybe_unused smsc_tbl[] = {
 	{ 0x0007c0c0, 0xfffffff0 },
 	{ 0x0007c0d0, 0xfffffff0 },
 	{ 0x0007c0f0, 0xfffffff0 },
+	{ 0x0007c110, 0xfffffff0 },
 	{ }
 };
 
-- 
1.7.9.5
