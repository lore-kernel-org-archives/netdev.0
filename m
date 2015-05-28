From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/7] xfrm: optimise the use of walk list header in xfrm_policy/state_walk
Date: Thu, 28 May 2015 08:25:49 +0200
Message-ID: <1432794354-19391-3-git-send-email-steffen.klassert@secunet.com>
References: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49988 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515AbbE1G0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 02:26:22 -0400
In-Reply-To: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The walk from input is the list header, and marked as dead, and will
be skipped in loop.

list_first_entry() can be used to return the true usable value from
walk if walk is not empty

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
1.9.1
