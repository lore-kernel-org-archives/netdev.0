From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/6] net/mlx4_en: Do not disable vlan filter during promiscuous mode
Date: Tue,  8 Jul 2014 11:25:22 +0300
Message-ID: <1404807924-29038-5-git-send-email-amirv@mellanox.com>
References: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Aviad Yehezkel <aviadye@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44693 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753598AbaGHI0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 04:26:33 -0400
In-Reply-To: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Promiscous mode is only for MACs.
Should not disable/enable VLAN filter when entering/leaving promisuous mode.


Signed-off-by: Aviad Yehezkel <aviadye@mellanox.co.il>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 7d4fb7b..255950a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -940,11 +940,6 @@ static void mlx4_en_set_promisc_mode(struct mlx4_en_priv *priv,
 					  0, MLX4_MCAST_DISABLE);
 		if (err)
 			en_err(priv, "Failed disabling multicast filter\n");
-
-		/* Disable port VLAN filter */
-		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
-		if (err)
-			en_err(priv, "Failed disabling VLAN filter\n");
 	}
 }
 
@@ -993,11 +988,6 @@ static void mlx4_en_clear_promisc_mode(struct mlx4_en_priv *priv,
 			en_err(priv, "Failed disabling promiscuous mode\n");
 		break;
 	}
-
-	/* Enable port VLAN filter */
-	err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
-	if (err)
-		en_err(priv, "Failed enabling VLAN filter\n");
 }
 
 static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
-- 
1.8.3.4
