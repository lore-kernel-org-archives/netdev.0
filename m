From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 01/10] net/mlx4_en: Fix resource leak in error flow
Date: Tue, 25 Jun 2013 12:09:29 +0300
Message-ID: <1372151378-21468-2-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Dotan Barak <dotanb@dev.mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40733 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751777Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.com>

Wrong condition was used when calling iounmap.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index a5c9df0..a071cda 100644
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
1.7.1
