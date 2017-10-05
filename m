From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH] net: ipv6: remove unused code in ipv6_find_hdr()
Date: Fri,  6 Oct 2017 02:07:08 +0800
Message-ID: <1507226828-51366-1-git-send-email-xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org, Lin Zhang <xiaolou4617@gmail.com>
To: kuznet@ms2.inr.ac.ru, davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35098 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdJEKHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:07:42 -0400
Received: by mail-pg0-f68.google.com with SMTP id p5so13066604pgn.2
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 03:07:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Storing the left length of skb into 'len' actually has no effect 
so we can remove it.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
 net/ipv6/exthdrs_core.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 305e2ed..98096ea 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -187,7 +187,6 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 {
 	unsigned int start = skb_network_offset(skb) + sizeof(struct ipv6hdr);
 	u8 nexthdr = ipv6_hdr(skb)->nexthdr;
-	unsigned int len;
 	bool found;
 
 	if (fragoff)
@@ -204,7 +203,6 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 		start = *offset + sizeof(struct ipv6hdr);
 		nexthdr = ip6->nexthdr;
 	}
-	len = skb->len - start;
 
 	do {
 		struct ipv6_opt_hdr _hdr, *hp;
@@ -273,7 +271,6 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 
 		if (!found) {
 			nexthdr = hp->nexthdr;
-			len -= hdrlen;
 			start += hdrlen;
 		}
 	} while (!found);
-- 
1.8.3.1
