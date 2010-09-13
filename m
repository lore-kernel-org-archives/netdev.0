From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 2/9] davinci: specify phy_id rather than auto-detect
Date: Mon, 13 Sep 2010 14:07:24 -0400
Message-ID: <1284401251-8846-3-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Cc: michael.williamson@criticallink.com, caglarakyuz@gmail.com,
	bparrot@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cpdma/mdio refactoring incorrectly defaulted to using the first phy
detected on the platform.  Although auto detection works on most sane
platforms, it can prove to be problematic on some.

For example, the da830/omap-l137 evm has an on-board switch that always
connects 100/full.  Consequently, normal phy auto-detection does not work
on this platform.

Rather than risk breaking other boards, this patch reverts to using hard-coded
phy ids on platforms that did so earlier.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Michael Williamson <michael.williamson@criticallink.com>
Signed-off-by: Caglar Akyuz <caglarakyuz@gmail.com>
---
 arch/arm/mach-davinci/board-da830-evm.c    |    2 ++
 arch/arm/mach-davinci/board-da850-evm.c    |    3 +++
 arch/arm/mach-davinci/board-dm365-evm.c    |    4 ++++
 arch/arm/mach-davinci/board-dm644x-evm.c   |    3 +++
 arch/arm/mach-davinci/board-dm646x-evm.c   |    5 +++++
 arch/arm/mach-davinci/board-mityomapl138.c |    3 +++
 arch/arm/mach-davinci/board-neuros-osd2.c  |    4 ++++
 arch/arm/mach-davinci/board-sffsdr.c       |    4 ++++
 8 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-davinci/board-da830-evm.c b/arch/arm/mach-davinci/board-da830-evm.c
index 2613324..1bb89d3 100644
--- a/arch/arm/mach-davinci/board-da830-evm.c
+++ b/arch/arm/mach-davinci/board-da830-evm.c
@@ -31,6 +31,7 @@
 #include <mach/usb.h>
 #include <mach/aemif.h>
 
+#define DA830_EVM_PHY_ID		""
 /*
  * USB1 VBUS is controlled by GPIO1[15], over-current is reported on GPIO2[4].
  */
@@ -556,6 +557,7 @@ static __init void da830_evm_init(void)
 	da830_evm_usb_init();
 
 	soc_info->emac_pdata->rmii_en = 1;
+	soc_info->emac_pdata->phy_id = DA830_EVM_PHY_ID;
 
 	ret = davinci_cfg_reg_list(da830_cpgmac_pins);
 	if (ret)
diff --git a/arch/arm/mach-davinci/board-da850-evm.c b/arch/arm/mach-davinci/board-da850-evm.c
index 9d4dfcb..5e435b0 100644
--- a/arch/arm/mach-davinci/board-da850-evm.c
+++ b/arch/arm/mach-davinci/board-da850-evm.c
@@ -38,6 +38,7 @@
 #include <mach/mux.h>
 #include <mach/aemif.h>
 
+#define DA850_EVM_PHY_ID		"0:00"
 #define DA850_LCD_PWR_PIN		GPIO_TO_PIN(2, 8)
 #define DA850_LCD_BL_PIN		GPIO_TO_PIN(2, 15)
 
@@ -675,6 +676,8 @@ static int __init da850_evm_config_emac(void)
 	/* Enable/Disable MII MDIO clock */
 	gpio_direction_output(DA850_MII_MDIO_CLKEN_PIN, rmii_en);
 
+	soc_info->emac_pdata->phy_id = DA850_EVM_PHY_ID;
+
 	ret = da8xx_register_emac();
 	if (ret)
 		pr_warning("da850_evm_init: emac registration failed: %d\n",
diff --git a/arch/arm/mach-davinci/board-dm365-evm.c b/arch/arm/mach-davinci/board-dm365-evm.c
index f697914..86d9abc 100644
--- a/arch/arm/mach-davinci/board-dm365-evm.c
+++ b/arch/arm/mach-davinci/board-dm365-evm.c
@@ -54,6 +54,7 @@ static inline int have_tvp7002(void)
 	return 0;
 }
 
