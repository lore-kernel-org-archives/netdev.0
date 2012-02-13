From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 8/8] tg3: Move transmit comment to a better location
Date: Mon, 13 Feb 2012 12:20:12 -0800
Message-ID: <1329164412-24566-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4234 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757948Ab2BMUUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:20:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves a comment in the transmit path to a better location.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b89c932..d418f95 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6923,7 +6923,6 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			  ((skb_shinfo(skb)->nr_frags == 0) ? TXD_FLAG_END : 0),
 			    mss, vlan)) {
 		would_hit_hwbug = 1;
-	/* Now loop through additional data fragments, and queue them. */
 	} else if (skb_shinfo(skb)->nr_frags > 0) {
 		u32 tmp_mss = mss;
 
@@ -6932,6 +6931,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		    !tg3_flag(tp, HW_TSO_3))
 			tmp_mss = 0;
 
+		/* Now loop through additional data
+		 * fragments, and queue them.
+		 */
 		last = skb_shinfo(skb)->nr_frags - 1;
 		for (i = 0; i <= last; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-- 
1.7.3.4
