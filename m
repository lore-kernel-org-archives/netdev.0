From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 4/4] net/mlx4_en: Set statistics bitmap at port init
Date: Wed, 18 Mar 2015 16:51:38 +0200
Message-ID: <1426690298-10567-5-git-send-email-ogerlitz@mellanox.com>
References: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49389 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754862AbbCROv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 10:51:57 -0400
In-Reply-To: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Port statistics bitmap will now be initialized at port init.  Even before
starting the port, statistics are visible to the user and must be properly masked.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2a210c4..ebce5bb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1698,8 +1698,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	/* Schedule multicast task to populate multicast list */
 	queue_work(mdev->workqueue, &priv->rx_mode_task);
 
-	mlx4_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
-
 #ifdef CONFIG_MLX4_EN_VXLAN
 	if (priv->mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		vxlan_get_rx_port(dev);
@@ -2853,6 +2851,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		queue_delayed_work(mdev->workqueue, &priv->service_task,
 				   SERVICE_TASK_DELAY);
 
+	mlx4_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
+
 	return 0;
 
 out:
-- 
1.7.1
