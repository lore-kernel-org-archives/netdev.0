From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 3/3] net: phy: replace phy_drivers_register calls
Date: Tue, 11 Nov 2014 19:45:59 +0100
Message-ID: <1415731559-10015-4-git-send-email-johan@kernel.org>
References: <1415731559-10015-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415731559-10015-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace module init/exit which only calls phy_drivers_register with
module_phy_driver macro.

Tested using Micrel driver, and otherwise compile-tested only.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/amd-xgbe-phy.c | 15 +--------------
 drivers/net/phy/at803x.c       | 14 +-------------
 drivers/net/phy/bcm63xx.c      | 15 +--------------
 drivers/net/phy/bcm7xxx.c      | 15 +--------------
 drivers/net/phy/bcm87xx.c      | 14 +-------------
 drivers/net/phy/broadcom.c     | 15 +--------------
 drivers/net/phy/cicada.c       | 15 +--------------
 drivers/net/phy/davicom.c      | 15 +--------------
 drivers/net/phy/icplus.c       | 15 +--------------
 drivers/net/phy/lxt.c          | 15 +--------------
 drivers/net/phy/marvell.c      | 15 +--------------
 drivers/net/phy/micrel.c       | 15 +--------------
 drivers/net/phy/realtek.c      | 13 +------------
 drivers/net/phy/smsc.c         | 14 +-------------
 drivers/net/phy/ste10Xp.c      | 15 +--------------
 drivers/net/phy/vitesse.c      | 14 +-------------
 16 files changed, 16 insertions(+), 218 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index f3230eef41fd..52e7427c0a38 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -1435,20 +1435,7 @@ static struct phy_driver amd_xgbe_phy_driver[] = {
 	},
 };
 
-static int __init amd_xgbe_phy_init(void)
-{
-	return phy_drivers_register(amd_xgbe_phy_driver,
-				    ARRAY_SIZE(amd_xgbe_phy_driver));
-}
-
-static void __exit amd_xgbe_phy_exit(void)
-{
-	phy_drivers_unregister(amd_xgbe_phy_driver,
-			       ARRAY_SIZE(amd_xgbe_phy_driver));
-}
-
-module_init(amd_xgbe_phy_init);
-module_exit(amd_xgbe_phy_exit);
+module_phy_driver(amd_xgbe_phy_driver);
 
 static struct mdio_device_id __maybe_unused amd_xgbe_phy_ids[] = {
 	{ XGBE_PHY_ID, XGBE_PHY_MASK },
diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index fdc1b418fa6a..f80e19ac6704 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -352,19 +352,7 @@ static struct phy_driver at803x_driver[] = {
 	},
 } };
 
-static int __init atheros_init(void)
-{
-	return phy_drivers_register(at803x_driver,
-				    ARRAY_SIZE(at803x_driver));
-}
-
-static void __exit atheros_exit(void)
-{
-	phy_drivers_unregister(at803x_driver, ARRAY_SIZE(at803x_driver));
-}
-
-module_init(atheros_init);
-module_exit(atheros_exit);
+module_phy_driver(at803x_driver);
 
 static struct mdio_device_id __maybe_unused atheros_tbl[] = {
 	{ ATH8030_PHY_ID, 0xffffffef },
diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index ac55b0807853..830ec31f952f 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -100,20 +100,7 @@ static struct phy_driver bcm63xx_driver[] = {
 	.driver		= { .owner = THIS_MODULE },
 } };
 
-static int __init bcm63xx_phy_init(void)
-{
-	return phy_drivers_register(bcm63xx_driver,
-		ARRAY_SIZE(bcm63xx_driver));
-}
-
-static void __exit bcm63xx_phy_exit(void)
-{
-	phy_drivers_unregister(bcm63xx_driver,
-		ARRAY_SIZE(bcm63xx_driver));
-}
-
-module_init(bcm63xx_phy_init);
-module_exit(bcm63xx_phy_exit);
+module_phy_driver(bcm63xx_driver);
 
 static struct mdio_device_id __maybe_unused bcm63xx_tbl[] = {
 	{ 0x00406000, 0xfffffc00 },
diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index fdce1ea28790..f9de20f93cb8 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -337,20 +337,7 @@ static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
 	{ }
 };
 
-static int __init bcm7xxx_phy_init(void)
-{
-	return phy_drivers_register(bcm7xxx_driver,
-			ARRAY_SIZE(bcm7xxx_driver));
-}
-
-static void __exit bcm7xxx_phy_exit(void)
-{
-	phy_drivers_unregister(bcm7xxx_driver,
-			ARRAY_SIZE(bcm7xxx_driver));
-}
-
-module_init(bcm7xxx_phy_init);
-module_exit(bcm7xxx_phy_exit);
+module_phy_driver(bcm7xxx_driver);
 
 MODULE_DEVICE_TABLE(mdio, bcm7xxx_tbl);
 
diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
index 799789518e87..1eca20452f03 100644
--- a/drivers/net/phy/bcm87xx.c
+++ b/drivers/net/phy/bcm87xx.c
@@ -216,18 +216,6 @@ static struct phy_driver bcm87xx_driver[] = {
 	.driver		= { .owner = THIS_MODULE },
 } };
 
-static int __init bcm87xx_init(void)
-{
-	return phy_drivers_register(bcm87xx_driver,
-		ARRAY_SIZE(bcm87xx_driver));
-}
-module_init(bcm87xx_init);
-
-static void __exit bcm87xx_exit(void)
-{
-	phy_drivers_unregister(bcm87xx_driver,
-		ARRAY_SIZE(bcm87xx_driver));
-}
-module_exit(bcm87xx_exit);
+module_phy_driver(bcm87xx_driver);
 
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 34088d60da74..4e2abfb8552c 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -776,20 +776,7 @@ static struct phy_driver broadcom_drivers[] = {
 	.driver		= { .owner = THIS_MODULE },
 } };
 
-static int __init broadcom_init(void)
-{
-	return phy_drivers_register(broadcom_drivers,
-		ARRAY_SIZE(broadcom_drivers));
-}
-
-static void __exit broadcom_exit(void)
-{
-	phy_drivers_unregister(broadcom_drivers,
-		ARRAY_SIZE(broadcom_drivers));
-}
-
-module_init(broadcom_init);
-module_exit(broadcom_exit);
+module_phy_driver(broadcom_drivers);
 
 static struct mdio_device_id __maybe_unused broadcom_tbl[] = {
 	{ PHY_ID_BCM5411, 0xfffffff0 },
diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index b57ce0cc9657..27f5464899d4 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -129,20 +129,7 @@ static struct phy_driver cis820x_driver[] = {
 	.driver		= { .owner = THIS_MODULE,},
 } };
 
-static int __init cicada_init(void)
-{
-	return phy_drivers_register(cis820x_driver,
-		ARRAY_SIZE(cis820x_driver));
-}
-
-static void __exit cicada_exit(void)
-{
-	phy_drivers_unregister(cis820x_driver,
-		ARRAY_SIZE(cis820x_driver));
-}
-
-module_init(cicada_init);
-module_exit(cicada_exit);
+module_phy_driver(cis820x_driver);
 
 static struct mdio_device_id __maybe_unused cicada_tbl[] = {
 	{ 0x000fc410, 0x000ffff0 },
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index d2c08f625a41..0d16c7d9e1bf 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -182,20 +182,7 @@ static struct phy_driver dm91xx_driver[] = {
 	.driver		= { .owner = THIS_MODULE,},
 } };
 
-static int __init davicom_init(void)
-{
-	return phy_drivers_register(dm91xx_driver,
-		ARRAY_SIZE(dm91xx_driver));
-}
-
-static void __exit davicom_exit(void)
-{
-	phy_drivers_unregister(dm91xx_driver,
-		ARRAY_SIZE(dm91xx_driver));
-}
-
-module_init(davicom_init);
-module_exit(davicom_exit);
+module_phy_driver(dm91xx_driver);
 
 static struct mdio_device_id __maybe_unused davicom_tbl[] = {
 	{ 0x0181b880, 0x0ffffff0 },
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 97bf58bf4939..8644f039d922 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -253,20 +253,7 @@ static struct phy_driver icplus_driver[] = {
 	.driver		= { .owner = THIS_MODULE,},
 } };
 
-static int __init icplus_init(void)
-{
-	return phy_drivers_register(icplus_driver,
-		ARRAY_SIZE(icplus_driver));
-}
-
-static void __exit icplus_exit(void)
-{
-	phy_drivers_unregister(icplus_driver,
-		ARRAY_SIZE(icplus_driver));
-}
-
-module_init(icplus_init);
-module_exit(icplus_exit);
+module_phy_driver(icplus_driver);
 
 static struct mdio_device_id __maybe_unused icplus_tbl[] = {
 	{ 0x02430d80, 0x0ffffff0 },
diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 9108f3191701..a3a5a703635b 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -312,20 +312,7 @@ static struct phy_driver lxt97x_driver[] = {
 	.driver		= { .owner = THIS_MODULE,},
 } };
 
-static int __init lxt_init(void)
-{
-	return phy_drivers_register(lxt97x_driver,
-		ARRAY_SIZE(lxt97x_driver));
-}
-
-static void __exit lxt_exit(void)
-{
-	phy_drivers_unregister(lxt97x_driver,
-		ARRAY_SIZE(lxt97x_driver));
-}
-
-module_init(lxt_init);
-module_exit(lxt_exit);
+module_phy_driver(lxt97x_driver);
 
 static struct mdio_device_id __maybe_unused lxt_tbl[] = {
 	{ 0x78100000, 0xfffffff0 },
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index bd37e45c89c0..708facd78612 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1052,20 +1052,7 @@ static struct phy_driver marvell_drivers[] = {
 	},
 };
 
