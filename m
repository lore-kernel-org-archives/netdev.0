From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 7/8] pxa: make zylonite to use the smc91x platform data
Date: Thu, 19 Jun 2008 19:09:54 +0800
Message-ID: <485A3E82.7070407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>
To: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:2067 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756709AbYFSLKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:10:04 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5102367rvb.1
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 04:10:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 arch/arm/mach-pxa/zylonite.c |    8 ++++++++
 drivers/net/smc91x.h         |   16 ----------------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/arch/arm/mach-pxa/zylonite.c b/arch/arm/mach-pxa/zylonite.c
index 4a4711d..f381ac9 100644
--- a/arch/arm/mach-pxa/zylonite.c
+++ b/arch/arm/mach-pxa/zylonite.c
@@ -19,6 +19,7 @@
 #include <linux/init.h>
 #include <linux/platform_device.h>
 #include <linux/pwm_backlight.h>
+#include <linux/smc91x.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -59,11 +60,18 @@ static struct resource smc91x_resources[] = {
 	}
 };
 
+static struct smc91x_platdata zylonite_smc91x_info = {
+	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_NOWAIT,
+};
+
 static struct platform_device smc91x_device = {
 	.name		= "smc91x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(smc91x_resources),
 	.resource	= smc91x_resources,
+	.dev		= {
+		.platform_data = &zylonite_smc91x_info,
+	},
 };
 
 #if defined(CONFIG_LEDS_GPIO) || defined(CONFIG_LEDS_GPIO_MODULE)
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 1d9b57f..80b04d3 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -212,22 +212,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 	}
 }
 
-#elif defined(CONFIG_MACH_ZYLONITE)
-
-#define SMC_CAN_USE_8BIT        1
-#define SMC_CAN_USE_16BIT       1
-#define SMC_CAN_USE_32BIT       0
-#define SMC_IO_SHIFT            0
-#define SMC_NOWAIT              1
-#define SMC_USE_PXA_DMA		1
-#define SMC_inb(a, r)           readb((a) + (r))
-#define SMC_inw(a, r)           readw((a) + (r))
-#define SMC_insw(a, r, p, l)    insw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)   outsw((a) + (r), p, l)
-#define SMC_outb(v, a, r)       writeb(v, (a) + (r))
-#define SMC_outw(v, a, r)       writew(v, (a) + (r))
-#define SMC_IRQ_FLAGS		(-1)	/* from resource */
-
 #elif	defined(CONFIG_ARCH_OMAP)
 
 /* We can only do 16-bit reads and writes in the static memory space. */
-- 
1.5.4.3

