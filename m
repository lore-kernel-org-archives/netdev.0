From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/9] s2io.c: Make more conforming to normal kernel style
Date: Mon, 24 Aug 2009 20:29:44 -0700
Message-ID: <7ec189a56b7f7a43a9e4c03524c4c47c24a56fb4.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1357 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754350AbZHYDjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 23:39:06 -0400
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Still has a few long lines.

checkpatch was:
	total: 263 errors, 53 warnings, 8751 lines checked
is:
	total: 4 errors, 35 warnings, 8767 lines checked

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c | 2232 ++++++++++++++++++++++++++--------------------------
 1 files changed, 1124 insertions(+), 1108 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 134cdb3..003dd8c 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1,7 +1,7 @@
 /************************************************************************
  * s2io.c: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
  * Copyright(c) 2002-2007 Neterion Inc.
-
+ *
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
  * Drivers based on or derived from this code fall under the GPL and must
@@ -75,11 +75,11 @@
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
+#include <linux/uaccess.h>
+#include <linux/io.h>
 #include <net/tcp.h>
 
 #include <asm/system.h>
-#include <asm/uaccess.h>
-#include <asm/io.h>
 #include <asm/div64.h>
 #include <asm/irq.h>
 
@@ -93,15 +93,15 @@
 static char s2io_driver_name[] = "Neterion";
 static char s2io_driver_version[] = DRV_VERSION;
 
-static int rxd_size[2] = {32,48};
-static int rxd_count[2] = {127,85};
+static int rxd_size[2] = {32, 48};
+static int rxd_count[2] = {127, 85};
 
 static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
 {
 	int ret;
 
 	ret = ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
-		(GET_RXD_MARKER(rxdp->Control_2) != THE_RXD_MARK));
+	       (GET_RXD_MARKER(rxdp->Control_2) != THE_RXD_MARK));
 
 	return ret;
 }
@@ -111,15 +111,15 @@ static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
  * problem, 600B, 600C, 600D, 640B, 640C and 640D.
  * macro below identifies these cards given the subsystem_id.
  */
-#define CARDS_WITH_FAULTY_LINK_INDICATORS(dev_type, subid) \
-	(dev_type == XFRAME_I_DEVICE) ?			\
-		((((subid >= 0x600B) && (subid <= 0x600D)) || \
-		 ((subid >= 0x640B) && (subid <= 0x640D))) ? 1 : 0) : 0
+#define CARDS_WITH_FAULTY_LINK_INDICATORS(dev_type, subid)		\
+	(dev_type == XFRAME_I_DEVICE) ?					\
+	((((subid >= 0x600B) && (subid <= 0x600D)) ||			\
+	  ((subid >= 0x640B) && (subid <= 0x640D))) ? 1 : 0) : 0
 
 #define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT | \
 				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))
 
-static inline int is_s2io_card_up(const struct s2io_nic * sp)
+static inline int is_s2io_card_up(const struct s2io_nic *sp)
 {
 	return test_bit(__S2IO_STATE_CARD_UP, &sp->state);
 }
@@ -328,20 +328,20 @@ static const char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 #define S2IO_ENHANCED_STAT_LEN	ARRAY_SIZE(ethtool_enhanced_stats_keys)
 #define S2IO_DRIVER_STAT_LEN	ARRAY_SIZE(ethtool_driver_stats_keys)
 
-#define XFRAME_I_STAT_LEN (S2IO_XENA_STAT_LEN + S2IO_DRIVER_STAT_LEN )
-#define XFRAME_II_STAT_LEN (XFRAME_I_STAT_LEN + S2IO_ENHANCED_STAT_LEN )
+#define XFRAME_I_STAT_LEN (S2IO_XENA_STAT_LEN + S2IO_DRIVER_STAT_LEN)
+#define XFRAME_II_STAT_LEN (XFRAME_I_STAT_LEN + S2IO_ENHANCED_STAT_LEN)
 
-#define XFRAME_I_STAT_STRINGS_LEN ( XFRAME_I_STAT_LEN * ETH_GSTRING_LEN )
-#define XFRAME_II_STAT_STRINGS_LEN ( XFRAME_II_STAT_LEN * ETH_GSTRING_LEN )
+#define XFRAME_I_STAT_STRINGS_LEN (XFRAME_I_STAT_LEN * ETH_GSTRING_LEN)
+#define XFRAME_II_STAT_STRINGS_LEN (XFRAME_II_STAT_LEN * ETH_GSTRING_LEN)
 
 #define S2IO_TEST_LEN	ARRAY_SIZE(s2io_gstrings)
-#define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN
+#define S2IO_STRINGS_LEN	(S2IO_TEST_LEN * ETH_GSTRING_LEN)
 
-#define S2IO_TIMER_CONF(timer, handle, arg, exp)		\
-			init_timer(&timer);			\
-			timer.function = handle;		\
-			timer.data = (unsigned long) arg;	\
-			mod_timer(&timer, (jiffies + exp))	\
+#define S2IO_TIMER_CONF(timer, handle, arg, exp)	\
+	init_timer(&timer);				\
+	timer.function = handle;			\
+	timer.data = (unsigned long)arg;		\
+	mod_timer(&timer, (jiffies + exp))		\
 
 /* copy mac addr to def_mac_addr array */
 static void do_s2io_copy_mac_addr(struct s2io_nic *sp, int offset, u64 mac_addr)
@@ -507,11 +507,11 @@ S2IO_PARM_INT(ufo, 0);
 S2IO_PARM_INT(vlan_tag_strip, NO_STRIP_IN_PROMISC);
 
 static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
-    {DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
+{DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
 static unsigned int rx_ring_sz[MAX_RX_RINGS] =
-    {[0 ...(MAX_RX_RINGS - 1)] = SMALL_BLK_CNT};
+{[0 ...(MAX_RX_RINGS - 1)] = SMALL_BLK_CNT};
 static unsigned int rts_frm_len[MAX_RX_RINGS] =
-    {[0 ...(MAX_RX_RINGS - 1)] = 0 };
+{[0 ...(MAX_RX_RINGS - 1)] = 0 };
 
 module_param_array(tx_fifo_len, uint, NULL, 0);
 module_param_array(rx_ring_sz, uint, NULL, 0);
@@ -527,9 +527,9 @@ static struct pci_device_id s2io_tbl[] __devinitdata = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_UNI,
 	 PCI_ANY_ID, PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_WIN,
-         PCI_ANY_ID, PCI_ANY_ID},
-        {PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_UNI,
-         PCI_ANY_ID, PCI_ANY_ID},
+	 PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_UNI,
+	 PCI_ANY_ID, PCI_ANY_ID},
 	{0,}
 };
 
@@ -542,11 +542,11 @@ static struct pci_error_handlers s2io_err_handler = {
 };
 
 static struct pci_driver s2io_driver = {
-      .name = "S2IO",
-      .id_table = s2io_tbl,
-      .probe = s2io_init_nic,
-      .remove = __devexit_p(s2io_rem_nic),
-      .err_handler = &s2io_err_handler,
+	.name = "S2IO",
+	.id_table = s2io_tbl,
+	.probe = s2io_init_nic,
+	.remove = __devexit_p(s2io_rem_nic),
+	.err_handler = &s2io_err_handler,
 };
 
 /* A simplifier macro used both by init and free shared_mem Fns(). */
@@ -655,7 +655,8 @@ static int init_shared_mem(struct s2io_nic *nic)
 	}
 	if (size > MAX_AVAILABLE_TXDS) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested TxDs too high, ");
-		DBG_PRINT(ERR_DBG, "Requested: %d, max supported: 8192\n", size);
+		DBG_PRINT(ERR_DBG, "Requested: %d, max supported: 8192\n",
+			  size);
 		return -EINVAL;
 	}
 
@@ -671,7 +672,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 			DBG_PRINT(ERR_DBG, "s2io: Invalid fifo len (%d)", size);
 			DBG_PRINT(ERR_DBG, "for fifo %d\n", i);
 			DBG_PRINT(ERR_DBG, "s2io: Legal values for fifo len"
-				"are 2 to 8192\n");
+				  "are 2 to 8192\n");
 			return -EINVAL;
 		}
 	}
@@ -687,8 +688,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 
 		fifo->list_info = kzalloc(list_holder_size, GFP_KERNEL);
 		if (!fifo->list_info) {
-			DBG_PRINT(INFO_DBG,
-				  "Malloc failed for list_info\n");
+			DBG_PRINT(INFO_DBG, "Malloc failed for list_info\n");
 			return -ENOMEM;
 		}
 		mem_allocated += list_holder_size;
@@ -715,8 +715,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 			tmp_v = pci_alloc_consistent(nic->pdev,
 						     PAGE_SIZE, &tmp_p);
 			if (!tmp_v) {
-				DBG_PRINT(INFO_DBG,
-					  "pci_alloc_consistent ");
+				DBG_PRINT(INFO_DBG, "pci_alloc_consistent ");
 				DBG_PRINT(INFO_DBG, "failed for TxDL\n");
 				return -ENOMEM;
 			}
@@ -728,15 +727,17 @@ static int init_shared_mem(struct s2io_nic *nic)
 			if (!tmp_p) {
 				mac_control->zerodma_virt_addr = tmp_v;
 				DBG_PRINT(INIT_DBG,
-				"%s: Zero DMA address for TxDL. ", dev->name);
+					  "%s: Zero DMA address for TxDL. ",
+					  dev->name);
 				DBG_PRINT(INIT_DBG,
-				"Virtual address %p\n", tmp_v);
+					  "Virtual address %p\n", tmp_v);
 				tmp_v = pci_alloc_consistent(nic->pdev,
-						     PAGE_SIZE, &tmp_p);
+							     PAGE_SIZE, &tmp_p);
 				if (!tmp_v) {
 					DBG_PRINT(INFO_DBG,
-					  "pci_alloc_consistent ");
-					DBG_PRINT(INFO_DBG, "failed for TxDL\n");
+						  "pci_alloc_consistent ");
+					DBG_PRINT(INFO_DBG,
+						  "failed for TxDL\n");
 					return -ENOMEM;
 				}
 				mem_allocated += PAGE_SIZE;
@@ -746,9 +747,9 @@ static int init_shared_mem(struct s2io_nic *nic)
 				if (l == tx_cfg->fifo_len)
 					break;
 				fifo->list_info[l].list_virt_addr =
-				    tmp_v + (k * lst_size);
+					tmp_v + (k * lst_size);
 				fifo->list_info[l].list_phy_addr =
-				    tmp_p + (k * lst_size);
+					tmp_p + (k * lst_size);
 				k++;
 			}
 		}
@@ -779,7 +780,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 		}
 		size += rx_cfg->num_rxd;
 		ring->block_count = rx_cfg->num_rxd /
-			(rxd_count[nic->rxd_mode] + 1 );
+			(rxd_count[nic->rxd_mode] + 1);
 		ring->pkt_cnt = rx_cfg->num_rxd - ring->block_count;
 	}
 	if (nic->rxd_mode == RXD_MODE_1)
@@ -808,7 +809,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 			int l;
 
 			rx_blocks = &ring->rx_blocks[j];
-			size = SIZE_OF_BLOCK; //size is always page size
+			size = SIZE_OF_BLOCK;	/* size is always page size */
 			tmp_v_addr = pci_alloc_consistent(nic->pdev, size,
 							  &tmp_p_addr);
 			if (tmp_v_addr == NULL) {
@@ -832,7 +833,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 			if (!rx_blocks->rxds)
 				return -ENOMEM;
 			mem_allocated += size;
-			for (l=0; l<rxd_count[nic->rxd_mode];l++) {
+			for (l = 0; l < rxd_count[nic->rxd_mode]; l++) {
 				rx_blocks->rxds[l].virt_addr =
 					rx_blocks->block_virt_addr +
 					(rxd_size[nic->rxd_mode] * l);
@@ -849,11 +850,11 @@ static int init_shared_mem(struct s2io_nic *nic)
 			tmp_p_addr = ring->rx_blocks[j].block_dma_addr;
 			tmp_p_addr_next = ring->rx_blocks[next].block_dma_addr;
 
-			pre_rxd_blk = (struct RxD_block *) tmp_v_addr;
+			pre_rxd_blk = (struct RxD_block *)tmp_v_addr;
 			pre_rxd_blk->reserved_2_pNext_RxD_block =
-			    (unsigned long) tmp_v_addr_next;
+				(unsigned long)tmp_v_addr_next;
 			pre_rxd_blk->pNext_RxD_Blk_physical =
-			    (u64) tmp_p_addr_next;
+				(u64)tmp_p_addr_next;
 		}
 	}
 	if (nic->rxd_mode == RXD_MODE_3B) {
@@ -866,7 +867,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 			struct ring_info *ring = &mac_control->rings[i];
 
 			blk_cnt = rx_cfg->num_rxd /
-				(rxd_count[nic->rxd_mode]+ 1);
+				(rxd_count[nic->rxd_mode] + 1);
 			size = sizeof(struct buffAdd *) * blk_cnt;
 			ring->ba = kmalloc(size, GFP_KERNEL);
 			if (!ring->ba)
@@ -890,18 +891,18 @@ static int init_shared_mem(struct s2io_nic *nic)
 					mem_allocated += size;
 					tmp = (unsigned long)ba->ba_0_org;
 					tmp += ALIGN_SIZE;
-					tmp &= ~((unsigned long) ALIGN_SIZE);
-					ba->ba_0 = (void *) tmp;
+					tmp &= ~((unsigned long)ALIGN_SIZE);
+					ba->ba_0 = (void *)tmp;
 
 					size = BUF1_LEN + ALIGN_SIZE;
 					ba->ba_1_org = kmalloc(size, GFP_KERNEL);
 					if (!ba->ba_1_org)
 						return -ENOMEM;
 					mem_allocated += size;
-					tmp = (unsigned long) ba->ba_1_org;
+					tmp = (unsigned long)ba->ba_1_org;
 					tmp += ALIGN_SIZE;
-					tmp &= ~((unsigned long) ALIGN_SIZE);
-					ba->ba_1 = (void *) tmp;
+					tmp &= ~((unsigned long)ALIGN_SIZE);
+					ba->ba_1 = (void *)tmp;
 					k++;
 				}
 			}
@@ -910,8 +911,9 @@ static int init_shared_mem(struct s2io_nic *nic)
 
 	/* Allocation and initialization of Statistics block */
 	size = sizeof(struct stat_block);
-	mac_control->stats_mem = pci_alloc_consistent
-	    (nic->pdev, size, &mac_control->stats_mem_phy);
+	mac_control->stats_mem =
+		pci_alloc_consistent(nic->pdev, size,
+				     &mac_control->stats_mem_phy);
 
 	if (!mac_control->stats_mem) {
 		/*
@@ -925,10 +927,10 @@ static int init_shared_mem(struct s2io_nic *nic)
 	mac_control->stats_mem_sz = size;
 
 	tmp_v_addr = mac_control->stats_mem;
-	mac_control->stats_info = (struct stat_block *) tmp_v_addr;
+	mac_control->stats_info = (struct stat_block *)tmp_v_addr;
 	memset(tmp_v_addr, 0, size);
 	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,
-		  (unsigned long long) tmp_p_addr);
+		  (unsigned long long)tmp_p_addr);
 	mac_control->stats_info->sw_stat.mem_allocated += mem_allocated;
 	return SUCCESS;
 }
@@ -959,7 +961,7 @@ static void free_shared_mem(struct s2io_nic *nic)
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	lst_size = (sizeof(struct TxD) * config->max_txds);
+	lst_size = sizeof(struct TxD) * config->max_txds;
 	lst_per_page = PAGE_SIZE / lst_size;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
@@ -981,7 +983,7 @@ static void free_shared_mem(struct s2io_nic *nic)
 					    fli->list_virt_addr,
 					    fli->list_phy_addr);
 			nic->mac_control.stats_info->sw_stat.mem_freed
-						+= PAGE_SIZE;
+				+= PAGE_SIZE;
 		}
 		/* If we got a zero DMA address during allocation,
 		 * free the page now
@@ -991,16 +993,17 @@ static void free_shared_mem(struct s2io_nic *nic)
 					    mac_control->zerodma_virt_addr,
 					    (dma_addr_t)0);
 			DBG_PRINT(INIT_DBG,
-			  	"%s: Freeing TxDL with zero DMA addr. ",
-				dev->name);
+				  "%s: Freeing TxDL with zero DMA addr. ",
+				  dev->name);
 			DBG_PRINT(INIT_DBG, "Virtual address %p\n",
-				mac_control->zerodma_virt_addr);
+				  mac_control->zerodma_virt_addr);
 			nic->mac_control.stats_info->sw_stat.mem_freed
-						+= PAGE_SIZE;
+				+= PAGE_SIZE;
 		}
 		kfree(fifo->list_info);
 		nic->mac_control.stats_info->sw_stat.mem_freed +=
-		(nic->config.tx_cfg[i].fifo_len *sizeof(struct list_info_hold));
+			nic->config.tx_cfg[i].fifo_len *
+			sizeof(struct list_info_hold);
 	}
 
 	size = SIZE_OF_BLOCK;
@@ -1018,7 +1021,7 @@ static void free_shared_mem(struct s2io_nic *nic)
 			nic->mac_control.stats_info->sw_stat.mem_freed += size;
 			kfree(ring->rx_blocks[j].rxds);
 			nic->mac_control.stats_info->sw_stat.mem_freed +=
-			( sizeof(struct rxd_info)* rxd_count[nic->rxd_mode]);
+				sizeof(struct rxd_info) * rxd_count[nic->rxd_mode];
 		}
 	}
 
@@ -1038,20 +1041,20 @@ static void free_shared_mem(struct s2io_nic *nic)
 					struct buffAdd *ba = &ring->ba[j][k];
 					kfree(ba->ba_0_org);
 					nic->mac_control.stats_info->sw_stat.\
-					mem_freed += (BUF0_LEN + ALIGN_SIZE);
+						mem_freed += (BUF0_LEN + ALIGN_SIZE);
 					kfree(ba->ba_1_org);
 					nic->mac_control.stats_info->sw_stat.\
-					mem_freed += (BUF1_LEN + ALIGN_SIZE);
+						mem_freed += (BUF1_LEN + ALIGN_SIZE);
 					k++;
 				}
 				kfree(ring->ba[j]);
 				nic->mac_control.stats_info->sw_stat.mem_freed +=
 					(sizeof(struct buffAdd) *
-					(rxd_count[nic->rxd_mode] + 1));
+					 (rxd_count[nic->rxd_mode] + 1));
 			}
 			kfree(ring->ba);
 			nic->mac_control.stats_info->sw_stat.mem_freed +=
-			(sizeof(struct buffAdd *) * blk_cnt);
+				(sizeof(struct buffAdd *) * blk_cnt);
 		}
 	}
 
@@ -1089,7 +1092,7 @@ static int s2io_verify_pci_mode(struct s2io_nic *nic)
 	val64 = readq(&bar0->pci_mode);
 	mode = (u8)GET_PCI_MODE(val64);
 
-	if ( val64 & PCI_MODE_UNKNOWN_MODE)
+	if (val64 & PCI_MODE_UNKNOWN_MODE)
 		return -1;      /* Unknown PCI mode */
 	return mode;
 }
@@ -1124,50 +1127,47 @@ static int s2io_print_pci_mode(struct s2io_nic *nic)
 	val64 = readq(&bar0->pci_mode);
 	mode = (u8)GET_PCI_MODE(val64);
 
-	if ( val64 & PCI_MODE_UNKNOWN_MODE)
+	if (val64 & PCI_MODE_UNKNOWN_MODE)
 		return -1;	/* Unknown PCI mode */
 
 	config->bus_speed = bus_speed[mode];
 
 	if (s2io_on_nec_bridge(nic->pdev)) {
 		DBG_PRINT(ERR_DBG, "%s: Device is on PCI-E bus\n",
-							nic->dev->name);
+			  nic->dev->name);
 		return mode;
 	}
 
-	if (val64 & PCI_MODE_32_BITS) {
-		DBG_PRINT(ERR_DBG, "%s: Device is on 32 bit ", nic->dev->name);
-	} else {
-		DBG_PRINT(ERR_DBG, "%s: Device is on 64 bit ", nic->dev->name);
-	}
+	DBG_PRINT(ERR_DBG, "%s: Device is on %d bit ",
+		  nic->dev->name, val64 & PCI_MODE_32_BITS ? 32 : 64);
 
-	switch(mode) {
-		case PCI_MODE_PCI_33:
-			DBG_PRINT(ERR_DBG, "33MHz PCI bus\n");
-			break;
-		case PCI_MODE_PCI_66:
-			DBG_PRINT(ERR_DBG, "66MHz PCI bus\n");
-			break;
-		case PCI_MODE_PCIX_M1_66:
-			DBG_PRINT(ERR_DBG, "66MHz PCIX(M1) bus\n");
-			break;
-		case PCI_MODE_PCIX_M1_100:
-			DBG_PRINT(ERR_DBG, "100MHz PCIX(M1) bus\n");
-			break;
-		case PCI_MODE_PCIX_M1_133:
-			DBG_PRINT(ERR_DBG, "133MHz PCIX(M1) bus\n");
-			break;
-		case PCI_MODE_PCIX_M2_66:
-			DBG_PRINT(ERR_DBG, "133MHz PCIX(M2) bus\n");
-			break;
-		case PCI_MODE_PCIX_M2_100:
-			DBG_PRINT(ERR_DBG, "200MHz PCIX(M2) bus\n");
-			break;
-		case PCI_MODE_PCIX_M2_133:
-			DBG_PRINT(ERR_DBG, "266MHz PCIX(M2) bus\n");
-			break;
-		default:
-			return -1;	/* Unsupported bus speed */
+	switch (mode) {
+	case PCI_MODE_PCI_33:
+		DBG_PRINT(ERR_DBG, "33MHz PCI bus\n");
+		break;
+	case PCI_MODE_PCI_66:
+		DBG_PRINT(ERR_DBG, "66MHz PCI bus\n");
+		break;
+	case PCI_MODE_PCIX_M1_66:
+		DBG_PRINT(ERR_DBG, "66MHz PCIX(M1) bus\n");
+		break;
+	case PCI_MODE_PCIX_M1_100:
+		DBG_PRINT(ERR_DBG, "100MHz PCIX(M1) bus\n");
+		break;
+	case PCI_MODE_PCIX_M1_133:
+		DBG_PRINT(ERR_DBG, "133MHz PCIX(M1) bus\n");
+		break;
+	case PCI_MODE_PCIX_M2_66:
+		DBG_PRINT(ERR_DBG, "133MHz PCIX(M2) bus\n");
+		break;
+	case PCI_MODE_PCIX_M2_100:
+		DBG_PRINT(ERR_DBG, "200MHz PCIX(M2) bus\n");
+		break;
+	case PCI_MODE_PCIX_M2_133:
+		DBG_PRINT(ERR_DBG, "266MHz PCIX(M2) bus\n");
+		break;
+	default:
+		return -1;	/* Unsupported bus speed */
 	}
 
 	return mode;
@@ -1205,9 +1205,9 @@ static int init_tti(struct s2io_nic *nic, int link)
 			val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0x2078);
 
 		val64 |= TTI_DATA1_MEM_TX_URNG_A(0xA) |
-				TTI_DATA1_MEM_TX_URNG_B(0x10) |
-				TTI_DATA1_MEM_TX_URNG_C(0x30) |
-				TTI_DATA1_MEM_TX_TIMER_AC_EN;
+			TTI_DATA1_MEM_TX_URNG_B(0x10) |
+			TTI_DATA1_MEM_TX_URNG_C(0x30) |
+			TTI_DATA1_MEM_TX_TIMER_AC_EN;
 		if (i == 0)
 			if (use_continuous_tx_intrs && (link == LINK_UP))
 				val64 |= TTI_DATA1_MEM_TX_TIMER_CI_EN;
@@ -1220,11 +1220,11 @@ static int init_tti(struct s2io_nic *nic, int link)
 				TTI_DATA2_MEM_TX_UFC_D(0x300);
 		} else {
 			if ((nic->config.tx_steering_type ==
-				TX_DEFAULT_STEERING) &&
-				(config->tx_fifo_num > 1) &&
-				(i >= nic->udp_fifo_idx) &&
-				(i < (nic->udp_fifo_idx +
-				nic->total_udp_fifos)))
+			     TX_DEFAULT_STEERING) &&
+			    (config->tx_fifo_num > 1) &&
+			    (i >= nic->udp_fifo_idx) &&
+			    (i < (nic->udp_fifo_idx +
+				  nic->total_udp_fifos)))
 				val64 = TTI_DATA2_MEM_TX_UFC_A(0x50) |
 					TTI_DATA2_MEM_TX_UFC_B(0x80) |
 					TTI_DATA2_MEM_TX_UFC_C(0x100) |
@@ -1238,12 +1238,14 @@ static int init_tti(struct s2io_nic *nic, int link)
 
 		writeq(val64, &bar0->tti_data2_mem);
 
-		val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD |
-				TTI_CMD_MEM_OFFSET(i);
+		val64 = TTI_CMD_MEM_WE |
+			TTI_CMD_MEM_STROBE_NEW_CMD |
+			TTI_CMD_MEM_OFFSET(i);
 		writeq(val64, &bar0->tti_command_mem);
 
 		if (wait_for_cmd_complete(&bar0->tti_command_mem,
-			TTI_CMD_MEM_STROBE_NEW_CMD, S2IO_BIT_RESET) != SUCCESS)
+					  TTI_CMD_MEM_STROBE_NEW_CMD,
+					  S2IO_BIT_RESET) != SUCCESS)
 			return FAILURE;
 	}
 
@@ -1277,8 +1279,8 @@ static int init_nic(struct s2io_nic *nic)
 	config = &nic->config;
 
 	/* to set the swapper controle on the card */
