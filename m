From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: [PATCH net-next 1/9] net/mlx5_core: Request the mlx5 IB module on driver load
Date: Tue,  2 Dec 2014 12:26:11 +0200
Message-ID: <1417515979-22418-2-git-send-email-eli@mellanox.com>
References: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417515979-22418-1-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Call request module on mlx5_ib so it will be available for applications
requiring it, such as installers that require boot over IB.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 71b10b210792..4e3c27e77768 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -43,6 +43,7 @@
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/srq.h>
 #include <linux/debugfs.h>
+#include <linux/kmod.h>
 #include <linux/mlx5/mlx5_ifc.h>
 #include "mlx5_core.h"
 
@@ -840,6 +841,8 @@ struct mlx5_core_event_handler {
 		      void *data);
 };
 
+#define MLX5_IB_MOD "mlx5_ib"
+
 static int init_one(struct pci_dev *pdev,
 		    const struct pci_device_id *id)
 {
@@ -878,6 +881,10 @@ static int init_one(struct pci_dev *pdev,
 		goto out_init;
 	}
 
+	err = request_module_nowait(MLX5_IB_MOD);
+	if (err)
+		pr_info("failed request module on %s\n", MLX5_IB_MOD);
+
 	return 0;
 
 out_init:
-- 
2.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
