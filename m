From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 2/2 v2] PS3: Remove the workaround no longer needed
Date: Fri, 31 Aug 2007 22:25:09 +0900
Message-ID: <20070831222404.C327.MOKUNO@sm.sony.co.jp>
References: <20070831220507.C31D.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NS5.Sony.CO.JP ([137.153.0.45]:58131 "EHLO ns5.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965017AbXHaNZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:25:25 -0400
In-Reply-To: <20070831220507.C31D.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed the workaround that was needed for PS3 firmware versions 
prior to the first release.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
CC: Geoff Levand <geoffrey.levand@am.sony.com>
---
 drivers/net/ps3_gelic_net.c |   16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -732,25 +732,17 @@ static int gelic_net_kick_txdma(struct g
 				struct gelic_net_descr *descr)
 {
 	int status = 0;
-	int count = 10;
 
 	if (card->tx_dma_progress)
 		return 0;
 
 	if (gelic_net_get_descr_status(descr) == GELIC_NET_DESCR_CARDOWNED) {
 		card->tx_dma_progress = 1;
-		/* sometimes we need retry here */
-		while (count--) {
-			status = lv1_net_start_tx_dma(bus_id(card),
-						      dev_id(card),
-						      descr->bus_addr, 0);
-			if (!status)
-				break;
-		}
-		if (!count)
+		status = lv1_net_start_tx_dma(bus_id(card), dev_id(card),
+					      descr->bus_addr, 0);
+		if (status)
 			dev_info(ctodev(card), "lv1_net_start_txdma failed," \
-				"status=%d %#lx\n",
-				 status, card->irq_status);
+				 "status=%d\n", status);
 	}
 	return status;
 }


-- 
Masakazu MOKUNO

