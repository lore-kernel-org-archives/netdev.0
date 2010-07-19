From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/qlge: Use pr_<level>, shrink text a
 bit
Date: Mon, 19 Jul 2010 14:49:08 -0700
Message-ID: <1279576149.5434.59.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add and use a few neatening macros
Remove PFX
Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Convert printk(KERN_ERR to pr_err(

$ size drivers/net/qlge/built-in.o.*
  text	   data	    bss	    dec	    hex	filename
 116456	   2312	  25712	 144480	  23460	drivers/net/qlge/built-in.o.old
 114909	   2312	  25728	 142949	  22e65	drivers/net/qlge/built-in.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qlge/qlge.h     |    2 -
 drivers/net/qlge/qlge_dbg.c |  809 +++++++++++++++++--------------------------
 2 files changed, 320 insertions(+), 491 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 06b2188..a478786 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -18,8 +18,6 @@
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
 #define DRV_VERSION	"v1.00.00.25.00.00-01"
 
-#define PFX "qlge: "
-
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
 #define QLGE_VENDOR_ID    0x1077
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 548e901..9d9498b 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 
 #include "qlge.h"
@@ -446,7 +448,7 @@ static int ql_get_cam_entries(struct ql_adapter *qdev, u32 * buf)
 					MAC_ADDR_TYPE_CAM_MAC, i, value);
 		if (status) {
 			netif_err(qdev, drv, qdev->ndev,
-				  "Failed read of mac index register.\n");
+				  "Failed read of mac index register\n");
 			goto err;
 		}
 		*buf++ = value[0];	/* lower MAC address */
@@ -458,7 +460,7 @@ static int ql_get_cam_entries(struct ql_adapter *qdev, u32 * buf)
 					MAC_ADDR_TYPE_MULTI_MAC, i, value);
 		if (status) {
 			netif_err(qdev, drv, qdev->ndev,
-				  "Failed read of mac index register.\n");
+				  "Failed read of mac index register\n");
 			goto err;
 		}
 		*buf++ = value[0];	/* lower Mcast address */
@@ -482,7 +484,7 @@ static int ql_get_routing_entries(struct ql_adapter *qdev, u32 * buf)
 		status = ql_get_routing_reg(qdev, i, &value);
 		if (status) {
 			netif_err(qdev, drv, qdev->ndev,
-				  "Failed read of routing index register.\n");
+				  "Failed read of routing index register\n");
 			goto err;
 		} else {
 			*buf++ = value;
@@ -668,7 +670,7 @@ static void ql_get_mac_protocol_registers(struct ql_adapter *qdev, u32 *buf)
 			max_offset = MAC_ADDR_MAX_MGMT_TU_DP_WCOUNT;
 			break;
 		default:
-			printk(KERN_ERR"Bad type!!! 0x%08x\n", type);
+			pr_err("Bad type!!! 0x%08x\n", type);
 			max_index = 0;
 			max_offset = 0;
 			break;
@@ -738,7 +740,7 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	int i;
 
 	if (!mpi_coredump) {
-		netif_err(qdev, drv, qdev->ndev, "No memory available.\n");
+		netif_err(qdev, drv, qdev->ndev, "No memory available\n");
 		return -ENOMEM;
 	}
 
@@ -1234,7 +1236,7 @@ static void ql_get_core_dump(struct ql_adapter *qdev)
 
 	if (!netif_running(qdev->ndev)) {
 		netif_err(qdev, ifup, qdev->ndev,
-			  "Force Coredump can only be done from interface that is up.\n");
+			  "Force Coredump can only be done from interface that is up\n");
 		return;
 	}
 	ql_queue_fw_error(qdev);
