From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: replace yield() with cond_resched()
Date: Tue,  4 Apr 2017 18:52:19 -0700
Message-ID: <1491357139-27108-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: efault@gmx.de, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34493 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbdDEBw0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 21:52:26 -0400
Received: by mail-pf0-f193.google.com with SMTP id o126so7058264pfb.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 18:52:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yield() should be rendered dead, according to Mike.

It is hard to wait properly for all qdisc's to transmit
all packets. So just keep the original logic.

Reported-by: Mike Galbraith <efault@gmx.de>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 1a2f9e9..4725d2f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -925,7 +925,7 @@ void dev_deactivate_many(struct list_head *head)
 	/* Wait for outstanding qdisc_run calls. */
 	list_for_each_entry(dev, head, close_list)
 		while (some_qdisc_is_busy(dev))
-			yield();
+			cond_resched();
 }
 
 void dev_deactivate(struct net_device *dev)
-- 
2.5.5
