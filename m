From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: act: pick a different type for act_xt
Date: Wed, 15 Jan 2014 15:38:43 -0800
Message-ID: <1389829123-22914-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34936 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaAOXiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:38:52 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so277469pab.35
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 15:38:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcf_register_action() we check either ->type or ->kind to see if
there is an existing action registered, but ipt action registers two
actions with same type but different kinds. They should have different
types too.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/uapi/linux/tc_act/tc_ipt.h | 1 +
 net/sched/act_ipt.c                | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tc_act/tc_ipt.h b/include/uapi/linux/tc_act/tc_ipt.h
index a233556..130aaad 100644
--- a/include/uapi/linux/tc_act/tc_ipt.h
+++ b/include/uapi/linux/tc_act/tc_ipt.h
@@ -4,6 +4,7 @@
 #include <linux/pkt_cls.h>
 
 #define TCA_ACT_IPT 6
+#define TCA_ACT_XT 10
 
 enum {
 	TCA_IPT_UNSPEC,
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 484bd19..bc9f498 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -298,7 +298,7 @@ static struct tc_action_ops act_ipt_ops = {
 static struct tc_action_ops act_xt_ops = {
 	.kind		=	"xt",
 	.hinfo		=	&ipt_hash_info,
-	.type		=	TCA_ACT_IPT,
+	.type		=	TCA_ACT_XT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_ipt,
-- 
1.8.3.1
