From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH] Remove unused parameter of xfrm_gen_index()
Date: Wed, 12 Nov 2008 14:10:03 +0100
Message-ID: <87zlk5ccpg.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:33553 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828AbYKLN0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 08:26:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

In commit 2518c7c2b3d7f0a6b302b4efe17c911f8dd4049f, the last use of
xfrm_gen_policy() first argument was removed, but the argument was
left behind in the prototype. Patch is against current net-2.6.


Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 net/xfrm/xfrm_policy.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 058f04f..959958c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -521,7 +521,7 @@ static DECLARE_WORK(xfrm_hash_work, xfrm_hash_resize);
 
 /* Generate new index... KAME seems to generate them ordered by cost
  * of an absolute inpredictability of ordering of rules. This will not pass. */
-static u32 xfrm_gen_index(u8 type, int dir)
+static u32 xfrm_gen_index(int dir)
 {
 	static u32 idx_generator;
 
@@ -608,7 +608,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		list_del(&delpol->walk.all);
 		xfrm_policy_count[dir]--;
 	}
-	policy->index = delpol ? delpol->index : xfrm_gen_index(policy->type, dir);
+	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
 	hlist_add_head(&policy->byidx, xfrm_policy_byidx+idx_hash(policy->index));
 	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
@@ -1138,7 +1138,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 	sk->sk_policy[dir] = pol;
 	if (pol) {
 		pol->curlft.add_time = get_seconds();
-		pol->index = xfrm_gen_index(pol->type, XFRM_POLICY_MAX+dir);
+		pol->index = xfrm_gen_index(XFRM_POLICY_MAX+dir);
 		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
 	}
 	if (old_pol)
-- 
1.5.6.5


