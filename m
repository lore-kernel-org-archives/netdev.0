From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 3/5] net/mlx5e: remove IEEE/CEE mode check when setting DCBX mode
Date: Fri, 10 Mar 2017 14:33:03 +0200
Message-ID: <20170310123305.2185-4-saeedm@mellanox.com>
References: <20170310123305.2185-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38696 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S937257AbdCJMdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 07:33:32 -0500
In-Reply-To: <20170310123305.2185-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Currently, the function setdcbx fails if the request dcbx mode
is either IEEE or CEE. We remove the IEEE/CEE mode check because
we support both IEEE and CEE interfaces.

Fixes: 3a6a931dfb8e ("net/mlx5e: Support DCBX CEE API")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 0523ed47f597..8fa23f6a1f67 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -302,6 +302,9 @@ static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5e_dcbx *dcbx = &priv->dcbx;
 
+	if (mode & DCB_CAP_DCBX_LLD_MANAGED)
+		return 1;
+
 	if ((!mode) && MLX5_CAP_GEN(priv->mdev, dcbx)) {
 		if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_AUTO)
 			return 0;
@@ -315,13 +318,10 @@ static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 		return 1;
 	}
 
-	if (mlx5e_dcbnl_switch_to_host_mode(netdev_priv(dev)))
+	if (!(mode & DCB_CAP_DCBX_HOST))
 		return 1;
 
-	if ((mode & DCB_CAP_DCBX_LLD_MANAGED) ||
-	    !(mode & DCB_CAP_DCBX_VER_CEE) ||
-	    !(mode & DCB_CAP_DCBX_VER_IEEE) ||
-	    !(mode & DCB_CAP_DCBX_HOST))
+	if (mlx5e_dcbnl_switch_to_host_mode(netdev_priv(dev)))
 		return 1;
 
 	return 0;
-- 
2.11.0
