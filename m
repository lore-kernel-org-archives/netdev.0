From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 7/9] net/mlx4_core: Fix sparse warning
Date: Fri, 28 Feb 2014 08:00:07 +0200
Message-ID: <1393567209-16358-8-git-send-email-amirv@mellanox.com>
References: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49359 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750746AbaB1GA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 01:00:29 -0500
In-Reply-To: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

This patch force conversion to u32 to fix the following sparse warning:
drivers/net/ethernet/mellanox/mlx4/fw.c:1822:53: warning: restricted __be32
degrades to integer

Casting to u32 is safe here, because token will be returned as is
from the hardware without any modification.


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 91b69ff..9cdf452 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1890,7 +1890,8 @@ void mlx4_opreq_action(struct work_struct *work)
 			err = EINVAL;
 			break;
 		}
-		err = mlx4_cmd(dev, 0, ((u32) err | cpu_to_be32(token) << 16),
+		err = mlx4_cmd(dev, 0, ((u32) err |
+					(__force u32)cpu_to_be32(token) << 16),
 			       1, MLX4_CMD_GET_OP_REQ, MLX4_CMD_TIME_CLASS_A,
 			       MLX4_CMD_NATIVE);
 		if (err) {
-- 
1.8.3.4
