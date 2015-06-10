From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Subject: [PATCH net-next] net: phy: davicom: add IDs for DM9161B and C variants
Date: Wed, 10 Jun 2015 13:48:20 -0300
Message-ID: <1433954900-25419-1-git-send-email-gustavo@zacarias.com.ar>
Cc: Gustavo Zacarias <gustavo@zacarias.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zacarias.com.ar ([176.9.42.171]:46311 "EHLO
	www.zacarias.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965511AbbFJQxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 12:53:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PHY IDs for Davicom DM9161B and DM9161C variants.
Tested with a DM9161C on a custom Atmel-based SAM9X25 board in RMII
mode.

The DM9161B uses the same model id with just the LSB bit of the version
id changing (which is masked out).

For all intents and purposes they're the same as the DM9161A with an
added GPSI mode and better fabrication process.

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
---
 drivers/net/phy/davicom.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 0d16c7d..2a32870 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -158,6 +158,18 @@ static struct phy_driver dm91xx_driver[] = {
 	.config_intr	= dm9161_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	.phy_id		= 0x0181b8b0,
+	.name		= "Davicom DM9161B/C",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= dm9161_config_init,
+	.config_aneg	= dm9161_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= dm9161_ack_interrupt,
+	.config_intr	= dm9161_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= 0x0181b8a0,
 	.name		= "Davicom DM9161A",
 	.phy_id_mask	= 0x0ffffff0,
@@ -186,6 +198,7 @@ module_phy_driver(dm91xx_driver);
 
 static struct mdio_device_id __maybe_unused davicom_tbl[] = {
 	{ 0x0181b880, 0x0ffffff0 },
+	{ 0x0181b8b0, 0x0ffffff0 },
 	{ 0x0181b8a0, 0x0ffffff0 },
 	{ 0x00181b80, 0x0ffffff0 },
 	{ }
-- 
2.3.6
