From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 04/14] mlx4_en: performing CLOSE_PORT at the end of
	tear-down process
Date: Tue, 24 Aug 2010 16:45:45 +0300
Message-ID: <4C73CD09.8090705@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50062 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755151Ab0HXNps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:45:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All port's resources should be closed before we give the
CLOSE_PORT command to the firmware.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index c4ab0fc..068e572 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -704,9 +704,8 @@ void mlx4_en_stop_port(struct net_device *dev)
 	netif_tx_stop_all_queues(dev);
 	netif_tx_unlock_bh(dev);
 
-	/* close port*/
+	/* Set port as not active */
 	priv->port_up = false;
-	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 
 	/* Unregister Mac address for the port */
 	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
@@ -731,6 +730,9 @@ void mlx4_en_stop_port(struct net_device *dev)
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


