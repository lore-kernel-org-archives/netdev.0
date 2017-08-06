From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v06 18/36] uapi linux/errqueue.h: include linux/time.h in user space
Date: Sun,  6 Aug 2017 18:44:09 +0200
Message-ID: <20170806164428.2273-19-mikko.rapeli@iki.fi>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170806164428.2273-1-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux/time.h conflicts with user space header time.h. Try to be compatible
with both.

Fixes userspace compilation error:

error: array type has incomplete element type
 struct timespec ts[3];

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: netdev@vger.kernel.org
---
 include/uapi/linux/errqueue.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 07bdce1f444a..b310b2c6d94f 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -3,6 +3,12 @@
 
 #include <linux/types.h>
 
+#ifdef __KERNEL__
+#include <linux/time.h>
+#else
+#include <time.h>
+#endif /* __KERNEL__ */
+
 struct sock_extended_err {
 	__u32	ee_errno;	
 	__u8	ee_origin;
-- 
2.13.3
