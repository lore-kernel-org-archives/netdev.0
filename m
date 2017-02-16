From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH v2] uapi: fix linux/mroute.h userspace compilation errors
Date: Thu, 16 Feb 2017 18:04:46 +0300
Message-ID: <20170216150446.GC13804@altlinux.org>
References: <20170215200650.GG1028@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170215200650.GG1028@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include <linux/in.h> to fix the following linux/mroute.h userspace
compilation errors:

/usr/include/linux/mroute.h:58:18: error: field 'vifc_lcl_addr' has incomplete type
  struct in_addr vifc_lcl_addr;     /* Local interface address */
/usr/include/linux/mroute.h:61:17: error: field 'vifc_rmt_addr' has incomplete type
  struct in_addr vifc_rmt_addr; /* IPIP tunnel addr */
/usr/include/linux/mroute.h:72:17: error: field 'mfcc_origin' has incomplete type
  struct in_addr mfcc_origin;  /* Origin of mcast */
/usr/include/linux/mroute.h:73:17: error: field 'mfcc_mcastgrp' has incomplete type
  struct in_addr mfcc_mcastgrp;  /* Group in question */
/usr/include/linux/mroute.h:84:17: error: field 'src' has incomplete type
  struct in_addr src;
/usr/include/linux/mroute.h:85:17: error: field 'grp' has incomplete type
  struct in_addr grp;
/usr/include/linux/mroute.h:109:17: error: field 'im_src' has incomplete type
  struct in_addr im_src,im_dst;
/usr/include/linux/mroute.h:109:24: error: field 'im_dst' has incomplete type
  struct in_addr im_src,im_dst;

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
v2: Cc'ed netdev

 include/uapi/linux/mroute.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
index cf94301..1fe4c1e 100644
--- a/include/uapi/linux/mroute.h
+++ b/include/uapi/linux/mroute.h
@@ -3,6 +3,7 @@
 
 #include <linux/sockios.h>
 #include <linux/types.h>
+#include <linux/in.h>		/* For struct in_addr. */
 
 /* Based on the MROUTING 3.5 defines primarily to keep
  * source compatibility with BSD.
-- 
ldv
