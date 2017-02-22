From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net V2 5/5] net/mlx4_en: Use __skb_fill_page_desc()
Date: Wed, 22 Feb 2017 18:25:29 +0200
Message-ID: <1487780729-8798-6-git-send-email-tariqt@mellanox.com>
References: <1487780729-8798-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Dexuan Cui <decui@microsoft.com>,
        Eric Dumazet <edumazet@google.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39989 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932842AbdBVQ0A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:26:00 -0500
In-Reply-To: <1487780729-8798-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Or we might miss the fact that a page was allocated from memory reserves.

Fixes: dceeab0e5258 ("mlx4: support __GFP_MEMALLOC for rx")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index cc003fdf0ed9..eca31f443909 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -603,10 +603,10 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 		dma_sync_single_for_cpu(priv->ddev, dma, frag_info->frag_size,
 					DMA_FROM_DEVICE);
 
-		/* Save page reference in skb */
-		__skb_frag_set_page(&skb_frags_rx[nr], frags[nr].page);
-		skb_frag_size_set(&skb_frags_rx[nr], frag_info->frag_size);
-		skb_frags_rx[nr].page_offset = frags[nr].page_offset;
+		__skb_fill_page_desc(skb, nr, frags[nr].page,
+				     frags[nr].page_offset,
+				     frag_info->frag_size);
+
 		skb->truesize += frag_info->frag_stride;
 		frags[nr].page = NULL;
 	}
-- 
1.8.3.1
