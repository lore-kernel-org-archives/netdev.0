From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] ARM: at91: remove AT91_PROGRAMMABLE_CLOCKS configuration option
Date: Thu, 12 Dec 2013 17:00:45 +0100
Message-ID: <1386864045-25198-1-git-send-email-nicolas.ferre@atmel.com>
References: <52A9C81B.7050007@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boris BREZILLON <b.brezillon@overkiz.com>,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Olof Johansson <olof@lixom.net>, <khilman@linaro.org>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52A9C81B.7050007@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This AT91 specific Kconfig option removed the code that dealt with
programmable clocks. Each AT91 SoC embeds programmable clocks and
there is little gain to remove this code in case that such a clock
is not used.
If this option is not selected, it causes certain drivers to fail
to build. We simply remove this option instead of adding code just
to build a workaround.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Olof, Kevin,

This patch goes on top of the AT91 "cleanup" branch.

Bye,


 arch/arm/configs/at91_dt_defconfig          | 1 -
 arch/arm/configs/at91rm9200_defconfig       | 1 -
 arch/arm/configs/at91sam9260_9g20_defconfig | 1 -
 arch/arm/configs/at91sam9261_9g10_defconfig | 1 -
 arch/arm/configs/at91sam9g45_defconfig      | 1 -
 arch/arm/configs/at91sam9rl_defconfig       | 1 -
 arch/arm/configs/sama5_defconfig            | 1 -
 arch/arm/mach-at91/Kconfig                  | 6 ------
 arch/arm/mach-at91/clock.c                  | 6 ------
 arch/arm/mach-at91/pm.c                     | 3 ---
 drivers/clk/at91/Makefile                   | 3 +--
 drivers/clk/at91/pmc.c                      | 2 --
 drivers/clk/at91/pmc.h                      | 2 --
 sound/soc/atmel/Kconfig                     | 2 +-
 14 files changed, 2 insertions(+), 29 deletions(-)

diff --git a/arch/arm/configs/at91_dt_defconfig b/arch/arm/configs/at91_dt_defconfig
index 690e89273230..0b4e9b5210d8 100644
--- a/arch/arm/configs/at91_dt_defconfig
+++ b/arch/arm/configs/at91_dt_defconfig
@@ -22,7 +22,6 @@ CONFIG_SOC_AT91SAM9X5=y
 CONFIG_SOC_AT91SAM9N12=y
 CONFIG_MACH_AT91RM9200_DT=y
 CONFIG_MACH_AT91SAM9_DT=y
-CONFIG_AT91_PROGRAMMABLE_CLOCKS=y
 CONFIG_AT91_TIMER_HZ=128
 CONFIG_AEABI=y
 # CONFIG_OABI_COMPAT is not set
diff --git a/arch/arm/configs/at91rm9200_defconfig b/arch/arm/configs/at91rm9200_defconfig
index 75502c4d222c..bf057719dab0 100644
--- a/arch/arm/configs/at91rm9200_defconfig
+++ b/arch/arm/configs/at91rm9200_defconfig
@@ -31,7 +31,6 @@ CONFIG_MACH_YL9200=y
 CONFIG_MACH_CPUAT91=y
 CONFIG_MACH_ECO920=y
 CONFIG_MTD_AT91_DATAFLASH_CARD=y
-CONFIG_AT91_PROGRAMMABLE_CLOCKS=y
 CONFIG_AT91_TIMER_HZ=100
 # CONFIG_ARM_THUMB is not set
 CONFIG_PCCARD=y
diff --git a/arch/arm/configs/at91sam9260_9g20_defconfig b/arch/arm/configs/at91sam9260_9g20_defconfig
index 69b6928d3d9d..955dc480f3ee 100644
--- a/arch/arm/configs/at91sam9260_9g20_defconfig
+++ b/arch/arm/configs/at91sam9260_9g20_defconfig
@@ -28,7 +28,6 @@ CONFIG_MACH_PCONTROL_G20=y
 CONFIG_MACH_GSIA18S=y
 CONFIG_MACH_SNAPPER_9260=y
 CONFIG_MACH_AT91SAM9_DT=y
-CONFIG_AT91_PROGRAMMABLE_CLOCKS=y
 CONFIG_AT91_SLOW_CLOCK=y
 # CONFIG_ARM_THUMB is not set
 CONFIG_AEABI=y
diff --git a/arch/arm/configs/at91sam9261_9g10_defconfig b/arch/arm/configs/at91sam9261_9g10_defconfig
index 9d35cd81c611..f80e993b04ce 100644
--- a/arch/arm/configs/at91sam9261_9g10_defconfig
+++ b/arch/arm/configs/at91sam9261_9g10_defconfig
@@ -18,7 +18,6 @@ CONFIG_ARCH_AT91=y
 CONFIG_ARCH_AT91SAM9261=y
 CONFIG_MACH_AT91SAM9261EK=y
 CONFIG_MACH_AT91SAM9G10EK=y
