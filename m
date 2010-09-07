From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH v3 05/10] davinci: cleanup unused davinci mdio arch code
Date: Tue,  7 Sep 2010 16:25:37 -0400
Message-ID: <1283891142-15522-6-git-send-email-cyril@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com>
Cc: davem@davemloft.net, khilman@deeprootsystems.com, tony@atomide.com,
	Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1283891142-15522-1-git-send-email-cyril@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes davinci architecture code that has now been rendered
useless by the previous patches in the MDIO separation series.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 arch/arm/mach-davinci/board-da830-evm.c     |    5 -----
 arch/arm/mach-davinci/board-da850-evm.c     |    6 ------
 arch/arm/mach-davinci/board-dm365-evm.c     |    7 -------
 arch/arm/mach-davinci/board-dm644x-evm.c    |    7 -------
 arch/arm/mach-davinci/board-dm646x-evm.c    |    8 --------
 arch/arm/mach-davinci/board-mityomapl138.c  |    7 -------
 arch/arm/mach-davinci/board-neuros-osd2.c   |    7 -------
 arch/arm/mach-davinci/board-sffsdr.c        |    7 -------
 arch/arm/mach-davinci/devices-da8xx.c       |    2 --
 arch/arm/mach-davinci/dm365.c               |    1 -
 arch/arm/mach-davinci/dm644x.c              |    1 -
 arch/arm/mach-davinci/dm646x.c              |    1 -
 arch/arm/mach-davinci/include/mach/dm365.h  |    1 -
 arch/arm/mach-davinci/include/mach/dm644x.h |    1 -
 arch/arm/mach-davinci/include/mach/dm646x.h |    1 -
 15 files changed, 0 insertions(+), 62 deletions(-)

diff --git a/arch/arm/mach-davinci/board-da830-evm.c b/arch/arm/mach-davinci/board-da830-evm.c
index ef1ab0b..2613324 100644
--- a/arch/arm/mach-davinci/board-da830-evm.c
+++ b/arch/arm/mach-davinci/board-da830-evm.c
@@ -31,9 +31,6 @@
 #include <mach/usb.h>
 #include <mach/aemif.h>
 
-#define DA830_EVM_PHY_MASK		0x0
-#define DA830_EVM_MDIO_FREQUENCY	2200000	/* PHY bus frequency */
-
 /*
  * USB1 VBUS is controlled by GPIO1[15], over-current is reported on GPIO2[4].
  */
@@ -558,8 +555,6 @@ static __init void da830_evm_init(void)
 
 	da830_evm_usb_init();
 
-	soc_info->emac_pdata->phy_mask = DA830_EVM_PHY_MASK;
-	soc_info->emac_pdata->mdio_max_freq = DA830_EVM_MDIO_FREQUENCY;
 	soc_info->emac_pdata->rmii_en = 1;
 
 	ret = davinci_cfg_reg_list(da830_cpgmac_pins);
diff --git a/arch/arm/mach-davinci/board-da850-evm.c b/arch/arm/mach-davinci/board-da850-evm.c
index ac2297c..9d4dfcb 100644
--- a/arch/arm/mach-davinci/board-da850-evm.c
+++ b/arch/arm/mach-davinci/board-da850-evm.c
@@ -38,9 +38,6 @@
 #include <mach/mux.h>
 #include <mach/aemif.h>
 
-#define DA850_EVM_PHY_MASK		0x1
-#define DA850_EVM_MDIO_FREQUENCY	2200000 /* PHY bus frequency */
-
 #define DA850_LCD_PWR_PIN		GPIO_TO_PIN(2, 8)
 #define DA850_LCD_BL_PIN		GPIO_TO_PIN(2, 15)
 
@@ -678,9 +675,6 @@ static int __init da850_evm_config_emac(void)
 	/* Enable/Disable MII MDIO clock */
 	gpio_direction_output(DA850_MII_MDIO_CLKEN_PIN, rmii_en);
 
