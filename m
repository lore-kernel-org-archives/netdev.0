From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] sh: remove references to CPU_SUBTYPE_SH7764
Date: Mon, 11 Mar 2013 12:55:40 +0100
Message-ID: <1363002940.3137.65.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Mundt <lethal@linux-sh.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since release v2.6.29 the tree has a few references to the Kconfig
symbol CPU_SUBTYPE_SH7764 and the Kconfig macro
CONFIG_CPU_SUBTYPE_SH7764. But the actual symbol CPU_SUBTYPE_SH7764 was
never added to the tree. Perhaps no one noticed because these references
were never used alone. Anyhow, these references serve no purpose and
can be removed.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Untested: I don't have the hardware. Neither do I have the compiler for
this architecture at hand.

 arch/sh/drivers/dma/Kconfig                | 2 +-
 arch/sh/include/cpu-sh4/cpu/dma-register.h | 1 -
 arch/sh/include/cpu-sh4a/cpu/dma.h         | 3 +--
 drivers/net/ethernet/renesas/sh_eth.c      | 1 -
 4 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/sh/drivers/dma/Kconfig b/arch/sh/drivers/dma/Kconfig
index cfd5b90..504afb4 100644
--- a/arch/sh/drivers/dma/Kconfig
+++ b/arch/sh/drivers/dma/Kconfig
@@ -12,7 +12,7 @@ config SH_DMA_IRQ_MULTI
 	default y if CPU_SUBTYPE_SH7750  || CPU_SUBTYPE_SH7751  || \
 		     CPU_SUBTYPE_SH7750S || CPU_SUBTYPE_SH7750R || \
 		     CPU_SUBTYPE_SH7751R || CPU_SUBTYPE_SH7091  || \
-		     CPU_SUBTYPE_SH7763  || CPU_SUBTYPE_SH7764  || \
+		     CPU_SUBTYPE_SH7763  || \
 		     CPU_SUBTYPE_SH7780  || CPU_SUBTYPE_SH7785  || \
 		     CPU_SUBTYPE_SH7760
 
diff --git a/arch/sh/include/cpu-sh4/cpu/dma-register.h b/arch/sh/include/cpu-sh4/cpu/dma-register.h
index 02788b6..9cd81e5 100644
--- a/arch/sh/include/cpu-sh4/cpu/dma-register.h
+++ b/arch/sh/include/cpu-sh4/cpu/dma-register.h
@@ -32,7 +32,6 @@
 #define CHCR_TS_HIGH_SHIFT	(20 - 2)	/* 2 bits for shifted low TS */
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757) || \
 	defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
 	defined(CONFIG_CPU_SUBTYPE_SH7780) || \
 	defined(CONFIG_CPU_SUBTYPE_SH7785)
 #define CHCR_TS_LOW_MASK	0x00000018
diff --git a/arch/sh/include/cpu-sh4a/cpu/dma.h b/arch/sh/include/cpu-sh4a/cpu/dma.h
index 89afb65..8ceccce 100644
--- a/arch/sh/include/cpu-sh4a/cpu/dma.h
+++ b/arch/sh/include/cpu-sh4a/cpu/dma.h
@@ -14,8 +14,7 @@
 #define DMTE4_IRQ	evt2irq(0xb80)
 #define DMAE0_IRQ	evt2irq(0xbc0)	/* DMA Error IRQ*/
 #define SH_DMAC_BASE0	0xFE008020
-#elif defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7764)
+#elif defined(CONFIG_CPU_SUBTYPE_SH7763)
 #define DMTE0_IRQ	evt2irq(0x640)
 #define DMTE4_IRQ	evt2irq(0x780)
 #define DMAE0_IRQ	evt2irq(0x6c0)
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 33e9617..44a3d7b 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1653,7 +1653,6 @@ static int sh_eth_open(struct net_device *ndev)
 
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
 #if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
 	defined(CONFIG_CPU_SUBTYPE_SH7757)
 				IRQF_SHARED,
 #else
-- 
1.7.11.7
