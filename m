From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 4/5] r8169: reduce max MTU for large frames
Date: Tue, 7 Dec 2004 01:17:22 +0100
Message-ID: <20041207001722.GC18672@electric-eye.fr.zoreil.com>
References: <20041119162920.GA26836@lilah.hetzel.org> <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com> <20041122181307.GA3625@lilah.hetzel.org> <20041205235519.GA21885@lilah.hetzel.org> <20041205233756.GB29236@electric-eye.fr.zoreil.com> <20041207001419.GB12838@electric-eye.fr.zoreil.com> <20041207001535.GA18672@electric-eye.fr.zoreil.com> <20041207001621.GB18672@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com,
        Dorn Hetzel <kernel@dorn.hetzel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20041207001621.GB18672@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The device does not support the whole mtu range it claims. Experimenting
with the Tx threshold and/or the PCI burst size does not seem to improve
the behavior.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-265 drivers/net/r8169.c
--- linux-2.6.10-rc2/drivers/net/r8169.c~r8169-265	2004-12-05 22:36:25.000000000 +0100
+++ linux-2.6.10-rc2-fr/drivers/net/r8169.c	2004-12-07 00:54:48.313082500 +0100
@@ -112,7 +112,8 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
-#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC */
+#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... */
+#define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
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
