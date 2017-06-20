From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/10] net/mlx5e: Prevent PFC call for non ethernet ports
Date: Tue, 20 Jun 2017 17:13:06 +0300
Message-ID: <20170620141314.25620-3-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Feras Daoud <ferasda@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42041 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751144AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feras Daoud <ferasda@mellanox.com>

Port flow control supported only for ethernet ports,
therefore, prevent any call if the port type differs from
MLX5_CAP_PORT_TYPE_ETH.

Signed-off-by: Feras Daoud <ferasda@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 216752070391..7408c298ce2f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -135,6 +135,9 @@ static unsigned long mlx5e_query_pfc_combined(struct mlx5e_priv *priv)
 	u8 pfc_en_rx;
 	int err;
 
+	if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+		return 0;
+
 	err = mlx5_query_port_pfc(mdev, &pfc_en_tx, &pfc_en_rx);
 
 	return err ? 0 : pfc_en_tx | pfc_en_rx;
@@ -147,6 +150,9 @@ static bool mlx5e_query_global_pause_combined(struct mlx5e_priv *priv)
 	u32 tx_pause;
 	int err;
 
+	if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+		return false;
+
 	err = mlx5_query_port_pause(mdev, &rx_pause, &tx_pause);
 
 	return err ? false : rx_pause | tx_pause;
-- 
2.11.0
