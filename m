From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 02/10] net/mlx5e: Placement changed for carrier state updates
Date: Thu, 25 Feb 2016 18:33:12 +0200
Message-ID: <1456418000-18898-3-git-send-email-saeedm@mellanox.com>
References: <1456418000-18898-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57320 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933163AbcBYQey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 11:34:54 -0500
In-Reply-To: <1456418000-18898-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

More proper to declare carrier state UP only after the channels
are ready for traffic.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 38944b8..013be09 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1451,8 +1451,8 @@ int mlx5e_open_locked(struct net_device *netdev)
 		goto err_close_channels;
 	}
 
-	mlx5e_update_carrier(priv);
 	mlx5e_redirect_rqts(priv);
+	mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
 
 	schedule_delayed_work(&priv->update_stats_work, 0);
@@ -1491,8 +1491,8 @@ int mlx5e_close_locked(struct net_device *netdev)
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 
 	mlx5e_timestamp_cleanup(priv);
-	mlx5e_redirect_rqts(priv);
 	netif_carrier_off(priv->netdev);
+	mlx5e_redirect_rqts(priv);
 	mlx5e_close_channels(priv);
 
 	return 0;
-- 
1.7.1
