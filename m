From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] sfq: timer is deferrable
Date: Fri, 18 Jan 2008 16:11:16 -0800
Message-ID: <20080118161116.1cd752d3@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55087 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757317AbYASAf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 19:35:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The perturbation timer used for re-keying can be deferred, it doesn't
need to be deterministic.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_sfq.c	2008-01-17 08:29:24.000000000 -0800
+++ b/net/sched/sch_sfq.c	2008-01-17 09:00:58.000000000 -0800
@@ -426,7 +426,9 @@ static int sfq_init(struct Qdisc *sch, s
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	int i;
 
-	setup_timer(&q->perturb_timer, sfq_perturbation, (unsigned long)sch);
+	q->perturb_timer.function = sfq_perturbation;
+	q->perturb_timer.data = (unsigned long)sch;;
+	init_timer_deferrable(&q->perturb_timer);
 
 	for (i=0; i<SFQ_HASH_DIVISOR; i++)
 		q->ht[i] = SFQ_DEPTH;
