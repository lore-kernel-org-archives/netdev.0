From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v5 06/17] i40e: fix curly brace use and return type
Date: Fri,  3 Jan 2014 21:56:34 -0800
Message-ID: <1388815005-23166-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31987 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754568AbaADF4x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 00:56:53 -0500
In-Reply-To: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add curly-braces on a multi-line function.  While we're here we
also change to return void in i40e_vsi_clear_rings() since no
caller cares.

Change-Id: I261fcef20e2a39e18d83ec08fdd14456131dee91
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 45b2198..b0cfb4c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5300,18 +5300,17 @@ free_vsi:
  * i40e_vsi_clear_rings - Deallocates the Rx and Tx rings for the provided VSI
  * @vsi: the VSI being cleaned
  **/
-static s32 i40e_vsi_clear_rings(struct i40e_vsi *vsi)
+static void i40e_vsi_clear_rings(struct i40e_vsi *vsi)
 {
 	int i;
 
-	if (vsi->tx_rings[0])
+	if (vsi->tx_rings[0]) {
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
 			kfree_rcu(vsi->tx_rings[i], rcu);
 			vsi->tx_rings[i] = NULL;
 			vsi->rx_rings[i] = NULL;
 		}
-
-	return 0;
+	}
 }
 
 /**
-- 
1.8.3.1
