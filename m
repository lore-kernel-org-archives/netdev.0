From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH 1/1] net: sched: Make netns available for ematch extensions
Date: Wed, 11 Sep 2013 15:20:14 +0200
Message-ID: <1378905614-29691-2-git-send-email-kadlec@blackhole.kfki.hu>
References: <1378905614-29691-1-git-send-email-kadlec@blackhole.kfki.hu>
Cc: netdev@vger.kernel.org, "V. Lavrov" <lve@guap.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.kfki.hu ([148.6.0.28]:33555 "EHLO smtp2.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753413Ab3IKNUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 09:20:16 -0400
In-Reply-To: <1378905614-29691-1-git-send-email-kadlec@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ematch API (change, destroy) doesn't pass netns data to ematch extensions.
This prevents adding netns support to ipset, which is an ematch too.

The patch adds the required pointer to "struct tcf_proto", thus
making it available for every ematch.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/net/sch_generic.h |    1 +
 net/sched/cls_api.c       |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f4eb365..38e5e4b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -225,6 +225,7 @@ struct tcf_proto {
 	struct Qdisc		*q;
 	void			*data;
 	const struct tcf_proto_ops	*ops;
+	struct net		*net;
 };
 
 struct qdisc_skb_cb {
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8e118af..1b1cb11 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -266,6 +266,7 @@ replay:
 		tp->q = q;
 		tp->classify = tp_ops->classify;
 		tp->classid = parent;
+		tp->net = net;
 
 		err = tp_ops->init(tp);
 		if (err != 0) {
-- 
1.7.0.4
