From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 8/8] net/mlx4_core: Fixed error flow in rem_slave_eqs
Date: Tue, 15 May 2012 23:35:04 +0300
Message-ID: <1337114104-26094-9-git-send-email-ogerlitz@mellanox.com>
References: <1337114104-26094-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:45733 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933350Ab2EOUfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 16:35:17 -0400
In-Reply-To: <1337114104-26094-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index b3c505d..b45d0e7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3152,14 +3152,13 @@ static void rem_slave_eqs(struct mlx4_dev *dev, int slave)
 							   MLX4_CMD_HW2SW_EQ,
 							   MLX4_CMD_TIME_CLASS_A,
 							   MLX4_CMD_NATIVE);
-					mlx4_dbg(dev, "rem_slave_eqs: failed"
-						 " to move slave %d eqs %d to"
-						 " SW ownership\n", slave, eqn);
+					if (err)
+						mlx4_dbg(dev, "rem_slave_eqs: failed"
+							 " to move slave %d eqs %d to"
+							 " SW ownership\n", slave, eqn);
 					mlx4_free_cmd_mailbox(dev, mailbox);
-					if (!err) {
-						atomic_dec(&eq->mtt->ref_count);
-						state = RES_EQ_RESERVED;
-					}
+					atomic_dec(&eq->mtt->ref_count);
+					state = RES_EQ_RESERVED;
 					break;
 
 				default:
-- 
1.7.1
