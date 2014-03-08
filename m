From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: add cond_resched() to class and qdisc
 dump
Date: Fri, 07 Mar 2014 18:01:04 -0800
Message-ID: <1394244064.20149.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:63560 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaCHCBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 21:01:06 -0500
Received: by mail-pd0-f174.google.com with SMTP id y13so4724502pdi.5
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 18:01:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We have seen delays of more than 50ms in class or qdisc dumps, in case
device is under high TX stress.

Add cond_resched() to give a chance to higher prio tasks to get cpu.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Google-Bug-Id: 13317737

 net/sched/sch_api.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1313145e3b86..15974e38cada 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1303,6 +1303,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	struct gnet_dump d;
 	struct qdisc_size_table *stab;
 
+	cond_resched();
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
 	if (!nlh)
 		goto out_nlmsg_trim;
@@ -1617,6 +1618,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	struct gnet_dump d;
 	const struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
 
+	cond_resched();
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
 	if (!nlh)
 		goto out_nlmsg_trim;
