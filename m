From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e/i40evf: organize and re-number feature flags
Date: Sat, 12 Aug 2017 04:08:41 -0700
Message-ID: <20170812110848.18264-10-jeffrey.t.kirsher@intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54045 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751127AbdHLLIz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:55 -0400
In-Reply-To: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Now that we've reduced the number of flags, organize similar flags
together and re-number them accordingly.

Also ensure that the flags variable is actually a u64 to guarantee
64bits of space on all architectures.

One alternative approach considered, but not implemented here, was to
use an enumeration for the flag variables, and create a macro
I40E_FLAG() which used string concatenation to generate BIT_ULL values.
This has the advantage of making the actual bit values compile-time
dynamic so that we do not need to worry about matching the order to the
bit value. However, this does produce a high level of code churn, and
makes it more difficult to read a dumped flags value when debugging.

Change-ID: I8653fff69453cd547d6fe98d29dfa9d8710387d1
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h     | 57 +++++++++++++++---------------
 drivers/net/ethernet/intel/i40evf/i40evf.h | 30 ++++++++--------
 2 files changed, 44 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index d0c1bf5441d8..5f75e67c6ce9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -423,33 +423,34 @@ struct i40e_pf {
 #define I40E_HW_RESTART_AUTONEG			BIT_ULL(18)
 
 	u64 flags;
-#define I40E_FLAG_RX_CSUM_ENABLED		BIT_ULL(1)
-#define I40E_FLAG_MSI_ENABLED			BIT_ULL(2)
-#define I40E_FLAG_MSIX_ENABLED			BIT_ULL(3)
-#define I40E_FLAG_HW_ATR_EVICT_ENABLED		BIT_ULL(4)
-#define I40E_FLAG_RSS_ENABLED			BIT_ULL(6)
-#define I40E_FLAG_VMDQ_ENABLED			BIT_ULL(7)
-#define I40E_FLAG_IWARP_ENABLED			BIT_ULL(10)
-#define I40E_FLAG_FILTER_SYNC			BIT_ULL(15)
-#define I40E_FLAG_SERVICE_CLIENT_REQUESTED	BIT_ULL(16)
-#define I40E_FLAG_SRIOV_ENABLED			BIT_ULL(19)
-#define I40E_FLAG_DCB_ENABLED			BIT_ULL(20)
-#define I40E_FLAG_FD_SB_ENABLED			BIT_ULL(21)
-#define I40E_FLAG_FD_ATR_ENABLED		BIT_ULL(22)
-#define I40E_FLAG_FD_SB_AUTO_DISABLED		BIT_ULL(23)
-#define I40E_FLAG_FD_ATR_AUTO_DISABLED		BIT_ULL(24)
-#define I40E_FLAG_PTP				BIT_ULL(25)
-#define I40E_FLAG_MFP_ENABLED			BIT_ULL(26)
-#define I40E_FLAG_UDP_FILTER_SYNC		BIT_ULL(27)
-#define I40E_FLAG_DCB_CAPABLE			BIT_ULL(29)
-#define I40E_FLAG_VEB_STATS_ENABLED		BIT_ULL(37)
-#define I40E_FLAG_LINK_POLLING_ENABLED		BIT_ULL(39)
-#define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(40)
-#define I40E_FLAG_TRUE_PROMISC_SUPPORT		BIT_ULL(51)
-#define I40E_FLAG_CLIENT_RESET			BIT_ULL(54)
-#define I40E_FLAG_TEMP_LINK_POLLING		BIT_ULL(55)
-#define I40E_FLAG_CLIENT_L2_CHANGE		BIT_ULL(56)
-#define I40E_FLAG_LEGACY_RX			BIT_ULL(58)
+#define I40E_FLAG_RX_CSUM_ENABLED		BIT_ULL(0)
+#define I40E_FLAG_MSI_ENABLED			BIT_ULL(1)
+#define I40E_FLAG_MSIX_ENABLED			BIT_ULL(2)
+#define I40E_FLAG_RSS_ENABLED			BIT_ULL(3)
+#define I40E_FLAG_VMDQ_ENABLED			BIT_ULL(4)
+#define I40E_FLAG_FILTER_SYNC			BIT_ULL(5)
+#define I40E_FLAG_SRIOV_ENABLED			BIT_ULL(6)
+#define I40E_FLAG_DCB_CAPABLE			BIT_ULL(7)
+#define I40E_FLAG_DCB_ENABLED			BIT_ULL(8)
+#define I40E_FLAG_FD_SB_ENABLED			BIT_ULL(9)
+#define I40E_FLAG_FD_ATR_ENABLED		BIT_ULL(10)
+#define I40E_FLAG_FD_SB_AUTO_DISABLED		BIT_ULL(11)
+#define I40E_FLAG_FD_ATR_AUTO_DISABLED		BIT_ULL(12)
+#define I40E_FLAG_MFP_ENABLED			BIT_ULL(13)
+#define I40E_FLAG_UDP_FILTER_SYNC		BIT_ULL(14)
+#define I40E_FLAG_HW_ATR_EVICT_ENABLED		BIT_ULL(15)
+#define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(16)
+#define I40E_FLAG_VEB_STATS_ENABLED		BIT_ULL(17)
+#define I40E_FLAG_LINK_POLLING_ENABLED		BIT_ULL(18)
+#define I40E_FLAG_TRUE_PROMISC_SUPPORT		BIT_ULL(19)
+#define I40E_FLAG_TEMP_LINK_POLLING		BIT_ULL(20)
+#define I40E_FLAG_LEGACY_RX			BIT_ULL(21)
+#define I40E_FLAG_PTP				BIT_ULL(22)
+#define I40E_FLAG_IWARP_ENABLED			BIT_ULL(23)
+#define I40E_FLAG_SERVICE_CLIENT_REQUESTED	BIT_ULL(24)
+#define I40E_FLAG_CLIENT_L2_CHANGE		BIT_ULL(25)
+#define I40E_FLAG_CLIENT_RESET			BIT_ULL(26)
+#define I40E_FLAG_LINK_DOWN_ON_CLOSE_ENABLED	BIT_ULL(27)
 
 	struct i40e_client_instance *cinst;
 	bool stat_offsets_loaded;
@@ -613,7 +614,7 @@ struct i40e_vsi {
 	DECLARE_BITMAP(state, __I40E_VSI_STATE_SIZE__);
 #define I40E_VSI_FLAG_FILTER_CHANGED	BIT(0)
 #define I40E_VSI_FLAG_VEB_OWNER		BIT(1)
-	unsigned long flags;
+	u64 flags;
 
 	/* Per VSI lock to protect elements/hash (MAC filter) */
 	spinlock_t mac_filter_hash_lock;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 7f905368fc93..c89767ee0ab2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -220,21 +220,21 @@ struct i40evf_adapter {
 
 	u32 flags;
 #define I40EVF_FLAG_RX_CSUM_ENABLED		BIT(0)
-#define I40EVF_FLAG_IMIR_ENABLED		BIT(5)
-#define I40EVF_FLAG_MQ_CAPABLE			BIT(6)
-#define I40EVF_FLAG_PF_COMMS_FAILED		BIT(8)
-#define I40EVF_FLAG_RESET_PENDING		BIT(9)
-#define I40EVF_FLAG_RESET_NEEDED		BIT(10)
-#define I40EVF_FLAG_WB_ON_ITR_CAPABLE		BIT(11)
-#define I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE	BIT(12)
-#define I40EVF_FLAG_ADDR_SET_BY_PF		BIT(13)
-#define I40EVF_FLAG_SERVICE_CLIENT_REQUESTED	BIT(14)
-#define I40EVF_FLAG_CLIENT_NEEDS_OPEN		BIT(15)
-#define I40EVF_FLAG_CLIENT_NEEDS_CLOSE		BIT(16)
-#define I40EVF_FLAG_CLIENT_NEEDS_L2_PARAMS	BIT(17)
-#define I40EVF_FLAG_PROMISC_ON			BIT(18)
-#define I40EVF_FLAG_ALLMULTI_ON			BIT(19)
-#define I40EVF_FLAG_LEGACY_RX			BIT(20)
+#define I40EVF_FLAG_IMIR_ENABLED		BIT(1)
+#define I40EVF_FLAG_MQ_CAPABLE			BIT(2)
+#define I40EVF_FLAG_PF_COMMS_FAILED		BIT(3)
+#define I40EVF_FLAG_RESET_PENDING		BIT(4)
+#define I40EVF_FLAG_RESET_NEEDED		BIT(5)
+#define I40EVF_FLAG_WB_ON_ITR_CAPABLE		BIT(6)
+#define I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE	BIT(7)
+#define I40EVF_FLAG_ADDR_SET_BY_PF		BIT(8)
+#define I40EVF_FLAG_SERVICE_CLIENT_REQUESTED	BIT(9)
+#define I40EVF_FLAG_CLIENT_NEEDS_OPEN		BIT(10)
+#define I40EVF_FLAG_CLIENT_NEEDS_CLOSE		BIT(11)
+#define I40EVF_FLAG_CLIENT_NEEDS_L2_PARAMS	BIT(12)
+#define I40EVF_FLAG_PROMISC_ON			BIT(13)
+#define I40EVF_FLAG_ALLMULTI_ON			BIT(14)
+#define I40EVF_FLAG_LEGACY_RX			BIT(15)
 /* duplicates for common code */
 #define I40E_FLAG_DCB_ENABLED			0
 #define I40E_FLAG_RX_CSUM_ENABLED		I40EVF_FLAG_RX_CSUM_ENABLED
-- 
2.14.0
