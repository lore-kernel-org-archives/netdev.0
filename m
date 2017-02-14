From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 3/6] net/sched: cls_flower: Reflect HW offload status
Date: Tue, 14 Feb 2017 16:30:37 +0200
Message-ID: <1487082640-24813-4-git-send-email-ogerlitz@mellanox.com>
References: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54485 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754070AbdBNOay (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 09:30:54 -0500
In-Reply-To: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flower support for the "in hw" offloading flags.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 0826c8e..a08d36f 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -273,6 +273,8 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
 					    tc);
+	if (!err)
+		f->flags |= TCA_CLS_FLAGS_IN_HW;
 
 	if (tc_skip_sw(f->flags))
 		return err;
@@ -912,6 +914,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 			goto errout;
 	}
 
+	if (!(tc_in_hw(fnew->flags)))
+		fnew->flags |= TCA_CLS_FLAGS_NOT_IN_HW;
+
 	if (fold) {
 		if (!tc_skip_sw(fold->flags))
 			rhashtable_remove_fast(&head->ht, &fold->ht_node,
-- 
2.3.7
