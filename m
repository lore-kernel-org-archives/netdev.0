From: akpm@osdl.org
Subject: [patch 6/18] gcc-3.5: ipv6/ndisc.c fixes
Date: Sun, 25 Jan 2004 03:07:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7Go25072@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/ipv6/ndisc.c: In function `ndisc_send_na':
net/ipv6/ndisc.c:478: warning: use of cast expressions as lvalues is deprecated



---

 net/ipv6/ndisc.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff -puN net/ipv6/ndisc.c~gcc-35-ip6-ndisc-fix net/ipv6/ndisc.c
--- 25/net/ipv6/ndisc.c~gcc-35-ip6-ndisc-fix	2004-01-19 13:36:19.000000000 -0800
+++ 25-akpm/net/ipv6/ndisc.c	2004-01-19 13:36:19.000000000 -0800
@@ -475,7 +475,8 @@ static void ndisc_send_na(struct net_dev
 	skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
 	ip6_nd_hdr(sk, skb, dev, src_addr, daddr, IPPROTO_ICMPV6, len);
 
-	skb->h.raw = (unsigned char*) msg = (struct nd_msg *) skb_put(skb, len);
+	msg = (struct nd_msg *)skb_put(skb, len);
+	skb->h.raw = (unsigned char*)msg;
 
         msg->icmph.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
         msg->icmph.icmp6_code = 0;
@@ -559,7 +560,8 @@ void ndisc_send_ns(struct net_device *de
 	skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
 
-	skb->h.raw = (unsigned char*) msg = (struct nd_msg *)skb_put(skb, len);
+	msg = (struct nd_msg *)skb_put(skb, len);
+	skb->h.raw = (unsigned char*)msg;
 	msg->icmph.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION;
 	msg->icmph.icmp6_code = 0;
 	msg->icmph.icmp6_cksum = 0;
@@ -630,7 +632,8 @@ void ndisc_send_rs(struct net_device *de
 	skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
 
-        skb->h.raw = (unsigned char*) hdr = (struct icmp6hdr *) skb_put(skb, len);
+        hdr = (struct icmp6hdr *)skb_put(skb, len);
+        skb->h.raw = (unsigned char*)hdr;
         hdr->icmp6_type = NDISC_ROUTER_SOLICITATION;
         hdr->icmp6_code = 0;
         hdr->icmp6_cksum = 0;
@@ -1374,7 +1377,8 @@ void ndisc_send_redirect(struct sk_buff 
 	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &skb->nh.ipv6h->saddr,
 		   IPPROTO_ICMPV6, len);
 
-	buff->h.raw = (unsigned char*) icmph = (struct icmp6hdr *) skb_put(buff, len);
+	icmph = (struct icmp6hdr *)skb_put(buff, len);
+	buff->h.raw = (unsigned char*)icmph;
 
 	memset(icmph, 0, sizeof(struct icmp6hdr));
 	icmph->icmp6_type = NDISC_REDIRECT;

_
