From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 01/11] net/mlx4_core: Remove zeroed out of explicit QUERY_FUNC_CAP fields
Date: Tue, 17 Dec 2013 09:01:50 +0200
Message-ID: <1387263720-31222-2-git-send-email-amirv@mellanox.com>
References: <1387263720-31222-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34094 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752582Ab3LQHCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 02:02:15 -0500
In-Reply-To: <1387263720-31222-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

All mailboxes are already zeroed by commit:
571b8b9 net/mlx4_core: Initialize all mailbox buffers to zero before use
Remove explicit zero set for force mac and force vlan fields in
mlx4_QUERY_FUNC_CAP_wrapper

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 1949282..91b50fe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -221,12 +221,6 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_RDMA_PROPS_FORCE_PHY_WQE_GID 0x80
 
 	if (vhcr->op_modifier == 1) {
-		field = 0;
-		/* ensure force vlan and force mac bits are not set */
-		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_ETH_PROPS_OFFSET);
-		/* ensure that phy_wqe_gid bit is not set */
-		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_RDMA_PROPS_OFFSET);
-
 		field = vhcr->in_modifier; /* phys-port = logical-port */
 		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_PHYS_PORT_OFFSET);
 
-- 
1.8.3.4
