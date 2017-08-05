From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] net: sched: set xt_tgchk_param par.nft_compat with false in ipt_init_target
Date: Sat,  5 Aug 2017 19:32:59 +0800
Message-ID: <985e6cb7c94f0014096ebca47e1efd74e022dc8d.1501932779.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Pablo Neira Ayuso <pablo@netfilter.org>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33929 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbdHELdH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 07:33:07 -0400
Received: by mail-pg0-f68.google.com with SMTP id y192so4186031pgd.1
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 04:33:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 55917a21d0cc ("netfilter: x_tables: add context to know if
extension runs from nft_compat") introduced a member nft_compat to
xt_tgchk_param structure.

But it didn't set it's value for ipt_init_target. With unexpected
value in par.nft_compat, it may return unexpected result in some
target's checkentry.

This patch is to set par.nft_compat with false in ipt_init_target.

Fixes: 55917a21d0cc ("netfilter: x_tables: add context to know if extension runs from nft_compat")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sched/act_ipt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index bb06d2ed..7c4816b 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -56,6 +56,7 @@ static int ipt_init_target(struct net *net, struct xt_entry_target *t,
 	par.targinfo  = t->data;
 	par.hook_mask = hook;
 	par.family    = NFPROTO_IPV4;
+	par.nft_compat = false;
 
 	ret = xt_check_target(&par, t->u.target_size - sizeof(*t), 0, false);
 	if (ret < 0) {
-- 
2.1.0
