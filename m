From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 17/22] phy: Centralize setting driver module owner
Date: Wed,  6 Jan 2016 20:11:22 +0100
Message-ID: <1452107487-475-18-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42312 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbcAFTMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:12:03 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than have each driver set the driver owner field, do it once in
the core code. This will also help with later changes, when the device
structure will move.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/amd.c        |  1 -
 drivers/net/phy/aquantia.c   |  4 ----
 drivers/net/phy/at803x.c     |  9 ---------
 drivers/net/phy/bcm63xx.c    |  2 --
 drivers/net/phy/bcm7xxx.c    |  6 ------
 drivers/net/phy/bcm87xx.c    |  2 --
 drivers/net/phy/broadcom.c   | 12 ------------
 drivers/net/phy/cicada.c     |  2 --
 drivers/net/phy/davicom.c    |  4 ----
 drivers/net/phy/dp83640.c    |  3 +--
 drivers/net/phy/dp83848.c    |  2 --
 drivers/net/phy/dp83867.c    |  2 --
 drivers/net/phy/et1011c.c    |  1 -
 drivers/net/phy/icplus.c     |  3 ---
 drivers/net/phy/lxt.c        |  4 ----
 drivers/net/phy/marvell.c    | 13 -------------
 drivers/net/phy/micrel.c     | 13 -------------
 drivers/net/phy/microchip.c  |  2 --
 drivers/net/phy/national.c   |  1 -
 drivers/net/phy/phy_device.c | 13 +++++++------
 drivers/net/phy/qsemi.c      |  1 -
 drivers/net/phy/realtek.c    |  5 -----
 drivers/net/phy/smsc.c       | 10 ----------
 drivers/net/phy/ste10Xp.c    |  2 --
 drivers/net/phy/teranetics.c |  1 -
 drivers/net/phy/vitesse.c    |  8 --------
 include/linux/phy.h          |  7 ++++---
 27 files changed, 12 insertions(+), 121 deletions(-)

diff --git a/drivers/net/phy/amd.c b/drivers/net/phy/amd.c
index 65a488f82eb8..18141c022b13 100644
--- a/drivers/net/phy/amd.c
+++ b/drivers/net/phy/amd.c
@@ -72,7 +72,6 @@ static struct phy_driver am79c_driver[] = { {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= am79c_ack_interrupt,
 	.config_intr	= am79c_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 } };
 
 module_phy_driver(am79c_driver);
