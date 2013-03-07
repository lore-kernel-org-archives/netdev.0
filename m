From: Andy King <acking@vmware.com>
Subject: [PATCH] VSOCK: Split vm_sockets.h into kernel/uapi
Date: Thu,  7 Mar 2013 07:26:13 -0800
Message-ID: <1362669973-26984-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, gregkh@linuxfoundation.org, pv-drivers@vmware.com,
	Andy King <acking@vmware.com>, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Split the vSockets header into kernel and UAPI parts.  The former gets the bits
that used to be in __KERNEL__ guards, while the latter gets everything that is
user-visible.  Tested by compiling vsock (+transport) and a simple user-mode
vSockets application.

Reported-by: David Howells <dhowells@redhat.com>
Acked-by: Dmitry Torokhov <dtor@vmware.com>
Signed-off-by: Andy King <acking@vmware.com>
---
 include/linux/vm_sockets.h      |   23 +++++++++++++++++++++++
 include/uapi/linux/vm_sockets.h |   23 ++++++++---------------
 2 files changed, 31 insertions(+), 15 deletions(-)
 create mode 100644 include/linux/vm_sockets.h

diff --git a/include/linux/vm_sockets.h b/include/linux/vm_sockets.h
new file mode 100644
index 0000000..0805eec
--- /dev/null
+++ b/include/linux/vm_sockets.h
@@ -0,0 +1,23 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2013 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef _VM_SOCKETS_H
+#define _VM_SOCKETS_H
+
+#include <uapi/linux/vm_sockets.h>
+
+int vm_sockets_get_local_cid(void);
+
+#endif /* _VM_SOCKETS_H */
diff --git a/include/uapi/linux/vm_sockets.h b/include/uapi/linux/vm_sockets.h
index df91301..b4ed5d8 100644
--- a/include/uapi/linux/vm_sockets.h
+++ b/include/uapi/linux/vm_sockets.h
@@ -13,12 +13,10 @@
  * more details.
  */
 
-#ifndef _VM_SOCKETS_H_
-#define _VM_SOCKETS_H_
+#ifndef _UAPI_VM_SOCKETS_H
+#define _UAPI_VM_SOCKETS_H
 
-#if !defined(__KERNEL__)
-#include <sys/socket.h>
-#endif
+#include <linux/socket.h>
 
 /* Option name for STREAM socket buffer size.  Use as the option name in
  * setsockopt(3) or getsockopt(3) to set or get an unsigned long long that
@@ -137,14 +135,13 @@
 #define VM_SOCKETS_VERSION_MINOR(_v) (((_v) & 0x0000FFFF))
 
 /* Address structure for vSockets.   The address family should be set to
- * whatever vmci_sock_get_af_value_fd() returns.  The structure members should
- * all align on their natural boundaries without resorting to compiler packing
- * directives.  The total size of this structure should be exactly the same as
- * that of struct sockaddr.
+ * AF_VSOCK.  The structure members should all align on their natural
+ * boundaries without resorting to compiler packing directives.  The total size
+ * of this structure should be exactly the same as that of struct sockaddr.
  */
 
 struct sockaddr_vm {
-	sa_family_t svm_family;
+	__kernel_sa_family_t svm_family;
 	unsigned short svm_reserved1;
 	unsigned int svm_port;
 	unsigned int svm_cid;
@@ -156,8 +153,4 @@ struct sockaddr_vm {
 
 #define IOCTL_VM_SOCKETS_GET_LOCAL_CID		_IO(7, 0xb9)
 
-#if defined(__KERNEL__)
-int vm_sockets_get_local_cid(void);
-#endif
-
-#endif
+#endif /* _UAPI_VM_SOCKETS_H */
-- 
1.7.4.1