+#define DM365_EVM_PHY_ID		"0:01"
 /*
  * A MAX-II CPLD is used for various board control functions.
  */
@@ -527,12 +528,15 @@ fail:
 		/* externally mux MMC1/ENET/AIC33 to imager */
 		mux |= BIT(6) | BIT(5) | BIT(3);
 	} else {
+		struct davinci_soc_info *soc_info = &davinci_soc_info;
+
 		/* we can use MMC1 ... */
 		dm365evm_mmc_configure();
 		davinci_setup_mmc(1, &dm365evm_mmc_config);
 
 		/* ... and ENET ... */
 		dm365evm_emac_configure();
+		soc_info->emac_pdata->phy_id = DM365_EVM_PHY_ID;
 		resets &= ~BIT(3);
 
 		/* ... and AIC33 */
diff --git a/arch/arm/mach-davinci/board-dm644x-evm.c b/arch/arm/mach-davinci/board-dm644x-evm.c
index c86bf23..44a2f0a 100644
--- a/arch/arm/mach-davinci/board-dm644x-evm.c
+++ b/arch/arm/mach-davinci/board-dm644x-evm.c
@@ -39,6 +39,7 @@
 #include <mach/usb.h>
 #include <mach/aemif.h>
 
+#define DM644X_EVM_PHY_ID		"0:01"
 #define LXT971_PHY_ID	(0x001378e2)
 #define LXT971_PHY_MASK	(0xfffffff0)
 
@@ -669,6 +670,7 @@ static int davinci_phy_fixup(struct phy_device *phydev)
 static __init void davinci_evm_init(void)
 {
 	struct clk *aemif_clk;
+	struct davinci_soc_info *soc_info = &davinci_soc_info;
 
 	aemif_clk = clk_get(NULL, "aemif");
 	clk_enable(aemif_clk);
@@ -703,6 +705,7 @@ static __init void davinci_evm_init(void)
 	davinci_serial_init(&uart_config);
 	dm644x_init_asp(&dm644x_evm_snd_data);
 
+	soc_info->emac_pdata->phy_id = DM644X_EVM_PHY_ID;
 	/* Register the fixup for PHY on DaVinci */
 	phy_register_fixup_for_uid(LXT971_PHY_ID, LXT971_PHY_MASK,
 					davinci_phy_fixup);
diff --git a/arch/arm/mach-davinci/board-dm646x-evm.c b/arch/arm/mach-davinci/board-dm646x-evm.c
index 3f34221..67669bb 100644
--- a/arch/arm/mach-davinci/board-dm646x-evm.c
+++ b/arch/arm/mach-davinci/board-dm646x-evm.c
@@ -729,6 +729,7 @@ static struct davinci_uart_config uart_config __initdata = {
 	.enabled_uarts = (1 << 0),
 };
 
+#define DM646X_EVM_PHY_ID		"0:01"
 /*
  * The following EDMA channels/slots are not being used by drivers (for
  * example: Timer, GPIO, UART events etc) on dm646x, hence they are being
@@ -764,6 +765,8 @@ static struct edma_rsv_info dm646x_edma_rsv[] = {
 
 static __init void evm_init(void)
 {
+	struct davinci_soc_info *soc_info = &davinci_soc_info;
+
 	evm_init_i2c();
 	davinci_serial_init(&uart_config);
 	dm646x_init_mcasp0(&dm646x_evm_snd_data[0]);
@@ -778,6 +781,8 @@ static __init void evm_init(void)
 
 	if (HAS_ATA)
 		davinci_init_ide();
+
+	soc_info->emac_pdata->phy_id = DM646X_EVM_PHY_ID;
 }
 
 #define DM646X_EVM_REF_FREQ		27000000
diff --git a/arch/arm/mach-davinci/board-mityomapl138.c b/arch/arm/mach-davinci/board-mityomapl138.c
index e872fcc..6f12a18 100644
--- a/arch/arm/mach-davinci/board-mityomapl138.c
+++ b/arch/arm/mach-davinci/board-mityomapl138.c
@@ -24,6 +24,7 @@
 #include <mach/nand.h>
 #include <mach/mux.h>
 
+#define MITYOMAPL138_PHY_ID		"0:03"
 static struct davinci_i2c_platform_data mityomap_i2c_0_pdata = {
 	.bus_freq	= 100,	/* kHz */
 	.bus_delay	= 0,	/* usec */
@@ -270,6 +271,8 @@ static void __init mityomapl138_config_emac(void)
 	/* configure the CFGCHIP3 register for RMII or MII */
 	__raw_writel(val, cfg_chip3_base);
 
+	soc_info->emac_pdata->phy_id = MITYOMAPL138_PHY_ID;
+
 	ret = da8xx_register_emac();
 	if (ret)
 		pr_warning("emac registration failed: %d\n", ret);
diff --git a/arch/arm/mach-davinci/board-neuros-osd2.c b/arch/arm/mach-davinci/board-neuros-osd2.c
index 4b32f0a..04a8d16 100644
--- a/arch/arm/mach-davinci/board-neuros-osd2.c
+++ b/arch/arm/mach-davinci/board-neuros-osd2.c
@@ -39,6 +39,7 @@
 #include <mach/mmc.h>
 #include <mach/usb.h>
 
+#define NEUROS_OSD2_PHY_ID		"0:01"
 #define LXT971_PHY_ID			0x001378e2
 #define LXT971_PHY_MASK			0xfffffff0
 
@@ -215,6 +216,7 @@ static struct davinci_mmc_config davinci_ntosd2_mmc_config = {
 static __init void davinci_ntosd2_init(void)
 {
 	struct clk *aemif_clk;
+	struct davinci_soc_info *soc_info = &davinci_soc_info;
 	int	status;
 
 	aemif_clk = clk_get(NULL, "aemif");
@@ -248,6 +250,8 @@ static __init void davinci_ntosd2_init(void)
 	davinci_serial_init(&uart_config);
 	dm644x_init_asp(&dm644x_ntosd2_snd_data);
 
+	soc_info->emac_pdata->phy_id = NEUROS_OSD2_PHY_ID;
+
 	davinci_setup_usb(1000, 8);
 	/*
 	 * Mux the pins to be GPIOs, VLYNQEN is already done at startup.
diff --git a/arch/arm/mach-davinci/board-sffsdr.c b/arch/arm/mach-davinci/board-sffsdr.c
index b372d7f..ab4292d 100644
--- a/arch/arm/mach-davinci/board-sffsdr.c
+++ b/arch/arm/mach-davinci/board-sffsdr.c
@@ -42,6 +42,7 @@
 #include <mach/mux.h>
 #include <mach/usb.h>
 
+#define SFFSDR_PHY_ID		"0:01"
 static struct mtd_partition davinci_sffsdr_nandflash_partition[] = {
 	/* U-Boot Environment: Block 0
 	 * UBL:                Block 1
@@ -134,10 +135,13 @@ static void __init davinci_sffsdr_map_io(void)
 
 static __init void davinci_sffsdr_init(void)
 {
+	struct davinci_soc_info *soc_info = &davinci_soc_info;
+
 	platform_add_devices(davinci_sffsdr_devices,
 			     ARRAY_SIZE(davinci_sffsdr_devices));
 	sffsdr_init_i2c();
 	davinci_serial_init(&uart_config);
+	soc_info->emac_pdata->phy_id = SFFSDR_PHY_ID;
 	davinci_setup_usb(0, 0); /* We support only peripheral mode. */
 
 	/* mux VLYNQ pins */
-- 
1.7.0.4

