From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2 2/3] net: phy: at803x: use #defines for supported PHY ids
Date: Wed, 18 Jun 2014 11:01:42 +0200
Message-ID: <1403082103-23709-3-git-send-email-zonque@gmail.com>
References: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:64588 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965543AbaFRJB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 05:01:56 -0400
Received: by mail-wg0-f43.google.com with SMTP id b13so486873wgh.26
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 02:01:55 -0700 (PDT)
In-Reply-To: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes magic values from two tables and also allows us to match
against specific PHY models at runtime.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/phy/at803x.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index b256083..045e446 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -35,6 +35,10 @@
 #define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
 #define AT803X_DEBUG_RGMII_TX_CLK_DLY		BIT(8)
 
+#define ATH8030_PHY_ID 0x004dd076
+#define ATH8031_PHY_ID 0x004dd074
+#define ATH8035_PHY_ID 0x004dd072
+
 MODULE_DESCRIPTION("Atheros 803x PHY driver");
 MODULE_AUTHOR("Matus Ujhelyi");
 MODULE_LICENSE("GPL");
@@ -192,7 +196,7 @@ static int at803x_config_intr(struct phy_device *phydev)
 static struct phy_driver at803x_driver[] = {
 {
 	/* ATHEROS 8035 */
-	.phy_id		= 0x004dd072,
+	.phy_id		= ATH8035_PHY_ID,
 	.name		= "Atheros 8035 ethernet",
 	.phy_id_mask	= 0xffffffef,
 	.config_init	= at803x_config_init,
@@ -209,7 +213,7 @@ static struct phy_driver at803x_driver[] = {
 	},
 }, {
 	/* ATHEROS 8030 */
-	.phy_id		= 0x004dd076,
+	.phy_id		= ATH8030_PHY_ID,
 	.name		= "Atheros 8030 ethernet",
 	.phy_id_mask	= 0xffffffef,
 	.config_init	= at803x_config_init,
@@ -226,7 +230,7 @@ static struct phy_driver at803x_driver[] = {
 	},
 }, {
 	/* ATHEROS 8031 */
-	.phy_id		= 0x004dd074,
+	.phy_id		= ATH8031_PHY_ID,
 	.name		= "Atheros 8031 ethernet",
 	.phy_id_mask	= 0xffffffef,
 	.config_init	= at803x_config_init,
@@ -261,9 +265,9 @@ module_init(atheros_init);
 module_exit(atheros_exit);
 
 static struct mdio_device_id __maybe_unused atheros_tbl[] = {
-	{ 0x004dd076, 0xffffffef },
-	{ 0x004dd074, 0xffffffef },
-	{ 0x004dd072, 0xffffffef },
+	{ ATH8030_PHY_ID, 0xffffffef },
+	{ ATH8031_PHY_ID, 0xffffffef },
+	{ ATH8035_PHY_ID, 0xffffffef },
 	{ }
 };
 
-- 
1.9.3
