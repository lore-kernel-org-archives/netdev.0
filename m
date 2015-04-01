From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 1/2] cxgb4: Firmware macro changes for fw verison 1.13.32.0
Date: Wed,  1 Apr 2015 21:41:15 +0530
Message-ID: <1427904676-31000-2-git-send-email-hariprasad@chelsio.com>
References: <1427904676-31000-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14646 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752645AbbDAK7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:59:39 -0400
In-Reply-To: <1427904676-31000-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds new macro and few macro changes for fw version 1.13.32.0 also
changes version string in driver to match 1.13.32.0

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h     | 39 +++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h |  8 ++---
 2 files changed, 41 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 9b353a8..a4a19e0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -101,7 +101,7 @@ enum fw_wr_opcodes {
 	FW_RI_BIND_MW_WR               = 0x18,
 	FW_RI_FR_NSMR_WR               = 0x19,
 	FW_RI_INV_LSTAG_WR             = 0x1a,
-	FW_LASTC2E_WR                  = 0x40
+	FW_LASTC2E_WR                  = 0x70
 };
 
 struct fw_wr_hdr {
@@ -993,6 +993,7 @@ enum fw_memtype_cf {
 	FW_MEMTYPE_CF_EXTMEM		= 0x2,
 	FW_MEMTYPE_CF_FLASH		= 0x4,
 	FW_MEMTYPE_CF_INTERNAL		= 0x5,
+	FW_MEMTYPE_CF_EXTMEM1           = 0x6,
 };
 
 struct fw_caps_config_cmd {
@@ -1035,6 +1036,7 @@ enum fw_params_mnem {
 	FW_PARAMS_MNEM_PFVF		= 2,	/* function params */
 	FW_PARAMS_MNEM_REG		= 3,	/* limited register access */
 	FW_PARAMS_MNEM_DMAQ		= 4,	/* dma queue params */
+	FW_PARAMS_MNEM_CHNET            = 5,    /* chnet params */
 	FW_PARAMS_MNEM_LAST
 };
 
@@ -3102,7 +3104,8 @@ enum fw_devlog_facility {
 	FW_DEVLOG_FACILITY_FCOE		= 0x2E,
 	FW_DEVLOG_FACILITY_FOISCSI	= 0x30,
 	FW_DEVLOG_FACILITY_FOFCOE	= 0x32,
-	FW_DEVLOG_FACILITY_MAX		= 0x32,
+	FW_DEVLOG_FACILITY_CHNET        = 0x34,
+	FW_DEVLOG_FACILITY_MAX          = 0x34,
 };
 
 /* log message format */
@@ -3139,4 +3142,36 @@ struct fw_devlog_cmd {
 	(((x) >> FW_DEVLOG_CMD_MEMADDR16_DEVLOG_S) & \
 	 FW_DEVLOG_CMD_MEMADDR16_DEVLOG_M)
 
+/* P C I E   F W   P F 7   R E G I S T E R */
+
+/* PF7 stores the Firmware Device Log parameters which allows Host Drivers to
+ * access the "devlog" which needing to contact firmware.  The encoding is
+ * mostly the same as that returned by the DEVLOG command except for the size
+ * which is encoded as the number of entries in multiples-1 of 128 here rather
+ * than the memory size as is done in the DEVLOG command.  Thus, 0 means 128
+ * and 15 means 2048.  This of course in turn constrains the allowed values
+ * for the devlog size ...
+ */
+#define PCIE_FW_PF_DEVLOG		7
+
+#define PCIE_FW_PF_DEVLOG_NENTRIES128_S	28
+#define PCIE_FW_PF_DEVLOG_NENTRIES128_M	0xf
+#define PCIE_FW_PF_DEVLOG_NENTRIES128_V(x) \
+	((x) << PCIE_FW_PF_DEVLOG_NENTRIES128_S)
+#define PCIE_FW_PF_DEVLOG_NENTRIES128_G(x) \
+	(((x) >> PCIE_FW_PF_DEVLOG_NENTRIES128_S) & \
+	 PCIE_FW_PF_DEVLOG_NENTRIES128_M)
+
+#define PCIE_FW_PF_DEVLOG_ADDR16_S	4
+#define PCIE_FW_PF_DEVLOG_ADDR16_M	0xffffff
+#define PCIE_FW_PF_DEVLOG_ADDR16_V(x)	((x) << PCIE_FW_PF_DEVLOG_ADDR16_S)
+#define PCIE_FW_PF_DEVLOG_ADDR16_G(x) \
+	(((x) >> PCIE_FW_PF_DEVLOG_ADDR16_S) & PCIE_FW_PF_DEVLOG_ADDR16_M)
+
+#define PCIE_FW_PF_DEVLOG_MEMTYPE_S	0
+#define PCIE_FW_PF_DEVLOG_MEMTYPE_M	0xf
+#define PCIE_FW_PF_DEVLOG_MEMTYPE_V(x)	((x) << PCIE_FW_PF_DEVLOG_MEMTYPE_S)
+#define PCIE_FW_PF_DEVLOG_MEMTYPE_G(x) \
+	(((x) >> PCIE_FW_PF_DEVLOG_MEMTYPE_S) & PCIE_FW_PF_DEVLOG_MEMTYPE_M)
+
 #endif /* _T4FW_INTERFACE_H_ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
index e2bd3f7..b9d1cba 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
@@ -36,13 +36,13 @@
 #define __T4FW_VERSION_H__
 
 #define T4FW_VERSION_MAJOR 0x01
-#define T4FW_VERSION_MINOR 0x0C
-#define T4FW_VERSION_MICRO 0x19
+#define T4FW_VERSION_MINOR 0x0D
+#define T4FW_VERSION_MICRO 0x20
 #define T4FW_VERSION_BUILD 0x00
 
 #define T5FW_VERSION_MAJOR 0x01
-#define T5FW_VERSION_MINOR 0x0C
-#define T5FW_VERSION_MICRO 0x19
+#define T5FW_VERSION_MINOR 0x0D
+#define T5FW_VERSION_MICRO 0x20
 #define T5FW_VERSION_BUILD 0x00
 
 #endif
-- 
2.3.4
