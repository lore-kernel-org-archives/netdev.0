From: pedro <marzo.pedro@gmail.com>
Subject: [PATCH 1/1] xen-netback: remove compilation warning
Date: Thu, 26 Feb 2015 09:25:41 +0100
Message-ID: <1424939141-30730-1-git-send-email-marzo.pedro@gmail.com>
Cc: pmarzo <marzo.pedro@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:38848 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812AbbBZIZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 03:25:53 -0500
Received: by wesw55 with SMTP id w55so8464923wes.5
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 00:25:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pmarzo <marzo.pedro@gmail.com>

offset and size are of type uint16_t so the %lu gives a warning
A %u specifier, the same used in size makes gcc happy
Not sure if a %x would be more correct

Signed-off-by: Pedro Marzo Perez <marzo.pedro@gmail.com>
---
 drivers/net/xen-netback/netback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f7a31d2..3888a2b 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1248,7 +1248,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 		/* No crossing a page as the payload mustn't fragment. */
 		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
 			netdev_err(queue->vif->dev,
-				   "txreq.offset: %x, size: %u, end: %lu\n",
+				   "txreq.offset: %x, size: %u, end: %u\n",
 				   txreq.offset, txreq.size,
 				   (txreq.offset&~PAGE_MASK) + txreq.size);
 			xenvif_fatal_tx_err(queue->vif);
-- 
1.9.1
