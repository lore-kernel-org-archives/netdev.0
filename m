From: latten@austin.ibm.com
Subject: PATCH: IPSecv6 in tunnel won't work with ext hdrs
Date: Mon, 30 Jun 2003 14:06:58 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306301906.h5UJ6wwV000537@faith.austin.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I noticed that using extensions headers along with IPsecv6 tunnel mode did
not work in 2.5.73 + patch-2.5.73-bk3. The following patch
checks "nexthdr" instead of "iph->nexthdr" which could be an
extension header. I tested this with tunnel mode and transport mode
with and without extension headers and it worked ok.

Let me know if it is ok.

Joy Latten

-----------------------------------------------------------------------


--- xfrm6_input.c.orig	2003-06-30 11:04:31.000000000 -0500
+++ xfrm6_input.c	2003-06-30 11:09:27.000000000 -0500
@@ -67,10 +67,8 @@
 
 		xfrm_vec[xfrm_nr++].xvec = x;
 
-		iph = skb->nh.ipv6h;
-
 		if (x->props.mode) { /* XXX */
-			if (iph->nexthdr != IPPROTO_IPV6)
+			if (nexthdr != IPPROTO_IPV6)
 				goto drop;
 			skb->nh.raw = skb->data;
 			iph = skb->nh.ipv6h;
