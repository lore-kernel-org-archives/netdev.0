From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 8/8] net: irda/sa1100_ir: remove sa11x0 irda platform data
Date: Mon, 29 Aug 2016 12:26:41 +0100
Message-ID: <E1beKi9-0001HU-SU@rmk-PC.armlinux.org.uk>
References: <20160829112540.GF1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vinod Koul <vinod.koul@intel.com>
To: dmaengine@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:56874 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757234AbcH2L1C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:27:02 -0400
In-Reply-To: <20160829112540.GF1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is now no need for the sa11x0 IrDA platform data, so remove
the header file and all locations that include it.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 arch/arm/mach-sa1100/assabet.c            |  6 +-----
 arch/arm/mach-sa1100/collie.c             |  6 +-----
 arch/arm/mach-sa1100/generic.c            |  4 ++--
 arch/arm/mach-sa1100/generic.h            |  3 +--
 arch/arm/mach-sa1100/h3100.c              |  6 +-----
 arch/arm/mach-sa1100/h3600.c              |  6 +-----
 drivers/net/irda/sa1100_ir.c              | 30 +-----------------------------
 include/linux/platform_data/irda-sa11x0.h | 20 --------------------
 8 files changed, 8 insertions(+), 73 deletions(-)
 delete mode 100644 include/linux/platform_data/irda-sa11x0.h

diff --git a/arch/arm/mach-sa1100/assabet.c b/arch/arm/mach-sa1100/assabet.c
index ba180eebd6ab..14a75735e9d0 100644
--- a/arch/arm/mach-sa1100/assabet.c
+++ b/arch/arm/mach-sa1100/assabet.c
@@ -42,7 +42,6 @@
 
 #include <asm/mach/arch.h>
 #include <asm/mach/flash.h>
-#include <linux/platform_data/irda-sa11x0.h>
 #include <asm/mach/map.h>
 #include <mach/assabet.h>
 #include <linux/platform_data/mfd-mcp-sa11x0.h>
@@ -303,9 +302,6 @@ static struct resource assabet_flash_resources[] = {
 };
 
 
