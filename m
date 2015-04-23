From: roy.qing.li@gmail.com
Subject: [PATCH] xfrm: fix the return code when xfrm_*_register_afinfo failed
Date: Thu, 23 Apr 2015 11:06:53 +0800
Message-ID: <1429758413-30896-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58278 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756296AbbDWDHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 23:07:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

If xfrm_*_register_afinfo failed since xfrm_*_afinfo[afinfo->family] had the
value, return the -EEXIST, not -ENOBUFS

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_input.c  | 2 +-
 net/xfrm/xfrm_policy.c | 2 +-
 net/xfrm/xfrm_state.c  | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 526c4fe..459796a 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -29,7 +29,7 @@ int xfrm_input_register_afinfo(struct xfrm_input_afinfo *afinfo)
 		return -EAFNOSUPPORT;
 	spin_lock_bh(&xfrm_input_afinfo_lock);
 	if (unlikely(xfrm_input_afinfo[afinfo->family] != NULL))
-		err = -ENOBUFS;
+		err = -EEXIST;
 	else
 		rcu_assign_pointer(xfrm_input_afinfo[afinfo->family], afinfo);
 	spin_unlock_bh(&xfrm_input_afinfo_lock);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 847053e..c4c47f3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2808,7 +2808,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 		return -EAFNOSUPPORT;
 	spin_lock(&xfrm_policy_afinfo_lock);
 	if (unlikely(xfrm_policy_afinfo[afinfo->family] != NULL))
-		err = -ENOBUFS;
+		err = -EEXIST;
 	else {
 		struct dst_ops *dst_ops = afinfo->dst_ops;
 		if (likely(dst_ops->kmem_cachep == NULL))
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index df93183..e47e498 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1908,7 +1908,7 @@ int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo)
 		return -EAFNOSUPPORT;
 	spin_lock_bh(&xfrm_state_afinfo_lock);
 	if (unlikely(xfrm_state_afinfo[afinfo->family] != NULL))
-		err = -ENOBUFS;
+		err = -EEXIST;
 	else
 		rcu_assign_pointer(xfrm_state_afinfo[afinfo->family], afinfo);
 	spin_unlock_bh(&xfrm_state_afinfo_lock);
-- 
2.1.0
