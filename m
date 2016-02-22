From: Loganaden Velvindron <logan@hackers.mu>
Subject: [PATCH] iproute2: Fix musl compatibility
Date: Mon, 22 Feb 2016 03:34:48 -0800
Message-ID: <20160222113447.GA10262@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.qubic.net ([208.69.177.116]:59413 "EHLO mx.elandsys.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754556AbcBVMBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 07:01:38 -0500
Received: from mx.elandsys.com (IDENT:logan@localhost [127.0.0.1])
	by mx.elandsys.com (8.14.5/8.14.5) with ESMTP id u1MBYm1Z026387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 03:34:49 -0800 (PST)
Received: (from logan@localhost)
	by mx.elandsys.com (8.14.5/8.14.5/Submit) id u1MBYmM3000893
	for netdev@vger.kernel.org; Mon, 22 Feb 2016 03:34:48 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't redefine in6_addr due to including linux/in6.h and also fix
the case of MAXPATHLEN constant not found.

(Original patch from VoidLinux)

Signed-off-by: Loganaden Velvindron <logan@hackers.mu>
---
 include/linux/if_bridge.h | 1 -
 include/linux/netfilter.h | 2 --
 include/linux/xfrm.h      | 1 -
 include/utils.h           | 1 +
 4 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index ee197a3..f823aa4 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -15,7 +15,6 @@
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
-#include <linux/in6.h>
 
 #define SYSFS_BRIDGE_ATTR	"bridge"
 #define SYSFS_BRIDGE_FDB	"brforward"
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index b71b4c9..3e4e6ae 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -4,8 +4,6 @@
 #include <linux/types.h>
 
 #include <linux/sysctl.h>
-#include <linux/in.h>
-#include <linux/in6.h>
 
 /* Responses from hook functions. */
 #define NF_DROP 0
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b8f5451..a9761a5 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -1,7 +1,6 @@
 #ifndef _LINUX_XFRM_H
 #define _LINUX_XFRM_H
 
-#include <linux/in6.h>
 #include <linux/types.h>
 
 /* All of the structures in this file may not change size as they are
diff --git a/include/utils.h b/include/utils.h
index c43427c..debcdde 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -1,6 +1,7 @@
 #ifndef __UTILS_H__
 #define __UTILS_H__ 1
 
+#include <sys/param.h> /* MAXPATHLEN */
 #include <sys/types.h>
 #include <asm/types.h>
 #include <resolv.h>
-- 
2.7.0
