From: Shuah Khan <shuah.khan@hp.com>
Subject: [PATCH RFT] net: Fix Neptune ethernet driver to check dma mapping
 error
Date: Fri, 20 Jul 2012 15:27:59 -0600
Message-ID: <1342819679.5434.50.camel@lorien2>
Reply-To: shuah.khan@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	shuahkhan@gmail.com, stable@vger.kernel.org
To: davem@davemloft.net, mcarlson@broadcom.com,
	bhutchings@solarflare.com, eric.dumazet@gmail.com,
	mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:11761 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab2GTV2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:28:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Request for testing, since I don't have the hardware to test.

--------------------------------------------------------------------

Fix Neptune ethernet driver to check dma mapping error after map_page()
interface returns.

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
Cc: <stable@vger.kernel.org>
---
 drivers/net/ethernet/sun/niu.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 8c726b7..60d5c03 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3335,6 +3335,10 @@ static int niu_rbr_add_page(struct niu *np, struct rx_ring_info *rp,
 
 	addr = np->ops->map_page(np->device, page, 0,
 				 PAGE_SIZE, DMA_FROM_DEVICE);
+	if (!addr) {
+		__free_page(page);
+		return -ENOMEM;
+	}
 
 	niu_hash_page(rp, page, addr);
 	if (rp->rbr_blocks_per_page > 1)
-- 
1.7.9.5
