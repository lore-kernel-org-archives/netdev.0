From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 5/7] net/mlx5e: Prevent adding the same vxlan port
Date: Mon, 27 Jun 2016 12:08:36 +0300
Message-ID: <1467018518-11630-6-git-send-email-saeedm@mellanox.com>
References: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53236 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751845AbcF0JQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:16:20 -0400
In-Reply-To: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

Do not allow the same vxlan udp port to be added to the device more than
once.

Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
Signed-off-by: Matthew Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
index f2fd1ef..05de772 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
@@ -105,6 +105,9 @@ static void mlx5e_vxlan_add_port(struct work_struct *work)
 	struct mlx5e_vxlan *vxlan;
 	int err;
 
+	if (mlx5e_vxlan_lookup_port(priv, port))
+		goto free_work;
+
 	if (mlx5e_vxlan_core_add_port_cmd(priv->mdev, port))
 		goto free_work;
 
-- 
2.8.0
