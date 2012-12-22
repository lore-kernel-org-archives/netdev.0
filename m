From: Stefan Hasko <hasko.stevo@gmail.com>
Subject: [PATCH] net: sched: integer overflow fix
Date: Sat, 22 Dec 2012 02:04:59 +0100
Message-ID: <1356138300-16076-1-git-send-email-hasko.stevo@gmail.com>
Cc: linux-kernel@vger.kernel.org, Stefan Hasko <hasko.stevo@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:39880 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab2LVBFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 20:05:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I did not realize different sizes casting problem, now it's clear to me. Thanks for help.

Fixed integer overflow in function htb_dequeue

Signed-off-by: Stefan Hasko <hasko.stevo@gmail.com>
---
 net/sched/sch_htb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d2922c0..51561ea 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -919,7 +919,7 @@ ok:
 	q->now = ktime_to_ns(ktime_get());
 	start_at = jiffies;
 
-	next_event = q->now + 5 * NSEC_PER_SEC;
+	next_event = q->now + 5LLU * NSEC_PER_SEC;
 
 	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
 		/* common case optimization - skip event handler quickly */
-- 
1.7.10.4
