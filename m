From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 1/1] net: phy: Add support for Microsemi VSC 8530/40 Fast Ethernet PHY
Date: Fri, 28 Oct 2016 12:10:11 +0200
Message-ID: <1477649411-31036-2-git-send-email-allan.nielsen@microsemi.com>
References: <1477649411-31036-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0044.outbound.protection.outlook.com ([104.47.40.44]:7515
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756470AbcJ1Knq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 06:43:46 -0400
In-Reply-To: <1477649411-31036-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 drivers/net/phy/Kconfig |  2 +-
 drivers/net/phy/mscc.c  | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 45f68ea..ff31c10 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -290,7 +290,7 @@ config MICROCHIP_PHY
 config MICROSEMI_PHY
 	tristate "Microsemi PHYs"
 	---help---
-	  Currently supports the VSC8531 and VSC8541 PHYs
+	  Currently supports VSC8530, VSC8531, VSC8540 and VSC8541 PHYs
 
 config NATIONAL_PHY
 	tristate "National Semiconductor PHYs"
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 113616b..d0026ab 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -65,7 +65,9 @@ enum rgmii_rx_clock_delay {
 #define SECURE_ON_PASSWD_LEN_4		  0x4000
 
 /* Microsemi PHY ID's */
+#define PHY_ID_VSC8530			  0x00070560
 #define PHY_ID_VSC8531			  0x00070570
+#define PHY_ID_VSC8540			  0x00070760
 #define PHY_ID_VSC8541			  0x00070770
 
 #define MSCC_VDDMAC_1500		  1500
@@ -399,6 +401,25 @@ static int vsc85xx_probe(struct phy_device *phydev)
 /* Microsemi VSC85xx PHYs */
 static struct phy_driver vsc85xx_driver[] = {
 {
+	.phy_id		= PHY_ID_VSC8530,
+	.name		= "Microsemi FE VSC8530",
+	.phy_id_mask	= 0xfffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.soft_reset	= &genphy_soft_reset,
+	.config_init	= &vsc85xx_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= &genphy_aneg_done,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc85xx_ack_interrupt,
+	.config_intr	= &vsc85xx_config_intr,
+	.suspend	= &genphy_suspend,
+	.resume		= &genphy_resume,
+	.probe		= &vsc85xx_probe,
+	.set_wol	= &vsc85xx_wol_set,
+	.get_wol	= &vsc85xx_wol_get,
+},
+{
 	.phy_id		= PHY_ID_VSC8531,
 	.name		= "Microsemi VSC8531",
 	.phy_id_mask    = 0xfffffff0,
@@ -418,6 +439,25 @@ static struct phy_driver vsc85xx_driver[] = {
 	.get_wol	= &vsc85xx_wol_get,
 },
 {
+	.phy_id		= PHY_ID_VSC8540,
+	.name		= "Microsemi FE VSC8540 SyncE",
+	.phy_id_mask	= 0xfffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.soft_reset	= &genphy_soft_reset,
+	.config_init	= &vsc85xx_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= &genphy_aneg_done,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc85xx_ack_interrupt,
+	.config_intr	= &vsc85xx_config_intr,
+	.suspend	= &genphy_suspend,
+	.resume		= &genphy_resume,
+	.probe		= &vsc85xx_probe,
+	.set_wol	= &vsc85xx_wol_set,
+	.get_wol	= &vsc85xx_wol_get,
+},
+{
 	.phy_id		= PHY_ID_VSC8541,
 	.name		= "Microsemi VSC8541 SyncE",
 	.phy_id_mask    = 0xfffffff0,
@@ -442,7 +482,9 @@ static struct phy_driver vsc85xx_driver[] = {
 module_phy_driver(vsc85xx_driver);
 
 static struct mdio_device_id __maybe_unused vsc85xx_tbl[] = {
+	{ PHY_ID_VSC8530, 0xfffffff0, },
 	{ PHY_ID_VSC8531, 0xfffffff0, },
+	{ PHY_ID_VSC8540, 0xfffffff0, },
 	{ PHY_ID_VSC8541, 0xfffffff0, },
 	{ }
 };
-- 
2.7.3
