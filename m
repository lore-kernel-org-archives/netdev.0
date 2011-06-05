From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] fix return values of l2tp_dfs_seq_open()
Date: Sun, 5 Jun 2011 11:54:03 +0100
Message-ID: <20110605105403.GC11521@ZenIV.linux.org.uk>
References: <20110604222531.GA11521@ZenIV.linux.org.uk>
 <20110605103735.GB11521@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46795 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305Ab1FEKyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 06:54:04 -0400
Content-Disposition: inline
In-Reply-To: <20110605103735.GB11521@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More fallout from struct net lifetime rules review: PTR_ERR() is *already*
negative and failing ->open() should return negatives on failure.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index b8dbae8..7613013 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -258,7 +258,7 @@ static int l2tp_dfs_seq_open(struct inode *inode, struct file *file)
 	 */
 	pd->net = get_net_ns_by_pid(current->pid);
 	if (IS_ERR(pd->net)) {
-		rc = -PTR_ERR(pd->net);
+		rc = PTR_ERR(pd->net);
 		goto err_free_pd;
 	}
 
