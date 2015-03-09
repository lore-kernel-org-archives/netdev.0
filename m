From: Josh Cartwright <joshc@ni.com>
Subject: [PATCH] net: macb: constify macb configuration data
Date: Mon, 9 Mar 2015 11:14:39 -0500
Message-ID: <1425917679-11956-1-git-send-email-joshc@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:47375 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754741AbbCIQOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 12:14:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The configurations are not modified by the driver.  Make them 'const' so
that they may be placed in a read-only section.

Signed-off-by: Josh Cartwright <joshc@ni.com>
---
 drivers/net/ethernet/cadence/macb.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 1fe8b94..2c30572 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2131,17 +2131,17 @@ static const struct net_device_ops macb_netdev_ops = {
 };
 
 #if defined(CONFIG_OF)
-static struct macb_config pc302gem_config = {
+static const struct macb_config pc302gem_config = {
 	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
 	.dma_burst_length = 16,
 };
 
-static struct macb_config sama5d3_config = {
+static const struct macb_config sama5d3_config = {
 	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
 	.dma_burst_length = 16,
 };
 
-static struct macb_config sama5d4_config = {
+static const struct macb_config sama5d4_config = {
 	.caps = 0,
 	.dma_burst_length = 4,
 };
@@ -2172,7 +2172,7 @@ static void macb_configure_caps(struct macb *bp)
 	if (bp->pdev->dev.of_node) {
 		match = of_match_node(macb_dt_ids, bp->pdev->dev.of_node);
 		if (match && match->data) {
-			config = (const struct macb_config *)match->data;
+			config = match->data;
 
 			bp->caps = config->caps;
 			/*
-- 
2.3.2
