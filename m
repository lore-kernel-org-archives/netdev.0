From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 01/10] net/mlx4_core: Fix the resource-type enum in res tracker to conform to FW spec
Date: Thu, 27 Oct 2016 16:27:13 +0300
Message-ID: <1477574842-29688-2-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Moshe Shemesh <moshe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57523 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941414AbcJ0NyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:17 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The resource type enum in the resource tracker was incorrect.
RES_EQ was put in the position of RES_NPORT_ID (a FC resource).

Since the remaining resources maintain their current values,
and RES_EQ is not passed from slaves to the hypervisor in any
FW command, this change affects only the hypervisor.
Therefore, there is no backwards-compatibility issue.

Fixes: 623ed84b1f95 ("mlx4_core: initial header-file changes for SRIOV support")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index e4878f31e45d..7aad07644289 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -145,9 +145,10 @@ enum mlx4_resource {
 	RES_MTT,
 	RES_MAC,
 	RES_VLAN,
-	RES_EQ,
+	RES_NPORT_ID,
 	RES_COUNTER,
 	RES_FS_RULE,
+	RES_EQ,
 	MLX4_NUM_OF_RESOURCE_TYPE
 };
 
-- 
1.8.3.1
