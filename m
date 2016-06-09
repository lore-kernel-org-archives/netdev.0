From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 07/13] net/mlx5: E-Switch, Use the correct free() function
Date: Fri, 10 Jun 2016 00:07:34 +0300
Message-ID: <1465506460-1854-8-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34456 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750795AbcFIVI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:58 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

We must use kvfree() for something that could have been allocated with vzalloc(),
do that.

Fixes: 5742df0f7dbe ('net/mlx5: E-Switch, Introduce VST vport ingress/egress ACLs')
Fixes: 86d722ad2c3b ('net/mlx5: Use flow steering infrastructure for mlx5_en')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index b84a691..5374796 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -529,7 +529,7 @@ out:
 		}
 	}
 
-	kfree(flow_group_in);
+	kvfree(flow_group_in);
 	return err;
 }
 
@@ -1097,7 +1097,7 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 	vport->egress.drop_grp = drop_grp;
 	vport->egress.allowed_vlans_grp = vlan_grp;
 out:
-	kfree(flow_group_in);
+	kvfree(flow_group_in);
 	if (err && !IS_ERR_OR_NULL(vlan_grp))
 		mlx5_destroy_flow_group(vlan_grp);
 	if (err && !IS_ERR_OR_NULL(acl))
@@ -1259,7 +1259,7 @@ out:
 			mlx5_destroy_flow_table(vport->ingress.acl);
 	}
 
-	kfree(flow_group_in);
+	kvfree(flow_group_in);
 }
 
 static void esw_vport_cleanup_ingress_rules(struct mlx5_eswitch *esw,
-- 
2.8.0
