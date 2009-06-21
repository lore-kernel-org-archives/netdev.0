From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 3/6] mlx4_en: using stop/start_all_queues
Date: Sun, 21 Jun 2009 11:15:46 +0300
Message-ID: <4A3DEC32.7040702@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:51503 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753261AbZFUHZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 03:25:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After we moved to be a multi queue device, need to stop/start
all of our transmit queues.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index e02bafd..20a34cb 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -668,7 +668,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	queue_work(mdev->workqueue, &priv->mcast_task);
 
 	priv->port_up = true;
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 	return 0;
 
 mac_err:
@@ -700,7 +700,7 @@ void mlx4_en_stop_port(struct net_device *dev)
 		en_dbg(DRV, priv, "stop port called while port already down\n");
 		return;
 	}
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 
 	/* Synchronize with tx routine */
 	netif_tx_lock_bh(dev);
-- 
1.6.0

