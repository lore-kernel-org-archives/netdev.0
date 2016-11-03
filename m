From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 6/6] net/mlx5: Fix invalid pointer reference when prof_sel parameter is invalid
Date: Fri,  4 Nov 2016 01:48:47 +0200
Message-ID: <1478216927-31328-7-git-send-email-saeedm@mellanox.com>
References: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37678 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933612AbcKCXuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:50:13 -0400
In-Reply-To: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

When prof_sel is invalid, mlx5_core_warn is called but the
mlx5_core_dev is not initialized yet. Solution is moving the prof_sel code
after dev->pdev assignment

Fixes: 2974ab6e8bd8 ('net/mlx5: Improve driver log messages')
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index d5433c4..3eb9315 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1226,6 +1226,9 @@ static int init_one(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, dev);
 
+	dev->pdev = pdev;
+	dev->event = mlx5_core_event;
+
 	if (prof_sel < 0 || prof_sel >= ARRAY_SIZE(profile)) {
 		mlx5_core_warn(dev,
 			       "selected profile out of range, selecting default (%d)\n",
@@ -1233,8 +1236,6 @@ static int init_one(struct pci_dev *pdev,
 		prof_sel = MLX5_DEFAULT_PROF;
 	}
 	dev->profile = &profile[prof_sel];
-	dev->pdev = pdev;
-	dev->event = mlx5_core_event;
 
 	INIT_LIST_HEAD(&priv->ctx_list);
 	spin_lock_init(&priv->ctx_lock);
-- 
2.7.4
