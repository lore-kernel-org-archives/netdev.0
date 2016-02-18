From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 01/12] net/mlx5: Introduce a new header file for physical port functions
Date: Thu, 18 Feb 2016 12:32:42 +0200
Message-ID: <1455791573-5270-2-git-send-email-saeedm@mellanox.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34133 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945951AbcBRKlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:41:50 -0500
In-Reply-To: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

All the device physical port access functions are implemented in the
port.c file.
We just extract the exposure of these functions from driver.h into a
dedicated header file called port.h.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c              |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h   |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c |    1 +
 include/linux/mlx5/driver.h                    |   31 -----------
 include/linux/mlx5/port.h                      |   69 ++++++++++++++++++++++++
 5 files changed, 72 insertions(+), 31 deletions(-)
 create mode 100644 include/linux/mlx5/port.h

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index ec737e2..fd3f8ae 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -42,6 +42,7 @@
 #include <rdma/ib_user_verbs.h>
 #include <rdma/ib_addr.h>
 #include <rdma/ib_cache.h>
+#include <linux/mlx5/port.h>
 #include <linux/mlx5/vport.h>
 #include <rdma/ib_smi.h>
 #include <rdma/ib_umem.h>
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index aac071a..15f6cdb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -38,6 +38,7 @@
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/cq.h>
+#include <linux/mlx5/port.h>
 #include <linux/mlx5/vport.h>
 #include <linux/mlx5/transobj.h>
 #include "wq.h"
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index a87e773..1e86321 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -32,6 +32,7 @@
 
 #include <linux/module.h>
 #include <linux/mlx5/driver.h>
+#include <linux/mlx5/port.h>
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 1e3006d..02adc67 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -794,37 +794,6 @@ int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 			 int size_in, void *data_out, int size_out,
 			 u16 reg_num, int arg, int write);
 
-int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps);
-int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
-			 int ptys_size, int proto_mask, u8 local_port);
-int mlx5_query_port_proto_cap(struct mlx5_core_dev *dev,
-			      u32 *proto_cap, int proto_mask);
-int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
-				u32 *proto_admin, int proto_mask);
-int mlx5_query_port_link_width_oper(struct mlx5_core_dev *dev,
-				    u8 *link_width_oper, u8 local_port);
-int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
-			       u8 *proto_oper, int proto_mask,
-			       u8 local_port);
-int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
-			int proto_mask);
-int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
-			       enum mlx5_port_status status);
-int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
-				 enum mlx5_port_status *status);
-
-int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port);
-void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu, u8 port);
-void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
-			      u8 port);
-
-int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
-			      u8 *vl_hw_cap, u8 local_port);
-
-int mlx5_set_port_pause(struct mlx5_core_dev *dev, u32 rx_pause, u32 tx_pause);
-int mlx5_query_port_pause(struct mlx5_core_dev *dev,
-			  u32 *rx_pause, u32 *tx_pause);
-
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 int mlx5_core_eq_query(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
new file mode 100644
index 0000000..7accd4a
--- /dev/null
+++ b/include/linux/mlx5/port.h
@@ -0,0 +1,69 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __MLX5_PORT_H__
+#define __MLX5_PORT_H__
+
+#include <linux/mlx5/driver.h>
+
+int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps);
+int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
+			 int ptys_size, int proto_mask, u8 local_port);
+int mlx5_query_port_proto_cap(struct mlx5_core_dev *dev,
+			      u32 *proto_cap, int proto_mask);
+int mlx5_query_port_proto_admin(struct mlx5_core_dev *dev,
+				u32 *proto_admin, int proto_mask);
+int mlx5_query_port_link_width_oper(struct mlx5_core_dev *dev,
+				    u8 *link_width_oper, u8 local_port);
+int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
+			       u8 *proto_oper, int proto_mask,
+			       u8 local_port);
+int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
+			int proto_mask);
+int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
+			       enum mlx5_port_status status);
+int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
+				 enum mlx5_port_status *status);
+
+int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port);
+void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu, u8 port);
+void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
+			      u8 port);
+
+int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
+			      u8 *vl_hw_cap, u8 local_port);
+
+int mlx5_set_port_pause(struct mlx5_core_dev *dev, u32 rx_pause, u32 tx_pause);
+int mlx5_query_port_pause(struct mlx5_core_dev *dev,
+			  u32 *rx_pause, u32 *tx_pause);
+
+#endif /* __MLX5_PORT_H__ */
-- 
1.7.1
