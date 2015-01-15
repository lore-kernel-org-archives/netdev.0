From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH 1/2] csiostor:Remove T4 FCoE support.
Date: Thu, 15 Jan 2015 19:15:51 +0530
Message-ID: <60c994d45d6dc008ce68b652cd08022c7692afbb.1421328606.git.praveenm@chelsio.com>
References: <cover.1421328605.git.praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18950 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754053AbbAONqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 08:46:36 -0500
In-Reply-To: <cover.1421328605.git.praveenm@chelsio.com>
In-Reply-To: <cover.1421328605.git.praveenm@chelsio.com>
References: <cover.1421328605.git.praveenm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes FCoE support for chelsio T4 adapters.
and claims only physical function 6 for chelsio T5 adapters.

Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>
---
 drivers/scsi/csiostor/csio_hw.c      | 61 +++++++++---------------------------
 drivers/scsi/csiostor/csio_hw_chip.h | 43 -------------------------
 drivers/scsi/csiostor/csio_init.c    |  6 ++--
 drivers/scsi/csiostor/csio_wr.c      | 15 +++++----
 4 files changed, 24 insertions(+), 101 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 5c31fa6..35c5f83 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -60,37 +60,10 @@ int csio_msi = 2;
 static int dev_num;
 
 /* FCoE Adapter types & its description */
-static const struct csio_adap_desc csio_t4_fcoe_adapters[] = {
-	{"T440-Dbg 10G", "Chelsio T440-Dbg 10G [FCoE]"},
-	{"T420-CR 10G", "Chelsio T420-CR 10G [FCoE]"},
-	{"T422-CR 10G/1G", "Chelsio T422-CR 10G/1G [FCoE]"},
-	{"T440-CR 10G", "Chelsio T440-CR 10G [FCoE]"},
-	{"T420-BCH 10G", "Chelsio T420-BCH 10G [FCoE]"},
-	{"T440-BCH 10G", "Chelsio T440-BCH 10G [FCoE]"},
-	{"T440-CH 10G", "Chelsio T440-CH 10G [FCoE]"},
-	{"T420-SO 10G", "Chelsio T420-SO 10G [FCoE]"},
-	{"T420-CX4 10G", "Chelsio T420-CX4 10G [FCoE]"},
-	{"T420-BT 10G", "Chelsio T420-BT 10G [FCoE]"},
-	{"T404-BT 1G", "Chelsio T404-BT 1G [FCoE]"},
-	{"B420-SR 10G", "Chelsio B420-SR 10G [FCoE]"},
-	{"B404-BT 1G", "Chelsio B404-BT 1G [FCoE]"},
-	{"T480-CR 10G", "Chelsio T480-CR 10G [FCoE]"},
-	{"T440-LP-CR 10G", "Chelsio T440-LP-CR 10G [FCoE]"},
-	{"AMSTERDAM 10G", "Chelsio AMSTERDAM 10G [FCoE]"},
-	{"HUAWEI T480 10G", "Chelsio HUAWEI T480 10G [FCoE]"},
-	{"HUAWEI T440 10G", "Chelsio HUAWEI T440 10G [FCoE]"},
-	{"HUAWEI STG 10G", "Chelsio HUAWEI STG 10G [FCoE]"},
-	{"ACROMAG XAUI 10G", "Chelsio ACROMAG XAUI 10G [FCoE]"},
-	{"ACROMAG SFP+ 10G", "Chelsio ACROMAG SFP+ 10G [FCoE]"},
-	{"QUANTA SFP+ 10G", "Chelsio QUANTA SFP+ 10G [FCoE]"},
-	{"HUAWEI 10Gbase-T", "Chelsio HUAWEI 10Gbase-T [FCoE]"},
-	{"HUAWEI T4TOE 10G", "Chelsio HUAWEI T4TOE 10G [FCoE]"}
-};
-
 static const struct csio_adap_desc csio_t5_fcoe_adapters[] = {
 	{"T580-Dbg 10G", "Chelsio T580-Dbg 10G [FCoE]"},
 	{"T520-CR 10G", "Chelsio T520-CR 10G [FCoE]"},
-	{"T522-CR 10G/1G", "Chelsio T452-CR 10G/1G [FCoE]"},
+	{"T522-CR 10G/1G", "Chelsio T522-CR 10G/1G [FCoE]"},
 	{"T540-CR 10G", "Chelsio T540-CR 10G [FCoE]"},
 	{"T520-BCH 10G", "Chelsio T520-BCH 10G [FCoE]"},
 	{"T540-BCH 10G", "Chelsio T540-BCH 10G [FCoE]"},
@@ -107,7 +80,9 @@ static const struct csio_adap_desc csio_t5_fcoe_adapters[] = {
 	{"T580-LP-CR 40G", "Chelsio T580-LP-CR 40G [FCoE]"},
 	{"T520-LL-CR 10G", "Chelsio T520-LL-CR 10G [FCoE]"},
 	{"T560-CR 40G", "Chelsio T560-CR 40G [FCoE]"},
-	{"T580-CR 40G", "Chelsio T580-CR 40G [FCoE]"}
+	{"T580-CR 40G", "Chelsio T580-CR 40G [FCoE]"},
+	{"T580-SO 40G", "Chelsio T580-SO 40G [FCoE]"},
+	{"T502-BT 1G", "Chelsio T502-BT 1G [FCoE]"}
 };
 
 static void csio_mgmtm_cleanup(struct csio_mgmtm *);
@@ -1716,9 +1691,9 @@ csio_hw_flash_config(struct csio_hw *hw, u32 *fw_cfg_param, char *path)
 	uint32_t *cfg_data;
 	int value_to_add = 0;
 
-	if (request_firmware(&cf, CSIO_CF_FNAME(hw), dev) < 0) {
+	if (request_firmware(&cf, FW_CFG_NAME_T5, dev) < 0) {
 		csio_err(hw, "could not find config file %s, err: %d\n",
-			 CSIO_CF_FNAME(hw), ret);
+			 FW_CFG_NAME_T5, ret);
 		return -ENOENT;
 	}
 
@@ -1758,8 +1733,8 @@ csio_hw_flash_config(struct csio_hw *hw, u32 *fw_cfg_param, char *path)
 	}
 	if (ret == 0) {
 		csio_info(hw, "config file upgraded to %s\n",
-			  CSIO_CF_FNAME(hw));
-		snprintf(path, 64, "%s%s", "/lib/firmware/", CSIO_CF_FNAME(hw));
+			  FW_CFG_NAME_T5);
+		snprintf(path, 64, "%s%s", "/lib/firmware/", FW_CFG_NAME_T5);
 	}
 
 leave:
