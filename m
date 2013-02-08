From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/7] tbf: ignore max_size check for gso skbs
Date: Fri,  8 Feb 2013 13:58:47 +0100
Message-ID: <1360328327-7144-8-git-send-email-jiri@resnulli.us>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:59176 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946551Ab3BHM7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 07:59:06 -0500
Received: by mail-ea0-f169.google.com with SMTP id d13so1644609eaa.14
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 04:59:04 -0800 (PST)
In-Reply-To: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check made bigger packets incorrectly dropped. Remove this
limitation for gso skbs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/sch_tbf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 35bfd49..7ee5bff 100644
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
