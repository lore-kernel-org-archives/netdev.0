From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 15/24] bnx2x: Cosmetic changes.
Date: Tue, 14 Jun 2011 14:34:02 +0300
Message-ID: <201106141434.02623.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2495 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756359Ab1FNLfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:35:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |   12 ++++--------
 drivers/net/bnx2x/bnx2x_ethtool.c |   12 ++++++------
 drivers/net/bnx2x/bnx2x_main.c    |   37 ++++++++++++++++++-------------------
 3 files changed, 28 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index c108e4c..4616d80 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -22,10 +22,6 @@
 #define DRV_MODULE_RELDATE      "2011/03/20"
 #define BNX2X_BC_VER            0x040200
 
-#define BNX2X_MULTI_QUEUE
-
-#define BNX2X_NEW_NAPI
-
 #if defined(CONFIG_DCB)
 #define BCM_DCBNL
 #endif
@@ -745,9 +741,9 @@ struct bnx2x_common {
 					 (CHIP_REV(bp) == CHIP_REV_Ax))
 
 	int			flash_size;
-#define NVRAM_1MB_SIZE			0x20000	/* 1M bit in bytes */
-#define NVRAM_TIMEOUT_COUNT		30000
-#define NVRAM_PAGE_SIZE			256
+#define BNX2X_NVRAM_1MB_SIZE			0x20000	/* 1M bit in bytes */
+#define BNX2X_NVRAM_TIMEOUT_COUNT		30000
+#define BNX2X_NVRAM_PAGE_SIZE			256
 
 	u32			shmem_base;
 	u32			shmem2_base;
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 965fb07..1a3ed41 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -762,7 +762,7 @@ static int bnx2x_acquire_nvram_lock(struct bnx2x *bp)
 	u32 val = 0;
 
 	/* adjust timeout for emulation/FPGA */
-	count = NVRAM_TIMEOUT_COUNT;
+	count = BNX2X_NVRAM_TIMEOUT_COUNT;
 	if (CHIP_REV_IS_SLOW(bp))
 		count *= 100;
 
@@ -793,7 +793,7 @@ static int bnx2x_release_nvram_lock(struct bnx2x *bp)
 	u32 val = 0;
 
 	/* adjust timeout for emulation/FPGA */
-	count = NVRAM_TIMEOUT_COUNT;
+	count = BNX2X_NVRAM_TIMEOUT_COUNT;
 	if (CHIP_REV_IS_SLOW(bp))
 		count *= 100;
 
@@ -861,7 +861,7 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
 	REG_WR(bp, MCP_REG_MCPR_NVM_COMMAND, cmd_flags);
 
 	/* adjust timeout for emulation/FPGA */
-	count = NVRAM_TIMEOUT_COUNT;
+	count = BNX2X_NVRAM_TIMEOUT_COUNT;
 	if (CHIP_REV_IS_SLOW(bp))
 		count *= 100;
 
@@ -984,7 +984,7 @@ static int bnx2x_nvram_write_dword(struct bnx2x *bp, u32 offset, u32 val,
 	REG_WR(bp, MCP_REG_MCPR_NVM_COMMAND, cmd_flags);
 
 	/* adjust timeout for emulation/FPGA */
-	count = NVRAM_TIMEOUT_COUNT;
+	count = BNX2X_NVRAM_TIMEOUT_COUNT;
 	if (CHIP_REV_IS_SLOW(bp))
 		count *= 100;
 
@@ -1088,9 +1088,9 @@ static int bnx2x_nvram_write(struct bnx2x *bp, u32 offset, u8 *data_buf,
 	while ((written_so_far < buf_size) && (rc == 0)) {
 		if (written_so_far == (buf_size - sizeof(u32)))
 			cmd_flags |= MCPR_NVM_COMMAND_LAST;
-		else if (((offset + 4) % NVRAM_PAGE_SIZE) == 0)
+		else if (((offset + 4) % BNX2X_NVRAM_PAGE_SIZE) == 0)
 			cmd_flags |= MCPR_NVM_COMMAND_LAST;
-		else if ((offset % NVRAM_PAGE_SIZE) == 0)
+		else if ((offset % BNX2X_NVRAM_PAGE_SIZE) == 0)
 			cmd_flags |= MCPR_NVM_COMMAND_FIRST;
 
 		memcpy(&val, data_buf, 4);
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 73a22fd..a2cc7d5 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1557,7 +1557,7 @@ void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 		offset++;
 #endif
 		for_each_eth_queue(bp, i)
-			synchronize_irq(bp->msix_table[i + offset].vector);
+			synchronize_irq(bp->msix_table[offset++].vector);
 	} else
 		synchronize_irq(bp->pdev->irq);
 
@@ -2514,7 +2514,8 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param)
 	SHMEM_WR(bp, func_mb[mb_idx].drv_mb_param, param);
 	SHMEM_WR(bp, func_mb[mb_idx].drv_mb_header, (command | seq));
 
-	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
+	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB param 0x%08x\n",
+			(command | seq), param);
 
 	do {
 		/* let the FW do it's magic ... */
@@ -8187,7 +8188,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	}
 
 	val = REG_RD(bp, MCP_REG_MCPR_NVM_CFG4);
