From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: typo, unrequired #undef and killing warning
Date: Wed, 04 Jun 2003 15:02:18 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604.150218.69810413.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Ville Nuorvala <vnuorval@tcs.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

- no need to #undef CONFIG_IPV6_SUBTREE
- use braces around "&" and "|".
- fib_repair_tree() is typo.

Thanks.

Index: linux25-LINUS/net/ipv6/ip6_fib.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ip6_fib.c,v
retrieving revision 1.1.1.12
diff -u -r1.1.1.12 ip6_fib.c
--- linux25-LINUS/net/ipv6/ip6_fib.c	26 May 2003 08:04:11 -0000	1.1.1.12
+++ linux25-LINUS/net/ipv6/ip6_fib.c	4 Jun 2003 05:39:49 -0000
@@ -40,7 +40,6 @@
 #include <net/ip6_route.h>
 
 #define RT6_DEBUG 2
-#undef CONFIG_IPV6_SUBTREES
 
 #if RT6_DEBUG >= 3
 #define RT6_TRACE(x...) printk(KERN_DEBUG x)
@@ -594,8 +593,8 @@
 	   is orphan. If it is, shoot it.
 	 */
 st_failure:
-	if (fn && !(fn->fn_flags&RTN_RTINFO|RTN_ROOT))
-		fib_repair_tree(fn);
+	if (fn && !(fn->fn_flags&(RTN_RTINFO|RTN_ROOT)))
+		fib6_repair_tree(fn);
 	dst_free(&rt->u.dst);
 	return err;
 #endif

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
