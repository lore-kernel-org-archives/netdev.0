From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 5/7] mlx4_en: Setting dev->perm_addr field
Date: Thu, 01 Oct 2009 16:34:03 +0200
Message-ID: <4AC4BDDB.30402@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:60247 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756430AbZJALfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 07:35:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 922ae1f..13fc6f0 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1030,9 +1030,10 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	/* Set defualt MAC */
 	dev->addr_len = ETH_ALEN;
-	for (i = 0; i < ETH_ALEN; i++)
-		dev->dev_addr[ETH_ALEN - 1 - i] =
-		(u8) (priv->mac >> (8 * i));
+	for (i = 0; i < ETH_ALEN; i++) {
+		dev->dev_addr[ETH_ALEN - 1 - i] = (u8) (priv->mac >> (8 * i));
+		dev->perm_addr[ETH_ALEN - 1 - i] = (u8) (priv->mac >> (8 * i));
+	}
 
 	/*
 	 * Set driver features
-- 
1.6.1.3


