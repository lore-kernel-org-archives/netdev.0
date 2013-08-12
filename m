From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] SolutionEngine SH771x: remove Ether support
Date: Tue, 13 Aug 2013 02:17:02 +0400
Message-ID: <201308130217.03133.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: linux-sh@vger.kernel.org, lethal@linux-sh.org,
	netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 'sh_eth' driver's probe will crash as the platform code is hopelessly behind
the platform data -- it passes PHY ID instead of 'struct sh_eth_plat_data *'.
Even if it's fixed, the driver probe will fail as the 'struct sh_eth_cpu_data'
indicates presence of TSU but the platform device resource  for it is absent.
Since I have no data to fix it, I think it's best to remove the erratic code.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Paul Mundt's 'linux-sh.git' repo, 'sh-latest' branch.
Paul, could you update your tree, it's still at 3.9-rc1? The code being removed
has changed upstream...

 arch/sh/boards/mach-se/770x/setup.c |   55 ------------------------------------
 arch/sh/include/mach-se/mach/se.h   |   15 ---------
 2 files changed, 70 deletions(-)

Index: linux-sh/arch/sh/boards/mach-se/770x/setup.c
===================================================================
--- linux-sh.orig/arch/sh/boards/mach-se/770x/setup.c
+++ linux-sh/arch/sh/boards/mach-se/770x/setup.c
@@ -111,64 +111,9 @@ static struct platform_device heartbeat_
 	.resource	= &heartbeat_resource,
 };
 
-#if defined(CONFIG_CPU_SUBTYPE_SH7710) ||\
-	defined(CONFIG_CPU_SUBTYPE_SH7712)
-/* SH771X Ethernet driver */
-static struct resource sh_eth0_resources[] = {
-	[0] = {
-		.start = SH_ETH0_BASE,
-		.end = SH_ETH0_BASE + 0x1B8,
-		.flags = IORESOURCE_MEM,
-	},
-	[1] = {
-		.start = SH_ETH0_IRQ,
-		.end = SH_ETH0_IRQ,
-		.flags = IORESOURCE_IRQ,
-	},
-};
-
-static struct platform_device sh_eth0_device = {
-	.name = "sh-eth",
-	.id	= 0,
-	.dev = {
-		.platform_data = PHY_ID,
-	},
-	.num_resources = ARRAY_SIZE(sh_eth0_resources),
-	.resource = sh_eth0_resources,
-};
-
-static struct resource sh_eth1_resources[] = {
-	[0] = {
-		.start = SH_ETH1_BASE,
-		.end = SH_ETH1_BASE + 0x1B8,
-		.flags = IORESOURCE_MEM,
-	},
-	[1] = {
-		.start = SH_ETH1_IRQ,
-		.end = SH_ETH1_IRQ,
-		.flags = IORESOURCE_IRQ,
-	},
-};
-
-static struct platform_device sh_eth1_device = {
-	.name = "sh-eth",
-	.id	= 1,
-	.dev = {
-		.platform_data = PHY_ID,
-	},
-	.num_resources = ARRAY_SIZE(sh_eth1_resources),
-	.resource = sh_eth1_resources,
-};
-#endif
-
 static struct platform_device *se_devices[] __initdata = {
 	&heartbeat_device,
 	&cf_ide_device,
-#if defined(CONFIG_CPU_SUBTYPE_SH7710) ||\
-	defined(CONFIG_CPU_SUBTYPE_SH7712)
-	&sh_eth0_device,
-	&sh_eth1_device,
-#endif
 };
 
 static int __init se_devices_setup(void)
Index: linux-sh/arch/sh/include/mach-se/mach/se.h
===================================================================
--- linux-sh.orig/arch/sh/include/mach-se/mach/se.h
+++ linux-sh/arch/sh/include/mach-se/mach/se.h
@@ -95,21 +95,6 @@
 #define IRQ_CFCARD	evt2irq(0x2e0)
 #endif
 
-/* SH Ether support (SH7710/SH7712) */
-/* Base address */
-#define SH_ETH0_BASE 0xA7000000
-#define SH_ETH1_BASE 0xA7000400
-/* PHY ID */
-#if defined(CONFIG_CPU_SUBTYPE_SH7710)
-# define PHY_ID 0x00
-#elif defined(CONFIG_CPU_SUBTYPE_SH7712)
-# define PHY_ID 0x01
-#endif
-/* Ether IRQ */
-#define SH_ETH0_IRQ	evt2irq(0xc00)
-#define SH_ETH1_IRQ	evt2irq(0xc20)
-#define SH_TSU_IRQ	evt2irq(0xc40)
-
 void init_se_IRQ(void);
 
 #define __IO_PREFIX	se
