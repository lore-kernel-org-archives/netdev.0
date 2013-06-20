From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 10/11] net/mlx4_core: Add warning in case of command timeouts
Date: Thu, 20 Jun 2013 22:40:21 +0300
Message-ID: <1371757222-21412-11-git-send-email-amirv@mellanox.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Dotan Barak <dotanb@dev.mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48212 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030293Ab3FTTkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:40:41 -0400
In-Reply-To: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.com>

Warning prints when there are command timeout to help debugging future
failures.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index ea1e038..df04c82 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -257,6 +257,8 @@ static int mlx4_comm_cmd_wait(struct mlx4_dev *dev, u8 op,
 
 	if (!wait_for_completion_timeout(&context->done,
 					 msecs_to_jiffies(timeout))) {
+		mlx4_warn(dev, "communication channel command 0x%x timed out\n",
+			  op);
 		err = -EBUSY;
 		goto out;
 	}
@@ -486,6 +488,8 @@ static int mlx4_cmd_poll(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 	}
 
 	if (cmd_pending(dev)) {
+		mlx4_warn(dev, "command 0x%x timed out (go bit not cleared)\n",
+			  op);
 		err = -ETIMEDOUT;
 		goto out;
 	}
@@ -549,6 +553,8 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 
 	if (!wait_for_completion_timeout(&context->done,
 					 msecs_to_jiffies(timeout))) {
+		mlx4_warn(dev, "command 0x%x timed out (go bit not cleared)\n",
+			  op);
 		err = -EBUSY;
 		goto out;
 	}
-- 
1.8.3.251.g1462b67
