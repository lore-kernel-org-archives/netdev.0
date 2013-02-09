From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 07/11] tbf: ignore max_size check for gso skbs
Date: Sat,  9 Feb 2013 17:45:08 +0100
Message-ID: <1360428312-1277-8-git-send-email-jiri@resnulli.us>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:39440 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446Ab3BIQpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 11:45:38 -0500
Received: by mail-ee0-f44.google.com with SMTP id l10so2559645eei.17
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 08:45:36 -0800 (PST)
In-Reply-To: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
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
