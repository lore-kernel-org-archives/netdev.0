From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 19/34]bnx2x: Disable napi
Date: Wed, 14 Jan 2009 18:43:39 +0200
Message-ID: <1231951419.11301.140.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763649AbZANQod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling napi disabled unconditionally at netif stop

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f17a238..801a283 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6145,8 +6145,8 @@ static void bnx2x_netif_start(struct bnx2x *bp)
 static void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 {
 	bnx2x_int_disable_sync(bp, disable_hw);
+	bnx2x_napi_disable(bp);
 	if (netif_running(bp->dev)) {
-		bnx2x_napi_disable(bp);
 		netif_tx_disable(bp->dev);
 		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
 	}
@@ -6691,8 +6691,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bnx2x_set_storm_rx_mode(bp);
 
 	bnx2x_netif_stop(bp, 1);
-	if (!netif_running(bp->dev))
-		bnx2x_napi_disable(bp);
+
 	del_timer_sync(&bp->timer);
 	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
 		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
-- 
1.5.4.3




