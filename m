From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3] net: sched: cls_u32: rcu can not be last node
Date: Wed, 17 Sep 2014 11:11:46 -0700
Message-ID: <20140917181144.9571.68528.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:51400 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756016AbaIQSMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 14:12:23 -0400
Received: by mail-oi0-f44.google.com with SMTP id v63so1211304oia.17
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 11:12:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tc_u32_sel 'sel' in tc_u_knode expects to be the last element in the
structure and pads the structure with tc_u32_key fields for each key.

 kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL)

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index eceeb04..730edb2 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -64,8 +64,11 @@ struct tc_u_knode {
 	u32 __percpu		*pcpu_success;
 #endif
 	struct tcf_proto	*tp;
-	struct tc_u32_sel	sel;
 	struct rcu_head		rcu;
+	/* The 'sel' field MUST be the last field in structure to allow for
+	 * tc_u32_keys allocated at end of structure.
+	 */
+	struct tc_u32_sel	sel;
 };
 
 struct tc_u_hnode {
