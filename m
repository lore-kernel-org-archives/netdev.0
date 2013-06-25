From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 09/10] net/mlx4_core: Add warning in case of command timeouts
Date: Tue, 25 Jun 2013 12:09:37 +0300
Message-ID: <1372151378-21468-10-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Dotan Barak <dotanb@dev.mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52116 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751902Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.com>

Warning prints when there are command timeout to help debugging future
failures.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

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
1.7.1
