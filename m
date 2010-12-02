From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: am79c961a: Omit private ndo_get_stats function
Date: Thu,  2 Dec 2010 18:20:05 +0100
Message-ID: <1291310405-5759-1-git-send-email-tklauser@distanz.ch>
To: Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:56719 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757413Ab0LBR2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 12:28:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

am79c961_getstats() just returns dev->stats so we can leave it out
alltogether and let dev_get_stats() do the job.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/arm/am79c961a.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 62f2110..0c9217f 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -340,14 +340,6 @@ am79c961_close(struct net_device *dev)
 	return 0;
 }
 
-/*
- * Get the current statistics.
- */
-static struct net_device_stats *am79c961_getstats (struct net_device *dev)
-{
-	return &dev->stats;
-}
-
 static void am79c961_mc_hash(char *addr, unsigned short *hash)
 {
 	if (addr[0] & 0x01) {
@@ -665,7 +657,6 @@ static const struct net_device_ops am79c961_netdev_ops = {
 	.ndo_open		= am79c961_open,
 	.ndo_stop		= am79c961_close,
 	.ndo_start_xmit		= am79c961_sendpacket,
-	.ndo_get_stats		= am79c961_getstats,
 	.ndo_set_multicast_list	= am79c961_setmulticastlist,
 	.ndo_tx_timeout		= am79c961_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-- 
1.7.0.4

