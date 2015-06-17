From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 07/12] net/mlx5e: Avoid redundant dev_kfree_skb() upon NOP completion
Date: Wed, 17 Jun 2015 18:26:24 +0300
Message-ID: <1434554789-13758-8-git-send-email-ogerlitz@mellanox.com>
References: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53990 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756776AbbFQP1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 11:27:13 -0400
In-Reply-To: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

NOP completion SKBs are always NULL.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index c0566b6..f5c7d78 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -294,7 +294,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 		if (unlikely(!skb)) { /* nop */
 			sq->stats.nop++;
 			sqcc++;
-			goto free_skb;
+			continue;
 		}
 
 		for (j = 0; j < MLX5E_TX_SKB_CB(skb)->num_dma; j++) {
@@ -309,8 +309,6 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 		npkts++;
 		nbytes += MLX5E_TX_SKB_CB(skb)->num_bytes;
 		sqcc += MLX5E_TX_SKB_CB(skb)->num_wqebbs;
-
-free_skb:
 		dev_kfree_skb(skb);
 	}
 
-- 
2.3.7
