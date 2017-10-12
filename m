From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/34] net: sched: cls_u32: swap u32_remove_hw_knode and u32_remove_hw_hnode
Date: Thu, 12 Oct 2017 19:18:06 +0200
Message-ID: <20171012171823.1431-18-jiri@resnulli.us>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35363 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755063AbdJLRSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:41 -0400
Received: by mail-wm0-f65.google.com with SMTP id b189so4344951wmd.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:41 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_u32.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index b6d4606..f407f13 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -462,7 +462,7 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 	return 0;
 }
 
-static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
+static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload cls_u32 = {};
@@ -471,8 +471,10 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 		return;
 
 	tc_cls_common_offload_init(&cls_u32.common, tp);
-	cls_u32.command = TC_CLSU32_DELETE_KNODE;
-	cls_u32.knode.handle = handle;
+	cls_u32.command = TC_CLSU32_DELETE_HNODE;
+	cls_u32.hnode.divisor = h->divisor;
+	cls_u32.hnode.handle = h->handle;
+	cls_u32.hnode.prio = h->prio;
 
 	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 }
@@ -500,7 +502,7 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 	return 0;
 }
 
-static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
+static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload cls_u32 = {};
@@ -509,10 +511,8 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 		return;
 
 	tc_cls_common_offload_init(&cls_u32.common, tp);
-	cls_u32.command = TC_CLSU32_DELETE_HNODE;
-	cls_u32.hnode.divisor = h->divisor;
-	cls_u32.hnode.handle = h->handle;
-	cls_u32.hnode.prio = h->prio;
+	cls_u32.command = TC_CLSU32_DELETE_KNODE;
+	cls_u32.knode.handle = handle;
 
 	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 }
-- 
2.9.5
