From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 6/6] net/mlx4_core: Fix obscure mlx4_cmd_box parameter in QUERY_DEV_CAP
Date: Wed, 30 May 2012 22:14:55 +0300
Message-ID: <1338405295-15427-7-git-send-email-yevgenyp@mellanox.com>
References: <1338405295-15427-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:55206 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751231Ab2E3TPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 15:15:03 -0400
In-Reply-To: <1338405295-15427-1-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The "!mlx4_is_slave" is totally confusing.  Fix with
constant MLX4_CMD_NATIVE, which is the intended behavior.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 7f2a4a6..9c83bb8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -412,7 +412,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	outbox = mailbox->buf;
 
 	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0, MLX4_CMD_QUERY_DEV_CAP,
-			   MLX4_CMD_TIME_CLASS_A, !mlx4_is_slave(dev));
+			   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 	if (err)
 		goto out;
 
@@ -590,8 +590,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 
 		for (i = 1; i <= dev_cap->num_ports; ++i) {
 			err = mlx4_cmd_box(dev, 0, mailbox->dma, i, 0, MLX4_CMD_QUERY_PORT,
-					   MLX4_CMD_TIME_CLASS_B,
-					   !mlx4_is_slave(dev));
+					   MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 			if (err)
 				goto out;
 
-- 
1.7.1
