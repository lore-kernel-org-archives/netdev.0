From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Fix call to __mlx4_unregister_mac
Date: Sun,  3 Nov 2013 10:04:07 +0200
Message-ID: <1383465847-28719-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33984 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752952Ab3KCIEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Nov 2013 03:04:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In function mlx4_master_deactivate_admin_state() __mlx4_unregister_mac was
called using the MAC index. It should be called with the value of the MAC itself.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Dave, this patch is against commit 6f092343 "net: flow_dissector: fail 
on evil iph->ihl", since we want it to go into -stable for kernels >= 3.10, 
and per your guideline, I'm submitting it against the net tree and not net-next. 

 drivers/net/ethernet/mellanox/mlx4/cmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index ea20182..bb11624 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1691,7 +1691,7 @@ static void mlx4_master_deactivate_admin_state(struct mlx4_priv *priv, int slave
 			vp_oper->vlan_idx = NO_INDX;
 		}
 		if (NO_INDX != vp_oper->mac_idx) {
-			__mlx4_unregister_mac(&priv->dev, port, vp_oper->mac_idx);
+			__mlx4_unregister_mac(&priv->dev, port, vp_oper->state.mac);
 			vp_oper->mac_idx = NO_INDX;
 		}
 	}
-- 
1.7.1
