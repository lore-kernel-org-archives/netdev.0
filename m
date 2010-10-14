From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] net: move MII outside of NET_ETHERNET, fix kconfig
 warning
Date: Wed, 13 Oct 2010 18:18:59 -0700
Message-ID: <20101013181859.fc3a96fd.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm <akpm@linux-foundation.org>, Jeff Garzik <jgarzik@pobox.com>,
	davem@davemloft.net
To: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

We have USB, PCMCIA, and gigabit ethernet drivers that select
MII even though NET_ETHERNET is not enabled, so make MII not
be dependent on NET_ETHERNET.  It is still dependent on NET
and NETDEVICES.

Fixes kconfig unmet dependency warning (shortened, was very long string):

warning: (ARM_AT91_ETHER && NETDEVICES && NET_ETHERNET && ARM && ARCH_AT91RM9200 || ARM_KS8695_ETHER && NETDEVICES && NET_ETHERNET && ARM && ARCH_KS8695 || ... || IP1000 && NETDEVICES && NETDEV_1000 && PCI && EXPERIMENTAL || HAMACHI && NETDEVICES && NETDEV_1000 && PCI || R8169 && NETDEVICES && NETDEV_1000 && PCI || SIS190 && NETDEVICES && NETDEV_1000 && PCI || VIA_VELOCITY && NETDEVICES && NETDEV_1000 && PCI || ATL1 && NETDEVICES && NETDEV_1000 && PCI || ATL1E && NETDEVICES && NETDEV_1000 && PCI && EXPERIMENTAL || ATL1C && NETDEVICES && NETDEV_1000 && PCI && EXPERIMENTAL || JME && NETDEVICES && NETDEV_1000 && PCI || STMMAC_ETH && NETDEV_1000 && NETDEVICES && HAS_IOMEM || USB_PEGASUS && NETDEVICES && USB && NET || USB_RTL8150 && NETDEVICES && USB && NET && EXPERIMENTAL || USB_USBNET && NETD
 EVICES && USB && NET || PCMCIA_SMC91C92 && NETDEVICES && NET_PCMCIA && PCMCIA) selects MII which has unmet direct dependencies (NETDEVICES && NET_ETHERNET)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Acked-by: Jeff Garzik <jgarzik@pobox.com> [2006-NOV-30]
---
 drivers/net/Kconfig |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- linux-next-20101013.orig/drivers/net/Kconfig
+++ linux-next-20101013/drivers/net/Kconfig
@@ -180,6 +180,13 @@ config NET_SB1000
 
 source "drivers/net/arcnet/Kconfig"
 
+config MII
+	tristate "Generic Media Independent Interface device support"
+	help
+	  Most ethernet controllers have MII transceiver either as an external
+	  or internal device.  It is safe to say Y or M here even if your
+	  ethernet card lacks MII.
+
 source "drivers/net/phy/Kconfig"
 
 #
@@ -215,13 +222,6 @@ menuconfig NET_ETHERNET
 
 if NET_ETHERNET
 
-config MII
-	tristate "Generic Media Independent Interface device support"
-	help
-	  Most ethernet controllers have MII transceiver either as an external
-	  or internal device.  It is safe to say Y or M here even if your
-	  ethernet card lack MII.
-
 config MACB
 	tristate "Atmel MACB support"
 	depends on HAVE_NET_MACB
