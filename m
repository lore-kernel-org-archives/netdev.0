From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 03/12] net/mlx4_core: Rename QUERY_FUNC_CAP fields
Date: Sun,  8 Dec 2013 14:35:43 +0200
Message-ID: <1386506152-10298-4-git-send-email-amirv@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40349 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752765Ab3LHMgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 07:36:12 -0500
In-Reply-To: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Use correct names for QUERY_FUNC_CAP fields: flags0 and flags1.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 91b50fe..58ca7de 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -207,18 +207,18 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 
 /* when opcode modifier = 1 */
 #define QUERY_FUNC_CAP_PHYS_PORT_OFFSET		0x3
-#define QUERY_FUNC_CAP_RDMA_PROPS_OFFSET	0x8
-#define QUERY_FUNC_CAP_ETH_PROPS_OFFSET		0xc
+#define QUERY_FUNC_CAP_FLAGS0_OFFSET		0x8
+#define QUERY_FUNC_CAP_FLAGS1_OFFSET		0xc
 
 #define QUERY_FUNC_CAP_QP0_TUNNEL		0x10
 #define QUERY_FUNC_CAP_QP0_PROXY		0x14
 #define QUERY_FUNC_CAP_QP1_TUNNEL		0x18
 #define QUERY_FUNC_CAP_QP1_PROXY		0x1c
 
-#define QUERY_FUNC_CAP_ETH_PROPS_FORCE_MAC	0x40
-#define QUERY_FUNC_CAP_ETH_PROPS_FORCE_VLAN	0x80
+#define QUERY_FUNC_CAP_FLAGS1_FORCE_MAC		0x40
+#define QUERY_FUNC_CAP_FLAGS1_FORCE_VLAN	0x80
 
-#define QUERY_FUNC_CAP_RDMA_PROPS_FORCE_PHY_WQE_GID 0x80
+#define QUERY_FUNC_CAP_FLAGS0_FORCE_PHY_WQE_GID 0x80
 
 	if (vhcr->op_modifier == 1) {
 		field = vhcr->in_modifier; /* phys-port = logical-port */
@@ -386,21 +386,21 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u32 gen_or_port,
 	}
 
 	if (dev->caps.port_type[gen_or_port] == MLX4_PORT_TYPE_ETH) {
-		MLX4_GET(field, outbox, QUERY_FUNC_CAP_ETH_PROPS_OFFSET);
-		if (field & QUERY_FUNC_CAP_ETH_PROPS_FORCE_VLAN) {
+		MLX4_GET(field, outbox, QUERY_FUNC_CAP_FLAGS1_OFFSET);
+		if (field & QUERY_FUNC_CAP_FLAGS1_FORCE_VLAN) {
 			mlx4_err(dev, "VLAN is enforced on this port\n");
 			err = -EPROTONOSUPPORT;
 			goto out;
 		}
 
-		if (field & QUERY_FUNC_CAP_ETH_PROPS_FORCE_MAC) {
+		if (field & QUERY_FUNC_CAP_FLAGS1_FORCE_MAC) {
 			mlx4_err(dev, "Force mac is enabled on this port\n");
 			err = -EPROTONOSUPPORT;
 			goto out;
 		}
 	} else if (dev->caps.port_type[gen_or_port] == MLX4_PORT_TYPE_IB) {
-		MLX4_GET(field, outbox, QUERY_FUNC_CAP_RDMA_PROPS_OFFSET);
-		if (field & QUERY_FUNC_CAP_RDMA_PROPS_FORCE_PHY_WQE_GID) {
+		MLX4_GET(field, outbox, QUERY_FUNC_CAP_FLAGS0_OFFSET);
+		if (field & QUERY_FUNC_CAP_FLAGS0_FORCE_PHY_WQE_GID) {
 			mlx4_err(dev, "phy_wqe_gid is "
 				 "enforced on this ib port\n");
 			err = -EPROTONOSUPPORT;
-- 
1.8.3.4
