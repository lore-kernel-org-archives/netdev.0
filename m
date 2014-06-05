From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e/i40evf: VEB structure added, GTIME macro update
Date: Thu,  5 Jun 2014 00:49:23 -0700
Message-ID: <1401954567-13557-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52024 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898AbaFEHtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 03:49:42 -0400
In-Reply-To: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

Structure for VEB context added. Update macro for
transition from ms to GTIME (us) time units.

Change-ID: Ib3a19587b4cf355348655df8f60c6f37bb1497a3
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 14 ++++++++++++--
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 14 ++++++++++++--
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 71f9718..02e8f9a4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -60,8 +60,8 @@
 /* Max default timeout in ms, */
 #define I40E_MAX_NVM_TIMEOUT		18000
 
-/* Switch from mc to the 2usec global time (this is the GTIME resolution) */
-#define I40E_MS_TO_GTIME(time)		(((time) * 1000) / 2)
+/* Switch from ms to the 1usec global time (this is the GTIME resolution) */
+#define I40E_MS_TO_GTIME(time)		((time) * 1000)
 
 /* forward declaration */
 struct i40e_hw;
@@ -955,6 +955,16 @@ struct i40e_vsi_context {
 	struct i40e_aqc_vsi_properties_data info;
 };
 
+struct i40e_veb_context {
+	u16 seid;
+	u16 uplink_seid;
+	u16 veb_number;
+	u16 vebs_allocated;
+	u16 vebs_unallocated;
+	u16 flags;
+	struct i40e_aqc_get_veb_parameters_completion info;
+};
+
 /* Statistics collected by each port, VSI, VEB, and S-channel */
 struct i40e_eth_stats {
 	u64 rx_bytes;			/* gorc */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 67082f7..eb2e9f3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -60,8 +60,8 @@
 /* Max default timeout in ms, */
 #define I40E_MAX_NVM_TIMEOUT		18000
 
-/* Switch from mc to the 2usec global time (this is the GTIME resolution) */
-#define I40E_MS_TO_GTIME(time)		(((time) * 1000) / 2)
+/* Switch from ms to the 1usec global time (this is the GTIME resolution) */
+#define I40E_MS_TO_GTIME(time)		((time) * 1000)
 
 /* forward declaration */
 struct i40e_hw;
@@ -955,6 +955,16 @@ struct i40e_vsi_context {
 	struct i40e_aqc_vsi_properties_data info;
 };
 
+struct i40e_veb_context {
+	u16 seid;
+	u16 uplink_seid;
+	u16 veb_number;
+	u16 vebs_allocated;
+	u16 vebs_unallocated;
+	u16 flags;
+	struct i40e_aqc_get_veb_parameters_completion info;
+};
+
 /* Statistics collected by each port, VSI, VEB, and S-channel */
 struct i40e_eth_stats {
 	u64 rx_bytes;			/* gorc */
-- 
1.9.3
