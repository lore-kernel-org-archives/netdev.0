From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 09/18] bnx2x: Calling tx disable unconditionally
Date: Mon, 02 Mar 2009 19:59:56 +0200
Message-ID: <1236016796.7723.80.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4812 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755803AbZCBSA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:00:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 09/18] bnx2x: Calling tx disable unconditionally

On unload, the FW assumes that no packets will be sent after the driver sends
the FW stop command. To ensure that, the driver must always call
netif_tx_disable

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 3ef24b9..5397de1 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6573,10 +6573,8 @@ static void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 {
 	bnx2x_int_disable_sync(bp, disable_hw);
 	bnx2x_napi_disable(bp);
-	if (netif_running(bp->dev)) {
-		netif_tx_disable(bp->dev);
-		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
-	}
+	netif_tx_disable(bp->dev);
+	bp->dev->trans_start = jiffies;	/* prevent tx timeout */
 }
 
 /*
-- 
1.5.4.3




