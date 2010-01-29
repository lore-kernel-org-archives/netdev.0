From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/13] tulip/interrupt.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:22 -0800
Message-ID: <083dca740c8aa9c767992217bc751cd5da8cc69e.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1590 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754016Ab0A2G7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:31 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/interrupt.c |  100 ++++++++++++++++++++++-------------------
 1 files changed, 53 insertions(+), 47 deletions(-)

diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 2e8e8ee..1faf7a4 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -125,12 +125,12 @@ int tulip_poll(struct napi_struct *napi, int budget)
 #endif
 
 	if (tulip_debug > 4)
-		printk(KERN_DEBUG " In tulip_rx(), entry %d %8.8x.\n", entry,
-			   tp->rx_ring[entry].status);
+		printk(KERN_DEBUG " In tulip_rx(), entry %d %08x\n",
+		       entry, tp->rx_ring[entry].status);
 
        do {
 		if (ioread32(tp->base_addr + CSR5) == 0xffffffff) {
-			printk(KERN_DEBUG " In tulip_poll(), hardware disappeared.\n");
+			printk(KERN_DEBUG " In tulip_poll(), hardware disappeared\n");
 			break;
 		}
                /* Acknowledge current RX interrupt sources. */
@@ -146,7 +146,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
                                break;
 
                        if (tulip_debug > 5)
-                               printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
+                               printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %08x\n",
                                       dev->name, entry, status);
 
 		       if (++work_done >= budget)
@@ -177,15 +177,15 @@ int tulip_poll(struct napi_struct *napi, int budget)
                                 /* Ingore earlier buffers. */
                                        if ((status & 0xffff) != 0x7fff) {
                                                if (tulip_debug > 1)
-                                                       printk(KERN_WARNING "%s: Oversized Ethernet frame "
-                                                              "spanned multiple buffers, status %8.8x!\n",
-                                                              dev->name, status);
+                                                       dev_warn(&dev->dev,
+								"Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
+								status);
                                                tp->stats.rx_length_errors++;
                                        }
 			       } else {
                                 /* There was a fatal error. */
                                        if (tulip_debug > 2)
-                                               printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
+                                               printk(KERN_DEBUG "%s: Receive error, Rx status %08x\n",
                                                       dev->name, status);
                                        tp->stats.rx_errors++; /* end of a packet.*/
 				       if (pkt_len > 1518 ||
@@ -226,12 +226,11 @@ int tulip_poll(struct napi_struct *napi, int budget)
 #ifndef final_version
                                        if (tp->rx_buffers[entry].mapping !=
                                            le32_to_cpu(tp->rx_ring[entry].buffer1)) {
-                                               printk(KERN_ERR "%s: Internal fault: The skbuff addresses "
-                                                      "do not match in tulip_rx: %08x vs. %08llx %p / %p.\n",
-                                                      dev->name,
-                                                      le32_to_cpu(tp->rx_ring[entry].buffer1),
-                                                      (unsigned long long)tp->rx_buffers[entry].mapping,
-                                                      skb->head, temp);
+                                               dev_err(&dev->dev,
+						       "Internal fault: The skbuff addresses do not match in tulip_rx: %08x vs. %08llx %p / %p\n",
+						       le32_to_cpu(tp->rx_ring[entry].buffer1),
+						       (unsigned long long)tp->rx_buffers[entry].mapping,
+						       skb->head, temp);
                                        }
 #endif
 
@@ -365,16 +364,16 @@ static int tulip_rx(struct net_device *dev)
 	int received = 0;
 
 	if (tulip_debug > 4)
-		printk(KERN_DEBUG " In tulip_rx(), entry %d %8.8x.\n", entry,
-			   tp->rx_ring[entry].status);
+		printk(KERN_DEBUG " In tulip_rx(), entry %d %08x\n",
+		       entry, tp->rx_ring[entry].status);
 	/* If we own the next entry, it is a new packet. Send it up. */
 	while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
 		s32 status = le32_to_cpu(tp->rx_ring[entry].status);
 		short pkt_len;
 
 		if (tulip_debug > 5)
-			printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
-				   dev->name, entry, status);
+			printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %08x\n",
+			       dev->name, entry, status);
 		if (--rx_work_limit < 0)
 			break;
 
