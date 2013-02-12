From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 02/11] htb: fix values in opt dump
Date: Tue, 12 Feb 2013 11:12:00 +0100
Message-ID: <1360663929-1023-3-git-send-email-jiri@resnulli.us>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:57658 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932782Ab3BLKMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:12:23 -0500
Received: by mail-ea0-f177.google.com with SMTP id n13so71633eaa.36
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 02:12:21 -0800 (PST)
In-Reply-To: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in htb_change_class() cl->buffer and cl->buffer are stored in ns.
So in dump, convert them back to psched ticks.

Note this was introduced by:
commit 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd
    htb: improved accuracy at high rates

Please consider this for -net/-stable.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Eric Dumazet <edumazet@google.com>
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
