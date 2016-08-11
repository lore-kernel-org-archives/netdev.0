From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 7/8] xfrm: policy: don't acquire policy lock in xfrm_spd_getinfo
Date: Thu, 11 Aug 2016 15:17:58 +0200
Message-ID: <1470921479-25592-8-git-send-email-fw@strlen.de>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54990 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752563AbcHKNSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:18:05 -0400
In-Reply-To: <1470921479-25592-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't seem that important.

We now get inconsistent view of the counters, but those are stale anyway
right after we drop the lock.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 575a48b..3ff5893 100644
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
2.7.3
