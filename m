From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 02/12] net: sched: free per cpu bstats
Date: Wed, 30 Dec 2015 09:51:30 -0800
Message-ID: <20151230175130.26257.98195.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34327 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbbL3Rvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:51:53 -0500
Received: by mail-pf0-f181.google.com with SMTP id e65so92076366pfe.1
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:51:53 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a qdisc is using per cpu stats only the bstats are being
freed. This also free's the qstats.

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