-static struct irda_platform_data assabet_irda_data = {
-};
-
 /* IrDA GPIO mappings */
 static struct gpiod_lookup_table assabet_irda_gpio_table = {
 	.dev_id = "sa11x0-ir",
@@ -586,7 +582,7 @@ static void __init assabet_init(void)
 #endif
 	sa11x0_register_mtd(&assabet_flash_data, assabet_flash_resources,
 			    ARRAY_SIZE(assabet_flash_resources));
-	sa11x0_register_irda(&assabet_irda_data);
+	sa11x0_register_irda();
 	sa11x0_register_mcp(&assabet_mcp_data);
 
 	if (!machine_has_neponset())
diff --git a/arch/arm/mach-sa1100/collie.c b/arch/arm/mach-sa1100/collie.c
index 8ed0cbfaa0f4..5f1549ed19d2 100644
--- a/arch/arm/mach-sa1100/collie.c
+++ b/arch/arm/mach-sa1100/collie.c
@@ -44,7 +44,6 @@
 #include <asm/mach/arch.h>
 #include <asm/mach/flash.h>
 #include <asm/mach/map.h>
-#include <linux/platform_data/irda-sa11x0.h>
 
 #include <asm/hardware/scoop.h>
 #include <asm/mach/sharpsl_param.h>
@@ -98,9 +97,6 @@ static struct mcp_plat_data collie_mcp_data = {
 	.codec_pdata	= &collie_ucb1x00_data,
 };
 
-static struct irda_platform_data collie_ir_data = {
-};
-
 /* IrDA GPIO mappings */
 static struct gpiod_lookup_table collie_irda_gpio_table = {
 	.dev_id = "sa11x0-ir",
@@ -379,7 +375,7 @@ static void __init collie_init(void)
 	sa11x0_register_mtd(&collie_flash_data, collie_flash_resources,
 			    ARRAY_SIZE(collie_flash_resources));
 	sa11x0_register_mcp(&collie_mcp_data);
-	sa11x0_register_irda(&collie_ir_data);
+	sa11x0_register_irda();
 
 	sharpsl_save_param();
 }
diff --git a/arch/arm/mach-sa1100/generic.c b/arch/arm/mach-sa1100/generic.c
index a005eef1a24e..5d2e68984303 100644
--- a/arch/arm/mach-sa1100/generic.c
+++ b/arch/arm/mach-sa1100/generic.c
@@ -274,9 +274,9 @@ static struct platform_device sa11x0ir_device = {
 	.resource	= sa11x0ir_resources,
 };
 
-void sa11x0_register_irda(struct irda_platform_data *irda)
+void sa11x0_register_irda(void)
 {
-	sa11x0_register_device(&sa11x0ir_device, irda);
+	sa11x0_register_device(&sa11x0ir_device, NULL);
 }
 
 static struct resource sa1100_rtc_resources[] = {
diff --git a/arch/arm/mach-sa1100/generic.h b/arch/arm/mach-sa1100/generic.h
index 22c432979150..b733c98214bd 100644
--- a/arch/arm/mach-sa1100/generic.h
+++ b/arch/arm/mach-sa1100/generic.h
@@ -29,8 +29,7 @@ struct resource;
 void sa11x0_register_mtd(struct flash_platform_data *flash,
 			 struct resource *res, int nr);
 
-struct irda_platform_data;
-void sa11x0_register_irda(struct irda_platform_data *irda);
+void sa11x0_register_irda(void);
 
 struct mcp_plat_data;
 void sa11x0_ppc_configure_mcp(void);
diff --git a/arch/arm/mach-sa1100/h3100.c b/arch/arm/mach-sa1100/h3100.c
index 9930e8a6cd43..8c1a105ba2d1 100644
--- a/arch/arm/mach-sa1100/h3100.c
+++ b/arch/arm/mach-sa1100/h3100.c
@@ -19,7 +19,6 @@
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
-#include <linux/platform_data/irda-sa11x0.h>
 
 #include <mach/h3xxx.h>
 #include <mach/irqs.h>
@@ -87,9 +86,6 @@ static void __init h3100_map_io(void)
 	GAFR &= ~0x000001fb;
 }
 
-static struct irda_platform_data h3100_irda_data = {
-};
-
 /* IrDA GPIO mappings */
 static struct gpiod_lookup_table h3100_irda_gpio_table = {
 	.dev_id = "sa11x0-ir",
@@ -107,7 +103,7 @@ static void __init h3100_mach_init(void)
 	h3xxx_mach_init();
 
 	sa11x0_register_lcd(&h3100_lcd_info);
-	sa11x0_register_irda(&h3100_irda_data);
+	sa11x0_register_irda();
 }
 
 MACHINE_START(H3100, "Compaq iPAQ H3100")
diff --git a/arch/arm/mach-sa1100/h3600.c b/arch/arm/mach-sa1100/h3600.c
index 1a925ab9aa51..14a7ad77b076 100644
--- a/arch/arm/mach-sa1100/h3600.c
+++ b/arch/arm/mach-sa1100/h3600.c
@@ -19,7 +19,6 @@
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
-#include <linux/platform_data/irda-sa11x0.h>
 
 #include <mach/h3xxx.h>
 #include <mach/irqs.h>
@@ -95,9 +94,6 @@ static void __init h3600_map_io(void)
 	h3xxx_map_io();
 }
 
-static struct irda_platform_data h3600_irda_data = {
-};
-
 /* IrDA GPIO mappings */
 static struct gpiod_lookup_table h3600_irda_gpio_table = {
 	.dev_id = "sa11x0-ir",
@@ -115,7 +111,7 @@ static void __init h3600_mach_init(void)
 	h3xxx_mach_init();
 
 	sa11x0_register_lcd(&h3600_lcd_info);
-	sa11x0_register_irda(&h3600_irda_data);
+	sa11x0_register_irda();
 }
 
 MACHINE_START(H3600, "Compaq iPAQ H3600")
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 25c63c9ff33c..3a8b9d5d61d1 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -38,7 +38,6 @@
 #include <net/irda/irda_device.h>
 
 #include <mach/hardware.h>
-#include <linux/platform_data/irda-sa11x0.h>
 
 static int power_level = 3;
 static int tx_lpm;
