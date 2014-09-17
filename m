From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 1/2] net: cls_u32: fix missed pcpu_success
 free_percpu
Date: Wed, 17 Sep 2014 12:11:33 -0700
Message-ID: <20140917191131.20529.91136.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:48186 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755907AbaIQTLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 15:11:54 -0400
Received: by mail-oa0-f43.google.com with SMTP id m19so917195oag.16
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 12:11:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a missed free_percpu in the unwind code path and when
keys are destroyed.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 730edb2..e76d50b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -363,6 +363,9 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 #ifdef CONFIG_CLS_U32_PERF
 	free_percpu(n->pf);
 #endif
+#ifdef CONFIG_CLS_U32_MARK
+	free_percpu(n->pcpu_success);
+#endif
 	kfree(n);
 	return 0;
 }
@@ -723,6 +726,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 #ifdef CONFIG_CLS_U32_PERF
 	free_percpu(n->pf);
 #endif
+#ifdef CONFIG_CLS_U32_MARK
+	free_percpu(n->pcpu_success);
+#endif
 	kfree(n);
 	return err;
 }
