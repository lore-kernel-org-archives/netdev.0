From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [PATCH 2.6.20 4/5] s2io: Removed enabling of some of the unused
 interrupts.
Date: Fri, 19 Jan 2007 02:45:14 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10701190243190.22012-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, alicia.pena@neterion.com,
	ramkrishna.vepa@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com, sriram.rapuru@neterion.com,
	ananda.raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:59296 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964852AbXASHpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 02:45:16 -0500
To: netdev@vger.kernel.org, jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed unused code in en_dis_able_nic_intrs(), TX_DMA_INTR, RX_DMA_INTR,
TX_XGXS_INTR, MC_INTR

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch3/drivers/net/s2io.c patch4/drivers/net/s2io.c
--- patch3/drivers/net/s2io.c	2007-01-08 23:38:48.000000000 +0530
+++ patch4/drivers/net/s2io.c	2007-01-09 01:12:42.000000000 +0530
@@ -1659,7 +1659,7 @@ static void en_dis_able_nic_intrs(struct
 	/*  PIC Interrupts */
 	if ((mask & (TX_PIC_INTR | RX_PIC_INTR))) {
 		/*  Enable PIC Intrs in the general intr mask register */
-		val64 = TXPIC_INT_M | PIC_RX_INT_M;
+		val64 = TXPIC_INT_M;
 		if (flag == ENABLE_INTRS) {
 			temp64 = readq(&bar0->general_int_mask);
 			temp64 &= ~((u64) val64);
@@ -1697,70 +1697,6 @@ static void en_dis_able_nic_intrs(struct
 		}
 	}
 
-	/*  DMA Interrupts */
-	/*  Enabling/Disabling Tx DMA interrupts */
-	if (mask & TX_DMA_INTR) {
-		/* Enable TxDMA Intrs in the general intr mask register */
-		val64 = TXDMA_INT_M;
-		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
-			/*
-			 * Keep all interrupts other than PFC interrupt
-			 * and PCC interrupt disabled in DMA level.
-			 */
-			val64 = DISABLE_ALL_INTRS & ~(TXDMA_PFC_INT_M |
-						      TXDMA_PCC_INT_M);
-			writeq(val64, &bar0->txdma_int_mask);
-			/*
-			 * Enable only the MISC error 1 interrupt in PFC block
-			 */
-			val64 = DISABLE_ALL_INTRS & (~PFC_MISC_ERR_1);
-			writeq(val64, &bar0->pfc_err_mask);
-			/*
-			 * Enable only the FB_ECC error interrupt in PCC block
-			 */
-			val64 = DISABLE_ALL_INTRS & (~PCC_FB_ECC_ERR);
-			writeq(val64, &bar0->pcc_err_mask);
-		} else if (flag == DISABLE_INTRS) {
-			/*
-			 * Disable TxDMA Intrs in the general intr mask
-			 * register
-			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->txdma_int_mask);
-			writeq(DISABLE_ALL_INTRS, &bar0->pfc_err_mask);
-			temp64 = readq(&bar0->general_int_mask);
-			val64 |= temp64;
-			writeq(val64, &bar0->general_int_mask);
-		}
-	}
-
-	/*  Enabling/Disabling Rx DMA interrupts */
-	if (mask & RX_DMA_INTR) {
-		/*  Enable RxDMA Intrs in the general intr mask register */
-		val64 = RXDMA_INT_M;
-		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
-			/*
-			 * All RxDMA block interrupts are disabled for now
-			 * TODO
-			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);
-		} else if (flag == DISABLE_INTRS) {
-			/*
-			 * Disable RxDMA Intrs in the general intr mask
-			 * register
-			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);
-			temp64 = readq(&bar0->general_int_mask);
-			val64 |= temp64;
-			writeq(val64, &bar0->general_int_mask);
-		}
-	}
-
 	/*  MAC Interrupts */
 	/*  Enabling/Disabling MAC interrupts */
 	if (mask & (TX_MAC_INTR | RX_MAC_INTR)) {
@@ -1787,53 +1723,6 @@ static void en_dis_able_nic_intrs(struct
 		}
 	}
 
-	/*  XGXS Interrupts */
-	if (mask & (TX_XGXS_INTR | RX_XGXS_INTR)) {
-		val64 = TXXGXS_INT_M | RXXGXS_INT_M;
-		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
-			/*
-			 * All XGXS block error interrupts are disabled for now
-			 * TODO
-			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);
-		} else if (flag == DISABLE_INTRS) {
-			/*
-			 * Disable MC Intrs in the general intr mask register
-			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);
-			temp64 = readq(&bar0->general_int_mask);
-			val64 |= temp64;
-			writeq(val64, &bar0->general_int_mask);
-		}
-	}
-
-	/*  Memory Controller(MC) interrupts */
-	if (mask & MC_INTR) {
-		val64 = MC_INT_M;
-		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
-			/*
-			 * Enable all MC Intrs.
-			 */
-			writeq(0x0, &bar0->mc_int_mask);
-			writeq(0x0, &bar0->mc_err_mask);
-		} else if (flag == DISABLE_INTRS) {
-			/*
-			 * Disable MC Intrs in the general intr mask register
-			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);
-			temp64 = readq(&bar0->general_int_mask);
-			val64 |= temp64;
-			writeq(val64, &bar0->general_int_mask);
-		}
-	}
-
-
 	/*  Tx traffic interrupts */
 	if (mask & TX_TRAFFIC_INTR) {
 		val64 = TXTRAFFIC_INT_M;

