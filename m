From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 04/16] mlx4_en: bringing link up when registering netdevice
Date: Wed, 23 Mar 2011 10:37:41 +0200
Message-ID: <4D89B155.8010300@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:35704 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754513Ab1CWIho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:37:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index b1180dd..5727bf5 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1069,6 +1069,23 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	en_warn(priv, "Using %d TX rings\n", prof->tx_ring_num);
 	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
 
+	/* Configure port */
+	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
+				    MLX4_EN_MIN_MTU,
+				    0, 0, 0, 0);
+	if (err) {
+		en_err(priv, "Failed setting port general configurations "
+		       "for port %d, with error %d\n", priv->port, err);
+		goto out;
+	}
+
+	/* Init port */
+	en_warn(priv, "Initializing port\n");
+	err = mlx4_INIT_PORT(mdev->dev, priv->port);
+	if (err) {
+		en_err(priv, "Failed Initializing port\n");
+		goto out;
+	}
 	priv->registered = 1;
 	mlx4_en_set_default_moderation(priv);
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
-- 
1.6.0.2





