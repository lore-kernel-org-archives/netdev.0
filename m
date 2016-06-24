From: Wang Sheng-Hui <shhuiw@foxmail.com>
Subject: [PATCH v3] net/mlx5: use mlx5_buf_alloc_node instead of mlx5_buf_alloc in mlx5_wq_ll_create
Date: Fri, 24 Jun 2016 08:52:11 +0800
Message-ID: <1466729531-45481-1-git-send-email-shhuiw@foxmail.com>
Cc: matanb@mellanox.com, leonro@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, stable@vger.kernel.org
To: saeedm@mellanox.com, amirv@mellanox.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 311c7c71c9bb ("net/mlx5e: Allocate DMA coherent memory on
reader NUMA node") introduced mlx5_*_alloc_node() but missed changing
some calling and warn messages. This patch introduces 2 changes:
	* Use mlx5_buf_alloc_node() instead of mlx5_buf_alloc() in
	  mlx5_wq_ll_create()
	* Update the failure warn messages with _node postfix for
	  mlx5_*_alloc function names

Fixes: 311c7c71c9bb ("net/mlx5e: Allocate DMA coherent memory on reader NUMA node")
Signed-off-by: Wang Sheng-Hui <shhuiw@foxmail.com>
---

Changes since v2:
	* Reformat the commit log

Changes since v1:
	* Add Fixes line in commit log

 drivers/net/ethernet/mellanox/mlx5/core/wq.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.c b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
index ce21ee5..821a087 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/wq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
@@ -75,14 +75,14 @@ int mlx5_wq_cyc_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 
 	err = mlx5_db_alloc_node(mdev, &wq_ctrl->db, param->db_numa_node);
 	if (err) {
-		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		mlx5_core_warn(mdev, "mlx5_db_alloc_node() failed, %d\n", err);
 		return err;
 	}
 
 	err = mlx5_buf_alloc_node(mdev, mlx5_wq_cyc_get_byte_size(wq),
 				  &wq_ctrl->buf, param->buf_numa_node);
 	if (err) {
-		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		mlx5_core_warn(mdev, "mlx5_buf_alloc_node() failed, %d\n", err);
 		goto err_db_free;
 	}
 
@@ -111,14 +111,14 @@ int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 
 	err = mlx5_db_alloc_node(mdev, &wq_ctrl->db, param->db_numa_node);
 	if (err) {
-		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		mlx5_core_warn(mdev, "mlx5_db_alloc_node() failed, %d\n", err);
 		return err;
 	}
 
 	err = mlx5_buf_alloc_node(mdev, mlx5_cqwq_get_byte_size(wq),
 				  &wq_ctrl->buf, param->buf_numa_node);
 	if (err) {
-		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		mlx5_core_warn(mdev, "mlx5_buf_alloc_node() failed, %d\n", err);
 		goto err_db_free;
 	}
 
@@ -148,13 +148,14 @@ int mlx5_wq_ll_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 
 	err = mlx5_db_alloc_node(mdev, &wq_ctrl->db, param->db_numa_node);
 	if (err) {
-		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		mlx5_core_warn(mdev, "mlx5_db_alloc_node() failed, %d\n", err);
 		return err;
 	}
 
-	err = mlx5_buf_alloc(mdev, mlx5_wq_ll_get_byte_size(wq), &wq_ctrl->buf);
+	err = mlx5_buf_alloc_node(mdev, mlx5_wq_ll_get_byte_size(wq),
+				  &wq_ctrl->buf, param->buf_numa_node);
 	if (err) {
-		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		mlx5_core_warn(mdev, "mlx5_buf_alloc_node() failed, %d\n", err);
 		goto err_db_free;
 	}
 
-- 
2.7.4
