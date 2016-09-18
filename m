From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: check NULL on error path in route4_change()
Date: Sun, 18 Sep 2016 15:52:20 -0700
Message-ID: <1474239140-6738-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34905 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932263AbcIRWwm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 18:52:42 -0400
Received: by mail-pf0-f195.google.com with SMTP id 6so3353578pfl.2
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 15:52:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On error path in route4_change(), 'f' could be NULL,
so we should check NULL before calling tcf_exts_destroy().

Fixes: b9a24bb76bf6 ("net_sched: properly handle failure case of tcf_exts_init()")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index c91e65d..aaab7a0 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -562,7 +562,8 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	return 0;
 
 errout:
-	tcf_exts_destroy(&f->exts);
+	if (f)
+		tcf_exts_destroy(&f->exts);
 	kfree(f);
 	return err;
 }
-- 
2.1.0