@@ -402,16 +401,16 @@ static int tulip_rx(struct net_device *dev)
 				/* Ingore earlier buffers. */
 				if ((status & 0xffff) != 0x7fff) {
 					if (tulip_debug > 1)
-						printk(KERN_WARNING "%s: Oversized Ethernet frame "
-							   "spanned multiple buffers, status %8.8x!\n",
-							   dev->name, status);
+						dev_warn(&dev->dev,
+							 "Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
+							 status);
 					tp->stats.rx_length_errors++;
 				}
 			} else {
 				/* There was a fatal error. */
 				if (tulip_debug > 2)
-					printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
-						   dev->name, status);
+					printk(KERN_DEBUG "%s: Receive error, Rx status %08x\n",
+					       dev->name, status);
 				tp->stats.rx_errors++; /* end of a packet.*/
 				if (pkt_len > 1518 ||
 				    (status & RxDescRunt))
@@ -450,12 +449,11 @@ static int tulip_rx(struct net_device *dev)
 #ifndef final_version
 				if (tp->rx_buffers[entry].mapping !=
 				    le32_to_cpu(tp->rx_ring[entry].buffer1)) {
-					printk(KERN_ERR "%s: Internal fault: The skbuff addresses "
-					       "do not match in tulip_rx: %08x vs. %Lx %p / %p.\n",
-					       dev->name,
-					       le32_to_cpu(tp->rx_ring[entry].buffer1),
-					       (long long)tp->rx_buffers[entry].mapping,
-					       skb->head, temp);
+					dev_err(&dev->dev,
+						"Internal fault: The skbuff addresses do not match in tulip_rx: %08x vs. %Lx %p / %p\n",
+						le32_to_cpu(tp->rx_ring[entry].buffer1),
+						(long long)tp->rx_buffers[entry].mapping,
+						skb->head, temp);
 				}
 #endif
 
@@ -569,7 +567,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 #endif /*  CONFIG_TULIP_NAPI */
 
 		if (tulip_debug > 4)
-			printk(KERN_DEBUG "%s: interrupt  csr5=%#8.8x new csr5=%#8.8x.\n",
+			printk(KERN_DEBUG "%s: interrupt  csr5=%#8.8x new csr5=%#8.8x\n",
 			       dev->name, csr5, ioread32(ioaddr + CSR5));
 
 
@@ -601,8 +599,8 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 					/* There was an major error, log it. */
 #ifndef final_version
 					if (tulip_debug > 1)
-						printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
-							   dev->name, status);
+						printk(KERN_DEBUG "%s: Transmit error, Tx status %08x\n",
+						       dev->name, status);
 #endif
 					tp->stats.tx_errors++;
 					if (status & 0x4104) tp->stats.tx_aborted_errors++;
@@ -631,8 +629,9 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 
 #ifndef final_version
 			if (tp->cur_tx - dirty_tx > TX_RING_SIZE) {
-				printk(KERN_ERR "%s: Out-of-sync dirty pointer, %d vs. %d.\n",
-					   dev->name, dirty_tx, tp->cur_tx);
+				dev_err(&dev->dev,
+					"Out-of-sync dirty pointer, %d vs. %d\n",
+					dirty_tx, tp->cur_tx);
 				dirty_tx += TX_RING_SIZE;
 			}
 #endif
@@ -643,9 +642,10 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 			tp->dirty_tx = dirty_tx;
 			if (csr5 & TxDied) {
 				if (tulip_debug > 2)
-					printk(KERN_WARNING "%s: The transmitter stopped."
-						   "  CSR5 is %x, CSR6 %x, new CSR6 %x.\n",
-						   dev->name, csr5, ioread32(ioaddr + CSR6), tp->csr6);
+					dev_warn(&dev->dev,
+						 "The transmitter stopped.  CSR5 is %x, CSR6 %x, new CSR6 %x\n",
+						 csr5, ioread32(ioaddr + CSR6),
+						 tp->csr6);
 				tulip_restart_rxtx(tp);
 			}
 			spin_unlock(&tp->lock);
