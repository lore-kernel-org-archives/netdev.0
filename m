From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] net/mlx4: use swap() in mlx4_init_qp_table()
Date: Wed, 10 Jun 2015 18:33:06 +0200
Message-ID: <1433953986-24573-1-git-send-email-fabf@skynet.be>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kernel.h macro definition.

Thanks to Julia Lawall for Coccinelle scripting support.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/mellanox/mlx4/qp.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index b75214a..2026863 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -749,7 +749,7 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 
 	{
 		int sort[MLX4_NUM_QP_REGION];
-		int i, j, tmp;
+		int i, j;
 		int last_base = dev->caps.num_qps;
 
 		for (i = 1; i < MLX4_NUM_QP_REGION; ++i)
@@ -758,11 +758,8 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 		for (i = MLX4_NUM_QP_REGION; i > MLX4_QP_REGION_BOTTOM; --i) {
 			for (j = MLX4_QP_REGION_BOTTOM + 2; j < i; ++j) {
 				if (dev->caps.reserved_qps_cnt[sort[j]] >
-				    dev->caps.reserved_qps_cnt[sort[j - 1]]) {
-					tmp             = sort[j];
-					sort[j]         = sort[j - 1];
-					sort[j - 1]     = tmp;
-				}
+				    dev->caps.reserved_qps_cnt[sort[j - 1]])
+					swap(sort[j], sort[j - 1]);
 			}
 		}
 
-- 
2.4.2