@@ -2123,9 +2098,9 @@ csio_hw_flash_fw(struct csio_hw *hw, int *reset)
 		return -EINVAL;
 	}
 
-	if (request_firmware(&fw, CSIO_FW_FNAME(hw), dev) < 0) {
+	if (request_firmware(&fw, FW_FNAME_T5, dev) < 0) {
 		csio_err(hw, "could not find firmware image %s, err: %d\n",
-			 CSIO_FW_FNAME(hw), ret);
+			 FW_FNAME_T5, ret);
 		return -EINVAL;
 	}
 
@@ -3207,7 +3182,7 @@ static void csio_ncsi_intr_handler(struct csio_hw *hw)
  */
 static void csio_xgmac_intr_handler(struct csio_hw *hw, int port)
 {
-	uint32_t v = csio_rd_reg32(hw, CSIO_MAC_INT_CAUSE_REG(hw, port));
+	uint32_t v = csio_rd_reg32(hw, T5_PORT_REG(port, MAC_PORT_INT_CAUSE_A));
 
 	v &= TXFIFO_PRTY_ERR_F | RXFIFO_PRTY_ERR_F;
 	if (!v)
@@ -3217,7 +3192,7 @@ static void csio_xgmac_intr_handler(struct csio_hw *hw, int port)
 		csio_fatal(hw, "XGMAC %d Tx FIFO parity error\n", port);
 	if (v & RXFIFO_PRTY_ERR_F)
 		csio_fatal(hw, "XGMAC %d Rx FIFO parity error\n", port);
-	csio_wr_reg32(hw, v, CSIO_MAC_INT_CAUSE_REG(hw, port));
+	csio_wr_reg32(hw, v, T5_PORT_REG(port, MAC_PORT_INT_CAUSE_A));
 	csio_hw_fatal_err(hw);
 }
 
@@ -3966,13 +3941,7 @@ csio_hw_set_description(struct csio_hw *hw, uint16_t ven_id, uint16_t dev_id)
 		prot_type = (dev_id & CSIO_ASIC_DEVID_PROTO_MASK);
 		adap_type = (dev_id & CSIO_ASIC_DEVID_TYPE_MASK);
 
