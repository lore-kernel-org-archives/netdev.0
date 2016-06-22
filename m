From: Wang Sheng-Hui <shhuiw@foxmail.com>
Subject: [PATCH] net/mlx5: use mlx5_buf_alloc_node insteaf of mlx5_buf_alloc in mlx5_wq_ll_create
Date: Wed, 22 Jun 2016 16:06:38 +0800
Message-ID: <1466582798-41187-1-git-send-email-shhuiw@foxmail.com>
Cc: matanb@mellanox.com, leonro@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: saeedm@mellanox.com, amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbguseast2.qq.com ([54.204.34.130]:59385 "EHLO
	smtpbguseast2.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbcFVIHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 04:07:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces 2 changes:
	* use mlx5_buf_alloc_node() insteaf of mlx5_buf_alloc() in
	  mlx5_wq_ll_create
	* Update the failure warn messages with _node postfix for mlx5_*_alloc
          function names

Signed-off-by: Wang Sheng-Hui <shhuiw@foxmail.com>
---
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
