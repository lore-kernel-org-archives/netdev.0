From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/2] [IPV{4,6}] Normalize jiffies values reported to
 userspace
Date: Sun, 09 Nov 2003 15:59:52 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031109.155952.106613268.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

[2/2] [IPV{4,6}] Normalize jiffies values reported to userspace

===== net/ipv4/route.c 1.73 vs edited =====
--- 1.73/net/ipv4/route.c	Tue Oct  7 23:54:12 2003
+++ edited/net/ipv4/route.c	Mon Nov 10 06:34:08 2003
@@ -89,6 +89,7 @@
 #include <linux/random.h>
 #include <linux/jhash.h>
 #include <linux/rcupdate.h>
+#include <linux/times.h>
 #include <net/protocol.h>
 #include <net/ip.h>
 #include <net/route.h>
@@ -2309,7 +2310,7 @@
 	ci.rta_used	= rt->u.dst.__use;
 	ci.rta_clntref	= atomic_read(&rt->u.dst.__refcnt);
 	if (rt->u.dst.expires)
-		ci.rta_expires = rt->u.dst.expires - jiffies;
+		ci.rta_expires = jiffies_to_clock_t(rt->u.dst.expires - jiffies);
 	else
 		ci.rta_expires = 0;
 	ci.rta_error	= rt->u.dst.error;
===== net/ipv6/route.c 1.58 vs edited =====
--- 1.58/net/ipv6/route.c	Sun Aug 31 13:26:12 2003
+++ edited/net/ipv6/route.c	Mon Nov 10 06:34:08 2003
@@ -27,6 +27,7 @@
 #include <linux/config.h>
 #include <linux/errno.h>
 #include <linux/types.h>
+#include <linux/times.h>
 #include <linux/socket.h>
 #include <linux/sockios.h>
 #include <linux/net.h>
@@ -717,7 +718,7 @@
 		return -ENOMEM;
 
 	rt->u.dst.obsolete = -1;
-	rt->rt6i_expires = rtmsg->rtmsg_info;
+	rt->rt6i_expires = clock_t_to_jiffies(rtmsg->rtmsg_info);
 	if (nlh && (r = NLMSG_DATA(nlh))) {
 		rt->rt6i_protocol = r->rtm_protocol;
 	} else {
@@ -1535,7 +1536,7 @@
 	RTA_PUT(skb, RTA_PRIORITY, 4, &rt->rt6i_metric);
 	ci.rta_lastuse = jiffies - rt->u.dst.lastuse;
 	if (rt->rt6i_expires)
-		ci.rta_expires = rt->rt6i_expires - jiffies;
+		ci.rta_expires = jiffies_to_clock_t(rt->rt6i_expires - jiffies);
 	else
 		ci.rta_expires = 0;
 	ci.rta_used = rt->u.dst.__use;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
