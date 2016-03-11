From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 10/13] net/mlx5e: Use napi_alloc_skb for RX SKB allocations
Date: Fri, 11 Mar 2016 15:39:51 +0200
Message-ID: <1457703594-9482-11-git-send-email-saeedm@mellanox.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33321 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932182AbcCKNmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 08:42:10 -0500
In-Reply-To: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Instead of netdev_alloc_skb, we use the napi_alloc_skb function
which is designated to allocate skbuff's for RX in a
channel-specific NAPI instance.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index dd3a6e1..aa7f90c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -47,7 +47,7 @@ int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 	struct sk_buff *skb;
 	dma_addr_t dma_addr;
 
-	skb = netdev_alloc_skb(rq->netdev, rq->wqe_sz);
+	skb = napi_alloc_skb(rq->cq.napi, rq->wqe_sz);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
@@ -644,7 +644,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		goto mpwrq_cqe_out;
 	}
 
-	skb = netdev_alloc_skb(rq->netdev, MLX5_MPWRQ_SMALL_PACKET_THRESHOLD);
+	skb = napi_alloc_skb(rq->cq.napi, MLX5_MPWRQ_SMALL_PACKET_THRESHOLD);
 	if (unlikely(!skb))
 		goto mpwrq_cqe_out;
 
-- 
1.7.1
