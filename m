From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH] xen-netback: remove dead code
Date: Mon, 6 May 2013 16:40:20 +0100
Message-ID: <1367854820-4129-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:51275 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754953Ab3EFPkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 11:40:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The array mmap_pages is never touched in the initialization function. This is
remnant of mapping mechanism, which does exist upstream.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 37984e6..295a9c2 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1939,10 +1939,6 @@ static int __init netback_init(void)
 failed_init:
 	while (--group >= 0) {
 		struct xen_netbk *netbk = &xen_netbk[group];
-		for (i = 0; i < MAX_PENDING_REQS; i++) {
-			if (netbk->mmap_pages[i])
-				__free_page(netbk->mmap_pages[i]);
-		}
 		del_timer(&netbk->net_timer);
 		kthread_stop(netbk->task);
 	}
-- 
1.7.10.4
