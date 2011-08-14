From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 net-next 3/3] bnx2x: Use pr_fmt and message logging cleanups
Date: Sun, 14 Aug 2011 15:16:21 -0700
Message-ID: <2d33739418a06602c817d002b30fedd57cbe5f11.1313360101.git.joe@perches.com>
References: <cover.1313360100.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1313360100.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add pr_fmt(fmt) KBUILD_MODNAME ": " to prefix messages with "bnx2x: ".
Remove #define DP_LEVEL and use pr_notice.
Repeating KERN_<LEVEL> isn't necessary in multi-line printks.
printk macro neatening, use fmt and ##__VA_ARGS__.
Coalesce long formats.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |   63 ++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    6 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    3 +
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   23 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   25 +++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |    3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |   46 +++++++-------
 7 files changed, 87 insertions(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 5aac959..f127768 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -66,69 +66,68 @@
 #define BNX2X_MSG_SP			0x100000 /* was: NETIF_MSG_INTR */
 #define BNX2X_MSG_FP			0x200000 /* was: NETIF_MSG_INTR */
 
-#define DP_LEVEL			KERN_NOTICE	/* was: KERN_DEBUG */
-
 /* regular debug print */
-#define DP(__mask, __fmt, __args...)				\
+#define DP(__mask, fmt, ...)					\
 do {								\
 	if (bp->msg_enable & (__mask))				\
-		printk(DP_LEVEL "[%s:%d(%s)]" __fmt,		\
-		       __func__, __LINE__,			\
-		       bp->dev ? (bp->dev->name) : "?",		\
-		       ##__args);				\
+		pr_notice("[%s:%d(%s)]" fmt,			\
+			  __func__, __LINE__,			\
+			  bp->dev ? (bp->dev->name) : "?",	\
+			  ##__VA_ARGS__);			\
 } while (0)
 
-#define DP_CONT(__mask, __fmt, __args...)			\
+#define DP_CONT(__mask, fmt, ...)				\
 do {								\
 	if (bp->msg_enable & (__mask))				\
-		pr_cont(__fmt, ##__args);			\
+		pr_cont(fmt, ##__VA_ARGS__);			\
 } while (0)
 
 /* errors debug print */
-#define BNX2X_DBG_ERR(__fmt, __args...)				\
+#define BNX2X_DBG_ERR(fmt, ...)					\
 do {								\
 	if (netif_msg_probe(bp))				\
-		pr_err("[%s:%d(%s)]" __fmt,			\
+		pr_err("[%s:%d(%s)]" fmt,			\
 		       __func__, __LINE__,			\
 		       bp->dev ? (bp->dev->name) : "?",		\
-		       ##__args);				\
+		       ##__VA_ARGS__);				\
 } while (0)
 
 /* for errors (never masked) */
-#define BNX2X_ERR(__fmt, __args...)				\
+#define BNX2X_ERR(fmt, ...)					\
 do {								\
-	pr_err("[%s:%d(%s)]" __fmt,				\
+	pr_err("[%s:%d(%s)]" fmt,				\
 	       __func__, __LINE__,				\
 	       bp->dev ? (bp->dev->name) : "?",			\
-	       ##__args);					\
-	} while (0)
+	       ##__VA_ARGS__);					\
+} while (0)
 
-#define BNX2X_ERROR(__fmt, __args...) do { \
-	pr_err("[%s:%d]" __fmt, __func__, __LINE__, ##__args); \
-	} while (0)
+#define BNX2X_ERROR(fmt, ...)					\
+	pr_err("[%s:%d]" fmt, __func__, __LINE__, ##__VA_ARGS__)
 
 
 /* before we have a dev->name use dev_info() */
-#define BNX2X_DEV_INFO(__fmt, __args...)			 \
+#define BNX2X_DEV_INFO(fmt, ...)				 \
 do {								 \
 	if (netif_msg_probe(bp))				 \
-		dev_info(&bp->pdev->dev, __fmt, ##__args);	 \
+		dev_info(&bp->pdev->dev, fmt, ##__VA_ARGS__);	 \
 } while (0)
 
 #ifdef BNX2X_STOP_ON_ERROR
 void bnx2x_int_disable(struct bnx2x *bp);
-#define bnx2x_panic() do { \
-		bp->panic = 1; \
-		BNX2X_ERR("driver assert\n"); \
-		bnx2x_int_disable(bp); \
-		bnx2x_panic_dump(bp); \
-	} while (0)
+#define bnx2x_panic()				\
+do {						\
+	bp->panic = 1;				\
+	BNX2X_ERR("driver assert\n");		\
+	bnx2x_int_disable(bp);			\
+	bnx2x_panic_dump(bp);			\
+} while (0)
 #else
-#define bnx2x_panic() do { \
-		bp->panic = 1; \
-		BNX2X_ERR("driver assert\n"); \
-		bnx2x_panic_dump(bp); \
-	} while (0)
+#define bnx2x_panic()				\
+do {						\
+	bp->panic = 1;				\
+	BNX2X_ERR("driver assert\n");		\
+	bnx2x_panic_dump(bp);			\
+} while (0)
 #endif
 
 #define bnx2x_mc_addr(ha)      ((ha)->addr)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 3254b9e..23b37dd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -15,6 +15,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
 #include <linux/interrupt.h>
@@ -3369,7 +3371,7 @@ int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 	struct bnx2x *bp = netdev_priv(dev);
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
+		pr_err("Handling parity error recovery. Try again later\n");
 		return -EAGAIN;
 	}
 
@@ -3495,7 +3497,7 @@ int bnx2x_resume(struct pci_dev *pdev)
 	bp = netdev_priv(dev);
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
+		pr_err("Handling parity error recovery. Try again later\n");
 		return -EAGAIN;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 38b5ca5..9525b93 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -16,6 +16,9 @@
  * Written by: Dmitry Kravkov
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/errno.h>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 2218630..767c229 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -14,6 +14,9 @@
  * Statistics and Link management by Yitchak Gertner
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
@@ -239,9 +242,9 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->maxrxpkt = 0;
 
 	DP(NETIF_MSG_LINK, "ethtool_cmd: cmd %d\n"
-	   DP_LEVEL "  supported 0x%x  advertising 0x%x  speed %u\n"
-	   DP_LEVEL "  duplex %d  port %d  phy_address %d  transceiver %d\n"
-	   DP_LEVEL "  autoneg %d  maxtxpkt %d  maxrxpkt %d\n",
+	   "  supported 0x%x  advertising 0x%x  speed %u\n"
+	   "  duplex %d  port %d  phy_address %d  transceiver %d\n"
+	   "  autoneg %d  maxtxpkt %d  maxrxpkt %d\n",
 	   cmd->cmd, cmd->supported, cmd->advertising,
 	   ethtool_cmd_speed(cmd),
 	   cmd->duplex, cmd->port, cmd->phy_address, cmd->transceiver,
@@ -482,7 +485,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	DP(NETIF_MSG_LINK, "req_line_speed %d\n"
-	   DP_LEVEL "  req_duplex %d  advertising 0x%x\n",
+	   "  req_duplex %d  advertising 0x%x\n",
 	   bp->link_params.req_line_speed[cfg_idx],
 	   bp->link_params.req_duplex[cfg_idx],
 	   bp->port.advertising[cfg_idx]);
@@ -1028,7 +1031,7 @@ static int bnx2x_get_eeprom(struct net_device *dev,
 		return -EAGAIN;
 
 	DP(BNX2X_MSG_NVM, "ethtool_eeprom: cmd %d\n"
-	   DP_LEVEL "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
+	   "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
 	   eeprom->cmd, eeprom->magic, eeprom->offset, eeprom->offset,
 	   eeprom->len, eeprom->len);
 
@@ -1199,7 +1202,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 		return -EAGAIN;
 
 	DP(BNX2X_MSG_NVM, "ethtool_eeprom: cmd %d\n"
-	   DP_LEVEL "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
+	   "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
 	   eeprom->cmd, eeprom->magic, eeprom->offset, eeprom->offset,
 	   eeprom->len, eeprom->len);
 
@@ -1328,7 +1331,7 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
+		pr_err("Handling parity error recovery. Try again later\n");
 		return -EAGAIN;
 	}
 
@@ -1359,7 +1362,7 @@ static void bnx2x_get_pauseparam(struct net_device *dev,
 			    BNX2X_FLOW_CTRL_TX);
 
 	DP(NETIF_MSG_LINK, "ethtool_pauseparam: cmd %d\n"
-	   DP_LEVEL "  autoneg %d  rx_pause %d  tx_pause %d\n",
+	   "  autoneg %d  rx_pause %d  tx_pause %d\n",
 	   epause->cmd, epause->autoneg, epause->rx_pause, epause->tx_pause);
 }
 
@@ -1372,7 +1375,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 		return 0;
 
 	DP(NETIF_MSG_LINK, "ethtool_pauseparam: cmd %d\n"
-	   DP_LEVEL "  autoneg %d  rx_pause %d  tx_pause %d\n",
+	   "  autoneg %d  rx_pause %d  tx_pause %d\n",
 	   epause->cmd, epause->autoneg, epause->rx_pause, epause->tx_pause);
 
 	bp->link_params.req_flow_ctrl[cfg_idx] = BNX2X_FLOW_CTRL_AUTO;
@@ -1970,7 +1973,7 @@ static void bnx2x_self_test(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	u8 is_serdes;
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
+		pr_err("Handling parity error recovery. Try again later\n");
 		etest->flags |= ETH_TEST_FL_FAILED;
 		return;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e899e87..f90e3fa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -15,6 +15,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
@@ -350,17 +352,15 @@ static void bnx2x_dp_dmae(struct bnx2x *bp, struct dmae_command *dmae,
 	default:
 		if (src_type == DMAE_CMD_SRC_PCI)
 			DP(msglvl, "DMAE: opcode 0x%08x\n"
-			   DP_LEVEL "src_addr [%x:%08x]  len [%d * 4]  "
-				    "dst_addr [none]\n"
-			   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
+			   "src_addr [%x:%08x]  len [%d * 4]  dst_addr [none]\n"
+			   "comp_addr [%x:%08x]  comp_val 0x%08x\n",
 			   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
 			   dmae->len, dmae->comp_addr_hi, dmae->comp_addr_lo,
 			   dmae->comp_val);
 		else
 			DP(msglvl, "DMAE: opcode 0x%08x\n"
-			   DP_LEVEL "src_addr [%08x]  len [%d * 4]  "
-				    "dst_addr [none]\n"
-			   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
+			   "src_addr [%08x]  len [%d * 4]  dst_addr [none]\n"
+			   "comp_addr [%x:%08x]  comp_val 0x%08x\n",
 			   dmae->opcode, dmae->src_addr_lo >> 2,
 			   dmae->len, dmae->comp_addr_hi, dmae->comp_addr_lo,
 			   dmae->comp_val);
@@ -789,18 +789,15 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 	BNX2X_ERR("     def (");
 	for (i = 0; i < HC_SP_SB_MAX_INDICES; i++)
 		pr_cont("0x%x%s",
-		       bp->def_status_blk->sp_sb.index_values[i],
-		       (i == HC_SP_SB_MAX_INDICES - 1) ? ")  " : " ");
+			bp->def_status_blk->sp_sb.index_values[i],
+			(i == HC_SP_SB_MAX_INDICES - 1) ? ")  " : " ");
 
 	for (i = 0; i < sizeof(struct hc_sp_status_block_data)/sizeof(u32); i++)
 		*((u32 *)&sp_sb_data + i) = REG_RD(bp, BAR_CSTRORM_INTMEM +
 			CSTORM_SP_STATUS_BLOCK_DATA_OFFSET(func) +
 			i*sizeof(u32));
 
-	pr_cont("igu_sb_id(0x%x)  igu_seg_id(0x%x) "
-			 "pf_id(0x%x)  vnic_id(0x%x)  "
-			 "vf_id(0x%x)  vf_valid (0x%x) "
-			 "state(0x%x)\n",
+	pr_cont("igu_sb_id(0x%x)  igu_seg_id(0x%x) pf_id(0x%x)  vnic_id(0x%x)  vf_id(0x%x)  vf_valid (0x%x) state(0x%x)\n",
 	       sp_sb_data.igu_sb_id,
 	       sp_sb_data.igu_seg_id,
 	       sp_sb_data.p_func.pf_id,
@@ -3721,9 +3718,7 @@ static inline void bnx2x_clear_load_cnt(struct bnx2x *bp)
 
 static inline void _print_next_block(int idx, const char *blk)
 {
-	if (idx)
-		pr_cont(", ");
-	pr_cont("%s", blk);
+	pr_cont("%s%s", idx ? ", " : "", blk);
 }
 
 static inline int bnx2x_check_blocks_with_parity0(u32 sig, int par_num,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 1f88c19..0440425 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -16,6 +16,9 @@
  * Written by: Vladislav Zolotarov
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/crc32.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 771f680..628f7b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -14,6 +14,9 @@
  * Statistics and Link management by Yitchak Gertner
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "bnx2x_stats.h"
 #include "bnx2x_cmn.h"
 
@@ -1194,14 +1197,13 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 			struct bnx2x_fastpath *fp = &bp->fp[i];
 			struct bnx2x_eth_q_stats *qstats = &fp->eth_q_stats;
 
-			printk(KERN_DEBUG "%s: rx usage(%4u)  *rx_cons_sb(%u)"
-					  "  rx pkt(%lu)  rx calls(%lu %lu)\n",
-			       fp->name, (le16_to_cpu(*fp->rx_cons_sb) -
-			       fp->rx_comp_cons),
-			       le16_to_cpu(*fp->rx_cons_sb),
-			       bnx2x_hilo(&qstats->
-					  total_unicast_packets_received_hi),
-			       fp->rx_calls, fp->rx_pkt);
+			pr_debug("%s: rx usage(%4u)  *rx_cons_sb(%u)  rx pkt(%lu)  rx calls(%lu %lu)\n",
+				 fp->name, (le16_to_cpu(*fp->rx_cons_sb) -
+					    fp->rx_comp_cons),
+				 le16_to_cpu(*fp->rx_cons_sb),
+				 bnx2x_hilo(&qstats->
+					    total_unicast_packets_received_hi),
+				 fp->rx_calls, fp->rx_pkt);
 		}
 
 		for_each_eth_queue(bp, i) {
@@ -1210,27 +1212,25 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 			struct bnx2x_eth_q_stats *qstats = &fp->eth_q_stats;
 			struct netdev_queue *txq;
 
-			printk(KERN_DEBUG "%s: tx pkt(%lu) (Xoff events %u)",
-				fp->name, bnx2x_hilo(
-				&qstats->total_unicast_packets_transmitted_hi),
-				qstats->driver_xoff);
+			pr_debug("%s: tx pkt(%lu) (Xoff events %u)",
+				 fp->name,
+				 bnx2x_hilo(
+					 &qstats->total_unicast_packets_transmitted_hi),
+				 qstats->driver_xoff);
 
 			for_each_cos_in_tx_queue(fp, cos) {
 				txdata = &fp->txdata[cos];
 				txq = netdev_get_tx_queue(bp->dev,
 						FP_COS_TO_TXQ(fp, cos));
 
-				printk(KERN_DEBUG "%d: tx avail(%4u)"
-				       "  *tx_cons_sb(%u)"
-				       "  tx calls (%lu)"
-				       "  %s\n",
-				       cos,
-				       bnx2x_tx_avail(bp, txdata),
-				       le16_to_cpu(*txdata->tx_cons_sb),
-				       txdata->tx_pkt,
-				       (netif_tx_queue_stopped(txq) ?
-					"Xoff" : "Xon")
-				       );
+				pr_debug("%d: tx avail(%4u)  *tx_cons_sb(%u)  tx calls (%lu)  %s\n",
+					 cos,
+					 bnx2x_tx_avail(bp, txdata),
+					 le16_to_cpu(*txdata->tx_cons_sb),
+					 txdata->tx_pkt,
+					 (netif_tx_queue_stopped(txq) ?
+					  "Xoff" : "Xon")
+					);
 			}
 		}
 	}
-- 
1.7.6.405.gc1be0
