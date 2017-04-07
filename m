From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 7/7] net/mlx5e: Set default RX moderation parameters on driver load
Date: Fri,  7 Apr 2017 21:26:56 +0300
Message-ID: <20170407182656.6734-8-saeedm@mellanox.com>
References: <20170407182656.6734-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47254 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756102AbdDGS1U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:27:20 -0400
In-Reply-To: <20170407182656.6734-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX moderation default parameters shouldn't be set in
mlx5e_build_rx_cq_param since it would reset the values every time on
netdev open/close.  Instead, it should be set in
mlx5e_set_rx_cq_mode_params which is called on driver load only.

Fixes: 6a9764efb255 ("net/mlx5e: Isolate open_channels from priv->params")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 57844ffca37f..8b7b7e604ea0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1944,10 +1944,6 @@ static void mlx5e_build_rx_cq_param(struct mlx5e_priv *priv,
 	}
 
 	mlx5e_build_common_cq_param(priv, param);
-
-	if (params->rx_am_enabled)
-		params->rx_cq_moderation =
-			mlx5e_am_get_def_profile(params->rx_cq_period_mode);
 }
 
 static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
@@ -3787,6 +3783,10 @@ void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params, u8 cq_period_mode)
 		params->rx_cq_moderation.usec =
 			MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE;
 
+	if (params->rx_am_enabled)
+		params->rx_cq_moderation =
+			mlx5e_am_get_def_profile(params->rx_cq_period_mode);
+
 	MLX5E_SET_PFLAG(params, MLX5E_PFLAG_RX_CQE_BASED_MODER,
 			params->rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
 }
-- 
2.11.0
