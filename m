From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 3/9] net/mlx5_core: Fix command queue size enforcement
Date: Tue,  2 Dec 2014 12:26:13 +0200
Message-ID: <1417515979-22418-4-git-send-email-eli@mellanox.com>
References: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Cc: roland@kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:35760 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571AbaLBK0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 05:26:37 -0500
Received: by mail-wg0-f41.google.com with SMTP id y19so16575840wgg.28
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 02:26:36 -0800 (PST)
In-Reply-To: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Command queue descriptor page size is 4KB and not the page size used by the
kernel.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 368c6c5ea014..a2853057c779 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1363,7 +1363,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 		goto err_map;
 	}
 
-	if (cmd->log_sz + cmd->log_stride > PAGE_SHIFT) {
+	if (cmd->log_sz + cmd->log_stride > MLX5_ADAPTER_PAGE_SHIFT) {
 		dev_err(&dev->pdev->dev, "command queue size overflow\n");
 		err = -EINVAL;
 		goto err_map;
-- 
2.1.3
