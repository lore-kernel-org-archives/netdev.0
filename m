From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET_SCHED] sch_sfq: use del_timer_sync() in sfq_destroy()
Date: Sun, 27 Apr 2008 14:59:21 +0200
Message-ID: <20080427125921.GA7480@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:18287 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbYD0NBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 09:01:34 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1720542nfb.21
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 06:01:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED] sch_sfq: use del_timer_sync() in sfq_destroy()

Let's delete timer reliably in sfq_destroy().


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_sfq.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index a20e2ef..f0463d7 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -521,7 +521,8 @@ static void sfq_destroy(struct Qdisc *sch)
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
 	tcf_destroy_chain(q->filter_list);
-	del_timer(&q->perturb_timer);
+	q->perturb_period = 0;
+	del_timer_sync(&q->perturb_timer);
 }
 
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
