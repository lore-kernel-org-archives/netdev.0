From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/8] net/mlx5e: Use hard-coded 4K page size for RQ/SQ/CQ
Date: Wed, 29 Jul 2015 15:05:40 +0300
Message-ID: <1438171546-17021-3-git-send-email-amirv@mellanox.com>
References: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53784 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750910AbbG2MGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:06:25 -0400
In-Reply-To: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

The page size of the device's RQ/SQ/CQ objects is defined in 4K
units regardless of the system pages size.
Thus using the Linux's PAGE_SHIFT macro yields wrong device
configuration in systems where PAGE_SHIFT!=12.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 355a10a..05b35bd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -349,7 +349,7 @@ static int mlx5e_enable_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 	MLX5_SET(rqc,  rqc, state,		MLX5_RQC_STATE_RST);
 	MLX5_SET(rqc,  rqc, flush_in_error_en,	1);
 	MLX5_SET(wq,   wq,  log_wq_pg_sz,	rq->wq_ctrl.buf.page_shift -
-						PAGE_SHIFT);
+						MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(wq, wq,  dbr_addr,		rq->wq_ctrl.db.dma);
 
 	mlx5_fill_page_array(&rq->wq_ctrl.buf,
@@ -587,7 +587,7 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 	MLX5_SET(wq,   wq, wq_type,       MLX5_WQ_TYPE_CYCLIC);
 	MLX5_SET(wq,   wq, uar_page,      sq->uar.index);
 	MLX5_SET(wq,   wq, log_wq_pg_sz,  sq->wq_ctrl.buf.page_shift -
-					  PAGE_SHIFT);
+					  MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(wq, wq, dbr_addr,      sq->wq_ctrl.db.dma);
 
 	mlx5_fill_page_array(&sq->wq_ctrl.buf,
@@ -782,7 +782,7 @@ static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 	MLX5_SET(cqc,   cqc, c_eqn,         eqn);
 	MLX5_SET(cqc,   cqc, uar_page,      mcq->uar->index);
 	MLX5_SET(cqc,   cqc, log_page_size, cq->wq_ctrl.buf.page_shift -
-					    PAGE_SHIFT);
+					    MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(cqc, cqc, dbr_addr,      cq->wq_ctrl.db.dma);
 
 	err = mlx5_core_create_cq(mdev, mcq, in, inlen);
-- 
2.4.3.413.ga5fe668
