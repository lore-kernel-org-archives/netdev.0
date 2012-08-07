From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v3 7/7] NET: mv643xx: remove device name macro.
Date: Tue,  7 Aug 2012 15:34:52 +0100
Message-ID: <1344350092-24050-8-git-send-email-ian.molton@codethink.co.uk>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:50829 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755029Ab2HGOfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 10:35:09 -0400
In-Reply-To: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coding style: remove the macros:

MV643XX_ETH_NAME and
MV643XX_ETH_SHARED_NAME

Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
---
 arch/arm/mach-kirkwood/board-dt.c          |    4 ++--
 arch/arm/mach-kirkwood/common.c            |    4 ++--
 arch/arm/plat-orion/common.c               |   24 ++++++++++++------------
 arch/powerpc/platforms/chrp/pegasos_eth.c  |    4 ++--
 arch/powerpc/sysdev/mv64x60_dev.c          |    5 ++---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    8 ++++----
 include/linux/mv643xx_eth.h                |    2 --
 7 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
index aa213b6..91784d9 100644
--- a/arch/arm/mach-kirkwood/board-dt.c
+++ b/arch/arm/mach-kirkwood/board-dt.c
@@ -34,9 +34,9 @@ struct of_dev_auxdata kirkwood_auxdata_lookup[] __initdata = {
 	OF_DEV_AUXDATA("marvell,orion-wdt", 0xf1020300, "orion_wdt", NULL),
 	OF_DEV_AUXDATA("marvell,orion-sata", 0xf1080000, "sata_mv.0", NULL),
 	OF_DEV_AUXDATA("marvell,orion-nand", 0xf4000000, "orion_nand", NULL),
-	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1072000, "mv643xx_eth_port.0",
+	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1072000, "mv643xx_eth.0",
 			NULL),
-	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1076000, "mv643xx_eth_port.1",
+	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1076000, "mv643xx_eth.1",
 			NULL),
 	{},
 };
diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
index 57b91cf..eb0a253 100644
--- a/arch/arm/mach-kirkwood/common.c
+++ b/arch/arm/mach-kirkwood/common.c
@@ -264,8 +264,8 @@ void __init kirkwood_clk_init(void)
 	/* clkdev entries, mapping clks to devices */
 	orion_clkdev_add(NULL, "orion_spi.0", runit);
 	orion_clkdev_add(NULL, "orion_spi.1", runit);
-	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".0", ge0);
-	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".1", ge1);
+	orion_clkdev_add(NULL, "mv643xx_eth.0", ge0);
+	orion_clkdev_add(NULL, "mv643xx_eth.1", ge1);
 	orion_clkdev_add(NULL, "orion_wdt", tclk);
 	orion_clkdev_add("0", "sata_mv.0", sata0);
 	orion_clkdev_add("1", "sata_mv.0", sata1);
diff --git a/arch/arm/plat-orion/common.c b/arch/arm/plat-orion/common.c
index d245a87..d4a6467 100644
--- a/arch/arm/plat-orion/common.c
+++ b/arch/arm/plat-orion/common.c
@@ -42,10 +42,10 @@ void __init orion_clkdev_init(struct clk *tclk)
 {
 	orion_clkdev_add(NULL, "orion_spi.0", tclk);
 	orion_clkdev_add(NULL, "orion_spi.1", tclk);
-	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".0", tclk);
-	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".1", tclk);
-	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".2", tclk);
-	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".3", tclk);
+	orion_clkdev_add(NULL, "mv643xx_eth.0", tclk);
+	orion_clkdev_add(NULL, "mv643xx_eth.1", tclk);
+	orion_clkdev_add(NULL, "mv643xx_eth.2", tclk);
+	orion_clkdev_add(NULL, "mv643xx_eth.3", tclk);
 	orion_clkdev_add(NULL, "orion_wdt", tclk);
 	orion_clkdev_add(NULL, MV64XXX_I2C_CTLR_NAME ".0", tclk);
 }
