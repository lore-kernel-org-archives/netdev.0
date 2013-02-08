From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/7] htb: initialize cl->tokens and cl->ctokens correctly
Date: Fri,  8 Feb 2013 13:58:44 +0100
Message-ID: <1360328327-7144-5-git-send-email-jiri@resnulli.us>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54774 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946510Ab3BHM7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 07:59:00 -0500
Received: by mail-ee0-f46.google.com with SMTP id e49so2039216eek.19
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 04:58:58 -0800 (PST)
In-Reply-To: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are in ns so convert from ticks to ns.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
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