diff --git a/drivers/net/phy/aquantia.c b/drivers/net/phy/aquantia.c
index f1936b7a7af6..09b0b0aa8d68 100644
--- a/drivers/net/phy/aquantia.c
+++ b/drivers/net/phy/aquantia.c
@@ -128,7 +128,6 @@ static struct phy_driver aquantia_driver[] = {
 	.config_intr	= aquantia_config_intr,
 	.ack_interrupt	= aquantia_ack_interrupt,
 	.read_status	= aquantia_read_status,
-	.driver		= { .owner = THIS_MODULE,},
 },
 {
 	.phy_id		= PHY_ID_AQ2104,
@@ -141,7 +140,6 @@ static struct phy_driver aquantia_driver[] = {
 	.config_intr	= aquantia_config_intr,
 	.ack_interrupt	= aquantia_ack_interrupt,
 	.read_status	= aquantia_read_status,
-	.driver		= { .owner = THIS_MODULE,},
 },
 {
 	.phy_id		= PHY_ID_AQR105,
@@ -154,7 +152,6 @@ static struct phy_driver aquantia_driver[] = {
 	.config_intr	= aquantia_config_intr,
 	.ack_interrupt	= aquantia_ack_interrupt,
 	.read_status	= aquantia_read_status,
-	.driver		= { .owner = THIS_MODULE,},
 },
 {
 	.phy_id		= PHY_ID_AQR405,
@@ -167,7 +164,6 @@ static struct phy_driver aquantia_driver[] = {
 	.config_intr	= aquantia_config_intr,
 	.ack_interrupt	= aquantia_ack_interrupt,
 	.read_status	= aquantia_read_status,
-	.driver		= { .owner = THIS_MODULE,},
 },
 };
 
diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index b76ac09a554f..8a8f6fb2880d 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -310,9 +310,6 @@ static struct phy_driver at803x_driver[] = {
 	.read_status		= genphy_read_status,
 	.ack_interrupt		= at803x_ack_interrupt,
 	.config_intr		= at803x_config_intr,
-	.driver			= {
-		.owner = THIS_MODULE,
-	},
 }, {
 	/* ATHEROS 8030 */
 	.phy_id			= ATH8030_PHY_ID,
@@ -331,9 +328,6 @@ static struct phy_driver at803x_driver[] = {
 	.read_status		= genphy_read_status,
 	.ack_interrupt		= at803x_ack_interrupt,
 	.config_intr		= at803x_config_intr,
-	.driver			= {
-		.owner = THIS_MODULE,
-	},
 }, {
 	/* ATHEROS 8031 */
 	.phy_id			= ATH8031_PHY_ID,
@@ -352,9 +346,6 @@ static struct phy_driver at803x_driver[] = {
 	.read_status		= genphy_read_status,
 	.ack_interrupt		= &at803x_ack_interrupt,
 	.config_intr		= &at803x_config_intr,
-	.driver			= {
-		.owner = THIS_MODULE,
-	},
 } };
 
 module_phy_driver(at803x_driver);
diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index 86b28052bf06..e741bf614c4e 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -56,7 +56,6 @@ static struct phy_driver bcm63xx_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	/* same phy as above, with just a different OUI */
 	.phy_id		= 0x002bdc00,
@@ -69,7 +68,6 @@ static struct phy_driver bcm63xx_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 } };
 
 module_phy_driver(bcm63xx_driver);
diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 9f4e6eb886af..bf241a3ec5e5 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -324,7 +324,6 @@ static int bcm7xxx_dummy_config_init(struct phy_device *phydev)
 	.config_aneg	= genphy_config_aneg,				\
 	.read_status	= genphy_read_status,				\
 	.resume		= bcm7xxx_28nm_resume,				\
-	.driver		= { .owner = THIS_MODULE },			\
 }
 
 static struct phy_driver bcm7xxx_driver[] = {
@@ -346,7 +345,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.read_status    = genphy_read_status,
 	.suspend        = bcm7xxx_suspend,
 	.resume         = bcm7xxx_config_init,
-	.driver         = { .owner = THIS_MODULE },
 }, {
 	.phy_id         = PHY_ID_BCM7429,
 	.phy_id_mask    = 0xfffffff0,
@@ -359,7 +357,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.read_status    = genphy_read_status,
 	.suspend        = bcm7xxx_suspend,
 	.resume         = bcm7xxx_config_init,
-	.driver         = { .owner = THIS_MODULE },
 }, {
 	.phy_id         = PHY_ID_BCM7435,
 	.phy_id_mask    = 0xfffffff0,
@@ -372,7 +369,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.read_status    = genphy_read_status,
 	.suspend        = bcm7xxx_suspend,
 	.resume         = bcm7xxx_config_init,
-	.driver         = { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_BCM_OUI_4,
 	.phy_id_mask	= 0xffff0000,
@@ -385,7 +381,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.read_status	= genphy_read_status,
 	.suspend	= bcm7xxx_suspend,
 	.resume		= bcm7xxx_config_init,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_BCM_OUI_5,
 	.phy_id_mask	= 0xffffff00,
@@ -398,7 +393,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.read_status	= genphy_read_status,
 	.suspend	= bcm7xxx_suspend,
 	.resume		= bcm7xxx_config_init,
-	.driver		= { .owner = THIS_MODULE },
 } };
 
 static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
