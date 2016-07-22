From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] i40e/i40evf: remove useless initializer
Date: Fri, 22 Jul 2016 00:36:31 -0700
Message-ID: <1469172999-8969-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37308 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726AbcGVHgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:48 -0400
In-Reply-To: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This initializer isn't needed because the variable is assigned right
away.

Change-ID: I6ce3edb3f4e0364db248a7a0bcc62ca95c01d941
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 4 +---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 +--
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 55f151f..2def562 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -740,14 +740,12 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 	tx_ring->q_vector->tx.total_packets += total_packets;
 
 	if (tx_ring->flags & I40E_TXR_FLAGS_WB_ON_ITR) {
-		unsigned int j = 0;
-
 		/* check to see if there are < 4 descriptors
 		 * waiting to be written back, then kick the hardware to force
 		 * them to be written back in case we stay in NAPI.
 		 * In this mode on X722 we do not enable Interrupt.
 		 */
-		j = i40e_get_tx_pending(tx_ring, false);
+		unsigned int j = i40e_get_tx_pending(tx_ring, false);
 
 		if (budget &&
 		    ((j / (WB_STRIDE + 1)) == 0) && (j != 0) &&
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index be99189..40f224f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -259,13 +259,12 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 	tx_ring->q_vector->tx.total_packets += total_packets;
 
 	if (tx_ring->flags & I40E_TXR_FLAGS_WB_ON_ITR) {
-		unsigned int j = 0;
 		/* check to see if there are < 4 descriptors
 		 * waiting to be written back, then kick the hardware to force
 		 * them to be written back in case we stay in NAPI.
 		 * In this mode on X722 we do not enable Interrupt.
 		 */
-		j = i40evf_get_tx_pending(tx_ring, false);
+		unsigned int j = i40evf_get_tx_pending(tx_ring, false);
 
 		if (budget &&
 		    ((j / (WB_STRIDE + 1)) == 0) && (j > 0) &&
-- 
2.5.5
