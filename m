From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: Fixed fragment check in ip6_output.c:ip6_fragment()
Date: Thu, 26 Jun 2003 20:55:40 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626.205540.83592923.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, miyazawa@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

MTU / alignment check in ip6_fragment() was wrong;
first_len was not correct.

Thanks.

Index: linux-2.5/net/ipv6/ip6_output.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_output.c,v
retrieving revision 1.29
diff -u -p -r1.29 ip6_output.c
--- linux-2.5/net/ipv6/ip6_output.c	21 Jun 2003 16:20:41 -0000	1.29
+++ linux-2.5/net/ipv6/ip6_output.c	26 Jun 2003 10:28:17 -0000
@@ -939,7 +939,7 @@ static int ip6_fragment(struct sk_buff *
 	mtu = dst_pmtu(&rt->u.dst) - hlen - sizeof(struct frag_hdr);
 
 	if (skb_shinfo(skb)->frag_list) {
-		int first_len = 0;
+		int first_len = skb_pagelen(skb);
 
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
