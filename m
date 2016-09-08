From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 14/17] xfrm: policy: don't acquire policy lock in xfrm_spd_getinfo
Date: Thu, 8 Sep 2016 07:54:49 +0200
Message-ID: <1473314092-11319-15-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36359 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753935AbcIHGv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:26 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

It doesn't seem that important.

We now get inconsistent view of the counters, but those are stale anyway
right after we drop the lock.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3d27b9a..35b85a9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -560,7 +560,6 @@ static inline int xfrm_byidx_should_resize(struct net *net, int total)
 
 void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si)
 {
-	read_lock_bh(&net->xfrm.xfrm_policy_lock);
 	si->incnt = net->xfrm.policy_count[XFRM_POLICY_IN];
 	si->outcnt = net->xfrm.policy_count[XFRM_POLICY_OUT];
 	si->fwdcnt = net->xfrm.policy_count[XFRM_POLICY_FWD];
@@ -569,7 +568,6 @@ void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si)
 	si->fwdscnt = net->xfrm.policy_count[XFRM_POLICY_FWD+XFRM_POLICY_MAX];
 	si->spdhcnt = net->xfrm.policy_idx_hmask;
 	si->spdhmcnt = xfrm_policy_hashmax;
-	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 }
 EXPORT_SYMBOL(xfrm_spd_getinfo);
 
-- 
1.9.1
