From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH v2] uapi: fix linux/if_pppol2tp.h userspace compilation errors
Date: Wed, 15 Feb 2017 05:23:26 +0300
Message-ID: <20170215022326.GA21493@altlinux.org>
References: <20170214103353.GA8394@altlinux.org> <20170214.143723.629330014459224649.davem@davemloft.net> <20170214202950.GB17325@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?Q?Asbj=C3=B8rn_Sloth_T=C3=B8nnesen?= <asbjorn@asbjorn.st>,
        James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214202950.GB17325@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because of <linux/libc-compat.h> interface limitations, <netinet/in.h>
provided by libc cannot be included after <linux/in.h>, therefore any
header that includes <netinet/in.h> cannot be included after <linux/in.h>.

Change uapi/linux/l2tp.h, the last uapi header that includes
<netinet/in.h>, to include <linux/in.h> and <linux/in6.h> instead of
<netinet/in.h> and use __SOCK_SIZE__ instead of sizeof(struct sockaddr)
the same way as uapi/linux/in.h does, to fix linux/if_pppol2tp.h userspace
compilation errors like this:

In file included from /usr/include/linux/l2tp.h:12:0,
                 from /usr/include/linux/if_pppol2tp.h:21,
/usr/include/netinet/in.h:31:8: error: redefinition of 'struct in_addr'

Fixes: 47c3e7783be4 ("net: l2tp: deprecate PPPOL2TP_MSG_* in favour of L2TP_MSG_*")
Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
v2: change uapi/linux/l2tp.h to fix <linux/if_pppol2tp.h>

 include/uapi/linux/l2tp.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/l2tp.h b/include/uapi/linux/l2tp.h
index 85ddb74..b23c191 100644
--- a/include/uapi/linux/l2tp.h
+++ b/include/uapi/linux/l2tp.h
@@ -9,9 +9,8 @@
 
 #include <linux/types.h>
 #include <linux/socket.h>
-#ifndef __KERNEL__
-#include <netinet/in.h>
-#endif
+#include <linux/in.h>
+#include <linux/in6.h>
 
 #define IPPROTO_L2TP		115
 
@@ -31,7 +30,7 @@ struct sockaddr_l2tpip {
 	__u32		l2tp_conn_id;	/* Connection ID of tunnel */
 
 	/* Pad to size of `struct sockaddr'. */
-	unsigned char	__pad[sizeof(struct sockaddr) -
+	unsigned char	__pad[__SOCK_SIZE__ -
 			      sizeof(__kernel_sa_family_t) -
 			      sizeof(__be16) - sizeof(struct in_addr) -
 			      sizeof(__u32)];
-- 
ldv
