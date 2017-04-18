From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: [PATCH v2 net 1/2] net sched actions: fix access to uninitialized data
Date: Tue, 18 Apr 2017 12:13:21 +0200
Message-ID: <20170418101322.27666-1-w.bumiller@proxmox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxmox.maurer-it.com ([212.186.127.180]:2471 "EHLO
        proxmox.maurer-it.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932288AbdDRKNZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 06:13:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
(same as v1)

 net/sched/act_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index b70aa57319ea..8cc883c063f0 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -604,7 +604,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (err < 0)
 		goto err_mod;
 
-	if (tb[TCA_ACT_COOKIE]) {
+	if (name == NULL && tb[TCA_ACT_COOKIE]) {
 		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
 
 		if (cklen > TC_COOKIE_MAX_SIZE) {
-- 
2.11.0
