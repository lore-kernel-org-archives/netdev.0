From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 1/4] net/mlx5_core: Expose transobj APIs from mlx5 core
Date: Tue, 25 Aug 2015 15:29:57 +0300
Message-ID: <1440505800-5934-2-git-send-email-achiad@mellanox.com>
References: <1440505800-5934-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54939 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754191AbbHYMcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 08:32:10 -0400
In-Reply-To: <1440505800-5934-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

Move transobj.h from the core library to include/linux/mlx5
and expose its APIs.
It enables using its functionality outside of mlx5 core.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 28 ++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h | 72 ----------------------
 4 files changed, 29 insertions(+), 75 deletions(-)
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0983a20..47b2811 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -36,8 +36,8 @@
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/cq.h>
 #include <linux/mlx5/vport.h>
+#include <linux/mlx5/transobj.h>
 #include "wq.h"
-#include "transobj.h"
 #include "mlx5_core.h"
 
 #define MLX5E_MAX_NUM_TC	8
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/srq.c b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
index c48f504..1c1619a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
@@ -35,9 +35,9 @@
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/cmd.h>
 #include <linux/mlx5/srq.h>
+#include <linux/mlx5/transobj.h>
 #include <rdma/ib_verbs.h>
 #include "mlx5_core.h"
-#include "transobj.h"
 
 void mlx5_srq_event(struct mlx5_core_dev *dev, u32 srqn, int event_type)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index b4c87c7..4039c69 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -30,9 +30,10 @@
  * SOFTWARE.
  */
 
+#include <linux/export.h>
 #include <linux/mlx5/driver.h>
+#include <linux/mlx5/transobj.h>
 #include "mlx5_core.h"
-#include "transobj.h"
 
 int mlx5_alloc_transport_domain(struct mlx5_core_dev *dev, u32 *tdn)
 {
@@ -53,6 +54,7 @@ int mlx5_alloc_transport_domain(struct mlx5_core_dev *dev, u32 *tdn)
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_alloc_transport_domain);
 
 void mlx5_dealloc_transport_domain(struct mlx5_core_dev *dev, u32 tdn)
 {
@@ -68,6 +70,7 @@ void mlx5_dealloc_transport_domain(struct mlx5_core_dev *dev, u32 tdn)
 
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_dealloc_transport_domain);
 
 int mlx5_core_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn)
 {
@@ -83,6 +86,7 @@ int mlx5_core_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn)
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_create_rq);
 
 int mlx5_core_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen)
 {
@@ -94,6 +98,7 @@ int mlx5_core_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen)
 	memset(out, 0, sizeof(out));
 	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_modify_rq);
 
 void mlx5_core_destroy_rq(struct mlx5_core_dev *dev, u32 rqn)
 {
@@ -107,6 +112,7 @@ void mlx5_core_destroy_rq(struct mlx5_core_dev *dev, u32 rqn)
 
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_destroy_rq);
 
 int mlx5_core_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *sqn)
 {
@@ -122,6 +128,7 @@ int mlx5_core_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *sqn)
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_create_sq);
 
 int mlx5_core_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen)
 {
@@ -133,6 +140,7 @@ int mlx5_core_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen)
 	memset(out, 0, sizeof(out));
 	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_modify_sq);
 
 void mlx5_core_destroy_sq(struct mlx5_core_dev *dev, u32 sqn)
 {
@@ -146,6 +154,7 @@ void mlx5_core_destroy_sq(struct mlx5_core_dev *dev, u32 sqn)
 
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_destroy_sq);
 
 int mlx5_core_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			 u32 *tirn)
@@ -162,6 +171,7 @@ int mlx5_core_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen,
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_create_tir);
 
 int mlx5_core_modify_tir(struct mlx5_core_dev *dev, u32 tirn, u32 *in,
 			 int inlen)
