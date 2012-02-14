From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 3/7] mlx4: remove unused field high_prios
Date: Tue, 14 Feb 2012 18:37:41 +0200
Message-ID: <4F3A8DD5.6090106@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:35555 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756448Ab2BNQll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 11:41:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

Remove unnecessary field high_prios from mlx4_steer struct and initialization

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    4 +---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    1 -
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 678558b..0809b7c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1543,13 +1543,11 @@ static int mlx4_init_steering(struct mlx4_dev *dev)
 	if (!priv->steer)
 		return -ENOMEM;
 
-	for (i = 0; i < num_entries; i++) {
+	for (i = 0; i < num_entries; i++)
 		for (j = 0; j < MLX4_NUM_STEERS; j++) {
 			INIT_LIST_HEAD(&priv->steer[i].promisc_qps[j]);
 			INIT_LIST_HEAD(&priv->steer[i].steer_entries[j]);
 		}
-		INIT_LIST_HEAD(&priv->steer[i].high_prios);
-	}
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index c92269f..276c7f7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -703,7 +703,6 @@ struct mlx4_msix_ctl {
 struct mlx4_steer {
 	struct list_head promisc_qps[MLX4_NUM_STEERS];
 	struct list_head steer_entries[MLX4_NUM_STEERS];
-	struct list_head high_prios;
 };
 
 struct mlx4_priv {
-- 
1.5.4.3
