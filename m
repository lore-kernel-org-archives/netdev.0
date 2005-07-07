From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.12.1 1/12] S2io: Code cleanup
Date: Thu,  7 Jul 2005 15:05:06 -0700 (PDT)
Message-ID: <20050707220506.A8AC689826@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
We are submitting a series of 12 patches to support our Xframe I and
Xframe II line of products. The patches can be categorized as follows:

Patches 1-8 : Changes applicable to both Xframe I and II
Patches 9-11: Xframe II specific features
Patch 12: Addresses issues found during testing cycle.

Please review the patches and let us know your comments.

Starting with patch 1 below.
This patch involves cosmetic changes(tabs and indentation, 
regrouping of transmit and receive data structures, typecasting,
code cleanup).

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendr Koushik <raghavendra.koushik@neterion.com>
---
diff -urpN vanilla_kernel/drivers/net/s2io-regs.h linux-2.6.12-rc6/drivers/net/s2io-regs.h
--- vanilla_kernel/drivers/net/s2io-regs.h	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io-regs.h	2005-06-27 06:21:32.000000000 -0700
@@ -77,19 +77,18 @@ typedef struct _XENA_dev_config {
 #define ADAPTER_ECC_EN                     BIT(55)
 
 	u64 serr_source;
-#define SERR_SOURCE_PIC					BIT(0)
-#define SERR_SOURCE_TXDMA				BIT(1)
-#define SERR_SOURCE_RXDMA				BIT(2)
+#define SERR_SOURCE_PIC			BIT(0)
+#define SERR_SOURCE_TXDMA		BIT(1)
+#define SERR_SOURCE_RXDMA		BIT(2)
 #define SERR_SOURCE_MAC                 BIT(3)
 #define SERR_SOURCE_MC                  BIT(4)
 #define SERR_SOURCE_XGXS                BIT(5)
-#define	SERR_SOURCE_ANY					(SERR_SOURCE_PIC		| \
-										SERR_SOURCE_TXDMA	| \
-										SERR_SOURCE_RXDMA	| \
-										SERR_SOURCE_MAC		| \
-										SERR_SOURCE_MC      | \
-										SERR_SOURCE_XGXS)
-
+#define	SERR_SOURCE_ANY			(SERR_SOURCE_PIC	| \
+					SERR_SOURCE_TXDMA	| \
+					SERR_SOURCE_RXDMA	| \
+					SERR_SOURCE_MAC		| \
+					SERR_SOURCE_MC		| \
+					SERR_SOURCE_XGXS)
 
 	u8 unused_0[0x800 - 0x120];
 
diff -urpN vanilla_kernel/drivers/net/s2io.c linux-2.6.12-rc6/drivers/net/s2io.c
--- vanilla_kernel/drivers/net/s2io.c	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io.c	2005-06-27 06:21:32.000000000 -0700
@@ -11,29 +11,28 @@
  * See the file COPYING in this distribution for more information.
  *
  * Credits:
- * Jeff Garzik		: For pointing out the improper error condition 
- *			  check in the s2io_xmit routine and also some 
- * 			  issues in the Tx watch dog function. Also for
- *			  patiently answering all those innumerable 
+ * Jeff Garzik		: For pointing out the improper error condition
+ *			  check in the s2io_xmit routine and also some
+ *			  issues in the Tx watch dog function. Also for
+ *			  patiently answering all those innumerable
  *			  questions regaring the 2.6 porting issues.
  * Stephen Hemminger	: Providing proper 2.6 porting mechanism for some
  *			  macros available only in 2.6 Kernel.
- * Francois Romieu	: For pointing out all code part that were 
+ * Francois Romieu	: For pointing out all code part that were
  *			  deprecated and also styling related comments.
- * Grant Grundler	: For helping me get rid of some Architecture 
+ * Grant Grundler	: For helping me get rid of some Architecture
  *			  dependent code.
  * Christopher Hellwig	: Some more 2.6 specific issues in the driver.
- *			  	
+ *
  * The module loadable parameters that are supported by the driver and a brief
  * explaination of all the variables.
- * rx_ring_num : This can be used to program the number of receive rings used 
- * in the driver.  					
- * rx_ring_len: This defines the number of descriptors each ring can have. This 
+ * rx_ring_num : This can be used to program the number of receive rings used
+ * in the driver.
+ * rx_ring_len: This defines the number of descriptors each ring can have. This
  * is also an array of size 8.
  * tx_fifo_num: This defines the number of Tx FIFOs thats used int the driver.
- * tx_fifo_len: This too is an array of 8. Each element defines the number of 
+ * tx_fifo_len: This too is an array of 8. Each element defines the number of
  * Tx descriptors that can be associated with each corresponding FIFO.
- * in PCI Configuration space.
  ************************************************************************/
 
 #include <linux/config.h>
@@ -56,19 +55,19 @@
 #include <linux/version.h>
 #include <linux/workqueue.h>
 
-#include <asm/io.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
+#include <asm/io.h>
 
 /* local include */
 #include "s2io.h"
 #include "s2io-regs.h"
 
 /* S2io Driver name & version. */
-static char s2io_driver_name[] = "s2io";
-static char s2io_driver_version[] = "Version 1.7.7.1";
+static char s2io_driver_name[] = "Neterion";
+static char s2io_driver_version[] = "Version 1.7.7";
 
-/* 
+/*
  * Cards with following subsystem_id have a link state indication
  * problem, 600B, 600C, 600D, 640B, 640C and 640D.
  * macro below identifies these cards given the subsystem_id.
@@ -85,9 +84,13 @@ static char s2io_driver_version[] = "Ver
 static inline int rx_buffer_level(nic_t * sp, int rxb_size, int ring)
 {
 	int level = 0;
-	if ((sp->pkt_cnt[ring] - rxb_size) > 16) {
+	mac_info_t *mac_control;
+
+	mac_control = &sp->mac_control;
+	if ((mac_control->rings[ring].pkt_cnt - rxb_size) > 16) {
 		level = LOW;
-		if ((sp->pkt_cnt[ring] - rxb_size) < MAX_RXDS_PER_BLOCK) {
+		if ((mac_control->rings[ring].pkt_cnt - rxb_size) <
+				MAX_RXDS_PER_BLOCK) {
 			level = PANIC;
 		}
 	}
@@ -152,8 +155,7 @@ static char ethtool_stats_keys[][ETH_GST
 #define S2IO_TEST_LEN	sizeof(s2io_gstrings) / ETH_GSTRING_LEN
 #define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN
 
-
-/* 
+/*
  * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
  */
@@ -195,8 +197,7 @@ static u64 default_dtx_cfg[] = {
 	END_SIGN
 };
 
-
-/* 
+/*
  * Constants for Fixing the MacAddress problem seen mostly on
  * Alpha machines.
  */
@@ -226,6 +227,8 @@ static unsigned int rx_ring_num = 1;
 static unsigned int rx_ring_sz[MAX_RX_RINGS] =
     {[0 ...(MAX_RX_RINGS - 1)] = 0 };
 static unsigned int Stats_refresh_time = 4;
+static unsigned int rts_frm_len[MAX_RX_RINGS] =
+    {[0 ...(MAX_RX_RINGS - 1)] = 0 };
 static unsigned int rmac_pause_time = 65535;
 static unsigned int mc_pause_threshold_q0q3 = 187;
 static unsigned int mc_pause_threshold_q4q7 = 187;
@@ -236,9 +239,9 @@ static unsigned int rmac_util_period = 5
 static unsigned int indicate_max_pkts;
 #endif
 
-/* 
+/*
  * S2IO device table.
- * This table lists all the devices that this driver supports. 
+ * This table lists all the devices that this driver supports.
  */
 static struct pci_device_id s2io_tbl[] __devinitdata = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_WIN,
@@ -246,9 +249,9 @@ static struct pci_device_id s2io_tbl[] _
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_UNI,
 	 PCI_ANY_ID, PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_WIN,
-	 PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_UNI,
-	 PCI_ANY_ID, PCI_ANY_ID},
+         PCI_ANY_ID, PCI_ANY_ID},
+        {PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_UNI,
+         PCI_ANY_ID, PCI_ANY_ID},
 	{0,}
 };
 
@@ -267,8 +270,8 @@ static struct pci_driver s2io_driver = {
 /**
  * init_shared_mem - Allocation and Initialization of Memory
  * @nic: Device private variable.
- * Description: The function allocates all the memory areas shared 
- * between the NIC and the driver. This includes Tx descriptors, 
+ * Description: The function allocates all the memory areas shared
+ * between the NIC and the driver. This includes Tx descriptors,
  * Rx descriptors and the statistics block.
  */
 
@@ -278,11 +281,11 @@ static int init_shared_mem(struct s2io_n
 	void *tmp_v_addr, *tmp_v_addr_next;
 	dma_addr_t tmp_p_addr, tmp_p_addr_next;
 	RxD_block_t *pre_rxd_blk = NULL;
-	int i, j, blk_cnt;
+	int i, j, blk_cnt, rx_sz, tx_sz;
 	int lst_size, lst_per_page;
 	struct net_device *dev = nic->dev;
 #ifdef CONFIG_2BUFF_MODE
-	unsigned long tmp;
+	u64 tmp;
 	buffAdd_t *ba;
 #endif
 
@@ -307,28 +310,34 @@ static int init_shared_mem(struct s2io_n
 	}
 
 	lst_size = (sizeof(TxD_t) * config->max_txds);
+	tx_sz = lst_size * size;
 	lst_per_page = PAGE_SIZE / lst_size;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int fifo_len = config->tx_cfg[i].fifo_len;
 		int list_holder_size = fifo_len * sizeof(list_info_hold_t);
-		nic->list_info[i] = kmalloc(list_holder_size, GFP_KERNEL);
-		if (!nic->list_info[i]) {
+		mac_control->fifos[i].list_info = kmalloc(list_holder_size,
+							  GFP_KERNEL);
+		if (!mac_control->fifos[i].list_info) {
 			DBG_PRINT(ERR_DBG,
 				  "Malloc failed for list_info\n");
 			return -ENOMEM;
 		}
-		memset(nic->list_info[i], 0, list_holder_size);
+		memset(mac_control->fifos[i].list_info, 0, list_holder_size);
 	}
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
 						lst_per_page);
-		mac_control->tx_curr_put_info[i].offset = 0;
-		mac_control->tx_curr_put_info[i].fifo_len =
+		mac_control->fifos[i].tx_curr_put_info.offset = 0;
+		mac_control->fifos[i].tx_curr_put_info.fifo_len =
 		    config->tx_cfg[i].fifo_len - 1;
-		mac_control->tx_curr_get_info[i].offset = 0;
-		mac_control->tx_curr_get_info[i].fifo_len =
+		mac_control->fifos[i].tx_curr_get_info.offset = 0;
+		mac_control->fifos[i].tx_curr_get_info.fifo_len =
 		    config->tx_cfg[i].fifo_len - 1;
+		mac_control->fifos[i].fifo_no = i;
+		mac_control->fifos[i].nic = nic;
+		mac_control->fifos[i].max_txds = MAX_SKB_FRAGS;
+
 		for (j = 0; j < page_num; j++) {
 			int k = 0;
 			dma_addr_t tmp_p;
@@ -344,16 +353,15 @@ static int init_shared_mem(struct s2io_n
 			while (k < lst_per_page) {
 				int l = (j * lst_per_page) + k;
 				if (l == config->tx_cfg[i].fifo_len)
-					goto end_txd_alloc;
-				nic->list_info[i][l].list_virt_addr =
+					break;
+				mac_control->fifos[i].list_info[l].list_virt_addr =
 				    tmp_v + (k * lst_size);
-				nic->list_info[i][l].list_phy_addr =
+				mac_control->fifos[i].list_info[l].list_phy_addr =
 				    tmp_p + (k * lst_size);
 				k++;
 			}
 		}
 	}
-      end_txd_alloc:
 
 	/* Allocation and initialization of RXDs in Rings */
 	size = 0;
@@ -366,21 +374,26 @@ static int init_shared_mem(struct s2io_n
 			return FAILURE;
 		}
 		size += config->rx_cfg[i].num_rxd;
-		nic->block_count[i] =
+		mac_control->rings[i].block_count =
 		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
-		nic->pkt_cnt[i] =
-		    config->rx_cfg[i].num_rxd - nic->block_count[i];
+		mac_control->rings[i].pkt_cnt =
+		    config->rx_cfg[i].num_rxd - mac_control->rings[i].block_count;
 	}
+	size = (size * (sizeof(RxD_t)));
+	rx_sz = size;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		mac_control->rx_curr_get_info[i].block_index = 0;
-		mac_control->rx_curr_get_info[i].offset = 0;
-		mac_control->rx_curr_get_info[i].ring_len =
+		mac_control->rings[i].rx_curr_get_info.block_index = 0;
+		mac_control->rings[i].rx_curr_get_info.offset = 0;
+		mac_control->rings[i].rx_curr_get_info.ring_len =
 		    config->rx_cfg[i].num_rxd - 1;
-		mac_control->rx_curr_put_info[i].block_index = 0;
-		mac_control->rx_curr_put_info[i].offset = 0;
-		mac_control->rx_curr_put_info[i].ring_len =
+		mac_control->rings[i].rx_curr_put_info.block_index = 0;
+		mac_control->rings[i].rx_curr_put_info.offset = 0;
+		mac_control->rings[i].rx_curr_put_info.ring_len =
 		    config->rx_cfg[i].num_rxd - 1;
+		mac_control->rings[i].nic = nic;
+		mac_control->rings[i].ring_no = i;
+
 		blk_cnt =
 		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
 		/*  Allocating all the Rx blocks */
@@ -394,32 +407,36 @@ static int init_shared_mem(struct s2io_n
 							  &tmp_p_addr);
 			if (tmp_v_addr == NULL) {
 				/*
-				 * In case of failure, free_shared_mem() 
-				 * is called, which should free any 
-				 * memory that was alloced till the 
+				 * In case of failure, free_shared_mem()
+				 * is called, which should free any
+				 * memory that was alloced till the
 				 * failure happened.
 				 */
-				nic->rx_blocks[i][j].block_virt_addr =
+				mac_control->rings[i].rx_blocks[j].block_virt_addr =
 				    tmp_v_addr;
 				return -ENOMEM;
 			}
 			memset(tmp_v_addr, 0, size);
