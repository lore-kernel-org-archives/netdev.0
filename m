From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next 2/2] net/sched: act_psample: Remove unnecessary ASSERT_RTNL
Date: Tue, 31 Jan 2017 11:33:54 +0200
Message-ID: <1485855234-9941-3-git-send-email-yotamg@mellanox.com>
References: <1485855234-9941-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: davem@davemloft.net, jhs@mojatatu.com, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46502 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751218AbdAaJcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:32:07 -0500
In-Reply-To: <1485855234-9941-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ASSERT_RTNL is not necessary in the init function, as it does not
touch any rtnl protected structures, as opposed to the mirred action which
does have to hold a net device.

Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/sched/act_sample.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index 02b6749..0b8217b 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -76,7 +76,6 @@ static int tcf_sample_init(struct net *net, struct nlattr *nla,
 	}
 	s = to_sample(*a);
 
-	ASSERT_RTNL();
 	s->tcf_action = parm->action;
 	s->rate = nla_get_u32(tb[TCA_SAMPLE_RATE]);
 	s->psample_group_num = nla_get_u32(tb[TCA_SAMPLE_PSAMPLE_GROUP]);
-- 
2.4.11
