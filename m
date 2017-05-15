From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net v2] ipv6: sr: fix user space compilation error with old glibc
Date: Mon, 15 May 2017 13:03:20 +0200
Message-ID: <20170515110320.23369-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <daniel@iogearbox.net>, David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:47359 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933701AbdEOLCq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 07:02:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When seg6.h is included in a user space program that also includes
netinet/in.h, it results in multiple definitions of structures such as
struct in6_addr. Recent glibc versions have a workaround that consists in
defining __USE_KERNEL_IPV6_DEFS to prevent duplicates. However, such a
program will fail to compile with older glibc versions.

This patch ensures that including seg6.h will work in any case.

v2: do not try to handle __USE_KERNEL_IPV6_DEFS case in seg6.h

Fixes: ea3ebc73b46fbdb049dafd47543bb22efaa09c8e ("uapi: fix linux/seg6.h and linux/seg6_iptunnel.h userspace compilation errors")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/uapi/linux/seg6.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/uapi/linux/seg6.h b/include/uapi/linux/seg6.h
index 7278511..4055ff3 100644
--- a/include/uapi/linux/seg6.h
+++ b/include/uapi/linux/seg6.h
@@ -15,7 +15,12 @@
 #define _UAPI_LINUX_SEG6_H
 
 #include <linux/types.h>
+
+#ifdef __KERNEL__
 #include <linux/in6.h>		/* For struct in6_addr. */
+#else
+#include <netinet/in.h>
+#endif
 
 /*
  * SRH
-- 
2.10.2
