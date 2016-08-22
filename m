From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 66/72] uapi icmp.h: glibc netinet/ip_icmp.h header file compatibility fixes
Date: Mon, 22 Aug 2016 20:33:23 +0200
Message-ID: <1471890809-4383-67-git-send-email-mikko.rapeli__23169.8006428362$1471985757$gmane$org@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:48294 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753971AbcHWUzt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 16:55:49 -0400
Received: from lakka.kapsi.fi ([2001:1bc8:1004::1] ident=Debian-exim)
        by mail.kapsi.fi with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
        (Exim 4.80)
        (envelope-from <mikko.rapeli@iki.fi>)
        id 1bcIjb-00051F-G2
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:55:47 +0300
Received: from mcfrisk by lakka.kapsi.fi with local (Exim 4.84_2)
        (envelope-from <mikko.rapeli@iki.fi>)
        id 1bcIjb-0008J7-Ek
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:55:47 +0300
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes this userspace compile error when glibc netinet/ip_icmp.h is included
before linux/icmp.h:

linux/icmp.h:68:8: error: redefinition of ‘struct icmphdr’

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/icmp.h        |  4 +++-
 include/uapi/linux/libc-compat.h | 10 ++++++++++
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/icmp.h b/include/uapi/linux/icmp.h
index fddd9d7..cd38005 100644
--- a/include/uapi/linux/icmp.h
+++ b/include/uapi/linux/icmp.h
@@ -17,6 +17,7 @@
 #ifndef _UAPI_LINUX_ICMP_H
 #define _UAPI_LINUX_ICMP_H
 
+#include <linux/libc-compat.h>
 #include <linux/types.h>
 
 #define ICMP_ECHOREPLY		0	/* Echo Reply			*/
@@ -64,7 +65,7 @@
 #define ICMP_EXC_TTL		0	/* TTL count exceeded		*/
 #define ICMP_EXC_FRAGTIME	1	/* Fragment Reass time exceeded	*/
 
-
+#if __UAPI_DEF_ICMPHDR
 struct icmphdr {
   __u8		type;
   __u8		code;
@@ -82,6 +83,7 @@ struct icmphdr {
 	__u8	reserved[4];
   } un;
 };
+#endif /* __UAPI_DEF_ICMPHDR */
 
 
 /*
diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 40190a4..8a5a7cc 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -154,6 +154,13 @@
 
 #endif /* _NETINET_IN_H */
 
+/* Coordinate with glibc netinet/ip_icmp.h header. */
+#if defined(__NETINET_IP_ICMP_H)
+#define __UAPI_DEF_ICMPHDR		0
+#else /* defined(__NETINET_IP_ICMP_H) */
+#define __UAPI_DEF_ICMPHDR		1
+#endif /* defined(__NETINET_IP_ICMP_H) */
+
 /* Coordinate with glibc netipx/ipx.h header. */
 #if defined(__NETIPX_IPX_H)
 
@@ -218,6 +225,9 @@
 #define __UAPI_DEF_IN6_PKTINFO		1
 #define __UAPI_DEF_IP6_MTUINFO		1
 
+/* Definitions for icmp.h */
+#define __UAPI_DEF_ICMPHDR		1
+
 /* Definitions for ipx.h */
 #define __UAPI_DEF_SOCKADDR_IPX			1
 #define __UAPI_DEF_IPX_ROUTE_DEFINITION		1
-- 
2.8.1
