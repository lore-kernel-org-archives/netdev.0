From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next] xen-netback: remove dead code
Date: Fri, 17 May 2013 10:24:28 +0100
Message-ID: <1368782668-23952-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:48812 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827Ab3EQJYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 05:24:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The array mmap_pages is never touched in the initialization function. This is
remnant of mapping mechanism, which does not exist upstream. In current
upstream code this array only tracks usage of pages inside netback. Those
pages are allocated when contructing a SKB and passed directly to network
subsystem.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
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