-	bp->common.flash_size = (NVRAM_1MB_SIZE <<
+	bp->common.flash_size = (BNX2X_NVRAM_1MB_SIZE <<
 				 (val & MCPR_NVM_CFG4_FLASH_SIZE));
 	BNX2X_DEV_INFO("flash_size 0x%x (%d)\n",
 		       bp->common.flash_size, bp->common.flash_size);
@@ -8460,7 +8461,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					(ADVERTISED_10baseT_Full |
 					 ADVERTISED_TP);
 			} else {
-				BNX2X_ERROR("NVRAM config error. "
+				BNX2X_ERR("NVRAM config error. "
 					    "Invalid link_config 0x%x"
 					    "  speed_cap_mask 0x%x\n",
 					    link_config,
@@ -8479,7 +8480,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					(ADVERTISED_10baseT_Half |
 					 ADVERTISED_TP);
 			} else {
-				BNX2X_ERROR("NVRAM config error. "
+				BNX2X_ERR("NVRAM config error. "
 					    "Invalid link_config 0x%x"
 					    "  speed_cap_mask 0x%x\n",
 					    link_config,
@@ -8497,7 +8498,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					(ADVERTISED_100baseT_Full |
 					 ADVERTISED_TP);
 			} else {
-				BNX2X_ERROR("NVRAM config error. "
+				BNX2X_ERR("NVRAM config error. "
 					    "Invalid link_config 0x%x"
 					    "  speed_cap_mask 0x%x\n",
 					    link_config,
@@ -8517,7 +8518,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					(ADVERTISED_100baseT_Half |
 					 ADVERTISED_TP);
 			} else {
-				BNX2X_ERROR("NVRAM config error. "
+				BNX2X_ERR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
 				    link_config,
@@ -8535,7 +8536,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					(ADVERTISED_1000baseT_Full |
 					 ADVERTISED_TP);
 			} else {
-				BNX2X_ERROR("NVRAM config error. "
+				BNX2X_ERR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
 				    link_config,
@@ -8553,7 +8554,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					(ADVERTISED_2500baseX_Full |
 						ADVERTISED_TP);
 			} else {
-				BNX2X_ERROR("NVRAM config error. "
+				BNX2X_ERR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
 				    link_config,
@@ -8571,7 +8572,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					(ADVERTISED_10000baseT_Full |
 						ADVERTISED_FIBRE);
 			} else {
-				BNX2X_ERROR("NVRAM config error. "
+				BNX2X_ERR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
 				    link_config,
@@ -8581,9 +8582,9 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			break;
 
 		default:
-			BNX2X_ERROR("NVRAM config error. "
-				    "BAD link speed link_config 0x%x\n",
-					  link_config);
+			BNX2X_ERR("NVRAM config error. "
+				  "BAD link speed link_config 0x%x\n",
+				  link_config);
 				bp->link_params.req_line_speed[idx] =
 							SPEED_AUTO_NEG;
 				bp->port.advertising[idx] =
@@ -8956,14 +8957,12 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 					bp->mf_config[vn] = MF_CFG_RD(bp,
 						func_mf_config[func].config);
 				} else
-					DP(NETIF_MSG_PROBE, "illegal OV for "
-							    "SD\n");
+					BNX2X_DEV_INFO("illegal OV for SD\n");
 				break;
 			default:
 				/* Unknown configuration: reset mf_config */
 				bp->mf_config[vn] = 0;
-				DP(NETIF_MSG_PROBE, "Unknown MF mode 0x%x\n",
-				   val);
+				BNX2X_DEV_INFO("unkown MF mode 0x%x\n", val);
 			}
 		}
 
@@ -10400,8 +10399,8 @@ static void bnx2x_io_resume(struct pci_dev *pdev)
 	struct bnx2x *bp = netdev_priv(dev);
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. "
-				"Try again later\n");
+		netdev_err(bp->dev, "Handling parity error recovery. "
+				    "Try again later\n");
 		return;
 	}
 
-- 
1.7.4.1


