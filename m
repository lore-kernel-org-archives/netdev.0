From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/9] mlx4: use __skb_fill_page_desc()
Date: Mon,  6 Feb 2017 19:02:32 -0800
Message-ID: <20170207030240.31357-2-edumazet@google.com>
References: <20170207030240.31357-1-edumazet@google.com>
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
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33101 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752579AbdBGDDY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:03:24 -0500
Received: by mail-pg0-f41.google.com with SMTP id 204so34071890pge.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 19:03:24 -0800 (PST)
In-Reply-To: <20170207030240.31357-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or we might miss the fact that a page was allocated from memory reserves.

Fixes: dceeab0e5258 ("mlx4: support __GFP_MEMALLOC for rx")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index f15ddba3659aac38471059c6bcbf05071794..03f1713c94c7fa57e9eaaf87fe38a0a6d372 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -601,10 +601,10 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
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
