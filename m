From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v06 15/36] uapi linux/socket.h: include sys/socket.h in user space
Date: Sun,  6 Aug 2017 18:44:06 +0200
Message-ID: <20170806164428.2273-16-mikko.rapeli@iki.fi>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>, netdev@vger.kernel.org,
        "Dmitry V . Levin" <ldv@altlinux.org>
To: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170806164428.2273-1-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This libc header has sockaddr definition in user space.

Fixes user space compilation errors like these from kernel headers including
only linux/socket.h:

error: field ‘ifru_addr’ has incomplete type
struct sockaddr ifru_addr;
error: field ‘_sockaddr’ has incomplete type
struct sockaddr  _sockaddr;
error: invalid application of ‘sizeof’ to incomplete type ‘struct sockaddr’

With this following uapi headers now compile in user space:

rdma/rdma_user_rxe.h
linux/vm_sockets.h
linux/ncp_fs.h
linux/nfc.h
linux/phonet.h

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Cc: netdev@vger.kernel.org
Cc: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/linux/socket.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/uapi/linux/socket.h b/include/uapi/linux/socket.h
index 76ab0c68561e..8a81197cc08b 100644
--- a/include/uapi/linux/socket.h
+++ b/include/uapi/linux/socket.h
@@ -1,6 +1,10 @@
 #ifndef _UAPI_LINUX_SOCKET_H
 #define _UAPI_LINUX_SOCKET_H
 
+#ifndef __KERNEL__
+#include <sys/socket.h>
+#endif
+
 /*
  * Desired design of maximum size and alignment (see RFC2553)
  */
-- 
2.13.3
