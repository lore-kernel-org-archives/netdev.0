From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/4] qlge: Reduce debug print output.
Date: Fri, 30 Oct 2009 15:13:35 -0700
Message-ID: <1256940816-27540-4-git-send-email-ron.mercer@qlogic.com>
References: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:33628 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932943AbZJ3WTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 18:19:51 -0400
In-Reply-To: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   12 +++++
 drivers/net/qlge/qlge_main.c |  101 ++++++++++++++++++++++-------------------
 drivers/net/qlge/qlge_mpi.c  |   14 +++---
 3 files changed, 73 insertions(+), 54 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index b9f65e0..502c3af 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -27,6 +27,18 @@
 		dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
 			   "%s: " fmt, __func__, ##args);  \
        } while (0)
+#if 0
+#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)	\
+	do {	\
+		if (!((qdev)->msg_enable & NETIF_MSG_##nlevel))	\
+			;					\
+		else						\
+			dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
+					"%s: " fmt, __func__, ##args);  \
+	} while (0)
+#else
+#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)
+#endif
 
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 01f78a9..57bbb90 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -359,7 +359,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			    (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) |
 			    (addr[5]);
 
-			QPRINTK(qdev, IFUP, DEBUG,
+			QPRINTK_DBG(qdev, IFUP, DEBUG,
 				"Adding %s address %pM"
 				" at index %d in the CAM.\n",
 				((type ==
@@ -414,7 +414,8 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			 * addressing. It's either MAC_ADDR_E on or off.
 			 * That's bit-27 we're talking about.
 			 */
-			QPRINTK(qdev, IFUP, INFO, "%s VLAN ID %d %s the CAM.\n",
+			QPRINTK_DBG(qdev, IFUP, INFO,
+				"%s VLAN ID %d %s the CAM.\n",
 				(enable_bit ? "Adding" : "Removing"),
 				index, (enable_bit ? "to" : "from"));
 
@@ -522,9 +523,9 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 	int status = -EINVAL; /* Return error if no mask match. */
 	u32 value = 0;
 
-	QPRINTK(qdev, IFUP, DEBUG,
-		"%s %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s mask %s the routing reg.\n",
-		(enable ? "Adding" : "Removing"),
+	QPRINTK_DBG(qdev, IFUP, DEBUG,
+		"%s %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s mask %s the routing "
+		"reg.\n", (enable ? "Adding" : "Removing"),
 		((index == RT_IDX_ALL_ERR_SLOT) ? "MAC ERROR/ALL ERROR" : ""),
 		((index == RT_IDX_IP_CSUM_ERR_SLOT) ? "IP CSUM ERROR" : ""),
 		((index ==
@@ -959,8 +960,9 @@ static int ql_8012_port_initialize(struct ql_adapter *qdev)
 		/* Another function has the semaphore, so
 		 * wait for the port init bit to come ready.
 		 */
-		QPRINTK(qdev, LINK, INFO,
-			"Another function has the semaphore, so wait for the port init bit to come ready.\n");
+		QPRINTK_DBG(qdev, LINK, INFO,
+			"Another function has the semaphore, so wait for the "
+			"port init bit to come ready.\n");
 		status = ql_wait_reg_rdy(qdev, STS, qdev->port_init, 0);
 		if (status) {
 			QPRINTK(qdev, LINK, CRIT,
@@ -969,7 +971,7 @@ static int ql_8012_port_initialize(struct ql_adapter *qdev)
 		return status;
 	}
 
-	QPRINTK(qdev, LINK, INFO, "Got xgmac semaphore!.\n");
+	QPRINTK_DBG(qdev, LINK, INFO, "Got xgmac semaphore!.\n");
 	/* Set the core reset. */
 	status = ql_read_xgmac_reg(qdev, GLOBAL_CFG, &data);
 	if (status)
@@ -1148,7 +1150,7 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 
 	while (rx_ring->lbq_free_cnt > 32) {
 		for (i = 0; i < 16; i++) {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
+			QPRINTK_DBG(qdev, RX_STATUS, DEBUG,
 				"lbq: try cleaning clean_idx = %d.\n",
 				clean_idx);
 			lbq_desc = &rx_ring->lbq[clean_idx];
@@ -1181,7 +1183,7 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	}
 
 	if (start_idx != clean_idx) {
-		QPRINTK(qdev, RX_STATUS, DEBUG,
+		QPRINTK_DBG(qdev, RX_STATUS, DEBUG,
 			"lbq: updating prod idx = %d.\n",
 			rx_ring->lbq_prod_idx);
 		ql_write_db_reg(rx_ring->lbq_prod_idx,
@@ -1201,7 +1203,7 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	while (rx_ring->sbq_free_cnt > 16) {
 		for (i = 0; i < 16; i++) {
 			sbq_desc = &rx_ring->sbq[clean_idx];
-			QPRINTK(qdev, RX_STATUS, DEBUG,
+			QPRINTK_DBG(qdev, RX_STATUS, DEBUG,
 				"sbq: try cleaning clean_idx = %d.\n",
 				clean_idx);
 			if (sbq_desc->p.skb == NULL) {
@@ -1247,7 +1249,7 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	}
 
 	if (start_idx != clean_idx) {
-		QPRINTK(qdev, RX_STATUS, DEBUG,
+		QPRINTK_DBG(qdev, RX_STATUS, DEBUG,
 			"sbq: updating prod idx = %d.\n",
 			rx_ring->sbq_prod_idx);
 		ql_write_db_reg(rx_ring->sbq_prod_idx,
@@ -1281,7 +1283,7 @@ static void ql_unmap_send(struct ql_adapter *qdev,
 			 * then its an OAL.
 			 */
 			if (i == 7) {
-				QPRINTK(qdev, TX_DONE, DEBUG,
+				QPRINTK_DBG(qdev, TX_DONE, DEBUG,
 					"unmapping OAL area.\n");
 			}
 			pci_unmap_single(qdev->pdev,
@@ -1291,8 +1293,8 @@ static void ql_unmap_send(struct ql_adapter *qdev,
 						       maplen),
 					 PCI_DMA_TODEVICE);
 		} else {
-			QPRINTK(qdev, TX_DONE, DEBUG, "unmapping frag %d.\n",
-				i);
+			QPRINTK_DBG(qdev, TX_DONE, DEBUG,
+					"unmapping frag %d.\n",	i);
 			pci_unmap_page(qdev->pdev,
 				       pci_unmap_addr(&tx_ring_desc->map[i],
 						      mapaddr),
@@ -1316,9 +1318,9 @@ static int ql_map_send(struct ql_adapter *qdev,
 	struct tx_buf_desc *tbd = mac_iocb_ptr->tbd;
 	int frag_cnt = skb_shinfo(skb)->nr_frags;
 
-	if (frag_cnt) {
-		QPRINTK(qdev, TX_QUEUED, DEBUG, "frag_cnt = %d.\n", frag_cnt);
-	}
+	if (frag_cnt)
+		QPRINTK_DBG(qdev, TX_QUEUED, DEBUG, "frag_cnt = %d.\n",
+				frag_cnt);
 	/*
 	 * Map the skb buffer first.
 	 */
@@ -1857,7 +1859,7 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 	/* While there are entries in the completion queue. */
 	while (prod != rx_ring->cnsmr_idx) {
 
-		QPRINTK(qdev, RX_STATUS, DEBUG,
+		QPRINTK_DBG(qdev, RX_STATUS, DEBUG,
 			"cq_id = %d, prod = %d, cnsmr = %d.\n.", rx_ring->cq_id,
 			prod, rx_ring->cnsmr_idx);
 
@@ -1871,7 +1873,8 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 			break;
 		default:
 			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"Hit default case, not handled! dropping the packet, opcode = %x.\n",
+				"Hit default case, not handled!	"
+				"dropping the packet, opcode = %x.\n",
 				net_rsp->opcode);
 		}
 		count++;
@@ -1904,7 +1907,7 @@ static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 	/* While there are entries in the completion queue. */
 	while (prod != rx_ring->cnsmr_idx) {
 
-		QPRINTK(qdev, RX_STATUS, DEBUG,
+		QPRINTK_DBG(qdev, RX_STATUS, DEBUG,
 			"cq_id = %d, prod = %d, cnsmr = %d.\n.", rx_ring->cq_id,
 			prod, rx_ring->cnsmr_idx);
 
@@ -1922,11 +1925,10 @@ static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 						net_rsp);
 			break;
 		default:
-			{
-				QPRINTK(qdev, RX_STATUS, DEBUG,
-					"Hit default case, not handled! dropping the packet, opcode = %x.\n",
+			QPRINTK(qdev, RX_STATUS, DEBUG,
+				"Hit default case, not handled!	"
+				"dropping the packet, opcode = %x.\n",
 					net_rsp->opcode);
-			}
 		}
 		count++;
 		ql_update_cq(rx_ring);
@@ -1947,7 +1949,7 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 	int i, work_done = 0;
 	struct intr_context *ctx = &qdev->intr_context[rx_ring->cq_id];
 
-	QPRINTK(qdev, RX_STATUS, DEBUG, "Enter, NAPI POLL cq_id = %d.\n",
+	QPRINTK_DBG(qdev, RX_STATUS, DEBUG, "Enter, NAPI POLL cq_id = %d.\n",
 		rx_ring->cq_id);
 
 	/* Service the TX rings first.  They start
@@ -1960,7 +1962,7 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 		if ((ctx->irq_mask & (1 << trx_ring->cq_id)) &&
 			(ql_read_sh_reg(trx_ring->prod_idx_sh_reg) !=
 					trx_ring->cnsmr_idx)) {
-			QPRINTK(qdev, INTR, DEBUG,
+			QPRINTK_DBG(qdev, INTR, DEBUG,
 				"%s: Servicing TX completion ring %d.\n",
 				__func__, trx_ring->cq_id);
 			ql_clean_outbound_rx_ring(trx_ring);
@@ -1972,7 +1974,7 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 	 */
 	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
 					rx_ring->cnsmr_idx) {
-		QPRINTK(qdev, INTR, DEBUG,
+		QPRINTK_DBG(qdev, INTR, DEBUG,
 			"%s: Servicing RX completion ring %d.\n",
 			__func__, rx_ring->cq_id);
 		work_done = ql_clean_inbound_rx_ring(rx_ring, budget);
@@ -1991,11 +1993,12 @@ static void qlge_vlan_rx_register(struct net_device *ndev, struct vlan_group *gr
 
 	qdev->vlgrp = grp;
 	if (grp) {
-		QPRINTK(qdev, IFUP, DEBUG, "Turning on VLAN in NIC_RCV_CFG.\n");
+		QPRINTK_DBG(qdev, IFUP, DEBUG,
+					"Turning on VLAN in NIC_RCV_CFG.\n");
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK |
 			   NIC_RCV_CFG_VLAN_MATCH_AND_NON);
 	} else {
-		QPRINTK(qdev, IFUP, DEBUG,
+		QPRINTK_DBG(qdev, IFUP, DEBUG,
 			"Turning off VLAN in NIC_RCV_CFG.\n");
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK);
 	}
@@ -2058,7 +2061,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 
 	spin_lock(&qdev->hw_lock);
 	if (atomic_read(&qdev->intr_context[0].irq_cnt)) {
-		QPRINTK(qdev, INTR, DEBUG, "Shared Interrupt, Not ours!\n");
+		QPRINTK_DBG(qdev, INTR, DEBUG, "Shared Interrupt, Not ours!\n");
 		spin_unlock(&qdev->hw_lock);
 		return IRQ_NONE;
 	}
@@ -2102,8 +2105,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 */
 	var = ql_read32(qdev, ISR1);
 	if (var & intr_context->irq_mask) {
-				QPRINTK(qdev, INTR, INFO,
-			"Waking handler for rx_ring[0].\n");
+		QPRINTK_DBG(qdev, INTR, INFO, "Waking handler for rx_ring[0].\n");
 		ql_disable_completion_interrupt(qdev, intr_context->intr);
 					napi_schedule(&rx_ring->napi);
 				work_done++;
@@ -2200,9 +2202,9 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 		return NETDEV_TX_OK;
 
 	if (unlikely(atomic_read(&tx_ring->tx_count) < 2)) {
-		QPRINTK(qdev, TX_QUEUED, INFO,
-			"%s: shutting down tx queue %d du to lack of resources.\n",
-			__func__, tx_ring_idx);
+		QPRINTK_DBG(qdev, TX_QUEUED, INFO,
+			"shutting down tx queue %d du to lack of resources.\n",
+			tx_ring_idx);
 		netif_stop_subqueue(ndev, tx_ring->wq_id);
 		atomic_inc(&tx_ring->queue_stopped);
 		return NETDEV_TX_BUSY;
@@ -2222,7 +2224,7 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	mac_iocb_ptr->frame_len = cpu_to_le16((u16) skb->len);
 
 	if (qdev->vlgrp && vlan_tx_tag_present(skb)) {
-		QPRINTK(qdev, TX_QUEUED, DEBUG, "Adding a vlan tag %d.\n",
+		QPRINTK_DBG(qdev, TX_QUEUED, DEBUG, "Adding a vlan tag %d.\n",
 			vlan_tx_tag_get(skb));
 		mac_iocb_ptr->flags3 |= OB_MAC_IOCB_V;
 		mac_iocb_ptr->vlan_tci = cpu_to_le16(vlan_tx_tag_get(skb));
@@ -2248,7 +2250,7 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	wmb();
 
 	ql_write_db_reg(tx_ring->prod_idx, tx_ring->prod_idx_db_reg);
-	QPRINTK(qdev, TX_QUEUED, DEBUG, "tx queued, slot %d, len %d\n",
+	QPRINTK_DBG(qdev, TX_QUEUED, DEBUG, "tx queued, slot %d, len %d\n",
 		tx_ring->prod_idx, skb->len);
 
 	atomic_dec(&tx_ring->tx_count);
@@ -2783,10 +2785,10 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		cqicb->pkt_delay = cpu_to_le16(qdev->rx_max_coalesced_frames);
 		break;
 	default:
-		QPRINTK(qdev, IFUP, DEBUG, "Invalid rx_ring->type = %d.\n",
+		QPRINTK_DBG(qdev, IFUP, DEBUG, "Invalid rx_ring->type = %d.\n",
 			rx_ring->type);
 	}
-	QPRINTK(qdev, IFUP, DEBUG, "Initializing rx work queue.\n");
+	QPRINTK_DBG(qdev, IFUP, DEBUG, "Initializing rx work queue.\n");
 	err = ql_write_cfg(qdev, cqicb, sizeof(struct cqicb),
 			   CFG_LCQ, rx_ring->cq_id);
 	if (err) {
@@ -2839,7 +2841,7 @@ static int ql_start_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 		QPRINTK(qdev, IFUP, ERR, "Failed to load tx_ring.\n");
 		return err;
 	}
-	QPRINTK(qdev, IFUP, DEBUG, "Successfully loaded WQICB.\n");
+	QPRINTK_DBG(qdev, IFUP, DEBUG, "Successfully loaded WQICB.\n");
 	return err;
 }
 
@@ -3088,11 +3090,11 @@ static void ql_free_irq(struct ql_adapter *qdev)
 			if (test_bit(QL_MSIX_ENABLED, &qdev->flags)) {
 				free_irq(qdev->msi_x_entry[i].vector,
 					 &qdev->rx_ring[i]);
-				QPRINTK(qdev, IFDOWN, DEBUG,
+				QPRINTK_DBG(qdev, IFDOWN, DEBUG,
 					"freeing msix interrupt %d.\n", i);
 			} else {
 				free_irq(qdev->pdev->irq, &qdev->rx_ring[0]);
-				QPRINTK(qdev, IFDOWN, DEBUG,
+				QPRINTK_DBG(qdev, IFDOWN, DEBUG,
 					"freeing msi interrupt %d.\n", i);
 			}
 		}
@@ -3200,14 +3202,14 @@ static int ql_start_rss(struct ql_adapter *qdev)
 	memcpy((void *)&ricb->ipv6_hash_key[0], init_hash_seed, 40);
 	memcpy((void *)&ricb->ipv4_hash_key[0], init_hash_seed, 16);
 
-	QPRINTK(qdev, IFUP, DEBUG, "Initializing RSS.\n");
+	QPRINTK_DBG(qdev, IFUP, DEBUG, "Initializing RSS.\n");
 
 	status = ql_write_cfg(qdev, ricb, sizeof(*ricb), CFG_LR, 0);
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to load RICB.\n");
 		return status;
 	}
-	QPRINTK(qdev, IFUP, DEBUG, "Successfully loaded RICB.\n");
+	QPRINTK_DBG(qdev, IFUP, DEBUG, "Successfully loaded RICB.\n");
 	return status;
 }
 
@@ -3679,7 +3681,7 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->lbq_size =
 			    rx_ring->lbq_len * sizeof(__le64);
 			rx_ring->lbq_buf_size = (u16)lbq_buf_len;
-			QPRINTK(qdev, IFUP, DEBUG,
+			QPRINTK_DBG(qdev, IFUP, DEBUG,
 				"lbq_buf_size %d, order = %d\n",
 				rx_ring->lbq_buf_size, qdev->lbq_buf_order);
 			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
@@ -3917,8 +3919,13 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 	if (netif_running(ndev))
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!is_valid_ether_addr(addr->sa_data)) {
+		QPRINTK_DBG(qdev, DRV, ERR,
+			"Invalid Mac addr %02x:%02x:%02x:%02x:%02x:%02x\n",
+			addr->sa_data[0], addr->sa_data[1], addr->sa_data[2],
+			addr->sa_data[3], addr->sa_data[4], addr->sa_data[5]);
 		return -EADDRNOTAVAIL;
+	}
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
 
 	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 80b6853..0a26055 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -207,7 +207,7 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	 * to our liking.
 	 */
 	if (!test_bit(QL_PORT_CFG, &qdev->flags)) {
-		QPRINTK(qdev, DRV, ERR, "Queue Port Config Worker!\n");
+		QPRINTK_DBG(qdev, DRV, DEBUG, "Queue Port Config Worker!\n");
 		set_bit(QL_PORT_CFG, &qdev->flags);
 		/* Begin polled mode early so
 		 * we don't get another interrupt
@@ -277,7 +277,7 @@ static int ql_aen_lost(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		int i;
 		QPRINTK(qdev, DRV, ERR, "Lost AEN detected.\n");
 		for (i = 0; i < mbcp->out_count; i++)
-			QPRINTK(qdev, DRV, ERR, "mbox_out[%d] = 0x%.08x.\n",
+			QPRINTK_DBG(qdev, DRV, ERR, "mbox_out[%d] = 0x%.08x.\n",
 					i, mbcp->mbox_out[i]);
 
 	}
@@ -658,7 +658,7 @@ int ql_mb_set_port_cfg(struct ql_adapter *qdev)
 		return status;
 
 	if (mbcp->mbox_out[0] == MB_CMD_STS_INTRMDT) {
-		QPRINTK(qdev, DRV, ERR,
+		QPRINTK_DBG(qdev, DRV, ERR,
 			"Port Config sent, wait for IDC.\n");
 	} else	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
 		QPRINTK(qdev, DRV, ERR,
@@ -694,7 +694,7 @@ int ql_mb_get_port_cfg(struct ql_adapter *qdev)
 			"Failed Get Port Configuration.\n");
 		status = -EIO;
 	} else	{
-		QPRINTK(qdev, DRV, DEBUG,
+		QPRINTK_DBG(qdev, DRV, DEBUG,
 			"Passed Get Port Configuration.\n");
 		qdev->link_config = mbcp->mbox_out[1];
 		qdev->max_frame_size = mbcp->mbox_out[2];
@@ -898,7 +898,7 @@ int ql_mb_set_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 control)
 		return status;
 
 	if (mbcp->mbox_out[0] == MB_CMD_STS_INVLD_CMD) {
-		QPRINTK(qdev, DRV, ERR,
+		QPRINTK_DBG(qdev, DRV, ERR,
 			"Command not supported by firmware.\n");
 		status = -EINVAL;
 	} else if (mbcp->mbox_out[0] == MB_CMD_STS_ERR) {
@@ -906,7 +906,7 @@ int ql_mb_set_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 control)
 		 * already in the state we are trying to
 		 * change it to.
 		 */
-		QPRINTK(qdev, DRV, ERR,
+		QPRINTK_DBG(qdev, DRV, ERR,
 			"Command parameters make no change.\n");
 	}
 	return status;
@@ -937,7 +937,7 @@ static int ql_mb_get_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 *control)
 	}
 
 	if (mbcp->mbox_out[0] == MB_CMD_STS_INVLD_CMD) {
-		QPRINTK(qdev, DRV, ERR,
+		QPRINTK_DBG(qdev, DRV, ERR,
 			"Command not supported by firmware.\n");
 		status = -EINVAL;
 	} else if (mbcp->mbox_out[0] == MB_CMD_STS_ERR) {
-- 
1.6.0.2