index e536e30d1643..f7ebdcff53e4 100644
--- a/drivers/net/phy/bcm87xx.c
+++ b/drivers/net/phy/bcm87xx.c
@@ -201,7 +201,6 @@ static struct phy_driver bcm87xx_driver[] = {
 	.config_intr	= bcm87xx_config_intr,
 	.did_interrupt	= bcm87xx_did_interrupt,
 	.match_phy_device = bcm8706_match_phy_device,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM8727,
 	.phy_id_mask	= 0xffffffff,
@@ -214,7 +213,6 @@ static struct phy_driver bcm87xx_driver[] = {
 	.config_intr	= bcm87xx_config_intr,
 	.did_interrupt	= bcm87xx_did_interrupt,
 	.match_phy_device = bcm8727_match_phy_device,
-	.driver		= { .owner = THIS_MODULE },
 } };
 
 module_phy_driver(bcm87xx_driver);
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 3ce5d9514623..870327efccf7 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -460,7 +460,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM5421,
 	.phy_id_mask	= 0xfffffff0,
@@ -473,7 +472,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM5461,
 	.phy_id_mask	= 0xfffffff0,
@@ -486,7 +484,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM54616S,
 	.phy_id_mask	= 0xfffffff0,
@@ -499,7 +496,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM5464,
 	.phy_id_mask	= 0xfffffff0,
@@ -512,7 +508,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM5481,
 	.phy_id_mask	= 0xfffffff0,
@@ -525,7 +520,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM5482,
 	.phy_id_mask	= 0xfffffff0,
@@ -538,7 +532,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= bcm5482_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM50610,
 	.phy_id_mask	= 0xfffffff0,
@@ -551,7 +544,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM50610M,
 	.phy_id_mask	= 0xfffffff0,
@@ -564,7 +556,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM57780,
 	.phy_id_mask	= 0xfffffff0,
@@ -577,7 +568,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCMAC131,
 	.phy_id_mask	= 0xfffffff0,
@@ -590,7 +580,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM5241,
 	.phy_id_mask	= 0xfffffff0,
@@ -603,7 +592,6 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
-	.driver		= { .owner = THIS_MODULE },
 } };
 
 module_phy_driver(broadcom_drivers);
diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index 27f5464899d4..d339c1afea77 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -114,7 +114,6 @@ static struct phy_driver cis820x_driver[] = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x000fc440,
 	.name		= "Cicada Cis8204",
@@ -126,7 +125,6 @@ static struct phy_driver cis820x_driver[] = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 } };
 
 module_phy_driver(cis820x_driver);
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 2a328703b4ae..36e3e2033eca 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -156,7 +156,6 @@ static struct phy_driver dm91xx_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x0181b8b0,
 	.name		= "Davicom DM9161B/C",
@@ -168,7 +167,6 @@ static struct phy_driver dm91xx_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x0181b8a0,
 	.name		= "Davicom DM9161A",
@@ -180,7 +178,6 @@ static struct phy_driver dm91xx_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x00181b80,
 	.name		= "Davicom DM9131",
@@ -191,7 +188,6 @@ static struct phy_driver dm91xx_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 } };
 
 module_phy_driver(dm91xx_driver);
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 39da6fc6a85e..180f69952779 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1492,12 +1492,11 @@ static struct phy_driver dp83640_driver = {
 	.hwtstamp	= dp83640_hwtstamp,
 	.rxtstamp	= dp83640_rxtstamp,
 	.txtstamp	= dp83640_txtstamp,
-	.driver		= {.owner = THIS_MODULE,}
 };
 
 static int __init dp83640_init(void)
 {
-	return phy_driver_register(&dp83640_driver);
+	return phy_driver_register(&dp83640_driver, THIS_MODULE);
 }
 
 static void __exit dp83640_exit(void)
diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 5ce9bef54468..5e14e629c597 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -88,8 +88,6 @@ static struct phy_driver dp83848_driver[] = {
 		/* IRQ related */
 		.ack_interrupt	= dp83848_ack_interrupt,
 		.config_intr	= dp83848_config_intr,
-
-		.driver		= { .owner = THIS_MODULE, },
 	},
 };
 module_phy_driver(dp83848_driver);
diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 74e4521bd2d3..2afa61b51d41 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -214,8 +214,6 @@ static struct phy_driver dp83867_driver[] = {
 		.read_status	= genphy_read_status,
 		.suspend	= genphy_suspend,
 		.resume		= genphy_resume,
-
-		.driver		= {.owner = THIS_MODULE,}
 	},
 };
 module_phy_driver(dp83867_driver);
