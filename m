From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 07/11] tbf: ignore max_size check for gso skbs
Date: Sun, 10 Feb 2013 11:52:15 +0100
Message-ID: <1360493539-14868-8-git-send-email-jiri@resnulli.us>
References: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:37353 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754685Ab3BJKw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 05:52:57 -0500
Received: by mail-ee0-f51.google.com with SMTP id d17so2559312eek.38
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 02:52:56 -0800 (PST)
In-Reply-To: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check made bigger packets incorrectly dropped. Remove this
limitation for gso skbs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_tbf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index e05710a..dc562a8 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -121,7 +121,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (qdisc_pkt_len(skb) > q->max_size)
+	if (qdisc_pkt_len(skb) > q->max_size && !skb_is_gso(skb))
 		return qdisc_reshape_fail(skb, sch);
 
 	ret = qdisc_enqueue(skb, q->qdisc);
-- 
1.8.1.2
