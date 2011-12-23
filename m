From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] alx: Coalesce long formats
Date: Thu, 22 Dec 2011 20:16:04 -0800
Message-ID: <b177a0ce5b62188ba37f1c243d9fe792375c5fa3.1324613334.git.joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@frijolero.org>,
	ath9k-devel <ath9k-devel@qualcomm.com>,
	Xiong Huang <xiong@qca.qualcomm.com>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org
To: Cloud Ren <cjren@qca.qualcomm.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

format strings broken into multiple bits are harder to grep.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/atheros/alx/alc_cb.c   |    3 +-
 drivers/net/ethernet/atheros/alx/alf_cb.c   |    3 +-
 drivers/net/ethernet/atheros/alx/alx_main.c |   54 ++++++++++----------------
 3 files changed, 23 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/alc_cb.c b/drivers/net/ethernet/atheros/alx/alc_cb.c
index 28c82ca..c6b32ad 100755
--- a/drivers/net/ethernet/atheros/alx/alc_cb.c
+++ b/drivers/net/ethernet/atheros/alx/alc_cb.c
@@ -733,8 +733,7 @@ static int alc_get_fc_mode(struct alx_hw *hw, enum alx_fc_mode *mode)
 				return retval;
 
 			if (!(giga & L1C_GIGA_PSSR_SPD_DPLX_RESOLVED)) {
-				alx_hw_err(hw, "error for speed duplex "
-					   "resolved.\n");
+				alx_hw_err(hw, "error for speed duplex resolved.\n");
 				return -EINVAL;
 			}
 
diff --git a/drivers/net/ethernet/atheros/alx/alf_cb.c b/drivers/net/ethernet/atheros/alx/alf_cb.c
index 4b12df1..fa79bff 100755
--- a/drivers/net/ethernet/atheros/alx/alf_cb.c
+++ b/drivers/net/ethernet/atheros/alx/alf_cb.c
@@ -957,8 +957,7 @@ static int alf_get_fc_mode(struct alx_hw *hw, enum alx_fc_mode *mode)
 				return retval;
 
 			if (!(giga & L1F_GIGA_PSSR_SPD_DPLX_RESOLVED)) {
-				alx_hw_err(hw, "error for speed duplex "
-					   "resolved.\n");
+				alx_hw_err(hw, "error for speed duplex resolved.\n");
 				return -EINVAL;
 			}
 
diff --git a/drivers/net/ethernet/atheros/alx/alx_main.c b/drivers/net/ethernet/atheros/alx/alx_main.c
index 0b71753..64360b4 100755
--- a/drivers/net/ethernet/atheros/alx/alx_main.c
+++ b/drivers/net/ethernet/atheros/alx/alx_main.c
@@ -593,8 +593,7 @@ static int alx_refresh_rx_buffer(struct alx_rx_queue *rxque)
 		wmb();
 		MEM_W16(hw, rxque->produce_reg, rxque->rfq.produce_idx);
 		netif_info(adpt, rx_err, adpt->netdev,
-			   "RX[%d]: prod_reg[0x%x] = 0x%x, "
-			   "rfq.produce_idx = 0x%x\n",
+			   "RX[%d]: prod_reg[0x%x] = 0x%x, rfq.produce_idx = 0x%x\n",
 			   rxque->que_idx, rxque->produce_reg,
 			   rxque->rfq.produce_idx, rxque->rfq.produce_idx);
 	}
@@ -1401,8 +1400,8 @@ static int alx_request_msix_irq(struct alx_adapter *adpt)
 		retval = request_irq(adpt->msix_entries[msix_idx].vector,
 				     handler, 0, msix->name, msix);
 		if (retval) {
-			alx_err(adpt, "request_irq failed for MSIX "
-				"Error: %d\n", retval);
+			alx_err(adpt, "request_irq failed for MSIX, Error: %d\n", 
+				retval);
 			goto free_msix_irq;
 		}
 		/* assign the mask for this irq */
@@ -1436,8 +1435,8 @@ static int alx_request_irq(struct alx_adapter *adpt)
 	if (CHK_ADPT_FLAG(0, MSIX_EN)) {
 		retval = alx_request_msix_irq(adpt);
 		if (retval)
-			alx_err(adpt, "request msix irq failed, "
-				"error = %d.\n", retval);
+			alx_err(adpt, "request msix irq failed, error = %d.\n",
+				retval);
 		goto out;
 	}
 
@@ -1446,8 +1445,8 @@ static int alx_request_irq(struct alx_adapter *adpt)
 		retval = request_irq(adpt->pdev->irq, &alx_interrupt, 0,
 			netdev->name, netdev);
 		if (retval)
-			alx_err(adpt, "request msix irq failed, "
-				"error = %d.\n", retval);
+			alx_err(adpt, "request msix irq failed, error = %d.\n",
+				retval);
 		goto out;
 	}
 
@@ -1455,8 +1454,8 @@ static int alx_request_irq(struct alx_adapter *adpt)
 	retval = request_irq(adpt->pdev->irq, &alx_interrupt, IRQF_SHARED,
 			netdev->name, netdev);
 	if (retval)
-		alx_err(adpt, "request shared irq failed, "
-			"error = %d\n", retval);
+		alx_err(adpt, "request shared irq failed, error = %d\n",
+			retval);
 out:
 	return retval;
 }
@@ -1929,8 +1928,7 @@ static int alx_set_msi_interrupt_mode(struct alx_adapter *adpt)
 	retval = pci_enable_msi(adpt->pdev);
 	if (retval) {
 		netif_info(adpt, probe, adpt->netdev,
-			   "can't enable MSI interrupt. "
-			   "retval: %d\n", retval);
+			   "can't enable MSI interrupt. retval: %d\n", retval);
 		return retval;
 	}
 	SET_ADPT_FLAG(0, MSI_EN);
