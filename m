From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] net: sched: cls_u32: rcu can not be last node
Date: Tue, 16 Sep 2014 22:34:38 -0700
Message-ID: <20140917053434.2833.66129.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:64254 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaIQFe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 01:34:58 -0400
Received: by mail-ob0-f180.google.com with SMTP id wp4so698215obc.39
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 22:34:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tc_u32_sel 'sel' in tc_u_knode expects to be the last element in the
structure and pads the structure with tc_u32_key fields for each key.

 kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL)

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index eceeb04..be24e7e 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -64,8 +64,8 @@ struct tc_u_knode {
 	u32 __percpu		*pcpu_success;
 #endif
 	struct tcf_proto	*tp;
-	struct tc_u32_sel	sel;
 	struct rcu_head		rcu;
+	struct tc_u32_sel	sel;
 };
 
 struct tc_u_hnode {
