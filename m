From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Fixed crash when port type is changed
Date: Thu,  7 Nov 2013 11:08:30 +0200
Message-ID: <1383815310-19116-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39644 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752251Ab3KGJIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 04:08:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

timecounter_init() was was called only after first potential
timecounter_read().
Moved mlx4_en_init_timestamp() before mlx4_en_init_netdev()

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
Please pull into -stable for kernels >= 3.10

 drivers/net/ethernet/mellanox/mlx4/en_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index a071cda..0d087b0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -264,6 +264,10 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH)
 		mdev->port_cnt++;
 
+	/* Initialize time stamp mechanism */
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
+		mlx4_en_init_timestamp(mdev);
+
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
 		if (!dev->caps.comp_pool) {
 			mdev->profile.prof[i].rx_ring_num =
@@ -301,10 +305,6 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 			mdev->pndev[i] = NULL;
 	}
 
-	/* Initialize time stamp mechanism */
-	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
-		mlx4_en_init_timestamp(mdev);
-
 	return mdev;
 
 err_mr:
-- 
1.8.3.4
