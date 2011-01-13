From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH v2 net-next-2.6] netdev: tilepro: Use is_unicast_ether_addr helper
Date: Thu, 13 Jan 2011 09:15:08 +0100
Message-ID: <1294906508-14999-1-git-send-email-tklauser@distanz.ch>
References: <20110112.234250.10542369.davem@davemloft.net>
Cc: tklauser@distanz.ch
To: David Miller <davem@davemloft.net>, cmetcalf@tilera.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:35667 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754892Ab1AMIPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 03:15:09 -0500
In-Reply-To: <20110112.234250.10542369.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use is_unicast_ether_addr from linux/etherdevice.h instead of custom
macros.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/tile/tilepro.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tile/tilepro.c b/drivers/net/tile/tilepro.c
index 0e6bac5..7cb301d 100644
--- a/drivers/net/tile/tilepro.c
+++ b/drivers/net/tile/tilepro.c
@@ -142,14 +142,6 @@
 MODULE_AUTHOR("Tilera");
 MODULE_LICENSE("GPL");
 
-
-#define IS_MULTICAST(mac_addr) \
-	(((u8 *)(mac_addr))[0] & 0x01)
-
-#define IS_BROADCAST(mac_addr) \
-	(((u16 *)(mac_addr))[0] == 0xffff)
-
-
 /*
  * Queue of incoming packets for a specific cpu and device.
  *
@@ -795,7 +787,7 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 		/*
 		 * FIXME: Implement HW multicast filter.
 		 */
-		if (!IS_MULTICAST(buf) && !IS_BROADCAST(buf)) {
+		if (is_unicast_ether_addr(buf)) {
 			/* Filter packets not for our address. */
 			const u8 *mine = dev->dev_addr;
 			filter = compare_ether_addr(mine, buf);
-- 
1.7.0.4

