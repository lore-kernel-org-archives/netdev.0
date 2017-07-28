From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/20] net: sched: cls_bpf: rename cls_bpf_modify_existing function
Date: Fri, 28 Jul 2017 16:40:32 +0200
Message-ID: <20170728144042.6380-11-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33160 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbdG1OlR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so16543674wmd.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:17 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The name cls_bpf_modify_existing is highly misleading, as it indeed does
not modify anything existing. It does not modify at all.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_bpf.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 49f311a..929cae9 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -382,10 +382,9 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
 	return 0;
 }
 
-static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
-				   struct cls_bpf_prog *prog,
-				   unsigned long base, struct nlattr **tb,
-				   struct nlattr *est, bool ovr)
+static int cls_bpf_set_parms(struct net *net, struct tcf_proto *tp,
+			     struct cls_bpf_prog *prog, unsigned long base,
+			     struct nlattr **tb, struct nlattr *est, bool ovr)
 {
 	bool is_bpf, is_ebpf, have_exts = false;
 	struct tcf_exts exts;
@@ -504,8 +503,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 	}
 
-	ret = cls_bpf_modify_existing(net, tp, prog, base, tb, tca[TCA_RATE],
-				      ovr);
+	ret = cls_bpf_set_parms(net, tp, prog, base, tb, tca[TCA_RATE], ovr);
 	if (ret < 0)
 		goto errout;
 
-- 
2.9.3
