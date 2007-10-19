From: ggrundstrom@neteffect.com
Subject: [ofa-general] [PATCH 9/14 v2] nes: kernel to userspace structures
Date: Fri, 19 Oct 2007 15:19:17 -0500
Message-ID: <200710192019.l9JKJHJG021802@neteffect.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: ewg@lists.openfabrics.org, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Kernel to userspace includes, structures and defines.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---

--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.3/drivers/infiniband/hw/nes/nes_user.h	2007-10-19 09:43:32.000000000 -0500
@@ -0,0 +1,95 @@
+/*
+ * Copyright (c) 2006 - 2007 NetEffect.  All rights reserved.
+ * Copyright (c) 2005 Topspin Communications.  All rights reserved.
+ * Copyright (c) 2005 Cisco Systems.  All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
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
+ *
+ */
+
+#ifndef NES_USER_H
+#define NES_USER_H
+
+#include <linux/types.h>
+
+/*
+ * Make sure that all structs defined in this file remain laid out so
+ * that they pack the same way on 32-bit and 64-bit architectures (to
+ * avoid incompatibility between 32-bit userspace and 64-bit kernels).
+ * In particular do not use pointer types -- pass pointers in __u64
+ * instead.
+ */
+
+struct nes_alloc_ucontext_resp {
+	__u32 max_pds; /* maximum pds allowed for this user process */
+	__u32 max_qps; /* maximum qps allowed for this user process */
+	__u32 wq_size; /* size of the WQs (sq+rq) allocated to the mmaped area */
+	__u32 reserved;
+};
+
+struct nes_alloc_pd_resp {
+	__u32 pd_id;
+	__u32 mmap_db_index;
+};
+
+struct nes_create_cq_req {
+	__u64 user_cq_buffer;
+};
+
+enum iwnes_memreg_type {
+	IWNES_MEMREG_TYPE_MEM = 0x0000,
+	IWNES_MEMREG_TYPE_QP = 0x0001,
+	IWNES_MEMREG_TYPE_CQ = 0x0002,
+	IWNES_MEMREG_TYPE_MW = 0x0003,
+	IWNES_MEMREG_TYPE_FMR = 0x0004,
+};
+
+struct nes_mem_reg_req {
+	__u32 reg_type;	/* indicates if id is memory, QP or CQ */
+	__u32 reserved;
+};
+
+struct nes_create_cq_resp {
+	__u32 cq_id;
+	__u32 cq_size;
+	__u32 mmap_db_index;
+	__u32 reserved;
+};
+
+struct nes_create_qp_resp {
+	__u32 qp_id;
+	__u32 actual_sq_size;
+	__u32 actual_rq_size;
+	__u32 mmap_sq_db_index;
+	__u32 mmap_rq_db_index;
+	__u32 nes_drv_opt;
+};
+
+#endif				/* NES_USER_H */
