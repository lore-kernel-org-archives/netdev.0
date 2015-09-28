From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e: fix VLAN inside VXLAN
Date: Mon, 28 Sep 2015 11:21:48 -0700
Message-ID: <1443464508-53806-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40566 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934152AbbI1SX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 14:23:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Previously to this patch, the hardware was removing
VLAN tags from the inner header of VXLAN packets.  The
hardware configuration can be changed to leave the
packet alone since that is what the linux stack
expects for this type of VLAN in VXLAN packet.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 48a52b3..5bb1e67 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2590,7 +2590,8 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 		rx_ctx.lrxqthresh = 2;
 	rx_ctx.crcstrip = 1;
 	rx_ctx.l2tsel = 1;
-	rx_ctx.showiv = 1;
+	/* this controls whether VLAN is stripped from inner headers */
+	rx_ctx.showiv = 0;
 #ifdef I40E_FCOE
 	rx_ctx.fc_ena = (vsi->type == I40E_VSI_FCOE);
 #endif
-- 
2.4.3
