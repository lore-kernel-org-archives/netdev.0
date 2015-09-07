From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Changes for new firmware 1.14.4.0
Date: Mon,  7 Sep 2015 17:40:50 +0530
Message-ID: <1441627850-5610-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12155 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750885AbbIGMKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 08:10:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Incorporate fw_ldst_cmd structure change for new firmware and also
update version string for the same

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h     | 33 +++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h | 12 ++++-----
 2 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index ab46746..a32de30 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -762,8 +762,6 @@ enum fw_ldst_func_mod_index {
 
 struct fw_ldst_cmd {
 	__be32 op_to_addrspace;
-#define FW_LDST_CMD_ADDRSPACE_S		0
-#define FW_LDST_CMD_ADDRSPACE_V(x)	((x) << FW_LDST_CMD_ADDRSPACE_S)
 	__be32 cycles_to_len16;
 	union fw_ldst {
 		struct fw_ldst_addrval {
@@ -788,6 +786,13 @@ struct fw_ldst_cmd {
 			__be16 vctl;
 			__be16 rval;
 		} mdio;
+		struct fw_ldst_cim_rq {
+			u8 req_first64[8];
+			u8 req_second64[8];
+			u8 resp_first64[8];
+			u8 resp_second64[8];
+			__be32 r3[2];
+		} cim_rq;
 		union fw_ldst_mps {
 			struct fw_ldst_mps_rplc {
 				__be16 fid_idx;
@@ -828,9 +833,33 @@ struct fw_ldst_cmd {
 			__be16 nset_pkd;
 			__be32 data[12];
 		} pcie;
+		struct fw_ldst_i2c_deprecated {
+			u8 pid_pkd;
+			u8 base;
+			u8 boffset;
+			u8 data;
+			__be32 r9;
+		} i2c_deprecated;
+		struct fw_ldst_i2c {
+			u8 pid;
+			u8 did;
+			u8 boffset;
+			u8 blen;
+			__be32 r9;
+			__u8   data[48];
+		} i2c;
+		struct fw_ldst_le {
+			__be32 index;
+			__be32 r9;
+			u8 val[33];
+			u8 r11[7];
+		} le;
 	} u;
 };
 
+#define FW_LDST_CMD_ADDRSPACE_S		0
+#define FW_LDST_CMD_ADDRSPACE_V(x)	((x) << FW_LDST_CMD_ADDRSPACE_S)
+
 #define FW_LDST_CMD_MSG_S       31
 #define FW_LDST_CMD_MSG_V(x)	((x) << FW_LDST_CMD_MSG_S)
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
index 32b2135..58a0327 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
@@ -36,18 +36,18 @@
 #define __T4FW_VERSION_H__
 
 #define T4FW_VERSION_MAJOR 0x01
-#define T4FW_VERSION_MINOR 0x0D
-#define T4FW_VERSION_MICRO 0x20
+#define T4FW_VERSION_MINOR 0x0E
+#define T4FW_VERSION_MICRO 0x04
 #define T4FW_VERSION_BUILD 0x00
 
 #define T5FW_VERSION_MAJOR 0x01
-#define T5FW_VERSION_MINOR 0x0D
-#define T5FW_VERSION_MICRO 0x20
+#define T5FW_VERSION_MINOR 0x0E
+#define T5FW_VERSION_MICRO 0x04
 #define T5FW_VERSION_BUILD 0x00
 
 #define T6FW_VERSION_MAJOR 0x01
-#define T6FW_VERSION_MINOR 0x0D
-#define T6FW_VERSION_MICRO 0x2D
+#define T6FW_VERSION_MINOR 0x0E
+#define T6FW_VERSION_MICRO 0x04
 #define T6FW_VERSION_BUILD 0x00
 
 #endif
-- 
2.3.4
