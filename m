From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] sched: Fix accidental removal of errout goto
Date: Tue, 14 Feb 2017 16:27:13 +0100
Message-ID: <1487086033-5486-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com,
        colin.king@canonical.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33765 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754141AbdBNP1Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 10:27:16 -0500
Received: by mail-wr0-f194.google.com with SMTP id i10so28065311wrb.0
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 07:27:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Bring back the goto that was removed by accident.

Reported-by: Colin Ian King <colin.king@canonical.com>
Fixes: 40c81b25b16c ("sched: check negative err value to safe one level of indent")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index abe1fe1..732f7ca 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -389,6 +389,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 				       RTM_DELTFILTER, false);
 			if (tcf_proto_destroy(tp, false))
 				RCU_INIT_POINTER(*back, next);
+			goto errout;
 		case RTM_GETTFILTER:
 			err = tfilter_notify(net, skb, n, tp, fh,
 					     RTM_NEWTFILTER, true);
-- 
2.7.4
