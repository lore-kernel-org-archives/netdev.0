From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: fix a potential use after free in ip6_offload.c
Date: Sat, 18 Oct 2014 17:27:42 +0800
Message-ID: <1413624462-13106-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54374 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaJRJ1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 05:27:46 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so2202591pab.24
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 02:27:46 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id dl1sm3622646pbc.16.2014.10.18.02.27.44
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 18 Oct 2014 02:27:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() maybe change skb->data and make opth pointer oboslete,
so set the opth again

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/ip6_offload.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 9034f76..91014d3 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -46,6 +46,7 @@ static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
 		if (unlikely(!pskb_may_pull(skb, len)))
 			break;
 
+		opth = (void *)skb->data;
 		proto = opth->nexthdr;
 		__skb_pull(skb, len);
 	}
-- 
1.7.10.4
