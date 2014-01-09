From: Terry Lam <vtlam@google.com>
Subject: [PATCH] HHF qdisc: fix jiffies-time conversion.
Date: Thu,  9 Jan 2014 00:40:00 -0800
Message-ID: <1389256800-18809-1-git-send-email-vtlam@google.com>
Cc: netdev@vger.kernel.org, Nandita Dukkipati <nanditad@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Terry Lam <vtlam@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:56404 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbaAIIp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 03:45:57 -0500
Received: by mail-ie0-f201.google.com with SMTP id at1so681771iec.4
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 00:45:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to be compatible with the use of "get_time" (i.e. default
time unit in us) in iproute2 patch for HHF as requested by Stephen.

Signed-off-by: Terry Lam <vtlam@google.com>
---
 net/sched/sch_hhf.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index cf7f614..1cf84a9 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -574,18 +574,18 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 		q->hh_flows_limit = nla_get_u32(tb[TCA_HHF_HH_FLOWS_LIMIT]);
 
 	if (tb[TCA_HHF_RESET_TIMEOUT]) {
-		u32 ms = nla_get_u32(tb[TCA_HHF_RESET_TIMEOUT]);
+		u32 us = nla_get_u32(tb[TCA_HHF_RESET_TIMEOUT]);
 
-		q->hhf_reset_timeout = msecs_to_jiffies(ms);
+		q->hhf_reset_timeout = usecs_to_jiffies(us);
 	}
 
 	if (tb[TCA_HHF_ADMIT_BYTES])
 		q->hhf_admit_bytes = nla_get_u32(tb[TCA_HHF_ADMIT_BYTES]);
 
 	if (tb[TCA_HHF_EVICT_TIMEOUT]) {
-		u32 ms = nla_get_u32(tb[TCA_HHF_EVICT_TIMEOUT]);
+		u32 us = nla_get_u32(tb[TCA_HHF_EVICT_TIMEOUT]);
 
-		q->hhf_evict_timeout = msecs_to_jiffies(ms);
+		q->hhf_evict_timeout = usecs_to_jiffies(us);
 	}
 
 	qlen = sch->q.qlen;
@@ -684,10 +684,10 @@ static int hhf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u32(skb, TCA_HHF_QUANTUM, q->quantum) ||
 	    nla_put_u32(skb, TCA_HHF_HH_FLOWS_LIMIT, q->hh_flows_limit) ||
 	    nla_put_u32(skb, TCA_HHF_RESET_TIMEOUT,
-			jiffies_to_msecs(q->hhf_reset_timeout)) ||
+			jiffies_to_usecs(q->hhf_reset_timeout)) ||
 	    nla_put_u32(skb, TCA_HHF_ADMIT_BYTES, q->hhf_admit_bytes) ||
 	    nla_put_u32(skb, TCA_HHF_EVICT_TIMEOUT,
-			jiffies_to_msecs(q->hhf_evict_timeout)) ||
+			jiffies_to_usecs(q->hhf_evict_timeout)) ||
 	    nla_put_u32(skb, TCA_HHF_NON_HH_WEIGHT, q->hhf_non_hh_weight))
 		goto nla_put_failure;
 
-- 
1.8.5.1
