From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH] macb: Add rx overrun counter
Date: Wed, 13 Apr 2011 17:03:24 +0200
Message-ID: <1302707004-15818-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: netdev@vger.kernel.org,
	Alexander Stein <alexander.stein@systec-electronic.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox687.server-home.net ([195.149.74.151]:59186 "EHLO
	webbox687.server-home.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173Ab1DMPDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 11:03:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
 drivers/net/macb.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 79ccb54..76ce819 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -576,6 +576,11 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		 * add that if/when we get our hands on a full-blown MII PHY.
 		 */
 
+		if (status & MACB_BIT(ISR_ROVR)) {
+			/* We missed at least one packet */
+			bp->hw_stats.rx_overruns++;
+		}
+
 		if (status & MACB_BIT(HRESP)) {
 			/*
 			 * TODO: Reset the hardware, and maybe move the printk
@@ -1024,7 +1029,8 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 				   hwstat->rx_jabbers +
 				   hwstat->rx_undersize_pkts +
 				   hwstat->rx_length_mismatch);
-	nstat->rx_over_errors = hwstat->rx_resource_errors;
+	nstat->rx_over_errors = hwstat->rx_resource_errors +
+				   hwstat->rx_overruns;
 	nstat->rx_crc_errors = hwstat->rx_fcs_errors;
 	nstat->rx_frame_errors = hwstat->rx_align_errors;
 	nstat->rx_fifo_errors = hwstat->rx_overruns;
-- 
1.7.3.4

