From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 6/9] net/mlx4_en: Fix selftest failing on non 10G link speed
Date: Sun,  2 Mar 2014 10:25:02 +0200
Message-ID: <1393748705-1685-7-git-send-email-amirv@mellanox.com>
References: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52988 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751674AbaCBIZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2014 03:25:30 -0500
In-Reply-To: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Connect-X devices selftest speed test shouldn't fail on 1G and 40G link
speeds.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index c11d063..03e5f6a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -129,8 +129,10 @@ static int mlx4_en_test_speed(struct mlx4_en_priv *priv)
 	if (mlx4_en_QUERY_PORT(priv->mdev, priv->port))
 		return -ENOMEM;
 
-	/* The device currently only supports 10G speed */
-	if (priv->port_state.link_speed != SPEED_10000)
+	/* The device supports 1G, 10G and 40G speeds */
+	if (priv->port_state.link_speed != 1000 &&
+	    priv->port_state.link_speed != 10000 &&
+	    priv->port_state.link_speed != 40000)
 		return priv->port_state.link_speed;
 	return 0;
 }
-- 
1.8.3.4
