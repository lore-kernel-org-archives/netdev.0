From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 6/6] xfrm: invalidate dst on policy insertion/deletion
Date: Fri, 19 Oct 2012 15:22:29 -0400
Message-ID: <20121019192229.GF8315@kvack.org>
References: <20121019191347.GD13515@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:43187 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757715Ab2JSTW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:22:29 -0400
Content-Disposition: inline
In-Reply-To: <20121019191347.GD13515@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ee8372dd1989287c5eedb69d44bac43f69e496f1
Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date:   Mon Sep 10 22:09:45 2012 +0000

    xfrm: invalidate dst on policy insertion/deletion

    When a policy is inserted or deleted, all dst should be recalculated.

    Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/xfrm/xfrm_policy.c          |    1 +
 security/selinux/include/xfrm.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1ae61bd..3aa00e1 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -587,6 +587,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	xfrm_pol_hold(policy);
 	net->xfrm.policy_count[dir]++;
 	atomic_inc(&flow_cache_genid);
+	rt_genid_bump(net);
 	if (delpol)
 		__xfrm_policy_unlink(delpol, dir);
 	policy->index = delpol ? delpol->index : xfrm_gen_index(net, dir);
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 13128f9..9acf6fa 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -49,6 +49,7 @@ int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall);
 static inline void selinux_xfrm_notify_policyload(void)
 {
 	atomic_inc(&flow_cache_genid);
+	rt_genid_bump(&init_net);
 }
 #else
 static inline int selinux_xfrm_enabled(void)
-- 
1.7.1


-- 
"Thought is the essence of where you are now."
