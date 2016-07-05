From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH] net/mlx5: Avoid setting unused var when modifying vport node GUID
Date: Tue,  5 Jul 2016 12:17:12 +0300
Message-ID: <1467710232-31192-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Noa Osherovich <noaos@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54398 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751248AbcGEJRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 05:17:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GCC complains on unused-but-set-variable, clean this up.

Fixes: 23898c763f4a ('net/mlx5: E-Switch, Modify node guid on vf set MAC')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/vport.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index daf44cd..91846df 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -513,7 +513,6 @@ int mlx5_modify_nic_vport_node_guid(struct mlx5_core_dev *mdev,
 {
 	int inlen = MLX5_ST_SZ_BYTES(modify_nic_vport_context_in);
 	void *nic_vport_context;
-	u8 *guid;
 	void *in;
 	int err;
 
@@ -535,8 +534,6 @@ int mlx5_modify_nic_vport_node_guid(struct mlx5_core_dev *mdev,
 
 	nic_vport_context = MLX5_ADDR_OF(modify_nic_vport_context_in,
 					 in, nic_vport_context);
-	guid = MLX5_ADDR_OF(nic_vport_context, nic_vport_context,
-			    node_guid);
 	MLX5_SET64(nic_vport_context, nic_vport_context, node_guid, node_guid);
 
 	err = mlx5_modify_nic_vport_context(mdev, in, inlen);
-- 
2.3.7
