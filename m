From: roy.qing.li@gmail.com
Subject: [PATCH] xfrm: fix the xfrm_policy/state_walk
Date: Wed, 22 Apr 2015 15:53:34 +0800
Message-ID: <1429689214-10827-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39018 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964935AbbDVHxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:53:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

If the walk from input is not empty, the following loop should start from
the walk->next, since walk is list header, and the last policy in previours
loop is connected walk tailor by list_move_tail()

Fixes: 12a169e7d8f(ipsec: Put dumpers on the dump list)
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_policy.c | 2 +-
 net/xfrm/xfrm_state.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d8c35ad..7a63148 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1004,7 +1004,7 @@ int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	if (list_empty(&walk->walk.all))
 		x = list_first_entry(&net->xfrm.policy_all, struct xfrm_policy_walk_entry, all);
 	else
-		x = list_entry(&walk->walk.all, struct xfrm_policy_walk_entry, all);
+		x = list_first_entry(&walk->walk.all, struct xfrm_policy_walk_entry, all);
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
