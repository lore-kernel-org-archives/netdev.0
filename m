From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/7] net/mlx5e: Check for BlueFlame capability before allocating SQ uar
Date: Mon, 27 Jun 2016 12:08:35 +0300
Message-ID: <1467018518-11630-5-git-send-email-saeedm@mellanox.com>
References: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53212 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751886AbcF0JQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:16:15 -0400
In-Reply-To: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Previous to this patch mapping was always set to write combining without
checking whether BlueFlame is supported in the device.

Fixes: 0ba422410bbf ('net/mlx5: Fix global UAR mapping')
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 4383f8c..793d7a1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -580,7 +580,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	void *sqc_wq = MLX5_ADDR_OF(sqc, sqc, wq);
 	int err;
 
-	err = mlx5_alloc_map_uar(mdev, &sq->uar, true);
+	err = mlx5_alloc_map_uar(mdev, &sq->uar, !!MLX5_CAP_GEN(mdev, bf));
 	if (err)
 		return err;
 
-- 
2.8.0
