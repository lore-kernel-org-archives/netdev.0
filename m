From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 6/7] r8169: missing barriers.
Date: Fri, 27 Jan 2012 21:58:43 +0100
Message-ID: <20120127205843.GF24507@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57459 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab2A0VJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:09:37 -0500
Content-Disposition: inline
In-Reply-To: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 610f4b3..8dd13f5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5552,7 +5552,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-		smp_rmb();
+		smp_mb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
 			netif_wake_queue(dev);
 	}
@@ -5653,7 +5653,7 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-		smp_wmb();
+		smp_mb();
 		if (netif_queue_stopped(dev) &&
 		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
@@ -5664,7 +5664,6 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		 * of start_xmit activity is detected (if it is not detected,
 		 * it is slow enough). -- FR
 		 */
-		smp_rmb();
 		if (tp->cur_tx != dirty_tx)
 			RTL_W8(TxPoll, NPQ);
 	}
-- 
1.7.6.5
