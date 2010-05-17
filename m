From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH resend] bnx2x: avoid TX timeout when stopping device
Date: Mon, 17 May 2010 14:34:06 +0200
Message-ID: <20100517123406.GA2504@dhcp-lab-161.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165Ab0EQMf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 08:35:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When stop device call netif_carrier_off() just after disabling TX queue to
avoid possibility of netdev watchdog warning and ->ndo_tx_timeout() invocation.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2bc35c7..57ff5b3 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8499,6 +8499,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	/* Disable HW interrupts, NAPI and Tx */
 	bnx2x_netif_stop(bp, 1);
+	netif_carrier_off(bp->dev);
 
 	del_timer_sync(&bp->timer);
 	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
@@ -8524,8 +8525,6 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	bp->state = BNX2X_STATE_CLOSED;
 
-	netif_carrier_off(bp->dev);
-
 	/* The last driver must disable a "close the gate" if there is no
 	 * parity attention or "process kill" pending.
 	 */
@@ -13431,6 +13430,7 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 
 	bnx2x_netif_stop(bp, 0);
+	netif_carrier_off(bp->dev);
 
 	del_timer_sync(&bp->timer);
 	bp->stats_state = STATS_STATE_DISABLED;
@@ -13457,8 +13457,6 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 
 	bp->state = BNX2X_STATE_CLOSED;
 
-	netif_carrier_off(bp->dev);
-
 	return 0;
 }
 
-- 
1.5.5.6

