From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] i40e: AQ Shared resource flags
Date: Tue, 16 Feb 2016 21:34:07 -0800
Message-ID: <1455687262-20453-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754152AbcBQFeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:25 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add flags to MAC allocation requests to signify that the MAC VLAN filters
should come from the shared resource pool rather than the dedicated PF
resource pools.

Change-ID: I4c2da64c01856edcb0982bc4aab75c5a91047a7a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 5 +++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 5 +++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 0e608d2..6e0834e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -976,6 +976,7 @@ struct i40e_aqc_add_macvlan_element_data {
 #define I40E_AQC_MACVLAN_ADD_HASH_MATCH		0x0002
 #define I40E_AQC_MACVLAN_ADD_IGNORE_VLAN	0x0004
 #define I40E_AQC_MACVLAN_ADD_TO_QUEUE		0x0008
+#define I40E_AQC_MACVLAN_ADD_USE_SHARED_MAC	0x0010
 	__le16	queue_number;
 #define I40E_AQC_MACVLAN_CMD_QUEUE_SHIFT	0
 #define I40E_AQC_MACVLAN_CMD_QUEUE_MASK		(0x7FF << \
@@ -1265,6 +1266,10 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE		2
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_IP			3
 
+#define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_OUTER_MAC	0x2000
+#define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_INNER_MAC	0x4000
+#define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_OUTER_IP	0x8000
+
 	__le32	tenant_id;
 	u8	reserved[4];
 	__le16	queue_number;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 578b178..220b972 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -973,6 +973,7 @@ struct i40e_aqc_add_macvlan_element_data {
 #define I40E_AQC_MACVLAN_ADD_HASH_MATCH		0x0002
 #define I40E_AQC_MACVLAN_ADD_IGNORE_VLAN	0x0004
 #define I40E_AQC_MACVLAN_ADD_TO_QUEUE		0x0008
+#define I40E_AQC_MACVLAN_ADD_USE_SHARED_MAC	0x0010
 	__le16	queue_number;
 #define I40E_AQC_MACVLAN_CMD_QUEUE_SHIFT	0
 #define I40E_AQC_MACVLAN_CMD_QUEUE_MASK		(0x7FF << \
@@ -1262,6 +1263,10 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE		2
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_IP			3
 
+#define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_OUTER_MAC	0x2000
+#define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_INNER_MAC	0x4000
+#define I40E_AQC_ADD_CLOUD_FLAGS_SHARED_OUTER_IP	0x8000
+
 	__le32	tenant_id;
 	u8	reserved[4];
 	__le16	queue_number;
-- 
2.5.0
