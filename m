From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 2/2] bnx2x: Fix the maximal values of coalescing
 timeouts.
Date: Sun, 5 Jul 2009 17:18:14 +0300
Message-ID: <1246803494.1685.19.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev List" <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Flavio Leitner" <fleitner@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1252 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771AbZGEOS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2009 10:18:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch properly defines the maximum values for rx/tx coalescing timeouts.

Signed-off-by: Vlad Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 ++
 drivers/net/bnx2x_main.c |    8 ++++----
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 8678457..85a737c 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -902,6 +902,8 @@ struct bnx2x {
 	u16			rx_quick_cons_trip;
 	u16			rx_ticks_int;
 	u16			rx_ticks;
+/* Maximal coalescing timeout in us */
+#define BNX2X_MAX_COALESCE_TOUT		(0xf0*12)

 	u32			lin_cnt;

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5737b75..6c67be6 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9069,12 +9069,12 @@ static int bnx2x_set_coalesce(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);

 	bp->rx_ticks = (u16) coal->rx_coalesce_usecs;
-	if (bp->rx_ticks > 3000)
-		bp->rx_ticks = 3000;
+	if (bp->rx_ticks > BNX2X_MAX_COALESCE_TOUT)
+		bp->rx_ticks = BNX2X_MAX_COALESCE_TOUT;

 	bp->tx_ticks = (u16) coal->tx_coalesce_usecs;
-	if (bp->tx_ticks > 0x3000)
-		bp->tx_ticks = 0x3000;
+	if (bp->tx_ticks > BNX2X_MAX_COALESCE_TOUT)
+		bp->tx_ticks = BNX2X_MAX_COALESCE_TOUT;

 	if (netif_running(dev))
 		bnx2x_update_coalesce(bp);
--
1.6.0.4




