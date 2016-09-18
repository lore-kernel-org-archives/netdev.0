From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 1/1] net sched actions police: peg drop stats for conforming traffic
Date: Sun, 18 Sep 2016 07:53:08 -0400
Message-ID: <1474199588-11032-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34029 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753192AbcIRLxR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 07:53:17 -0400
Received: by mail-io0-f194.google.com with SMTP id y139so3742314ioy.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 04:53:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>

setting conforming action to drop is a valid policy.
When it is set we need to at least see the stats indicating it
for debugging.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_police.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 8a3be1d..ba7074b 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -249,6 +249,8 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 			police->tcfp_t_c = now;
 			police->tcfp_toks = toks;
 			police->tcfp_ptoks = ptoks;
+			if (police->tcfp_result == TC_ACT_SHOT)
+				police->tcf_qstats.drops++;
 			spin_unlock(&police->tcf_lock);
 			return police->tcfp_result;
 		}
-- 
1.9.1
