From: gfilip@ee.ethz.ch
Subject: [PATCH 5/5] temac: add missing mask
Date: Mon, 22 Feb 2010 20:07:01 +0100
Message-ID: <1266865621-28955-5-git-send-email-gfilip@ee.ethz.ch>
References: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
 <1266865621-28955-2-git-send-email-gfilip@ee.ethz.ch>
 <1266865621-28955-3-git-send-email-gfilip@ee.ethz.ch>
 <1266865621-28955-4-git-send-email-gfilip@ee.ethz.ch>
Cc: glikely@secretlab.ca, Filip Gospodinov <gfilip@ee.ethz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:56344 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753208Ab0BVTOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 14:14:36 -0500
In-Reply-To: <1266865621-28955-4-git-send-email-gfilip@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For Virtex4-FX this mask is necessary. I think this is also true for Virtex5. Please test.

Signed-off-by: Filip Gospodinov <gfilip@ee.ethz.ch>
---
 drivers/net/ll_temac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 8b4e1b9..43d51b7 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -627,7 +627,7 @@ static void ll_temac_recv(struct net_device *ndev)
 	while ((bdstat & STS_CTRL_APP0_CMPLT)) {
 
 		skb = lp->rx_skb[lp->rx_bd_ci];
-		length = cur_p->app4;
+		length = (cur_p->app4 & 0x3fff);
 
 		skb_vaddr = virt_to_bus(skb->data);
 		dma_unmap_single(ndev->dev.parent, skb_vaddr, length,
-- 
1.6.4.4

