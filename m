From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_en: Remove dependency between timestamping capability and service_task
Date: Thu, 17 Dec 2015 15:35:37 +0200
Message-ID: <1450359338-32220-2-git-send-email-ogerlitz@mellanox.com>
References: <a>
 <1450359338-32220-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36158 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752270AbbLQNgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 08:36:06 -0500
In-Reply-To: <1450359338-32220-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Service task is responsible for other tasks in addition to timestamping
overflow check. Launch it even if timestamping is not supported by device.

Fixes: 07841f9d94c1 ('net/mlx4_en: Schedule napi when RX buffers allocation fails')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 886e1bc..4eef316 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -3058,9 +3058,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 
-	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
-		queue_delayed_work(mdev->workqueue, &priv->service_task,
-				   SERVICE_TASK_DELAY);
+	queue_delayed_work(mdev->workqueue, &priv->service_task,
+			   SERVICE_TASK_DELAY);
 
 	mlx4_en_set_stats_bitmap(mdev->dev, &priv->stats_bitmap,
 				 mdev->profile.prof[priv->port].rx_ppp,
-- 
2.3.7
