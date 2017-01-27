From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 8/8] net/mlx5e: Check ets capability before ets query FW command
Date: Fri, 27 Jan 2017 22:38:43 +0200
Message-ID: <20170127203843.3206-9-saeedm@mellanox.com>
References: <20170127203843.3206-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Moshe Shemesh <moshe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58011 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750933AbdA0UxV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:53:21 -0500
In-Reply-To: <20170127203843.3206-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

On dcbnl callback getpgtccfgtx, the driver should check the ets
capability before ets query command is sent to firmware.
It is valid to return from this void function without changing in/out
parameters, as these parameters are initialized to
DCB_ATTR_VALUE_UNDEFINED.

Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 35f9ae037ba0..0523ed47f597 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -511,6 +511,11 @@ static void mlx5e_dcbnl_getpgtccfgtx(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
+	if (!MLX5_CAP_GEN(priv->mdev, ets)) {
+		netdev_err(netdev, "%s, ets is not supported\n", __func__);
+		return;
+	}
+
 	if (priority >= CEE_DCBX_MAX_PRIO) {
 		netdev_err(netdev,
 			   "%s, priority is out of range\n", __func__);
-- 
2.11.0
