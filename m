From: "Josef 'Jeff' Sipek" <jsipek@cs.sunysb.edu>
Subject: [PATCH 1/1] net/core: Fix error handling
Date: Sun,  6 May 2007 19:20:43 -0400
Message-ID: <11784936433022-git-send-email-jsipek@cs.sunysb.edu>
Cc: "Josef 'Jeff' Sipek" <jsipek@cs.sunysb.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:43035 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbXEFXUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 19:20:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upon failure to register "ptype" procfs entry, "softnet_stat" was not
removed, and an incorrect attempt was made to remove the "ptype" entry.

Signed-off-by: Josef 'Jeff' Sipek <jsipek@cs.sunysb.edu>
---
 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d5e42d1..d8dc621 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2365,9 +2365,9 @@ static int __init dev_proc_init(void)
 out:
 	return rc;
 out_softnet:
-	proc_net_remove("softnet_stat");
-out_dev2:
 	proc_net_remove("ptype");
+out_dev2:
+	proc_net_remove("softnet_stat");
 out_dev:
 	proc_net_remove("dev");
 	goto out;
-- 
1.5.2.rc1.20.g86b9

