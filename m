From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/16] sfc: Added and removed braces to comply with kernel style
Date: Fri, 16 May 2008 21:15:49 +0100
Message-ID: <20080516201549.GX28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53526 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754499AbYEPUQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:16:43 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c    |    6 +++---
 drivers/net/sfc/falcon.c |    3 ++-
 drivers/net/sfc/rx.c     |    3 ++-
 drivers/net/sfc/tx.c     |    9 ++++++---
 4 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 3494f4c..df19e86 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1060,9 +1060,8 @@ static void efx_flush_all(struct efx_nic *efx)
 	cancel_delayed_work_sync(&efx->monitor_work);
 
 	/* Ensure that all RX slow refills are complete. */
-	efx_for_each_rx_queue(rx_queue, efx) {
+	efx_for_each_rx_queue(rx_queue, efx)
 		cancel_delayed_work_sync(&rx_queue->work);
-	}
 
 	/* Stop scheduled port reconfigurations */
 	cancel_work_sync(&efx->reconfigure_work);
@@ -1088,9 +1087,10 @@ static void efx_stop_all(struct efx_nic *efx)
 	falcon_disable_interrupts(efx);
 	if (efx->legacy_irq)
 		synchronize_irq(efx->legacy_irq);
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel_with_interrupt(channel, efx) {
 		if (channel->irq)
 			synchronize_irq(channel->irq);
+	}
 
 	/* Stop all NAPI processing and synchronous rx refills */
 	efx_for_each_channel(channel, efx)
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index c58f8a3..4f96ce4 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1636,9 +1636,10 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 	efx_oword_t reg;
 
 	/* Disable MSI/MSI-X interrupts */
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel_with_interrupt(channel, efx) {
 		if (channel->irq)
 			free_irq(channel->irq, channel);
+	}
 
 	/* ACK legacy interrupt */
 	if (FALCON_REV(efx) >= FALCON_REV_B0)
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 6706223..a641330 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -400,9 +400,10 @@ static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
 		return 0;
 
 	/* Record minimum fill level */
-	if (unlikely(fill_level < rx_queue->min_fill))
+	if (unlikely(fill_level < rx_queue->min_fill)) {
 		if (fill_level)
 			rx_queue->min_fill = fill_level;
+	}
 
 	/* Acquire RX add lock.  If this lock is contended, then a fast
 	 * fill must already be in progress (e.g. in the refill
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 9b436f5..75eb0fd 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -639,11 +639,12 @@ static void efx_tsoh_block_free(struct efx_tx_queue *tx_queue,
 	base_dma = tsoh->dma_addr & PAGE_MASK;
 
 	p = &tx_queue->tso_headers_free;
-	while (*p != NULL)
+	while (*p != NULL) {
 		if (((unsigned long)*p & PAGE_MASK) == base_kva)
 			*p = (*p)->next;
 		else
 			p = &(*p)->next;
+	}
 
 	pci_free_consistent(pci_dev, PAGE_SIZE, (void *)base_kva, base_dma);
 }
@@ -939,9 +940,10 @@ static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 
 	/* Allocate a DMA-mapped header buffer. */
 	if (likely(TSOH_SIZE(st->p.header_length) <= TSOH_STD_SIZE)) {
-		if (tx_queue->tso_headers_free == NULL)
+		if (tx_queue->tso_headers_free == NULL) {
 			if (efx_tsoh_block_alloc(tx_queue))
 				return -1;
+		}
 		EFX_BUG_ON_PARANOID(!tx_queue->tso_headers_free);
 		tsoh = tx_queue->tso_headers_free;
 		tx_queue->tso_headers_free = tsoh->next;
@@ -1106,9 +1108,10 @@ static void efx_fini_tso(struct efx_tx_queue *tx_queue)
 {
 	unsigned i;
 
-	if (tx_queue->buffer)
+	if (tx_queue->buffer) {
 		for (i = 0; i <= tx_queue->efx->type->txd_ring_mask; ++i)
 			efx_tsoh_free(tx_queue, &tx_queue->buffer[i]);
+	}
 
 	while (tx_queue->tso_headers_free != NULL)
 		efx_tsoh_block_free(tx_queue, tx_queue->tso_headers_free,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
