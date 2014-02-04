From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH] net: irda: ep7211-sir: Remove driver
Date: Tue,  4 Feb 2014 19:43:32 +0400
Message-ID: <1391528612-16957-1-git-send-email-shc_work@mail.ru>
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Alexander Shiyan <shc_work@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback1.mail.ru ([94.100.176.18]:40912 "EHLO
	fallback1.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbaBDPoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 10:44:16 -0500
Received: from smtp49.i.mail.ru (smtp49.i.mail.ru [94.100.177.109])
	by fallback1.mail.ru (mPOP.Fallback_MX) with ESMTP id B87773387AF4
	for <netdev@vger.kernel.org>; Tue,  4 Feb 2014 19:44:14 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes old and unsupported CLPS711X IrDA driver.
Support for IrDA for CLPS711X serial port now provided by commit
4a33f1f59abd (serial: clps711x: Add support for N_IRDA line
discipline), so IrDA-mode can be turned ON with "irattach" tool
through "irtty" driver.

Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 drivers/net/irda/Kconfig      |  7 -----
 drivers/net/irda/Makefile     |  1 -
 drivers/net/irda/ep7211-sir.c | 70 -------------------------------------------
 3 files changed, 78 deletions(-)
 delete mode 100644 drivers/net/irda/ep7211-sir.c

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 2dc82f1..3da44d5 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -210,13 +210,6 @@ config KINGSUN_DONGLE
 	  To compile it as a module, choose M here: the module will be called
 	  kingsun-sir.
 
-config EP7211_DONGLE
-	tristate "Cirrus Logic clps711x I/R support"
-	depends on IRTTY_SIR && ARCH_CLPS711X && IRDA
-	help
-	  Say Y here if you want to build support for the Cirrus logic
-	  EP7211 chipset's infrared module.
-
 config KSDAZZLE_DONGLE
 	tristate "KingSun Dazzle IrDA-USB dongle"
 	depends on IRDA && USB
diff --git a/drivers/net/irda/Makefile b/drivers/net/irda/Makefile
index dfc6453..be8ab5b 100644
--- a/drivers/net/irda/Makefile
+++ b/drivers/net/irda/Makefile
@@ -35,7 +35,6 @@ obj-$(CONFIG_MCP2120_DONGLE)	+= mcp2120-sir.o
 obj-$(CONFIG_ACT200L_DONGLE)	+= act200l-sir.o
 obj-$(CONFIG_MA600_DONGLE)	+= ma600-sir.o
 obj-$(CONFIG_TOIM3232_DONGLE)	+= toim3232-sir.o
-obj-$(CONFIG_EP7211_DONGLE)	+= ep7211-sir.o
 obj-$(CONFIG_KINGSUN_DONGLE)	+= kingsun-sir.o
 obj-$(CONFIG_KSDAZZLE_DONGLE)	+= ksdazzle-sir.o
 obj-$(CONFIG_KS959_DONGLE)    	+= ks959-sir.o
diff --git a/drivers/net/irda/ep7211-sir.c b/drivers/net/irda/ep7211-sir.c
deleted file mode 100644
index 5fe1f4d..0000000
--- a/drivers/net/irda/ep7211-sir.c
+++ /dev/null
@@ -1,70 +0,0 @@
-/*
- * IR port driver for the Cirrus Logic CLPS711X processors
- *
- * Copyright 2001, Blue Mug Inc.  All rights reserved.
- * Copyright 2007, Samuel Ortiz <samuel@sortiz.org>
- */
-
-#include <linux/module.h>
-#include <linux/platform_device.h>
-
-#include <mach/hardware.h>
-
-#include "sir-dev.h"
-
-static int clps711x_dongle_open(struct sir_dev *dev)
-{
-	unsigned int syscon;
-
-	/* Turn on the SIR encoder. */
-	syscon = clps_readl(SYSCON1);
-	syscon |= SYSCON1_SIREN;
-	clps_writel(syscon, SYSCON1);
-
-	return 0;
-}
-
-static int clps711x_dongle_close(struct sir_dev *dev)
-{
-	unsigned int syscon;
-
-	/* Turn off the SIR encoder. */
-	syscon = clps_readl(SYSCON1);
-	syscon &= ~SYSCON1_SIREN;
-	clps_writel(syscon, SYSCON1);
-
-	return 0;
-}
-
-static struct dongle_driver clps711x_dongle = {
-	.owner		= THIS_MODULE,
-	.driver_name	= "EP7211 IR driver",
-	.type		= IRDA_EP7211_DONGLE,
-	.open		= clps711x_dongle_open,
-	.close		= clps711x_dongle_close,
-};
-
-static int clps711x_sir_probe(struct platform_device *pdev)
-{
-	return irda_register_dongle(&clps711x_dongle);
-}
-
-static int clps711x_sir_remove(struct platform_device *pdev)
-{
-	return irda_unregister_dongle(&clps711x_dongle);
-}
-
-static struct platform_driver clps711x_sir_driver = {
-	.driver	= {
-		.name	= "sir-clps711x",
-		.owner	= THIS_MODULE,
-	},
-	.probe	= clps711x_sir_probe,
-	.remove	= clps711x_sir_remove,
-};
-module_platform_driver(clps711x_sir_driver);
-
-MODULE_AUTHOR("Samuel Ortiz <samuel@sortiz.org>");
-MODULE_DESCRIPTION("EP7211 IR dongle driver");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("irda-dongle-13"); /* IRDA_EP7211_DONGLE */
-- 
1.8.3.2
