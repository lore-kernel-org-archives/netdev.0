From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net-next 1/1] net sched qdisc: pass netlink message flags in event notification
Date: Thu, 26 Oct 2017 17:40:14 -0400
Message-ID: <1509054014-23254-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:44385 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751886AbdJZVkV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 17:40:21 -0400
Received: by mail-io0-f194.google.com with SMTP id m16so8557218iod.1
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 14:40:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userland client should be able to read an event, and reflect it back to
the kernel, therefore it needs to extract complete set of netlink flags.
    
For example, this will allow "tc monitor" to distinguish Add and Replace
qdisc operations.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 net/sched/sch_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a9ac912..e3e29be 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -859,7 +859,7 @@ static int qdisc_notify(struct net *net, struct sk_buff *oskb,
 	}
 	if (new && !tc_qdisc_dump_ignore(new, false)) {
 		if (tc_fill_qdisc(skb, new, clid, portid, n->nlmsg_seq,
-				  old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
+				  n->nlmsg_flags, RTM_NEWQDISC) < 0)
 			goto err_out;
 	}
 
-- 
1.9.1
