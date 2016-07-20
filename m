From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2] net/mlx5e: Fix del vxlan port command buffer memset
Date: Thu, 21 Jul 2016 00:39:53 +0300
Message-ID: <1469050793-29235-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43020 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754151AbcGTVkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 17:40:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

memset the command buffers rather than the pointers to them.

Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---

V2:
 - Improved log message.

 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
index 05de772..e25a73ed 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
@@ -72,8 +72,8 @@ static int mlx5e_vxlan_core_del_port_cmd(struct mlx5_core_dev *mdev, u16 port)
 	u32 in[MLX5_ST_SZ_DW(delete_vxlan_udp_dport_in)];
 	u32 out[MLX5_ST_SZ_DW(delete_vxlan_udp_dport_out)];
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
 
 	MLX5_SET(delete_vxlan_udp_dport_in, in, opcode,
 		 MLX5_CMD_OP_DELETE_VXLAN_UDP_DPORT);
-- 
2.8.0
