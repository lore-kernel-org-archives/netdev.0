From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/6] bnxt_en: Update to firmware interface spec to 1.6.1.
Date: Tue, 10 Jan 2017 20:12:36 -0500
Message-ID: <1484097159-21575-4-git-send-email-michael.chan@broadcom.com>
References: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34831 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760655AbdAKBM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:12:59 -0500
Received: by mail-pf0-f175.google.com with SMTP id f144so46298378pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 17:12:58 -0800 (PST)
In-Reply-To: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h | 261 +++++++++++++++++++++++---
 1 file changed, 237 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index d0d49ed..5df32ab 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -1,7 +1,7 @@
 /* Broadcom NetXtreme-C/E network driver.
  *
  * Copyright (c) 2014-2016 Broadcom Corporation
- * Copyright (c) 2016 Broadcom Limited
+ * Copyright (c) 2016-2017 Broadcom Limited
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -11,12 +11,12 @@
 #ifndef BNXT_HSI_H
 #define BNXT_HSI_H
 
-/* HSI and HWRM Specification 1.6.0 */
+/* HSI and HWRM Specification 1.6.1 */
 #define HWRM_VERSION_MAJOR	1
 #define HWRM_VERSION_MINOR	6
-#define HWRM_VERSION_UPDATE	0
+#define HWRM_VERSION_UPDATE	1
 
