From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2] net: sched: cls_u32: rcu can not be last node
Date: Wed, 17 Sep 2014 10:31:14 -0700
Message-ID: <20140917173108.3864.57490.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:47609 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801AbaIQRbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 13:31:41 -0400
Received: by mail-oa0-f46.google.com with SMTP id i7so1511045oag.5
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 10:31:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tc_u32_sel 'sel' in tc_u_knode expects to be the last element in the
structure and pads the structure with tc_u32_key fields for each key.

 kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL)

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index eceeb04..8462132 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -64,8 +64,9 @@ struct tc_u_knode {
 	u32 __percpu		*pcpu_success;
 #endif
 	struct tcf_proto	*tp;
-	struct tc_u32_sel	sel;
 	struct rcu_head		rcu;
+	struct tc_u32_sel	sel;
+	/* tc_u32_keys allocated at end of structure */
 };
 
 struct tc_u_hnode {