diff --git a/drivers/net/phy/et1011c.c b/drivers/net/phy/et1011c.c
index a907743816a8..a9a4edfa23c8 100644
--- a/drivers/net/phy/et1011c.c
+++ b/drivers/net/phy/et1011c.c
@@ -95,7 +95,6 @@ static struct phy_driver et1011c_driver[] = { {
 	.flags		= PHY_POLL,
 	.config_aneg	= et1011c_config_aneg,
 	.read_status	= et1011c_read_status,
-	.driver 	= { .owner = THIS_MODULE,},
 } };
 
 module_phy_driver(et1011c_driver);
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index c12170d07b62..e5f251b91578 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -221,7 +221,6 @@ static struct phy_driver icplus_driver[] = {
 	.read_status	= &ip175c_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x02430d90,
 	.name		= "ICPlus IP1001",
@@ -233,7 +232,6 @@ static struct phy_driver icplus_driver[] = {
 	.read_status	= &genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x02430c54,
 	.name		= "ICPlus IP101A/G",
@@ -247,7 +245,6 @@ static struct phy_driver icplus_driver[] = {
 	.read_status	= &genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 } };
 
 module_phy_driver(icplus_driver);
diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index a3a5a703635b..f6078376ef50 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -278,7 +278,6 @@ static struct phy_driver lxt97x_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt970_ack_interrupt,
 	.config_intr	= lxt970_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x001378e0,
 	.name		= "LXT971",
@@ -289,7 +288,6 @@ static struct phy_driver lxt97x_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt971_ack_interrupt,
 	.config_intr	= lxt971_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x00137a10,
 	.name		= "LXT973-A2",
@@ -299,7 +297,6 @@ static struct phy_driver lxt97x_driver[] = {
 	.probe		= lxt973_probe,
 	.config_aneg	= lxt973_config_aneg,
 	.read_status	= lxt973a2_read_status,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x00137a10,
 	.name		= "LXT973",
@@ -309,7 +306,6 @@ static struct phy_driver lxt97x_driver[] = {
 	.probe		= lxt973_probe,
 	.config_aneg	= lxt973_config_aneg,
 	.read_status	= genphy_read_status,
-	.driver		= { .owner = THIS_MODULE,},
 } };
 
 module_phy_driver(lxt97x_driver);
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index f96c93c9819a..e3eb96443c97 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1087,7 +1087,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1112,
@@ -1106,7 +1105,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1111,
@@ -1125,7 +1123,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1118,
@@ -1144,7 +1141,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = {.owner = THIS_MODULE,},
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1121R,
@@ -1163,7 +1159,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1318S,
@@ -1184,7 +1179,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1145,
@@ -1203,7 +1197,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1149R,
@@ -1222,7 +1215,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1240,
@@ -1241,7 +1233,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1116R,
@@ -1260,7 +1251,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1510,
@@ -1279,7 +1269,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1540,
@@ -1298,7 +1287,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E3016,
@@ -1319,7 +1307,6 @@ static struct phy_driver marvell_drivers[] = {
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-		.driver = { .owner = THIS_MODULE },
 	},
 };
 
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index b51505be1fa9..0dbc6496b6f6 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -706,7 +706,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8021,
 	.phy_id_mask	= 0x00ffffff,
@@ -726,7 +725,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8031,
 	.phy_id_mask	= 0x00ffffff,
@@ -746,7 +744,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8041,
 	.phy_id_mask	= 0x00fffff0,
@@ -766,7 +763,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8041RNLI,
 	.phy_id_mask	= 0x00fffff0,
@@ -786,7 +782,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8051,
 	.phy_id_mask	= 0x00fffff0,
@@ -806,7 +801,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8001,
 	.name		= "Micrel KSZ8001 or KS8721",
@@ -825,7 +819,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8081,
 	.name		= "Micrel KSZ8081 or KSZ8091",
@@ -844,7 +837,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8061,
 	.name		= "Micrel KSZ8061",
@@ -861,7 +853,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ9021,
 	.phy_id_mask	= 0x000ffffe,
