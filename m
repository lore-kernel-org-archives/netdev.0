From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 13/13] net/mlx4_en: Report actual number of rings in indirection table
Date: Mon, 27 Oct 2014 11:37:47 +0200
Message-ID: <1414402667-8841-14-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40649 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752448AbaJ0Jiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:52 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware requires the number of rings in indirection table to be a power
of 2. When setting number of channels to a non power of 2 number,
indirection table is using only the closest power of 2 rings.
Report this number in 'ethtool -x' and not the total number of rx rings.


Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 144d6bd..8ea4d5b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -982,6 +982,7 @@ static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key)
 	int err = 0;
 
 	rss_rings = priv->prof->rss_rings ?: priv->rx_ring_num;
+	rss_rings = 1 << ilog2(rss_rings);
 
 	while (n--) {
 		ring_index[n] = rss_map->qps[n % rss_rings].qpn -
-- 
1.8.3.4
