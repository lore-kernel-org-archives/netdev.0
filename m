From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: remove internal use of TC_POLICE_*
Date: Mon, 13 Jun 2016 10:47:43 -0700
Message-ID: <1465840064-7650-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34082 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161277AbcFMRrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:47:49 -0400
Received: by mail-pf0-f195.google.com with SMTP id 66so9200442pfy.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:47:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These should be gone when we removed CONFIG_NET_CLS_POLICE.
We can not totally remove them since they are exposed
to userspace.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_ipt.c | 2 +-
 net/sched/sch_atm.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index e7c0f4d..8998a35 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -243,7 +243,7 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 	default:
 		net_notice_ratelimited("tc filter: Bogus netfilter code %d assume ACCEPT\n",
 				       ret);
-		result = TC_POLICE_OK;
+		result = TC_ACT_OK;
 		break;
 	}
 	spin_unlock(&ipt->tcf_lock);
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 0785b23..e04ea69 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -366,7 +366,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 
 	pr_debug("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
-	result = TC_POLICE_OK;	/* be nice to gcc */
+	result = TC_ACT_OK;	/* be nice to gcc */
 	flow = NULL;
 	if (TC_H_MAJ(skb->priority) != sch->handle ||
 	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority))) {
@@ -403,7 +403,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		case TC_ACT_SHOT:
 			kfree_skb(skb);
 			goto drop;
-		case TC_POLICE_RECLASSIFY:
+		case TC_ACT_RECLASSIFY:
 			if (flow->excess)
 				flow = flow->excess;
 			else
-- 
2.1.0
