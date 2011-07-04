From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: de4x5: Use helpers from linux/etherdevice.h
Date: Mon,  4 Jul 2011 11:48:13 +0200
Message-ID: <1309772893-22585-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:42497 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762Ab1GDJsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 05:48:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/tulip/de4x5.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index d8db2b6..959b410 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1868,14 +1868,13 @@ de4x5_local_stats(struct net_device *dev, char *buf, int pkt_len)
 	    i = DE4X5_PKT_STAT_SZ;
 	}
     }
-    if (buf[0] & 0x01) {          /* Multicast/Broadcast */
-        if ((*(s32 *)&buf[0] == -1) && (*(s16 *)&buf[4] == -1)) {
+    if (is_multicast_ether_addr(buf)) {
+        if (is_broadcast_ether_addr(buf)) {
 	    lp->pktStats.broadcast++;
 	} else {
 	    lp->pktStats.multicast++;
 	}
-    } else if ((*(s32 *)&buf[0] == *(s32 *)&dev->dev_addr[0]) &&
-	       (*(s16 *)&buf[4] == *(s16 *)&dev->dev_addr[4])) {
+    } else if (compare_ether_addr(buf, dev->dev_addr) == 0) {
         lp->pktStats.unicast++;
     }
 
-- 
1.7.5.4

