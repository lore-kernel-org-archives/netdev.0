From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] mlx4: remove unnecessary pci_set_drvdata()
Date: Tue, 15 Aug 2017 02:33:05 -0400
Message-ID: <1502778786-14738-1-git-send-email-yanjun.zhu@oracle.com>
To: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not necessary to manually clear the
device driver data to NULL.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 09b9bc1..df9b0ef 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -3782,7 +3782,6 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
 
 err_disable_pdev:
 	mlx4_pci_disable_device(&priv->dev);
-	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -3997,7 +3996,6 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	devlink_unregister(devlink);
 	kfree(dev->persist);
 	devlink_free(devlink);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static int restore_current_port_types(struct mlx4_dev *dev,
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
