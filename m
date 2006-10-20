From: akpm@osdl.org
Subject: [patch 3/8] sundance: remove TxStartThresh and RxEarlyThresh
Date: Fri, 20 Oct 2006 14:42:05 -0700
Message-ID: <200610202142.k9KLg5W6003719@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25220 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992758AbWJTVnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:02 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

For patent issue need to remove TxStartThresh and RxEarlyThresh.  This patent
is cut-through patent.  If use this function, Tx will start to transmit after
few data be move in to Tx FIFO.  We are not allow to use those function in
DFE530/DFE550/DFE580/DL10050/IP100/IP100A.  It will decrease a little
performance.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/sundance.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff -puN drivers/net/sundance.c~sundance-remove-txstartthresh-and-rxearlythresh drivers/net/sundance.c
--- a/drivers/net/sundance.c~sundance-remove-txstartthresh-and-rxearlythresh
+++ a/drivers/net/sundance.c
@@ -264,8 +264,6 @@ enum alta_offsets {
 	ASICCtrl = 0x30,
 	EEData = 0x34,
 	EECtrl = 0x36,
-	TxStartThresh = 0x3c,
-	RxEarlyThresh = 0x3e,
 	FlashAddr = 0x40,
 	FlashData = 0x44,
 	TxStatus = 0x46,
@@ -1111,6 +1109,7 @@ static irqreturn_t intr_handler(int irq,
 	int tx_cnt;
 	int tx_status;
 	int handled = 0;
+	int i;
 
 
 	do {
@@ -1153,17 +1152,14 @@ static irqreturn_t intr_handler(int irq,
 						np->stats.tx_fifo_errors++;
 					if (tx_status & 0x02)
 						np->stats.tx_window_errors++;
+
 					/*
 					** This reset has been verified on
 					** DFE-580TX boards ! phdm@macqel.be.
 					*/
 					if (tx_status & 0x10) {	/* TxUnderrun */
-						unsigned short txthreshold;
-
-						txthreshold = ioread16 (ioaddr + TxStartThresh);
 						/* Restart Tx FIFO and transmitter */
 						sundance_reset(dev, (NetworkReset|FIFOReset|TxReset) << 16);
-						iowrite16 (txthreshold, ioaddr + TxStartThresh);
 						/* No need to reset the Tx pointer here */
 					}
 					/* Restart the Tx. */
_
