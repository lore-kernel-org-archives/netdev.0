From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV4] LL_RESERVED_SPACE
Date: Mon, 09 Feb 2004 13:44:13 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209.134413.98076915.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: [IPV4] Use LL_RESERVED_SPACE() where appricable

===== net/ipv4/igmp.c 1.47 vs edited =====
--- 1.47/net/ipv4/igmp.c	Tue Feb  3 08:43:31 2004
+++ edited/net/ipv4/igmp.c	Mon Feb  9 12:44:46 2004
@@ -276,7 +276,7 @@
 	struct iphdr *pip;
 	struct igmpv3_report *pig;
 
-	skb = alloc_skb(size + dev->hard_header_len + 15, GFP_ATOMIC);
+	skb = alloc_skb(size + LL_RESERVED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
 		return 0;
 
@@ -298,7 +298,7 @@
 	skb->dst = &rt->u.dst;
 	skb->dev = dev;
 
-	skb_reserve(skb, (dev->hard_header_len+15)&~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 
 	skb->nh.iph = pip =(struct iphdr *)skb_put(skb, sizeof(struct iphdr)+4);
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
