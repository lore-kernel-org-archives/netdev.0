From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40evf: Update AdminQ interface
Date: Wed, 21 May 2014 05:00:59 -0700
Message-ID: <1400673673-31626-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Kevin Scott <kevin.c.scott@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20362 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751882AbaEUMBW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:22 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Minor changes to the AdminQ interface to bring it up-to-date.

Change-ID: Ie31a4cc4911b2d9d3b7f9af2e56fb0ae674f6345
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 6e61766..77e4f14 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -676,7 +676,6 @@ struct i40e_aqc_add_get_update_vsi {
 #define I40E_AQ_VSI_TYPE_PF             0x2
 #define I40E_AQ_VSI_TYPE_EMP_MNG        0x3
 #define I40E_AQ_VSI_FLAG_CASCADED_PV    0x4
-#define I40E_AQ_VSI_FLAG_CLOUD_VSI      0x8
 	__le32 addr_high;
 	__le32 addr_low;
 };
@@ -1038,7 +1037,9 @@ struct i40e_aqc_set_vsi_promiscuous_modes {
 #define I40E_AQC_SET_VSI_PROMISC_VLAN        0x10
 	__le16 seid;
 #define I40E_AQC_VSI_PROM_CMD_SEID_MASK      0x3FF
-	u8     reserved[10];
+	__le16 vlan_tag;
+#define I40E_AQC_SET_VSI_VLAN_VALID          0x8000
+	u8     reserved[8];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_set_vsi_promiscuous_modes);
@@ -1931,19 +1932,12 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_lldp_start);
 /* Add Udp Tunnel command and completion (direct 0x0B00) */
 struct i40e_aqc_add_udp_tunnel {
 	__le16 udp_port;
-	u8     header_len; /* in DWords, 1 to 15 */
+	u8     reserved0[3];
 	u8     protocol_type;
-#define I40E_AQC_TUNNEL_TYPE_TEREDO	0x0
-#define I40E_AQC_TUNNEL_TYPE_VXLAN	0x2
-#define I40E_AQC_TUNNEL_TYPE_NGE	0x3
-	u8     variable_udp_length;
-#define I40E_AQC_TUNNEL_FIXED_UDP_LENGTH	0x0
-#define I40E_AQC_TUNNEL_VARIABLE_UDP_LENGTH	0x1
-	u8		udp_key_index;
-#define I40E_AQC_TUNNEL_KEY_INDEX_VXLAN			0x0
-#define I40E_AQC_TUNNEL_KEY_INDEX_NGE			0x1
-#define I40E_AQC_TUNNEL_KEY_INDEX_PROPRIETARY_UDP	0x2
-	u8		reserved[10];
+#define I40E_AQC_TUNNEL_TYPE_VXLAN	0x00
+#define I40E_AQC_TUNNEL_TYPE_NGE	0x01
+#define I40E_AQC_TUNNEL_TYPE_TEREDO	0x10
+	u8     reserved1[10];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_add_udp_tunnel);
-- 
1.9.0