-	soc_info->emac_pdata->phy_mask = DA850_EVM_PHY_MASK;
-	soc_info->emac_pdata->mdio_max_freq = DA850_EVM_MDIO_FREQUENCY;
-
 	ret = da8xx_register_emac();
 	if (ret)
 		pr_warning("da850_evm_init: emac registration failed: %d\n",
diff --git a/arch/arm/mach-davinci/board-dm365-evm.c b/arch/arm/mach-davinci/board-dm365-evm.c
index 60c59dd..f697914 100644
--- a/arch/arm/mach-davinci/board-dm365-evm.c
+++ b/arch/arm/mach-davinci/board-dm365-evm.c
@@ -54,9 +54,6 @@ static inline int have_tvp7002(void)
 	return 0;
 }
 
-#define DM365_EVM_PHY_MASK		(0x2)
-#define DM365_EVM_MDIO_FREQUENCY	(2200000) /* PHY bus frequency */
-
 /*
  * A MAX-II CPLD is used for various board control functions.
  */
@@ -530,16 +527,12 @@ fail:
 		/* externally mux MMC1/ENET/AIC33 to imager */
 		mux |= BIT(6) | BIT(5) | BIT(3);
 	} else {
-		struct davinci_soc_info *soc_info = &davinci_soc_info;
-
 		/* we can use MMC1 ... */
 		dm365evm_mmc_configure();
 		davinci_setup_mmc(1, &dm365evm_mmc_config);
 
 		/* ... and ENET ... */
 		dm365evm_emac_configure();
-		soc_info->emac_pdata->phy_mask = DM365_EVM_PHY_MASK;
-		soc_info->emac_pdata->mdio_max_freq = DM365_EVM_MDIO_FREQUENCY;
 		resets &= ~BIT(3);
 
 		/* ... and AIC33 */
diff --git a/arch/arm/mach-davinci/board-dm644x-evm.c b/arch/arm/mach-davinci/board-dm644x-evm.c
index 65bb940..c86bf23 100644
--- a/arch/arm/mach-davinci/board-dm644x-evm.c
+++ b/arch/arm/mach-davinci/board-dm644x-evm.c
@@ -39,9 +39,6 @@
 #include <mach/usb.h>
 #include <mach/aemif.h>
 
-#define DM644X_EVM_PHY_MASK		(0x2)
-#define DM644X_EVM_MDIO_FREQUENCY	(2200000) /* PHY bus frequency */
-
 #define LXT971_PHY_ID	(0x001378e2)
 #define LXT971_PHY_MASK	(0xfffffff0)
 
@@ -672,7 +669,6 @@ static int davinci_phy_fixup(struct phy_device *phydev)
 static __init void davinci_evm_init(void)
 {
 	struct clk *aemif_clk;
-	struct davinci_soc_info *soc_info = &davinci_soc_info;
 
 	aemif_clk = clk_get(NULL, "aemif");
 	clk_enable(aemif_clk);
@@ -707,9 +703,6 @@ static __init void davinci_evm_init(void)
 	davinci_serial_init(&uart_config);
 	dm644x_init_asp(&dm644x_evm_snd_data);
 
-	soc_info->emac_pdata->phy_mask = DM644X_EVM_PHY_MASK;
-	soc_info->emac_pdata->mdio_max_freq = DM644X_EVM_MDIO_FREQUENCY;
-
 	/* Register the fixup for PHY on DaVinci */
 	phy_register_fixup_for_uid(LXT971_PHY_ID, LXT971_PHY_MASK,
 					davinci_phy_fixup);
diff --git a/arch/arm/mach-davinci/board-dm646x-evm.c b/arch/arm/mach-davinci/board-dm646x-evm.c
index 5a29955..3f34221 100644
--- a/arch/arm/mach-davinci/board-dm646x-evm.c
+++ b/arch/arm/mach-davinci/board-dm646x-evm.c
@@ -729,9 +729,6 @@ static struct davinci_uart_config uart_config __initdata = {
 	.enabled_uarts = (1 << 0),
 };
 
-#define DM646X_EVM_PHY_MASK		(0x2)
-#define DM646X_EVM_MDIO_FREQUENCY	(2200000) /* PHY bus frequency */
-
 /*
  * The following EDMA channels/slots are not being used by drivers (for
  * example: Timer, GPIO, UART events etc) on dm646x, hence they are being
@@ -767,8 +764,6 @@ static struct edma_rsv_info dm646x_edma_rsv[] = {
 
 static __init void evm_init(void)
 {
-	struct davinci_soc_info *soc_info = &davinci_soc_info;
-
 	evm_init_i2c();
 	davinci_serial_init(&uart_config);
 	dm646x_init_mcasp0(&dm646x_evm_snd_data[0]);
@@ -783,9 +778,6 @@ static __init void evm_init(void)
 
 	if (HAS_ATA)
 		davinci_init_ide();
-
-	soc_info->emac_pdata->phy_mask = DM646X_EVM_PHY_MASK;
-	soc_info->emac_pdata->mdio_max_freq = DM646X_EVM_MDIO_FREQUENCY;
 }
 
 #define DM646X_EVM_REF_FREQ		27000000
diff --git a/arch/arm/mach-davinci/board-mityomapl138.c b/arch/arm/mach-davinci/board-mityomapl138.c
index 7146916..ec5808f 100644
--- a/arch/arm/mach-davinci/board-mityomapl138.c
+++ b/arch/arm/mach-davinci/board-mityomapl138.c
@@ -22,9 +22,6 @@
 #include <mach/nand.h>
 #include <mach/mux.h>
 
-#define MITYOMAPL138_PHY_MASK		0x08 /* hardcoded for now */
-#define MITYOMAPL138_MDIO_FREQUENCY	(2200000) /* PHY bus frequency */
-
 /*
  * MityDSP-L138 includes a 256 MByte large-page NAND flash
  * (128K blocks).
@@ -136,10 +133,6 @@ static void __init mityomapl138_config_emac(void)
 	/* configure the CFGCHIP3 register for RMII or MII */
 	__raw_writel(val, cfg_chip3_base);
 
-	soc_info->emac_pdata->phy_mask = MITYOMAPL138_PHY_MASK;
-	pr_debug("setting phy_mask to %x\n", soc_info->emac_pdata->phy_mask);
-	soc_info->emac_pdata->mdio_max_freq = MITYOMAPL138_MDIO_FREQUENCY;
-
 	ret = da8xx_register_emac();
 	if (ret)
 		pr_warning("emac registration failed: %d\n", ret);
diff --git a/arch/arm/mach-davinci/board-neuros-osd2.c b/arch/arm/mach-davinci/board-neuros-osd2.c
index 4c30e92..4b32f0a 100644
--- a/arch/arm/mach-davinci/board-neuros-osd2.c
+++ b/arch/arm/mach-davinci/board-neuros-osd2.c
@@ -39,9 +39,6 @@
 #include <mach/mmc.h>
 #include <mach/usb.h>
 
-#define NEUROS_OSD2_PHY_MASK		0x2
-#define NEUROS_OSD2_MDIO_FREQUENCY	2200000 /* PHY bus frequency */
-
 #define LXT971_PHY_ID			0x001378e2
 #define LXT971_PHY_MASK			0xfffffff0
 
@@ -218,7 +215,6 @@ static struct davinci_mmc_config davinci_ntosd2_mmc_config = {
 static __init void davinci_ntosd2_init(void)
 {
 	struct clk *aemif_clk;
-	struct davinci_soc_info *soc_info = &davinci_soc_info;
 	int	status;
 
 	aemif_clk = clk_get(NULL, "aemif");
@@ -252,9 +248,6 @@ static __init void davinci_ntosd2_init(void)
 	davinci_serial_init(&uart_config);
 	dm644x_init_asp(&dm644x_ntosd2_snd_data);
 
-	soc_info->emac_pdata->phy_mask = NEUROS_OSD2_PHY_MASK;
-	soc_info->emac_pdata->mdio_max_freq = NEUROS_OSD2_MDIO_FREQUENCY;
-
 	davinci_setup_usb(1000, 8);
 	/*
 	 * Mux the pins to be GPIOs, VLYNQEN is already done at startup.
diff --git a/arch/arm/mach-davinci/board-sffsdr.c b/arch/arm/mach-davinci/board-sffsdr.c
index 23e664a..b372d7f 100644
--- a/arch/arm/mach-davinci/board-sffsdr.c
+++ b/arch/arm/mach-davinci/board-sffsdr.c
@@ -42,9 +42,6 @@
 #include <mach/mux.h>
 #include <mach/usb.h>
 
-#define SFFSDR_PHY_MASK		(0x2)
-#define SFFSDR_MDIO_FREQUENCY	(2200000) /* PHY bus frequency */
-
 static struct mtd_partition davinci_sffsdr_nandflash_partition[] = {
 	/* U-Boot Environment: Block 0
 	 * UBL:                Block 1
@@ -137,14 +134,10 @@ static void __init davinci_sffsdr_map_io(void)
 
 static __init void davinci_sffsdr_init(void)
 {
-	struct davinci_soc_info *soc_info = &davinci_soc_info;
-
 	platform_add_devices(davinci_sffsdr_devices,
 			     ARRAY_SIZE(davinci_sffsdr_devices));
 	sffsdr_init_i2c();
 	davinci_serial_init(&uart_config);
-	soc_info->emac_pdata->phy_mask = SFFSDR_PHY_MASK;
-	soc_info->emac_pdata->mdio_max_freq = SFFSDR_MDIO_FREQUENCY;
 	davinci_setup_usb(0, 0); /* We support only peripheral mode. */
 
 	/* mux VLYNQ pins */
diff --git a/arch/arm/mach-davinci/devices-da8xx.c b/arch/arm/mach-davinci/devices-da8xx.c
index 9039221..9eec630 100644
--- a/arch/arm/mach-davinci/devices-da8xx.c
+++ b/arch/arm/mach-davinci/devices-da8xx.c
@@ -42,7 +42,6 @@
 #define DA8XX_EMAC_CTRL_REG_OFFSET	0x3000
 #define DA8XX_EMAC_MOD_REG_OFFSET	0x2000
 #define DA8XX_EMAC_RAM_OFFSET		0x0000
-#define DA8XX_MDIO_REG_OFFSET		0x4000
 #define DA8XX_EMAC_CTRL_RAM_SIZE	SZ_8K
 
 void __iomem *da8xx_syscfg0_base;
@@ -381,7 +380,6 @@ struct emac_platform_data da8xx_emac_pdata = {
 	.ctrl_reg_offset	= DA8XX_EMAC_CTRL_REG_OFFSET,
 	.ctrl_mod_reg_offset	= DA8XX_EMAC_MOD_REG_OFFSET,
 	.ctrl_ram_offset	= DA8XX_EMAC_RAM_OFFSET,
-	.mdio_reg_offset	= DA8XX_MDIO_REG_OFFSET,
 	.ctrl_ram_size		= DA8XX_EMAC_CTRL_RAM_SIZE,
 	.version		= EMAC_VERSION_2,
 };
diff --git a/arch/arm/mach-davinci/dm365.c b/arch/arm/mach-davinci/dm365.c
index 0add1ca..a12065e 100644
--- a/arch/arm/mach-davinci/dm365.c
+++ b/arch/arm/mach-davinci/dm365.c
@@ -691,7 +691,6 @@ static struct emac_platform_data dm365_emac_pdata = {
 	.ctrl_reg_offset	= DM365_EMAC_CNTRL_OFFSET,
 	.ctrl_mod_reg_offset	= DM365_EMAC_CNTRL_MOD_OFFSET,
 	.ctrl_ram_offset	= DM365_EMAC_CNTRL_RAM_OFFSET,
-	.mdio_reg_offset	= DM365_EMAC_MDIO_OFFSET,
 	.ctrl_ram_size		= DM365_EMAC_CNTRL_RAM_SIZE,
 	.version		= EMAC_VERSION_2,
 };
diff --git a/arch/arm/mach-davinci/dm644x.c b/arch/arm/mach-davinci/dm644x.c
index 22166a5..0608dd7 100644
--- a/arch/arm/mach-davinci/dm644x.c
+++ b/arch/arm/mach-davinci/dm644x.c
@@ -322,7 +322,6 @@ static struct emac_platform_data dm644x_emac_pdata = {
 	.ctrl_reg_offset	= DM644X_EMAC_CNTRL_OFFSET,
 	.ctrl_mod_reg_offset	= DM644X_EMAC_CNTRL_MOD_OFFSET,
 	.ctrl_ram_offset	= DM644X_EMAC_CNTRL_RAM_OFFSET,
-	.mdio_reg_offset	= DM644X_EMAC_MDIO_OFFSET,
 	.ctrl_ram_size		= DM644X_EMAC_CNTRL_RAM_SIZE,
 	.version		= EMAC_VERSION_1,
 };
diff --git a/arch/arm/mach-davinci/dm646x.c b/arch/arm/mach-davinci/dm646x.c
index 3d636b2..1e0f809 100644
--- a/arch/arm/mach-davinci/dm646x.c
+++ b/arch/arm/mach-davinci/dm646x.c
@@ -358,7 +358,6 @@ static struct emac_platform_data dm646x_emac_pdata = {
 	.ctrl_reg_offset	= DM646X_EMAC_CNTRL_OFFSET,
 	.ctrl_mod_reg_offset	= DM646X_EMAC_CNTRL_MOD_OFFSET,
 	.ctrl_ram_offset	= DM646X_EMAC_CNTRL_RAM_OFFSET,
-	.mdio_reg_offset	= DM646X_EMAC_MDIO_OFFSET,
 	.ctrl_ram_size		= DM646X_EMAC_CNTRL_RAM_SIZE,
 	.version		= EMAC_VERSION_2,
 };
diff --git a/arch/arm/mach-davinci/include/mach/dm365.h b/arch/arm/mach-davinci/include/mach/dm365.h
index dbb5052..2563bf4 100644
--- a/arch/arm/mach-davinci/include/mach/dm365.h
+++ b/arch/arm/mach-davinci/include/mach/dm365.h
@@ -25,7 +25,6 @@
 #define DM365_EMAC_CNTRL_OFFSET		(0x0000)
 #define DM365_EMAC_CNTRL_MOD_OFFSET	(0x3000)
 #define DM365_EMAC_CNTRL_RAM_OFFSET	(0x1000)
-#define DM365_EMAC_MDIO_OFFSET		(0x4000)
 #define DM365_EMAC_CNTRL_RAM_SIZE	(0x2000)
 
 /* Base of key scan register bank */
diff --git a/arch/arm/mach-davinci/include/mach/dm644x.h b/arch/arm/mach-davinci/include/mach/dm644x.h
index 5159117..5a1b26d 100644
--- a/arch/arm/mach-davinci/include/mach/dm644x.h
+++ b/arch/arm/mach-davinci/include/mach/dm644x.h
@@ -32,7 +32,6 @@
 #define DM644X_EMAC_CNTRL_OFFSET	(0x0000)
 #define DM644X_EMAC_CNTRL_MOD_OFFSET	(0x1000)
 #define DM644X_EMAC_CNTRL_RAM_OFFSET	(0x2000)
-#define DM644X_EMAC_MDIO_OFFSET		(0x4000)
 #define DM644X_EMAC_CNTRL_RAM_SIZE	(0x2000)
 
 #define DM644X_ASYNC_EMIF_CONTROL_BASE	0x01E00000
diff --git a/arch/arm/mach-davinci/include/mach/dm646x.h b/arch/arm/mach-davinci/include/mach/dm646x.h
index 1c4dca9..7a27f3f 100644
--- a/arch/arm/mach-davinci/include/mach/dm646x.h
+++ b/arch/arm/mach-davinci/include/mach/dm646x.h
@@ -23,7 +23,6 @@
 #define DM646X_EMAC_CNTRL_OFFSET	(0x0000)
 #define DM646X_EMAC_CNTRL_MOD_OFFSET	(0x1000)
 #define DM646X_EMAC_CNTRL_RAM_OFFSET	(0x2000)
-#define DM646X_EMAC_MDIO_OFFSET		(0x4000)
 #define DM646X_EMAC_CNTRL_RAM_SIZE	(0x2000)
 
 #define DM646X_ASYNC_EMIF_CONTROL_BASE	0x20008000
-- 
1.7.0.4

