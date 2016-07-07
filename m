From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] Removing lots of IS_ERR_VALUE abuses and compilation warning.
Date: Thu,  7 Jul 2016 21:30:14 +0530
Message-ID: <1467907214-5783-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	Arvind Yadav <arvind.yadav.cs@gmail.com>
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 51.17-broadband.acttv.in ([106.51.17.148]:9614 "EHLO
	arvind-ThinkPad-Edge-E431" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750859AbcGGQAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 12:00:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passing value in IS_ERR_VALUE() is wrong, as they pass an 'int'
into a function that takes an 'unsigned long' argument.This happens
to work because the type is sign-extended on 64-bit architectures
before it gets converted into an unsigned type.

Passing an 'unsigned short' or 'unsigned int'argument into
IS_ERR_VALUE() is guaranteed to be broken, as are 8-bit integers
and types that are wider than 'unsigned long'.

Any user will get compilation warning for that do not pass an
unsigned long' argument.

Commit '287980e49f; - This change is alreday fixes lots of other
Worst abusers

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 5bf1ade..c1ead2c 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -289,7 +289,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 		else {
 			init_enet_offset =
 			    qe_muram_alloc(thread_size, thread_alignment);
-			if (IS_ERR_VALUE(init_enet_offset)) {
+			if (init_enet_offset < 0) {
 				if (netif_msg_ifup(ugeth))
 					pr_err("Can not allocate DPRAM memory\n");
 				qe_put_snum((u8) snum);
@@ -2234,7 +2234,7 @@ static int ucc_geth_alloc_tx(struct ucc_geth_private *ugeth)
 			ugeth->tx_bd_ring_offset[j] =
 			    qe_muram_alloc(length,
 					   UCC_GETH_TX_BD_RING_ALIGNMENT);
-			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
+			if (!ugeth->tx_bd_ring_offset[j])
 				ugeth->p_tx_bd_ring[j] =
 				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 tx_bd_ring_offset[j]);
@@ -2311,7 +2311,7 @@ static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
 			ugeth->rx_bd_ring_offset[j] =
 			    qe_muram_alloc(length,
 					   UCC_GETH_RX_BD_RING_ALIGNMENT);
-			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
+			if (!ugeth->rx_bd_ring_offset[j])
 				ugeth->p_rx_bd_ring[j] =
 				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 rx_bd_ring_offset[j]);
@@ -2521,7 +2521,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	ugeth->tx_glbl_pram_offset =
 	    qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
 			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
+	if (ugeth->tx_glbl_pram_offset < 0) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_tx_glbl_pram\n");
 		return -ENOMEM;
@@ -2541,7 +2541,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_thread_data_tx) +
 			   32 * (numThreadsTxNumerical == 1),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
+	if (ugeth->thread_dat_tx_offset < 0) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_thread_data_tx\n");
 		return -ENOMEM;
@@ -2568,7 +2568,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(ug_info->numQueuesTx *
 			   sizeof(struct ucc_geth_send_queue_qd),
 			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
+	if (ugeth->send_q_mem_reg_offset < 0) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_send_q_mem_reg\n");
 		return -ENOMEM;
@@ -2609,7 +2609,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		ugeth->scheduler_offset =
 		    qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
 				   UCC_GETH_SCHEDULER_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
+		if (ugeth->scheduler_offset < 0) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_scheduler\n");
 			return -ENOMEM;
@@ -2656,7 +2656,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof
 				   (struct ucc_geth_tx_firmware_statistics_pram),
 				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
+		if (ugeth->tx_fw_statistics_pram_offset < 0) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_tx_fw_statistics_pram\n");
 			return -ENOMEM;
@@ -2693,7 +2693,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	ugeth->rx_glbl_pram_offset =
 	    qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
 			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
+	if (ugeth->rx_glbl_pram_offset < 0) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_glbl_pram\n");
 		return -ENOMEM;
@@ -2712,7 +2712,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(numThreadsRxNumerical *
 			   sizeof(struct ucc_geth_thread_data_rx),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
+	if (ugeth->thread_dat_rx_offset < 0) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_thread_data_rx\n");
 		return -ENOMEM;
@@ -2733,7 +2733,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof
 				   (struct ucc_geth_rx_firmware_statistics_pram),
 				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
+		if (ugeth->rx_fw_statistics_pram_offset < 0) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_rx_fw_statistics_pram\n");
 			return -ENOMEM;
@@ -2753,7 +2753,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(ug_info->numQueuesRx *
 			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
 			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
+	if (ugeth->rx_irq_coalescing_tbl_offset < 0) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_irq_coalescing_tbl\n");
 		return -ENOMEM;
@@ -2819,7 +2819,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   (sizeof(struct ucc_geth_rx_bd_queues_entry) +
 			    sizeof(struct ucc_geth_rx_prefetched_bds)),
 			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
+	if (ugeth->rx_bd_qs_tbl_offset < 0) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_bd_qs_tbl\n");
 		return -ENOMEM;
@@ -2905,7 +2905,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		ugeth->exf_glbl_param_offset =
 		    qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
 		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
+		if (ugeth->exf_glbl_param_offset < 0) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_exf_glbl_param\n");
 			return -ENOMEM;
@@ -3039,7 +3039,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 
 	/* Allocate InitEnet command parameter structure */
 	init_enet_pram_offset = qe_muram_alloc(sizeof(struct ucc_geth_init_pram), 4);
-	if (IS_ERR_VALUE(init_enet_pram_offset)) {
+	if (init_enet_pram_offset < 0) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_init_enet_pram\n");
 		return -ENOMEM;
-- 
1.9.1
