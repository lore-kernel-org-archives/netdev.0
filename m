From: kaber@trash.net
Subject: [PATCH 03/28] netfilter: ipt_REJECT: avoid touching dst ref
Date: Mon,  2 Aug 2010 21:57:20 +0200
Message-ID: <1280779065-9333-4-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35361 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711Ab0HBT55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:57:57 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

We can avoid a pair of atomic ops in ipt_REJECT send_reset()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_REJECT.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 3d0e064..b254daf 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -110,7 +110,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 		addr_type = RTN_LOCAL;
 
 	/* ip_route_me_harder expects skb->dst to be set */
-	skb_dst_set(nskb, dst_clone(skb_dst(oldskb)));
+	skb_dst_set_noref(nskb, skb_dst(oldskb));
 
 	if (ip_route_me_harder(nskb, addr_type))
 		goto free_nskb;
-- 
1.7.1

