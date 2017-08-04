From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 08/20] net: sched: use tcf_exts_has_actions instead of exts->nr_actions
Date: Fri,  4 Aug 2017 14:29:03 +0200
Message-ID: <20170804122915.15177-9-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36583 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752483AbdHDM3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:34 -0400
Received: by mail-wm0-f68.google.com with SMTP id d40so5519214wma.3
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:33 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

For check in tcf_exts_dump use tcf_exts_has_actions helper instead
of exts->nr_actions for checking if there are any actions present.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 287ae6c..735d556 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -915,7 +915,7 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 #ifdef CONFIG_NET_CLS_ACT
 	struct nlattr *nest;
 
-	if (exts->action && exts->nr_actions) {
+	if (exts->action && tcf_exts_has_actions(exts)) {
 		/*
 		 * again for backward compatible mode - we want
 		 * to work with both old and new modes of entering
-- 
2.9.3
