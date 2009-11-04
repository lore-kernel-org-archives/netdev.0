From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 01/25] mlx4_core: identify function as pf or vf
Date: Wed, 04 Nov 2009 17:30:15 +0200
Message-ID: <4AF19E07.7040702@mellanox.co.il>
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


Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 include/linux/mlx4/device.h |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ce7cc6c..f35703d 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -42,6 +42,9 @@
 enum {
 	MLX4_FLAG_MSI_X		= 1 << 0,
 	MLX4_FLAG_OLD_PORT_CMDS	= 1 << 1,
+	MLX4_FLAG_MASTER	= 1 << 2,
+	MLX4_FLAG_SLAVE		= 1 << 3,
+	MLX4_FLAG_SRIOV		= 1 << 4,
 };
 
 enum {
@@ -375,6 +378,7 @@ struct mlx4_av {
 struct mlx4_dev {
 	struct pci_dev	       *pdev;
 	unsigned long		flags;
+	unsigned long		num_slaves;
 	struct mlx4_caps	caps;
 	struct radix_tree_root	qp_table_tree;
 	u32			rev_id;
@@ -400,6 +404,21 @@ struct mlx4_init_port_param {
 		if (((type) == MLX4_PORT_TYPE_IB ? (dev)->caps.port_mask : \
 		     ~(dev)->caps.port_mask) & 1 << ((port) - 1))
 
+static inline int mlx4_is_slave(struct mlx4_dev *dev)
+{
+	return dev->flags & MLX4_FLAG_SLAVE;
+}
+
+static inline int mlx4_is_master(struct mlx4_dev *dev)
+{
+	return dev->flags & MLX4_FLAG_MASTER;
+}
+
+static inline int mlx4_is_mfunc(struct mlx4_dev *dev)
+{
+	return dev->flags & (MLX4_FLAG_MASTER | MLX4_FLAG_SLAVE);
+}
+
 int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 		   struct mlx4_buf *buf);
 void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf);
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
