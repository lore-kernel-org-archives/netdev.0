From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] Misc. Trivial Patches
Date: Thu, 29 Jul 2004 02:16:43 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729.021643.25787950.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Here's misc. patches.
Also available at <bk://bk.skbuff.net:20608/linux-2.6-misc/>.

Thanks.

DIFFSTAT
--------
 include/linux/icmpv6.h |   32 +++++++++++++++++++++-----------
 include/net/addrconf.h |    4 ++--
 net/ipv6/af_inet6.c    |    2 --
 net/ipv6/icmp.c        |    6 ++++++
 4 files changed, 29 insertions(+), 15 deletions(-)

CHANGESET
---------
ChangeSet@1.1857, 2004-07-29 02:00:59+09:00, yoshfuji@linux-ipv6.org
  [IPV6] fix typoes in macro definitions.
  
  Signed-Off-By: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/addrconf.h b/include/net/addrconf.h
--- a/include/net/addrconf.h	2004-07-29 02:08:20 +09:00
+++ b/include/net/addrconf.h	2004-07-29 02:08:20 +09:00
@@ -160,8 +160,8 @@
 		inet6_ifa_finish_destroy(ifp);
 }
 
-#define __in6_ifa_put(idev)  atomic_dec(&(idev)->refcnt)
-#define in6_ifa_hold(idev)   atomic_inc(&(idev)->refcnt)
+#define __in6_ifa_put(ifp)	atomic_dec(&(ifp)->refcnt)
+#define in6_ifa_hold(ifp)	atomic_inc(&(ifp)->refcnt)
 
 
 extern void			addrconf_forwarding_on(void);


ChangeSet@1.1858, 2004-07-29 02:02:25+09:00, yoshfuji@linux-ipv6.org
  [IPV6] remove unused macro.

diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-07-29 02:08:23 +09:00
+++ b/net/ipv6/af_inet6.c	2004-07-29 02:08:23 +09:00
@@ -560,8 +560,6 @@
 	.flags		= INET_PROTOSW_REUSE,
 };
 
-#define INETSW6_ARRAY_LEN (sizeof(inetsw6_array) / sizeof(struct inet_protosw))
-
 void
 inet6_register_protosw(struct inet_protosw *p)
 {


ChangeSet@1.1859, 2004-07-29 02:04:10+09:00, yoshfuji@linux-ipv6.org
  [IPV6] fix the order of icmpv6 definitions for consistency.
  
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/linux/icmpv6.h b/include/linux/icmpv6.h
--- a/include/linux/icmpv6.h	2004-07-29 02:08:26 +09:00
+++ b/include/linux/icmpv6.h	2004-07-29 02:08:26 +09:00
@@ -85,18 +85,7 @@
 #define ICMPV6_MGM_QUERY		130
 #define ICMPV6_MGM_REPORT       	131
 #define ICMPV6_MGM_REDUCTION    	132
-
-/* definitions for MLDv2 */
-
-#define MLD2_MODE_IS_INCLUDE	1
-#define MLD2_MODE_IS_EXCLUDE	2
-#define MLD2_CHANGE_TO_INCLUDE	3
-#define MLD2_CHANGE_TO_EXCLUDE	4
-#define MLD2_ALLOW_NEW_SOURCES	5
-#define MLD2_BLOCK_OLD_SOURCES	6
-
 #define ICMPV6_MLD2_REPORT		143
-#define MLD2_ALL_MCR_INIT { { { 0xff,0x02,0,0,0,0,0,0,0,0,0,0,0,0,0,0x16 } } }
 
 /*
  *	Codes for Destination Unreachable
@@ -138,6 +127,18 @@
 struct icmp6_filter {
 	__u32		data[8];
 };
+
+/*
+ *	Definitions for MLDv2
+ */
+#define MLD2_MODE_IS_INCLUDE	1
+#define MLD2_MODE_IS_EXCLUDE	2
+#define MLD2_CHANGE_TO_INCLUDE	3
+#define MLD2_CHANGE_TO_EXCLUDE	4
+#define MLD2_ALLOW_NEW_SOURCES	5
+#define MLD2_BLOCK_OLD_SOURCES	6
+
+#define MLD2_ALL_MCR_INIT { { { 0xff,0x02,0,0,0,0,0,0,0,0,0,0,0,0,0,0x16 } } }
 
 #ifdef __KERNEL__
 


ChangeSet@1.1860, 2004-07-29 02:07:10+09:00, yoshfuji@linux-ipv6.org
  [IPV6] add missing known icmpv6 types.
  
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/linux/icmpv6.h b/include/linux/icmpv6.h
--- a/include/linux/icmpv6.h	2004-07-29 02:08:29 +09:00
+++ b/include/linux/icmpv6.h	2004-07-29 02:08:29 +09:00
@@ -85,7 +85,16 @@
 #define ICMPV6_MGM_QUERY		130
 #define ICMPV6_MGM_REPORT       	131
 #define ICMPV6_MGM_REDUCTION    	132
+
+#define ICMPV6_NI_QUERY			139
+#define ICMPV6_NI_REPLY			140
+
 #define ICMPV6_MLD2_REPORT		143
+
+#define ICMPV6_DHAAD_REQUEST		144
+#define ICMPV6_DHAAD_REPLY		145
+#define ICMPV6_MOBILE_PREFIX_SOL	146
+#define ICMPV6_MOBILE_PREFIX_ADV	147
 
 /*
  *	Codes for Destination Unreachable
diff -Nru a/net/ipv6/icmp.c b/net/ipv6/icmp.c
--- a/net/ipv6/icmp.c	2004-07-29 02:08:29 +09:00
+++ b/net/ipv6/icmp.c	2004-07-29 02:08:29 +09:00
@@ -646,7 +646,13 @@
 		break;
 
 	case ICMPV6_MGM_REDUCTION:
+	case ICMPV6_NI_QUERY:
+	case ICMPV6_NI_REPLY:
 	case ICMPV6_MLD2_REPORT:
+	case ICMPV6_DHAAD_REQUEST:
+	case ICMPV6_DHAAD_REPLY:
+	case ICMPV6_MOBILE_PREFIX_SOL:
+	case ICMPV6_MOBILE_PREFIX_ADV:
 		break;
 
 	default:



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
