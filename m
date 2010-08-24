From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bnx2x: small fix in stats handling
Date: Tue, 24 Aug 2010 07:44:08 +0200
Message-ID: <1282628648.2378.1492.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49142 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530Ab0HXFoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 01:44:14 -0400
Received: by wyb35 with SMTP id 35so29805wyb.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 22:44:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a private variable to fold rx_dropped value, instead of shared
destination buffer, as it might break SNMP applications.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Eilon Greenstein <eilong@broadcom.com>
CC: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_stats.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index c747244..efa1403 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -969,6 +969,7 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 {
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	struct net_device_stats *nstats = &bp->dev->stats;
+	unsigned long tmp;
 	int i;
 
 	nstats->rx_packets =
@@ -985,10 +986,10 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 
 	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
 
-	nstats->rx_dropped = estats->mac_discard;
+	tmp = estats->mac_discard;
 	for_each_queue(bp, i)
-		nstats->rx_dropped +=
-			le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
+		tmp += le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
+	nstats->rx_dropped = tmp;
 
 	nstats->tx_dropped = 0;
 


