From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V3 01/21] bnxt_re: Add bnxt_re RoCE driver files
Date: Tue, 20 Dec 2016 01:13:11 -0800
Message-ID: <1482225211-22423-2-git-send-email-selvin.xavier@broadcom.com>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34531 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932313AbcLTJNz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 04:13:55 -0500
Received: by mail-qk0-f176.google.com with SMTP id q68so42196897qki.1
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 01:13:55 -0800 (PST)
In-Reply-To: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the required skeletal files for Broadcom NetXtreme-E RoCE
driver. Also, added the load/unload routines for bnxt_re driver.

v2: Modified the license text to include Dual License

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c    |  37 ++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h    |  42 +++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c  |  37 ++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h  |  42 +++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c   |  37 ++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h   |  42 +++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c    |  37 ++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h    |  43 +++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re.h          |  46 ++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_hsi.h      |  42 +++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c |  37 ++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h |  42 +++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c     | 116 ++++++++++++++++++++++++
 13 files changed, 600 insertions(+)
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_re.h
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_re_hsi.h
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
 create mode 100644 drivers/infiniband/hw/bnxtre/bnxt_re_main.c

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
new file mode 100644
index 0000000..36c4b81
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
@@ -0,0 +1,37 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: Fast Path Operators
+ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
new file mode 100644
index 0000000..0983465
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
@@ -0,0 +1,42 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: Fast Path Operators (header)
+ */
+
+#ifndef __BNXT_QPLIB_FP_H__
+#define __BNXT_QPLIB_FP_H__
+
+#endif /* __BNXT_QPLIB_FP_H__ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
new file mode 100644
index 0000000..4029935
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
@@ -0,0 +1,37 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: RDMA Controller HW interface
+ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h
new file mode 100644
index 0000000..1f63956
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.h
@@ -0,0 +1,42 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: RDMA Controller HW interface (header)
+ */
+
+#ifndef __BNXT_QPLIB_RCFW_H__
+#define __BNXT_QPLIB_RCFW_H__
+
+#endif /* __BNXT_QPLIB_RCFW_H__ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
new file mode 100644
index 0000000..178eebd
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
@@ -0,0 +1,37 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: QPLib resource manager
+ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
new file mode 100644
index 0000000..5fc4107
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
@@ -0,0 +1,42 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: QPLib resource manager (header)
+ */
+
+#ifndef __BNXT_QPLIB_RES_H__
+#define __BNXT_QPLIB_RES_H__
+
+#endif /* __BNXT_QPLIB_RES_H__ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
new file mode 100644
index 0000000..667c8e1
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
@@ -0,0 +1,37 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: Slow Path Operators
+ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
new file mode 100644
index 0000000..90901c1
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
@@ -0,0 +1,43 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: Slow Path Operators (header)
+ *
+ */
+
+#ifndef __BNXT_QPLIB_SP_H__
+#define __BNXT_QPLIB_SP_H__
+
+#endif /* __BNXT_QPLIB_SP_H__*/
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re.h b/drivers/infiniband/hw/bnxtre/bnxt_re.h
new file mode 100644
index 0000000..f9b8542
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re.h
@@ -0,0 +1,46 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: Slow Path Operators (header)
+ *
+ */
+
+#ifndef __BNXT_RE_H__
+#define __BNXT_RE_H__
+#define ROCE_DRV_MODULE_NAME		"bnxt_re"
+#define ROCE_DRV_MODULE_VERSION		"1.0.0"
+
+#define BNXT_RE_DESC	"Broadcom NetXtreme-C/E RoCE Driver"
+#endif
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_hsi.h b/drivers/infiniband/hw/bnxtre/bnxt_re_hsi.h
new file mode 100644
index 0000000..b7d35aa
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_hsi.h
@@ -0,0 +1,42 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: RoCE HSI File - Autogenerated
+ */
+
+#ifndef __BNXT_RE_HSI_H__
+#define __BNXT_RE_HSI_H__
+
+#endif /* __BNXT_RE_HSI_H__ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
new file mode 100644
index 0000000..c01fa40
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
@@ -0,0 +1,37 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: IB Verbs interpreter
+ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
new file mode 100644
index 0000000..9162774
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
@@ -0,0 +1,42 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: IB Verbs interpreter (header)
+ */
+
+#ifndef __BNXT_RE_IB_VERBS_H__
+#define __BNXT_RE_IB_VERBS_H__
+
+#endif /* __BNXT_RE_IB_VERBS_H__ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
new file mode 100644
index 0000000..6c22d51
--- /dev/null
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -0,0 +1,116 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: Main component of the bnxt_re driver
+ */
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/rculist.h>
+#include "bnxt_re.h"
+static char version[] =
+		BNXT_RE_DESC " v" ROCE_DRV_MODULE_VERSION "\n";
+
+MODULE_AUTHOR("Eddie Wai <eddie.wai@broadcom.com>");
+MODULE_DESCRIPTION(BNXT_RE_DESC " Driver");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(ROCE_DRV_MODULE_VERSION);
+
+/* globals */
+static struct list_head bnxt_re_dev_list = LIST_HEAD_INIT(bnxt_re_dev_list);
+/* Mutex to protect the list of bnxt_re devices added */
+static DEFINE_MUTEX(bnxt_re_dev_lock);
+static struct workqueue_struct *bnxt_re_wq;
+/*
+ * "Notifier chain callback can be invoked for the same chain from
+ * different CPUs at the same time".
+ *
+ * For cases when the netdev is already present, our call to the
+ * register_netdevice_notifier() will actually get the rtnl_lock()
+ * before sending NETDEV_REGISTER and (if up) NETDEV_UP
+ * events.
+ *
+ * But for cases when the netdev is not already present, the notifier
+ * chain is subjected to be invoked from different CPUs simultaneously.
+ *
+ * This is protected by the netdev_mutex.
+ */
+static int bnxt_re_netdev_event(struct notifier_block *notifier,
+				unsigned long event, void *ptr)
+{
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block bnxt_re_netdev_notifier = {
+	.notifier_call = bnxt_re_netdev_event
+};
+
+static int __init bnxt_re_mod_init(void)
+{
+	int rc = 0;
+
+	pr_info("%s: %s", ROCE_DRV_MODULE_NAME, version);
+
+	bnxt_re_wq = create_singlethread_workqueue("bnxt_re");
+	if (!bnxt_re_wq)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&bnxt_re_dev_list);
+
+	rc = register_netdevice_notifier(&bnxt_re_netdev_notifier);
+	if (rc) {
+		pr_err("%s: Cannot register to netdevice_notifier",
+		       ROCE_DRV_MODULE_NAME);
+		goto err_netdev;
+	}
+	return 0;
+
+err_netdev:
+	destroy_workqueue(bnxt_re_wq);
+
+	return rc;
+}
+
+static void __exit bnxt_re_mod_exit(void)
+{
+	unregister_netdevice_notifier(&bnxt_re_netdev_notifier);
+	if (bnxt_re_wq)
+		destroy_workqueue(bnxt_re_wq);
+}
+
+module_init(bnxt_re_mod_init);
+module_exit(bnxt_re_mod_exit);
-- 
2.5.5
