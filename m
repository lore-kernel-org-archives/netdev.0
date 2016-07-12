From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 03/10] net/mlx5e: Offload TC flow counters only when supported
Date: Wed, 13 Jul 2016 00:28:59 +0300
Message-ID: <1468358946-28709-4-git-send-email-saeedm@mellanox.com>
References: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51269 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751018AbcGLVbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 17:31:32 -0400
In-Reply-To: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Currenly, the code that programs the flow actions into the firmware
doesn't check if was actually asked to offload the statistics, fix that.

Fixes: aad7e08d39bd ('net/mlx5e: Hardware offloaded flower filter statistics support')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3261e8b..cd58fc8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -62,7 +62,7 @@ static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
 	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
 		dest.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
 		dest.ft = priv->fs.vlan.ft.t;
-	} else {
+	} else if (action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
 		counter = mlx5_fc_create(dev, true);
 		if (IS_ERR(counter))
 			return ERR_CAST(counter);
-- 
2.8.0
