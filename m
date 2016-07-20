From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net] net/mlx5e: Fix del vxlan port command
Date: Wed, 20 Jul 2016 17:48:48 +0300
Message-ID: <1469026128-15975-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34742 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754201AbcGTOtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 10:49:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx5e_vxlan_core_del_port_cmd cleared the wrong address, the address of
the pointer of the buffer rather than clearing the buffer itself.

This can lead to a serious stack corruption.

Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
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
