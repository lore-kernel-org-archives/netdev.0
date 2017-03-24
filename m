From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/12] net/mlx5e: Use dma_rmb rather than rmb in CQE fetch routine
Date: Sat, 25 Mar 2017 00:52:03 +0300
Message-ID: <20170324215214.25711-2-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35747 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933123AbdCXVwY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:24 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dma_rmb in mlx5e_get_cqe rather than aggressive rmb (at least on
some architectures), this should help improve the performance on such
CPU archs where dma_rmb is optimized.

Performance improvement:
System: Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz

Test case                   Baseline      Now      improvement
---------------------------------------------------------------
TX packets (24 threads)     45Mpps        50Mpps      11%
TC stack Drop (1 core)      3.45Mpps      3.6Mpps     5%
XDP Drop      (1 core)      14Mpps        16.9Mpps    20%
XDP TX        (1 core)      10.4Mpps      12Mpps      15%

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index e5c12a732aa1..d8cda2f6239b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -44,7 +44,7 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 		return NULL;
 
 	/* ensure cqe content is read after cqe ownership bit */
-	rmb();
+	dma_rmb();
 
 	return cqe;
 }
-- 
2.11.0
