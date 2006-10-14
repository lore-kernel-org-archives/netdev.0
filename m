From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH 1/5] remove TxStartThresh and RxEarlyThresh
Date: Sat, 14 Oct 2006 15:55:25 -0400
Message-ID: <1160855725.2266.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr7.hinet.net ([168.95.4.107]:49337 "EHLO msr7.hinet.net")
	by vger.kernel.org with ESMTP id S1161003AbWJNILM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2006 04:11:12 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jesse@icplus.com.tw
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Change Logs:
For patent issue need to remove TxStartThresh and RxEarlyThresh. This patent 
is cut-through patent. If use this function, Tx will start to transmit after 
few data be move in to Tx FIFO. We are not allow to use those function in 
DFE530/DFE550/DFE580/DL10050/IP100/IP100A. It will decrease a little 
performance.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
---

 drivers/net/sundance.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

3751714e0fc36905c87a230172d9561c29321833
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 6b8f4ba..a5dd1c3 100755
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
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
-- 
1.3.GIT



