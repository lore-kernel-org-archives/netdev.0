From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH 1/2] r8169: Jumbo Frames mini-increase
Date: Mon, 28 Feb 2005 11:27:53 -0600
Message-ID: <20050228172753.GA13280@us.ibm.com>
References: <4220ADA6.2040506@phekda.gotadsl.co.uk> <20050226203518.GA14688@electric-eye.fr.zoreil.com> <42224CF5.5090601@phekda.gotadsl.co.uk> <20050227235210.GA27271@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050227235210.GA27271@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch increases the maximum MTU from ~7k to 8169 (the maximum MTU
that will fit into a single descriptor).  

Applies cleanly to linux-2.6.11-rc4-mm1 and tested on amd64

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- drivers/net/r8169.c.orig	2005-02-26 12:38:54.000000000 -0600
+++ drivers/net/r8169.c	2005-02-27 11:10:19.000000000 -0600
@@ -117,8 +117,9 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
+#define LargeSendETT	0x35
 #define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... */
-#define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
+#define SafeMtu		0x1FE9	/* Largest MTU that can fit in a single desc */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
@@ -1576,8 +1577,12 @@ rtl8169_hw_start(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-	RTL_W8(EarlyTxThres, EarlyTxThld);
 
+	if (dev->mtu < 7400)
+		RTL_W8(EarlyTxThres, EarlyTxThld);
+	else
+		RTL_W8(EarlyTxThres, LargeSendETT);
+			
 	/* For gigabit rtl8169, MTU + header + CRC + VLAN */
 	RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
