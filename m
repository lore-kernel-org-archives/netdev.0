From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 13/13] net/mlx5e: Log link state changes
Date: Thu, 30 Jun 2016 17:34:50 +0300
Message-ID: <1467297290-11443-14-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Shaker Daibes <shakerd@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37710 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752482AbcF3OhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:23 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

Add Link UP/Down prints to kernel log when link state changes

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 216fe3e..7a0dca2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -81,10 +81,13 @@ static void mlx5e_update_carrier(struct mlx5e_priv *priv)
 	port_state = mlx5_query_vport_state(mdev,
 		MLX5_QUERY_VPORT_STATE_IN_OP_MOD_VNIC_VPORT, 0);
 
-	if (port_state == VPORT_STATE_UP)
+	if (port_state == VPORT_STATE_UP) {
+		netdev_info(priv->netdev, "Link up\n");
 		netif_carrier_on(priv->netdev);
-	else
+	} else {
+		netdev_info(priv->netdev, "Link down\n");
 		netif_carrier_off(priv->netdev);
+	}
 }
 
 static void mlx5e_update_carrier_work(struct work_struct *work)
-- 
2.8.0
