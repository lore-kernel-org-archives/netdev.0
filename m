From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/20] net: sched: cls_fw: rename fw_change_attrs function
Date: Fri,  4 Aug 2017 14:29:05 +0200
Message-ID: <20170804122915.15177-11-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:32844 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752522AbdHDM3h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:37 -0400
Received: by mail-wr0-f194.google.com with SMTP id y43so2904218wrd.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:36 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since the function name is misleading since it is not changing
anything, name it similarly to other cls.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_fw.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index a53fa75..358bf34 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -190,10 +190,9 @@ static const struct nla_policy fw_policy[TCA_FW_MAX + 1] = {
 	[TCA_FW_MASK]		= { .type = NLA_U32 },
 };
 
-static int
-fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
-		struct nlattr **tb, struct nlattr **tca, unsigned long base,
-		bool ovr)
+static int fw_set_parms(struct net *net, struct tcf_proto *tp,
+			struct fw_filter *f, struct nlattr **tb,
+			struct nlattr **tca, unsigned long base, bool ovr)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
 	struct tcf_exts e;
@@ -282,7 +281,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 			return err;
 		}
 
-		err = fw_change_attrs(net, tp, fnew, tb, tca, base, ovr);
+		err = fw_set_parms(net, tp, fnew, tb, tca, base, ovr);
 		if (err < 0) {
 			tcf_exts_destroy(&fnew->exts);
 			kfree(fnew);
@@ -330,7 +329,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	f->id = handle;
 	f->tp = tp;
 
-	err = fw_change_attrs(net, tp, f, tb, tca, base, ovr);
+	err = fw_set_parms(net, tp, f, tb, tca, base, ovr);
 	if (err < 0)
 		goto errout;
 
-- 
2.9.3
