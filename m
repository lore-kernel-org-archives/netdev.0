From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 03/10] net/mlx4_en: Move register_netdev() to the end of initialization function
Date: Tue, 25 Jun 2013 12:09:31 +0300
Message-ID: <1372151378-21468-4-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40736 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751907Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

To avoid a race between the open function and everything that happens after
register_netdev() move it to be the last operation called.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c0b02d7..1f0f817 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2323,6 +2323,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	mdev->pndev[port] = dev;
 
 	netif_carrier_off(dev);
+	mlx4_en_set_default_moderation(priv);
+
 	err = register_netdev(dev);
 	if (err) {
 		en_err(priv, "Netdev registration failed for port %d\n", port);
@@ -2354,7 +2356,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		en_err(priv, "Failed Initializing port\n");
 		goto out;
 	}
-	mlx4_en_set_default_moderation(priv);
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 
 	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
-- 
1.7.1
