From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/15] net/mlx5_core: don't export static symbol
Date: Wed, 11 Mar 2015 17:56:25 +0100
Message-ID: <1426092997-30605-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1426092997-30605-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	daniel@iogearbox.net
To: Eli Cohen <eli@mellanox.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1426092997-30605-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

The semantic patch that fixes this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
type T;
identifier f;
@@

static T f (...) { ... }

@@
identifier r.f;
declarer name EXPORT_SYMBOL;
@@

-EXPORT_SYMBOL(f);
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |    1 -
 1 file changed, 1 deletion(-)

diff -u -p a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -697,7 +697,6 @@ err_dbg:
 	debugfs_remove(priv->dbg_root);
 	return err;
 }
-EXPORT_SYMBOL(mlx5_dev_init);
 
 static void mlx5_dev_cleanup(struct mlx5_core_dev *dev)
 {

