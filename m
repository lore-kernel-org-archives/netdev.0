From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 02/16]  mlx4_en: moderation parameters are not reseted.
Date: Wed, 23 Mar 2011 10:37:28 +0200
Message-ID: <4D89B148.4090102@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:35684 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753440Ab1CWIhb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:37:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of reseting the module parameters each ifup or mtu change,
they are being set once at device initialization
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 897f576..56627c2 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -801,7 +801,6 @@ static int mlx4_en_open(struct net_device *dev)
 		priv->rx_ring[i].packets = 0;
 	}
 
-	mlx4_en_set_default_moderation(priv);
 	err = mlx4_en_start_port(dev);
 	if (err)
 		en_err(priv, "Failed starting port:%d\n", priv->port);
@@ -932,7 +931,6 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 			en_dbg(DRV, priv, "Change MTU called with card down!?\n");
 		} else {
 			mlx4_en_stop_port(dev);
-			mlx4_en_set_default_moderation(priv);
 			err = mlx4_en_start_port(dev);
 			if (err) {
 				en_err(priv, "Failed restarting port:%d\n",
@@ -1080,6 +1078,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
 
 	priv->registered = 1;
+	mlx4_en_set_default_moderation(priv);
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 	return 0;
 
-- 
1.6.0.2





