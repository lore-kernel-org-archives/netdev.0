From: Olaf Hering <olh@suse.de>
Subject: the remaining purpose of cmsg_nxthdr()
Date: Sat, 12 Feb 2005 18:15:21 +0100
Message-ID: <20050212171521.GA3497@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Are there still valid users of <linux/socket.h>?
All I found was uClibc-0.9.26/include/netinet/ip_tcp.h, which should
probably include their sys/socket.h instead.


diff -purN linux-2.6.11-rc3-bk8/include/linux/socket.h linux-2.6.11/include/linux/socket.h
--- linux-2.6.11-rc3-bk8/include/linux/socket.h	2005-02-03 02:56:33.000000000 +0100
+++ linux-2.6.11/include/linux/socket.h	2005-02-12 18:05:10.000000000 +0100
@@ -95,20 +95,8 @@ struct cmsghdr {
 			     ((mhdr)->msg_controllen - \
 			      ((char *)(cmsg) - (char *)(mhdr)->msg_control)))
 
-/*
- *	This mess will go away with glibc
- */
- 
 #ifdef __KERNEL__
 #define __KINLINE static inline
-#elif  defined(__GNUC__) 
-#define __KINLINE static __inline__
-#elif defined(__cplusplus)
-#define __KINLINE static inline
-#else
-#define __KINLINE static
-#endif
-
 
 /*
  *	Get the next cmsg header
@@ -120,7 +108,7 @@ struct cmsghdr {
  *	Now it always returns valid, not truncated ancillary object
  *	HEADER. But caller still MUST check, that cmsg->cmsg_len is
  *	inside range, given by msg->msg_controllen before using
- *	ansillary object DATA.				--ANK (980731)
+ *	ancillary object DATA.				--ANK (980731)
  */
  
 __KINLINE struct cmsghdr * __cmsg_nxthdr(void *__ctl, __kernel_size_t __size,
@@ -139,6 +127,7 @@ __KINLINE struct cmsghdr * cmsg_nxthdr (
 {
 	return __cmsg_nxthdr(__msg->msg_control, __msg->msg_controllen, __cmsg);
 }
+#endif
 
 /* "Socket"-level control message types: */
 
