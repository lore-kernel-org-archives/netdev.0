From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 1/2] net: convert lists of macros to enumerations
Date: Sun, 23 Jun 2013 15:56:16 -0600
Message-ID: <1372024577-6343-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:39479 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab3FWV55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 17:57:57 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld11so10177724pab.36
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 14:57:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use enumerations to replace macros for simpler preprocessing. Map numeric
values to enumerators. Where required, prepend the list with an additional
enumerator to accommodate the rest.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 include/linux/net.h      | 15 +++++++++------
 include/uapi/linux/net.h | 43 +++++++++++++++++++++++--------------------
 2 files changed, 32 insertions(+), 26 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 4f27575..84444bb 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -32,12 +32,15 @@ struct inode;
 struct file;
 struct net;
 
-#define SOCK_ASYNC_NOSPACE	0
-#define SOCK_ASYNC_WAITDATA	1
-#define SOCK_NOSPACE		2
-#define SOCK_PASSCRED		3
-#define SOCK_PASSSEC		4
-#define SOCK_EXTERNALLY_ALLOCATED 5
+/* Bit value for {set,clear,test{,_and_clear}}_bit() */
+enum {
+	SOCK_ASYNC_NOSPACE,		/* 0 */
+	SOCK_ASYNC_WAITDATA,		/* 1 */
+	SOCK_NOSPACE,			/* 2 */
+	SOCK_PASSCRED,			/* 3 */
+	SOCK_PASSSEC,			/* 4 */
+	SOCK_EXTERNALLY_ALLOCATED,	/* 5 */
+};
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff --git a/include/uapi/linux/net.h b/include/uapi/linux/net.h
index 9457239..9136b54 100644
--- a/include/uapi/linux/net.h
+++ b/include/uapi/linux/net.h
@@ -23,26 +23,29 @@
 
 #define NPROTO		AF_MAX
 
-#define SYS_SOCKET	1		/* sys_socket(2)		*/
-#define SYS_BIND	2		/* sys_bind(2)			*/
-#define SYS_CONNECT	3		/* sys_connect(2)		*/
-#define SYS_LISTEN	4		/* sys_listen(2)		*/
-#define SYS_ACCEPT	5		/* sys_accept(2)		*/
-#define SYS_GETSOCKNAME	6		/* sys_getsockname(2)		*/
-#define SYS_GETPEERNAME	7		/* sys_getpeername(2)		*/
-#define SYS_SOCKETPAIR	8		/* sys_socketpair(2)		*/
-#define SYS_SEND	9		/* sys_send(2)			*/
-#define SYS_RECV	10		/* sys_recv(2)			*/
-#define SYS_SENDTO	11		/* sys_sendto(2)		*/
-#define SYS_RECVFROM	12		/* sys_recvfrom(2)		*/
-#define SYS_SHUTDOWN	13		/* sys_shutdown(2)		*/
-#define SYS_SETSOCKOPT	14		/* sys_setsockopt(2)		*/
-#define SYS_GETSOCKOPT	15		/* sys_getsockopt(2)		*/
-#define SYS_SENDMSG	16		/* sys_sendmsg(2)		*/
-#define SYS_RECVMSG	17		/* sys_recvmsg(2)		*/
-#define SYS_ACCEPT4	18		/* sys_accept4(2)		*/
-#define SYS_RECVMMSG	19		/* sys_recvmmsg(2)		*/
-#define SYS_SENDMMSG	20		/* sys_sendmmsg(2)		*/
+enum {
+	SYS_DUMMY,			/* 0  - place holder		*/
+	SYS_SOCKET,			/* 1  - sys_socket(2)		*/
+	SYS_BIND,			/* 2  - sys_bind(2)		*/
+	SYS_CONNECT,			/* 3  - sys_connect(2)		*/
+	SYS_LISTEN,			/* 4  - sys_listen(2)		*/
+	SYS_ACCEPT,			/* 5  - sys_accept(2)		*/
+	SYS_GETSOCKNAME,		/* 6  - sys_getsockname(2)	*/
+	SYS_GETPEERNAME,		/* 7  - sys_getpeername(2)	*/
+	SYS_SOCKETPAIR,			/* 8  - sys_socketpair(2)	*/
+	SYS_SEND,			/* 9  - sys_send(2)		*/
+	SYS_RECV,			/* 10 - sys_recv(2)		*/
+	SYS_SENDTO,			/* 11 - sys_sendto(2)		*/
+	SYS_RECVFROM,			/* 12 - sys_recvfrom(2)		*/
+	SYS_SHUTDOWN,			/* 13 - sys_shutdown(2)		*/
+	SYS_SETSOCKOPT,			/* 14 - sys_setsockopt(2)	*/
+	SYS_GETSOCKOPT,			/* 15 - sys_getsockopt(2)	*/
+	SYS_SENDMSG,			/* 16 - sys_sendmsg(2)		*/
+	SYS_RECVMSG,			/* 17 - sys_recvmsg(2)		*/
+	SYS_ACCEPT4,			/* 18 - sys_accept4(2)		*/
+	SYS_RECVMMSG,			/* 19 - sys_recvmmsg(2)		*/
+	SYS_SENDMMSG,			/* 20 - sys_sendmmsg(2)		*/
+};
 
 typedef enum {
 	SS_FREE = 0,			/* not allocated		*/
