From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] i40e: clear qtx_head before enabling Tx queue
Date: Fri, 10 Jan 2014 00:58:52 -0800
Message-ID: <1389344336-1558-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50715 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbaAJI7G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 03:59:06 -0500
In-Reply-To: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure the "new" qtx_head[q] register is cleared before
enabling the Tx queue.

Change-ID: I0c7a12815e343a5ae68807af172a35d6c6857935
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 65c27cb..bc14a85 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3008,11 +3008,13 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 			continue;
 
 		/* turn on/off the queue */
-		if (enable)
+		if (enable) {
+			wr32(hw, I40E_QTX_HEAD(pf_q), 0);
 			tx_reg |= I40E_QTX_ENA_QENA_REQ_MASK |
 				  I40E_QTX_ENA_QENA_STAT_MASK;
-		else
+		} else {
 			tx_reg &= ~I40E_QTX_ENA_QENA_REQ_MASK;
+		}
 
 		wr32(hw, I40E_QTX_ENA(pf_q), tx_reg);
 
-- 
1.8.3.1
