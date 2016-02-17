From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/16] i40e: AQ thermal sensor control struct
Date: Tue, 16 Feb 2016 21:34:10 -0800
Message-ID: <1455687262-20453-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771AbcBQFe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:26 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the new AQ command and struct for managing a thermal sensor.

Change-ID: I6f5631839a0f3dca352a6c222f1269a960e2310a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 17 +++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 17 +++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 5effb91..9684572 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -230,6 +230,7 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_nvm_config_read		= 0x0704,
 	i40e_aqc_opc_nvm_config_write		= 0x0705,
 	i40e_aqc_opc_oem_post_update		= 0x0720,
+	i40e_aqc_opc_thermal_sensor		= 0x0721,
 
 	/* virtualization commands */
 	i40e_aqc_opc_send_msg_to_pf		= 0x0801,
@@ -1952,6 +1953,22 @@ struct i40e_aqc_nvm_oem_post_update_buffer {
 
 I40E_CHECK_STRUCT_LEN(0x28, i40e_aqc_nvm_oem_post_update_buffer);
 
+/* Thermal Sensor (indirect 0x0721)
+ *     read or set thermal sensor configs and values
+ *     takes a sensor and command specific data buffer, not detailed here
+ */
+struct i40e_aqc_thermal_sensor {
+	u8 sensor_action;
+#define I40E_AQ_THERMAL_SENSOR_READ_CONFIG	0
+#define I40E_AQ_THERMAL_SENSOR_SET_CONFIG	1
+#define I40E_AQ_THERMAL_SENSOR_READ_TEMP	2
+	u8 reserved[7];
+	__le32	addr_high;
+	__le32	addr_low;
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_thermal_sensor);
+
 /* Send to PF command (indirect 0x0801) id is only used by PF
  * Send to VF command (indirect 0x0802) id is only used by PF
  * Send to Peer PF command (indirect 0x0803)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index bdb18f6..6468537 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -230,6 +230,7 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_nvm_config_read		= 0x0704,
 	i40e_aqc_opc_nvm_config_write		= 0x0705,
 	i40e_aqc_opc_oem_post_update		= 0x0720,
+	i40e_aqc_opc_thermal_sensor		= 0x0721,
 
 	/* virtualization commands */
 	i40e_aqc_opc_send_msg_to_pf		= 0x0801,
@@ -1949,6 +1950,22 @@ struct i40e_aqc_nvm_oem_post_update_buffer {
 
 I40E_CHECK_STRUCT_LEN(0x28, i40e_aqc_nvm_oem_post_update_buffer);
 
+/* Thermal Sensor (indirect 0x0721)
+ *     read or set thermal sensor configs and values
+ *     takes a sensor and command specific data buffer, not detailed here
+ */
+struct i40e_aqc_thermal_sensor {
+	u8 sensor_action;
+#define I40E_AQ_THERMAL_SENSOR_READ_CONFIG	0
+#define I40E_AQ_THERMAL_SENSOR_SET_CONFIG	1
+#define I40E_AQ_THERMAL_SENSOR_READ_TEMP	2
+	u8 reserved[7];
+	__le32	addr_high;
+	__le32	addr_low;
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_thermal_sensor);
+
 /* Send to PF command (indirect 0x0801) id is only used by PF
  * Send to VF command (indirect 0x0802) id is only used by PF
  * Send to Peer PF command (indirect 0x0803)
-- 
2.5.0
