From: Luotao Fu <l.fu@pengutronix.de>
Subject: [PATCH]  remove isa stuff from smc91x driver
Date: Wed,  3 Dec 2008 15:48:21 +0100
Message-ID: <1228315701-17240-1-git-send-email-l.fu@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, Luotao Fu <lfu@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52195 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbYLCOsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 09:48:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luotao Fu <lfu@pengutronix.de>

ISA support in smc91x is incomplete. I doubt there're any smc91x isa card.
This driver is greatly used on arm pxa platforms. Hence we remove the
isa stuff from smc91x driver.

Signed-off-by: Luotao Fu <lfu@pengutronix.de>
---
 drivers/net/smc91x.c |   36 ------------------------------------
 drivers/net/smc91x.h |   13 -------------
 2 files changed, 0 insertions(+), 49 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 35c56ab..7827683 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -90,33 +90,6 @@ static const char version[] =
 
 #include "smc91x.h"
 
-#ifdef CONFIG_ISA
-/*
- * the LAN91C111 can be at any of the following port addresses.  To change,
- * for a slightly different card, you can add it to the array.  Keep in
- * mind that the array must end in zero.
- */
-static unsigned int smc_portlist[] __initdata = {
-	0x200, 0x220, 0x240, 0x260, 0x280, 0x2A0, 0x2C0, 0x2E0,
-	0x300, 0x320, 0x340, 0x360, 0x380, 0x3A0, 0x3C0, 0x3E0, 0
-};
-
-#ifndef SMC_IOADDR
-# define SMC_IOADDR		-1
-#endif
-static unsigned long io = SMC_IOADDR;
-module_param(io, ulong, 0400);
-MODULE_PARM_DESC(io, "I/O base address");
-
-#ifndef SMC_IRQ
-# define SMC_IRQ		-1
-#endif
-static int irq = SMC_IRQ;
-module_param(irq, int, 0400);
-MODULE_PARM_DESC(irq, "IRQ number");
-
-#endif  /* CONFIG_ISA */
-
 #ifndef SMC_NOWAIT
 # define SMC_NOWAIT		0
 #endif
@@ -2316,15 +2289,6 @@ static struct platform_driver smc_driver = {
 
 static int __init smc_init(void)
 {
-#ifdef MODULE
-#ifdef CONFIG_ISA
-	if (io == -1)
-		printk(KERN_WARNING
-			"%s: You shouldn't use auto-probing with insmod!\n",
-			CARDNAME);
-#endif
-#endif
-
 	return platform_driver_register(&smc_driver);
 }
 
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index a07cc93..066bab5 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -286,19 +286,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 
 #define SMC_IRQ_FLAGS		(0)
 
-#elif	defined(CONFIG_ISA)
-
-#define SMC_CAN_USE_8BIT	1
-#define SMC_CAN_USE_16BIT	1
-#define SMC_CAN_USE_32BIT	0
-
-#define SMC_inb(a, r)		inb((a) + (r))
-#define SMC_inw(a, r)		inw((a) + (r))
-#define SMC_outb(v, a, r)	outb(v, (a) + (r))
-#define SMC_outw(v, a, r)	outw(v, (a) + (r))
-#define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)
-
 #elif   defined(CONFIG_M32R)
 
 #define SMC_CAN_USE_8BIT	0
-- 
1.5.6.5

