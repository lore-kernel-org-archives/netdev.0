From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 3/3] i40e: updates to AdminQ interface
Date: Wed, 15 Jan 2014 15:18:24 -0800
Message-ID: <1389827904-14713-4-git-send-email-aaron.f.brown@intel.com>
References: <1389827904-14713-1-git-send-email-aaron.f.brown@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49479 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900AbaAOXSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 18:18:33 -0500
In-Reply-To: <1389827904-14713-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Refinements to cloud support in the Firmware API.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h | 22 ++++++++--------------
 drivers/net/ethernet/intel/i40e/i40e_common.c     |  1 -
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index be61a47..7b6374a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -680,7 +680,6 @@ struct i40e_aqc_add_get_update_vsi {
 #define I40E_AQ_VSI_TYPE_PF             0x2
 #define I40E_AQ_VSI_TYPE_EMP_MNG        0x3
 #define I40E_AQ_VSI_FLAG_CASCADED_PV    0x4
-#define I40E_AQ_VSI_FLAG_CLOUD_VSI      0x8
 	__le32 addr_high;
 	__le32 addr_low;
 };
@@ -1042,7 +1041,9 @@ struct i40e_aqc_set_vsi_promiscuous_modes {
 #define I40E_AQC_SET_VSI_PROMISC_VLAN        0x10
 	__le16 seid;
 #define I40E_AQC_VSI_PROM_CMD_SEID_MASK      0x3FF
-	u8     reserved[10];
+	__le16 vlan_tag;
+#define I40E_AQC_SET_VSI_VLAN_VALID          0x8000
+	u8     reserved[8];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_set_vsi_promiscuous_modes);
@@ -1947,19 +1948,12 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_lldp_start);
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
-	u8     udp_key_index;
-#define I40E_AQC_TUNNEL_KEY_INDEX_VXLAN			0x0
-#define I40E_AQC_TUNNEL_KEY_INDEX_NGE			0x1
-#define I40E_AQC_TUNNEL_KEY_INDEX_PROPRIETARY_UDP	0x2
-	u8     reserved[10];
+#define I40E_AQC_TUNNEL_TYPE_VXLAN	0x00
+#define I40E_AQC_TUNNEL_TYPE_NGE	0x01
+#define I40E_AQC_TUNNEL_TYPE_TEREDO	0x10
+	u8     reserved1[10];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_add_udp_tunnel);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index aedc71b..529ecb4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1742,7 +1742,6 @@ i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
 	i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_add_udp_tunnel);
 
 	cmd->udp_port = cpu_to_le16(udp_port);
-	cmd->header_len = header_len;
 	cmd->protocol_type = protocol_index;
 
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
-- 
1.8.5.GIT