-	if(s2io_set_swapper(nic)) {
-		DBG_PRINT(ERR_DBG,"ERROR: Setting Swapper failed\n");
+	if (s2io_set_swapper(nic)) {
+		DBG_PRINT(ERR_DBG, "ERROR: Setting Swapper failed\n");
 		return -EIO;
 	}
 
@@ -1317,7 +1319,7 @@ static int init_nic(struct s2io_nic *nic)
 	val64 = readq(&bar0->mac_cfg);
 	val64 |= MAC_RMAC_BCAST_ENABLE;
 	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
-	writel((u32) val64, add);
+	writel((u32)val64, add);
 	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
 	writel((u32) (val64 >> 32), (add + 4));
 
@@ -1354,7 +1356,6 @@ static int init_nic(struct s2io_nic *nic)
 	writeq(val64, &bar0->tx_fifo_partition_2);
 	writeq(val64, &bar0->tx_fifo_partition_3);
 
-
 	for (i = 0, j = 0; i < config->tx_fifo_num; i++) {
 		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
 
@@ -1397,21 +1398,22 @@ static int init_nic(struct s2io_nic *nic)
 	 * Disable 4 PCCs for Xena1, 2 and 3 as per H/W bug
 	 * SXE-008 TRANSMIT DMA ARBITRATION ISSUE.
 	 */
-	if ((nic->device_type == XFRAME_I_DEVICE) &&
-		(nic->pdev->revision < 4))
+	if ((nic->device_type == XFRAME_I_DEVICE) && (nic->pdev->revision < 4))
 		writeq(PCC_ENABLE_FOUR, &bar0->pcc_enable);
 
 	val64 = readq(&bar0->tx_fifo_partition_0);
 	DBG_PRINT(INIT_DBG, "Fifo partition at: 0x%p is: 0x%llx\n",
-		  &bar0->tx_fifo_partition_0, (unsigned long long) val64);
+		  &bar0->tx_fifo_partition_0, (unsigned long long)val64);
 
 	/*
 	 * Initialization of Tx_PA_CONFIG register to ignore packet
 	 * integrity checking.
 	 */
 	val64 = readq(&bar0->tx_pa_cfg);
-	val64 |= TX_PA_CFG_IGNORE_FRM_ERR | TX_PA_CFG_IGNORE_SNAP_OUI |
-	    TX_PA_CFG_IGNORE_LLC_CTRL | TX_PA_CFG_IGNORE_L2_ERR;
+	val64 |= TX_PA_CFG_IGNORE_FRM_ERR |
+		TX_PA_CFG_IGNORE_SNAP_OUI |
+		TX_PA_CFG_IGNORE_LLC_CTRL |
+		TX_PA_CFG_IGNORE_L2_ERR;
 	writeq(val64, &bar0->tx_pa_cfg);
 
 	/* Rx DMA intialization. */
@@ -1703,7 +1705,7 @@ static int init_nic(struct s2io_nic *nic)
 		 */
 		if (rts_frm_len[i] != 0) {
 			writeq(MAC_RTS_FRM_LEN_SET(rts_frm_len[i]),
-				&bar0->rts_frm_len_n[i]);
+			       &bar0->rts_frm_len_n[i]);
 		}
 	}
 
@@ -1711,7 +1713,7 @@ static int init_nic(struct s2io_nic *nic)
 	for (i = 0; i < 64; i++) {
 		if (rts_ds_steer(nic, i, 0) == FAILURE) {
 			DBG_PRINT(ERR_DBG, "%s: failed rts ds steering",
-				dev->name);
+				  dev->name);
 			DBG_PRINT(ERR_DBG, "set on codepoint %d\n", i);
 			return -ENODEV;
 		}
@@ -1730,7 +1732,7 @@ static int init_nic(struct s2io_nic *nic)
 	 * bandwidth utilization.
 	 */
 	val64 = MAC_TX_LINK_UTIL_VAL(tmac_util_period) |
-	    MAC_RX_LINK_UTIL_VAL(rmac_util_period);
+		MAC_RX_LINK_UTIL_VAL(rmac_util_period);
 	writeq(val64, &bar0->mac_link_util);
 
 	/*
@@ -1753,24 +1755,26 @@ static int init_nic(struct s2io_nic *nic)
 	} else
 		val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF);
 	val64 |= RTI_DATA1_MEM_RX_URNG_A(0xA) |
-		 RTI_DATA1_MEM_RX_URNG_B(0x10) |
-		 RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
+		RTI_DATA1_MEM_RX_URNG_B(0x10) |
+		RTI_DATA1_MEM_RX_URNG_C(0x30) |
+		RTI_DATA1_MEM_RX_TIMER_AC_EN;
 
 	writeq(val64, &bar0->rti_data1_mem);
 
 	val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
 		RTI_DATA2_MEM_RX_UFC_B(0x2) ;
 	if (nic->config.intr_type == MSI_X)
-	    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x20) | \
-			RTI_DATA2_MEM_RX_UFC_D(0x40));
+		val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x20) |
+			  RTI_DATA2_MEM_RX_UFC_D(0x40));
 	else
-	    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x40) | \
-			RTI_DATA2_MEM_RX_UFC_D(0x80));
+		val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x40) |
+			  RTI_DATA2_MEM_RX_UFC_D(0x80));
 	writeq(val64, &bar0->rti_data2_mem);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD
-				| RTI_CMD_MEM_OFFSET(i);
+		val64 = RTI_CMD_MEM_WE |
+			RTI_CMD_MEM_STROBE_NEW_CMD |
+			RTI_CMD_MEM_OFFSET(i);
 		writeq(val64, &bar0->rti_command_mem);
 
 		/*
@@ -1843,19 +1847,17 @@ static int init_nic(struct s2io_nic *nic)
 	 */
 	val64 = 0;
 	for (i = 0; i < 4; i++) {
-		val64 |=
-		    (((u64) 0xFF00 | nic->mac_control.
-		      mc_pause_threshold_q0q3)
-		     << (i * 2 * 8));
+		val64 |= (((u64)0xFF00 |
+			   nic->mac_control.mc_pause_threshold_q0q3)
+			  << (i * 2 * 8));
 	}
 	writeq(val64, &bar0->mc_pause_thresh_q0q3);
 
 	val64 = 0;
 	for (i = 0; i < 4; i++) {
-		val64 |=
-		    (((u64) 0xFF00 | nic->mac_control.
-		      mc_pause_threshold_q4q7)
-		     << (i * 2 * 8));
+		val64 |= (((u64)0xFF00 |
+			   nic->mac_control.mc_pause_threshold_q4q7)
+			  << (i * 2 * 8));
 	}
 	writeq(val64, &bar0->mc_pause_thresh_q4q7);
 
@@ -1918,10 +1920,10 @@ static void do_s2io_write_bits(u64 value, int flag, void __iomem *addr)
 
 	temp64 = readq(addr);
 
-	if(flag == ENABLE_INTRS)
-		temp64 &= ~((u64) value);
+	if (flag == ENABLE_INTRS)
+		temp64 &= ~((u64)value);
 	else
-		temp64 |= ((u64) value);
+		temp64 |= ((u64)value);
 	writeq(temp64, addr);
 }
 
@@ -1933,124 +1935,125 @@ static void en_dis_err_alarms(struct s2io_nic *nic, u16 mask, int flag)
 
 	writeq(DISABLE_ALL_INTRS, &bar0->general_int_mask);
 	if (mask & TX_DMA_INTR) {
-
 		gen_int_mask |= TXDMA_INT_M;
 
 		do_s2io_write_bits(TXDMA_TDA_INT | TXDMA_PFC_INT |
-				TXDMA_PCC_INT | TXDMA_TTI_INT |
-				TXDMA_LSO_INT | TXDMA_TPA_INT |
-				TXDMA_SM_INT, flag, &bar0->txdma_int_mask);
+				   TXDMA_PCC_INT | TXDMA_TTI_INT |
+				   TXDMA_LSO_INT | TXDMA_TPA_INT |
+				   TXDMA_SM_INT, flag, &bar0->txdma_int_mask);
 
 		do_s2io_write_bits(PFC_ECC_DB_ERR | PFC_SM_ERR_ALARM |
-				PFC_MISC_0_ERR | PFC_MISC_1_ERR |
-				PFC_PCIX_ERR | PFC_ECC_SG_ERR, flag,
-				&bar0->pfc_err_mask);
+				   PFC_MISC_0_ERR | PFC_MISC_1_ERR |
+				   PFC_PCIX_ERR | PFC_ECC_SG_ERR, flag,
+				   &bar0->pfc_err_mask);
 
 		do_s2io_write_bits(TDA_Fn_ECC_DB_ERR | TDA_SM0_ERR_ALARM |
-				TDA_SM1_ERR_ALARM | TDA_Fn_ECC_SG_ERR |
-				TDA_PCIX_ERR, flag, &bar0->tda_err_mask);
+				   TDA_SM1_ERR_ALARM | TDA_Fn_ECC_SG_ERR |
+				   TDA_PCIX_ERR, flag, &bar0->tda_err_mask);
 
 		do_s2io_write_bits(PCC_FB_ECC_DB_ERR | PCC_TXB_ECC_DB_ERR |
-				PCC_SM_ERR_ALARM | PCC_WR_ERR_ALARM |
-				PCC_N_SERR | PCC_6_COF_OV_ERR |
-				PCC_7_COF_OV_ERR | PCC_6_LSO_OV_ERR |
-				PCC_7_LSO_OV_ERR | PCC_FB_ECC_SG_ERR |
-				PCC_TXB_ECC_SG_ERR, flag, &bar0->pcc_err_mask);
+				   PCC_SM_ERR_ALARM | PCC_WR_ERR_ALARM |
+				   PCC_N_SERR | PCC_6_COF_OV_ERR |
+				   PCC_7_COF_OV_ERR | PCC_6_LSO_OV_ERR |
+				   PCC_7_LSO_OV_ERR | PCC_FB_ECC_SG_ERR |
+				   PCC_TXB_ECC_SG_ERR,
+				   flag, &bar0->pcc_err_mask);
 
 		do_s2io_write_bits(TTI_SM_ERR_ALARM | TTI_ECC_SG_ERR |
-				TTI_ECC_DB_ERR, flag, &bar0->tti_err_mask);
+				   TTI_ECC_DB_ERR, flag, &bar0->tti_err_mask);
 
 		do_s2io_write_bits(LSO6_ABORT | LSO7_ABORT |
-				LSO6_SM_ERR_ALARM | LSO7_SM_ERR_ALARM |
-				LSO6_SEND_OFLOW | LSO7_SEND_OFLOW,
-				flag, &bar0->lso_err_mask);
+				   LSO6_SM_ERR_ALARM | LSO7_SM_ERR_ALARM |
+				   LSO6_SEND_OFLOW | LSO7_SEND_OFLOW,
+				   flag, &bar0->lso_err_mask);
 
 		do_s2io_write_bits(TPA_SM_ERR_ALARM | TPA_TX_FRM_DROP,
-				flag, &bar0->tpa_err_mask);
+				   flag, &bar0->tpa_err_mask);
 
 		do_s2io_write_bits(SM_SM_ERR_ALARM, flag, &bar0->sm_err_mask);
-
 	}
 
 	if (mask & TX_MAC_INTR) {
 		gen_int_mask |= TXMAC_INT_M;
 		do_s2io_write_bits(MAC_INT_STATUS_TMAC_INT, flag,
-				&bar0->mac_int_mask);
+				   &bar0->mac_int_mask);
 		do_s2io_write_bits(TMAC_TX_BUF_OVRN | TMAC_TX_SM_ERR |
-				TMAC_ECC_SG_ERR | TMAC_ECC_DB_ERR |
-				TMAC_DESC_ECC_SG_ERR | TMAC_DESC_ECC_DB_ERR,
-				flag, &bar0->mac_tmac_err_mask);
+				   TMAC_ECC_SG_ERR | TMAC_ECC_DB_ERR |
+				   TMAC_DESC_ECC_SG_ERR | TMAC_DESC_ECC_DB_ERR,
+				   flag, &bar0->mac_tmac_err_mask);
 	}
 
 	if (mask & TX_XGXS_INTR) {
 		gen_int_mask |= TXXGXS_INT_M;
 		do_s2io_write_bits(XGXS_INT_STATUS_TXGXS, flag,
-				&bar0->xgxs_int_mask);
+				   &bar0->xgxs_int_mask);
 		do_s2io_write_bits(TXGXS_ESTORE_UFLOW | TXGXS_TX_SM_ERR |
-				TXGXS_ECC_SG_ERR | TXGXS_ECC_DB_ERR,
-				flag, &bar0->xgxs_txgxs_err_mask);
+				   TXGXS_ECC_SG_ERR | TXGXS_ECC_DB_ERR,
+				   flag, &bar0->xgxs_txgxs_err_mask);
 	}
 
 	if (mask & RX_DMA_INTR) {
 		gen_int_mask |= RXDMA_INT_M;
 		do_s2io_write_bits(RXDMA_INT_RC_INT_M | RXDMA_INT_RPA_INT_M |
-				RXDMA_INT_RDA_INT_M | RXDMA_INT_RTI_INT_M,
-				flag, &bar0->rxdma_int_mask);
+				   RXDMA_INT_RDA_INT_M | RXDMA_INT_RTI_INT_M,
+				   flag, &bar0->rxdma_int_mask);
 		do_s2io_write_bits(RC_PRCn_ECC_DB_ERR | RC_FTC_ECC_DB_ERR |
-				RC_PRCn_SM_ERR_ALARM | RC_FTC_SM_ERR_ALARM |
-				RC_PRCn_ECC_SG_ERR | RC_FTC_ECC_SG_ERR |
-				RC_RDA_FAIL_WR_Rn, flag, &bar0->rc_err_mask);
+				   RC_PRCn_SM_ERR_ALARM | RC_FTC_SM_ERR_ALARM |
+				   RC_PRCn_ECC_SG_ERR | RC_FTC_ECC_SG_ERR |
+				   RC_RDA_FAIL_WR_Rn, flag, &bar0->rc_err_mask);
 		do_s2io_write_bits(PRC_PCI_AB_RD_Rn | PRC_PCI_AB_WR_Rn |
-				PRC_PCI_AB_F_WR_Rn | PRC_PCI_DP_RD_Rn |
-				PRC_PCI_DP_WR_Rn | PRC_PCI_DP_F_WR_Rn, flag,
-				&bar0->prc_pcix_err_mask);
+				   PRC_PCI_AB_F_WR_Rn | PRC_PCI_DP_RD_Rn |
+				   PRC_PCI_DP_WR_Rn | PRC_PCI_DP_F_WR_Rn, flag,
+				   &bar0->prc_pcix_err_mask);
 		do_s2io_write_bits(RPA_SM_ERR_ALARM | RPA_CREDIT_ERR |
-				RPA_ECC_SG_ERR | RPA_ECC_DB_ERR, flag,
-				&bar0->rpa_err_mask);
+				   RPA_ECC_SG_ERR | RPA_ECC_DB_ERR, flag,
+				   &bar0->rpa_err_mask);
 		do_s2io_write_bits(RDA_RXDn_ECC_DB_ERR | RDA_FRM_ECC_DB_N_AERR |
-				RDA_SM1_ERR_ALARM | RDA_SM0_ERR_ALARM |
-				RDA_RXD_ECC_DB_SERR | RDA_RXDn_ECC_SG_ERR |
-				RDA_FRM_ECC_SG_ERR | RDA_MISC_ERR|RDA_PCIX_ERR,
-				flag, &bar0->rda_err_mask);
+				   RDA_SM1_ERR_ALARM | RDA_SM0_ERR_ALARM |
+				   RDA_RXD_ECC_DB_SERR | RDA_RXDn_ECC_SG_ERR |
+				   RDA_FRM_ECC_SG_ERR |
+				   RDA_MISC_ERR|RDA_PCIX_ERR,
+				   flag, &bar0->rda_err_mask);
 		do_s2io_write_bits(RTI_SM_ERR_ALARM |
-				RTI_ECC_SG_ERR | RTI_ECC_DB_ERR,
-				flag, &bar0->rti_err_mask);
+				   RTI_ECC_SG_ERR | RTI_ECC_DB_ERR,
+				   flag, &bar0->rti_err_mask);
 	}
 
 	if (mask & RX_MAC_INTR) {
 		gen_int_mask |= RXMAC_INT_M;
 		do_s2io_write_bits(MAC_INT_STATUS_RMAC_INT, flag,
-				&bar0->mac_int_mask);
-		interruptible = RMAC_RX_BUFF_OVRN | RMAC_RX_SM_ERR |
-				RMAC_UNUSED_INT | RMAC_SINGLE_ECC_ERR |
-				RMAC_DOUBLE_ECC_ERR;
+				   &bar0->mac_int_mask);
+		interruptible = (RMAC_RX_BUFF_OVRN | RMAC_RX_SM_ERR |
+				 RMAC_UNUSED_INT | RMAC_SINGLE_ECC_ERR |
+				 RMAC_DOUBLE_ECC_ERR);
 		if (s2io_link_fault_indication(nic) == MAC_RMAC_ERR_TIMER)
 			interruptible |= RMAC_LINK_STATE_CHANGE_INT;
 		do_s2io_write_bits(interruptible,
-				flag, &bar0->mac_rmac_err_mask);
+				   flag, &bar0->mac_rmac_err_mask);
 	}
 
-	if (mask & RX_XGXS_INTR)
-	{
+	if (mask & RX_XGXS_INTR) {
 		gen_int_mask |= RXXGXS_INT_M;
 		do_s2io_write_bits(XGXS_INT_STATUS_RXGXS, flag,
-				&bar0->xgxs_int_mask);
+				   &bar0->xgxs_int_mask);
 		do_s2io_write_bits(RXGXS_ESTORE_OFLOW | RXGXS_RX_SM_ERR, flag,
-				&bar0->xgxs_rxgxs_err_mask);
+				   &bar0->xgxs_rxgxs_err_mask);
 	}
 
 	if (mask & MC_INTR) {
 		gen_int_mask |= MC_INT_M;
-		do_s2io_write_bits(MC_INT_MASK_MC_INT, flag, &bar0->mc_int_mask);
+		do_s2io_write_bits(MC_INT_MASK_MC_INT,
+				   flag, &bar0->mc_int_mask);
 		do_s2io_write_bits(MC_ERR_REG_SM_ERR | MC_ERR_REG_ECC_ALL_SNG |
-				MC_ERR_REG_ECC_ALL_DBL | PLL_LOCK_N, flag,
-				&bar0->mc_err_mask);
+				   MC_ERR_REG_ECC_ALL_DBL | PLL_LOCK_N, flag,
+				   &bar0->mc_err_mask);
 	}
 	nic->general_int_mask = gen_int_mask;
 
 	/* Remove this line when alarm interrupts are enabled */
 	nic->general_int_mask = 0;
 }
