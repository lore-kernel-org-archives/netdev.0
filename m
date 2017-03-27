From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/14] net/mlx5e: Set netdev->rx_cpu_rmap on netdev creation
Date: Mon, 27 Mar 2017 23:48:58 +0300
Message-ID: <20170327204910.20287-3-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44885 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752229AbdC0Ut5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:49:57 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To simplify mlx5e_open_locked flow we set netdev->rx_cpu_rmap on netdev
creation rather on netdev open, it is redundant to set it every time on
mlx5e_open_locked.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 469d6c147db7..f0eff5e30729 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2478,9 +2478,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 	mlx5e_redirect_rqts(priv);
 	mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
-#ifdef CONFIG_RFS_ACCEL
-	priv->netdev->rx_cpu_rmap = priv->mdev->rmap;
-#endif
+
 	if (priv->profile->update_stats)
 		queue_delayed_work(priv->wq, &priv->update_stats_work, 0);
 
@@ -4022,6 +4020,10 @@ struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 		return NULL;
 	}
 
+#ifdef CONFIG_RFS_ACCEL
+	netdev->rx_cpu_rmap = mdev->rmap;
+#endif
+
 	profile->init(mdev, netdev, profile, ppriv);
 
 	netif_carrier_off(netdev);
-- 
2.11.0
