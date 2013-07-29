From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net_sched: stack info leak in cbq_dump_wrr()
Date: Mon, 29 Jul 2013 22:36:51 +0300
Message-ID: <20130729193651.GA12525@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51627 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab3G2ThQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 15:37:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

opt.__reserved isn't cleared so we leak a byte of stack information.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 71a5688..6398a61 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1469,6 +1469,7 @@ static int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
 	opt.allot = cl->allot;
 	opt.priority = cl->priority + 1;
 	opt.cpriority = cl->cpriority + 1;
+	opt.__reserved = 0;
 	opt.weight = cl->weight;
 	if (nla_put(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt))
 		goto nla_put_failure;
