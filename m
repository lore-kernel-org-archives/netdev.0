From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH iproute2 2/3] include: add <linux/vm_sockets_diag.h>
Date: Tue,  3 Oct 2017 13:57:43 -0400
Message-ID: <20171003175744.24987-3-stefanha@redhat.com>
References: <20171003175744.24987-1-stefanha@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56424 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751199AbdJCR6G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 13:58:06 -0400
In-Reply-To: <20171003175744.24987-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new Linux header file defines the sock_diag interface used by
AF_VSOCK.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/linux/vm_sockets_diag.h | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)
 create mode 100644 include/linux/vm_sockets_diag.h

diff --git a/include/linux/vm_sockets_diag.h b/include/linux/vm_sockets_diag.h
new file mode 100644
index 00000000..14cd7dc5
--- /dev/null
+++ b/include/linux/vm_sockets_diag.h
@@ -0,0 +1,33 @@
+/* AF_VSOCK sock_diag(7) interface for querying open sockets */
+
+#ifndef _UAPI__VM_SOCKETS_DIAG_H__
+#define _UAPI__VM_SOCKETS_DIAG_H__
+
+#include <linux/types.h>
+
+/* Request */
+struct vsock_diag_req {
+	__u8	sdiag_family;	/* must be AF_VSOCK */
+	__u8	sdiag_protocol;	/* must be 0 */
+	__u16	pad;		/* must be 0 */
+	__u32	vdiag_states;	/* query bitmap (e.g. 1 << TCP_LISTEN) */
+	__u32	vdiag_ino;	/* must be 0 (reserved) */
+	__u32	vdiag_show;	/* must be 0 (reserved) */
+	__u32	vdiag_cookie[2];
+};
+
+/* Response */
+struct vsock_diag_msg {
+	__u8	vdiag_family;	/* AF_VSOCK */
+	__u8	vdiag_type;	/* SOCK_STREAM or SOCK_DGRAM */
+	__u8	vdiag_state;	/* sk_state (e.g. TCP_LISTEN) */
+	__u8	vdiag_shutdown; /* local RCV_SHUTDOWN | SEND_SHUTDOWN */
+	__u32   vdiag_src_cid;
+	__u32   vdiag_src_port;
+	__u32   vdiag_dst_cid;
+	__u32   vdiag_dst_port;
+	__u32	vdiag_ino;
+	__u32	vdiag_cookie[2];
+};
+
+#endif /* _UAPI__VM_SOCKETS_DIAG_H__ */
-- 
2.13.6