-			nic->rx_blocks[i][j].block_virt_addr = tmp_v_addr;
-			nic->rx_blocks[i][j].block_dma_addr = tmp_p_addr;
+			mac_control->rings[i].rx_blocks[j].block_virt_addr =
+				tmp_v_addr;
+			mac_control->rings[i].rx_blocks[j].block_dma_addr =
+				tmp_p_addr;
 		}
 		/* Interlinking all Rx Blocks */
 		for (j = 0; j < blk_cnt; j++) {
-			tmp_v_addr = nic->rx_blocks[i][j].block_virt_addr;
+			tmp_v_addr =
+				mac_control->rings[i].rx_blocks[j].block_virt_addr;
 			tmp_v_addr_next =
-			    nic->rx_blocks[i][(j + 1) %
+				mac_control->rings[i].rx_blocks[(j + 1) %
 					      blk_cnt].block_virt_addr;
-			tmp_p_addr = nic->rx_blocks[i][j].block_dma_addr;
+			tmp_p_addr =
+				mac_control->rings[i].rx_blocks[j].block_dma_addr;
 			tmp_p_addr_next =
-			    nic->rx_blocks[i][(j + 1) %
+				mac_control->rings[i].rx_blocks[(j + 1) %
 					      blk_cnt].block_dma_addr;
 
 			pre_rxd_blk = (RxD_block_t *) tmp_v_addr;
-			pre_rxd_blk->reserved_1 = END_OF_BLOCK;	/* last RxD 
+			pre_rxd_blk->reserved_1 = END_OF_BLOCK;	/* last RxD
 								 * marker.
 								 */
 #ifndef	CONFIG_2BUFF_MODE
@@ -432,43 +449,43 @@ static int init_shared_mem(struct s2io_n
 	}
 
 #ifdef CONFIG_2BUFF_MODE
-	/* 
+	/*
 	 * Allocation of Storages for buffer addresses in 2BUFF mode
 	 * and the buffers as well.
 	 */
 	for (i = 0; i < config->rx_ring_num; i++) {
 		blk_cnt =
 		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
-		nic->ba[i] = kmalloc((sizeof(buffAdd_t *) * blk_cnt),
+		mac_control->rings[i].ba = kmalloc((sizeof(buffAdd_t *) * blk_cnt),
 				     GFP_KERNEL);
-		if (!nic->ba[i])
+		if (!mac_control->rings[i].ba)
 			return -ENOMEM;
 		for (j = 0; j < blk_cnt; j++) {
 			int k = 0;
-			nic->ba[i][j] = kmalloc((sizeof(buffAdd_t) *
+			mac_control->rings[i].ba[j] = kmalloc((sizeof(buffAdd_t) *
 						 (MAX_RXDS_PER_BLOCK + 1)),
 						GFP_KERNEL);
-			if (!nic->ba[i][j])
+			if (!mac_control->rings[i].ba[j])
 				return -ENOMEM;
 			while (k != MAX_RXDS_PER_BLOCK) {
-				ba = &nic->ba[i][j][k];
+				ba = &mac_control->rings[i].ba[j][k];
 
-				ba->ba_0_org = kmalloc
+				ba->ba_0_org = (void *) kmalloc
 				    (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
 				if (!ba->ba_0_org)
 					return -ENOMEM;
-				tmp = (unsigned long) ba->ba_0_org;
+				tmp = (u64) ba->ba_0_org;
 				tmp += ALIGN_SIZE;
-				tmp &= ~((unsigned long) ALIGN_SIZE);
+				tmp &= ~((u64) ALIGN_SIZE);
 				ba->ba_0 = (void *) tmp;
 
-				ba->ba_1_org = kmalloc
+				ba->ba_1_org = (void *) kmalloc
 				    (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
 				if (!ba->ba_1_org)
 					return -ENOMEM;
-				tmp = (unsigned long) ba->ba_1_org;
+				tmp = (u64) ba->ba_1_org;
 				tmp += ALIGN_SIZE;
-				tmp &= ~((unsigned long) ALIGN_SIZE);
+				tmp &= ~((u64) ALIGN_SIZE);
 				ba->ba_1 = (void *) tmp;
 				k++;
 			}
@@ -482,9 +499,9 @@ static int init_shared_mem(struct s2io_n
 	    (nic->pdev, size, &mac_control->stats_mem_phy);
 
 	if (!mac_control->stats_mem) {
-		/* 
-		 * In case of failure, free_shared_mem() is called, which 
-		 * should free any memory that was alloced till the 
+		/*
+		 * In case of failure, free_shared_mem() is called, which
+		 * should free any memory that was alloced till the
 		 * failure happened.
 		 */
 		return -ENOMEM;
@@ -494,15 +511,14 @@ static int init_shared_mem(struct s2io_n
 	tmp_v_addr = mac_control->stats_mem;
 	mac_control->stats_info = (StatInfo_t *) tmp_v_addr;
 	memset(tmp_v_addr, 0, size);
-
 	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,
 		  (unsigned long long) tmp_p_addr);
 
 	return SUCCESS;
 }
 
-/**  
- * free_shared_mem - Free the allocated Memory 
+/**
+ * free_shared_mem - Free the allocated Memory
  * @nic:  Device private variable.
  * Description: This function is to free all memory locations allocated by
  * the init_shared_mem() function and return it to the kernel.
@@ -532,15 +548,18 @@ static void free_shared_mem(struct s2io_
 						lst_per_page);
 		for (j = 0; j < page_num; j++) {
 			int mem_blks = (j * lst_per_page);
-			if (!nic->list_info[i][mem_blks].list_virt_addr)
+			if (!mac_control->fifos[i].list_info[mem_blks].
+			    list_virt_addr)
 				break;
 			pci_free_consistent(nic->pdev, PAGE_SIZE,
-					    nic->list_info[i][mem_blks].
+					    mac_control->fifos[i].
+					    list_info[mem_blks].
 					    list_virt_addr,
-					    nic->list_info[i][mem_blks].
+					    mac_control->fifos[i].
+					    list_info[mem_blks].
 					    list_phy_addr);
 		}
-		kfree(nic->list_info[i]);
+		kfree(mac_control->fifos[i].list_info);
 	}
 
 #ifndef CONFIG_2BUFF_MODE
@@ -549,10 +568,12 @@ static void free_shared_mem(struct s2io_
 	size = SIZE_OF_BLOCK;
 #endif
 	for (i = 0; i < config->rx_ring_num; i++) {
-		blk_cnt = nic->block_count[i];
+		blk_cnt = mac_control->rings[i].block_count;
 		for (j = 0; j < blk_cnt; j++) {
-			tmp_v_addr = nic->rx_blocks[i][j].block_virt_addr;
-			tmp_p_addr = nic->rx_blocks[i][j].block_dma_addr;
+			tmp_v_addr = mac_control->rings[i].rx_blocks[j].
+				block_virt_addr;
+			tmp_p_addr = mac_control->rings[i].rx_blocks[j].
+				block_dma_addr;
 			if (tmp_v_addr == NULL)
 				break;
 			pci_free_consistent(nic->pdev, size,
@@ -565,35 +586,21 @@ static void free_shared_mem(struct s2io_
 	for (i = 0; i < config->rx_ring_num; i++) {
 		blk_cnt =
 		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
-		if (!nic->ba[i])
-			goto end_free;
 		for (j = 0; j < blk_cnt; j++) {
 			int k = 0;
-			if (!nic->ba[i][j]) {
-				kfree(nic->ba[i]);
-				goto end_free;
-			}
+			if (!mac_control->rings[i].ba[j])
+				continue;
 			while (k != MAX_RXDS_PER_BLOCK) {
-				buffAdd_t *ba = &nic->ba[i][j][k];
-				if (!ba || !ba->ba_0_org || !ba->ba_1_org)
-				{
-					kfree(nic->ba[i]);
-					kfree(nic->ba[i][j]);
-					if(ba->ba_0_org)
-						kfree(ba->ba_0_org);
-					if(ba->ba_1_org)
-						kfree(ba->ba_1_org);
-					goto end_free;
-				}
+				buffAdd_t *ba = &mac_control->rings[i].ba[j][k];
 				kfree(ba->ba_0_org);
 				kfree(ba->ba_1_org);
 				k++;
 			}
-			kfree(nic->ba[i][j]);
+			kfree(mac_control->rings[i].ba[j]);
 		}
-		kfree(nic->ba[i]);
+		if (mac_control->rings[i].ba)
+			kfree(mac_control->rings[i].ba);
 	}
-end_free:
 #endif
 
 	if (mac_control->stats_mem) {
@@ -604,12 +611,12 @@ end_free:
 	}
 }
 
-/**  
- *  init_nic - Initialization of hardware 
+/**
+ *  init_nic - Initialization of hardware
  *  @nic: device peivate variable
- *  Description: The function sequentially configures every block 
- *  of the H/W from their reset values. 
- *  Return Value:  SUCCESS on success and 
+ *  Description: The function sequentially configures every block
+ *  of the H/W from their reset values.
+ *  Return Value:  SUCCESS on success and
  *  '-1' on failure (endian settings incorrect).
  */
 
@@ -625,12 +632,13 @@ static int init_nic(struct s2io_nic *nic
 	struct config_param *config;
 	int mdio_cnt = 0, dtx_cnt = 0;
 	unsigned long long mem_share;
+	int mem_size;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	/* Initialize swapper control register */
-	if (s2io_set_swapper(nic)) {
+	/* to set the swapper control on the card */
+	if(s2io_set_swapper(nic)) {
 		DBG_PRINT(ERR_DBG,"ERROR: Setting Swapper failed\n");
 		return -1;
 	}
@@ -638,8 +646,8 @@ static int init_nic(struct s2io_nic *nic
 	/* Remove XGXS from reset state */
 	val64 = 0;
 	writeq(val64, &bar0->sw_reset);
-	val64 = readq(&bar0->sw_reset);
 	msleep(500);
+	val64 = readq(&bar0->sw_reset);
 
 	/*  Enable Receiving broadcasts */
 	add = &bar0->mac_cfg;
@@ -659,18 +667,18 @@ static int init_nic(struct s2io_nic *nic
 	val64 = dev->mtu;
 	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
 
-	/* 
-	 * Configuring the XAUI Interface of Xena. 
+	/*
+	 * Configuring the XAUI Interface of Xena.
 	 * ***************************************
-	 * To Configure the Xena's XAUI, one has to write a series 
-	 * of 64 bit values into two registers in a particular 
-	 * sequence. Hence a macro 'SWITCH_SIGN' has been defined 
-	 * which will be defined in the array of configuration values 
-	 * (default_dtx_cfg & default_mdio_cfg) at appropriate places 
-	 * to switch writing from one regsiter to another. We continue 
+	 * To Configure the Xena's XAUI, one has to write a series
+	 * of 64 bit values into two registers in a particular
+	 * sequence. Hence a macro 'SWITCH_SIGN' has been defined
+	 * which will be defined in the array of configuration values
+	 * (default_dtx_cfg & default_mdio_cfg) at appropriate places
+	 * to switch writing from one regsiter to another. We continue
 	 * writing these values until we encounter the 'END_SIGN' macro.
-	 * For example, After making a series of 21 writes into 
-	 * dtx_control register the 'SWITCH_SIGN' appears and hence we 
+	 * For example, After making a series of 21 writes into
+	 * dtx_control register the 'SWITCH_SIGN' appears and hence we
 	 * start writing into mdio_control until we encounter END_SIGN.
 	 */
 	while (1) {
@@ -751,8 +759,8 @@ static int init_nic(struct s2io_nic *nic
 	DBG_PRINT(INIT_DBG, "Fifo partition at: 0x%p is: 0x%llx\n",
 		  &bar0->tx_fifo_partition_0, (unsigned long long) val64);
 
-	/* 
-	 * Initialization of Tx_PA_CONFIG register to ignore packet 
+	/*
+	 * Initialization of Tx_PA_CONFIG register to ignore packet
 	 * integrity checking.
 	 */
 	val64 = readq(&bar0->tx_pa_cfg);
@@ -769,54 +777,54 @@ static int init_nic(struct s2io_nic *nic
 	}
 	writeq(val64, &bar0->rx_queue_priority);
 
-	/* 
-	 * Allocating equal share of memory to all the 
+	/*
+	 * Allocating equal share of memory to all the
 	 * configured Rings.
 	 */
 	val64 = 0;
+	mem_size = 64;
 	for (i = 0; i < config->rx_ring_num; i++) {
 		switch (i) {
 		case 0:
-			mem_share = (64 / config->rx_ring_num +
-				     64 % config->rx_ring_num);
+			mem_share = (mem_size / config->rx_ring_num +
+				     mem_size % config->rx_ring_num);
 			val64 |= RX_QUEUE_CFG_Q0_SZ(mem_share);
 			continue;
 		case 1:
-			mem_share = (64 / config->rx_ring_num);
+			mem_share = (mem_size / config->rx_ring_num);
 			val64 |= RX_QUEUE_CFG_Q1_SZ(mem_share);
 			continue;
 		case 2:
-			mem_share = (64 / config->rx_ring_num);
+			mem_share = (mem_size / config->rx_ring_num);
 			val64 |= RX_QUEUE_CFG_Q2_SZ(mem_share);
 			continue;
 		case 3:
-			mem_share = (64 / config->rx_ring_num);
+			mem_share = (mem_size / config->rx_ring_num);
 			val64 |= RX_QUEUE_CFG_Q3_SZ(mem_share);
 			continue;
 		case 4:
-			mem_share = (64 / config->rx_ring_num);
+			mem_share = (mem_size / config->rx_ring_num);
 			val64 |= RX_QUEUE_CFG_Q4_SZ(mem_share);
 			continue;
 		case 5:
-			mem_share = (64 / config->rx_ring_num);
+			mem_share = (mem_size / config->rx_ring_num);
 			val64 |= RX_QUEUE_CFG_Q5_SZ(mem_share);
 			continue;
 		case 6:
-			mem_share = (64 / config->rx_ring_num);
+			mem_share = (mem_size / config->rx_ring_num);
 			val64 |= RX_QUEUE_CFG_Q6_SZ(mem_share);
 			continue;
 		case 7:
-			mem_share = (64 / config->rx_ring_num);
+			mem_share = (mem_size / config->rx_ring_num);
 			val64 |= RX_QUEUE_CFG_Q7_SZ(mem_share);
 			continue;
 		}
 	}
 	writeq(val64, &bar0->rx_queue_cfg);
 
-	/* 
-	 * Initializing the Tx round robin registers to 0.
-	 * Filling Tx and Rx round robin registers as per the 
-	 * number of FIFOs and Rings is still TODO.
+	/* Initializing the Tx round robin registers to 0
+	 * filling tx and rx round robin registers as per
+	 * the number of FIFOs and Rings is still TODO
 	 */
 	writeq(0, &bar0->tx_w_round_robin_0);
 	writeq(0, &bar0->tx_w_round_robin_1);
@@ -824,30 +832,30 @@ static int init_nic(struct s2io_nic *nic
 	writeq(0, &bar0->tx_w_round_robin_3);
 	writeq(0, &bar0->tx_w_round_robin_4);
 
-	/* 
+	/*
 	 * TODO
-	 * Disable Rx steering. Hard coding all packets be steered to
-	 * Queue 0 for now. 
+	 * Disable Rx steering. Hard coding all packets to be steered to
+	 * Queue 0 for now.
 	 */
 	val64 = 0x8080808080808080ULL;
 	writeq(val64, &bar0->rts_qos_steering);
 
 	/* UDP Fix */
 	val64 = 0;
-	for (i = 1; i < 8; i++)
+	for (i = 0; i < 8; i++)
 		writeq(val64, &bar0->rts_frm_len_n[i]);
 
-	/* Set rts_frm_len register for fifo 0 */
-	writeq(MAC_RTS_FRM_LEN_SET(dev->mtu + 22),
-	       &bar0->rts_frm_len_n[0]);
+	/* Set the default rts frame length for ring0 */
+	writeq(MAC_RTS_FRM_LEN_SET(dev->mtu+22),
+		&bar0->rts_frm_len_n[0]);
 
-	/* Enable statistics */
+	/* Program statistics memory */
 	writeq(mac_control->stats_mem_phy, &bar0->stat_addr);
 	val64 = SET_UPDT_PERIOD(Stats_refresh_time) |
 	    STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;
 	writeq(val64, &bar0->stat_cfg);
 
-	/* 
+	/*
 	 * Initializing the sampling rate for the device to calculate the
 	 * bandwidth utilization.
 	 */
@@ -856,11 +864,12 @@ static int init_nic(struct s2io_nic *nic
 	writeq(val64, &bar0->mac_link_util);
 
 
-	/* 
-	 * Initializing the Transmit and Receive Traffic Interrupt 
+	/*
+	 * Initializing the Transmit and Receive Traffic Interrupt
 	 * Scheme.
 	 */
-	/* TTI Initialization. Default Tx timer gets us about
+	/*
+	 * TTI Initialization. Default Tx timer gets us about
 	 * 250 interrupts per sec. Continuous interrupts are enabled
 	 * by default.
 	 */
@@ -879,7 +888,7 @@ static int init_nic(struct s2io_nic *nic
 	val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
 	writeq(val64, &bar0->tti_command_mem);
 
-	/* 
+	/*
 	 * Once the operation completes, the Strobe bit of the command
 	 * register will be reset. We poll for this particular condition
 	 * We wait for a maximum of 500ms for the operation to complete,
@@ -916,7 +925,7 @@ static int init_nic(struct s2io_nic *nic
 	val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD;
 	writeq(val64, &bar0->rti_command_mem);
 
-	/* 
+	/*
 	 * Once the operation completes, the Strobe bit of the command
 	 * register will be reset. We poll for this particular condition
 	 * We wait for a maximum of 500ms for the operation to complete,
@@ -925,7 +934,7 @@ static int init_nic(struct s2io_nic *nic
 	time = 0;
 	while (TRUE) {
 		val64 = readq(&bar0->rti_command_mem);
-		if (!(val64 & TTI_CMD_MEM_STROBE_NEW_CMD)) {
+		if (!(val64 & RTI_CMD_MEM_STROBE_NEW_CMD)) {
 			break;
 		}
 		if (time > 10) {
@@ -937,15 +946,15 @@ static int init_nic(struct s2io_nic *nic
 		msleep(50);
 	}
 
-	/* 
-	 * Initializing proper values as Pause threshold into all 
+	/*
+	 * Initializing proper values as Pause threshold into all
 	 * the 8 Queues on Rx side.
 	 */
 	writeq(0xffbbffbbffbbffbbULL, &bar0->mc_pause_thresh_q0q3);
 	writeq(0xffbbffbbffbbffbbULL, &bar0->mc_pause_thresh_q4q7);
 
 	/* Disable RMAC PAD STRIPPING */
-	add = &bar0->mac_cfg;
+	add = (void *) &bar0->mac_cfg;
 	val64 = readq(&bar0->mac_cfg);
 	val64 &= ~(MAC_CFG_RMAC_STRIP_PAD);
 	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
@@ -954,8 +963,8 @@ static int init_nic(struct s2io_nic *nic
 	writel((u32) (val64 >> 32), (add + 4));
 	val64 = readq(&bar0->mac_cfg);
 
-	/* 
-	 * Set the time value to be inserted in the pause frame 
+	/*
+	 * Set the time value to be inserted in the pause frame
 	 * generated by xena.
 	 */
 	val64 = readq(&bar0->rmac_pause_cfg);
@@ -963,7 +972,7 @@ static int init_nic(struct s2io_nic *nic
 	val64 |= RMAC_PAUSE_HG_PTIME(nic->mac_control.rmac_pause_time);
 	writeq(val64, &bar0->rmac_pause_cfg);
 
-	/* 
+	/*
 	 * Set the Threshold Limit for Generating the pause frame
 	 * If the amount of data in any Queue exceeds ratio of
 	 * (mac_control.mc_pause_threshold_q0q3 or q4q7)/256
@@ -987,8 +996,8 @@ static int init_nic(struct s2io_nic *nic
 	}
 	writeq(val64, &bar0->mc_pause_thresh_q4q7);
 
-	/* 
-	 * TxDMA will stop Read request if the number of read split has 
+	/*
+	 * TxDMA will stop Read request if the number of read split has
 	 * exceeded the limit pointed by shared_splits
 	 */
 	val64 = readq(&bar0->pic_control);
@@ -998,14 +1007,14 @@ static int init_nic(struct s2io_nic *nic
 	return SUCCESS;
 }
 
-/**  
- *  en_dis_able_nic_intrs - Enable or Disable the interrupts 
+/**
+ *  en_dis_able_nic_intrs - Enable or Disable the interrupts
  *  @nic: device private variable,
  *  @mask: A mask indicating which Intr block must be modified and,
  *  @flag: A flag indicating whether to enable or disable the Intrs.
  *  Description: This function will either disable or enable the interrupts
- *  depending on the flag argument. The mask argument can be used to 
- *  enable/disable any Intr block. 
+ *  depending on the flag argument. The mask argument can be used to
+ *  enable/disable any Intr block.
  *  Return Value: NONE.
  */
 
@@ -1023,20 +1032,20 @@ static void en_dis_able_nic_intrs(struct
 			temp64 = readq(&bar0->general_int_mask);
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/*  
+			/*
 			 * Disabled all PCIX, Flash, MDIO, IIC and GPIO
-			 * interrupts for now. 
-			 * TODO 
+			 * interrupts for now.
+			 * TODO
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
-			/* 
+			/*
 			 * No MSI Support is available presently, so TTI and
 			 * RTI interrupts are also disabled.
 			 */
 		} else if (flag == DISABLE_INTRS) {
-			/*  
-			 * Disable PIC Intrs in the general 
-			 * intr mask register 
+			/*
+			 * Disable PIC Intrs in the general
+			 * intr mask register
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
 			temp64 = readq(&bar0->general_int_mask);
@@ -1054,27 +1063,27 @@ static void en_dis_able_nic_intrs(struct
 			temp64 = readq(&bar0->general_int_mask);
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* 
-			 * Keep all interrupts other than PFC interrupt 
+			/*
+			 * Keep all interrupts other than PFC interrupt
 			 * and PCC interrupt disabled in DMA level.
 			 */
 			val64 = DISABLE_ALL_INTRS & ~(TXDMA_PFC_INT_M |
 						      TXDMA_PCC_INT_M);
 			writeq(val64, &bar0->txdma_int_mask);
-			/* 
-			 * Enable only the MISC error 1 interrupt in PFC block 
+			/*
+			 * Enable only the MISC error 1 interrupt in PFC block
 			 */
 			val64 = DISABLE_ALL_INTRS & (~PFC_MISC_ERR_1);
 			writeq(val64, &bar0->pfc_err_mask);
-			/* 
-			 * Enable only the FB_ECC error interrupt in PCC block 
+			/*
+			 * Enable only the FB_ECC error interrupt in PCC block
 			 */
 			val64 = DISABLE_ALL_INTRS & (~PCC_FB_ECC_ERR);
 			writeq(val64, &bar0->pcc_err_mask);
 		} else if (flag == DISABLE_INTRS) {
-			/* 
-			 * Disable TxDMA Intrs in the general intr mask 
-			 * register 
+			/*
+			 * Disable TxDMA Intrs in the general intr mask
+			 * register
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->txdma_int_mask);
 			writeq(DISABLE_ALL_INTRS, &bar0->pfc_err_mask);
@@ -1092,15 +1101,15 @@ static void en_dis_able_nic_intrs(struct
 			temp64 = readq(&bar0->general_int_mask);
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* 
-			 * All RxDMA block interrupts are disabled for now 
-			 * TODO 
+			/*
+			 * All RxDMA block interrupts are disabled for now
+			 * TODO
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);
 		} else if (flag == DISABLE_INTRS) {
-			/*  
-			 * Disable RxDMA Intrs in the general intr mask 
-			 * register 
+			/*
+			 * Disable RxDMA Intrs in the general intr mask
+			 * register
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);
 			temp64 = readq(&bar0->general_int_mask);
@@ -1117,8 +1126,8 @@ static void en_dis_able_nic_intrs(struct
 			temp64 = readq(&bar0->general_int_mask);
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* 
-			 * All MAC block error interrupts are disabled for now 
+			/*
+			 * All MAC block error interrupts are disabled for now
 			 * except the link status change interrupt.
 			 * TODO
 			 */
@@ -1131,8 +1140,8 @@ static void en_dis_able_nic_intrs(struct
 			val64 &= ~((u64) RMAC_LINK_STATE_CHANGE_INT);
 			writeq(val64, &bar0->mac_rmac_err_mask);
 		} else if (flag == DISABLE_INTRS) {
-			/*  
-			 * Disable MAC Intrs in the general intr mask register 
+			/*
+			 * Disable MAC Intrs in the general intr mask register
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->mac_int_mask);
 			writeq(DISABLE_ALL_INTRS,
@@ -1151,14 +1160,14 @@ static void en_dis_able_nic_intrs(struct
 			temp64 = readq(&bar0->general_int_mask);
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* 
+			/*
 			 * All XGXS block error interrupts are disabled for now
-			 * TODO 
+			 * TODO
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);
 		} else if (flag == DISABLE_INTRS) {
-			/*  
-			 * Disable MC Intrs in the general intr mask register 
+			/*
+			 * Disable MC Intrs in the general intr mask register
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);
 			temp64 = readq(&bar0->general_int_mask);
@@ -1174,9 +1183,9 @@ static void en_dis_able_nic_intrs(struct
 			temp64 = readq(&bar0->general_int_mask);
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* 
-			 * All MC block error interrupts are disabled for now
-			 * TODO 
+			/*
+			 * All MC block error interrupts are disabled for now.
+			 * TODO
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);
 		} else if (flag == DISABLE_INTRS) {
@@ -1198,14 +1207,14 @@ static void en_dis_able_nic_intrs(struct
 			temp64 = readq(&bar0->general_int_mask);
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* 
+			/*
 			 * Enable all the Tx side interrupts
-			 * writing 0 Enables all 64 TX interrupt levels 
+			 * writing 0 Enables all 64 TX interrupt levels
 			 */
 			writeq(0x0, &bar0->tx_traffic_mask);
 		} else if (flag == DISABLE_INTRS) {
-			/* 
-			 * Disable Tx Traffic Intrs in the general intr mask 
+			/*
+			 * Disable Tx Traffic Intrs in the general intr mask
 			 * register.
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->tx_traffic_mask);
@@ -1225,8 +1234,8 @@ static void en_dis_able_nic_intrs(struct
 			/* writing 0 Enables all 8 RX interrupt levels */
 			writeq(0x0, &bar0->rx_traffic_mask);
 		} else if (flag == DISABLE_INTRS) {
-			/*  
-			 * Disable Rx Traffic Intrs in the general intr mask 
+			/*
+			 * Disable Rx Traffic Intrs in the general intr mask
 			 * register.
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->rx_traffic_mask);
@@ -1237,20 +1246,42 @@ static void en_dis_able_nic_intrs(struct
 	}
 }
 
-/**  
- *  verify_xena_quiescence - Checks whether the H/W is ready 
+static int check_prc_pcc_state(u64 val64, int flag)
+{
+	int ret = 0;
+
+	if (flag == FALSE) {
+		if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) &&
+		    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
+		     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
+			ret = 1;
+		}
+	} else {
+		if (((val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) ==
+		     ADAPTER_STATUS_RMAC_PCC_IDLE) &&
+		    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||
+		     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
+		      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {
+			ret = 1;
+		}
+	}
+
+	return ret;
+}
+/**
+ *  verify_xena_quiescence - Checks whether the H/W is ready
  *  @val64 :  Value read from adapter status register.
  *  @flag : indicates if the adapter enable bit was ever written once
  *  before.
  *  Description: Returns whether the H/W is ready to go or not. Depending
- *  on whether adapter enable bit was written or not the comparison 
+ *  on whether adapter enable bit was written or not the comparison
  *  differs and the calling function passes the input argument flag to
  *  indicate this.
- *  Return: 1 If xena is quiescence 
+ *  Return: 1 If xena is quiescence
  *          0 If Xena is not quiescence
  */
 
-static int verify_xena_quiescence(u64 val64, int flag)
+static int verify_xena_quiescence(nic_t *sp, u64 val64, int flag)
 {
 	int ret = 0;
 	u64 tmp64 = ~((u64) val64);
@@ -1262,25 +1293,7 @@ static int verify_xena_quiescence(u64 va
 	      ADAPTER_STATUS_PIC_QUIESCENT | ADAPTER_STATUS_MC_DRAM_READY |
 	      ADAPTER_STATUS_MC_QUEUES_READY | ADAPTER_STATUS_M_PLL_LOCK |
 	      ADAPTER_STATUS_P_PLL_LOCK))) {
-		if (flag == FALSE) {
-			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) &&
-			    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-			     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
-
-				ret = 1;
-
-			}
-		} else {
-			if (((val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) ==
-			     ADAPTER_STATUS_RMAC_PCC_IDLE) &&
-			    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||
-			     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-			      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {
-
-				ret = 1;
-
-			}
-		}
+		ret = check_prc_pcc_state(val64, flag);
 	}
 
 	return ret;
@@ -1289,12 +1302,12 @@ static int verify_xena_quiescence(u64 va
 /**
  * fix_mac_address -  Fix for Mac addr problem on Alpha platforms
  * @sp: Pointer to device specifc structure
- * Description : 
+ * Description :
  * New procedure to clear mac address reading  problems on Alpha platforms
  *
  */
 
-static void fix_mac_address(nic_t * sp)
+void fix_mac_address(nic_t * sp)
 {
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
@@ -1302,20 +1315,21 @@ static void fix_mac_address(nic_t * sp)
 
 	while (fix_mac[i] != END_SIGN) {
 		writeq(fix_mac[i++], &bar0->gpio_control);
+		udelay(10);
 		val64 = readq(&bar0->gpio_control);
 	}
 }
 
 /**
- *  start_nic - Turns the device on   
+ *  start_nic - Turns the device on
  *  @nic : device private variable.
- *  Description: 
- *  This function actually turns the device on. Before this  function is 
- *  called,all Registers are configured from their reset states 
- *  and shared memory is allocated but the NIC is still quiescent. On 
+ *  Description:
+ *  This function actually turns the device on. Before this  function is
+ *  called,all Registers are configured from their reset states
+ *  and shared memory is allocated but the NIC is still quiescent. On
  *  calling this function, the device interrupts are cleared and the NIC is
  *  literally switched on by writing into the adapter control register.
- *  Return Value: 
+ *  Return Value:
  *  SUCCESS on success and -1 on failure.
  */
 
@@ -1324,8 +1338,8 @@ static int start_nic(struct s2io_nic *ni
 	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	struct net_device *dev = nic->dev;
 	register u64 val64 = 0;
-	u16 interruptible, i;
-	u16 subid;
+	u16 interruptible;
+	u16 subid, i;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
@@ -1334,7 +1348,7 @@ static int start_nic(struct s2io_nic *ni
 
 	/*  PRC Initialization and configuration */
 	for (i = 0; i < config->rx_ring_num; i++) {
-		writeq((u64) nic->rx_blocks[i][0].block_dma_addr,
+		writeq((u64) mac_control->rings[i].rx_blocks[0].block_dma_addr,
 		       &bar0->prc_rxd0_n[i]);
 
 		val64 = readq(&bar0->prc_ctrl_n[i]);
@@ -1353,7 +1367,7 @@ static int start_nic(struct s2io_nic *ni
 	writeq(val64, &bar0->rx_pa_cfg);
 #endif
 
-	/* 
+	/*
 	 * Enabling MC-RLDRAM. After enabling the device, we timeout
 	 * for around 100ms, which is approximately the time required
 	 * for the device to be ready for operation.
@@ -1363,27 +1377,27 @@ static int start_nic(struct s2io_nic *ni
 	SPECIAL_REG_WRITE(val64, &bar0->mc_rldram_mrs, UF);
 	val64 = readq(&bar0->mc_rldram_mrs);
 
-	msleep(100);			/* Delay by around 100 ms. */
+	msleep(100);	/* Delay by around 100 ms. */
 
 	/* Enabling ECC Protection. */
 	val64 = readq(&bar0->adapter_control);
 	val64 &= ~ADAPTER_ECC_EN;
 	writeq(val64, &bar0->adapter_control);
 
-	/* 
-	 * Clearing any possible Link state change interrupts that 
+	/*
+	 * Clearing any possible Link state change interrupts that
 	 * could have popped up just before Enabling the card.
 	 */
 	val64 = readq(&bar0->mac_rmac_err_reg);
 	if (val64)
 		writeq(val64, &bar0->mac_rmac_err_reg);
 
-	/* 
-	 * Verify if the device is ready to be enabled, if so enable 
+	/*
+	 * Verify if the device is ready to be enabled, if so enable
 	 * it.
 	 */
 	val64 = readq(&bar0->adapter_status);
-	if (!verify_xena_quiescence(val64, nic->device_enabled_once)) {
+	if (!verify_xena_quiescence(nic, val64, nic->device_enabled_once)) {
 		DBG_PRINT(ERR_DBG, "%s: device is not ready, ", dev->name);
 		DBG_PRINT(ERR_DBG, "Adapter status reads: 0x%llx\n",
 			  (unsigned long long) val64);
@@ -1395,12 +1409,12 @@ static int start_nic(struct s2io_nic *ni
 	    RX_MAC_INTR;
 	en_dis_able_nic_intrs(nic, interruptible, ENABLE_INTRS);
 
-	/* 
+	/*
 	 * With some switches, link might be already up at this point.
-	 * Because of this weird behavior, when we enable laser, 
-	 * we may not get link. We need to handle this. We cannot 
-	 * figure out which switch is misbehaving. So we are forced to 
-	 * make a global change. 
+	 * Because of this weird behavior, when we enable laser,
+	 * we may not get link. We need to handle this. We cannot
+	 * figure out which switch is misbehaving. So we are forced to
+	 * make a global change.
 	 */
 
 	/* Enabling Laser. */
@@ -1415,17 +1429,17 @@ static int start_nic(struct s2io_nic *ni
 		val64 |= 0x0000800000000000ULL;
 		writeq(val64, &bar0->gpio_control);
 		val64 = 0x0411040400000000ULL;
-		writeq(val64, (void __iomem *) bar0 + 0x2700);
+		writeq(val64, (void __iomem *) ((u8 *) bar0 + 0x2700));
 	}
 
-	/* 
-	 * Don't see link state interrupts on certain switches, so 
+	/*
+	 * Don't see link state interrupts on certain switches, so
 	 * directly scheduling a link state task from here.
 	 */
 	schedule_work(&nic->set_link_task);
 
-	/* 
-	 * Here we are performing soft reset on XGXS to 
+	/*
+	 * Here we are performing soft reset on XGXS to
 	 * force link down. Since link is already up, we will get
 	 * link state change interrupt after this reset
 	 */
@@ -1442,12 +1456,12 @@ static int start_nic(struct s2io_nic *ni
 	return SUCCESS;
 }
 
-/** 
- *  free_tx_buffers - Free all queued Tx buffers 
+/**
+ *  free_tx_buffers - Free all queued Tx buffers
  *  @nic : device private variable.
- *  Description: 
+ *  Description:
  *  Free all queued Tx buffers.
- *  Return Value: void 
+ *  Return Value: void
 */
 
 static void free_tx_buffers(struct s2io_nic *nic)
@@ -1465,7 +1479,7 @@ static void free_tx_buffers(struct s2io_
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		for (j = 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
-			txdp = (TxD_t *) nic->list_info[i][j].
+			txdp = (TxD_t *) mac_control->fifos[i].list_info[j].
 			    list_virt_addr;
 			skb =
 			    (struct sk_buff *) ((unsigned long) txdp->
@@ -1481,16 +1495,16 @@ static void free_tx_buffers(struct s2io_
 		DBG_PRINT(INTR_DBG,
 			  "%s:forcibly freeing %d skbs on FIFO%d\n",
 			  dev->name, cnt, i);
-		mac_control->tx_curr_get_info[i].offset = 0;
-		mac_control->tx_curr_put_info[i].offset = 0;
+		mac_control->fifos[i].tx_curr_get_info.offset = 0;
+		mac_control->fifos[i].tx_curr_put_info.offset = 0;
 	}
 }
 
-/**  
- *   stop_nic -  To stop the nic  
+/**
+ *   stop_nic -  To stop the nic
  *   @nic ; device private variable.
- *   Description: 
- *   This function does exactly the opposite of what the start_nic() 
+ *   Description:
+ *   This function does exactly the opposite of what the start_nic()
  *   function does. This function is called to stop the device.
  *   Return Value:
  *   void.
@@ -1520,11 +1534,11 @@ static void stop_nic(struct s2io_nic *ni
 	}
 }
 
-/**  
- *  fill_rx_buffers - Allocates the Rx side skbs 
+/**
+ *  fill_rx_buffers - Allocates the Rx side skbs
  *  @nic:  device private variable
- *  @ring_no: ring number 
- *  Description: 
+ *  @ring_no: ring number
+ *  Description:
  *  The function allocates Rx side skbs and puts the physical
  *  address of these buffers into the RxD buffer pointers, so that the NIC
  *  can DMA the received frame into these locations.
@@ -1532,8 +1546,8 @@ static void stop_nic(struct s2io_nic *ni
  *  1. single buffer,
  *  2. three buffer and
  *  3. Five buffer modes.
- *  Each mode defines how many fragments the received frame will be split 
- *  up into by the NIC. The frame is split into L3 header, L4 Header, 
+ *  Each mode defines how many fragments the received frame will be split
+ *  up into by the NIC. The frame is split into L3 header, L4 Header,
  *  L4 payload in three buffer mode and in 5 buffer mode, L4 payload itself
  *  is split into 3 fragments. As of now only single buffer mode is
  *  supported.
@@ -1541,7 +1555,7 @@ static void stop_nic(struct s2io_nic *ni
  *  SUCCESS on success or an appropriate -ve value on failure.
  */
 
-static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
+int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 {
 	struct net_device *dev = nic->dev;
 	struct sk_buff *skb;
@@ -1549,14 +1563,13 @@ static int fill_rx_buffers(struct s2io_n
 	int off, off1, size, block_no, block_no1;
 	int offset, offset1;
 	u32 alloc_tab = 0;
-	u32 alloc_cnt = nic->pkt_cnt[ring_no] -
-	    atomic_read(&nic->rx_bufs_left[ring_no]);
+	u32 alloc_cnt;
 	mac_info_t *mac_control;
 	struct config_param *config;
 #ifdef CONFIG_2BUFF_MODE
 	RxD_t *rxdpnext;
 	int nextblk;
-	unsigned long tmp;
+	u64 tmp;
 	buffAdd_t *ba;
 	dma_addr_t rxdpphys;
 #endif
@@ -1566,17 +1579,18 @@ static int fill_rx_buffers(struct s2io_n
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
-
+	alloc_cnt = mac_control->rings[ring_no].pkt_cnt -
+	    atomic_read(&nic->rx_bufs_left[ring_no]);
 	size = dev->mtu + HEADER_ETHERNET_II_802_3_SIZE +
 	    HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
 
 	while (alloc_tab < alloc_cnt) {
-		block_no = mac_control->rx_curr_put_info[ring_no].
+		block_no = mac_control->rings[ring_no].rx_curr_put_info.
 		    block_index;
-		block_no1 = mac_control->rx_curr_get_info[ring_no].
+		block_no1 = mac_control->rings[ring_no].rx_curr_get_info.
 		    block_index;
-		off = mac_control->rx_curr_put_info[ring_no].offset;
-		off1 = mac_control->rx_curr_get_info[ring_no].offset;
+		off = mac_control->rings[ring_no].rx_curr_put_info.offset;
+		off1 = mac_control->rings[ring_no].rx_curr_get_info.offset;
 #ifndef CONFIG_2BUFF_MODE
 		offset = block_no * (MAX_RXDS_PER_BLOCK + 1) + off;
 		offset1 = block_no1 * (MAX_RXDS_PER_BLOCK + 1) + off1;
@@ -1585,7 +1599,7 @@ static int fill_rx_buffers(struct s2io_n
 		offset1 = block_no1 * (MAX_RXDS_PER_BLOCK) + off1;
 #endif
 
-		rxdp = nic->rx_blocks[ring_no][block_no].
+		rxdp = mac_control->rings[ring_no].rx_blocks[block_no].
 		    block_virt_addr + off;
 		if ((offset == offset1) && (rxdp->Host_Control)) {
 			DBG_PRINT(INTR_DBG, "%s: Get and Put", dev->name);
@@ -1594,15 +1608,15 @@ static int fill_rx_buffers(struct s2io_n
 		}
 #ifndef	CONFIG_2BUFF_MODE
 		if (rxdp->Control_1 == END_OF_BLOCK) {
-			mac_control->rx_curr_put_info[ring_no].
+			mac_control->rings[ring_no].rx_curr_put_info.
 			    block_index++;
-			mac_control->rx_curr_put_info[ring_no].
-			    block_index %= nic->block_count[ring_no];
-			block_no = mac_control->rx_curr_put_info
-			    [ring_no].block_index;
+			mac_control->rings[ring_no].rx_curr_put_info.
+			    block_index %= mac_control->rings[ring_no].block_count;
+			block_no = mac_control->rings[ring_no].rx_curr_put_info.
+				block_index;
 			off++;
 			off %= (MAX_RXDS_PER_BLOCK + 1);
-			mac_control->rx_curr_put_info[ring_no].offset =
+			mac_control->rings[ring_no].rx_curr_put_info.offset =
 			    off;
 			rxdp = (RxD_t *) ((unsigned long) rxdp->Control_2);
 			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",
@@ -1610,30 +1624,30 @@ static int fill_rx_buffers(struct s2io_n
 		}
 #ifndef CONFIG_S2IO_NAPI
 		spin_lock_irqsave(&nic->put_lock, flags);
-		nic->put_pos[ring_no] =
+		mac_control->rings[ring_no].put_pos =
 		    (block_no * (MAX_RXDS_PER_BLOCK + 1)) + off;
 		spin_unlock_irqrestore(&nic->put_lock, flags);
 #endif
 #else
 		if (rxdp->Host_Control == END_OF_BLOCK) {
-			mac_control->rx_curr_put_info[ring_no].
+			mac_control->rings[ring_no].rx_curr_put_info.
 			    block_index++;
-			mac_control->rx_curr_put_info[ring_no].
-			    block_index %= nic->block_count[ring_no];
-			block_no = mac_control->rx_curr_put_info
-			    [ring_no].block_index;
+			mac_control->rings[ring_no].rx_curr_put_info.block_index
+			    %= mac_control->rings[ring_no].block_count;
+			block_no = mac_control->rings[ring_no].rx_curr_put_info
+			    .block_index;
 			off = 0;
 			DBG_PRINT(INTR_DBG, "%s: block%d at: 0x%llx\n",
 				  dev->name, block_no,
 				  (unsigned long long) rxdp->Control_1);
-			mac_control->rx_curr_put_info[ring_no].offset =
+			mac_control->rings[ring_no].rx_curr_put_info.offset =
 			    off;
-			rxdp = nic->rx_blocks[ring_no][block_no].
+			rxdp = mac_control->rings[ring_no].rx_blocks[block_no].
 			    block_virt_addr;
 		}
 #ifndef CONFIG_S2IO_NAPI
 		spin_lock_irqsave(&nic->put_lock, flags);
-		nic->put_pos[ring_no] = (block_no *
+		mac_control->rings[ring_no].put_pos = (block_no *
 					 (MAX_RXDS_PER_BLOCK + 1)) + off;
 		spin_unlock_irqrestore(&nic->put_lock, flags);
 #endif
@@ -1645,27 +1659,27 @@ static int fill_rx_buffers(struct s2io_n
 		if (rxdp->Control_2 & BIT(0))
 #endif
 		{
-			mac_control->rx_curr_put_info[ring_no].
+			mac_control->rings[ring_no].rx_curr_put_info.
 			    offset = off;
 			goto end;
 		}
 #ifdef	CONFIG_2BUFF_MODE
-		/* 
-		 * RxDs Spanning cache lines will be replenished only 
-		 * if the succeeding RxD is also owned by Host. It 
-		 * will always be the ((8*i)+3) and ((8*i)+6) 
-		 * descriptors for the 48 byte descriptor. The offending 
+		/*
+		 * RxDs Spanning cache lines will be replenished only
+		 * if the succeeding RxD is also owned by Host. It
+		 * will always be the ((8*i)+3) and ((8*i)+6)
+		 * descriptors for the 48 byte descriptor. The offending
 		 * decsriptor is of-course the 3rd descriptor.
 		 */
-		rxdpphys = nic->rx_blocks[ring_no][block_no].
+		rxdpphys = mac_control->rings[ring_no].rx_blocks[block_no].
 		    block_dma_addr + (off * sizeof(RxD_t));
 		if (((u64) (rxdpphys)) % 128 > 80) {
-			rxdpnext = nic->rx_blocks[ring_no][block_no].
+			rxdpnext = mac_control->rings[ring_no].rx_blocks[block_no].
 			    block_virt_addr + (off + 1);
 			if (rxdpnext->Host_Control == END_OF_BLOCK) {
 				nextblk = (block_no + 1) %
-				    (nic->block_count[ring_no]);
-				rxdpnext = nic->rx_blocks[ring_no]
+				    (mac_control->rings[ring_no].block_count);
+				rxdpnext = mac_control->rings[ring_no].rx_blocks
 				    [nextblk].block_virt_addr;
 			}
 			if (rxdpnext->Control_2 & BIT(0))
@@ -1694,11 +1708,11 @@ static int fill_rx_buffers(struct s2io_n
 		rxdp->Control_1 |= RXD_OWN_XENA;
 		off++;
 		off %= (MAX_RXDS_PER_BLOCK + 1);
-		mac_control->rx_curr_put_info[ring_no].offset = off;
+		mac_control->rings[ring_no].rx_curr_put_info.offset = off;
 #else
-		ba = &nic->ba[ring_no][block_no][off];
+		ba = &mac_control->rings[ring_no].ba[block_no][off];
 		skb_reserve(skb, BUF0_LEN);
-		tmp = (unsigned long) skb->data;
+		tmp = (u64) skb->data;
 		tmp += ALIGN_SIZE;
 		tmp &= ~ALIGN_SIZE;
 		skb->data = (void *) tmp;
@@ -1722,8 +1736,9 @@ static int fill_rx_buffers(struct s2io_n
 		rxdp->Host_Control = (u64) ((unsigned long) (skb));
 		rxdp->Control_1 |= RXD_OWN_XENA;
 		off++;
-		mac_control->rx_curr_put_info[ring_no].offset = off;
+		mac_control->rings[ring_no].rx_curr_put_info.offset = off;
 #endif
+
 		atomic_inc(&nic->rx_bufs_left[ring_no]);
 		alloc_tab++;
 	}
@@ -1733,9 +1748,9 @@ static int fill_rx_buffers(struct s2io_n
 }
 
 /**
- *  free_rx_buffers - Frees all Rx buffers   
+ *  free_rx_buffers - Frees all Rx buffers
  *  @sp: device private variable.
- *  Description: 
+ *  Description:
  *  This function will free all Rx buffers allocated by host.
  *  Return Value:
  *  NONE.
@@ -1759,7 +1774,8 @@ static void free_rx_buffers(struct s2io_
 	for (i = 0; i < config->rx_ring_num; i++) {
 		for (j = 0, blk = 0; j < config->rx_cfg[i].num_rxd; j++) {
 			off = j % (MAX_RXDS_PER_BLOCK + 1);
-			rxdp = sp->rx_blocks[i][blk].block_virt_addr + off;
+			rxdp = mac_control->rings[i].rx_blocks[blk].
+				block_virt_addr + off;
 
 #ifndef CONFIG_2BUFF_MODE
 			if (rxdp->Control_1 == END_OF_BLOCK) {
@@ -1794,7 +1810,7 @@ static void free_rx_buffers(struct s2io_
 						 HEADER_SNAP_SIZE,
 						 PCI_DMA_FROMDEVICE);
 #else
-				ba = &sp->ba[i][blk][off];
+				ba = &mac_control->rings[i].ba[blk][off];
 				pci_unmap_single(sp->pdev, (dma_addr_t)
 						 rxdp->Buffer0_ptr,
 						 BUF0_LEN,
@@ -1814,10 +1830,10 @@ static void free_rx_buffers(struct s2io_
 			}
 			memset(rxdp, 0, sizeof(RxD_t));
 		}
-		mac_control->rx_curr_put_info[i].block_index = 0;
-		mac_control->rx_curr_get_info[i].block_index = 0;
-		mac_control->rx_curr_put_info[i].offset = 0;
-		mac_control->rx_curr_get_info[i].offset = 0;
+		mac_control->rings[i].rx_curr_put_info.block_index = 0;
+		mac_control->rings[i].rx_curr_get_info.block_index = 0;
+		mac_control->rings[i].rx_curr_put_info.offset = 0;
+		mac_control->rings[i].rx_curr_get_info.offset = 0;
 		atomic_set(&sp->rx_bufs_left[i], 0);
 		DBG_PRINT(INIT_DBG, "%s:Freed 0x%x Rx Buffers on ring%d\n",
 			  dev->name, buf_cnt, i);
@@ -1827,7 +1843,7 @@ static void free_rx_buffers(struct s2io_
 /**
  * s2io_poll - Rx interrupt handler for NAPI support
  * @dev : pointer to the device structure.
- * @budget : The number of packets that were budgeted to be processed 
+ * @budget : The number of packets that were budgeted to be processed
  * during  one pass through the 'Poll" function.
  * Description:
  * Comes into picture only if NAPI support has been incorporated. It does
@@ -1837,160 +1853,35 @@ static void free_rx_buffers(struct s2io_
  * 0 on success and 1 if there are No Rx packets to be processed.
  */
 
-#ifdef CONFIG_S2IO_NAPI
+#if defined(CONFIG_S2IO_NAPI)
 static int s2io_poll(struct net_device *dev, int *budget)
 {
 	nic_t *nic = dev->priv;
-	XENA_dev_config_t __iomem *bar0 = nic->bar0;
-	int pkts_to_process = *budget, pkt_cnt = 0;
-	register u64 val64 = 0;
-	rx_curr_get_info_t get_info, put_info;
-	int i, get_block, put_block, get_offset, put_offset, ring_bufs;
-#ifndef CONFIG_2BUFF_MODE
-	u16 val16, cksum;
-#endif
-	struct sk_buff *skb;
-	RxD_t *rxdp;
+	int pkt_cnt = 0, org_pkts_to_process;
 	mac_info_t *mac_control;
 	struct config_param *config;
-#ifdef CONFIG_2BUFF_MODE
-	buffAdd_t *ba;
-#endif
+	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	u64 val64;
+	int i;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	if (pkts_to_process > dev->quota)
-		pkts_to_process = dev->quota;
+	nic->pkts_to_process = *budget;
+	if (nic->pkts_to_process > dev->quota)
+		nic->pkts_to_process = dev->quota;
+	org_pkts_to_process = nic->pkts_to_process;
 
 	val64 = readq(&bar0->rx_traffic_int);
 	writeq(val64, &bar0->rx_traffic_int);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		get_info = mac_control->rx_curr_get_info[i];
-		get_block = get_info.block_index;
-		put_info = mac_control->rx_curr_put_info[i];
-		put_block = put_info.block_index;
-		ring_bufs = config->rx_cfg[i].num_rxd;
-		rxdp = nic->rx_blocks[i][get_block].block_virt_addr +
-		    get_info.offset;
-#ifndef	CONFIG_2BUFF_MODE
-		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
-		    get_info.offset;
-		put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
-		    put_info.offset;
-		while ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
-		       (((get_offset + 1) % ring_bufs) != put_offset)) {
-			if (--pkts_to_process < 0) {
-				goto no_rx;
-			}
-			if (rxdp->Control_1 == END_OF_BLOCK) {
-				rxdp =
-				    (RxD_t *) ((unsigned long) rxdp->
-					       Control_2);
-				get_info.offset++;
-				get_info.offset %=
-				    (MAX_RXDS_PER_BLOCK + 1);
-				get_block++;
-				get_block %= nic->block_count[i];
-				mac_control->rx_curr_get_info[i].
-				    offset = get_info.offset;
-				mac_control->rx_curr_get_info[i].
-				    block_index = get_block;
-				continue;
-			}
-			get_offset =
-			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
-			    get_info.offset;
-			skb =
-			    (struct sk_buff *) ((unsigned long) rxdp->
-						Host_Control);
-			if (skb == NULL) {
-				DBG_PRINT(ERR_DBG, "%s: The skb is ",
-					  dev->name);
-				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-				goto no_rx;
-			}
-			val64 = RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
-			val16 = (u16) (val64 >> 48);
-			cksum = RXD_GET_L4_CKSUM(rxdp->Control_1);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 rxdp->Buffer0_ptr,
-					 dev->mtu +
-					 HEADER_ETHERNET_II_802_3_SIZE +
-					 HEADER_802_2_SIZE +
-					 HEADER_SNAP_SIZE,
-					 PCI_DMA_FROMDEVICE);
-			rx_osm_handler(nic, val16, rxdp, i);
-			pkt_cnt++;
-			get_info.offset++;
-			get_info.offset %= (MAX_RXDS_PER_BLOCK + 1);
-			rxdp =
-			    nic->rx_blocks[i][get_block].block_virt_addr +
-			    get_info.offset;
-			mac_control->rx_curr_get_info[i].offset =
-			    get_info.offset;
-		}
-#else
-		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
-		    get_info.offset;
-		put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
-		    put_info.offset;
-		while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
-			!(rxdp->Control_2 & BIT(0))) &&
-		       (((get_offset + 1) % ring_bufs) != put_offset)) {
-			if (--pkts_to_process < 0) {
-				goto no_rx;
-			}
-			skb = (struct sk_buff *) ((unsigned long)
-						  rxdp->Host_Control);
-			if (skb == NULL) {
-				DBG_PRINT(ERR_DBG, "%s: The skb is ",
-					  dev->name);
-				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-				goto no_rx;
-			}
-
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 rxdp->Buffer0_ptr,
-					 BUF0_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 rxdp->Buffer1_ptr,
-					 BUF1_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 rxdp->Buffer2_ptr,
-					 dev->mtu + BUF0_LEN + 4,
-					 PCI_DMA_FROMDEVICE);
-			ba = &nic->ba[i][get_block][get_info.offset];
-
-			rx_osm_handler(nic, rxdp, i, ba);
-
-			get_info.offset++;
-			mac_control->rx_curr_get_info[i].offset =
-			    get_info.offset;
-			rxdp =
-			    nic->rx_blocks[i][get_block].block_virt_addr +
-			    get_info.offset;
-
-			if (get_info.offset &&
-			    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
-				get_info.offset = 0;
-				mac_control->rx_curr_get_info[i].
-				    offset = get_info.offset;
-				get_block++;
-				get_block %= nic->block_count[i];
-				mac_control->rx_curr_get_info[i].
-				    block_index = get_block;
-				rxdp =
-				    nic->rx_blocks[i][get_block].
-				    block_virt_addr;
-			}
-			get_offset =
-			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
-			    get_info.offset;
-			pkt_cnt++;
+		rx_intr_handler(&mac_control->rings[i]);
+		pkt_cnt = org_pkts_to_process - nic->pkts_to_process;
+		if (!nic->pkts_to_process) {
+			/* Quota for the current iteration has been met */
+			goto no_rx;
 		}
-#endif
 	}
 	if (!pkt_cnt)
 		pkt_cnt = 1;
@@ -2010,7 +1901,7 @@ static int s2io_poll(struct net_device *
 	en_dis_able_nic_intrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);
 	return 0;
 
-      no_rx:
+no_rx:
 	dev->quota -= pkt_cnt;
 	*budget -= pkt_cnt;
 
@@ -2023,277 +1914,213 @@ static int s2io_poll(struct net_device *
 	}
 	return 1;
 }
-#else
-/**  
+#endif
+
+/**
  *  rx_intr_handler - Rx interrupt handler
  *  @nic: device private variable.
- *  Description: 
- *  If the interrupt is because of a received frame or if the 
+ *  Description:
+ *  If the interrupt is because of a received frame or if the
  *  receive ring contains fresh as yet un-processed frames,this function is
- *  called. It picks out the RxD at which place the last Rx processing had 
- *  stopped and sends the skb to the OSM's Rx handler and then increments 
+ *  called. It picks out the RxD at which place the last Rx processing had
+ *  stopped and sends the skb to the OSM's Rx handler and then increments
  *  the offset.
  *  Return Value:
  *  NONE.
  */
-
-static void rx_intr_handler(struct s2io_nic *nic)
+static void rx_intr_handler(ring_info_t *ring_data)
 {
+	nic_t *nic = ring_data->nic;
 	struct net_device *dev = (struct net_device *) nic->dev;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
+	int get_block, get_offset, put_block, put_offset, ring_bufs;
 	rx_curr_get_info_t get_info, put_info;
 	RxD_t *rxdp;
 	struct sk_buff *skb;
-#ifndef CONFIG_2BUFF_MODE
-	u16 val16, cksum;
-#endif
-	register u64 val64 = 0;
-	int get_block, get_offset, put_block, put_offset, ring_bufs;
-	int i, pkt_cnt = 0;
-	mac_info_t *mac_control;
-	struct config_param *config;
-#ifdef CONFIG_2BUFF_MODE
-	buffAdd_t *ba;
+#ifndef CONFIG_S2IO_NAPI
+	int pkt_cnt = 0;
 #endif
+	register u64 val64;
 
-	mac_control = &nic->mac_control;
-	config = &nic->config;
-
-	/* 
-	 * rx_traffic_int reg is an R1 register, hence we read and write back 
-	 * the samevalue in the register to clear it.
+	/*
+	 * rx_traffic_int reg is an R1 register, hence we read and write
+	 * back the same value in the register to clear it
 	 */
-	val64 = readq(&bar0->rx_traffic_int);
-	writeq(val64, &bar0->rx_traffic_int);
+	val64 = readq(&bar0->tx_traffic_int);
+	writeq(val64, &bar0->tx_traffic_int);
 
-	for (i = 0; i < config->rx_ring_num; i++) {
-		get_info = mac_control->rx_curr_get_info[i];
-		get_block = get_info.block_index;
-		put_info = mac_control->rx_curr_put_info[i];
-		put_block = put_info.block_index;
-		ring_bufs = config->rx_cfg[i].num_rxd;
-		rxdp = nic->rx_blocks[i][get_block].block_virt_addr +
+	get_info = ring_data->rx_curr_get_info;
+	get_block = get_info.block_index;
+	put_info = ring_data->rx_curr_put_info;
+	put_block = put_info.block_index;
+	ring_bufs = get_info.ring_len+1;
+	rxdp = ring_data->rx_blocks[get_block].block_virt_addr +
 		    get_info.offset;
-#ifndef	CONFIG_2BUFF_MODE
-		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
-		    get_info.offset;
-		spin_lock(&nic->put_lock);
-		put_offset = nic->put_pos[i];
-		spin_unlock(&nic->put_lock);
-		while ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
-		       (((get_offset + 1) % ring_bufs) != put_offset)) {
-			if (rxdp->Control_1 == END_OF_BLOCK) {
-				rxdp = (RxD_t *) ((unsigned long)
-						  rxdp->Control_2);
-				get_info.offset++;
-				get_info.offset %=
-				    (MAX_RXDS_PER_BLOCK + 1);
-				get_block++;
-				get_block %= nic->block_count[i];
-				mac_control->rx_curr_get_info[i].
-				    offset = get_info.offset;
-				mac_control->rx_curr_get_info[i].
-				    block_index = get_block;
-				continue;
-			}
-			get_offset =
-			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
-			    get_info.offset;
-			skb = (struct sk_buff *) ((unsigned long)
-						  rxdp->Host_Control);
-			if (skb == NULL) {
-				DBG_PRINT(ERR_DBG, "%s: The skb is ",
-					  dev->name);
-				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-				return;
-			}
-			val64 = RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
-			val16 = (u16) (val64 >> 48);
-			cksum = RXD_GET_L4_CKSUM(rxdp->Control_1);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 rxdp->Buffer0_ptr,
-					 dev->mtu +
-					 HEADER_ETHERNET_II_802_3_SIZE +
-					 HEADER_802_2_SIZE +
-					 HEADER_SNAP_SIZE,
-					 PCI_DMA_FROMDEVICE);
-			rx_osm_handler(nic, val16, rxdp, i);
-			get_info.offset++;
-			get_info.offset %= (MAX_RXDS_PER_BLOCK + 1);
-			rxdp =
-			    nic->rx_blocks[i][get_block].block_virt_addr +
-			    get_info.offset;
-			mac_control->rx_curr_get_info[i].offset =
-			    get_info.offset;
-			pkt_cnt++;
-			if ((indicate_max_pkts)
-			    && (pkt_cnt > indicate_max_pkts))
-				break;
+	get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		get_info.offset;
+#ifndef CONFIG_S2IO_NAPI
+	spin_lock(&nic->put_lock);
+	put_offset = ring_data->put_pos;
+	spin_unlock(&nic->put_lock);
+#else
+	put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		put_info.offset;
+#endif
+	while ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+#ifdef CONFIG_2BUFF_MODE
+		(!rxdp->Control_2 & BIT(0)) &&
+#endif
+	        (((get_offset + 1) % ring_bufs) != put_offset)) {
+		skb = (struct sk_buff *) ((unsigned long)rxdp->Host_Control);
+		if (skb == NULL) {
+			DBG_PRINT(ERR_DBG, "%s: The skb is ",
+				  dev->name);
+			DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
+			return;
 		}
+#ifndef CONFIG_2BUFF_MODE
+		pci_unmap_single(nic->pdev, (dma_addr_t)
+				 rxdp->Buffer0_ptr,
+				 dev->mtu +
+				 HEADER_ETHERNET_II_802_3_SIZE +
+				 HEADER_802_2_SIZE +
+				 HEADER_SNAP_SIZE,
+				 PCI_DMA_FROMDEVICE);
 #else
-		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		pci_unmap_single(nic->pdev, (dma_addr_t)
+				 rxdp->Buffer0_ptr,
+				 BUF0_LEN, PCI_DMA_FROMDEVICE);
+		pci_unmap_single(nic->pdev, (dma_addr_t)
+				 rxdp->Buffer1_ptr,
+				 BUF1_LEN, PCI_DMA_FROMDEVICE);
+		pci_unmap_single(nic->pdev, (dma_addr_t)
+				 rxdp->Buffer2_ptr,
+				 dev->mtu + BUF0_LEN + 4,
+				 PCI_DMA_FROMDEVICE);
+#endif
+		rx_osm_handler(ring_data, rxdp);
+		get_info.offset++;
+		ring_data->rx_curr_get_info.offset =
 		    get_info.offset;
-		spin_lock(&nic->put_lock);
-		put_offset = nic->put_pos[i];
-		spin_unlock(&nic->put_lock);
-		while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
-			!(rxdp->Control_2 & BIT(0))) &&
-		       (((get_offset + 1) % ring_bufs) != put_offset)) {
-			skb = (struct sk_buff *) ((unsigned long)
-						  rxdp->Host_Control);
-			if (skb == NULL) {
-				DBG_PRINT(ERR_DBG, "%s: The skb is ",
-					  dev->name);
-				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-				return;
-			}
-
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 rxdp->Buffer0_ptr,
-					 BUF0_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 rxdp->Buffer1_ptr,
-					 BUF1_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 rxdp->Buffer2_ptr,
-					 dev->mtu + BUF0_LEN + 4,
-					 PCI_DMA_FROMDEVICE);
-			ba = &nic->ba[i][get_block][get_info.offset];
-
-			rx_osm_handler(nic, rxdp, i, ba);
-
-			get_info.offset++;
-			mac_control->rx_curr_get_info[i].offset =
-			    get_info.offset;
-			rxdp =
-			    nic->rx_blocks[i][get_block].block_virt_addr +
-			    get_info.offset;
+		rxdp = ring_data->rx_blocks[get_block].block_virt_addr +
+		    get_info.offset;
+		if (get_info.offset &&
+		    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
+			get_info.offset = 0;
+			ring_data->rx_curr_get_info.offset
+			    = get_info.offset;
+			get_block++;
+			get_block %= ring_data->block_count;
+			ring_data->rx_curr_get_info.block_index
+			    = get_block;
+			rxdp = ring_data->rx_blocks[get_block].block_virt_addr;
+		}
 
-			if (get_info.offset &&
-			    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
-				get_info.offset = 0;
-				mac_control->rx_curr_get_info[i].
-				    offset = get_info.offset;
-				get_block++;
-				get_block %= nic->block_count[i];
-				mac_control->rx_curr_get_info[i].
-				    block_index = get_block;
-				rxdp =
-				    nic->rx_blocks[i][get_block].
-				    block_virt_addr;
-			}
-			get_offset =
-			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
 			    get_info.offset;
-			pkt_cnt++;
-			if ((indicate_max_pkts)
-			    && (pkt_cnt > indicate_max_pkts))
-				break;
-		}
-#endif
+#ifdef CONFIG_S2IO_NAPI
+		nic->pkts_to_process -= 1;
+		if (!nic->pkts_to_process)
+			break;
+#else
+		pkt_cnt++;
 		if ((indicate_max_pkts) && (pkt_cnt > indicate_max_pkts))
 			break;
+#endif
 	}
 }
-#endif
-/**  
+
+/**
  *  tx_intr_handler - Transmit interrupt handler
  *  @nic : device private variable
- *  Description: 
- *  If an interrupt was raised to indicate DMA complete of the 
- *  Tx packet, this function is called. It identifies the last TxD 
- *  whose buffer was freed and frees all skbs whose data have already 
+ *  Description:
+ *  If an interrupt was raised to indicate DMA complete of the
+ *  Tx packet, this function is called. It identifies the last TxD
+ *  whose buffer was freed and frees all skbs whose data have already
  *  DMA'ed into the NICs internal memory.
  *  Return Value:
  *  NONE
  */
 
-static void tx_intr_handler(struct s2io_nic *nic)
+static void tx_intr_handler(fifo_info_t *fifo_data)
 {
+	nic_t *nic = fifo_data->nic;
 	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	struct net_device *dev = (struct net_device *) nic->dev;
 	tx_curr_get_info_t get_info, put_info;
 	struct sk_buff *skb;
 	TxD_t *txdlp;
-	register u64 val64 = 0;
-	int i;
 	u16 j, frg_cnt;
-	mac_info_t *mac_control;
-	struct config_param *config;
-
-	mac_control = &nic->mac_control;
-	config = &nic->config;
+	register u64 val64 = 0;
 
-	/* 
-	 * tx_traffic_int reg is an R1 register, hence we read and write 
-	 * back the samevalue in the register to clear it.
+	/*
+	 * tx_traffic_int reg is an R1 register, hence we read and write
+	 * back the same value in the register to clear it
 	 */
 	val64 = readq(&bar0->tx_traffic_int);
 	writeq(val64, &bar0->tx_traffic_int);
 
-	for (i = 0; i < config->tx_fifo_num; i++) {
-		get_info = mac_control->tx_curr_get_info[i];
-		put_info = mac_control->tx_curr_put_info[i];
-		txdlp = (TxD_t *) nic->list_info[i][get_info.offset].
-		    list_virt_addr;
-		while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&
-		       (get_info.offset != put_info.offset) &&
-		       (txdlp->Host_Control)) {
-			/* Check for TxD errors */
-			if (txdlp->Control_1 & TXD_T_CODE) {
-				unsigned long long err;
-				err = txdlp->Control_1 & TXD_T_CODE;
-				DBG_PRINT(ERR_DBG, "***TxD error %llx\n",
-					  err);
-			}
-
-			skb = (struct sk_buff *) ((unsigned long)
-						  txdlp->Host_Control);
-			if (skb == NULL) {
-				DBG_PRINT(ERR_DBG, "%s: Null skb ",
-					  dev->name);
-				DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");
-				return;
-			}
-			nic->tx_pkt_count++;
+	get_info = fifo_data->tx_curr_get_info;
+	put_info = fifo_data->tx_curr_put_info;
+	txdlp = (TxD_t *) fifo_data->list_info[get_info.offset].
+	    list_virt_addr;
+	while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&
+	       (get_info.offset != put_info.offset) &&
+	       (txdlp->Host_Control)) {
+		/* Check for TxD errors */
+		if (txdlp->Control_1 & TXD_T_CODE) {
+			unsigned long long err;
+			err = txdlp->Control_1 & TXD_T_CODE;
+			DBG_PRINT(ERR_DBG, "***TxD error %llx\n",
+				  err);
+		}
+
+		skb = (struct sk_buff *) ((unsigned long)
+				txdlp->Host_Control);
+		if (skb == NULL) {
+			DBG_PRINT(ERR_DBG, "%s: Null skb ",
+			__FUNCTION__);
+			DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");
+			return;
+		}
 
-			frg_cnt = skb_shinfo(skb)->nr_frags;
+		frg_cnt = skb_shinfo(skb)->nr_frags;
+		nic->tx_pkt_count++;
 
-			/*  For unfragmented skb */
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 txdlp->Buffer_Pointer,
-					 skb->len - skb->data_len,
-					 PCI_DMA_TODEVICE);
-			if (frg_cnt) {
-				TxD_t *temp = txdlp;
-				txdlp++;
-				for (j = 0; j < frg_cnt; j++, txdlp++) {
-					skb_frag_t *frag =
-					    &skb_shinfo(skb)->frags[j];
-					pci_unmap_page(nic->pdev,
-						       (dma_addr_t)
-						       txdlp->
-						       Buffer_Pointer,
-						       frag->size,
-						       PCI_DMA_TODEVICE);
-				}
-				txdlp = temp;
+		pci_unmap_single(nic->pdev, (dma_addr_t)
+				 txdlp->Buffer_Pointer,
+				 skb->len - skb->data_len,
+				 PCI_DMA_TODEVICE);
+		if (frg_cnt) {
+			TxD_t *temp;
+			temp = txdlp;
+			txdlp++;
+			for (j = 0; j < frg_cnt; j++, txdlp++) {
+				skb_frag_t *frag =
+				    &skb_shinfo(skb)->frags[j];
+				pci_unmap_page(nic->pdev,
+					       (dma_addr_t)
+					       txdlp->
+					       Buffer_Pointer,
+					       frag->size,
+					       PCI_DMA_TODEVICE);
 			}
-			memset(txdlp, 0,
-			       (sizeof(TxD_t) * config->max_txds));
-
-			/* Updating the statistics block */
-			nic->stats.tx_packets++;
-			nic->stats.tx_bytes += skb->len;
-			dev_kfree_skb_irq(skb);
-
-			get_info.offset++;
-			get_info.offset %= get_info.fifo_len + 1;
-			txdlp = (TxD_t *) nic->list_info[i]
-			    [get_info.offset].list_virt_addr;
-			mac_control->tx_curr_get_info[i].offset =
-			    get_info.offset;
+			txdlp = temp;
 		}
+		memset(txdlp, 0,
+		       (sizeof(TxD_t) * fifo_data->max_txds));
+
+		/* Updating the statistics block */
+		nic->stats.tx_packets++;
+		nic->stats.tx_bytes += skb->len;
+		dev_kfree_skb_irq(skb);
+
+		get_info.offset++;
+		get_info.offset %= get_info.fifo_len + 1;
+		txdlp = (TxD_t *) fifo_data->list_info
+		    [get_info.offset].list_virt_addr;
+		fifo_data->tx_curr_get_info.offset =
+		    get_info.offset;
 	}
 
 	spin_lock(&nic->tx_lock);
@@ -2302,13 +2129,13 @@ static void tx_intr_handler(struct s2io_
 	spin_unlock(&nic->tx_lock);
 }
 
-/**  
+/**
  *  alarm_intr_handler - Alarm Interrrupt handler
  *  @nic: device private variable
- *  Description: If the interrupt was neither because of Rx packet or Tx 
+ *  Description: If the interrupt was neither because of Rx packet or Tx
  *  complete, this function is called. If the interrupt was to indicate
- *  a loss of link, the OSM link status handler is invoked for any other 
- *  alarm interrupt the block that raised the interrupt is displayed 
+ *  a loss of link, the OSM link status handler is invoked for any other
+ *  alarm interrupt the block that raised the interrupt is displayed
  *  and a H/W reset is issued.
  *  Return Value:
  *  NONE
@@ -2339,7 +2166,7 @@ static void alarm_intr_handler(struct s2
 	/*
 	 * Also as mentioned in the latest Errata sheets if the PCC_FB_ECC
 	 * Error occurs, the adapter will be recycled by disabling the
-	 * adapter enable bit and enabling it again after the device 
+	 * adapter enable bit and enabling it again after the device
 	 * becomes Quiescent.
 	 */
 	val64 = readq(&bar0->pcc_err_reg);
@@ -2355,18 +2182,18 @@ static void alarm_intr_handler(struct s2
 	/* Other type of interrupts are not being handled now,  TODO */
 }
 
-/** 
+/**
  *  wait_for_cmd_complete - waits for a command to complete.
- *  @sp : private member of the device structure, which is a pointer to the 
+ *  @sp : private member of the device structure, which is a pointer to the
  *  s2io_nic structure.
- *  Description: Function that waits for a command to Write into RMAC 
- *  ADDR DATA registers to be completed and returns either success or 
- *  error depending on whether the command was complete or not. 
+ *  Description: Function that waits for a command to Write into RMAC
+ *  ADDR DATA registers to be completed and returns either success or
+ *  error depending on whether the command was complete or not.
  *  Return value:
  *   SUCCESS on success and FAILURE on failure.
  */
 
-static int wait_for_cmd_complete(nic_t * sp)
+int wait_for_cmd_complete(nic_t * sp)
 {
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	int ret = FAILURE, cnt = 0;
@@ -2386,17 +2213,17 @@ static int wait_for_cmd_complete(nic_t *
 	return ret;
 }
 
-/** 
- *  s2io_reset - Resets the card. 
+/**
+ *  s2io_reset - Resets the card.
  *  @sp : private member of the device structure.
  *  Description: Function to Reset the card. This function then also
- *  restores the previously saved PCI configuration space registers as 
+ *  restores the previously saved PCI configuration space registers as
  *  the card reset also resets the configuration space.
  *  Return value:
  *  void.
  */
 
-static void s2io_reset(nic_t * sp)
+void s2io_reset(nic_t * sp)
 {
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
@@ -2405,10 +2232,10 @@ static void s2io_reset(nic_t * sp)
 	val64 = SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
 
-	/* 
-	 * At this stage, if the PCI write is indeed completed, the 
-	 * card is reset and so is the PCI Config space of the device. 
-	 * So a read cannot be issued at this stage on any of the 
+	/*
+	 * At this stage, if the PCI write is indeed completed, the
+	 * card is reset and so is the PCI Config space of the device.
+	 * So a read cannot be issued at this stage on any of the
 	 * registers to ensure the write into "sw_reset" register
 	 * has gone through.
 	 * Question: Is there any system call that will explicitly force
@@ -2421,10 +2248,17 @@ static void s2io_reset(nic_t * sp)
 
 	/* Restore the PCI state saved during initializarion. */
 	pci_restore_state(sp->pdev);
+
 	s2io_init_pci(sp);
 
 	msleep(250);
 
+	/* Set swapper to enable I/O register access */
+	s2io_set_swapper(sp);
+
+	/* Reset device statistics maintained by OS */
+	memset(&sp->stats, 0, sizeof (struct net_device_stats));
+
 	/* SXE-002: Configure link and activity LED to turn it off */
 	subid = sp->pdev->subsystem_device;
 	if ((subid & 0xFF) >= 0x07) {
@@ -2432,29 +2266,29 @@ static void s2io_reset(nic_t * sp)
 		val64 |= 0x0000800000000000ULL;
 		writeq(val64, &bar0->gpio_control);
 		val64 = 0x0411040400000000ULL;
-		writeq(val64, (void __iomem *) bar0 + 0x2700);
+		writeq(val64, (void __iomem *) ((u8 *) bar0 + 0x2700));
 	}
 
 	sp->device_enabled_once = FALSE;
 }
 
 /**
- *  s2io_set_swapper - to set the swapper controle on the card 
- *  @sp : private member of the device structure, 
+ *  s2io_set_swapper - to set the swapper controle on the card
+ *  @sp : private member of the device structure,
  *  pointer to the s2io_nic structure.
- *  Description: Function to set the swapper control on the card 
+ *  Description: Function to set the swapper control on the card
  *  correctly depending on the 'endianness' of the system.
  *  Return value:
  *  SUCCESS on success and FAILURE on failure.
  */
 
-static int s2io_set_swapper(nic_t * sp)
+int s2io_set_swapper(nic_t * sp)
 {
 	struct net_device *dev = sp->dev;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64, valt, valr;
 
-	/* 
+	/*
 	 * Set proper endian settings and verify the same by reading
 	 * the PIF Feed-back register.
 	 */
@@ -2506,8 +2340,9 @@ static int s2io_set_swapper(nic_t * sp)
 			i++;
 		}
 		if(i == 4) {
+			unsigned long long x = val64;
 			DBG_PRINT(ERR_DBG, "Write failed, Xmsi_addr ");
-			DBG_PRINT(ERR_DBG, "reads:0x%llx\n",val64);
+			DBG_PRINT(ERR_DBG, "reads:0x%llx\n", x);
 			return FAILURE;
 		}
 	}
@@ -2515,8 +2350,8 @@ static int s2io_set_swapper(nic_t * sp)
 	val64 &= 0xFFFF000000000000ULL;
 
 #ifdef  __BIG_ENDIAN
-	/* 
-	 * The device by default set to a big endian format, so a 
+	/*
+	 * The device by default set to a big endian format, so a
 	 * big endian driver need not set anything.
 	 */
 	val64 |= (SWAPPER_CTRL_TXP_FE |
@@ -2532,9 +2367,9 @@ static int s2io_set_swapper(nic_t * sp)
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
 	writeq(val64, &bar0->swapper_ctrl);
 #else
-	/* 
+	/*
 	 * Initially we enable all bits to make it accessible by the
-	 * driver, then we selectively enable only those bits that 
+	 * driver, then we selectively enable only those bits that
 	 * we want to set.
 	 */
 	val64 |= (SWAPPER_CTRL_TXP_FE |
@@ -2556,8 +2391,8 @@ static int s2io_set_swapper(nic_t * sp)
 #endif
 	val64 = readq(&bar0->swapper_ctrl);
 
-	/* 
-	 * Verifying if endian settings are accurate by reading a 
+	/*
+	 * Verifying if endian settings are accurate by reading a
 	 * feedback register.
 	 */
 	val64 = readq(&bar0->pif_rd_swapper_fb);
@@ -2577,25 +2412,25 @@ static int s2io_set_swapper(nic_t * sp)
  * Functions defined below concern the OS part of the driver *
  * ********************************************************* */
 
-/**  
+/**
  *  s2io_open - open entry point of the driver
  *  @dev : pointer to the device structure.
  *  Description:
  *  This function is the open entry point of the driver. It mainly calls a
  *  function to allocate Rx buffers and inserts them into the buffer
- *  descriptors and then enables the Rx part of the NIC. 
+ *  descriptors and then enables the Rx part of the NIC.
  *  Return value:
  *  0 on success and an appropriate (-)ve integer as defined in errno.h
  *   file on failure.
  */
 
-static int s2io_open(struct net_device *dev)
+int s2io_open(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
 	int err = 0;
 
-	/* 
-	 * Make sure you have link off by default every time 
+	/*
+	 * Make sure you have link off by default every time
 	 * Nic is initialized
 	 */
 	netif_carrier_off(dev);
@@ -2605,27 +2440,34 @@ static int s2io_open(struct net_device *
 	if (s2io_card_up(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",
 			  dev->name);
-		return -ENODEV;
+		err = -ENODEV;
+		goto hw_init_failed;
 	}
 
 	/* After proper initialization of H/W, register ISR */
-	err = request_irq((int) sp->irq, s2io_isr, SA_SHIRQ,
+	err = request_irq((int) sp->pdev->irq, s2io_isr, SA_SHIRQ,
 			  sp->name, dev);
 	if (err) {
-		s2io_reset(sp);
 		DBG_PRINT(ERR_DBG, "%s: ISR registration failed\n",
 			  dev->name);
-		return err;
+		goto isr_registration_failed;
 	}
 
 	if (s2io_set_mac_addr(dev, dev->dev_addr) == FAILURE) {
 		DBG_PRINT(ERR_DBG, "Set Mac Address Failed\n");
-		s2io_reset(sp);
-		return -ENODEV;
+		err = -ENODEV;
+		goto setting_mac_address_failed;
 	}
 
 	netif_start_queue(dev);
 	return 0;
+
+setting_mac_address_failed:
+	free_irq(sp->pdev->irq, dev);
+isr_registration_failed:
+	s2io_reset(sp);
+hw_init_failed:
+	return err;
 }
 
 /**
@@ -2641,16 +2483,15 @@ static int s2io_open(struct net_device *
  *  file on failure.
  */
 
-static int s2io_close(struct net_device *dev)
+int s2io_close(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
-
 	flush_scheduled_work();
 	netif_stop_queue(dev);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
 
-	free_irq(dev->irq, dev);
+	free_irq(sp->pdev->irq, dev);
 	sp->device_close_flag = TRUE;	/* Device is shut down. */
 	return 0;
 }
@@ -2668,7 +2509,7 @@ static int s2io_close(struct net_device 
  *  0 on success & 1 on failure.
  */
 
-static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
+int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
 	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
@@ -2686,22 +2527,24 @@ static int s2io_xmit(struct sk_buff *skb
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
-	DBG_PRINT(TX_DBG, "%s: In S2IO Tx routine\n", dev->name);
+	DBG_PRINT(TX_DBG, "%s: In Neterion Tx routine\n", dev->name);
 	spin_lock_irqsave(&sp->tx_lock, flags);
-
 	if (atomic_read(&sp->card_state) == CARD_DOWN) {
-		DBG_PRINT(ERR_DBG, "%s: Card going down for reset\n",
+		DBG_PRINT(TX_DBG, "%s: Card going down for reset\n",
 			  dev->name);
 		spin_unlock_irqrestore(&sp->tx_lock, flags);
-		return 1;
+		dev_kfree_skb(skb);
+		return 0;
 	}
 
 	queue = 0;
-	put_off = (u16) mac_control->tx_curr_put_info[queue].offset;
-	get_off = (u16) mac_control->tx_curr_get_info[queue].offset;
-	txdp = (TxD_t *) sp->list_info[queue][put_off].list_virt_addr;
 
-	queue_len = mac_control->tx_curr_put_info[queue].fifo_len + 1;
+	put_off = (u16) mac_control->fifos[queue].tx_curr_put_info.offset;
+	get_off = (u16) mac_control->fifos[queue].tx_curr_get_info.offset;
+	txdp = (TxD_t *) mac_control->fifos[queue].list_info[put_off].
+		list_virt_addr;
+
+	queue_len = mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1;
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (txdp->Host_Control || (((put_off + 1) % queue_len) == get_off)) {
 		DBG_PRINT(ERR_DBG, "Error in xmit, No free TXDs.\n");
@@ -2721,9 +2564,9 @@ static int s2io_xmit(struct sk_buff *skb
 	frg_cnt = skb_shinfo(skb)->nr_frags;
 	frg_len = skb->len - skb->data_len;
 
-	txdp->Host_Control = (unsigned long) skb;
 	txdp->Buffer_Pointer = pci_map_single
 	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
+	txdp->Host_Control = (unsigned long) skb;
 	if (skb->ip_summed == CHECKSUM_HW) {
 		txdp->Control_2 |=
 		    (TXD_TX_CKO_IPV4_EN | TXD_TX_CKO_TCP_EN |
@@ -2748,11 +2591,12 @@ static int s2io_xmit(struct sk_buff *skb
 	txdp->Control_1 |= TXD_GATHER_CODE_LAST;
 
 	tx_fifo = mac_control->tx_FIFO_start[queue];
-	val64 = sp->list_info[queue][put_off].list_phy_addr;
+	val64 = mac_control->fifos[queue].list_info[put_off].list_phy_addr;
 	writeq(val64, &tx_fifo->TxDL_Pointer);
 
 	val64 = (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |
 		 TX_FIFO_LAST_LIST);
+
 #ifdef NETIF_F_TSO
 	if (mss)
 		val64 |= TX_FIFO_SPECIAL_FUNC;
@@ -2763,8 +2607,8 @@ static int s2io_xmit(struct sk_buff *skb
 	val64 = readq(&bar0->general_int_status);
 
 	put_off++;
-	put_off %= mac_control->tx_curr_put_info[queue].fifo_len + 1;
-	mac_control->tx_curr_put_info[queue].offset = put_off;
+	put_off %= mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1;
+	mac_control->fifos[queue].tx_curr_put_info.offset = put_off;
 
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (((put_off + 1) % queue_len) == get_off) {
@@ -2785,13 +2629,13 @@ static int s2io_xmit(struct sk_buff *skb
  *  @irq: the irq of the device.
  *  @dev_id: a void pointer to the dev structure of the NIC.
  *  @pt_regs: pointer to the registers pushed on the stack.
- *  Description:  This function is the ISR handler of the device. It 
- *  identifies the reason for the interrupt and calls the relevant 
- *  service routines. As a contongency measure, this ISR allocates the 
+ *  Description:  This function is the ISR handler of the device. It
+ *  identifies the reason for the interrupt and calls the relevant
+ *  service routines. As a contongency measure, this ISR allocates the
  *  recv buffers, if their numbers are below the panic value which is
  *  presently set to 25% of the original number of rcv buffers allocated.
  *  Return value:
- *   IRQ_HANDLED: will be returned if IRQ was handled by this routine 
+ *   IRQ_HANDLED: will be returned if IRQ was handled by this routine
  *   IRQ_NONE: will be returned if interrupt is not from our device
  */
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs)
@@ -2799,9 +2643,7 @@ static irqreturn_t s2io_isr(int irq, voi
 	struct net_device *dev = (struct net_device *) dev_id;
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
-#ifndef CONFIG_S2IO_NAPI
-	int i, ret;
-#endif
+	int i;
 	u64 reason = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
@@ -2809,13 +2651,13 @@ static irqreturn_t s2io_isr(int irq, voi
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
-	/* 
+	/*
 	 * Identify the cause for interrupt and call the appropriate
 	 * interrupt handler. Causes for the interrupt could be;
 	 * 1. Rx of packet.
 	 * 2. Tx complete.
 	 * 3. Link down.
-	 * 4. Error in any functional blocks of the NIC. 
+	 * 4. Error in any functional blocks of the NIC.
 	 */
 	reason = readq(&bar0->general_int_status);
 
@@ -2824,12 +2666,6 @@ static irqreturn_t s2io_isr(int irq, voi
 		return IRQ_NONE;
 	}
 
-	/* If Intr is because of Tx Traffic */
-	if (reason & GEN_INTR_TXTRAFFIC) {
-		tx_intr_handler(sp);
-	}
-
-	/* If Intr is because of an error */
 	if (reason & (GEN_ERROR_INTR))
 		alarm_intr_handler(sp);
 
@@ -2844,17 +2680,26 @@ static irqreturn_t s2io_isr(int irq, voi
 #else
 	/* If Intr is because of Rx Traffic */
 	if (reason & GEN_INTR_RXTRAFFIC) {
-		rx_intr_handler(sp);
+		for (i = 0; i < config->rx_ring_num; i++) {
+			rx_intr_handler(&mac_control->rings[i]);
+		}
 	}
 #endif
 
-	/* 
-	 * If the Rx buffer count is below the panic threshold then 
-	 * reallocate the buffers from the interrupt handler itself, 
+	/* If Intr is because of Tx Traffic */
+	if (reason & GEN_INTR_TXTRAFFIC) {
+		for (i = 0; i < config->tx_fifo_num; i++)
+			tx_intr_handler(&mac_control->fifos[i]);
+	}
+
+	/*
+	 * If the Rx buffer count is below the panic threshold then
+	 * reallocate the buffers from the interrupt handler itself,
 	 * else schedule a tasklet to reallocate the buffers.
 	 */
 #ifndef CONFIG_S2IO_NAPI
 	for (i = 0; i < config->rx_ring_num; i++) {
+		int ret;
 		int rxb_size = atomic_read(&sp->rx_bufs_left[i]);
 		int level = rx_buffer_level(sp, rxb_size, i);
 
@@ -2879,29 +2724,33 @@ static irqreturn_t s2io_isr(int irq, voi
 }
 
 /**
- *  s2io_get_stats - Updates the device statistics structure. 
+ *  s2io_get_stats - Updates the device statistics structure.
  *  @dev : pointer to the device structure.
  *  Description:
- *  This function updates the device statistics structure in the s2io_nic 
+ *  This function updates the device statistics structure in the s2io_nic
  *  structure and returns a pointer to the same.
  *  Return value:
  *  pointer to the updated net_device_stats structure.
  */
 
-static struct net_device_stats *s2io_get_stats(struct net_device *dev)
+struct net_device_stats *s2io_get_stats(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
+
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
-	sp->stats.tx_errors = mac_control->stats_info->tmac_any_err_frms;
-	sp->stats.rx_errors = mac_control->stats_info->rmac_drop_frms;
-	sp->stats.multicast = mac_control->stats_info->rmac_vld_mcst_frms;
+	sp->stats.tx_errors =
+		le32_to_cpu(mac_control->stats_info->tmac_any_err_frms);
+	sp->stats.rx_errors =
+		le32_to_cpu(mac_control->stats_info->rmac_drop_frms);
+	sp->stats.multicast =
+		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms);
 	sp->stats.rx_length_errors =
-	    mac_control->stats_info->rmac_long_frms;
+		le32_to_cpu(mac_control->stats_info->rmac_long_frms);
 
 	return (&sp->stats);
 }
@@ -2910,8 +2759,8 @@ static struct net_device_stats *s2io_get
  *  s2io_set_multicast - entry point for multicast address enable/disable.
  *  @dev : pointer to the device structure
  *  Description:
- *  This function is a driver entry point which gets called by the kernel 
- *  whenever multicast addresses must be enabled/disabled. This also gets 
+ *  This function is a driver entry point which gets called by the kernel
+ *  whenever multicast addresses must be enabled/disabled. This also gets
  *  called to set/reset promiscuous mode. Depending on the deivce flag, we
  *  determine, if multicast address must be enabled or if promiscuous mode
  *  is to be disabled etc.
@@ -3011,7 +2860,7 @@ static void s2io_set_multicast(struct ne
 			writeq(RMAC_ADDR_DATA0_MEM_ADDR(dis_addr),
 			       &bar0->rmac_addr_data0_mem);
 			writeq(RMAC_ADDR_DATA1_MEM_MASK(0ULL),
-		       		&bar0->rmac_addr_data1_mem);
+				&bar0->rmac_addr_data1_mem);
 			val64 = RMAC_ADDR_CMD_MEM_WE |
 			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 			    RMAC_ADDR_CMD_MEM_OFFSET
@@ -3040,8 +2889,7 @@ static void s2io_set_multicast(struct ne
 			writeq(RMAC_ADDR_DATA0_MEM_ADDR(mac_addr),
 			       &bar0->rmac_addr_data0_mem);
 			writeq(RMAC_ADDR_DATA1_MEM_MASK(0ULL),
-		       		&bar0->rmac_addr_data1_mem);
-
+				&bar0->rmac_addr_data1_mem);
 			val64 = RMAC_ADDR_CMD_MEM_WE |
 			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 			    RMAC_ADDR_CMD_MEM_OFFSET
@@ -3060,12 +2908,12 @@ static void s2io_set_multicast(struct ne
 }
 
 /**
- *  s2io_set_mac_addr - Programs the Xframe mac address 
+ *  s2io_set_mac_addr - Programs the Xframe mac address
  *  @dev : pointer to the device structure.
  *  @addr: a uchar pointer to the new mac address which is to be set.
- *  Description : This procedure will program the Xframe to receive 
+ *  Description : This procedure will program the Xframe to receive
  *  frames with new Mac Address
- *  Return value: SUCCESS on success and an appropriate (-)ve integer 
+ *  Return value: SUCCESS on success and an appropriate (-)ve integer
  *  as defined in errno.h file on failure.
  */
 
@@ -3076,10 +2924,10 @@ int s2io_set_mac_addr(struct net_device 
 	register u64 val64, mac_addr = 0;
 	int i;
 
-	/* 
+	/*
 	 * Set the new MAC address as the new unicast filter and reflect this
 	 * change on the device address registered with the OS. It will be
-	 * at offset 0. 
+	 * at offset 0.
 	 */
 	for (i = 0; i < ETH_ALEN; i++) {
 		mac_addr <<= 8;
@@ -3103,12 +2951,12 @@ int s2io_set_mac_addr(struct net_device 
 }
 
 /**
- * s2io_ethtool_sset - Sets different link parameters. 
+ * s2io_ethtool_sset - Sets different link parameters.
  * @sp : private member of the device structure, which is a pointer to the  * s2io_nic structure.
  * @info: pointer to the structure with parameters given by ethtool to set
  * link information.
  * Description:
- * The function sets different link parameters provided by the user onto 
+ * The function sets different link parameters provided by the user onto
  * the NIC.
  * Return value:
  * 0 on success.
@@ -3130,7 +2978,7 @@ static int s2io_ethtool_sset(struct net_
 }
 
 /**
- * s2io_ethtol_gset - Return link specific information. 
+ * s2io_ethtol_gset - Return link specific information.
  * @sp : private member of the device structure, pointer to the
  *      s2io_nic structure.
  * @info : pointer to the structure with parameters given by ethtool
@@ -3162,8 +3010,8 @@ static int s2io_ethtool_gset(struct net_
 }
 
 /**
- * s2io_ethtool_gdrvinfo - Returns driver specific information. 
- * @sp : private member of the device structure, which is a pointer to the 
+ * s2io_ethtool_gdrvinfo - Returns driver specific information.
+ * @sp : private member of the device structure, which is a pointer to the
  * s2io_nic structure.
  * @info : pointer to the structure with parameters given by ethtool to
  * return driver information.
@@ -3191,9 +3039,9 @@ static void s2io_ethtool_gdrvinfo(struct
 
 /**
  *  s2io_ethtool_gregs - dumps the entire space of Xfame into the buffer.
- *  @sp: private member of the device structure, which is a pointer to the 
+ *  @sp: private member of the device structure, which is a pointer to the
  *  s2io_nic structure.
- *  @regs : pointer to the structure with parameters given by ethtool for 
+ *  @regs : pointer to the structure with parameters given by ethtool for
  *  dumping the registers.
  *  @reg_space: The input argumnet into which all the registers are dumped.
  *  Description:
@@ -3222,11 +3070,11 @@ static void s2io_ethtool_gregs(struct ne
 
 /**
  *  s2io_phy_id  - timer function that alternates adapter LED.
- *  @data : address of the private member of the device structure, which 
+ *  @data : address of the private member of the device structure, which
  *  is a pointer to the s2io_nic structure, provided as an u32.
- * Description: This is actually the timer function that alternates the 
- * adapter LED bit of the adapter control bit to set/reset every time on 
- * invocation. The timer is set for 1/2 a second, hence tha NIC blinks 
+ * Description: This is actually the timer function that alternates the
+ * adapter LED bit of the adapter control bit to set/reset every time on
+ * invocation. The timer is set for 1/2 a second, hence tha NIC blinks
  *  once every second.
 */
 static void s2io_phy_id(unsigned long data)
@@ -3254,12 +3102,12 @@ static void s2io_phy_id(unsigned long da
  * s2io_ethtool_idnic - To physically identify the nic on the system.
  * @sp : private member of the device structure, which is a pointer to the
  * s2io_nic structure.
- * @id : pointer to the structure with identification parameters given by 
+ * @id : pointer to the structure with identification parameters given by
  * ethtool.
  * Description: Used to physically identify the NIC on the system.
- * The Link LED will blink for a time specified by the user for 
+ * The Link LED will blink for a time specified by the user for
  * identification.
- * NOTE: The Link has to be Up to be able to blink the LED. Hence 
+ * NOTE: The Link has to be Up to be able to blink the LED. Hence
  * identification is possible only if it's link is up.
  * Return value:
  * int , returns 0 on success
@@ -3289,9 +3137,9 @@ static int s2io_ethtool_idnic(struct net
 	}
 	mod_timer(&sp->id_timer, jiffies);
 	if (data)
-		msleep(data * 1000);
+		msleep_interruptible(data * HZ);
 	else
-		msleep(0xFFFFFFFF);
+		msleep_interruptible(MAX_FLICKER_TIME);
 	del_timer_sync(&sp->id_timer);
 
 	if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {
@@ -3304,7 +3152,8 @@ static int s2io_ethtool_idnic(struct net
 
 /**
  * s2io_ethtool_getpause_data -Pause frame frame generation and reception.
- * @sp : private member of the device structure, which is a pointer to the  * s2io_nic structure.
+ * @sp : private member of the device structure, which is a pointer to the
+ *	s2io_nic structure.
  * @ep : pointer to the structure with pause parameters given by ethtool.
  * Description:
  * Returns the Pause frame generation and reception capability of the NIC.
@@ -3328,7 +3177,7 @@ static void s2io_ethtool_getpause_data(s
 
 /**
  * s2io_ethtool_setpause_data -  set/reset pause frame generation.
- * @sp : private member of the device structure, which is a pointer to the 
+ * @sp : private member of the device structure, which is a pointer to the
  *      s2io_nic structure.
  * @ep : pointer to the structure with pause parameters given by ethtool.
  * Description:
@@ -3339,7 +3188,7 @@ static void s2io_ethtool_getpause_data(s
  */
 
 static int s2io_ethtool_setpause_data(struct net_device *dev,
-				      struct ethtool_pauseparam *ep)
+			       struct ethtool_pauseparam *ep)
 {
 	u64 val64;
 	nic_t *sp = dev->priv;
@@ -3360,13 +3209,13 @@ static int s2io_ethtool_setpause_data(st
 
 /**
  * read_eeprom - reads 4 bytes of data from user given offset.
- * @sp : private member of the device structure, which is a pointer to the 
+ * @sp : private member of the device structure, which is a pointer to the
  *      s2io_nic structure.
  * @off : offset at which the data must be written
  * @data : Its an output parameter where the data read at the given
- * 	offset is stored.
+ *	offset is stored.
  * Description:
- * Will read 4 bytes of data from the user given offset and return the 
+ * Will read 4 bytes of data from the user given offset and return the
  * read data.
  * NOTE: Will allow to read only part of the EEPROM visible through the
  *   I2C bus.
@@ -3407,7 +3256,7 @@ static int read_eeprom(nic_t * sp, int o
  *       s2io_nic structure.
  *  @off : offset at which the data must be written
  *  @data : The data that is to be written
- *  @cnt : Number of bytes of the data that are actually to be written into 
+ *  @cnt : Number of bytes of the data that are actually to be written into
  *  the Eeprom. (max of 3)
  * Description:
  *  Actually writes the relevant part of the data value into the Eeprom
@@ -3444,7 +3293,7 @@ static int write_eeprom(nic_t * sp, int 
 /**
  *  s2io_ethtool_geeprom  - reads the value stored in the Eeprom.
  *  @sp : private member of the device structure, which is a pointer to the *       s2io_nic structure.
- *  @eeprom : pointer to the user level structure provided by ethtool, 
+ *  @eeprom : pointer to the user level structure provided by ethtool,
  *  containing all relevant information.
  *  @data_buf : user defined value to be written into Eeprom.
  *  Description: Reads the values stored in the Eeprom at given offset
@@ -3455,7 +3304,7 @@ static int write_eeprom(nic_t * sp, int 
  */
 
 static int s2io_ethtool_geeprom(struct net_device *dev,
-				struct ethtool_eeprom *eeprom, u8 * data_buf)
+			 struct ethtool_eeprom *eeprom, u8 * data_buf)
 {
 	u32 data, i, valid;
 	nic_t *sp = dev->priv;
@@ -3480,7 +3329,7 @@ static int s2io_ethtool_geeprom(struct n
  *  s2io_ethtool_seeprom - tries to write the user provided value in Eeprom
  *  @sp : private member of the device structure, which is a pointer to the
  *  s2io_nic structure.
- *  @eeprom : pointer to the user level structure provided by ethtool, 
+ *  @eeprom : pointer to the user level structure provided by ethtool,
  *  containing all relevant information.
  *  @data_buf ; user defined value to be written into Eeprom.
  *  Description:
@@ -3528,8 +3377,8 @@ static int s2io_ethtool_seeprom(struct n
 }
 
 /**
- * s2io_register_test - reads and writes into all clock domains. 
- * @sp : private member of the device structure, which is a pointer to the 
+ * s2io_register_test - reads and writes into all clock domains.
+ * @sp : private member of the device structure, which is a pointer to the
  * s2io_nic structure.
  * @data : variable that returns the result of each of the test conducted b
  * by the driver.
@@ -3546,8 +3395,8 @@ static int s2io_register_test(nic_t * sp
 	u64 val64 = 0;
 	int fail = 0;
 
-	val64 = readq(&bar0->pcc_enable);
-	if (val64 != 0xff00000000000000ULL) {
+	val64 = readq(&bar0->pif_rd_swapper_fb);
+	if (val64 != 0x123456789abcdefULL) {
 		fail = 1;
 		DBG_PRINT(INFO_DBG, "Read Test level 1 fails\n");
 	}
@@ -3591,13 +3440,13 @@ static int s2io_register_test(nic_t * sp
 }
 
 /**
- * s2io_eeprom_test - to verify that EEprom in the xena can be programmed. 
+ * s2io_eeprom_test - to verify that EEprom in the xena can be programmed.
  * @sp : private member of the device structure, which is a pointer to the
  * s2io_nic structure.
  * @data:variable that returns the result of each of the test conducted by
  * the driver.
  * Description:
- * Verify that EEPROM in the xena can be programmed using I2C_CONTROL 
+ * Verify that EEPROM in the xena can be programmed using I2C_CONTROL
  * register.
  * Return value:
  * 0 on success.
@@ -3662,14 +3511,14 @@ static int s2io_eeprom_test(nic_t * sp, 
 
 /**
  * s2io_bist_test - invokes the MemBist test of the card .
- * @sp : private member of the device structure, which is a pointer to the 
+ * @sp : private member of the device structure, which is a pointer to the
  * s2io_nic structure.
- * @data:variable that returns the result of each of the test conducted by 
+ * @data:variable that returns the result of each of the test conducted by
  * the driver.
  * Description:
  * This invokes the MemBist test of the card. We give around
  * 2 secs time for the Test to complete. If it's still not complete
- * within this peiod, we consider that the test failed. 
+ * within this peiod, we consider that the test failed.
  * Return value:
  * 0 on success and -1 on failure.
  */
@@ -3698,13 +3547,13 @@ static int s2io_bist_test(nic_t * sp, ui
 }
 
 /**
- * s2io-link_test - verifies the link state of the nic  
- * @sp ; private member of the device structure, which is a pointer to the 
+ * s2io-link_test - verifies the link state of the nic
+ * @sp ; private member of the device structure, which is a pointer to the
  * s2io_nic structure.
  * @data: variable that returns the result of each of the test conducted by
  * the driver.
  * Description:
- * The function verifies the link state of the NIC and updates the input 
+ * The function verifies the link state of the NIC and updates the input
  * argument 'data' appropriately.
  * Return value:
  * 0 on success.
@@ -3723,13 +3572,13 @@ static int s2io_link_test(nic_t * sp, ui
 }
 
 /**
- * s2io_rldram_test - offline test for access to the RldRam chip on the NIC 
- * @sp - private member of the device structure, which is a pointer to the  
+ * s2io_rldram_test - offline test for access to the RldRam chip on the NIC
+ * @sp - private member of the device structure, which is a pointer to the
  * s2io_nic structure.
- * @data - variable that returns the result of each of the test 
+ * @data - variable that returns the result of each of the test
  * conducted by the driver.
  * Description:
- *  This is one of the offline test that tests the read and write 
+ *  This is one of the offline test that tests the read and write
  *  access to the RldRam chip on the NIC.
  * Return value:
  *  0 on success.
@@ -3834,7 +3683,7 @@ static int s2io_rldram_test(nic_t * sp, 
  *  s2io_nic structure.
  *  @ethtest : pointer to a ethtool command specific structure that will be
  *  returned to the user.
- *  @data : variable that returns the result of each of the test 
+ *  @data : variable that returns the result of each of the test
  * conducted by the driver.
  * Description:
  *  This function conducts 6 tests ( 4 offline and 2 online) to determine
@@ -3852,23 +3701,18 @@ static void s2io_ethtool_test(struct net
 
 	if (ethtest->flags == ETH_TEST_FL_OFFLINE) {
 		/* Offline Tests. */
-		if (orig_state) {
+		if (orig_state)
 			s2io_close(sp->dev);
-			s2io_set_swapper(sp);
-		} else
-			s2io_set_swapper(sp);
 
 		if (s2io_register_test(sp, &data[0]))
 			ethtest->flags |= ETH_TEST_FL_FAILED;
 
 		s2io_reset(sp);
-		s2io_set_swapper(sp);
 
 		if (s2io_rldram_test(sp, &data[3]))
 			ethtest->flags |= ETH_TEST_FL_FAILED;
 
 		s2io_reset(sp);
-		s2io_set_swapper(sp);
 
 		if (s2io_eeprom_test(sp, &data[1]))
 			ethtest->flags |= ETH_TEST_FL_FAILED;
@@ -3952,20 +3796,19 @@ static void s2io_get_ethtool_stats(struc
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_err_tcp);
 }
 
-static int s2io_ethtool_get_regs_len(struct net_device *dev)
+int s2io_ethtool_get_regs_len(struct net_device *dev)
 {
 	return (XENA_REG_SPACE);
 }
 
 
-static u32 s2io_ethtool_get_rx_csum(struct net_device * dev)
+u32 s2io_ethtool_get_rx_csum(struct net_device * dev)
 {
 	nic_t *sp = dev->priv;
 
 	return (sp->rx_csum);
 }
-
-static int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
+int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
 {
 	nic_t *sp = dev->priv;
 
@@ -3976,19 +3819,17 @@ static int s2io_ethtool_set_rx_csum(stru
 
 	return 0;
 }
-
-static int s2io_get_eeprom_len(struct net_device *dev)
+int s2io_get_eeprom_len(struct net_device *dev)
 {
 	return (XENA_EEPROM_SPACE);
 }
 
-static int s2io_ethtool_self_test_count(struct net_device *dev)
+int s2io_ethtool_self_test_count(struct net_device *dev)
 {
 	return (S2IO_TEST_LEN);
 }
-
-static void s2io_ethtool_get_strings(struct net_device *dev,
-				     u32 stringset, u8 * data)
+void s2io_ethtool_get_strings(struct net_device *dev,
+			      u32 stringset, u8 * data)
 {
 	switch (stringset) {
 	case ETH_SS_TEST:
@@ -3999,13 +3840,12 @@ static void s2io_ethtool_get_strings(str
 		       sizeof(ethtool_stats_keys));
 	}
 }
-
 static int s2io_ethtool_get_stats_count(struct net_device *dev)
 {
 	return (S2IO_STAT_LEN);
 }
 
-static int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
+int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
 {
 	if (data)
 		dev->features |= NETIF_F_IP_CSUM;
@@ -4047,21 +3887,18 @@ static struct ethtool_ops netdev_ethtool
 };
 
 /**
- *  s2io_ioctl - Entry point for the Ioctl 
+ *  s2io_ioctl - Entry point for the Ioctl
  *  @dev :  Device pointer.
  *  @ifr :  An IOCTL specefic structure, that can contain a pointer to
  *  a proprietary structure used to pass information to the driver.
  *  @cmd :  This is used to distinguish between the different commands that
  *  can be passed to the IOCTL functions.
  *  Description:
- *  This function has support for ethtool, adding multiple MAC addresses on 
- *  the NIC and some DBG commands for the util tool.
- *  Return value:
- *  Currently the IOCTL supports no operations, hence by default this
- *  function returns OP NOT SUPPORTED value.
+ *  Currently there are no special functionality supported in IOCTL, hence
+ *  function always return EOPNOTSUPPORTED
  */
 
-static int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	return -EOPNOTSUPP;
 }
@@ -4077,7 +3914,7 @@ static int s2io_ioctl(struct net_device 
  *   file on failure.
  */
 
-static int s2io_change_mtu(struct net_device *dev, int new_mtu)
+int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
@@ -4085,7 +3922,7 @@ static int s2io_change_mtu(struct net_de
 
 	if (netif_running(dev)) {
 		DBG_PRINT(ERR_DBG, "%s: Must be stopped to ", dev->name);
-		DBG_PRINT(ERR_DBG, "change its MTU \n");
+		DBG_PRINT(ERR_DBG, "change its MTU\n");
 		return -EBUSY;
 	}
 
@@ -4109,9 +3946,9 @@ static int s2io_change_mtu(struct net_de
  *  @dev_adr : address of the device structure in dma_addr_t format.
  *  Description:
  *  This is the tasklet or the bottom half of the ISR. This is
- *  an extension of the ISR which is scheduled by the scheduler to be run 
+ *  an extension of the ISR which is scheduled by the scheduler to be run
  *  when the load on the CPU is low. All low priority tasks of the ISR can
- *  be pushed into the tasklet. For now the tasklet is used only to 
+ *  be pushed into the tasklet. For now the tasklet is used only to
  *  replenish the Rx buffers in the Rx buffer descriptors.
  *  Return value:
  *  void.
@@ -4167,14 +4004,14 @@ static void s2io_set_link(unsigned long 
 	}
 
 	subid = nic->pdev->subsystem_device;
-	/* 
-	 * Allow a small delay for the NICs self initiated 
+	/*
+	 * Allow a small delay for the NICs self initiated
 	 * cleanup to complete.
 	 */
 	msleep(100);
 
 	val64 = readq(&bar0->adapter_status);
-	if (verify_xena_quiescence(val64, nic->device_enabled_once)) {
+	if (verify_xena_quiescence(nic, val64, nic->device_enabled_once)) {
 		if (LINK_IS_UP(val64)) {
 			val64 = readq(&bar0->adapter_control);
 			val64 |= ADAPTER_CNTL_EN;
@@ -4225,8 +4062,9 @@ static void s2io_card_down(nic_t * sp)
 	register u64 val64 = 0;
 
 	/* If s2io_set_link task is executing, wait till it completes. */
-	while (test_and_set_bit(0, &(sp->link_state)))
+	while (test_and_set_bit(0, &(sp->link_state))) {
 		msleep(50);
+	}
 	atomic_set(&sp->card_state, CARD_DOWN);
 
 	/* disable Tx and Rx traffic on the NIC */
@@ -4238,7 +4076,7 @@ static void s2io_card_down(nic_t * sp)
 	/* Check if the device is Quiescent and then Reset the NIC */
 	do {
 		val64 = readq(&bar0->adapter_status);
-		if (verify_xena_quiescence(val64, sp->device_enabled_once)) {
+		if (verify_xena_quiescence(sp, val64, sp->device_enabled_once)) {
 			break;
 		}
 
@@ -4277,8 +4115,8 @@ static int s2io_card_up(nic_t * sp)
 		return -ENODEV;
 	}
 
-	/* 
-	 * Initializing the Rx buffers. For now we are considering only 1 
+	/*
+	 * Initializing the Rx buffers. For now we are considering only 1
 	 * Rx ring and initializing buffers into 30 Rx blocks
 	 */
 	mac_control = &sp->mac_control;
@@ -4316,12 +4154,12 @@ static int s2io_card_up(nic_t * sp)
 	return 0;
 }
 
-/** 
+/**
  * s2io_restart_nic - Resets the NIC.
  * @data : long pointer to the device private structure
  * Description:
  * This function is scheduled to be run by the s2io_tx_watchdog
- * function after 0.5 secs to reset the NIC. The idea is to reduce 
+ * function after 0.5 secs to reset the NIC. The idea is to reduce
  * the run time of the watch dog routine which is run holding a
  * spin lock.
  */
@@ -4339,10 +4177,11 @@ static void s2io_restart_nic(unsigned lo
 	netif_wake_queue(dev);
 	DBG_PRINT(ERR_DBG, "%s: was reset by Tx watchdog timer\n",
 		  dev->name);
+
 }
 
-/** 
- *  s2io_tx_watchdog - Watchdog for transmit side. 
+/**
+ *  s2io_tx_watchdog - Watchdog for transmit side.
  *  @dev : Pointer to net device structure
  *  Description:
  *  This function is triggered if the Tx Queue is stopped
@@ -4370,7 +4209,7 @@ static void s2io_tx_watchdog(struct net_
  *   @len : length of the packet
  *   @cksum : FCS checksum of the frame.
  *   @ring_no : the ring from which this RxD was extracted.
- *   Description: 
+ *   Description:
  *   This function is called by the Tx interrupt serivce routine to perform
  *   some OS related operations on the SKB before passing it to the upper
  *   layers. It mainly checks if the checksum is OK, if so adds it to the
@@ -4380,35 +4219,63 @@ static void s2io_tx_watchdog(struct net_
  *   Return value:
  *   SUCCESS on success and -1 on failure.
  */
-#ifndef CONFIG_2BUFF_MODE
-static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no)
-#else
-static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
-			  buffAdd_t * ba)
-#endif
+static int rx_osm_handler(ring_info_t *ring_data, RxD_t * rxdp)
 {
+	nic_t *sp = ring_data->nic;
 	struct net_device *dev = (struct net_device *) sp->dev;
-	struct sk_buff *skb =
-	    (struct sk_buff *) ((unsigned long) rxdp->Host_Control);
+	struct sk_buff *skb = (struct sk_buff *)
+		((unsigned long) rxdp->Host_Control);
+	int ring_no = ring_data->ring_no;
 	u16 l3_csum, l4_csum;
 #ifdef CONFIG_2BUFF_MODE
-	int buf0_len, buf2_len;
+	int buf0_len = RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
+	int buf2_len = RXD_GET_BUFFER2_SIZE(rxdp->Control_2);
+	int get_block = ring_data->rx_curr_get_info.block_index;
+	int get_off = ring_data->rx_curr_get_info.offset;
+	buffAdd_t *ba = &ring_data->ba[get_block][get_off];
 	unsigned char *buff;
+#else
+	u16 len = (u16) ((RXD_GET_BUFFER0_SIZE(rxdp->Control_2)) >> 48);;
 #endif
+	skb->dev = dev;
+	if (rxdp->Control_1 & RXD_T_CODE) {
+		unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
+		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
+			  dev->name, err);
+	}
 
-	l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
-	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && (sp->rx_csum)) {
+	/* Updating statistics */
+	rxdp->Host_Control = 0;
+	sp->rx_pkt_count++;
+	sp->stats.rx_packets++;
+#ifndef CONFIG_2BUFF_MODE
+	sp->stats.rx_bytes += len;
+#else
+	sp->stats.rx_bytes += buf0_len + buf2_len;
+#endif
+
+#ifndef CONFIG_2BUFF_MODE
+	skb_put(skb, len);
+#else
+	buff = skb_push(skb, buf0_len);
+	memcpy(buff, ba->ba_0, buf0_len);
+	skb_put(skb, buf2_len);
+#endif
+
+	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) &&
+	    (sp->rx_csum)) {
+		l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
 		l4_csum = RXD_GET_L4_CKSUM(rxdp->Control_1);
 		if ((l3_csum == L3_CKSUM_OK) && (l4_csum == L4_CKSUM_OK)) {
-			/* 
+			/*
 			 * NIC verifies if the Checksum of the received
 			 * frame is Ok or not and accordingly returns
 			 * a flag in the RxD.
 			 */
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		} else {
-			/* 
-			 * Packet with erroneous checksum, let the 
+			/*
+			 * Packet with erroneous checksum, let the
 			 * upper layers deal with it.
 			 */
 			skb->ip_summed = CHECKSUM_NONE;
@@ -4417,44 +4284,14 @@ static int rx_osm_handler(nic_t * sp, Rx
 		skb->ip_summed = CHECKSUM_NONE;
 	}
 
-	if (rxdp->Control_1 & RXD_T_CODE) {
-		unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
-		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
-			  dev->name, err);
-	}
-#ifdef CONFIG_2BUFF_MODE
-	buf0_len = RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
-	buf2_len = RXD_GET_BUFFER2_SIZE(rxdp->Control_2);
-#endif
-
-	skb->dev = dev;
-#ifndef CONFIG_2BUFF_MODE
-	skb_put(skb, len);
-	skb->protocol = eth_type_trans(skb, dev);
-#else
-	buff = skb_push(skb, buf0_len);
-	memcpy(buff, ba->ba_0, buf0_len);
-	skb_put(skb, buf2_len);
 	skb->protocol = eth_type_trans(skb, dev);
-#endif
-
 #ifdef CONFIG_S2IO_NAPI
 	netif_receive_skb(skb);
 #else
 	netif_rx(skb);
 #endif
-
 	dev->last_rx = jiffies;
-	sp->rx_pkt_count++;
-	sp->stats.rx_packets++;
-#ifndef CONFIG_2BUFF_MODE
-	sp->stats.rx_bytes += len;
-#else
-	sp->stats.rx_bytes += buf0_len + buf2_len;
-#endif
-
 	atomic_dec(&sp->rx_bufs_left[ring_no]);
-	rxdp->Host_Control = 0;
 	return SUCCESS;
 }
 
@@ -4465,13 +4302,13 @@ static int rx_osm_handler(nic_t * sp, Rx
  *  @link : inidicates whether link is UP/DOWN.
  *  Description:
  *  This function stops/starts the Tx queue depending on whether the link
- *  status of the NIC is is down or up. This is called by the Alarm 
- *  interrupt handler whenever a link change interrupt comes up. 
+ *  status of the NIC is is down or up. This is called by the Alarm
+ *  interrupt handler whenever a link change interrupt comes up.
  *  Return value:
  *  void.
  */
 
-static void s2io_link(nic_t * sp, int link)
+void s2io_link(nic_t * sp, int link)
 {
 	struct net_device *dev = (struct net_device *) sp->dev;
 
@@ -4488,8 +4325,25 @@ static void s2io_link(nic_t * sp, int li
 }
 
 /**
- *  s2io_init_pci -Initialization of PCI and PCI-X configuration registers . 
- *  @sp : private member of the device structure, which is a pointer to the 
+ *  get_xena_rev_id - to identify revision ID of xena.
+ *  @pdev : PCI Dev structure
+ *  Description:
+ *  Function to identify the Revision ID of xena.
+ *  Return value:
+ *  returns the revision ID of the device.
+ */
+
+int get_xena_rev_id(struct pci_dev *pdev)
+{
+	u8 id = 0;
+	int ret;
+	ret = pci_read_config_byte(pdev, PCI_REVISION_ID, (u8 *) & id);
+	return id;
+}
+
+/**
+ *  s2io_init_pci -Initialization of PCI and PCI-X configuration registers .
+ *  @sp : private member of the device structure, which is a pointer to the
  *  s2io_nic structure.
  *  Description:
  *  This function initializes a few of the PCI and PCI-X configuration registers
@@ -4500,15 +4354,15 @@ static void s2io_link(nic_t * sp, int li
 
 static void s2io_init_pci(nic_t * sp)
 {
-	u16 pci_cmd = 0;
+	u16 pci_cmd = 0, pcix_cmd = 0;
 
 	/* Enable Data Parity Error Recovery in PCI-X command register. */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			     &(sp->pcix_cmd));
+			     &(pcix_cmd));
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			      (sp->pcix_cmd | 1));
+			      (pcix_cmd | 1));
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			     &(sp->pcix_cmd));
+			     &(pcix_cmd));
 
 	/* Set the PErr Response bit in PCI command register. */
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
@@ -4517,34 +4371,36 @@ static void s2io_init_pci(nic_t * sp)
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
 
 	/* Set MMRB count to 1024 in PCI-X Command register. */
-	sp->pcix_cmd &= 0xFFF3;
-	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER, (sp->pcix_cmd | (0x1 << 2)));	/* MMRBC 1K */
+	pcix_cmd &= 0xFFF3;
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
+			      (pcix_cmd | (0x1 << 2)));	/* MMRBC 1K */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			     &(sp->pcix_cmd));
+			     &(pcix_cmd));
 
 	/*  Setting Maximum outstanding splits based on system type. */
-	sp->pcix_cmd &= 0xFF8F;
-
-	sp->pcix_cmd |= XENA_MAX_OUTSTANDING_SPLITS(0x1);	/* 2 splits. */
+	pcix_cmd &= 0xFF8F;
+	pcix_cmd |= XENA_MAX_OUTSTANDING_SPLITS(0x1);	/* 2 splits. */
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			      sp->pcix_cmd);
+			      pcix_cmd);
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			     &(sp->pcix_cmd));
+			     &(pcix_cmd));
+
 	/* Forcibly disabling relaxed ordering capability of the card. */
-	sp->pcix_cmd &= 0xfffd;
+	pcix_cmd &= 0xfffd;
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			      sp->pcix_cmd);
+			      pcix_cmd);
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			     &(sp->pcix_cmd));
+			     &(pcix_cmd));
 }
 
 MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@neterion.com>");
 MODULE_LICENSE("GPL");
 module_param(tx_fifo_num, int, 0);
-module_param_array(tx_fifo_len, int, NULL, 0);
 module_param(rx_ring_num, int, 0);
-module_param_array(rx_ring_sz, int, NULL, 0);
+module_param_array(tx_fifo_len, uint, NULL, 0);
+module_param_array(rx_ring_sz, uint, NULL, 0);
 module_param(Stats_refresh_time, int, 0);
+module_param_array(rts_frm_len, uint, NULL, 0);
 module_param(rmac_pause_time, int, 0);
 module_param(mc_pause_threshold_q0q3, int, 0);
 module_param(mc_pause_threshold_q4q7, int, 0);
@@ -4554,15 +4410,16 @@ module_param(rmac_util_period, int, 0);
 #ifndef CONFIG_S2IO_NAPI
 module_param(indicate_max_pkts, int, 0);
 #endif
+
 /**
- *  s2io_init_nic - Initialization of the adapter . 
+ *  s2io_init_nic - Initialization of the adapter .
  *  @pdev : structure containing the PCI related information of the device.
  *  @pre: List of PCI devices supported by the driver listed in s2io_tbl.
  *  Description:
  *  The function initializes an adapter identified by the pci_dec structure.
- *  All OS related initialization including memory and device structure and 
- *  initlaization of the device private variable is done. Also the swapper 
- *  control register is initialized to enable read and write into the I/O 
+ *  All OS related initialization including memory and device structure and
+ *  initlaization of the device private variable is done. Also the swapper
+ *  control register is initialized to enable read and write into the I/O
  *  registers of the device.
  *  Return value:
  *  returns 0 on success and negative on failure.
@@ -4573,7 +4430,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 {
 	nic_t *sp;
 	struct net_device *dev;
-	char *dev_name = "S2IO 10GE NIC";
 	int i, j, ret;
 	int dma_flag = FALSE;
 	u32 mac_up, mac_down;
@@ -4583,9 +4439,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	mac_info_t *mac_control;
 	struct config_param *config;
 
-
-	DBG_PRINT(ERR_DBG, "Loading S2IO driver with %s\n",
-		s2io_driver_version);
+#ifdef CONFIG_S2IO_NAPI
+	DBG_PRINT(ERR_DBG, "NAPI support has been enabled\n");
+#endif
 
 	if ((ret = pci_enable_device(pdev))) {
 		DBG_PRINT(ERR_DBG,
@@ -4596,7 +4452,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");
 		dma_flag = TRUE;
-
 		if (pci_set_consistent_dma_mask
 		    (pdev, 0xffffffffffffffffULL)) {
 			DBG_PRINT(ERR_DBG,
@@ -4636,21 +4491,17 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	memset(sp, 0, sizeof(nic_t));
 	sp->dev = dev;
 	sp->pdev = pdev;
-	sp->vendor_id = pdev->vendor;
-	sp->device_id = pdev->device;
 	sp->high_dma_flag = dma_flag;
-	sp->irq = pdev->irq;
 	sp->device_enabled_once = FALSE;
-	strcpy(sp->name, dev_name);
 
 	/* Initialize some PCI/PCI-X fields of the NIC. */
 	s2io_init_pci(sp);
 
-	/* 
+	/*
 	 * Setting the device configuration parameters.
-	 * Most of these parameters can be specified by the user during 
-	 * module insertion as they are module loadable parameters. If 
-	 * these parameters are not not specified during load time, they 
+	 * Most of these parameters can be specified by the user during
+	 * module insertion as they are module loadable parameters. If
+	 * these parameters are not not specified during load time, they
 	 * are initialized with default values.
 	 */
 	mac_control = &sp->mac_control;
@@ -4664,6 +4515,10 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		config->tx_cfg[i].fifo_priority = i;
 	}
 
+	/* mapping the QoS priority to the configured fifos */
+	for (i = 0; i < MAX_TX_FIFOS; i++)
+		config->fifo_mapping[i] = fifo_map[config->tx_fifo_num][i];
+
 	config->tx_intr_type = TXD_INT_TYPE_UTILZ;
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		config->tx_cfg[i].f_no_snoop =
@@ -4744,13 +4599,14 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	dev->do_ioctl = &s2io_ioctl;
 	dev->change_mtu = &s2io_change_mtu;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
+
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
 	 * mac address will be set every time dev->open() is called
 	 */
-#ifdef CONFIG_S2IO_NAPI
+#if defined(CONFIG_S2IO_NAPI)
 	dev->poll = s2io_poll;
-	dev->weight = 90;
+	dev->weight = 32;
 #endif
 
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
@@ -4777,22 +4633,14 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		goto set_swap_failed;
 	}
 
-	/* Fix for all "FFs" MAC address problems observed on Alpha platforms */
+	/*
+	 * Fix for all "FFs" MAC address problems observed on
+	 * Alpha platforms
+	 */
 	fix_mac_address(sp);
 	s2io_reset(sp);
 
 	/*
-	 * Setting swapper control on the NIC, so the MAC address can be read.
-	 */
-	if (s2io_set_swapper(sp)) {
-		DBG_PRINT(ERR_DBG,
-			  "%s: S2IO: swapper settings are wrong\n",
-			  dev->name);
-		ret = -EAGAIN;
-		goto set_swap_failed;
-	}
-
-	/*  
 	 * MAC address initialization.
 	 * For now only one mac address will be read and used.
 	 */
@@ -4829,23 +4677,22 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);
 
 	/*
-	 * Initialize the tasklet status and link state flags 
+	 * Initialize the tasklet status and link state flags
 	 * and the card statte parameter
 	 */
 	atomic_set(&(sp->card_state), 0);
 	sp->tasklet_status = 0;
 	sp->link_state = 0;
 
-
 	/* Initialize spinlocks */
 	spin_lock_init(&sp->tx_lock);
 #ifndef CONFIG_S2IO_NAPI
 	spin_lock_init(&sp->put_lock);
 #endif
 
-	/* 
-	 * SXE-002: Configure link and activity LED to init state 
-	 * on driver load. 
+	/*
+	 * SXE-002: Configure link and activity LED to init state
+	 * on driver load.
 	 */
 	subid = sp->pdev->subsystem_device;
 	if ((subid & 0xFF) >= 0x07) {
@@ -4865,9 +4712,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		goto register_failed;
 	}
 
-	/* 
-	 * Make Link state as off at this point, when the Link change 
-	 * interrupt comes the state will be automatically changed to 
+	/*
+	 * Make Link state as off at this point, when the Link change
+	 * interrupt comes the state will be automatically changed to
 	 * the right state.
 	 */
 	netif_carrier_off(dev);
@@ -4892,11 +4739,11 @@ s2io_init_nic(struct pci_dev *pdev, cons
 }
 
 /**
- * s2io_rem_nic - Free the PCI device 
+ * s2io_rem_nic - Free the PCI device
  * @pdev: structure containing the PCI related information of the device.
- * Description: This function is called by the Pci subsystem to release a 
+ * Description: This function is called by the Pci subsystem to release a
  * PCI device and free up all resource held up by the device. This could
- * be in response to a Hot plug event or when the driver is to be removed 
+ * be in response to a Hot plug event or when the driver is to be removed
  * from memory.
  */
 
@@ -4920,7 +4767,6 @@ static void __devexit s2io_rem_nic(struc
 	pci_disable_device(pdev);
 	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
-
 	free_netdev(dev);
 }
 
@@ -4936,11 +4782,11 @@ int __init s2io_starter(void)
 }
 
 /**
- * s2io_closer - Cleanup routine for the driver 
+ * s2io_closer - Cleanup routine for the driver
  * Description: This function is the cleanup routine for the driver. It unregist * ers the driver.
  */
 
-static void s2io_closer(void)
+void s2io_closer(void)
 {
 	pci_unregister_driver(&s2io_driver);
 	DBG_PRINT(INIT_DBG, "cleanup done\n");
diff -urpN vanilla_kernel/drivers/net/s2io.h linux-2.6.12-rc6/drivers/net/s2io.h
--- vanilla_kernel/drivers/net/s2io.h	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io.h	2005-06-27 06:21:32.000000000 -0700
@@ -31,6 +31,9 @@
 #define SUCCESS 0
 #define FAILURE -1
 
+/* Maximum time to flicker LED when asked to identify NIC using ethtool */
+#define MAX_FLICKER_TIME	60000 /* 60 Secs */
+
 /* Maximum outstanding splits to be configured into xena. */
 typedef enum xena_max_outstanding_splits {
 	XENA_ONE_SPLIT_TRANSACTION = 0,
@@ -45,10 +48,10 @@ typedef enum xena_max_outstanding_splits
 #define XENA_MAX_OUTSTANDING_SPLITS(n) (n << 4)
 
 /*  OS concerned variables and constants */
-#define WATCH_DOG_TIMEOUT   	5*HZ
-#define EFILL       			0x1234
-#define ALIGN_SIZE  			127
-#define	PCIX_COMMAND_REGISTER	0x62
+#define WATCH_DOG_TIMEOUT		15*HZ
+#define EFILL				0x1234
+#define ALIGN_SIZE			127
+#define	PCIX_COMMAND_REGISTER		0x62
 
 /*
  * Debug related variables.
@@ -61,7 +64,7 @@ typedef enum xena_max_outstanding_splits
 #define	INTR_DBG	4
 
 /* Global variable that defines the present debug level of the driver. */
-static int debug_level = ERR_DBG;	/* Default level. */
+int debug_level = ERR_DBG;	/* Default level. */
 
 /* DEBUG message print. */
 #define DBG_PRINT(dbg_level, args...)  if(!(debug_level<dbg_level)) printk(args)
@@ -71,6 +74,12 @@ static int debug_level = ERR_DBG;	/* Def
 #define L4_CKSUM_OK 0xFFFF
 #define S2IO_JUMBO_SIZE 9600
 
+/* Driver statistics maintained by driver */
+typedef struct {
+	unsigned long long single_ecc_errs;
+	unsigned long long double_ecc_errs;
+} swStat_t;
+
 /* The statistics block of Xena */
 typedef struct stat_block {
 /* Tx MAC statistics counters. */
@@ -188,10 +197,26 @@ typedef struct stat_block {
 	u32 txf_rd_cnt;
 } StatInfo_t;
 
-/* Structures representing different init time configuration
+/*
+ * Structures representing different init time configuration
  * parameters of the NIC.
  */
 
+#define MAX_TX_FIFOS 8
+#define MAX_RX_RINGS 8
+
+/* FIFO mappings for all possible number of fifos configured */
+int fifo_map[][MAX_TX_FIFOS] = {
+	{0, 0, 0, 0, 0, 0, 0, 0},
+	{0, 0, 0, 0, 1, 1, 1, 1},
+	{0, 0, 0, 1, 1, 1, 2, 2},
+	{0, 0, 1, 1, 2, 2, 3, 3},
+	{0, 0, 1, 1, 2, 2, 3, 4},
+	{0, 0, 1, 1, 2, 3, 4, 5},
+	{0, 0, 1, 2, 3, 4, 5, 6},
+	{0, 1, 2, 3, 4, 5, 6, 7},
+};
+
 /* Maintains Per FIFO related information. */
 typedef struct tx_fifo_config {
 #define	MAX_AVAILABLE_TXDS	8192
@@ -237,14 +262,14 @@ typedef struct rx_ring_config {
 #define NO_SNOOP_RXD_BUFFER         0x02
 } rx_ring_config_t;
 
-/* This structure provides contains values of the tunable parameters 
- * of the H/W 
+/* This structure provides contains values of the tunable parameters
+ * of the H/W
  */
 struct config_param {
 /* Tx Side */
 	u32 tx_fifo_num;	/*Number of Tx FIFOs */
-#define MAX_TX_FIFOS 8
 
+	u8 fifo_mapping[MAX_TX_FIFOS];
 	tx_fifo_config_t tx_cfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */
 	u32 max_txds;		/*Max no. of Tx buffer descriptor per TxDL */
 	u64 tx_intr_type;
@@ -252,7 +277,6 @@ struct config_param {
 
 /* Rx Side */
 	u32 rx_ring_num;	/*Number of receive rings */
-#define MAX_RX_RINGS 8
 #define MAX_RX_BLOCKS_PER_RING  150
 
 	rx_ring_config_t rx_cfg[MAX_RX_RINGS];	/*Per-Rx Ring config */
@@ -269,6 +293,7 @@ struct config_param {
 #define MAX_PYLD_JUMBO              9600
 #define MAX_MTU_JUMBO               (MAX_PYLD_JUMBO+18)
 #define MAX_MTU_JUMBO_VLAN          (MAX_PYLD_JUMBO+22)
+	u16 bus_speed;
 };
 
 /* Structure representing MAC Addrs */
@@ -277,7 +302,7 @@ typedef struct mac_addr {
 } macaddr_t;
 
 /* Structure that represent every FIFO element in the BAR1
- * Address location. 
+ * Address location.
  */
 typedef struct _TxFIFO_element {
 	u64 TxDL_Pointer;
@@ -339,6 +364,7 @@ typedef struct _RxD_t {
 #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
 #define RXD_FRAME_PROTO_IPV4    BIT(27)
 #define RXD_FRAME_PROTO_IPV6    BIT(28)
+#define RXD_FRAME_IP_FRAG	BIT(29)
 #define RXD_FRAME_PROTO_TCP     BIT(30)
 #define RXD_FRAME_PROTO_UDP     BIT(31)
 #define TCP_OR_UDP_FRAME        (RXD_FRAME_PROTO_TCP | RXD_FRAME_PROTO_UDP)
@@ -347,10 +373,10 @@ typedef struct _RxD_t {
 
 	u64 Control_2;
 #ifndef CONFIG_2BUFF_MODE
-#define MASK_BUFFER0_SIZE       vBIT(0xFFFF,0,16)
-#define SET_BUFFER0_SIZE(val)   vBIT(val,0,16)
+#define MASK_BUFFER0_SIZE       vBIT(0x3FFF,2,14)
+#define SET_BUFFER0_SIZE(val)   vBIT(val,2,14)
 #else
-#define MASK_BUFFER0_SIZE       vBIT(0xFF,0,16)
+#define MASK_BUFFER0_SIZE       vBIT(0xFF,2,14)
 #define MASK_BUFFER1_SIZE       vBIT(0xFFFF,16,16)
 #define MASK_BUFFER2_SIZE       vBIT(0xFFFF,32,16)
 #define SET_BUFFER0_SIZE(val)   vBIT(val,8,8)
@@ -363,7 +389,7 @@ typedef struct _RxD_t {
 #define SET_NUM_TAG(val)       vBIT(val,16,32)
 
 #ifndef CONFIG_2BUFF_MODE
-#define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 & vBIT(0xFFFF,0,16)))
+#define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 & vBIT(0x3FFF,2,14)))
 #else
 #define RXD_GET_BUFFER0_SIZE(Control_2) (u8)((Control_2 & MASK_BUFFER0_SIZE) \
 							>> 48)
@@ -382,7 +408,7 @@ typedef struct _RxD_t {
 #endif
 } RxD_t;
 
-/* Structure that represents the Rx descriptor block which contains 
+/* Structure that represents the Rx descriptor block which contains
  * 128 Rx descriptors.
  */
 #ifndef CONFIG_2BUFF_MODE
@@ -392,11 +418,11 @@ typedef struct _RxD_block {
 
 	u64 reserved_0;
 #define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
-	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last 
+	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last
 				 * Rxd in this blk */
 	u64 reserved_2_pNext_RxD_block;	/* Logical ptr to next */
 	u64 pNext_RxD_Blk_physical;	/* Buff0_ptr.In a 32 bit arch
-					 * the upper 32 bits should 
+					 * the upper 32 bits should
 					 * be 0 */
 } RxD_block_t;
 #else
@@ -405,13 +431,13 @@ typedef struct _RxD_block {
 	RxD_t rxd[MAX_RXDS_PER_BLOCK];
 
 #define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
-	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd 
+	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd
 				 * in this blk */
 	u64 pNext_RxD_Blk_physical;	/* Phy ponter to next blk. */
 } RxD_block_t;
 #define SIZE_OF_BLOCK	4096
 
-/* Structure to hold virtual addresses of Buf0 and Buf1 in 
+/* Structure to hold virtual addresses of Buf0 and Buf1 in
  * 2buf mode. */
 typedef struct bufAdd {
 	void *ba_0_org;
@@ -423,8 +449,8 @@ typedef struct bufAdd {
 
 /* Structure which stores all the MAC control parameters */
 
-/* This structure stores the offset of the RxD in the ring 
- * from which the Rx Interrupt processor can start picking 
+/* This structure stores the offset of the RxD in the ring
+ * from which the Rx Interrupt processor can start picking
  * up the RxDs for processing.
  */
 typedef struct _rx_curr_get_info_t {
@@ -436,7 +462,7 @@ typedef struct _rx_curr_get_info_t {
 typedef rx_curr_get_info_t rx_curr_put_info_t;
 
 /* This structure stores the offset of the TxDl in the FIFO
- * from which the Tx Interrupt processor can start picking 
+ * from which the Tx Interrupt processor can start picking
  * up the TxDLs for send complete interrupt processing.
  */
 typedef struct {
@@ -446,32 +472,96 @@ typedef struct {
 
 typedef tx_curr_get_info_t tx_curr_put_info_t;
 
-/* Infomation related to the Tx and Rx FIFOs and Rings of Xena
- * is maintained in this structure.
- */
-typedef struct mac_info {
-/* rx side stuff */
-	/* Put pointer info which indictes which RxD has to be replenished 
+/* Structure that holds the Phy and virt addresses of the Blocks */
+typedef struct rx_block_info {
+	RxD_t *block_virt_addr;
+	dma_addr_t block_dma_addr;
+} rx_block_info_t;
+
+/* pre declaration of the nic structure */
+typedef struct s2io_nic nic_t;
+
+/* Ring specific structure */
+typedef struct ring_info {
+	/* The ring number */
+	int ring_no;
+
+	/*
+	 *  Place holders for the virtual and physical addresses of
+	 *  all the Rx Blocks
+	 */
+	rx_block_info_t rx_blocks[MAX_RX_BLOCKS_PER_RING];
+	int block_count;
+	int pkt_cnt;
+
+	/*
+	 * Put pointer info which indictes which RxD has to be replenished
 	 * with a new buffer.
 	 */
-	rx_curr_put_info_t rx_curr_put_info[MAX_RX_RINGS];
+	rx_curr_put_info_t rx_curr_put_info;
 
-	/* Get pointer info which indictes which is the last RxD that was 
+	/*
+	 * Get pointer info which indictes which is the last RxD that was
 	 * processed by the driver.
 	 */
-	rx_curr_get_info_t rx_curr_get_info[MAX_RX_RINGS];
+	rx_curr_get_info_t rx_curr_get_info;
 
-	u16 rmac_pause_time;
-	u16 mc_pause_threshold_q0q3;
-	u16 mc_pause_threshold_q4q7;
+#ifndef CONFIG_S2IO_NAPI
+	/* Index to the absolute position of the put pointer of Rx ring */
+	int put_pos;
+#endif
+
+#ifdef CONFIG_2BUFF_MODE
+	/* Buffer Address store. */
+	buffAdd_t **ba;
+#endif
+	nic_t *nic;
+} ring_info_t;
 
+/* Fifo specific structure */
+typedef struct fifo_info {
+	/* FIFO number */
+	int fifo_no;
+
+	/* Maximum TxDs per TxDL */
+	int max_txds;
+
+	/* Place holder of all the TX List's Phy and Virt addresses. */
+	list_info_hold_t *list_info;
+
+	/*
+	 * Current offset within the tx FIFO where driver would write
+	 * new Tx frame
+	 */
+	tx_curr_put_info_t tx_curr_put_info;
+
+	/*
+	 * Current offset within tx FIFO from where the driver would start freeing
+	 * the buffers
+	 */
+	tx_curr_get_info_t tx_curr_get_info;
+
+	nic_t *nic;
+}fifo_info_t;
+
+/* Infomation related to the Tx and Rx FIFOs and Rings of Xena
+ * is maintained in this structure.
+ */
+typedef struct mac_info {
 /* tx side stuff */
 	/* logical pointer of start of each Tx FIFO */
 	TxFIFO_element_t __iomem *tx_FIFO_start[MAX_TX_FIFOS];
 
-/* Current offset within tx_FIFO_start, where driver would write new Tx frame*/
-	tx_curr_put_info_t tx_curr_put_info[MAX_TX_FIFOS];
-	tx_curr_get_info_t tx_curr_get_info[MAX_TX_FIFOS];
+	/* Fifo specific structure */
+	fifo_info_t fifos[MAX_TX_FIFOS];
+
+/* rx side stuff */
+	/* Ring specific structure */
+	ring_info_t rings[MAX_RX_RINGS];
+
+	u16 rmac_pause_time;
+	u16 mc_pause_threshold_q0q3;
+	u16 mc_pause_threshold_q4q7;
 
 	void *stats_mem;	/* orignal pointer to allocated mem */
 	dma_addr_t stats_mem_phy;	/* Physical address of the stat block */
@@ -485,12 +575,6 @@ typedef struct {
 	int usage_cnt;
 } usr_addr_t;
 
-/* Structure that holds the Phy and virt addresses of the Blocks */
-typedef struct rx_block_info {
-	RxD_t *block_virt_addr;
-	dma_addr_t block_dma_addr;
-} rx_block_info_t;
-
 /* Default Tunable parameters of the NIC. */
 #define DEFAULT_FIFO_LEN 4096
 #define SMALL_RXD_CNT	30 * (MAX_RXDS_PER_BLOCK+1)
@@ -499,7 +583,20 @@ typedef struct rx_block_info {
 #define LARGE_BLK_CNT	100
 
 /* Structure representing one instance of the NIC */
-typedef struct s2io_nic {
+struct s2io_nic {
+#ifdef CONFIG_S2IO_NAPI
+	/*
+	 * Count of packets to be processed in a given iteration, it will be indicated
+	 * by the quota field of the device structure when NAPI is enabled.
+	 */
+	int pkts_to_process;
+#endif
+	struct net_device *dev;
+	mac_info_t mac_control;
+	struct config_param config;
+	struct pci_dev *pdev;
+	void __iomem *bar0;
+	void __iomem *bar1;
 #define MAX_MAC_SUPPORTED   16
 #define MAX_SUPPORTED_MULTICASTS MAX_MAC_SUPPORTED
 
@@ -507,33 +604,17 @@ typedef struct s2io_nic {
 	macaddr_t pre_mac_addr[MAX_MAC_SUPPORTED];
 
 	struct net_device_stats stats;
-	void __iomem *bar0;
-	void __iomem *bar1;
-	struct config_param config;
-	mac_info_t mac_control;
 	int high_dma_flag;
 	int device_close_flag;
 	int device_enabled_once;
 
-	char name[32];
+	char name[50];
 	struct tasklet_struct task;
 	volatile unsigned long tasklet_status;
-	struct timer_list timer;
-	struct net_device *dev;
-	struct pci_dev *pdev;
 
-	u16 vendor_id;
-	u16 device_id;
-	u16 ccmd;
-	u32 cbar0_1;
-	u32 cbar0_2;
-	u32 cbar1_1;
-	u32 cbar1_2;
-	u32 cirq;
-	u8 cache_line;
-	u32 rom_expansion;
-	u16 pcix_cmd;
-	u32 irq;
+	/* Space to back up the PCI config space */
+	u32 config_space[256 / sizeof(u32)];
+
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
 
 	spinlock_t tx_lock;
@@ -558,27 +639,11 @@ typedef struct s2io_nic {
 	u16 tx_err_count;
 	u16 rx_err_count;
 
-#ifndef CONFIG_S2IO_NAPI
-	/* Index to the absolute position of the put pointer of Rx ring. */
-	int put_pos[MAX_RX_RINGS];
-#endif
-
-	/*
-	 *  Place holders for the virtual and physical addresses of 
-	 *  all the Rx Blocks
-	 */
-	rx_block_info_t rx_blocks[MAX_RX_RINGS][MAX_RX_BLOCKS_PER_RING];
-	int block_count[MAX_RX_RINGS];
-	int pkt_cnt[MAX_RX_RINGS];
-
-	/* Place holder of all the TX List's Phy and Virt addresses. */
-	list_info_hold_t *list_info[MAX_TX_FIFOS];
-
 	/*  Id timer, used to blink NIC to physically identify NIC. */
 	struct timer_list id_timer;
 
 	/*  Restart timer, used to restart NIC if the device is stuck and
-	 *  a schedule task that will set the correct Link state once the 
+	 *  a schedule task that will set the correct Link state once the
 	 *  NIC's PHY has stabilized after a state change.
 	 */
 #ifdef INIT_TQUEUE
@@ -589,12 +654,12 @@ typedef struct s2io_nic {
 	struct work_struct set_link_task;
 #endif
 
-	/* Flag that can be used to turn on or turn off the Rx checksum 
+	/* Flag that can be used to turn on or turn off the Rx checksum
 	 * offload feature.
 	 */
 	int rx_csum;
 
-	/*  after blink, the adapter must be restored with original 
+	/*  after blink, the adapter must be restored with original
 	 *  values.
 	 */
 	u64 adapt_ctrl_org;
@@ -604,16 +669,12 @@ typedef struct s2io_nic {
 #define	LINK_DOWN	1
 #define	LINK_UP		2
 
-#ifdef CONFIG_2BUFF_MODE
-	/* Buffer Address store. */
-	buffAdd_t **ba[MAX_RX_RINGS];
-#endif
 	int task_flag;
 #define CARD_DOWN 1
 #define CARD_UP 2
 	atomic_t card_state;
 	volatile unsigned long link_state;
-} nic_t;
+};
 
 #define RESET_ERROR 1;
 #define CMD_ERROR   2;
@@ -622,9 +683,10 @@ typedef struct s2io_nic {
 #ifndef readq
 static inline u64 readq(void __iomem *addr)
 {
-	u64 ret = readl(addr + 4);
-	ret <<= 32;
-	ret |= readl(addr);
+	u64 ret = 0;
+	ret = readl(addr + 4);
+	(u64) ret <<= 32;
+	(u64) ret |= readl(addr);
 
 	return ret;
 }
@@ -637,10 +699,10 @@ static inline void writeq(u64 val, void 
 	writel((u32) (val >> 32), (addr + 4));
 }
 
-/* In 32 bit modes, some registers have to be written in a 
+/* In 32 bit modes, some registers have to be written in a
  * particular order to expect correct hardware operation. The
- * macro SPECIAL_REG_WRITE is used to perform such ordered 
- * writes. Defines UF (Upper First) and LF (Lower First) will 
+ * macro SPECIAL_REG_WRITE is used to perform such ordered
+ * writes. Defines UF (Upper First) and LF (Lower First) will
  * be used to specify the required write order.
  */
 #define UF	1
@@ -716,6 +778,7 @@ static inline void SPECIAL_REG_WRITE(u64
 #define	PCC_FB_ECC_ERR	   vBIT(0xff, 16, 8)	/* Interrupt to indicate
 						   PCC_FB_ECC Error. */
 
+#define RXD_GET_VLAN_TAG(Control_2) (u16)(Control_2 & MASK_VLAN_TAG)
 /*
  * Prototype declaration.
  */
@@ -725,36 +788,29 @@ static void __devexit s2io_rem_nic(struc
 static int init_shared_mem(struct s2io_nic *sp);
 static void free_shared_mem(struct s2io_nic *sp);
 static int init_nic(struct s2io_nic *nic);
-#ifndef CONFIG_S2IO_NAPI
-static void rx_intr_handler(struct s2io_nic *sp);
-#endif
-static void tx_intr_handler(struct s2io_nic *sp);
+static void rx_intr_handler(ring_info_t *ring_data);
+static void tx_intr_handler(fifo_info_t *fifo_data);
 static void alarm_intr_handler(struct s2io_nic *sp);
 
 static int s2io_starter(void);
-static void s2io_closer(void);
+void s2io_closer(void);
 static void s2io_tx_watchdog(struct net_device *dev);
 static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
-#ifndef CONFIG_2BUFF_MODE
-static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no);
-#else
-static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
-			  buffAdd_t * ba);
-#endif
-static void s2io_link(nic_t * sp, int link);
-static void s2io_reset(nic_t * sp);
-#ifdef CONFIG_S2IO_NAPI
+static int rx_osm_handler(ring_info_t *ring_data, RxD_t * rxdp);
+void s2io_link(nic_t * sp, int link);
+void s2io_reset(nic_t * sp);
+#if defined(CONFIG_S2IO_NAPI)
 static int s2io_poll(struct net_device *dev, int *budget);
 #endif
 static void s2io_init_pci(nic_t * sp);
-static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
+int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs);
-static int verify_xena_quiescence(u64 val64, int flag);
+static int verify_xena_quiescence(nic_t *sp, u64 val64, int flag);
 static struct ethtool_ops netdev_ethtool_ops;
 static void s2io_set_link(unsigned long data);
-static int s2io_set_swapper(nic_t * sp);
-static void s2io_card_down(nic_t * nic);
-static int s2io_card_up(nic_t * nic);
-
+int s2io_set_swapper(nic_t * sp);
+static void s2io_card_down(nic_t *nic);
+static int s2io_card_up(nic_t *nic);
+int get_xena_rev_id(struct pci_dev *pdev);
 #endif				/* _S2IO_H */
