From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 02/12] net/mlx5: Always Query HCA caps after setting them
Date: Tue, 25 Oct 2016 18:36:25 +0300
Message-ID: <1477409795-28807-3-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40907 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751302AbcJYPiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:20 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Always query the HCA caps after setting them to update the capablities
data structures. Not doing so results in incorrect capabilities being
reported including max_dc, max_qp and several others.

Fixes: 59211bd3b632 ("net/mlx5: Split the load/unload flow into hardware
and software flows")
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index d9c3c70..8a63910 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -844,12 +844,6 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	struct pci_dev *pdev = dev->pdev;
 	int err;
 
-	err = mlx5_query_hca_caps(dev);
-	if (err) {
-		dev_err(&pdev->dev, "query hca failed\n");
-		goto out;
-	}
-
 	err = mlx5_query_board_id(dev);
 	if (err) {
 		dev_err(&pdev->dev, "query board id failed\n");
@@ -1023,6 +1017,12 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 
 	mlx5_start_health_poll(dev);
 
+	err = mlx5_query_hca_caps(dev);
+	if (err) {
+		dev_err(&pdev->dev, "query hca failed\n");
+		goto err_stop_poll;
+	}
+
 	if (boot && mlx5_init_once(dev, priv)) {
 		dev_err(&pdev->dev, "sw objs init failed\n");
 		goto err_stop_poll;
-- 
2.7.4
