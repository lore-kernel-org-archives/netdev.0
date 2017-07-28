From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/20] net: sched: fix return value of tcf_exts_exec
Date: Fri, 28 Jul 2017 16:40:28 +0200
Message-ID: <20170728144042.6380-7-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36675 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbdG1OlM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:12 -0400
Received: by mail-wr0-f195.google.com with SMTP id y67so25909435wrb.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:11 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Return the defined TC_ACT_OK instead of 0.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 817badf..61ce521 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -182,7 +182,7 @@ static inline bool tcf_exts_has_one_action(struct tcf_exts *exts)
  * @exts: tc filter extensions handle
  * @res: desired result
  *
- * Executes all configured extensions. Returns 0 on a normal execution,
+ * Executes all configured extensions. Returns TC_ACT_OK on a normal execution,
  * a negative number if the filter must be considered unmatched or
  * a positive action code (TC_ACT_*) which must be returned to the
  * underlying layer.
@@ -196,7 +196,7 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 		return tcf_action_exec(skb, exts->actions, exts->nr_actions,
 				       res);
 #endif
-	return 0;
+	return TC_ACT_OK;
 }
 
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
-- 
2.9.3
