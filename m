From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 08/11] net/mlx5e: Don't add/remove 802.1ad rules when changing 802.1Q VLAN filter
Date: Thu, 28 Sep 2017 07:41:29 +0300
Message-ID: <20170928044132.30940-9-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54408 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751673AbdI1EmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:06 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Toggling of C-tag VLAN filter should not affect the "any S-tag" steering rule.

Fixes: 8a271746a264 ("net/mlx5e: Receive s-tagged packets in promiscuous mode")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index f11fd07ac4dd..850cdc980ab5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -291,7 +291,7 @@ void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv)
 	priv->fs.vlan.filter_disabled = false;
 	if (priv->netdev->flags & IFF_PROMISC)
 		return;
-	mlx5e_del_any_vid_rules(priv);
+	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_CTAG_VID, 0);
 }
 
 void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv)
@@ -302,7 +302,7 @@ void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv)
 	priv->fs.vlan.filter_disabled = true;
 	if (priv->netdev->flags & IFF_PROMISC)
 		return;
-	mlx5e_add_any_vid_rules(priv);
+	mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_CTAG_VID, 0);
 }
 
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
-- 
2.13.0
