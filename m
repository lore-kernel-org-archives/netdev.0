From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] net: sched: remove unused tcf_exts_get_dev helper and cls_flower->egress_dev
Date: Tue, 10 Oct 2017 09:30:16 +0200
Message-ID: <20171010073016.3682-5-jiri@resnulli.us>
References: <20171010073016.3682-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:46531 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755361AbdJJHaW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 03:30:22 -0400
Received: by mail-wm0-f68.google.com with SMTP id m72so2347297wmc.1
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 00:30:22 -0700 (PDT)
In-Reply-To: <20171010073016.3682-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The helper and the struct field ares no longer used by any code,
so remove them.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h |  3 ---
 net/sched/cls_api.c   | 22 ----------------------
 2 files changed, 25 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index c0bdf5c..f526374 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -204,8 +204,6 @@ void tcf_exts_destroy(struct tcf_exts *exts);
 void tcf_exts_change(struct tcf_exts *dst, struct tcf_exts *src);
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
-int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
-		     struct net_device **hw_dev);
 
 /**
  * struct tcf_pkt_info - packet information
@@ -517,7 +515,6 @@ struct tc_cls_flower_offload {
 	struct fl_flow_key *mask;
 	struct fl_flow_key *key;
 	struct tcf_exts *exts;
-	bool egress_dev;
 };
 
 enum tc_matchall_command {
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 51994a2..2977b8a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -1004,28 +1004,6 @@ int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts)
 }
 EXPORT_SYMBOL(tcf_exts_dump_stats);
 
-int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
-		     struct net_device **hw_dev)
-{
-#ifdef CONFIG_NET_CLS_ACT
-	const struct tc_action *a;
-	LIST_HEAD(actions);
-
-	if (!tcf_exts_has_actions(exts))
-		return -EINVAL;
-
-	tcf_exts_to_list(exts, &actions);
-	list_for_each_entry(a, &actions, list) {
-		if (a->ops->get_dev)
-			*hw_dev = a->ops->get_dev(a);
-	}
-	if (*hw_dev)
-		return 0;
-#endif
-	return -EOPNOTSUPP;
-}
-EXPORT_SYMBOL(tcf_exts_get_dev);
-
 static int tc_exts_setup_cb_egdev_call(struct tcf_exts *exts,
 				       enum tc_setup_type type,
 				       void *type_data, bool err_stop)
-- 
2.9.5