-#define HWRM_VERSION_STR	"1.6.0"
+#define HWRM_VERSION_STR	"1.6.1"
 /*
  * Following is the signature for HWRM message field that indicates not
  * applicable (All F's). Need to cast it the size of the field if needed.
@@ -549,6 +549,8 @@ struct hwrm_ver_get_output {
 	__le32 dev_caps_cfg;
 	#define VER_GET_RESP_DEV_CAPS_CFG_SECURE_FW_UPD_SUPPORTED  0x1UL
 	#define VER_GET_RESP_DEV_CAPS_CFG_FW_DCBX_AGENT_SUPPORTED  0x2UL
+	#define VER_GET_RESP_DEV_CAPS_CFG_SHORT_CMD_SUPPORTED      0x4UL
+	#define VER_GET_RESP_DEV_CAPS_CFG_SHORT_CMD_REQUIRED       0x8UL
 	u8 roce_fw_maj;
 	u8 roce_fw_min;
 	u8 roce_fw_bld;
@@ -1919,6 +1921,219 @@ struct hwrm_port_phy_i2c_read_output {
 	u8 valid;
 };
 
+/* hwrm_port_led_cfg */
+/* Input (64 bytes) */
+struct hwrm_port_led_cfg_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le32 enables;
+	#define PORT_LED_CFG_REQ_ENABLES_LED0_ID		    0x1UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED0_STATE		    0x2UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED0_COLOR		    0x4UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED0_BLINK_ON		    0x8UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED0_BLINK_OFF	    0x10UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED0_GROUP_ID		    0x20UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED1_ID		    0x40UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED1_STATE		    0x80UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED1_COLOR		    0x100UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED1_BLINK_ON		    0x200UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED1_BLINK_OFF	    0x400UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED1_GROUP_ID		    0x800UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED2_ID		    0x1000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED2_STATE		    0x2000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED2_COLOR		    0x4000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED2_BLINK_ON		    0x8000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED2_BLINK_OFF	    0x10000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED2_GROUP_ID		    0x20000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED3_ID		    0x40000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED3_STATE		    0x80000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED3_COLOR		    0x100000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED3_BLINK_ON		    0x200000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED3_BLINK_OFF	    0x400000UL
+	#define PORT_LED_CFG_REQ_ENABLES_LED3_GROUP_ID		    0x800000UL
+	__le16 port_id;
+	u8 num_leds;
+	u8 rsvd;
+	u8 led0_id;
+	u8 led0_state;
+	#define PORT_LED_CFG_REQ_LED0_STATE_DEFAULT		   0x0UL
+	#define PORT_LED_CFG_REQ_LED0_STATE_OFF		   0x1UL
+	#define PORT_LED_CFG_REQ_LED0_STATE_ON			   0x2UL
+	#define PORT_LED_CFG_REQ_LED0_STATE_BLINK		   0x3UL
+	#define PORT_LED_CFG_REQ_LED0_STATE_BLINKALT		   0x4UL
+	u8 led0_color;
+	#define PORT_LED_CFG_REQ_LED0_COLOR_DEFAULT		   0x0UL
+	#define PORT_LED_CFG_REQ_LED0_COLOR_AMBER		   0x1UL
+	#define PORT_LED_CFG_REQ_LED0_COLOR_GREEN		   0x2UL
+	#define PORT_LED_CFG_REQ_LED0_COLOR_GREENAMBER		   0x3UL
+	u8 unused_0;
+	__le16 led0_blink_on;
+	__le16 led0_blink_off;
+	u8 led0_group_id;
+	u8 rsvd0;
+	u8 led1_id;
+	u8 led1_state;
+	#define PORT_LED_CFG_REQ_LED1_STATE_DEFAULT		   0x0UL
+	#define PORT_LED_CFG_REQ_LED1_STATE_OFF		   0x1UL
+	#define PORT_LED_CFG_REQ_LED1_STATE_ON			   0x2UL
+	#define PORT_LED_CFG_REQ_LED1_STATE_BLINK		   0x3UL
+	#define PORT_LED_CFG_REQ_LED1_STATE_BLINKALT		   0x4UL
+	u8 led1_color;
+	#define PORT_LED_CFG_REQ_LED1_COLOR_DEFAULT		   0x0UL
+	#define PORT_LED_CFG_REQ_LED1_COLOR_AMBER		   0x1UL
+	#define PORT_LED_CFG_REQ_LED1_COLOR_GREEN		   0x2UL
+	#define PORT_LED_CFG_REQ_LED1_COLOR_GREENAMBER		   0x3UL
+	u8 unused_1;
+	__le16 led1_blink_on;
+	__le16 led1_blink_off;
+	u8 led1_group_id;
+	u8 rsvd1;
+	u8 led2_id;
+	u8 led2_state;
+	#define PORT_LED_CFG_REQ_LED2_STATE_DEFAULT		   0x0UL
+	#define PORT_LED_CFG_REQ_LED2_STATE_OFF		   0x1UL
+	#define PORT_LED_CFG_REQ_LED2_STATE_ON			   0x2UL
+	#define PORT_LED_CFG_REQ_LED2_STATE_BLINK		   0x3UL
+	#define PORT_LED_CFG_REQ_LED2_STATE_BLINKALT		   0x4UL
+	u8 led2_color;
+	#define PORT_LED_CFG_REQ_LED2_COLOR_DEFAULT		   0x0UL
+	#define PORT_LED_CFG_REQ_LED2_COLOR_AMBER		   0x1UL
+	#define PORT_LED_CFG_REQ_LED2_COLOR_GREEN		   0x2UL
+	#define PORT_LED_CFG_REQ_LED2_COLOR_GREENAMBER		   0x3UL
+	u8 unused_2;
+	__le16 led2_blink_on;
+	__le16 led2_blink_off;
+	u8 led2_group_id;
+	u8 rsvd2;
+	u8 led3_id;
+	u8 led3_state;
+	#define PORT_LED_CFG_REQ_LED3_STATE_DEFAULT		   0x0UL
+	#define PORT_LED_CFG_REQ_LED3_STATE_OFF		   0x1UL
+	#define PORT_LED_CFG_REQ_LED3_STATE_ON			   0x2UL
+	#define PORT_LED_CFG_REQ_LED3_STATE_BLINK		   0x3UL
+	#define PORT_LED_CFG_REQ_LED3_STATE_BLINKALT		   0x4UL
+	u8 led3_color;
+	#define PORT_LED_CFG_REQ_LED3_COLOR_DEFAULT		   0x0UL
+	#define PORT_LED_CFG_REQ_LED3_COLOR_AMBER		   0x1UL
+	#define PORT_LED_CFG_REQ_LED3_COLOR_GREEN		   0x2UL
+	#define PORT_LED_CFG_REQ_LED3_COLOR_GREENAMBER		   0x3UL
+	u8 unused_3;
+	__le16 led3_blink_on;
+	__le16 led3_blink_off;
+	u8 led3_group_id;
+	u8 rsvd3;
+};
+
+/* Output (16 bytes) */
+struct hwrm_port_led_cfg_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le32 unused_0;
+	u8 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 valid;
+};
+
+/* hwrm_port_led_qcaps */
+/* Input (24 bytes) */
+struct hwrm_port_led_qcaps_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le16 port_id;
+	__le16 unused_0[3];
+};
+
+/* Output (48 bytes) */
+struct hwrm_port_led_qcaps_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	u8 num_leds;
+	u8 unused_0[3];
+	u8 led0_id;
+	u8 led0_type;
+	#define PORT_LED_QCAPS_RESP_LED0_TYPE_SPEED		   0x0UL
+	#define PORT_LED_QCAPS_RESP_LED0_TYPE_ACTIVITY		   0x1UL
+	#define PORT_LED_QCAPS_RESP_LED0_TYPE_INVALID		   0xffUL
+	u8 led0_group_id;
+	u8 unused_1;
+	__le16 led0_state_caps;
+	#define PORT_LED_QCAPS_RESP_LED0_STATE_CAPS_ENABLED	    0x1UL
+	#define PORT_LED_QCAPS_RESP_LED0_STATE_CAPS_OFF_SUPPORTED  0x2UL
+	#define PORT_LED_QCAPS_RESP_LED0_STATE_CAPS_ON_SUPPORTED   0x4UL
+	#define PORT_LED_QCAPS_RESP_LED0_STATE_CAPS_BLINK_SUPPORTED 0x8UL
+	#define PORT_LED_QCAPS_RESP_LED0_STATE_CAPS_BLINK_ALT_SUPPORTED 0x10UL
+	__le16 led0_color_caps;
+	#define PORT_LED_QCAPS_RESP_LED0_COLOR_CAPS_RSVD	    0x1UL
+	#define PORT_LED_QCAPS_RESP_LED0_COLOR_CAPS_AMBER_SUPPORTED 0x2UL
+	#define PORT_LED_QCAPS_RESP_LED0_COLOR_CAPS_GREEN_SUPPORTED 0x4UL
+	u8 led1_id;
+	u8 led1_type;
+	#define PORT_LED_QCAPS_RESP_LED1_TYPE_SPEED		   0x0UL
+	#define PORT_LED_QCAPS_RESP_LED1_TYPE_ACTIVITY		   0x1UL
+	#define PORT_LED_QCAPS_RESP_LED1_TYPE_INVALID		   0xffUL
+	u8 led1_group_id;
+	u8 unused_2;
+	__le16 led1_state_caps;
+	#define PORT_LED_QCAPS_RESP_LED1_STATE_CAPS_ENABLED	    0x1UL
+	#define PORT_LED_QCAPS_RESP_LED1_STATE_CAPS_OFF_SUPPORTED  0x2UL
+	#define PORT_LED_QCAPS_RESP_LED1_STATE_CAPS_ON_SUPPORTED   0x4UL
+	#define PORT_LED_QCAPS_RESP_LED1_STATE_CAPS_BLINK_SUPPORTED 0x8UL
+	#define PORT_LED_QCAPS_RESP_LED1_STATE_CAPS_BLINK_ALT_SUPPORTED 0x10UL
+	__le16 led1_color_caps;
+	#define PORT_LED_QCAPS_RESP_LED1_COLOR_CAPS_RSVD	    0x1UL
+	#define PORT_LED_QCAPS_RESP_LED1_COLOR_CAPS_AMBER_SUPPORTED 0x2UL
+	#define PORT_LED_QCAPS_RESP_LED1_COLOR_CAPS_GREEN_SUPPORTED 0x4UL
+	u8 led2_id;
+	u8 led2_type;
+	#define PORT_LED_QCAPS_RESP_LED2_TYPE_SPEED		   0x0UL
+	#define PORT_LED_QCAPS_RESP_LED2_TYPE_ACTIVITY		   0x1UL
+	#define PORT_LED_QCAPS_RESP_LED2_TYPE_INVALID		   0xffUL
+	u8 led2_group_id;
+	u8 unused_3;
+	__le16 led2_state_caps;
+	#define PORT_LED_QCAPS_RESP_LED2_STATE_CAPS_ENABLED	    0x1UL
+	#define PORT_LED_QCAPS_RESP_LED2_STATE_CAPS_OFF_SUPPORTED  0x2UL
+	#define PORT_LED_QCAPS_RESP_LED2_STATE_CAPS_ON_SUPPORTED   0x4UL
+	#define PORT_LED_QCAPS_RESP_LED2_STATE_CAPS_BLINK_SUPPORTED 0x8UL
+	#define PORT_LED_QCAPS_RESP_LED2_STATE_CAPS_BLINK_ALT_SUPPORTED 0x10UL
+	__le16 led2_color_caps;
+	#define PORT_LED_QCAPS_RESP_LED2_COLOR_CAPS_RSVD	    0x1UL
+	#define PORT_LED_QCAPS_RESP_LED2_COLOR_CAPS_AMBER_SUPPORTED 0x2UL
+	#define PORT_LED_QCAPS_RESP_LED2_COLOR_CAPS_GREEN_SUPPORTED 0x4UL
+	u8 led3_id;
+	u8 led3_type;
+	#define PORT_LED_QCAPS_RESP_LED3_TYPE_SPEED		   0x0UL
+	#define PORT_LED_QCAPS_RESP_LED3_TYPE_ACTIVITY		   0x1UL
+	#define PORT_LED_QCAPS_RESP_LED3_TYPE_INVALID		   0xffUL
+	u8 led3_group_id;
+	u8 unused_4;
+	__le16 led3_state_caps;
+	#define PORT_LED_QCAPS_RESP_LED3_STATE_CAPS_ENABLED	    0x1UL
+	#define PORT_LED_QCAPS_RESP_LED3_STATE_CAPS_OFF_SUPPORTED  0x2UL
+	#define PORT_LED_QCAPS_RESP_LED3_STATE_CAPS_ON_SUPPORTED   0x4UL
+	#define PORT_LED_QCAPS_RESP_LED3_STATE_CAPS_BLINK_SUPPORTED 0x8UL
+	#define PORT_LED_QCAPS_RESP_LED3_STATE_CAPS_BLINK_ALT_SUPPORTED 0x10UL
+	__le16 led3_color_caps;
+	#define PORT_LED_QCAPS_RESP_LED3_COLOR_CAPS_RSVD	    0x1UL
+	#define PORT_LED_QCAPS_RESP_LED3_COLOR_CAPS_AMBER_SUPPORTED 0x2UL
+	#define PORT_LED_QCAPS_RESP_LED3_COLOR_CAPS_GREEN_SUPPORTED 0x4UL
+	u8 unused_5;
+	u8 unused_6;
+	u8 unused_7;
+	u8 valid;
+};
+
 /* hwrm_queue_qportcfg */
 /* Input (24 bytes) */
 struct hwrm_queue_qportcfg_input {
@@ -4092,9 +4307,7 @@ struct hwrm_fw_set_structured_data_input {
 	__le64 src_data_addr;
 	__le16 data_len;
 	u8 hdr_cnt;
-	u8 unused_0;
-	__le16 port_id;
-	__le16 unused_1;
+	u8 unused_0[5];
 };
 
 /* Output (16 bytes) */
@@ -4111,7 +4324,7 @@ struct hwrm_fw_set_structured_data_output {
 };
 
 /* hwrm_fw_get_structured_data */
-/* Input (40 bytes) */
+/* Input (32 bytes) */
 struct hwrm_fw_get_structured_data_input {
 	__le16 req_type;
 	__le16 cmpl_ring;
@@ -4131,8 +4344,6 @@ struct hwrm_fw_get_structured_data_input {
 	#define FW_GET_STRUCTURED_DATA_REQ_SUBTYPE_NON_TPMR_OPERATIONAL 0x202UL
 	u8 count;
 	u8 unused_0;
-	__le16 port_id;
-	__le16 unused_1[3];
 };
 
 /* Output (16 bytes) */
@@ -4616,7 +4827,8 @@ struct hwrm_nvm_install_update_input {
 	__le32 install_type;
 	#define NVM_INSTALL_UPDATE_REQ_INSTALL_TYPE_NORMAL	   0x0UL
 	#define NVM_INSTALL_UPDATE_REQ_INSTALL_TYPE_ALL	   0xffffffffUL
-	__le32 unused_0;
+	__le16 flags;
+	__le16 unused_0;
 };
 
 /* Output (24 bytes) */
@@ -4973,12 +5185,13 @@ struct ctx_hw_stats {
 struct hwrm_struct_hdr {
 	__le16 struct_id;
 	#define STRUCT_HDR_STRUCT_ID_LLDP_CFG			   0x41bUL
-	#define STRUCT_HDR_STRUCT_ID_DCBX_ETS_CFG		   0x41dUL
-	#define STRUCT_HDR_STRUCT_ID_DCBX_PFC_CFG		   0x41fUL
-	#define STRUCT_HDR_STRUCT_ID_DCBX_APP_CFG		   0x421UL
-	#define STRUCT_HDR_STRUCT_ID_DCBX_STATE_CFG		   0x422UL
-	#define STRUCT_HDR_STRUCT_ID_LLDP_GENERIC_CFG		   0x424UL
-	#define STRUCT_HDR_STRUCT_ID_LLDP_DEVICE_CFG		   0x426UL
+	#define STRUCT_HDR_STRUCT_ID_DCBX_ETS			   0x41dUL
+	#define STRUCT_HDR_STRUCT_ID_DCBX_PFC			   0x41fUL
+	#define STRUCT_HDR_STRUCT_ID_DCBX_APP			   0x421UL
+	#define STRUCT_HDR_STRUCT_ID_DCBX_FEATURE_STATE	   0x422UL
+	#define STRUCT_HDR_STRUCT_ID_LLDP_GENERIC		   0x424UL
+	#define STRUCT_HDR_STRUCT_ID_LLDP_DEVICE		   0x426UL
+	#define STRUCT_HDR_STRUCT_ID_PORT_DESCRIPTION		   0xaUL
 	__le16 len;
 	u8 version;
 	u8 count;
@@ -4988,14 +5201,14 @@ struct hwrm_struct_hdr {
 	__le16 unused_0[3];
 };
 
-/* DCBX Application configuration structure (8 bytes) */
-struct hwrm_struct_data_dcbx_app_cfg {
-	__le16 protocol_id;
+/* DCBX Application configuration structure (1057) (8 bytes) */
+struct hwrm_struct_data_dcbx_app {
+	__be16 protocol_id;
 	u8 protocol_selector;
-	#define STRUCT_DATA_DCBX_APP_CFG_PROTOCOL_SELECTOR_ETHER_TYPE 0x1UL
-	#define STRUCT_DATA_DCBX_APP_CFG_PROTOCOL_SELECTOR_TCP_PORT 0x2UL
-	#define STRUCT_DATA_DCBX_APP_CFG_PROTOCOL_SELECTOR_UDP_PORT 0x3UL
-	#define STRUCT_DATA_DCBX_APP_CFG_PROTOCOL_SELECTOR_TCP_UDP_PORT 0x4UL
+	#define STRUCT_DATA_DCBX_APP_PROTOCOL_SELECTOR_ETHER_TYPE 0x1UL
+	#define STRUCT_DATA_DCBX_APP_PROTOCOL_SELECTOR_TCP_PORT   0x2UL
+	#define STRUCT_DATA_DCBX_APP_PROTOCOL_SELECTOR_UDP_PORT   0x3UL
+	#define STRUCT_DATA_DCBX_APP_PROTOCOL_SELECTOR_TCP_UDP_PORT 0x4UL
 	u8 priority;
 	u8 valid;
 	u8 unused_0[3];
-- 
1.8.3.1
