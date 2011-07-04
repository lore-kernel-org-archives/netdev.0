From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: depca: Use helpers from linux/etherdevice.h
Date: Mon,  4 Jul 2011 11:55:53 +0200
Message-ID: <1309773353-26210-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:43022 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756994Ab1GDJzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 05:55:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/depca.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index a7ccaa6..f2015a8 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1073,13 +1073,13 @@ static int depca_rx(struct net_device *dev)
 							i = DEPCA_PKT_STAT_SZ;
 						}
 					}
-					if (buf[0] & 0x01) {	/* Multicast/Broadcast */
-						if ((*(s16 *) & buf[0] == -1) && (*(s16 *) & buf[2] == -1) && (*(s16 *) & buf[4] == -1)) {
+					if (is_multicast_ether_addr(buf)) {
+						if (is_broadcast_ether_addr(buf)) {
 							lp->pktStats.broadcast++;
 						} else {
 							lp->pktStats.multicast++;
 						}
-					} else if ((*(s16 *) & buf[0] == *(s16 *) & dev->dev_addr[0]) && (*(s16 *) & buf[2] == *(s16 *) & dev->dev_addr[2]) && (*(s16 *) & buf[4] == *(s16 *) & dev->dev_addr[4])) {
+					} else if (compare_ether_addr(buf, dev->dev_addr) == 0) {
 						lp->pktStats.unicast++;
 					}
 
-- 
1.7.5.4

