From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: atm: destroy main filter chain
Date: Fri, 24 Mar 2017 14:39:49 +0100
Message-ID: <1490362789-7293-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34751 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbdCXNkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 09:40:14 -0400
Received: by mail-wm0-f65.google.com with SMTP id u132so661781wmg.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 06:39:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In atm_tc_destroy, the flow qdisc filter chains are destroyed. However
the main chain is not. So fix this memory and reference leak.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
Sending this for net-next because this is present at least from the
beginning of git epoch. Feel free to apply on -net, however I don't have
"Fixes: " :)
---
 net/sched/sch_atm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 2209c2d..56421da 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -560,6 +560,9 @@ static void atm_tc_destroy(struct Qdisc *sch)
 	struct atm_flow_data *flow, *tmp;
 
 	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
+
+	tcf_destroy_chain(&p->link.filter_list);
+
 	list_for_each_entry(flow, &p->flows, list)
 		tcf_destroy_chain(&flow->filter_list);
 
-- 
2.7.4
