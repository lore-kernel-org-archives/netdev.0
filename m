From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 3/4] xen-netback: remove skb in xen_netbk_alloc_page
Date: Mon, 18 Mar 2013 10:35:54 +0000
Message-ID: <1363602955-24790-4-git-send-email-wei.liu2@citrix.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23973 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab3CRKgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 06:36:15 -0400
In-Reply-To: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This variable is never used.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index da726a3..6e8e51a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -948,7 +948,6 @@ static int netbk_count_requests(struct xenvif *vif,
 }
 
 static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
-					 struct sk_buff *skb,
 					 u16 pending_idx)
 {
 	struct page *page;
@@ -982,7 +981,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 
 		index = pending_index(netbk->pending_cons++);
 		pending_idx = netbk->pending_ring[index];
-		page = xen_netbk_alloc_page(netbk, skb, pending_idx);
+		page = xen_netbk_alloc_page(netbk, pending_idx);
 		if (!page)
 			goto err;
 
@@ -1387,7 +1386,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		}
 
 		/* XXX could copy straight to head */
-		page = xen_netbk_alloc_page(netbk, skb, pending_idx);
+		page = xen_netbk_alloc_page(netbk, pending_idx);
 		if (!page) {
 			kfree_skb(skb);
 			netbk_tx_err(vif, &txreq, idx);
-- 
1.7.10.4
