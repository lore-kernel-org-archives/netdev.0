From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 6/8] net/mlx5e: Do not use netdev_err() before the netdev is registered
Date: Wed, 29 Jul 2015 15:05:44 +0300
Message-ID: <1438171546-17021-7-git-send-email-amirv@mellanox.com>
References: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53845 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752438AbbG2MGp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:06:45 -0400
In-Reply-To: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Since it is un-named at this time.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5504910..6581f58 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1893,36 +1893,31 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 
 	err = mlx5_alloc_map_uar(mdev, &priv->cq_uar);
 	if (err) {
-		netdev_err(netdev, "%s: mlx5_alloc_map_uar failed, %d\n",
-			   __func__, err);
+		mlx5_core_err(mdev, "alloc_map uar failed, %d\n", err);
 		goto err_free_netdev;
 	}
 
 	err = mlx5_core_alloc_pd(mdev, &priv->pdn);
 	if (err) {
-		netdev_err(netdev, "%s: mlx5_core_alloc_pd failed, %d\n",
-			   __func__, err);
+		mlx5_core_err(mdev, "alloc pd failed, %d\n", err);
 		goto err_unmap_free_uar;
 	}
 
 	err = mlx5_alloc_transport_domain(mdev, &priv->tdn);
 	if (err) {
-		netdev_err(netdev, "%s: mlx5_alloc_transport_domain failed, %d\n",
-			   __func__, err);
+		mlx5_core_err(mdev, "alloc td failed, %d\n", err);
 		goto err_dealloc_pd;
 	}
 
 	err = mlx5e_create_mkey(priv, priv->pdn, &priv->mr);
 	if (err) {
-		netdev_err(netdev, "%s: mlx5e_create_mkey failed, %d\n",
-			   __func__, err);
+		mlx5_core_err(mdev, "create mkey failed, %d\n", err);
 		goto err_dealloc_transport_domain;
 	}
 
 	err = register_netdev(netdev);
 	if (err) {
-		netdev_err(netdev, "%s: register_netdev failed, %d\n",
-			   __func__, err);
+		mlx5_core_err(mdev, "register_netdev failed, %d\n", err);
 		goto err_destroy_mkey;
 	}
 
-- 
2.4.3.413.ga5fe668
