From: Phil Sutter <psutter@redhat.com>
Subject: [net PATCH] net: sched: fix act_ipt for LOG target
Date: Thu,  3 Mar 2016 14:34:14 +0100
Message-ID: <1457012054-18012-1-git-send-email-psutter@redhat.com>
Cc: David Miller <davem@davemloft.net>, Phil Sutter <phil@nwl.cc>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754539AbcCCNeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 08:34:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>

Before calling the destroy() or target() callbacks, the family parameter
field has to be initialized. Otherwise at least the LOG target will
refuse to work and upon removal oops the kernel.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sched/act_ipt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 89c41a1f35894..350e134cffb32 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -66,6 +66,7 @@ static void ipt_destroy_target(struct xt_entry_target *t)
 	struct xt_tgdtor_param par = {
 		.target   = t->u.kernel.target,
 		.targinfo = t->data,
+		.family   = NFPROTO_IPV4,
 	};
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
@@ -219,6 +220,7 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 	par.hooknum  = ipt->tcfi_hook;
 	par.target   = ipt->tcfi_t->u.kernel.target;
 	par.targinfo = ipt->tcfi_t->data;
+	par.family   = NFPROTO_IPV4;
 	ret = par.target->target(skb, &par);
 
 	switch (ret) {
-- 
2.7.2
