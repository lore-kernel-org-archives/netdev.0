From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 08/12] fec: align receive packets
Date: Wed, 15 Apr 2009 13:32:21 +0200
Message-ID: <1239795145-27558-9-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37836 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759421AbZDOLcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:32:48 -0400
In-Reply-To: <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we get a lot of alignment errors

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index a3037ab..be3226c 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -598,13 +598,14 @@ fec_enet_rx(struct net_device *dev)
 		 * include that when passing upstream as it messes up
 		 * bridging applications.
 		 */
-		skb = dev_alloc_skb(pkt_len - 4);
+		skb = dev_alloc_skb(pkt_len - 4 + NET_IP_ALIGN);
 
-		if (skb == NULL) {
+		if (unlikely(!skb)) {
 			printk("%s: Memory squeeze, dropping packet.\n",
 					dev->name);
 			dev->stats.rx_dropped++;
 		} else {
+			skb_reserve(skb, NET_IP_ALIGN);
 			skb_put(skb, pkt_len - 4);	/* Make room */
 			skb_copy_to_linear_data(skb, data, pkt_len - 4);
 			skb->protocol = eth_type_trans(skb, dev);
-- 
1.6.2.1

