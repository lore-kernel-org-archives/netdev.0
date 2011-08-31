From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 05/14] mv643xx: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:46:57 +0100
Message-ID: <1314787626-12273-5-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10632 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041Ab1HaKrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 06:47:14 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 1e2c9f07..7325737 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -752,10 +752,10 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 
 		desc->l4i_chk = 0;
 		desc->byte_cnt = this_frag->size;
-		desc->buf_ptr = dma_map_page(mp->dev->dev.parent,
-					     this_frag->page,
-					     this_frag->page_offset,
-					     this_frag->size, DMA_TO_DEVICE);
+		desc->buf_ptr = skb_frag_dma_map(mp->dev->dev.parent,
+						 this_frag, 0,
+						 this_frag->size,
+						 DMA_TO_DEVICE);
 	}
 }
 
-- 
1.7.2.5
