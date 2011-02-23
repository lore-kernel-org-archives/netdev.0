From: David Miller <davem@davemloft.net>
Subject: [PATCH 08/20] xfrm: Mark flowi arg to
 security_xfrm_state_pol_flow_match() const.
Date: Tue, 22 Feb 2011 19:54:30 -0800 (PST)
Message-ID: <20110222.195430.59660887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32836
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753025Ab1BWDxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:54 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 12A4F24C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/security.h        |    7 ++++---
 security/capability.c           |    2 +-
 security/security.c             |    3 ++-
 security/selinux/include/xfrm.h |    2 +-
 security/selinux/xfrm.c         |    2 +-
 5 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index b2b7f97..9b5f184 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1623,7 +1623,7 @@ struct security_operations {
 	int (*xfrm_policy_lookup) (struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir);
 	int (*xfrm_state_pol_flow_match) (struct xfrm_state *x,
 					  struct xfrm_policy *xp,
-					  struct flowi *fl);
+					  const struct flowi *fl);
 	int (*xfrm_decode_session) (struct sk_buff *skb, u32 *secid, int ckall);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
@@ -2761,7 +2761,8 @@ int security_xfrm_state_delete(struct xfrm_state *x);
 void security_xfrm_state_free(struct xfrm_state *x);
 int security_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir);
 int security_xfrm_state_pol_flow_match(struct xfrm_state *x,
-				       struct xfrm_policy *xp, struct flowi *fl);
+				       struct xfrm_policy *xp,
+				       const struct flowi *fl);
 int security_xfrm_decode_session(struct sk_buff *skb, u32 *secid);
 void security_skb_classify_flow(struct sk_buff *skb, struct flowi *fl);
 
@@ -2813,7 +2814,7 @@ static inline int security_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_s
 }
 
 static inline int security_xfrm_state_pol_flow_match(struct xfrm_state *x,
-			struct xfrm_policy *xp, struct flowi *fl)
+			struct xfrm_policy *xp, const struct flowi *fl)
 {
 	return 1;
 }
diff --git a/security/capability.c b/security/capability.c
index 2a5df2b..b8eeaee 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -760,7 +760,7 @@ static int cap_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 sk_sid, u8 dir)
 
 static int cap_xfrm_state_pol_flow_match(struct xfrm_state *x,
 					 struct xfrm_policy *xp,
-					 struct flowi *fl)
+					 const struct flowi *fl)
 {
 	return 1;
 }
diff --git a/security/security.c b/security/security.c
index 7b7308a..8ef1f7d 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1233,7 +1233,8 @@ int security_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir)
 }
 
 int security_xfrm_state_pol_flow_match(struct xfrm_state *x,
-				       struct xfrm_policy *xp, struct flowi *fl)
+				       struct xfrm_policy *xp,
+				       const struct flowi *fl)
 {
 	return security_ops->xfrm_state_pol_flow_match(x, xp, fl);
 }
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 13128f9..b43813c 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -19,7 +19,7 @@ void selinux_xfrm_state_free(struct xfrm_state *x);
 int selinux_xfrm_state_delete(struct xfrm_state *x);
 int selinux_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir);
 int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x,
-			struct xfrm_policy *xp, struct flowi *fl);
+			struct xfrm_policy *xp, const struct flowi *fl);
 
 /*
  * Extract the security blob from the sock (it's actually on the socket)
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index fff78d3..c43ab54 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -112,7 +112,7 @@ int selinux_xfrm_policy_lookup(struct xfrm_sec_ctx *ctx, u32 fl_secid, u8 dir)
  */
 
 int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x, struct xfrm_policy *xp,
-			struct flowi *fl)
+			const struct flowi *fl)
 {
 	u32 state_sid;
 	int rc;
-- 
1.7.4.1

