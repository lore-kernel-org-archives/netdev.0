From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/9] net: sched: introduce tcf_block_q and tcf_block_dev helpers
Date: Fri, 13 Oct 2017 14:00:59 +0200
Message-ID: <20171013120105.23358-4-jiri@resnulli.us>
References: <20171013120105.23358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37646 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758060AbdJMMBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 08:01:11 -0400
Received: by mail-wm0-f65.google.com with SMTP id r68so5588158wmr.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 05:01:10 -0700 (PDT)
In-Reply-To: <20171013120105.23358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

These helpers allows to get a q and netdev pointers
for given block easily.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 772dfa8..01ffda5 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -24,6 +24,17 @@ void tcf_chain_put(struct tcf_chain *chain);
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q);
 void tcf_block_put(struct tcf_block *block);
+
+static inline struct Qdisc *tcf_block_q(struct tcf_block *block)
+{
+	return block->q;
+}
+
+static inline struct net_device *tcf_block_dev(struct tcf_block *block)
+{
+	return tcf_block_q(block)->dev_queue->dev;
+}
+
 int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		 struct tcf_result *res, bool compat_mode);
 
@@ -39,6 +50,16 @@ static inline void tcf_block_put(struct tcf_block *block)
 {
 }
 
+static inline struct Qdisc *tcf_block_q(struct tcf_block *block)
+{
+	return NULL;
+}
+
+static inline struct net_device *tcf_block_dev(struct tcf_block *block)
+{
+	return NULL;
+}
+
 static inline int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			       struct tcf_result *res, bool compat_mode)
 {
-- 
2.9.5
