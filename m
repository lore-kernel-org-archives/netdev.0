From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH V2 4/4] CS89x0 : remove QQ2440 board support from the CS89x0
 driver
Date: Wed, 11 Jan 2012 00:14:54 +0100
Message-ID: <1326237294-23698-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: jaccon.bastiaansen@gmail.com, s.hauer@pengutronix.de,
 kernel@pengutronix.de, u.kleine-koenig@pengutronix.de, davem@davemloft.net,
 cavokz@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The QQ2440 board isn't supported anymore in the kernel, so support
for this board can be removed from the CS89x0 driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 drivers/net/Space.c                  |    2 +-
 drivers/net/ethernet/cirrus/cs89x0.c |   11 ++---------
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 04c4561..2e9c222 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -191,7 +191,7 @@ static struct devprobe2 isa_probes[] __initdata = {
 #endif
 #ifdef CONFIG_CS89x0
 #if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351) || \
-	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440)
+	defined(CONFIG_ARCH_IXDP2X01)
  	{cs89x0_probe, 0},
 #endif
 #endif
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 9149974..af5042d 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -181,10 +181,6 @@ static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
 #elif defined(CONFIG_ARCH_IXDP2X01)
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
-#elif defined(CONFIG_MACH_QQ2440)
-#include <mach/qq2440.h>
-static unsigned int netcard_portlist[] __used __initdata = { QQ2440_CS8900_VIRT_BASE + 0x300, 0 };
-static unsigned int cs8900_irq_map[] = { QQ2440_CS8900_IRQ, 0, 0, 0 };
 #endif
 #else
 static unsigned int netcard_portlist[] __used __initdata =
@@ -297,7 +293,7 @@ __setup("cs89x0_media=", media_fn);
 
 
 #if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351) || \
-	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440)
+	defined(CONFIG_ARCH_IXDP2X01)
 /* Check for a network adaptor of this type, and return '0' iff one exists.
    If dev->base_addr == 0, probe all likely locations.
    If dev->base_addr == 1, always return failure.
@@ -534,9 +530,6 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 		lp->force = g_cs89x0_media__force;
 #endif
 
-#if defined(CONFIG_MACH_QQ2440)
-		lp->force |= FORCE_RJ45 | FORCE_FULL;
-#endif
         }
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
@@ -1173,7 +1166,7 @@ write_irq(struct net_device *dev, int chip_type, int irq)
 
 	if (chip_type == CS8900) {
 #if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351) || \
-	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440)
+	defined(CONFIG_ARCH_IXDP2X01)
 		/* Search the mapping table for the corresponding IRQ pin. */
 		for (i = 0; i != ARRAY_SIZE(cs8900_irq_map); i++)
 			if (cs8900_irq_map[i] == irq)
-- 
1.7.1
