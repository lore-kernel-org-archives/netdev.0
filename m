From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] genetlink: fix genl_set_err() group ID
Date: Thu, 21 Nov 2013 18:20:28 +0100
Message-ID: <1385054428-6447-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:50892 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381Ab3KURUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 12:20:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Fix another really stupid bug - I introduced genl_set_err()
precisely to be able to adjust the group and reject invalid
ones, but then forgot to do so.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 771af09..1b177ed 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -384,6 +384,9 @@ static inline struct sk_buff *genlmsg_new(size_t payload, gfp_t flags)
 static inline int genl_set_err(struct genl_family *family, struct net *net,
 			       u32 portid, u32 group, int code)
 {
+	if (WARN_ON_ONCE(group >= family->n_mcgrps))
+		return -EINVAL;
+	group = family->mcgrp_offset + group;
 	return netlink_set_err(net->genl_sock, portid, group, code);
 }
 
-- 
1.8.4.rc3
