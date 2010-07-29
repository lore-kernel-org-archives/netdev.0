From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_nat: get the position info from skb->tc_verd
Date: Fri, 30 Jul 2010 02:42:32 +0800
Message-ID: <1280428952-14151-1-git-send-email-xiaosuo@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35145 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755750Ab0G3CPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 22:15:20 -0400
Received: by pvc7 with SMTP id 7so358894pvc.19
        for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 19:15:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

act_nat uses its flags field to determine where it acts. It isn't reliable,
and can't prevent users from doing wrong settings, and act_nat should get the
position info from skb->tc_verd as act_mirred does.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/net/tc_act/tc_nat.h |    2 +-
 net/sched/act_nat.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
diff --git a/include/net/tc_act/tc_nat.h b/include/net/tc_act/tc_nat.h
index 4a691f3..343376a 100644
--- a/include/net/tc_act/tc_nat.h
+++ b/include/net/tc_act/tc_nat.h
@@ -10,7 +10,7 @@ struct tcf_nat {
 	__be32 old_addr;
 	__be32 new_addr;
 	__be32 mask;
-	u32 flags;
+	u32 flags;	/* unused */
 };
 
 static inline struct tcf_nat *to_tcf_nat(struct tcf_common *pc)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 24e614c..144e118 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -121,7 +121,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	old_addr = p->old_addr;
 	new_addr = p->new_addr;
 	mask = p->mask;
-	egress = p->flags & TCA_NAT_FLAG_EGRESS;
+	egress = G_TC_AT(skb->tc_verd) & AT_EGRESS;
 	action = p->tcf_action;
 
 	p->tcf_bstats.bytes += qdisc_pkt_len(skb);
