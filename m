From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 29/31: ip6t_eui: fix read outside array bounds
Date: Thu, 10 Sep 2009 18:12:24 +0200 (MEST)
Message-ID: <20090910161219.31179.52997.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64716 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbZIJQMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:12:21 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 488908696971c5ea1dcc5d13f29c158ba4f6ae7d
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Aug 31 15:30:31 2009 +0200

    netfilter: ip6t_eui: fix read outside array bounds
    
    Use memcmp() instead of open coded comparison that reads one byte past
    the intended end.
    
    Based on patch from Roel Kluin <roel.kluin@gmail.com>
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
index db610ba..ca287f6 100644
--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -23,7 +23,6 @@ static bool
 eui64_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	unsigned char eui64[8];
-	int i = 0;
 
 	if (!(skb_mac_header(skb) >= skb->head &&
 	      skb_mac_header(skb) + ETH_HLEN <= skb->data) &&
@@ -42,12 +41,8 @@ eui64_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 			eui64[4] = 0xfe;
 			eui64[0] ^= 0x02;
 
-			i = 0;
-			while (ipv6_hdr(skb)->saddr.s6_addr[8 + i] == eui64[i]
-			       && i < 8)
-				i++;
-
-			if (i == 8)
+			if (!memcmp(ipv6_hdr(skb)->saddr.s6_addr + 8, eui64,
+				    sizeof(eui64)))
 				return true;
 		}
 	}
