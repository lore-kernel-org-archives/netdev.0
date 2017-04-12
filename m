From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: [PATCH linux 1/2] net sched actions: fix access to uninitialized data
Date: Wed, 12 Apr 2017 16:21:39 +0200
Message-ID: <20170412142140.26649-2-w.bumiller@proxmox.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
Cc: linux-kernel@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412142140.26649-1-w.bumiller@proxmox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
---
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
