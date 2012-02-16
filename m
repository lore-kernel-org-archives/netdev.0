From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netem: fix unwanted reordering
Date: Thu, 16 Feb 2012 06:49:35 +0100
Message-ID: <1329371375.5646.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:56404 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab2BPFtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 00:49:39 -0500
Received: by werb13 with SMTP id b13so1080390wer.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 21:49:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 50612537e9 (netem: fix classful handling) added in typo in
netem_dequeue() :

After checking skb at the head of tfifo queue for time constraints, it
dequeues tail skb, thus adding unwanted reordering.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_netem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index e83d61c..1db8ff0 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -501,7 +501,7 @@ tfifo_dequeue:
 
 		/* if more time remaining? */
 		if (cb->time_to_send <= psched_get_time()) {
-			skb = qdisc_dequeue_tail(sch);
+			skb = qdisc_dequeue_head(sch);
 			if (unlikely(!skb))
 				goto qdisc_dequeue;
 