-CONFIG_AT91_PROGRAMMABLE_CLOCKS=y
 # CONFIG_ARM_THUMB is not set
 CONFIG_AEABI=y
 # CONFIG_OABI_COMPAT is not set
diff --git a/arch/arm/configs/at91sam9g45_defconfig b/arch/arm/configs/at91sam9g45_defconfig
index 08166cd4e7d6..e181a50fd65a 100644
--- a/arch/arm/configs/at91sam9g45_defconfig
+++ b/arch/arm/configs/at91sam9g45_defconfig
@@ -18,7 +18,6 @@ CONFIG_ARCH_AT91=y
 CONFIG_ARCH_AT91SAM9G45=y
 CONFIG_MACH_AT91SAM9M10G45EK=y
 CONFIG_MACH_AT91SAM9_DT=y
-CONFIG_AT91_PROGRAMMABLE_CLOCKS=y
 CONFIG_AT91_SLOW_CLOCK=y
 CONFIG_AEABI=y
 # CONFIG_OABI_COMPAT is not set
diff --git a/arch/arm/configs/at91sam9rl_defconfig b/arch/arm/configs/at91sam9rl_defconfig
index 7cf87856d63c..7b6f131cecd6 100644
--- a/arch/arm/configs/at91sam9rl_defconfig
+++ b/arch/arm/configs/at91sam9rl_defconfig
@@ -13,7 +13,6 @@ CONFIG_MODULE_UNLOAD=y
 CONFIG_ARCH_AT91=y
 CONFIG_ARCH_AT91SAM9RL=y
 CONFIG_MACH_AT91SAM9RLEK=y
-CONFIG_AT91_PROGRAMMABLE_CLOCKS=y
 # CONFIG_ARM_THUMB is not set
 CONFIG_ZBOOT_ROM_TEXT=0x0
 CONFIG_ZBOOT_ROM_BSS=0x0
diff --git a/arch/arm/configs/sama5_defconfig b/arch/arm/configs/sama5_defconfig
index f6e78f83c3c3..dc3881e07630 100644
--- a/arch/arm/configs/sama5_defconfig
+++ b/arch/arm/configs/sama5_defconfig
@@ -20,7 +20,6 @@ CONFIG_ARCH_AT91=y
 CONFIG_SOC_SAM_V7=y
 CONFIG_SOC_SAMA5D3=y
 CONFIG_MACH_SAMA5_DT=y
-CONFIG_AT91_PROGRAMMABLE_CLOCKS=y
 CONFIG_AEABI=y
 # CONFIG_OABI_COMPAT is not set
 CONFIG_UACCESS_WITH_MEMCPY=y
diff --git a/arch/arm/mach-at91/Kconfig b/arch/arm/mach-at91/Kconfig
index aac7814db4f9..f1bf952da747 100644
--- a/arch/arm/mach-at91/Kconfig
+++ b/arch/arm/mach-at91/Kconfig
@@ -214,12 +214,6 @@ config MACH_SAMA5_DT
 
 comment "AT91 Feature Selections"
 
-config AT91_PROGRAMMABLE_CLOCKS
-	bool "Programmable Clocks"
-	help
-	  Select this if you need to program one or more of the PCK0..PCK3
-	  programmable clock outputs.
-
 config AT91_SLOW_CLOCK
 	bool "Suspend-to-RAM disables main oscillator"
 	depends on SUSPEND
diff --git a/arch/arm/mach-at91/clock.c b/arch/arm/mach-at91/clock.c
index 72b257944733..034529d801b2 100644
--- a/arch/arm/mach-at91/clock.c
+++ b/arch/arm/mach-at91/clock.c
@@ -330,8 +330,6 @@ EXPORT_SYMBOL(clk_get_rate);
 
 /*------------------------------------------------------------------------*/
 
-#ifdef CONFIG_AT91_PROGRAMMABLE_CLOCKS
-
 /*
  * For now, only the programmable clocks support reparenting (MCK could
  * do this too, with care) or rate changing (the PLLs could do this too,
@@ -459,8 +457,6 @@ static void __init init_programmable_clock(struct clk *clk)
 	clk->rate_hz = parent->rate_hz / pmc_prescaler_divider(pckr);
 }
 
-#endif	/* CONFIG_AT91_PROGRAMMABLE_CLOCKS */
-
 /*------------------------------------------------------------------------*/
 
 #ifdef CONFIG_DEBUG_FS
@@ -577,12 +573,10 @@ int __init clk_register(struct clk *clk)
 		clk->parent = &mck;
 		clk->mode = pmc_sys_mode;
 	}
-#ifdef CONFIG_AT91_PROGRAMMABLE_CLOCKS
 	else if (clk_is_programmable(clk)) {
 		clk->mode = pmc_sys_mode;
 		init_programmable_clock(clk);
 	}
