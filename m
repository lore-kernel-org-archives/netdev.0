From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net next] bnx2x: Add dcbnl notification
Date: Thu, 7 Jul 2011 16:55:41 +0300
Message-ID: <1310046941.22577.20.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2576 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755675Ab1GGMHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 08:07:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a dcbnl notification to the bnx2x. The notification is
sent to user mode clients following a change in the dcb negotiated
parameters as resolved by the embedded DCBX stack. 

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_dcb.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index b51a759..45cf3ce 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -19,14 +19,14 @@
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/errno.h>
-#ifdef BCM_DCBNL
-#include <linux/dcbnl.h>
-#endif
 
 #include "bnx2x.h"
 #include "bnx2x_cmn.h"
 #include "bnx2x_dcb.h"
 
+#ifdef BCM_DCBNL
+#include <linux/rtnetlink.h>
+#endif
 
 /* forward declarations of dcbx related functions */
 static void bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp);
@@ -702,6 +702,12 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 	case BNX2X_DCBX_STATE_TX_RELEASED:
 		DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_TX_RELEASED\n");
 		bnx2x_fw_command(bp, DRV_MSG_CODE_DCBX_PMF_DRV_OK, 0);
+#ifdef BCM_DCBNL
+		/**
+		 * Send a notification for the new negotiated parameters
+		 */
+		dcbnl_cee_notify(bp->dev, RTM_GETDCB, DCB_CMD_CEE_GET, 0, 0);
+#endif
 		return;
 	default:
 		BNX2X_ERR("Unknown DCBX_STATE\n");
-- 
1.7.3.5




