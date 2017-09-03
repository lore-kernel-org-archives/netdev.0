From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/17] net/mlx5e: Use memset to init skbs_frags array to zeros
Date: Sun,  3 Sep 2017 07:21:04 +0300
Message-ID: <20170903042117.28923-5-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60000 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750912AbdICEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:11 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In RX data-path, use memset() instead of loop assignment
to init the whole skbs_frags array.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index aa5cc1590859..db372dcecbe0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -391,9 +391,9 @@ static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 			goto err_unmap;
 		wi->umr.mtt[i] = cpu_to_be64(dma_info->addr | MLX5_EN_WR);
 		page_ref_add(dma_info->page, pg_strides);
-		wi->skbs_frags[i] = 0;
 	}
 
+	memset(wi->skbs_frags, 0, sizeof(*wi->skbs_frags) * MLX5_MPWRQ_PAGES_PER_WQE);
 	wi->consumed_strides = 0;
 	wqe->data.addr = cpu_to_be64(dma_offset);
 
-- 
2.13.0
