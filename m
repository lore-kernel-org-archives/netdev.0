From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V2] net/sched: pkt_cls: change tc actions order to be as the user sets
Date: Tue, 27 Sep 2016 11:09:51 +0300
Message-ID: <1474963791-3717-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53851 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751750AbcI0IKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 04:10:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the created tc actions list is reversed against the order
set by the user.
Change the actions list order to be the same as was set by the user.

This patch doesn't affect dump actions behavior.
For dumping, action->order parameter is used so the list order doesn't
matter.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/pkt_cls.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 5ccaa4b..767b03a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -123,7 +123,7 @@ static inline void tcf_exts_to_list(const struct tcf_exts *exts,
 	for (i = 0; i < exts->nr_actions; i++) {
 		struct tc_action *a = exts->actions[i];
 
-		list_add(&a->list, actions);
+		list_add_tail(&a->list, actions);
 	}
 #endif
 }
-- 
1.8.3.1
