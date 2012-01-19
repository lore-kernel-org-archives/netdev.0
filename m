From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH ] netem: Fix off-by-one bug in reordering
Date: Thu, 19 Jan 2012 12:20:59 -0800
Message-ID: <1327004459-19275-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34689 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932690Ab2ASUQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 15:16:36 -0500
Received: by iagf6 with SMTP id f6so353640iag.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 12:16:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With netem reordering, a gap of N is supposed to reorder every Nth packet with
given reorder probability.  However, the code currently skips N packets and
reorders every (N+1)th packet.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/sched/sch_netem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index e7e1d0b..2776012 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -419,7 +419,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	cb = netem_skb_cb(skb);
 	if (q->gap == 0 ||		/* not doing reordering */
-	    q->counter < q->gap ||	/* inside last reordering gap */
+	    q->counter < q->gap - 1 ||	/* inside last reordering gap */
 	    q->reorder < get_crandom(&q->reorder_cor)) {
 		psched_time_t now;
 		psched_tdiff_t delay;
-- 
1.7.0.4
