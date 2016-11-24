From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch] net/mlx5: remove a duplicate condition
Date: Thu, 24 Nov 2016 14:03:45 +0300
Message-ID: <20161124110345.GC17225@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We verified that MLX5_FLOW_CONTEXT_ACTION_COUNT was set on the first
line of the function so we don't need to check again here.

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
Not a bugfix so it would go into -next

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 68ec4ea..a263d89 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1307,8 +1307,7 @@ static bool counter_is_valid(struct mlx5_fc *counter, u32 action)
 		return false;
 
 	return (action & (MLX5_FLOW_CONTEXT_ACTION_DROP |
-			  MLX5_FLOW_CONTEXT_ACTION_FWD_DEST)) &&
-		(action & MLX5_FLOW_CONTEXT_ACTION_COUNT);
+			  MLX5_FLOW_CONTEXT_ACTION_FWD_DEST));
 }
 
 static bool dest_is_valid(struct mlx5_flow_destination *dest,
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
