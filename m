From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 13/15] net/mlx5e: Use u8 as ownership type in mlx5e_get_cqe()
Date: Sun, 30 Apr 2017 16:20:14 +0300
Message-ID: <20170430132016.27012-14-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46858 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756902AbdD3NUj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:39 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

CQE ownership indication is as small as a single bit.
Use u8 to speedup the comparison.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 491e83d09b58..5ca6714e3e02 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -37,8 +37,8 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 	struct mlx5_cqwq *wq = &cq->wq;
 	u32 ci = mlx5_cqwq_get_ci(wq);
 	struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(wq, ci);
-	int cqe_ownership_bit = cqe->op_own & MLX5_CQE_OWNER_MASK;
-	int sw_ownership_val = mlx5_cqwq_get_wrap_cnt(wq) & 1;
+	u8 cqe_ownership_bit = cqe->op_own & MLX5_CQE_OWNER_MASK;
+	u8 sw_ownership_val = mlx5_cqwq_get_wrap_cnt(wq) & 1;
 
 	if (cqe_ownership_bit != sw_ownership_val)
 		return NULL;
-- 
2.11.0
