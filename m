From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV{4,6}: Normalize jiffies reported to userspace in
 routing code (missing pieces)
Date: Mon, 10 Nov 2003 10:50:23 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110.105023.116811039.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry, I failed to fix these bits.

===== net/ipv4/route.c 1.74 vs edited =====
--- 1.74/net/ipv4/route.c	Mon Nov 10 12:26:48 2003
+++ edited/net/ipv4/route.c	Tue Nov 11 01:43:28 2003
@@ -2306,7 +2306,7 @@
 		RTA_PUT(skb, RTA_GATEWAY, 4, &rt->rt_gateway);
 	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
 		goto rtattr_failure;
-	ci.rta_lastuse	= jiffies - rt->u.dst.lastuse;
+	ci.rta_lastuse	= jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
 	ci.rta_used	= rt->u.dst.__use;
 	ci.rta_clntref	= atomic_read(&rt->u.dst.__refcnt);
 	if (rt->u.dst.expires)
===== net/ipv6/route.c 1.59 vs edited =====
--- 1.59/net/ipv6/route.c	Mon Nov 10 12:26:48 2003
+++ edited/net/ipv6/route.c	Tue Nov 11 01:42:00 2003
@@ -1534,7 +1534,7 @@
 	if (rt->u.dst.dev)
 		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->rt6i_dev->ifindex);
 	RTA_PUT(skb, RTA_PRIORITY, 4, &rt->rt6i_metric);
-	ci.rta_lastuse = jiffies - rt->u.dst.lastuse;
+	ci.rta_lastuse = jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
 	if (rt->rt6i_expires)
 		ci.rta_expires = jiffies_to_clock_t(rt->rt6i_expires - jiffies);
 	else

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
