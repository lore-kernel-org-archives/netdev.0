From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 5/8] genetlink: remove genl_unregister_mc_group()
Date: Sat, 16 Nov 2013 18:03:46 +0100
Message-ID: <1384621429-24543-6-git-send-email-johannes@sipsolutions.net>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:57908 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab3KPREA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 12:04:00 -0500
In-Reply-To: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There are no users of this API remaining, and we'll soon
change group registration to be static (like ops are now)

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h |  2 --
 net/netlink/genetlink.c | 23 -----------------------
 2 files changed, 25 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 9bd52a4c..067569d 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -168,8 +168,6 @@ static inline int _genl_register_family_with_ops(struct genl_family *family,
 int genl_unregister_family(struct genl_family *family);
 int genl_register_mc_group(struct genl_family *family,
 			   struct genl_multicast_group *grp);
-void genl_unregister_mc_group(struct genl_family *family,
-			      struct genl_multicast_group *grp);
 void genl_notify(struct sk_buff *skb, struct net *net, u32 portid,
 		 u32 group, struct nlmsghdr *nlh, gfp_t flags);
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index d0757c6..9fa0607 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -265,29 +265,6 @@ static void __genl_unregister_mc_group(struct genl_family *family,
 	grp->family = NULL;
 }
 
-/**
- * genl_unregister_mc_group - unregister a multicast group
- *
- * Unregisters the specified multicast group and notifies userspace
- * about it. All current listeners on the group are removed.
- *
- * Note: It is not necessary to unregister all multicast groups before
- *       unregistering the family, unregistering the family will cause
- *       all assigned multicast groups to be unregistered automatically.
- *
- * @family: Generic netlink family the group belongs to.
- * @grp: The group to unregister, must have been registered successfully
- *	 previously.
- */
-void genl_unregister_mc_group(struct genl_family *family,
-			      struct genl_multicast_group *grp)
-{
-	genl_lock_all();
-	__genl_unregister_mc_group(family, grp);
-	genl_unlock_all();
-}
-EXPORT_SYMBOL(genl_unregister_mc_group);
-
 static void genl_unregister_mc_groups(struct genl_family *family)
 {
 	struct genl_multicast_group *grp, *tmp;
-- 
1.8.4.rc3
