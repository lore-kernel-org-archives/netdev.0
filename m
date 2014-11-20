From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_en: mlx4_en_set_settings() always fails when autoneg is set
Date: Thu, 20 Nov 2014 14:19:44 +0200
Message-ID: <1416485984-5029-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59821 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750776AbaKTMWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 07:22:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Fix ethtool set settings to not check AUTONEG_ENABLE

mlx4_en_set_settings should not check if cmd->autoneg == AUTONEG_ENABLE,
cmd->autoneg can be enabled by default and this check will fail other settings requests.
mlx4_en driver doesn't support changing autoneg value, but shouldn't fail the request
in case cmd->autoneg was set.

Fixes: d48b3ab ("net/mlx4_en: Use PTYS register to set ethtool settings (Speed)")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 710cf30..bdff834 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -756,7 +756,7 @@ static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	       speed, cmd->advertising, cmd->autoneg, cmd->duplex);
 
 	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL) ||
-	    (cmd->autoneg == AUTONEG_ENABLE) || (cmd->duplex == DUPLEX_HALF))
+	    (cmd->duplex == DUPLEX_HALF))
 		return -EINVAL;
 
 	memset(&ptys_reg, 0, sizeof(ptys_reg));
-- 
1.8.3.4
