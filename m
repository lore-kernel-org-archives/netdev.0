From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 02/13] net/mlx5_core: Apply proper name convention to helpers
Date: Thu,  4 Jun 2015 19:30:37 +0300
Message-ID: <1433435448-4937-3-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47629 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932134AbbFDQbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:15 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haggai Abramonvsky <hagaya@mellanox.com>

Some core helper functions were named with mlx5_ only prefix, fix that to
mlx5_core_ so we're aligned with the overall scheme used for core services.

Signed-off-by: Haggai Abramovsky <hagaya@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   20 ++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |   22 ++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |   24 +++++++++++--------
 3 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d38b98d..e86bfd7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -347,7 +347,7 @@ static int mlx5e_enable_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 	mlx5_fill_page_array(&rq->wq_ctrl.buf,
 			     (__be64 *)MLX5_ADDR_OF(wq, wq, pas));
 
-	err = mlx5_create_rq(mdev, in, inlen, &rq->rqn);
+	err = mlx5_core_create_rq(mdev, in, inlen, &rq->rqn);
 
 	kvfree(in);
 
@@ -375,7 +375,7 @@ static int mlx5e_modify_rq(struct mlx5e_rq *rq, int curr_state, int next_state)
 	MLX5_SET(modify_rq_in, in, rq_state, curr_state);
 	MLX5_SET(rqc, rqc, state, next_state);
 
-	err = mlx5_modify_rq(mdev, rq->rqn, in, inlen);
+	err = mlx5_core_modify_rq(mdev, rq->rqn, in, inlen);
 
 	kvfree(in);
 
@@ -388,7 +388,7 @@ static void mlx5e_disable_rq(struct mlx5e_rq *rq)
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
 
-	mlx5_destroy_rq(mdev, rq->rqn);
+	mlx5_core_destroy_rq(mdev, rq->rqn);
 }
 
 static int mlx5e_wait_for_min_rx_wqes(struct mlx5e_rq *rq)
@@ -577,7 +577,7 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 	mlx5_fill_page_array(&sq->wq_ctrl.buf,
 			     (__be64 *)MLX5_ADDR_OF(wq, wq, pas));
 
-	err = mlx5_create_sq(mdev, in, inlen, &sq->sqn);
+	err = mlx5_core_create_sq(mdev, in, inlen, &sq->sqn);
 
 	kvfree(in);
 
@@ -605,7 +605,7 @@ static int mlx5e_modify_sq(struct mlx5e_sq *sq, int curr_state, int next_state)
 	MLX5_SET(modify_sq_in, in, sq_state, curr_state);
 	MLX5_SET(sqc, sqc, state, next_state);
 
-	err = mlx5_modify_sq(mdev, sq->sqn, in, inlen);
+	err = mlx5_core_modify_sq(mdev, sq->sqn, in, inlen);
 
 	kvfree(in);
 
@@ -618,7 +618,7 @@ static void mlx5e_disable_sq(struct mlx5e_sq *sq)
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
 
-	mlx5_destroy_sq(mdev, sq->sqn);
+	mlx5_core_destroy_sq(mdev, sq->sqn);
 }
 
 static int mlx5e_open_sq(struct mlx5e_channel *c,
@@ -1096,12 +1096,12 @@ static int mlx5e_open_tis(struct mlx5e_priv *priv, int tc)
 
 	MLX5_SET(tisc, tisc, prio,  tc);
 
-	return mlx5_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
+	return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
 }
 
 static void mlx5e_close_tis(struct mlx5e_priv *priv, int tc)
 {
-	mlx5_destroy_tis(priv->mdev, priv->tisn[tc]);
+	mlx5_core_destroy_tis(priv->mdev, priv->tisn[tc]);
 }
 
 static int mlx5e_open_tises(struct mlx5e_priv *priv)
@@ -1307,7 +1307,7 @@ static int mlx5e_open_tir(struct mlx5e_priv *priv, int tt)
 
 	mlx5e_build_tir_ctx(priv, tirc, tt);
 
-	err = mlx5_create_tir(mdev, in, inlen, &priv->tirn[tt]);
+	err = mlx5_core_create_tir(mdev, in, inlen, &priv->tirn[tt]);
 
 	kvfree(in);
 
@@ -1316,7 +1316,7 @@ static int mlx5e_open_tir(struct mlx5e_priv *priv, int tt)
 
 static void mlx5e_close_tir(struct mlx5e_priv *priv, int tt)
 {
-	mlx5_destroy_tir(priv->mdev, priv->tirn[tt]);
+	mlx5_core_destroy_tir(priv->mdev, priv->tirn[tt]);
 }
 
 static int mlx5e_open_tirs(struct mlx5e_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index 3c555d7..d918816 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -34,7 +34,7 @@
 #include "mlx5_core.h"
 #include "transobj.h"
 
-int mlx5_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn)
+int mlx5_core_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn)
 {
 	u32 out[MLX5_ST_SZ_DW(create_rq_out)];
 	int err;
@@ -49,7 +49,7 @@ int mlx5_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn)
 	return err;
 }
 
