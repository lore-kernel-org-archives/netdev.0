From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 04/12] net/mlx5: E-Switch, Fix error flow memory leak
Date: Tue,  3 May 2016 17:13:56 +0300
Message-ID: <1462284844-16926-5-git-send-email-saeedm@mellanox.com>
References: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48768 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755920AbcECOPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 10:15:05 -0400
In-Reply-To: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Fix memory leak in case query nic vport command failed.

Fixes: 81848731ff40 ('net/mlx5: E-Switch, Add SR-IOV (FDB) support')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index f01903a..c975ff5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -646,7 +646,7 @@ static void esw_update_vport_addr_list(struct mlx5_eswitch *esw,
 	err = mlx5_query_nic_vport_mac_list(esw->dev, vport_num, list_type,
 					    mac_list, &size);
 	if (err)
-		return;
+		goto out;
 	esw_debug(esw->dev, "vport[%d] context update %s list size (%d)\n",
 		  vport_num, is_uc ? "UC" : "MC", size);
 
@@ -674,6 +674,7 @@ static void esw_update_vport_addr_list(struct mlx5_eswitch *esw,
 		addr->vport = vport_num;
 		addr->action = MLX5_ACTION_ADD;
 	}
+out:
 	kfree(mac_list);
 }
 
-- 
2.8.0
