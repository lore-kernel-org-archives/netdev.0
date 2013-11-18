From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] genetlink: rename shadowed variable
Date: Mon, 18 Nov 2013 20:54:58 +0100
Message-ID: <1384804498-7482-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:38348 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab3KRTzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:55:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Sparse pointed out that the new flags variable I had added
shadowed an existing one, rename the new one to avoid that,
making the code clearer.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/genetlink.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 9bdc581..7dbc4f7 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -680,21 +680,21 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 		for (i = 0; i < family->n_ops; i++) {
 			struct nlattr *nest;
 			const struct genl_ops *ops = &family->ops[i];
-			u32 flags = ops->flags;
+			u32 op_flags = ops->flags;
 
 			if (ops->dumpit)
-				flags |= GENL_CMD_CAP_DUMP;
+				op_flags |= GENL_CMD_CAP_DUMP;
 			if (ops->doit)
-				flags |= GENL_CMD_CAP_DO;
+				op_flags |= GENL_CMD_CAP_DO;
 			if (ops->policy)
-				flags |= GENL_CMD_CAP_HASPOL;
+				op_flags |= GENL_CMD_CAP_HASPOL;
 
 			nest = nla_nest_start(skb, i + 1);
 			if (nest == NULL)
 				goto nla_put_failure;
 
 			if (nla_put_u32(skb, CTRL_ATTR_OP_ID, ops->cmd) ||
-			    nla_put_u32(skb, CTRL_ATTR_OP_FLAGS, flags))
+			    nla_put_u32(skb, CTRL_ATTR_OP_FLAGS, op_flags))
 				goto nla_put_failure;
 
 			nla_nest_end(skb, nest);
-- 
1.8.4.rc3
