From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 01/14] mlx4: use __skb_fill_page_desc()
Date: Thu,  9 Feb 2017 05:58:25 -0800
Message-ID: <20170209135838.16487-2-edumazet@google.com>
References: <20170209135838.16487-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35388 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753096AbdBIO1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:27:34 -0500
Received: by mail-pf0-f174.google.com with SMTP id f144so1093651pfa.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:27:34 -0800 (PST)
In-Reply-To: <20170209135838.16487-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or we might miss the fact that a page was allocated from memory reserves.

Fixes: dceeab0e5258 ("mlx4: support __GFP_MEMALLOC for rx")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index d85e6446f9d99e38c75b97d7fba29bd057e0..867292880c07a15124a0cf099d1fcda09926 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -604,10 +604,10 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
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
2.11.0.483.g087da7b7c-goog