@@ -174,6 +184,7 @@ int mlx5_core_modify_tir(struct mlx5_core_dev *dev, u32 tirn, u32 *in,
 	memset(out, 0, sizeof(out));
 	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_modify_tir);
 
 void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
 {
@@ -187,6 +198,7 @@ void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
 
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_destroy_tir);
 
 int mlx5_core_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			 u32 *tisn)
@@ -203,6 +215,7 @@ int mlx5_core_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen,
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_create_tis);
 
 void mlx5_core_destroy_tis(struct mlx5_core_dev *dev, u32 tisn)
 {
@@ -216,6 +229,7 @@ void mlx5_core_destroy_tis(struct mlx5_core_dev *dev, u32 tisn)
 
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_destroy_tis);
 
 int mlx5_core_create_rmp(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			 u32 *rmpn)
@@ -232,6 +246,7 @@ int mlx5_core_create_rmp(struct mlx5_core_dev *dev, u32 *in, int inlen,
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_create_rmp);
 
 int mlx5_core_modify_rmp(struct mlx5_core_dev *dev, u32 *in, int inlen)
 {
@@ -242,6 +257,7 @@ int mlx5_core_modify_rmp(struct mlx5_core_dev *dev, u32 *in, int inlen)
 	memset(out, 0, sizeof(out));
 	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_modify_rmp);
 
 int mlx5_core_destroy_rmp(struct mlx5_core_dev *dev, u32 rmpn)
 {
@@ -256,6 +272,7 @@ int mlx5_core_destroy_rmp(struct mlx5_core_dev *dev, u32 rmpn)
 	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
 					  sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_destroy_rmp);
 
 int mlx5_core_query_rmp(struct mlx5_core_dev *dev, u32 rmpn, u32 *out)
 {
@@ -268,6 +285,7 @@ int mlx5_core_query_rmp(struct mlx5_core_dev *dev, u32 rmpn, u32 *out)
 
 	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, outlen);
 }
+EXPORT_SYMBOL(mlx5_core_query_rmp);
 
 int mlx5_core_arm_rmp(struct mlx5_core_dev *dev, u32 rmpn, u16 lwm)
 {
@@ -297,6 +315,7 @@ int mlx5_core_arm_rmp(struct mlx5_core_dev *dev, u32 rmpn, u16 lwm)
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_arm_rmp);
 
 int mlx5_core_create_xsrq(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			  u32 *xsrqn)
@@ -313,6 +332,7 @@ int mlx5_core_create_xsrq(struct mlx5_core_dev *dev, u32 *in, int inlen,
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_create_xsrq);
 
 int mlx5_core_destroy_xsrq(struct mlx5_core_dev *dev, u32 xsrqn)
 {
@@ -328,6 +348,7 @@ int mlx5_core_destroy_xsrq(struct mlx5_core_dev *dev, u32 xsrqn)
 	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
 					  sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_destroy_xsrq);
 
 int mlx5_core_query_xsrq(struct mlx5_core_dev *dev, u32 xsrqn, u32 *out)
 {
@@ -352,6 +373,7 @@ int mlx5_core_query_xsrq(struct mlx5_core_dev *dev, u32 xsrqn, u32 *out)
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_query_xsrq);
 
 int mlx5_core_arm_xsrq(struct mlx5_core_dev *dev, u32 xsrqn, u16 lwm)
 {
@@ -370,6 +392,7 @@ int mlx5_core_arm_xsrq(struct mlx5_core_dev *dev, u32 xsrqn, u16 lwm)
 	return  mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
 					   sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_arm_xsrq);
 
 int mlx5_core_create_rqt(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			 u32 *rqtn)
@@ -386,6 +409,7 @@ int mlx5_core_create_rqt(struct mlx5_core_dev *dev, u32 *in, int inlen,
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_create_rqt);
 
 int mlx5_core_modify_rqt(struct mlx5_core_dev *dev, u32 rqtn, u32 *in,
 			 int inlen)