+
 /**
  *  en_dis_able_nic_intrs - Enable or Disable the interrupts
  *  @nic: device private variable,
@@ -2082,11 +2085,11 @@ static void en_dis_able_nic_intrs(struct s2io_nic *nic, u16 mask, int flag)
 			 * TODO
 			 */
 			if (s2io_link_fault_indication(nic) ==
-					LINK_UP_DOWN_INTERRUPT ) {
+			    LINK_UP_DOWN_INTERRUPT) {
 				do_s2io_write_bits(PIC_INT_GPIO, flag,
-						&bar0->pic_int_mask);
+						   &bar0->pic_int_mask);
 				do_s2io_write_bits(GPIO_INT_MASK_LINK_UP, flag,
-						&bar0->gpio_int_mask);
+						   &bar0->gpio_int_mask);
 			} else
 				writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
 		} else if (flag == DISABLE_INTRS) {
@@ -2133,7 +2136,7 @@ static void en_dis_able_nic_intrs(struct s2io_nic *nic, u16 mask, int flag)
 
 	temp64 = readq(&bar0->general_int_mask);
 	if (flag == ENABLE_INTRS)
-		temp64 &= ~((u64) intr_mask);
+		temp64 &= ~((u64)intr_mask);
 	else
 		temp64 = DISABLE_ALL_INTRS;
 	writeq(temp64, &bar0->general_int_mask);
@@ -2198,7 +2201,7 @@ static int verify_xena_quiescence(struct s2io_nic *sp)
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_RDMA_READY)) {
-	DBG_PRINT(ERR_DBG, "%s", "RDMA is not ready!");
+		DBG_PRINT(ERR_DBG, "%s", "RDMA is not ready!");
 		return 0;
 	}
 	if (!(val64 & ADAPTER_STATUS_PFC_READY)) {
@@ -2232,13 +2235,13 @@ static int verify_xena_quiescence(struct s2io_nic *sp)
 	 * not be asserted.
 	 */
 	if (!(val64 & ADAPTER_STATUS_P_PLL_LOCK) &&
-		sp->device_type == XFRAME_II_DEVICE && mode !=
-		PCI_MODE_PCI_33) {
+	    sp->device_type == XFRAME_II_DEVICE &&
+	    mode != PCI_MODE_PCI_33) {
 		DBG_PRINT(ERR_DBG, "%s", "P_PLL is not locked!");
 		return 0;
 	}
 	if (!((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-			ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
+	      ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
 		DBG_PRINT(ERR_DBG, "%s", "RC_PRC is not QUIESCENT!");
 		return 0;
 	}
@@ -2253,7 +2256,7 @@ static int verify_xena_quiescence(struct s2io_nic *sp)
  *
  */
 
-static void fix_mac_address(struct s2io_nic * sp)
+static void fix_mac_address(struct s2io_nic *sp)
 {
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64;
@@ -2295,7 +2298,7 @@ static int start_nic(struct s2io_nic *nic)
 	for (i = 0; i < config->rx_ring_num; i++) {
 		struct ring_info *ring = &mac_control->rings[i];
 
-		writeq((u64) ring->rx_blocks[0].block_dma_addr,
+		writeq((u64)ring->rx_blocks[0].block_dma_addr,
 		       &bar0->prc_rxd0_n[i]);
 
 		val64 = readq(&bar0->prc_ctrl_n[i]);
@@ -2349,7 +2352,7 @@ static int start_nic(struct s2io_nic *nic)
 	if (!verify_xena_quiescence(nic)) {
 		DBG_PRINT(ERR_DBG, "%s: device is not ready, ", dev->name);
 		DBG_PRINT(ERR_DBG, "Adapter status reads: 0x%llx\n",
-			  (unsigned long long) val64);
+			  (unsigned long long)val64);
 		return FAILURE;
 	}
 
@@ -2389,8 +2392,8 @@ static int start_nic(struct s2io_nic *nic)
 /**
  * s2io_txdl_getskb - Get the skb from txdl, unmap and return skb
  */
-static struct sk_buff *s2io_txdl_getskb(struct fifo_info *fifo_data, struct \
-					TxD *txdlp, int get_off)
+static struct sk_buff *s2io_txdl_getskb(struct fifo_info *fifo_data,
+					struct TxD *txdlp, int get_off)
 {
 	struct s2io_nic *nic = fifo_data->nic;
 	struct sk_buff *skb;
@@ -2399,22 +2402,18 @@ static struct sk_buff *s2io_txdl_getskb(struct fifo_info *fifo_data, struct \
 
 	txds = txdlp;
 	if (txds->Host_Control == (u64)(long)fifo_data->ufo_in_band_v) {
-		pci_unmap_single(nic->pdev, (dma_addr_t)
-			txds->Buffer_Pointer, sizeof(u64),
-			PCI_DMA_TODEVICE);
+		pci_unmap_single(nic->pdev, (dma_addr_t)txds->Buffer_Pointer,
+				 sizeof(u64), PCI_DMA_TODEVICE);
 		txds++;
 	}
 
-	skb = (struct sk_buff *) ((unsigned long)
-			txds->Host_Control);
+	skb = (struct sk_buff *)((unsigned long)txds->Host_Control);
 	if (!skb) {
 		memset(txdlp, 0, (sizeof(struct TxD) * fifo_data->max_txds));
 		return NULL;
 	}
-	pci_unmap_single(nic->pdev, (dma_addr_t)
-			 txds->Buffer_Pointer,
-			 skb->len - skb->data_len,
-			 PCI_DMA_TODEVICE);
+	pci_unmap_single(nic->pdev, (dma_addr_t)txds->Buffer_Pointer,
+			 skb->len - skb->data_len, PCI_DMA_TODEVICE);
 	frg_cnt = skb_shinfo(skb)->nr_frags;
 	if (frg_cnt) {
 		txds++;
@@ -2422,13 +2421,13 @@ static struct sk_buff *s2io_txdl_getskb(struct fifo_info *fifo_data, struct \
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[j];
 			if (!txds->Buffer_Pointer)
 				break;
-			pci_unmap_page(nic->pdev, (dma_addr_t)
-					txds->Buffer_Pointer,
+			pci_unmap_page(nic->pdev,
+				       (dma_addr_t)txds->Buffer_Pointer,
 				       frag->size, PCI_DMA_TODEVICE);
 		}
 	}
-	memset(txdlp,0, (sizeof(struct TxD) * fifo_data->max_txds));
-	return(skb);
+	memset(txdlp, 0, (sizeof(struct TxD) * fifo_data->max_txds));
+	return skb;
 }
 
 /**
@@ -2437,7 +2436,7 @@ static struct sk_buff *s2io_txdl_getskb(struct fifo_info *fifo_data, struct \
  *  Description:
  *  Free all queued Tx buffers.
  *  Return Value: void
-*/
+ */
 
 static void free_tx_buffers(struct s2io_nic *nic)
 {
@@ -2533,7 +2532,7 @@ static void stop_nic(struct s2io_nic *nic)
  *  SUCCESS on success or an appropriate -ve value on failure.
  */
 static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
-				int from_card_up)
+			   int from_card_up)
 {
 	struct sk_buff *skb;
 	struct RxD_t *rxdp;
@@ -2564,17 +2563,16 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 			rxd_index += (block_no * ring->rxd_count);
 
 		if ((block_no == block_no1) &&
-			(off == ring->rx_curr_get_info.offset) &&
-			(rxdp->Host_Control)) {
-			DBG_PRINT(INTR_DBG, "%s: Get and Put",
-				ring->dev->name);
+		    (off == ring->rx_curr_get_info.offset) &&
+		    (rxdp->Host_Control)) {
+			DBG_PRINT(INTR_DBG, "%s: Get and Put", ring->dev->name);
 			DBG_PRINT(INTR_DBG, " info equated\n");
 			goto end;
 		}
 		if (off && (off == ring->rxd_count)) {
 			ring->rx_curr_put_info.block_index++;
 			if (ring->rx_curr_put_info.block_index ==
-							ring->block_count)
+			    ring->block_count)
 				ring->rx_curr_put_info.block_index = 0;
 			block_no = ring->rx_curr_put_info.block_index;
 			off = 0;
@@ -2586,14 +2584,15 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 		}
 
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
-			((ring->rxd_mode == RXD_MODE_3B) &&
-				(rxdp->Control_2 & s2BIT(0)))) {
+		    ((ring->rxd_mode == RXD_MODE_3B) &&
+		     (rxdp->Control_2 & s2BIT(0)))) {
 			ring->rx_curr_put_info.offset = off;
 			goto end;
 		}
 		/* calculate size of skb based on ring mode */
-		size = ring->mtu + HEADER_ETHERNET_II_802_3_SIZE +
-				HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
+		size = ring->mtu +
+			HEADER_ETHERNET_II_802_3_SIZE +
+			HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
 		if (ring->rxd_mode == RXD_MODE_1)
 			size += NET_IP_ALIGN;
 		else
@@ -2601,7 +2600,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 
 		/* allocate skb */
 		skb = dev_alloc_skb(size);
-		if(!skb) {
+		if (!skb) {
 			DBG_PRINT(INFO_DBG, "%s: Out of ", ring->dev->name);
 			DBG_PRINT(INFO_DBG, "memory to allocate SKBs\n");
 			if (first_rxdp) {
@@ -2616,19 +2615,20 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 
 		if (ring->rxd_mode == RXD_MODE_1) {
 			/* 1 buffer mode - normal operation mode */
-			rxdp1 = (struct RxD1*)rxdp;
+			rxdp1 = (struct RxD1 *)rxdp;
 			memset(rxdp, 0, sizeof(struct RxD1));
 			skb_reserve(skb, NET_IP_ALIGN);
-			rxdp1->Buffer0_ptr = pci_map_single
-			    (ring->pdev, skb->data, size - NET_IP_ALIGN,
-				PCI_DMA_FROMDEVICE);
+			rxdp1->Buffer0_ptr =
+				pci_map_single(ring->pdev, skb->data,
+					       size - NET_IP_ALIGN,
+					       PCI_DMA_FROMDEVICE);
 			if (pci_dma_mapping_error(nic->pdev,
-						rxdp1->Buffer0_ptr))
+						  rxdp1->Buffer0_ptr))
 				goto pci_map_failed;
 
 			rxdp->Control_2 =
 				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
-			rxdp->Host_Control = (unsigned long) (skb);
+			rxdp->Host_Control = (unsigned long)skb;
 		} else if (ring->rxd_mode == RXD_MODE_3B) {
 			/*
 			 * 2 buffer mode -
@@ -2636,7 +2636,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 			 * byte aligned receive buffers.
 			 */
 
-			rxdp3 = (struct RxD3*)rxdp;
+			rxdp3 = (struct RxD3 *)rxdp;
 			/* save buffer pointers to avoid frequent dma mapping */
 			Buffer0_ptr = rxdp3->Buffer0_ptr;
 			Buffer1_ptr = rxdp3->Buffer1_ptr;
@@ -2647,7 +2647,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 
 			ba = &ring->ba[block_no][off];
 			skb_reserve(skb, BUF0_LEN);
-			tmp = (u64)(unsigned long) skb->data;
+			tmp = (u64)(unsigned long)skb->data;
 			tmp += ALIGN_SIZE;
 			tmp &= ~ALIGN_SIZE;
 			skb->data = (void *) (unsigned long)tmp;
@@ -2655,15 +2655,17 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 
 			if (from_card_up) {
 				rxdp3->Buffer0_ptr =
-				   pci_map_single(ring->pdev, ba->ba_0,
-					BUF0_LEN, PCI_DMA_FROMDEVICE);
-			if (pci_dma_mapping_error(nic->pdev,
-						rxdp3->Buffer0_ptr))
+					pci_map_single(ring->pdev, ba->ba_0,
+						       BUF0_LEN,
+						       PCI_DMA_FROMDEVICE);
+				if (pci_dma_mapping_error(nic->pdev,
+							  rxdp3->Buffer0_ptr))
 					goto pci_map_failed;
 			} else
 				pci_dma_sync_single_for_device(ring->pdev,
-				(dma_addr_t) rxdp3->Buffer0_ptr,
-				    BUF0_LEN, PCI_DMA_FROMDEVICE);
+							       (dma_addr_t)rxdp3->Buffer0_ptr,
+							       BUF0_LEN,
+							       PCI_DMA_FROMDEVICE);
 
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (ring->rxd_mode == RXD_MODE_3B) {
@@ -2673,34 +2675,35 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 				 * Buffer2 will have L3/L4 header plus
 				 * L4 payload
 				 */
-				rxdp3->Buffer2_ptr = pci_map_single
-				(ring->pdev, skb->data, ring->mtu + 4,
-						PCI_DMA_FROMDEVICE);
+				rxdp3->Buffer2_ptr = pci_map_single(ring->pdev,
+								    skb->data,
+								    ring->mtu + 4,
+								    PCI_DMA_FROMDEVICE);
 
 				if (pci_dma_mapping_error(nic->pdev,
-							rxdp3->Buffer2_ptr))
+							  rxdp3->Buffer2_ptr))
 					goto pci_map_failed;
 
 				if (from_card_up) {
 					rxdp3->Buffer1_ptr =
 						pci_map_single(ring->pdev,
-						ba->ba_1, BUF1_LEN,
-						PCI_DMA_FROMDEVICE);
+							       ba->ba_1,
+							       BUF1_LEN,
+							       PCI_DMA_FROMDEVICE);
 
 					if (pci_dma_mapping_error(nic->pdev,
-						rxdp3->Buffer1_ptr)) {
-						pci_unmap_single
-							(ring->pdev,
-						    (dma_addr_t)(unsigned long)
-							skb->data,
-							ring->mtu + 4,
-							PCI_DMA_FROMDEVICE);
+								  rxdp3->Buffer1_ptr)) {
+						pci_unmap_single(ring->pdev,
+								 (dma_addr_t)(unsigned long)
+								 skb->data,
+								 ring->mtu + 4,
+								 PCI_DMA_FROMDEVICE);
 						goto pci_map_failed;
 					}
 				}
 				rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
-								(ring->mtu + 4);
+					(ring->mtu + 4);
 			}
 			rxdp->Control_2 |= s2BIT(0);
 			rxdp->Host_Control = (unsigned long) (skb);
@@ -2724,7 +2727,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 		alloc_tab++;
 	}
 
-      end:
+end:
 	/* Transfer ownership of first descriptor to adapter just before
 	 * exiting. Before that, use memory barrier so that ownership
 	 * and other fields are seen by adapter correctly.
@@ -2735,6 +2738,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 	}
 
 	return SUCCESS;
+
 pci_map_failed:
 	stats->pci_map_fail_cnt++;
 	stats->mem_freed += skb->truesize;
@@ -2756,38 +2760,34 @@ static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
 	mac_control = &sp->mac_control;
 	for (j = 0 ; j < rxd_count[sp->rxd_mode]; j++) {
 		rxdp = mac_control->rings[ring_no].
-                                rx_blocks[blk].rxds[j].virt_addr;
-		skb = (struct sk_buff *)
-			((unsigned long) rxdp->Host_Control);
-		if (!skb) {
+			rx_blocks[blk].rxds[j].virt_addr;
+		skb = (struct sk_buff *)((unsigned long)rxdp->Host_Control);
+		if (!skb)
 			continue;
-		}
 		if (sp->rxd_mode == RXD_MODE_1) {
-			rxdp1 = (struct RxD1*)rxdp;
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				rxdp1->Buffer0_ptr,
-				dev->mtu +
-				HEADER_ETHERNET_II_802_3_SIZE
-				+ HEADER_802_2_SIZE +
-				HEADER_SNAP_SIZE,
-				PCI_DMA_FROMDEVICE);
+			rxdp1 = (struct RxD1 *)rxdp;
+			pci_unmap_single(sp->pdev,
+					 (dma_addr_t)rxdp1->Buffer0_ptr,
+					 dev->mtu +
+					 HEADER_ETHERNET_II_802_3_SIZE +
+					 HEADER_802_2_SIZE + HEADER_SNAP_SIZE,
+					 PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD1));
-		} else if(sp->rxd_mode == RXD_MODE_3B) {
-			rxdp3 = (struct RxD3*)rxdp;
-			ba = &mac_control->rings[ring_no].
-				ba[blk][j];
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				rxdp3->Buffer0_ptr,
-				BUF0_LEN,
-				PCI_DMA_FROMDEVICE);
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				rxdp3->Buffer1_ptr,
-				BUF1_LEN,
-				PCI_DMA_FROMDEVICE);
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				rxdp3->Buffer2_ptr,
-				dev->mtu + 4,
-				PCI_DMA_FROMDEVICE);
+		} else if (sp->rxd_mode == RXD_MODE_3B) {
+			rxdp3 = (struct RxD3 *)rxdp;
+			ba = &mac_control->rings[ring_no].ba[blk][j];
+			pci_unmap_single(sp->pdev,
+					 (dma_addr_t)rxdp3->Buffer0_ptr,
+					 BUF0_LEN,
+					 PCI_DMA_FROMDEVICE);
+			pci_unmap_single(sp->pdev,
+					 (dma_addr_t)rxdp3->Buffer1_ptr,
+					 BUF1_LEN,
+					 PCI_DMA_FROMDEVICE);
+			pci_unmap_single(sp->pdev,
+					 (dma_addr_t)rxdp3->Buffer2_ptr,
+					 dev->mtu + 4,
+					 PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD3));
 		}
 		sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
@@ -2819,7 +2819,7 @@ static void free_rx_buffers(struct s2io_nic *sp)
 		struct ring_info *ring = &mac_control->rings[i];
 
 		for (blk = 0; blk < rx_ring_sz[i]; blk++)
-			free_rxd_blk(sp,i,blk);
+			free_rxd_blk(sp, i, blk);
 
 		ring->rx_curr_put_info.block_index = 0;
 		ring->rx_curr_get_info.block_index = 0;
@@ -2886,6 +2886,7 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 	}
 	return pkts_processed;
 }
+
 static int s2io_poll_inta(struct napi_struct *napi, int budget)
 {
 	struct s2io_nic *nic = container_of(napi, struct s2io_nic, napi);
@@ -2999,8 +3000,8 @@ static int rx_intr_handler(struct ring_info *ring_data, int budget)
 	struct sk_buff *skb;
 	int pkt_cnt = 0, napi_pkts = 0;
 	int i;
-	struct RxD1* rxdp1;
-	struct RxD3* rxdp3;
+	struct RxD1 *rxdp1;
+	struct RxD3 *rxdp3;
 
 	get_info = ring_data->rx_curr_get_info;
 	get_block = get_info.block_index;
@@ -3016,10 +3017,10 @@ static int rx_intr_handler(struct ring_info *ring_data, int budget)
 		if ((get_block == put_block) &&
 		    (get_info.offset + 1) == put_info.offset) {
 			DBG_PRINT(INTR_DBG, "%s: Ring Full\n",
-				ring_data->dev->name);
+				  ring_data->dev->name);
 			break;
 		}
-		skb = (struct sk_buff *) ((unsigned long)rxdp->Host_Control);
+		skb = (struct sk_buff *)((unsigned long)rxdp->Host_Control);
 		if (skb == NULL) {
 			DBG_PRINT(ERR_DBG, "%s: The skb is ",
 				  ring_data->dev->name);
@@ -3027,30 +3028,31 @@ static int rx_intr_handler(struct ring_info *ring_data, int budget)
 			return 0;
 		}
 		if (ring_data->rxd_mode == RXD_MODE_1) {
-			rxdp1 = (struct RxD1*)rxdp;
+			rxdp1 = (struct RxD1 *)rxdp;
 			pci_unmap_single(ring_data->pdev, (dma_addr_t)
-				rxdp1->Buffer0_ptr,
-				ring_data->mtu +
-				HEADER_ETHERNET_II_802_3_SIZE +
-				HEADER_802_2_SIZE +
-				HEADER_SNAP_SIZE,
-				PCI_DMA_FROMDEVICE);
+					 rxdp1->Buffer0_ptr,
+					 ring_data->mtu +
+					 HEADER_ETHERNET_II_802_3_SIZE +
+					 HEADER_802_2_SIZE +
+					 HEADER_SNAP_SIZE,
+					 PCI_DMA_FROMDEVICE);
 		} else if (ring_data->rxd_mode == RXD_MODE_3B) {
-			rxdp3 = (struct RxD3*)rxdp;
-			pci_dma_sync_single_for_cpu(ring_data->pdev, (dma_addr_t)
-				rxdp3->Buffer0_ptr,
-				BUF0_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(ring_data->pdev, (dma_addr_t)
-				rxdp3->Buffer2_ptr,
-				ring_data->mtu + 4,
-				PCI_DMA_FROMDEVICE);
+			rxdp3 = (struct RxD3 *)rxdp;
+			pci_dma_sync_single_for_cpu(ring_data->pdev,
+						    (dma_addr_t)rxdp3->Buffer0_ptr,
+						    BUF0_LEN,
+						    PCI_DMA_FROMDEVICE);
+			pci_unmap_single(ring_data->pdev,
+					 (dma_addr_t)rxdp3->Buffer2_ptr,
+					 ring_data->mtu + 4,
+					 PCI_DMA_FROMDEVICE);
 		}
 		prefetch(skb->data);
 		rx_osm_handler(ring_data, rxdp);
 		get_info.offset++;
 		ring_data->rx_curr_get_info.offset = get_info.offset;
 		rxdp = ring_data->rx_blocks[get_block].
-				rxds[get_info.offset].virt_addr;
+			rxds[get_info.offset].virt_addr;
 		if (get_info.offset == rxd_count[ring_data->rxd_mode]) {
 			get_info.offset = 0;
 			ring_data->rx_curr_get_info.offset = get_info.offset;
@@ -3073,7 +3075,7 @@ static int rx_intr_handler(struct ring_info *ring_data, int budget)
 	}
 	if (ring_data->lro) {
 		/* Clear all LRO sessions before exiting */
-		for (i=0; i<MAX_LRO_SESSIONS; i++) {
+		for (i = 0; i < MAX_LRO_SESSIONS; i++) {
 			struct lro *lro = &ring_data->lro0_n[i];
 			if (lro->in_use) {
 				update_L3L4_header(ring_data->nic, lro);
@@ -3082,7 +3084,7 @@ static int rx_intr_handler(struct ring_info *ring_data, int budget)
 			}
 		}
 	}
-	return(napi_pkts);
+	return napi_pkts;
 }
 
 /**
@@ -3108,12 +3110,12 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 	u8 err_mask;
 
 	if (!spin_trylock_irqsave(&fifo_data->tx_lock, flags))
-			return;
+		return;
 
 	get_info = fifo_data->tx_curr_get_info;
 	memcpy(&put_info, &fifo_data->tx_curr_put_info, sizeof(put_info));
-	txdlp = (struct TxD *) fifo_data->list_info[get_info.offset].
-	    list_virt_addr;
+	txdlp = (struct TxD *)
+		fifo_data->list_info[get_info.offset].list_virt_addr;
 	while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&
 	       (get_info.offset != put_info.offset) &&
 	       (txdlp->Host_Control)) {
@@ -3123,44 +3125,43 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 			err = txdlp->Control_1 & TXD_T_CODE;
 			if (err & 0x1) {
 				nic->mac_control.stats_info->sw_stat.
-						parity_err_cnt++;
+					parity_err_cnt++;
 			}
 
 			/* update t_code statistics */
 			err_mask = err >> 48;
-			switch(err_mask) {
-				case 2:
-					nic->mac_control.stats_info->sw_stat.
-							tx_buf_abort_cnt++;
+			switch (err_mask) {
+			case 2:
+				nic->mac_control.stats_info->sw_stat.
+					tx_buf_abort_cnt++;
 				break;
 
-				case 3:
-					nic->mac_control.stats_info->sw_stat.
-							tx_desc_abort_cnt++;
+			case 3:
+				nic->mac_control.stats_info->sw_stat.
+					tx_desc_abort_cnt++;
 				break;
 
-				case 7:
-					nic->mac_control.stats_info->sw_stat.
-							tx_parity_err_cnt++;
+			case 7:
+				nic->mac_control.stats_info->sw_stat.
+					tx_parity_err_cnt++;
 				break;
 
-				case 10:
-					nic->mac_control.stats_info->sw_stat.
-							tx_link_loss_cnt++;
+			case 10:
+				nic->mac_control.stats_info->sw_stat.
+					tx_link_loss_cnt++;
 				break;
 
-				case 15:
-					nic->mac_control.stats_info->sw_stat.
-							tx_list_proc_err_cnt++;
+			case 15:
+				nic->mac_control.stats_info->sw_stat.
+					tx_list_proc_err_cnt++;
 				break;
-                        }
+			}
 		}
 
 		skb = s2io_txdl_getskb(fifo_data, txdlp, get_info.offset);
 		if (skb == NULL) {
 			spin_unlock_irqrestore(&fifo_data->tx_lock, flags);
-			DBG_PRINT(ERR_DBG, "%s: Null skb ",
-			__func__);
+			DBG_PRINT(ERR_DBG, "%s: Null skb ", __func__);
 			DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");
 			return;
 		}
@@ -3174,10 +3175,9 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 		get_info.offset++;
 		if (get_info.offset == get_info.fifo_len + 1)
 			get_info.offset = 0;
-		txdlp = (struct TxD *) fifo_data->list_info
-		    [get_info.offset].list_virt_addr;
-		fifo_data->tx_curr_get_info.offset =
-		    get_info.offset;
+		txdlp = (struct TxD *)
+			fifo_data->list_info[get_info.offset].list_virt_addr;
+		fifo_data->tx_curr_get_info.offset = get_info.offset;
 	}
 
 	s2io_wake_tx_queue(fifo_data, pkt_cnt, nic->config.multiq);
@@ -3195,43 +3195,41 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
  *  This function is used to write values to the MDIO registers
  *  NONE
  */
-static void s2io_mdio_write(u32 mmd_type, u64 addr, u16 value, struct net_device *dev)
+static void s2io_mdio_write(u32 mmd_type, u64 addr, u16 value,
+			    struct net_device *dev)
 {
-	u64 val64 = 0x0;
+	u64 val64;
 	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
-	//address transaction
-	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
-			| MDIO_MMD_DEV_ADDR(mmd_type)
-			| MDIO_MMS_PRT_ADDR(0x0);
+	/* address transaction */
+	val64 = MDIO_MMD_INDX_ADDR(addr) |
+		MDIO_MMD_DEV_ADDR(mmd_type) |
+		MDIO_MMS_PRT_ADDR(0x0);
 	writeq(val64, &bar0->mdio_control);
 	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
 	writeq(val64, &bar0->mdio_control);
 	udelay(100);
 
-	//Data transaction
-	val64 = 0x0;
-	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
-			| MDIO_MMD_DEV_ADDR(mmd_type)
-			| MDIO_MMS_PRT_ADDR(0x0)
-			| MDIO_MDIO_DATA(value)
-			| MDIO_OP(MDIO_OP_WRITE_TRANS);
+	/* Data transaction */
+	val64 = MDIO_MMD_INDX_ADDR(addr) |
+		MDIO_MMD_DEV_ADDR(mmd_type) |
+		MDIO_MMS_PRT_ADDR(0x0) |
+		MDIO_MDIO_DATA(value) |
+		MDIO_OP(MDIO_OP_WRITE_TRANS);
 	writeq(val64, &bar0->mdio_control);
 	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
 	writeq(val64, &bar0->mdio_control);
 	udelay(100);
 
-	val64 = 0x0;
-	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
-	| MDIO_MMD_DEV_ADDR(mmd_type)
-	| MDIO_MMS_PRT_ADDR(0x0)
-	| MDIO_OP(MDIO_OP_READ_TRANS);
+	val64 = MDIO_MMD_INDX_ADDR(addr) |
+		MDIO_MMD_DEV_ADDR(mmd_type) |
+		MDIO_MMS_PRT_ADDR(0x0) |
+		MDIO_OP(MDIO_OP_READ_TRANS);
 	writeq(val64, &bar0->mdio_control);
 	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
 	writeq(val64, &bar0->mdio_control);
 	udelay(100);
-
 }
 
 /**
@@ -3251,20 +3249,19 @@ static u64 s2io_mdio_read(u32 mmd_type, u64 addr, struct net_device *dev)
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	/* address transaction */
-	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
-			| MDIO_MMD_DEV_ADDR(mmd_type)
-			| MDIO_MMS_PRT_ADDR(0x0);
+	val64 = val64 | (MDIO_MMD_INDX_ADDR(addr)
+			 | MDIO_MMD_DEV_ADDR(mmd_type)
+			 | MDIO_MMS_PRT_ADDR(0x0));
 	writeq(val64, &bar0->mdio_control);
 	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
 	writeq(val64, &bar0->mdio_control);
 	udelay(100);
 
 	/* Data transaction */
-	val64 = 0x0;
-	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
-			| MDIO_MMD_DEV_ADDR(mmd_type)
-			| MDIO_MMS_PRT_ADDR(0x0)
-			| MDIO_OP(MDIO_OP_READ_TRANS);
+	val64 = MDIO_MMD_INDX_ADDR(addr) |
+		MDIO_MMD_DEV_ADDR(mmd_type) |
+		MDIO_MMS_PRT_ADDR(0x0) |
+		MDIO_OP(MDIO_OP_READ_TRANS);
 	writeq(val64, &bar0->mdio_control);
 	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
 	writeq(val64, &bar0->mdio_control);
@@ -3276,6 +3273,7 @@ static u64 s2io_mdio_read(u32 mmd_type, u64 addr, struct net_device *dev)
 	rval64 = rval64 >> 16;
 	return rval64;
 }
+
 /**
  *  s2io_chk_xpak_counter - Function to check the status of the xpak counters
  *  @counter      : couter value to be updated
@@ -3286,45 +3284,43 @@ static u64 s2io_mdio_read(u32 mmd_type, u64 addr, struct net_device *dev)
  *  NONE
  */
 
-static void s2io_chk_xpak_counter(u64 *counter, u64 * regs_stat, u32 index, u16 flag, u16 type)
+static void s2io_chk_xpak_counter(u64 *counter, u64 * regs_stat, u32 index,
+				  u16 flag, u16 type)
 {
 	u64 mask = 0x3;
 	u64 val64;
 	int i;
-	for(i = 0; i <index; i++)
+	for (i = 0; i < index; i++)
 		mask = mask << 0x2;
 
-	if(flag > 0)
-	{
+	if (flag > 0) {
 		*counter = *counter + 1;
 		val64 = *regs_stat & mask;
 		val64 = val64 >> (index * 0x2);
 		val64 = val64 + 1;
-		if(val64 == 3)
-		{
-			switch(type)
-			{
+		if (val64 == 3) {
+			switch (type) {
 			case 1:
 				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
 					  "service. Excessive temperatures may "
 					  "result in premature transceiver "
 					  "failure \n");
-			break;
+				break;
 			case 2:
 				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
 					  "service Excessive bias currents may "
 					  "indicate imminent laser diode "
 					  "failure \n");
-			break;
+				break;
 			case 3:
 				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
 					  "service Excessive laser output "
 					  "power may saturate far-end "
 					  "receiver\n");
-			break;
+				break;
 			default:
-				DBG_PRINT(ERR_DBG, "Incorrect XPAK Alarm "
-					  "type \n");
+				DBG_PRINT(ERR_DBG,
+					  "Incorrect XPAK Alarm type\n");
 			}
 			val64 = 0x0;
 		}
@@ -3358,16 +3354,14 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	addr = MDIO_CTRL1;
 	val64 = 0x0;
 	val64 = s2io_mdio_read(MDIO_MMD_PMAPMD, addr, dev);
-	if((val64 == 0xFFFF) || (val64 == 0x0000))
-	{
+	if ((val64 == 0xFFFF) || (val64 == 0x0000)) {
 		DBG_PRINT(ERR_DBG, "ERR: MDIO slave access failed - "
 			  "Returned %llx\n", (unsigned long long)val64);
 		return;
 	}
 
 	/* Check for the expected value of control reg 1 */
-	if(val64 != MDIO_CTRL1_SPEED10G)
-	{
+	if (val64 != MDIO_CTRL1_SPEED10G) {
 		DBG_PRINT(ERR_DBG, "Incorrect value at PMA address 0x0000 - ");
 		DBG_PRINT(ERR_DBG, "Returned: %llx- Expected: 0x%x\n",
 			  (unsigned long long)val64, MDIO_CTRL1_SPEED10G);
@@ -3387,28 +3381,28 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	flag = CHECKBIT(val64, 0x7);
 	type = 1;
 	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_transceiver_temp_high,
-				&stat_info->xpak_stat.xpak_regs_stat,
-				0x0, flag, type);
+			      &stat_info->xpak_stat.xpak_regs_stat,
+			      0x0, flag, type);
 
-	if(CHECKBIT(val64, 0x6))
+	if (CHECKBIT(val64, 0x6))
 		stat_info->xpak_stat.alarm_transceiver_temp_low++;
 
 	flag = CHECKBIT(val64, 0x3);
 	type = 2;
 	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_laser_bias_current_high,
-				&stat_info->xpak_stat.xpak_regs_stat,
-				0x2, flag, type);
+			      &stat_info->xpak_stat.xpak_regs_stat,
+			      0x2, flag, type);
 
-	if(CHECKBIT(val64, 0x2))
+	if (CHECKBIT(val64, 0x2))
 		stat_info->xpak_stat.alarm_laser_bias_current_low++;
 
 	flag = CHECKBIT(val64, 0x1);
 	type = 3;
 	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_laser_output_power_high,
-				&stat_info->xpak_stat.xpak_regs_stat,
-				0x4, flag, type);
+			      &stat_info->xpak_stat.xpak_regs_stat,
+			      0x4, flag, type);
 
-	if(CHECKBIT(val64, 0x0))
+	if (CHECKBIT(val64, 0x0))
 		stat_info->xpak_stat.alarm_laser_output_power_low++;
 
 	/* Reading the Warning flags */
@@ -3416,22 +3410,22 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	val64 = 0x0;
 	val64 = s2io_mdio_read(MDIO_MMD_PMAPMD, addr, dev);
 
-	if(CHECKBIT(val64, 0x7))
+	if (CHECKBIT(val64, 0x7))
 		stat_info->xpak_stat.warn_transceiver_temp_high++;
 
-	if(CHECKBIT(val64, 0x6))
+	if (CHECKBIT(val64, 0x6))
 		stat_info->xpak_stat.warn_transceiver_temp_low++;
 
-	if(CHECKBIT(val64, 0x3))
+	if (CHECKBIT(val64, 0x3))
 		stat_info->xpak_stat.warn_laser_bias_current_high++;
 
-	if(CHECKBIT(val64, 0x2))
+	if (CHECKBIT(val64, 0x2))
 		stat_info->xpak_stat.warn_laser_bias_current_low++;
 
-	if(CHECKBIT(val64, 0x1))
+	if (CHECKBIT(val64, 0x1))
 		stat_info->xpak_stat.warn_laser_output_power_high++;
 
