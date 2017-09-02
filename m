From: greearb@candelatech.com
Subject: [PATCH] Fix build on fedora-14 (and other older systems)
Date: Sat,  2 Sep 2017 07:15:02 -0700
Message-ID: <1504361702-30266-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51838 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752649AbdIBOPI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 10:15:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Seems Fedora-20 and below fail, hopefully this fixes
them.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 include/linux/sysinfo.h | 8 ++++++++
 ip/ipxfrm.c             | 1 +
 ip/xfrm_policy.c        | 1 +
 ip/xfrm_state.c         | 1 +
 4 files changed, 11 insertions(+)

diff --git a/include/linux/sysinfo.h b/include/linux/sysinfo.h
index 934335a..3596b02 100644
--- a/include/linux/sysinfo.h
+++ b/include/linux/sysinfo.h
@@ -3,6 +3,14 @@
 
 #include <linux/types.h>
 
+/* So we can compile on older OSs, hopefully this is correct. --Ben */
+#ifndef __kernel_long_t
+typedef long __kernel_long_t;
+#endif
+#ifndef __kernel_ulong_t
+typedef unsigned long __kernel_ulong_t;
+#endif
+
 #define SI_LOAD_SHIFT	16
 struct sysinfo {
 	__kernel_long_t uptime;		/* Seconds since boot */
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 12c2f72..492a6af 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -38,6 +38,7 @@
 #include "utils.h"
 #include "xfrm.h"
 #include "ip_common.h"
+#include "xtables.h"
 
 #define STRBUF_SIZE	(128)
 
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index de689c4..0f957c1 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -32,6 +32,7 @@
 #include "utils.h"
 #include "xfrm.h"
 #include "ip_common.h"
+#include "xtables.h"
 
 /* #define NLMSG_DELETEALL_BUF_SIZE (4096-512) */
 #define NLMSG_DELETEALL_BUF_SIZE 8192
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 4483fb8..5a6a895 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -31,6 +31,7 @@
 #include "utils.h"
 #include "xfrm.h"
 #include "ip_common.h"
+#include "xtables.h"
 
 /* #define NLMSG_DELETEALL_BUF_SIZE (4096-512) */
 #define NLMSG_DELETEALL_BUF_SIZE 8192
-- 
2.4.11
