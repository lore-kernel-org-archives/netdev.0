From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Fix to clean devlink resources
Date: Tue, 20 Sep 2016 14:55:31 +0300
Message-ID: <1474372531-27120-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40479 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752793AbcITL4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 07:56:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

This patch cleans devlink resources by calling devlink_port_unregister()
to avoid the following issues:

- Kernel panic when triggering reset flow.
- Memory leak due to unfreed resources in mlx4_init_port_info().

Fixes: 09d4d087cd48 ("mlx4: Implement devlink interface")
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
Please push it to -stable  >= 4.6 as well. Thanks.

 drivers/net/ethernet/mellanox/mlx4/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 75dd2e3d3059..7183ac4135d2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2970,6 +2970,7 @@ static int mlx4_init_port_info(struct mlx4_dev *dev, int port)
 		mlx4_err(dev, "Failed to create mtu file for port %d\n", port);
 		device_remove_file(&info->dev->persist->pdev->dev,
 				   &info->port_attr);
+		devlink_port_unregister(&info->devlink_port);
 		info->port = -1;
 	}
 
@@ -2984,6 +2985,8 @@ static void mlx4_cleanup_port_info(struct mlx4_port_info *info)
 	device_remove_file(&info->dev->persist->pdev->dev, &info->port_attr);
 	device_remove_file(&info->dev->persist->pdev->dev,
 			   &info->port_mtu_attr);
+	devlink_port_unregister(&info->devlink_port);
+
 #ifdef CONFIG_RFS_ACCEL
 	free_irq_cpu_rmap(info->rmap);
 	info->rmap = NULL;
-- 
1.8.3.1