-#endif
 
 	at91_clk_add(clk);
 
diff --git a/arch/arm/mach-at91/pm.c b/arch/arm/mach-at91/pm.c
index d43b79f56e94..590b52dea9f7 100644
--- a/arch/arm/mach-at91/pm.c
+++ b/arch/arm/mach-at91/pm.c
@@ -155,9 +155,6 @@ static int at91_pm_verify_clocks(void)
 		}
 	}
 
-	if (!IS_ENABLED(CONFIG_AT91_PROGRAMMABLE_CLOCKS))
-		return 1;
-
 	/* PCK0..PCK3 must be disabled, or configured to use clk32k */
 	for (i = 0; i < 4; i++) {
 		u32 css;
diff --git a/drivers/clk/at91/Makefile b/drivers/clk/at91/Makefile
index 0e92b716f934..46c1d3d0d66b 100644
--- a/drivers/clk/at91/Makefile
+++ b/drivers/clk/at91/Makefile
@@ -4,9 +4,8 @@
 
 obj-y += pmc.o
 obj-y += clk-main.o clk-pll.o clk-plldiv.o clk-master.o
-obj-y += clk-system.o clk-peripheral.o
+obj-y += clk-system.o clk-peripheral.o clk-programmable.o
 
-obj-$(CONFIG_AT91_PROGRAMMABLE_CLOCKS)	+= clk-programmable.o
 obj-$(CONFIG_HAVE_AT91_UTMI)		+= clk-utmi.o
 obj-$(CONFIG_HAVE_AT91_USB_CLK)		+= clk-usb.o
 obj-$(CONFIG_HAVE_AT91_SMD)		+= clk-smd.o
diff --git a/drivers/clk/at91/pmc.c b/drivers/clk/at91/pmc.c
index 7b9db603b936..11fceff8d9f1 100644
--- a/drivers/clk/at91/pmc.c
+++ b/drivers/clk/at91/pmc.c
@@ -279,7 +279,6 @@ static const struct of_device_id pmc_clk_ids[] __initdata = {
 		.data = of_at91sam9x5_clk_periph_setup,
 	},
 	/* Programmable clocks */
-#if defined(CONFIG_AT91_PROGRAMMABLE_CLOCKS)
 	{
 		.compatible = "atmel,at91rm9200-clk-programmable",
 		.data = of_at91rm9200_clk_prog_setup,
@@ -292,7 +291,6 @@ static const struct of_device_id pmc_clk_ids[] __initdata = {
 		.compatible = "atmel,at91sam9x5-clk-programmable",
 		.data = of_at91sam9x5_clk_prog_setup,
 	},
-#endif
 	/* UTMI clock */
 #if defined(CONFIG_HAVE_AT91_UTMI)
 	{
diff --git a/drivers/clk/at91/pmc.h b/drivers/clk/at91/pmc.h
index ba8d14233f80..441350983ccb 100644
--- a/drivers/clk/at91/pmc.h
+++ b/drivers/clk/at91/pmc.h
@@ -85,14 +85,12 @@ extern void __init of_at91rm9200_clk_periph_setup(struct device_node *np,
 extern void __init of_at91sam9x5_clk_periph_setup(struct device_node *np,
 						  struct at91_pmc *pmc);
 
-#if defined(CONFIG_AT91_PROGRAMMABLE_CLOCKS)
 extern void __init of_at91rm9200_clk_prog_setup(struct device_node *np,
 						struct at91_pmc *pmc);
 extern void __init of_at91sam9g45_clk_prog_setup(struct device_node *np,
 						 struct at91_pmc *pmc);
 extern void __init of_at91sam9x5_clk_prog_setup(struct device_node *np,
 						struct at91_pmc *pmc);
-#endif
 
 #if defined(CONFIG_HAVE_AT91_UTMI)
 extern void __init of_at91sam9x5_clk_utmi_setup(struct device_node *np,
diff --git a/sound/soc/atmel/Kconfig b/sound/soc/atmel/Kconfig
index e48d38a1b95c..e634eb78ed03 100644
--- a/sound/soc/atmel/Kconfig
+++ b/sound/soc/atmel/Kconfig
@@ -25,7 +25,7 @@ config SND_ATMEL_SOC_SSC
 
 config SND_AT91_SOC_SAM9G20_WM8731
 	tristate "SoC Audio support for WM8731-based At91sam9g20 evaluation board"
-	depends on ARCH_AT91 && ATMEL_SSC && SND_ATMEL_SOC && AT91_PROGRAMMABLE_CLOCKS
+	depends on ARCH_AT91 && ATMEL_SSC && SND_ATMEL_SOC
 	select SND_ATMEL_SOC_PDC
 	select SND_ATMEL_SOC_SSC
 	select SND_SOC_WM8731
-- 
1.8.2.2
