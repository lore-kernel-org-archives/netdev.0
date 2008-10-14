From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 14/14] pkt_sched: sch_generic: Purge qdisc->requeue list in
	qdisc_reset().
Date: Tue, 14 Oct 2008 09:55:41 +0000
Message-ID: <20081014095541.GO10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197AbYJNJzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:55:46 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:55:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: sch_generic: Purge qdisc->requeue list in qdisc_reset().

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_generic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9560ea1..eceec2f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -504,6 +504,7 @@ void qdisc_reset(struct Qdisc *qdisc)
 {
 	const struct Qdisc_ops *ops = qdisc->ops;
 
+	__skb_queue_purge(&qdisc->requeue);
 	if (ops->reset)
 		ops->reset(qdisc);
 }
-- 
1.5.6.5

