From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/7] htb: fix values in opt dump
Date: Fri,  8 Feb 2013 13:58:42 +0100
Message-ID: <1360328327-7144-3-git-send-email-jiri@resnulli.us>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:43593 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946441Ab3BHM64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 07:58:56 -0500
Received: by mail-ee0-f41.google.com with SMTP id c13so2079498eek.28
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 04:58:55 -0800 (PST)
In-Reply-To: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in htb_change_class() cl->buffer and cl->buffer are stored in ns.
So in dump, convert them back to psched ticks.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/sch_htb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 476992c..14a83dc 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1135,9 +1135,9 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	memset(&opt, 0, sizeof(opt));
 
 	opt.rate.rate = cl->rate.rate_bps >> 3;
-	opt.buffer = cl->buffer;
+	opt.buffer = PSCHED_NS2TICKS(cl->buffer);
 	opt.ceil.rate = cl->ceil.rate_bps >> 3;
-	opt.cbuffer = cl->cbuffer;
+	opt.cbuffer = PSCHED_NS2TICKS(cl->cbuffer);
 	opt.quantum = cl->quantum;
 	opt.prio = cl->prio;
 	opt.level = cl->level;
-- 
1.8.1.2
