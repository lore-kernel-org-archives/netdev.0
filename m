From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v10 2/4] net sched actions: Use proper root attribute table for actions
Date: Sun, 11 Jun 2017 07:53:44 -0400
Message-ID: <1497182026-11594-3-git-send-email-jhs@emojatatu.com>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35849 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbdFKLx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 07:53:59 -0400
Received: by mail-io0-f196.google.com with SMTP id i93so8354017iod.3
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 04:53:59 -0700 (PDT)
In-Reply-To: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
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
index aed6cf2..400eb6e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1072,7 +1072,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
-	struct nlattr *tca[TCA_ACT_MAX + 1];
+	struct nlattr *tca[TCAA_MAX + 1];
 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = 0, ovr = 0;
 
@@ -1080,7 +1080,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
 			  extack);
 	if (ret < 0)
 		return ret;
-- 
1.9.1