-		if (prot_type == CSIO_T4_FCOE_ASIC) {
-			memcpy(hw->hw_ver,
-			       csio_t4_fcoe_adapters[adap_type].model_no, 16);
-			memcpy(hw->model_desc,
-			       csio_t4_fcoe_adapters[adap_type].description,
-			       32);
-		} else if (prot_type == CSIO_T5_FCOE_ASIC) {
+		if (prot_type == CSIO_T5_FCOE_ASIC) {
 			memcpy(hw->hw_ver,
 			       csio_t5_fcoe_adapters[adap_type].model_no, 16);
 			memcpy(hw->model_desc,
@@ -4009,8 +3978,8 @@ csio_hw_init(struct csio_hw *hw)
 
 	strcpy(hw->name, CSIO_HW_NAME);
 
-	/* Initialize the HW chip ops with T4/T5 specific ops */
-	hw->chip_ops = csio_is_t4(hw->chip_id) ? &t4_ops : &t5_ops;
+	/* Initialize the HW chip ops T5 specific ops */
+	hw->chip_ops = &t5_ops;
 
 	/* Set the model & its description */
 
diff --git a/drivers/scsi/csiostor/csio_hw_chip.h b/drivers/scsi/csiostor/csio_hw_chip.h
index eec98f5..e962d3d 100644
--- a/drivers/scsi/csiostor/csio_hw_chip.h
+++ b/drivers/scsi/csiostor/csio_hw_chip.h
@@ -37,24 +37,14 @@
 #include "csio_defs.h"
 
 /* Define MACRO values */
-#define CSIO_HW_T4				0x4000
-#define CSIO_T4_FCOE_ASIC			0x4600
 #define CSIO_HW_T5				0x5000
 #define CSIO_T5_FCOE_ASIC			0x5600
 #define CSIO_HW_CHIP_MASK			0xF000
 
-#define T4_REGMAP_SIZE				(160 * 1024)
 #define T5_REGMAP_SIZE				(332 * 1024)
-#define FW_FNAME_T4				"cxgb4/t4fw.bin"
 #define FW_FNAME_T5				"cxgb4/t5fw.bin"
-#define FW_CFG_NAME_T4				"cxgb4/t4-config.txt"
 #define FW_CFG_NAME_T5				"cxgb4/t5-config.txt"
 
-#define T4FW_VERSION_MAJOR 0x01
-#define T4FW_VERSION_MINOR 0x0B
-#define T4FW_VERSION_MICRO 0x1B
-#define T4FW_VERSION_BUILD 0x00
-
 #define T5FW_VERSION_MAJOR 0x01
 #define T5FW_VERSION_MINOR 0x0B
 #define T5FW_VERSION_MICRO 0x1B
@@ -65,27 +55,15 @@
 #define CHELSIO_CHIP_VERSION(code) (((code) >> 12) & 0xf)
 #define CHELSIO_CHIP_RELEASE(code) ((code) & 0xf)
 
-#define CHELSIO_T4		0x4
 #define CHELSIO_T5		0x5
 
 enum chip_type {
-	T4_A1 = CHELSIO_CHIP_CODE(CHELSIO_T4, 1),
-	T4_A2 = CHELSIO_CHIP_CODE(CHELSIO_T4, 2),
-	T4_FIRST_REV	= T4_A1,
-	T4_LAST_REV	= T4_A2,
-
 	T5_A0 = CHELSIO_CHIP_CODE(CHELSIO_T5, 0),
 	T5_A1 = CHELSIO_CHIP_CODE(CHELSIO_T5, 1),
 	T5_FIRST_REV	= T5_A0,
 	T5_LAST_REV	= T5_A1,
 };
 
-/* Define static functions */
-static inline int csio_is_t4(uint16_t chip)
-{
-	return (chip == CSIO_HW_T4);
-}
-
 static inline int csio_is_t5(uint16_t chip)
 {
 	return (chip == CSIO_HW_T5);
@@ -95,21 +73,6 @@ static inline int csio_is_t5(uint16_t chip)
 #define CSIO_DEVICE(devid, idx)						\
 	{ PCI_VENDOR_ID_CHELSIO, (devid), PCI_ANY_ID, PCI_ANY_ID, 0, 0, (idx) }
 
-#define CSIO_HW_PIDX(hw, index)						\
-	(csio_is_t4(hw->chip_id) ? (PIDX_V(index)) :			\
-					(PIDX_T5_G(index) | DBTYPE_F))
-
-#define CSIO_HW_LP_INT_THRESH(hw, val)					\
-	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH_V(val)) :		\
-					(LP_INT_THRESH_T5_V(val)))
-
-#define CSIO_HW_M_LP_INT_THRESH(hw)					\
-	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH_M) : (LP_INT_THRESH_T5_M))
-
-#define CSIO_MAC_INT_CAUSE_REG(hw, port)				\
-	(csio_is_t4(hw->chip_id) ? (PORT_REG(port, XGMAC_PORT_INT_CAUSE_A)) : \
-				(T5_PORT_REG(port, MAC_PORT_INT_CAUSE_A)))
-
 #include "t4fw_api.h"
 
 #define FW_VERSION(chip) ( \
@@ -125,11 +88,6 @@ struct fw_info {
 	char *fw_mod_name;
 	struct fw_hdr fw_hdr;
 };
