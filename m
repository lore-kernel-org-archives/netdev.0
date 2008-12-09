From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 4/6] pkt_sched: sch_htb: Change if () check in htb_dequeue()
Date: Tue, 9 Dec 2008 10:21:38 +0000
Message-ID: <20081209102138.GD14862@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:44025 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbYLIKVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 05:21:44 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1033647ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 02:21:43 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skip "event" in if () in htb_dequeue(): it's always > 0 at this place.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index b241ac6..2e0a74c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -879,7 +879,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		} else
 			event = q->near_ev_cache[level];
 
-		if (event && next_event > event)
+		if (next_event > event)
 			next_event = event;
 
 		m = ~q->row_mask[level];
-- 
1.5.6.5

