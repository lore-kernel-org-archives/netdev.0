From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/8] net/mlx5_core: Check the return value of mlx5_command_exec()
Date: Wed, 29 Jul 2015 15:05:39 +0300
Message-ID: <1438171546-17021-2-git-send-email-amirv@mellanox.com>
References: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53794 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750898AbbG2MG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:06:28 -0400
In-Reply-To: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haggai Abramonvsky <hagaya@mellanox.com>

mlx5_cmd_exec() might fail - need to check return value.

Signed-off-by: Haggai Abramovsky <hagaya@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index fc88eca..566a704 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -73,7 +73,12 @@ static inline int mlx5_cmd_exec_check_status(struct mlx5_core_dev *dev, u32 *in,
 					     int in_size, u32 *out,
 					     int out_size)
 {
-	mlx5_cmd_exec(dev, in, in_size, out, out_size);
+	int err;
+
+	err = mlx5_cmd_exec(dev, in, in_size, out, out_size);
+	if (err)
+		return err;
+
 	return mlx5_cmd_status_to_err((struct mlx5_outbox_hdr *)out);
 }
 
-- 
2.4.3.413.ga5fe668
