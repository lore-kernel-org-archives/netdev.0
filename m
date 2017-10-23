From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 13/15] net_sched: add rtnl assertion to tcf_exts_destroy()
Date: Mon, 23 Oct 2017 15:03:02 -0700
Message-ID: <20171023220304.2268-14-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:44547 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbdJWWDr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:47 -0400
Received: by mail-pg0-f67.google.com with SMTP id j3so12849054pga.1
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:47 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After previous patches, it is now safe to claim that
tcf_exts_destroy() is always called with RTNL lock.

Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0b2219adf520..c48482942995 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -879,6 +879,7 @@ void tcf_exts_destroy(struct tcf_exts *exts)
 #ifdef CONFIG_NET_CLS_ACT
 	LIST_HEAD(actions);
 
+	ASSERT_RTNL();
 	tcf_exts_to_list(exts, &actions);
 	tcf_action_destroy(&actions, TCA_ACT_UNBIND);
 	kfree(exts->actions);
-- 
2.13.0