@@ -398,6 +422,7 @@ int mlx5_core_modify_rqt(struct mlx5_core_dev *dev, u32 rqtn, u32 *in,
 	memset(out, 0, sizeof(out));
 	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_modify_rqt);
 
 void mlx5_core_destroy_rqt(struct mlx5_core_dev *dev, u32 rqtn)
 {
@@ -411,3 +436,4 @@ void mlx5_core_destroy_rqt(struct mlx5_core_dev *dev, u32 rqtn)
 
 	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 }
+EXPORT_SYMBOL(mlx5_core_destroy_rqt);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
deleted file mode 100644
index 74cae51..0000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
+++ /dev/null
@@ -1,72 +0,0 @@
-/*
- * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
- *
- * This software is available to you under a choice of one of two
- * licenses.  You may choose to be licensed under the terms of the GNU
- * General Public License (GPL) Version 2, available from the file
- * COPYING in the main directory of this source tree, or the
- * OpenIB.org BSD license below:
- *
- *     Redistribution and use in source and binary forms, with or
- *     without modification, are permitted provided that the following
- *     conditions are met:
- *
- *      - Redistributions of source code must retain the above
- *        copyright notice, this list of conditions and the following
- *        disclaimer.
- *
- *      - Redistributions in binary form must reproduce the above
- *        copyright notice, this list of conditions and the following
- *        disclaimer in the documentation and/or other materials
- *        provided with the distribution.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-
-#ifndef __TRANSOBJ_H__
-#define __TRANSOBJ_H__
-
-int mlx5_alloc_transport_domain(struct mlx5_core_dev *dev, u32 *tdn);
-void mlx5_dealloc_transport_domain(struct mlx5_core_dev *dev, u32 tdn);
-int mlx5_core_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen,
-			u32 *rqn);
-int mlx5_core_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen);
-void mlx5_core_destroy_rq(struct mlx5_core_dev *dev, u32 rqn);
-int mlx5_core_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen,
-			u32 *sqn);
-int mlx5_core_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen);
-void mlx5_core_destroy_sq(struct mlx5_core_dev *dev, u32 sqn);
-int mlx5_core_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen,
-			 u32 *tirn);
-int mlx5_core_modify_tir(struct mlx5_core_dev *dev, u32 tirn, u32 *in,
-			 int inlen);
-void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn);
-int mlx5_core_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen,
-			 u32 *tisn);
-void mlx5_core_destroy_tis(struct mlx5_core_dev *dev, u32 tisn);
-int mlx5_core_create_rmp(struct mlx5_core_dev *dev, u32 *in, int inlen,
-			 u32 *rmpn);
-int mlx5_core_modify_rmp(struct mlx5_core_dev *dev, u32 *in, int inlen);
-int mlx5_core_destroy_rmp(struct mlx5_core_dev *dev, u32 rmpn);
-int mlx5_core_query_rmp(struct mlx5_core_dev *dev, u32 rmpn, u32 *out);
-int mlx5_core_arm_rmp(struct mlx5_core_dev *dev, u32 rmpn, u16 lwm);
-int mlx5_core_create_xsrq(struct mlx5_core_dev *dev, u32 *in, int inlen,
-			  u32 *rmpn);
-int mlx5_core_destroy_xsrq(struct mlx5_core_dev *dev, u32 rmpn);
-int mlx5_core_query_xsrq(struct mlx5_core_dev *dev, u32 rmpn, u32 *out);
-int mlx5_core_arm_xsrq(struct mlx5_core_dev *dev, u32 rmpn, u16 lwm);
-
-int mlx5_core_create_rqt(struct mlx5_core_dev *dev, u32 *in, int inlen,
-			 u32 *rqtn);
-int mlx5_core_modify_rqt(struct mlx5_core_dev *dev, u32 rqtn, u32 *in,
-			 int inlen);
-void mlx5_core_destroy_rqt(struct mlx5_core_dev *dev, u32 rqtn);
-
-#endif /* __TRANSOBJ_H__ */
-- 
1.8.3.1
