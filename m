From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 07/11] net/mlx4_en: Add prints when TX timeout occurs
Date: Thu, 20 Jun 2013 22:40:18 +0300
Message-ID: <1371757222-21412-8-git-send-email-amirv@mellanox.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38537 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030276Ab3FTTkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:40:45 -0400
In-Reply-To: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.com>

Debug prints when a TX timeout is detected

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f1dcddc..b91d577 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1236,10 +1236,21 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
+	int i;
 
 	if (netif_msg_timer(priv))
 		en_warn(priv, "Tx timeout called on port:%d\n", priv->port);
 
+	for (i = 0; i < priv->tx_ring_num; i++) {
+		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)))
+			continue;
+		en_info(priv, "TX timeout detected on queue: %d,\n"
+			"QP: 0x%x, CQ: 0x%x,\n"
+			"Cons index: 0x%x, Prod index: 0x%x\n", i,
+			priv->tx_ring[i].qpn, priv->tx_ring[i].cqn,
+			priv->tx_ring[i].cons, priv->tx_ring[i].prod);
+	}
+
 	priv->port_stats.tx_timeout++;
 	en_dbg(DRV, priv, "Scheduling watchdog\n");
 	queue_work(mdev->workqueue, &priv->watchdog_task);
-- 
1.8.3.251.g1462b67