@@ -696,8 +696,9 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 				 * to the 21142/3 docs that is).
 				 *   -- rmk
 				 */
-				printk(KERN_ERR "%s: (%lu) System Error occurred (%d)\n",
-					dev->name, tp->nir, error);
+				dev_err(&dev->dev,
+					"(%lu) System Error occurred (%d)\n",
+					tp->nir, error);
 			}
 			/* Clear all error sources, included undocumented ones! */
 			iowrite32(0x0800f7ba, ioaddr + CSR5);
@@ -706,16 +707,17 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 		if (csr5 & TimerInt) {
 
 			if (tulip_debug > 2)
-				printk(KERN_ERR "%s: Re-enabling interrupts, %8.8x.\n",
-					   dev->name, csr5);
+				dev_err(&dev->dev,
+					"Re-enabling interrupts, %08x\n",
+					csr5);
 			iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
 			tp->ttimer = 0;
 			oi++;
 		}
 		if (tx > maxtx || rx > maxrx || oi > maxoi) {
 			if (tulip_debug > 1)
-				printk(KERN_WARNING "%s: Too much work during an interrupt, "
-					   "csr5=0x%8.8x. (%lu) (%d,%d,%d)\n", dev->name, csr5, tp->nir, tx, rx, oi);
+				dev_warn(&dev->dev, "Too much work during an interrupt, csr5=0x%08x. (%lu) (%d,%d,%d)\n",
+					 csr5, tp->nir, tx, rx, oi);
 
                        /* Acknowledge all interrupt sources. */
                         iowrite32(0x8001ffff, ioaddr + CSR5);
@@ -764,14 +766,18 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 	entry = tp->dirty_rx % RX_RING_SIZE;
 	if (tp->rx_buffers[entry].skb == NULL) {
 		if (tulip_debug > 1)
-			printk(KERN_WARNING "%s: in rx suspend mode: (%lu) (tp->cur_rx = %u, ttimer = %d, rx = %d) go/stay in suspend mode\n", dev->name, tp->nir, tp->cur_rx, tp->ttimer, rx);
+			dev_warn(&dev->dev,
+				 "in rx suspend mode: (%lu) (tp->cur_rx = %u, ttimer = %d, rx = %d) go/stay in suspend mode\n",
+				 tp->nir, tp->cur_rx, tp->ttimer, rx);
 		if (tp->chip_id == LC82C168) {
 			iowrite32(0x00, ioaddr + CSR7);
 			mod_timer(&tp->timer, RUN_AT(HZ/50));
 		} else {
 			if (tp->ttimer == 0 || (ioread32(ioaddr + CSR11) & 0xffff) == 0) {
 				if (tulip_debug > 1)
-					printk(KERN_WARNING "%s: in rx suspend mode: (%lu) set timer\n", dev->name, tp->nir);
+					dev_warn(&dev->dev,
+						 "in rx suspend mode: (%lu) set timer\n",
+						 tp->nir);
 				iowrite32(tulip_tbl[tp->chip_id].valid_intrs | TimerInt,
 					ioaddr + CSR7);
 				iowrite32(TimerInt, ioaddr + CSR5);
@@ -787,8 +793,8 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 	}
 
 	if (tulip_debug > 4)
-		printk(KERN_DEBUG "%s: exiting interrupt, csr5=%#4.4x.\n",
-			   dev->name, ioread32(ioaddr + CSR5));
+		printk(KERN_DEBUG "%s: exiting interrupt, csr5=%#04x\n",
+		       dev->name, ioread32(ioaddr + CSR5));
 
 	return IRQ_HANDLED;
 }
-- 
1.6.6.rc0.57.gad7a

