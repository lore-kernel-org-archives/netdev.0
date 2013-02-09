From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 04/11] htb: initialize cl->tokens and cl->ctokens correctly
Date: Sat,  9 Feb 2013 17:45:05 +0100
Message-ID: <1360428312-1277-5-git-send-email-jiri@resnulli.us>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:41749 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932409Ab3BIQpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 11:45:30 -0500
Received: by mail-ee0-f41.google.com with SMTP id c13so2480316eek.14
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 08:45:28 -0800 (PST)
In-Reply-To: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are in ns so convert from ticks to ns.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_htb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 547912e9..2b22544 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1459,8 +1459,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		cl->parent = parent;
 
 		/* set class to be in HTB_CAN_SEND state */
-		cl->tokens = hopt->buffer;
-		cl->ctokens = hopt->cbuffer;
+		cl->tokens = PSCHED_TICKS2NS(hopt->buffer);
+		cl->ctokens = PSCHED_TICKS2NS(hopt->cbuffer);
 		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
 		cl->t_c = psched_get_time();
 		cl->cmode = HTB_CAN_SEND;
-- 
1.8.1.2
