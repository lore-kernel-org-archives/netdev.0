From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40e: Cleanup if/else statements
Date: Tue, 22 Apr 2014 05:39:29 -0700
Message-ID: <1398170371-3333-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21423 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932618AbaDVMjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:43 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Simplify some if/else statements in i40e_main.c

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 34 +++++++----------------------
 1 file changed, 8 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8392796..159f97a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3165,9 +3165,7 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 			usleep_range(1000, 2000);
 		}
 		/* Skip if the queue is already in the requested state */
-		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
-			continue;
-		if (!enable && !(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
+		if (enable == !!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
 			continue;
 
 		/* turn on/off the queue */
@@ -3183,13 +3181,8 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 		/* wait for the change to finish */
 		for (j = 0; j < 10; j++) {
 			tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
-			if (enable) {
-				if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
-					break;
-			} else {
-				if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
-					break;
-			}
+			if (enable == !!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
+				break;
 
 			udelay(10);
 		}
@@ -3228,15 +3221,9 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 			usleep_range(1000, 2000);
 		}
 
-		if (enable) {
-			/* is STAT set ? */
-			if ((rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
-				continue;
-		} else {
-			/* is !STAT set ? */
-			if (!(rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
-				continue;
-		}
+		/* Skip if the queue is already in the requested state */
+		if (enable == !!(rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
+			continue;
 
 		/* turn on/off the queue */
 		if (enable)
@@ -3249,13 +3236,8 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 		for (j = 0; j < 10; j++) {
 			rx_reg = rd32(hw, I40E_QRX_ENA(pf_q));
 
-			if (enable) {
-				if ((rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
-					break;
-			} else {
-				if (!(rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
-					break;
-			}
+			if (enable == !!(rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
+				break;
 
 			udelay(10);
 		}
-- 
1.9.0
