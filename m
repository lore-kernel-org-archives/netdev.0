From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 72/72] uapi route.h: glibc net/route.h compat fix
Date: Mon, 22 Aug 2016 20:33:29 +0200
Message-ID: <1471890809-4383-73-git-send-email-mikko.rapeli__45545.0496440337$1471985801$gmane$org@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:37139 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755156AbcHWU4b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 16:56:31 -0400
Received: from lakka.kapsi.fi ([2001:1bc8:1004::1] ident=Debian-exim)
        by mail.kapsi.fi with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
        (Exim 4.80)
        (envelope-from <mikko.rapeli@iki.fi>)
        id 1bcIkI-0005F9-3X
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:56:30 +0300
Received: from mcfrisk by lakka.kapsi.fi with local (Exim 4.84_2)
        (envelope-from <mikko.rapeli@iki.fi>)
        id 1bcIkI-0001TS-2X
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:56:30 +0300
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes this userspace compile error when net/route.h is included before
linux/route.h:

linux/route.h:30:8: error: redefinition of ‘struct rtentry’

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/libc-compat.h | 10 ++++++++++
 include/uapi/linux/route.h       |  4 +++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 07a3462..16ba7dc 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -230,6 +230,13 @@
 
 #endif /* defined(_NETROSE_ROSE_H) */
 
+/* Coordinate with glibc net/route.h */
+#if defined(_NET_ROUTE_H)
+#define __UAPI_DEF_RTENTRY		0
+#else /* defined(_NET_ROUTE_H) */
+#define __UAPI_DEF_RTENTRY		1
+#endif /* defined(_NET_ROUTE_H) */
+
 /* Coordinate with glibc pty.h */
 #if defined(_PTY_H)
 #define __UAPI_DEF_TERMIOS	0
@@ -369,6 +376,9 @@
 #define __UAPI_DEF_ROSE_CAUSE_STRUCT			1
 #define __UAPI_DEF_ROSE_FACILITIES_STRUCT		1
 
+/* Definitions for route.h */
+#define __UAPI_DEF_RTENTRY		1
+
 /* Definitions for time.h */
 #define __UAPI_DEF_TIMESPEC			1
 #define __UAPI_DEF_TIMEVAL			1
diff --git a/include/uapi/linux/route.h b/include/uapi/linux/route.h
index 6600708..7b77ef2 100644
--- a/include/uapi/linux/route.h
+++ b/include/uapi/linux/route.h
@@ -23,10 +23,12 @@
 #ifndef _LINUX_ROUTE_H
 #define _LINUX_ROUTE_H
 
+#include <linux/libc-compat.h>
 #include <linux/if.h>
 #include <linux/compiler.h>
 
 /* This structure gets passed by the SIOCADDRT and SIOCDELRT calls. */
+#if __UAPI_DEF_RTENTRY
 struct rtentry {
 	unsigned long	rt_pad1;
 	struct sockaddr	rt_dst;		/* target address		*/
@@ -45,7 +47,7 @@ struct rtentry {
 	unsigned long	rt_window;	/* Window clamping 		*/
 	unsigned short	rt_irtt;	/* Initial RTT			*/
 };
-
+#endif /* __UAPI_DEF_RTENTRY */
 
 #define	RTF_UP		0x0001		/* route usable		  	*/
 #define	RTF_GATEWAY	0x0002		/* destination is a gateway	*/
-- 
2.8.1