-	if(CHECKBIT(val64, 0x0))
+	if (CHECKBIT(val64, 0x0))
 		stat_info->xpak_stat.warn_laser_output_power_low++;
 }
 
@@ -3447,7 +3441,7 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
  */
 
 static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit,
-				int bit_state)
+				 int bit_state)
 {
 	int ret = FAILURE, cnt = 0, delay = 1;
 	u64 val64;
@@ -3469,7 +3463,7 @@ static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit,
 			}
 		}
 
-		if(in_interrupt())
+		if (in_interrupt())
 			mdelay(delay);
 		else
 			msleep(delay);
@@ -3509,7 +3503,7 @@ static u16 check_pci_device_id(u16 id)
  *  void.
  */
 
-static void s2io_reset(struct s2io_nic * sp)
+static void s2io_reset(struct s2io_nic *sp)
 {
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64;
@@ -3519,17 +3513,16 @@ static void s2io_reset(struct s2io_nic * sp)
 	unsigned long long up_cnt, down_cnt, up_time, down_time, reset_cnt;
 	unsigned long long mem_alloc_cnt, mem_free_cnt, watchdog_cnt;
 
-	DBG_PRINT(INIT_DBG,"%s - Resetting XFrame card %s\n",
-			__func__, sp->dev->name);
+	DBG_PRINT(INIT_DBG, "%s - Resetting XFrame card %s\n",
+		  __func__, sp->dev->name);
 
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
 
 	val64 = SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
-	if (strstr(sp->product_name, "CX4")) {
+	if (strstr(sp->product_name, "CX4"))
 		msleep(750);
-	}
 	msleep(250);
 	for (i = 0; i < S2IO_MAX_PCI_CONFIG_SPACE_REINIT; i++) {
 
@@ -3541,9 +3534,8 @@ static void s2io_reset(struct s2io_nic * sp)
 		msleep(200);
 	}
 
-	if (check_pci_device_id(val16) == (u16)PCI_ANY_ID) {
-		DBG_PRINT(ERR_DBG,"%s SW_Reset failed!\n", __func__);
-	}
+	if (check_pci_device_id(val16) == (u16)PCI_ANY_ID)
+		DBG_PRINT(ERR_DBG, "%s SW_Reset failed!\n", __func__);
 
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER, pci_cmd);
 
@@ -3571,7 +3563,7 @@ static void s2io_reset(struct s2io_nic * sp)
 	}
 
 	/* Reset device statistics maintained by OS */
-	memset(&sp->stats, 0, sizeof (struct net_device_stats));
+	memset(&sp->stats, 0, sizeof(struct net_device_stats));
 
 	up_cnt = sp->mac_control.stats_info->sw_stat.link_up_cnt;
 	down_cnt = sp->mac_control.stats_info->sw_stat.link_down_cnt;
@@ -3626,7 +3618,7 @@ static void s2io_reset(struct s2io_nic * sp)
  *  SUCCESS on success and FAILURE on failure.
  */
 
-static int s2io_set_swapper(struct s2io_nic * sp)
+static int s2io_set_swapper(struct s2io_nic *sp)
 {
 	struct net_device *dev = sp->dev;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
@@ -3645,7 +3637,7 @@ static int s2io_set_swapper(struct s2io_nic * sp)
 				0x4200004242000042ULL,  /* FE=0, SE=1 */
 				0};                     /* FE=0, SE=0 */
 
-		while(i<4) {
+		while (i < 4) {
 			writeq(value[i], &bar0->swapper_ctrl);
 			val64 = readq(&bar0->pif_rd_swapper_fb);
 			if (val64 == 0x0123456789ABCDEFULL)
@@ -3654,9 +3646,9 @@ static int s2io_set_swapper(struct s2io_nic * sp)
 		}
 		if (i == 4) {
 			DBG_PRINT(ERR_DBG, "%s: Endian settings are wrong, ",
-				dev->name);
+				  dev->name);
 			DBG_PRINT(ERR_DBG, "feedback read %llx\n",
-				(unsigned long long) val64);
+				  (unsigned long long)val64);
 			return FAILURE;
 		}
 		valr = value[i];
@@ -3668,22 +3660,22 @@ static int s2io_set_swapper(struct s2io_nic * sp)
 	writeq(valt, &bar0->xmsi_address);
 	val64 = readq(&bar0->xmsi_address);
 
-	if(val64 != valt) {
+	if (val64 != valt) {
 		int i = 0;
 		u64 value[] = { 0x00C3C30000C3C300ULL,  /* FE=1, SE=1 */
 				0x0081810000818100ULL,  /* FE=1, SE=0 */
 				0x0042420000424200ULL,  /* FE=0, SE=1 */
 				0};                     /* FE=0, SE=0 */
 
-		while(i<4) {
+		while (i < 4) {
 			writeq((value[i] | valr), &bar0->swapper_ctrl);
 			writeq(valt, &bar0->xmsi_address);
 			val64 = readq(&bar0->xmsi_address);
-			if(val64 == valt)
+			if (val64 == valt)
 				break;
 			i++;
 		}
-		if(i == 4) {
+		if (i == 4) {
 			unsigned long long x = val64;
 			DBG_PRINT(ERR_DBG, "Write failed, Xmsi_addr ");
 			DBG_PRINT(ERR_DBG, "reads:0x%llx\n", x);
@@ -3693,21 +3685,22 @@ static int s2io_set_swapper(struct s2io_nic * sp)
 	val64 = readq(&bar0->swapper_ctrl);
 	val64 &= 0xFFFF000000000000ULL;
 
-#ifdef  __BIG_ENDIAN
+#ifdef __BIG_ENDIAN
 	/*
 	 * The device by default set to a big endian format, so a
 	 * big endian driver need not set anything.
 	 */
 	val64 |= (SWAPPER_CTRL_TXP_FE |
-		 SWAPPER_CTRL_TXP_SE |
-		 SWAPPER_CTRL_TXD_R_FE |
-		 SWAPPER_CTRL_TXD_W_FE |
-		 SWAPPER_CTRL_TXF_R_FE |
-		 SWAPPER_CTRL_RXD_R_FE |
-		 SWAPPER_CTRL_RXD_W_FE |
-		 SWAPPER_CTRL_RXF_W_FE |
-		 SWAPPER_CTRL_XMSI_FE |
-		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
+		  SWAPPER_CTRL_TXP_SE |
+		  SWAPPER_CTRL_TXD_R_FE |
+		  SWAPPER_CTRL_TXD_W_FE |
+		  SWAPPER_CTRL_TXF_R_FE |
+		  SWAPPER_CTRL_RXD_R_FE |
+		  SWAPPER_CTRL_RXD_W_FE |
+		  SWAPPER_CTRL_RXF_W_FE |
+		  SWAPPER_CTRL_XMSI_FE |
+		  SWAPPER_CTRL_STATS_FE |
+		  SWAPPER_CTRL_STATS_SE);
 	if (sp->config.intr_type == INTA)
 		val64 |= SWAPPER_CTRL_XMSI_SE;
 	writeq(val64, &bar0->swapper_ctrl);
@@ -3718,19 +3711,20 @@ static int s2io_set_swapper(struct s2io_nic * sp)
 	 * we want to set.
 	 */
 	val64 |= (SWAPPER_CTRL_TXP_FE |
-		 SWAPPER_CTRL_TXP_SE |
-		 SWAPPER_CTRL_TXD_R_FE |
-		 SWAPPER_CTRL_TXD_R_SE |
-		 SWAPPER_CTRL_TXD_W_FE |
-		 SWAPPER_CTRL_TXD_W_SE |
-		 SWAPPER_CTRL_TXF_R_FE |
-		 SWAPPER_CTRL_RXD_R_FE |
-		 SWAPPER_CTRL_RXD_R_SE |
-		 SWAPPER_CTRL_RXD_W_FE |
-		 SWAPPER_CTRL_RXD_W_SE |
-		 SWAPPER_CTRL_RXF_W_FE |
-		 SWAPPER_CTRL_XMSI_FE |
-		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
+		  SWAPPER_CTRL_TXP_SE |
+		  SWAPPER_CTRL_TXD_R_FE |
+		  SWAPPER_CTRL_TXD_R_SE |
+		  SWAPPER_CTRL_TXD_W_FE |
+		  SWAPPER_CTRL_TXD_W_SE |
+		  SWAPPER_CTRL_TXF_R_FE |
+		  SWAPPER_CTRL_RXD_R_FE |
+		  SWAPPER_CTRL_RXD_R_SE |
+		  SWAPPER_CTRL_RXD_W_FE |
+		  SWAPPER_CTRL_RXD_W_SE |
+		  SWAPPER_CTRL_RXF_W_FE |
+		  SWAPPER_CTRL_XMSI_FE |
+		  SWAPPER_CTRL_STATS_FE |
+		  SWAPPER_CTRL_STATS_SE);
 	if (sp->config.intr_type == INTA)
 		val64 |= SWAPPER_CTRL_XMSI_SE;
 	writeq(val64, &bar0->swapper_ctrl);
@@ -3747,7 +3741,7 @@ static int s2io_set_swapper(struct s2io_nic * sp)
 		DBG_PRINT(ERR_DBG, "%s: Endian settings are wrong, ",
 			  dev->name);
 		DBG_PRINT(ERR_DBG, "feedback read %llx\n",
-			  (unsigned long long) val64);
+			  (unsigned long long)val64);
 		return FAILURE;
 	}
 
@@ -3766,7 +3760,7 @@ static int wait_for_msix_trans(struct s2io_nic *nic, int i)
 			break;
 		mdelay(1);
 		cnt++;
-	} while(cnt < 5);
+	} while (cnt < 5);
 	if (cnt == 5) {
 		DBG_PRINT(ERR_DBG, "XMSI # %d Access failed\n", i);
 		ret = 1;
@@ -3781,12 +3775,11 @@ static void restore_xmsi_data(struct s2io_nic *nic)
 	u64 val64;
 	int i, msix_index;
 
-
 	if (nic->device_type == XFRAME_I_DEVICE)
 		return;
 
-	for (i=0; i < MAX_REQUESTED_MSI_X; i++) {
-		msix_index = (i) ? ((i-1) * 8 + 1): 0;
+	for (i = 0; i < MAX_REQUESTED_MSI_X; i++) {
+		msix_index = (i) ? ((i-1) * 8 + 1) : 0;
 		writeq(nic->msix_info[i].addr, &bar0->xmsi_address);
 		writeq(nic->msix_info[i].data, &bar0->xmsi_data);
 		val64 = (s2BIT(7) | s2BIT(15) | vBIT(msix_index, 26, 6));
@@ -3808,8 +3801,8 @@ static void store_xmsi_data(struct s2io_nic *nic)
 		return;
 
 	/* Store and display */
-	for (i=0; i < MAX_REQUESTED_MSI_X; i++) {
-		msix_index = (i) ? ((i-1) * 8 + 1): 0;
+	for (i = 0; i < MAX_REQUESTED_MSI_X; i++) {
+		msix_index = (i) ? ((i-1) * 8 + 1) : 0;
 		val64 = (s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, msix_index)) {
@@ -3836,8 +3829,8 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	size = nic->num_entries * sizeof(struct msix_entry);
 	nic->entries = kzalloc(size, GFP_KERNEL);
 	if (!nic->entries) {
-		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
-			__func__);
+		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
+			  __func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
@@ -3847,7 +3840,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	nic->s2io_entries = kzalloc(size, GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
-			__func__);
+			  __func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
@@ -3926,14 +3919,14 @@ static int s2io_test_msi(struct s2io_nic *sp)
 	u64 val64, saved64;
 
 	err = request_irq(sp->entries[1].vector, s2io_test_intr, 0,
-			sp->name, sp);
+			  sp->name, sp);
 	if (err) {
 		DBG_PRINT(ERR_DBG, "%s: PCI %s: cannot assign irq %d\n",
-		       sp->dev->name, pci_name(pdev), pdev->irq);
+			  sp->dev->name, pci_name(pdev), pdev->irq);
 		return err;
 	}
 
-	init_waitqueue_head (&sp->msi_wait);
+	init_waitqueue_head(&sp->msi_wait);
 	sp->msi_detected = 0;
 
 	saved64 = val64 = readq(&bar0->scheduled_int_ctrl);
@@ -3947,8 +3940,8 @@ static int s2io_test_msi(struct s2io_nic *sp)
 	if (!sp->msi_detected) {
 		/* MSI(X) test failed, go back to INTx mode */
 		DBG_PRINT(ERR_DBG, "%s: PCI %s: No interrupt was generated "
-			"using MSI(X) during test\n", sp->dev->name,
-			pci_name(pdev));
+			  "using MSI(X) during test\n", sp->dev->name,
+			  pci_name(pdev));
 
 		err = -EOPNOTSUPP;
 	}
@@ -3966,8 +3959,7 @@ static void remove_msix_isr(struct s2io_nic *sp)
 	u16 msi_control;
 
 	for (i = 0; i < sp->num_entries; i++) {
-		if (sp->s2io_entries[i].in_use ==
-			MSIX_REGISTERED_SUCCESS) {
+		if (sp->s2io_entries[i].in_use == MSIX_REGISTERED_SUCCESS) {
 			int vector = sp->entries[i].vector;
 			void *arg = sp->s2io_entries[i].arg;
 			free_irq(vector, arg);
@@ -4043,12 +4035,12 @@ hw_init_failed:
 		if (sp->entries) {
 			kfree(sp->entries);
 			sp->mac_control.stats_info->sw_stat.mem_freed
-			+= (sp->num_entries * sizeof(struct msix_entry));
+				+= (sp->num_entries * sizeof(struct msix_entry));
 		}
 		if (sp->s2io_entries) {
 			kfree(sp->s2io_entries);
 			sp->mac_control.stats_info->sw_stat.mem_freed
-			+= (sp->num_entries * sizeof(struct s2io_msix_entry));
+				+= (sp->num_entries * sizeof(struct s2io_msix_entry));
 		}
 	}
 	return err;
@@ -4075,8 +4067,8 @@ static int s2io_close(struct net_device *dev)
 	int offset;
 
 	/* Return if the device is already closed               *
-	*  Can happen when s2io_card_up failed in change_mtu    *
-	*/
+	 *  Can happen when s2io_card_up failed in change_mtu    *
+	 */
 	if (!is_s2io_card_up(sp))
 		return 0;
 
@@ -4152,20 +4144,20 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			if ((ip->frag_off & htons(IP_OFFSET|IP_MF)) == 0) {
 				th = (struct tcphdr *)(((unsigned char *)ip) +
-						ip->ihl*4);
+						       ip->ihl*4);
 
 				if (ip->protocol == IPPROTO_TCP) {
 					queue_len = sp->total_tcp_fifos;
 					queue = (ntohs(th->source) +
-							ntohs(th->dest)) &
-					    sp->fifo_selector[queue_len - 1];
+						 ntohs(th->dest)) &
+						sp->fifo_selector[queue_len - 1];
 					if (queue >= queue_len)
 						queue = queue_len - 1;
 				} else if (ip->protocol == IPPROTO_UDP) {
 					queue_len = sp->total_udp_fifos;
 					queue = (ntohs(th->source) +
-							ntohs(th->dest)) &
-					    sp->fifo_selector[queue_len - 1];
+						 ntohs(th->dest)) &
+						sp->fifo_selector[queue_len - 1];
 					if (queue >= queue_len)
 						queue = queue_len - 1;
 					queue += sp->udp_fifo_idx;
@@ -4178,7 +4170,7 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else if (sp->config.tx_steering_type == TX_PRIORITY_STEERING)
 		/* get fifo number based on skb->priority value */
 		queue = config->fifo_mapping
-					[skb->priority & (MAX_TX_FIFOS - 1)];
+			[skb->priority & (MAX_TX_FIFOS - 1)];
 	fifo = &mac_control->fifos[queue];
 
 	if (do_spin_lock)
@@ -4200,14 +4192,14 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	put_off = (u16) fifo->tx_curr_put_info.offset;
-	get_off = (u16) fifo->tx_curr_get_info.offset;
-	txdp = (struct TxD *) fifo->list_info[put_off].list_virt_addr;
+	put_off = (u16)fifo->tx_curr_put_info.offset;
+	get_off = (u16)fifo->tx_curr_get_info.offset;
+	txdp = (struct TxD *)fifo->list_info[put_off].list_virt_addr;
 
 	queue_len = fifo->tx_curr_put_info.fifo_len + 1;
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (txdp->Host_Control ||
-		   ((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
+	    ((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
 		DBG_PRINT(TX_DBG, "Error in xmit, No free TXDs.\n");
 		s2io_stop_tx_queue(sp, fifo->fifo_no);
 		dev_kfree_skb(skb);
@@ -4221,9 +4213,9 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		txdp->Control_1 |= TXD_TCP_LSO_MSS(s2io_tcp_mss(skb));
 	}
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		txdp->Control_2 |=
-		    (TXD_TX_CKO_IPV4_EN | TXD_TX_CKO_TCP_EN |
-		     TXD_TX_CKO_UDP_EN);
+		txdp->Control_2 |= (TXD_TX_CKO_IPV4_EN |
+				    TXD_TX_CKO_TCP_EN |
+				    TXD_TX_CKO_UDP_EN);
 	}
 	txdp->Control_1 |= TXD_GATHER_CODE_FIRST;
 	txdp->Control_1 |= TXD_LIST_OWN_XENA;
@@ -4248,26 +4240,27 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef __BIG_ENDIAN
 		/* both variants do cpu_to_be64(be32_to_cpu(...)) */
 		fifo->ufo_in_band_v[put_off] =
-				(__force u64)skb_shinfo(skb)->ip6_frag_id;
+			(__force u64)skb_shinfo(skb)->ip6_frag_id;
 #else
 		fifo->ufo_in_band_v[put_off] =
-				(__force u64)skb_shinfo(skb)->ip6_frag_id << 32;
+			(__force u64)skb_shinfo(skb)->ip6_frag_id << 32;
 #endif
 		txdp->Host_Control = (unsigned long)fifo->ufo_in_band_v;
 		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
-					fifo->ufo_in_band_v,
-					sizeof(u64), PCI_DMA_TODEVICE);
+						      fifo->ufo_in_band_v,
+						      sizeof(u64),
+						      PCI_DMA_TODEVICE);
 		if (pci_dma_mapping_error(sp->pdev, txdp->Buffer_Pointer))
 			goto pci_map_failed;
 		txdp++;
 	}
 
-	txdp->Buffer_Pointer = pci_map_single
-	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
+	txdp->Buffer_Pointer = pci_map_single(sp->pdev, skb->data,
+					      frg_len, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(sp->pdev, txdp->Buffer_Pointer))
 		goto pci_map_failed;
 
-	txdp->Host_Control = (unsigned long) skb;
+	txdp->Host_Control = (unsigned long)skb;
 	txdp->Control_1 |= TXD_BUFFER0_SIZE(frg_len);
 	if (offload_type == SKB_GSO_UDP)
 		txdp->Control_1 |= TXD_UFO_EN;
@@ -4280,9 +4273,10 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!frag->size)
 			continue;
 		txdp++;
-		txdp->Buffer_Pointer = (u64) pci_map_page
-		    (sp->pdev, frag->page, frag->page_offset,
-		     frag->size, PCI_DMA_TODEVICE);
+		txdp->Buffer_Pointer = (u64)pci_map_page(sp->pdev, frag->page,
+							 frag->page_offset,
+							 frag->size,
+							 PCI_DMA_TODEVICE);
 		txdp->Control_1 = TXD_BUFFER0_SIZE(frag->size);
 		if (offload_type == SKB_GSO_UDP)
 			txdp->Control_1 |= TXD_UFO_EN;
@@ -4422,17 +4416,16 @@ static void s2io_txpic_intr_handle(struct s2io_nic *sp)
 			 * This is unstable state so clear both up/down
 			 * interrupt and adapter to re-evaluate the link state.
 			 */
-			val64 |=  GPIO_INT_REG_LINK_DOWN;
+			val64 |= GPIO_INT_REG_LINK_DOWN;
 			val64 |= GPIO_INT_REG_LINK_UP;
 			writeq(val64, &bar0->gpio_int_reg);
 			val64 = readq(&bar0->gpio_int_mask);
 			val64 &= ~(GPIO_INT_MASK_LINK_UP |
 				   GPIO_INT_MASK_LINK_DOWN);
 			writeq(val64, &bar0->gpio_int_mask);
-		}
-		else if (val64 & GPIO_INT_REG_LINK_UP) {
+		} else if (val64 & GPIO_INT_REG_LINK_UP) {
 			val64 = readq(&bar0->adapter_status);
-				/* Enable Adapter */
+			/* Enable Adapter */
 			val64 = readq(&bar0->adapter_control);
 			val64 |= ADAPTER_CNTL_EN;
 			writeq(val64, &bar0->adapter_control);
@@ -4451,7 +4444,7 @@ static void s2io_txpic_intr_handle(struct s2io_nic *sp)
 			val64 |= GPIO_INT_MASK_LINK_UP;
 			writeq(val64, &bar0->gpio_int_mask);
 
-		}else if (val64 & GPIO_INT_REG_LINK_DOWN) {
+		} else if (val64 & GPIO_INT_REG_LINK_DOWN) {
 			val64 = readq(&bar0->adapter_status);
 			s2io_link(sp, LINK_DOWN);
 			/* Link is down so unmaks link up interrupt */
@@ -4462,7 +4455,7 @@ static void s2io_txpic_intr_handle(struct s2io_nic *sp)
 
 			/* turn off LED */
 			val64 = readq(&bar0->adapter_control);
-			val64 = val64 &(~ADAPTER_LED_ON);
+			val64 = val64 & (~ADAPTER_LED_ON);
 			writeq(val64, &bar0->adapter_control);
 		}
 	}
@@ -4479,12 +4472,12 @@ static void s2io_txpic_intr_handle(struct s2io_nic *sp)
  *  1 - if alarm bit set
  *  0 - if alarm bit is not set
  */
-static int do_s2io_chk_alarm_bit(u64 value, void __iomem * addr,
-			  unsigned long long *cnt)
+static int do_s2io_chk_alarm_bit(u64 value, void __iomem *addr,
+				 unsigned long long *cnt)
 {
 	u64 val64;
 	val64 = readq(addr);
-	if ( val64 & value ) {
+	if (val64 & value) {
 		writeq(val64, addr);
 		(*cnt)++;
 		return 1;
@@ -4501,12 +4494,12 @@ static int do_s2io_chk_alarm_bit(u64 value, void __iomem * addr,
  *  Return Value:
  *  NONE
  */
-static void s2io_handle_errors(void * dev_id)
+static void s2io_handle_errors(void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
+	struct net_device *dev = (struct net_device *)dev_id;
 	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
-	u64 temp64 = 0,val64=0;
+	u64 temp64 = 0, val64 = 0;
 	int i = 0;
 
 	struct swStat *sw_stat = &sp->mac_control.stats_info->sw_stat;
@@ -4519,10 +4512,10 @@ static void s2io_handle_errors(void * dev_id)
 		return;
 
 	memset(&sw_stat->ring_full_cnt, 0,
-		sizeof(sw_stat->ring_full_cnt));
+	       sizeof(sw_stat->ring_full_cnt));
 
 	/* Handling the XPAK counters update */
-	if(stats->xpak_timer_count < 72000) {
+	if (stats->xpak_timer_count < 72000) {
 		/* waiting for an hour */
 		stats->xpak_timer_count++;
 	} else {
@@ -4541,191 +4534,227 @@ static void s2io_handle_errors(void * dev_id)
 
 	/* In case of a serious error, the device will be Reset. */
 	if (do_s2io_chk_alarm_bit(SERR_SOURCE_ANY, &bar0->serr_source,
-				&sw_stat->serious_err_cnt))
+				  &sw_stat->serious_err_cnt))
 		goto reset;
 
 	/* Check for data parity error */
 	if (do_s2io_chk_alarm_bit(GPIO_INT_REG_DP_ERR_INT, &bar0->gpio_int_reg,
-				&sw_stat->parity_err_cnt))
+				  &sw_stat->parity_err_cnt))
 		goto reset;
 
 	/* Check for ring full counter */
 	if (sp->device_type == XFRAME_II_DEVICE) {
 		val64 = readq(&bar0->ring_bump_counter1);
-		for (i=0; i<4; i++) {
-			temp64 = ( val64 & vBIT(0xFFFF,(i*16),16));
+		for (i = 0; i < 4; i++) {
+			temp64 = (val64 & vBIT(0xFFFF, (i*16), 16));
 			temp64 >>= 64 - ((i+1)*16);
 			sw_stat->ring_full_cnt[i] += temp64;
 		}
 
 		val64 = readq(&bar0->ring_bump_counter2);
-		for (i=0; i<4; i++) {
-			temp64 = ( val64 & vBIT(0xFFFF,(i*16),16));
+		for (i = 0; i < 4; i++) {
+			temp64 = (val64 & vBIT(0xFFFF, (i*16), 16));
 			temp64 >>= 64 - ((i+1)*16);
-			 sw_stat->ring_full_cnt[i+4] += temp64;
+			sw_stat->ring_full_cnt[i+4] += temp64;
 		}
 	}
 
 	val64 = readq(&bar0->txdma_int_status);
 	/*check for pfc_err*/
 	if (val64 & TXDMA_PFC_INT) {
-		if (do_s2io_chk_alarm_bit(PFC_ECC_DB_ERR | PFC_SM_ERR_ALARM|
-				PFC_MISC_0_ERR | PFC_MISC_1_ERR|
-				PFC_PCIX_ERR, &bar0->pfc_err_reg,
-				&sw_stat->pfc_err_cnt))
+		if (do_s2io_chk_alarm_bit(PFC_ECC_DB_ERR | PFC_SM_ERR_ALARM |
+					  PFC_MISC_0_ERR | PFC_MISC_1_ERR |
+					  PFC_PCIX_ERR,
+					  &bar0->pfc_err_reg,
+					  &sw_stat->pfc_err_cnt))
 			goto reset;
-		do_s2io_chk_alarm_bit(PFC_ECC_SG_ERR, &bar0->pfc_err_reg,
-				&sw_stat->pfc_err_cnt);
+		do_s2io_chk_alarm_bit(PFC_ECC_SG_ERR,
+				      &bar0->pfc_err_reg,
+				      &sw_stat->pfc_err_cnt);
 	}
 
 	/*check for tda_err*/
 	if (val64 & TXDMA_TDA_INT) {
-		if(do_s2io_chk_alarm_bit(TDA_Fn_ECC_DB_ERR | TDA_SM0_ERR_ALARM |
-				TDA_SM1_ERR_ALARM, &bar0->tda_err_reg,
-				&sw_stat->tda_err_cnt))
+		if (do_s2io_chk_alarm_bit(TDA_Fn_ECC_DB_ERR |
+					  TDA_SM0_ERR_ALARM |
+					  TDA_SM1_ERR_ALARM,
+					  &bar0->tda_err_reg,
+					  &sw_stat->tda_err_cnt))
 			goto reset;
 		do_s2io_chk_alarm_bit(TDA_Fn_ECC_SG_ERR | TDA_PCIX_ERR,
-				&bar0->tda_err_reg, &sw_stat->tda_err_cnt);
+				      &bar0->tda_err_reg,
+				      &sw_stat->tda_err_cnt);
 	}
 	/*check for pcc_err*/
 	if (val64 & TXDMA_PCC_INT) {
-		if (do_s2io_chk_alarm_bit(PCC_SM_ERR_ALARM | PCC_WR_ERR_ALARM
-				| PCC_N_SERR | PCC_6_COF_OV_ERR
-				| PCC_7_COF_OV_ERR | PCC_6_LSO_OV_ERR
-				| PCC_7_LSO_OV_ERR | PCC_FB_ECC_DB_ERR
-				| PCC_TXB_ECC_DB_ERR, &bar0->pcc_err_reg,
-				&sw_stat->pcc_err_cnt))
+		if (do_s2io_chk_alarm_bit(PCC_SM_ERR_ALARM | PCC_WR_ERR_ALARM |
+					  PCC_N_SERR | PCC_6_COF_OV_ERR |
+					  PCC_7_COF_OV_ERR | PCC_6_LSO_OV_ERR |
+					  PCC_7_LSO_OV_ERR | PCC_FB_ECC_DB_ERR |
+					  PCC_TXB_ECC_DB_ERR,
+					  &bar0->pcc_err_reg,
+					  &sw_stat->pcc_err_cnt))
 			goto reset;
 		do_s2io_chk_alarm_bit(PCC_FB_ECC_SG_ERR | PCC_TXB_ECC_SG_ERR,
-				&bar0->pcc_err_reg, &sw_stat->pcc_err_cnt);
+				      &bar0->pcc_err_reg,
+				      &sw_stat->pcc_err_cnt);
 	}
 
 	/*check for tti_err*/
 	if (val64 & TXDMA_TTI_INT) {
-		if (do_s2io_chk_alarm_bit(TTI_SM_ERR_ALARM, &bar0->tti_err_reg,
-				&sw_stat->tti_err_cnt))
+		if (do_s2io_chk_alarm_bit(TTI_SM_ERR_ALARM,
+					  &bar0->tti_err_reg,
+					  &sw_stat->tti_err_cnt))
 			goto reset;
 		do_s2io_chk_alarm_bit(TTI_ECC_SG_ERR | TTI_ECC_DB_ERR,
-				&bar0->tti_err_reg, &sw_stat->tti_err_cnt);
+				      &bar0->tti_err_reg,
+				      &sw_stat->tti_err_cnt);
 	}
 
 	/*check for lso_err*/
 	if (val64 & TXDMA_LSO_INT) {
-		if (do_s2io_chk_alarm_bit(LSO6_ABORT | LSO7_ABORT
-				| LSO6_SM_ERR_ALARM | LSO7_SM_ERR_ALARM,
-				&bar0->lso_err_reg, &sw_stat->lso_err_cnt))
+		if (do_s2io_chk_alarm_bit(LSO6_ABORT | LSO7_ABORT |
+					  LSO6_SM_ERR_ALARM | LSO7_SM_ERR_ALARM,
+					  &bar0->lso_err_reg,
+					  &sw_stat->lso_err_cnt))
 			goto reset;
 		do_s2io_chk_alarm_bit(LSO6_SEND_OFLOW | LSO7_SEND_OFLOW,
-				&bar0->lso_err_reg, &sw_stat->lso_err_cnt);
+				      &bar0->lso_err_reg,
+				      &sw_stat->lso_err_cnt);
 	}
 
 	/*check for tpa_err*/
 	if (val64 & TXDMA_TPA_INT) {
-		if (do_s2io_chk_alarm_bit(TPA_SM_ERR_ALARM, &bar0->tpa_err_reg,
-			&sw_stat->tpa_err_cnt))
+		if (do_s2io_chk_alarm_bit(TPA_SM_ERR_ALARM,
+					  &bar0->tpa_err_reg,
+					  &sw_stat->tpa_err_cnt))
 			goto reset;
-		do_s2io_chk_alarm_bit(TPA_TX_FRM_DROP, &bar0->tpa_err_reg,
-			&sw_stat->tpa_err_cnt);
+		do_s2io_chk_alarm_bit(TPA_TX_FRM_DROP,
+				      &bar0->tpa_err_reg,
+				      &sw_stat->tpa_err_cnt);
 	}
 
 	/*check for sm_err*/
 	if (val64 & TXDMA_SM_INT) {
-		if (do_s2io_chk_alarm_bit(SM_SM_ERR_ALARM, &bar0->sm_err_reg,
-			&sw_stat->sm_err_cnt))
+		if (do_s2io_chk_alarm_bit(SM_SM_ERR_ALARM,
+					  &bar0->sm_err_reg,
+					  &sw_stat->sm_err_cnt))
 			goto reset;
 	}
 
 	val64 = readq(&bar0->mac_int_status);
 	if (val64 & MAC_INT_STATUS_TMAC_INT) {
 		if (do_s2io_chk_alarm_bit(TMAC_TX_BUF_OVRN | TMAC_TX_SM_ERR,
-				&bar0->mac_tmac_err_reg,
-				&sw_stat->mac_tmac_err_cnt))
+					  &bar0->mac_tmac_err_reg,
+					  &sw_stat->mac_tmac_err_cnt))
 			goto reset;
