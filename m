From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NETFILTER] LL_RESERVED_SPACE
Date: Mon, 09 Feb 2004 13:44:18 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209.134418.72875541.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: [NETFILTER] Use LL_RESERVED_SPACE() where appricable.

===== net/ipv4/netfilter/ipt_REJECT.c 1.26 vs edited =====
--- 1.26/net/ipv4/netfilter/ipt_REJECT.c	Fri Jan 30 10:00:13 2004
+++ edited/net/ipv4/netfilter/ipt_REJECT.c	Mon Feb  9 12:47:03 2004
@@ -117,7 +117,7 @@
 	if ((rt = route_reverse(oldskb, hook)) == NULL)
 		return;
 
-	hh_len = (rt->u.dst.dev->hard_header_len + 15)&~15;
+	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
 	/* We need a linear, writeable skb.  We also need to expand
 	   headroom in case hh_len of incoming interface < hh_len of
@@ -305,9 +305,9 @@
 	if (length > 576)
 		length = 576;
 
-	hh_len = (rt->u.dst.dev->hard_header_len + 15)&~15;
+	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
-	nskb = alloc_skb(hh_len+15+length, GFP_ATOMIC);
+	nskb = alloc_skb(hh_len + length, GFP_ATOMIC);
 	if (!nskb) {
 		ip_rt_put(rt);
 		return;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
