From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net_sched: always reset qdisc backlog in qdisc_reset()
Date: Wed, 20 Sep 2017 15:45:36 +0300
Message-ID: <150591153693.113604.8604505743746410801.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1j.cmail.yandex.net ([5.255.227.106]:60649 "EHLO
        forwardcorp1j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751554AbdITMpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 08:45:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SKB stored in qdisc->gso_skb also counted into backlog.

Some qdiscs don't reset backlog to zero in ->reset(),
for example sfq just dequeue and free all queued skb.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
---
 net/sched/sch_generic.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 92237e75dbbc..bf8c81e07c70 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -685,6 +685,7 @@ void qdisc_reset(struct Qdisc *qdisc)
 		qdisc->gso_skb = NULL;
 	}
 	qdisc->q.qlen = 0;
+	qdisc->qstats.backlog = 0;
 }
 EXPORT_SYMBOL(qdisc_reset);
 