-		do_s2io_chk_alarm_bit(TMAC_ECC_SG_ERR | TMAC_ECC_DB_ERR
-				| TMAC_DESC_ECC_SG_ERR | TMAC_DESC_ECC_DB_ERR,
-				&bar0->mac_tmac_err_reg,
-				&sw_stat->mac_tmac_err_cnt);
+		do_s2io_chk_alarm_bit(TMAC_ECC_SG_ERR | TMAC_ECC_DB_ERR |
+				      TMAC_DESC_ECC_SG_ERR |
+				      TMAC_DESC_ECC_DB_ERR,
+				      &bar0->mac_tmac_err_reg,
+				      &sw_stat->mac_tmac_err_cnt);
 	}
 
 	val64 = readq(&bar0->xgxs_int_status);
 	if (val64 & XGXS_INT_STATUS_TXGXS) {
 		if (do_s2io_chk_alarm_bit(TXGXS_ESTORE_UFLOW | TXGXS_TX_SM_ERR,
-				&bar0->xgxs_txgxs_err_reg,
-				&sw_stat->xgxs_txgxs_err_cnt))
+					  &bar0->xgxs_txgxs_err_reg,
+					  &sw_stat->xgxs_txgxs_err_cnt))
 			goto reset;
 		do_s2io_chk_alarm_bit(TXGXS_ECC_SG_ERR | TXGXS_ECC_DB_ERR,
-				&bar0->xgxs_txgxs_err_reg,
-				&sw_stat->xgxs_txgxs_err_cnt);
+				      &bar0->xgxs_txgxs_err_reg,
+				      &sw_stat->xgxs_txgxs_err_cnt);
 	}
 
 	val64 = readq(&bar0->rxdma_int_status);
 	if (val64 & RXDMA_INT_RC_INT_M) {
-		if (do_s2io_chk_alarm_bit(RC_PRCn_ECC_DB_ERR | RC_FTC_ECC_DB_ERR
-				| RC_PRCn_SM_ERR_ALARM |RC_FTC_SM_ERR_ALARM,
-				&bar0->rc_err_reg, &sw_stat->rc_err_cnt))
+		if (do_s2io_chk_alarm_bit(RC_PRCn_ECC_DB_ERR |
+					  RC_FTC_ECC_DB_ERR |
+					  RC_PRCn_SM_ERR_ALARM |
+					  RC_FTC_SM_ERR_ALARM,
+					  &bar0->rc_err_reg,
+					  &sw_stat->rc_err_cnt))
 			goto reset;
-		do_s2io_chk_alarm_bit(RC_PRCn_ECC_SG_ERR | RC_FTC_ECC_SG_ERR
-				| RC_RDA_FAIL_WR_Rn, &bar0->rc_err_reg,
-				&sw_stat->rc_err_cnt);
-		if (do_s2io_chk_alarm_bit(PRC_PCI_AB_RD_Rn | PRC_PCI_AB_WR_Rn
-				| PRC_PCI_AB_F_WR_Rn, &bar0->prc_pcix_err_reg,
-				&sw_stat->prc_pcix_err_cnt))
+		do_s2io_chk_alarm_bit(RC_PRCn_ECC_SG_ERR |
+				      RC_FTC_ECC_SG_ERR |
+				      RC_RDA_FAIL_WR_Rn, &bar0->rc_err_reg,
+				      &sw_stat->rc_err_cnt);
+		if (do_s2io_chk_alarm_bit(PRC_PCI_AB_RD_Rn |
+					  PRC_PCI_AB_WR_Rn |
+					  PRC_PCI_AB_F_WR_Rn,
+					  &bar0->prc_pcix_err_reg,
+					  &sw_stat->prc_pcix_err_cnt))
 			goto reset;
-		do_s2io_chk_alarm_bit(PRC_PCI_DP_RD_Rn | PRC_PCI_DP_WR_Rn
-				| PRC_PCI_DP_F_WR_Rn, &bar0->prc_pcix_err_reg,
-				&sw_stat->prc_pcix_err_cnt);
+		do_s2io_chk_alarm_bit(PRC_PCI_DP_RD_Rn |
+				      PRC_PCI_DP_WR_Rn |
+				      PRC_PCI_DP_F_WR_Rn,
+				      &bar0->prc_pcix_err_reg,
+				      &sw_stat->prc_pcix_err_cnt);
 	}
 
 	if (val64 & RXDMA_INT_RPA_INT_M) {
 		if (do_s2io_chk_alarm_bit(RPA_SM_ERR_ALARM | RPA_CREDIT_ERR,
-				&bar0->rpa_err_reg, &sw_stat->rpa_err_cnt))
+					  &bar0->rpa_err_reg,
+					  &sw_stat->rpa_err_cnt))
 			goto reset;
 		do_s2io_chk_alarm_bit(RPA_ECC_SG_ERR | RPA_ECC_DB_ERR,
-				&bar0->rpa_err_reg, &sw_stat->rpa_err_cnt);
+				      &bar0->rpa_err_reg,
+				      &sw_stat->rpa_err_cnt);
 	}
 
 	if (val64 & RXDMA_INT_RDA_INT_M) {
-		if (do_s2io_chk_alarm_bit(RDA_RXDn_ECC_DB_ERR
-				| RDA_FRM_ECC_DB_N_AERR | RDA_SM1_ERR_ALARM
-				| RDA_SM0_ERR_ALARM | RDA_RXD_ECC_DB_SERR,
-				&bar0->rda_err_reg, &sw_stat->rda_err_cnt))
+		if (do_s2io_chk_alarm_bit(RDA_RXDn_ECC_DB_ERR |
+					  RDA_FRM_ECC_DB_N_AERR |
+					  RDA_SM1_ERR_ALARM |
+					  RDA_SM0_ERR_ALARM |
+					  RDA_RXD_ECC_DB_SERR,
+					  &bar0->rda_err_reg,
+					  &sw_stat->rda_err_cnt))
 			goto reset;
-		do_s2io_chk_alarm_bit(RDA_RXDn_ECC_SG_ERR | RDA_FRM_ECC_SG_ERR
-				| RDA_MISC_ERR | RDA_PCIX_ERR,
-				&bar0->rda_err_reg, &sw_stat->rda_err_cnt);
+		do_s2io_chk_alarm_bit(RDA_RXDn_ECC_SG_ERR |
+				      RDA_FRM_ECC_SG_ERR |
+				      RDA_MISC_ERR |
+				      RDA_PCIX_ERR,
+				      &bar0->rda_err_reg,
+				      &sw_stat->rda_err_cnt);
 	}
 
 	if (val64 & RXDMA_INT_RTI_INT_M) {
-		if (do_s2io_chk_alarm_bit(RTI_SM_ERR_ALARM, &bar0->rti_err_reg,
-				&sw_stat->rti_err_cnt))
+		if (do_s2io_chk_alarm_bit(RTI_SM_ERR_ALARM,
+					  &bar0->rti_err_reg,
+					  &sw_stat->rti_err_cnt))
 			goto reset;
 		do_s2io_chk_alarm_bit(RTI_ECC_SG_ERR | RTI_ECC_DB_ERR,
-				&bar0->rti_err_reg, &sw_stat->rti_err_cnt);
+				      &bar0->rti_err_reg,
+				      &sw_stat->rti_err_cnt);
 	}
 
 	val64 = readq(&bar0->mac_int_status);
 	if (val64 & MAC_INT_STATUS_RMAC_INT) {
 		if (do_s2io_chk_alarm_bit(RMAC_RX_BUFF_OVRN | RMAC_RX_SM_ERR,
-				&bar0->mac_rmac_err_reg,
-				&sw_stat->mac_rmac_err_cnt))
+					  &bar0->mac_rmac_err_reg,
+					  &sw_stat->mac_rmac_err_cnt))
 			goto reset;
-		do_s2io_chk_alarm_bit(RMAC_UNUSED_INT|RMAC_SINGLE_ECC_ERR|
-				RMAC_DOUBLE_ECC_ERR, &bar0->mac_rmac_err_reg,
-				&sw_stat->mac_rmac_err_cnt);
+		do_s2io_chk_alarm_bit(RMAC_UNUSED_INT |
+				      RMAC_SINGLE_ECC_ERR |
+				      RMAC_DOUBLE_ECC_ERR,
+				      &bar0->mac_rmac_err_reg,
+				      &sw_stat->mac_rmac_err_cnt);
 	}
 
 	val64 = readq(&bar0->xgxs_int_status);
 	if (val64 & XGXS_INT_STATUS_RXGXS) {
 		if (do_s2io_chk_alarm_bit(RXGXS_ESTORE_OFLOW | RXGXS_RX_SM_ERR,
-				&bar0->xgxs_rxgxs_err_reg,
-				&sw_stat->xgxs_rxgxs_err_cnt))
+					  &bar0->xgxs_rxgxs_err_reg,
+					  &sw_stat->xgxs_rxgxs_err_cnt))
 			goto reset;
 	}
 
 	val64 = readq(&bar0->mc_int_status);
-	if(val64 & MC_INT_STATUS_MC_INT) {
-		if (do_s2io_chk_alarm_bit(MC_ERR_REG_SM_ERR, &bar0->mc_err_reg,
-				&sw_stat->mc_err_cnt))
+	if (val64 & MC_INT_STATUS_MC_INT) {
+		if (do_s2io_chk_alarm_bit(MC_ERR_REG_SM_ERR,
+					  &bar0->mc_err_reg,
+					  &sw_stat->mc_err_cnt))
 			goto reset;
 
 		/* Handling Ecc errors */
@@ -4738,10 +4767,10 @@ static void s2io_handle_errors(void * dev_id)
 					 * Reset XframeI only if critical error
 					 */
 					if (val64 &
-						(MC_ERR_REG_MIRI_ECC_DB_ERR_0 |
-						MC_ERR_REG_MIRI_ECC_DB_ERR_1))
-								goto reset;
-					}
+					    (MC_ERR_REG_MIRI_ECC_DB_ERR_0 |
+					     MC_ERR_REG_MIRI_ECC_DB_ERR_1))
+						goto reset;
+				}
 			} else
 				sw_stat->single_ecc_errs++;
 		}
@@ -4770,7 +4799,7 @@ reset:
  */
 static irqreturn_t s2io_isr(int irq, void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
+	struct net_device *dev = (struct net_device *)dev_id;
 	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	int i;
@@ -4797,14 +4826,11 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 	 */
 	reason = readq(&bar0->general_int_status);
 
-	if (unlikely(reason == S2IO_MINUS_ONE) ) {
-		/* Nothing much can be done. Get out */
-		return IRQ_HANDLED;
-	}
+	if (unlikely(reason == S2IO_MINUS_ONE))
+		return IRQ_HANDLED;	/* Nothing much can be done. Get out */
 
-	if (reason & (GEN_INTR_RXTRAFFIC |
-		GEN_INTR_TXTRAFFIC | GEN_INTR_TXPIC))
-	{
+	if (reason &
+	    (GEN_INTR_RXTRAFFIC | GEN_INTR_TXTRAFFIC | GEN_INTR_TXPIC)) {
 		writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
 
 		if (config->napi) {
@@ -4859,8 +4885,7 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 
 		return IRQ_HANDLED;
 
-	}
-	else if (!reason) {
+	} else if (!reason) {
 		/* The interrupt was not raised by us */
 		return IRQ_NONE;
 	}
@@ -4890,7 +4915,7 @@ static void s2io_updt_stats(struct s2io_nic *sp)
 			cnt++;
 			if (cnt == 5)
 				break; /* Updt failed */
-		} while(1);
+		} while (1);
 	}
 }
 
@@ -4921,7 +4946,7 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 	/* Using sp->stats as a staging area, because reset (due to mtu
 	   change, for example) will clear some hardware counters */
 	dev->stats.tx_packets +=
-		le32_to_cpu(mac_control->stats_info->tmac_frms) - 
+		le32_to_cpu(mac_control->stats_info->tmac_frms) -
 		sp->stats.tx_packets;
 	sp->stats.tx_packets =
 		le32_to_cpu(mac_control->stats_info->tmac_frms);
@@ -4936,12 +4961,12 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 	sp->stats.rx_errors =
 		le64_to_cpu(mac_control->stats_info->rmac_drop_frms);
 	dev->stats.multicast =
-		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms) - 
+		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms) -
 		sp->stats.multicast;
 	sp->stats.multicast =
 		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms);
 	dev->stats.rx_length_errors =
-		le64_to_cpu(mac_control->stats_info->rmac_long_frms) - 
+		le64_to_cpu(mac_control->stats_info->rmac_long_frms) -
 		sp->stats.rx_length_errors;
 	sp->stats.rx_length_errors =
 		le64_to_cpu(mac_control->stats_info->rmac_long_frms);
@@ -4955,7 +4980,7 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 		dev->stats.rx_bytes += ring->rx_bytes;
 	}
 
-	return (&dev->stats);
+	return &dev->stats;
 }
 
 /**
@@ -4978,7 +5003,7 @@ static void s2io_set_multicast(struct net_device *dev)
 	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64 = 0, multi_mac = 0x010203040506ULL, mask =
-	    0xfeffffffffffULL;
+		0xfeffffffffffULL;
 	u64 dis_addr = S2IO_DISABLE_MAC_ENTRY, mac_addr = 0;
 	void __iomem *add;
 	struct config_param *config = &sp->config;
@@ -4990,13 +5015,13 @@ static void s2io_set_multicast(struct net_device *dev)
 		writeq(RMAC_ADDR_DATA1_MEM_MASK(mask),
 		       &bar0->rmac_addr_data1_mem);
 		val64 = RMAC_ADDR_CMD_MEM_WE |
-		    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
-		    RMAC_ADDR_CMD_MEM_OFFSET(config->max_mc_addr - 1);
+			RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
+			RMAC_ADDR_CMD_MEM_OFFSET(config->max_mc_addr - 1);
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
 		wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-					RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
-					S2IO_BIT_RESET);
+				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+				      S2IO_BIT_RESET);
 
 		sp->m_cast_flg = 1;
 		sp->all_multi_pos = config->max_mc_addr - 1;
@@ -5007,13 +5032,13 @@ static void s2io_set_multicast(struct net_device *dev)
 		writeq(RMAC_ADDR_DATA1_MEM_MASK(0x0),
 		       &bar0->rmac_addr_data1_mem);
 		val64 = RMAC_ADDR_CMD_MEM_WE |
-		    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
-		    RMAC_ADDR_CMD_MEM_OFFSET(sp->all_multi_pos);
+			RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
+			RMAC_ADDR_CMD_MEM_OFFSET(sp->all_multi_pos);
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
 		wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-					RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
-					S2IO_BIT_RESET);
+				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+				      S2IO_BIT_RESET);
 
 		sp->m_cast_flg = 0;
 		sp->all_multi_pos = 0;
@@ -5026,7 +5051,7 @@ static void s2io_set_multicast(struct net_device *dev)
 		val64 |= MAC_CFG_RMAC_PROM_ENABLE;
 
 		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
-		writel((u32) val64, add);
+		writel((u32)val64, add);
 		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
 		writel((u32) (val64 >> 32), (add + 4));
 
@@ -5048,7 +5073,7 @@ static void s2io_set_multicast(struct net_device *dev)
 		val64 &= ~MAC_CFG_RMAC_PROM_ENABLE;
 
 		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
-		writel((u32) val64, add);
+		writel((u32)val64, add);
 		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
 		writel((u32) (val64 >> 32), (add + 4));
 
@@ -5084,19 +5109,18 @@ static void s2io_set_multicast(struct net_device *dev)
 			writeq(RMAC_ADDR_DATA0_MEM_ADDR(dis_addr),
 			       &bar0->rmac_addr_data0_mem);
 			writeq(RMAC_ADDR_DATA1_MEM_MASK(0ULL),
-				&bar0->rmac_addr_data1_mem);
+			       &bar0->rmac_addr_data1_mem);
 			val64 = RMAC_ADDR_CMD_MEM_WE |
-			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
-			    RMAC_ADDR_CMD_MEM_OFFSET
-			    (config->mc_start_offset + i);
+				RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
+				RMAC_ADDR_CMD_MEM_OFFSET
+				(config->mc_start_offset + i);
 			writeq(val64, &bar0->rmac_addr_cmd_mem);
 
 			/* Wait for command completes */
 			if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-					RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
-					S2IO_BIT_RESET)) {
-				DBG_PRINT(ERR_DBG, "%s: Adding ",
-					  dev->name);
+						  RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+						  S2IO_BIT_RESET)) {
+				DBG_PRINT(ERR_DBG, "%s: Adding ", dev->name);
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
 				return;
 			}
@@ -5116,19 +5140,18 @@ static void s2io_set_multicast(struct net_device *dev)
 			writeq(RMAC_ADDR_DATA0_MEM_ADDR(mac_addr),
 			       &bar0->rmac_addr_data0_mem);
 			writeq(RMAC_ADDR_DATA1_MEM_MASK(0ULL),
-				&bar0->rmac_addr_data1_mem);
+			       &bar0->rmac_addr_data1_mem);
 			val64 = RMAC_ADDR_CMD_MEM_WE |
-			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
-			    RMAC_ADDR_CMD_MEM_OFFSET
-			    (i + config->mc_start_offset);
+				RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
+				RMAC_ADDR_CMD_MEM_OFFSET
+				(i + config->mc_start_offset);
 			writeq(val64, &bar0->rmac_addr_cmd_mem);
 
 			/* Wait for command completes */
 			if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-					RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
-					S2IO_BIT_RESET)) {
-				DBG_PRINT(ERR_DBG, "%s: Adding ",
-					  dev->name);
+						  RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+						  S2IO_BIT_RESET)) {
+				DBG_PRINT(ERR_DBG, "%s: Adding ", dev->name);
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
 				return;
 			}
@@ -5163,11 +5186,11 @@ static void do_s2io_restore_unicast_mc(struct s2io_nic *sp)
 	/* restore unicast mac address */
 	for (offset = 0; offset < config->max_mac_addr; offset++)
 		do_s2io_prog_unicast(sp->dev,
-			sp->def_mac_addr[offset].mac_addr);
+				     sp->def_mac_addr[offset].mac_addr);
 
 	/* restore multicast mac address */
 	for (offset = config->mc_start_offset;
-		offset < config->max_mc_addr; offset++)
+	     offset < config->max_mc_addr; offset++)
 		do_s2io_add_mc(sp, sp->def_mac_addr[offset].mac_addr);
 }
 
@@ -5197,13 +5220,13 @@ static int do_s2io_add_mc(struct s2io_nic *sp, u8 *addr)
 	}
 	if (i == config->max_mc_addr) {
 		DBG_PRINT(ERR_DBG,
-			"CAM full no space left for multicast MAC\n");
+			  "CAM full no space left for multicast MAC\n");
 		return FAILURE;
 	}
 	/* Update the internal structure with this new mac address */
 	do_s2io_copy_mac_addr(sp, i, mac_addr);
 
-	return (do_s2io_add_mac(sp, mac_addr, i));
+	return do_s2io_add_mac(sp, mac_addr, i);
 }
 
 /* add MAC address to CAM */
@@ -5213,17 +5236,16 @@ static int do_s2io_add_mac(struct s2io_nic *sp, u64 addr, int off)
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	writeq(RMAC_ADDR_DATA0_MEM_ADDR(addr),
-		&bar0->rmac_addr_data0_mem);
+	       &bar0->rmac_addr_data0_mem);
 
-	val64 =
-		RMAC_ADDR_CMD_MEM_WE | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
+	val64 =	RMAC_ADDR_CMD_MEM_WE | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 		RMAC_ADDR_CMD_MEM_OFFSET(off);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
 
 	/* Wait till command completes */
 	if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-		RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
-		S2IO_BIT_RESET)) {
+				  RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+				  S2IO_BIT_RESET)) {
 		DBG_PRINT(INFO_DBG, "do_s2io_add_mac failed\n");
 		return FAILURE;
 	}
@@ -5237,7 +5259,7 @@ static int do_s2io_delete_unicast_mc(struct s2io_nic *sp, u64 addr)
 	struct config_param *config = &sp->config;
 
 	for (offset = 1;
-		offset < config->max_mc_addr; offset++) {
+	     offset < config->max_mc_addr; offset++) {
 		tmp64 = do_s2io_read_unicast_mc(sp, offset);
 		if (tmp64 == addr) {
 			/* disable the entry by writing  0xffffffffffffULL */
@@ -5249,7 +5271,7 @@ static int do_s2io_delete_unicast_mc(struct s2io_nic *sp, u64 addr)
 		}
 	}
 	DBG_PRINT(ERR_DBG, "MAC address 0x%llx not found in CAM\n",
-			(unsigned long long)addr);
+		  (unsigned long long)addr);
 	return FAILURE;
 }
 
