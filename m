From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 2/4] xfrm: invalidate dst on policy insertion/deletion
Date: Mon, 10 Sep 2012 15:22:16 +0200
Message-ID: <1347283338-4249-3-git-send-email-nicolas.dichtel@6wind.com>
References: <20120907.144828.97793990734588625.davem@davemloft.net>
 <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: vyasevich@gmail.com, davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38173 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636Ab2IJNWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 09:22:14 -0400
In-Reply-To: <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a policy is inserted or deleted, all dst should be recalculated.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/xfrm/xfrm_policy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 741a32a..67f456d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -602,6 +602,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	xfrm_pol_hold(policy);
 	net->xfrm.policy_count[dir]++;
 	atomic_inc(&flow_cache_genid);
+	rt_genid_bump(net);
 	if (delpol)
 		__xfrm_policy_unlink(delpol, dir);
 	policy->index = delpol ? delpol->index : xfrm_gen_index(net, dir);
-- 
1.7.12
