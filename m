From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] vmxnet3: fix indentation
Date: Tue, 13 Nov 2012 15:53:28 -0800
Message-ID: <20121113155328.0914d6f1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42089 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755988Ab2KMXyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 18:54:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor indentation out of alignment.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vmxnet3/vmxnet3_drv.c	2012-11-12 07:58:45.531037908 -0800
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c	2012-11-13 15:50:53.076593627 -0800
@@ -1094,10 +1094,10 @@ vmxnet3_xmit_frame(struct sk_buff *skb,
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 
-		BUG_ON(skb->queue_mapping > adapter->num_tx_queues);
-		return vmxnet3_tq_xmit(skb,
-				       &adapter->tx_queue[skb->queue_mapping],
-				       adapter, netdev);
+	BUG_ON(skb->queue_mapping > adapter->num_tx_queues);
+	return vmxnet3_tq_xmit(skb,
+			       &adapter->tx_queue[skb->queue_mapping],
+			       adapter, netdev);
 }
 
 
@@ -1243,8 +1243,8 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx
 			skb_reserve(new_skb, NET_IP_ALIGN);
 			rbi->skb = new_skb;
 			rbi->dma_addr = pci_map_single(adapter->pdev,
-					rbi->skb->data, rbi->len,
-					PCI_DMA_FROMDEVICE);
+						       rbi->skb->data, rbi->len,
+						       PCI_DMA_FROMDEVICE);
 			rxd->addr = cpu_to_le64(rbi->dma_addr);
 			rxd->len = rbi->len;
 
@@ -1331,14 +1331,14 @@ rcd_done:
 		/* if needed, update the register */
 		if (unlikely(rq->shared->updateRxProd)) {
 			VMXNET3_WRITE_BAR0_REG(adapter,
-				rxprod_reg[ring_idx] + rq->qid * 8,
-				ring->next2fill);
+					       rxprod_reg[ring_idx] + rq->qid * 8,
+					       ring->next2fill);
 			rq->uncommitted[ring_idx] = 0;
 		}
 
 		vmxnet3_comp_ring_adv_next2proc(&rq->comp_ring);
 		vmxnet3_getRxComp(rcd,
-		     &rq->comp_ring.base[rq->comp_ring.next2proc].rcd, &rxComp);
+				  &rq->comp_ring.base[rq->comp_ring.next2proc].rcd, &rxComp);
 	}
 
 	return num_rxd;
@@ -2949,11 +2949,11 @@ vmxnet3_probe_device(struct pci_dev *pde
 
 	spin_lock_init(&adapter->cmd_lock);
 	adapter->shared = pci_alloc_consistent(adapter->pdev,
-			  sizeof(struct Vmxnet3_DriverShared),
-			  &adapter->shared_pa);
+					       sizeof(struct Vmxnet3_DriverShared),
+					       &adapter->shared_pa);
 	if (!adapter->shared) {
 		printk(KERN_ERR "Failed to allocate memory for %s\n",
-			pci_name(pdev));
+		       pci_name(pdev));
 		err = -ENOMEM;
 		goto err_alloc_shared;
 	}
@@ -2964,16 +2964,16 @@ vmxnet3_probe_device(struct pci_dev *pde
 	size = sizeof(struct Vmxnet3_TxQueueDesc) * adapter->num_tx_queues;
 	size += sizeof(struct Vmxnet3_RxQueueDesc) * adapter->num_rx_queues;
 	adapter->tqd_start = pci_alloc_consistent(adapter->pdev, size,
-			     &adapter->queue_desc_pa);
+						  &adapter->queue_desc_pa);
 
 	if (!adapter->tqd_start) {
 		printk(KERN_ERR "Failed to allocate memory for %s\n",
-			pci_name(pdev));
+		       pci_name(pdev));
 		err = -ENOMEM;
 		goto err_alloc_queue_desc;
 	}
 	adapter->rqd_start = (struct Vmxnet3_RxQueueDesc *)(adapter->tqd_start +
-							adapter->num_tx_queues);
+							    adapter->num_tx_queues);
 
 	adapter->pm_conf = kmalloc(sizeof(struct Vmxnet3_PMConf), GFP_KERNEL);
 	if (adapter->pm_conf == NULL) {
@@ -3019,7 +3019,7 @@ vmxnet3_probe_device(struct pci_dev *pde
 
 	adapter->dev_number = atomic_read(&devices_found);
 
-	 adapter->share_intr = irq_share_mode;
+	adapter->share_intr = irq_share_mode;
 	if (adapter->share_intr == VMXNET3_INTR_BUDDYSHARE &&
 	    adapter->num_tx_queues != adapter->num_rx_queues)
 		adapter->share_intr = VMXNET3_INTR_DONTSHARE;
@@ -3065,7 +3065,7 @@ vmxnet3_probe_device(struct pci_dev *pde
 
 	if (err) {
 		printk(KERN_ERR "Failed to register adapter %s\n",
-			pci_name(pdev));
+		       pci_name(pdev));
 		goto err_register;
 	}
 
