From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 01/11] net/mlx5e: Check for qos capability in dcbnl_initialize
Date: Thu, 31 Aug 2017 01:21:00 +0300
Message-ID: <20170830222110.15737-2-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53212 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750851AbdH3WVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:32 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

qos capability is the master capability bit that determines
if the DCBX is supported for the PCI function. If this bit is off,
driver cannot run any dcbx code.

Fixes: e207b7e99176 ("net/mlx5e: ConnectX-4 firmware support for DCBX")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Reviewed-by: Parav Pandit <parav@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 2eb54d36e16e..810b51029c7f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -754,6 +754,9 @@ void mlx5e_dcbnl_initialize(struct mlx5e_priv *priv)
 {
 	struct mlx5e_dcbx *dcbx = &priv->dcbx;
 
+	if (!MLX5_CAP_GEN(priv->mdev, qos))
+		return;
+
 	if (MLX5_CAP_GEN(priv->mdev, dcbx))
 		mlx5e_dcbnl_query_dcbx_mode(priv, &dcbx->mode);
 
-- 
2.13.0
