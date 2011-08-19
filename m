From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 35/75] mv643xx: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:07 +0100
Message-ID: <1313760467-8598-35-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/mv643xx_eth.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2596999..0da6643 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
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
