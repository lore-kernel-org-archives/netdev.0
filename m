From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 1/2] r8169: Jumbo Frames mini-increase
Date: Mon, 28 Feb 2005 13:41:07 -0600
Message-ID: <20050228194107.GA13533@us.ibm.com>
References: <4220ADA6.2040506@phekda.gotadsl.co.uk> <20050226203518.GA14688@electric-eye.fr.zoreil.com> <42224CF5.5090601@phekda.gotadsl.co.uk> <20050227235210.GA27271@electric-eye.fr.zoreil.com> <20050228172753.GA13280@us.ibm.com> <20050228193204.GA8186@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050228193204.GA8186@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2005 at 08:32:04PM +0100, Francois Romieu wrote:
[...]
> 1 - Any objection against ternary operator, say:
> 
> 	RTL_W8(EarlyTxThres, (dev->mtu < 7400) ? EarlyTxThld : LargeSendETT);

Sorry, one of these days I'll learn.

> 2 - patch includes uneeded tabs on the last added (empty) line.

Removed.  See rediff below.

--- drivers/net/r8169.c.orig	2005-02-27 20:26:22.000000000 -0600
+++ drivers/net/r8169.c	2005-02-28 13:40:29.000000000 -0600
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
@@ -1576,7 +1577,7 @@ rtl8169_hw_start(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(EarlyTxThres, (dev->mtu < 7400) ? EarlyTxThld : LargeSendETT);
 
 	/* For gigabit rtl8169, MTU + header + CRC + VLAN */
 	RTL_W16(RxMaxSize, tp->rx_buf_sz);
