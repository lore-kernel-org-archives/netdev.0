From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 09/20] net: sched: cls_bpf: rename cls_bpf_modify_existing function
Date: Fri,  4 Aug 2017 14:29:04 +0200
Message-ID: <20170804122915.15177-10-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35271 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752516AbdHDM3f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:35 -0400
Received: by mail-wm0-f67.google.com with SMTP id r77so5552201wmd.2
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:35 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The name cls_bpf_modify_existing is highly misleading, as it indeed does
not modify anything existing. It does not modify at all.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_bpf.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index f57bd53..e9ab837 100644
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
@@ -508,8 +507,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 	}
 
-	ret = cls_bpf_modify_existing(net, tp, prog, base, tb, tca[TCA_RATE],
-				      ovr);
+	ret = cls_bpf_set_parms(net, tp, prog, base, tb, tca[TCA_RATE], ovr);
 	if (ret < 0)
 		goto errout;
 
-- 
2.9.3
