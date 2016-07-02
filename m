From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 3/3] net sched actions: skbedit convert to use more modern nla_put_xxx
Date: Sat,  2 Jul 2016 06:43:16 -0400
Message-ID: <1467456196-25712-3-git-send-email-jhs@emojatatu.com>
References: <1467456196-25712-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, fw@strlen.de,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35113 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbcGBKnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 06:43:32 -0400
Received: by mail-it0-f67.google.com with SMTP id g127so4520236ith.2
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 03:43:31 -0700 (PDT)
In-Reply-To: <1467456196-25712-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_skbedit.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 1c4c924..8e573c0 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -170,20 +170,16 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	if (nla_put(skb, TCA_SKBEDIT_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 	if ((d->flags & SKBEDIT_F_PRIORITY) &&
-	    nla_put(skb, TCA_SKBEDIT_PRIORITY, sizeof(d->priority),
-		    &d->priority))
+	    nla_put_u32(skb, TCA_SKBEDIT_PRIORITY, d->priority))
 		goto nla_put_failure;
 	if ((d->flags & SKBEDIT_F_QUEUE_MAPPING) &&
-	    nla_put(skb, TCA_SKBEDIT_QUEUE_MAPPING,
-		    sizeof(d->queue_mapping), &d->queue_mapping))
+	    nla_put_u16(skb, TCA_SKBEDIT_QUEUE_MAPPING, d->queue_mapping))
 		goto nla_put_failure;
 	if ((d->flags & SKBEDIT_F_MARK) &&
-	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
-		    &d->mark))
+	    nla_put_u32(skb, TCA_SKBEDIT_MARK, d->mark))
 		goto nla_put_failure;
 	if ((d->flags & SKBEDIT_F_PTYPE) &&
-	    nla_put(skb, TCA_SKBEDIT_PTYPE, sizeof(d->ptype),
-		    &d->ptype))
+	    nla_put_u16(skb, TCA_SKBEDIT_PTYPE, d->ptype))
 		goto nla_put_failure;
 
 	tcf_tm_dump(&t, &d->tcf_tm);
-- 
1.9.1
