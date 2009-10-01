From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 6/7] mlx4_en: performing CLOSE_PORT at the end of tear-down
 process
Date: Thu, 01 Oct 2009 16:34:08 +0200
Message-ID: <4AC4BDE0.2050400@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:48836 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756432AbZJALfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 07:35:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As required by ConnectX PRM.
Not doing it might cause races in the HW during tear down process. 

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 13fc6f0..b1e80d8 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -711,9 +711,8 @@ void mlx4_en_stop_port(struct net_device *dev)
 	netif_tx_stop_all_queues(dev);
 	netif_tx_unlock_bh(dev);
 
-	/* close port*/
+	/* Set port as not active */
 	priv->port_up = false;
-	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 
 	/* Unregister Mac address for the port */
 	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
@@ -738,6 +737,9 @@ void mlx4_en_stop_port(struct net_device *dev)
 			msleep(1);
 		mlx4_en_deactivate_cq(priv, &priv->rx_cq[i]);
 	}
+
+	/* close port*/
+	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 }
 
 static void mlx4_en_restart(struct work_struct *work)
-- 
1.6.1.3


