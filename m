From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net/sched/hfsc: allocate tcf block for hfsc root class
Date: Thu, 10 Aug 2017 12:31:40 +0300
Message-ID: <150235750037.493227.16245118631720190134.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1h.cmail.yandex.net ([87.250.230.216]:33110 "EHLO
        forwardcorp1h.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752002AbdHJJjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 05:39:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this filters cannot be attached.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")
---
 net/sched/sch_hfsc.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index b52f74610dc7..3ad02bbe6903 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1428,6 +1428,10 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 		return err;
 	q->eligible = RB_ROOT;
 
+	err = tcf_block_get(&q->root.block, &q->root.filter_list);
+	if (err)
+		goto err_tcf;
+
 	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
 	q->root.sched   = q;
@@ -1447,6 +1451,10 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	qdisc_watchdog_init(&q->watchdog, sch);
 
 	return 0;
+
+err_tcf:
+	qdisc_class_hash_destroy(&q->clhash);
+	return err;
 }
 
 static int
