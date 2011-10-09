From: Alexander Guller <alexg@mellanox.com>
Subject: [PATCH 6/7] mlx4_en: Fix crash upon device initialization error
Date: Sun, 9 Oct 2011 17:29:35 +0200
Message-ID: <4E91BDDF.6060600@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexg@mellanox.com>,
	<yevgenyp@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53780 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751240Ab1JIP3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 11:29:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netdevice was being freed without being unregistered first if
mlx4_SET_PORT_general or mlx4_INIT_PORT failed.

Signed-off-by: Alexander Guller <alexg@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b82db4a..c4c4be4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1097,6 +1097,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		en_err(priv, "Netdev registration failed for port %d\n", port);
 		goto out;
 	}
+	priv->registered = 1;
 
 	en_warn(priv, "Using %d TX rings\n", prof->tx_ring_num);
 	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
@@ -1118,7 +1119,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		en_err(priv, "Failed Initializing port\n");
 		goto out;
 	}
-	priv->registered = 1;
 	mlx4_en_set_default_moderation(priv);
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 	return 0;
-- 
1.7.5.4
