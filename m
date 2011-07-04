From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: ewrk3: Use helpers from linux/etherdevice.h
Date: Mon,  4 Jul 2011 11:56:22 +0200
Message-ID: <1309773382-26609-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:43057 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756948Ab1GDJ4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 05:56:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ewrk3.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index b5f6173..d1e229f 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1008,15 +1008,13 @@ static int ewrk3_rx(struct net_device *dev)
 							}
 						}
 						p = skb->data;	/* Look at the dest addr */
-						if (p[0] & 0x01) {	/* Multicast/Broadcast */
-							if ((*(s16 *) & p[0] == -1) && (*(s16 *) & p[2] == -1) && (*(s16 *) & p[4] == -1)) {
+						if (is_multicast_ether_addr(p)) {
+							if (is_broadcast_ether_addr(p)) {
 								lp->pktStats.broadcast++;
 							} else {
 								lp->pktStats.multicast++;
 							}
-						} else if ((*(s16 *) & p[0] == *(s16 *) & dev->dev_addr[0]) &&
-							   (*(s16 *) & p[2] == *(s16 *) & dev->dev_addr[2]) &&
-							   (*(s16 *) & p[4] == *(s16 *) & dev->dev_addr[4])) {
+						} else if (compare_ether_addr(p, dev->dev_addr) == 0) {
 							lp->pktStats.unicast++;
 						}
 						lp->pktStats.bins[0]++;		/* Duplicates stats.rx_packets */
-- 
1.7.5.4

