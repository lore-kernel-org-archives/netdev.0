From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/12] netfilter: xt_CT: fix error value in xt_ct_tg_check()
Date: Mon,  6 Jan 2014 00:13:03 +0100
Message-ID: <1388963586-5049-10-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Leblond <eric@regit.org>

If setting event mask fails then we were returning 0 for success.
This patch updates return code to -EINVAL in case of problem.

Signed-off-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index da35ac0..5929be6 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -211,8 +211,10 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 	ret = 0;
 	if ((info->ct_events || info->exp_events) &&
 	    !nf_ct_ecache_ext_add(ct, info->ct_events, info->exp_events,
-				  GFP_KERNEL))
+				  GFP_KERNEL)) {
+		ret = -EINVAL;
 		goto err3;
+	}
 
 	if (info->helper[0]) {
 		ret = xt_ct_set_helper(ct, info->helper, par);
-- 
1.7.10.4

