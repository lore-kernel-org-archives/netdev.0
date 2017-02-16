From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH v2] uapi: fix linux/mroute6.h userspace compilation errors
Date: Thu, 16 Feb 2017 18:04:29 +0300
Message-ID: <20170216150429.GB13804@altlinux.org>
References: <20170215200617.GF1028@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170215200617.GF1028@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include <linux/in6.h> to fix the following linux/mroute6.h userspace
compilation errors:

/usr/include/linux/mroute6.h:80:22: error: field 'mf6cc_origin' has incomplete type
  struct sockaddr_in6 mf6cc_origin;  /* Origin of mcast */
/usr/include/linux/mroute6.h:81:22: error: field 'mf6cc_mcastgrp' has incomplete type
  struct sockaddr_in6 mf6cc_mcastgrp;  /* Group in question */
/usr/include/linux/mroute6.h:91:22: error: field 'src' has incomplete type
  struct sockaddr_in6 src;
/usr/include/linux/mroute6.h:92:22: error: field 'grp' has incomplete type
  struct sockaddr_in6 grp;
/usr/include/linux/mroute6.h:132:18: error: field 'im6_src' has incomplete type
  struct in6_addr im6_src, im6_dst;
/usr/include/linux/mroute6.h:132:27: error: field 'im6_dst' has incomplete type
  struct in6_addr im6_src, im6_dst;

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
v2: Cc'ed netdev

 include/uapi/linux/mroute6.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/mroute6.h b/include/uapi/linux/mroute6.h
index 5062fb5..ed57211 100644
--- a/include/uapi/linux/mroute6.h
+++ b/include/uapi/linux/mroute6.h
@@ -4,6 +4,7 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/sockios.h>
+#include <linux/in6.h>		/* For struct sockaddr_in6. */
 
 /*
  *	Based on the MROUTING 3.5 defines primarily to keep
-- 
ldv
