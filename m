From: Christoph Egger <siccegge@cs.fau.de>
Subject: [PATCH 10/11] Removing dead NETWINDER_{T,R}X_DMA_PROBLEMS
Date: Wed, 14 Jul 2010 14:41:26 +0200
Message-ID: <48e9743a02fc6630900d911d377002cbd1acb06e.1279110895.git.siccegge@cs.fau.de>
References: <cover.1279110894.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roel Kluin <roel.kluin@gmail.com>,
	Stephen Hemminger <shemminger
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:43702 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756840Ab0GNMl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:41:28 -0400
Content-Disposition: inline
In-Reply-To: <cover.1279110894.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETWINDER_{T,R}X_DMA_PROBLEMS doesn't exist in Kconfig, therefore
removing all references for it from the source code.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 drivers/net/irda/w83977af_ir.c |   33 ++++-----------------------------
 1 files changed, 4 insertions(+), 29 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 1f9c3f0..05c6d79 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -61,10 +61,6 @@
 #include "w83977af.h"
 #include "w83977af_ir.h"
 
-#ifdef  CONFIG_ARCH_NETWINDER            /* Adjust to NetWinder differences */
-#undef  CONFIG_NETWINDER_TX_DMA_PROBLEMS /* Not needed */
-#define CONFIG_NETWINDER_RX_DMA_PROBLEMS /* Must have this one! */
-#endif
 #define CONFIG_USE_W977_PNP        /* Currently needed */
 #define PIO_MAX_SPEED       115200 
 
@@ -565,11 +561,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 {
 	__u8 set;
-#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
-	unsigned long flags;
-	__u8 hcr;
-#endif
-        IRDA_DEBUG(4, "%s(), len=%d\n", __func__ , self->tx_buff.len);
+	IRDA_DEBUG(4, "%s(), len=%d\n", __func__ , self->tx_buff.len);
 
 	/* Save current set */
 	set = inb(iobase+SSR);
@@ -581,30 +573,13 @@ static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 	/* Choose transmit DMA channel  */ 
 	switch_bank(iobase, SET2);
 	outb(ADCR1_D_CHSW|/*ADCR1_DMA_F|*/ADCR1_ADV_SL, iobase+ADCR1);
-#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
-	spin_lock_irqsave(&self->lock, flags);
-
-	disable_dma(self->io.dma);
-	clear_dma_ff(self->io.dma);
-	set_dma_mode(self->io.dma, DMA_MODE_READ);
-	set_dma_addr(self->io.dma, self->tx_buff_dma);
-	set_dma_count(self->io.dma, self->tx_buff.len);
-#else
 	irda_setup_dma(self->io.dma, self->tx_buff_dma, self->tx_buff.len,
 		       DMA_MODE_WRITE);	
-#endif
 	self->io.direction = IO_XMIT;
 	
 	/* Enable DMA */
  	switch_bank(iobase, SET0);
-#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
-	hcr = inb(iobase+HCR);
-	outb(hcr | HCR_EN_DMA, iobase+HCR);
-	enable_dma(self->io.dma);
-	spin_unlock_irqrestore(&self->lock, flags);
-#else	
 	outb(inb(iobase+HCR) | HCR_EN_DMA | HCR_TX_WT, iobase+HCR);
-#endif
 
 	/* Restore set register */
 	outb(set, iobase+SSR);
@@ -713,7 +688,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 {
 	int iobase;
 	__u8 set;
-#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
+#ifdef CONFIG_ARCH_NETWINDER
 	unsigned long flags;
 	__u8 hcr;
 #endif
@@ -738,7 +713,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 	self->io.direction = IO_RECV;
 	self->rx_buff.data = self->rx_buff.head;
 
-#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
+#ifdef CONFIG_ARCH_NETWINDER
 	spin_lock_irqsave(&self->lock, flags);
 
 	disable_dma(self->io.dma);
@@ -761,7 +736,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 	
 	/* Enable DMA */
 	switch_bank(iobase, SET0);
-#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
+#ifdef CONFIG_ARCH_NETWINDER
 	hcr = inb(iobase+HCR);
 	outb(hcr | HCR_EN_DMA, iobase+HCR);
 	enable_dma(self->io.dma);
-- 
1.7.0.4

