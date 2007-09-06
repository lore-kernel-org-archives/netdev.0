From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24 3/5]S2io: Cleanup - removed unused variable intr_type
Date: Thu, 6 Sep 2007 06:46:07 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10709060643440.19944-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:36822 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbXIFKqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 06:46:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Removed the unused variable, intr_type, in device private structure.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_2/drivers/net/s2io.c patch_3/drivers/net/s2io.c
--- patch_2/drivers/net/s2io.c	2007-09-05 13:34:37.000000000 +0530
+++ patch_3/drivers/net/s2io.c	2007-09-05 13:50:34.000000000 +0530
@@ -1611,7 +1611,7 @@ static int init_nic(struct s2io_nic *nic
 
 		val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
 		    RTI_DATA2_MEM_RX_UFC_B(0x2) ;
-		if (nic->intr_type == MSI_X)
+		if (nic->config.intr_type == MSI_X)
 		    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x20) | \
 				RTI_DATA2_MEM_RX_UFC_D(0x40));
 		else
@@ -1749,7 +1749,7 @@ static int init_nic(struct s2io_nic *nic
 
 static int s2io_link_fault_indication(struct s2io_nic *nic)
 {
-	if (nic->intr_type != INTA)
+	if (nic->config.intr_type != INTA)
 		return MAC_RMAC_ERR_TIMER;
 	if (nic->device_type == XFRAME_II_DEVICE)
 		return LINK_UP_DOWN_INTERRUPT;
@@ -3557,7 +3557,7 @@ static int s2io_set_swapper(struct s2io_
 		 SWAPPER_CTRL_RXF_W_FE |
 		 SWAPPER_CTRL_XMSI_FE |
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
-	if (sp->intr_type == INTA)
+	if (sp->config.intr_type == INTA)
 		val64 |= SWAPPER_CTRL_XMSI_SE;
 	writeq(val64, &bar0->swapper_ctrl);
 #else
@@ -3580,7 +3580,7 @@ static int s2io_set_swapper(struct s2io_
 		 SWAPPER_CTRL_RXF_W_FE |
 		 SWAPPER_CTRL_XMSI_FE |
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
-	if (sp->intr_type == INTA)
+	if (sp->config.intr_type == INTA)
 		val64 |= SWAPPER_CTRL_XMSI_SE;
 	writeq(val64, &bar0->swapper_ctrl);
 #endif
@@ -3854,7 +3854,7 @@ static int s2io_open(struct net_device *
 	netif_carrier_off(dev);
 	sp->last_link_state = 0;
 
-	if (sp->intr_type == MSI_X) {
+	if (sp->config.intr_type == MSI_X) {
 		int ret = s2io_enable_msi_x(sp);
 
 		if (!ret) {
@@ -3886,12 +3886,12 @@ static int s2io_open(struct net_device *
 			DBG_PRINT(ERR_DBG,
 			  "%s: MSI-X requested but failed to enable\n",
 			  dev->name);
-			sp->intr_type = INTA;
+			sp->config.intr_type = INTA;
 		}
 	}
 
 	/* NAPI doesn't work well with MSI(X) */
-	 if (sp->intr_type != INTA) {
+	 if (sp->config.intr_type != INTA) {
 		if(sp->config.napi)
 			sp->config.napi = 0;
 	}
@@ -3915,7 +3915,7 @@ static int s2io_open(struct net_device *
 	return 0;
 
 hw_init_failed:
-	if (sp->intr_type == MSI_X) {
+	if (sp->config.intr_type == MSI_X) {
 		if (sp->entries) {
 			kfree(sp->entries);
 			sp->mac_control.stats_info->sw_stat.mem_freed 
@@ -6700,18 +6700,18 @@ static int s2io_add_isr(struct s2io_nic 
 	struct net_device *dev = sp->dev;
 	int err = 0;
 
-	if (sp->intr_type == MSI_X)
+	if (sp->config.intr_type == MSI_X)
 		ret = s2io_enable_msi_x(sp);
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Defaulting to INTA\n", dev->name);
-		sp->intr_type = INTA;
+		sp->config.intr_type = INTA;
 	}
 
 	/* Store the values of the MSIX table in the struct s2io_nic structure */
 	store_xmsi_data(sp);
 
 	/* After proper initialization of H/W, register ISR */
-	if (sp->intr_type == MSI_X) {
+	if (sp->config.intr_type == MSI_X) {
 		int i, msix_tx_cnt=0,msix_rx_cnt=0;
 
 		for (i=1; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
@@ -6763,7 +6763,7 @@ static int s2io_add_isr(struct s2io_nic 
 		printk("MSI-X-TX %d entries enabled\n",msix_tx_cnt);
 		printk("MSI-X-RX %d entries enabled\n",msix_rx_cnt);
 	}
-	if (sp->intr_type == INTA) {
+	if (sp->config.intr_type == INTA) {
 		err = request_irq((int) sp->pdev->irq, s2io_isr, IRQF_SHARED,
 				sp->name, dev);
 		if (err) {
@@ -6780,7 +6780,7 @@ static void s2io_rem_isr(struct s2io_nic
 	struct net_device *dev = sp->dev;
 	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
-	if (sp->intr_type == MSI_X) {
+	if (sp->config.intr_type == MSI_X) {
 		int i;
 		u16 msi_control;
 
@@ -6953,7 +6953,7 @@ static int s2io_card_up(struct s2io_nic 
 
 	/* Add interrupt service routine */
 	if (s2io_add_isr(sp) != 0) {
-		if (sp->intr_type == MSI_X)
+		if (sp->config.intr_type == MSI_X)
 			s2io_rem_isr(sp);
 		s2io_reset(sp);
 		free_rx_buffers(sp);
@@ -6967,7 +6967,7 @@ static int s2io_card_up(struct s2io_nic 
 
 	/*  Enable select interrupts */
 	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
-	if (sp->intr_type != INTA)
+	if (sp->config.intr_type != INTA)
 		en_dis_able_nic_intrs(sp, ENA_ALL_INTRS, DISABLE_INTRS);
 	else {
 		interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
@@ -7494,7 +7494,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	if (rx_ring_mode == 2)
 		sp->rxd_mode = RXD_MODE_3B;
 
-	sp->intr_type = dev_intr_type;
+	sp->config.intr_type = dev_intr_type;
 
 	if ((pdev->device == PCI_DEVICE_ID_HERC_WIN) ||
 		(pdev->device == PCI_DEVICE_ID_HERC_UNI))
@@ -7774,7 +7774,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 
 	if (napi)
 		DBG_PRINT(ERR_DBG, "%s: NAPI enabled\n", dev->name);
-	switch(sp->intr_type) {
+	switch(sp->config.intr_type) {
 		case INTA:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
 		    break;
diff -urpN patch_2/drivers/net/s2io.h patch_3/drivers/net/s2io.h
--- patch_2/drivers/net/s2io.h	2007-09-03 18:27:16.000000000 +0530
+++ patch_3/drivers/net/s2io.h	2007-09-05 13:50:37.000000000 +0530
@@ -905,11 +905,6 @@ struct s2io_nic {
 	unsigned long	sending_both;
 	u8		lro;
 	u16		lro_max_aggr_per_sess;
-
-#define INTA	0
-#define MSI_X	2
-	u8 intr_type;
-
 	spinlock_t	rx_lock;
 	atomic_t	isr_cnt;
 	u64		general_int_mask;

