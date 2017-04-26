From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v9 1/3] net sched actions: Use proper root attribute table for actions
Date: Wed, 26 Apr 2017 08:42:16 -0400
Message-ID: <1493210538-21716-2-git-send-email-jhs@emojatatu.com>
References: <1493210538-21716-1-git-send-email-jhs@emojatatu.com>
Cc: jiri@resnulli.us, xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, netdev@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34553 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2999760AbdDZMmu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 08:42:50 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so303599ioi.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 05:42:50 -0700 (PDT)
In-Reply-To: <1493210538-21716-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Bug fix for an issue which has been around for about a decade.
We got away with it because the enumeration was larger than needed.

Fixes: 7ba699c604ab ("[NET_SCHED]: Convert actions from rtnetlink to new netlink API")
Suggested-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 7f2cd70..9d0f007 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1031,7 +1031,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
-	struct nlattr *tca[TCA_ACT_MAX + 1];
+	struct nlattr *tca[TCAA_MAX + 1];
 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = 0, ovr = 0;
 
@@ -1039,7 +1039,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
 			  extack);
 	if (ret < 0)
 		return ret;
-- 
1.9.1
