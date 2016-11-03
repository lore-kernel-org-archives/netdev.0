From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/6] net/mlx5e: Handle matching on vlan priority for offloaded TC rules
Date: Fri,  4 Nov 2016 01:48:45 +0200
Message-ID: <1478216927-31328-5-git-send-email-saeedm@mellanox.com>
References: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37669 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933504AbcKCXuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:50:13 -0400
In-Reply-To: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

We ignored the vlan priority in offloaded TC rules matching part,
fix that.

Fixes: 095b6cfd69ce ('net/mlx5e: Add TC vlan match parsing')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index ce8c54d..6bb21b3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -237,12 +237,15 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 			skb_flow_dissector_target(f->dissector,
 						  FLOW_DISSECTOR_KEY_VLAN,
 						  f->mask);
-		if (mask->vlan_id) {
+		if (mask->vlan_id || mask->vlan_priority) {
 			MLX5_SET(fte_match_set_lyr_2_4, headers_c, vlan_tag, 1);
 			MLX5_SET(fte_match_set_lyr_2_4, headers_v, vlan_tag, 1);
 
 			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_vid, mask->vlan_id);
 			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_vid, key->vlan_id);
+
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_prio, mask->vlan_priority);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_prio, key->vlan_priority);
 		}
 	}
 
-- 
2.7.4
