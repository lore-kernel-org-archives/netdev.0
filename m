From: Cheng Renquan <crquan@gmail.com>
Subject: [PATCH] genetlink: remove superfluous assignment
Date: Wed, 28 May 2014 23:54:08 -0700
Message-ID: <1401346448-17105-1-git-send-email-crquan@gmail.com>
Cc: Johannes Berg <johannes.berg@intel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:64388 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbaE2GzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 02:55:01 -0400
Received: by mail-yk0-f180.google.com with SMTP id q9so9182410ykb.11
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 23:55:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the local variable ops and n_ops were just read out from family,
and not changed, why need to assign back?

Validation functions should operate on const parameters and not
change anything.

Signed-off-by: Cheng Renquan <crquan@gmail.com>

---
 net/netlink/genetlink.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

Index: linux-3.14.3/net/netlink/genetlink.c
===================================================================
--- linux-3.14.3.orig/net/netlink/genetlink.c	2014-05-06 07:59:58.000000000 -0700
+++ linux-3.14.3/net/netlink/genetlink.c	2014-05-28 23:42:46.325410152 -0700
@@ -307,39 +307,35 @@
 		genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, family,
 				&family->mcgrps[i], grp_id);
 	}
 }
 
-static int genl_validate_ops(struct genl_family *family)
+static int genl_validate_ops(const struct genl_family *family)
 {
 	const struct genl_ops *ops = family->ops;
 	unsigned int n_ops = family->n_ops;
 	int i, j;
 
 	if (WARN_ON(n_ops && !ops))
 		return -EINVAL;
 
 	if (!n_ops)
 		return 0;
 
 	for (i = 0; i < n_ops; i++) {
 		if (ops[i].dumpit == NULL && ops[i].doit == NULL)
 			return -EINVAL;
 		for (j = i + 1; j < n_ops; j++)
 			if (ops[i].cmd == ops[j].cmd)
 				return -EINVAL;
 	}
 
-	/* family is not registered yet, so no locking needed */
-	family->ops = ops;
-	family->n_ops = n_ops;
-
 	return 0;
 }
