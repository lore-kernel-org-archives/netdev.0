From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: kill in6_u.u6_addrX
Date: Thu, 12 Feb 2004 14:00:22 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040212.140022.128605177.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

There're still two in6_u.u6_addrX in the tree.
(I've grep'ed the tree.)

D: kill in6_u.u6_addrX and use s6_addrX instead.

Thanks.

===== net/ipv6/addrconf.c 1.91 vs edited =====
--- 1.91/net/ipv6/addrconf.c	Tue Feb  3 03:31:58 2004
+++ edited/net/ipv6/addrconf.c	Thu Feb 12 13:45:34 2004
@@ -231,7 +231,7 @@
 
 	if ((addr->s6_addr32[0] | addr->s6_addr32[1]) == 0) {
 		if (addr->s6_addr32[2] == 0) {
-			if (addr->in6_u.u6_addr32[3] == 0)
+			if (addr->s6_addr32[3] == 0)
 				return IPV6_ADDR_ANY;
 
 			if (addr->s6_addr32[3] == htonl(0x00000001))
===== net/ipv6/netfilter/ip6t_eui64.c 1.4 vs edited =====
--- 1.4/net/ipv6/netfilter/ip6t_eui64.c	Thu Jan 29 08:59:34 2004
+++ edited/net/ipv6/netfilter/ip6t_eui64.c	Thu Feb 12 13:46:24 2004
@@ -50,7 +50,7 @@
 	 eui64[0] |= 0x02;
 
 	 i=0;
-	 while ((skb->nh.ipv6h->saddr.in6_u.u6_addr8[8+i] ==
+	 while ((skb->nh.ipv6h->saddr.s6_addr[8+i] ==
 			 eui64[i]) && (i<8)) i++;
 
 	 if ( i == 8 )

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
