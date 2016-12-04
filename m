From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 5/6] net/mlx5e: Don't flush SQ on error
Date: Sun,  4 Dec 2016 12:56:15 +0200
Message-ID: <1480848976-6797-6-git-send-email-saeedm@mellanox.com>
References: <1480848976-6797-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39408 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751083AbcLDK5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 05:57:05 -0500
In-Reply-To: <1480848976-6797-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are doing SQ descriptors cleanup in driver.

Fixes: 6e8dd6d6f4bd ("net/mlx5e: Don't wait for SQ completions on close")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 84e8b25..5bf7f86 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1006,7 +1006,6 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 	MLX5_SET(sqc,  sqc, min_wqe_inline_mode, sq->min_inline_mode);
 	MLX5_SET(sqc,  sqc, state,		MLX5_SQC_STATE_RST);
 	MLX5_SET(sqc,  sqc, tis_lst_sz, param->type == MLX5E_SQ_ICO ? 0 : 1);
-	MLX5_SET(sqc,  sqc, flush_in_error_en,	1);
 
 	MLX5_SET(wq,   wq, wq_type,       MLX5_WQ_TYPE_CYCLIC);
 	MLX5_SET(wq,   wq, uar_page,      sq->uar.index);
-- 
2.7.4