@@ -881,7 +872,6 @@ static struct phy_driver ksphy_driver[] = {
 	.resume		= genphy_resume,
 	.read_mmd_indirect = ksz9021_rd_mmd_phyreg,
 	.write_mmd_indirect = ksz9021_wr_mmd_phyreg,
-	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ9031,
 	.phy_id_mask	= 0x00fffff0,
@@ -899,7 +889,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ8873MLL,
 	.phy_id_mask	= 0x00fffff0,
@@ -914,7 +903,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ886X,
 	.phy_id_mask	= 0x00fffff0,
@@ -929,7 +917,6 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE, },
 } };
 
 module_phy_driver(ksphy_driver);
diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index 5e34b49be0b3..15f820648f82 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -129,8 +129,6 @@ static struct phy_driver microchip_phy_driver[] = {
 	.suspend	= lan88xx_suspend,
 	.resume		= genphy_resume,
 	.set_wol	= lan88xx_set_wol,
-
-	.driver		= { .owner = THIS_MODULE, }
 } };
 
 module_phy_driver(microchip_phy_driver);
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index 0a7b9c7f09a2..2a1b490bc587 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -140,7 +140,6 @@ static struct phy_driver dp83865_driver[] = { {
 	.read_status = genphy_read_status,
 	.ack_interrupt = ns_ack_interrupt,
 	.config_intr = ns_config_intr,
-	.driver = {.owner = THIS_MODULE,}
 } };
 
 module_phy_driver(dp83865_driver);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index eb0b0ed32662..a1b833cd4183 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1564,8 +1564,9 @@ static int phy_remove(struct device *dev)
 /**
  * phy_driver_register - register a phy_driver with the PHY layer
  * @new_driver: new phy_driver to register
+ * @owner: module owning this PHY
  */
