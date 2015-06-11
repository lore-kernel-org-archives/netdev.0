From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] net/mlx5_core: fix an error code
Date: Thu, 11 Jun 2015 11:50:01 +0300
Message-ID: <20150611085001.GB27393@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>, Amir Vadai <amirv@mellanox.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We return success if mlx5e_alloc_sq_db() fails but we should return an
error code.

Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support ConnectX-4 Ethernet functionality')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7348c51..075e517 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -525,7 +525,8 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	sq->uar_map     = sq->uar.map;
 	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
 
-	if (mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu)))
+	err = mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu));
+	if (err)
 		goto err_sq_wq_destroy;
 
 	sq->txq = netdev_get_tx_queue(priv->netdev,
