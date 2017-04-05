From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: check noop_qdisc before qdisc_hash_add()
Date: Tue,  4 Apr 2017 18:51:30 -0700
Message-ID: <1491357091-27064-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, edumazet@google.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Kosina <jkosina@suse.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36199 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753178AbdDEBvr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 21:51:47 -0400
Received: by mail-pf0-f194.google.com with SMTP id r137so7051069pfr.3
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 18:51:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry reported a crash when injecting faults in
attach_one_default_qdisc() and dev->qdisc is still
a noop_disc, the check before qdisc_hash_add() fails
to catch it because it tests NULL. We should test
against noop_qdisc since it is the default qdisc
at this point.

Fixes: 59cc1f61f09c ("net: sched: convert qdisc linked list to hashtable")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b052b27..1a2f9e9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -794,7 +794,7 @@ static void attach_default_qdiscs(struct net_device *dev)
 		}
 	}
 #ifdef CONFIG_NET_SCHED
-	if (dev->qdisc)
+	if (dev->qdisc != &noop_qdisc)
 		qdisc_hash_add(dev->qdisc);
 #endif
 }
-- 
2.5.5
