From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V3 5/9] net/mlx5e: Set drop RQ's necessary parameters only
Date: Wed,  2 Mar 2016 00:13:36 +0200
Message-ID: <1456870420-23655-6-git-send-email-saeedm@mellanox.com>
References: <1456870420-23655-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59505 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752193AbcCAWWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 17:22:09 -0500
In-Reply-To: <1456870420-23655-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

By its role, there is no need to set all the other parameters
for the drop RQ.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 013be09..30fd971 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1064,6 +1064,15 @@ static void mlx5e_build_rq_param(struct mlx5e_priv *priv,
 	param->wq.linear = 1;
 }
 
+static void mlx5e_build_drop_rq_param(struct mlx5e_rq_param *param)
+{
+	void *rqc = param->rqc;
+	void *wq = MLX5_ADDR_OF(rqc, rqc, wq);
+
+	MLX5_SET(wq, wq, wq_type, MLX5_WQ_TYPE_LINKED_LIST);
+	MLX5_SET(wq, wq, log_wq_stride,    ilog2(sizeof(struct mlx5e_rx_wqe)));
+}
+
 static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
 				 struct mlx5e_sq_param *param)
 {
@@ -1574,8 +1583,7 @@ static int mlx5e_open_drop_rq(struct mlx5e_priv *priv)
 
 	memset(&cq_param, 0, sizeof(cq_param));
 	memset(&rq_param, 0, sizeof(rq_param));
-	mlx5e_build_rx_cq_param(priv, &cq_param);
-	mlx5e_build_rq_param(priv, &rq_param);
+	mlx5e_build_drop_rq_param(&rq_param);
 
 	err = mlx5e_create_drop_cq(priv, cq, &cq_param);
 	if (err)
-- 
1.7.1
