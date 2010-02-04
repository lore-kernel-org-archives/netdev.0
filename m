From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 01/23 v3] mlx4_core: identify function as pf or vf
Date: Thu, 04 Feb 2010 17:54:24 +0200
Message-ID: <4B6AEDB0.2030105@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:46821 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933060Ab0BDPy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:54:27 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 include/linux/mlx4/device.h |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e92d1bf..f7f0508 100644
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
@@ -376,6 +379,7 @@ struct mlx4_av {
 struct mlx4_dev {
 	struct pci_dev	       *pdev;
 	unsigned long		flags;
+	unsigned long		num_slaves;
 	struct mlx4_caps	caps;
 	struct radix_tree_root	qp_table_tree;
 	u32			rev_id;
@@ -401,6 +405,21 @@ struct mlx4_init_port_param {
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


