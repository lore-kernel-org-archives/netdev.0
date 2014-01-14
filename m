From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: act: fix a bug in tcf_register_action()
Date: Tue, 14 Jan 2014 14:48:14 -0800
Message-ID: <1389739694-9251-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:62857 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbaANWsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 17:48:21 -0500
Received: by mail-pa0-f43.google.com with SMTP id rd3so277229pab.2
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 14:48:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcf_register_action() we check ->type and ->kind to see if there
is an existing action registered, but ipt action registers two
actions with same type but different kinds. This should be a valid
case, otherwise only xt can be registered.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 35f89e9..2070ee3 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -273,7 +273,7 @@ int tcf_register_action(struct tc_action_ops *act)
 
 	write_lock(&act_mod_lock);
 	list_for_each_entry(a, &act_base, head) {
-		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
+		if (act->type == a->type && (strcmp(act->kind, a->kind) == 0)) {
 			write_unlock(&act_mod_lock);
 			return -EEXIST;
 		}
