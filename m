From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/17] net/mlx5e: Remove unnecessary wqe_sz field from RQ buffer
Date: Sun,  3 Sep 2017 07:21:03 +0300
Message-ID: <20170903042117.28923-4-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59980 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750904AbdICEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:11 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Field is used only locally within the RQ create function.
The use of a local variable is sufficient.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 8 +++-----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 44bd8df905ca..ce8b4f648757 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -540,7 +540,6 @@ struct mlx5e_rq {
 		} mpwqe;
 	};
 	struct {
-		u32            wqe_sz;    /* wqe data buffer size */
 		u16            headroom;
 		u8             page_order;
 		u8             map_dir;   /* dma map direction */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7a25d952c922..591e0dca9671 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -618,8 +618,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 		rq->mpwqe.log_stride_sz = params->mpwqe_log_stride_sz;
 		rq->mpwqe.num_strides = BIT(params->mpwqe_log_num_strides);
 
-		rq->buff.wqe_sz = rq->mpwqe.num_strides << rq->mpwqe.log_stride_sz;
-		byte_count = rq->buff.wqe_sz;
+		byte_count = rq->mpwqe.num_strides << rq->mpwqe.log_stride_sz;
 
 		err = mlx5e_create_rq_umr_mkey(mdev, rq);
 		if (err)
@@ -654,15 +653,14 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 			goto err_rq_wq_destroy;
 		}
 
-		rq->buff.wqe_sz = params->lro_en  ?
+		byte_count = params->lro_en  ?
 				params->lro_wqe_sz :
 				MLX5E_SW2HW_MTU(c->priv, c->netdev->mtu);
 #ifdef CONFIG_MLX5_EN_IPSEC
 		if (MLX5_IPSEC_DEV(mdev))
-			rq->buff.wqe_sz += MLX5E_METADATA_ETHER_LEN;
+			byte_count += MLX5E_METADATA_ETHER_LEN;
 #endif
 		rq->wqe.page_reuse = !params->xdp_prog && !params->lro_en;
-		byte_count = rq->buff.wqe_sz;
 
 		/* calc the required page order */
 		rq->wqe.frag_sz = MLX5_SKB_FRAG_SZ(rq->buff.headroom + byte_count);
-- 
2.13.0
