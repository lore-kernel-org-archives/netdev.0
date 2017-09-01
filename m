From: Ben Greear <greearb@candelatech.com>
Subject: Problem compiling iproute2 on older systems
Date: Fri, 1 Sep 2017 16:52:20 -0700
Message-ID: <bf2c63d1-42cc-7fd3-7d79-945feabda50e@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:36894 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdIAXwW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 19:52:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the patch below, usage of __kernel_ulong_t and __kernel_long_t is
introduced, but that is not available on older system (fedora-14, at least).

It is not a #define, so I am having trouble finding a quick hack
around this.

Any ideas on how to make this work better on older OSs running
modern kernels?


Author: Stephen Hemminger <stephen@networkplumber.org>  2017-01-12 17:54:39
Committer: Stephen Hemminger <stephen@networkplumber.org>  2017-01-12 17:54:39
Child:  c7ec7697e3f000359aa317394e6dd972e35c1f84 (Fix build on fedora-14 (and other older systems))
Branches: master, remotes/origin/master
Follows: v3.10.0
Precedes:

     add more uapi header files

     In order to ensure no backward/forward compatiablity problems,
     make sure that all kernel headers used come from the local copy.

     Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--------------------------- include/linux/sysinfo.h ---------------------------
new file mode 100644
index 0000000..934335a
@@ -0,0 +1,24 @@
+#ifndef _LINUX_SYSINFO_H
+#define _LINUX_SYSINFO_H
+
+#include <linux/types.h>
+
+#define SI_LOAD_SHIFT	16
+struct sysinfo {
+	__kernel_long_t uptime;		/* Seconds since boot */
+	__kernel_ulong_t loads[3];	/* 1, 5, and 15 minute load averages */
+	__kernel_ulong_t totalram;	/* Total usable main memory size */
+	__kernel_ulong_t freeram;	/* Available memory size */
+	__kernel_ulong_t sharedram;	/* Amount of shared memory */
+	__kernel_ulong_t bufferram;	/* Memory used by buffers */
+	__kernel_ulong_t totalswap;	/* Total swap space size */
+	__kernel_ulong_t freeswap;	/* swap space still available */
+	__u16 procs;		   	/* Number of current processes */
+	__u16 pad;		   	/* Explicit padding for m68k */
+	__kernel_ulong_t totalhigh;	/* Total high memory size */
+	__kernel_ulong_t freehigh;	/* Available high memory size */
+	__u32 mem_unit;			/* Memory unit size in bytes */
+	char _f[20-2*sizeof(__kernel_ulong_t)-sizeof(__u32)];	/* Padding: libc5 uses this.. */
+};
+
+#endif /* _LINUX_SYSINFO_H */


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
