From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net 1/1] net sched filters: fix filter handle ID in tfilter_notify_chain()
Date: Tue, 22 Nov 2016 20:57:04 -0500
Message-ID: <1479866224-12285-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34090 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756019AbcKWB5W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 20:57:22 -0500
Received: by mail-io0-f195.google.com with SMTP id r94so27346ioe.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 17:57:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should pass valid filter handle, not the netlink flags.

Fixes: 30a391a13ab92 ("net sched filters: pass netlink message flags in event notification")
Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/cls_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8e93d4a..b05d4a2 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -112,7 +112,7 @@ static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 
 	for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
 	     it_chain = &tp->next)
-		tfilter_notify(net, oskb, n, tp, n->nlmsg_flags, event, false);
+		tfilter_notify(net, oskb, n, tp, 0, event, false);
 }
 
 /* Select new prio value from the range, managed by kernel. */
-- 
1.9.1
