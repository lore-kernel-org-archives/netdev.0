From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 3/7] 2.6.6-rc3-mm1 - r8169 register rename
Date: Sat, 1 May 2004 02:26:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501022654.C500@electric-eye.fr.zoreil.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com> <20040501022439.A500@electric-eye.fr.zoreil.com> <20040501022552.B500@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, Jon D Mason <jonmason@us.ibm.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040501022552.B500@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, May 01, 2004 at 02:25:52AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


RxUnderrun status bit renamed to LinkChg (identical to the 8139cp driver).


diff -puN drivers/net/r8169.c~r8169-register-rename drivers/net/r8169.c
--- linux-2.6.6-rc3/drivers/net/r8169.c~r8169-register-rename	2004-05-01 01:46:33.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/r8169.c	2004-05-01 01:46:33.000000000 +0200
@@ -203,7 +203,7 @@ enum RTL8169_register_content {
 	SWInt = 0x0100,
 	TxDescUnavail = 0x80,
 	RxFIFOOver = 0x40,
-	RxUnderrun = 0x20,
+	LinkChg = 0x20,
 	RxOverflow = 0x10,
 	TxErr = 0x08,
 	TxOK = 0x04,
@@ -359,9 +359,9 @@ static int rtl8169_poll(struct net_devic
 #endif
 
 static const u16 rtl8169_intr_mask =
-	RxUnderrun | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
+	LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
 static const u16 rtl8169_napi_event =
-	RxOK | RxUnderrun | RxOverflow | RxFIFOOver | TxOK | TxErr;
+	RxOK | LinkChg | RxOverflow | RxFIFOOver | TxOK | TxErr;
 static const unsigned int rtl8169_rx_config =
     (RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
@@ -1569,7 +1569,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 
 		handled = 1;
 /*
-		if (status & RxUnderrun)
+		if (status & LinkChg)
 			link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
 */
 		status &= tp->intr_mask;
@@ -1592,7 +1592,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 		break;
 #else
 		// Rx interrupt 
-		if (status & (RxOK | RxUnderrun | RxOverflow | RxFIFOOver)) {
+		if (status & (RxOK | LinkChg | RxOverflow | RxFIFOOver)) {
 			rtl8169_rx_interrupt(dev, tp, ioaddr);
 		}
 		// Tx interrupt

_
