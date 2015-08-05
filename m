From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e/i40evf: Add flags for X722 capabilities
Date: Wed,  5 Aug 2015 16:52:02 -0700
Message-ID: <1438818735-38115-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7970 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbbHEXwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:18 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Add capabilities flags specific to X722.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 7 +++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++++
 drivers/net/ethernet/intel/i40evf/i40evf.h  | 7 ++++++-
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 281fd84..9914886 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -298,6 +298,7 @@ struct i40e_pf {
 #define I40E_FLAG_VMDQ_ENABLED			BIT_ULL(7)
 #define I40E_FLAG_FDIR_REQUIRES_REINIT		BIT_ULL(8)
 #define I40E_FLAG_NEED_LINK_UPDATE		BIT_ULL(9)
+#define I40E_FLAG_IWARP_ENABLED			BIT_ULL(10)
 #ifdef I40E_FCOE
 #define I40E_FLAG_FCOE_ENABLED			BIT_ULL(11)
 #endif /* I40E_FCOE */
@@ -318,6 +319,12 @@ struct i40e_pf {
 #endif
 #define I40E_FLAG_PORT_ID_VALID			BIT_ULL(28)
 #define I40E_FLAG_DCB_CAPABLE			BIT_ULL(29)
+#define I40E_FLAG_RSS_AQ_CAPABLE		BIT_ULL(31)
+#define I40E_FLAG_HW_ATR_EVICT_CAPABLE		BIT_ULL(32)
+#define I40E_FLAG_OUTER_UDP_CSUM_CAPABLE	BIT_ULL(33)
+#define I40E_FLAG_128_QP_RSS_CAPABLE		BIT_ULL(34)
+#define I40E_FLAG_WB_ON_ITR_CAPABLE		BIT_ULL(35)
+#define I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE	BIT_ULL(38)
 #define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(40)
 
 	/* tracks features that get auto disabled by errors */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9c96706..3269b05 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7785,6 +7785,14 @@ static int i40e_sw_init(struct i40e_pf *pf)
 					I40E_MAX_VF_COUNT);
 	}
 #endif /* CONFIG_PCI_IOV */
+	if (pf->hw.mac.type == I40E_MAC_X722) {
+		pf->flags |= I40E_FLAG_RSS_AQ_CAPABLE |
+			     I40E_FLAG_128_QP_RSS_CAPABLE |
+			     I40E_FLAG_HW_ATR_EVICT_CAPABLE |
+			     I40E_FLAG_OUTER_UDP_CSUM_CAPABLE |
+			     I40E_FLAG_WB_ON_ITR_CAPABLE |
+			     I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE;
+	}
 	pf->eeprom_version = 0xDEAD;
 	pf->lan_veb = I40E_NO_VEB;
 	pf->lan_vsi = I40E_NO_VSI;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index c33c7cc..bd227b3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -218,11 +218,15 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_PF_COMMS_FAILED              BIT(8)
 #define I40EVF_FLAG_RESET_PENDING                BIT(9)
 #define I40EVF_FLAG_RESET_NEEDED                 BIT(10)
-/* duplcates for common code */
+#define I40EVF_FLAG_WB_ON_ITR_CAPABLE		BIT(11)
+#define I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE	BIT(12)
+/* duplicates for common code */
 #define I40E_FLAG_FDIR_ATR_ENABLED		 0
 #define I40E_FLAG_DCB_ENABLED			 0
 #define I40E_FLAG_IN_NETPOLL			 I40EVF_FLAG_IN_NETPOLL
 #define I40E_FLAG_RX_CSUM_ENABLED                I40EVF_FLAG_RX_CSUM_ENABLED
+#define I40E_FLAG_WB_ON_ITR_CAPABLE		I40EVF_FLAG_WB_ON_ITR_CAPABLE
+#define I40E_FLAG_OUTER_UDP_CSUM_CAPABLE	I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE
 	/* flags for admin queue service task */
 	u32 aq_required;
 #define I40EVF_FLAG_AQ_ENABLE_QUEUES		BIT(0)
@@ -234,6 +238,7 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_AQ_CONFIGURE_QUEUES		BIT(6)
 #define I40EVF_FLAG_AQ_MAP_VECTORS		BIT(7)
 #define I40EVF_FLAG_AQ_HANDLE_RESET		BIT(8)
+#define I40EVF_FLAG_AQ_CONFIGURE_RSS		BIT(9)
 #define I40EVF_FLAG_AQ_GET_CONFIG		BIT(10)
 
 	/* OS defined structs */
-- 
2.4.3
