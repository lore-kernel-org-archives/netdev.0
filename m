From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 5/7] net/mlx5e: Correct cleanup order when deleting offloaded TC rules
Date: Wed, 30 Nov 2016 00:19:30 +0200
Message-ID: <1480457972-31286-6-git-send-email-saeedm@mellanox.com>
References: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45850 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754456AbcK2WT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 17:19:56 -0500
In-Reply-To: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

According to the reverse unwinding principle, on delete time we should
first handle deletion of the steering rule and later handle the vlan
deletion from the eswitch.

Fixes: 8b32580df1cb ("net/mlx5e: Add TC vlan action for SRIOV offloads")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index dd6d954..4d71445 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -151,11 +151,11 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 
 	counter = mlx5_flow_rule_counter(rule);
 
+	mlx5_del_flow_rules(rule);
+
 	if (esw && esw->mode == SRIOV_OFFLOADS)
 		mlx5_eswitch_del_vlan_action(esw, attr);
 
-	mlx5_del_flow_rules(rule);
-
 	mlx5_fc_destroy(priv->mdev, counter);
 
 	if (!mlx5e_tc_num_filters(priv) && (priv->fs.tc.t)) {
-- 
2.7.4
