From: Christoph Egger <siccegge@cs.fau.de>
Subject: [PATCH 07/11] Removing dead ARCH_PNX010X
Date: Wed, 14 Jul 2010 14:41:09 +0200
Message-ID: <395890e97bb1e879725ea56562f362d4af61c463.1279110895.git.siccegge__734.182858332311$1279111370$gmane$org@cs.fau.de>
References: <cover.1279110894.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Dongdong Deng <dongdong.deng@windriver.com>,
	Jiri Kosina <jkosina@s
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:43657 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756719Ab0GNMlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:41:11 -0400
Content-Disposition: inline
In-Reply-To: <cover.1279110894.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ARCH_PNX010X doesn't exist in Kconfig, therefore removing all
references for it from the source code.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 drivers/net/cs89x0.c |   45 ---------------------------------------------
 1 files changed, 0 insertions(+), 45 deletions(-)

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

