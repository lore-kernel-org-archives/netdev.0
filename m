From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [net-next-2.6 #2 02/08] r8169: identify different registers.
Date: Tue, 4 Jan 2011 02:07:42 +0100
Message-ID: <20110104010742.GC5957@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <benh@debian.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42056 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab1ADBHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 20:07:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation (sort of).

The location are the same, the values are the same but it is
just accidental. Note that the 810x could cope with a smaller
value as it does not support jumbo frames.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3124462..33c3fbf 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -67,7 +67,6 @@ static const int multicast_filter_limit = 32;
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
-#define EarlyTxThld	0x3F	/* 0x3F means NO early transmit */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
@@ -231,7 +230,14 @@ enum rtl_registers {
 	IntrMitigate	= 0xe2,
 	RxDescAddrLow	= 0xe4,
 	RxDescAddrHigh	= 0xe8,
-	EarlyTxThres	= 0xec,
+	EarlyTxThres	= 0xec,	/* 8169. Unit of 32 bytes. */
+
+#define NoEarlyTx	0x3f	/* Max value : no early transmit. */
+
+	MaxTxPacketSize	= 0xec,	/* 8101/8168. Unit of 128 bytes. */
+
+#define TxPacketMax	(8064 >> 7)
+
 	FuncEvent	= 0xf0,
 	FuncEventMask	= 0xf4,
 	FuncPresetState	= 0xf8,
@@ -2901,7 +2907,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(EarlyTxThres, NoEarlyTx);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
@@ -3036,7 +3042,7 @@ static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
 {
 	rtl_hw_start_8168bb(ioaddr, pdev);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
@@ -3091,7 +3097,7 @@ static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
 	/* Magic. */
 	RTL_W8(DBG_REG, 0x20);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -3147,7 +3153,7 @@ static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	rtl_disable_clock_request(pdev);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -3162,7 +3168,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
@@ -3342,7 +3348,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
-- 
1.7.3.4

