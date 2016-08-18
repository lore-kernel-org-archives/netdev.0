From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 06/10] net/mlx5e: Use correct flow dissector key on flower offloading
Date: Thu, 18 Aug 2016 21:09:07 +0300
Message-ID: <1471543751-24164-7-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41780 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755279AbcHSBnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:05 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The wrong key is used when extracting the address type field set by
the flower offload code. We have to use the control key and not the
basic key, fix that.

Fixes: e3a2b7ed018e ('net/mlx5e: Support offload cls_flower with drop action')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index dc8b1cb..22cfc4a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -170,7 +170,7 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_CONTROL)) {
 		struct flow_dissector_key_control *key =
 			skb_flow_dissector_target(f->dissector,
-						  FLOW_DISSECTOR_KEY_BASIC,
+						  FLOW_DISSECTOR_KEY_CONTROL,
 						  f->key);
 		addr_type = key->addr_type;
 	}
-- 
2.7.4
