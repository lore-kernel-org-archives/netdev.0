From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 02/11] net/mlx4_en: Fix resource leak in error flow
Date: Thu, 20 Jun 2013 22:40:13 +0300
Message-ID: <1371757222-21412-3-git-send-email-amirv@mellanox.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Dotan Barak <dotanb@dev.mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48206 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030251Ab3FTTkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:40:41 -0400
In-Reply-To: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.com>

Wrong condition was used when calling iounmap.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index a5c9df07..a071cda 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -310,7 +310,7 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 err_mr:
 	(void) mlx4_mr_free(dev, &mdev->mr);
 err_map:
-	if (!mdev->uar_map)
+	if (mdev->uar_map)
 		iounmap(mdev->uar_map);
 err_uar:
 	mlx4_uar_free(dev, &mdev->priv_uar);
-- 
1.8.3.251.g1462b67
