From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 3/9] net/irda: remove trailing space in messages
Date: Wed, 24 Mar 2010 18:57:30 +0100
Message-ID: <1269453456-13599-3-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>, Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml105.kpnxchange.com ([195.121.3.9]:55517 "EHLO
	CPSMTPM-EML105.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756653Ab0CXR5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 13:57:39 -0400
In-Reply-To: <201003241840.18701.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes a minor consistency improvement between two related
debug messages.

Signed-off-by: Frans Pop <elendil@planet.nl>
Cc: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/ali-ircc.c |   32 ++++++++++++++++----------------
 drivers/net/irda/irda-usb.c |    2 +-
 drivers/net/irda/vlsi_ir.c  |    4 ++--
 3 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 12c7b00..a32c97e 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -753,18 +753,18 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 			if(OldMessageCount > ((self->LineStatus+1) & 0x07))
 			{
 				self->rcvFramesOverflow = TRUE;	
-				IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ******** \n", __func__);
+				IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ********\n", __func__);
 			}
 						
 			if (ali_ircc_dma_receive_complete(self))
 			{
-				IRDA_DEBUG(1, "%s(), ******* receive complete ******** \n", __func__);
+				IRDA_DEBUG(1, "%s(), ******* receive complete ********\n", __func__);
 				
 				self->ier = IER_EOM;				
 			}
 			else
 			{
-				IRDA_DEBUG(1, "%s(), ******* Not receive complete ******** \n", __func__);
+				IRDA_DEBUG(1, "%s(), ******* Not receive complete ********\n", __func__);
 				
 				self->ier = IER_EOM | IER_TIMER;								
 			}	
@@ -777,7 +777,7 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 		if(OldMessageCount > ((self->LineStatus+1) & 0x07))
 		{
 			self->rcvFramesOverflow = TRUE;	
-			IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ******* \n", __func__);
+			IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE *******\n", __func__);
 		}
 		/* Disable Timer */
 		switch_bank(iobase, BANK1);
@@ -942,7 +942,7 @@ static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self)
 			// benjamin 2000/11/10 06:32PM
 			if (self->io.speed > 115200)
 			{
-				IRDA_DEBUG(2, "%s(), ali_ircc_change_speed from UART_LSR_TEMT \n", __func__ );
+				IRDA_DEBUG(2, "%s(), ali_ircc_change_speed from UART_LSR_TEMT\n", __func__ );
 					
 				self->ier = IER_EOM;
 				// SetCOMInterrupts(self, TRUE);							
@@ -970,7 +970,7 @@ static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
 	
 	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
-	IRDA_DEBUG(2, "%s(), setting speed = %d \n", __func__ , baud);
+	IRDA_DEBUG(2, "%s(), setting speed = %d\n", __func__ , baud);
 	
 	/* This function *must* be called with irq off and spin-lock.
 	 * - Jean II */
@@ -1500,7 +1500,7 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 			diff = self->now.tv_usec - self->stamp.tv_usec;
 			/* self->stamp is set from ali_ircc_dma_receive_complete() */
 							
-			IRDA_DEBUG(1, "%s(), ******* diff = %d ******* \n", __func__ , diff);
+			IRDA_DEBUG(1, "%s(), ******* diff = %d *******\n", __func__ , diff);
 			
 			if (diff < 0) 
 				diff += 1000000;
@@ -1641,7 +1641,7 @@ static void ali_ircc_dma_xmit(struct ali_ircc_cb *self)
 	tmp = inb(iobase+FIR_LCR_B);
 	tmp &= ~0x20; // Disable SIP
 	outb(((unsigned char)(tmp & 0x3f) | LCR_B_TX_MODE) & ~LCR_B_BW, iobase+FIR_LCR_B);
-	IRDA_DEBUG(1, "%s(), ******* Change to TX mode: FIR_LCR_B = 0x%x ******* \n", __func__ , inb(iobase+FIR_LCR_B));
+	IRDA_DEBUG(1, "%s(), *** Change to TX mode: FIR_LCR_B = 0x%x ***\n", __func__ , inb(iobase+FIR_LCR_B));
 	
 	outb(0, iobase+FIR_LSR);
 			
@@ -1768,7 +1768,7 @@ static int ali_ircc_dma_receive(struct ali_ircc_cb *self)
 	//switch_bank(iobase, BANK0);
 	tmp = inb(iobase+FIR_LCR_B);
 	outb((unsigned char)(tmp &0x3f) | LCR_B_RX_MODE | LCR_B_BW , iobase + FIR_LCR_B); // 2000/12/1 05:16PM
-	IRDA_DEBUG(1, "%s(), *** Change To RX mode: FIR_LCR_B = 0x%x *** \n", __func__ , inb(iobase+FIR_LCR_B));
+	IRDA_DEBUG(1, "%s(), *** Change To RX mode: FIR_LCR_B = 0x%x ***\n", __func__ , inb(iobase+FIR_LCR_B));
 			
 	/* Set Rx Threshold */
 	switch_bank(iobase, BANK1);
@@ -1840,7 +1840,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 		/* Check for errors */
 		if ((status & 0xd8) || self->rcvFramesOverflow || (len==0)) 		
 		{
-			IRDA_DEBUG(0,"%s(), ************* RX Errors ************ \n", __func__ );
+			IRDA_DEBUG(0,"%s(), ************* RX Errors ************\n", __func__ );
 			
 			/* Skip frame */
 			self->netdev->stats.rx_errors++;
@@ -1850,29 +1850,29 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			if (status & LSR_FIFO_UR) 
 			{
 				self->netdev->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* FIFO Errors ************ \n", __func__ );
+				IRDA_DEBUG(0,"%s(), ************* FIFO Errors ************\n", __func__ );
 			}	
 			if (status & LSR_FRAME_ERROR)
 			{
 				self->netdev->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* FRAME Errors ************ \n", __func__ );
+				IRDA_DEBUG(0,"%s(), ************* FRAME Errors ************\n", __func__ );
 			}
 							
 			if (status & LSR_CRC_ERROR) 
 			{
 				self->netdev->stats.rx_crc_errors++;
-				IRDA_DEBUG(0,"%s(), ************* CRC Errors ************ \n", __func__ );
+				IRDA_DEBUG(0,"%s(), ************* CRC Errors ************\n", __func__ );
 			}
 			
 			if(self->rcvFramesOverflow)
 			{
 				self->netdev->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* Overran DMA buffer ************ \n", __func__ );
+				IRDA_DEBUG(0,"%s(), ************* Overran DMA buffer ************\n", __func__ );
 			}
 			if(len == 0)
 			{
 				self->netdev->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ********** Receive Frame Size = 0 ********* \n", __func__ );
+				IRDA_DEBUG(0,"%s(), ********** Receive Frame Size = 0 *********\n", __func__ );
 			}
 		}	 
 		else 
@@ -1884,7 +1884,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 				val = inb(iobase+FIR_BSR);	
 				if ((val& BSR_FIFO_NOT_EMPTY)== 0x80) 
 				{
-					IRDA_DEBUG(0, "%s(), ************* BSR_FIFO_NOT_EMPTY ************ \n", __func__ );
+					IRDA_DEBUG(0, "%s(), ************* BSR_FIFO_NOT_EMPTY ************\n", __func__ );
 					
 					/* Put this entry back in fifo */
 					st_fifo->head--;
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 2c9b3af..4441fa3 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -839,7 +839,7 @@ static void irda_usb_receive(struct urb *urb)
 			/* Usually precursor to a hot-unplug on OHCI. */
 		default:
 			self->netdev->stats.rx_errors++;
-			IRDA_DEBUG(0, "%s(), RX status %d, transfer_flags 0x%04X \n", __func__, urb->status, urb->transfer_flags);
+			IRDA_DEBUG(0, "%s(), RX status %d, transfer_flags 0x%04X\n", __func__, urb->status, urb->transfer_flags);
 			break;
 		}
 		/* If we received an error, we don't want to resubmit the
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 209d4bc..e145052 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1742,7 +1742,7 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 	vlsi_irda_dev_t *idev;
 
 	if (!ndev) {
-		IRDA_ERROR("%s - %s: no netdevice \n",
+		IRDA_ERROR("%s - %s: no netdevice\n",
 			   __func__, pci_name(pdev));
 		return 0;
 	}
@@ -1781,7 +1781,7 @@ static int vlsi_irda_resume(struct pci_dev *pdev)
 	vlsi_irda_dev_t	*idev;
 
 	if (!ndev) {
-		IRDA_ERROR("%s - %s: no netdevice \n",
+		IRDA_ERROR("%s - %s: no netdevice\n",
 			   __func__, pci_name(pdev));
 		return 0;
 	}
-- 
1.6.6.1