-int phy_driver_register(struct phy_driver *new_driver)
+int phy_driver_register(struct phy_driver *new_driver, struct module *owner)
 {
 	int retval;
 
@@ -1573,6 +1574,7 @@ int phy_driver_register(struct phy_driver *new_driver)
 	new_driver->driver.bus = &mdio_bus_type;
 	new_driver->driver.probe = phy_probe;
 	new_driver->driver.remove = phy_remove;
+	new_driver->driver.owner = owner;
 
 	retval = driver_register(&new_driver->driver);
 	if (retval) {
@@ -1588,12 +1590,13 @@ int phy_driver_register(struct phy_driver *new_driver)
 }
 EXPORT_SYMBOL(phy_driver_register);
 
-int phy_drivers_register(struct phy_driver *new_driver, int n)
+int phy_drivers_register(struct phy_driver *new_driver, int n,
+			 struct module *owner)
 {
 	int i, ret = 0;
 
 	for (i = 0; i < n; i++) {
-		ret = phy_driver_register(new_driver + i);
+		ret = phy_driver_register(new_driver + i, owner);
 		if (ret) {
 			while (i-- > 0)
 				phy_driver_unregister(new_driver + i);
@@ -1634,7 +1637,6 @@ static struct phy_driver genphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id         = 0xffffffff,
 	.phy_id_mask    = 0xffffffff,
@@ -1646,7 +1648,6 @@ static struct phy_driver genphy_driver[] = {
 	.read_status    = gen10g_read_status,
 	.suspend        = gen10g_suspend,
 	.resume         = gen10g_resume,
-	.driver         = {.owner = THIS_MODULE, },
 } };
 
 static int __init phy_init(void)
@@ -1658,7 +1659,7 @@ static int __init phy_init(void)
 		return rc;
 
 	rc = phy_drivers_register(genphy_driver,
-				  ARRAY_SIZE(genphy_driver));
+				  ARRAY_SIZE(genphy_driver), THIS_MODULE);
 	if (rc)
 		mdio_bus_exit();
 
diff --git a/drivers/net/phy/qsemi.c b/drivers/net/phy/qsemi.c
index be4c6f7c3645..d470db89e8dd 100644
--- a/drivers/net/phy/qsemi.c
+++ b/drivers/net/phy/qsemi.c
@@ -122,7 +122,6 @@ static struct phy_driver qs6612_driver[] = { {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= qs6612_ack_interrupt,
 	.config_intr	= qs6612_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
 } };
 
 module_phy_driver(qs6612_driver);
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 43ab691362d4..aadd6e9f54ad 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -124,7 +124,6 @@ static struct phy_driver realtek_drvs[] = {
 		.flags          = PHY_HAS_INTERRUPT,
 		.config_aneg    = &genphy_config_aneg,
 		.read_status    = &genphy_read_status,
-		.driver         = { .owner = THIS_MODULE,},
 	}, {
 		.phy_id		= 0x001cc912,
 		.name		= "RTL8211B Gigabit Ethernet",
@@ -135,7 +134,6 @@ static struct phy_driver realtek_drvs[] = {
 		.read_status	= &genphy_read_status,
 		.ack_interrupt	= &rtl821x_ack_interrupt,
 		.config_intr	= &rtl8211b_config_intr,
-		.driver		= { .owner = THIS_MODULE,},
 	}, {
 		.phy_id		= 0x001cc914,
 		.name		= "RTL8211DN Gigabit Ethernet",
@@ -148,7 +146,6 @@ static struct phy_driver realtek_drvs[] = {
 		.config_intr	= rtl8211e_config_intr,
 		.suspend	= genphy_suspend,
 		.resume		= genphy_resume,
-		.driver		= { .owner = THIS_MODULE,},
 	}, {
 		.phy_id		= 0x001cc915,
 		.name		= "RTL8211E Gigabit Ethernet",
@@ -161,7 +158,6 @@ static struct phy_driver realtek_drvs[] = {
 		.config_intr	= &rtl8211e_config_intr,
 		.suspend	= genphy_suspend,
 		.resume		= genphy_resume,
-		.driver		= { .owner = THIS_MODULE,},
 	}, {
 		.phy_id		= 0x001cc916,
 		.name		= "RTL8211F Gigabit Ethernet",
@@ -175,7 +171,6 @@ static struct phy_driver realtek_drvs[] = {
 		.config_intr	= &rtl8211f_config_intr,
 		.suspend	= genphy_suspend,
 		.resume		= genphy_resume,
-		.driver		= { .owner = THIS_MODULE },
 	},
 };
 
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 18c981b95910..ddb06135c21d 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -171,8 +171,6 @@ static struct phy_driver smsc_phy_driver[] = {
 
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-
-	.driver		= { .owner = THIS_MODULE, }
 }, {
 	.phy_id		= 0x0007c0b0, /* OUI=0x00800f, Model#=0x0b */
 	.phy_id_mask	= 0xfffffff0,
@@ -194,8 +192,6 @@ static struct phy_driver smsc_phy_driver[] = {
 
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-
-	.driver		= { .owner = THIS_MODULE, }
 }, {
 	.phy_id		= 0x0007c0c0, /* OUI=0x00800f, Model#=0x0c */
 	.phy_id_mask	= 0xfffffff0,
@@ -217,8 +213,6 @@ static struct phy_driver smsc_phy_driver[] = {
 
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-
-	.driver		= { .owner = THIS_MODULE, }
 }, {
 	.phy_id		= 0x0007c0d0, /* OUI=0x00800f, Model#=0x0d */
 	.phy_id_mask	= 0xfffffff0,
@@ -239,8 +233,6 @@ static struct phy_driver smsc_phy_driver[] = {
 
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-
-	.driver		= { .owner = THIS_MODULE, }
 }, {
 	.phy_id		= 0x0007c0f0, /* OUI=0x00800f, Model#=0x0f */
 	.phy_id_mask	= 0xfffffff0,
@@ -262,8 +254,6 @@ static struct phy_driver smsc_phy_driver[] = {
 
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-
-	.driver		= { .owner = THIS_MODULE, }
 } };
 
 module_phy_driver(smsc_phy_driver);
diff --git a/drivers/net/phy/ste10Xp.c b/drivers/net/phy/ste10Xp.c
index 3fc199b773e6..d00cfb64529e 100644
--- a/drivers/net/phy/ste10Xp.c
+++ b/drivers/net/phy/ste10Xp.c
@@ -95,7 +95,6 @@ static struct phy_driver ste10xp_pdriver[] = {
 	.config_intr = ste10Xp_config_intr,
 	.suspend = genphy_suspend,
 	.resume = genphy_resume,
-	.driver = {.owner = THIS_MODULE,}
 }, {
 	.phy_id = STE100P_PHY_ID,
 	.phy_id_mask = 0xffffffff,
@@ -109,7 +108,6 @@ static struct phy_driver ste10xp_pdriver[] = {
 	.config_intr = ste10Xp_config_intr,
 	.suspend = genphy_suspend,
 	.resume = genphy_resume,
-	.driver = {.owner = THIS_MODULE,}
 } };
 
 module_phy_driver(ste10xp_pdriver);
diff --git a/drivers/net/phy/teranetics.c b/drivers/net/phy/teranetics.c
index 07463fcca212..fb2cef764e9a 100644
--- a/drivers/net/phy/teranetics.c
+++ b/drivers/net/phy/teranetics.c
@@ -108,7 +108,6 @@ static struct phy_driver teranetics_driver[] = {
 	.config_aneg    = teranetics_config_aneg,
 	.read_status	= teranetics_read_status,
 	.match_phy_device = teranetics_match_phy_device,
-	.driver		= { .owner = THIS_MODULE,},
 },
 };
 
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index dd295dbaa074..2e37eb337d48 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -236,7 +236,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
 	.config_intr    = &vsc82xx_config_intr,
-	.driver         = { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_VSC8244,
 	.name		= "Vitesse VSC8244",
@@ -248,7 +247,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_VSC8514,
 	.name		= "Vitesse VSC8514",
@@ -260,7 +258,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id         = PHY_ID_VSC8574,
 	.name           = "Vitesse VSC8574",
@@ -272,7 +269,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
 	.config_intr    = &vsc82xx_config_intr,
-	.driver         = { .owner = THIS_MODULE,},
 }, {
 	.phy_id         = PHY_ID_VSC8601,
 	.name           = "Vitesse VSC8601",
@@ -284,7 +280,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
 	.config_intr    = &vsc82xx_config_intr,
-	.driver         = { .owner = THIS_MODULE,},
 }, {
 	.phy_id         = PHY_ID_VSC8662,
 	.name           = "Vitesse VSC8662",
@@ -296,7 +291,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
 	.config_intr    = &vsc82xx_config_intr,
-	.driver         = { .owner = THIS_MODULE,},
 }, {
 	/* Vitesse 8221 */
 	.phy_id		= PHY_ID_VSC8221,
@@ -309,7 +303,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 }, {
 	/* Vitesse 8211 */
 	.phy_id		= PHY_ID_VSC8211,
@@ -322,7 +315,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
 } };
 
 module_phy_driver(vsc82xx_driver);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2d7beef20825..49e4418822b3 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -797,8 +797,9 @@ int genphy_resume(struct phy_device *phydev);
 int genphy_soft_reset(struct phy_device *phydev);
 void phy_driver_unregister(struct phy_driver *drv);
 void phy_drivers_unregister(struct phy_driver *drv, int n);
-int phy_driver_register(struct phy_driver *new_driver);
-int phy_drivers_register(struct phy_driver *new_driver, int n);
+int phy_driver_register(struct phy_driver *new_driver, struct module *owner);
+int phy_drivers_register(struct phy_driver *new_driver, int n,
+			 struct module *owner);
 void phy_state_machine(struct work_struct *work);
 void phy_change(struct work_struct *work);
 void phy_mac_interrupt(struct phy_device *phydev, int new_link);
@@ -843,7 +844,7 @@ extern struct bus_type mdio_bus_type;
 #define phy_module_driver(__phy_drivers, __count)			\
 static int __init phy_module_init(void)					\
 {									\
-	return phy_drivers_register(__phy_drivers, __count);		\
+	return phy_drivers_register(__phy_drivers, __count, THIS_MODULE); \
 }									\
 module_init(phy_module_init);						\
 static void __exit phy_module_exit(void)				\
-- 
2.6.4
