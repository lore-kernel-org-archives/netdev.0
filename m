From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] net_sched: sfq: always randomize hash
 perturbation
Date: Wed, 04 Jan 2012 17:23:01 +0100
Message-ID: <1325694181.2428.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54105 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab2ADQXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 11:23:05 -0500
Received: by wgbdr13 with SMTP id dr13so29187739wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 08:23:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFQ q->perturbation is used in sfq_hash() as an input to Jenkins hash.

We currently randomize this 32bit value only if a perturbation timer is
setup.

Its much better to always initialize it to defeat attackers, or else
they can predict very well what kind of packets they have to forge to
hit a particular flow.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 465af66..a1cb00e 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -591,12 +591,12 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->cur_depth = 0;
 	q->tail = NULL;
 	q->divisor = SFQ_DEFAULT_HASH_DIVISOR;
-	if (opt == NULL) {
-		q->quantum = psched_mtu(qdisc_dev(sch));
-		q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
-		q->perturb_period = 0;
-		q->perturbation = net_random();
-	} else {
+	q->quantum = psched_mtu(qdisc_dev(sch));
+	q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
+	q->perturb_period = 0;
+	q->perturbation = net_random();
+
+	if (opt) {
 		int err = sfq_change(sch, opt);
 		if (err)
 			return err;
