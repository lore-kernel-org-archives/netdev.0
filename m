From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 7/7] net/mlx4_en: Initialize RFS filters lock and list in init_netdev
Date: Wed, 16 Jan 2013 17:42:15 +0200
Message-ID: <1358350935-3281-8-git-send-email-amirv@mellanox.com>
References: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:57635 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755728Ab3APPnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 10:43:03 -0500
In-Reply-To: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

filters_lock might have been used while it was re-initialized.
Moved filters_lock and filters_list initialization to init_netdev instead of
alloc_resources which is called every time the device is configured.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 108c4cf..f297d4c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1455,9 +1455,6 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 	priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->rx_ring_num);
 	if (!priv->dev->rx_cpu_rmap)
 		goto err;
-
-	INIT_LIST_HEAD(&priv->filters);
-	spin_lock_init(&priv->filters_lock);
 #endif
 
 	return 0;
@@ -1652,6 +1649,11 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (err)
 		goto out;
 
+#ifdef CONFIG_RFS_ACCEL
+	INIT_LIST_HEAD(&priv->filters);
+	spin_lock_init(&priv->filters_lock);
+#endif
+
 	/* Allocate page for receive rings */
 	err = mlx4_alloc_hwq_res(mdev->dev, &priv->res,
 				MLX4_EN_PAGE_SIZE, MLX4_EN_PAGE_SIZE);
-- 
1.7.8.2
