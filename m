From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v6 1/3] net sched actions: User proper root attribute table for actions
Date: Fri, 21 Apr 2017 06:55:30 -0400
Message-ID: <1492772132-16559-2-git-send-email-jhs@emojatatu.com>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
Cc: jiri@resnulli.us, xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35841 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755827AbdDUKzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 06:55:52 -0400
Received: by mail-io0-f194.google.com with SMTP id x86so28994375ioe.3
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 03:55:52 -0700 (PDT)
In-Reply-To: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Bug fix for an issue which has been around for about a decade.
We got away with it because the enumeration was larger than needed.

Fixes commit 7ba699c604ab ("[NET_SCHED]: Convert actions from rtnetlink to new netlink API")

Thanks to Jiri Pirko for spotting it.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 82b1d48..9ce22b7 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -997,7 +997,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
-	struct nlattr *tca[TCA_ACT_MAX + 1];
+	struct nlattr *tca[TCAA_MAX + 1];
 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = 0, ovr = 0;
 
@@ -1005,7 +1005,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
 			  extack);
 	if (ret < 0)
 		return ret;
-- 
1.9.1
