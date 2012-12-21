From: Stefan Hasko <hasko.stevo@gmail.com>
Subject: [PATCH] net: sched: integer overflow fix
Date: Fri, 21 Dec 2012 21:39:24 +0100
Message-ID: <1356122364-1418-1-git-send-email-hasko.stevo@gmail.com>
Cc: linux-kernel@vger.kernel.org, Stefan Hasko <hasko.stevo@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:61670 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035Ab2LUUsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 15:48:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed integer overflow in function htb_dequeue

Signed-off-by: Stefan Hasko <hasko.stevo@gmail.com>
---
 net/sched/sch_htb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d2922c0..1bd3faa 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -919,7 +919,7 @@ ok:
 	q->now = ktime_to_ns(ktime_get());
 	start_at = jiffies;
 
-	next_event = q->now + 5 * NSEC_PER_SEC;
+	next_event = q->now + (u32)5 * NSEC_PER_SEC;
 
 	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
 		/* common case optimization - skip event handler quickly */
-- 
1.7.10.4
