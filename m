From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: properly show packet split status in debugfs
Date: Wed, 17 Feb 2016 19:38:56 -0800
Message-ID: <1455766737-11911-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20355 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424817AbcBRDjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:03 -0500
In-Reply-To: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Get rid of the unused hsplit field in the ring struct and use the
existing macro to detect packet split enablement. This allows debugfs
dumps of the VSI to properly show which Rx routine is in use.

Change-ID: Ic4e9589e6a788ab196ed0850703f704e30c03781
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 6 +++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h  | 1 -
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index bdac691..34da53b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -521,7 +521,7 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 rx_ring->dtype);
 		dev_info(&pf->pdev->dev,
 			 "    rx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
-			 i, rx_ring->hsplit,
+			 i, ring_is_ps_enabled(rx_ring),
 			 rx_ring->next_to_use,
 			 rx_ring->next_to_clean,
 			 rx_ring->ring_active);
@@ -572,8 +572,8 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 "    tx_rings[%i]: dtype = %d\n",
 			 i, tx_ring->dtype);
 		dev_info(&pf->pdev->dev,
-			 "    tx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
-			 i, tx_ring->hsplit,
+			 "    tx_rings[%i]: next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
+			 i,
 			 tx_ring->next_to_use,
 			 tx_ring->next_to_clean,
 			 tx_ring->ring_active);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 3b8d147..ae22c4e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -256,7 +256,6 @@ struct i40e_ring {
 #define I40E_RX_DTYPE_NO_SPLIT      0
 #define I40E_RX_DTYPE_HEADER_SPLIT  1
 #define I40E_RX_DTYPE_SPLIT_ALWAYS  2
-	u8  hsplit;
 #define I40E_RX_SPLIT_L2      0x1
 #define I40E_RX_SPLIT_IP      0x2
 #define I40E_RX_SPLIT_TCP_UDP 0x4
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 5f03c44..5467fcdf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -255,7 +255,6 @@ struct i40e_ring {
 #define I40E_RX_DTYPE_NO_SPLIT      0
 #define I40E_RX_DTYPE_HEADER_SPLIT  1
 #define I40E_RX_DTYPE_SPLIT_ALWAYS  2
-	u8  hsplit;
 #define I40E_RX_SPLIT_L2      0x1
 #define I40E_RX_SPLIT_IP      0x2
 #define I40E_RX_SPLIT_TCP_UDP 0x4
-- 
2.5.0
