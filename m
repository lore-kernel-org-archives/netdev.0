From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] atm: fore200e: mark expected switch fall-throughs
Date: Thu, 12 Oct 2017 16:11:32 -0500
Message-ID: <20171012211132.GA6589@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Chas Williams <3chas3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.119]:39387 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751682AbdJLVcb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 17:32:31 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id 1E44A4C376
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 16:11:34 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/atm/fore200e.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index f8b7e86..126855e 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -358,26 +358,33 @@ fore200e_shutdown(struct fore200e* fore200e)
     case FORE200E_STATE_COMPLETE:
 	kfree(fore200e->stats);
 
+	/* fall through */
     case FORE200E_STATE_IRQ:
 	free_irq(fore200e->irq, fore200e->atm_dev);
 
+	/* fall through */
     case FORE200E_STATE_ALLOC_BUF:
 	fore200e_free_rx_buf(fore200e);
 
+	/* fall through */
     case FORE200E_STATE_INIT_BSQ:
 	fore200e_uninit_bs_queue(fore200e);
 
+	/* fall through */
     case FORE200E_STATE_INIT_RXQ:
 	fore200e->bus->dma_chunk_free(fore200e, &fore200e->host_rxq.status);
 	fore200e->bus->dma_chunk_free(fore200e, &fore200e->host_rxq.rpd);
 
+	/* fall through */
     case FORE200E_STATE_INIT_TXQ:
 	fore200e->bus->dma_chunk_free(fore200e, &fore200e->host_txq.status);
 	fore200e->bus->dma_chunk_free(fore200e, &fore200e->host_txq.tpd);
 
+	/* fall through */
     case FORE200E_STATE_INIT_CMDQ:
 	fore200e->bus->dma_chunk_free(fore200e, &fore200e->host_cmdq.status);
 
+	/* fall through */
     case FORE200E_STATE_INITIALIZE:
 	/* nothing to do for that state */
 
@@ -390,6 +397,7 @@ fore200e_shutdown(struct fore200e* fore200e)
     case FORE200E_STATE_MAP:
 	fore200e->bus->unmap(fore200e);
 
+	/* fall through */
     case FORE200E_STATE_CONFIGURE:
 	/* nothing to do for that state */
 
-- 
2.7.4
