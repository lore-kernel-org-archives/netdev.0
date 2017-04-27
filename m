From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/10] net: sched: rename tcf_destroy_chain helper
Date: Thu, 27 Apr 2017 13:12:13 +0200
Message-ID: <1493291540-2119-4-git-send-email-jiri@resnulli.us>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, mlxsw@mellanox.com,
        simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36043 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933542AbdD0LM2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:12:28 -0400
Received: by mail-wr0-f196.google.com with SMTP id v42so3383221wrc.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:12:27 -0700 (PDT)
In-Reply-To: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Make the name consistent with the rest of the helpers around.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 42fdc8a..88ec1a1 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -187,7 +187,7 @@ static void tcf_proto_destroy(struct tcf_proto *tp)
 	kfree_rcu(tp, rcu);
 }
 
-static void tcf_destroy_chain(struct tcf_proto __rcu **fl)
+static void tcf_chain_destroy(struct tcf_proto __rcu **fl)
 {
 	struct tcf_proto *tp;
 
@@ -214,7 +214,7 @@ void tcf_block_put(struct tcf_block *block)
 {
 	if (!block)
 		return;
-	tcf_destroy_chain(block->p_filter_chain);
+	tcf_chain_destroy(block->p_filter_chain);
 	kfree(block);
 }
 EXPORT_SYMBOL(tcf_block_put);
@@ -366,7 +366,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
 		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
-		tcf_destroy_chain(chain);
+		tcf_chain_destroy(chain);
 		err = 0;
 		goto errout;
 	}
-- 
2.7.4
