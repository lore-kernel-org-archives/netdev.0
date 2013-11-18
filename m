From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH v2 3/4] net/phy: Add VSC8662 support
Date: Mon, 18 Nov 2013 13:05:15 -0600
Message-ID: <1384801516-19595-3-git-send-email-Shruti@Freescale.com>
References: <1384801516-19595-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sandeep Singh <sandeep@Freescale.com>,
	Sandeep Singh <Sandeep@Freescale.com>,
	Andy Fleming <afleming@gmail.com>,
	Shruti Kanetkar <Shruti@Freescale.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:54341
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752471Ab3KRTFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:05:24 -0500
In-Reply-To: <1384801516-19595-1-git-send-email-Shruti@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Singh <sandeep@freescale.com>

Vitesse VSC8662 is Dual Port 10/100/1000Base-T Phy
Its register set and features are similar to other Vitesse Phys.

Signed-off-by: Sandeep Singh <Sandeep@freescale.com>
Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
---
 drivers/net/phy/vitesse.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 31b3148..40406bc 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -57,6 +57,7 @@
 #define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8574			0x000704a0
+#define PHY_ID_VSC8662			0x00070660
 #define PHY_ID_VSC8221			0x000fc550
 #define PHY_ID_VSC8211			0x000fc4b0
 
@@ -192,6 +193,18 @@ static struct phy_driver vsc82xx_driver[] = {
 	.config_intr    = &vsc82xx_config_intr,
 	.driver         = { .owner = THIS_MODULE,},
 }, {
+	.phy_id         = PHY_ID_VSC8662,
+	.name           = "Vitesse VSC8662",
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
@@ -238,6 +251,7 @@ static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8234, 0x000ffff0 },
 	{ PHY_ID_VSC8244, 0x000fffc0 },
 	{ PHY_ID_VSC8574, 0x000ffff0 },
+	{ PHY_ID_VSC8662, 0x000ffff0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
 	{ PHY_ID_VSC8211, 0x000ffff0 },
 	{ }
-- 
1.8.3.1
