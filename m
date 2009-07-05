From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 1/2] bnx2x: Disable HC coalescing when setting timeout
 to zero.
Date: Sun, 5 Jul 2009 17:18:12 +0300
Message-ID: <1246803492.1685.18.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev List" <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Flavio Leitner" <fleitner@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2393 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbZGEOSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2009 10:18:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem reported by Flavio Leitner <fleitner@redhat.com>:
When setting rx/tx coalescing timeout to the values less than 12 traffic was
stopped.

The FW supports coalescing in 12us granularity, and so value of less then 12
should be interpreted as disabling coalescing

Signed-off-by: Vlad Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 951714a..5737b75 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4434,7 +4434,7 @@ static void bnx2x_update_coalesce(struct bnx2x *bp)
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
 			 USTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
 						     U_SB_ETH_RX_CQ_INDEX),
-			 bp->rx_ticks ? 0 : 1);
+			 (bp->rx_ticks/12) ? 0 : 1);

 		/* HC_INDEX_C_ETH_TX_CQ_CONS */
 		REG_WR8(bp, BAR_CSTRORM_INTMEM +
@@ -4444,7 +4444,7 @@ static void bnx2x_update_coalesce(struct bnx2x *bp)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
 			 CSTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
 						     C_SB_ETH_TX_CQ_INDEX),
-			 bp->tx_ticks ? 0 : 1);
+			 (bp->tx_ticks/12) ? 0 : 1);
 	}
 }

--
1.6.0.4