@@ -264,7 +264,7 @@ static struct resource orion_ge00_shared_resources[] = {
 };
 
 static struct platform_device orion_ge00_shared = {
-	.name		= MV643XX_ETH_SHARED_NAME,
+	.name		= "mdio-mv643xx",
 	.id		= 0,
 	.dev		= {
 		.platform_data	= &orion_ge00_shared_data,
@@ -279,7 +279,7 @@ static struct resource orion_ge00_resources[] = {
 };
 
 static struct platform_device orion_ge00 = {
-	.name		= MV643XX_ETH_NAME,
+	.name		= "mv643xx_eth",
 	.id		= 0,
 	.num_resources	= 1,
 	.resource	= orion_ge00_resources,
@@ -316,7 +316,7 @@ static struct resource orion_ge01_shared_resources[] = {
 };
 
 static struct platform_device orion_ge01_shared = {
-	.name		= MV643XX_ETH_SHARED_NAME,
+	.name		= "mdio-mv643xx",
 	.id		= 1,
 	.dev		= {
 		.platform_data	= &orion_ge01_shared_data,
@@ -331,7 +331,7 @@ static struct resource orion_ge01_resources[] = {
 };
 
 static struct platform_device orion_ge01 = {
-	.name		= MV643XX_ETH_NAME,
+	.name		= "mv643xx_eth",
 	.id		= 1,
 	.num_resources	= 1,
 	.resource	= orion_ge01_resources,
@@ -368,7 +368,7 @@ static struct resource orion_ge10_shared_resources[] = {
 };
 
 static struct platform_device orion_ge10_shared = {
-	.name		= MV643XX_ETH_SHARED_NAME,
+	.name		= "mdio-mv643xx",
 	.id		= 1,
 	.dev		= {
 		.platform_data	= &orion_ge10_shared_data,
@@ -383,7 +383,7 @@ static struct resource orion_ge10_resources[] = {
 };
 
 static struct platform_device orion_ge10 = {
-	.name		= MV643XX_ETH_NAME,
+	.name		= "mv643xx_eth",
 	.id		= 1,
 	.num_resources	= 2,
 	.resource	= orion_ge10_resources,
@@ -420,7 +420,7 @@ static struct resource orion_ge11_shared_resources[] = {
 };
 
 static struct platform_device orion_ge11_shared = {
-	.name		= MV643XX_ETH_SHARED_NAME,
+	.name		= "mdio-mv643xx",
 	.id		= 1,
 	.dev		= {
 		.platform_data	= &orion_ge11_shared_data,
@@ -435,7 +435,7 @@ static struct resource orion_ge11_resources[] = {
 };
 
 static struct platform_device orion_ge11 = {
-	.name		= MV643XX_ETH_NAME,
+	.name		= "mv643xx_eth",
 	.id		= 1,
 	.num_resources	= 2,
 	.resource	= orion_ge11_resources,
diff --git a/arch/powerpc/platforms/chrp/pegasos_eth.c b/arch/powerpc/platforms/chrp/pegasos_eth.c
index 039fc8e..1832127 100644
--- a/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -41,7 +41,7 @@ static struct resource mv643xx_eth_shared_resources[] = {
 };
 
 static struct platform_device mv643xx_eth_shared_device = {
-	.name		= MV643XX_ETH_SHARED_NAME,
+	.name		= "mdio-mv643xx",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(mv643xx_eth_shared_resources),
 	.resource	= mv643xx_eth_shared_resources,
@@ -71,7 +71,7 @@ static struct mv643xx_eth_platform_data eth_port1_pd = {
 };
 
 static struct platform_device eth_port1_device = {
-	.name		= MV643XX_ETH_NAME,
+	.name		= "mv643xx_eth",
 	.id		= 1,
 	.num_resources	= ARRAY_SIZE(mv643xx_eth_port1_resources),
 	.resource	= mv643xx_eth_port1_resources,
diff --git a/arch/powerpc/sysdev/mv64x60_dev.c b/arch/powerpc/sysdev/mv64x60_dev.c
index 0f6af41..ca404ec 100644
--- a/arch/powerpc/sysdev/mv64x60_dev.c
+++ b/arch/powerpc/sysdev/mv64x60_dev.c
@@ -221,8 +221,7 @@ static struct platform_device * __init mv64x60_eth_register_shared_pdev(
 	if (err)
 		return ERR_PTR(err);
 
-	pdev = platform_device_register_simple(MV643XX_ETH_SHARED_NAME, id,
-					       r, 1);
+	pdev = platform_device_register_simple("mdio-mv643xx", id, i r, 1);
 	return pdev;
 }
 
@@ -296,7 +295,7 @@ static int __init mv64x60_eth_device_setup(struct device_node *np, int id,
 
 	of_node_put(phy);
 
-	pdev = platform_device_alloc(MV643XX_ETH_NAME, id);
+	pdev = platform_device_alloc("mv643xx_eth", id);
 	if (!pdev)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index bb80050..9371601 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2746,7 +2746,7 @@ static struct platform_driver mv643xx_eth_shared_driver = {
 	.probe		= mv643xx_eth_shared_probe,
 	.remove		= mv643xx_eth_shared_remove,
 	.driver = {
-		.name	= MV643XX_ETH_SHARED_NAME,
+		.name	= "mdio-mv643xx",
 		.owner	= THIS_MODULE,
 		.of_match_table = of_match_ptr(mv_mdio_dt_ids),
 	},
@@ -3113,7 +3113,7 @@ static struct platform_driver mv643xx_eth_driver = {
 	.remove		= mv643xx_eth_remove,
 	.shutdown	= mv643xx_eth_shutdown,
 	.driver = {
-		.name	= MV643XX_ETH_NAME,
+		.name	= "mv643xx_eth",
 		.owner	= THIS_MODULE,
 		.of_match_table = of_match_ptr(mv_eth_dt_ids),
 	},
@@ -3145,5 +3145,5 @@ MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, "
 	      "Manish Lachwani, Dale Farnsworth and Lennert Buytenhek");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("platform:" MV643XX_ETH_SHARED_NAME);
-MODULE_ALIAS("platform:" MV643XX_ETH_NAME);
+MODULE_ALIAS("platform:" "mdio-mv643xx");
+MODULE_ALIAS("platform:" "mv643xx_eth");
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 51bf8ad..33dc6f4 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -7,8 +7,6 @@
 
 #include <linux/mbus.h>
 
-#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth"
-#define MV643XX_ETH_NAME		"mv643xx_eth_port"
 #define MV643XX_ETH_SHARED_REGS		0x2000
 #define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
 #define MV643XX_ETH_BAR_4		0x2220
-- 
1.7.9.5
