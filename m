From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_plug: purge buffered packets during reset
Date: Tue, 21 Jul 2015 16:31:53 -0700
Message-ID: <1437521513-16116-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34484 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbGUXcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 19:32:19 -0400
Received: by pdbbh15 with SMTP id bh15so82436057pdb.1
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 16:32:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise the skbuff related structures are not correctly
refcount'ed.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_plug.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
index 89f8fcf..ade9445 100644
--- a/net/sched/sch_plug.c
+++ b/net/sched/sch_plug.c
@@ -216,6 +216,7 @@ static struct Qdisc_ops plug_qdisc_ops __read_mostly = {
 	.peek        =       qdisc_peek_head,
 	.init        =       plug_init,
 	.change      =       plug_change,
+	.reset       =	     qdisc_reset_queue,
 	.owner       =       THIS_MODULE,
 };
 
-- 
1.8.3.1
