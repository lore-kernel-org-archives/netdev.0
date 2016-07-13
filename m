From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Wed, 13 Jul 2016 13:08:25 +0300
Message-ID: <20160713100825.GD29468@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We accidentally return success when we had intended to return an error
code.

Fixes: 69697b6e2086 ('net/mlx5: E-Switch, Add support for the sriov offloads mode')
Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 1842dfb..7d982cf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -183,6 +183,7 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
 	if (!root_ns) {
+		err = -EINVAL;
 		esw_warn(dev, "Failed to get FDB flow namespace\n");
 		goto ns_err;
 	}
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