@@ -5260,20 +5282,20 @@ static u64 do_s2io_read_unicast_mc(struct s2io_nic *sp, int offset)
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	/* read mac addr */
-	val64 =
-		RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
+	val64 =	RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 		RMAC_ADDR_CMD_MEM_OFFSET(offset);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
 
 	/* Wait till command completes */
 	if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-		RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
-		S2IO_BIT_RESET)) {
+				  RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+				  S2IO_BIT_RESET)) {
 		DBG_PRINT(INFO_DBG, "do_s2io_read_unicast_mc failed\n");
 		return FAILURE;
 	}
 	tmp64 = readq(&bar0->rmac_addr_data0_mem);
-	return (tmp64 >> 16);
+
+	return tmp64 >> 16;
 }
 
 /**
@@ -5290,7 +5312,7 @@ static int s2io_set_mac_addr(struct net_device *dev, void *p)
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	/* store the MAC address in CAM */
-	return (do_s2io_prog_unicast(dev, dev->dev_addr));
+	return do_s2io_prog_unicast(dev, dev->dev_addr);
 }
 /**
  *  do_s2io_prog_unicast - Programs the Xframe mac address
@@ -5311,10 +5333,10 @@ static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
 	struct config_param *config = &sp->config;
 
 	/*
-	* Set the new MAC address as the new unicast filter and reflect this
-	* change on the device address registered with the OS. It will be
-	* at offset 0.
-	*/
+	 * Set the new MAC address as the new unicast filter and reflect this
+	 * change on the device address registered with the OS. It will be
+	 * at offset 0.
+	 */
 	for (i = 0; i < ETH_ALEN; i++) {
 		mac_addr <<= 8;
 		mac_addr |= addr[i];
@@ -5334,8 +5356,8 @@ static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
 
 		if (tmp64 == mac_addr) {
 			DBG_PRINT(INFO_DBG,
-			"MAC addr:0x%llx already present in CAM\n",
-			(unsigned long long)mac_addr);
+				  "MAC addr:0x%llx already present in CAM\n",
+				  (unsigned long long)mac_addr);
 			return SUCCESS;
 		}
 	}
@@ -5345,7 +5367,8 @@ static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
 	}
 	/* Update the internal structure with this new mac address */
 	do_s2io_copy_mac_addr(sp, i, mac_addr);
-	return (do_s2io_add_mac(sp, mac_addr, i));
+
+	return do_s2io_add_mac(sp, mac_addr, i);
 }
 
 /**
@@ -5358,14 +5381,15 @@ static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
  * the NIC.
  * Return value:
  * 0 on success.
-*/
+ */
 
 static int s2io_ethtool_sset(struct net_device *dev,
 			     struct ethtool_cmd *info)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
 	if ((info->autoneg == AUTONEG_ENABLE) ||
-	    (info->speed != SPEED_10000) || (info->duplex != DUPLEX_FULL))
+	    (info->speed != SPEED_10000) ||
+	    (info->duplex != DUPLEX_FULL))
 		return -EINVAL;
 	else {
 		s2io_close(sp->dev);
@@ -5446,14 +5470,14 @@ static void s2io_ethtool_gdrvinfo(struct net_device *dev,
  *  buffer area.
  * Return value :
  * void .
-*/
+ */
 
 static void s2io_ethtool_gregs(struct net_device *dev,
 			       struct ethtool_regs *regs, void *space)
 {
 	int i;
 	u64 reg;
-	u8 *reg_space = (u8 *) space;
+	u8 *reg_space = (u8 *)space;
 	struct s2io_nic *sp = netdev_priv(dev);
 
 	regs->len = XENA_REG_SPACE;
@@ -5473,17 +5497,17 @@ static void s2io_ethtool_gregs(struct net_device *dev,
  * adapter LED bit of the adapter control bit to set/reset every time on
  * invocation. The timer is set for 1/2 a second, hence tha NIC blinks
  *  once every second.
-*/
+ */
 static void s2io_phy_id(unsigned long data)
 {
-	struct s2io_nic *sp = (struct s2io_nic *) data;
+	struct s2io_nic *sp = (struct s2io_nic *)data;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64 = 0;
 	u16 subid;
 
 	subid = sp->pdev->subsystem_device;
 	if ((sp->device_type == XFRAME_II_DEVICE) ||
-		   ((subid & 0xFF) >= 0x07)) {
+	    ((subid & 0xFF) >= 0x07)) {
 		val64 = readq(&bar0->gpio_control);
 		val64 ^= GPIO_CTRL_GPIO_0;
 		writeq(val64, &bar0->gpio_control);
@@ -5520,8 +5544,7 @@ static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 
 	subid = sp->pdev->subsystem_device;
 	last_gpio_ctrl_val = readq(&bar0->gpio_control);
-	if ((sp->device_type == XFRAME_I_DEVICE) &&
-		((subid & 0xFF) < 0x07)) {
+	if ((sp->device_type == XFRAME_I_DEVICE) && ((subid & 0xFF) < 0x07)) {
 		val64 = readq(&bar0->adapter_control);
 		if (!(val64 & ADAPTER_CNTL_EN)) {
 			printk(KERN_ERR
@@ -5532,7 +5555,7 @@ static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 	if (sp->id_timer.function == NULL) {
 		init_timer(&sp->id_timer);
 		sp->id_timer.function = s2io_phy_id;
-		sp->id_timer.data = (unsigned long) sp;
+		sp->id_timer.data = (unsigned long)sp;
 	}
 	mod_timer(&sp->id_timer, jiffies);
 	if (data)
@@ -5550,10 +5573,10 @@ static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 }
 
 static void s2io_ethtool_gringparam(struct net_device *dev,
-                                    struct ethtool_ringparam *ering)
+				    struct ethtool_ringparam *ering)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
-	int i,tx_desc_count=0,rx_desc_count=0;
+	int i, tx_desc_count = 0, rx_desc_count = 0;
 
 	if (sp->rxd_mode == RXD_MODE_1)
 		ering->rx_max_pending = MAX_RX_DESC_1;
@@ -5564,7 +5587,7 @@ static void s2io_ethtool_gringparam(struct net_device *dev,
 	for (i = 0 ; i < sp->config.tx_fifo_num ; i++)
 		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
 
-	DBG_PRINT(INFO_DBG,"\nmax txds : %d\n",sp->config.max_txds);
+	DBG_PRINT(INFO_DBG, "\nmax txds : %d\n", sp->config.max_txds);
 	ering->tx_pending = tx_desc_count;
 	rx_desc_count = 0;
 	for (i = 0 ; i < sp->config.rx_ring_num ; i++)
@@ -5574,7 +5597,7 @@ static void s2io_ethtool_gringparam(struct net_device *dev,
 
 	ering->rx_mini_max_pending = 0;
 	ering->rx_mini_pending = 0;
-	if(sp->rxd_mode == RXD_MODE_1)
+	if (sp->rxd_mode == RXD_MODE_1)
 		ering->rx_jumbo_max_pending = MAX_RX_DESC_1;
 	else if (sp->rxd_mode == RXD_MODE_3B)
 		ering->rx_jumbo_max_pending = MAX_RX_DESC_2;
@@ -5619,7 +5642,7 @@ static void s2io_ethtool_getpause_data(struct net_device *dev,
  */
 
 static int s2io_ethtool_setpause_data(struct net_device *dev,
-			       struct ethtool_pauseparam *ep)
+				      struct ethtool_pauseparam *ep)
 {
 	u64 val64;
 	struct s2io_nic *sp = netdev_priv(dev);
@@ -5655,7 +5678,7 @@ static int s2io_ethtool_setpause_data(struct net_device *dev,
  */
 
 #define S2IO_DEV_ID		5
-static int read_eeprom(struct s2io_nic * sp, int off, u64 * data)
+static int read_eeprom(struct s2io_nic *sp, int off, u64 *data)
 {
 	int ret = -1;
 	u32 exit_cnt = 0;
@@ -5663,9 +5686,11 @@ static int read_eeprom(struct s2io_nic * sp, int off, u64 * data)
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	if (sp->device_type == XFRAME_I_DEVICE) {
-		val64 = I2C_CONTROL_DEV_ID(S2IO_DEV_ID) | I2C_CONTROL_ADDR(off) |
-		    I2C_CONTROL_BYTE_CNT(0x3) | I2C_CONTROL_READ |
-		    I2C_CONTROL_CNTL_START;
+		val64 = I2C_CONTROL_DEV_ID(S2IO_DEV_ID) |
+			I2C_CONTROL_ADDR(off) |
+			I2C_CONTROL_BYTE_CNT(0x3) |
+			I2C_CONTROL_READ |
+			I2C_CONTROL_CNTL_START;
 		SPECIAL_REG_WRITE(val64, &bar0->i2c_control, LF);
 
 		while (exit_cnt < 5) {
@@ -5720,16 +5745,18 @@ static int read_eeprom(struct s2io_nic * sp, int off, u64 * data)
  *  0 on success, -1 on failure.
  */
 
-static int write_eeprom(struct s2io_nic * sp, int off, u64 data, int cnt)
+static int write_eeprom(struct s2io_nic *sp, int off, u64 data, int cnt)
 {
 	int exit_cnt = 0, ret = -1;
 	u64 val64;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	if (sp->device_type == XFRAME_I_DEVICE) {
-		val64 = I2C_CONTROL_DEV_ID(S2IO_DEV_ID) | I2C_CONTROL_ADDR(off) |
-		    I2C_CONTROL_BYTE_CNT(cnt) | I2C_CONTROL_SET_DATA((u32)data) |
-		    I2C_CONTROL_CNTL_START;
+		val64 = I2C_CONTROL_DEV_ID(S2IO_DEV_ID) |
+			I2C_CONTROL_ADDR(off) |
+			I2C_CONTROL_BYTE_CNT(cnt) |
+			I2C_CONTROL_SET_DATA((u32)data) |
+			I2C_CONTROL_CNTL_START;
 		SPECIAL_REG_WRITE(val64, &bar0->i2c_control, LF);
 
 		while (exit_cnt < 5) {
@@ -5746,7 +5773,7 @@ static int write_eeprom(struct s2io_nic * sp, int off, u64 data, int cnt)
 
 	if (sp->device_type == XFRAME_II_DEVICE) {
 		int write_cnt = (cnt == 8) ? 0 : cnt;
-		writeq(SPI_DATA_WRITE(data,(cnt<<3)), &bar0->spi_data);
+		writeq(SPI_DATA_WRITE(data, (cnt << 3)), &bar0->spi_data);
 
 		val64 = SPI_CONTROL_KEY(0x9) | SPI_CONTROL_SEL1 |
 			SPI_CONTROL_BYTECNT(write_cnt) |
@@ -5773,14 +5800,13 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 {
 	u8 *vpd_data;
 	u8 data;
-	int i=0, cnt, fail = 0;
+	int i = 0, cnt, fail = 0;
 	int vpd_addr = 0x80;
 
 	if (nic->device_type == XFRAME_II_DEVICE) {
 		strcpy(nic->product_name, "Xframe II 10GbE network adapter");
 		vpd_addr = 0x80;
-	}
-	else {
+	} else {
 		strcpy(nic->product_name, "Xframe I 10GbE network adapter");
 		vpd_addr = 0x50;
 	}
@@ -5793,11 +5819,11 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 	}
 	nic->mac_control.stats_info->sw_stat.mem_allocated += 256;
 
-	for (i = 0; i < 256; i +=4 ) {
+	for (i = 0; i < 256; i += 4) {
 		pci_write_config_byte(nic->pdev, (vpd_addr + 2), i);
 		pci_read_config_byte(nic->pdev,  (vpd_addr + 2), &data);
 		pci_write_config_byte(nic->pdev, (vpd_addr + 3), 0);
-		for (cnt = 0; cnt <5; cnt++) {
+		for (cnt = 0; cnt < 5; cnt++) {
 			msleep(2);
 			pci_read_config_byte(nic->pdev, (vpd_addr + 3), &data);
 			if (data == 0x80)
@@ -5812,15 +5838,15 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 				      (u32 *)&vpd_data[i]);
 	}
 
-	if(!fail) {
+	if (!fail) {
 		/* read serial number of adapter */
 		for (cnt = 0; cnt < 256; cnt++) {
-		if ((vpd_data[cnt] == 'S') &&
-			(vpd_data[cnt+1] == 'N') &&
-			(vpd_data[cnt+2] < VPD_STRING_LEN)) {
+			if ((vpd_data[cnt] == 'S') &&
+			    (vpd_data[cnt+1] == 'N') &&
+			    (vpd_data[cnt+2] < VPD_STRING_LEN)) {
 				memset(nic->serial_num, 0, VPD_STRING_LEN);
 				memcpy(nic->serial_num, &vpd_data[cnt + 3],
-					vpd_data[cnt+2]);
+				       vpd_data[cnt+2]);
 				break;
 			}
 		}
@@ -5848,7 +5874,7 @@ static void s2io_vpd_read(struct s2io_nic *nic)
  */
 
 static int s2io_ethtool_geeprom(struct net_device *dev,
-			 struct ethtool_eeprom *eeprom, u8 * data_buf)
+				struct ethtool_eeprom *eeprom, u8 * data_buf)
 {
 	u32 i, valid;
 	u64 data;
@@ -5886,7 +5912,7 @@ static int s2io_ethtool_geeprom(struct net_device *dev,
 
 static int s2io_ethtool_seeprom(struct net_device *dev,
 				struct ethtool_eeprom *eeprom,
-				u8 * data_buf)
+				u8 *data_buf)
 {
 	int len = eeprom->len, cnt = 0;
 	u64 valid = 0, data;
@@ -5895,16 +5921,15 @@ static int s2io_ethtool_seeprom(struct net_device *dev,
 	if (eeprom->magic != (sp->pdev->vendor | (sp->pdev->device << 16))) {
 		DBG_PRINT(ERR_DBG,
 			  "ETHTOOL_WRITE_EEPROM Err: Magic value ");
-		DBG_PRINT(ERR_DBG, "is wrong, Its not 0x%x\n",
-			  eeprom->magic);
+		DBG_PRINT(ERR_DBG, "is wrong, Its not 0x%x\n", eeprom->magic);
 		return -EFAULT;
 	}
 
 	while (len) {
-		data = (u32) data_buf[cnt] & 0x000000FF;
-		if (data) {
-			valid = (u32) (data << 24);
-		} else
+		data = (u32)data_buf[cnt] & 0x000000FF;
+		if (data)
+			valid = (u32)(data << 24);
+		else
 			valid = data;
 
 		if (write_eeprom(sp, (eeprom->offset + cnt), valid, 0)) {
@@ -5934,7 +5959,7 @@ static int s2io_ethtool_seeprom(struct net_device *dev,
  * 0 on success.
  */
 
-static int s2io_register_test(struct s2io_nic * sp, uint64_t * data)
+static int s2io_register_test(struct s2io_nic *sp, uint64_t *data)
 {
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64 = 0, exp_val;
@@ -6001,7 +6026,7 @@ static int s2io_register_test(struct s2io_nic * sp, uint64_t * data)
  * 0 on success.
  */
 
-static int s2io_eeprom_test(struct s2io_nic * sp, uint64_t * data)
+static int s2io_eeprom_test(struct s2io_nic *sp, uint64_t *data)
 {
 	int fail = 0;
 	u64 ret_data, org_4F0, org_7F0;
@@ -6030,9 +6055,9 @@ static int s2io_eeprom_test(struct s2io_nic * sp, uint64_t * data)
 
 	if (ret_data != 0x012345) {
 		DBG_PRINT(ERR_DBG, "%s: eeprom test error at offset 0x4F0. "
-			"Data written %llx Data read %llx\n",
-			dev->name, (unsigned long long)0x12345,
-			(unsigned long long)ret_data);
+			  "Data written %llx Data read %llx\n",
+			  dev->name, (unsigned long long)0x12345,
+			  (unsigned long long)ret_data);
 		fail = 1;
 	}
 
@@ -6052,9 +6077,9 @@ static int s2io_eeprom_test(struct s2io_nic * sp, uint64_t * data)
 
 	if (ret_data != 0x012345) {
 		DBG_PRINT(ERR_DBG, "%s: eeprom test error at offset 0x7F0. "
-			"Data written %llx Data read %llx\n",
-			dev->name, (unsigned long long)0x12345,
-			(unsigned long long)ret_data);
+			  "Data written %llx Data read %llx\n",
+			  dev->name, (unsigned long long)0x12345,
+			  (unsigned long long)ret_data);
 		fail = 1;
 	}
 
@@ -6103,7 +6128,7 @@ static int s2io_eeprom_test(struct s2io_nic * sp, uint64_t * data)
  * 0 on success and -1 on failure.
  */
 
-static int s2io_bist_test(struct s2io_nic * sp, uint64_t * data)
+static int s2io_bist_test(struct s2io_nic *sp, uint64_t *data)
 {
 	u8 bist = 0;
 	int cnt = 0, ret = -1;
@@ -6139,13 +6164,13 @@ static int s2io_bist_test(struct s2io_nic * sp, uint64_t * data)
  * 0 on success.
  */
 
-static int s2io_link_test(struct s2io_nic * sp, uint64_t * data)
+static int s2io_link_test(struct s2io_nic *sp, uint64_t *data)
 {
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64;
 
 	val64 = readq(&bar0->adapter_status);
-	if(!(LINK_IS_UP(val64)))
+	if (!(LINK_IS_UP(val64)))
 		*data = 1;
 	else
 		*data = 0;
@@ -6166,7 +6191,7 @@ static int s2io_link_test(struct s2io_nic * sp, uint64_t * data)
  *  0 on success.
  */
 
-static int s2io_rldram_test(struct s2io_nic * sp, uint64_t * data)
+static int s2io_rldram_test(struct s2io_nic *sp, uint64_t *data)
 {
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64;
@@ -6189,28 +6214,26 @@ static int s2io_rldram_test(struct s2io_nic * sp, uint64_t * data)
 
 	while (iteration < 2) {
 		val64 = 0x55555555aaaa0000ULL;
-		if (iteration == 1) {
+		if (iteration == 1)
 			val64 ^= 0xFFFFFFFFFFFF0000ULL;
-		}
 		writeq(val64, &bar0->mc_rldram_test_d0);
 
 		val64 = 0xaaaa5a5555550000ULL;
-		if (iteration == 1) {
+		if (iteration == 1)
 			val64 ^= 0xFFFFFFFFFFFF0000ULL;
-		}
 		writeq(val64, &bar0->mc_rldram_test_d1);
 
 		val64 = 0x55aaaaaaaa5a0000ULL;
-		if (iteration == 1) {
+		if (iteration == 1)
 			val64 ^= 0xFFFFFFFFFFFF0000ULL;
-		}
 		writeq(val64, &bar0->mc_rldram_test_d2);
 
 		val64 = (u64) (0x0000003ffffe0100ULL);
 		writeq(val64, &bar0->mc_rldram_test_add);
 
-		val64 = MC_RLDRAM_TEST_MODE | MC_RLDRAM_TEST_WRITE |
-		    	MC_RLDRAM_TEST_GO;
+		val64 = MC_RLDRAM_TEST_MODE |
+			MC_RLDRAM_TEST_WRITE |
+			MC_RLDRAM_TEST_GO;
 		SPECIAL_REG_WRITE(val64, &bar0->mc_rldram_test_ctrl, LF);
 
 		for (cnt = 0; cnt < 5; cnt++) {
@@ -6268,7 +6291,7 @@ static int s2io_rldram_test(struct s2io_nic * sp, uint64_t * data)
 
 static void s2io_ethtool_test(struct net_device *dev,
 			      struct ethtool_test *ethtest,
-			      uint64_t * data)
+			      uint64_t *data)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
 	int orig_state = netif_running(sp->dev);
@@ -6301,8 +6324,7 @@ static void s2io_ethtool_test(struct net_device *dev,
 	} else {
 		/* Online Tests. */
 		if (!orig_state) {
-			DBG_PRINT(ERR_DBG,
-				  "%s: is not up, cannot run test\n",
+			DBG_PRINT(ERR_DBG, "%s: is not up, cannot run test\n",
 				  dev->name);
 			data[0] = -1;
 			data[1] = -1;
@@ -6323,7 +6345,7 @@ static void s2io_ethtool_test(struct net_device *dev,
 
 static void s2io_get_ethtool_stats(struct net_device *dev,
 				   struct ethtool_stats *estats,
-				   u64 * tmp_stats)
+				   u64 *tmp_stats)
 {
 	int i = 0, k;
 	struct s2io_nic *sp = netdev_priv(dev);
@@ -6344,19 +6366,19 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 		(u64)le32_to_cpu(stat_info->tmac_bcst_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->tmac_bcst_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_pause_ctrl_frms);
-        tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->tmac_ttl_octets_oflow) << 32 |
-                le32_to_cpu(stat_info->tmac_ttl_octets);
 	tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->tmac_ucst_frms_oflow) << 32 |
-                le32_to_cpu(stat_info->tmac_ucst_frms);
+		(u64)le32_to_cpu(stat_info->tmac_ttl_octets_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_ttl_octets);
 	tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->tmac_nucst_frms_oflow) << 32 |
-                le32_to_cpu(stat_info->tmac_nucst_frms);
+		(u64)le32_to_cpu(stat_info->tmac_ucst_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_ucst_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_nucst_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_nucst_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->tmac_any_err_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->tmac_any_err_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->tmac_ttl_less_fb_octets);
+	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_ttl_less_fb_octets);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_vld_ip_octets);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->tmac_vld_ip_oflow) << 32 |
@@ -6392,23 +6414,23 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_long_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_pause_ctrl_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_unsup_ctrl_frms);
-        tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->rmac_ttl_octets_oflow) << 32 |
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_ttl_octets_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_ttl_octets);
-        tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->rmac_accepted_ucst_frms_oflow)
-		<< 32 | le32_to_cpu(stat_info->rmac_accepted_ucst_frms);
 	tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->rmac_accepted_nucst_frms_oflow)
-                 << 32 | le32_to_cpu(stat_info->rmac_accepted_nucst_frms);
+		(u64)le32_to_cpu(stat_info->rmac_accepted_ucst_frms_oflow) << 32
+		| le32_to_cpu(stat_info->rmac_accepted_ucst_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_accepted_nucst_frms_oflow)
+		<< 32 | le32_to_cpu(stat_info->rmac_accepted_nucst_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_discarded_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_discarded_frms);
-        tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->rmac_drop_events_oflow)
-                 << 32 | le32_to_cpu(stat_info->rmac_drop_events);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_less_fb_octets);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_drop_events_oflow)
+		<< 32 | le32_to_cpu(stat_info->rmac_drop_events);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_less_fb_octets);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_usized_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_usized_frms);
@@ -6422,11 +6444,11 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 		(u64)le32_to_cpu(stat_info->rmac_jabber_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_jabber_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_64_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_65_127_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_128_255_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_256_511_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_512_1023_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_1024_1518_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_65_127_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_128_255_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_256_511_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_512_1023_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_1024_1518_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_ip_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_ip);
@@ -6446,27 +6468,27 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 		(u64)le32_to_cpu(stat_info->rmac_err_drp_udp_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_err_drp_udp);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_err_sym);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q0);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q1);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q2);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q3);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q4);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q5);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q6);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q7);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q0);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q1);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q2);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q3);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q4);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q5);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q6);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q7);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q0);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q1);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q2);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q3);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q4);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q5);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q6);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q7);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q0);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q1);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q2);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q3);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q4);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q5);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q6);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q7);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_pause_cnt_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_pause_cnt);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_data_err_cnt);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_ctrl_err_cnt);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_ctrl_err_cnt);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_accepted_ip_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_accepted_ip);
@@ -6491,13 +6513,13 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 	tmp_stats[i++] = le32_to_cpu(stat_info->rxf_wr_cnt);
 
 	/* Enhanced statistics exist only for Hercules */
-	if(sp->device_type == XFRAME_II_DEVICE) {
+	if (sp->device_type == XFRAME_II_DEVICE) {
 		tmp_stats[i++] =
-				le64_to_cpu(stat_info->rmac_ttl_1519_4095_frms);
+			le64_to_cpu(stat_info->rmac_ttl_1519_4095_frms);
 		tmp_stats[i++] =
-				le64_to_cpu(stat_info->rmac_ttl_4096_8191_frms);
+			le64_to_cpu(stat_info->rmac_ttl_4096_8191_frms);
 		tmp_stats[i++] =
-				le64_to_cpu(stat_info->rmac_ttl_8192_max_frms);
+			le64_to_cpu(stat_info->rmac_ttl_8192_max_frms);
 		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_gt_max_frms);
 		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_osized_alt_frms);
 		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_jabber_alt_frms);
@@ -6550,8 +6572,7 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 			count++;
 		}
 		tmp_stats[i++] = count;
-	}
-	else
+	} else
 		tmp_stats[i++] = 0;
 	tmp_stats[i++] = stat_info->sw_stat.mem_alloc_fail_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.pci_map_fail_cnt;
@@ -6599,15 +6620,15 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 
 static int s2io_ethtool_get_regs_len(struct net_device *dev)
 {
-	return (XENA_REG_SPACE);
+	return XENA_REG_SPACE;
 }
 
 
-static u32 s2io_ethtool_get_rx_csum(struct net_device * dev)
+static u32 s2io_ethtool_get_rx_csum(struct net_device *dev)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
 
-	return (sp->rx_csum);
+	return sp->rx_csum;
 }
 
 static int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
@@ -6624,7 +6645,7 @@ static int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
 
 static int s2io_get_eeprom_len(struct net_device *dev)
 {
-	return (XENA_EEPROM_SPACE);
+	return XENA_EEPROM_SPACE;
 }
 
 static int s2io_get_sset_count(struct net_device *dev, int sset)
@@ -6635,7 +6656,7 @@ static int s2io_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_TEST:
 		return S2IO_TEST_LEN;
 	case ETH_SS_STATS:
