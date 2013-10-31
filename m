From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 01/10] net/mlx4_core: Fix call to __mlx4_unregister_mac
Date: Thu, 31 Oct 2013 14:29:20 +0200
Message-ID: <1383222569-10930-2-git-send-email-ogerlitz@mellanox.com>
References: <1383222569-10930-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:35599 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753084Ab3JaM3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 08:29:47 -0400
In-Reply-To: <1383222569-10930-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In function mlx4_master_deactivate_admin_state() __mlx4_unregister_mac was
called using the MAC index. It should be called with the value of the MAC itself.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 735765c..ae8eb4c 100644
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
