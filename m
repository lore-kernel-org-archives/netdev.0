From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 14/16] net_sched: fix call_rcu() race on act_sample module removal
Date: Thu, 26 Oct 2017 18:24:41 -0700
Message-ID: <20171027012443.3306-15-xiyou.wangcong@gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Cc: Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:55312 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932415AbdJ0BZP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:15 -0400
Received: by mail-pg0-f65.google.com with SMTP id 15so4041202pgc.12
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:15 -0700 (PDT)
In-Reply-To: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit c78e1746d3ad
("net: sched: fix call_rcu() race on classifier module unloads"),
we need to wait for flying RCU callback tcf_sample_cleanup_rcu().

Cc: Yotam Gigi <yotamg@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_sample.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index ec986ae52808..a9f9a2ccc664 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -264,6 +264,7 @@ static int __init sample_init_module(void)
 
 static void __exit sample_cleanup_module(void)
 {
+	rcu_barrier();
 	tcf_unregister_action(&act_sample_ops, &sample_net_ops);
 }
 
-- 
2.13.0
