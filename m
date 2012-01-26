From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 01/10] bnx2x: Support Queue Per Cos in 5771xx
 devices
Date: Thu, 26 Jan 2012 18:01:45 +0200
Message-ID: <1327593714-18358-2-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4709 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720Ab2AZQBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:01:50 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the use of up to three hardware queues for transmission. The queues
are always dequed round robin (i.e. strict priority, PFC and ETS are not
supported). This does allow the allocation of a seperate HW queue for low
volume, high priority traffic which will be serviced more promptly.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    7 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h  |    4 ++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index bf27c54..0dd22bb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -984,10 +984,11 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 	/* Function parameters */
 	start_params->mf_mode = bp->mf_mode;
 	start_params->sd_vlan_tag = bp->mf_ov;
-	if (CHIP_IS_E1x(bp))
-		start_params->network_cos_mode = OVERRIDE_COS;
-	else
+
+	if (CHIP_IS_E2(bp) || CHIP_IS_E3(bp))
 		start_params->network_cos_mode = STATIC_COS;
+	else /* CHIP_IS_E1X */
+		start_params->network_cos_mode = FW_WRR;
 
 	return bnx2x_func_state_change(bp, &func_params);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 66da39f..f33bc57 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -803,10 +803,10 @@ enum bnx2x_q_type {
 };
 
 #define BNX2X_PRIMARY_CID_INDEX			0
-#define BNX2X_MULTI_TX_COS_E1X			1
+#define BNX2X_MULTI_TX_COS_E1X			3 /* QM only */
 #define BNX2X_MULTI_TX_COS_E2_E3A0		2
 #define BNX2X_MULTI_TX_COS_E3B0			3
-#define BNX2X_MULTI_TX_COS			BNX2X_MULTI_TX_COS_E3B0
+#define BNX2X_MULTI_TX_COS			3 /* Maximum possible */
 
 
 struct bnx2x_queue_init_params {
-- 
1.7.1