@@ -1959,8 +1957,7 @@ static int alx_set_interrupt_mode(struct alx_adapter *adpt)
 	}
 
 	netif_info(adpt, probe, adpt->netdev,
-		   "can't enable MSIX and MSI interrupt. "
-		   "then enable Legacy interrupt.\n");
+		   "can't enable MSIX and MSI interrupt then enable Legacy interrupt.\n");
 	retval = 0;
 	return retval;
 }
@@ -2237,8 +2234,7 @@ static int alx_alloc_tx_descriptor(struct alx_adapter *adpt,
 	return 0;
 
 err_alloc_tpq_buffer:
-	alx_err(adpt, "Unable to allocate memory "
-		"for the Tx descriptor.\n");
+	alx_err(adpt, "Unable to allocate memory for the Tx descriptor.\n");
 	return -ENOMEM;
 }
 
@@ -2323,8 +2319,7 @@ err_alloc_swq_buffer:
 	kfree(rxque->rfq.rfbuff);
 	rxque->rfq.rfbuff = NULL;
 err_alloc_rfq_buffer:
-	alx_err(adpt, "Unable to allocate memory "
-		"for the Rx descriptor\n");
+	alx_err(adpt, "Unable to allocate memory for the Rx descriptor\n");
 	return -ENOMEM;
 }
 
@@ -2694,8 +2689,7 @@ static int alx_stop(struct net_device *netdev)
 
 	if (CHK_ADPT_FLAG(1, STATE_RESETTING))
 		netif_warn(adpt, ifdown, adpt->netdev,
-			   "ALX_ADPT_FLAG_1_STATE_RESETTING "
-			   "has already set\n");
+			   "ALX_ADPT_FLAG_1_STATE_RESETTING has already set\n");
 
 	alx_stop_internal(adpt, ALX_OPEN_CTRL_IRQ_EN |
 				ALX_OPEN_CTRL_RESET_MAC);
@@ -3059,8 +3053,7 @@ static void alx_task_routine(struct work_struct *work)
 	/* test state of adapter */
 	if (!CHK_ADPT_FLAG(1, STATE_WATCH_DOG))
 		netif_warn(adpt, timer, adpt->netdev,
-			   "ALX_ADPT_FLAG_1_STATE_WATCH_DOG "
-			   "is not set\n");
+			   "ALX_ADPT_FLAG_1_STATE_WATCH_DOG is not set\n");
 
 	/* reinit task */
 	alx_reinit_task_routine(adpt);
@@ -3180,8 +3173,7 @@ check_sum:
 		cso = skb_transport_offset(skb);
 
 		if (unlikely(cso & 0x1)) {
-			dev_err(&pdev->dev, "pay load offset should not "
-				"be an event number\n");
+			dev_err(&pdev->dev, "pay load offset should not be an event number\n");
 			return -1;
 		} else {
 			css = cso + skb->csum_offset;
@@ -3292,8 +3284,7 @@ netdev_tx_t alx_start_xmit_frame(struct alx_adapter *adpt,
 	}
 
 	netif_info(adpt, tx_err, adpt->netdev,
-		   "before XMIT: TX[%d]: tpq.consume_idx = 0x%x, "
-		   "tpq.produce_idx = 0x%x\n",
+		   "before XMIT: TX[%d]: tpq.consume_idx = 0x%x, tpq.produce_idx = 0x%x\n",
 		   txque->que_idx, txque->tpq.consume_idx,
 		   txque->tpq.produce_idx);
 	memset(&stpd, 0, sizeof(struct alx_tpdesc));
@@ -3503,8 +3494,7 @@ int __devinit alx_init(struct pci_dev *pdev,
 			retval = dma_set_coherent_mask(&pdev->dev,
 						       DMA_BIT_MASK(32));
 			if (retval) {
-				dev_err(&pdev->dev, "No usable DMA "
-					"configuration, aborting\n");
+				dev_err(&pdev->dev, "No usable DMA configuration, aborting\n");
 				goto err_alloc_pci_res_mem;
 			}
 		}
@@ -3650,9 +3640,8 @@ int __devinit alx_init(struct pci_dev *pdev,
 
 	alx_set_register_info_special(adpt);
 
-	netif_dbg(adpt, probe, adpt->netdev, "num_msix_noque_intrs = %d, "
-		  "num_msix_rxque_intrs = %d, "
-		  "num_msix_txque_intrs = %d.\n",
+	netif_dbg(adpt, probe, adpt->netdev,
+		  "num_msix_noque_intrs = %d, num_msix_rxque_intrs = %d, num_msix_txque_intrs = %d.\n",
 		  adpt->num_msix_noques,
 		  adpt->num_msix_rxques,
 		  adpt->num_msix_txques);
@@ -3660,8 +3649,7 @@ int __devinit alx_init(struct pci_dev *pdev,
 		  adpt->num_msix_intrs);
 
 	netif_dbg(adpt, probe, adpt->netdev,
-		  "RX Queue Count = %u, HRX Queue Count = %u, "
-		  "SRX Queue Count = %u, TX Queue Count = %u\n",
+		  "RX Queue Count = %u, HRX Queue Count = %u, SRX Queue Count = %u, TX Queue Count = %u\n",
 		  adpt->num_rxques, adpt->num_hw_rxques, adpt->num_sw_rxques,
 		  adpt->num_txques);
 
-- 
1.7.8.111.gad25c.dirty
