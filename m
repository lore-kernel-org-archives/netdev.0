From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 13/25 v2] mlx4_core: remove unused driver/kernel uar (kar)
Date: Fri, 06 Nov 2009 05:09:23 +0200
Message-ID: <4AF39363.6050405@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/main.c |   25 +------------------------
 drivers/net/mlx4/mlx4.h |    2 --
 2 files changed, 1 insertions(+), 26 deletions(-)

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 4edc8d7..d8143c6 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -883,26 +883,11 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 		return err;
 	}
 
-	err = mlx4_uar_alloc(dev, &priv->driver_uar);
-	if (err) {
-		mlx4_err(dev, "Failed to allocate driver access region, "
-			 "aborting.\n");
-		goto err_uar_table_free;
-	}
-
-	priv->kar = ioremap(priv->driver_uar.pfn << PAGE_SHIFT, PAGE_SIZE);
-	if (!priv->kar) {
-		mlx4_err(dev, "Couldn't map kernel access region, "
-			 "aborting.\n");
-		err = -ENOMEM;
-		goto err_uar_free;
-	}
-
 	err = mlx4_init_pd_table(dev);
 	if (err) {
 		mlx4_err(dev, "Failed to initialize "
 			 "protection domain table, aborting.\n");
-		goto err_kar_unmap;
+		goto err_uar_table_free;
 	}
 
 	err = mlx4_init_mr_table(dev);
@@ -1015,12 +1000,6 @@ err_mr_table_free:
 err_pd_table_free:
 	mlx4_cleanup_pd_table(dev);
 
-err_kar_unmap:
-	iounmap(priv->kar);
-
-err_uar_free:
-	mlx4_uar_free(dev, &priv->driver_uar);
-
 err_uar_table_free:
 	mlx4_cleanup_uar_table(dev);
 	return err;
@@ -1316,8 +1295,6 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 		mlx4_cleanup_mr_table(dev);
 		mlx4_cleanup_pd_table(dev);
 
-		iounmap(priv->kar);
-		mlx4_uar_free(dev, &priv->driver_uar);
 		mlx4_cleanup_uar_table(dev);
 		mlx4_free_eq_table(dev);
 		mlx4_close_hca(dev);
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 0686856..f0afbb6 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -401,8 +401,6 @@ struct mlx4_priv {
 
 	void __iomem	       *clr_base;
 
-	struct mlx4_uar		driver_uar;
-	void __iomem	       *kar;
 	struct mlx4_port_info	port[MLX4_MAX_PORTS + 1];
 	struct mlx4_sense       sense;
 	struct mutex		port_mutex;
-- 
1.5.3.7

From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
