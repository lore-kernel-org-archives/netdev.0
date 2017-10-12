From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/34] net: sched: avoid usage of tp->q in tcf_classify
Date: Thu, 12 Oct 2017 19:17:57 +0200
Message-ID: <20171012171823.1431-9-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:45519 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753306AbdJLRSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:33 -0400
Received: by mail-wm0-f67.google.com with SMTP id q124so15082237wmb.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:32 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use block index in the messages instead.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 2d0f18f..b1bcc8b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -501,8 +501,9 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 #ifdef CONFIG_NET_CLS_ACT
 reset:
 	if (unlikely(limit++ >= max_reclassify_loop)) {
-		net_notice_ratelimited("%s: reclassify loop, rule prio %u, protocol %02x\n",
-				       tp->q->ops->id, tp->prio & 0xffff,
+		net_notice_ratelimited("%u: reclassify loop, rule prio %u, protocol %02x\n",
+				       tp->chain->block->index,
+				       tp->prio & 0xffff,
 				       ntohs(tp->protocol));
 		return TC_ACT_SHOT;
 	}
-- 
2.9.5
