From: Christoph Egger <siccegge@cs.fau.de>
Subject: Re: [PATCH 07/11] Removing dead ARCH_PNX010X
Date: Mon, 19 Jul 2010 16:37:11 +0200
Message-ID: <20100719143711.GI12299@faui48a.informatik.uni-erlangen.de>
References: <cover.1279110894.git.siccegge@cs.fau.de> <395890e97bb1e879725ea56562f362d4af61c463.1279110895.git.siccegge@cs.fau.de> <20100714.133916.71109591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, shemminger@vyatta.com,
	dongdong.deng@windriver.com, jkosina@suse.cz,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100714.133916.71109591.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 01:39:16PM -0700, David Miller wrote:
> From: Christoph Egger <siccegge@cs.fau.de>
> Date: Wed, 14 Jul 2010 14:41:09 +0200
> 
> > ARCH_PNX010X doesn't exist in Kconfig, therefore removing all
> > references for it from the source code.
> > 
> > Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
> 
> If you are going to kill this off, kill the references in
> driver/net/Kconfig at the same time.
> 
> Please fix this up and resubmit your patch, thanks.

DOne, patch below

Thanks

    CHristoph

---
>From ed6ffbfd77e14f17fa7d75ddf70b0d3b0126848c Mon Sep 17 00:00:00 2001
From: Christoph Egger <siccegge@cs.fau.de>
Date: Wed, 14 Jul 2010 14:19:15 +0200
Subject: [PATCH] Removing dead ARCH_PNX010X

ARCH_PNX010X doesn't exist in Kconfig, therefore removing all
references for it from the source code/Kconfig.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 drivers/net/Kconfig  |    4 ++--
 drivers/net/cs89x0.c |   45 ---------------------------------------------
 2 files changed, 2 insertions(+), 47 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ce2fcdd..ba5b862 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1463,7 +1463,7 @@ config FORCEDETH
 config CS89x0
 	tristate "CS89x0 support"
 	depends on NET_ETHERNET && (ISA || EISA || MACH_IXDP2351 \
-		|| ARCH_IXDP2X01 || ARCH_PNX010X || MACH_MX31ADS)
+		|| ARCH_IXDP2X01 || MACH_MX31ADS)
 	---help---
 	  Support for CS89x0 chipset based Ethernet cards. If you have a
 	  network (Ethernet) card of this type, say Y and read the
@@ -1477,7 +1477,7 @@ config CS89x0
 config CS89x0_NONISA_IRQ
 	def_bool y
 	depends on CS89x0 != n
-	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X || MACH_MX31ADS
+	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS
 
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 2ccb9f1..7a5d787 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -180,12 +180,6 @@ static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
 #elif defined(CONFIG_ARCH_IXDP2X01)
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
-#elif defined(CONFIG_ARCH_PNX010X)
-#include <mach/gpio.h>
-#define CIRRUS_DEFAULT_BASE	IO_ADDRESS(EXT_STATIC2_s0_BASE + 0x200000)	/* = Physical address 0x48200000 */
-#define CIRRUS_DEFAULT_IRQ	VH_INTC_INT_NUM_CASCADED_INTERRUPT_1 /* Event inputs bank 1 - ID 35/bit 3 */
-static unsigned int netcard_portlist[] __used __initdata = {CIRRUS_DEFAULT_BASE, 0};
-static unsigned int cs8900_irq_map[] = {CIRRUS_DEFAULT_IRQ, 0, 0, 0};
 #elif defined(CONFIG_MACH_MX31ADS)
 #include <mach/board-mx31ads.h>
 static unsigned int netcard_portlist[] __used __initdata = {
@@ -372,18 +366,6 @@ writeword(unsigned long base_addr, int portno, u16 value)
 {
 	__raw_writel(value, base_addr + (portno << 1));
 }
-#elif defined(CONFIG_ARCH_PNX010X)
-static u16
-readword(unsigned long base_addr, int portno)
-{
-	return inw(base_addr + (portno << 1));
-}
-
-static void
-writeword(unsigned long base_addr, int portno, u16 value)
-{
-	outw(value, base_addr + (portno << 1));
-}
 #else
 static u16
 readword(unsigned long base_addr, int portno)
@@ -546,30 +528,6 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 #endif
         }
 
-#ifdef CONFIG_ARCH_PNX010X
-	initialize_ebi();
-
-	/* Map GPIO registers for the pins connected to the CS8900a. */
-	if (map_cirrus_gpio() < 0)
-		return -ENODEV;
-
-	reset_cirrus();
-
-	/* Map event-router registers. */
-	if (map_event_router() < 0)
-		return -ENODEV;
-
-	enable_cirrus_irq();
-
-	unmap_cirrus_gpio();
-	unmap_event_router();
-
-	dev->base_addr = ioaddr;
-
-	for (i = 0 ; i < 3 ; i++)
-		readreg(dev, 0);
-#endif
-
 	/* Grab the region so we can find another board if autoIRQ fails. */
 	/* WTF is going on here? */
 	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, DRV_NAME)) {
@@ -1391,9 +1349,6 @@ net_open(struct net_device *dev)
 	case A_CNF_MEDIA_10B_2: result = lp->adapter_cnf & A_CNF_10B_2; break;
         default: result = lp->adapter_cnf & (A_CNF_10B_T | A_CNF_AUI | A_CNF_10B_2);
         }
-#ifdef CONFIG_ARCH_PNX010X
-	result = A_CNF_10B_T;
-#endif
         if (!result) {
                 printk(KERN_ERR "%s: EEPROM is configured for unavailable media\n", dev->name);
 release_dma:
-- 
1.7.0.4
