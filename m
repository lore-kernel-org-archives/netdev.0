From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 6/6] net/mlx4_en: Initialize RFS filters lock and list in init_netdev
Date: Thu, 17 Jan 2013 13:47:21 +0200
Message-ID: <1358423241-2452-7-git-send-email-amirv@mellanox.com>
References: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:41823 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754976Ab3AQLrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 06:47:36 -0500
In-Reply-To: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
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
index 805e242..9c42812 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1454,9 +1454,6 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 	priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->rx_ring_num);
 	if (!priv->dev->rx_cpu_rmap)
 		goto err;
-
-	INIT_LIST_HEAD(&priv->filters);
-	spin_lock_init(&priv->filters_lock);
 #endif
 
 	return 0;
@@ -1651,6 +1648,11 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
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
