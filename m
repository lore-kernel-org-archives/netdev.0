From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_nat: fix wild pointer
Date: Fri, 30 Jul 2010 07:41:46 +0800
Message-ID: <1280446906-29032-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:49257 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135Ab0G3HOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 03:14:37 -0400
Received: by pzk26 with SMTP id 26so407264pzk.19
        for <netdev@vger.kernel.org>; Fri, 30 Jul 2010 00:14:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pskb_may_pull() may change skb pointers, so adjust icmph after pskb_may_pull().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_nat.c |    1 +
 1 file changed, 1 insertion(+)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 24e614c..b6d7c6f 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -218,6 +218,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph)))
 			goto drop;
 
+		icmph = (void *)(skb_network_header(skb) + ihl);
 		iph = (void *)(icmph + 1);
 		if (egress)
 			addr = iph->daddr;
