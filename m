From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: use skb_at_tc_ingress helper in tcf_bpf
Date: Mon, 12 Sep 2016 23:38:43 +0200
Message-ID: <c2f57d785c3586eca68b3bb29e2bff4ac4189238.1473715365.git.daniel@iogearbox.net>
References: <cover.1473715365.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42376 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751567AbcILVjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 17:39:00 -0400
In-Reply-To: <cover.1473715365.git.daniel@iogearbox.net>
In-Reply-To: <cover.1473715365.git.daniel@iogearbox.net>
References: <cover.1473715365.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a small skb_at_tc_ingress() helper for testing for ingress, so
make use of it. cls_bpf already uses it and so should act_bpf.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/sched/act_bpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 78400de..1d39600 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -39,10 +39,10 @@ static struct tc_action_ops act_bpf_ops;
 static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		   struct tcf_result *res)
 {
+	bool at_ingress = skb_at_tc_ingress(skb);
 	struct tcf_bpf *prog = to_bpf(act);
 	struct bpf_prog *filter;
 	int action, filter_res;
-	bool at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;
 
 	tcf_lastuse_update(&prog->tcf_tm);
 	bstats_cpu_update(this_cpu_ptr(prog->common.cpu_bstats), skb);
-- 
1.9.3
