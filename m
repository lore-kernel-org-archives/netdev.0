From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 05/10] net/mlx5e: Set inline mode requirements for matching on IP fragments
Date: Tue, 10 Jan 2017 22:33:34 +0200
Message-ID: <1484080419-24256-6-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52046 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751110AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

For e-switch level matching on packets being an IP fragment, we
need to make sure the source vport inline mode is L3, fix that.

Fixes: 3f7d0eb42d59 ('net/mlx5e: Offload TC matching on packets being IP fragments')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 9cfddd9..a35fa1e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -389,6 +389,10 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 			MLX5_SET(fte_match_set_lyr_2_4, headers_c, frag, 1);
 			MLX5_SET(fte_match_set_lyr_2_4, headers_v, frag,
 				 key->flags & FLOW_DIS_IS_FRAGMENT);
+
+			/* the HW doesn't need L3 inline to match on frag=no */
+			if (key->flags & FLOW_DIS_IS_FRAGMENT)
+				*min_inline = MLX5_INLINE_MODE_IP;
 		}
 	}
 
-- 
2.7.4
