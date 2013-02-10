From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 01/11] htb: use PSCHED_TICKS2NS()
Date: Sun, 10 Feb 2013 11:52:09 +0100
Message-ID: <1360493539-14868-2-git-send-email-jiri@resnulli.us>
References: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:58617 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151Ab3BJKwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 05:52:42 -0500
Received: by mail-ee0-f52.google.com with SMTP id b15so2666372eek.39
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 02:52:41 -0800 (PST)
In-Reply-To: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Eric Dumazet <edumazet@google.com>
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
