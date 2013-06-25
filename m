From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 04/10] net/mlx4_en: Change log level from error to debug for vlan related messages
Date: Tue, 25 Jun 2013 12:09:32 +0300
Message-ID: <1372151378-21468-5-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
	Aviad Yehezkel <aviadye@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52115 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751738Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

The port vlan table size is 126 (used for IBoE) so after 126 we will
not have space and the user need to see it only in debug print and not
error.

Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 1f0f817..f256a73 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -405,7 +405,7 @@ static int mlx4_en_vlan_rx_add_vid(struct net_device *dev,
 			en_err(priv, "Failed configuring VLAN filter\n");
 	}
 	if (mlx4_register_vlan(mdev->dev, priv->port, vid, &idx))
-		en_err(priv, "failed adding vlan %d\n", vid);
+		en_dbg(HW, priv, "failed adding vlan %d\n", vid);
 	mutex_unlock(&mdev->state_lock);
 
 	return 0;
@@ -428,7 +428,7 @@ static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev,
 	if (!mlx4_find_cached_vlan(mdev->dev, priv->port, vid, &idx))
 		mlx4_unregister_vlan(mdev->dev, priv->port, idx);
 	else
-		en_err(priv, "could not find vid %d in cache\n", vid);
+		en_dbg(HW, priv, "could not find vid %d in cache\n", vid);
 
 	if (mdev->device_up && priv->port_up) {
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
-- 
1.7.1
