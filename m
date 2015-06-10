From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 01/13] net/mlx4_core: Check before cleaning counters bitmap
Date: Wed, 10 Jun 2015 17:59:26 +0300
Message-ID: <1433948378-17570-2-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37754 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933500AbbFJPAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:00:07 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

If counters are not supported by the device. The indices bitmap table is not
allocated during initialization. Add the symmetrical check before cleaning
the counters bitmap table or freeing a counter.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 0dbd704..f95466f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2204,6 +2204,9 @@ static int mlx4_init_counters_table(struct mlx4_dev *dev)
 
 static void mlx4_cleanup_counters_table(struct mlx4_dev *dev)
 {
+	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_COUNTERS))
+		return;
+
 	mlx4_bitmap_cleanup(&mlx4_priv(dev)->counters_bitmap);
 }
 
@@ -2241,6 +2244,9 @@ EXPORT_SYMBOL_GPL(mlx4_counter_alloc);
 
 void __mlx4_counter_free(struct mlx4_dev *dev, u32 idx)
 {
+	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_COUNTERS))
+		return;
+
 	mlx4_bitmap_free(&mlx4_priv(dev)->counters_bitmap, idx, MLX4_USE_RR);
 	return;
 }
-- 
1.7.1