-#define CSIO_FW_FNAME(hw)						\
-	(csio_is_t4(hw->chip_id) ? FW_FNAME_T4 : FW_FNAME_T5)
-
-#define CSIO_CF_FNAME(hw)						\
-	(csio_is_t4(hw->chip_id) ? FW_CFG_NAME_T4 : FW_CFG_NAME_T5)
 
 /* Declare ENUMS */
 enum { MEM_EDC0, MEM_EDC1, MEM_MC, MEM_MC0 = MEM_MC, MEM_MC1 };
@@ -163,7 +121,6 @@ struct csio_hw_chip_ops {
 	void (*chip_dfs_create_ext_mem)(struct csio_hw *);
 };
 
-extern struct csio_hw_chip_ops t4_ops;
 extern struct csio_hw_chip_ops t5_ops;
 
 #endif /* #ifndef __CSIO_HW_CHIP_H__ */
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index 34d20cc..9b9794d 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -1176,9 +1176,8 @@ static struct pci_error_handlers csio_err_handler = {
  */
 #define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
 	static struct pci_device_id csio_pci_tbl[] = {
-/* Define for iSCSI uses PF5, FCoE uses PF6 */
-#define CH_PCI_DEVICE_ID_FUNCTION	0x5
-#define CH_PCI_DEVICE_ID_FUNCTION2	0x6
+/* Define for FCoE uses PF6 */
+#define CH_PCI_DEVICE_ID_FUNCTION	0x6
 
 #define CH_PCI_ID_TABLE_ENTRY(devid) \
 		{ PCI_VDEVICE(CHELSIO, (devid)), 0 }
@@ -1256,5 +1255,4 @@ MODULE_DESCRIPTION(CSIO_DRV_DESC);
 MODULE_LICENSE(CSIO_DRV_LICENSE);
 MODULE_DEVICE_TABLE(pci, csio_pci_tbl);
 MODULE_VERSION(CSIO_DRV_VERSION);
-MODULE_FIRMWARE(FW_FNAME_T4);
 MODULE_FIRMWARE(FW_FNAME_T5);
diff --git a/drivers/scsi/csiostor/csio_wr.c b/drivers/scsi/csiostor/csio_wr.c
index b47ea33..e8f1817 100644
--- a/drivers/scsi/csiostor/csio_wr.c
+++ b/drivers/scsi/csiostor/csio_wr.c
@@ -85,7 +85,7 @@ csio_wr_ring_fldb(struct csio_hw *hw, struct csio_q *flq)
 	 */
 	if (flq->inc_idx >= 8) {
 		csio_wr_reg32(hw, DBPRIO_F | QID_V(flq->un.fl.flid) |
-				  CSIO_HW_PIDX(hw, flq->inc_idx / 8),
+				  PIDX_T5_V(flq->inc_idx / 8) | DBTYPE_F,
 				  MYPF_REG(SGE_PF_KDOORBELL_A));
 		flq->inc_idx &= 7;
 	}
@@ -983,7 +983,7 @@ csio_wr_issue(struct csio_hw *hw, int qidx, bool prio)
 	wmb();
 	/* Ring SGE Doorbell writing q->pidx into it */
 	csio_wr_reg32(hw, DBPRIO_V(prio) | QID_V(q->un.eq.physeqid) |
-			  CSIO_HW_PIDX(hw, q->inc_idx),
+			  PIDX_T5_V(q->inc_idx) | DBTYPE_F,
 			  MYPF_REG(SGE_PF_KDOORBELL_A));
 	q->inc_idx = 0;
 
@@ -1467,12 +1467,11 @@ csio_wr_set_sge(struct csio_hw *hw)
 	 * and generate an interrupt when this occurs so we can recover.
 	 */
 	csio_set_reg_field(hw, SGE_DBFIFO_STATUS_A,
-			   HP_INT_THRESH_V(HP_INT_THRESH_M) |
-			   CSIO_HW_LP_INT_THRESH(hw,
-						 CSIO_HW_M_LP_INT_THRESH(hw)),
-			   HP_INT_THRESH_V(CSIO_SGE_DBFIFO_INT_THRESH) |
-			   CSIO_HW_LP_INT_THRESH(hw,
-						 CSIO_SGE_DBFIFO_INT_THRESH));
+			   LP_INT_THRESH_T5_V(LP_INT_THRESH_T5_M),
+			   LP_INT_THRESH_T5_V(CSIO_SGE_DBFIFO_INT_THRESH));
+	csio_set_reg_field(hw, SGE_DBFIFO_STATUS2_A,
+			   HP_INT_THRESH_T5_V(LP_INT_THRESH_T5_M),
+			   HP_INT_THRESH_T5_V(CSIO_SGE_DBFIFO_INT_THRESH));
 
 	csio_set_reg_field(hw, SGE_DOORBELL_CONTROL_A, ENABLE_DROP_F,
 			   ENABLE_DROP_F);
-- 
2.0.2
