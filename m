From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 01/17] mv643xx_eth: fix receive buffer DMA unmapping
Date: Wed,  3 Sep 2008 14:29:28 +0200
Message-ID: <1220444984-20150-2-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52886 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751572AbYICM3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:46 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tearing down a DMA mapping for a receive buffer, we should pass
dma_unmap_single() the exact same address that dma_map_single() gave
us when we originally set up the mapping.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index deee66d..ad2ae93 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -559,7 +559,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 
 		spin_unlock_irqrestore(&mp->lock, flags);
 
-		dma_unmap_single(NULL, rx_desc->buf_ptr + 2,
+		dma_unmap_single(NULL, rx_desc->buf_ptr,
 				 rx_desc->buf_size, DMA_FROM_DEVICE);
 		rxq->rx_desc_count--;
 		rx++;
-- 
1.5.6.4

