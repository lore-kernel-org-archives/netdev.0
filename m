From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] fix flags for ndisc dst
Date: Mon, 05 Jul 2004 16:28:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705.162838.67048785.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Because RTF_LOCAL is for local unicast address, 
it was wrong to set RTF_LOCAL to ndisc dst.
This patch also adds some comment on other fields.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/route.c 1.76 vs edited =====
--- 1.76/net/ipv6/route.c	2004-06-13 02:51:53 +09:00
+++ edited/net/ipv6/route.c	2004-07-05 16:24:14 +09:00
@@ -605,14 +605,19 @@
 	rt->rt6i_dev	  = dev;
 	rt->rt6i_idev     = in6_dev_get(dev);
 	rt->rt6i_nexthop  = neigh;
-	rt->rt6i_expires  = 0;
-	rt->rt6i_flags    = RTF_LOCAL;
-	rt->rt6i_metric   = 0;
 	atomic_set(&rt->u.dst.__refcnt, 1);
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
 	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&rt->u.dst));
 	rt->u.dst.output  = output;
+
+#if 0	/* there's no chance to use these for ndisc */
+	rt->u.dst.flags   = ipv6_addr_type(addr) & IPV6_ADDR_UNICAST 
+				? DST_HOST 
+				: 0;
+	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
+	rt->rt6i_dst.plen = 128;
+#endif
 
 	write_lock_bh(&rt6_lock);
 	rt->u.dst.next = ndisc_dst_gc_list;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