@@ -1334,7 +1336,7 @@ void ql_mpi_core_to_log(struct work_struct *work)
 		     "Core is dumping to log file!\n");
 
 	for (i = 0; i < count; i += 8) {
-		printk(KERN_ERR "%.08x: %.08x %.08x %.08x %.08x %.08x "
+		pr_err("%.08x: %.08x %.08x %.08x %.08x %.08x "
 			"%.08x %.08x %.08x\n", i,
 			tmp[i + 0],
 			tmp[i + 1],
@@ -1356,71 +1358,43 @@ static void ql_dump_intr_states(struct ql_adapter *qdev)
 	for (i = 0; i < qdev->intr_count; i++) {
 		ql_write32(qdev, INTR_EN, qdev->intr_context[i].intr_read_mask);
 		value = ql_read32(qdev, INTR_EN);
-		printk(KERN_ERR PFX
-		       "%s: Interrupt %d is %s.\n",
+		pr_err("%s: Interrupt %d is %s\n",
 		       qdev->ndev->name, i,
 		       (value & INTR_EN_EN ? "enabled" : "disabled"));
 	}
 }
 
+#define DUMP_XGMAC(qdev, reg)					\
+do {								\
+	u32 data;						\
+	ql_read_xgmac_reg(qdev, reg, &data);			\
+	pr_err("%s: %s = 0x%.08x\n", qdev->ndev->name, #reg, data); \
+} while (0)
+
 void ql_dump_xgmac_control_regs(struct ql_adapter *qdev)
 {
-	u32 data;
 	if (ql_sem_spinlock(qdev, qdev->xg_sem_mask)) {
-		printk(KERN_ERR "%s: Couldn't get xgmac sem.\n", __func__);
+		pr_err("%s: Couldn't get xgmac sem\n", __func__);
 		return;
 	}
-	ql_read_xgmac_reg(qdev, PAUSE_SRC_LO, &data);
-	printk(KERN_ERR PFX "%s: PAUSE_SRC_LO = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, PAUSE_SRC_HI, &data);
-	printk(KERN_ERR PFX "%s: PAUSE_SRC_HI = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, GLOBAL_CFG, &data);
-	printk(KERN_ERR PFX "%s: GLOBAL_CFG = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, TX_CFG, &data);
-	printk(KERN_ERR PFX "%s: TX_CFG = 0x%.08x.\n", qdev->ndev->name, data);
-	ql_read_xgmac_reg(qdev, RX_CFG, &data);
-	printk(KERN_ERR PFX "%s: RX_CFG = 0x%.08x.\n", qdev->ndev->name, data);
-	ql_read_xgmac_reg(qdev, FLOW_CTL, &data);
-	printk(KERN_ERR PFX "%s: FLOW_CTL = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, PAUSE_OPCODE, &data);
-	printk(KERN_ERR PFX "%s: PAUSE_OPCODE = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, PAUSE_TIMER, &data);
-	printk(KERN_ERR PFX "%s: PAUSE_TIMER = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, PAUSE_FRM_DEST_LO, &data);
-	printk(KERN_ERR PFX "%s: PAUSE_FRM_DEST_LO = 0x%.08x.\n",
-	       qdev->ndev->name, data);
-	ql_read_xgmac_reg(qdev, PAUSE_FRM_DEST_HI, &data);
-	printk(KERN_ERR PFX "%s: PAUSE_FRM_DEST_HI = 0x%.08x.\n",
-	       qdev->ndev->name, data);
-	ql_read_xgmac_reg(qdev, MAC_TX_PARAMS, &data);
-	printk(KERN_ERR PFX "%s: MAC_TX_PARAMS = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, MAC_RX_PARAMS, &data);
-	printk(KERN_ERR PFX "%s: MAC_RX_PARAMS = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, MAC_SYS_INT, &data);
-	printk(KERN_ERR PFX "%s: MAC_SYS_INT = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, MAC_SYS_INT_MASK, &data);
-	printk(KERN_ERR PFX "%s: MAC_SYS_INT_MASK = 0x%.08x.\n",
-	       qdev->ndev->name, data);
-	ql_read_xgmac_reg(qdev, MAC_MGMT_INT, &data);
-	printk(KERN_ERR PFX "%s: MAC_MGMT_INT = 0x%.08x.\n", qdev->ndev->name,
-	       data);
-	ql_read_xgmac_reg(qdev, MAC_MGMT_IN_MASK, &data);
-	printk(KERN_ERR PFX "%s: MAC_MGMT_IN_MASK = 0x%.08x.\n",
-	       qdev->ndev->name, data);
-	ql_read_xgmac_reg(qdev, EXT_ARB_MODE, &data);
-	printk(KERN_ERR PFX "%s: EXT_ARB_MODE = 0x%.08x.\n", qdev->ndev->name,
-	       data);
+	DUMP_XGMAC(qdev, PAUSE_SRC_LO);
+	DUMP_XGMAC(qdev, PAUSE_SRC_HI);
+	DUMP_XGMAC(qdev, GLOBAL_CFG);
+	DUMP_XGMAC(qdev, TX_CFG);
+	DUMP_XGMAC(qdev, RX_CFG);
+	DUMP_XGMAC(qdev, FLOW_CTL);
+	DUMP_XGMAC(qdev, PAUSE_OPCODE);
+	DUMP_XGMAC(qdev, PAUSE_TIMER);
+	DUMP_XGMAC(qdev, PAUSE_FRM_DEST_LO);
+	DUMP_XGMAC(qdev, PAUSE_FRM_DEST_HI);
+	DUMP_XGMAC(qdev, MAC_TX_PARAMS);
+	DUMP_XGMAC(qdev, MAC_RX_PARAMS);
+	DUMP_XGMAC(qdev, MAC_SYS_INT);
+	DUMP_XGMAC(qdev, MAC_SYS_INT_MASK);
+	DUMP_XGMAC(qdev, MAC_MGMT_INT);
+	DUMP_XGMAC(qdev, MAC_MGMT_IN_MASK);
+	DUMP_XGMAC(qdev, EXT_ARB_MODE);
 	ql_sem_unlock(qdev, qdev->xg_sem_mask);
-
 }
 
 static void ql_dump_ets_regs(struct ql_adapter *qdev)
@@ -1437,14 +1411,12 @@ static void ql_dump_cam_entries(struct ql_adapter *qdev)
 		return;
 	for (i = 0; i < 4; i++) {
 		if (ql_get_mac_addr_reg(qdev, MAC_ADDR_TYPE_CAM_MAC, i, value)) {
-			printk(KERN_ERR PFX
-			       "%s: Failed read of mac index register.\n",
+			pr_err("%s: Failed read of mac index register\n",
 			       __func__);
 			return;
 		} else {
 			if (value[0])
-				printk(KERN_ERR PFX
-				       "%s: CAM index %d CAM Lookup Lower = 0x%.08x:%.08x, Output = 0x%.08x.\n",
+				pr_err("%s: CAM index %d CAM Lookup Lower = 0x%.08x:%.08x, Output = 0x%.08x\n",
 				       qdev->ndev->name, i, value[1], value[0],
 				       value[2]);
 		}
@@ -1452,14 +1424,12 @@ static void ql_dump_cam_entries(struct ql_adapter *qdev)
 	for (i = 0; i < 32; i++) {
 		if (ql_get_mac_addr_reg
 		    (qdev, MAC_ADDR_TYPE_MULTI_MAC, i, value)) {
-			printk(KERN_ERR PFX
-			       "%s: Failed read of mac index register.\n",
+			pr_err("%s: Failed read of mac index register\n",
 			       __func__);
 			return;
 		} else {
 			if (value[0])
-				printk(KERN_ERR PFX
-				       "%s: MCAST index %d CAM Lookup Lower = 0x%.08x:%.08x.\n",
+				pr_err("%s: MCAST index %d CAM Lookup Lower = 0x%.08x:%.08x\n",
 				       qdev->ndev->name, i, value[1], value[0]);
 		}
 	}
@@ -1476,129 +1446,78 @@ void ql_dump_routing_entries(struct ql_adapter *qdev)
 	for (i = 0; i < 16; i++) {
 		value = 0;
 		if (ql_get_routing_reg(qdev, i, &value)) {
-			printk(KERN_ERR PFX
-			       "%s: Failed read of routing index register.\n",
+			pr_err("%s: Failed read of routing index register\n",
 			       __func__);
 			return;
 		} else {
 			if (value)
-				printk(KERN_ERR PFX
-				       "%s: Routing Mask %d = 0x%.08x.\n",
+				pr_err("%s: Routing Mask %d = 0x%.08x\n",
 				       qdev->ndev->name, i, value);
 		}
 	}
 	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 }
 
+#define DUMP_REG(qdev, reg)			\
+	pr_err("%-32s= 0x%x\n", #reg, ql_read32(qdev, reg))
+
 void ql_dump_regs(struct ql_adapter *qdev)
 {
-	printk(KERN_ERR PFX "reg dump for function #%d.\n", qdev->func);
-	printk(KERN_ERR PFX "SYS	 			= 0x%x.\n",
-	       ql_read32(qdev, SYS));
-	printk(KERN_ERR PFX "RST_FO 			= 0x%x.\n",
-	       ql_read32(qdev, RST_FO));
-	printk(KERN_ERR PFX "FSC 				= 0x%x.\n",
-	       ql_read32(qdev, FSC));
-	printk(KERN_ERR PFX "CSR 				= 0x%x.\n",
-	       ql_read32(qdev, CSR));
-	printk(KERN_ERR PFX "ICB_RID 			= 0x%x.\n",
-	       ql_read32(qdev, ICB_RID));
-	printk(KERN_ERR PFX "ICB_L 				= 0x%x.\n",
-	       ql_read32(qdev, ICB_L));
-	printk(KERN_ERR PFX "ICB_H 				= 0x%x.\n",
-	       ql_read32(qdev, ICB_H));
-	printk(KERN_ERR PFX "CFG 				= 0x%x.\n",
-	       ql_read32(qdev, CFG));
-	printk(KERN_ERR PFX "BIOS_ADDR 			= 0x%x.\n",
-	       ql_read32(qdev, BIOS_ADDR));
-	printk(KERN_ERR PFX "STS 				= 0x%x.\n",
-	       ql_read32(qdev, STS));
-	printk(KERN_ERR PFX "INTR_EN			= 0x%x.\n",
-	       ql_read32(qdev, INTR_EN));
-	printk(KERN_ERR PFX "INTR_MASK 			= 0x%x.\n",
-	       ql_read32(qdev, INTR_MASK));
-	printk(KERN_ERR PFX "ISR1 				= 0x%x.\n",
-	       ql_read32(qdev, ISR1));
-	printk(KERN_ERR PFX "ISR2 				= 0x%x.\n",
-	       ql_read32(qdev, ISR2));
-	printk(KERN_ERR PFX "ISR3 				= 0x%x.\n",
-	       ql_read32(qdev, ISR3));
-	printk(KERN_ERR PFX "ISR4 				= 0x%x.\n",
-	       ql_read32(qdev, ISR4));
-	printk(KERN_ERR PFX "REV_ID 			= 0x%x.\n",
-	       ql_read32(qdev, REV_ID));
-	printk(KERN_ERR PFX "FRC_ECC_ERR 			= 0x%x.\n",
-	       ql_read32(qdev, FRC_ECC_ERR));
-	printk(KERN_ERR PFX "ERR_STS 			= 0x%x.\n",
-	       ql_read32(qdev, ERR_STS));
-	printk(KERN_ERR PFX "RAM_DBG_ADDR 			= 0x%x.\n",
-	       ql_read32(qdev, RAM_DBG_ADDR));
-	printk(KERN_ERR PFX "RAM_DBG_DATA 			= 0x%x.\n",
-	       ql_read32(qdev, RAM_DBG_DATA));
-	printk(KERN_ERR PFX "ECC_ERR_CNT 			= 0x%x.\n",
-	       ql_read32(qdev, ECC_ERR_CNT));
-	printk(KERN_ERR PFX "SEM 				= 0x%x.\n",
-	       ql_read32(qdev, SEM));
-	printk(KERN_ERR PFX "GPIO_1 			= 0x%x.\n",
-	       ql_read32(qdev, GPIO_1));
-	printk(KERN_ERR PFX "GPIO_2 			= 0x%x.\n",
-	       ql_read32(qdev, GPIO_2));
-	printk(KERN_ERR PFX "GPIO_3 			= 0x%x.\n",
-	       ql_read32(qdev, GPIO_3));
-	printk(KERN_ERR PFX "XGMAC_ADDR 			= 0x%x.\n",
-	       ql_read32(qdev, XGMAC_ADDR));
-	printk(KERN_ERR PFX "XGMAC_DATA 			= 0x%x.\n",
-	       ql_read32(qdev, XGMAC_DATA));
-	printk(KERN_ERR PFX "NIC_ETS 			= 0x%x.\n",
-	       ql_read32(qdev, NIC_ETS));
-	printk(KERN_ERR PFX "CNA_ETS 			= 0x%x.\n",
-	       ql_read32(qdev, CNA_ETS));
-	printk(KERN_ERR PFX "FLASH_ADDR 			= 0x%x.\n",
-	       ql_read32(qdev, FLASH_ADDR));
-	printk(KERN_ERR PFX "FLASH_DATA 			= 0x%x.\n",
-	       ql_read32(qdev, FLASH_DATA));
-	printk(KERN_ERR PFX "CQ_STOP 			= 0x%x.\n",
-	       ql_read32(qdev, CQ_STOP));
-	printk(KERN_ERR PFX "PAGE_TBL_RID 			= 0x%x.\n",
-	       ql_read32(qdev, PAGE_TBL_RID));
-	printk(KERN_ERR PFX "WQ_PAGE_TBL_LO 		= 0x%x.\n",
-	       ql_read32(qdev, WQ_PAGE_TBL_LO));
-	printk(KERN_ERR PFX "WQ_PAGE_TBL_HI 		= 0x%x.\n",
-	       ql_read32(qdev, WQ_PAGE_TBL_HI));
-	printk(KERN_ERR PFX "CQ_PAGE_TBL_LO 		= 0x%x.\n",
-	       ql_read32(qdev, CQ_PAGE_TBL_LO));
-	printk(KERN_ERR PFX "CQ_PAGE_TBL_HI 		= 0x%x.\n",
-	       ql_read32(qdev, CQ_PAGE_TBL_HI));
-	printk(KERN_ERR PFX "COS_DFLT_CQ1 			= 0x%x.\n",
-	       ql_read32(qdev, COS_DFLT_CQ1));
-	printk(KERN_ERR PFX "COS_DFLT_CQ2 			= 0x%x.\n",
-	       ql_read32(qdev, COS_DFLT_CQ2));
-	printk(KERN_ERR PFX "SPLT_HDR 			= 0x%x.\n",
-	       ql_read32(qdev, SPLT_HDR));
-	printk(KERN_ERR PFX "FC_PAUSE_THRES 		= 0x%x.\n",
-	       ql_read32(qdev, FC_PAUSE_THRES));
-	printk(KERN_ERR PFX "NIC_PAUSE_THRES 		= 0x%x.\n",
-	       ql_read32(qdev, NIC_PAUSE_THRES));
-	printk(KERN_ERR PFX "FC_ETHERTYPE 			= 0x%x.\n",
-	       ql_read32(qdev, FC_ETHERTYPE));
-	printk(KERN_ERR PFX "FC_RCV_CFG 			= 0x%x.\n",
-	       ql_read32(qdev, FC_RCV_CFG));
-	printk(KERN_ERR PFX "NIC_RCV_CFG 			= 0x%x.\n",
-	       ql_read32(qdev, NIC_RCV_CFG));
-	printk(KERN_ERR PFX "FC_COS_TAGS 			= 0x%x.\n",
-	       ql_read32(qdev, FC_COS_TAGS));
-	printk(KERN_ERR PFX "NIC_COS_TAGS 			= 0x%x.\n",
-	       ql_read32(qdev, NIC_COS_TAGS));
-	printk(KERN_ERR PFX "MGMT_RCV_CFG 			= 0x%x.\n",
-	       ql_read32(qdev, MGMT_RCV_CFG));
-	printk(KERN_ERR PFX "XG_SERDES_ADDR 		= 0x%x.\n",
-	       ql_read32(qdev, XG_SERDES_ADDR));
-	printk(KERN_ERR PFX "XG_SERDES_DATA 		= 0x%x.\n",
-	       ql_read32(qdev, XG_SERDES_DATA));
-	printk(KERN_ERR PFX "PRB_MX_ADDR 			= 0x%x.\n",
-	       ql_read32(qdev, PRB_MX_ADDR));
-	printk(KERN_ERR PFX "PRB_MX_DATA 			= 0x%x.\n",
-	       ql_read32(qdev, PRB_MX_DATA));
+	pr_err("reg dump for function #%d\n", qdev->func);
+	DUMP_REG(qdev, SYS);
+	DUMP_REG(qdev, SYS);
+	DUMP_REG(qdev, RST_FO);
+	DUMP_REG(qdev, FSC);
+	DUMP_REG(qdev, CSR);
+	DUMP_REG(qdev, ICB_RID);
+	DUMP_REG(qdev, ICB_L);
+	DUMP_REG(qdev, ICB_H);
+	DUMP_REG(qdev, CFG);
+	DUMP_REG(qdev, BIOS_ADDR);
+	DUMP_REG(qdev, STS);
+	DUMP_REG(qdev, INTR_EN);
+	DUMP_REG(qdev, INTR_MASK);
+	DUMP_REG(qdev, ISR1);
+	DUMP_REG(qdev, ISR2);
+	DUMP_REG(qdev, ISR3);
+	DUMP_REG(qdev, ISR4);
+	DUMP_REG(qdev, REV_ID);
+	DUMP_REG(qdev, FRC_ECC_ERR);
+	DUMP_REG(qdev, ERR_STS);
+	DUMP_REG(qdev, RAM_DBG_ADDR);
+	DUMP_REG(qdev, RAM_DBG_DATA);
+	DUMP_REG(qdev, ECC_ERR_CNT);
+	DUMP_REG(qdev, SEM);
+	DUMP_REG(qdev, GPIO_1);
+	DUMP_REG(qdev, GPIO_2);
+	DUMP_REG(qdev, GPIO_3);
+	DUMP_REG(qdev, XGMAC_ADDR);
+	DUMP_REG(qdev, XGMAC_DATA);
+	DUMP_REG(qdev, NIC_ETS);
+	DUMP_REG(qdev, CNA_ETS);
+	DUMP_REG(qdev, FLASH_ADDR);
+	DUMP_REG(qdev, FLASH_DATA);
+	DUMP_REG(qdev, CQ_STOP);
+	DUMP_REG(qdev, PAGE_TBL_RID);
+	DUMP_REG(qdev, WQ_PAGE_TBL_LO);
+	DUMP_REG(qdev, WQ_PAGE_TBL_HI);
+	DUMP_REG(qdev, CQ_PAGE_TBL_LO);
+	DUMP_REG(qdev, CQ_PAGE_TBL_HI);
+	DUMP_REG(qdev, COS_DFLT_CQ1);
+	DUMP_REG(qdev, COS_DFLT_CQ2);
+	DUMP_REG(qdev, SPLT_HDR);
+	DUMP_REG(qdev, FC_PAUSE_THRES);
+	DUMP_REG(qdev, NIC_PAUSE_THRES);
+	DUMP_REG(qdev, FC_ETHERTYPE);
+	DUMP_REG(qdev, FC_RCV_CFG);
+	DUMP_REG(qdev, NIC_RCV_CFG);
+	DUMP_REG(qdev, FC_COS_TAGS);
+	DUMP_REG(qdev, NIC_COS_TAGS);
+	DUMP_REG(qdev, MGMT_RCV_CFG);
+	DUMP_REG(qdev, XG_SERDES_ADDR);
+	DUMP_REG(qdev, XG_SERDES_DATA);
+	DUMP_REG(qdev, PRB_MX_ADDR);
+	DUMP_REG(qdev, PRB_MX_DATA);
 	ql_dump_intr_states(qdev);
 	ql_dump_xgmac_control_regs(qdev);
 	ql_dump_ets_regs(qdev);
@@ -1608,191 +1527,125 @@ void ql_dump_regs(struct ql_adapter *qdev)
 #endif
 
 #ifdef QL_STAT_DUMP
+
+#define DUMP_STAT(qdev, stat)	\
+	pr_err("%s = %ld\n", #stat, (unsigned long)qdev->nic_stats.stat)
+
 void ql_dump_stat(struct ql_adapter *qdev)
 {
-	printk(KERN_ERR "%s: Enter.\n", __func__);
-	printk(KERN_ERR "tx_pkts = %ld\n",
-	       (unsigned long)qdev->nic_stats.tx_pkts);
-	printk(KERN_ERR "tx_bytes = %ld\n",
-	       (unsigned long)qdev->nic_stats.tx_bytes);
-	printk(KERN_ERR "tx_mcast_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_mcast_pkts);
-	printk(KERN_ERR "tx_bcast_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_bcast_pkts);
-	printk(KERN_ERR "tx_ucast_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_ucast_pkts);
-	printk(KERN_ERR "tx_ctl_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_ctl_pkts);
-	printk(KERN_ERR "tx_pause_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_pause_pkts);
-	printk(KERN_ERR "tx_64_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_64_pkt);
-	printk(KERN_ERR "tx_65_to_127_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_65_to_127_pkt);
-	printk(KERN_ERR "tx_128_to_255_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_128_to_255_pkt);
-	printk(KERN_ERR "tx_256_511_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_256_511_pkt);
-	printk(KERN_ERR "tx_512_to_1023_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_512_to_1023_pkt);
-	printk(KERN_ERR "tx_1024_to_1518_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_1024_to_1518_pkt);
-	printk(KERN_ERR "tx_1519_to_max_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_1519_to_max_pkt);
-	printk(KERN_ERR "tx_undersize_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_undersize_pkt);
-	printk(KERN_ERR "tx_oversize_pkt = %ld.\n",
-	       (unsigned long)qdev->nic_stats.tx_oversize_pkt);
-	printk(KERN_ERR "rx_bytes = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_bytes);
-	printk(KERN_ERR "rx_bytes_ok = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_bytes_ok);
-	printk(KERN_ERR "rx_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_pkts);
-	printk(KERN_ERR "rx_pkts_ok = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_pkts_ok);
-	printk(KERN_ERR "rx_bcast_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_bcast_pkts);
-	printk(KERN_ERR "rx_mcast_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_mcast_pkts);
-	printk(KERN_ERR "rx_ucast_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_ucast_pkts);
-	printk(KERN_ERR "rx_undersize_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_undersize_pkts);
-	printk(KERN_ERR "rx_oversize_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_oversize_pkts);
-	printk(KERN_ERR "rx_jabber_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_jabber_pkts);
-	printk(KERN_ERR "rx_undersize_fcerr_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_undersize_fcerr_pkts);
-	printk(KERN_ERR "rx_drop_events = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_drop_events);
-	printk(KERN_ERR "rx_fcerr_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_fcerr_pkts);
-	printk(KERN_ERR "rx_align_err = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_align_err);
-	printk(KERN_ERR "rx_symbol_err = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_symbol_err);
-	printk(KERN_ERR "rx_mac_err = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_mac_err);
-	printk(KERN_ERR "rx_ctl_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_ctl_pkts);
-	printk(KERN_ERR "rx_pause_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_pause_pkts);
-	printk(KERN_ERR "rx_64_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_64_pkts);
-	printk(KERN_ERR "rx_65_to_127_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_65_to_127_pkts);
-	printk(KERN_ERR "rx_128_255_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_128_255_pkts);
-	printk(KERN_ERR "rx_256_511_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_256_511_pkts);
-	printk(KERN_ERR "rx_512_to_1023_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_512_to_1023_pkts);
-	printk(KERN_ERR "rx_1024_to_1518_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_1024_to_1518_pkts);
-	printk(KERN_ERR "rx_1519_to_max_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_1519_to_max_pkts);
-	printk(KERN_ERR "rx_len_err_pkts = %ld.\n",
-	       (unsigned long)qdev->nic_stats.rx_len_err_pkts);
+	pr_err("%s: Enter\n", __func__);
+	DUMP_STAT(qdev, tx_pkts);
+	DUMP_STAT(qdev, tx_pkts);
+	DUMP_STAT(qdev, tx_bytes);
+	DUMP_STAT(qdev, tx_mcast_pkts);
+	DUMP_STAT(qdev, tx_bcast_pkts);
+	DUMP_STAT(qdev, tx_ucast_pkts);
+	DUMP_STAT(qdev, tx_ctl_pkts);
+	DUMP_STAT(qdev, tx_pause_pkts);
+	DUMP_STAT(qdev, tx_64_pkt);
+	DUMP_STAT(qdev, tx_65_to_127_pkt);
+	DUMP_STAT(qdev, tx_128_to_255_pkt);
+	DUMP_STAT(qdev, tx_256_511_pkt);
+	DUMP_STAT(qdev, tx_512_to_1023_pkt);
+	DUMP_STAT(qdev, tx_1024_to_1518_pkt);
+	DUMP_STAT(qdev, tx_1519_to_max_pkt);
+	DUMP_STAT(qdev, tx_undersize_pkt);
+	DUMP_STAT(qdev, tx_oversize_pkt);
+	DUMP_STAT(qdev, rx_bytes);
+	DUMP_STAT(qdev, rx_bytes_ok);
+	DUMP_STAT(qdev, rx_pkts);
+	DUMP_STAT(qdev, rx_pkts_ok);
+	DUMP_STAT(qdev, rx_bcast_pkts);
+	DUMP_STAT(qdev, rx_mcast_pkts);
+	DUMP_STAT(qdev, rx_ucast_pkts);
+	DUMP_STAT(qdev, rx_undersize_pkts);
+	DUMP_STAT(qdev, rx_oversize_pkts);
+	DUMP_STAT(qdev, rx_jabber_pkts);
+	DUMP_STAT(qdev, rx_undersize_fcerr_pkts);
+	DUMP_STAT(qdev, rx_drop_events);
+	DUMP_STAT(qdev, rx_fcerr_pkts);
+	DUMP_STAT(qdev, rx_align_err);
+	DUMP_STAT(qdev, rx_symbol_err);
+	DUMP_STAT(qdev, rx_mac_err);
+	DUMP_STAT(qdev, rx_ctl_pkts);
+	DUMP_STAT(qdev, rx_pause_pkts);
+	DUMP_STAT(qdev, rx_64_pkts);
+	DUMP_STAT(qdev, rx_65_to_127_pkts);
+	DUMP_STAT(qdev, rx_128_255_pkts);
+	DUMP_STAT(qdev, rx_256_511_pkts);
+	DUMP_STAT(qdev, rx_512_to_1023_pkts);
+	DUMP_STAT(qdev, rx_1024_to_1518_pkts);
+	DUMP_STAT(qdev, rx_1519_to_max_pkts);
+	DUMP_STAT(qdev, rx_len_err_pkts);
 };
 #endif
 
 #ifdef QL_DEV_DUMP
+
+#define DUMP_QDEV_FIELD(qdev, type, field)		\
+	pr_err("qdev->%-24s = " type "\n", #field, qdev->field)
+#define DUMP_QDEV_DMA_FIELD(qdev, field)		\
+	pr_err("qdev->%-24s = %llx\n", #field, (unsigned long long)qdev->field)
+#define DUMP_QDEV_ARRAY(qdev, type, array, index, field) \
+	pr_err("%s[%d].%s = " type "\n",		 \
+	       #array, index, #field, qdev->array[index].field);
 void ql_dump_qdev(struct ql_adapter *qdev)
 {
 	int i;
-	printk(KERN_ERR PFX "qdev->flags 			= %lx.\n",
-	       qdev->flags);
-	printk(KERN_ERR PFX "qdev->vlgrp 			= %p.\n",
-	       qdev->vlgrp);
-	printk(KERN_ERR PFX "qdev->pdev 			= %p.\n",
-	       qdev->pdev);
-	printk(KERN_ERR PFX "qdev->ndev 			= %p.\n",
-	       qdev->ndev);
-	printk(KERN_ERR PFX "qdev->chip_rev_id 		= %d.\n",
-	       qdev->chip_rev_id);
-	printk(KERN_ERR PFX "qdev->reg_base 		= %p.\n",
-	       qdev->reg_base);
-	printk(KERN_ERR PFX "qdev->doorbell_area 	= %p.\n",
-	       qdev->doorbell_area);
-	printk(KERN_ERR PFX "qdev->doorbell_area_size 	= %d.\n",
-	       qdev->doorbell_area_size);
-	printk(KERN_ERR PFX "msg_enable 		= %x.\n",
-	       qdev->msg_enable);
-	printk(KERN_ERR PFX "qdev->rx_ring_shadow_reg_area	= %p.\n",
-	       qdev->rx_ring_shadow_reg_area);
-	printk(KERN_ERR PFX "qdev->rx_ring_shadow_reg_dma 	= %llx.\n",
-	       (unsigned long long) qdev->rx_ring_shadow_reg_dma);
-	printk(KERN_ERR PFX "qdev->tx_ring_shadow_reg_area	= %p.\n",
-	       qdev->tx_ring_shadow_reg_area);
-	printk(KERN_ERR PFX "qdev->tx_ring_shadow_reg_dma	= %llx.\n",
-	       (unsigned long long) qdev->tx_ring_shadow_reg_dma);
-	printk(KERN_ERR PFX "qdev->intr_count 		= %d.\n",
-	       qdev->intr_count);
+	DUMP_QDEV_FIELD(qdev, "%lx", flags);
+	DUMP_QDEV_FIELD(qdev, "%p", vlgrp);
+	DUMP_QDEV_FIELD(qdev, "%p", pdev);
+	DUMP_QDEV_FIELD(qdev, "%p", ndev);
+	DUMP_QDEV_FIELD(qdev, "%d", chip_rev_id);
+	DUMP_QDEV_FIELD(qdev, "%p", reg_base);
+	DUMP_QDEV_FIELD(qdev, "%p", doorbell_area);
+	DUMP_QDEV_FIELD(qdev, "%d", doorbell_area_size);
+	DUMP_QDEV_FIELD(qdev, "%x", msg_enable);
+	DUMP_QDEV_FIELD(qdev, "%p", rx_ring_shadow_reg_area);
+	DUMP_QDEV_DMA_FIELD(qdev, rx_ring_shadow_reg_dma);
+	DUMP_QDEV_FIELD(qdev, "%p", tx_ring_shadow_reg_area);
+	DUMP_QDEV_DMA_FIELD(qdev, tx_ring_shadow_reg_dma);
+	DUMP_QDEV_FIELD(qdev, "%d", intr_count);
 	if (qdev->msi_x_entry)
 		for (i = 0; i < qdev->intr_count; i++) {
-			printk(KERN_ERR PFX
-			       "msi_x_entry.[%d]vector	= %d.\n", i,
-			       qdev->msi_x_entry[i].vector);
-			printk(KERN_ERR PFX
-			       "msi_x_entry.[%d]entry	= %d.\n", i,
-			       qdev->msi_x_entry[i].entry);
+			DUMP_QDEV_ARRAY(qdev, "%d", msi_x_entry, i, vector);
+			DUMP_QDEV_ARRAY(qdev, "%d", msi_x_entry, i, entry);
 		}
 	for (i = 0; i < qdev->intr_count; i++) {
-		printk(KERN_ERR PFX
-		       "intr_context[%d].qdev		= %p.\n", i,
-		       qdev->intr_context[i].qdev);
-		printk(KERN_ERR PFX
-		       "intr_context[%d].intr		= %d.\n", i,
-		       qdev->intr_context[i].intr);
-		printk(KERN_ERR PFX
-		       "intr_context[%d].hooked		= %d.\n", i,
-		       qdev->intr_context[i].hooked);
-		printk(KERN_ERR PFX
-		       "intr_context[%d].intr_en_mask	= 0x%08x.\n", i,
-		       qdev->intr_context[i].intr_en_mask);
-		printk(KERN_ERR PFX
-		       "intr_context[%d].intr_dis_mask	= 0x%08x.\n", i,
-		       qdev->intr_context[i].intr_dis_mask);
-		printk(KERN_ERR PFX
-		       "intr_context[%d].intr_read_mask	= 0x%08x.\n", i,
-		       qdev->intr_context[i].intr_read_mask);
+		DUMP_QDEV_ARRAY(qdev, "%p", intr_context, i, qdev);
+		DUMP_QDEV_ARRAY(qdev, "%d", intr_context, i, intr);
+		DUMP_QDEV_ARRAY(qdev, "%d", intr_context, i, hooked);
+		DUMP_QDEV_ARRAY(qdev, "0x%08x", intr_context, i, intr_en_mask);
+		DUMP_QDEV_ARRAY(qdev, "0x%08x", intr_context, i, intr_dis_mask);
+		DUMP_QDEV_ARRAY(qdev, "0x%08x", intr_context, i, intr_read_mask);
 	}
-	printk(KERN_ERR PFX "qdev->tx_ring_count = %d.\n", qdev->tx_ring_count);
-	printk(KERN_ERR PFX "qdev->rx_ring_count = %d.\n", qdev->rx_ring_count);
-	printk(KERN_ERR PFX "qdev->ring_mem_size = %d.\n", qdev->ring_mem_size);
-	printk(KERN_ERR PFX "qdev->ring_mem 	= %p.\n", qdev->ring_mem);
-	printk(KERN_ERR PFX "qdev->intr_count 	= %d.\n", qdev->intr_count);
-	printk(KERN_ERR PFX "qdev->tx_ring		= %p.\n",
-	       qdev->tx_ring);
-	printk(KERN_ERR PFX "qdev->rss_ring_count 	= %d.\n",
-	       qdev->rss_ring_count);
-	printk(KERN_ERR PFX "qdev->rx_ring	= %p.\n", qdev->rx_ring);
-	printk(KERN_ERR PFX "qdev->default_rx_queue	= %d.\n",
-	       qdev->default_rx_queue);
-	printk(KERN_ERR PFX "qdev->xg_sem_mask		= 0x%08x.\n",
-	       qdev->xg_sem_mask);
-	printk(KERN_ERR PFX "qdev->port_link_up		= 0x%08x.\n",
-	       qdev->port_link_up);
-	printk(KERN_ERR PFX "qdev->port_init		= 0x%08x.\n",
-	       qdev->port_init);
-
+	DUMP_QDEV_FIELD(qdev, "%d", tx_ring_count);
+	DUMP_QDEV_FIELD(qdev, "%d", rx_ring_count);
+	DUMP_QDEV_FIELD(qdev, "%d", ring_mem_size);
+	DUMP_QDEV_FIELD(qdev, "%p", ring_mem);
+	DUMP_QDEV_FIELD(qdev, "%d", intr_count);
+	DUMP_QDEV_FIELD(qdev, "%p", tx_ring);
+	DUMP_QDEV_FIELD(qdev, "%d", rss_ring_count);
+	DUMP_QDEV_FIELD(qdev, "%p", rx_ring);
+	DUMP_QDEV_FIELD(qdev, "%d", default_rx_queue);
+	DUMP_QDEV_FIELD(qdev, "0x%08x", xg_sem_mask);
+	DUMP_QDEV_FIELD(qdev, "0x%08x", port_link_up);
+	DUMP_QDEV_FIELD(qdev, "0x%08x", port_init);
 }
 #endif
 
 #ifdef QL_CB_DUMP
 void ql_dump_wqicb(struct wqicb *wqicb)
 {
-	printk(KERN_ERR PFX "Dumping wqicb stuff...\n");
-	printk(KERN_ERR PFX "wqicb->len = 0x%x.\n", le16_to_cpu(wqicb->len));
-	printk(KERN_ERR PFX "wqicb->flags = %x.\n", le16_to_cpu(wqicb->flags));
-	printk(KERN_ERR PFX "wqicb->cq_id_rss = %d.\n",
+	pr_err("Dumping wqicb stuff...\n");
+	pr_err("wqicb->len = 0x%x\n", le16_to_cpu(wqicb->len));
+	pr_err("wqicb->flags = %x\n", le16_to_cpu(wqicb->flags));
+	pr_err("wqicb->cq_id_rss = %d\n",
 	       le16_to_cpu(wqicb->cq_id_rss));
-	printk(KERN_ERR PFX "wqicb->rid = 0x%x.\n", le16_to_cpu(wqicb->rid));
-	printk(KERN_ERR PFX "wqicb->wq_addr = 0x%llx.\n",
+	pr_err("wqicb->rid = 0x%x\n", le16_to_cpu(wqicb->rid));
+	pr_err("wqicb->wq_addr = 0x%llx\n",
 	       (unsigned long long) le64_to_cpu(wqicb->addr));
-	printk(KERN_ERR PFX "wqicb->wq_cnsmr_idx_addr = 0x%llx.\n",
+	pr_err("wqicb->wq_cnsmr_idx_addr = 0x%llx\n",
 	       (unsigned long long) le64_to_cpu(wqicb->cnsmr_idx_addr));
 }
 
@@ -1800,40 +1653,34 @@ void ql_dump_tx_ring(struct tx_ring *tx_ring)
 {
 	if (tx_ring == NULL)
 		return;
-	printk(KERN_ERR PFX
-	       "===================== Dumping tx_ring %d ===============.\n",
+	pr_err("===================== Dumping tx_ring %d ===============\n",
 	       tx_ring->wq_id);
-	printk(KERN_ERR PFX "tx_ring->base = %p.\n", tx_ring->wq_base);
-	printk(KERN_ERR PFX "tx_ring->base_dma = 0x%llx.\n",
+	pr_err("tx_ring->base = %p\n", tx_ring->wq_base);
+	pr_err("tx_ring->base_dma = 0x%llx\n",
 	       (unsigned long long) tx_ring->wq_base_dma);
-	printk(KERN_ERR PFX
-	       "tx_ring->cnsmr_idx_sh_reg, addr = 0x%p, value = %d.\n",
+	pr_err("tx_ring->cnsmr_idx_sh_reg, addr = 0x%p, value = %d\n",
 	       tx_ring->cnsmr_idx_sh_reg,
 	       tx_ring->cnsmr_idx_sh_reg
 			? ql_read_sh_reg(tx_ring->cnsmr_idx_sh_reg) : 0);
-	printk(KERN_ERR PFX "tx_ring->size = %d.\n", tx_ring->wq_size);
-	printk(KERN_ERR PFX "tx_ring->len = %d.\n", tx_ring->wq_len);
-	printk(KERN_ERR PFX "tx_ring->prod_idx_db_reg = %p.\n",
-	       tx_ring->prod_idx_db_reg);
-	printk(KERN_ERR PFX "tx_ring->valid_db_reg = %p.\n",
-	       tx_ring->valid_db_reg);
-	printk(KERN_ERR PFX "tx_ring->prod_idx = %d.\n", tx_ring->prod_idx);
-	printk(KERN_ERR PFX "tx_ring->cq_id = %d.\n", tx_ring->cq_id);
-	printk(KERN_ERR PFX "tx_ring->wq_id = %d.\n", tx_ring->wq_id);
-	printk(KERN_ERR PFX "tx_ring->q = %p.\n", tx_ring->q);
-	printk(KERN_ERR PFX "tx_ring->tx_count = %d.\n",
-	       atomic_read(&tx_ring->tx_count));
+	pr_err("tx_ring->size = %d\n", tx_ring->wq_size);
+	pr_err("tx_ring->len = %d\n", tx_ring->wq_len);
+	pr_err("tx_ring->prod_idx_db_reg = %p\n", tx_ring->prod_idx_db_reg);
+	pr_err("tx_ring->valid_db_reg = %p\n", tx_ring->valid_db_reg);
+	pr_err("tx_ring->prod_idx = %d\n", tx_ring->prod_idx);
+	pr_err("tx_ring->cq_id = %d\n", tx_ring->cq_id);
+	pr_err("tx_ring->wq_id = %d\n", tx_ring->wq_id);
+	pr_err("tx_ring->q = %p\n", tx_ring->q);
+	pr_err("tx_ring->tx_count = %d\n", atomic_read(&tx_ring->tx_count));
 }
 
 void ql_dump_ricb(struct ricb *ricb)
 {
 	int i;
-	printk(KERN_ERR PFX
-	       "===================== Dumping ricb ===============.\n");
-	printk(KERN_ERR PFX "Dumping ricb stuff...\n");
+	pr_err("===================== Dumping ricb ===============\n");
+	pr_err("Dumping ricb stuff...\n");
 
-	printk(KERN_ERR PFX "ricb->base_cq = %d.\n", ricb->base_cq & 0x1f);
-	printk(KERN_ERR PFX "ricb->flags = %s%s%s%s%s%s%s%s%s.\n",
+	pr_err("ricb->base_cq = %d\n", ricb->base_cq & 0x1f);
+	pr_err("ricb->flags = %s%s%s%s%s%s%s%s%s\n",
 	       ricb->base_cq & RSS_L4K ? "RSS_L4K " : "",
 	       ricb->flags & RSS_L6K ? "RSS_L6K " : "",
 	       ricb->flags & RSS_LI ? "RSS_LI " : "",
@@ -1843,44 +1690,44 @@ void ql_dump_ricb(struct ricb *ricb)
 	       ricb->flags & RSS_RT4 ? "RSS_RT4 " : "",
 	       ricb->flags & RSS_RI6 ? "RSS_RI6 " : "",
 	       ricb->flags & RSS_RT6 ? "RSS_RT6 " : "");
-	printk(KERN_ERR PFX "ricb->mask = 0x%.04x.\n", le16_to_cpu(ricb->mask));
+	pr_err("ricb->mask = 0x%.04x\n", le16_to_cpu(ricb->mask));
 	for (i = 0; i < 16; i++)
-		printk(KERN_ERR PFX "ricb->hash_cq_id[%d] = 0x%.08x.\n", i,
+		pr_err("ricb->hash_cq_id[%d] = 0x%.08x\n", i,
 		       le32_to_cpu(ricb->hash_cq_id[i]));
 	for (i = 0; i < 10; i++)
-		printk(KERN_ERR PFX "ricb->ipv6_hash_key[%d] = 0x%.08x.\n", i,
+		pr_err("ricb->ipv6_hash_key[%d] = 0x%.08x\n", i,
 		       le32_to_cpu(ricb->ipv6_hash_key[i]));
 	for (i = 0; i < 4; i++)
-		printk(KERN_ERR PFX "ricb->ipv4_hash_key[%d] = 0x%.08x.\n", i,
+		pr_err("ricb->ipv4_hash_key[%d] = 0x%.08x\n", i,
 		       le32_to_cpu(ricb->ipv4_hash_key[i]));
 }
 
 void ql_dump_cqicb(struct cqicb *cqicb)
 {
-	printk(KERN_ERR PFX "Dumping cqicb stuff...\n");
+	pr_err("Dumping cqicb stuff...\n");
 
-	printk(KERN_ERR PFX "cqicb->msix_vect = %d.\n", cqicb->msix_vect);
-	printk(KERN_ERR PFX "cqicb->flags = %x.\n", cqicb->flags);
-	printk(KERN_ERR PFX "cqicb->len = %d.\n", le16_to_cpu(cqicb->len));
-	printk(KERN_ERR PFX "cqicb->addr = 0x%llx.\n",
+	pr_err("cqicb->msix_vect = %d\n", cqicb->msix_vect);
+	pr_err("cqicb->flags = %x\n", cqicb->flags);
+	pr_err("cqicb->len = %d\n", le16_to_cpu(cqicb->len));
+	pr_err("cqicb->addr = 0x%llx\n",
 	       (unsigned long long) le64_to_cpu(cqicb->addr));
-	printk(KERN_ERR PFX "cqicb->prod_idx_addr = 0x%llx.\n",
+	pr_err("cqicb->prod_idx_addr = 0x%llx\n",
 	       (unsigned long long) le64_to_cpu(cqicb->prod_idx_addr));
-	printk(KERN_ERR PFX "cqicb->pkt_delay = 0x%.04x.\n",
+	pr_err("cqicb->pkt_delay = 0x%.04x\n",
 	       le16_to_cpu(cqicb->pkt_delay));
-	printk(KERN_ERR PFX "cqicb->irq_delay = 0x%.04x.\n",
+	pr_err("cqicb->irq_delay = 0x%.04x\n",
 	       le16_to_cpu(cqicb->irq_delay));
-	printk(KERN_ERR PFX "cqicb->lbq_addr = 0x%llx.\n",
+	pr_err("cqicb->lbq_addr = 0x%llx\n",
 	       (unsigned long long) le64_to_cpu(cqicb->lbq_addr));
-	printk(KERN_ERR PFX "cqicb->lbq_buf_size = 0x%.04x.\n",
+	pr_err("cqicb->lbq_buf_size = 0x%.04x\n",
 	       le16_to_cpu(cqicb->lbq_buf_size));
-	printk(KERN_ERR PFX "cqicb->lbq_len = 0x%.04x.\n",
+	pr_err("cqicb->lbq_len = 0x%.04x\n",
 	       le16_to_cpu(cqicb->lbq_len));
-	printk(KERN_ERR PFX "cqicb->sbq_addr = 0x%llx.\n",
+	pr_err("cqicb->sbq_addr = 0x%llx\n",
 	       (unsigned long long) le64_to_cpu(cqicb->sbq_addr));
-	printk(KERN_ERR PFX "cqicb->sbq_buf_size = 0x%.04x.\n",
+	pr_err("cqicb->sbq_buf_size = 0x%.04x\n",
 	       le16_to_cpu(cqicb->sbq_buf_size));
-	printk(KERN_ERR PFX "cqicb->sbq_len = 0x%.04x.\n",
+	pr_err("cqicb->sbq_len = 0x%.04x\n",
 	       le16_to_cpu(cqicb->sbq_len));
 }
 
@@ -1888,100 +1735,85 @@ void ql_dump_rx_ring(struct rx_ring *rx_ring)
 {
 	if (rx_ring == NULL)
 		return;
-	printk(KERN_ERR PFX
-	       "===================== Dumping rx_ring %d ===============.\n",
+	pr_err("===================== Dumping rx_ring %d ===============\n",
 	       rx_ring->cq_id);
-	printk(KERN_ERR PFX "Dumping rx_ring %d, type = %s%s%s.\n",
+	pr_err("Dumping rx_ring %d, type = %s%s%s\n",
 	       rx_ring->cq_id, rx_ring->type == DEFAULT_Q ? "DEFAULT" : "",
 	       rx_ring->type == TX_Q ? "OUTBOUND COMPLETIONS" : "",
 	       rx_ring->type == RX_Q ? "INBOUND_COMPLETIONS" : "");
-	printk(KERN_ERR PFX "rx_ring->cqicb = %p.\n", &rx_ring->cqicb);
-	printk(KERN_ERR PFX "rx_ring->cq_base = %p.\n", rx_ring->cq_base);
-	printk(KERN_ERR PFX "rx_ring->cq_base_dma = %llx.\n",
+	pr_err("rx_ring->cqicb = %p\n", &rx_ring->cqicb);
+	pr_err("rx_ring->cq_base = %p\n", rx_ring->cq_base);
+	pr_err("rx_ring->cq_base_dma = %llx\n",
 	       (unsigned long long) rx_ring->cq_base_dma);
-	printk(KERN_ERR PFX "rx_ring->cq_size = %d.\n", rx_ring->cq_size);
-	printk(KERN_ERR PFX "rx_ring->cq_len = %d.\n", rx_ring->cq_len);
-	printk(KERN_ERR PFX
-	       "rx_ring->prod_idx_sh_reg, addr = 0x%p, value = %d.\n",
+	pr_err("rx_ring->cq_size = %d\n", rx_ring->cq_size);
+	pr_err("rx_ring->cq_len = %d\n", rx_ring->cq_len);
+	pr_err("rx_ring->prod_idx_sh_reg, addr = 0x%p, value = %d\n",
 	       rx_ring->prod_idx_sh_reg,
 	       rx_ring->prod_idx_sh_reg
 			? ql_read_sh_reg(rx_ring->prod_idx_sh_reg) : 0);
-	printk(KERN_ERR PFX "rx_ring->prod_idx_sh_reg_dma = %llx.\n",
+	pr_err("rx_ring->prod_idx_sh_reg_dma = %llx\n",
 	       (unsigned long long) rx_ring->prod_idx_sh_reg_dma);
-	printk(KERN_ERR PFX "rx_ring->cnsmr_idx_db_reg = %p.\n",
+	pr_err("rx_ring->cnsmr_idx_db_reg = %p\n",
 	       rx_ring->cnsmr_idx_db_reg);
-	printk(KERN_ERR PFX "rx_ring->cnsmr_idx = %d.\n", rx_ring->cnsmr_idx);
-	printk(KERN_ERR PFX "rx_ring->curr_entry = %p.\n", rx_ring->curr_entry);
-	printk(KERN_ERR PFX "rx_ring->valid_db_reg = %p.\n",
-	       rx_ring->valid_db_reg);
+	pr_err("rx_ring->cnsmr_idx = %d\n", rx_ring->cnsmr_idx);
+	pr_err("rx_ring->curr_entry = %p\n", rx_ring->curr_entry);
+	pr_err("rx_ring->valid_db_reg = %p\n", rx_ring->valid_db_reg);
 
-	printk(KERN_ERR PFX "rx_ring->lbq_base = %p.\n", rx_ring->lbq_base);
-	printk(KERN_ERR PFX "rx_ring->lbq_base_dma = %llx.\n",
+	pr_err("rx_ring->lbq_base = %p\n", rx_ring->lbq_base);
+	pr_err("rx_ring->lbq_base_dma = %llx\n",
 	       (unsigned long long) rx_ring->lbq_base_dma);
-	printk(KERN_ERR PFX "rx_ring->lbq_base_indirect = %p.\n",
+	pr_err("rx_ring->lbq_base_indirect = %p\n",
 	       rx_ring->lbq_base_indirect);
-	printk(KERN_ERR PFX "rx_ring->lbq_base_indirect_dma = %llx.\n",
+	pr_err("rx_ring->lbq_base_indirect_dma = %llx\n",
 	       (unsigned long long) rx_ring->lbq_base_indirect_dma);
-	printk(KERN_ERR PFX "rx_ring->lbq = %p.\n", rx_ring->lbq);
-	printk(KERN_ERR PFX "rx_ring->lbq_len = %d.\n", rx_ring->lbq_len);
-	printk(KERN_ERR PFX "rx_ring->lbq_size = %d.\n", rx_ring->lbq_size);
-	printk(KERN_ERR PFX "rx_ring->lbq_prod_idx_db_reg = %p.\n",
+	pr_err("rx_ring->lbq = %p\n", rx_ring->lbq);
+	pr_err("rx_ring->lbq_len = %d\n", rx_ring->lbq_len);
+	pr_err("rx_ring->lbq_size = %d\n", rx_ring->lbq_size);
+	pr_err("rx_ring->lbq_prod_idx_db_reg = %p\n",
 	       rx_ring->lbq_prod_idx_db_reg);
-	printk(KERN_ERR PFX "rx_ring->lbq_prod_idx = %d.\n",
-	       rx_ring->lbq_prod_idx);
-	printk(KERN_ERR PFX "rx_ring->lbq_curr_idx = %d.\n",
-	       rx_ring->lbq_curr_idx);
-	printk(KERN_ERR PFX "rx_ring->lbq_clean_idx = %d.\n",
-	       rx_ring->lbq_clean_idx);
-	printk(KERN_ERR PFX "rx_ring->lbq_free_cnt = %d.\n",
-	       rx_ring->lbq_free_cnt);
-	printk(KERN_ERR PFX "rx_ring->lbq_buf_size = %d.\n",
-	       rx_ring->lbq_buf_size);
-
-	printk(KERN_ERR PFX "rx_ring->sbq_base = %p.\n", rx_ring->sbq_base);
-	printk(KERN_ERR PFX "rx_ring->sbq_base_dma = %llx.\n",
+	pr_err("rx_ring->lbq_prod_idx = %d\n", rx_ring->lbq_prod_idx);
+	pr_err("rx_ring->lbq_curr_idx = %d\n", rx_ring->lbq_curr_idx);
+	pr_err("rx_ring->lbq_clean_idx = %d\n", rx_ring->lbq_clean_idx);
+	pr_err("rx_ring->lbq_free_cnt = %d\n", rx_ring->lbq_free_cnt);
+	pr_err("rx_ring->lbq_buf_size = %d\n", rx_ring->lbq_buf_size);
+
+	pr_err("rx_ring->sbq_base = %p\n", rx_ring->sbq_base);
+	pr_err("rx_ring->sbq_base_dma = %llx\n",
 	       (unsigned long long) rx_ring->sbq_base_dma);
-	printk(KERN_ERR PFX "rx_ring->sbq_base_indirect = %p.\n",
+	pr_err("rx_ring->sbq_base_indirect = %p\n",
 	       rx_ring->sbq_base_indirect);
-	printk(KERN_ERR PFX "rx_ring->sbq_base_indirect_dma = %llx.\n",
+	pr_err("rx_ring->sbq_base_indirect_dma = %llx\n",
 	       (unsigned long long) rx_ring->sbq_base_indirect_dma);
-	printk(KERN_ERR PFX "rx_ring->sbq = %p.\n", rx_ring->sbq);
-	printk(KERN_ERR PFX "rx_ring->sbq_len = %d.\n", rx_ring->sbq_len);
-	printk(KERN_ERR PFX "rx_ring->sbq_size = %d.\n", rx_ring->sbq_size);
-	printk(KERN_ERR PFX "rx_ring->sbq_prod_idx_db_reg addr = %p.\n",
+	pr_err("rx_ring->sbq = %p\n", rx_ring->sbq);
+	pr_err("rx_ring->sbq_len = %d\n", rx_ring->sbq_len);
+	pr_err("rx_ring->sbq_size = %d\n", rx_ring->sbq_size);
+	pr_err("rx_ring->sbq_prod_idx_db_reg addr = %p\n",
 	       rx_ring->sbq_prod_idx_db_reg);
-	printk(KERN_ERR PFX "rx_ring->sbq_prod_idx = %d.\n",
-	       rx_ring->sbq_prod_idx);
-	printk(KERN_ERR PFX "rx_ring->sbq_curr_idx = %d.\n",
-	       rx_ring->sbq_curr_idx);
-	printk(KERN_ERR PFX "rx_ring->sbq_clean_idx = %d.\n",
-	       rx_ring->sbq_clean_idx);
-	printk(KERN_ERR PFX "rx_ring->sbq_free_cnt = %d.\n",
-	       rx_ring->sbq_free_cnt);
-	printk(KERN_ERR PFX "rx_ring->sbq_buf_size = %d.\n",
-	       rx_ring->sbq_buf_size);
-	printk(KERN_ERR PFX "rx_ring->cq_id = %d.\n", rx_ring->cq_id);
-	printk(KERN_ERR PFX "rx_ring->irq = %d.\n", rx_ring->irq);
-	printk(KERN_ERR PFX "rx_ring->cpu = %d.\n", rx_ring->cpu);
-	printk(KERN_ERR PFX "rx_ring->qdev = %p.\n", rx_ring->qdev);
+	pr_err("rx_ring->sbq_prod_idx = %d\n", rx_ring->sbq_prod_idx);
+	pr_err("rx_ring->sbq_curr_idx = %d\n", rx_ring->sbq_curr_idx);
+	pr_err("rx_ring->sbq_clean_idx = %d\n", rx_ring->sbq_clean_idx);
+	pr_err("rx_ring->sbq_free_cnt = %d\n", rx_ring->sbq_free_cnt);
+	pr_err("rx_ring->sbq_buf_size = %d\n", rx_ring->sbq_buf_size);
+	pr_err("rx_ring->cq_id = %d\n", rx_ring->cq_id);
+	pr_err("rx_ring->irq = %d\n", rx_ring->irq);
+	pr_err("rx_ring->cpu = %d\n", rx_ring->cpu);
+	pr_err("rx_ring->qdev = %p\n", rx_ring->qdev);
 }
 
 void ql_dump_hw_cb(struct ql_adapter *qdev, int size, u32 bit, u16 q_id)
 {
 	void *ptr;
 
-	printk(KERN_ERR PFX "%s: Enter.\n", __func__);
+	pr_err("%s: Enter\n", __func__);
 
 	ptr = kmalloc(size, GFP_ATOMIC);
 	if (ptr == NULL) {
-		printk(KERN_ERR PFX "%s: Couldn't allocate a buffer.\n",
-		       __func__);
+		pr_err("%s: Couldn't allocate a buffer\n", __func__);
 		return;
 	}
 
 	if (ql_write_cfg(qdev, ptr, size, bit, q_id)) {
-		printk(KERN_ERR "%s: Failed to upload control block!\n",
-		       __func__);
+		pr_err("%s: Failed to upload control block!\n", __func__);
 		goto fail_it;
 	}
 	switch (bit) {
@@ -1995,8 +1827,7 @@ void ql_dump_hw_cb(struct ql_adapter *qdev, int size, u32 bit, u16 q_id)
 		ql_dump_ricb((struct ricb *)ptr);
 		break;
 	default:
-		printk(KERN_ERR PFX "%s: Invalid bit value = %x.\n",
-		       __func__, bit);
+		pr_err("%s: Invalid bit value = %x\n", __func__, bit);
 		break;
 	}
 fail_it:
@@ -2007,27 +1838,27 @@ fail_it:
 #ifdef QL_OB_DUMP
 void ql_dump_tx_desc(struct tx_buf_desc *tbd)
 {
-	printk(KERN_ERR PFX "tbd->addr  = 0x%llx\n",
+	pr_err("tbd->addr  = 0x%llx\n",
 	       le64_to_cpu((u64) tbd->addr));
-	printk(KERN_ERR PFX "tbd->len   = %d\n",
+	pr_err("tbd->len   = %d\n",
 	       le32_to_cpu(tbd->len & TX_DESC_LEN_MASK));
-	printk(KERN_ERR PFX "tbd->flags = %s %s\n",
+	pr_err("tbd->flags = %s %s\n",
 	       tbd->len & TX_DESC_C ? "C" : ".",
 	       tbd->len & TX_DESC_E ? "E" : ".");
 	tbd++;
-	printk(KERN_ERR PFX "tbd->addr  = 0x%llx\n",
+	pr_err("tbd->addr  = 0x%llx\n",
 	       le64_to_cpu((u64) tbd->addr));
-	printk(KERN_ERR PFX "tbd->len   = %d\n",
+	pr_err("tbd->len   = %d\n",
 	       le32_to_cpu(tbd->len & TX_DESC_LEN_MASK));
-	printk(KERN_ERR PFX "tbd->flags = %s %s\n",
+	pr_err("tbd->flags = %s %s\n",
 	       tbd->len & TX_DESC_C ? "C" : ".",
 	       tbd->len & TX_DESC_E ? "E" : ".");
 	tbd++;
-	printk(KERN_ERR PFX "tbd->addr  = 0x%llx\n",
+	pr_err("tbd->addr  = 0x%llx\n",
 	       le64_to_cpu((u64) tbd->addr));
-	printk(KERN_ERR PFX "tbd->len   = %d\n",
+	pr_err("tbd->len   = %d\n",
 	       le32_to_cpu(tbd->len & TX_DESC_LEN_MASK));
-	printk(KERN_ERR PFX "tbd->flags = %s %s\n",
+	pr_err("tbd->flags = %s %s\n",
 	       tbd->len & TX_DESC_C ? "C" : ".",
 	       tbd->len & TX_DESC_E ? "E" : ".");
 
@@ -2040,38 +1871,38 @@ void ql_dump_ob_mac_iocb(struct ob_mac_iocb_req *ob_mac_iocb)
 	struct tx_buf_desc *tbd;
 	u16 frame_len;
 
-	printk(KERN_ERR PFX "%s\n", __func__);
-	printk(KERN_ERR PFX "opcode         = %s\n",
+	pr_err("%s\n", __func__);
+	pr_err("opcode         = %s\n",
 	       (ob_mac_iocb->opcode == OPCODE_OB_MAC_IOCB) ? "MAC" : "TSO");
-	printk(KERN_ERR PFX "flags1          = %s %s %s %s %s\n",
+	pr_err("flags1          = %s %s %s %s %s\n",
 	       ob_mac_tso_iocb->flags1 & OB_MAC_TSO_IOCB_OI ? "OI" : "",
 	       ob_mac_tso_iocb->flags1 & OB_MAC_TSO_IOCB_I ? "I" : "",
 	       ob_mac_tso_iocb->flags1 & OB_MAC_TSO_IOCB_D ? "D" : "",
 	       ob_mac_tso_iocb->flags1 & OB_MAC_TSO_IOCB_IP4 ? "IP4" : "",
 	       ob_mac_tso_iocb->flags1 & OB_MAC_TSO_IOCB_IP6 ? "IP6" : "");
-	printk(KERN_ERR PFX "flags2          = %s %s %s\n",
+	pr_err("flags2          = %s %s %s\n",
 	       ob_mac_tso_iocb->flags2 & OB_MAC_TSO_IOCB_LSO ? "LSO" : "",
 	       ob_mac_tso_iocb->flags2 & OB_MAC_TSO_IOCB_UC ? "UC" : "",
 	       ob_mac_tso_iocb->flags2 & OB_MAC_TSO_IOCB_TC ? "TC" : "");
-	printk(KERN_ERR PFX "flags3          = %s %s %s\n",
+	pr_err("flags3          = %s %s %s\n",
 	       ob_mac_tso_iocb->flags3 & OB_MAC_TSO_IOCB_IC ? "IC" : "",
 	       ob_mac_tso_iocb->flags3 & OB_MAC_TSO_IOCB_DFP ? "DFP" : "",
 	       ob_mac_tso_iocb->flags3 & OB_MAC_TSO_IOCB_V ? "V" : "");
-	printk(KERN_ERR PFX "tid = %x\n", ob_mac_iocb->tid);
-	printk(KERN_ERR PFX "txq_idx = %d\n", ob_mac_iocb->txq_idx);
-	printk(KERN_ERR PFX "vlan_tci      = %x\n", ob_mac_tso_iocb->vlan_tci);
+	pr_err("tid = %x\n", ob_mac_iocb->tid);
+	pr_err("txq_idx = %d\n", ob_mac_iocb->txq_idx);
+	pr_err("vlan_tci      = %x\n", ob_mac_tso_iocb->vlan_tci);
 	if (ob_mac_iocb->opcode == OPCODE_OB_MAC_TSO_IOCB) {
-		printk(KERN_ERR PFX "frame_len      = %d\n",
+		pr_err("frame_len      = %d\n",
 		       le32_to_cpu(ob_mac_tso_iocb->frame_len));
-		printk(KERN_ERR PFX "mss      = %d\n",
+		pr_err("mss      = %d\n",
 		       le16_to_cpu(ob_mac_tso_iocb->mss));
-		printk(KERN_ERR PFX "prot_hdr_len   = %d\n",
+		pr_err("prot_hdr_len   = %d\n",
 		       le16_to_cpu(ob_mac_tso_iocb->total_hdrs_len));
-		printk(KERN_ERR PFX "hdr_offset     = 0x%.04x\n",
+		pr_err("hdr_offset     = 0x%.04x\n",
 		       le16_to_cpu(ob_mac_tso_iocb->net_trans_offset));
 		frame_len = le32_to_cpu(ob_mac_tso_iocb->frame_len);
 	} else {
-		printk(KERN_ERR PFX "frame_len      = %d\n",
+		pr_err("frame_len      = %d\n",
 		       le16_to_cpu(ob_mac_iocb->frame_len));
 		frame_len = le16_to_cpu(ob_mac_iocb->frame_len);
 	}
@@ -2081,9 +1912,9 @@ void ql_dump_ob_mac_iocb(struct ob_mac_iocb_req *ob_mac_iocb)
 
 void ql_dump_ob_mac_rsp(struct ob_mac_iocb_rsp *ob_mac_rsp)
 {
-	printk(KERN_ERR PFX "%s\n", __func__);
-	printk(KERN_ERR PFX "opcode         = %d\n", ob_mac_rsp->opcode);
-	printk(KERN_ERR PFX "flags          = %s %s %s %s %s %s %s\n",
+	pr_err("%s\n", __func__);
+	pr_err("opcode         = %d\n", ob_mac_rsp->opcode);
+	pr_err("flags          = %s %s %s %s %s %s %s\n",
 	       ob_mac_rsp->flags1 & OB_MAC_IOCB_RSP_OI ? "OI" : ".",
 	       ob_mac_rsp->flags1 & OB_MAC_IOCB_RSP_I ? "I" : ".",
 	       ob_mac_rsp->flags1 & OB_MAC_IOCB_RSP_E ? "E" : ".",
@@ -2091,16 +1922,16 @@ void ql_dump_ob_mac_rsp(struct ob_mac_iocb_rsp *ob_mac_rsp)
 	       ob_mac_rsp->flags1 & OB_MAC_IOCB_RSP_L ? "L" : ".",
 	       ob_mac_rsp->flags1 & OB_MAC_IOCB_RSP_P ? "P" : ".",
 	       ob_mac_rsp->flags2 & OB_MAC_IOCB_RSP_B ? "B" : ".");
-	printk(KERN_ERR PFX "tid = %x\n", ob_mac_rsp->tid);
+	pr_err("tid = %x\n", ob_mac_rsp->tid);
 }
 #endif
 
 #ifdef QL_IB_DUMP
 void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 {
-	printk(KERN_ERR PFX "%s\n", __func__);
-	printk(KERN_ERR PFX "opcode         = 0x%x\n", ib_mac_rsp->opcode);
-	printk(KERN_ERR PFX "flags1 = %s%s%s%s%s%s\n",
+	pr_err("%s\n", __func__);
+	pr_err("opcode         = 0x%x\n", ib_mac_rsp->opcode);
+	pr_err("flags1 = %s%s%s%s%s%s\n",
 	       ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_OI ? "OI " : "",
 	       ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_I ? "I " : "",
 	       ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_TE ? "TE " : "",
@@ -2109,7 +1940,7 @@ void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 	       ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_B ? "B " : "");
 
 	if (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK)
-		printk(KERN_ERR PFX "%s%s%s Multicast.\n",
+		pr_err("%s%s%s Multicast\n",
 		       (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
 		       IB_MAC_IOCB_RSP_M_HASH ? "Hash" : "",
 		       (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
@@ -2117,7 +1948,7 @@ void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 		       (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
 		       IB_MAC_IOCB_RSP_M_PROM ? "Promiscuous" : "");
 
-	printk(KERN_ERR PFX "flags2 = %s%s%s%s%s\n",
+	pr_err("flags2 = %s%s%s%s%s\n",
 	       (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_P) ? "P " : "",
 	       (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) ? "V " : "",
 	       (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) ? "U " : "",
@@ -2125,7 +1956,7 @@ void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 	       (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_FO) ? "FO " : "");
 
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK)
-		printk(KERN_ERR PFX "%s%s%s%s%s error.\n",
+		pr_err("%s%s%s%s%s error\n",
 		       (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) ==
 		       IB_MAC_IOCB_RSP_ERR_OVERSIZE ? "oversize" : "",
 		       (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) ==
@@ -2137,12 +1968,12 @@ void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 		       (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) ==
 		       IB_MAC_IOCB_RSP_ERR_CRC ? "CRC" : "");
 
-	printk(KERN_ERR PFX "flags3 = %s%s.\n",
+	pr_err("flags3 = %s%s\n",
 	       ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DS ? "DS " : "",
 	       ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DL ? "DL " : "");
 
 	if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_RSS_MASK)
-		printk(KERN_ERR PFX "RSS flags = %s%s%s%s.\n",
+		pr_err("RSS flags = %s%s%s%s\n",
 		       ((ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_RSS_MASK) ==
 			IB_MAC_IOCB_RSP_M_IPV4) ? "IPv4 RSS" : "",
 		       ((ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_RSS_MASK) ==
@@ -2152,26 +1983,26 @@ void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 		       ((ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_RSS_MASK) ==
 			IB_MAC_IOCB_RSP_M_TCP_V6) ? "TCP/IPv6 RSS" : "");
 
-	printk(KERN_ERR PFX "data_len	= %d\n",
+	pr_err("data_len	= %d\n",
 	       le32_to_cpu(ib_mac_rsp->data_len));
-	printk(KERN_ERR PFX "data_addr    = 0x%llx\n",
+	pr_err("data_addr    = 0x%llx\n",
 	       (unsigned long long) le64_to_cpu(ib_mac_rsp->data_addr));
 	if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_RSS_MASK)
-		printk(KERN_ERR PFX "rss    = %x\n",
+		pr_err("rss    = %x\n",
 		       le32_to_cpu(ib_mac_rsp->rss));
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V)
-		printk(KERN_ERR PFX "vlan_id    = %x\n",
+		pr_err("vlan_id    = %x\n",
 		       le16_to_cpu(ib_mac_rsp->vlan_id));
 
-	printk(KERN_ERR PFX "flags4 = %s%s%s.\n",
+	pr_err("flags4 = %s%s%s\n",
 		ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV ? "HV " : "",
 		ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HS ? "HS " : "",
 		ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HL ? "HL " : "");
 
 	if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV) {
-		printk(KERN_ERR PFX "hdr length	= %d.\n",
+		pr_err("hdr length	= %d\n",
 		       le32_to_cpu(ib_mac_rsp->hdr_len));
-		printk(KERN_ERR PFX "hdr addr    = 0x%llx.\n",
+		pr_err("hdr addr    = 0x%llx\n",
 		       (unsigned long long) le64_to_cpu(ib_mac_rsp->hdr_addr));
 	}
 }
