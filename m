From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH] net: sched: fix missing free per cpu on qstats
Date: Tue, 05 Jan 2016 09:11:36 -0800
Message-ID: <20160105171136.9063.98710.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34659 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbcAERL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:11:57 -0500
Received: by mail-pf0-f169.google.com with SMTP id e65so170226856pfe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:11:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a qdisc is using per cpu stats (currently just the ingress
qdisc) only the bstats are being freed. This also free's the qstats.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e82a1ad..16bc83b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -658,8 +658,10 @@ static void qdisc_rcu_free(struct rcu_head *head)
 {
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, rcu_head);
 
-	if (qdisc_is_percpu_stats(qdisc))
+	if (qdisc_is_percpu_stats(qdisc)) {
 		free_percpu(qdisc->cpu_bstats);
+		free_percpu(qdisc->cpu_qstats);
+	}
 
 	kfree((char *) qdisc - qdisc->padded);
 }
