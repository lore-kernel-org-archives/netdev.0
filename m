From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/3] net/mlx4_core: Fix wrong dump of the vxlan offloads device capability
Date: Wed, 12 Mar 2014 17:16:30 +0200
Message-ID: <1394637392-31104-2-git-send-email-ogerlitz@mellanox.com>
References: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40492 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754067AbaCLPQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 11:16:37 -0400
In-Reply-To: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the value used to dump the vxlan offloads device capability to align
with the MLX4_DEV_CAP_FLAG2_yyy definition. While on that, add dump to
the IPoIB flow-steering device capability and fix small typo.

The vxlan cap value wasn't fully handled when a conflict was resolved
between MLX4_DEV_CAP_FLAG2_DMFS_IPOIB coming from the IB tree to
MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS coming from net-next.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 8726e34..7e2995e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -129,13 +129,14 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[0] = "RSS support",
 		[1] = "RSS Toeplitz Hash Function support",
 		[2] = "RSS XOR Hash Function support",
-		[3] = "Device manage flow steering support",
+		[3] = "Device managed flow steering support",
 		[4] = "Automatic MAC reassignment support",
 		[5] = "Time stamping support",
 		[6] = "VST (control vlan insertion/stripping) support",
 		[7] = "FSM (MAC anti-spoofing) support",
 		[8] = "Dynamic QP updates support",
-		[9] = "TCP/IP offloads/flow-steering for VXLAN support"
+		[9] = "Device managed flow steering IPoIB support",
+		[10] = "TCP/IP offloads/flow-steering for VXLAN support"
 	};
 	int i;
 
-- 
1.7.1