-		switch(sp->device_type) {
+		switch (sp->device_type) {
 		case XFRAME_I_DEVICE:
 			return XFRAME_I_STAT_LEN;
 		case XFRAME_II_DEVICE:
@@ -6649,7 +6670,7 @@ static int s2io_get_sset_count(struct net_device *dev, int sset)
 }
 
 static void s2io_ethtool_get_strings(struct net_device *dev,
-				     u32 stringset, u8 * data)
+				     u32 stringset, u8 *data)
 {
 	int stat_size = 0;
 	struct s2io_nic *sp = netdev_priv(dev);
@@ -6660,16 +6681,16 @@ static void s2io_ethtool_get_strings(struct net_device *dev,
 		break;
 	case ETH_SS_STATS:
 		stat_size = sizeof(ethtool_xena_stats_keys);
-		memcpy(data, &ethtool_xena_stats_keys,stat_size);
-		if(sp->device_type == XFRAME_II_DEVICE) {
+		memcpy(data, &ethtool_xena_stats_keys, stat_size);
+		if (sp->device_type == XFRAME_II_DEVICE) {
 			memcpy(data + stat_size,
-				&ethtool_enhanced_stats_keys,
-				sizeof(ethtool_enhanced_stats_keys));
+			       &ethtool_enhanced_stats_keys,
+			       sizeof(ethtool_enhanced_stats_keys));
 			stat_size += sizeof(ethtool_enhanced_stats_keys);
 		}
 
 		memcpy(data + stat_size, &ethtool_driver_stats_keys,
-			sizeof(ethtool_driver_stats_keys));
+		       sizeof(ethtool_driver_stats_keys));
 	}
 }
 
@@ -6758,8 +6779,7 @@ static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 	int ret = 0;
 
 	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {
-		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n",
-			  dev->name);
+		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n", dev->name);
 		return -EPERM;
 	}
 
@@ -6792,7 +6812,8 @@ static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 
 static void s2io_set_link(struct work_struct *work)
 {
-	struct s2io_nic *nic = container_of(work, struct s2io_nic, set_link_task);
+	struct s2io_nic *nic = container_of(work, struct s2io_nic,
+					    set_link_task);
 	struct net_device *dev = nic->dev;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 val64;
@@ -6825,7 +6846,7 @@ static void s2io_set_link(struct work_struct *work)
 				val64 |= ADAPTER_CNTL_EN;
 				writeq(val64, &bar0->adapter_control);
 				if (CARDS_WITH_FAULTY_LINK_INDICATORS(
-					nic->device_type, subid)) {
+					    nic->device_type, subid)) {
 					val64 = readq(&bar0->gpio_control);
 					val64 |= GPIO_CTRL_GPIO_0;
 					writeq(val64, &bar0->gpio_control);
@@ -6855,7 +6876,7 @@ static void s2io_set_link(struct work_struct *work)
 		}
 		/* turn off LED */
 		val64 = readq(&bar0->adapter_control);
-		val64 = val64 &(~ADAPTER_LED_ON);
+		val64 = val64 & (~ADAPTER_LED_ON);
 		writeq(val64, &bar0->adapter_control);
 		s2io_link(nic, LINK_DOWN);
 	}
@@ -6866,9 +6887,9 @@ out_unlock:
 }
 
 static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
-				struct buffAdd *ba,
-				struct sk_buff **skb, u64 *temp0, u64 *temp1,
-				u64 *temp2, int size)
+				  struct buffAdd *ba,
+				  struct sk_buff **skb, u64 *temp0, u64 *temp1,
+				  u64 *temp2, int size)
 {
 	struct net_device *dev = sp->dev;
 	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
@@ -6890,7 +6911,7 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
 				DBG_PRINT(INFO_DBG, "memory to allocate ");
 				DBG_PRINT(INFO_DBG, "1 buf mode SKBs\n");
-				sp->mac_control.stats_info->sw_stat. \
+				sp->mac_control.stats_info->sw_stat.
 					mem_alloc_fail_cnt++;
 				return -ENOMEM ;
 			}
@@ -6901,9 +6922,9 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			 * Host Control is NULL
 			 */
 			rxdp1->Buffer0_ptr = *temp0 =
-				pci_map_single( sp->pdev, (*skb)->data,
-					size - NET_IP_ALIGN,
-					PCI_DMA_FROMDEVICE);
+				pci_map_single(sp->pdev, (*skb)->data,
+					       size - NET_IP_ALIGN,
+					       PCI_DMA_FROMDEVICE);
 			if (pci_dma_mapping_error(sp->pdev, rxdp1->Buffer0_ptr))
 				goto memalloc_failed;
 			rxdp->Host_Control = (unsigned long) (*skb);
@@ -6921,7 +6942,7 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
 				DBG_PRINT(INFO_DBG, "memory to allocate ");
 				DBG_PRINT(INFO_DBG, "2 buf mode SKBs\n");
-				sp->mac_control.stats_info->sw_stat. \
+				sp->mac_control.stats_info->sw_stat.
 					mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
@@ -6934,13 +6955,14 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			if (pci_dma_mapping_error(sp->pdev, rxdp3->Buffer2_ptr))
 				goto memalloc_failed;
 			rxdp3->Buffer0_ptr = *temp0 =
-				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
-						PCI_DMA_FROMDEVICE);
+				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,
+					       PCI_DMA_FROMDEVICE);
 			if (pci_dma_mapping_error(sp->pdev,
-						rxdp3->Buffer0_ptr)) {
-				pci_unmap_single (sp->pdev,
-					(dma_addr_t)rxdp3->Buffer2_ptr,
-					dev->mtu + 4, PCI_DMA_FROMDEVICE);
+						  rxdp3->Buffer0_ptr)) {
+				pci_unmap_single(sp->pdev,
+						 (dma_addr_t)rxdp3->Buffer2_ptr,
+						 dev->mtu + 4,
+						 PCI_DMA_FROMDEVICE);
 				goto memalloc_failed;
 			}
 			rxdp->Host_Control = (unsigned long) (*skb);
@@ -6948,25 +6970,27 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			/* Buffer-1 will be dummy buffer not used */
 			rxdp3->Buffer1_ptr = *temp1 =
 				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
-						PCI_DMA_FROMDEVICE);
+					       PCI_DMA_FROMDEVICE);
 			if (pci_dma_mapping_error(sp->pdev,
-						rxdp3->Buffer1_ptr)) {
-				pci_unmap_single (sp->pdev,
-					(dma_addr_t)rxdp3->Buffer0_ptr,
-					BUF0_LEN, PCI_DMA_FROMDEVICE);
-				pci_unmap_single (sp->pdev,
-					(dma_addr_t)rxdp3->Buffer2_ptr,
-					dev->mtu + 4, PCI_DMA_FROMDEVICE);
+						  rxdp3->Buffer1_ptr)) {
+				pci_unmap_single(sp->pdev,
+						 (dma_addr_t)rxdp3->Buffer0_ptr,
+						 BUF0_LEN, PCI_DMA_FROMDEVICE);
+				pci_unmap_single(sp->pdev,
+						 (dma_addr_t)rxdp3->Buffer2_ptr,
+						 dev->mtu + 4,
+						 PCI_DMA_FROMDEVICE);
 				goto memalloc_failed;
 			}
 		}
 	}
 	return 0;
-	memalloc_failed:
-		stats->pci_map_fail_cnt++;
-		stats->mem_freed += (*skb)->truesize;
-		dev_kfree_skb(*skb);
-		return -ENOMEM;
+
+memalloc_failed:
+	stats->pci_map_fail_cnt++;
+	stats->mem_freed += (*skb)->truesize;
+	dev_kfree_skb(*skb);
+	return -ENOMEM;
 }
 
 static void set_rxd_buffer_size(struct s2io_nic *sp, struct RxD_t *rxdp,
@@ -6974,18 +6998,18 @@ static void set_rxd_buffer_size(struct s2io_nic *sp, struct RxD_t *rxdp,
 {
 	struct net_device *dev = sp->dev;
 	if (sp->rxd_mode == RXD_MODE_1) {
-		rxdp->Control_2 = SET_BUFFER0_SIZE_1( size - NET_IP_ALIGN);
+		rxdp->Control_2 = SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
 	} else if (sp->rxd_mode == RXD_MODE_3B) {
 		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
-		rxdp->Control_2 |= SET_BUFFER2_SIZE_3( dev->mtu + 4);
+		rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu + 4);
 	}
 }
 
 static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 {
 	int i, j, k, blk_cnt = 0, size;
-	struct mac_info * mac_control = &sp->mac_control;
+	struct mac_info *mac_control = &sp->mac_control;
 	struct config_param *config = &sp->config;
 	struct net_device *dev = sp->dev;
 	struct RxD_t *rxdp = NULL;
@@ -7005,18 +7029,18 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 		struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
 		struct ring_info *ring = &mac_control->rings[i];
 
-		blk_cnt = rx_cfg->num_rxd / (rxd_count[sp->rxd_mode] +1);
+		blk_cnt = rx_cfg->num_rxd / (rxd_count[sp->rxd_mode] + 1);
 
 		for (j = 0; j < blk_cnt; j++) {
 			for (k = 0; k < rxd_count[sp->rxd_mode]; k++) {
-				rxdp = ring-> rx_blocks[j].rxds[k].virt_addr;
-				if(sp->rxd_mode == RXD_MODE_3B)
+				rxdp = ring->rx_blocks[j].rxds[k].virt_addr;
+				if (sp->rxd_mode == RXD_MODE_3B)
 					ba = &ring->ba[j][k];
-				if (set_rxd_buffer_pointer(sp, rxdp, ba,
-						       &skb,(u64 *)&temp0_64,
-						       (u64 *)&temp1_64,
-						       (u64 *)&temp2_64,
-							size) == -ENOMEM) {
+				if (set_rxd_buffer_pointer(sp, rxdp, ba, &skb,
+							   (u64 *)&temp0_64,
+							   (u64 *)&temp1_64,
+							   (u64 *)&temp2_64,
+							   size) == -ENOMEM) {
 					return 0;
 				}
 
@@ -7031,7 +7055,7 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 
 }
 
-static int s2io_add_isr(struct s2io_nic * sp)
+static int s2io_add_isr(struct s2io_nic *sp)
 {
 	int ret = 0;
 	struct net_device *dev = sp->dev;
@@ -7044,7 +7068,10 @@ static int s2io_add_isr(struct s2io_nic * sp)
 		sp->config.intr_type = INTA;
 	}
 
-	/* Store the values of the MSIX table in the struct s2io_nic structure */
+	/*
+	 * Store the values of the MSIX table in
+	 * the struct s2io_nic structure
+	 */
 	store_xmsi_data(sp);
 
 	/* After proper initialization of H/W, register ISR */
@@ -7054,45 +7081,47 @@ static int s2io_add_isr(struct s2io_nic * sp)
 		for (i = 0; i < sp->num_entries; i++) {
 			if (sp->s2io_entries[i].in_use == MSIX_FLG) {
 				if (sp->s2io_entries[i].type ==
-					MSIX_RING_TYPE) {
+				    MSIX_RING_TYPE) {
 					sprintf(sp->desc[i], "%s:MSI-X-%d-RX",
 						dev->name, i);
 					err = request_irq(sp->entries[i].vector,
-						s2io_msix_ring_handle, 0,
-						sp->desc[i],
-						sp->s2io_entries[i].arg);
+							  s2io_msix_ring_handle,
+							  0,
+							  sp->desc[i],
+							  sp->s2io_entries[i].arg);
 				} else if (sp->s2io_entries[i].type ==
-					MSIX_ALARM_TYPE) {
+					   MSIX_ALARM_TYPE) {
 					sprintf(sp->desc[i], "%s:MSI-X-%d-TX",
-					dev->name, i);
+						dev->name, i);
 					err = request_irq(sp->entries[i].vector,
-						s2io_msix_fifo_handle, 0,
-						sp->desc[i],
-						sp->s2io_entries[i].arg);
+							  s2io_msix_fifo_handle,
+							  0,
+							  sp->desc[i],
+							  sp->s2io_entries[i].arg);
 
 				}
 				/* if either data or addr is zero print it. */
 				if (!(sp->msix_info[i].addr &&
-					sp->msix_info[i].data)) {
+				      sp->msix_info[i].data)) {
 					DBG_PRINT(ERR_DBG,
-						"%s @Addr:0x%llx Data:0x%llx\n",
-						sp->desc[i],
-						(unsigned long long)
-						sp->msix_info[i].addr,
-						(unsigned long long)
-						ntohl(sp->msix_info[i].data));
+						  "%s @Addr:0x%llx Data:0x%llx\n",
+						  sp->desc[i],
+						  (unsigned long long)
+						  sp->msix_info[i].addr,
+						  (unsigned long long)
+						  ntohl(sp->msix_info[i].data));
 				} else
 					msix_rx_cnt++;
 				if (err) {
 					remove_msix_isr(sp);
 
 					DBG_PRINT(ERR_DBG,
-						"%s:MSI-X-%d registration "
-						"failed\n", dev->name, i);
+						  "%s:MSI-X-%d registration "
+						  "failed\n", dev->name, i);
 
 					DBG_PRINT(ERR_DBG,
-						"%s: Defaulting to INTA\n",
-						dev->name);
+						  "%s: Defaulting to INTA\n",
+						  dev->name);
 					sp->config.intr_type = INTA;
 					break;
 				}
@@ -7102,14 +7131,14 @@ static int s2io_add_isr(struct s2io_nic * sp)
 		}
 		if (!err) {
 			printk(KERN_INFO "MSI-X-RX %d entries enabled\n",
-				--msix_rx_cnt);
+			       --msix_rx_cnt);
 			DBG_PRINT(INFO_DBG, "MSI-X-TX entries enabled"
-						" through alarm vector\n");
+				  " through alarm vector\n");
 		}
 	}
 	if (sp->config.intr_type == INTA) {
-		err = request_irq((int) sp->pdev->irq, s2io_isr, IRQF_SHARED,
-				sp->name, dev);
+		err = request_irq((int)sp->pdev->irq, s2io_isr, IRQF_SHARED,
+				  sp->name, dev);
 		if (err) {
 			DBG_PRINT(ERR_DBG, "%s: ISR registration failed\n",
 				  dev->name);
@@ -7118,7 +7147,8 @@ static int s2io_add_isr(struct s2io_nic * sp)
 	}
 	return 0;
 }
-static void s2io_rem_isr(struct s2io_nic * sp)
+
+static void s2io_rem_isr(struct s2io_nic *sp)
 {
 	if (sp->config.intr_type == MSI_X)
 		remove_msix_isr(sp);
@@ -7126,7 +7156,7 @@ static void s2io_rem_isr(struct s2io_nic * sp)
 		remove_inta_isr(sp);
 }
 
-static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
+static void do_s2io_card_down(struct s2io_nic *sp, int do_io)
 {
 	int cnt = 0;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
@@ -7139,9 +7169,8 @@ static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 
 	del_timer_sync(&sp->alarm_timer);
 	/* If s2io_set_link task is executing, wait till it completes. */
-	while (test_and_set_bit(__S2IO_STATE_LINK_TASK, &(sp->state))) {
+	while (test_and_set_bit(__S2IO_STATE_LINK_TASK, &(sp->state)))
 		msleep(50);
-	}
 	clear_bit(__S2IO_STATE_CARD_UP, &sp->state);
 
 	/* Disable napi */
@@ -7150,7 +7179,7 @@ static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 		if (config->intr_type ==  MSI_X) {
 			for (; off < sp->config.rx_ring_num; off++)
 				napi_disable(&sp->mac_control.rings[off].napi);
-			}
+		}
 		else
 			napi_disable(&sp->napi);
 	}
@@ -7165,7 +7194,7 @@ static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 	s2io_link(sp, LINK_DOWN);
 
 	/* Check if the device is Quiescent and then Reset the NIC */
-	while(do_io) {
+	while (do_io) {
 		/* As per the HW requirement we need to replenish the
 		 * receive buffer to avoid the ring bump. Since there is
 		 * no intention of processing the Rx frame at this pointwe are
@@ -7177,17 +7206,16 @@ static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 
 		val64 = readq(&bar0->adapter_status);
 		if (verify_xena_quiescence(sp)) {
-			if(verify_pcc_quiescent(sp, sp->device_enabled_once))
-			break;
+			if (verify_pcc_quiescent(sp, sp->device_enabled_once))
+				break;
 		}
 
 		msleep(50);
 		cnt++;
 		if (cnt == 10) {
-			DBG_PRINT(ERR_DBG,
-				  "s2io_close:Device not Quiescent ");
+			DBG_PRINT(ERR_DBG, "s2io_close:Device not Quiescent ");
 			DBG_PRINT(ERR_DBG, "adaper status reads 0x%llx\n",
-				  (unsigned long long) val64);
+				  (unsigned long long)val64);
 			break;
 		}
 	}
@@ -7203,17 +7231,17 @@ static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 	clear_bit(__S2IO_STATE_LINK_TASK, &(sp->state));
 }
 
-static void s2io_card_down(struct s2io_nic * sp)
+static void s2io_card_down(struct s2io_nic *sp)
 {
 	do_s2io_card_down(sp, 1);
 }
 
-static int s2io_card_up(struct s2io_nic * sp)
+static int s2io_card_up(struct s2io_nic *sp)
 {
 	int i, ret = 0;
 	struct mac_info *mac_control;
 	struct config_param *config;
-	struct net_device *dev = (struct net_device *) sp->dev;
+	struct net_device *dev = (struct net_device *)sp->dev;
 	u16 interruptible;
 
 	/* Initialize the H/W I/O registers */
@@ -7264,7 +7292,7 @@ static int s2io_card_up(struct s2io_nic * sp)
 		sp->promisc_flg = 0;
 	if (sp->m_cast_flg) {
 		sp->m_cast_flg = 0;
-		sp->all_multi_pos= 0;
+		sp->all_multi_pos = 0;
 	}
 
 	/* Setting its receive mode */
@@ -7273,7 +7301,7 @@ static int s2io_card_up(struct s2io_nic * sp)
 	if (sp->lro) {
 		/* Initialize max aggregatable pkts per session based on MTU */
 		sp->lro_max_aggr_per_sess = ((1<<16) - 1) / dev->mtu;
-		/* Check if we can use(if specified) user provided value */
+		/* Check if we can use (if specified) user provided value */
 		if (lro_max_pkts < sp->lro_max_aggr_per_sess)
 			sp->lro_max_aggr_per_sess = lro_max_pkts;
 	}
@@ -7335,12 +7363,10 @@ static void s2io_restart_nic(struct work_struct *work)
 
 	s2io_card_down(sp);
 	if (s2io_card_up(sp)) {
-		DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
-			  dev->name);
+		DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n", dev->name);
 	}
 	s2io_wake_all_tx_queue(sp);
-	DBG_PRINT(ERR_DBG, "%s: was reset by Tx watchdog timer\n",
-		  dev->name);
+	DBG_PRINT(ERR_DBG, "%s: was reset by Tx watchdog timer\n", dev->name);
 out_unlock:
 	rtnl_unlock();
 }
@@ -7389,9 +7415,9 @@ static void s2io_tx_watchdog(struct net_device *dev)
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 {
 	struct s2io_nic *sp = ring_data->nic;
-	struct net_device *dev = (struct net_device *) ring_data->dev;
+	struct net_device *dev = (struct net_device *)ring_data->dev;
 	struct sk_buff *skb = (struct sk_buff *)
-		((unsigned long) rxdp->Host_Control);
+		((unsigned long)rxdp->Host_Control);
 	int ring_no = ring_data->ring_no;
 	u16 l3_csum, l4_csum;
 	unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
@@ -7402,66 +7428,57 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 
 	if (err) {
 		/* Check for parity error */
-		if (err & 0x1) {
+		if (err & 0x1)
 			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
-		}
+
 		err_mask = err >> 48;
-		switch(err_mask) {
-			case 1:
-				sp->mac_control.stats_info->sw_stat.
-				rx_parity_err_cnt++;
+		switch (err_mask) {
+		case 1:
+			sp->mac_control.stats_info->sw_stat.rx_parity_err_cnt++;
 			break;
 
-			case 2:
-				sp->mac_control.stats_info->sw_stat.
-				rx_abort_cnt++;
+		case 2:
+			sp->mac_control.stats_info->sw_stat.rx_abort_cnt++;
 			break;
 
-			case 3:
-				sp->mac_control.stats_info->sw_stat.
-				rx_parity_abort_cnt++;
+		case 3:
+			sp->mac_control.stats_info->sw_stat.rx_parity_abort_cnt++;
 			break;
 
-			case 4:
-				sp->mac_control.stats_info->sw_stat.
-				rx_rda_fail_cnt++;
+		case 4:
+			sp->mac_control.stats_info->sw_stat.rx_rda_fail_cnt++;
 			break;
 
-			case 5:
-				sp->mac_control.stats_info->sw_stat.
-				rx_unkn_prot_cnt++;
+		case 5:
+			sp->mac_control.stats_info->sw_stat.rx_unkn_prot_cnt++;
 			break;
 
-			case 6:
-				sp->mac_control.stats_info->sw_stat.
-				rx_fcs_err_cnt++;
+		case 6:
+			sp->mac_control.stats_info->sw_stat.rx_fcs_err_cnt++;
 			break;
 
-			case 7:
-				sp->mac_control.stats_info->sw_stat.
-				rx_buf_size_err_cnt++;
+		case 7:
+			sp->mac_control.stats_info->sw_stat.rx_buf_size_err_cnt++;
 			break;
 
-			case 8:
-				sp->mac_control.stats_info->sw_stat.
-				rx_rxd_corrupt_cnt++;
+		case 8:
+			sp->mac_control.stats_info->sw_stat.rx_rxd_corrupt_cnt++;
 			break;
 
-			case 15:
-				sp->mac_control.stats_info->sw_stat.
-				rx_unkn_err_cnt++;
+		case 15:
+			sp->mac_control.stats_info->sw_stat.rx_unkn_err_cnt++;
 			break;
 		}
 		/*
-		* Drop the packet if bad transfer code. Exception being
-		* 0x5, which could be due to unsupported IPv6 extension header.
-		* In this case, we let stack handle the packet.
-		* Note that in this case, since checksum will be incorrect,
-		* stack will validate the same.
-		*/
+		 * Drop the packet if bad transfer code. Exception being
+		 * 0x5, which could be due to unsupported IPv6 extension header.
+		 * In this case, we let stack handle the packet.
+		 * Note that in this case, since checksum will be incorrect,
+		 * stack will validate the same.
+		 */
 		if (err_mask != 0x5) {
 			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%x\n",
-				dev->name, err_mask);
+				  dev->name, err_mask);
 			dev->stats.rx_crc_errors++;
 			sp->mac_control.stats_info->sw_stat.mem_freed
 				+= skb->truesize;
@@ -7494,8 +7511,9 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		skb_put(skb, buf2_len);
 	}
 
-	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && ((!ring_data->lro) ||
-	    (ring_data->lro && (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG)))) &&
+	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) &&
+	    ((!ring_data->lro) ||
+	     (ring_data->lro && (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG)))) &&
 	    (sp->rx_csum)) {
 		l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
 		l4_csum = RXD_GET_L4_CKSUM(rxdp->Control_1);
@@ -7512,52 +7530,44 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 				int ret = 0;
 
 				ret = s2io_club_tcp_session(ring_data,
-					skb->data, &tcp, &tcp_len, &lro,
-					rxdp, sp);
+							    skb->data, &tcp,
+							    &tcp_len, &lro,
+							    rxdp, sp);
 				switch (ret) {
-					case 3: /* Begin anew */
-						lro->parent = skb;
-						goto aggregate;
-					case 1: /* Aggregate */
-					{
-						lro_append_pkt(sp, lro,
-							skb, tcp_len);
-						goto aggregate;
-					}
-					case 4: /* Flush session */
-					{
-						lro_append_pkt(sp, lro,
-							skb, tcp_len);
-						queue_rx_frame(lro->parent,
-							lro->vlan_tag);
-						clear_lro_session(lro);
-						sp->mac_control.stats_info->
-						    sw_stat.flush_max_pkts++;
-						goto aggregate;
-					}
-					case 2: /* Flush both */
-						lro->parent->data_len =
-							lro->frags_len;
-						sp->mac_control.stats_info->
-						     sw_stat.sending_both++;
-						queue_rx_frame(lro->parent,
-							lro->vlan_tag);
-						clear_lro_session(lro);
-						goto send_up;
-					case 0: /* sessions exceeded */
-					case -1: /* non-TCP or not
-						  * L2 aggregatable
-						  */
-					case 5: /*
-						 * First pkt in session not
-						 * L3/L4 aggregatable
-						 */
-						break;
-					default:
-						DBG_PRINT(ERR_DBG,
-							"%s: Samadhana!!\n",
-							 __func__);
-						BUG();
+				case 3: /* Begin anew */
+					lro->parent = skb;
+					goto aggregate;
+				case 1: /* Aggregate */
+					lro_append_pkt(sp, lro, skb, tcp_len);
+					goto aggregate;
+				case 4: /* Flush session */
+					lro_append_pkt(sp, lro, skb, tcp_len);
+					queue_rx_frame(lro->parent,
+						       lro->vlan_tag);
+					clear_lro_session(lro);
+					sp->mac_control.stats_info->
+						sw_stat.flush_max_pkts++;
+					goto aggregate;
+				case 2: /* Flush both */
+					lro->parent->data_len = lro->frags_len;
+					sp->mac_control.stats_info->
+						sw_stat.sending_both++;
+					queue_rx_frame(lro->parent,
+						       lro->vlan_tag);
+					clear_lro_session(lro);
+					goto send_up;
+				case 0: /* sessions exceeded */
+				case -1: /* non-TCP or not L2 aggregatable */
+				case 5: /*
+					 * First pkt in session not
+					 * L3/L4 aggregatable
+					 */
+					break;
+				default:
+					DBG_PRINT(ERR_DBG,
+						  "%s: Samadhana!!\n",
+						  __func__);
+					BUG();
 				}
 			}
 		} else {
@@ -7592,9 +7602,9 @@ aggregate:
  *  void.
  */
 
-static void s2io_link(struct s2io_nic * sp, int link)
+static void s2io_link(struct s2io_nic *sp, int link)
 {
-	struct net_device *dev = (struct net_device *) sp->dev;
+	struct net_device *dev = (struct net_device *)sp->dev;
 
 	if (link != sp->last_link_state) {
 		init_tti(sp, link);
@@ -7602,15 +7612,16 @@ static void s2io_link(struct s2io_nic * sp, int link)
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);
 			s2io_stop_all_tx_queue(sp);
 			netif_carrier_off(dev);
-			if(sp->mac_control.stats_info->sw_stat.link_up_cnt)
-			sp->mac_control.stats_info->sw_stat.link_up_time =
-				jiffies - sp->start_time;
+			if (sp->mac_control.stats_info->sw_stat.link_up_cnt)
+				sp->mac_control.stats_info->sw_stat.
+					link_up_time = jiffies - sp->start_time;
 			sp->mac_control.stats_info->sw_stat.link_down_cnt++;
 		} else {
 			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);
 			if (sp->mac_control.stats_info->sw_stat.link_down_cnt)
-			sp->mac_control.stats_info->sw_stat.link_down_time =
-				jiffies - sp->start_time;
+				sp->mac_control.stats_info->
+					sw_stat.link_down_time =
+					jiffies - sp->start_time;
 			sp->mac_control.stats_info->sw_stat.link_up_cnt++;
 			netif_carrier_on(dev);
 			s2io_wake_all_tx_queue(sp);
@@ -7631,7 +7642,7 @@ static void s2io_link(struct s2io_nic * sp, int link)
  *  void
  */
 
-static void s2io_init_pci(struct s2io_nic * sp)
+static void s2io_init_pci(struct s2io_nic *sp)
 {
 	u16 pci_cmd = 0, pcix_cmd = 0;
 
@@ -7651,12 +7662,11 @@ static void s2io_init_pci(struct s2io_nic * sp)
 }
 
 static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
-	u8 *dev_multiq)
+			    u8 *dev_multiq)
 {
-	if ((tx_fifo_num > MAX_TX_FIFOS) ||
-		(tx_fifo_num < 1)) {
+	if ((tx_fifo_num > MAX_TX_FIFOS) || (tx_fifo_num < 1)) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested number of tx fifos "
-			"(%d) not supported\n", tx_fifo_num);
+			  "(%d) not supported\n", tx_fifo_num);
 
 		if (tx_fifo_num < 1)
 			tx_fifo_num = 1;
