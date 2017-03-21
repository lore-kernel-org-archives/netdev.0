From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/8] net/mlx5e: Use the proper UAPI values when offloading TC vlan actions
Date: Tue, 21 Mar 2017 15:59:15 +0200
Message-ID: <20170321135919.25018-5-saeedm@mellanox.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38172 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757593AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Currently we use the non UAPI values and we miss erring on
the modify action which is not supported, fix that.

Fixes: 8b32580df1cb ('net/mlx5e: Add TC vlan action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 2825b5665456..9c13abaf3885 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1131,14 +1131,16 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 		}
 
 		if (is_tcf_vlan(a)) {
-			if (tcf_vlan_action(a) == VLAN_F_POP) {
+			if (tcf_vlan_action(a) == TCA_VLAN_ACT_POP) {
 				attr->action |= MLX5_FLOW_CONTEXT_ACTION_VLAN_POP;
-			} else if (tcf_vlan_action(a) == VLAN_F_PUSH) {
+			} else if (tcf_vlan_action(a) == TCA_VLAN_ACT_PUSH) {
 				if (tcf_vlan_push_proto(a) != htons(ETH_P_8021Q))
 					return -EOPNOTSUPP;
 
 				attr->action |= MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH;
 				attr->vlan = tcf_vlan_push_vid(a);
+			} else { /* action is TCA_VLAN_ACT_MODIFY */
+				return -EOPNOTSUPP;
 			}
 			continue;
 		}
-- 
2.11.0
