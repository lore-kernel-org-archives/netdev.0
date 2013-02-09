From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 01/11] htb: use PSCHED_TICKS2NS()
Date: Sat,  9 Feb 2013 17:45:02 +0100
Message-ID: <1360428312-1277-2-git-send-email-jiri@resnulli.us>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:46007 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932324Ab3BIQpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 11:45:22 -0500
Received: by mail-ea0-f179.google.com with SMTP id d12so1986555eaa.38
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 08:45:20 -0800 (PST)
In-Reply-To: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
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
