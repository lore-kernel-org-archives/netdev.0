From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/7] xfrm: fix the return code when xfrm_*_register_afinfo failed
Date: Thu, 28 May 2015 08:25:50 +0200
Message-ID: <1432794354-19391-4-git-send-email-steffen.klassert@secunet.com>
References: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49996 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673AbbE1G0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 02:26:24 -0400
In-Reply-To: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

If xfrm_*_register_afinfo failed since xfrm_*_afinfo[afinfo->family] had the
value, return the -EEXIST, not -ENOBUFS

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
1.9.1
