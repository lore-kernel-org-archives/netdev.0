From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6]: kill needless initialization and comparison.
Date: Wed, 19 Jan 2005 14:18:17 +0900 (JST)
Message-ID: <20050119.141817.84595066.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I believe that compilers are clever enough, but anyway...

Thanks.

----
[IPV6] kill needless initialization and comparison.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/icmp.c b/net/ipv6/icmp.c
--- a/net/ipv6/icmp.c	2005-01-19 14:10:16 +09:00
+++ b/net/ipv6/icmp.c	2005-01-19 14:10:16 +09:00
@@ -287,7 +287,7 @@
 	int iif = 0;
 	int addr_type = 0;
 	int len;
-	int hlimit = -1;
+	int hlimit;
 	int err = 0;
 
 	if ((u8*)hdr < skb->head || (u8*)(hdr+1) > skb->tail)
@@ -375,14 +375,12 @@
 	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
 		goto out_dst_release;
 
-	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl.fl6_dst))
-			hlimit = np->mcast_hops;
-		else
-			hlimit = np->hop_limit;
-		if (hlimit < 0)
-			hlimit = dst_metric(dst, RTAX_HOPLIMIT);
-	}
+	if (ipv6_addr_is_multicast(&fl.fl6_dst))
+		hlimit = np->mcast_hops;
+	else
+		hlimit = np->hop_limit;
+	if (hlimit < 0)
+		hlimit = dst_metric(dst, RTAX_HOPLIMIT);
 
 	msg.skb = skb;
 	msg.offset = skb->nh.raw - skb->data;
@@ -433,7 +431,7 @@
 	struct icmpv6_msg msg;
 	struct dst_entry *dst;
 	int err = 0;
-	int hlimit = -1;
+	int hlimit;
 
 	saddr = &skb->nh.ipv6h->daddr;
 
@@ -463,14 +461,12 @@
 	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
 		goto out_dst_release;
 
-	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl.fl6_dst))
-			hlimit = np->mcast_hops;
-		else
-			hlimit = np->hop_limit;
-		if (hlimit < 0)
-			hlimit = dst_metric(dst, RTAX_HOPLIMIT);
-	}
+	if (ipv6_addr_is_multicast(&fl.fl6_dst))
+		hlimit = np->mcast_hops;
+	else
+		hlimit = np->hop_limit;
+	if (hlimit < 0)
+		hlimit = dst_metric(dst, RTAX_HOPLIMIT);
 
 	idev = in6_dev_get(skb->dev);
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
