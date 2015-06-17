From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 12/12] net/mlx5e: Prefetch skb data on RX
Date: Wed, 17 Jun 2015 18:26:29 +0300
Message-ID: <1434554789-13758-13-git-send-email-ogerlitz@mellanox.com>
References: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53943 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753812AbbFQP06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 11:26:58 -0400
In-Reply-To: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Prefetch the 1st cache line used by the buffer pointed by
the skb linear data.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 760b3ef..9a93741 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -215,6 +215,7 @@ bool mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		wqe_counter    = be16_to_cpu(wqe_counter_be);
 		wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 		skb            = rq->skb[wqe_counter];
+		prefetch(skb->data);
 		rq->skb[wqe_counter] = NULL;
 
 		dma_unmap_single(rq->pdev,
-- 
2.3.7