@@ -7673,24 +7683,24 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 	if (tx_steering_type && (1 == tx_fifo_num)) {
 		if (tx_steering_type != TX_DEFAULT_STEERING)
 			DBG_PRINT(ERR_DBG,
-				"s2io: Tx steering is not supported with "
-				"one fifo. Disabling Tx steering.\n");
+				  "s2io: Tx steering is not supported with "
+				  "one fifo. Disabling Tx steering.\n");
 		tx_steering_type = NO_STEERING;
 	}
 
 	if ((tx_steering_type < NO_STEERING) ||
-		(tx_steering_type > TX_DEFAULT_STEERING)) {
-		DBG_PRINT(ERR_DBG, "s2io: Requested transmit steering not "
-			 "supported\n");
+	    (tx_steering_type > TX_DEFAULT_STEERING)) {
+		DBG_PRINT(ERR_DBG,
+			  "s2io: Requested transmit steering not supported\n");
 		DBG_PRINT(ERR_DBG, "s2io: Disabling transmit steering\n");
 		tx_steering_type = NO_STEERING;
 	}
 
 	if (rx_ring_num > MAX_RX_RINGS) {
-		DBG_PRINT(ERR_DBG, "s2io: Requested number of rx rings not "
-			 "supported\n");
+		DBG_PRINT(ERR_DBG,
+			  "s2io: Requested number of rx rings not supported\n");
 		DBG_PRINT(ERR_DBG, "s2io: Default to %d rx rings\n",
-			MAX_RX_RINGS);
+			  MAX_RX_RINGS);
 		rx_ring_num = MAX_RX_RINGS;
 	}
 
@@ -7701,10 +7711,10 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 	}
 
 	if ((*dev_intr_type == MSI_X) &&
-			((pdev->device != PCI_DEVICE_ID_HERC_WIN) &&
-			(pdev->device != PCI_DEVICE_ID_HERC_UNI))) {
+	    ((pdev->device != PCI_DEVICE_ID_HERC_WIN) &&
+	     (pdev->device != PCI_DEVICE_ID_HERC_UNI))) {
 		DBG_PRINT(ERR_DBG, "s2io: Xframe I does not support MSI_X. "
-					"Defaulting to INTA\n");
+			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
 	}
 
@@ -7743,8 +7753,8 @@ static int rts_ds_steer(struct s2io_nic *nic, u8 ds_codepoint, u8 ring)
 	writeq(val64, &bar0->rts_ds_mem_ctrl);
 
 	return wait_for_cmd_complete(&bar0->rts_ds_mem_ctrl,
-				RTS_DS_MEM_CTRL_STROBE_CMD_BEING_EXECUTED,
-				S2IO_BIT_RESET);
+				     RTS_DS_MEM_CTRL_STROBE_CMD_BEING_EXECUTED,
+				     S2IO_BIT_RESET);
 }
 
 static const struct net_device_ops s2io_netdev_ops = {
@@ -7800,7 +7810,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	if (ret)
 		return ret;
 
-	if ((ret = pci_enable_device(pdev))) {
+	ret = pci_enable_device(pdev);
+	if (ret) {
 		DBG_PRINT(ERR_DBG,
 			  "s2io_init_nic: pci_enable_device failed\n");
 		return ret;
@@ -7809,11 +7820,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");
 		dma_flag = true;
-		if (pci_set_consistent_dma_mask
-		    (pdev, DMA_BIT_MASK(64))) {
+		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 			DBG_PRINT(ERR_DBG,
-				  "Unable to obtain 64bit DMA for \
-					consistent allocations\n");
+				  "Unable to obtain 64bit DMA "
+				  "for consistent allocations\n");
 			pci_disable_device(pdev);
 			return -ENOMEM;
 		}
@@ -7823,8 +7833,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		pci_disable_device(pdev);
 		return -ENOMEM;
 	}
-	if ((ret = pci_request_regions(pdev, s2io_driver_name))) {
-		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __func__, ret);
+	ret = pci_request_regions(pdev, s2io_driver_name);
+	if (ret) {
+		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n",
+			  __func__, ret);
 		pci_disable_device(pdev);
 		return -ENODEV;
 	}
@@ -7858,7 +7870,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	sp->config.intr_type = dev_intr_type;
 
 	if ((pdev->device == PCI_DEVICE_ID_HERC_WIN) ||
-		(pdev->device == PCI_DEVICE_ID_HERC_UNI))
+	    (pdev->device == PCI_DEVICE_ID_HERC_UNI))
 		sp->device_type = XFRAME_II_DEVICE;
 	else
 		sp->device_type = XFRAME_I_DEVICE;
@@ -7889,16 +7901,16 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	/* Initialize the fifos used for tx steering */
 	if (config->tx_fifo_num < 5) {
-			if (config->tx_fifo_num  == 1)
-				sp->total_tcp_fifos = 1;
-			else
-				sp->total_tcp_fifos = config->tx_fifo_num - 1;
-			sp->udp_fifo_idx = config->tx_fifo_num - 1;
-			sp->total_udp_fifos = 1;
-			sp->other_fifo_idx = sp->total_tcp_fifos - 1;
+		if (config->tx_fifo_num  == 1)
+			sp->total_tcp_fifos = 1;
+		else
+			sp->total_tcp_fifos = config->tx_fifo_num - 1;
+		sp->udp_fifo_idx = config->tx_fifo_num - 1;
+		sp->total_udp_fifos = 1;
+		sp->other_fifo_idx = sp->total_tcp_fifos - 1;
 	} else {
 		sp->total_tcp_fifos = (tx_fifo_num - FIFO_UDP_MAX_NUM -
-						FIFO_OTHER_MAX_NUM);
+				       FIFO_OTHER_MAX_NUM);
 		sp->udp_fifo_idx = sp->total_tcp_fifos;
 		sp->total_udp_fifos = FIFO_UDP_MAX_NUM;
 		sp->other_fifo_idx = sp->udp_fifo_idx + FIFO_UDP_MAX_NUM;
@@ -7964,8 +7976,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	/*  initialize the shared memory used by the NIC and the host */
 	if (init_shared_mem(sp)) {
-		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",
-			  dev->name);
+		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n", dev->name);
 		ret = -ENOMEM;
 		goto mem_alloc_failed;
 	}
@@ -7987,12 +7998,13 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	}
 
 	dev->irq = pdev->irq;
-	dev->base_addr = (unsigned long) sp->bar0;
+	dev->base_addr = (unsigned long)sp->bar0;
 
 	/* Initializing the BAR1 address as the start of the FIFO pointer. */
 	for (j = 0; j < MAX_TX_FIFOS; j++) {
-		mac_control->tx_FIFO_start[j] = (struct TxFIFO_element __iomem *)
-		    (sp->bar1 + (j * 0x00020000));
+		mac_control->tx_FIFO_start[j] =
+			(struct TxFIFO_element __iomem *)
+			(sp->bar1 + (j * 0x00020000));
 	}
 
 	/*  Driver entry points */
@@ -8046,7 +8058,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		if (ret) {
 
 			DBG_PRINT(ERR_DBG,
-			  "s2io: MSI-X requested but failed to enable\n");
+				  "s2io: MSI-X requested but failed to enable\n");
 			sp->config.intr_type = INTA;
 		}
 	}
@@ -8077,12 +8089,13 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	 */
 	bar0 = sp->bar0;
 	val64 = RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
-	    RMAC_ADDR_CMD_MEM_OFFSET(0 + S2IO_MAC_ADDR_START_OFFSET);
+		RMAC_ADDR_CMD_MEM_OFFSET(0 + S2IO_MAC_ADDR_START_OFFSET);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
 	wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
-		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING, S2IO_BIT_RESET);
+			      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING,
+			      S2IO_BIT_RESET);
 	tmp64 = readq(&bar0->rmac_addr_data0_mem);
-	mac_down = (u32) tmp64;
+	mac_down = (u32)tmp64;
 	mac_up = (u32) (tmp64 >> 32);
 
 	sp->def_mac_addr[0].mac_addr[3] = (u8) (mac_up);
@@ -8113,10 +8126,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	/* Configure MSIX vector for number of rings configured plus one */
 	if ((sp->device_type == XFRAME_II_DEVICE) &&
-		(config->intr_type == MSI_X))
+	    (config->intr_type == MSI_X))
 		sp->num_entries = config->rx_ring_num + 1;
 
-	 /* Store the values of the MSIX table in the s2io_nic structure */
+	/* Store the values of the MSIX table in the s2io_nic structure */
 	store_xmsi_data(sp);
 	/* reset Nic and bring it to known state */
 	s2io_reset(sp);
@@ -8144,7 +8157,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		val64 |= 0x0000800000000000ULL;
 		writeq(val64, &bar0->gpio_control);
 		val64 = 0x0411040400000000ULL;
-		writeq(val64, (void __iomem *) bar0 + 0x2700);
+		writeq(val64, (void __iomem *)bar0 + 0x2700);
 		val64 = readq(&bar0->gpio_control);
 	}
 
@@ -8157,7 +8170,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	}
 	s2io_vpd_read(sp);
 	DBG_PRINT(ERR_DBG, "Copyright(c) 2002-2007 Neterion Inc.\n");
-	DBG_PRINT(ERR_DBG, "%s: Neterion %s (rev %d)\n",dev->name,
+	DBG_PRINT(ERR_DBG, "%s: Neterion %s (rev %d)\n", dev->name,
 		  sp->product_name, pdev->revision);
 	DBG_PRINT(ERR_DBG, "%s: Driver version %s\n", dev->name,
 		  s2io_driver_version);
@@ -8172,15 +8185,15 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 			goto set_swap_failed;
 		}
 	}
-	switch(sp->rxd_mode) {
-		case RXD_MODE_1:
-		    DBG_PRINT(ERR_DBG, "%s: 1-Buffer receive mode enabled\n",
-						dev->name);
-		    break;
-		case RXD_MODE_3B:
-		    DBG_PRINT(ERR_DBG, "%s: 2-Buffer receive mode enabled\n",
-						dev->name);
-		    break;
+	switch (sp->rxd_mode) {
+	case RXD_MODE_1:
+		DBG_PRINT(ERR_DBG, "%s: 1-Buffer receive mode enabled\n",
+			  dev->name);
+		break;
+	case RXD_MODE_3B:
+		DBG_PRINT(ERR_DBG, "%s: 2-Buffer receive mode enabled\n",
+			  dev->name);
+		break;
 	}
 
 	switch (sp->config.napi) {
@@ -8193,18 +8206,18 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	}
 
 	DBG_PRINT(ERR_DBG, "%s: Using %d Tx fifo(s)\n", dev->name,
-		sp->config.tx_fifo_num);
+		  sp->config.tx_fifo_num);
 
 	DBG_PRINT(ERR_DBG, "%s: Using %d Rx ring(s)\n", dev->name,
 		  sp->config.rx_ring_num);
 
-	switch(sp->config.intr_type) {
-		case INTA:
-		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
-		    break;
-		case MSI_X:
-		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI-X\n", dev->name);
-		    break;
+	switch (sp->config.intr_type) {
+	case INTA:
+		DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
+		break;
+	case MSI_X:
+		DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI-X\n", dev->name);
+		break;
 	}
 	if (sp->config.multiq) {
 		for (i = 0; i < sp->config.tx_fifo_num; i++) {
@@ -8213,31 +8226,34 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 			fifo->multiq = config->multiq;
 		}
 		DBG_PRINT(ERR_DBG, "%s: Multiqueue support enabled\n",
-			dev->name);
+			  dev->name);
 	} else
 		DBG_PRINT(ERR_DBG, "%s: Multiqueue support disabled\n",
-			dev->name);
+			  dev->name);
 
 	switch (sp->config.tx_steering_type) {
 	case NO_STEERING:
-		DBG_PRINT(ERR_DBG, "%s: No steering enabled for"
-			" transmit\n", dev->name);
-			break;
+		DBG_PRINT(ERR_DBG, "%s: No steering enabled for transmit\n",
+			  dev->name);
+		break;
 	case TX_PRIORITY_STEERING:
-		DBG_PRINT(ERR_DBG, "%s: Priority steering enabled for"
-			" transmit\n", dev->name);
+		DBG_PRINT(ERR_DBG,
+			  "%s: Priority steering enabled for transmit\n",
+			  dev->name);
 		break;
 	case TX_DEFAULT_STEERING:
-		DBG_PRINT(ERR_DBG, "%s: Default steering enabled for"
-			" transmit\n", dev->name);
+		DBG_PRINT(ERR_DBG,
+			  "%s: Default steering enabled for transmit\n",
+			  dev->name);
 	}
 
 	if (sp->lro)
 		DBG_PRINT(ERR_DBG, "%s: Large receive offload enabled\n",
 			  dev->name);
 	if (ufo)
-		DBG_PRINT(ERR_DBG, "%s: UDP Fragmentation Offload(UFO)"
-					" enabled\n", dev->name);
+		DBG_PRINT(ERR_DBG,
+			  "%s: UDP Fragmentation Offload(UFO) enabled\n",
+			  dev->name);
 	/* Initialize device name */
 	sprintf(sp->name, "%s Neterion %s", dev->name, sp->product_name);
 
@@ -8255,13 +8271,13 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	return 0;
 
-      register_failed:
-      set_swap_failed:
+register_failed:
+set_swap_failed:
 	iounmap(sp->bar1);
-      bar1_remap_failed:
+bar1_remap_failed:
 	iounmap(sp->bar0);
-      bar0_remap_failed:
-      mem_alloc_failed:
+bar0_remap_failed:
+mem_alloc_failed:
 	free_shared_mem(sp);
 	pci_disable_device(pdev);
 	pci_release_regions(pdev);
@@ -8283,7 +8299,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 static void __devexit s2io_rem_nic(struct pci_dev *pdev)
 {
 	struct net_device *dev =
-	    (struct net_device *) pci_get_drvdata(pdev);
+		(struct net_device *)pci_get_drvdata(pdev);
 	struct s2io_nic *sp;
 
 	if (dev == NULL) {
@@ -8331,28 +8347,28 @@ module_init(s2io_starter);
 module_exit(s2io_closer);
 
 static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
-		struct tcphdr **tcp, struct RxD_t *rxdp,
-		struct s2io_nic *sp)
+				struct tcphdr **tcp, struct RxD_t *rxdp,
+				struct s2io_nic *sp)
 {
 	int ip_off;
 	u8 l2_type = (u8)((rxdp->Control_1 >> 37) & 0x7), ip_len;
 
 	if (!(rxdp->Control_1 & RXD_FRAME_PROTO_TCP)) {
-		DBG_PRINT(INIT_DBG,"%s: Non-TCP frames not supported for LRO\n",
+		DBG_PRINT(INIT_DBG,
+			  "%s: Non-TCP frames not supported for LRO\n",
 			  __func__);
 		return -1;
 	}
 
 	/* Checking for DIX type or DIX type with VLAN */
-	if ((l2_type == 0)
-		|| (l2_type == 4)) {
+	if ((l2_type == 0) || (l2_type == 4)) {
 		ip_off = HEADER_ETHERNET_II_802_3_SIZE;
 		/*
 		 * If vlan stripping is disabled and the frame is VLAN tagged,
 		 * shift the offset by the VLAN header size bytes.
 		 */
 		if ((!sp->vlan_strip_flag) &&
-			(rxdp->Control_1 & RXD_FRAME_VLAN_TAG))
+		    (rxdp->Control_1 & RXD_FRAME_VLAN_TAG))
 			ip_off += HEADER_VLAN_SIZE;
 	} else {
 		/* LLC, SNAP etc are considered non-mergeable */
@@ -8370,22 +8386,25 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 static int check_for_socket_match(struct lro *lro, struct iphdr *ip,
 				  struct tcphdr *tcp)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
-	if ((lro->iph->saddr != ip->saddr) || (lro->iph->daddr != ip->daddr) ||
-	   (lro->tcph->source != tcp->source) || (lro->tcph->dest != tcp->dest))
+	DBG_PRINT(INFO_DBG, "%s: Been here...\n", __func__);
+	if ((lro->iph->saddr != ip->saddr) ||
+	    (lro->iph->daddr != ip->daddr) ||
+	    (lro->tcph->source != tcp->source) ||
+	    (lro->tcph->dest != tcp->dest))
 		return -1;
 	return 0;
 }
 
 static inline int get_l4_pyld_length(struct iphdr *ip, struct tcphdr *tcp)
 {
-	return(ntohs(ip->tot_len) - (ip->ihl << 2) - (tcp->doff << 2));
+	return ntohs(ip->tot_len) - (ip->ihl << 2) - (tcp->doff << 2);
 }
 
 static void initiate_new_session(struct lro *lro, u8 *l2h,
-	struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len, u16 vlan_tag)
+				 struct iphdr *ip, struct tcphdr *tcp,
+				 u32 tcp_pyld_len, u16 vlan_tag)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
+	DBG_PRINT(INFO_DBG, "%s: Been here...\n", __func__);
 	lro->l2h = l2h;
 	lro->iph = ip;
 	lro->tcph = tcp;
@@ -8396,9 +8415,9 @@ static void initiate_new_session(struct lro *lro, u8 *l2h,
 	lro->frags_len = 0;
 	lro->vlan_tag = vlan_tag;
 	/*
-	 * check if we saw TCP timestamp. Other consistency checks have
-	 * already been done.
- 	 */
+	 * Check if we saw TCP timestamp.
+	 * Other consistency checks have already been done.
+	 */
 	if (tcp->doff == 8) {
 		__be32 *ptr;
 		ptr = (__be32 *)(tcp+1);
@@ -8415,7 +8434,7 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 	struct tcphdr *tcp = lro->tcph;
 	__sum16 nchk;
 	struct stat_block *statinfo = sp->mac_control.stats_info;
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
+	DBG_PRINT(INFO_DBG, "%s: Been here...\n", __func__);
 
 	/* Update L3 header */
 	ip->tot_len = htons(lro->total_len);
@@ -8441,9 +8460,9 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 }
 
 static void aggregate_new_rx(struct lro *lro, struct iphdr *ip,
-		struct tcphdr *tcp, u32 l4_pyld)
+			     struct tcphdr *tcp, u32 l4_pyld)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
+	DBG_PRINT(INFO_DBG, "%s: Been here...\n", __func__);
 	lro->total_len += l4_pyld;
 	lro->frags_len += l4_pyld;
 	lro->tcp_next_seq += l4_pyld;
@@ -8467,7 +8486,7 @@ static int verify_l3_l4_lro_capable(struct lro *l_lro, struct iphdr *ip,
 {
 	u8 *ptr;
 
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
+	DBG_PRINT(INFO_DBG, "%s: Been here...\n", __func__);
 
 	if (!tcp_pyld_len) {
 		/* Runt frame or a pure ack */
@@ -8482,8 +8501,9 @@ static int verify_l3_l4_lro_capable(struct lro *l_lro, struct iphdr *ip,
 		return -1;
 
 	/* If we see ECE or CWR flags in TCP header, packet is not mergeable */
-	if (tcp->urg || tcp->psh || tcp->rst || tcp->syn || tcp->fin ||
-				    tcp->ece || tcp->cwr || !tcp->ack) {
+	if (tcp->urg || tcp->psh || tcp->rst ||
+	    tcp->syn || tcp->fin ||
+	    tcp->ece || tcp->cwr || !tcp->ack) {
 		/*
 		 * Currently recognize only the ack control word and
 		 * any other control field being set would result in
@@ -8519,27 +8539,26 @@ static int verify_l3_l4_lro_capable(struct lro *l_lro, struct iphdr *ip,
 	return 0;
 }
 
-static int
-s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer, u8 **tcp,
-	u32 *tcp_len, struct lro **lro, struct RxD_t *rxdp,
-	struct s2io_nic *sp)
+static int s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer,
+				 u8 **tcp, u32 *tcp_len, struct lro **lro,
+				 struct RxD_t *rxdp, struct s2io_nic *sp)
 {
 	struct iphdr *ip;
 	struct tcphdr *tcph;
 	int ret = 0, i;
 	u16 vlan_tag = 0;
 
-	if (!(ret = check_L2_lro_capable(buffer, &ip, (struct tcphdr **)tcp,
-					 rxdp, sp))) {
-		DBG_PRINT(INFO_DBG,"IP Saddr: %x Daddr: %x\n",
-			  ip->saddr, ip->daddr);
-	} else
+	ret = check_L2_lro_capable(buffer, &ip, (struct tcphdr **)tcp,
+				   rxdp, sp);
+	if (ret)
 		return ret;
 
+	DBG_PRINT(INFO_DBG, "IP Saddr: %x Daddr: %x\n", ip->saddr, ip->daddr);
+
 	vlan_tag = RXD_GET_VLAN_TAG(rxdp->Control_2);
 	tcph = (struct tcphdr *)*tcp;
 	*tcp_len = get_l4_pyld_length(ip, tcph);
-	for (i=0; i<MAX_LRO_SESSIONS; i++) {
+	for (i = 0; i < MAX_LRO_SESSIONS; i++) {
 		struct lro *l_lro = &ring_data->lro0_n[i];
 		if (l_lro->in_use) {
 			if (check_for_socket_match(l_lro, ip, tcph))
@@ -8554,12 +8573,13 @@ s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer, u8 **tcp,
 					  ntohl(tcph->seq));
 
 				sp->mac_control.stats_info->
-				   sw_stat.outof_sequence_pkts++;
+					sw_stat.outof_sequence_pkts++;
 				ret = 2;
 				break;
 			}
 
-			if (!verify_l3_l4_lro_capable(l_lro, ip, tcph,*tcp_len))
+			if (!verify_l3_l4_lro_capable(l_lro, ip, tcph,
+						      *tcp_len))
 				ret = 1; /* Aggregate */
 			else
 				ret = 2; /* Flush both */
@@ -8573,11 +8593,10 @@ s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer, u8 **tcp,
 		 * don't create new LRO session. Just send this
 		 * packet up.
 		 */
-		if (verify_l3_l4_lro_capable(NULL, ip, tcph, *tcp_len)) {
+		if (verify_l3_l4_lro_capable(NULL, ip, tcph, *tcp_len))
 			return 5;
-		}
 
-		for (i=0; i<MAX_LRO_SESSIONS; i++) {
+		for (i = 0; i < MAX_LRO_SESSIONS; i++) {
 			struct lro *l_lro = &ring_data->lro0_n[i];
 			if (!(l_lro->in_use)) {
 				*lro = l_lro;
@@ -8588,31 +8607,30 @@ s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer, u8 **tcp,
 	}
 
 	if (ret == 0) { /* sessions exceeded */
-		DBG_PRINT(INFO_DBG,"%s:All LRO sessions already in use\n",
+		DBG_PRINT(INFO_DBG, "%s:All LRO sessions already in use\n",
 			  __func__);
 		*lro = NULL;
 		return ret;
 	}
 
 	switch (ret) {
-		case 3:
-			initiate_new_session(*lro, buffer, ip, tcph, *tcp_len,
-								vlan_tag);
-			break;
-		case 2:
+	case 3:
+		initiate_new_session(*lro, buffer, ip, tcph, *tcp_len,
+				     vlan_tag);
+		break;
+	case 2:
+		update_L3L4_header(sp, *lro);
+		break;
+	case 1:
+		aggregate_new_rx(*lro, ip, tcph, *tcp_len);
+		if ((*lro)->sg_num == sp->lro_max_aggr_per_sess) {
 			update_L3L4_header(sp, *lro);
-			break;
-		case 1:
-			aggregate_new_rx(*lro, ip, tcph, *tcp_len);
-			if ((*lro)->sg_num == sp->lro_max_aggr_per_sess) {
-				update_L3L4_header(sp, *lro);
-				ret = 4; /* Flush the LRO */
-			}
-			break;
-		default:
-			DBG_PRINT(ERR_DBG,"%s:Dont know, can't say!!\n",
-				__func__);
-			break;
+			ret = 4; /* Flush the LRO */
+		}
+		break;
+	default:
+		DBG_PRINT(ERR_DBG, "%s:Dont know, can't say!!\n", __func__);
+		break;
 	}
 
 	return ret;
@@ -8631,8 +8649,7 @@ static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 	struct s2io_nic *sp = netdev_priv(dev);
 
 	skb->protocol = eth_type_trans(skb, dev);
-	if (sp->vlgrp && vlan_tag
-		&& (sp->vlan_strip_flag)) {
+	if (sp->vlgrp && vlan_tag && (sp->vlan_strip_flag)) {
 		/* Queueing the vlan frame to the upper layer */
 		if (sp->config.napi)
 			vlan_hwaccel_receive_skb(skb, sp->vlgrp, vlan_tag);
@@ -8647,8 +8664,7 @@ static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 }
 
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
-			   struct sk_buff *skb,
-			   u32 tcp_len)
+			   struct sk_buff *skb, u32 tcp_len)
 {
 	struct sk_buff *first = lro->parent;
 
@@ -8674,7 +8690,7 @@ static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
  * this device has been detected.
  */
 static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
-                                               pci_channel_state_t state)
+					       pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct s2io_nic *sp = netdev_priv(netdev);
-- 
1.6.3.1.10.g659a0.dirty

