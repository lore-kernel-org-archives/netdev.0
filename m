From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/26] xfrm: Const'ify selector args in xfrm_migrate paths.
Date: Wed, 23 Feb 2011 23:13:39 -0800 (PST)
Message-ID: <20110223.231339.246538101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38706
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932756Ab1BXHND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:13:03 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B943E24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    2 +-
 net/xfrm/xfrm_policy.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 17b296b..1806c91 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1493,7 +1493,7 @@ extern int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 extern struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m);
 extern struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
 					      struct xfrm_migrate *m);
-extern int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
+extern int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 			struct xfrm_migrate *m, int num_bundles,
 			struct xfrm_kmaddress *k);
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0770b3a..0c503be 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2736,8 +2736,8 @@ EXPORT_SYMBOL_GPL(xfrm_audit_policy_delete);
 #endif
 
 #ifdef CONFIG_XFRM_MIGRATE
-static int xfrm_migrate_selector_match(struct xfrm_selector *sel_cmp,
-				       struct xfrm_selector *sel_tgt)
+static int xfrm_migrate_selector_match(const struct xfrm_selector *sel_cmp,
+				       const struct xfrm_selector *sel_tgt)
 {
 	if (sel_cmp->proto == IPSEC_ULPROTO_ANY) {
 		if (sel_tgt->family == sel_cmp->family &&
@@ -2757,7 +2757,7 @@ static int xfrm_migrate_selector_match(struct xfrm_selector *sel_cmp,
 	return 0;
 }
 
-static struct xfrm_policy * xfrm_migrate_policy_find(struct xfrm_selector *sel,
+static struct xfrm_policy * xfrm_migrate_policy_find(const struct xfrm_selector *sel,
 						     u8 dir, u8 type)
 {
 	struct xfrm_policy *pol, *ret = NULL;
@@ -2897,7 +2897,7 @@ static int xfrm_migrate_check(const struct xfrm_migrate *m, int num_migrate)
 	return 0;
 }
 
-int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
+int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		 struct xfrm_migrate *m, int num_migrate,
 		 struct xfrm_kmaddress *k)
 {
-- 
1.7.4.1

