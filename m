From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/4] net/mlx4_core: Fix namespace misalignment in QinQ VST support commit
Date: Tue,  1 Aug 2017 16:43:45 +0300
Message-ID: <1501595026-32368-4-git-send-email-tariqt@mellanox.com>
References: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43037 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751913AbdHANog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 09:44:36 -0400
In-Reply-To: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The cited commit introduced the following new enum value in file
include/linux/mlx4/device.h:

    MLX4_DEV_CAP_FLAG2_SVLAN_BY_QP

However the value of MLX4_DEV_CAP_FLAG2_SVLAN_BY_QP needs to stay
consistent with the value used in another namespace in
function dump_dev_cap_flags2(), which is manually kept in sync.
The change here restores that consistency.

Fixes: 7c3d21c8153c ("net/mlx4_core: Preparation for VF vlan protocol 802.1ad")
Reported-by: Mukesh Kacker <mukesh.kacker@oracle.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 009dd03466d6..7c9502bae1cc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -159,7 +159,7 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[32] = "Loopback source checks support",
 		[33] = "RoCEv2 support",
 		[34] = "DMFS Sniffer support (UC & MC)",
-		[35] = "QinQ VST mode support",
+		[36] = "QinQ VST mode support",
 		[37] = "sl to vl mapping table change event support",
 	};
 	int i;
-- 
1.8.3.1
