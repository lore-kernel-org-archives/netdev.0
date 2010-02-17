From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 3/8] bnx2x: Do not allow enabling LRO if disable_tpa=1
Date: Wed, 17 Feb 2010 14:03:40 +0200
Message-ID: <1266408220.25691.844.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2040 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757119Ab0BQMMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 07:12:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix: Do not allow enabling LRO if disable_tpa=1.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 16685a1..ccdc3fe 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9968,12 +9968,14 @@ static int bnx2x_set_flags(struct net_device *dev, u32 data)
 
 	/* TPA requires Rx CSUM offloading */
 	if ((data & ETH_FLAG_LRO) && bp->rx_csum) {
-		if (!(dev->features & NETIF_F_LRO)) {
-			dev->features |= NETIF_F_LRO;
-			bp->flags |= TPA_ENABLE_FLAG;
-			changed = 1;
-		}
-
+		if (!disable_tpa) {
+			if (!(dev->features & NETIF_F_LRO)) {
+				dev->features |= NETIF_F_LRO;
+				bp->flags |= TPA_ENABLE_FLAG;
+				changed = 1;
+			}
+		} else
+			rc = -EINVAL;
 	} else if (dev->features & NETIF_F_LRO) {
 		dev->features &= ~NETIF_F_LRO;
 		bp->flags &= ~TPA_ENABLE_FLAG;
-- 
1.6.3.3




