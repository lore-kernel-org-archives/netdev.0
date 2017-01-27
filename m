From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 3/8] net/mlx5: E-Switch, Err when retrieving steering name-space fails
Date: Fri, 27 Jan 2017 22:38:38 +0200
Message-ID: <20170127203843.3206-4-saeedm@mellanox.com>
References: <20170127203843.3206-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33321 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751054AbdA0VL0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:11:26 -0500
In-Reply-To: <20170127203843.3206-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Make sure to return error when we failed retrieving the FDB steering
name space. Also, while around, correctly print the error when mode
change revert fails in the warning message.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 5803216157cf..c61bca138e65 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -424,6 +424,7 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
 	if (!root_ns) {
 		esw_warn(dev, "Failed to get FDB flow namespace\n");
+		err = -EOPNOTSUPP;
 		goto ns_err;
 	}
 
@@ -655,7 +656,7 @@ static int esw_offloads_start(struct mlx5_eswitch *esw)
 		esw_warn(esw->dev, "Failed setting eswitch to offloads, err %d\n", err);
 		err1 = mlx5_eswitch_enable_sriov(esw, num_vfs, SRIOV_LEGACY);
 		if (err1)
-			esw_warn(esw->dev, "Failed setting eswitch back to legacy, err %d\n", err);
+			esw_warn(esw->dev, "Failed setting eswitch back to legacy, err %d\n", err1);
 	}
 	if (esw->offloads.inline_mode == MLX5_INLINE_MODE_NONE) {
 		if (mlx5_eswitch_inline_mode_get(esw,
-- 
2.11.0
