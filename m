From: roy.qing.li@gmail.com
Subject: [PATCH][net-next][v2] xfrm: optimise the use of walk list header in xfrm_policy/state_walk
Date: Wed, 22 Apr 2015 17:09:54 +0800
Message-ID: <1429693794-17256-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53021 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756379AbbDVJL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 05:11:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The walk from input is the list header, and marked as dead, and will
be skipped in loop.

list_first_entry() can be used to return the true usable value from
walk if walk is not empty

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_policy.c | 4 +++-
 net/xfrm/xfrm_state.c  | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d8c35ad..847053e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1004,7 +1004,9 @@ int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	if (list_empty(&walk->walk.all))
 		x = list_first_entry(&net->xfrm.policy_all, struct xfrm_policy_walk_entry, all);
 	else
-		x = list_entry(&walk->walk.all, struct xfrm_policy_walk_entry, all);
+		x = list_first_entry(&walk->walk.all,
+				     struct xfrm_policy_walk_entry, all);
+
 	list_for_each_entry_from(x, &net->xfrm.policy_all, all) {
 		if (x->dead)
 			continue;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f5e39e3..df93183 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1626,7 +1626,7 @@ int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 	if (list_empty(&walk->all))
 		x = list_first_entry(&net->xfrm.state_all, struct xfrm_state_walk, all);
 	else
-		x = list_entry(&walk->all, struct xfrm_state_walk, all);
+		x = list_first_entry(&walk->all, struct xfrm_state_walk, all);
 	list_for_each_entry_from(x, &net->xfrm.state_all, all) {
 		if (x->state == XFRM_STATE_DEAD)
 			continue;
-- 
2.1.0
