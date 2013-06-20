From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 01/11] net/mlx4_en: Suppress page allocation failure warnings
Date: Thu, 20 Jun 2013 22:40:12 +0300
Message-ID: <1371757222-21412-2-git-send-email-amirv@mellanox.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38514 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030253Ab3FTTkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:40:41 -0400
In-Reply-To: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.com>

When system is low on resources, those warnings hang the host.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 9c57581..2b564ac 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -57,8 +57,8 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 	for (i = 0; i < priv->num_frags; i++) {
 		frag_info = &priv->frag_info[i];
 		if (ring_alloc[i].offset == frag_info->last_offset) {
-			page = alloc_pages(GFP_ATOMIC | __GFP_COMP,
-					MLX4_EN_ALLOC_ORDER);
+			page = alloc_pages(GFP_ATOMIC | __GFP_COMP |
+					   __GFP_NOWARN, MLX4_EN_ALLOC_ORDER);
 			if (!page)
 				goto out;
 			dma = dma_map_page(priv->ddev, page, 0,
-- 
1.8.3.251.g1462b67
