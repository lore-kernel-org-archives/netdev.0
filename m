From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] net: sched: fix p_filter_chain check in tcf_chain_flush
Date: Fri, 18 Aug 2017 10:10:43 +0200
Message-ID: <20170818081043.2130-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33622 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbdHRIKr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:10:47 -0400
Received: by mail-wr0-f195.google.com with SMTP id 5so675859wrz.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 01:10:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The dereference before check is wrong and leads to an oops when
p_filter_chain is NULL. The check needs to be done on the pointer to
prevent NULL dereference.

Fixes: f93e1cdcf42c ("net/sched: fix filter flushing")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index ebeeb87..eef6b07 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -190,7 +190,7 @@ static void tcf_chain_flush(struct tcf_chain *chain)
 {
 	struct tcf_proto *tp;
 
-	if (*chain->p_filter_chain)
+	if (chain->p_filter_chain)
 		RCU_INIT_POINTER(*chain->p_filter_chain, NULL);
 	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
 		RCU_INIT_POINTER(chain->filter_chain, tp->next);
-- 
2.9.3
