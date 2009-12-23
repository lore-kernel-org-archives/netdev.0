From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/8] sfc: Fix DMA mapping cleanup in case of an error in TSO
Date: Wed, 23 Dec 2009 23:47:13 +0000
Message-ID: <1261612033.2782.92.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28213 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264AbZLWXrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:47:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Turton <nturton@solarflare.com>

We need buffer->len to remain valid to work out the correct address to
be unmapped.  We therefore need to clear buffer->len after the unmap
operation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index e669f94..a8b70ef 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -821,8 +821,6 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 					   EFX_TXQ_MASK];
 		efx_tsoh_free(tx_queue, buffer);
 		EFX_BUG_ON_PARANOID(buffer->skb);
-		buffer->len = 0;
-		buffer->continuation = true;
 		if (buffer->unmap_len) {
 			unmap_addr = (buffer->dma_addr + buffer->len -
 				      buffer->unmap_len);
@@ -836,6 +834,8 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 					       PCI_DMA_TODEVICE);
 			buffer->unmap_len = 0;
 		}
+		buffer->len = 0;
+		buffer->continuation = true;
 	}
 }
 
-- 
1.5.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

