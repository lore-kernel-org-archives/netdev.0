From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.10-rc2-netdev1 4/4] r8169: reduce max MTU for large frames
Date: Tue, 16 Nov 2004 23:36:04 +0100
Message-ID: <20041116223604.GC16781@electric-eye.fr.zoreil.com>
References: <20041116223040.GA16715@electric-eye.fr.zoreil.com> <20041116223332.GA16781@electric-eye.fr.zoreil.com> <20041116223439.GB16781@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041116223439.GB16781@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The device does not support the whole mtu range it claims. Experimenting
with the Tx threshold and/or the PCI burst size does not seem to improve
the behavior.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-265 drivers/net/r8169.c
--- linux-2.6.10-rc2-mm1.orig/drivers/net/r8169.c~r8169-265	2004-11-16 22:26:06.000000000 +0100
+++ linux-2.6.10-rc2-mm1/drivers/net/r8169.c	2004-11-16 22:26:06.000000000 +0100
@@ -112,7 +112,8 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
-#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC */
+#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... */
+#define SafeMtu		0x1964	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
@@ -1592,9 +1593,9 @@ static int rtl8169_change_mtu(struct net
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int ret = 0;
 
-	if (new_mtu < ETH_ZLEN || new_mtu > RxPacketMaxSize)
+	if (new_mtu < ETH_ZLEN || new_mtu > SafeMtu)
 		return -EINVAL;
-	
+
 	dev->mtu = new_mtu;
 
 	if (!netif_running(dev)) 

_
