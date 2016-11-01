From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH net-next 1/2] net/sched: cls_flower: add missing unbind call when destroying flows
Date: Tue,  1 Nov 2016 16:08:28 +0200
Message-ID: <1478009309-63180-2-git-send-email-roid@mellanox.com>
References: <1478009309-63180-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35503 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S966187AbcKAOIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 10:08:38 -0400
In-Reply-To: <1478009309-63180-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcf_unbind was called in fl_delete but was missing in fl_destroy when
force deleting flows.

Fixes: 77b9900ef53a ('tc: introduce Flower classifier')
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index f6f40fb..a5f6370 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -280,6 +280,7 @@ static bool fl_destroy(struct tcf_proto *tp, bool force)
 	list_for_each_entry_safe(f, next, &head->filters, list) {
 		fl_hw_destroy_filter(tp, (unsigned long)f);
 		list_del_rcu(&f->list);
+		tcf_unbind_filter(tp, &f->res);
 		call_rcu(&f->rcu, fl_destroy_filter);
 	}
 	RCU_INIT_POINTER(tp->root, NULL);
-- 
2.7.4
