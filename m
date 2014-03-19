From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/15] i40e/i40evf: reduce context descriptors
Date: Tue, 18 Mar 2014 20:42:05 -0700
Message-ID: <1395200533-16908-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18793 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933563AbaCSDmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 23:42:19 -0400
In-Reply-To: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

We don't need context descriptors for every packet, only tso
or timesync.  This fixes a bug in the driver where it would
always add a context even if all the passed in values
to the context descriptor function were 0/default values.

Change-ID: I0101d2b893380707b5c2de61aab3e16d4310e9a1
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 3 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 9892a69..752e680 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1950,7 +1950,8 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
 	struct i40e_tx_context_desc *context_desc;
 	int i = tx_ring->next_to_use;
 
-	if (!cd_type_cmd_tso_mss && !cd_tunneling && !cd_l2tag2)
+	if ((cd_type_cmd_tso_mss == I40E_TX_DESC_DTYPE_CONTEXT) &&
+	    !cd_tunneling && !cd_l2tag2)
 		return;
 
 	/* grab the next descriptor */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index d4d9842..18f174d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1285,7 +1285,8 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
 	struct i40e_tx_context_desc *context_desc;
 	int i = tx_ring->next_to_use;
 
-	if (!cd_type_cmd_tso_mss && !cd_tunneling && !cd_l2tag2)
+	if ((cd_type_cmd_tso_mss == I40E_TX_DESC_DTYPE_CONTEXT) &&
+	    !cd_tunneling && !cd_l2tag2)
 		return;
 
 	/* grab the next descriptor */
-- 
1.8.3.1
