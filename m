From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_htb: do not report fake rate estimators
Date: Fri, 21 Oct 2016 09:02:43 -0700
Message-ID: <1477065763.7065.84.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Kosina <jikos@kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34209 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753953AbcJUQCp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 12:02:45 -0400
Received: by mail-pf0-f195.google.com with SMTP id 128so9014787pfz.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 09:02:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When I prepared commit d250a5f90e53 ("pkt_sched: gen_estimator: Dont
report fake rate estimators"), htb still had an implicit rate estimator
for all its classes.

Then later, I made this rate estimator optional in commit 64153ce0a7b6
("net_sched: htb: do not setup default rate estimators"), but I forgot
to update htb use of gnet_stats_copy_rate_est()

After this patch, "tc -s qdisc ..." no longer report fake rate
estimators for HTB classes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_htb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c798d0de8a9daf067cae2485ad6bfeeac039efb0..9926fe4f3b6f7db9aeba22fbbfae3d47c4e2af60 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1145,7 +1145,7 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 
 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
 				  d, NULL, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &qs, qlen) < 0)
 		return -1;
 
