From: Jaswinder Singh Rajput <jaswinder@infradead.org>
Subject: [PATCH -tip] socket.h: extern's make no sense in userspace
Date: Tue, 13 Jan 2009 13:50:55 +0530
Message-ID: <1231834855.3212.35.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, netdev <netdev@vger.kernel.org>,
	sam@ravnborg.org, harvey.harrison@gmail.com, gorcunov@gmail.com,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56168 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbZAMIXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 03:23:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: fix 2 make headers_check warnings:

usr/include/linux/socket.h:27: leaks CONFIG_PROC to userspace where it is not valid
usr/include/linux/socket.h:29: extern's make no sense in userspace

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 include/linux/socket.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 20fc4bb..f5771a2 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -24,11 +24,6 @@ struct __kernel_sockaddr_storage {
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
 
-#ifdef CONFIG_PROC_FS
-struct seq_file;
-extern void socket_seq_show(struct seq_file *seq);
-#endif
-
 typedef unsigned short	sa_family_t;
 
 /*
@@ -303,6 +298,11 @@ struct ucred {
 #define IPX_TYPE	1
 
 #ifdef __KERNEL__
+#ifdef CONFIG_PROC_FS
+struct seq_file;
+extern void socket_seq_show(struct seq_file *seq);
+#endif
+
 extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
 extern int memcpy_fromiovecend(unsigned char *kdata, struct iovec *iov, 
 				int offset, int len);
-- 
1.5.6.6



