From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: fix suspicious RCU usage in cls_bpf_classify()
Date: Mon, 15 Sep 2014 14:21:50 -0700
Message-ID: <1410816110-10354-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:60313 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543AbaIOVV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:21:57 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so7376120pab.41
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:21:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: commit 1f947bf151e90ec0baad2948 ("net: sched: rcu'ify cls_bpf")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_bpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 6a7386e..4e3f5bf 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -52,7 +52,7 @@ static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
-	struct cls_bpf_head *head = rcu_dereference(tp->root);
+	struct cls_bpf_head *head = rcu_dereference_bh(tp->root);
 	struct cls_bpf_prog *prog;
 	int ret;
 
-- 
1.8.3.1
