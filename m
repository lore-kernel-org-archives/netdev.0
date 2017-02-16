From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH v2 2/2] uapi: fix linux/rds.h userspace compilation error
Date: Thu, 16 Feb 2017 18:05:45 +0300
Message-ID: <20170216150545.GE13804@altlinux.org>
References: <20170215200946.GI1028@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170215200946.GI1028@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the kernel side, sockaddr_storage is #define'd to
__kernel_sockaddr_storage.  Replacing struct sockaddr_storage with
struct __kernel_sockaddr_storage defined by <linux/socket.h> fixes
the following linux/rds.h userspace compilation error:

/usr/include/linux/rds.h:226:26: error: field 'dest_addr' has incomplete type
  struct sockaddr_storage dest_addr;

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
v2: Cc'ed netdev

 include/uapi/linux/rds.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/rds.h b/include/uapi/linux/rds.h
index 3ff5cc2..804c9b2 100644
--- a/include/uapi/linux/rds.h
+++ b/include/uapi/linux/rds.h
@@ -35,6 +35,7 @@
 #define _LINUX_RDS_H
 
 #include <linux/types.h>
+#include <linux/socket.h>		/* For __kernel_sockaddr_storage. */
 
 #define RDS_IB_ABI_VERSION		0x301
 
@@ -223,7 +224,7 @@ struct rds_get_mr_args {
 };
 
 struct rds_get_mr_for_dest_args {
-	struct sockaddr_storage	dest_addr;
+	struct __kernel_sockaddr_storage dest_addr;
 	struct rds_iovec 	vec;
 	__u64			cookie_addr;
 	__u64			flags;
-- 
ldv
