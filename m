From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 33/34] net: sched: remove classid and q fields from tcf_proto
Date: Thu, 12 Oct 2017 19:18:22 +0200
Message-ID: <20171012171823.1431-34-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33790 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754494AbdJLRSz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:55 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so4373236wmu.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:55 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Both are no longer used, so remove them.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/sch_generic.h | 2 --
 net/sched/cls_api.c       | 7 ++-----
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 17c908a..df4a1e9 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -244,8 +244,6 @@ struct tcf_proto {
 
 	/* All the rest */
 	u32			prio;
-	u32			classid;
-	struct Qdisc		*q;
 	void			*data;
 	const struct tcf_proto_ops	*ops;
 	struct tcf_chain	*chain;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index fba6a85..4b0c051 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -114,8 +114,7 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 }
 
 static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
-					  u32 prio, u32 parent, struct Qdisc *q,
-					  struct tcf_chain *chain)
+					  u32 prio, struct tcf_chain *chain)
 {
 	struct tcf_proto *tp;
 	int err;
@@ -149,8 +148,6 @@ static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
 	tp->classify = tp->ops->classify;
 	tp->protocol = protocol;
 	tp->prio = prio;
-	tp->classid = parent;
-	tp->q = q;
 	tp->chain = chain;
 
 	err = tp->ops->init(tp);
@@ -1039,7 +1036,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			prio = tcf_auto_prio(tcf_chain_tp_prev(&chain_info));
 
 		tp = tcf_proto_create(nla_data(tca[TCA_KIND]),
-				      protocol, prio, parent, q, chain);
+				      protocol, prio, chain);
 		if (IS_ERR(tp)) {
 			err = PTR_ERR(tp);
 			goto errout;
-- 
2.9.5