-static int __init marvell_init(void)
-{
-	return phy_drivers_register(marvell_drivers,
-		 ARRAY_SIZE(marvell_drivers));
-}
-
-static void __exit marvell_exit(void)
-{
-	phy_drivers_unregister(marvell_drivers,
-		 ARRAY_SIZE(marvell_drivers));
-}
-
-module_init(marvell_init);
-module_exit(marvell_exit);
+module_phy_driver(marvell_drivers);
 
 static struct mdio_device_id __maybe_unused marvell_tbl[] = {
 	{ MARVELL_PHY_ID_88E1101, MARVELL_PHY_ID_MASK },
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 8c2a29a9bd7f..bcc6c0ea75fa 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -657,20 +657,7 @@ static struct phy_driver ksphy_driver[] = {
 	.driver		= { .owner = THIS_MODULE, },
 } };
 
-static int __init ksphy_init(void)
-{
-	return phy_drivers_register(ksphy_driver,
-		ARRAY_SIZE(ksphy_driver));
-}
-
-static void __exit ksphy_exit(void)
-{
-	phy_drivers_unregister(ksphy_driver,
-		ARRAY_SIZE(ksphy_driver));
-}
-
-module_init(ksphy_init);
-module_exit(ksphy_exit);
+module_phy_driver(ksphy_driver);
 
 MODULE_DESCRIPTION("Micrel PHY driver");
 MODULE_AUTHOR("David J. Choi");
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 45483fdfbe06..96a0f0fab3ca 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -101,18 +101,7 @@ static struct phy_driver realtek_drvs[] = {
 	},
 };
 
-static int __init realtek_init(void)
-{
-	return phy_drivers_register(realtek_drvs, ARRAY_SIZE(realtek_drvs));
-}
-
-static void __exit realtek_exit(void)
-{
-	phy_drivers_unregister(realtek_drvs, ARRAY_SIZE(realtek_drvs));
-}
-
-module_init(realtek_init);
-module_exit(realtek_exit);
+module_phy_driver(realtek_drvs);
 
 static struct mdio_device_id __maybe_unused realtek_tbl[] = {
 	{ 0x001cc912, 0x001fffff },
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index a4b08198fb9f..c0f6479e19d4 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -250,24 +250,12 @@ static struct phy_driver smsc_phy_driver[] = {
 	.driver		= { .owner = THIS_MODULE, }
 } };
 
-static int __init smsc_init(void)
-{
-	return phy_drivers_register(smsc_phy_driver,
-		ARRAY_SIZE(smsc_phy_driver));
-}
-
-static void __exit smsc_exit(void)
-{
-	phy_drivers_unregister(smsc_phy_driver, ARRAY_SIZE(smsc_phy_driver));
-}
+module_phy_driver(smsc_phy_driver);
 
 MODULE_DESCRIPTION("SMSC PHY driver");
 MODULE_AUTHOR("Herbert Valerio Riedel");
 MODULE_LICENSE("GPL");
 
-module_init(smsc_init);
-module_exit(smsc_exit);
-
 static struct mdio_device_id __maybe_unused smsc_tbl[] = {
 	{ 0x0007c0a0, 0xfffffff0 },
 	{ 0x0007c0b0, 0xfffffff0 },
diff --git a/drivers/net/phy/ste10Xp.c b/drivers/net/phy/ste10Xp.c
index 5e1eb138916f..3fc199b773e6 100644
--- a/drivers/net/phy/ste10Xp.c
+++ b/drivers/net/phy/ste10Xp.c
@@ -112,20 +112,7 @@ static struct phy_driver ste10xp_pdriver[] = {
 	.driver = {.owner = THIS_MODULE,}
 } };
 
-static int __init ste10Xp_init(void)
-{
-	return phy_drivers_register(ste10xp_pdriver,
-		ARRAY_SIZE(ste10xp_pdriver));
-}
-
-static void __exit ste10Xp_exit(void)
-{
-	phy_drivers_unregister(ste10xp_pdriver,
-		ARRAY_SIZE(ste10xp_pdriver));
-}
-
-module_init(ste10Xp_init);
-module_exit(ste10Xp_exit);
+module_phy_driver(ste10xp_pdriver);
 
 static struct mdio_device_id __maybe_unused ste10Xp_tbl[] = {
 	{ STE101P_PHY_ID, 0xfffffff0 },
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 5dc0935da99c..76cad712ddb2 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -311,19 +311,7 @@ static struct phy_driver vsc82xx_driver[] = {
 	.driver		= { .owner = THIS_MODULE,},
 } };
 
-static int __init vsc82xx_init(void)
-{
-	return phy_drivers_register(vsc82xx_driver,
-		ARRAY_SIZE(vsc82xx_driver));
-}
-
-static void __exit vsc82xx_exit(void)
-{
-	phy_drivers_unregister(vsc82xx_driver, ARRAY_SIZE(vsc82xx_driver));
-}
-
-module_init(vsc82xx_init);
-module_exit(vsc82xx_exit);
+module_phy_driver(vsc82xx_driver);
 
 static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8234, 0x000ffff0 },
-- 
2.0.4
