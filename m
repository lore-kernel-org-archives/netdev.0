From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH] netback: remove redundant assignment
Date: Tue, 6 Dec 2011 10:08:20 +0000
Message-ID: <1323166100-7059-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, Wei Liu <wei.liu2@citrix.com>
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60643 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933037Ab1LFKIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 05:08:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New value for netbk->mmap_pages[pending_idx] is assigned in
xen_netbk_alloc_page(), no need for a second assignment which
exposes internal to the outside world.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 15e332d..3ecb5aa 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -940,8 +940,6 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		if (!page)
 			return NULL;
 
-		netbk->mmap_pages[pending_idx] = page;
-
 		gop->source.u.ref = txp->gref;
 		gop->source.domid = vif->domid;
 		gop->source.offset = txp->offset;
@@ -1336,8 +1334,6 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 			continue;
 		}
 
-		netbk->mmap_pages[pending_idx] = page;
-
 		gop->source.u.ref = txreq.gref;
 		gop->source.domid = vif->domid;
 		gop->source.offset = txreq.offset;
-- 
1.7.2.5
