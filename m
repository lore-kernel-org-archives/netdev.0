From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 13/16] net_sched: add rtnl assertion to tcf_exts_destroy()
Date: Thu, 26 Oct 2017 18:24:40 -0700
Message-ID: <20171027012443.3306-14-xiyou.wangcong@gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Cc: Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:45039 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932414AbdJ0BZP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:15 -0400
Received: by mail-pf0-f195.google.com with SMTP id x7so3784466pfa.1
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:15 -0700 (PDT)
In-Reply-To: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After previous patches, it is now safe to claim that
tcf_exts_destroy() is always called with RTNL lock.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 045d13679ad6..231181c602ed 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -909,6 +909,7 @@ void tcf_exts_destroy(struct tcf_exts *exts)
 #ifdef CONFIG_NET_CLS_ACT
 	LIST_HEAD(actions);
 
+	ASSERT_RTNL();
 	tcf_exts_to_list(exts, &actions);
 	tcf_action_destroy(&actions, TCA_ACT_UNBIND);
 	kfree(exts->actions);
-- 
2.13.0
