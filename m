From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: rps: fix the wrong network header pointer
Date: Sun, 22 Aug 2010 00:13:28 +0800
Message-ID: <1282407208-3367-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:39133 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab0HUQNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 12:13:51 -0400
Received: by pwi7 with SMTP id 7so1480276pwi.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 09:13:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__skb_get_rxhash() was broken after the commit:

 commit bfb564e7391340638afe4ad67744a8f3858e7566
 Author: Krishna Kumar <krkumar2@in.ibm.com>
 Date:   Wed Aug 4 06:15:52 2010 +0000

 core: Factor out flow calculation from get_rps_cpu

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index da584f5..4d74d26 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2283,7 +2283,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
 			goto done;
 
-		ip = (struct iphdr *) skb->data + nhoff;
+		ip = (struct iphdr *) (skb->data + nhoff);
 		if (ip->frag_off & htons(IP_MF | IP_OFFSET))
 			ip_proto = 0;
 		else
@@ -2296,7 +2296,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
 			goto done;
 
-		ip6 = (struct ipv6hdr *) skb->data + nhoff;
+		ip6 = (struct ipv6hdr *) (skb->data + nhoff);
 		ip_proto = ip6->nexthdr;
 		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
 		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
