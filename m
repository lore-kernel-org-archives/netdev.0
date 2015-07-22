From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 4/4] net/mlx4_en: Remove BUG_ON assert when checking if ring is full
Date: Wed, 22 Jul 2015 16:53:49 +0300
Message-ID: <1437573229-13127-5-git-send-email-ogerlitz@mellanox.com>
References: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Ido Shamay <idos@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54960 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965222AbbGVNyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 09:54:23 -0400
In-Reply-To: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

In mlx4_en_is_ring_empty we check if ring surpassed its size.
Since the prod and cons indicators are u32, there might be a state where
prod wrapped around and cons, making this assert false, although no
actual bug exists (other code segment can cope with this state).

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 7a4f20b..9c145dd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -246,7 +246,6 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 
 static inline bool mlx4_en_is_ring_empty(struct mlx4_en_rx_ring *ring)
 {
-	BUG_ON((u32)(ring->prod - ring->cons) > ring->actual_size);
 	return ring->prod == ring->cons;
 }
 
-- 
2.3.7
