From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: [PATCH net] in6: fix conflict with glibc
Date: Sat, 20 Dec 2014 12:15:49 -0800
Message-ID: <20141220121549.7c1b8aad@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Florent Fourcot <florent.fourcot-Pj3lBMu8rt9bbU8NOSLlsg@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Resolve conflicts between glibc definition of IPV6 socket options
and those defined in Linux headers. Looks like earlier efforts to
solve this did not cover all the definitions.

It resolves warnings during iproute2 build. 
Please consider for stable as well.

Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>

---
Patch against -net tree

--- a/include/uapi/linux/in6.h	2014-08-28 08:23:29.981240723 -0700
+++ b/include/uapi/linux/in6.h	2014-12-20 12:00:31.973120787 -0800
@@ -149,7 +149,7 @@ struct in6_flowlabel_req {
 /*
  *	IPV6 socket options
  */
-
+#if __UAPI_DEF_IPV6_OPTIONS
 #define IPV6_ADDRFORM		1
 #define IPV6_2292PKTINFO	2
 #define IPV6_2292HOPOPTS	3
@@ -196,6 +196,7 @@ struct in6_flowlabel_req {
 
 #define IPV6_IPSEC_POLICY	34
 #define IPV6_XFRM_POLICY	35
+#endif
 
 /*
  * Multicast:
--- a/include/uapi/linux/libc-compat.h	2014-04-08 22:12:24.316054847 -0700
+++ b/include/uapi/linux/libc-compat.h	2014-12-20 12:10:29.960213758 -0800
@@ -69,6 +69,7 @@
 #define __UAPI_DEF_SOCKADDR_IN6		0
 #define __UAPI_DEF_IPV6_MREQ		0
 #define __UAPI_DEF_IPPROTO_V6		0
+#define __UAPI_DEF_IPV6_OPTIONS		0
 
 #else
 
@@ -82,6 +83,7 @@
 #define __UAPI_DEF_SOCKADDR_IN6		1
 #define __UAPI_DEF_IPV6_MREQ		1
 #define __UAPI_DEF_IPPROTO_V6		1
+#define __UAPI_DEF_IPV6_OPTIONS		1
 
 #endif /* _NETINET_IN_H */
 
@@ -103,6 +105,7 @@
 #define __UAPI_DEF_SOCKADDR_IN6		1
 #define __UAPI_DEF_IPV6_MREQ		1
 #define __UAPI_DEF_IPPROTO_V6		1
+#define __UAPI_DEF_IPV6_OPTIONS		1
 
 /* Definitions for xattr.h */
 #define __UAPI_DEF_XATTR		1
