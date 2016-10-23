From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net 1/1] net sched filters: fix notification of filter delete with proper handle
Date: Sun, 23 Oct 2016 11:35:12 -0400
Message-ID: <1477236912-5789-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, eric.dumazet@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36354 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754618AbcJWPfT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 11:35:19 -0400
Received: by mail-it0-f65.google.com with SMTP id m138so187129itm.3
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 08:35:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/cls_api.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 2ee29a3..2b2a797 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -345,7 +345,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			if (err == 0) {
 				struct tcf_proto *next = rtnl_dereference(tp->next);
 
-				tfilter_notify(net, skb, n, tp, fh,
+				tfilter_notify(net, skb, n, tp,
+					       t->tcm_handle,
 					       RTM_DELTFILTER, false);
 				if (tcf_destroy(tp, false))
 					RCU_INIT_POINTER(*back, next);
-- 
1.9.1