-int mlx5_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen)
+int mlx5_core_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen)
 {
 	u32 out[MLX5_ST_SZ_DW(modify_rq_out)];
 
@@ -60,7 +60,7 @@ int mlx5_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen)
 	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
 }
 
-void mlx5_destroy_rq(struct mlx5_core_dev *dev, u32 rqn)
+void mlx5_core_destroy_rq(struct mlx5_core_dev *dev, u32 rqn)
 {
 	u32 in[MLX5_ST_SZ_DW(destroy_rq_in)];
 	u32 out[MLX5_ST_SZ_DW(destroy_rq_out)];
@@ -73,7 +73,7 @@ void mlx5_destroy_rq(struct mlx5_core_dev *dev, u32 rqn)
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
 
-int mlx5_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *sqn)
+int mlx5_core_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *sqn)
 {
 	u32 out[MLX5_ST_SZ_DW(create_sq_out)];
 	int err;
@@ -88,7 +88,7 @@ int mlx5_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *sqn)
 	return err;
 }
 
-int mlx5_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen)
+int mlx5_core_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen)
 {
 	u32 out[MLX5_ST_SZ_DW(modify_sq_out)];
 
@@ -99,7 +99,7 @@ int mlx5_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen)
 	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
 }
 
-void mlx5_destroy_sq(struct mlx5_core_dev *dev, u32 sqn)
+void mlx5_core_destroy_sq(struct mlx5_core_dev *dev, u32 sqn)
 {
 	u32 in[MLX5_ST_SZ_DW(destroy_sq_in)];
 	u32 out[MLX5_ST_SZ_DW(destroy_sq_out)];
@@ -112,7 +112,8 @@ void mlx5_destroy_sq(struct mlx5_core_dev *dev, u32 sqn)
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
 
-int mlx5_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tirn)
+int mlx5_core_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen,
+			 u32 *tirn)
 {
 	u32 out[MLX5_ST_SZ_DW(create_tir_out)];
 	int err;
@@ -127,7 +128,7 @@ int mlx5_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tirn)
 	return err;
 }
 
-void mlx5_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
+void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
 {
 	u32 in[MLX5_ST_SZ_DW(destroy_tir_out)];
 	u32 out[MLX5_ST_SZ_DW(destroy_tir_out)];
@@ -140,7 +141,8 @@ void mlx5_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
 
-int mlx5_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tisn)
+int mlx5_core_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen,
+			 u32 *tisn)
 {
 	u32 out[MLX5_ST_SZ_DW(create_tis_out)];
 	int err;
@@ -155,7 +157,7 @@ int mlx5_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tisn)
 	return err;
 }
 
-void mlx5_destroy_tis(struct mlx5_core_dev *dev, u32 tisn)
+void mlx5_core_destroy_tis(struct mlx5_core_dev *dev, u32 tisn)
 {
 	u32 in[MLX5_ST_SZ_DW(destroy_tis_out)];
 	u32 out[MLX5_ST_SZ_DW(destroy_tis_out)];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
index 1bc898c..b71d77f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
@@ -33,15 +33,19 @@
 #ifndef __TRANSOBJ_H__
 #define __TRANSOBJ_H__
 
-int mlx5_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn);
-int mlx5_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen);
-void mlx5_destroy_rq(struct mlx5_core_dev *dev, u32 rqn);
-int mlx5_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *sqn);
-int mlx5_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen);
-void mlx5_destroy_sq(struct mlx5_core_dev *dev, u32 sqn);
-int mlx5_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tirn);
-void mlx5_destroy_tir(struct mlx5_core_dev *dev, u32 tirn);
-int mlx5_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tisn);
-void mlx5_destroy_tis(struct mlx5_core_dev *dev, u32 tisn);
+int mlx5_core_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen,
+			u32 *rqn);
+int mlx5_core_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen);
+void mlx5_core_destroy_rq(struct mlx5_core_dev *dev, u32 rqn);
+int mlx5_core_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen,
+			u32 *sqn);
+int mlx5_core_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen);
+void mlx5_core_destroy_sq(struct mlx5_core_dev *dev, u32 sqn);
+int mlx5_core_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen,
+			 u32 *tirn);
+void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn);
+int mlx5_core_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen,
+			 u32 *tisn);
+void mlx5_core_destroy_tis(struct mlx5_core_dev *dev, u32 tisn);
 
 #endif /* __TRANSOBJ_H__ */
-- 
1.7.1
