From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/7] htb: use PSCHED_TICKS2NS()
Date: Fri,  8 Feb 2013 13:58:41 +0100
Message-ID: <1360328327-7144-2-git-send-email-jiri@resnulli.us>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:42745 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946481Ab3BHM6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 07:58:54 -0500
Received: by mail-ee0-f41.google.com with SMTP id c13so1988240eek.14
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 04:58:53 -0800 (PST)
In-Reply-To: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/sch_htb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 51561ea..476992c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1512,8 +1512,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	htb_precompute_ratedata(&cl->rate);
 	htb_precompute_ratedata(&cl->ceil);
 
-	cl->buffer = hopt->buffer << PSCHED_SHIFT;
-	cl->cbuffer = hopt->buffer << PSCHED_SHIFT;
+	cl->buffer = PSCHED_TICKS2NS(hopt->buffer);
+	cl->cbuffer = PSCHED_TICKS2NS(hopt->buffer);
 
 	sch_tree_unlock(sch);
 
-- 
1.8.1.2
