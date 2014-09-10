From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] mlx4: Fix wrong endianess access with QP context flags
Date: Wed, 10 Sep 2014 17:15:11 +0300
Message-ID: <1410358511-13461-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48897 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752766AbaIJOPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 10:15:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We wrongly tested QP context bits without BE conversion
as was spotted by sparse...

drivers/infiniband/hw/mlx4/qp.c:1685:38: sparse: restricted __be32 degrades to integer

Fix that!

Fixes: d2fce8a ('mlx4: Set user-space raw Ethernet QPs to properly handle VXLAN traffic')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/qp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index efb9eff..8365039 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1682,7 +1682,7 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 					MLX4_IB_LINK_TYPE_ETH;
 		if (dev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
 			/* set QP to receive both tunneled & non-tunneled packets */
-			if (!(context->flags & (1 << MLX4_RSS_QPC_FLAG_OFFSET)))
+			if (!(context->flags & cpu_to_be32(1 << MLX4_RSS_QPC_FLAG_OFFSET)))
 				context->srqn = cpu_to_be32(7 << 28);
 		}
 	}
-- 
1.7.1
