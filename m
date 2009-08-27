From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] ip6tables: Read outside array bounds
Date: Thu, 27 Aug 2009 13:23:00 +0200
Message-ID: <4A966C94.1060703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:43210 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbZH0LRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 07:17:45 -0400
Received: by ewy2 with SMTP id 2so1079274ewy.17
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 04:17:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check bounds before reading from the s6_addr array. It read 1 past
the end at s6_addr[16] and eui64[] was also read 1 past the end.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
index db610ba..7b40a20 100644
--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -43,8 +43,8 @@ eui64_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 			eui64[0] ^= 0x02;
 
 			i = 0;
-			while (ipv6_hdr(skb)->saddr.s6_addr[8 + i] == eui64[i]
-			       && i < 8)
+			while (i < 8 && ipv6_hdr(skb)->saddr.s6_addr[8 + i] ==
+					eui64[i])
 				i++;
 
 			if (i == 8)
