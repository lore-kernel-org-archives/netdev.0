From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] mlx5: remove unnecessary pci_set_drvdata()
Date: Tue, 15 Aug 2017 02:33:06 -0400
Message-ID: <1502778786-14738-2-git-send-email-yanjun.zhu@oracle.com>
References: <1502778786-14738-1-git-send-email-yanjun.zhu@oracle.com>
To: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1502778786-14738-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not necessary to manually clear the
device driver data to NULL.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index c065132..2cafbdc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1407,7 +1407,6 @@ static int init_one(struct pci_dev *pdev,
 	cleanup_srcu_struct(&priv->pfault_srcu);
 clean_dev:
 #endif
-	pci_set_drvdata(pdev, NULL);
 	devlink_free(devlink);
 
 	return err;
@@ -1434,7 +1433,6 @@ static void remove_one(struct pci_dev *pdev)
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 	cleanup_srcu_struct(&priv->pfault_srcu);
 #endif
-	pci_set_drvdata(pdev, NULL);
 	devlink_free(devlink);
 }
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
