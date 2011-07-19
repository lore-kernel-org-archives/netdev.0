From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 03/10] bnx2x: stop tx before CNIC_STOP
Date: Tue, 19 Jul 2011 14:39:41 +0300
Message-ID: <1311075581.30287.4.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4807 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199Ab1GSLuV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:50:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 3f3760d3c841152da976007adca5b66a30eeb7df Mon Sep 17 00:00:00 2001
From: Vladislav Zolotarov <vladz@broadcom.com>

It may take some time to cnic to respond, this prevents tx_timeout
when it happens.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 5854a6c..8b079dc 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1989,6 +1989,9 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		return -EINVAL;
 	}
 
+	/* Stop Tx */
+	bnx2x_tx_disable(bp);
+
 #ifdef BCM_CNIC
 	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
 #endif
@@ -1997,9 +2000,6 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 
-	/* Stop Tx */
-	bnx2x_tx_disable(bp);
-
 	del_timer_sync(&bp->timer);
 
 	/* Set ALWAYS_ALIVE bit in shmem */
-- 
1.7.2.2




