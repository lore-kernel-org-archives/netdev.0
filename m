From: akpm@osdl.org
Subject: [patch 08/10] r8169: reduce max MTU for large frames
Date: Tue, 04 Jan 2005 21:59:34 -0800
Message-ID: <200501050559.j055xh614717@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org,
        romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Francois Romieu <romieu@fr.zoreil.com>

The device does not support the whole mtu range it claims. Experimenting
with the Tx threshold and/or the PCI burst size does not seem to improve
the behavior.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/r8169.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -puN drivers/net/r8169.c~r8169-reduce-max-mtu-for-large-frames drivers/net/r8169.c
--- 25/drivers/net/r8169.c~r8169-reduce-max-mtu-for-large-frames	2005-01-04 21:57:36.322612408 -0800
+++ 25-akpm/drivers/net/r8169.c	2005-01-04 21:57:44.698339104 -0800
@@ -112,7 +112,8 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
-#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC */
+#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... */
+#define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
@@ -1593,7 +1594,7 @@ static int rtl8169_change_mtu(struct net
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int ret = 0;
 
-	if (new_mtu < ETH_ZLEN || new_mtu > RxPacketMaxSize)
+	if (new_mtu < ETH_ZLEN || new_mtu > SafeMtu)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
_
