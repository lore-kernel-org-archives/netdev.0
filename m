From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 4/4] net/mlx4_core: Fixes missing capability bit in flags2 capability dump
Date: Tue,  1 Aug 2017 16:43:46 +0300
Message-ID: <1501595026-32368-5-git-send-email-tariqt@mellanox.com>
References: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43053 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751930AbdHANog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 09:44:36 -0400
In-Reply-To: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The cited commit introduced the following new enum value in file
include/linux/mlx4/device.h:

    QUERY_DEV_CAP_DIAG_RPRT_PER_PORT

However, it failed to introduce a corresponding entry in function
dump_dev_cap_flags2() for outputting a line in the message log
when this capability bit is set.

The change here fixes that omission.

Fixes: c7c122ed67e4 ("net/mlx4: Add diagnostic counters capability bit")
Reported-by: Mukesh Kacker <mukesh.kacker@oracle.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 7c9502bae1cc..041c0ed65929 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -159,6 +159,7 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[32] = "Loopback source checks support",
 		[33] = "RoCEv2 support",
 		[34] = "DMFS Sniffer support (UC & MC)",
+		[35] = "Diag counters per port",
 		[36] = "QinQ VST mode support",
 		[37] = "sl to vl mapping table change event support",
 	};
-- 
1.8.3.1
