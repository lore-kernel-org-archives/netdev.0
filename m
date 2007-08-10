From: akpm@linux-foundation.org
Subject: [patch 27/28] Introduce U16_MAX and U32_MAX
Date: Fri, 10 Aug 2007 14:12:10 -0700
Message-ID: <200708102112.l7ALCA2M009460@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	satyam@infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37138 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755899AbXHJVPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:15:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

... in kernel.h and clean up home-grown macros elsewhere in the tree.

Leave out the one in reiserfs_fs.h as it is in the userspace-visible part
of that header. Still, #undef the (equivalent) kernel version there to
avoid seeing "redefined, previous definition was here" gcc warnings.

[akpm@linux-foundation.org: fix U16_MAX, U32_MAX defns]
Signed-off-by: Satyam Sharma <satyam@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/netconsole.c    |    7 +++----
 include/linux/kernel.h      |    3 +++
 include/linux/reiserfs_fs.h |    1 +
 net/ipv4/tcp_illinois.c     |    2 +-
 4 files changed, 8 insertions(+), 5 deletions(-)

diff -puN drivers/net/netconsole.c~introduce-u16_max-and-u32_max drivers/net/netconsole.c
--- a/drivers/net/netconsole.c~introduce-u16_max-and-u32_max
+++ a/drivers/net/netconsole.c
@@ -34,6 +34,7 @@
  *
  ****************************************************************/
 
+#include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -389,7 +390,6 @@ static ssize_t store_local_port(struct n
 				size_t count)
 {
 	long local_port;
-#define __U16_MAX	((__u16) ~0U)
 
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
@@ -398,7 +398,7 @@ static ssize_t store_local_port(struct n
 		return -EINVAL;
 	}
 
-	local_port = strtol10_check_range(buf, 0, __U16_MAX);
+	local_port = strtol10_check_range(buf, 0, U16_MAX);
 	if (local_port < 0)
 		return local_port;
 
@@ -412,7 +412,6 @@ static ssize_t store_remote_port(struct 
 				 size_t count)
 {
 	long remote_port;
-#define __U16_MAX	((__u16) ~0U)
 
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
@@ -421,7 +420,7 @@ static ssize_t store_remote_port(struct 
 		return -EINVAL;
 	}
 
-	remote_port = strtol10_check_range(buf, 0, __U16_MAX);
+	remote_port = strtol10_check_range(buf, 0, U16_MAX);
 	if (remote_port < 0)
 		return remote_port;
 
diff -puN include/linux/kernel.h~introduce-u16_max-and-u32_max include/linux/kernel.h
--- a/include/linux/kernel.h~introduce-u16_max-and-u32_max
+++ a/include/linux/kernel.h
@@ -30,6 +30,9 @@ extern const char linux_proc_banner[];
 #define LLONG_MIN	(-LLONG_MAX - 1)
 #define ULLONG_MAX	(~0ULL)
 
+#define U16_MAX		(0xffff)
+#define U32_MAX		(0xffffffff)
+
 #define STACK_MAGIC	0xdeadbeef
 
 #define ALIGN(x,a)		__ALIGN_MASK(x,(typeof(x))(a)-1)
diff -puN include/linux/reiserfs_fs.h~introduce-u16_max-and-u32_max include/linux/reiserfs_fs.h
--- a/include/linux/reiserfs_fs.h~introduce-u16_max-and-u32_max
+++ a/include/linux/reiserfs_fs.h
@@ -1225,6 +1225,7 @@ struct treepath var = {.path_length = IL
 #define MAX_US_INT 0xffff
 
 // reiserfs version 2 has max offset 60 bits. Version 1 - 32 bit offset
+#undef	U32_MAX
 #define U32_MAX (~(__u32)0)
 
 static inline loff_t max_reiserfs_offset(struct inode *inode)
diff -puN net/ipv4/tcp_illinois.c~introduce-u16_max-and-u32_max net/ipv4/tcp_illinois.c
--- a/net/ipv4/tcp_illinois.c~introduce-u16_max-and-u32_max
+++ a/net/ipv4/tcp_illinois.c
@@ -12,6 +12,7 @@
  * Copyright (C) 2007 Stephen Hemminger <shemminger@linux-foundation.org>
  */
 
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/inet_diag.h>
@@ -23,7 +24,6 @@
 #define ALPHA_MIN	((3*ALPHA_SCALE)/10)	/* ~0.3 */
 #define ALPHA_MAX	(10*ALPHA_SCALE)	/* 10.0 */
 #define ALPHA_BASE	ALPHA_SCALE		/* 1.0 */
-#define U32_MAX		((u32)~0U)
 #define RTT_MAX		(U32_MAX / ALPHA_MAX)	/* 3.3 secs */
 
 #define BETA_SHIFT	6
_
