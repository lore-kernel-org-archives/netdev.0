From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] DECNET: Normalize jiffies reported to userspace
Date: Mon, 10 Nov 2003 10:48:43 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110.104843.65576225.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

jiffies normalization for decnet.

===== net/decnet/dn_route.c 1.18 vs edited =====
--- 1.18/net/decnet/dn_route.c	Wed Jul 23 15:33:06 2003
+++ edited/net/decnet/dn_route.c	Tue Nov 11 01:31:31 2003
@@ -77,6 +77,7 @@
 #include <linux/string.h>
 #include <linux/netfilter_decnet.h>
 #include <linux/rcupdate.h>
+#include <linux/times.h>
 #include <asm/errno.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
@@ -1508,11 +1509,11 @@
 		RTA_PUT(skb, RTA_GATEWAY, 2, &rt->rt_gateway);
 	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
 		goto rtattr_failure;
-	ci.rta_lastuse = jiffies - rt->u.dst.lastuse;
+	ci.rta_lastuse = jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
 	ci.rta_used     = rt->u.dst.__use;
 	ci.rta_clntref  = atomic_read(&rt->u.dst.__refcnt);
 	if (rt->u.dst.expires)
-		ci.rta_expires = rt->u.dst.expires - jiffies;
+		ci.rta_expires = jiffies_to_clock_t(rt->u.dst.expires - jiffies);
 	else
 		ci.rta_expires = 0;
 	ci.rta_error    = rt->u.dst.error;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
