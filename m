From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net] net: sched: set xt_tgchk_param par.nft_compat as 0 in ipt_init_target
Date: Wed,  9 Aug 2017 18:15:19 +0800
Message-ID: <35173c1e2c6272d137c24706186f1641496943ce.1502273719.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34869 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752562AbdHIKP2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 06:15:28 -0400
Received: by mail-pf0-f195.google.com with SMTP id j68so5738472pfc.2
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 03:15:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 55917a21d0cc ("netfilter: x_tables: add context to know if
extension runs from nft_compat") introduced a member nft_compat to
xt_tgchk_param structure.

But it didn't set it's value for ipt_init_target. With unexpected
value in par.nft_compat, it may return unexpected result in some
target's checkentry.

This patch is to set all it's fields as 0 and only initialize the
non-zero fields in ipt_init_target.

v1->v2:
  As Wang Cong's suggestion, fix it by setting all it's fields as
  0 and only initializing the non-zero fields.

Fixes: 55917a21d0cc ("netfilter: x_tables: add context to know if extension runs from nft_compat")
Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sched/act_ipt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 94ba5cf..d516ba8 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -49,9 +49,9 @@ static int ipt_init_target(struct net *net, struct xt_entry_target *t,
 		return PTR_ERR(target);
 
 	t->u.kernel.target = target;
+	memset(&par, 0, sizeof(par));
 	par.net       = net;
 	par.table     = table;
-	par.entryinfo = NULL;
 	par.target    = target;
 	par.targinfo  = t->data;
 	par.hook_mask = hook;
-- 
2.1.0
