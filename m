From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 12/13] net/mlx5e: Use ndo_stop explicitly at shutdown flow
Date: Fri, 10 Jun 2016 00:07:39 +0300
Message-ID: <1465506460-1854-13-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34555 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751016AbcFIVK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:10:29 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

The current implementation copies the flow of ndo_stop instead of
calling it explicitly, Fixed it.

Fixes: 5fc7197d3a25 ("net/mlx5: Add pci shutdown callback")
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index fd43929..f5c8d5d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3192,10 +3192,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	flush_workqueue(priv->wq);
 	if (test_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &mdev->intf_state)) {
 		netif_device_detach(netdev);
-		mutex_lock(&priv->state_lock);
-		if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-			mlx5e_close_locked(netdev);
-		mutex_unlock(&priv->state_lock);
+		mlx5e_close(netdev);
 	} else {
 		unregister_netdev(netdev);
 	}
-- 
2.8.0
