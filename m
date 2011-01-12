From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next-2.6] netdev: tilepro: Use is_multicast_ether_addr helper
Date: Wed, 12 Jan 2011 10:31:53 +0100
Message-ID: <1294824713-10644-1-git-send-email-tklauser@distanz.ch>
To: Chris Metcalf <cmetcalf@tilera.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:38644 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023Ab1ALJbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 04:31:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use is_multicast_ether_addr from linux/etherdevice.h instead of a custom
macro. Also remove the broadcast address check, as it is considered a
multicast address too.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/tile/tilepro.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tile/tilepro.c b/drivers/net/tile/tilepro.c
index 0e6bac5..8d8b67b 100644
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
+		if (!is_multicast_ether_addr(buf)) {
 			/* Filter packets not for our address. */
 			const u8 *mine = dev->dev_addr;
 			filter = compare_ether_addr(mine, buf);
-- 
1.7.0.4

