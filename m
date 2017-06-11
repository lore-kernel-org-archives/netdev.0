From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 1/9] net/mlx5e: Remove limitation of single NIC offloaded TC action per rule
Date: Sun, 11 Jun 2017 17:55:45 +0300
Message-ID: <20170611145553.14180-2-saeedm@mellanox.com>
References: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46618 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751764AbdFKO4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:10 -0400
In-Reply-To: <20170611145553.14180-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Remove the limitation that offloaded NIC filters can have only one
action. This allows us for example to provide flow tag as a note
to upper layers / apps that that HW header re-write was applied.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 8ec13f9be660..cfb32fe5129d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1194,10 +1194,6 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 
 	tcf_exts_to_list(exts, &actions);
 	list_for_each_entry(a, &actions, list) {
-		/* Only support a single action per rule */
-		if (attr->action)
-			return -EINVAL;
-
 		if (is_tcf_gact_shot(a)) {
 			attr->action |= MLX5_FLOW_CONTEXT_ACTION_DROP;
 			if (MLX5_CAP_FLOWTABLE(priv->mdev,
-- 
2.11.0
