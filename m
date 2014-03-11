From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] pkt_sched: add cond_resched() to class and qdisc dump
Date: Mon, 10 Mar 2014 17:11:43 -0700
Message-ID: <1394496703-9278-3-git-send-email-edumazet@google.com>
References: <1394496703-9278-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:42897 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912AbaCKATA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 20:19:00 -0400
Received: by mail-pb0-f73.google.com with SMTP id rp16so1053031pbb.2
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 17:19:00 -0700 (PDT)
In-Reply-To: <1394496703-9278-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have seen delays of more than 50ms in class or qdisc dumps, in case
device is under high TX stress, even with the prior 4KB per skb limit.

Add cond_resched() to give a chance to higher prio tasks to get cpu.

Signed-off-by; Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 272292efa7f0..0a99d7ced71e 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1303,6 +1303,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	struct gnet_dump d;
 	struct qdisc_size_table *stab;
 
+	cond_resched();
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
 	if (!nlh)
 		goto out_nlmsg_trim;
@@ -1615,6 +1616,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	struct gnet_dump d;
 	const struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
 
+	cond_resched();
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
 	if (!nlh)
 		goto out_nlmsg_trim;
-- 
1.9.0.279.gdc9e3eb
