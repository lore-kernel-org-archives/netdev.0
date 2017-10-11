From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net-next 1/2] net sched actions: change IFE modules alias names
Date: Wed, 11 Oct 2017 10:50:29 -0400
Message-ID: <1507733430-17860-2-git-send-email-mrv@mojatatu.com>
References: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:44111 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752242AbdJKOuy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 10:50:54 -0400
Received: by mail-it0-f66.google.com with SMTP id n195so13540559itg.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 07:50:54 -0700 (PDT)
In-Reply-To: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make style of module alias name consistent with other subsystems in kernel,
for example net devices.

Fixes: 084e2f6566d2 ("Support to encoding decoding skb mark on IFE action")
Fixes: 200e10f46936 ("Support to encoding decoding skb prio on IFE action")
Fixes: 408fbc22ef1e ("net sched ife action: Introduce skb tcindex metadata encap decap")
Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 include/net/tc_act/tc_ife.h     | 2 +-
 net/sched/act_ife.c             | 2 +-
 net/sched/act_meta_mark.c       | 2 +-
 net/sched/act_meta_skbprio.c    | 2 +-
 net/sched/act_meta_skbtcindex.c | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
index 30ba459..104578f 100644
--- a/include/net/tc_act/tc_ife.h
+++ b/include/net/tc_act/tc_ife.h
@@ -40,7 +40,7 @@ struct tcf_meta_ops {
 	struct module	*owner;
 };
 
-#define MODULE_ALIAS_IFE_META(metan)   MODULE_ALIAS("ifemeta" __stringify_1(metan))
+#define MODULE_ALIAS_IFE_META(metan)   MODULE_ALIAS("ife-meta-" metan)
 
 int ife_get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi);
 int ife_get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi);
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 8ccd358..791aeee 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -263,7 +263,7 @@ static int load_metaops_and_vet(struct tcf_ife_info *ife, u32 metaid,
 		if (exists)
 			spin_unlock_bh(&ife->tcf_lock);
 		rtnl_unlock();
-		request_module("ifemeta%u", metaid);
+		request_module("ife-meta-%u", metaid);
 		rtnl_lock();
 		if (exists)
 			spin_lock_bh(&ife->tcf_lock);
diff --git a/net/sched/act_meta_mark.c b/net/sched/act_meta_mark.c
index 8289217..1e3f10e 100644
--- a/net/sched/act_meta_mark.c
+++ b/net/sched/act_meta_mark.c
@@ -76,4 +76,4 @@ static void __exit ifemark_cleanup_module(void)
 MODULE_AUTHOR("Jamal Hadi Salim(2015)");
 MODULE_DESCRIPTION("Inter-FE skb mark metadata module");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_IFE_META(IFE_META_SKBMARK);
+MODULE_ALIAS_IFE_META("skbmark");
diff --git a/net/sched/act_meta_skbprio.c b/net/sched/act_meta_skbprio.c
index 26bf4d8..4033f9f 100644
--- a/net/sched/act_meta_skbprio.c
+++ b/net/sched/act_meta_skbprio.c
@@ -73,4 +73,4 @@ static void __exit ifeprio_cleanup_module(void)
 MODULE_AUTHOR("Jamal Hadi Salim(2015)");
 MODULE_DESCRIPTION("Inter-FE skb prio metadata action");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_IFE_META(IFE_META_PRIO);
+MODULE_ALIAS_IFE_META("skbprio");
diff --git a/net/sched/act_meta_skbtcindex.c b/net/sched/act_meta_skbtcindex.c
index 3b35774..2ea1f26 100644
--- a/net/sched/act_meta_skbtcindex.c
+++ b/net/sched/act_meta_skbtcindex.c
@@ -76,4 +76,4 @@ static void __exit ifetc_index_cleanup_module(void)
 MODULE_AUTHOR("Jamal Hadi Salim(2016)");
 MODULE_DESCRIPTION("Inter-FE skb tc_index metadata module");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_IFE_META(IFE_META_SKBTCINDEX);
+MODULE_ALIAS_IFE_META("tcindex");
-- 
1.9.1