@@ -64,7 +63,6 @@ struct sa1100_irda {
 	struct sa1100_buf	dma_tx;
 
 	struct device		*dev;
-	struct irda_platform_data *pdata;
 	struct irlap_cb		*irlap;
 	struct qos_info		qos;
 
@@ -577,8 +575,6 @@ static int sa1100_irda_set_speed(struct sa1100_irda *si, int speed)
 		Ser2UTSR0 = UTSR0_REB | UTSR0_RBB | UTSR0_RID;
 		Ser2UTCR3 = UTCR3_RIE | UTCR3_RXE | UTCR3_TXE;
 
-		if (si->pdata->set_speed)
-			si->pdata->set_speed(si->dev, speed);
 		if (si->fsel_gpio)
 			gpiod_set_value(si->fsel_gpio, 0);
 
@@ -605,8 +601,6 @@ static int sa1100_irda_set_speed(struct sa1100_irda *si, int speed)
 		si->tx_start = sa1100_irda_fir_tx_start;
 		si->irq = sa1100_irda_fir_irq;
 
-		if (si->pdata->set_speed)
-			si->pdata->set_speed(si->dev, speed);
 		if (si->fsel_gpio)
 			gpiod_set_value(si->fsel_gpio, 1);
 
@@ -637,10 +631,7 @@ static int sa1100_irda_set_speed(struct sa1100_irda *si, int speed)
 static int
 __sa1100_irda_set_power(struct sa1100_irda *si, unsigned int state)
 {
-	int ret = 0;
-	if (si->pdata->set_power) {
-		ret = si->pdata->set_power(si->dev, state);
-	} else if (si->pwr_gpio) {
+	if (si->pwr_gpio) {
 		gpiod_set_value_cansleep(si->pwr_gpio, state);
 	} else if (si->md_gpio[0] && si->md_gpio[1]) {
 		int vals[2];
@@ -750,15 +741,6 @@ static int sa1100_irda_startup(struct sa1100_irda *si)
 	int ret;
 
 	/*
-	 * Ensure that the ports for this device are setup correctly.
-	 */
-	if (si->pdata->startup)	{
-		ret = si->pdata->startup(si->dev);
-		if (ret)
-			return ret;
-	}
-
-	/*
 	 * Configure PPC for IRDA - we want to drive TXD2 low.
 	 * We also want to drive this pin low during sleep.
 	 */
@@ -784,9 +766,6 @@ static int sa1100_irda_startup(struct sa1100_irda *si)
 	if (ret) {
 		Ser2UTCR3 = 0;
 		Ser2HSCR0 = 0;
-
-		if (si->pdata->shutdown)
-			si->pdata->shutdown(si->dev);
 	}
 
 	return ret;
@@ -803,9 +782,6 @@ static void sa1100_irda_shutdown(struct sa1100_irda *si)
 	/* Disable the port. */
 	Ser2UTCR3 = 0;
 	Ser2HSCR0 = 0;
-
-	if (si->pdata->shutdown)
-		si->pdata->shutdown(si->dev);
 }
 
 static int sa1100_irda_start(struct net_device *dev)
@@ -955,9 +931,6 @@ static int sa1100_irda_probe(struct platform_device *pdev)
 	unsigned int baudrate_mask;
 	int err, irq;
 
-	if (!pdev->dev.platform_data)
-		return -EINVAL;
-
 	irq = platform_get_irq(pdev, 0);
 	if (irq <= 0)
 		return irq < 0 ? irq : -ENXIO;
@@ -982,7 +955,6 @@ static int sa1100_irda_probe(struct platform_device *pdev)
 
 	si = netdev_priv(dev);
 	si->dev = &pdev->dev;
-	si->pdata = pdev->dev.platform_data;
 
 	err = sa1100_irda_get_gpio(&pdev->dev, &si->fsel_gpio, "ir-fsel",
 				   GPIOD_OUT_LOW);
diff --git a/include/linux/platform_data/irda-sa11x0.h b/include/linux/platform_data/irda-sa11x0.h
deleted file mode 100644
index 38f77b5e56cf..000000000000
--- a/include/linux/platform_data/irda-sa11x0.h
+++ /dev/null
@@ -1,20 +0,0 @@
-/*
- *  arch/arm/include/asm/mach/irda.h
- *
- *  Copyright (C) 2004 Russell King.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#ifndef __ASM_ARM_MACH_IRDA_H
-#define __ASM_ARM_MACH_IRDA_H
-
-struct irda_platform_data {
-	int (*startup)(struct device *);
-	void (*shutdown)(struct device *);
-	int (*set_power)(struct device *, unsigned int state);
-	void (*set_speed)(struct device *, unsigned int speed);
-};
-
-#endif
-- 
2.1.0
