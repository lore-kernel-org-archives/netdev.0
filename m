From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Tue, 08 Mar 2005 14:31:45 -0500
Message-ID: <422DFDA1.6080108@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040800020201020107010706"
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040800020201020107010706
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Changes:
* viro's iomap/iomem updates
* ham, mv643xx, orinoco updates
* sis900, via-rhine updates

--------------040800020201020107010706
Content-Type: text/plain;
 name="changelog.txt"
Content-Disposition: inline;
 filename="changelog.txt"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j28Jaa3A025755

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/Kconfig                   |    5=20
 drivers/net/fealnx.c                  |  275 +--
 drivers/net/hamradio/6pack.c          |    4=20
 drivers/net/hamradio/baycom_epp.c     |   53=20
 drivers/net/hamradio/baycom_par.c     |    8=20
 drivers/net/hamradio/baycom_ser_fdx.c |    7=20
 drivers/net/hamradio/baycom_ser_hdx.c |    7=20
 drivers/net/hamradio/bpqether.c       |   19=20
 drivers/net/hamradio/dmascc.c         | 2073 +++++++++++++-------------
 drivers/net/hamradio/hdlcdrv.c        |   48=20
 drivers/net/hamradio/mkiss.c          |   12=20
 drivers/net/hamradio/yam.c            |   38=20
 drivers/net/mv643xx_eth.c             | 2687 +++++++++++++++++++--------=
-------
 drivers/net/mv643xx_eth.h             |  641 +++-----
 drivers/net/sis900.c                  |  216 +-
 drivers/net/via-rhine.c               |    4=20
 drivers/net/wireless/airport.c        |   22=20
 drivers/net/wireless/hermes.c         |   72=20
 drivers/net/wireless/hermes.h         |   64=20
 drivers/net/wireless/orinoco.c        |  419 +++--
 drivers/net/wireless/orinoco.h        |   37=20
 drivers/net/wireless/orinoco_cs.c     |   49=20
 drivers/net/wireless/orinoco_pci.c    |  124 -
 drivers/net/wireless/orinoco_plx.c    |  235 +-
 drivers/net/wireless/orinoco_tmd.c    |  150 +
 include/linux/mv643xx.h               |  448 ++++-
 26 files changed, 4187 insertions(+), 3530 deletions(-)

through these ChangeSets:

<dfarnsworth:mvista.com>:
  o [netdrvr mv643xx] Big rename
  o [netdrvr mv643xx] Rename MV_READ =3D> mv_read and MV_WRITE =3D> mv_wr=
ite
  o [netdrvr mv643xx] Additional whitespace cleanups, mostly changing spa=
ces to tabs in comments
  o [netdrvr mv643xx] Run mv643xx_eth.[ch] through scripts/Lindent
  o [netdrvr mv643xx] Add a function to detect at runtime whether a PHY i=
s attached to the specified port, and use it to cause the probe routine t=
o fail when there is no PHY.
  o [netdrvr mv643xx] This one liner removes a spurious left paren fixing=
 an obvious syntax error in the #ifndef MV64340_NAPI case
  o [netdrvr mv643xx] Add support for PHYs/boards that don't support auto=
negotiation
  o [netdrvr mv643xx] With this patch, the driver now calls netif_carrier=
_off/netif_carrier_on
  o [netdrvr mv643xx] This patch cleans up the handling of receive skb si=
zing

<mbrancaleoni:tiscali.it>:
  o sis900.c net poll support

<takis:lumumba.luc.ac.be>:
  o Possible VIA-Rhine free irq issue

Alexander Viro:
  o fealnx iomem annotations, switch to io{read,write}
  o wireless iomem annotations and fixes, switch to io{read,write}

Andrew Morton:
  o VIA-Rhine: undork whitespace

Dale Farnsworth:
  o mv643xx: remove superfluous function, mv643xx_set_ethtool_ops
  o mv643xx: raise size of receive skbs to allow for an optional VLAN tag
  o [netdrvr mv643xx] Remove call to msleep() while locks are held.  We d=
on't really need to wait for the link to come up.  It was a workaround to=
 avoid a transient error message, "Virtual device %s asks to queue packet=
!\n", in dev_queue_xmit() when called by ic_bootp_send_if().  This happen=
s because right after opening the network device, there is a pending PHY =
status change interrupt causing the driver to call netif_stop_queue().  A=
 half second later, the link comes up and all is well.  We could have mov=
ed the call to msleep() to mv643xx_eth_open() to perpetuate the workaroun=
d, but I think it's best to remove it entirely.
  o [netdrvr mv643xx] Ensure that we only change the Port Serial Control =
Reg while the port is disabled.
  o [netdrvr mv643xx] Add ethtool support to the mv643xx ethernet driver
  o [netdrvr mv643xx] Enable the mv643xx ethernet support on platforms us=
ing the MV64360 chip
  o [netdrvr mv643xx] Disable tcp/udp checksum offload to hardware.  It g=
enerally works, but the hardware appears to generate the wrong checksum i=
f the hw checksum generation wasn't used in the previous packet sent.
  o [netdrvr mv643xx] We already set ETH_TX_ENABLE_INTERRUPT whenever we =
set ETH_TX_LAST_DESC
  o [netdrvr mv643xx] Update tx_bytes statistic when using hw tcp/udp che=
cksum generation
  o [netdrvr mv643xx] Call netif_carrier_off when closing the driver
  o [netdrvr mv643xx] Trivial.  Remove repeated comment
  o [netdrvr mv643xx] Clear transmit l4i_chk even when the hardware ignor=
es it
  o [netdrvr mv643xx] Increment tx_ring_skbs before calling eth_port_send=
, since
  o [netdrvr mv643xx] Fix handling of unaligned tiny fragments not handle=
d by hardware Check all fragments instead of just the last.
  o [netdrvr mv643xx] Fix a few places I missed in the previous rename pa=
tch
  o [netdrvr mv643xx] This patch simplifies the mv64340_eth_set_rx_mode f=
unction without changing its behavior.
  o [netdrvr mv643xx] This patch makes the use of the MV64340_RX_QUEUE_FI=
LL_ON_TASK config macro more consistent, though the macro remains undefin=
ed, since the feature still does not work properly.
  o [netdrvr mv643xx] This patch adds support for passing additional para=
meters via the platform_device interface.  These additional parameters ar=
e:
  o [netdrvr mv643xx] This patch adds device driver model support to the =
mv643xx_eth driver
  o [netdrvr mv643xx] This patch replaces the use of the pci_map_* functi=
ons with the corresponding dma_map_* functions.
  o [netdrvr mv643xx] This patch fixes the code that enables hardware che=
cksum generation
  o [netdrvr mv643xx] This patch removes spin delays (count to 1000000, u=
gh) and instead waits with udelay or msleep for hardware flags to change.
  o [netdrvr mv643xx] This patch removes code that is redundant or useles=
s

Daniele Venzano:
  o sis900: chiprev i/o cleanups
  o sis900: debugging output update
  o sis900 printk audit
  o sis900: version bump; remove broken URL
  o sis900: add infrastructure needed for standard netif messages

David Gibson:
  o Orinoco driver updates - cleanup PCI initialization
  o Orinoco driver updates - PCMCIA initialization cleanups
  o Orinoco driver updates - update version and changelog
  o Orinoco driver updates - update firmware detection
  o Orinoco driver updates - WEP updates
  o Orinoco driver updates - delay Tx wake
  o Orinoco driver updates - prohibit IBSS with no ESSID
  o Orinoco driver updates - update is_ethersnap()
  o Orinoco driver updates - PCMCIA initialization cleanups
  o Orinoco driver updates - use modern module_parm()
  o Orinoco driver updates - cleanup PCI initialization
  o Orinoco driver updates - cleanup low-level code
  o Orinoco driver updates - add free_orinocodev()
  o Orinoco driver updates - use mdelay()/ssleep() more
  o Orinoco driver updates - update printk()s
  o Orinoco driver updates - use netif_carrier_*()

Ralf B=E4chle:
  o Remove unused MAXBPQDEV definition
  o Sparse fixes for drivers/net/hamradio
  o Reformat DMASCC driver
  o Use netdev_priv in baycom_epp driver
  o Use netdev_priv in baycom_ser_fdx driver
  o Use netdev_priv in hdlcdrv driver
  o Use netdev_priv in baycom_ser_hdx driver
  o Use netdev_priv in baycom_par driver
  o Use netdev_priv in bpqether driver
  o Use netdev_priv in mkiss driver
  o Use netdev_priv in YAM driver


--------------040800020201020107010706
Content-Type: text/plain;
 name="patch"
Content-Disposition: inline;
 filename="patch"
Content-Transfer-Encoding: 7bit

diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/Kconfig	2005-03-08 14:29:45 -05:00
@@ -2066,10 +2066,11 @@
 
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
-	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MOMENCO_OCELOT_3
+	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MV64360 || MOMENCO_OCELOT_3
 	help
 	  This driver supports the gigabit Ethernet on the Marvell MV643XX
-	  chipset which is used in the Momenco Ocelot C and Jaguar ATX.
+	  chipset which is used in the Momenco Ocelot C and Jaguar ATX and
+	  Pegasos II, amongst other PPC and MIPS boards.
 
 config MV643XX_ETH_0
 	bool "MV-643XX Port 0"
diff -Nru a/drivers/net/fealnx.c b/drivers/net/fealnx.c
--- a/drivers/net/fealnx.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/fealnx.c	2005-03-08 14:29:45 -05:00
@@ -102,21 +102,6 @@
 #define USE_IO_OPS
 #endif
 
-#ifdef USE_IO_OPS
-#undef readb
-#undef readw
-#undef readl
-#undef writeb
-#undef writew
-#undef writel
-#define readb inb
-#define readw inw
-#define readl inl
-#define writeb outb
-#define writew outw
-#define writel outl
-#endif
-
 /* Kernel compatibility defines, some common to David Hinds' PCMCIA package. */
 /* This is only in the support-all-kernels source code. */
 
@@ -444,6 +429,7 @@
 	int mii_cnt;		/* MII device addresses. */
 	unsigned char phys[2];	/* MII device addresses. */
 	struct mii_if_info mii;
+	void __iomem *mem;
 };
 
 
@@ -468,23 +454,23 @@
 static void reset_rx_descriptors(struct net_device *dev);
 static void reset_tx_descriptors(struct net_device *dev);
 
-static void stop_nic_rx(long ioaddr, long crvalue)
+static void stop_nic_rx(void __iomem *ioaddr, long crvalue)
 {
 	int delay = 0x1000;
-	writel(crvalue & ~(CR_W_RXEN), ioaddr + TCRRCR);
+	iowrite32(crvalue & ~(CR_W_RXEN), ioaddr + TCRRCR);
 	while (--delay) {
-		if ( (readl(ioaddr + TCRRCR) & CR_R_RXSTOP) == CR_R_RXSTOP)
+		if ( (ioread32(ioaddr + TCRRCR) & CR_R_RXSTOP) == CR_R_RXSTOP)
 			break;
 	}
 }
 
 
-static void stop_nic_rxtx(long ioaddr, long crvalue)
+static void stop_nic_rxtx(void __iomem *ioaddr, long crvalue)
 {
 	int delay = 0x1000;
-	writel(crvalue & ~(CR_W_RXEN+CR_W_TXEN), ioaddr + TCRRCR);
+	iowrite32(crvalue & ~(CR_W_RXEN+CR_W_TXEN), ioaddr + TCRRCR);
 	while (--delay) {
-		if ( (readl(ioaddr + TCRRCR) & (CR_R_RXSTOP+CR_R_TXSTOP))
+		if ( (ioread32(ioaddr + TCRRCR) & (CR_R_RXSTOP+CR_R_TXSTOP))
 					    == (CR_R_RXSTOP+CR_R_TXSTOP) )
 			break;
 	}
@@ -498,11 +484,17 @@
 	int i, option, err, irq;
 	static int card_idx = -1;
 	char boardname[12];
-	long ioaddr;
+	void __iomem *ioaddr;
+	unsigned long len;
 	unsigned int chip_id = ent->driver_data;
 	struct net_device *dev;
 	void *ring_space;
 	dma_addr_t ring_dma;
+#ifdef USE_IO_OPS
+	int bar = 0;
+#else
+	int bar = 1;
+#endif
 	
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -520,14 +512,10 @@
 	if (i) return i;
 	pci_set_master(pdev);
 	
-#ifdef USE_IO_OPS
-	ioaddr = pci_resource_len(pdev, 0);
-#else
-	ioaddr = pci_resource_len(pdev, 1);
-#endif
-	if (ioaddr < MIN_REGION_SIZE) {
+	len = pci_resource_len(pdev, bar);
+	if (len < MIN_REGION_SIZE) {
 		printk(KERN_ERR "%s: region size %ld too small, aborting\n",
-		       boardname, ioaddr);
+		       boardname, len);
 		return -ENODEV;
 	}
 
@@ -536,17 +524,12 @@
 	
 	irq = pdev->irq;
 
-#ifdef USE_IO_OPS
-	ioaddr = pci_resource_start(pdev, 0);
-#else
-	ioaddr = (long) ioremap(pci_resource_start(pdev, 1),
-				pci_resource_len(pdev, 1));
+	ioaddr = pci_iomap(pdev, bar, len);
 	if (!ioaddr) {
 		err = -ENOMEM;
 		goto err_out_res;
 	}
-#endif
-	
+
 	dev = alloc_etherdev(sizeof(struct netdev_private));
 	if (!dev) {
 		err = -ENOMEM;
@@ -557,16 +540,17 @@
 
 	/* read ethernet id */
 	for (i = 0; i < 6; ++i)
-		dev->dev_addr[i] = readb(ioaddr + PAR0 + i);
+		dev->dev_addr[i] = ioread8(ioaddr + PAR0 + i);
 
 	/* Reset the chip to erase previous misconfiguration. */
-	writel(0x00000001, ioaddr + BCR);
+	iowrite32(0x00000001, ioaddr + BCR);
 
-	dev->base_addr = ioaddr;
+	dev->base_addr = (unsigned long)ioaddr;
 	dev->irq = irq;
 
 	/* Make certain the descriptor lists are aligned. */
-	np = dev->priv;
+	np = netdev_priv(dev);
+	np->mem = ioaddr;
 	spin_lock_init(&np->lock);
 	np->pci_dev = pdev;
 	np->flags = skel_netdrv_tbl[chip_id].flags;
@@ -635,7 +619,7 @@
 		np->phys[0] = 32;
 /* 89/6/23 add, (begin) */
 		/* get phy type */
-		if (readl(ioaddr + PHYIDENTIFIER) == MysonPHYID)
+		if (ioread32(ioaddr + PHYIDENTIFIER) == MysonPHYID)
 			np->PHYType = MysonPHY;
 		else
 			np->PHYType = OtherPHY;
@@ -670,7 +654,7 @@
 		if (np->flags == HAS_MII_XCVR)
 			mdio_write(dev, np->phys[0], MII_ADVERTISE, ADVERTISE_FULL);
 		else
-			writel(ADVERTISE_FULL, ioaddr + ANARANLPAR);
+			iowrite32(ADVERTISE_FULL, ioaddr + ANARANLPAR);
 		np->mii.force_media = 1;
 	}
 
@@ -689,7 +673,7 @@
 	if (err)
 		goto err_out_free_tx;
 
-	printk(KERN_INFO "%s: %s at 0x%lx, ",
+	printk(KERN_INFO "%s: %s at %p, ",
 	       dev->name, skel_netdrv_tbl[chip_id].chip_name, ioaddr);
 	for (i = 0; i < 5; i++)
 		printk("%2.2x:", dev->dev_addr[i]);
@@ -704,10 +688,8 @@
 err_out_free_dev:
 	free_netdev(dev);
 err_out_unmap:
-#ifndef USE_IO_OPS
-	iounmap((void *)ioaddr);
+	pci_iounmap(pdev, ioaddr);
 err_out_res:
-#endif
 	pci_release_regions(pdev);
 	return err;
 }
@@ -718,16 +700,14 @@
 	struct net_device *dev = pci_get_drvdata(pdev);
 
 	if (dev) {
-		struct netdev_private *np = dev->priv;
+		struct netdev_private *np = netdev_priv(dev);
 
 		pci_free_consistent(pdev, TX_TOTAL_SIZE, np->tx_ring,
 			np->tx_ring_dma);
 		pci_free_consistent(pdev, RX_TOTAL_SIZE, np->rx_ring,
 			np->rx_ring_dma);
 		unregister_netdev(dev);
-#ifndef USE_IO_OPS
-		iounmap((void *)dev->base_addr);
-#endif
+		pci_iounmap(pdev, np->mem);
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
@@ -736,14 +716,14 @@
 }
 
 
-static ulong m80x_send_cmd_to_phy(long miiport, int opcode, int phyad, int regad)
+static ulong m80x_send_cmd_to_phy(void __iomem *miiport, int opcode, int phyad, int regad)
 {
 	ulong miir;
 	int i;
 	unsigned int mask, data;
 
 	/* enable MII output */
-	miir = (ulong) readl(miiport);
+	miir = (ulong) ioread32(miiport);
 	miir &= 0xfffffff0;
 
 	miir |= MASK_MIIR_MII_WRITE + MASK_MIIR_MII_MDO;
@@ -752,11 +732,11 @@
 	for (i = 0; i < 32; i++) {
 		/* low MDC; MDO is already high (miir) */
 		miir &= ~MASK_MIIR_MII_MDC;
-		writel(miir, miiport);
+		iowrite32(miir, miiport);
 
 		/* high MDC */
 		miir |= MASK_MIIR_MII_MDC;
-		writel(miir, miiport);
+		iowrite32(miir, miiport);
 	}
 
 	/* calculate ST+OP+PHYAD+REGAD+TA */
@@ -770,10 +750,10 @@
 		if (mask & data)
 			miir |= MASK_MIIR_MII_MDO;
 
-		writel(miir, miiport);
+		iowrite32(miir, miiport);
 		/* high MDC */
 		miir |= MASK_MIIR_MII_MDC;
-		writel(miir, miiport);
+		iowrite32(miir, miiport);
 		udelay(30);
 
 		/* next */
@@ -787,7 +767,8 @@
 
 static int mdio_read(struct net_device *dev, int phyad, int regad)
 {
-	long miiport = dev->base_addr + MANAGEMENT;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *miiport = np->mem + MANAGEMENT;
 	ulong miir;
 	unsigned int mask, data;
 
@@ -799,16 +780,16 @@
 	while (mask) {
 		/* low MDC */
 		miir &= ~MASK_MIIR_MII_MDC;
-		writel(miir, miiport);
+		iowrite32(miir, miiport);
 
 		/* read MDI */
-		miir = readl(miiport);
+		miir = ioread32(miiport);
 		if (miir & MASK_MIIR_MII_MDI)
 			data |= mask;
 
 		/* high MDC, and wait */
 		miir |= MASK_MIIR_MII_MDC;
-		writel(miir, miiport);
+		iowrite32(miir, miiport);
 		udelay(30);
 
 		/* next */
@@ -817,7 +798,7 @@
 
 	/* low MDC */
 	miir &= ~MASK_MIIR_MII_MDC;
-	writel(miir, miiport);
+	iowrite32(miir, miiport);
 
 	return data & 0xffff;
 }
@@ -825,7 +806,8 @@
 
 static void mdio_write(struct net_device *dev, int phyad, int regad, int data)
 {
-	long miiport = dev->base_addr + MANAGEMENT;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *miiport = np->mem + MANAGEMENT;
 	ulong miir;
 	unsigned int mask;
 
@@ -838,11 +820,11 @@
 		miir &= ~(MASK_MIIR_MII_MDC + MASK_MIIR_MII_MDO);
 		if (mask & data)
 			miir |= MASK_MIIR_MII_MDO;
-		writel(miir, miiport);
+		iowrite32(miir, miiport);
 
 		/* high MDC */
 		miir |= MASK_MIIR_MII_MDC;
-		writel(miir, miiport);
+		iowrite32(miir, miiport);
 
 		/* next */
 		mask >>= 1;
@@ -850,29 +832,29 @@
 
 	/* low MDC */
 	miir &= ~MASK_MIIR_MII_MDC;
-	writel(miir, miiport);
+	iowrite32(miir, miiport);
 }
 
 
 static int netdev_open(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 	int i;
 
-	writel(0x00000001, ioaddr + BCR);	/* Reset */
+	iowrite32(0x00000001, ioaddr + BCR);	/* Reset */
 
 	if (request_irq(dev->irq, &intr_handler, SA_SHIRQ, dev->name, dev))
 		return -EAGAIN;
 
 	for (i = 0; i < 3; i++)
-		writew(((unsigned short*)dev->dev_addr)[i],
+		iowrite16(((unsigned short*)dev->dev_addr)[i],
 				ioaddr + PAR0 + i*2);
 
 	init_ring(dev);
 
-	writel(np->rx_ring_dma, ioaddr + RXLBA);
-	writel(np->tx_ring_dma, ioaddr + TXLBA);
+	iowrite32(np->rx_ring_dma, ioaddr + RXLBA);
+	iowrite32(np->tx_ring_dma, ioaddr + TXLBA);
 
 	/* Initialize other registers. */
 	/* Configure the PCI bus bursts and FIFO thresholds.
@@ -933,12 +915,12 @@
 		np->crvalue |= CR_W_ENH;	/* set enhanced bit */
 		np->imrvalue |= ETI;
 	}
-	writel(np->bcrvalue, ioaddr + BCR);
+	iowrite32(np->bcrvalue, ioaddr + BCR);
 
 	if (dev->if_port == 0)
 		dev->if_port = np->default_port;
 
-	writel(0, ioaddr + RXPDR);
+	iowrite32(0, ioaddr + RXPDR);
 // 89/9/1 modify,
 //   np->crvalue = 0x00e40001;    /* tx store and forward, tx/rx enable */
 	np->crvalue |= 0x00e40001;	/* tx store and forward, tx/rx enable */
@@ -951,8 +933,8 @@
 	netif_start_queue(dev);
 
 	/* Clear and Enable interrupts by setting the interrupt mask. */
-	writel(FBE | TUNF | CNTOVF | RBU | TI | RI, ioaddr + ISR);
-	writel(np->imrvalue, ioaddr + IMR);
+	iowrite32(FBE | TUNF | CNTOVF | RBU | TI | RI, ioaddr + ISR);
+	iowrite32(np->imrvalue, ioaddr + IMR);
 
 	if (debug)
 		printk(KERN_DEBUG "%s: Done netdev_open().\n", dev->name);
@@ -980,14 +962,14 @@
 /* input   : dev... pointer to the adapter block.                            */
 /* output  : none.                                                           */
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	unsigned int i, DelayTime = 0x1000;
 
 	np->linkok = 0;
 
 	if (np->PHYType == MysonPHY) {
 		for (i = 0; i < DelayTime; ++i) {
-			if (readl(dev->base_addr + BMCRSR) & LinkIsUp2) {
+			if (ioread32(np->mem + BMCRSR) & LinkIsUp2) {
 				np->linkok = 1;
 				return;
 			}
@@ -1007,14 +989,14 @@
 
 static void getlinktype(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (np->PHYType == MysonPHY) {	/* 3-in-1 case */
-		if (readl(dev->base_addr + TCRRCR) & CR_R_FD)
+		if (ioread32(np->mem + TCRRCR) & CR_R_FD)
 			np->duplexmode = 2;	/* full duplex */
 		else
 			np->duplexmode = 1;	/* half duplex */
-		if (readl(dev->base_addr + TCRRCR) & CR_R_PS10)
+		if (ioread32(np->mem + TCRRCR) & CR_R_PS10)
 			np->line_speed = 1;	/* 10M */
 		else
 			np->line_speed = 2;	/* 100M */
@@ -1110,7 +1092,7 @@
 /* Take lock before calling this */
 static void allocate_rx_buffers(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/*  allocate skb for rx buffers */
 	while (np->really_rx_count != RX_RING_SIZE) {
@@ -1136,16 +1118,16 @@
 static void netdev_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 	int old_crvalue = np->crvalue;
 	unsigned int old_linkok = np->linkok;
 	unsigned long flags;
 
 	if (debug)
 		printk(KERN_DEBUG "%s: Media selection timer tick, status %8.8x "
-		       "config %8.8x.\n", dev->name, readl(ioaddr + ISR),
-		       readl(ioaddr + TCRRCR));
+		       "config %8.8x.\n", dev->name, ioread32(ioaddr + ISR),
+		       ioread32(ioaddr + TCRRCR));
 
 	spin_lock_irqsave(&np->lock, flags);
 
@@ -1155,7 +1137,7 @@
 			getlinktype(dev);
 			if (np->crvalue != old_crvalue) {
 				stop_nic_rxtx(ioaddr, np->crvalue);
-				writel(np->crvalue, ioaddr + TCRRCR);
+				iowrite32(np->crvalue, ioaddr + TCRRCR);
 			}
 		}
 	}
@@ -1173,22 +1155,23 @@
 /* Reset chip and disable rx, tx and interrupts */
 static void reset_and_disable_rxtx(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 	int delay=51;
 
 	/* Reset the chip's Tx and Rx processes. */
 	stop_nic_rxtx(ioaddr, 0);
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	writel(0, ioaddr + IMR);
+	iowrite32(0, ioaddr + IMR);
 
 	/* Reset the chip to erase previous misconfiguration. */
-	writel(0x00000001, ioaddr + BCR);
+	iowrite32(0x00000001, ioaddr + BCR);
 
 	/* Ueimor: wait for 50 PCI cycles (and flush posted writes btw). 
 	   We surely wait too long (address+data phase). Who cares? */
 	while (--delay) {
-		readl(ioaddr + BCR);
+		ioread32(ioaddr + BCR);
 		rmb();
 	}
 }
@@ -1198,33 +1181,33 @@
 /* Restore chip after reset */
 static void enable_rxtx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 
 	reset_rx_descriptors(dev);
 
-	writel(np->tx_ring_dma + ((char*)np->cur_tx - (char*)np->tx_ring),
+	iowrite32(np->tx_ring_dma + ((char*)np->cur_tx - (char*)np->tx_ring),
 		ioaddr + TXLBA);
-	writel(np->rx_ring_dma + ((char*)np->cur_rx - (char*)np->rx_ring),
+	iowrite32(np->rx_ring_dma + ((char*)np->cur_rx - (char*)np->rx_ring),
 		ioaddr + RXLBA);
 
-	writel(np->bcrvalue, ioaddr + BCR);
+	iowrite32(np->bcrvalue, ioaddr + BCR);
 
-	writel(0, ioaddr + RXPDR);
+	iowrite32(0, ioaddr + RXPDR);
 	__set_rx_mode(dev); /* changes np->crvalue, writes it into TCRRCR */
 
 	/* Clear and Enable interrupts by setting the interrupt mask. */
-	writel(FBE | TUNF | CNTOVF | RBU | TI | RI, ioaddr + ISR);
-	writel(np->imrvalue, ioaddr + IMR);
+	iowrite32(FBE | TUNF | CNTOVF | RBU | TI | RI, ioaddr + ISR);
+	iowrite32(np->imrvalue, ioaddr + IMR);
 
-	writel(0, ioaddr + TXPDR);
+	iowrite32(0, ioaddr + TXPDR);
 }
 
 
 static void reset_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	unsigned long flags;
 
 	printk(KERN_WARNING "%s: resetting tx and rx machinery\n", dev->name);
@@ -1247,13 +1230,13 @@
 
 static void tx_timeout(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 	unsigned long flags;
 	int i;
 
 	printk(KERN_WARNING "%s: Transmit timed out, status %8.8x,"
-	       " resetting...\n", dev->name, readl(ioaddr + ISR));
+	       " resetting...\n", dev->name, ioread32(ioaddr + ISR));
 
 	{
 		printk(KERN_DEBUG "  Rx ring %p: ", np->rx_ring);
@@ -1282,7 +1265,7 @@
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void init_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	/* initialize rx variables */
@@ -1346,7 +1329,7 @@
 
 static int start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&np->lock, flags);
@@ -1413,7 +1396,7 @@
 	if (np->free_tx_count < 2)
 		netif_stop_queue(dev);
 	++np->really_tx_count;
-	writel(0, dev->base_addr + TXPDR);
+	iowrite32(0, np->mem + TXPDR);
 	dev->trans_start = jiffies;
 
 	spin_unlock_irqrestore(&np->lock, flags);
@@ -1425,7 +1408,7 @@
 /* Chip probably hosed tx ring. Clean up. */
 static void reset_tx_descriptors(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	struct fealnx_desc *cur;
 	int i;
 
@@ -1460,7 +1443,7 @@
 /* Take lock and stop rx before calling this */
 static void reset_rx_descriptors(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	struct fealnx_desc *cur = np->cur_rx;
 	int i;
 
@@ -1472,8 +1455,8 @@
 		cur = cur->next_desc_logical;
 	}
 
-	writel(np->rx_ring_dma + ((char*)np->cur_rx - (char*)np->rx_ring),
-		dev->base_addr + RXLBA);
+	iowrite32(np->rx_ring_dma + ((char*)np->cur_rx - (char*)np->rx_ring),
+		np->mem + RXLBA);
 }
 
 
@@ -1482,21 +1465,21 @@
 static irqreturn_t intr_handler(int irq, void *dev_instance, struct pt_regs *rgs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 	long boguscnt = max_interrupt_work;
 	unsigned int num_tx = 0;
 	int handled = 0;
 
 	spin_lock(&np->lock);
 
-	writel(0, ioaddr + IMR);
+	iowrite32(0, ioaddr + IMR);
 
 	do {
-		u32 intr_status = readl(ioaddr + ISR);
+		u32 intr_status = ioread32(ioaddr + ISR);
 
 		/* Acknowledge all of the current interrupt sources ASAP. */
-		writel(intr_status, ioaddr + ISR);
+		iowrite32(intr_status, ioaddr + ISR);
 
 		if (debug)
 			printk(KERN_DEBUG "%s: Interrupt, status %4.4x.\n", dev->name,
@@ -1517,15 +1500,15 @@
 //      };
 
 		if (intr_status & TUNF)
-			writel(0, ioaddr + TXPDR);
+			iowrite32(0, ioaddr + TXPDR);
 
 		if (intr_status & CNTOVF) {
 			/* missed pkts */
-			np->stats.rx_missed_errors += readl(ioaddr + TALLY) & 0x7fff;
+			np->stats.rx_missed_errors += ioread32(ioaddr + TALLY) & 0x7fff;
 
 			/* crc error */
 			np->stats.rx_crc_errors +=
-			    (readl(ioaddr + TALLY) & 0x7fff0000) >> 16;
+			    (ioread32(ioaddr + TALLY) & 0x7fff0000) >> 16;
 		}
 
 		if (intr_status & (RI | RBU)) {
@@ -1534,7 +1517,7 @@
 			else {
 				stop_nic_rx(ioaddr, np->crvalue);
 				reset_rx_descriptors(dev);
-				writel(np->crvalue, ioaddr + TCRRCR);
+				iowrite32(np->crvalue, ioaddr + TCRRCR);
 			}				
 		}
 
@@ -1605,7 +1588,7 @@
 		if (np->crvalue & CR_W_ENH) {
 			long data;
 
-			data = readl(ioaddr + TSR);
+			data = ioread32(ioaddr + TSR);
 			np->stats.tx_errors += (data & 0xff000000) >> 24;
 			np->stats.tx_aborted_errors += (data & 0xff000000) >> 24;
 			np->stats.tx_window_errors += (data & 0x00ff0000) >> 16;
@@ -1635,16 +1618,16 @@
 
 	/* read the tally counters */
 	/* missed pkts */
-	np->stats.rx_missed_errors += readl(ioaddr + TALLY) & 0x7fff;
+	np->stats.rx_missed_errors += ioread32(ioaddr + TALLY) & 0x7fff;
 
 	/* crc error */
-	np->stats.rx_crc_errors += (readl(ioaddr + TALLY) & 0x7fff0000) >> 16;
+	np->stats.rx_crc_errors += (ioread32(ioaddr + TALLY) & 0x7fff0000) >> 16;
 
 	if (debug)
 		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x.\n",
-		       dev->name, readl(ioaddr + ISR));
+		       dev->name, ioread32(ioaddr + ISR));
 
-	writel(np->imrvalue, ioaddr + IMR);
+	iowrite32(np->imrvalue, ioaddr + IMR);
 
 	spin_unlock(&np->lock);
 
@@ -1656,8 +1639,8 @@
    for clarity and better register allocation. */
 static int netdev_rx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
 	while (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) {
@@ -1725,7 +1708,7 @@
 				} else {        /* rx error, need to reset this chip */
 					stop_nic_rx(ioaddr, np->crvalue);
 					reset_rx_descriptors(dev);
-					writel(np->crvalue, ioaddr + TCRRCR);
+					iowrite32(np->crvalue, ioaddr + TCRRCR);
 				}
 				break;	/* exit the while loop */
 			}
@@ -1793,13 +1776,13 @@
 
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 
 	/* The chip only need report frame silently dropped. */
 	if (netif_running(dev)) {
-		np->stats.rx_missed_errors += readl(ioaddr + TALLY) & 0x7fff;
-		np->stats.rx_crc_errors += (readl(ioaddr + TALLY) & 0x7fff0000) >> 16;
+		np->stats.rx_missed_errors += ioread32(ioaddr + TALLY) & 0x7fff;
+		np->stats.rx_crc_errors += (ioread32(ioaddr + TALLY) & 0x7fff0000) >> 16;
 	}
 
 	return &np->stats;
@@ -1809,7 +1792,7 @@
 /* for dev->set_multicast_list */
 static void set_rx_mode(struct net_device *dev)
 {
-	spinlock_t *lp = &((struct netdev_private *)dev->priv)->lock;
+	spinlock_t *lp = &((struct netdev_private *)netdev_priv(dev))->lock;
 	unsigned long flags;
 	spin_lock_irqsave(lp, flags);
 	__set_rx_mode(dev);
@@ -1820,8 +1803,8 @@
 /* Take lock before calling */
 static void __set_rx_mode(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	u32 rx_mode;
 
@@ -1851,16 +1834,16 @@
 
 	stop_nic_rxtx(ioaddr, np->crvalue);
 
-	writel(mc_filter[0], ioaddr + MAR0);
-	writel(mc_filter[1], ioaddr + MAR1);
+	iowrite32(mc_filter[0], ioaddr + MAR0);
+	iowrite32(mc_filter[1], ioaddr + MAR1);
 	np->crvalue &= ~CR_W_RXMODEMASK;
 	np->crvalue |= rx_mode;
-	writel(np->crvalue, ioaddr + TCRRCR);
+	iowrite32(np->crvalue, ioaddr + TCRRCR);
 }
 
 static void netdev_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -1869,7 +1852,7 @@
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
@@ -1881,7 +1864,7 @@
 
 static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
@@ -1893,13 +1876,13 @@
 
 static int netdev_nway_reset(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	return mii_nway_restart(&np->mii);
 }
 
 static u32 netdev_get_link(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	return mii_link_ok(&np->mii);
 }
 
@@ -1927,7 +1910,7 @@
 
 static int mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	if (!netif_running(dev))
@@ -1943,14 +1926,14 @@
 
 static int netdev_close(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->mem;
 	int i;
 
 	netif_stop_queue(dev);
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	writel(0x0000, ioaddr + IMR);
+	iowrite32(0x0000, ioaddr + IMR);
 
 	/* Stop the chip's Tx and Rx processes. */
 	stop_nic_rxtx(ioaddr, 0);
diff -Nru a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
--- a/drivers/net/hamradio/6pack.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/6pack.c	2005-03-08 14:29:45 -05:00
@@ -756,12 +756,12 @@
 
 	switch(cmd) {
 	case SIOCGIFNAME:
-		err = copy_to_user((void *) arg, dev->name,
+		err = copy_to_user((void __user *) arg, dev->name,
 		                   strlen(dev->name) + 1) ? -EFAULT : 0;
 		break;
 
 	case SIOCGIFENCAP:
-		err = put_user(0, (int __user *)arg);
+		err = put_user(0, (int __user *) arg);
 		break;
 
 	case SIOCSIFENCAP:
diff -Nru a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
--- a/drivers/net/hamradio/baycom_epp.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/baycom_epp.c	2005-03-08 14:29:45 -05:00
@@ -68,25 +68,7 @@
 /* --------------------------------------------------------------------- */
 
 static const char paranoia_str[] = KERN_ERR 
-"baycom_epp: bad magic number for hdlcdrv_state struct in routine %s\n";
-
-#define baycom_paranoia_check(dev,routine,retval)                                              \
-({                                                                                             \
-	if (!dev || !dev->priv || ((struct baycom_state *)dev->priv)->magic != BAYCOM_MAGIC) { \
-		printk(paranoia_str, routine);                                                 \
-		return retval;                                                                 \
-	}                                                                                      \
-})
-
-#define baycom_paranoia_check_void(dev,routine)                                                \
-({                                                                                             \
-	if (!dev || !dev->priv || ((struct baycom_state *)dev->priv)->magic != BAYCOM_MAGIC) { \
-		printk(paranoia_str, routine);                                                 \
-		return;                                                                        \
-	}                                                                                      \
-})
-
-/* --------------------------------------------------------------------- */
+	"baycom_epp: bad magic number for hdlcdrv_state struct in routine %s\n";
 
 static const char bc_drvname[] = "baycom_epp";
 static const char bc_drvinfo[] = KERN_INFO "baycom_epp: (C) 1998-2000 Thomas Sailer, HB9JNX/AE4WA\n"
@@ -747,7 +729,6 @@
 	unsigned int time1 = 0, time2 = 0, time3 = 0;
 	int cnt, cnt2;
 	
-	baycom_paranoia_check_void(dev, "epp_bh");
 	bc = netdev_priv(dev);
 	if (!bc->work_running)
 		return;
@@ -863,10 +844,8 @@
 
 static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct baycom_state *bc;
+	struct baycom_state *bc = netdev_priv(dev);
 
-	baycom_paranoia_check(dev, "baycom_send_packet", 0);
-	bc = netdev_priv(dev);
 	if (skb->data[0] != 0) {
 		do_kiss_params(bc, skb->data, skb->len);
 		dev_kfree_skb(skb);
@@ -899,10 +878,8 @@
 
 static struct net_device_stats *baycom_get_stats(struct net_device *dev)
 {
-	struct baycom_state *bc;
+	struct baycom_state *bc = netdev_priv(dev);
 
-	baycom_paranoia_check(dev, "baycom_get_stats", NULL);
-	bc = netdev_priv(dev);
 	/* 
 	 * Get the current statistics.  This may be called with the
 	 * card open or closed. 
@@ -915,10 +892,8 @@
 static void epp_wakeup(void *handle)
 {
         struct net_device *dev = (struct net_device *)handle;
-        struct baycom_state *bc;
+        struct baycom_state *bc = netdev_priv(dev);
 
-	baycom_paranoia_check_void(dev, "epp_wakeup");
-        bc = netdev_priv(dev);
         printk(KERN_DEBUG "baycom_epp: %s: why am I being woken up?\n", dev->name);
         if (!parport_claim(bc->pdev))
                 printk(KERN_DEBUG "baycom_epp: %s: I'm broken.\n", dev->name);
@@ -937,16 +912,13 @@
 
 static int epp_open(struct net_device *dev)
 {
-	struct baycom_state *bc;
-        struct parport *pp;
+	struct baycom_state *bc = netdev_priv(dev);
+        struct parport *pp = parport_find_base(dev->base_addr);
 	unsigned int i, j;
 	unsigned char tmp[128];
 	unsigned char stat;
 	unsigned long tstart;
 	
-	baycom_paranoia_check(dev, "epp_open", -ENXIO);
-	bc = netdev_priv(dev);
-        pp = parport_find_base(dev->base_addr);
         if (!pp) {
                 printk(KERN_ERR "%s: parport at 0x%lx unknown\n", bc_drvname, dev->base_addr);
                 return -ENXIO;
@@ -1055,13 +1027,10 @@
 
 static int epp_close(struct net_device *dev)
 {
-	struct baycom_state *bc;
-	struct parport *pp;
+	struct baycom_state *bc = netdev_priv(dev);
+	struct parport *pp = bc->pdev->port;
 	unsigned char tmp[1];
 
-	baycom_paranoia_check(dev, "epp_close", -EINVAL);
-	bc = netdev_priv(dev);
-	pp = bc->pdev->port;
 	bc->work_running = 0;
 	flush_scheduled_work();
 	bc->stat = EPP_DCDBIT;
@@ -1117,11 +1086,9 @@
 
 static int baycom_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct baycom_state *bc;
+	struct baycom_state *bc = netdev_priv(dev);
 	struct hdlcdrv_ioctl hi;
 
-	baycom_paranoia_check(dev, "baycom_ioctl", -EINVAL);
-	bc = netdev_priv(dev);
 	if (cmd != SIOCDEVPRIVATE)
 		return -ENOIOCTLCMD;
 
@@ -1354,7 +1321,7 @@
 			free_netdev(dev);
 			break;
 		}
-		if (set_hw && baycom_setmode(dev->priv, mode[i]))
+		if (set_hw && baycom_setmode(netdev_priv(dev), mode[i]))
 			set_hw = 0;
 		baycom_device[i] = dev;
 		found++;
diff -Nru a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
--- a/drivers/net/hamradio/baycom_par.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/baycom_par.c	2005-03-08 14:29:45 -05:00
@@ -85,6 +85,7 @@
 #include <linux/parport.h>
 #include <linux/bitops.h>
 
+#include <asm/bug.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
@@ -415,12 +416,11 @@
 	struct baycom_state *bc;
 	struct baycom_ioctl bi;
 
-	if (!dev || !dev->priv ||
-	    ((struct baycom_state *)dev->priv)->hdrv.magic != HDLCDRV_MAGIC) {
-		printk(KERN_ERR "bc_ioctl: invalid device struct\n");
+	if (!dev)
 		return -EINVAL;
-	}
+
 	bc = netdev_priv(dev);
+	BUG_ON(bc->hdrv.magic != HDLCDRV_MAGIC);
 
 	if (cmd != SIOCDEVPRIVATE)
 		return -ENOIOCTLCMD;
diff -Nru a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
--- a/drivers/net/hamradio/baycom_ser_fdx.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/baycom_ser_fdx.c	2005-03-08 14:29:45 -05:00
@@ -530,12 +530,11 @@
 	struct baycom_state *bc;
 	struct baycom_ioctl bi;
 
-	if (!dev || !dev->priv ||
-	    ((struct baycom_state *)dev->priv)->hdrv.magic != HDLCDRV_MAGIC) {
-		printk(KERN_ERR "bc_ioctl: invalid device struct\n");
+	if (!dev)
 		return -EINVAL;
-	}
+
 	bc = netdev_priv(dev);
+	BUG_ON(bc->hdrv.magic != HDLCDRV_MAGIC);
 
 	if (cmd != SIOCDEVPRIVATE)
 		return -ENOIOCTLCMD;
diff -Nru a/drivers/net/hamradio/baycom_ser_hdx.c b/drivers/net/hamradio/baycom_ser_hdx.c
--- a/drivers/net/hamradio/baycom_ser_hdx.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/baycom_ser_hdx.c	2005-03-08 14:29:45 -05:00
@@ -570,12 +570,11 @@
 	struct baycom_state *bc;
 	struct baycom_ioctl bi;
 
-	if (!dev || !dev->priv ||
-	    ((struct baycom_state *)dev->priv)->hdrv.magic != HDLCDRV_MAGIC) {
-		printk(KERN_ERR "bc_ioctl: invalid device struct\n");
+	if (!dev)
 		return -EINVAL;
-	}
+
 	bc = netdev_priv(dev);
+	BUG_ON(bc->hdrv.magic != HDLCDRV_MAGIC);
 
 	if (cmd != SIOCDEVPRIVATE)
 		return -ENOIOCTLCMD;
diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/bpqether.c	2005-03-08 14:29:45 -05:00
@@ -112,8 +112,6 @@
 };
 
 
-#define MAXBPQDEV 100
-
 struct bpqdev {
 	struct list_head bpq_list;	/* list of bpq devices chain */
 	struct net_device *ethdev;	/* link to ethernet device */
@@ -134,7 +132,7 @@
  */
 static inline struct net_device *bpq_get_ether_dev(struct net_device *dev)
 {
-	struct bpqdev *bpq = (struct bpqdev *) dev->priv;
+	struct bpqdev *bpq = netdev_priv(dev);
 
 	return bpq ? bpq->ethdev : NULL;
 }
@@ -191,7 +189,7 @@
 	 * we check the source address of the sender.
 	 */
 
-	bpq = (struct bpqdev *)dev->priv;
+	bpq = netdev_priv(dev);
 
 	eth = eth_hdr(skb);
 
@@ -281,7 +279,7 @@
 	*ptr++ = (size + 5) % 256;
 	*ptr++ = (size + 5) / 256;
 
-	bpq = (struct bpqdev *)dev->priv;
+	bpq = netdev_priv(dev);
 
 	if ((dev = bpq_get_ether_dev(dev)) == NULL) {
 		bpq->stats.tx_dropped++;
@@ -305,7 +303,7 @@
  */
 static struct net_device_stats *bpq_get_stats(struct net_device *dev)
 {
-	struct bpqdev *bpq = (struct bpqdev *) dev->priv;
+	struct bpqdev *bpq = netdev_priv(dev);
 
 	return &bpq->stats;
 }
@@ -332,15 +330,12 @@
 static int bpq_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct bpq_ethaddr __user *ethaddr = ifr->ifr_data;
-	struct bpqdev *bpq = dev->priv;
+	struct bpqdev *bpq = netdev_priv(dev);
 	struct bpq_req req;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (bpq == NULL)		/* woops! */
-		return -ENODEV;
-
 	switch (cmd) {
 		case SIOCSBPQETHOPT:
 			if (copy_from_user(&req, ifr->ifr_data, sizeof(struct bpq_req)))
@@ -525,7 +520,7 @@
 		return -ENOMEM;
 
 		
-	bpq = ndev->priv;
+	bpq = netdev_priv(ndev);
 	dev_hold(edev);
 	bpq->ethdev = edev;
 	bpq->axdev = ndev;
@@ -554,7 +549,7 @@
 
 static void bpq_free_device(struct net_device *ndev)
 {
-	struct bpqdev *bpq = ndev->priv;
+	struct bpqdev *bpq = netdev_priv(ndev);
 
 	dev_put(bpq->ethdev);
 	list_del_rcu(&bpq->bpq_list);
diff -Nru a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
--- a/drivers/net/hamradio/dmascc.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/dmascc.c	2005-03-08 14:29:45 -05:00
@@ -1,6 +1,4 @@
 /*
- * $Id: dmascc.c,v 1.27 2000/06/01 14:46:23 oe1kib Exp $
- *
  * Driver for high-speed SCC boards (those with DMA support)
  * Copyright (C) 1997-2000 Klaus Kudielka
  *
@@ -19,7 +17,6 @@
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
  */
 
 
@@ -49,9 +46,9 @@
 
 /* Number of buffers per channel */
 
-#define NUM_TX_BUF      2          /* NUM_TX_BUF >= 1 (min. 2 recommended) */
-#define NUM_RX_BUF      6          /* NUM_RX_BUF >= 1 (min. 2 recommended) */
-#define BUF_SIZE        1576       /* BUF_SIZE >= mtu + hard_header_len */
+#define NUM_TX_BUF      2	/* NUM_TX_BUF >= 1 (min. 2 recommended) */
+#define NUM_RX_BUF      6	/* NUM_RX_BUF >= 1 (min. 2 recommended) */
+#define BUF_SIZE        1576	/* BUF_SIZE >= mtu + hard_header_len */
 
 
 /* Cards supported */
@@ -67,7 +64,7 @@
 
 #define HARDWARE        { HW_PI, HW_PI2, HW_TWIN, HW_S5 }
 
-#define TMR_0_HZ        25600      /* Frequency of timer 0 */
+#define TMR_0_HZ        25600	/* Frequency of timer 0 */
 
 #define TYPE_PI         0
 #define TYPE_PI2        1
@@ -164,69 +161,69 @@
 /* Data types */
 
 struct scc_param {
-  int pclk_hz;    /* frequency of BRG input (don't change) */
-  int brg_tc;     /* BRG terminal count; BRG disabled if < 0 */
-  int nrzi;       /* 0 (nrz), 1 (nrzi) */
-  int clocks;     /* see dmascc_cfg documentation */
-  int txdelay;    /* [1/TMR_0_HZ] */
-  int txtimeout;  /* [1/HZ] */
-  int txtail;     /* [1/TMR_0_HZ] */
-  int waittime;   /* [1/TMR_0_HZ] */
-  int slottime;   /* [1/TMR_0_HZ] */
-  int persist;    /* 1 ... 256 */
-  int dma;        /* -1 (disable), 0, 1, 3 */
-  int txpause;    /* [1/TMR_0_HZ] */
-  int rtsoff;     /* [1/TMR_0_HZ] */
-  int dcdon;      /* [1/TMR_0_HZ] */
-  int dcdoff;     /* [1/TMR_0_HZ] */
+	int pclk_hz;		/* frequency of BRG input (don't change) */
+	int brg_tc;		/* BRG terminal count; BRG disabled if < 0 */
+	int nrzi;		/* 0 (nrz), 1 (nrzi) */
+	int clocks;		/* see dmascc_cfg documentation */
+	int txdelay;		/* [1/TMR_0_HZ] */
+	int txtimeout;		/* [1/HZ] */
+	int txtail;		/* [1/TMR_0_HZ] */
+	int waittime;		/* [1/TMR_0_HZ] */
+	int slottime;		/* [1/TMR_0_HZ] */
+	int persist;		/* 1 ... 256 */
+	int dma;		/* -1 (disable), 0, 1, 3 */
+	int txpause;		/* [1/TMR_0_HZ] */
+	int rtsoff;		/* [1/TMR_0_HZ] */
+	int dcdon;		/* [1/TMR_0_HZ] */
+	int dcdoff;		/* [1/TMR_0_HZ] */
 };
 
 struct scc_hardware {
-  char *name;
-  int io_region;
-  int io_delta;
-  int io_size;
-  int num_devs;
-  int scc_offset;
-  int tmr_offset;
-  int tmr_hz;
-  int pclk_hz;
+	char *name;
+	int io_region;
+	int io_delta;
+	int io_size;
+	int num_devs;
+	int scc_offset;
+	int tmr_offset;
+	int tmr_hz;
+	int pclk_hz;
 };
 
 struct scc_priv {
-  int type;
-  int chip;
-  struct net_device *dev;
-  struct scc_info *info;
-  struct net_device_stats stats;
-  int channel;
-  int card_base, scc_cmd, scc_data;
-  int tmr_cnt, tmr_ctrl, tmr_mode;
-  struct scc_param param;
-  char rx_buf[NUM_RX_BUF][BUF_SIZE];
-  int rx_len[NUM_RX_BUF];
-  int rx_ptr;
-  struct work_struct rx_work;
-  int rx_head, rx_tail, rx_count;
-  int rx_over;
-  char tx_buf[NUM_TX_BUF][BUF_SIZE];
-  int tx_len[NUM_TX_BUF];
-  int tx_ptr;
-  int tx_head, tx_tail, tx_count;
-  int state;
-  unsigned long tx_start;
-  int rr0;
-  spinlock_t *register_lock;	/* Per scc_info */
-  spinlock_t ring_lock;
+	int type;
+	int chip;
+	struct net_device *dev;
+	struct scc_info *info;
+	struct net_device_stats stats;
+	int channel;
+	int card_base, scc_cmd, scc_data;
+	int tmr_cnt, tmr_ctrl, tmr_mode;
+	struct scc_param param;
+	char rx_buf[NUM_RX_BUF][BUF_SIZE];
+	int rx_len[NUM_RX_BUF];
+	int rx_ptr;
+	struct work_struct rx_work;
+	int rx_head, rx_tail, rx_count;
+	int rx_over;
+	char tx_buf[NUM_TX_BUF][BUF_SIZE];
+	int tx_len[NUM_TX_BUF];
+	int tx_ptr;
+	int tx_head, tx_tail, tx_count;
+	int state;
+	unsigned long tx_start;
+	int rr0;
+	spinlock_t *register_lock;	/* Per scc_info */
+	spinlock_t ring_lock;
 };
 
 struct scc_info {
-  int irq_used;
-  int twin_serial_cfg;
-  struct net_device *dev[2];
-  struct scc_priv priv[2];
-  struct scc_info *next;
-  spinlock_t register_lock;	/* Per device register lock */
+	int irq_used;
+	int twin_serial_cfg;
+	struct net_device *dev[2];
+	struct scc_priv priv[2];
+	struct scc_info *next;
+	spinlock_t register_lock;	/* Per device register lock */
 };
 
 
@@ -252,7 +249,7 @@
 static inline unsigned char random(void);
 
 static inline void z8530_isr(struct scc_info *info);
-static irqreturn_t scc_isr(int irq, void *dev_id, struct pt_regs * regs);
+static irqreturn_t scc_isr(int irq, void *dev_id, struct pt_regs *regs);
 static void rx_isr(struct scc_priv *priv);
 static void special_condition(struct scc_priv *priv, int rc);
 static void rx_bh(void *arg);
@@ -264,12 +261,15 @@
 /* Initialization variables */
 
 static int io[MAX_NUM_DEVS] __initdata = { 0, };
+
 /* Beware! hw[] is also used in cleanup_module(). */
 static struct scc_hardware hw[NUM_TYPES] __initdata_or_module = HARDWARE;
 static char ax25_broadcast[7] __initdata =
-  { 'Q'<<1, 'S'<<1, 'T'<<1, ' '<<1, ' '<<1, ' '<<1, '0'<<1 };
+    { 'Q' << 1, 'S' << 1, 'T' << 1, ' ' << 1, ' ' << 1, ' ' << 1,
+'0' << 1 };
 static char ax25_test[7] __initdata =
-  { 'L'<<1, 'I'<<1, 'N'<<1, 'U'<<1, 'X'<<1, ' '<<1, '1'<<1 };
+    { 'L' << 1, 'I' << 1, 'N' << 1, 'U' << 1, 'X' << 1, ' ' << 1,
+'1' << 1 };
 
 
 /* Global variables */
@@ -283,143 +283,164 @@
 MODULE_PARM(io, "1-" __MODULE_STRING(MAX_NUM_DEVS) "i");
 MODULE_LICENSE("GPL");
 
-static void __exit dmascc_exit(void) {
-  int i;
-  struct scc_info *info;
-
-  while (first) {
-    info = first;
-
-    /* Unregister devices */
-    for (i = 0; i < 2; i++)
-	unregister_netdev(info->dev[i]);
-
-    /* Reset board */
-    if (info->priv[0].type == TYPE_TWIN)
-      outb(0, info->dev[0]->base_addr + TWIN_SERIAL_CFG);
-    write_scc(&info->priv[0], R9, FHWRES);
-    release_region(info->dev[0]->base_addr,
-		   hw[info->priv[0].type].io_size);
-
-    for (i = 0; i < 2; i++)
-	free_netdev(info->dev[i]);
-
-    /* Free memory */
-    first = info->next;
-    kfree(info);
-  }
+static void __exit dmascc_exit(void)
+{
+	int i;
+	struct scc_info *info;
+
+	while (first) {
+		info = first;
+
+		/* Unregister devices */
+		for (i = 0; i < 2; i++)
+			unregister_netdev(info->dev[i]);
+
+		/* Reset board */
+		if (info->priv[0].type == TYPE_TWIN)
+			outb(0, info->dev[0]->base_addr + TWIN_SERIAL_CFG);
+		write_scc(&info->priv[0], R9, FHWRES);
+		release_region(info->dev[0]->base_addr,
+			       hw[info->priv[0].type].io_size);
+
+		for (i = 0; i < 2; i++)
+			free_netdev(info->dev[i]);
+
+		/* Free memory */
+		first = info->next;
+		kfree(info);
+	}
 }
 
 #ifndef MODULE
-void __init dmascc_setup(char *str, int *ints) {
-   int i;
+void __init dmascc_setup(char *str, int *ints)
+{
+	int i;
 
-   for (i = 0; i < MAX_NUM_DEVS && i < ints[0]; i++)
-      io[i] = ints[i+1];
+	for (i = 0; i < MAX_NUM_DEVS && i < ints[0]; i++)
+		io[i] = ints[i + 1];
 }
 #endif
 
-static int __init dmascc_init(void) {
-  int h, i, j, n;
-  int base[MAX_NUM_DEVS], tcmd[MAX_NUM_DEVS], t0[MAX_NUM_DEVS],
-    t1[MAX_NUM_DEVS];
-  unsigned t_val;
-  unsigned long time, start[MAX_NUM_DEVS], delay[MAX_NUM_DEVS],
-    counting[MAX_NUM_DEVS];
-
-  /* Initialize random number generator */
-  rand = jiffies;
-  /* Cards found = 0 */
-  n = 0;
-  /* Warning message */
-  if (!io[0]) printk(KERN_INFO "dmascc: autoprobing (dangerous)\n");
-
-  /* Run autodetection for each card type */
-  for (h = 0; h < NUM_TYPES; h++) {
-
-    if (io[0]) {
-      /* User-specified I/O address regions */
-      for (i = 0; i < hw[h].num_devs; i++) base[i] = 0;
-      for (i = 0; i < MAX_NUM_DEVS && io[i]; i++) {
-	j = (io[i] - hw[h].io_region) / hw[h].io_delta;
-	if (j >= 0 &&
-	    j < hw[h].num_devs && 
-	    hw[h].io_region + j * hw[h].io_delta == io[i]) {
-	  base[j] = io[i];
-	}
-      }
-    } else {
-      /* Default I/O address regions */
-      for (i = 0; i < hw[h].num_devs; i++) {
-	base[i] = hw[h].io_region + i * hw[h].io_delta;
-      }
-    }
-
-    /* Check valid I/O address regions */
-    for (i = 0; i < hw[h].num_devs; i++)
-      if (base[i]) {
-	if (!request_region(base[i], hw[h].io_size, "dmascc"))
-	  base[i] = 0;
-	else {
-	  tcmd[i] = base[i] + hw[h].tmr_offset + TMR_CTRL;
-	  t0[i]   = base[i] + hw[h].tmr_offset + TMR_CNT0;
-	  t1[i]   = base[i] + hw[h].tmr_offset + TMR_CNT1;
-	}
-      }
-
-    /* Start timers */
-    for (i = 0; i < hw[h].num_devs; i++)
-      if (base[i]) {
-	/* Timer 0: LSB+MSB, Mode 3, TMR_0_HZ */
-	outb(0x36, tcmd[i]);
-	outb((hw[h].tmr_hz/TMR_0_HZ) & 0xFF, t0[i]);
-	outb((hw[h].tmr_hz/TMR_0_HZ) >> 8, t0[i]);
-	/* Timer 1: LSB+MSB, Mode 0, HZ/10 */
-	outb(0x70, tcmd[i]);
-	outb((TMR_0_HZ/HZ*10) & 0xFF, t1[i]);
-	outb((TMR_0_HZ/HZ*10) >> 8, t1[i]);
-	start[i] = jiffies;
-	delay[i] = 0;
-	counting[i] = 1;
-	/* Timer 2: LSB+MSB, Mode 0 */
-	outb(0xb0, tcmd[i]);
-      }
-    time = jiffies;
-    /* Wait until counter registers are loaded */
-    udelay(2000000/TMR_0_HZ);
-
-    /* Timing loop */
-    while (jiffies - time < 13) {
-      for (i = 0; i < hw[h].num_devs; i++)
-	if (base[i] && counting[i]) {
-	  /* Read back Timer 1: latch; read LSB; read MSB */
-	  outb(0x40, tcmd[i]);
-	  t_val = inb(t1[i]) + (inb(t1[i]) << 8);
-	  /* Also check whether counter did wrap */
-	  if (t_val == 0 || t_val > TMR_0_HZ/HZ*10) counting[i] = 0;
-	  delay[i] = jiffies - start[i];
-	}
-    }
-
-    /* Evaluate measurements */
-    for (i = 0; i < hw[h].num_devs; i++)
-      if (base[i]) {
-	if ((delay[i] >= 9 && delay[i] <= 11)&& 
-	    /* Ok, we have found an adapter */
-	    (setup_adapter(base[i], h, n) == 0))
-	  n++;
-	else
-	  release_region(base[i], hw[h].io_size);
-      }
-
-  } /* NUM_TYPES */
+static int __init dmascc_init(void)
+{
+	int h, i, j, n;
+	int base[MAX_NUM_DEVS], tcmd[MAX_NUM_DEVS], t0[MAX_NUM_DEVS],
+	    t1[MAX_NUM_DEVS];
+	unsigned t_val;
+	unsigned long time, start[MAX_NUM_DEVS], delay[MAX_NUM_DEVS],
+	    counting[MAX_NUM_DEVS];
+
+	/* Initialize random number generator */
+	rand = jiffies;
+	/* Cards found = 0 */
+	n = 0;
+	/* Warning message */
+	if (!io[0])
+		printk(KERN_INFO "dmascc: autoprobing (dangerous)\n");
+
+	/* Run autodetection for each card type */
+	for (h = 0; h < NUM_TYPES; h++) {
+
+		if (io[0]) {
+			/* User-specified I/O address regions */
+			for (i = 0; i < hw[h].num_devs; i++)
+				base[i] = 0;
+			for (i = 0; i < MAX_NUM_DEVS && io[i]; i++) {
+				j = (io[i] -
+				     hw[h].io_region) / hw[h].io_delta;
+				if (j >= 0 && j < hw[h].num_devs
+				    && hw[h].io_region +
+				    j * hw[h].io_delta == io[i]) {
+					base[j] = io[i];
+				}
+			}
+		} else {
+			/* Default I/O address regions */
+			for (i = 0; i < hw[h].num_devs; i++) {
+				base[i] =
+				    hw[h].io_region + i * hw[h].io_delta;
+			}
+		}
 
-  /* If any adapter was successfully initialized, return ok */
-  if (n) return 0;
+		/* Check valid I/O address regions */
+		for (i = 0; i < hw[h].num_devs; i++)
+			if (base[i]) {
+				if (!request_region
+				    (base[i], hw[h].io_size, "dmascc"))
+					base[i] = 0;
+				else {
+					tcmd[i] =
+					    base[i] + hw[h].tmr_offset +
+					    TMR_CTRL;
+					t0[i] =
+					    base[i] + hw[h].tmr_offset +
+					    TMR_CNT0;
+					t1[i] =
+					    base[i] + hw[h].tmr_offset +
+					    TMR_CNT1;
+				}
+			}
+
+		/* Start timers */
+		for (i = 0; i < hw[h].num_devs; i++)
+			if (base[i]) {
+				/* Timer 0: LSB+MSB, Mode 3, TMR_0_HZ */
+				outb(0x36, tcmd[i]);
+				outb((hw[h].tmr_hz / TMR_0_HZ) & 0xFF,
+				     t0[i]);
+				outb((hw[h].tmr_hz / TMR_0_HZ) >> 8,
+				     t0[i]);
+				/* Timer 1: LSB+MSB, Mode 0, HZ/10 */
+				outb(0x70, tcmd[i]);
+				outb((TMR_0_HZ / HZ * 10) & 0xFF, t1[i]);
+				outb((TMR_0_HZ / HZ * 10) >> 8, t1[i]);
+				start[i] = jiffies;
+				delay[i] = 0;
+				counting[i] = 1;
+				/* Timer 2: LSB+MSB, Mode 0 */
+				outb(0xb0, tcmd[i]);
+			}
+		time = jiffies;
+		/* Wait until counter registers are loaded */
+		udelay(2000000 / TMR_0_HZ);
+
+		/* Timing loop */
+		while (jiffies - time < 13) {
+			for (i = 0; i < hw[h].num_devs; i++)
+				if (base[i] && counting[i]) {
+					/* Read back Timer 1: latch; read LSB; read MSB */
+					outb(0x40, tcmd[i]);
+					t_val =
+					    inb(t1[i]) + (inb(t1[i]) << 8);
+					/* Also check whether counter did wrap */
+					if (t_val == 0
+					    || t_val > TMR_0_HZ / HZ * 10)
+						counting[i] = 0;
+					delay[i] = jiffies - start[i];
+				}
+		}
 
-  /* If no adapter found, return error */
-  printk(KERN_INFO "dmascc: no adapters found\n");
-  return -EIO;
+		/* Evaluate measurements */
+		for (i = 0; i < hw[h].num_devs; i++)
+			if (base[i]) {
+				if ((delay[i] >= 9 && delay[i] <= 11) &&
+				    /* Ok, we have found an adapter */
+				    (setup_adapter(base[i], h, n) == 0))
+					n++;
+				else
+					release_region(base[i],
+						       hw[h].io_size);
+			}
+
+	}			/* NUM_TYPES */
+
+	/* If any adapter was successfully initialized, return ok */
+	if (n)
+		return 0;
+
+	/* If no adapter found, return error */
+	printk(KERN_INFO "dmascc: no adapters found\n");
+	return -EIO;
 }
 
 module_init(dmascc_init);
@@ -452,8 +473,8 @@
 	info = kmalloc(sizeof(struct scc_info), GFP_KERNEL | GFP_DMA);
 	if (!info) {
 		printk(KERN_ERR "dmascc: "
-			"could not allocate memory for %s at %#3x\n",
-			hw[type].name, card_base);
+		       "could not allocate memory for %s at %#3x\n",
+		       hw[type].name, card_base);
 		goto out;
 	}
 
@@ -463,16 +484,16 @@
 	info->dev[0] = alloc_netdev(0, "", dev_setup);
 	if (!info->dev[0]) {
 		printk(KERN_ERR "dmascc: "
-			"could not allocate memory for %s at %#3x\n",
-			hw[type].name, card_base);
+		       "could not allocate memory for %s at %#3x\n",
+		       hw[type].name, card_base);
 		goto out1;
 	}
 
 	info->dev[1] = alloc_netdev(0, "", dev_setup);
 	if (!info->dev[1]) {
 		printk(KERN_ERR "dmascc: "
-			"could not allocate memory for %s at %#3x\n",
-			hw[type].name, card_base);
+		       "could not allocate memory for %s at %#3x\n",
+		       hw[type].name, card_base);
 		goto out2;
 	}
 	spin_lock_init(&info->register_lock);
@@ -526,7 +547,8 @@
 	outb(0, tmr_base + TMR_CNT1);
 
 	/* Wait and detect IRQ */
-	time = jiffies; while (jiffies - time < 2 + HZ / TMR_0_HZ);
+	time = jiffies;
+	while (jiffies - time < 2 + HZ / TMR_0_HZ);
 	irq = probe_irq_off(irqs);
 
 	/* Clear pending interrupt, disable interrupts */
@@ -539,8 +561,9 @@
 	}
 
 	if (irq <= 0) {
-		printk(KERN_ERR "dmascc: could not find irq of %s at %#3x (irq=%d)\n",
-			hw[type].name, card_base, irq);
+		printk(KERN_ERR
+		       "dmascc: could not find irq of %s at %#3x (irq=%d)\n",
+		       hw[type].name, card_base, irq);
 		goto out3;
 	}
 
@@ -568,7 +591,7 @@
 		priv->param.dma = -1;
 		INIT_WORK(&priv->rx_work, rx_bh, priv);
 		dev->priv = priv;
-		sprintf(dev->name, "dmascc%i", 2*n+i);
+		sprintf(dev->name, "dmascc%i", 2 * n + i);
 		SET_MODULE_OWNER(dev);
 		dev->base_addr = card_base;
 		dev->irq = irq;
@@ -583,820 +606,888 @@
 	}
 	if (register_netdev(info->dev[0])) {
 		printk(KERN_ERR "dmascc: could not register %s\n",
-				info->dev[0]->name);
+		       info->dev[0]->name);
 		goto out3;
 	}
 	if (register_netdev(info->dev[1])) {
 		printk(KERN_ERR "dmascc: could not register %s\n",
-				info->dev[1]->name);
+		       info->dev[1]->name);
 		goto out4;
 	}
 
 
 	info->next = first;
 	first = info;
-	printk(KERN_INFO "dmascc: found %s (%s) at %#3x, irq %d\n", hw[type].name,
-	chipnames[chip], card_base, irq);
+	printk(KERN_INFO "dmascc: found %s (%s) at %#3x, irq %d\n",
+	       hw[type].name, chipnames[chip], card_base, irq);
 	return 0;
 
-out4:
+      out4:
 	unregister_netdev(info->dev[0]);
-out3:
+      out3:
 	if (info->priv[0].type == TYPE_TWIN)
 		outb(0, info->dev[0]->base_addr + TWIN_SERIAL_CFG);
 	write_scc(&info->priv[0], R9, FHWRES);
 	free_netdev(info->dev[1]);
-out2:
+      out2:
 	free_netdev(info->dev[0]);
-out1:
+      out1:
 	kfree(info);
-out:
+      out:
 	return -1;
 }
 
 
 /* Driver functions */
 
-static void write_scc(struct scc_priv *priv, int reg, int val) {
-  unsigned long flags;
-  switch (priv->type) {
-  case TYPE_S5:
-    if (reg) outb(reg, priv->scc_cmd);
-    outb(val, priv->scc_cmd);
-    return;
-  case TYPE_TWIN:
-    if (reg) outb_p(reg, priv->scc_cmd);
-    outb_p(val, priv->scc_cmd);
-    return;
-  default:
-    spin_lock_irqsave(priv->register_lock, flags);
-    outb_p(0, priv->card_base + PI_DREQ_MASK);
-    if (reg) outb_p(reg, priv->scc_cmd);
-    outb_p(val, priv->scc_cmd);
-    outb(1, priv->card_base + PI_DREQ_MASK);
-    spin_unlock_irqrestore(priv->register_lock, flags);
-    return;
-  }
-}
-
-
-static void write_scc_data(struct scc_priv *priv, int val, int fast) {
-  unsigned long flags;
-  switch (priv->type) {
-  case TYPE_S5:
-    outb(val, priv->scc_data);
-    return;
-  case TYPE_TWIN:
-    outb_p(val, priv->scc_data);
-    return;
-  default:
-    if (fast) outb_p(val, priv->scc_data);
-    else {
-      spin_lock_irqsave(priv->register_lock, flags);
-      outb_p(0, priv->card_base + PI_DREQ_MASK);
-      outb_p(val, priv->scc_data);
-      outb(1, priv->card_base + PI_DREQ_MASK);
-      spin_unlock_irqrestore(priv->register_lock, flags);
-    }
-    return;
-  }
-}
-
-
-static int read_scc(struct scc_priv *priv, int reg) {
-  int rc;
-  unsigned long flags;
-  switch (priv->type) {
-  case TYPE_S5:
-    if (reg) outb(reg, priv->scc_cmd);
-    return inb(priv->scc_cmd);
-  case TYPE_TWIN:
-    if (reg) outb_p(reg, priv->scc_cmd);
-    return inb_p(priv->scc_cmd);
-  default:
-    spin_lock_irqsave(priv->register_lock, flags);
-    outb_p(0, priv->card_base + PI_DREQ_MASK);
-    if (reg) outb_p(reg, priv->scc_cmd);
-    rc = inb_p(priv->scc_cmd);
-    outb(1, priv->card_base + PI_DREQ_MASK);
-    spin_unlock_irqrestore(priv->register_lock, flags);
-    return rc;
-  }
-}
-
-
-static int read_scc_data(struct scc_priv *priv) {
-  int rc;
-  unsigned long flags;
-  switch (priv->type) {
-  case TYPE_S5:
-    return inb(priv->scc_data);
-  case TYPE_TWIN:
-    return inb_p(priv->scc_data);
-  default:
-    spin_lock_irqsave(priv->register_lock, flags);
-    outb_p(0, priv->card_base + PI_DREQ_MASK);
-    rc = inb_p(priv->scc_data);
-    outb(1, priv->card_base + PI_DREQ_MASK);
-    spin_unlock_irqrestore(priv->register_lock, flags);
-    return rc;
-  }
-}
-
-
-static int scc_open(struct net_device *dev) {
-  struct scc_priv *priv = dev->priv;
-  struct scc_info *info = priv->info;
-  int card_base = priv->card_base;
-
-  /* Request IRQ if not already used by other channel */
-  if (!info->irq_used) {
-    if (request_irq(dev->irq, scc_isr, 0, "dmascc", info)) {
-      return -EAGAIN;
-    }
-  }
-  info->irq_used++;
-
-  /* Request DMA if required */
-  if (priv->param.dma >= 0) {
-    if (request_dma(priv->param.dma, "dmascc")) {
-      if (--info->irq_used == 0) free_irq(dev->irq, info);
-      return -EAGAIN;
-    } else {
-      unsigned long flags = claim_dma_lock();
-      clear_dma_ff(priv->param.dma);
-      release_dma_lock(flags);
-    }
-  }
-
-  /* Initialize local variables */
-  priv->rx_ptr = 0;
-  priv->rx_over = 0;
-  priv->rx_head = priv->rx_tail = priv->rx_count = 0;
-  priv->state = IDLE;
-  priv->tx_head = priv->tx_tail = priv->tx_count = 0;
-  priv->tx_ptr = 0;
-
-  /* Reset channel */
-  write_scc(priv, R9, (priv->channel ? CHRB : CHRA) | MIE | NV);
-  /* X1 clock, SDLC mode */
-  write_scc(priv, R4, SDLC | X1CLK);
-  /* DMA */
-  write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN);
-  /* 8 bit RX char, RX disable */
-  write_scc(priv, R3, Rx8);
-  /* 8 bit TX char, TX disable */
-  write_scc(priv, R5, Tx8);
-  /* SDLC address field */
-  write_scc(priv, R6, 0);
-  /* SDLC flag */
-  write_scc(priv, R7, FLAG);
-  switch (priv->chip) {
-  case Z85C30:
-    /* Select WR7' */
-    write_scc(priv, R15, SHDLCE);
-    /* Auto EOM reset */
-    write_scc(priv, R7, AUTOEOM);
-    write_scc(priv, R15, 0);
-    break;
-  case Z85230:
-    /* Select WR7' */
-    write_scc(priv, R15, SHDLCE);
-    /* The following bits are set (see 2.5.2.1):
-       - Automatic EOM reset
-       - Interrupt request if RX FIFO is half full
-         This bit should be ignored in DMA mode (according to the
-         documentation), but actually isn't. The receiver doesn't work if
-         it is set. Thus, we have to clear it in DMA mode.
-       - Interrupt/DMA request if TX FIFO is completely empty
-         a) If set, the ESCC behaves as if it had no TX FIFO (Z85C30
-            compatibility).
-         b) If cleared, DMA requests may follow each other very quickly,
-            filling up the TX FIFO.
-            Advantage: TX works even in case of high bus latency.
-            Disadvantage: Edge-triggered DMA request circuitry may miss
-                          a request. No more data is delivered, resulting
-                          in a TX FIFO underrun.
-         Both PI2 and S5SCC/DMA seem to work fine with TXFIFOE cleared.
-         The PackeTwin doesn't. I don't know about the PI, but let's
-	 assume it behaves like the PI2.
-    */
-    if (priv->param.dma >= 0) {
-      if (priv->type == TYPE_TWIN) write_scc(priv, R7, AUTOEOM | TXFIFOE);
-      else write_scc(priv, R7, AUTOEOM);
-    } else {
-      write_scc(priv, R7, AUTOEOM | RXFIFOH);
-    }
-    write_scc(priv, R15, 0);
-    break;
-  }
-  /* Preset CRC, NRZ(I) encoding */
-  write_scc(priv, R10, CRCPS | (priv->param.nrzi ? NRZI : NRZ));
-
-  /* Configure baud rate generator */
-  if (priv->param.brg_tc >= 0) {
-    /* Program BR generator */
-    write_scc(priv, R12, priv->param.brg_tc & 0xFF);
-    write_scc(priv, R13, (priv->param.brg_tc>>8) & 0xFF);
-    /* BRG source = SYS CLK; enable BRG; DTR REQ function (required by
-       PackeTwin, not connected on the PI2); set DPLL source to BRG */
-    write_scc(priv, R14, SSBR | DTRREQ | BRSRC | BRENABL);
-    /* Enable DPLL */
-    write_scc(priv, R14, SEARCH | DTRREQ | BRSRC | BRENABL);
-  } else {
-    /* Disable BR generator */
-    write_scc(priv, R14, DTRREQ | BRSRC);
-  }
-
-  /* Configure clocks */
-  if (priv->type == TYPE_TWIN) {
-    /* Disable external TX clock receiver */
-    outb((info->twin_serial_cfg &=
-	    ~(priv->channel ? TWIN_EXTCLKB : TWIN_EXTCLKA)), 
-	   card_base + TWIN_SERIAL_CFG);
-  }
-  write_scc(priv, R11, priv->param.clocks);
-  if ((priv->type == TYPE_TWIN) && !(priv->param.clocks & TRxCOI)) {
-    /* Enable external TX clock receiver */
-    outb((info->twin_serial_cfg |=
-	    (priv->channel ? TWIN_EXTCLKB : TWIN_EXTCLKA)),
-	   card_base + TWIN_SERIAL_CFG);
-  }
-
-  /* Configure PackeTwin */
-  if (priv->type == TYPE_TWIN) {
-    /* Assert DTR, enable interrupts */
-    outb((info->twin_serial_cfg |= TWIN_EI |
-	    (priv->channel ? TWIN_DTRB_ON : TWIN_DTRA_ON)),
-	   card_base + TWIN_SERIAL_CFG);
-  }
-
-  /* Read current status */
-  priv->rr0 = read_scc(priv, R0);
-  /* Enable DCD interrupt */
-  write_scc(priv, R15, DCDIE);
-
-  netif_start_queue(dev);
-
-  return 0;
-}
-
-
-static int scc_close(struct net_device *dev) {
-  struct scc_priv *priv = dev->priv;
-  struct scc_info *info = priv->info;
-  int card_base = priv->card_base;
-
-  netif_stop_queue(dev);
-
-  if (priv->type == TYPE_TWIN) {
-    /* Drop DTR */
-    outb((info->twin_serial_cfg &=
-	    (priv->channel ? ~TWIN_DTRB_ON : ~TWIN_DTRA_ON)),
-	   card_base + TWIN_SERIAL_CFG);
-  }
-
-  /* Reset channel, free DMA and IRQ */
-  write_scc(priv, R9, (priv->channel ? CHRB : CHRA) | MIE | NV);
-  if (priv->param.dma >= 0) {
-    if (priv->type == TYPE_TWIN) outb(0, card_base + TWIN_DMA_CFG);
-    free_dma(priv->param.dma);
-  }
-  if (--info->irq_used == 0) free_irq(dev->irq, info);
-
-  return 0;
-}
-
-
-static int scc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) {
-  struct scc_priv *priv = dev->priv;
-  
-  switch (cmd) {
-  case SIOCGSCCPARAM:
-    if (copy_to_user(ifr->ifr_data, &priv->param, sizeof(struct scc_param)))
-      return -EFAULT;
-    return 0;
-  case SIOCSSCCPARAM:
-    if (!capable(CAP_NET_ADMIN)) return -EPERM;
-    if (netif_running(dev)) return -EAGAIN;
-    if (copy_from_user(&priv->param, ifr->ifr_data, sizeof(struct scc_param)))
-      return -EFAULT;
-    return 0;
-  default:
-    return -EINVAL;
-  }
-}
-
-
-static int scc_send_packet(struct sk_buff *skb, struct net_device *dev) {
-  struct scc_priv *priv = dev->priv;
-  unsigned long flags;
-  int i;
-
-  /* Temporarily stop the scheduler feeding us packets */
-  netif_stop_queue(dev);
-
-  /* Transfer data to DMA buffer */
-  i = priv->tx_head;
-  memcpy(priv->tx_buf[i], skb->data+1, skb->len-1);
-  priv->tx_len[i] = skb->len-1;
-
-  /* Clear interrupts while we touch our circular buffers */
-
-  spin_lock_irqsave(&priv->ring_lock, flags);
-  /* Move the ring buffer's head */
-  priv->tx_head = (i + 1) % NUM_TX_BUF;
-  priv->tx_count++;
-
-  /* If we just filled up the last buffer, leave queue stopped.
-     The higher layers must wait until we have a DMA buffer
-     to accept the data. */
-  if (priv->tx_count < NUM_TX_BUF) netif_wake_queue(dev);
-
-  /* Set new TX state */
-  if (priv->state == IDLE) {
-    /* Assert RTS, start timer */
-    priv->state = TX_HEAD;
-    priv->tx_start = jiffies;
-    write_scc(priv, R5, TxCRC_ENAB | RTS | TxENAB | Tx8);
-    write_scc(priv, R15, 0);
-    start_timer(priv, priv->param.txdelay, 0);
-  }
-
-  /* Turn interrupts back on and free buffer */
-  spin_unlock_irqrestore(&priv->ring_lock, flags);
-  dev_kfree_skb(skb);
-
-  return 0;
-}
-
-
-static struct net_device_stats *scc_get_stats(struct net_device *dev) {
-  struct scc_priv *priv = dev->priv;
-
-  return &priv->stats;
-}
-
-
-static int scc_set_mac_address(struct net_device *dev, void *sa) {
-  memcpy(dev->dev_addr, ((struct sockaddr *)sa)->sa_data, dev->addr_len);
-  return 0;
-}
-
-
-static inline void tx_on(struct scc_priv *priv) {
-  int i, n;
-  unsigned long flags;
-
-  if (priv->param.dma >= 0) {
-    n = (priv->chip == Z85230) ? 3 : 1;
-    /* Program DMA controller */
-    flags = claim_dma_lock();
-    set_dma_mode(priv->param.dma, DMA_MODE_WRITE);
-    set_dma_addr(priv->param.dma, (int) priv->tx_buf[priv->tx_tail]+n);
-    set_dma_count(priv->param.dma, priv->tx_len[priv->tx_tail]-n);
-    release_dma_lock(flags);
-    /* Enable TX underrun interrupt */
-    write_scc(priv, R15, TxUIE);
-    /* Configure DREQ */
-    if (priv->type == TYPE_TWIN)
-      outb((priv->param.dma == 1) ? TWIN_DMA_HDX_T1 : TWIN_DMA_HDX_T3,
-	   priv->card_base + TWIN_DMA_CFG);
-    else
-      write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN | WT_RDY_ENAB);
-    /* Write first byte(s) */
-    spin_lock_irqsave(priv->register_lock, flags);
-    for (i = 0; i < n; i++)
-      write_scc_data(priv, priv->tx_buf[priv->tx_tail][i], 1);
-    enable_dma(priv->param.dma);
-    spin_unlock_irqrestore(priv->register_lock, flags);
-  } else {
-    write_scc(priv, R15, TxUIE);
-    write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN | TxINT_ENAB);
-    tx_isr(priv);
-  }
-  /* Reset EOM latch if we do not have the AUTOEOM feature */
-  if (priv->chip == Z8530) write_scc(priv, R0, RES_EOM_L);
-}
-
-
-static inline void rx_on(struct scc_priv *priv) {
-  unsigned long flags;
-
-  /* Clear RX FIFO */
-  while (read_scc(priv, R0) & Rx_CH_AV) read_scc_data(priv);
-  priv->rx_over = 0;
-  if (priv->param.dma >= 0) {
-    /* Program DMA controller */
-    flags = claim_dma_lock();
-    set_dma_mode(priv->param.dma, DMA_MODE_READ);
-    set_dma_addr(priv->param.dma, (int) priv->rx_buf[priv->rx_head]);
-    set_dma_count(priv->param.dma, BUF_SIZE);
-    release_dma_lock(flags);
-    enable_dma(priv->param.dma);
-    /* Configure PackeTwin DMA */
-    if (priv->type == TYPE_TWIN) {
-      outb((priv->param.dma == 1) ? TWIN_DMA_HDX_R1 : TWIN_DMA_HDX_R3,
-	   priv->card_base + TWIN_DMA_CFG);
-    }
-    /* Sp. cond. intr. only, ext int enable, RX DMA enable */
-    write_scc(priv, R1, EXT_INT_ENAB | INT_ERR_Rx |
-	      WT_RDY_RT | WT_FN_RDYFN | WT_RDY_ENAB);
-  } else {
-    /* Reset current frame */
-    priv->rx_ptr = 0;
-    /* Intr. on all Rx characters and Sp. cond., ext int enable */
-    write_scc(priv, R1, EXT_INT_ENAB | INT_ALL_Rx | WT_RDY_RT |
-	      WT_FN_RDYFN);
-  }
-  write_scc(priv, R0, ERR_RES);
-  write_scc(priv, R3, RxENABLE | Rx8 | RxCRC_ENAB);
-}
-
-
-static inline void rx_off(struct scc_priv *priv) {
-  /* Disable receiver */
-  write_scc(priv, R3, Rx8);
-  /* Disable DREQ / RX interrupt */
-  if (priv->param.dma >= 0 && priv->type == TYPE_TWIN)
-    outb(0, priv->card_base + TWIN_DMA_CFG);
-  else
-    write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN);
-  /* Disable DMA */
-  if (priv->param.dma >= 0) disable_dma(priv->param.dma);
-}
-
-
-static void start_timer(struct scc_priv *priv, int t, int r15) {
-  unsigned long flags;
-
-  outb(priv->tmr_mode, priv->tmr_ctrl);
-  if (t == 0) {
-    tm_isr(priv);
-  } else if (t > 0) {
-    save_flags(flags);
-    cli();
-    outb(t & 0xFF, priv->tmr_cnt);
-    outb((t >> 8) & 0xFF, priv->tmr_cnt);
-    if (priv->type != TYPE_TWIN) {
-      write_scc(priv, R15, r15 | CTSIE);
-      priv->rr0 |= CTS;
-    }
-    restore_flags(flags);
-  }
-}
-
-
-static inline unsigned char random(void) {
-  /* See "Numerical Recipes in C", second edition, p. 284 */
-  rand = rand * 1664525L + 1013904223L;
-  return (unsigned char) (rand >> 24);
-}
-
-static inline void z8530_isr(struct scc_info *info) {
-  int is, i = 100;
-
-  while ((is = read_scc(&info->priv[0], R3)) && i--) {
-    if (is & CHARxIP) {
-      rx_isr(&info->priv[0]);
-    } else if (is & CHATxIP) {
-      tx_isr(&info->priv[0]);
-    } else if (is & CHAEXT) {
-      es_isr(&info->priv[0]);
-    } else if (is & CHBRxIP) {
-      rx_isr(&info->priv[1]);
-    } else if (is & CHBTxIP) {
-      tx_isr(&info->priv[1]);
-    } else {
-      es_isr(&info->priv[1]);
-    }
-    write_scc(&info->priv[0], R0, RES_H_IUS);
-    i++;
-  }
-  if (i < 0) {
-    printk(KERN_ERR "dmascc: stuck in ISR with RR3=0x%02x.\n", is);
-  }
-  /* Ok, no interrupts pending from this 8530. The INT line should
-     be inactive now. */
-}
-
-
-static irqreturn_t scc_isr(int irq, void *dev_id, struct pt_regs * regs) {
-  struct scc_info *info = dev_id;
-
-  spin_lock(info->priv[0].register_lock);
-  /* At this point interrupts are enabled, and the interrupt under service
-     is already acknowledged, but masked off.
-
-     Interrupt processing: We loop until we know that the IRQ line is
-     low. If another positive edge occurs afterwards during the ISR,
-     another interrupt will be triggered by the interrupt controller
-     as soon as the IRQ level is enabled again (see asm/irq.h).
-
-     Bottom-half handlers will be processed after scc_isr(). This is
-     important, since we only have small ringbuffers and want new data
-     to be fetched/delivered immediately. */
-
-  if (info->priv[0].type == TYPE_TWIN) {
-    int is, card_base = info->priv[0].card_base;
-    while ((is = ~inb(card_base + TWIN_INT_REG)) &
-	   TWIN_INT_MSK) {
-      if (is & TWIN_SCC_MSK) {
-	z8530_isr(info);
-      } else if (is & TWIN_TMR1_MSK) {
-	inb(card_base + TWIN_CLR_TMR1);
-	tm_isr(&info->priv[0]);
-      } else {
-	inb(card_base + TWIN_CLR_TMR2);
-	tm_isr(&info->priv[1]);
-      }
-    }
-  } else z8530_isr(info);
-  spin_unlock(info->priv[0].register_lock);
-  return IRQ_HANDLED;
-}
-
-
-static void rx_isr(struct scc_priv *priv) {
-  if (priv->param.dma >= 0) {
-    /* Check special condition and perform error reset. See 2.4.7.5. */
-    special_condition(priv, read_scc(priv, R1));
-    write_scc(priv, R0, ERR_RES);
-  } else {
-    /* Check special condition for each character. Error reset not necessary.
-       Same algorithm for SCC and ESCC. See 2.4.7.1 and 2.4.7.4. */
-    int rc;
-    while (read_scc(priv, R0) & Rx_CH_AV) {
-      rc = read_scc(priv, R1);
-      if (priv->rx_ptr < BUF_SIZE)
-	priv->rx_buf[priv->rx_head][priv->rx_ptr++] =
-	  read_scc_data(priv);
-      else {
-	priv->rx_over = 2;
-	read_scc_data(priv);
-      }
-      special_condition(priv, rc);
-    }
-  }
-}
-
-
-static void special_condition(struct scc_priv *priv, int rc) {
-  int cb;
-  unsigned long flags;
-
-  /* See Figure 2-15. Only overrun and EOF need to be checked. */
-  
-  if (rc & Rx_OVR) {
-    /* Receiver overrun */
-    priv->rx_over = 1;
-    if (priv->param.dma < 0) write_scc(priv, R0, ERR_RES);
-  } else if (rc & END_FR) {
-    /* End of frame. Get byte count */
-    if (priv->param.dma >= 0) {
-      flags = claim_dma_lock();
-      cb = BUF_SIZE - get_dma_residue(priv->param.dma) - 2;
-      release_dma_lock(flags);
-    } else {
-      cb = priv->rx_ptr - 2;
-    }
-    if (priv->rx_over) {
-      /* We had an overrun */
-      priv->stats.rx_errors++;
-      if (priv->rx_over == 2) priv->stats.rx_length_errors++;
-      else priv->stats.rx_fifo_errors++;
-      priv->rx_over = 0;
-    } else if (rc & CRC_ERR) {
-      /* Count invalid CRC only if packet length >= minimum */
-      if (cb >= 15) {
-	priv->stats.rx_errors++;
-	priv->stats.rx_crc_errors++;
-      }
-    } else {
-      if (cb >= 15) {
-	if (priv->rx_count < NUM_RX_BUF - 1) {
-	  /* Put good frame in FIFO */
-	  priv->rx_len[priv->rx_head] = cb;
-	  priv->rx_head = (priv->rx_head + 1) % NUM_RX_BUF;
-	  priv->rx_count++;
-	  schedule_work(&priv->rx_work);
+static void write_scc(struct scc_priv *priv, int reg, int val)
+{
+	unsigned long flags;
+	switch (priv->type) {
+	case TYPE_S5:
+		if (reg)
+			outb(reg, priv->scc_cmd);
+		outb(val, priv->scc_cmd);
+		return;
+	case TYPE_TWIN:
+		if (reg)
+			outb_p(reg, priv->scc_cmd);
+		outb_p(val, priv->scc_cmd);
+		return;
+	default:
+		spin_lock_irqsave(priv->register_lock, flags);
+		outb_p(0, priv->card_base + PI_DREQ_MASK);
+		if (reg)
+			outb_p(reg, priv->scc_cmd);
+		outb_p(val, priv->scc_cmd);
+		outb(1, priv->card_base + PI_DREQ_MASK);
+		spin_unlock_irqrestore(priv->register_lock, flags);
+		return;
+	}
+}
+
+
+static void write_scc_data(struct scc_priv *priv, int val, int fast)
+{
+	unsigned long flags;
+	switch (priv->type) {
+	case TYPE_S5:
+		outb(val, priv->scc_data);
+		return;
+	case TYPE_TWIN:
+		outb_p(val, priv->scc_data);
+		return;
+	default:
+		if (fast)
+			outb_p(val, priv->scc_data);
+		else {
+			spin_lock_irqsave(priv->register_lock, flags);
+			outb_p(0, priv->card_base + PI_DREQ_MASK);
+			outb_p(val, priv->scc_data);
+			outb(1, priv->card_base + PI_DREQ_MASK);
+			spin_unlock_irqrestore(priv->register_lock, flags);
+		}
+		return;
+	}
+}
+
+
+static int read_scc(struct scc_priv *priv, int reg)
+{
+	int rc;
+	unsigned long flags;
+	switch (priv->type) {
+	case TYPE_S5:
+		if (reg)
+			outb(reg, priv->scc_cmd);
+		return inb(priv->scc_cmd);
+	case TYPE_TWIN:
+		if (reg)
+			outb_p(reg, priv->scc_cmd);
+		return inb_p(priv->scc_cmd);
+	default:
+		spin_lock_irqsave(priv->register_lock, flags);
+		outb_p(0, priv->card_base + PI_DREQ_MASK);
+		if (reg)
+			outb_p(reg, priv->scc_cmd);
+		rc = inb_p(priv->scc_cmd);
+		outb(1, priv->card_base + PI_DREQ_MASK);
+		spin_unlock_irqrestore(priv->register_lock, flags);
+		return rc;
+	}
+}
+
+
+static int read_scc_data(struct scc_priv *priv)
+{
+	int rc;
+	unsigned long flags;
+	switch (priv->type) {
+	case TYPE_S5:
+		return inb(priv->scc_data);
+	case TYPE_TWIN:
+		return inb_p(priv->scc_data);
+	default:
+		spin_lock_irqsave(priv->register_lock, flags);
+		outb_p(0, priv->card_base + PI_DREQ_MASK);
+		rc = inb_p(priv->scc_data);
+		outb(1, priv->card_base + PI_DREQ_MASK);
+		spin_unlock_irqrestore(priv->register_lock, flags);
+		return rc;
+	}
+}
+
+
+static int scc_open(struct net_device *dev)
+{
+	struct scc_priv *priv = dev->priv;
+	struct scc_info *info = priv->info;
+	int card_base = priv->card_base;
+
+	/* Request IRQ if not already used by other channel */
+	if (!info->irq_used) {
+		if (request_irq(dev->irq, scc_isr, 0, "dmascc", info)) {
+			return -EAGAIN;
+		}
+	}
+	info->irq_used++;
+
+	/* Request DMA if required */
+	if (priv->param.dma >= 0) {
+		if (request_dma(priv->param.dma, "dmascc")) {
+			if (--info->irq_used == 0)
+				free_irq(dev->irq, info);
+			return -EAGAIN;
+		} else {
+			unsigned long flags = claim_dma_lock();
+			clear_dma_ff(priv->param.dma);
+			release_dma_lock(flags);
+		}
+	}
+
+	/* Initialize local variables */
+	priv->rx_ptr = 0;
+	priv->rx_over = 0;
+	priv->rx_head = priv->rx_tail = priv->rx_count = 0;
+	priv->state = IDLE;
+	priv->tx_head = priv->tx_tail = priv->tx_count = 0;
+	priv->tx_ptr = 0;
+
+	/* Reset channel */
+	write_scc(priv, R9, (priv->channel ? CHRB : CHRA) | MIE | NV);
+	/* X1 clock, SDLC mode */
+	write_scc(priv, R4, SDLC | X1CLK);
+	/* DMA */
+	write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN);
+	/* 8 bit RX char, RX disable */
+	write_scc(priv, R3, Rx8);
+	/* 8 bit TX char, TX disable */
+	write_scc(priv, R5, Tx8);
+	/* SDLC address field */
+	write_scc(priv, R6, 0);
+	/* SDLC flag */
+	write_scc(priv, R7, FLAG);
+	switch (priv->chip) {
+	case Z85C30:
+		/* Select WR7' */
+		write_scc(priv, R15, SHDLCE);
+		/* Auto EOM reset */
+		write_scc(priv, R7, AUTOEOM);
+		write_scc(priv, R15, 0);
+		break;
+	case Z85230:
+		/* Select WR7' */
+		write_scc(priv, R15, SHDLCE);
+		/* The following bits are set (see 2.5.2.1):
+		   - Automatic EOM reset
+		   - Interrupt request if RX FIFO is half full
+		   This bit should be ignored in DMA mode (according to the
+		   documentation), but actually isn't. The receiver doesn't work if
+		   it is set. Thus, we have to clear it in DMA mode.
+		   - Interrupt/DMA request if TX FIFO is completely empty
+		   a) If set, the ESCC behaves as if it had no TX FIFO (Z85C30
+		   compatibility).
+		   b) If cleared, DMA requests may follow each other very quickly,
+		   filling up the TX FIFO.
+		   Advantage: TX works even in case of high bus latency.
+		   Disadvantage: Edge-triggered DMA request circuitry may miss
+		   a request. No more data is delivered, resulting
+		   in a TX FIFO underrun.
+		   Both PI2 and S5SCC/DMA seem to work fine with TXFIFOE cleared.
+		   The PackeTwin doesn't. I don't know about the PI, but let's
+		   assume it behaves like the PI2.
+		 */
+		if (priv->param.dma >= 0) {
+			if (priv->type == TYPE_TWIN)
+				write_scc(priv, R7, AUTOEOM | TXFIFOE);
+			else
+				write_scc(priv, R7, AUTOEOM);
+		} else {
+			write_scc(priv, R7, AUTOEOM | RXFIFOH);
+		}
+		write_scc(priv, R15, 0);
+		break;
+	}
+	/* Preset CRC, NRZ(I) encoding */
+	write_scc(priv, R10, CRCPS | (priv->param.nrzi ? NRZI : NRZ));
+
+	/* Configure baud rate generator */
+	if (priv->param.brg_tc >= 0) {
+		/* Program BR generator */
+		write_scc(priv, R12, priv->param.brg_tc & 0xFF);
+		write_scc(priv, R13, (priv->param.brg_tc >> 8) & 0xFF);
+		/* BRG source = SYS CLK; enable BRG; DTR REQ function (required by
+		   PackeTwin, not connected on the PI2); set DPLL source to BRG */
+		write_scc(priv, R14, SSBR | DTRREQ | BRSRC | BRENABL);
+		/* Enable DPLL */
+		write_scc(priv, R14, SEARCH | DTRREQ | BRSRC | BRENABL);
 	} else {
-	  priv->stats.rx_errors++;
-	  priv->stats.rx_over_errors++;
+		/* Disable BR generator */
+		write_scc(priv, R14, DTRREQ | BRSRC);
+	}
+
+	/* Configure clocks */
+	if (priv->type == TYPE_TWIN) {
+		/* Disable external TX clock receiver */
+		outb((info->twin_serial_cfg &=
+		      ~(priv->channel ? TWIN_EXTCLKB : TWIN_EXTCLKA)),
+		     card_base + TWIN_SERIAL_CFG);
+	}
+	write_scc(priv, R11, priv->param.clocks);
+	if ((priv->type == TYPE_TWIN) && !(priv->param.clocks & TRxCOI)) {
+		/* Enable external TX clock receiver */
+		outb((info->twin_serial_cfg |=
+		      (priv->channel ? TWIN_EXTCLKB : TWIN_EXTCLKA)),
+		     card_base + TWIN_SERIAL_CFG);
+	}
+
+	/* Configure PackeTwin */
+	if (priv->type == TYPE_TWIN) {
+		/* Assert DTR, enable interrupts */
+		outb((info->twin_serial_cfg |= TWIN_EI |
+		      (priv->channel ? TWIN_DTRB_ON : TWIN_DTRA_ON)),
+		     card_base + TWIN_SERIAL_CFG);
+	}
+
+	/* Read current status */
+	priv->rr0 = read_scc(priv, R0);
+	/* Enable DCD interrupt */
+	write_scc(priv, R15, DCDIE);
+
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+
+static int scc_close(struct net_device *dev)
+{
+	struct scc_priv *priv = dev->priv;
+	struct scc_info *info = priv->info;
+	int card_base = priv->card_base;
+
+	netif_stop_queue(dev);
+
+	if (priv->type == TYPE_TWIN) {
+		/* Drop DTR */
+		outb((info->twin_serial_cfg &=
+		      (priv->channel ? ~TWIN_DTRB_ON : ~TWIN_DTRA_ON)),
+		     card_base + TWIN_SERIAL_CFG);
+	}
+
+	/* Reset channel, free DMA and IRQ */
+	write_scc(priv, R9, (priv->channel ? CHRB : CHRA) | MIE | NV);
+	if (priv->param.dma >= 0) {
+		if (priv->type == TYPE_TWIN)
+			outb(0, card_base + TWIN_DMA_CFG);
+		free_dma(priv->param.dma);
+	}
+	if (--info->irq_used == 0)
+		free_irq(dev->irq, info);
+
+	return 0;
+}
+
+
+static int scc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct scc_priv *priv = dev->priv;
+
+	switch (cmd) {
+	case SIOCGSCCPARAM:
+		if (copy_to_user
+		    (ifr->ifr_data, &priv->param,
+		     sizeof(struct scc_param)))
+			return -EFAULT;
+		return 0;
+	case SIOCSSCCPARAM:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (netif_running(dev))
+			return -EAGAIN;
+		if (copy_from_user
+		    (&priv->param, ifr->ifr_data,
+		     sizeof(struct scc_param)))
+			return -EFAULT;
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
+
+static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct scc_priv *priv = dev->priv;
+	unsigned long flags;
+	int i;
+
+	/* Temporarily stop the scheduler feeding us packets */
+	netif_stop_queue(dev);
+
+	/* Transfer data to DMA buffer */
+	i = priv->tx_head;
+	memcpy(priv->tx_buf[i], skb->data + 1, skb->len - 1);
+	priv->tx_len[i] = skb->len - 1;
+
+	/* Clear interrupts while we touch our circular buffers */
+
+	spin_lock_irqsave(&priv->ring_lock, flags);
+	/* Move the ring buffer's head */
+	priv->tx_head = (i + 1) % NUM_TX_BUF;
+	priv->tx_count++;
+
+	/* If we just filled up the last buffer, leave queue stopped.
+	   The higher layers must wait until we have a DMA buffer
+	   to accept the data. */
+	if (priv->tx_count < NUM_TX_BUF)
+		netif_wake_queue(dev);
+
+	/* Set new TX state */
+	if (priv->state == IDLE) {
+		/* Assert RTS, start timer */
+		priv->state = TX_HEAD;
+		priv->tx_start = jiffies;
+		write_scc(priv, R5, TxCRC_ENAB | RTS | TxENAB | Tx8);
+		write_scc(priv, R15, 0);
+		start_timer(priv, priv->param.txdelay, 0);
+	}
+
+	/* Turn interrupts back on and free buffer */
+	spin_unlock_irqrestore(&priv->ring_lock, flags);
+	dev_kfree_skb(skb);
+
+	return 0;
+}
+
+
+static struct net_device_stats *scc_get_stats(struct net_device *dev)
+{
+	struct scc_priv *priv = dev->priv;
+
+	return &priv->stats;
+}
+
+
+static int scc_set_mac_address(struct net_device *dev, void *sa)
+{
+	memcpy(dev->dev_addr, ((struct sockaddr *) sa)->sa_data,
+	       dev->addr_len);
+	return 0;
+}
+
+
+static inline void tx_on(struct scc_priv *priv)
+{
+	int i, n;
+	unsigned long flags;
+
+	if (priv->param.dma >= 0) {
+		n = (priv->chip == Z85230) ? 3 : 1;
+		/* Program DMA controller */
+		flags = claim_dma_lock();
+		set_dma_mode(priv->param.dma, DMA_MODE_WRITE);
+		set_dma_addr(priv->param.dma,
+			     (int) priv->tx_buf[priv->tx_tail] + n);
+		set_dma_count(priv->param.dma,
+			      priv->tx_len[priv->tx_tail] - n);
+		release_dma_lock(flags);
+		/* Enable TX underrun interrupt */
+		write_scc(priv, R15, TxUIE);
+		/* Configure DREQ */
+		if (priv->type == TYPE_TWIN)
+			outb((priv->param.dma ==
+			      1) ? TWIN_DMA_HDX_T1 : TWIN_DMA_HDX_T3,
+			     priv->card_base + TWIN_DMA_CFG);
+		else
+			write_scc(priv, R1,
+				  EXT_INT_ENAB | WT_FN_RDYFN |
+				  WT_RDY_ENAB);
+		/* Write first byte(s) */
+		spin_lock_irqsave(priv->register_lock, flags);
+		for (i = 0; i < n; i++)
+			write_scc_data(priv,
+				       priv->tx_buf[priv->tx_tail][i], 1);
+		enable_dma(priv->param.dma);
+		spin_unlock_irqrestore(priv->register_lock, flags);
+	} else {
+		write_scc(priv, R15, TxUIE);
+		write_scc(priv, R1,
+			  EXT_INT_ENAB | WT_FN_RDYFN | TxINT_ENAB);
+		tx_isr(priv);
+	}
+	/* Reset EOM latch if we do not have the AUTOEOM feature */
+	if (priv->chip == Z8530)
+		write_scc(priv, R0, RES_EOM_L);
+}
+
+
+static inline void rx_on(struct scc_priv *priv)
+{
+	unsigned long flags;
+
+	/* Clear RX FIFO */
+	while (read_scc(priv, R0) & Rx_CH_AV)
+		read_scc_data(priv);
+	priv->rx_over = 0;
+	if (priv->param.dma >= 0) {
+		/* Program DMA controller */
+		flags = claim_dma_lock();
+		set_dma_mode(priv->param.dma, DMA_MODE_READ);
+		set_dma_addr(priv->param.dma,
+			     (int) priv->rx_buf[priv->rx_head]);
+		set_dma_count(priv->param.dma, BUF_SIZE);
+		release_dma_lock(flags);
+		enable_dma(priv->param.dma);
+		/* Configure PackeTwin DMA */
+		if (priv->type == TYPE_TWIN) {
+			outb((priv->param.dma ==
+			      1) ? TWIN_DMA_HDX_R1 : TWIN_DMA_HDX_R3,
+			     priv->card_base + TWIN_DMA_CFG);
+		}
+		/* Sp. cond. intr. only, ext int enable, RX DMA enable */
+		write_scc(priv, R1, EXT_INT_ENAB | INT_ERR_Rx |
+			  WT_RDY_RT | WT_FN_RDYFN | WT_RDY_ENAB);
+	} else {
+		/* Reset current frame */
+		priv->rx_ptr = 0;
+		/* Intr. on all Rx characters and Sp. cond., ext int enable */
+		write_scc(priv, R1, EXT_INT_ENAB | INT_ALL_Rx | WT_RDY_RT |
+			  WT_FN_RDYFN);
+	}
+	write_scc(priv, R0, ERR_RES);
+	write_scc(priv, R3, RxENABLE | Rx8 | RxCRC_ENAB);
+}
+
+
+static inline void rx_off(struct scc_priv *priv)
+{
+	/* Disable receiver */
+	write_scc(priv, R3, Rx8);
+	/* Disable DREQ / RX interrupt */
+	if (priv->param.dma >= 0 && priv->type == TYPE_TWIN)
+		outb(0, priv->card_base + TWIN_DMA_CFG);
+	else
+		write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN);
+	/* Disable DMA */
+	if (priv->param.dma >= 0)
+		disable_dma(priv->param.dma);
+}
+
+
+static void start_timer(struct scc_priv *priv, int t, int r15)
+{
+	unsigned long flags;
+
+	outb(priv->tmr_mode, priv->tmr_ctrl);
+	if (t == 0) {
+		tm_isr(priv);
+	} else if (t > 0) {
+		save_flags(flags);
+		cli();
+		outb(t & 0xFF, priv->tmr_cnt);
+		outb((t >> 8) & 0xFF, priv->tmr_cnt);
+		if (priv->type != TYPE_TWIN) {
+			write_scc(priv, R15, r15 | CTSIE);
+			priv->rr0 |= CTS;
+		}
+		restore_flags(flags);
+	}
+}
+
+
+static inline unsigned char random(void)
+{
+	/* See "Numerical Recipes in C", second edition, p. 284 */
+	rand = rand * 1664525L + 1013904223L;
+	return (unsigned char) (rand >> 24);
+}
+
+static inline void z8530_isr(struct scc_info *info)
+{
+	int is, i = 100;
+
+	while ((is = read_scc(&info->priv[0], R3)) && i--) {
+		if (is & CHARxIP) {
+			rx_isr(&info->priv[0]);
+		} else if (is & CHATxIP) {
+			tx_isr(&info->priv[0]);
+		} else if (is & CHAEXT) {
+			es_isr(&info->priv[0]);
+		} else if (is & CHBRxIP) {
+			rx_isr(&info->priv[1]);
+		} else if (is & CHBTxIP) {
+			tx_isr(&info->priv[1]);
+		} else {
+			es_isr(&info->priv[1]);
+		}
+		write_scc(&info->priv[0], R0, RES_H_IUS);
+		i++;
+	}
+	if (i < 0) {
+		printk(KERN_ERR "dmascc: stuck in ISR with RR3=0x%02x.\n",
+		       is);
+	}
+	/* Ok, no interrupts pending from this 8530. The INT line should
+	   be inactive now. */
+}
+
+
+static irqreturn_t scc_isr(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct scc_info *info = dev_id;
+
+	spin_lock(info->priv[0].register_lock);
+	/* At this point interrupts are enabled, and the interrupt under service
+	   is already acknowledged, but masked off.
+
+	   Interrupt processing: We loop until we know that the IRQ line is
+	   low. If another positive edge occurs afterwards during the ISR,
+	   another interrupt will be triggered by the interrupt controller
+	   as soon as the IRQ level is enabled again (see asm/irq.h).
+
+	   Bottom-half handlers will be processed after scc_isr(). This is
+	   important, since we only have small ringbuffers and want new data
+	   to be fetched/delivered immediately. */
+
+	if (info->priv[0].type == TYPE_TWIN) {
+		int is, card_base = info->priv[0].card_base;
+		while ((is = ~inb(card_base + TWIN_INT_REG)) &
+		       TWIN_INT_MSK) {
+			if (is & TWIN_SCC_MSK) {
+				z8530_isr(info);
+			} else if (is & TWIN_TMR1_MSK) {
+				inb(card_base + TWIN_CLR_TMR1);
+				tm_isr(&info->priv[0]);
+			} else {
+				inb(card_base + TWIN_CLR_TMR2);
+				tm_isr(&info->priv[1]);
+			}
+		}
+	} else
+		z8530_isr(info);
+	spin_unlock(info->priv[0].register_lock);
+	return IRQ_HANDLED;
+}
+
+
+static void rx_isr(struct scc_priv *priv)
+{
+	if (priv->param.dma >= 0) {
+		/* Check special condition and perform error reset. See 2.4.7.5. */
+		special_condition(priv, read_scc(priv, R1));
+		write_scc(priv, R0, ERR_RES);
+	} else {
+		/* Check special condition for each character. Error reset not necessary.
+		   Same algorithm for SCC and ESCC. See 2.4.7.1 and 2.4.7.4. */
+		int rc;
+		while (read_scc(priv, R0) & Rx_CH_AV) {
+			rc = read_scc(priv, R1);
+			if (priv->rx_ptr < BUF_SIZE)
+				priv->rx_buf[priv->rx_head][priv->
+							    rx_ptr++] =
+				    read_scc_data(priv);
+			else {
+				priv->rx_over = 2;
+				read_scc_data(priv);
+			}
+			special_condition(priv, rc);
+		}
+	}
+}
+
+
+static void special_condition(struct scc_priv *priv, int rc)
+{
+	int cb;
+	unsigned long flags;
+
+	/* See Figure 2-15. Only overrun and EOF need to be checked. */
+
+	if (rc & Rx_OVR) {
+		/* Receiver overrun */
+		priv->rx_over = 1;
+		if (priv->param.dma < 0)
+			write_scc(priv, R0, ERR_RES);
+	} else if (rc & END_FR) {
+		/* End of frame. Get byte count */
+		if (priv->param.dma >= 0) {
+			flags = claim_dma_lock();
+			cb = BUF_SIZE - get_dma_residue(priv->param.dma) -
+			    2;
+			release_dma_lock(flags);
+		} else {
+			cb = priv->rx_ptr - 2;
+		}
+		if (priv->rx_over) {
+			/* We had an overrun */
+			priv->stats.rx_errors++;
+			if (priv->rx_over == 2)
+				priv->stats.rx_length_errors++;
+			else
+				priv->stats.rx_fifo_errors++;
+			priv->rx_over = 0;
+		} else if (rc & CRC_ERR) {
+			/* Count invalid CRC only if packet length >= minimum */
+			if (cb >= 15) {
+				priv->stats.rx_errors++;
+				priv->stats.rx_crc_errors++;
+			}
+		} else {
+			if (cb >= 15) {
+				if (priv->rx_count < NUM_RX_BUF - 1) {
+					/* Put good frame in FIFO */
+					priv->rx_len[priv->rx_head] = cb;
+					priv->rx_head =
+					    (priv->rx_head +
+					     1) % NUM_RX_BUF;
+					priv->rx_count++;
+					schedule_work(&priv->rx_work);
+				} else {
+					priv->stats.rx_errors++;
+					priv->stats.rx_over_errors++;
+				}
+			}
+		}
+		/* Get ready for new frame */
+		if (priv->param.dma >= 0) {
+			flags = claim_dma_lock();
+			set_dma_addr(priv->param.dma,
+				     (int) priv->rx_buf[priv->rx_head]);
+			set_dma_count(priv->param.dma, BUF_SIZE);
+			release_dma_lock(flags);
+		} else {
+			priv->rx_ptr = 0;
+		}
+	}
+}
+
+
+static void rx_bh(void *arg)
+{
+	struct scc_priv *priv = arg;
+	int i = priv->rx_tail;
+	int cb;
+	unsigned long flags;
+	struct sk_buff *skb;
+	unsigned char *data;
+
+	spin_lock_irqsave(&priv->ring_lock, flags);
+	while (priv->rx_count) {
+		spin_unlock_irqrestore(&priv->ring_lock, flags);
+		cb = priv->rx_len[i];
+		/* Allocate buffer */
+		skb = dev_alloc_skb(cb + 1);
+		if (skb == NULL) {
+			/* Drop packet */
+			priv->stats.rx_dropped++;
+		} else {
+			/* Fill buffer */
+			data = skb_put(skb, cb + 1);
+			data[0] = 0;
+			memcpy(&data[1], priv->rx_buf[i], cb);
+			skb->dev = priv->dev;
+			skb->protocol = ntohs(ETH_P_AX25);
+			skb->mac.raw = skb->data;
+			netif_rx(skb);
+			priv->dev->last_rx = jiffies;
+			priv->stats.rx_packets++;
+			priv->stats.rx_bytes += cb;
+		}
+		spin_lock_irqsave(&priv->ring_lock, flags);
+		/* Move tail */
+		priv->rx_tail = i = (i + 1) % NUM_RX_BUF;
+		priv->rx_count--;
+	}
+	spin_unlock_irqrestore(&priv->ring_lock, flags);
+}
+
+
+static void tx_isr(struct scc_priv *priv)
+{
+	int i = priv->tx_tail, p = priv->tx_ptr;
+
+	/* Suspend TX interrupts if we don't want to send anything.
+	   See Figure 2-22. */
+	if (p == priv->tx_len[i]) {
+		write_scc(priv, R0, RES_Tx_P);
+		return;
+	}
+
+	/* Write characters */
+	while ((read_scc(priv, R0) & Tx_BUF_EMP) && p < priv->tx_len[i]) {
+		write_scc_data(priv, priv->tx_buf[i][p++], 0);
+	}
+
+	/* Reset EOM latch of Z8530 */
+	if (!priv->tx_ptr && p && priv->chip == Z8530)
+		write_scc(priv, R0, RES_EOM_L);
+
+	priv->tx_ptr = p;
+}
+
+
+static void es_isr(struct scc_priv *priv)
+{
+	int i, rr0, drr0, res;
+	unsigned long flags;
+
+	/* Read status, reset interrupt bit (open latches) */
+	rr0 = read_scc(priv, R0);
+	write_scc(priv, R0, RES_EXT_INT);
+	drr0 = priv->rr0 ^ rr0;
+	priv->rr0 = rr0;
+
+	/* Transmit underrun (2.4.9.6). We can't check the TxEOM flag, since
+	   it might have already been cleared again by AUTOEOM. */
+	if (priv->state == TX_DATA) {
+		/* Get remaining bytes */
+		i = priv->tx_tail;
+		if (priv->param.dma >= 0) {
+			disable_dma(priv->param.dma);
+			flags = claim_dma_lock();
+			res = get_dma_residue(priv->param.dma);
+			release_dma_lock(flags);
+		} else {
+			res = priv->tx_len[i] - priv->tx_ptr;
+			priv->tx_ptr = 0;
+		}
+		/* Disable DREQ / TX interrupt */
+		if (priv->param.dma >= 0 && priv->type == TYPE_TWIN)
+			outb(0, priv->card_base + TWIN_DMA_CFG);
+		else
+			write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN);
+		if (res) {
+			/* Update packet statistics */
+			priv->stats.tx_errors++;
+			priv->stats.tx_fifo_errors++;
+			/* Other underrun interrupts may already be waiting */
+			write_scc(priv, R0, RES_EXT_INT);
+			write_scc(priv, R0, RES_EXT_INT);
+		} else {
+			/* Update packet statistics */
+			priv->stats.tx_packets++;
+			priv->stats.tx_bytes += priv->tx_len[i];
+			/* Remove frame from FIFO */
+			priv->tx_tail = (i + 1) % NUM_TX_BUF;
+			priv->tx_count--;
+			/* Inform upper layers */
+			netif_wake_queue(priv->dev);
+		}
+		/* Switch state */
+		write_scc(priv, R15, 0);
+		if (priv->tx_count &&
+		    (jiffies - priv->tx_start) < priv->param.txtimeout) {
+			priv->state = TX_PAUSE;
+			start_timer(priv, priv->param.txpause, 0);
+		} else {
+			priv->state = TX_TAIL;
+			start_timer(priv, priv->param.txtail, 0);
+		}
+	}
+
+	/* DCD transition */
+	if (drr0 & DCD) {
+		if (rr0 & DCD) {
+			switch (priv->state) {
+			case IDLE:
+			case WAIT:
+				priv->state = DCD_ON;
+				write_scc(priv, R15, 0);
+				start_timer(priv, priv->param.dcdon, 0);
+			}
+		} else {
+			switch (priv->state) {
+			case RX_ON:
+				rx_off(priv);
+				priv->state = DCD_OFF;
+				write_scc(priv, R15, 0);
+				start_timer(priv, priv->param.dcdoff, 0);
+			}
+		}
+	}
+
+	/* CTS transition */
+	if ((drr0 & CTS) && (~rr0 & CTS) && priv->type != TYPE_TWIN)
+		tm_isr(priv);
+
+}
+
+
+static void tm_isr(struct scc_priv *priv)
+{
+	switch (priv->state) {
+	case TX_HEAD:
+	case TX_PAUSE:
+		tx_on(priv);
+		priv->state = TX_DATA;
+		break;
+	case TX_TAIL:
+		write_scc(priv, R5, TxCRC_ENAB | Tx8);
+		priv->state = RTS_OFF;
+		if (priv->type != TYPE_TWIN)
+			write_scc(priv, R15, 0);
+		start_timer(priv, priv->param.rtsoff, 0);
+		break;
+	case RTS_OFF:
+		write_scc(priv, R15, DCDIE);
+		priv->rr0 = read_scc(priv, R0);
+		if (priv->rr0 & DCD) {
+			priv->stats.collisions++;
+			rx_on(priv);
+			priv->state = RX_ON;
+		} else {
+			priv->state = WAIT;
+			start_timer(priv, priv->param.waittime, DCDIE);
+		}
+		break;
+	case WAIT:
+		if (priv->tx_count) {
+			priv->state = TX_HEAD;
+			priv->tx_start = jiffies;
+			write_scc(priv, R5,
+				  TxCRC_ENAB | RTS | TxENAB | Tx8);
+			write_scc(priv, R15, 0);
+			start_timer(priv, priv->param.txdelay, 0);
+		} else {
+			priv->state = IDLE;
+			if (priv->type != TYPE_TWIN)
+				write_scc(priv, R15, DCDIE);
+		}
+		break;
+	case DCD_ON:
+	case DCD_OFF:
+		write_scc(priv, R15, DCDIE);
+		priv->rr0 = read_scc(priv, R0);
+		if (priv->rr0 & DCD) {
+			rx_on(priv);
+			priv->state = RX_ON;
+		} else {
+			priv->state = WAIT;
+			start_timer(priv,
+				    random() / priv->param.persist *
+				    priv->param.slottime, DCDIE);
+		}
+		break;
 	}
-      }
-    }
-    /* Get ready for new frame */
-    if (priv->param.dma >= 0) {
-      flags = claim_dma_lock();
-      set_dma_addr(priv->param.dma, (int) priv->rx_buf[priv->rx_head]);
-      set_dma_count(priv->param.dma, BUF_SIZE);
-      release_dma_lock(flags);
-    } else {
-      priv->rx_ptr = 0;
-    }
-  }
-}
-
-
-static void rx_bh(void *arg) {
-  struct scc_priv *priv = arg;
-  int i = priv->rx_tail;
-  int cb;
-  unsigned long flags;
-  struct sk_buff *skb;
-  unsigned char *data;
-
-  spin_lock_irqsave(&priv->ring_lock, flags);
-  while (priv->rx_count) {
-    spin_unlock_irqrestore(&priv->ring_lock, flags);
-    cb = priv->rx_len[i];
-    /* Allocate buffer */
-    skb = dev_alloc_skb(cb+1);
-    if (skb == NULL) {
-      /* Drop packet */
-      priv->stats.rx_dropped++;
-    } else {
-      /* Fill buffer */
-      data = skb_put(skb, cb+1);
-      data[0] = 0;
-      memcpy(&data[1], priv->rx_buf[i], cb);
-      skb->dev = priv->dev;
-      skb->protocol = ntohs(ETH_P_AX25);
-      skb->mac.raw = skb->data;
-      netif_rx(skb);
-      priv->dev->last_rx = jiffies;
-      priv->stats.rx_packets++;
-      priv->stats.rx_bytes += cb;
-    }
-    spin_lock_irqsave(&priv->ring_lock, flags);
-    /* Move tail */
-    priv->rx_tail = i = (i + 1) % NUM_RX_BUF;
-    priv->rx_count--;
-  }
-  spin_unlock_irqrestore(&priv->ring_lock, flags);
-}
-
-
-static void tx_isr(struct scc_priv *priv) {
-  int i = priv->tx_tail, p = priv->tx_ptr;
-
-  /* Suspend TX interrupts if we don't want to send anything.
-     See Figure 2-22. */
-  if (p ==  priv->tx_len[i]) {
-    write_scc(priv, R0, RES_Tx_P);
-    return;
-  }
-
-  /* Write characters */
-  while ((read_scc(priv, R0) & Tx_BUF_EMP) && p < priv->tx_len[i]) {
-    write_scc_data(priv, priv->tx_buf[i][p++], 0);
-  }
-
-  /* Reset EOM latch of Z8530 */
-  if (!priv->tx_ptr && p && priv->chip == Z8530)
-    write_scc(priv, R0, RES_EOM_L);
-
-  priv->tx_ptr = p;
-}
-
-
-static void es_isr(struct scc_priv *priv) {
-  int i, rr0, drr0, res;
-  unsigned long flags;
-
-  /* Read status, reset interrupt bit (open latches) */
-  rr0 = read_scc(priv, R0);
-  write_scc(priv, R0, RES_EXT_INT);
-  drr0 = priv->rr0 ^ rr0;
-  priv->rr0 = rr0;
-
-  /* Transmit underrun (2.4.9.6). We can't check the TxEOM flag, since
-     it might have already been cleared again by AUTOEOM. */
-  if (priv->state == TX_DATA) {
-    /* Get remaining bytes */
-    i = priv->tx_tail;
-    if (priv->param.dma >= 0) {
-      disable_dma(priv->param.dma);
-      flags = claim_dma_lock();
-      res = get_dma_residue(priv->param.dma);
-      release_dma_lock(flags);
-    } else {
-      res = priv->tx_len[i] - priv->tx_ptr;
-      priv->tx_ptr = 0;
-    }
-    /* Disable DREQ / TX interrupt */
-    if (priv->param.dma >= 0 && priv->type == TYPE_TWIN)
-      outb(0, priv->card_base + TWIN_DMA_CFG);
-    else
-      write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN);
-    if (res) {
-      /* Update packet statistics */
-      priv->stats.tx_errors++;
-      priv->stats.tx_fifo_errors++;
-      /* Other underrun interrupts may already be waiting */
-      write_scc(priv, R0, RES_EXT_INT);
-      write_scc(priv, R0, RES_EXT_INT);
-    } else {
-      /* Update packet statistics */
-      priv->stats.tx_packets++;
-      priv->stats.tx_bytes += priv->tx_len[i];
-      /* Remove frame from FIFO */
-      priv->tx_tail = (i + 1) % NUM_TX_BUF;
-      priv->tx_count--;
-      /* Inform upper layers */
-      netif_wake_queue(priv->dev);
-    }
-    /* Switch state */
-    write_scc(priv, R15, 0);
-    if (priv->tx_count &&
-	(jiffies - priv->tx_start) < priv->param.txtimeout) {
-      priv->state = TX_PAUSE;
-      start_timer(priv, priv->param.txpause, 0);
-    } else {
-      priv->state = TX_TAIL;
-      start_timer(priv, priv->param.txtail, 0);
-    }
-  }
-
-  /* DCD transition */
-  if (drr0 & DCD) {
-    if (rr0 & DCD) {
-      switch (priv->state) {
-      case IDLE:
-      case WAIT:
-	priv->state = DCD_ON;
-	write_scc(priv, R15, 0);
-	start_timer(priv, priv->param.dcdon, 0);
-      }
-    } else {
-      switch (priv->state) {
-      case RX_ON:
-	rx_off(priv);
-	priv->state = DCD_OFF;
-	write_scc(priv, R15, 0);
-	start_timer(priv, priv->param.dcdoff, 0);
-      }
-    }
-  }
-
-  /* CTS transition */
-  if ((drr0 & CTS) && (~rr0 & CTS) && priv->type != TYPE_TWIN)
-    tm_isr(priv);
-
-}
-
-
-static void tm_isr(struct scc_priv *priv) {
-  switch (priv->state) {
-  case TX_HEAD:
-  case TX_PAUSE:
-    tx_on(priv);
-    priv->state = TX_DATA;
-    break;
-  case TX_TAIL:
-    write_scc(priv, R5, TxCRC_ENAB | Tx8);
-    priv->state = RTS_OFF;
-    if (priv->type != TYPE_TWIN) write_scc(priv, R15, 0);
-    start_timer(priv, priv->param.rtsoff, 0);
-    break;
-  case RTS_OFF:
-    write_scc(priv, R15, DCDIE);
-    priv->rr0 = read_scc(priv, R0);
-    if (priv->rr0 & DCD) {
-      priv->stats.collisions++;
-      rx_on(priv);
-      priv->state = RX_ON;
-    } else {
-      priv->state = WAIT;
-      start_timer(priv, priv->param.waittime, DCDIE);
-    }
-    break;
-  case WAIT:
-    if (priv->tx_count) {
-      priv->state = TX_HEAD;
-      priv->tx_start = jiffies;
-      write_scc(priv, R5, TxCRC_ENAB | RTS | TxENAB | Tx8);
-      write_scc(priv, R15, 0);
-      start_timer(priv, priv->param.txdelay, 0);
-    } else {
-      priv->state = IDLE;
-      if (priv->type != TYPE_TWIN) write_scc(priv, R15, DCDIE);
-    }
-    break;
-  case DCD_ON:
-  case DCD_OFF:
-    write_scc(priv, R15, DCDIE);
-    priv->rr0 = read_scc(priv, R0);
-    if (priv->rr0 & DCD) {
-      rx_on(priv);
-      priv->state = RX_ON;
-    } else {
-      priv->state = WAIT;
-      start_timer(priv,
-		  random()/priv->param.persist*priv->param.slottime,
-		  DCDIE);
-    }
-    break;
-  }
 }
diff -Nru a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
--- a/drivers/net/hamradio/hdlcdrv.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/hdlcdrv.c	2005-03-08 14:29:45 -05:00
@@ -427,27 +427,10 @@
  * ===================== network driver interface =========================
  */
 
-static inline int hdlcdrv_paranoia_check(struct net_device *dev,
-					const char *routine)
-{
-	if (!dev || !dev->priv || 
-	    ((struct hdlcdrv_state *)dev->priv)->magic != HDLCDRV_MAGIC) {
-		printk(KERN_ERR "hdlcdrv: bad magic number for hdlcdrv_state "
-		       "struct in routine %s\n", routine);
-		return 1;
-	}
-	return 0;
-}
-
-/* --------------------------------------------------------------------- */
-
 static int hdlcdrv_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct hdlcdrv_state *sm;
+	struct hdlcdrv_state *sm = netdev_priv(dev);
 
-	if (hdlcdrv_paranoia_check(dev, "hdlcdrv_send_packet"))
-		return 0;
-	sm = (struct hdlcdrv_state *)dev->priv;
 	if (skb->data[0] != 0) {
 		do_kiss_params(sm, skb->data, skb->len);
 		dev_kfree_skb(skb);
@@ -475,11 +458,8 @@
 
 static struct net_device_stats *hdlcdrv_get_stats(struct net_device *dev)
 {
-	struct hdlcdrv_state *sm;
+	struct hdlcdrv_state *sm = netdev_priv(dev);
 
-	if (hdlcdrv_paranoia_check(dev, "hdlcdrv_get_stats"))
-		return NULL;
-	sm = (struct hdlcdrv_state *)dev->priv;
 	/* 
 	 * Get the current statistics.  This may be called with the
 	 * card open or closed. 
@@ -499,13 +479,9 @@
 
 static int hdlcdrv_open(struct net_device *dev)
 {
-	struct hdlcdrv_state *s;
+	struct hdlcdrv_state *s = netdev_priv(dev);
 	int i;
 
-	if (hdlcdrv_paranoia_check(dev, "hdlcdrv_open"))
-		return -EINVAL;
-	s = (struct hdlcdrv_state *)dev->priv;
-
 	if (!s->ops || !s->ops->open)
 		return -ENODEV;
 
@@ -540,13 +516,9 @@
 
 static int hdlcdrv_close(struct net_device *dev)
 {
-	struct hdlcdrv_state *s;
+	struct hdlcdrv_state *s = netdev_priv(dev);
 	int i = 0;
 
-	if (hdlcdrv_paranoia_check(dev, "hdlcdrv_close"))
-		return -EINVAL;
-	s = (struct hdlcdrv_state *)dev->priv;
-
 	netif_stop_queue(dev);
 
 	if (s->ops && s->ops->close)
@@ -562,12 +534,8 @@
 
 static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct hdlcdrv_state *s;
+	struct hdlcdrv_state *s = netdev_priv(dev);
 	struct hdlcdrv_ioctl bi;
-		
-	if (hdlcdrv_paranoia_check(dev, "hdlcdrv_ioctl"))
-		return -EINVAL;
-	s = (struct hdlcdrv_state *)dev->priv;
 
 	if (cmd != SIOCDEVPRIVATE) {
 		if (s->ops && s->ops->ioctl)
@@ -698,7 +666,7 @@
 	static const struct hdlcdrv_channel_params dflt_ch_params = { 
 		20, 2, 10, 40, 0 
 	};
-	struct hdlcdrv_state *s = dev->priv;
+	struct hdlcdrv_state *s = netdev_priv(dev);
 
 	/*
 	 * initialize the hdlcdrv_state struct
@@ -782,7 +750,7 @@
 	/*
 	 * initialize part of the hdlcdrv_state struct
 	 */
-	s = dev->priv;
+	s = netdev_priv(dev);
 	s->magic = HDLCDRV_MAGIC;
 	s->ops = ops;
 	dev->base_addr = baseaddr;
@@ -803,7 +771,7 @@
 
 void hdlcdrv_unregister(struct net_device *dev) 
 {
-	struct hdlcdrv_state *s = dev->priv;
+	struct hdlcdrv_state *s = netdev_priv(dev);
 
 	BUG_ON(s->magic != HDLCDRV_MAGIC);
 
diff -Nru a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
--- a/drivers/net/hamradio/mkiss.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/mkiss.c	2005-03-08 14:29:45 -05:00
@@ -419,7 +419,7 @@
 /* Encapsulate an AX.25 packet and kick it into a TTY queue. */
 static int ax_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ax_disp *ax = (struct ax_disp *) dev->priv;
+	struct ax_disp *ax = netdev_priv(dev);
 
 	if (!netif_running(dev))  {
 		printk(KERN_ERR "mkiss: %s: xmit call when iface is down\n", dev->name);
@@ -483,7 +483,7 @@
 /* Open the low-level part of the AX25 channel. Easy! */
 static int ax_open(struct net_device *dev)
 {
-	struct ax_disp *ax = (struct ax_disp *) dev->priv;
+	struct ax_disp *ax = netdev_priv(dev);
 	unsigned long len;
 
 	if (ax->tty == NULL)
@@ -534,7 +534,7 @@
 /* Close the low-level part of the AX25 channel. Easy! */
 static int ax_close(struct net_device *dev)
 {
-	struct ax_disp *ax = (struct ax_disp *) dev->priv;
+	struct ax_disp *ax = netdev_priv(dev);
 
 	if (ax->tty == NULL)
 		return -EBUSY;
@@ -634,7 +634,7 @@
 static struct net_device_stats *ax_get_stats(struct net_device *dev)
 {
 	static struct net_device_stats stats;
-	struct ax_disp *ax = (struct ax_disp *) dev->priv;
+	struct ax_disp *ax = netdev_priv(dev);
 
 	memset(&stats, 0, sizeof(struct net_device_stats));
 
@@ -827,7 +827,7 @@
 
 static int ax_open_dev(struct net_device *dev)
 {
-	struct ax_disp *ax = (struct ax_disp *) dev->priv;
+	struct ax_disp *ax = netdev_priv(dev);
 
 	if (ax->tty == NULL)
 		return -ENODEV;
@@ -839,7 +839,7 @@
 /* Initialize the driver.  Called by network startup. */
 static int ax25_init(struct net_device *dev)
 {
-	struct ax_disp *ax = (struct ax_disp *) dev->priv;
+	struct ax_disp *ax = netdev_priv(dev);
 
 	static char ax25_bcast[AX25_ADDR_LEN] =
 		{'Q'<<1,'S'<<1,'T'<<1,' '<<1,' '<<1,' '<<1,'0'<<1};
diff -Nru a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
--- a/drivers/net/hamradio/yam.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/hamradio/yam.c	2005-03-08 14:29:45 -05:00
@@ -442,7 +442,7 @@
 
 static void yam_set_uart(struct net_device *dev)
 {
-	struct yam_port *yp = (struct yam_port *) dev->priv;
+	struct yam_port *yp = netdev_priv(dev);
 	int divisor = 115200 / yp->baudrate;
 
 	outb(0, IER(dev->base_addr));
@@ -565,7 +565,7 @@
 
 static int yam_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct yam_port *yp = dev->priv;
+	struct yam_port *yp = netdev_priv(dev);
 
 	skb_queue_tail(&yp->send_queue, skb);
 	dev->trans_start = jiffies;
@@ -592,12 +592,11 @@
 
 static void yam_arbitrate(struct net_device *dev)
 {
-	struct yam_port *yp = dev->priv;
+	struct yam_port *yp = netdev_priv(dev);
 
-	if (!yp || yp->magic != YAM_MAGIC
-		|| yp->tx_state != TX_OFF || skb_queue_empty(&yp->send_queue)) {
+	if (yp->magic != YAM_MAGIC || yp->tx_state != TX_OFF ||
+	    skb_queue_empty(&yp->send_queue))
 		return;
-	}
 	/* tx_state is TX_OFF and there is data to send */
 
 	if (yp->dupmode) {
@@ -725,7 +724,7 @@
 
 	for (i = 0; i < NR_PORTS; i++) {
 		dev = yam_devs[i];
-		yp = dev->priv;
+		yp = netdev_priv(dev);
 
 		if (!netif_running(dev))
 			continue;
@@ -784,8 +783,8 @@
 
 static int yam_seq_show(struct seq_file *seq, void *v)
 {
-	const struct net_device *dev = v;
-	const struct yam_port *yp = dev->priv;
+	struct net_device *dev = v;
+	const struct yam_port *yp = netdev_priv(dev);
 
 	seq_printf(seq, "Device %s\n", dev->name);
 	seq_printf(seq, "  Up       %d\n", netif_running(dev));
@@ -838,10 +837,10 @@
 {
 	struct yam_port *yp;
 
-	if (!dev || !dev->priv)
+	if (!dev)
 		return NULL;
 
-	yp = (struct yam_port *) dev->priv;
+	yp = netdev_priv(dev);
 	if (yp->magic != YAM_MAGIC)
 		return NULL;
 
@@ -856,14 +855,14 @@
 
 static int yam_open(struct net_device *dev)
 {
-	struct yam_port *yp = (struct yam_port *) dev->priv;
+	struct yam_port *yp = netdev_priv(dev);
 	enum uart u;
 	int i;
 	int ret=0;
 
 	printk(KERN_INFO "Trying %s at iobase 0x%lx irq %u\n", dev->name, dev->base_addr, dev->irq);
 
-	if (!dev || !yp || !yp->bitrate)
+	if (!dev || !yp->bitrate)
 		return -ENXIO;
 	if (!dev->base_addr || dev->base_addr > 0x1000 - YAM_EXTENT ||
 		dev->irq < 2 || dev->irq > 15) {
@@ -900,7 +899,7 @@
 	/* Reset overruns for all ports - FPGA programming makes overruns */
 	for (i = 0; i < NR_PORTS; i++) {
 		struct net_device *dev = yam_devs[i];
-		struct yam_port *yp = dev->priv;
+		struct yam_port *yp = netdev_priv(dev);
 		inb(LSR(dev->base_addr));
 		yp->stats.rx_fifo_errors = 0;
 	}
@@ -919,10 +918,11 @@
 static int yam_close(struct net_device *dev)
 {
 	struct sk_buff *skb;
-	struct yam_port *yp = (struct yam_port *) dev->priv;
+	struct yam_port *yp = netdev_priv(dev);
 
-	if (!dev || !yp)
+	if (!dev)
 		return -EINVAL;
+
 	/*
 	 * disable interrupts
 	 */
@@ -944,7 +944,7 @@
 
 static int yam_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct yam_port *yp = (struct yam_port *) dev->priv;
+	struct yam_port *yp = netdev_priv(dev);
 	struct yamdrv_ioctl_cfg yi;
 	struct yamdrv_ioctl_mcs *ym;
 	int ioctl_cmd;
@@ -952,7 +952,7 @@
 	if (copy_from_user(&ioctl_cmd, ifr->ifr_data, sizeof(int)))
 		 return -EFAULT;
 
-	if (yp == NULL || yp->magic != YAM_MAGIC)
+	if (yp->magic != YAM_MAGIC)
 		return -EINVAL;
 
 	if (!capable(CAP_NET_ADMIN))
@@ -1091,7 +1091,7 @@
 
 static void yam_setup(struct net_device *dev)
 {
-	struct yam_port *yp = dev->priv;
+	struct yam_port *yp = netdev_priv(dev);
 
 	yp->magic = YAM_MAGIC;
 	yp->bitrate = DEFAULT_BITRATE;
diff -Nru a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/mv643xx_eth.c	2005-03-08 14:29:45 -05:00
@@ -1,5 +1,5 @@
 /*
- * drivers/net/mv64340_eth.c - Driver for MV64340X ethernet ports
+ * drivers/net/mv643xx_eth.c - Driver for MV643XX ethernet ports
  * Copyright (C) 2002 Matthew Dharm <mdharm@momenco.com>
  *
  * Based on the 64360 driver from:
@@ -10,6 +10,12 @@
  *
  * Copyright (C) 2003 Ralf Baechle <ralf@linux-mips.org>
  *
+ * Copyright (C) 2004-2005 MontaVista Software, Inc.
+ *			   Dale Farnsworth <dale@farnsworth.org>
+ *
+ * Copyright (C) 2004 Steven J. Hill <sjhill1@rockwellcollins.com>
+ *				     <sjhill@realitydiluted.com>
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -24,80 +30,100 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
-#include <linux/config.h>
-#include <linux/version.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/config.h>
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/fcntl.h>
-#include <linux/ioport.h>
-#include <linux/interrupt.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/ip.h>
 #include <linux/init.h>
-#include <linux/in.h>
-#include <linux/pci.h>
-#include <linux/workqueue.h>
-#include <asm/smp.h>
-#include <linux/skbuff.h>
+#include <linux/dma-mapping.h>
 #include <linux/tcp.h>
-#include <linux/netdevice.h>
+#include <linux/udp.h>
 #include <linux/etherdevice.h>
-#include <net/ip.h>
 
 #include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/ethtool.h>
 #include <asm/io.h>
 #include <asm/types.h>
 #include <asm/pgtable.h>
 #include <asm/system.h>
+#include <asm/delay.h>
 #include "mv643xx_eth.h"
 
 /*
- * The first part is the high level driver of the gigE ethernet ports. 
+ * The first part is the high level driver of the gigE ethernet ports.
  */
 
-/* Definition for configuring driver */
-#undef MV64340_RX_QUEUE_FILL_ON_TASK
-
 /* Constants */
-#define EXTRA_BYTES 32
-#define WRAP       ETH_HLEN + 2 + 4 + 16
-#define BUFFER_MTU dev->mtu + WRAP
+#define VLAN_HLEN		4
+#define FCS_LEN			4
+#define WRAP			NET_IP_ALIGN + ETH_HLEN + VLAN_HLEN + FCS_LEN
+#define RX_SKB_SIZE		((dev->mtu + WRAP + 7) & ~0x7)
+
 #define INT_CAUSE_UNMASK_ALL		0x0007ffff
 #define INT_CAUSE_UNMASK_ALL_EXT	0x0011ffff
-#ifdef MV64340_RX_FILL_ON_TASK
+#ifdef MV643XX_RX_QUEUE_FILL_ON_TASK
 #define INT_CAUSE_MASK_ALL		0x00000000
 #define INT_CAUSE_CHECK_BITS		INT_CAUSE_UNMASK_ALL
 #define INT_CAUSE_CHECK_BITS_EXT	INT_CAUSE_UNMASK_ALL_EXT
 #endif
 
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+#define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
+#else
+#define MAX_DESCS_PER_SKB	1
+#endif
+
+#define PHY_WAIT_ITERATIONS	1000	/* 1000 iterations * 10uS = 10mS max */
+#define PHY_WAIT_MICRO_SECONDS	10
+
 /* Static function declarations */
-static int mv64340_eth_real_open(struct net_device *);
-static int mv64340_eth_real_stop(struct net_device *);
-static int mv64340_eth_change_mtu(struct net_device *, int);
-static struct net_device_stats *mv64340_eth_get_stats(struct net_device *);
+static int eth_port_link_is_up(unsigned int eth_port_num);
+static void eth_port_uc_addr_get(struct net_device *dev,
+						unsigned char *MacAddr);
+static int mv643xx_eth_real_open(struct net_device *);
+static int mv643xx_eth_real_stop(struct net_device *);
+static int mv643xx_eth_change_mtu(struct net_device *, int);
+static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *);
 static void eth_port_init_mac_tables(unsigned int eth_port_num);
-#ifdef MV64340_NAPI
-static int mv64340_poll(struct net_device *dev, int *budget);
+#ifdef MV643XX_NAPI
+static int mv643xx_poll(struct net_device *dev, int *budget);
 #endif
+static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
+static int ethernet_phy_detect(unsigned int eth_port_num);
+static struct ethtool_ops mv643xx_ethtool_ops;
+
+static char mv643xx_driver_name[] = "mv643xx_eth";
+static char mv643xx_driver_version[] = "1.0";
+
+static void __iomem *mv643xx_eth_shared_base;
+
+/* used to protect MV643XX_ETH_SMI_REG, which is shared across ports */
+static spinlock_t mv643xx_eth_phy_lock = SPIN_LOCK_UNLOCKED;
+
+static inline u32 mv_read(int offset)
+{
+	void *__iomem reg_base;
+
+	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
+
+	return readl(reg_base + offset);
+}
+
+static inline void mv_write(int offset, u32 data)
+{
+	void * __iomem reg_base;
 
-unsigned char prom_mac_addr_base[6];
-unsigned long mv64340_sram_base;
+	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
+	writel(data, reg_base + offset);
+}
 
 /*
  * Changes MTU (maximum transfer unit) of the gigabit ethenret port
  *
- * Input : pointer to ethernet interface network device structure
- *         new mtu size 
- * Output : 0 upon success, -EINVAL upon failure
+ * Input :	pointer to ethernet interface network device structure
+ *		new mtu size
+ * Output :	0 upon success, -EINVAL upon failure
  */
-static int mv64340_eth_change_mtu(struct net_device *dev, int new_mtu)
+static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&mp->lock, flags);
@@ -108,21 +134,21 @@
 	}
 
 	dev->mtu = new_mtu;
-	/* 
+	/*
 	 * Stop then re-open the interface. This will allocate RX skb's with
 	 * the new MTU.
 	 * There is a possible danger that the open will not successed, due
 	 * to memory is full, which might fail the open function.
 	 */
 	if (netif_running(dev)) {
-		if (mv64340_eth_real_stop(dev))
+		if (mv643xx_eth_real_stop(dev))
 			printk(KERN_ERR
-			       "%s: Fatal error on stopping device\n",
-			       dev->name);
-		if (mv64340_eth_real_open(dev))
+				"%s: Fatal error on stopping device\n",
+				dev->name);
+		if (mv643xx_eth_real_open(dev))
 			printk(KERN_ERR
-			       "%s: Fatal error on opening device\n",
-			       dev->name);
+				"%s: Fatal error on opening device\n",
+				dev->name);
 	}
 
 	spin_unlock_irqrestore(&mp->lock, flags);
@@ -130,17 +156,17 @@
 }
 
 /*
- * mv64340_eth_rx_task
- *								       
+ * mv643xx_eth_rx_task
+ *
  * Fills / refills RX queue on a certain gigabit ethernet port
  *
- * Input : pointer to ethernet interface network device structure
- * Output : N/A
+ * Input :	pointer to ethernet interface network device structure
+ * Output :	N/A
  */
-static void mv64340_eth_rx_task(void *data)
+static void mv643xx_eth_rx_task(void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct net_device *dev = (struct net_device *)data;
+	struct mv643xx_private *mp = netdev_priv(dev);
 	struct pkt_info pkt_info;
 	struct sk_buff *skb;
 
@@ -148,28 +174,18 @@
 		panic("%s: Error in test_set_bit / clear_bit", dev->name);
 
 	while (mp->rx_ring_skbs < (mp->rx_ring_size - 5)) {
-		/* The +8 for buffer allignment and another 32 byte extra */
-
-		skb = dev_alloc_skb(BUFFER_MTU + 8 + EXTRA_BYTES);
+		skb = dev_alloc_skb(RX_SKB_SIZE);
 		if (!skb)
-			/* Better luck next time */
 			break;
 		mp->rx_ring_skbs++;
 		pkt_info.cmd_sts = ETH_RX_ENABLE_INTERRUPT;
-		pkt_info.byte_cnt = dev->mtu + ETH_HLEN + 4 + 2 + EXTRA_BYTES;
-		/* Allign buffer to 8 bytes */
-		if (pkt_info.byte_cnt & ~0x7) {
-			pkt_info.byte_cnt &= ~0x7;
-			pkt_info.byte_cnt += 8;
-		}
-		pkt_info.buf_ptr =
-		    pci_map_single(0, skb->data,
-				   dev->mtu + ETH_HLEN + 4 + 2 + EXTRA_BYTES,
-				   PCI_DMA_FROMDEVICE);
+		pkt_info.byte_cnt = RX_SKB_SIZE;
+		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, RX_SKB_SIZE,
+							DMA_FROM_DEVICE);
 		pkt_info.return_info = skb;
 		if (eth_rx_return_buff(mp, &pkt_info) != ETH_OK) {
 			printk(KERN_ERR
-			       "%s: Error allocating RX Ring\n", dev->name);
+				"%s: Error allocating RX Ring\n", dev->name);
 			break;
 		}
 		skb_reserve(skb, 2);
@@ -186,46 +202,45 @@
 		add_timer(&mp->timeout);
 		mp->rx_timer_flag = 1;
 	}
-#if MV64340_RX_QUEUE_FILL_ON_TASK
+#ifdef MV643XX_RX_QUEUE_FILL_ON_TASK
 	else {
 		/* Return interrupts */
-		MV_WRITE(MV64340_ETH_INTERRUPT_MASK_REG(mp->port_num),
-			 INT_CAUSE_UNMASK_ALL);
+		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(mp->port_num),
+							INT_CAUSE_UNMASK_ALL);
 	}
 #endif
 }
 
 /*
- * mv64340_eth_rx_task_timer_wrapper
- *								       
+ * mv643xx_eth_rx_task_timer_wrapper
+ *
  * Timer routine to wake up RX queue filling task. This function is
  * used only in case the RX queue is empty, and all alloc_skb has
  * failed (due to out of memory event).
  *
- * Input : pointer to ethernet interface network device structure
- * Output : N/A
+ * Input :	pointer to ethernet interface network device structure
+ * Output :	N/A
  */
-static void mv64340_eth_rx_task_timer_wrapper(unsigned long data)
+static void mv643xx_eth_rx_task_timer_wrapper(unsigned long data)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct net_device *dev = (struct net_device *)data;
+	struct mv643xx_private *mp = netdev_priv(dev);
 
 	mp->rx_timer_flag = 0;
-	mv64340_eth_rx_task((void *) data);
+	mv643xx_eth_rx_task((void *)data);
 }
 
-
 /*
- * mv64340_eth_update_mac_address
- *								       
+ * mv643xx_eth_update_mac_address
+ *
  * Update the MAC address of the port in the address table
  *
- * Input : pointer to ethernet interface network device structure
- * Output : N/A
+ * Input :	pointer to ethernet interface network device structure
+ * Output :	N/A
  */
-static void mv64340_eth_update_mac_address(struct net_device *dev)
+static void mv643xx_eth_update_mac_address(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
 
 	eth_port_init_mac_tables(port_num);
@@ -234,64 +249,59 @@
 }
 
 /*
- * mv64340_eth_set_rx_mode
- *								       
+ * mv643xx_eth_set_rx_mode
+ *
  * Change from promiscuos to regular rx mode
  *
- * Input : pointer to ethernet interface network device structure
- * Output : N/A
+ * Input :	pointer to ethernet interface network device structure
+ * Output :	N/A
  */
-static void mv64340_eth_set_rx_mode(struct net_device *dev)
+static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
+	u32 config_reg;
 
-	if (dev->flags & IFF_PROMISC) {
-		ethernet_set_config_reg
-		    (mp->port_num,
-		     ethernet_get_config_reg(mp->port_num) |
-		     ETH_UNICAST_PROMISCUOUS_MODE);
-	} else {
-		ethernet_set_config_reg
-		    (mp->port_num,
-		     ethernet_get_config_reg(mp->port_num) &
-		     ~(unsigned int) ETH_UNICAST_PROMISCUOUS_MODE);
-	}
+	config_reg = ethernet_get_config_reg(mp->port_num);
+	if (dev->flags & IFF_PROMISC)
+		config_reg |= (u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
+	else
+		config_reg &= ~(u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
+	ethernet_set_config_reg(mp->port_num, config_reg);
 }
 
-
 /*
- * mv64340_eth_set_mac_address
- *								       
+ * mv643xx_eth_set_mac_address
+ *
  * Change the interface's mac address.
  * No special hardware thing should be done because interface is always
  * put in promiscuous mode.
  *
- * Input : pointer to ethernet interface network device structure and
- *         a pointer to the designated entry to be added to the cache.
- * Output : zero upon success, negative upon failure
+ * Input :	pointer to ethernet interface network device structure and
+ *		a pointer to the designated entry to be added to the cache.
+ * Output :	zero upon success, negative upon failure
  */
-static int mv64340_eth_set_mac_address(struct net_device *dev, void *addr)
+static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 {
 	int i;
 
 	for (i = 0; i < 6; i++)
 		/* +2 is for the offset of the HW addr type */
-		dev->dev_addr[i] = ((unsigned char *) addr)[i + 2];
-	mv64340_eth_update_mac_address(dev);
+		dev->dev_addr[i] = ((unsigned char *)addr)[i + 2];
+	mv643xx_eth_update_mac_address(dev);
 	return 0;
 }
 
 /*
- * mv64340_eth_tx_timeout
- *								       
+ * mv643xx_eth_tx_timeout
+ *
  * Called upon a timeout on transmitting a packet
  *
- * Input : pointer to ethernet interface network device structure.
- * Output : N/A
+ * Input :	pointer to ethernet interface network device structure.
+ * Output :	N/A
  */
-static void mv64340_eth_tx_timeout(struct net_device *dev)
+static void mv643xx_eth_tx_timeout(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 
 	printk(KERN_INFO "%s: TX timeout  ", dev->name);
 
@@ -300,31 +310,31 @@
 }
 
 /*
- * mv64340_eth_tx_timeout_task
+ * mv643xx_eth_tx_timeout_task
  *
  * Actual routine to reset the adapter when a timeout on Tx has occurred
  */
-static void mv64340_eth_tx_timeout_task(struct net_device *dev)
+static void mv643xx_eth_tx_timeout_task(struct net_device *dev)
 {
-        struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 
-        netif_device_detach(dev);
-        eth_port_reset(mp->port_num);
-        eth_port_start(mp);
-        netif_device_attach(dev);
+	netif_device_detach(dev);
+	eth_port_reset(mp->port_num);
+	eth_port_start(mp);
+	netif_device_attach(dev);
 }
 
 /*
- * mv64340_eth_free_tx_queue
+ * mv643xx_eth_free_tx_queue
  *
- * Input : dev - a pointer to the required interface
+ * Input :	dev - a pointer to the required interface
  *
- * Output : 0 if was able to release skb , nonzero otherwise
+ * Output :	0 if was able to release skb , nonzero otherwise
  */
-static int mv64340_eth_free_tx_queue(struct net_device *dev,
-			      unsigned int eth_int_cause_ext)
+static int mv643xx_eth_free_tx_queue(struct net_device *dev,
+					unsigned int eth_int_cause_ext)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	struct net_device_stats *stats = &mp->stats;
 	struct pkt_info pkt_info;
 	int released = 1;
@@ -341,33 +351,36 @@
 			stats->tx_errors++;
 		}
 
-		/* 
+		/*
 		 * If return_info is different than 0, release the skb.
 		 * The case where return_info is not 0 is only in case
 		 * when transmitted a scatter/gather packet, where only
 		 * last skb releases the whole chain.
 		 */
 		if (pkt_info.return_info) {
-			dev_kfree_skb_irq((struct sk_buff *)
-					  pkt_info.return_info);
-			released = 0;
 			if (skb_shinfo(pkt_info.return_info)->nr_frags)
-				pci_unmap_page(NULL, pkt_info.buf_ptr,
-					pkt_info.byte_cnt, PCI_DMA_TODEVICE);
+				dma_unmap_page(NULL, pkt_info.buf_ptr,
+						pkt_info.byte_cnt,
+						DMA_TO_DEVICE);
+			else
+				dma_unmap_single(NULL, pkt_info.buf_ptr,
+						pkt_info.byte_cnt,
+						DMA_TO_DEVICE);
 
-			if (mp->tx_ring_skbs != 1)
-				mp->tx_ring_skbs--;
-		} else 
-			pci_unmap_page(NULL, pkt_info.buf_ptr,
-					pkt_info.byte_cnt, PCI_DMA_TODEVICE);
-
-		/* 
-		 * Decrement the number of outstanding skbs counter on
-		 * the TX queue.
-		 */
-		if (mp->tx_ring_skbs == 0)
-			panic("ERROR - TX outstanding SKBs counter is corrupted");
+			dev_kfree_skb_irq(pkt_info.return_info);
+			released = 0;
 
+			/*
+			 * Decrement the number of outstanding skbs counter on
+			 * the TX queue.
+			 */
+			if (mp->tx_ring_skbs == 0)
+				panic("ERROR - TX outstanding SKBs"
+						" counter is corrupted");
+			mp->tx_ring_skbs--;
+		} else
+			dma_unmap_page(NULL, pkt_info.buf_ptr,
+					pkt_info.byte_cnt, DMA_TO_DEVICE);
 	}
 
 	spin_unlock(&mp->lock);
@@ -376,60 +389,59 @@
 }
 
 /*
- * mv64340_eth_receive
+ * mv643xx_eth_receive
  *
  * This function is forward packets that are received from the port's
  * queues toward kernel core or FastRoute them to another interface.
  *
- * Input : dev - a pointer to the required interface
- *         max - maximum number to receive (0 means unlimted)
+ * Input :	dev - a pointer to the required interface
+ *		max - maximum number to receive (0 means unlimted)
  *
- * Output : number of served packets
+ * Output :	number of served packets
  */
-#ifdef MV64340_NAPI
-static int mv64340_eth_receive_queue(struct net_device *dev, unsigned int max,
-								int budget)
+#ifdef MV643XX_NAPI
+static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 #else
-static int mv64340_eth_receive_queue(struct net_device *dev, unsigned int max)
+static int mv643xx_eth_receive_queue(struct net_device *dev)
 #endif
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	struct net_device_stats *stats = &mp->stats;
 	unsigned int received_packets = 0;
 	struct sk_buff *skb;
 	struct pkt_info pkt_info;
 
-#ifdef MV64340_NAPI
+#ifdef MV643XX_NAPI
 	while (eth_port_receive(mp, &pkt_info) == ETH_OK && budget > 0) {
 #else
-	while ((--max) && eth_port_receive(mp, &pkt_info) == ETH_OK) {
+	while (eth_port_receive(mp, &pkt_info) == ETH_OK) {
 #endif
 		mp->rx_ring_skbs--;
 		received_packets++;
-#ifdef MV64340_NAPI
+#ifdef MV643XX_NAPI
 		budget--;
 #endif
 		/* Update statistics. Note byte count includes 4 byte CRC count */
 		stats->rx_packets++;
 		stats->rx_bytes += pkt_info.byte_cnt;
-		skb = (struct sk_buff *) pkt_info.return_info;
+		skb = pkt_info.return_info;
 		/*
 		 * In case received a packet without first / last bits on OR
 		 * the error summary bit is on, the packets needs to be dropeed.
 		 */
 		if (((pkt_info.cmd_sts
-		      & (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) !=
-		     (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC))
-		    || (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)) {
+				& (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) !=
+					(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC))
+				|| (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)) {
 			stats->rx_dropped++;
 			if ((pkt_info.cmd_sts & (ETH_RX_FIRST_DESC |
-						 ETH_RX_LAST_DESC)) !=
-			    (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
+							ETH_RX_LAST_DESC)) !=
+				(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
 				if (net_ratelimit())
 					printk(KERN_ERR
-					       "%s: Received packet spread on multiple"
-					       " descriptors\n",
-					       dev->name);
+						"%s: Received packet spread "
+						"on multiple descriptors\n",
+						dev->name);
 			}
 			if (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)
 				stats->rx_errors++;
@@ -445,11 +457,11 @@
 
 			if (pkt_info.cmd_sts & ETH_LAYER_4_CHECKSUM_OK) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				skb->csum = htons((pkt_info.cmd_sts
-							& 0x0007fff8) >> 3);
+				skb->csum = htons(
+					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
 			}
 			skb->protocol = eth_type_trans(skb, dev);
-#ifdef MV64340_NAPI
+#ifdef MV643XX_NAPI
 			netif_receive_skb(skb);
 #else
 			netif_rx(skb);
@@ -461,74 +473,74 @@
 }
 
 /*
- * mv64340_eth_int_handler
+ * mv643xx_eth_int_handler
  *
  * Main interrupt handler for the gigbit ethernet ports
  *
- * Input : irq - irq number (not used)
- *         dev_id - a pointer to the required interface's data structure
- *         regs   - not used
- * Output : N/A
+ * Input :	irq	- irq number (not used)
+ *		dev_id	- a pointer to the required interface's data structure
+ *		regs	- not used
+ * Output :	N/A
  */
 
-static irqreturn_t mv64340_eth_int_handler(int irq, void *dev_id,
-	struct pt_regs *regs)
+static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id,
+							struct pt_regs *regs)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct mv643xx_private *mp = netdev_priv(dev);
 	u32 eth_int_cause, eth_int_cause_ext = 0;
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = MV_READ(MV64340_ETH_INTERRUPT_CAUSE_REG(port_num)) &
-			INT_CAUSE_UNMASK_ALL;
+	eth_int_cause = mv_read(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num)) &
+						INT_CAUSE_UNMASK_ALL;
 
 	if (eth_int_cause & BIT1)
-		eth_int_cause_ext =
-		MV_READ(MV64340_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
-		INT_CAUSE_UNMASK_ALL_EXT;
+		eth_int_cause_ext = mv_read(
+			MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
+						INT_CAUSE_UNMASK_ALL_EXT;
 
-#ifdef MV64340_NAPI
+#ifdef MV643XX_NAPI
 	if (!(eth_int_cause & 0x0007fffd)) {
-	/* Dont ack the Rx interrupt */
+		/* Dont ack the Rx interrupt */
 #endif
 		/*
-	 	 * Clear specific ethernet port intrerrupt registers by
+		 * Clear specific ethernet port intrerrupt registers by
 		 * acknowleding relevant bits.
 		 */
-		MV_WRITE(MV64340_ETH_INTERRUPT_CAUSE_REG(port_num),
-			 ~eth_int_cause);
+		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num),
+							~eth_int_cause);
 		if (eth_int_cause_ext != 0x0)
-			MV_WRITE(MV64340_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num),
-				 ~eth_int_cause_ext);
+			mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG
+					(port_num), ~eth_int_cause_ext);
 
 		/* UDP change : We may need this */
 		if ((eth_int_cause_ext & 0x0000ffff) &&
-		    (mv64340_eth_free_tx_queue(dev, eth_int_cause_ext) == 0) &&
-		    (MV64340_TX_QUEUE_SIZE > mp->tx_ring_skbs + 1))
-                                         netif_wake_queue(dev);
-#ifdef MV64340_NAPI
+		    (mv643xx_eth_free_tx_queue(dev, eth_int_cause_ext) == 0) &&
+		    (mp->tx_ring_size > mp->tx_ring_skbs + MAX_DESCS_PER_SKB))
+			netif_wake_queue(dev);
+#ifdef MV643XX_NAPI
 	} else {
 		if (netif_rx_schedule_prep(dev)) {
 			/* Mask all the interrupts */
-			MV_WRITE(MV64340_ETH_INTERRUPT_MASK_REG(port_num),0);
-			MV_WRITE(MV64340_ETH_INTERRUPT_EXTEND_MASK_REG(port_num), 0);
+			mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
+			mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG
+								(port_num), 0);
 			__netif_rx_schedule(dev);
 		}
 #else
-		{
 		if (eth_int_cause & (BIT2 | BIT11))
-			mv64340_eth_receive_queue(dev, 0);
+			mv643xx_eth_receive_queue(dev, 0);
 
 		/*
-		 * After forwarded received packets to upper layer,  add a task
+		 * After forwarded received packets to upper layer, add a task
 		 * in an interrupts enabled context that refills the RX ring
 		 * with skb's.
 		 */
-#if MV64340_RX_QUEUE_FILL_ON_TASK
+#ifdef MV643XX_RX_QUEUE_FILL_ON_TASK
 		/* Unmask all interrupts on ethernet port */
-		MV_WRITE(MV64340_ETH_INTERRUPT_MASK_REG(port_num),
-		         INT_CAUSE_MASK_ALL);
+		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+							INT_CAUSE_MASK_ALL);
 		queue_task(&mp->rx_task, &tq_immediate);
 		mark_bh(IMMEDIATE_BH);
 #else
@@ -538,25 +550,15 @@
 	}
 	/* PHY status changed */
 	if (eth_int_cause_ext & (BIT16 | BIT20)) {
-		unsigned int phy_reg_data;
-
-		/* Check Link status on ethernet port */
-		eth_port_read_smi_reg(port_num, 1, &phy_reg_data);
-		if (!(phy_reg_data & 0x20)) {
-			netif_stop_queue(dev);
-		} else {
+		if (eth_port_link_is_up(port_num)) {
+			netif_carrier_on(dev);
 			netif_wake_queue(dev);
-
-			/*
-			 * Start all TX queues on ethernet port. This is good in
-			 * case of previous packets where not transmitted, due
-			 * to link down and this command re-enables all TX
-			 * queues.
-			 * Note that it is possible to get a TX resource error
-			 * interrupt after issuing this, since not all TX queues
-			 * are enabled, or has anything to send.
-			 */
-			MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 1);
+			/* Start TX queue */
+			mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG
+								(port_num), 1);
+		} else {
+			netif_carrier_off(dev);
+			netif_stop_queue(dev);
 		}
 	}
 
@@ -570,7 +572,7 @@
 	return IRQ_HANDLED;
 }
 
-#ifdef MV64340_COAL
+#ifdef MV643XX_COAL
 
 /*
  * eth_port_set_rx_coal - Sets coalescing interrupt mechanism on RX path
@@ -584,9 +586,9 @@
  *	, and the required delay of the interrupt in usec.
  *
  * INPUT:
- *	unsigned int eth_port_num      Ethernet port number
- *	unsigned int t_clk        t_clk of the MV-643xx chip in HZ units
- *	unsigned int delay       Delay in usec
+ *	unsigned int eth_port_num	Ethernet port number
+ *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
+ *	unsigned int delay		Delay in usec
  *
  * OUTPUT:
  *	Interrupt coalescing mechanism value is set in MV-643xx chip.
@@ -596,15 +598,15 @@
  *
  */
 static unsigned int eth_port_set_rx_coal(unsigned int eth_port_num,
-	unsigned int t_clk, unsigned int delay)
+					unsigned int t_clk, unsigned int delay)
 {
 	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
-	MV_WRITE(MV64340_ETH_SDMA_CONFIG_REG(eth_port_num),
-		 ((coal & 0x3fff) << 8) |
-		 (MV_READ(MV64340_ETH_SDMA_CONFIG_REG(eth_port_num))
-		  & 0xffc000ff));
+	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num),
+		((coal & 0x3fff) << 8) |
+		(mv_read(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num))
+			& 0xffc000ff));
 
 	return coal;
 }
@@ -618,13 +620,13 @@
  *	This parameter is a timeout counter, that counts in 64 t_clk
  *	chunks ; that when timeout event occurs a maskable interrupt
  *	occurs.
- *	The parameter is calculated using the t_cLK frequency of the 
+ *	The parameter is calculated using the t_cLK frequency of the
  *	MV-643xx chip and the required delay in the interrupt in uSec
  *
  * INPUT:
- *	unsigned int eth_port_num      Ethernet port number
- *	unsigned int t_clk        t_clk of the MV-643xx chip in HZ units
- *	unsigned int delay       Delay in uSeconds
+ *	unsigned int eth_port_num	Ethernet port number
+ *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
+ *	unsigned int delay		Delay in uSeconds
  *
  * OUTPUT:
  *	Interrupt coalescing mechanism value is set in MV-643xx chip.
@@ -634,48 +636,48 @@
  *
  */
 static unsigned int eth_port_set_tx_coal(unsigned int eth_port_num,
-	unsigned int t_clk, unsigned int delay)
+					unsigned int t_clk, unsigned int delay)
 {
 	unsigned int coal;
 	coal = ((t_clk / 1000000) * delay) / 64;
 	/* Set TX Coalescing mechanism */
-	MV_WRITE(MV64340_ETH_TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num),
-		 coal << 4);
+	mv_write(MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num),
+								coal << 4);
 	return coal;
 }
 
 /*
- * mv64340_eth_open
+ * mv643xx_eth_open
  *
  * This function is called when openning the network device. The function
  * should initialize all the hardware, initialize cyclic Rx/Tx
  * descriptors chain and buffers and allocate an IRQ to the network
  * device.
  *
- * Input : a pointer to the network device structure
+ * Input :	a pointer to the network device structure
  *
- * Output : zero of success , nonzero if fails.
+ * Output :	zero of success , nonzero if fails.
  */
 
-static int mv64340_eth_open(struct net_device *dev)
+static int mv643xx_eth_open(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
-	int err = err;
+	int err;
 
 	spin_lock_irq(&mp->lock);
 
-	err = request_irq(dev->irq, mv64340_eth_int_handler,
-	                  SA_INTERRUPT | SA_SAMPLE_RANDOM, dev->name, dev);
+	err = request_irq(dev->irq, mv643xx_eth_int_handler,
+			SA_INTERRUPT | SA_SAMPLE_RANDOM, dev->name, dev);
 
 	if (err) {
-		printk(KERN_ERR "Can not assign IRQ number to MV64340_eth%d\n",
-		       port_num);
+		printk(KERN_ERR "Can not assign IRQ number to MV643XX_eth%d\n",
+								port_num);
 		err = -EAGAIN;
 		goto out;
 	}
 
-	if (mv64340_eth_real_open(dev)) {
+	if (mv643xx_eth_real_open(dev)) {
 		printk("%s: Error opening interface\n", dev->name);
 		err = -EBUSY;
 		goto out_free;
@@ -698,66 +700,35 @@
  * ether_init_rx_desc_ring - Curve a Rx chain desc list and buffer in memory.
  *
  * DESCRIPTION:
- *       This function prepares a Rx chained list of descriptors and packet 
- *       buffers in a form of a ring. The routine must be called after port 
- *       initialization routine and before port start routine. 
- *       The Ethernet SDMA engine uses CPU bus addresses to access the various 
- *       devices in the system (i.e. DRAM). This function uses the ethernet 
- *       struct 'virtual to physical' routine (set by the user) to set the ring 
- *       with physical addresses.
+ *	This function prepares a Rx chained list of descriptors and packet
+ *	buffers in a form of a ring. The routine must be called after port
+ *	initialization routine and before port start routine.
+ *	The Ethernet SDMA engine uses CPU bus addresses to access the various
+ *	devices in the system (i.e. DRAM). This function uses the ethernet
+ *	struct 'virtual to physical' routine (set by the user) to set the ring
+ *	with physical addresses.
  *
  * INPUT:
- *	struct mv64340_private   *mp   Ethernet Port Control srtuct. 
- *      int 			rx_desc_num       Number of Rx descriptors
- *      int 			rx_buff_size      Size of Rx buffer
- *      unsigned int    rx_desc_base_addr  Rx descriptors memory area base addr.
- *      unsigned int    rx_buff_base_addr  Rx buffer memory area base addr.
+ *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
  *
  * OUTPUT:
- *      The routine updates the Ethernet port control struct with information 
- *      regarding the Rx descriptors and buffers.
+ *	The routine updates the Ethernet port control struct with information
+ *	regarding the Rx descriptors and buffers.
  *
  * RETURN:
- *      false if the given descriptors memory area is not aligned according to
- *      Ethernet SDMA specifications.
- *      true otherwise.
+ *	None.
  */
-static int ether_init_rx_desc_ring(struct mv64340_private * mp,
-	unsigned long rx_buff_base_addr)
+static void ether_init_rx_desc_ring(struct mv643xx_private *mp)
 {
-	unsigned long buffer_addr = rx_buff_base_addr;
 	volatile struct eth_rx_desc *p_rx_desc;
 	int rx_desc_num = mp->rx_ring_size;
-	unsigned long rx_desc_base_addr = (unsigned long) mp->p_rx_desc_area;
-	int rx_buff_size = 1536;	/* Dummy, will be replaced later */
 	int i;
 
-	p_rx_desc = (struct eth_rx_desc *) rx_desc_base_addr;
-
-	/* Rx desc Must be 4LW aligned (i.e. Descriptor_Address[3:0]=0000). */
-	if (rx_buff_base_addr & 0xf)
-		return 0;
-
-	/* Rx buffers are limited to 64K bytes and Minimum size is 8 bytes  */
-	if ((rx_buff_size < 8) || (rx_buff_size > RX_BUFFER_MAX_SIZE))
-		return 0;
-
-	/* Rx buffers must be 64-bit aligned.       */
-	if ((rx_buff_base_addr + rx_buff_size) & 0x7)
-		return 0;
-
-	/* initialize the Rx descriptors ring */
+	/* initialize the next_desc_ptr links in the Rx descriptors ring */
+	p_rx_desc = (struct eth_rx_desc *)mp->p_rx_desc_area;
 	for (i = 0; i < rx_desc_num; i++) {
-		p_rx_desc[i].buf_size = rx_buff_size;
-		p_rx_desc[i].byte_cnt = 0x0000;
-		p_rx_desc[i].cmd_sts =
-			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
 		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
 			((i + 1) % rx_desc_num) * sizeof(struct eth_rx_desc);
-		p_rx_desc[i].buf_ptr = buffer_addr;
-
-		mp->rx_skb[i] = NULL;
-		buffer_addr += rx_buff_size;
 	}
 
 	/* Save Rx desc pointer to driver struct. */
@@ -766,293 +737,288 @@
 
 	mp->rx_desc_area_size = rx_desc_num * sizeof(struct eth_rx_desc);
 
+	/* Add the queue to the list of RX queues of this port */
 	mp->port_rx_queue_command |= 1;
-
-	return 1;
 }
 
 /*
  * ether_init_tx_desc_ring - Curve a Tx chain desc list and buffer in memory.
  *
  * DESCRIPTION:
- *       This function prepares a Tx chained list of descriptors and packet 
- *       buffers in a form of a ring. The routine must be called after port 
- *       initialization routine and before port start routine. 
- *       The Ethernet SDMA engine uses CPU bus addresses to access the various 
- *       devices in the system (i.e. DRAM). This function uses the ethernet 
- *       struct 'virtual to physical' routine (set by the user) to set the ring 
- *       with physical addresses.
+ *	This function prepares a Tx chained list of descriptors and packet
+ *	buffers in a form of a ring. The routine must be called after port
+ *	initialization routine and before port start routine.
+ *	The Ethernet SDMA engine uses CPU bus addresses to access the various
+ *	devices in the system (i.e. DRAM). This function uses the ethernet
+ *	struct 'virtual to physical' routine (set by the user) to set the ring
+ *	with physical addresses.
  *
  * INPUT:
- *	struct mv64340_private   *mp   Ethernet Port Control srtuct. 
- *      int 		tx_desc_num        Number of Tx descriptors
- *      int 		tx_buff_size	   Size of Tx buffer
- *      unsigned int    tx_desc_base_addr  Tx descriptors memory area base addr.
+ *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
  *
  * OUTPUT:
- *      The routine updates the Ethernet port control struct with information 
- *      regarding the Tx descriptors and buffers.
+ *	The routine updates the Ethernet port control struct with information
+ *	regarding the Tx descriptors and buffers.
  *
  * RETURN:
- *      false if the given descriptors memory area is not aligned according to
- *      Ethernet SDMA specifications.
- *      true otherwise.
+ *	None.
  */
-static int ether_init_tx_desc_ring(struct mv64340_private *mp)
+static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
 {
-	unsigned long tx_desc_base_addr = (unsigned long) mp->p_tx_desc_area;
 	int tx_desc_num = mp->tx_ring_size;
 	struct eth_tx_desc *p_tx_desc;
 	int i;
 
-	/* Tx desc Must be 4LW aligned (i.e. Descriptor_Address[3:0]=0000). */
-	if (tx_desc_base_addr & 0xf)
-		return 0;
-
-	/* save the first desc pointer to link with the last descriptor */
-	p_tx_desc = (struct eth_tx_desc *) tx_desc_base_addr;
-
-	/* Initialize the Tx descriptors ring */
+	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
+	p_tx_desc = (struct eth_tx_desc *)mp->p_tx_desc_area;
 	for (i = 0; i < tx_desc_num; i++) {
-		p_tx_desc[i].byte_cnt	= 0x0000;
-		p_tx_desc[i].l4i_chk	= 0x0000;
-		p_tx_desc[i].cmd_sts	= 0x00000000;
 		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
 			((i + 1) % tx_desc_num) * sizeof(struct eth_tx_desc);
-		p_tx_desc[i].buf_ptr	= 0x00000000;
-		mp->tx_skb[i]		= NULL;
 	}
 
-	/* Set Tx desc pointer in driver struct. */
 	mp->tx_curr_desc_q = 0;
 	mp->tx_used_desc_q = 0;
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
-        mp->tx_first_desc_q = 0;
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+	mp->tx_first_desc_q = 0;
 #endif
-	/* Init Tx ring base and size parameters */
-	mp->tx_desc_area_size	= tx_desc_num * sizeof(struct eth_tx_desc);
+
+	mp->tx_desc_area_size = tx_desc_num * sizeof(struct eth_tx_desc);
 
 	/* Add the queue to the list of Tx queues of this port */
 	mp->port_tx_queue_command |= 1;
-
-	return 1;
 }
 
-/* Helper function for mv64340_eth_open */
-static int mv64340_eth_real_open(struct net_device *dev)
+/* Helper function for mv643xx_eth_open */
+static int mv643xx_eth_real_open(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
-	u32 phy_reg_data;
 	unsigned int size;
 
 	/* Stop RX Queues */
-	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
-		 0x0000ff00);
+	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), 0x0000ff00);
 
 	/* Clear the ethernet port interrupts */
-	MV_WRITE(MV64340_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	MV_WRITE(MV64340_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 
 	/* Unmask RX buffer and TX end interrupt */
-	MV_WRITE(MV64340_ETH_INTERRUPT_MASK_REG(port_num),
-		 INT_CAUSE_UNMASK_ALL);
+	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+						INT_CAUSE_UNMASK_ALL);
 
 	/* Unmask phy and link status changes interrupts */
-	MV_WRITE(MV64340_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
-		 INT_CAUSE_UNMASK_ALL_EXT);
+	mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
+						INT_CAUSE_UNMASK_ALL_EXT);
 
 	/* Set the MAC Address */
 	memcpy(mp->port_mac_addr, dev->dev_addr, 6);
 
 	eth_port_init(mp);
 
-	INIT_WORK(&mp->rx_task, (void (*)(void *)) mv64340_eth_rx_task, dev);
+	INIT_WORK(&mp->rx_task, (void (*)(void *))mv643xx_eth_rx_task, dev);
 
 	memset(&mp->timeout, 0, sizeof(struct timer_list));
-	mp->timeout.function = mv64340_eth_rx_task_timer_wrapper;
-	mp->timeout.data = (unsigned long) dev;
+	mp->timeout.function = mv643xx_eth_rx_task_timer_wrapper;
+	mp->timeout.data = (unsigned long)dev;
 
 	mp->rx_task_busy = 0;
 	mp->rx_timer_flag = 0;
 
+	/* Allocate RX and TX skb rings */
+	mp->rx_skb = kmalloc(sizeof(*mp->rx_skb) * mp->rx_ring_size,
+								GFP_KERNEL);
+	if (!mp->rx_skb) {
+		printk(KERN_ERR "%s: Cannot allocate Rx skb ring\n", dev->name);
+		return -ENOMEM;
+	}
+	mp->tx_skb = kmalloc(sizeof(*mp->tx_skb) * mp->tx_ring_size,
+								GFP_KERNEL);
+	if (!mp->tx_skb) {
+		printk(KERN_ERR "%s: Cannot allocate Tx skb ring\n", dev->name);
+		kfree(mp->rx_skb);
+		return -ENOMEM;
+	}
+
 	/* Allocate TX ring */
 	mp->tx_ring_skbs = 0;
-	mp->tx_ring_size = MV64340_TX_QUEUE_SIZE;
 	size = mp->tx_ring_size * sizeof(struct eth_tx_desc);
 	mp->tx_desc_area_size = size;
 
-	/* Assumes allocated ring is 16 bytes alligned */
-	mp->p_tx_desc_area = pci_alloc_consistent(NULL, size, &mp->tx_desc_dma);
+	if (mp->tx_sram_size) {
+		mp->p_tx_desc_area = ioremap(mp->tx_sram_addr,
+							mp->tx_sram_size);
+		mp->tx_desc_dma = mp->tx_sram_addr;
+	} else
+		mp->p_tx_desc_area = dma_alloc_coherent(NULL, size,
+							&mp->tx_desc_dma,
+							GFP_KERNEL);
+
 	if (!mp->p_tx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
-		       dev->name, size);
+							dev->name, size);
+		kfree(mp->rx_skb);
+		kfree(mp->tx_skb);
 		return -ENOMEM;
 	}
-	memset((void *) mp->p_tx_desc_area, 0, mp->tx_desc_area_size);
+	BUG_ON((u32) mp->p_tx_desc_area & 0xf);	/* check 16-byte alignment */
+	memset((void *)mp->p_tx_desc_area, 0, mp->tx_desc_area_size);
 
-	/* Dummy will be replaced upon real tx */
 	ether_init_tx_desc_ring(mp);
 
 	/* Allocate RX ring */
-	/* Meantime RX Ring are fixed - but must be configurable by user */
-	mp->rx_ring_size = MV64340_RX_QUEUE_SIZE;
 	mp->rx_ring_skbs = 0;
 	size = mp->rx_ring_size * sizeof(struct eth_rx_desc);
 	mp->rx_desc_area_size = size;
 
-	/* Assumes allocated ring is 16 bytes aligned */
-
-	mp->p_rx_desc_area = pci_alloc_consistent(NULL, size, &mp->rx_desc_dma);
+	if (mp->rx_sram_size) {
+		mp->p_rx_desc_area = ioremap(mp->rx_sram_addr,
+							mp->rx_sram_size);
+		mp->rx_desc_dma = mp->rx_sram_addr;
+	} else
+		mp->p_rx_desc_area = dma_alloc_coherent(NULL, size,
+							&mp->rx_desc_dma,
+							GFP_KERNEL);
 
 	if (!mp->p_rx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Rx ring (size %d bytes)\n",
-		       dev->name, size);
+							dev->name, size);
 		printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
-		       dev->name);
-		pci_free_consistent(0, mp->tx_desc_area_size,
-				    (void *) mp->p_tx_desc_area,
-				    mp->tx_desc_dma);
+							dev->name);
+		if (mp->rx_sram_size)
+			iounmap(mp->p_rx_desc_area);
+		else
+			dma_free_coherent(NULL, mp->tx_desc_area_size,
+					mp->p_tx_desc_area, mp->tx_desc_dma);
+		kfree(mp->rx_skb);
+		kfree(mp->tx_skb);
 		return -ENOMEM;
 	}
-	memset(mp->p_rx_desc_area, 0, size);
+	memset((void *)mp->p_rx_desc_area, 0, size);
 
-	if (!(ether_init_rx_desc_ring(mp, 0)))
-		panic("%s: Error initializing RX Ring", dev->name);
+	ether_init_rx_desc_ring(mp);
 
-	mv64340_eth_rx_task(dev);	/* Fill RX ring with skb's */
+	mv643xx_eth_rx_task(dev);	/* Fill RX ring with skb's */
 
 	eth_port_start(mp);
 
 	/* Interrupt Coalescing */
 
-#ifdef MV64340_COAL
+#ifdef MV643XX_COAL
 	mp->rx_int_coal =
-		eth_port_set_rx_coal(port_num, 133000000, MV64340_RX_COAL);
+		eth_port_set_rx_coal(port_num, 133000000, MV643XX_RX_COAL);
 #endif
 
 	mp->tx_int_coal =
-		eth_port_set_tx_coal (port_num, 133000000, MV64340_TX_COAL);  
+		eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
 
-	/* Increase the Rx side buffer size */
-
-	MV_WRITE (MV64340_ETH_PORT_SERIAL_CONTROL_REG(port_num), (0x5 << 17) |
-			(MV_READ(MV64340_ETH_PORT_SERIAL_CONTROL_REG(port_num))
-					& 0xfff1ffff));
-
-	/* Check Link status on phy */
-	eth_port_read_smi_reg(port_num, 1, &phy_reg_data);
-	if (!(phy_reg_data & 0x20))
-		netif_stop_queue(dev);
-	else
-		netif_start_queue(dev);
+	netif_start_queue(dev);
 
 	return 0;
 }
 
-static void mv64340_eth_free_tx_rings(struct net_device *dev)
+static void mv643xx_eth_free_tx_rings(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
 	unsigned int curr;
 
 	/* Stop Tx Queues */
-	MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
-		 0x0000ff00);
+	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 0x0000ff00);
 
-	/* Free TX rings */
 	/* Free outstanding skb's on TX rings */
-	for (curr = 0;
-	     (mp->tx_ring_skbs) && (curr < MV64340_TX_QUEUE_SIZE);
-	     curr++) {
+	for (curr = 0; mp->tx_ring_skbs && curr < mp->tx_ring_size; curr++) {
 		if (mp->tx_skb[curr]) {
 			dev_kfree_skb(mp->tx_skb[curr]);
 			mp->tx_ring_skbs--;
 		}
 	}
-	if (mp->tx_ring_skbs != 0)
+	if (mp->tx_ring_skbs)
 		printk("%s: Error on Tx descriptor free - could not free %d"
-		     " descriptors\n", dev->name,
-		     mp->tx_ring_skbs);
-	pci_free_consistent(0, mp->tx_desc_area_size,
-			    (void *) mp->p_tx_desc_area, mp->tx_desc_dma);
+				" descriptors\n", dev->name, mp->tx_ring_skbs);
+
+	/* Free TX ring */
+	if (mp->tx_sram_size)
+		iounmap(mp->p_tx_desc_area);
+	else
+		dma_free_coherent(NULL, mp->tx_desc_area_size,
+				mp->p_tx_desc_area, mp->tx_desc_dma);
 }
 
-static void mv64340_eth_free_rx_rings(struct net_device *dev)
+static void mv643xx_eth_free_rx_rings(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
 	int curr;
 
 	/* Stop RX Queues */
-	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
-		 0x0000ff00);
+	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), 0x0000ff00);
 
-	/* Free RX rings */
 	/* Free preallocated skb's on RX rings */
-	for (curr = 0;
-		mp->rx_ring_skbs && (curr < MV64340_RX_QUEUE_SIZE);
-		curr++) {
+	for (curr = 0; mp->rx_ring_skbs && curr < mp->rx_ring_size; curr++) {
 		if (mp->rx_skb[curr]) {
 			dev_kfree_skb(mp->rx_skb[curr]);
 			mp->rx_ring_skbs--;
 		}
 	}
 
-	if (mp->rx_ring_skbs != 0)
+	if (mp->rx_ring_skbs)
 		printk(KERN_ERR
-		       "%s: Error in freeing Rx Ring. %d skb's still"
-		       " stuck in RX Ring - ignoring them\n", dev->name,
-		       mp->rx_ring_skbs);
-	pci_free_consistent(0, mp->rx_desc_area_size,
-			    (void *) mp->p_rx_desc_area,
-			    mp->rx_desc_dma);
+			"%s: Error in freeing Rx Ring. %d skb's still"
+			" stuck in RX Ring - ignoring them\n", dev->name,
+			mp->rx_ring_skbs);
+	/* Free RX ring */
+	if (mp->rx_sram_size)
+		iounmap(mp->p_rx_desc_area);
+	else
+		dma_free_coherent(NULL, mp->rx_desc_area_size,
+				mp->p_rx_desc_area, mp->rx_desc_dma);
 }
 
 /*
- * mv64340_eth_stop
+ * mv643xx_eth_stop
  *
- * This function is used when closing the network device. 
- * It updates the hardware, 
+ * This function is used when closing the network device.
+ * It updates the hardware,
  * release all memory that holds buffers and descriptors and release the IRQ.
- * Input : a pointer to the device structure
- * Output : zero if success , nonzero if fails
+ * Input :	a pointer to the device structure
+ * Output :	zero if success , nonzero if fails
  */
 
-/* Helper function for mv64340_eth_stop */
+/* Helper function for mv643xx_eth_stop */
 
-static int mv64340_eth_real_stop(struct net_device *dev)
+static int mv643xx_eth_real_stop(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
 
+	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
-	mv64340_eth_free_tx_rings(dev);
-	mv64340_eth_free_rx_rings(dev);
+	mv643xx_eth_free_tx_rings(dev);
+	mv643xx_eth_free_rx_rings(dev);
 
 	eth_port_reset(mp->port_num);
 
 	/* Disable ethernet port interrupts */
-	MV_WRITE(MV64340_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	MV_WRITE(MV64340_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 
 	/* Mask RX buffer and TX end interrupt */
-	MV_WRITE(MV64340_ETH_INTERRUPT_MASK_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
 
 	/* Mask phy and link status changes interrupts */
-	MV_WRITE(MV64340_ETH_INTERRUPT_EXTEND_MASK_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num), 0);
 
 	return 0;
 }
 
-static int mv64340_eth_stop(struct net_device *dev)
+static int mv643xx_eth_stop(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 
 	spin_lock_irq(&mp->lock);
 
-	mv64340_eth_real_stop(dev);
+	mv643xx_eth_real_stop(dev);
 
 	free_irq(dev->irq, dev);
 	spin_unlock_irq(&mp->lock);
@@ -1060,59 +1026,64 @@
 	return 0;
 }
 
-#ifdef MV64340_NAPI
-static void mv64340_tx(struct net_device *dev)
+#ifdef MV643XX_NAPI
+static void mv643xx_tx(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
-        struct pkt_info pkt_info;
+	struct mv643xx_private *mp = netdev_priv(dev);
+	struct pkt_info pkt_info;
 
 	while (eth_tx_return_desc(mp, &pkt_info) == ETH_OK) {
 		if (pkt_info.return_info) {
-			dev_kfree_skb_irq((struct sk_buff *)
-                                                  pkt_info.return_info);
-			if (skb_shinfo(pkt_info.return_info)->nr_frags) 
-                                 pci_unmap_page(NULL, pkt_info.buf_ptr,
-                                             pkt_info.byte_cnt,
-                                             PCI_DMA_TODEVICE);
-
-                         if (mp->tx_ring_skbs != 1)
-                                  mp->tx_ring_skbs--;
-                } else 
-                       pci_unmap_page(NULL, pkt_info.buf_ptr, pkt_info.byte_cnt,
-                                      PCI_DMA_TODEVICE);
+			if (skb_shinfo(pkt_info.return_info)->nr_frags)
+				dma_unmap_page(NULL, pkt_info.buf_ptr,
+						pkt_info.byte_cnt,
+						DMA_TO_DEVICE);
+			else
+				dma_unmap_single(NULL, pkt_info.buf_ptr,
+						pkt_info.byte_cnt,
+						DMA_TO_DEVICE);
+
+			dev_kfree_skb_irq(pkt_info.return_info);
+
+			if (mp->tx_ring_skbs)
+				mp->tx_ring_skbs--;
+		} else
+			dma_unmap_page(NULL, pkt_info.buf_ptr,
+					pkt_info.byte_cnt, DMA_TO_DEVICE);
 	}
 
 	if (netif_queue_stopped(dev) &&
-            MV64340_TX_QUEUE_SIZE > mp->tx_ring_skbs + 1)
-                       netif_wake_queue(dev);
+			mp->tx_ring_size > mp->tx_ring_skbs + MAX_DESCS_PER_SKB)
+		netif_wake_queue(dev);
 }
 
 /*
- * mv64340_poll
+ * mv643xx_poll
  *
  * This function is used in case of NAPI
  */
-static int mv64340_poll(struct net_device *dev, int *budget)
+static int mv643xx_poll(struct net_device *dev, int *budget)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
-	int	done = 1, orig_budget, work_done;
+	struct mv643xx_private *mp = netdev_priv(dev);
+	int done = 1, orig_budget, work_done;
 	unsigned int port_num = mp->port_num;
 	unsigned long flags;
 
-#ifdef MV64340_TX_FAST_REFILL
+#ifdef MV643XX_TX_FAST_REFILL
 	if (++mp->tx_clean_threshold > 5) {
 		spin_lock_irqsave(&mp->lock, flags);
-		mv64340_tx(dev);
+		mv643xx_tx(dev);
 		mp->tx_clean_threshold = 0;
 		spin_unlock_irqrestore(&mp->lock, flags);
 	}
 #endif
 
-	if ((u32)(MV_READ(MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))                                      != (u32)mp->rx_used_desc_q) {
+	if ((mv_read(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
+						!= (u32) mp->rx_used_desc_q) {
 		orig_budget = *budget;
 		if (orig_budget > dev->quota)
 			orig_budget = dev->quota;
-		work_done = mv64340_eth_receive_queue(dev, 0, orig_budget);
+		work_done = mv643xx_eth_receive_queue(dev, orig_budget);
 		mp->rx_task.func(dev);
 		*budget -= work_done;
 		dev->quota -= work_done;
@@ -1123,12 +1094,12 @@
 	if (done) {
 		spin_lock_irqsave(&mp->lock, flags);
 		__netif_rx_complete(dev);
-		MV_WRITE(MV64340_ETH_INTERRUPT_CAUSE_REG(port_num),0);
-                MV_WRITE(MV64340_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num),0);
-		MV_WRITE(MV64340_ETH_INTERRUPT_MASK_REG(port_num), 
+		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
 						INT_CAUSE_UNMASK_ALL);
-		MV_WRITE(MV64340_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
-				                 INT_CAUSE_UNMASK_ALL_EXT);
+		mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
+						INT_CAUSE_UNMASK_ALL_EXT);
 		spin_unlock_irqrestore(&mp->lock, flags);
 	}
 
@@ -1137,19 +1108,19 @@
 #endif
 
 /*
- * mv64340_eth_start_xmit
+ * mv643xx_eth_start_xmit
  *
- * This function is queues a packet in the Tx descriptor for 
+ * This function is queues a packet in the Tx descriptor for
  * required port.
  *
- * Input : skb - a pointer to socket buffer
- *         dev - a pointer to the required port
+ * Input :	skb - a pointer to socket buffer
+ *		dev - a pointer to the required port
  *
- * Output : zero upon success
+ * Output :	zero upon success
  */
-static int mv64340_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 	struct net_device_stats *stats = &mp->stats;
 	ETH_FUNC_RET_STATUS status;
 	unsigned long flags;
@@ -1157,119 +1128,195 @@
 
 	if (netif_queue_stopped(dev)) {
 		printk(KERN_ERR
-		       "%s: Tried sending packet when interface is stopped\n",
-		       dev->name);
+			"%s: Tried sending packet when interface is stopped\n",
+			dev->name);
 		return 1;
 	}
 
 	/* This is a hard error, log it. */
-	if ((MV64340_TX_QUEUE_SIZE - mp->tx_ring_skbs) <=
-	    (skb_shinfo(skb)->nr_frags + 1)) {
+	if ((mp->tx_ring_size - mp->tx_ring_skbs) <=
+					(skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
 		printk(KERN_ERR
-		       "%s: Bug in mv64340_eth - Trying to transmit when"
-		       " queue full !\n", dev->name);
+			"%s: Bug in mv643xx_eth - Trying to transmit when"
+			" queue full !\n", dev->name);
 		return 1;
 	}
 
 	/* Paranoid check - this shouldn't happen */
 	if (skb == NULL) {
 		stats->tx_dropped++;
+		printk(KERN_ERR "mv64320_eth paranoid check failed\n");
 		return 1;
 	}
 
 	spin_lock_irqsave(&mp->lock, flags);
 
 	/* Update packet info data structure -- DMA owned, first last */
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
-	if (!skb_shinfo(skb)->nr_frags || (skb_shinfo(skb)->nr_frags > 3)) {
-#endif
-		pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
-	    	                   ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC;
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+	if (!skb_shinfo(skb)->nr_frags) {
+linear:
+		if (skb->ip_summed != CHECKSUM_HW) {
+			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
+					ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC;
+			pkt_info.l4i_chk = 0;
+		} else {
+			u32 ipheader = skb->nh.iph->ihl << 11;
 
+			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
+					ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC |
+					ETH_GEN_TCP_UDP_CHECKSUM |
+					ETH_GEN_IP_V_4_CHECKSUM | ipheader;
+			/* CPU already calculated pseudo header checksum. */
+			if (skb->nh.iph->protocol == IPPROTO_UDP) {
+				pkt_info.cmd_sts |= ETH_UDP_FRAME;
+				pkt_info.l4i_chk = skb->h.uh->check;
+			} else if (skb->nh.iph->protocol == IPPROTO_TCP)
+				pkt_info.l4i_chk = skb->h.th->check;
+			else {
+				printk(KERN_ERR
+					"%s: chksum proto != TCP or UDP\n",
+					dev->name);
+				spin_unlock_irqrestore(&mp->lock, flags);
+				return 1;
+			}
+		}
 		pkt_info.byte_cnt = skb->len;
-		pkt_info.buf_ptr = pci_map_single(0, skb->data, skb->len,
-		                                  PCI_DMA_TODEVICE);
-
-
+		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, skb->len,
+							DMA_TO_DEVICE);
 		pkt_info.return_info = skb;
+		mp->tx_ring_skbs++;
 		status = eth_port_send(mp, &pkt_info);
 		if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
 			printk(KERN_ERR "%s: Error on transmitting packet\n",
-				       dev->name);
-		mp->tx_ring_skbs++;
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
+								dev->name);
+		stats->tx_bytes += pkt_info.byte_cnt;
 	} else {
-		unsigned int    frag;
-		u32		ipheader;
+		unsigned int frag;
+		u32 ipheader;
 
-                /* first frag which is skb header */
-                pkt_info.byte_cnt = skb_headlen(skb);
-                pkt_info.buf_ptr = pci_map_single(0, skb->data,
-                                        skb_headlen(skb), PCI_DMA_TODEVICE);
-                pkt_info.return_info = 0;
-                ipheader = skb->nh.iph->ihl << 11;
-                pkt_info.cmd_sts = ETH_TX_FIRST_DESC | 
-					ETH_GEN_TCP_UDP_CHECKSUM |
-					ETH_GEN_IP_V_4_CHECKSUM |
-                                        ipheader;
-		/* CPU already calculated pseudo header checksum. So, use it */
-                pkt_info.l4i_chk = skb->h.th->check;
-                status = eth_port_send(mp, &pkt_info);
+		/* Since hardware can't handle unaligned fragments smaller
+		 * than 9 bytes, if we find any, we linearize the skb
+		 * and start again.  When I've seen it, it's always been
+		 * the first frag (probably near the end of the page),
+		 * but we check all frags to be safe.
+		 */
+		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
+			skb_frag_t *fragp;
+
+			fragp = &skb_shinfo(skb)->frags[frag];
+			if (fragp->size <= 8 && fragp->page_offset & 0x7) {
+				skb_linearize(skb, GFP_ATOMIC);
+				printk(KERN_DEBUG "%s: unaligned tiny fragment"
+						"%d of %d, fixed\n",
+						dev->name, frag,
+						skb_shinfo(skb)->nr_frags);
+				goto linear;
+			}
+		}
+
+		/* first frag which is skb header */
+		pkt_info.byte_cnt = skb_headlen(skb);
+		pkt_info.buf_ptr = dma_map_single(NULL, skb->data,
+							skb_headlen(skb),
+							DMA_TO_DEVICE);
+		pkt_info.l4i_chk = 0;
+		pkt_info.return_info = 0;
+		pkt_info.cmd_sts = ETH_TX_FIRST_DESC;
+
+		if (skb->ip_summed == CHECKSUM_HW) {
+			ipheader = skb->nh.iph->ihl << 11;
+			pkt_info.cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
+					ETH_GEN_IP_V_4_CHECKSUM | ipheader;
+			/* CPU already calculated pseudo header checksum. */
+			if (skb->nh.iph->protocol == IPPROTO_UDP) {
+				pkt_info.cmd_sts |= ETH_UDP_FRAME;
+				pkt_info.l4i_chk = skb->h.uh->check;
+			} else if (skb->nh.iph->protocol == IPPROTO_TCP)
+				pkt_info.l4i_chk = skb->h.th->check;
+			else {
+				printk(KERN_ERR
+					"%s: chksum proto != TCP or UDP\n",
+					dev->name);
+				spin_unlock_irqrestore(&mp->lock, flags);
+				return 1;
+			}
+		}
+
+		status = eth_port_send(mp, &pkt_info);
 		if (status != ETH_OK) {
-	                if ((status == ETH_ERROR))
-        	                printk(KERN_ERR "%s: Error on transmitting packet\n", dev->name);
-	                if (status == ETH_QUEUE_FULL)
-        	                printk("Error on Queue Full \n");
-                	if (status == ETH_QUEUE_LAST_RESOURCE)
-                        	printk("Tx resource error \n");
+			if ((status == ETH_ERROR))
+				printk(KERN_ERR
+					"%s: Error on transmitting packet\n",
+					dev->name);
+			if (status == ETH_QUEUE_FULL)
+				printk("Error on Queue Full \n");
+			if (status == ETH_QUEUE_LAST_RESOURCE)
+				printk("Tx resource error \n");
 		}
+		stats->tx_bytes += pkt_info.byte_cnt;
+
+		/* Check for the remaining frags */
+		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
+			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
+			pkt_info.l4i_chk = 0x0000;
+			pkt_info.cmd_sts = 0x00000000;
+
+			/* Last Frag enables interrupt and frees the skb */
+			if (frag == (skb_shinfo(skb)->nr_frags - 1)) {
+				pkt_info.cmd_sts |= ETH_TX_ENABLE_INTERRUPT |
+							ETH_TX_LAST_DESC;
+				pkt_info.return_info = skb;
+				mp->tx_ring_skbs++;
+			} else {
+				pkt_info.return_info = 0;
+			}
+			pkt_info.l4i_chk = 0;
+			pkt_info.byte_cnt = this_frag->size;
 
-                /* Check for the remaining frags */
-                for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-                        skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
-                        pkt_info.l4i_chk = 0x0000;
-                        pkt_info.cmd_sts = 0x00000000;
-
-                        /* Last Frag enables interrupt and frees the skb */
-                        if (frag == (skb_shinfo(skb)->nr_frags - 1)) {
-                                pkt_info.cmd_sts |= ETH_TX_ENABLE_INTERRUPT |
-                                                        ETH_TX_LAST_DESC;
-                                pkt_info.return_info = skb;
-                                mp->tx_ring_skbs++;
-                        }
-                        else {
-                                pkt_info.return_info = 0;
-                        }
-                        pkt_info.byte_cnt = this_frag->size;
-                        if (this_frag->size < 8)
-                                printk("%d : \n", skb_shinfo(skb)->nr_frags);
-
-                        pkt_info.buf_ptr = pci_map_page(NULL, this_frag->page,
-                                        this_frag->page_offset,
-                                        this_frag->size, PCI_DMA_TODEVICE);
+			pkt_info.buf_ptr = dma_map_page(NULL, this_frag->page,
+							this_frag->page_offset,
+							this_frag->size,
+							DMA_TO_DEVICE);
 
-                        status = eth_port_send(mp, &pkt_info);
+			status = eth_port_send(mp, &pkt_info);
 
 			if (status != ETH_OK) {
-	                        if ((status == ETH_ERROR))
-        	                        printk(KERN_ERR "%s: Error on transmitting packet\n", dev->name);
+				if ((status == ETH_ERROR))
+					printk(KERN_ERR "%s: Error on "
+							"transmitting packet\n",
+							dev->name);
 
-       		                 if (status == ETH_QUEUE_LAST_RESOURCE)
-                	                printk("Tx resource error \n");
+				if (status == ETH_QUEUE_LAST_RESOURCE)
+					printk("Tx resource error \n");
 
-                        	if (status == ETH_QUEUE_FULL)
-                                	printk("Queue is full \n");
+				if (status == ETH_QUEUE_FULL)
+					printk("Queue is full \n");
 			}
-                }
-        }
+			stats->tx_bytes += pkt_info.byte_cnt;
+		}
+	}
+#else
+	pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT | ETH_TX_FIRST_DESC |
+							ETH_TX_LAST_DESC;
+	pkt_info.l4i_chk = 0;
+	pkt_info.byte_cnt = skb->len;
+	pkt_info.buf_ptr = dma_map_single(NULL, skb->data, skb->len,
+								DMA_TO_DEVICE);
+	pkt_info.return_info = skb;
+	mp->tx_ring_skbs++;
+	status = eth_port_send(mp, &pkt_info);
+	if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
+		printk(KERN_ERR "%s: Error on transmitting packet\n",
+								dev->name);
+	stats->tx_bytes += pkt_info.byte_cnt;
 #endif
 
 	/* Check if TX queue can handle another skb. If not, then
 	 * signal higher layers to stop requesting TX
 	 */
-	if (MV64340_TX_QUEUE_SIZE <= (mp->tx_ring_skbs + 1))
-		/* 
+	if (mp->tx_ring_size <= (mp->tx_ring_skbs + MAX_DESCS_PER_SKB))
+		/*
 		 * Stop getting skb's from upper layers.
 		 * Getting skb's from upper layers will be enabled again after
 		 * packets are released.
@@ -1277,7 +1324,6 @@
 		netif_stop_queue(dev);
 
 	/* Update statistics and start of transmittion time */
-	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
@@ -1287,212 +1333,302 @@
 }
 
 /*
- * mv64340_eth_get_stats
+ * mv643xx_eth_get_stats
  *
  * Returns a pointer to the interface statistics.
  *
- * Input : dev - a pointer to the required interface
+ * Input :	dev - a pointer to the required interface
  *
- * Output : a pointer to the interface's statistics
+ * Output :	a pointer to the interface's statistics
  */
 
-static struct net_device_stats *mv64340_eth_get_stats(struct net_device *dev)
+static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct mv643xx_private *mp = netdev_priv(dev);
 
 	return &mp->stats;
 }
 
 /*/
- * mv64340_eth_init
- *								       
- * First function called after registering the network device. 
- * It's purpose is to initialize the device as an ethernet device, 
- * fill the structure that was given in registration with pointers
- * to functions, and setting the MAC address of the interface
+ * mv643xx_eth_probe
  *
- * Input : number of port to initialize
- * Output : -ENONMEM if failed , 0 if success
- */
-static struct net_device *mv64340_eth_init(int port_num)
-{
-	struct mv64340_private *mp;
+ * First function called after registering the network device.
+ * It's purpose is to initialize the device as an ethernet device,
+ * fill the ethernet device structure with pointers * to functions,
+ * and set the MAC address of the interface
+ *
+ * Input :	struct device *
+ * Output :	-ENOMEM if failed , 0 if success
+ */
+static int mv643xx_eth_probe(struct device *ddev)
+{
+	struct platform_device *pdev = to_platform_device(ddev);
+	struct mv643xx_eth_platform_data *pd;
+	int port_num = pdev->id;
+	struct mv643xx_private *mp;
 	struct net_device *dev;
+	u8 *p;
+	struct resource *res;
 	int err;
 
-	dev = alloc_etherdev(sizeof(struct mv64340_private));
+	dev = alloc_etherdev(sizeof(struct mv643xx_private));
 	if (!dev)
-		return NULL;
+		return -ENOMEM;
+
+	dev_set_drvdata(ddev, dev);
 
 	mp = netdev_priv(dev);
 
-	dev->irq = ETH_PORT0_IRQ_NUM + port_num;
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	BUG_ON(!res);
+	dev->irq = res->start;
 
-	dev->open = mv64340_eth_open;
-	dev->stop = mv64340_eth_stop;
-	dev->hard_start_xmit = mv64340_eth_start_xmit;
-	dev->get_stats = mv64340_eth_get_stats;
-	dev->set_mac_address = mv64340_eth_set_mac_address;
-	dev->set_multicast_list = mv64340_eth_set_rx_mode;
+	mp->port_num = port_num;
+
+	dev->open = mv643xx_eth_open;
+	dev->stop = mv643xx_eth_stop;
+	dev->hard_start_xmit = mv643xx_eth_start_xmit;
+	dev->get_stats = mv643xx_eth_get_stats;
+	dev->set_mac_address = mv643xx_eth_set_mac_address;
+	dev->set_multicast_list = mv643xx_eth_set_rx_mode;
 
 	/* No need to Tx Timeout */
-	dev->tx_timeout = mv64340_eth_tx_timeout;
-#ifdef MV64340_NAPI
-        dev->poll = mv64340_poll;
-        dev->weight = 64;
+	dev->tx_timeout = mv643xx_eth_tx_timeout;
+#ifdef MV643XX_NAPI
+	dev->poll = mv643xx_poll;
+	dev->weight = 64;
 #endif
 
 	dev->watchdog_timeo = 2 * HZ;
-	dev->tx_queue_len = MV64340_TX_QUEUE_SIZE;
+	dev->tx_queue_len = mp->tx_ring_size;
 	dev->base_addr = 0;
-	dev->change_mtu = mv64340_eth_change_mtu;
+	dev->change_mtu = mv643xx_eth_change_mtu;
+	SET_ETHTOOL_OPS(dev, &mv643xx_ethtool_ops);
 
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 #ifdef MAX_SKB_FRAGS
-        /*
-         * Zero copy can only work if we use Discovery II memory. Else, we will
-         * have to map the buffers to ISA memory which is only 16 MB
-         */
-        dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_HW_CSUM;
+	/*
+	 * Zero copy can only work if we use Discovery II memory. Else, we will
+	 * have to map the buffers to ISA memory which is only 16 MB
+	 */
+	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_HW_CSUM;
 #endif
 #endif
 
-	mp->port_num = port_num;
-
 	/* Configure the timeout task */
-        INIT_WORK(&mp->tx_timeout_task,
-                  (void (*)(void *))mv64340_eth_tx_timeout_task, dev);
+	INIT_WORK(&mp->tx_timeout_task,
+			(void (*)(void *))mv643xx_eth_tx_timeout_task, dev);
 
 	spin_lock_init(&mp->lock);
 
-	/* set MAC addresses */
-	memcpy(dev->dev_addr, prom_mac_addr_base, 6);
-	dev->dev_addr[5] += port_num;
+	/* set default config values */
+	eth_port_uc_addr_get(dev, dev->dev_addr);
+	mp->port_config = MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE;
+	mp->port_config_extend = MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE;
+	mp->port_sdma_config = MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE;
+	mp->port_serial_control = MV643XX_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE;
+	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
+	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
+
+	pd = pdev->dev.platform_data;
+	if (pd) {
+		if (pd->mac_addr != NULL)
+			memcpy(dev->dev_addr, pd->mac_addr, 6);
+
+		if (pd->phy_addr || pd->force_phy_addr)
+			ethernet_phy_set(port_num, pd->phy_addr);
+
+		if (pd->port_config || pd->force_port_config)
+			mp->port_config = pd->port_config;
+
+		if (pd->port_config_extend || pd->force_port_config_extend)
+			mp->port_config_extend = pd->port_config_extend;
+
+		if (pd->port_sdma_config || pd->force_port_sdma_config)
+			mp->port_sdma_config = pd->port_sdma_config;
+
+		if (pd->port_serial_control || pd->force_port_serial_control)
+			mp->port_serial_control = pd->port_serial_control;
+
+		if (pd->rx_queue_size)
+			mp->rx_ring_size = pd->rx_queue_size;
+
+		if (pd->tx_queue_size)
+			mp->tx_ring_size = pd->tx_queue_size;
+
+		if (pd->tx_sram_size) {
+			mp->tx_sram_size = pd->tx_sram_size;
+			mp->tx_sram_addr = pd->tx_sram_addr;
+		}
+
+		if (pd->rx_sram_size) {
+			mp->rx_sram_size = pd->rx_sram_size;
+			mp->rx_sram_addr = pd->rx_sram_addr;
+		}
+	}
+
+	err = ethernet_phy_detect(port_num);
+	if (err) {
+		pr_debug("MV643xx ethernet port %d: "
+					"No PHY detected at addr %d\n",
+					port_num, ethernet_phy_get(port_num));
+		return err;
+	}
 
 	err = register_netdev(dev);
 	if (err)
-		goto out_free_dev;
+		goto out;
 
-	printk(KERN_NOTICE "%s: port %d with MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
-		dev->name, port_num,
-		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	p = dev->dev_addr;
+	printk(KERN_NOTICE
+		"%s: port %d with MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
+		dev->name, port_num, p[0], p[1], p[2], p[3], p[4], p[5]);
 
 	if (dev->features & NETIF_F_SG)
-		printk("Scatter Gather Enabled  ");
+		printk(KERN_NOTICE "%s: Scatter Gather Enabled\n", dev->name);
 
 	if (dev->features & NETIF_F_IP_CSUM)
-		printk("TX TCP/IP Checksumming Supported  \n");
+		printk(KERN_NOTICE "%s: TX TCP/IP Checksumming Supported\n",
+								dev->name);
+
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+	printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON \n", dev->name);
+#endif
 
-	printk("RX TCP/UDP Checksum Offload ON, \n");
-	printk("TX and RX Interrupt Coalescing ON \n");
+#ifdef MV643XX_COAL
+	printk(KERN_NOTICE "%s: TX and RX Interrupt Coalescing ON \n",
+								dev->name);
+#endif
 
-#ifdef MV64340_NAPI
-	printk("RX NAPI Enabled \n");
+#ifdef MV643XX_NAPI
+	printk(KERN_NOTICE "%s: RX NAPI Enabled \n", dev->name);
 #endif
 
-	return dev;
+	return 0;
 
-out_free_dev:
+out:
 	free_netdev(dev);
 
-	return NULL;
+	return err;
 }
 
-static void mv64340_eth_remove(struct net_device *dev)
+static int mv643xx_eth_remove(struct device *ddev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct net_device *dev = dev_get_drvdata(ddev);
 
 	unregister_netdev(dev);
 	flush_scheduled_work();
+
 	free_netdev(dev);
+	dev_set_drvdata(ddev, NULL);
+	return 0;
+}
+
+static int mv643xx_eth_shared_probe(struct device *ddev)
+{
+	struct platform_device *pdev = to_platform_device(ddev);
+	struct resource *res;
+
+	printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res == NULL)
+		return -ENODEV;
+
+	mv643xx_eth_shared_base = ioremap(res->start,
+						MV643XX_ETH_SHARED_REGS_SIZE);
+	if (mv643xx_eth_shared_base == NULL)
+		return -ENOMEM;
+
+	return 0;
+
+}
+
+static int mv643xx_eth_shared_remove(struct device *ddev)
+{
+	iounmap(mv643xx_eth_shared_base);
+	mv643xx_eth_shared_base = NULL;
+
+	return 0;
 }
 
-static struct net_device *mv64340_dev0;
-static struct net_device *mv64340_dev1;
-static struct net_device *mv64340_dev2;
+static struct device_driver mv643xx_eth_driver = {
+	.name = MV643XX_ETH_NAME,
+	.bus = &platform_bus_type,
+	.probe = mv643xx_eth_probe,
+	.remove = mv643xx_eth_remove,
+};
+
+static struct device_driver mv643xx_eth_shared_driver = {
+	.name = MV643XX_ETH_SHARED_NAME,
+	.bus = &platform_bus_type,
+	.probe = mv643xx_eth_shared_probe,
+	.remove = mv643xx_eth_shared_remove,
+};
 
 /*
- * mv64340_init_module
+ * mv643xx_init_module
  *
  * Registers the network drivers into the Linux kernel
  *
- * Input : N/A
+ * Input :	N/A
  *
- * Output : N/A
+ * Output :	N/A
  */
-static int __init mv64340_init_module(void)
+static int __init mv643xx_init_module(void)
 {
-	printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+	int rc;
 
-#ifdef CONFIG_MV643XX_ETH_0
-	mv64340_dev0 = mv64340_eth_init(0);
-	if (!mv64340_dev0) {
-		printk(KERN_ERR
-		       "Error registering MV-64360 ethernet port 0\n");
-	}
-#endif
-#ifdef CONFIG_MV643XX_ETH_1
-	mv64340_dev1 = mv64340_eth_init(1);
-	if (!mv64340_dev1) {
-		printk(KERN_ERR
-		       "Error registering MV-64360 ethernet port 1\n");
-	}
-#endif
-#ifdef CONFIG_MV643XX_ETH_2
-	mv64340_dev2 = mv64340_eth_init(2);
-	if (!mv64340_dev2) {
-		printk(KERN_ERR
-		       "Error registering MV-64360 ethernet port 2\n");
+	rc = driver_register(&mv643xx_eth_shared_driver);
+	if (!rc) {
+		rc = driver_register(&mv643xx_eth_driver);
+		if (rc)
+			driver_unregister(&mv643xx_eth_shared_driver);
 	}
-#endif
-	return 0;
+	return rc;
 }
 
 /*
- * mv64340_cleanup_module
+ * mv643xx_cleanup_module
  *
  * Registers the network drivers into the Linux kernel
  *
- * Input : N/A
+ * Input :	N/A
  *
- * Output : N/A
+ * Output :	N/A
  */
-static void __exit mv64340_cleanup_module(void)
+static void __exit mv643xx_cleanup_module(void)
 {
-	if (mv64340_dev2)
-		mv64340_eth_remove(mv64340_dev2);
-	if (mv64340_dev1)
-		mv64340_eth_remove(mv64340_dev1);
-	if (mv64340_dev0)
-		mv64340_eth_remove(mv64340_dev0);
+	driver_unregister(&mv643xx_eth_driver);
+	driver_unregister(&mv643xx_eth_shared_driver);
 }
 
-module_init(mv64340_init_module);
-module_exit(mv64340_cleanup_module);
+module_init(mv643xx_init_module);
+module_exit(mv643xx_cleanup_module);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm and Manish Lachwani");
-MODULE_DESCRIPTION("Ethernet driver for Marvell MV64340");
+MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
+		" and Dale Farnsworth");
+MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
 
 /*
- *  The second part is the low level driver of the gigE ethernet ports.
+ * The second part is the low level driver of the gigE ethernet ports.
  */
 
 /*
  * Marvell's Gigabit Ethernet controller low level driver
  *
  * DESCRIPTION:
- *       This file introduce low level API to Marvell's Gigabit Ethernet
+ *	This file introduce low level API to Marvell's Gigabit Ethernet
  *		controller. This Gigabit Ethernet Controller driver API controls
  *		1) Operations (i.e. port init, start, reset etc').
  *		2) Data flow (i.e. port send, receive etc').
  *		Each Gigabit Ethernet port is controlled via
- *              struct mv64340_private.
+ *		struct mv643xx_private.
  *		This struct includes user configuration information as well as
  *		driver internal data needed for its operations.
  *
- *		Supported Features:  
+ *		Supported Features:
  *		- This low level driver is OS independent. Allocating memory for
  *		  the descriptor rings and buffers are not within the scope of
  *		  this driver.
@@ -1509,12 +1645,12 @@
  *		- PHY access and control API.
  *		- Port control register configuration API.
  *		- Full control over Unicast and Multicast MAC configurations.
- *								   
+ *
  *		Operation flow:
  *
  *		Initialization phase
- *		This phase complete the initialization of the the mv64340_private
- *		struct. 
+ *		This phase complete the initialization of the the
+ *		mv643xx_private struct.
  *		User information regarding port configuration has to be set
  *		prior to calling the port initialization routine.
  *
@@ -1523,7 +1659,7 @@
  *		access to DRAM and internal SRAM memory spaces.
  *
  *		Driver ring initialization
- *		Allocating memory for the descriptor rings and buffers is not 
+ *		Allocating memory for the descriptor rings and buffers is not
  *		within the scope of this driver. Thus, the user is required to
  *		allocate memory for the descriptors ring and buffers. Those
  *		memory parameters are used by the Rx and Tx ring initialization
@@ -1531,49 +1667,50 @@
  *		of a ring.
  *		Note: Pay special attention to alignment issues when using
  *		cached descriptors/buffers. In this phase the driver store
- *		information in the mv64340_private struct regarding each queue
+ *		information in the mv643xx_private struct regarding each queue
  *		ring.
  *
- *		Driver start 
+ *		Driver start
  *		This phase prepares the Ethernet port for Rx and Tx activity.
- *		It uses the information stored in the mv64340_private struct to 
+ *		It uses the information stored in the mv643xx_private struct to
  *		initialize the various port registers.
  *
  *		Data flow:
  *		All packet references to/from the driver are done using
- *              struct pkt_info.
- *		This struct is a unified struct used with Rx and Tx operations. 
+ *		struct pkt_info.
+ *		This struct is a unified struct used with Rx and Tx operations.
  *		This way the user is not required to be familiar with neither
  *		Tx nor Rx descriptors structures.
  *		The driver's descriptors rings are management by indexes.
  *		Those indexes controls the ring resources and used to indicate
  *		a SW resource error:
- *		'current' 
- *		This index points to the current available resource for use. For 
- *		example in Rx process this index will point to the descriptor  
- *		that will be passed to the user upon calling the receive routine.
- *		In Tx process, this index will point to the descriptor
+ *		'current'
+ *		This index points to the current available resource for use. For
+ *		example in Rx process this index will point to the descriptor
+ *		that will be passed to the user upon calling the receive
+ *		routine.  In Tx process, this index will point to the descriptor
  *		that will be assigned with the user packet info and transmitted.
- *		'used'    
- *		This index points to the descriptor that need to restore its 
+ *		'used'
+ *		This index points to the descriptor that need to restore its
  *		resources. For example in Rx process, using the Rx buffer return
  *		API will attach the buffer returned in packet info to the
  *		descriptor pointed by 'used'. In Tx process, using the Tx
  *		descriptor return will merely return the user packet info with
- *		the command status of  the transmitted buffer pointed by the
+ *		the command status of the transmitted buffer pointed by the
  *		'used' index. Nevertheless, it is essential to use this routine
  *		to update the 'used' index.
  *		'first'
- *		This index supports Tx Scatter-Gather. It points to the first 
- *		descriptor of a packet assembled of multiple buffers. For example
- *		when in middle of Such packet we have a Tx resource error the 
- *		'curr' index get the value of 'first' to indicate that the ring 
- *		returned to its state before trying to transmit this packet.
+ *		This index supports Tx Scatter-Gather. It points to the first
+ *		descriptor of a packet assembled of multiple buffers. For
+ *		example when in middle of Such packet we have a Tx resource
+ *		error the 'curr' index get the value of 'first' to indicate
+ *		that the ring returned to its state before trying to transmit
+ *		this packet.
  *
  *		Receive operation:
  *		The eth_port_receive API set the packet information struct,
- *		passed by the caller, with received information from the 
- *		'current' SDMA descriptor. 
+ *		passed by the caller, with received information from the
+ *		'current' SDMA descriptor.
  *		It is the user responsibility to return this resource back
  *		to the Rx descriptor ring to enable the reuse of this source.
  *		Return Rx resource is done using the eth_rx_return_buff API.
@@ -1594,27 +1731,21 @@
  *
  *		EXTERNAL INTERFACE
  *
- *       Prior to calling the initialization routine eth_port_init() the user
- *	 must set the following fields under mv64340_private struct:
- *       port_num             User Ethernet port number.
- *       port_mac_addr[6]	    User defined port MAC address.
- *       port_config          User port configuration value.
- *       port_config_extend    User port config extend value.
- *       port_sdma_config      User port SDMA config value.
- *       port_serial_control   User port serial control value.
- *
- *       This driver introduce a set of default values:
- *       PORT_CONFIG_VALUE           Default port configuration value
- *       PORT_CONFIG_EXTEND_VALUE    Default port extend configuration value
- *       PORT_SDMA_CONFIG_VALUE      Default sdma control value
- *       PORT_SERIAL_CONTROL_VALUE   Default port serial control value
+ *	Prior to calling the initialization routine eth_port_init() the user
+ *	must set the following fields under mv643xx_private struct:
+ *	port_num		User Ethernet port number.
+ *	port_mac_addr[6]	User defined port MAC address.
+ *	port_config		User port configuration value.
+ *	port_config_extend	User port config extend value.
+ *	port_sdma_config	User port SDMA config value.
+ *	port_serial_control	User port serial control value.
  *
  *		This driver data flow is done using the struct pkt_info which
- *              is a unified struct for Rx and Tx operations:
+ *		is a unified struct for Rx and Tx operations:
  *
  *		byte_cnt	Tx/Rx descriptor buffer byte count.
  *		l4i_chk		CPU provided TCP Checksum. For Tx operation
- *                              only.
+ *				only.
  *		cmd_sts		Tx/Rx descriptor command status.
  *		buf_ptr		Tx/Rx descriptor buffer pointer.
  *		return_info	Tx/Rx user resource return information.
@@ -1623,70 +1754,44 @@
 /* defines */
 /* SDMA command macros */
 #define ETH_ENABLE_TX_QUEUE(eth_port) \
-	MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port), 1)
-
-#define ETH_DISABLE_TX_QUEUE(eth_port) \
-	MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port),	\
-	         (1 << 8))
-
-#define ETH_ENABLE_RX_QUEUE(rx_queue, eth_port) \
-	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(eth_port),	\
-	         (1 << rx_queue))
-
-#define ETH_DISABLE_RX_QUEUE(rx_queue, eth_port) \
-	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(eth_port),	\
-	         (1 << (8 + rx_queue)))
-
-#define LINK_UP_TIMEOUT		100000
-#define PHY_BUSY_TIMEOUT	10000000
+	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port), 1)
 
 /* locals */
 
 /* PHY routines */
 static int ethernet_phy_get(unsigned int eth_port_num);
+static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
 
 /* Ethernet Port routines */
 static int eth_port_uc_addr(unsigned int eth_port_num, unsigned char uc_nibble,
-	int option);
+								int option);
 
 /*
  * eth_port_init - Initialize the Ethernet port driver
  *
  * DESCRIPTION:
- *       This function prepares the ethernet port to start its activity:
- *       1) Completes the ethernet port driver struct initialization toward port
- *           start routine.
- *       2) Resets the device to a quiescent state in case of warm reboot.
- *       3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
- *       4) Clean MAC tables. The reset status of those tables is unknown.
- *       5) Set PHY address. 
- *       Note: Call this routine prior to eth_port_start routine and after
- *       setting user values in the user fields of Ethernet port control
- *       struct.
+ *	This function prepares the ethernet port to start its activity:
+ *	1) Completes the ethernet port driver struct initialization toward port
+ *		start routine.
+ *	2) Resets the device to a quiescent state in case of warm reboot.
+ *	3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
+ *	4) Clean MAC tables. The reset status of those tables is unknown.
+ *	5) Set PHY address.
+ *	Note: Call this routine prior to eth_port_start routine and after
+ *	setting user values in the user fields of Ethernet port control
+ *	struct.
  *
  * INPUT:
- *       struct mv64340_private *mp   Ethernet port control struct
+ *	struct mv643xx_private *mp	Ethernet port control struct
  *
  * OUTPUT:
- *       See description.
+ *	See description.
  *
  * RETURN:
- *       None.
+ *	None.
  */
-static void eth_port_init(struct mv64340_private * mp)
+static void eth_port_init(struct mv643xx_private *mp)
 {
-	mp->port_config = PORT_CONFIG_VALUE;
-	mp->port_config_extend = PORT_CONFIG_EXTEND_VALUE;
-#if defined(__BIG_ENDIAN)
-	mp->port_sdma_config = PORT_SDMA_CONFIG_VALUE;
-#elif defined(__LITTLE_ENDIAN)
-	mp->port_sdma_config = PORT_SDMA_CONFIG_VALUE |
-		ETH_BLM_RX_NO_SWAP | ETH_BLM_TX_NO_SWAP;
-#else
-#error One of __LITTLE_ENDIAN or __BIG_ENDIAN must be defined!
-#endif
-	mp->port_serial_control = PORT_SERIAL_CONTROL_VALUE;
-
 	mp->port_rx_queue_command = 0;
 	mp->port_tx_queue_command = 0;
 
@@ -1704,77 +1809,73 @@
  * eth_port_start - Start the Ethernet port activity.
  *
  * DESCRIPTION:
- *       This routine prepares the Ethernet port for Rx and Tx activity:
- *       1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
- *          has been initialized a descriptor's ring (using
- *          ether_init_tx_desc_ring for Tx and ether_init_rx_desc_ring for Rx)
- *       2. Initialize and enable the Ethernet configuration port by writing to
- *          the port's configuration and command registers.
- *       3. Initialize and enable the SDMA by writing to the SDMA's 
- *          configuration and command registers.  After completing these steps,
- *          the ethernet port SDMA can starts to perform Rx and Tx activities.
+ *	This routine prepares the Ethernet port for Rx and Tx activity:
+ *	 1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
+ *	    has been initialized a descriptor's ring (using
+ *	    ether_init_tx_desc_ring for Tx and ether_init_rx_desc_ring for Rx)
+ *	 2. Initialize and enable the Ethernet configuration port by writing to
+ *	    the port's configuration and command registers.
+ *	 3. Initialize and enable the SDMA by writing to the SDMA's
+ *	    configuration and command registers.  After completing these steps,
+ *	    the ethernet port SDMA can starts to perform Rx and Tx activities.
  *
- *       Note: Each Rx and Tx queue descriptor's list must be initialized prior
- *       to calling this function (use ether_init_tx_desc_ring for Tx queues
- *       and ether_init_rx_desc_ring for Rx queues).
+ *	Note: Each Rx and Tx queue descriptor's list must be initialized prior
+ *	to calling this function (use ether_init_tx_desc_ring for Tx queues
+ *	and ether_init_rx_desc_ring for Rx queues).
  *
  * INPUT:
- *       struct mv64340_private 	*mp   Ethernet port control struct
+ *	struct mv643xx_private *mp	Ethernet port control struct
  *
  * OUTPUT:
- *       Ethernet port is ready to receive and transmit.
+ *	Ethernet port is ready to receive and transmit.
  *
  * RETURN:
- *       false if the port PHY is not up.
- *       true otherwise.
+ *	None.
  */
-static int eth_port_start(struct mv64340_private *mp)
+static void eth_port_start(struct mv643xx_private *mp)
 {
-	unsigned int eth_port_num = mp->port_num;
+	unsigned int port_num = mp->port_num;
 	int tx_curr_desc, rx_curr_desc;
-	unsigned int phy_reg_data;
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
-	MV_WRITE(MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(eth_port_num),
-	         (struct eth_tx_desc *) mp->tx_desc_dma + tx_curr_desc);
+	mv_write(MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
-	MV_WRITE(MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(eth_port_num),
-		 (struct eth_rx_desc *) mp->rx_desc_dma + rx_curr_desc);
+	mv_write(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
-	eth_port_uc_addr_set(mp->port_num, mp->port_mac_addr);
+	eth_port_uc_addr_set(port_num, mp->port_mac_addr);
 
 	/* Assign port configuration and command. */
-	MV_WRITE(MV64340_ETH_PORT_CONFIG_REG(eth_port_num),
-		 mp->port_config);
+	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num), mp->port_config);
 
-	MV_WRITE(MV64340_ETH_PORT_CONFIG_EXTEND_REG(eth_port_num),
-		 mp->port_config_extend);
+	mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
+						mp->port_config_extend);
 
-	MV_WRITE(MV64340_ETH_PORT_SERIAL_CONTROL_REG(eth_port_num),
-		 mp->port_serial_control);
 
-	MV_SET_REG_BITS(MV64340_ETH_PORT_SERIAL_CONTROL_REG(eth_port_num),
-			ETH_SERIAL_PORT_ENABLE);
+	/* Increase the Rx side buffer size if supporting GigE */
+	if (mp->port_serial_control & MV643XX_ETH_SET_GMII_SPEED_TO_1000)
+		mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+			(mp->port_serial_control & 0xfff1ffff) | (0x5 << 17));
+	else
+		mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+						mp->port_serial_control);
+
+	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+		mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num)) |
+						MV643XX_ETH_SERIAL_PORT_ENABLE);
 
 	/* Assign port SDMA configuration */
-	MV_WRITE(MV64340_ETH_SDMA_CONFIG_REG(eth_port_num),
-		 mp->port_sdma_config);
+	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(port_num),
+							mp->port_sdma_config);
 
 	/* Enable port Rx. */
-	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(eth_port_num),
-		 mp->port_rx_queue_command);
-
-	/* Check if link is up */
-	eth_port_read_smi_reg(eth_port_num, 1, &phy_reg_data);
-
-	if (!(phy_reg_data & 0x20))
-		return 0;
-
-	return 1;
+	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
+						mp->port_rx_queue_command);
 }
 
 /*
@@ -1784,29 +1885,29 @@
  *		This function Set the port Ethernet MAC address.
  *
  * INPUT:
- *	unsigned int eth_port_num     Port number.
- *	char *        p_addr		Address to be set 
+ *	unsigned int	eth_port_num	Port number.
+ *	char *		p_addr		Address to be set
  *
  * OUTPUT:
- *	Set MAC address low and high registers. also calls eth_port_uc_addr() 
- *       To set the unicast table with the proper information.
+ *	Set MAC address low and high registers. also calls eth_port_uc_addr()
+ *	To set the unicast table with the proper information.
  *
  * RETURN:
  *	N/A.
  *
  */
 static void eth_port_uc_addr_set(unsigned int eth_port_num,
-				 unsigned char *p_addr)
+							unsigned char *p_addr)
 {
 	unsigned int mac_h;
 	unsigned int mac_l;
 
 	mac_l = (p_addr[4] << 8) | (p_addr[5]);
-	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) |
-	    (p_addr[2] << 8) | (p_addr[3] << 0);
+	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
+							(p_addr[3] << 0);
 
-	MV_WRITE(MV64340_ETH_MAC_ADDR_LOW(eth_port_num), mac_l);
-	MV_WRITE(MV64340_ETH_MAC_ADDR_HIGH(eth_port_num), mac_h);
+	mv_write(MV643XX_ETH_MAC_ADDR_LOW(eth_port_num), mac_l);
+	mv_write(MV643XX_ETH_MAC_ADDR_HIGH(eth_port_num), mac_h);
 
 	/* Accept frames of this address */
 	eth_port_uc_addr(eth_port_num, p_addr[5], ACCEPT_MAC_ADDR);
@@ -1815,29 +1916,64 @@
 }
 
 /*
+ * eth_port_uc_addr_get - This function retrieves the port Unicast address
+ * (MAC address) from the ethernet hw registers.
+ *
+ * DESCRIPTION:
+ *		This function retrieves the port Ethernet MAC address.
+ *
+ * INPUT:
+ *	unsigned int	eth_port_num	Port number.
+ *	char		*MacAddr	pointer where the MAC address is stored
+ *
+ * OUTPUT:
+ *	Copy the MAC address to the location pointed to by MacAddr
+ *
+ * RETURN:
+ *	N/A.
+ *
+ */
+static void eth_port_uc_addr_get(struct net_device *dev, unsigned char *p_addr)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	unsigned int mac_h;
+	unsigned int mac_l;
+
+	mac_h = mv_read(MV643XX_ETH_MAC_ADDR_HIGH(mp->port_num));
+	mac_l = mv_read(MV643XX_ETH_MAC_ADDR_LOW(mp->port_num));
+
+	p_addr[0] = (mac_h >> 24) & 0xff;
+	p_addr[1] = (mac_h >> 16) & 0xff;
+	p_addr[2] = (mac_h >> 8) & 0xff;
+	p_addr[3] = mac_h & 0xff;
+	p_addr[4] = (mac_l >> 8) & 0xff;
+	p_addr[5] = mac_l & 0xff;
+}
+
+/*
  * eth_port_uc_addr - This function Set the port unicast address table
  *
  * DESCRIPTION:
- *	This function locates the proper entry in the Unicast table for the 
- *	specified MAC nibble and sets its properties according to function 
+ *	This function locates the proper entry in the Unicast table for the
+ *	specified MAC nibble and sets its properties according to function
  *	parameters.
  *
  * INPUT:
- *	unsigned int 	eth_port_num      Port number.
- *	unsigned char uc_nibble		Unicast MAC Address last nibble. 
- *	int 			option      0 = Add, 1 = remove address.
+ *	unsigned int	eth_port_num	Port number.
+ *	unsigned char	uc_nibble	Unicast MAC Address last nibble.
+ *	int 		option		0 = Add, 1 = remove address.
  *
  * OUTPUT:
  *	This function add/removes MAC addresses from the port unicast address
- *	table. 
+ *	table.
  *
  * RETURN:
  *	true is output succeeded.
  *	false if option parameter is invalid.
  *
  */
-static int eth_port_uc_addr(unsigned int eth_port_num,
-	unsigned char uc_nibble, int option)
+static int eth_port_uc_addr(unsigned int eth_port_num, unsigned char uc_nibble,
+								int option)
 {
 	unsigned int unicast_reg;
 	unsigned int tbl_offset;
@@ -1850,29 +1986,26 @@
 
 	switch (option) {
 	case REJECT_MAC_ADDR:
-		/* Clear accepts frame bit at specified unicast DA table entry */
-		unicast_reg = MV_READ((MV64340_ETH_DA_FILTER_UNICAST_TABLE_BASE
-				  (eth_port_num) + tbl_offset));
+		/* Clear accepts frame bit at given unicast DA table entry */
+		unicast_reg = mv_read((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+						(eth_port_num) + tbl_offset));
 
 		unicast_reg &= (0x0E << (8 * reg_offset));
 
-		MV_WRITE(
-			 (MV64340_ETH_DA_FILTER_UNICAST_TABLE_BASE
-			  (eth_port_num) + tbl_offset), unicast_reg);
+		mv_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+				(eth_port_num) + tbl_offset), unicast_reg);
 		break;
 
 	case ACCEPT_MAC_ADDR:
 		/* Set accepts frame bit at unicast DA filter table entry */
 		unicast_reg =
-		    MV_READ(
-				 (MV64340_ETH_DA_FILTER_UNICAST_TABLE_BASE
-				  (eth_port_num) + tbl_offset));
+			mv_read((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+						(eth_port_num) + tbl_offset));
 
 		unicast_reg |= (0x01 << (8 * reg_offset));
 
-		MV_WRITE(
-			 (MV64340_ETH_DA_FILTER_UNICAST_TABLE_BASE
-			  (eth_port_num) + tbl_offset), unicast_reg);
+		mv_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+				(eth_port_num) + tbl_offset), unicast_reg);
 
 		break;
 
@@ -1887,17 +2020,17 @@
  * eth_port_init_mac_tables - Clear all entrance in the UC, SMC and OMC tables
  *
  * DESCRIPTION:
- *       Go through all the DA filter tables (Unicast, Special Multicast &
- *       Other Multicast) and set each entry to 0.
+ *	Go through all the DA filter tables (Unicast, Special Multicast &
+ *	Other Multicast) and set each entry to 0.
  *
  * INPUT:
- *	unsigned int    eth_port_num   Ethernet Port number.
+ *	unsigned int	eth_port_num	Ethernet Port number.
  *
  * OUTPUT:
- *       Multicast and Unicast packets are rejected.
+ *	Multicast and Unicast packets are rejected.
  *
  * RETURN:
- *       None.
+ *	None.
  */
 static void eth_port_init_mac_tables(unsigned int eth_port_num)
 {
@@ -1905,18 +2038,16 @@
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		MV_WRITE(
-			 (MV64340_ETH_DA_FILTER_UNICAST_TABLE_BASE
-			  (eth_port_num) + table_index), 0);
+		mv_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+					(eth_port_num) + table_index), 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		MV_WRITE(
-			 (MV64340_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
-			  (eth_port_num) + table_index), 0);
+		mv_write((MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+					(eth_port_num) + table_index), 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		MV_WRITE((MV64340_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
-			  (eth_port_num) + table_index), 0);
+		mv_write((MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
+					(eth_port_num) + table_index), 0);
 	}
 }
 
@@ -1924,17 +2055,17 @@
  * eth_clear_mib_counters - Clear all MIB counters
  *
  * DESCRIPTION:
- *       This function clears all MIB counters of a specific ethernet port.
- *       A read from the MIB counter will reset the counter.
+ *	This function clears all MIB counters of a specific ethernet port.
+ *	A read from the MIB counter will reset the counter.
  *
  * INPUT:
- *	unsigned int    eth_port_num   Ethernet Port number.
+ *	unsigned int	eth_port_num	Ethernet Port number.
  *
  * OUTPUT:
- *       After reading all MIB counters, the counters resets.
+ *	After reading all MIB counters, the counters resets.
  *
  * RETURN:
- *       MIB counter value.
+ *	MIB counter value.
  *
  */
 static void eth_clear_mib_counters(unsigned int eth_port_num)
@@ -1942,72 +2073,155 @@
 	int i;
 
 	/* Perform dummy reads from MIB counters */
-	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION; i += 4)
-		MV_READ(MV64340_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
+	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
+									i += 4)
+		mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
+}
+
+static inline u32 read_mib(struct mv643xx_private *mp, int offset)
+{
+	return mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) + offset);
 }
 
+static void eth_update_mib_counters(struct mv643xx_private *mp)
+{
+	struct mv643xx_mib_counters *p = &mp->mib_counters;
+	int offset;
+
+	p->good_octets_received +=
+		read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
+	p->good_octets_received +=
+		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
+
+	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
+			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
+			offset += 4)
+		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+
+	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
+	p->good_octets_sent +=
+		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
+
+	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
+			offset <= ETH_MIB_LATE_COLLISION;
+			offset += 4)
+		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+}
+
+/*
+ * ethernet_phy_detect - Detect whether a phy is present
+ *
+ * DESCRIPTION:
+ *	This function tests whether there is a PHY present on
+ *	the specified port.
+ *
+ * INPUT:
+ *	unsigned int	eth_port_num	Ethernet Port number.
+ *
+ * OUTPUT:
+ *	None
+ *
+ * RETURN:
+ *	0 on success
+ *	-ENODEV on failure
+ *
+ */
+static int ethernet_phy_detect(unsigned int port_num)
+{
+	unsigned int phy_reg_data0;
+	int auto_neg;
+
+	eth_port_read_smi_reg(port_num, 0, &phy_reg_data0);
+	auto_neg = phy_reg_data0 & 0x1000;
+	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
+	eth_port_write_smi_reg(port_num, 0, phy_reg_data0);
+
+	eth_port_read_smi_reg(port_num, 0, &phy_reg_data0);
+	if ((phy_reg_data0 & 0x1000) == auto_neg)
+		return -ENODEV;				/* change didn't take */
+
+	phy_reg_data0 ^= 0x1000;
+	eth_port_write_smi_reg(port_num, 0, phy_reg_data0);
+	return 0;
+}
 
 /*
  * ethernet_phy_get - Get the ethernet port PHY address.
  *
  * DESCRIPTION:
- *       This routine returns the given ethernet port PHY address.
+ *	This routine returns the given ethernet port PHY address.
  *
  * INPUT:
- *		unsigned int   eth_port_num   Ethernet Port number.
+ *	unsigned int	eth_port_num	Ethernet Port number.
  *
  * OUTPUT:
- *       None.
+ *	None.
  *
  * RETURN:
- *       PHY address.
+ *	PHY address.
  *
  */
 static int ethernet_phy_get(unsigned int eth_port_num)
 {
 	unsigned int reg_data;
 
-	reg_data = MV_READ(MV64340_ETH_PHY_ADDR_REG);
+	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
 
 	return ((reg_data >> (5 * eth_port_num)) & 0x1f);
 }
 
 /*
+ * ethernet_phy_set - Set the ethernet port PHY address.
+ *
+ * DESCRIPTION:
+ *	This routine sets the given ethernet port PHY address.
+ *
+ * INPUT:
+ *	unsigned int	eth_port_num	Ethernet Port number.
+ *	int		phy_addr	PHY address.
+ *
+ * OUTPUT:
+ *	None.
+ *
+ * RETURN:
+ *	None.
+ *
+ */
+static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr)
+{
+	u32 reg_data;
+	int addr_shift = 5 * eth_port_num;
+
+	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
+	reg_data &= ~(0x1f << addr_shift);
+	reg_data |= (phy_addr & 0x1f) << addr_shift;
+	mv_write(MV643XX_ETH_PHY_ADDR_REG, reg_data);
+}
+
+/*
  * ethernet_phy_reset - Reset Ethernet port PHY.
  *
  * DESCRIPTION:
- *       This routine utilize the SMI interface to reset the ethernet port PHY.
- *       The routine waits until the link is up again or link up is timeout.
+ *	This routine utilizes the SMI interface to reset the ethernet port PHY.
  *
  * INPUT:
- *	unsigned int   eth_port_num   Ethernet Port number.
+ *	unsigned int	eth_port_num	Ethernet Port number.
  *
  * OUTPUT:
- *       The ethernet port PHY renew its link.
+ *	The PHY is reset.
  *
  * RETURN:
- *       None.
+ *	None.
  *
  */
-static int ethernet_phy_reset(unsigned int eth_port_num)
+static void ethernet_phy_reset(unsigned int eth_port_num)
 {
-	unsigned int time_out = 50;
 	unsigned int phy_reg_data;
 
 	/* Reset the PHY */
 	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data);
 	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
 	eth_port_write_smi_reg(eth_port_num, 0, phy_reg_data);
-
-	/* Poll on the PHY LINK */
-	do {
-		eth_port_read_smi_reg(eth_port_num, 1, &phy_reg_data);
-
-		if (time_out-- == 0)
-			return 0;
-	} while (!(phy_reg_data & 0x20));
-
-	return 1;
 }
 
 /*
@@ -2015,381 +2229,358 @@
  *
  * DESCRIPTION:
  * 	This routine resets the chip by aborting any SDMA engine activity and
- *      clearing the MIB counters. The Receiver and the Transmit unit are in 
- *      idle state after this command is performed and the port is disabled.
+ *	clearing the MIB counters. The Receiver and the Transmit unit are in
+ *	idle state after this command is performed and the port is disabled.
  *
  * INPUT:
- *	unsigned int   eth_port_num   Ethernet Port number.
+ *	unsigned int	eth_port_num	Ethernet Port number.
  *
  * OUTPUT:
- *       Channel activity is halted.
+ *	Channel activity is halted.
  *
  * RETURN:
- *       None.
+ *	None.
  *
  */
-static void eth_port_reset(unsigned int eth_port_num)
+static void eth_port_reset(unsigned int port_num)
 {
 	unsigned int reg_data;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	reg_data =
-	    MV_READ(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port_num));
+	reg_data = mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num));
 
 	if (reg_data & 0xFF) {
 		/* Issue stop command for active channels only */
-		MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG
-			 (eth_port_num), (reg_data << 8));
+		mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
+							(reg_data << 8));
 
 		/* Wait for all Tx activity to terminate. */
-		do {
-			/* Check port cause register that all Tx queues are stopped */
-			reg_data =
-			    MV_READ
-			    (MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG
-			     (eth_port_num));
-		}
-		while (reg_data & 0xFF);
+		/* Check port cause register that all Tx queues are stopped */
+		while (mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
+									& 0xFF)
+			udelay(10);
 	}
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	reg_data =
-	    MV_READ(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG
-			 (eth_port_num));
+	reg_data = mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num));
 
 	if (reg_data & 0xFF) {
 		/* Issue stop command for active channels only */
-		MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG
-			 (eth_port_num), (reg_data << 8));
+		mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
+							(reg_data << 8));
 
 		/* Wait for all Rx activity to terminate. */
-		do {
-			/* Check port cause register that all Rx queues are stopped */
-			reg_data =
-			    MV_READ
-			    (MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG
-			     (eth_port_num));
-		}
-		while (reg_data & 0xFF);
+		/* Check port cause register that all Rx queues are stopped */
+		while (mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
+									& 0xFF)
+			udelay(10);
 	}
 
-
 	/* Clear all MIB counters */
-	eth_clear_mib_counters(eth_port_num);
+	eth_clear_mib_counters(port_num);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data =
-	    MV_READ(MV64340_ETH_PORT_SERIAL_CONTROL_REG (eth_port_num));
-	reg_data &= ~ETH_SERIAL_PORT_ENABLE;
-	MV_WRITE(MV64340_ETH_PORT_SERIAL_CONTROL_REG(eth_port_num), reg_data);
-
-	return;
+	reg_data = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data &= ~MV643XX_ETH_SERIAL_PORT_ENABLE;
+	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
 }
 
 /*
  * ethernet_set_config_reg - Set specified bits in configuration register.
  *
  * DESCRIPTION:
- *       This function sets specified bits in the given ethernet 
- *       configuration register. 
+ *	This function sets specified bits in the given ethernet
+ *	configuration register.
  *
  * INPUT:
- *	unsigned int   eth_port_num   Ethernet Port number.
- *      unsigned int    value   32 bit value.
+ *	unsigned int	eth_port_num	Ethernet Port number.
+ *	unsigned int	value		32 bit value.
  *
  * OUTPUT:
- *      The set bits in the value parameter are set in the configuration 
- *      register.
+ *	The set bits in the value parameter are set in the configuration
+ *	register.
  *
  * RETURN:
- *      None.
+ *	None.
  *
  */
 static void ethernet_set_config_reg(unsigned int eth_port_num,
-				    unsigned int value)
+							unsigned int value)
 {
 	unsigned int eth_config_reg;
 
-	eth_config_reg =
-	    MV_READ(MV64340_ETH_PORT_CONFIG_REG(eth_port_num));
+	eth_config_reg = mv_read(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num));
 	eth_config_reg |= value;
-	MV_WRITE(MV64340_ETH_PORT_CONFIG_REG(eth_port_num),
-		 eth_config_reg);
+	mv_write(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num), eth_config_reg);
+}
+
+static int eth_port_autoneg_supported(unsigned int eth_port_num)
+{
+	unsigned int phy_reg_data0;
+
+	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data0);
+
+	return phy_reg_data0 & 0x1000;
+}
+
+static int eth_port_link_is_up(unsigned int eth_port_num)
+{
+	unsigned int phy_reg_data1;
+
+	eth_port_read_smi_reg(eth_port_num, 1, &phy_reg_data1);
+
+	if (eth_port_autoneg_supported(eth_port_num)) {
+		if (phy_reg_data1 & 0x20)	/* auto-neg complete */
+			return 1;
+	} else if (phy_reg_data1 & 0x4)		/* link up */
+		return 1;
+
+	return 0;
 }
 
 /*
  * ethernet_get_config_reg - Get the port configuration register
  *
  * DESCRIPTION:
- *       This function returns the configuration register value of the given 
- *       ethernet port.
+ *	This function returns the configuration register value of the given
+ *	ethernet port.
  *
  * INPUT:
- *	unsigned int   eth_port_num   Ethernet Port number.
+ *	unsigned int	eth_port_num	Ethernet Port number.
  *
  * OUTPUT:
- *       None.
+ *	None.
  *
  * RETURN:
- *       Port configuration register value.
+ *	Port configuration register value.
  */
 static unsigned int ethernet_get_config_reg(unsigned int eth_port_num)
 {
 	unsigned int eth_config_reg;
 
-	eth_config_reg = MV_READ(MV64340_ETH_PORT_CONFIG_EXTEND_REG
-				      (eth_port_num));
+	eth_config_reg = mv_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG
+								(eth_port_num));
 	return eth_config_reg;
 }
 
-
 /*
  * eth_port_read_smi_reg - Read PHY registers
  *
  * DESCRIPTION:
- *       This routine utilize the SMI interface to interact with the PHY in 
- *       order to perform PHY register read.
+ *	This routine utilize the SMI interface to interact with the PHY in
+ *	order to perform PHY register read.
  *
  * INPUT:
- *	unsigned int   eth_port_num   Ethernet Port number.
- *       unsigned int   phy_reg   PHY register address offset.
- *       unsigned int   *value   Register value buffer.
+ *	unsigned int	port_num	Ethernet Port number.
+ *	unsigned int	phy_reg		PHY register address offset.
+ *	unsigned int	*value		Register value buffer.
  *
  * OUTPUT:
- *       Write the value of a specified PHY register into given buffer.
+ *	Write the value of a specified PHY register into given buffer.
  *
  * RETURN:
- *       false if the PHY is busy or read data is not in valid state.
- *       true otherwise.
+ *	false if the PHY is busy or read data is not in valid state.
+ *	true otherwise.
  *
  */
-static int eth_port_read_smi_reg(unsigned int eth_port_num,
-	unsigned int phy_reg, unsigned int *value)
+static void eth_port_read_smi_reg(unsigned int port_num,
+				unsigned int phy_reg, unsigned int *value)
 {
-	int phy_addr = ethernet_phy_get(eth_port_num);
-	unsigned int time_out = PHY_BUSY_TIMEOUT;
-	unsigned int reg_value;
-
-	/* first check that it is not busy */
-	do {
-		reg_value = MV_READ(MV64340_ETH_SMI_REG);
-		if (time_out-- == 0)
-			return 0;
-	} while (reg_value & ETH_SMI_BUSY);
-
-	/* not busy */
-
-	MV_WRITE(MV64340_ETH_SMI_REG,
-		 (phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
-
-	time_out = PHY_BUSY_TIMEOUT;	/* initialize the time out var again */
+	int phy_addr = ethernet_phy_get(port_num);
+	unsigned long flags;
+	int i;
 
-	do {
-		reg_value = MV_READ(MV64340_ETH_SMI_REG);
-		if (time_out-- == 0)
-			return 0;
-	} while (reg_value & ETH_SMI_READ_VALID);
+	/* the SMI register is a shared resource */
+	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
-	/* Wait for the data to update in the SMI register */
-	for (time_out = 0; time_out < PHY_BUSY_TIMEOUT; time_out++);
+	/* wait for the SMI register to become available */
+	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("mv643xx PHY busy timeout, port %d\n", port_num);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
 
-	reg_value = MV_READ(MV64340_ETH_SMI_REG);
+	mv_write(MV643XX_ETH_SMI_REG,
+		(phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
 
-	*value = reg_value & 0xffff;
+	/* now wait for the data to be valid */
+	for (i = 0; !(mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("mv643xx PHY read timeout, port %d\n", port_num);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
 
-	return 1;
+	*value = mv_read(MV643XX_ETH_SMI_REG) & 0xffff;
+out:
+	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
 
 /*
  * eth_port_write_smi_reg - Write to PHY registers
  *
  * DESCRIPTION:
- *       This routine utilize the SMI interface to interact with the PHY in 
- *       order to perform writes to PHY registers.
+ *	This routine utilize the SMI interface to interact with the PHY in
+ *	order to perform writes to PHY registers.
  *
  * INPUT:
- *	unsigned int   eth_port_num   Ethernet Port number.
- *      unsigned int   phy_reg   PHY register address offset.
- *      unsigned int    value   Register value.
+ *	unsigned int	eth_port_num	Ethernet Port number.
+ *	unsigned int	phy_reg		PHY register address offset.
+ *	unsigned int	value		Register value.
  *
  * OUTPUT:
- *      Write the given value to the specified PHY register.
+ *	Write the given value to the specified PHY register.
  *
  * RETURN:
- *      false if the PHY is busy.
- *      true otherwise.
+ *	false if the PHY is busy.
+ *	true otherwise.
  *
  */
-static int eth_port_write_smi_reg(unsigned int eth_port_num,
-	unsigned int phy_reg, unsigned int value)
+static void eth_port_write_smi_reg(unsigned int eth_port_num,
+				   unsigned int phy_reg, unsigned int value)
 {
-	unsigned int time_out = PHY_BUSY_TIMEOUT;
-	unsigned int reg_value;
 	int phy_addr;
+	int i;
+	unsigned long flags;
 
 	phy_addr = ethernet_phy_get(eth_port_num);
 
-	/* first check that it is not busy */
-	do {
-		reg_value = MV_READ(MV64340_ETH_SMI_REG);
-		if (time_out-- == 0)
-			return 0;
-	} while (reg_value & ETH_SMI_BUSY);
-
-	/* not busy */
-	MV_WRITE(MV64340_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
-		 ETH_SMI_OPCODE_WRITE | (value & 0xffff));
+	/* the SMI register is a shared resource */
+	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
-	return 1;
+	/* wait for the SMI register to become available */
+	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("mv643xx PHY busy timeout, port %d\n",
+								eth_port_num);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
+
+	mv_write(MV643XX_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
+				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
+out:
+	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
 
 /*
  * eth_port_send - Send an Ethernet packet
  *
  * DESCRIPTION:
- *	This routine send a given packet described by p_pktinfo parameter. It 
- *      supports transmitting of a packet spaned over multiple buffers. The 
- *      routine updates 'curr' and 'first' indexes according to the packet 
- *      segment passed to the routine. In case the packet segment is first, 
- *      the 'first' index is update. In any case, the 'curr' index is updated. 
- *      If the routine get into Tx resource error it assigns 'curr' index as 
- *      'first'. This way the function can abort Tx process of multiple 
- *      descriptors per packet.
+ *	This routine send a given packet described by p_pktinfo parameter. It
+ *	supports transmitting of a packet spaned over multiple buffers. The
+ *	routine updates 'curr' and 'first' indexes according to the packet
+ *	segment passed to the routine. In case the packet segment is first,
+ *	the 'first' index is update. In any case, the 'curr' index is updated.
+ *	If the routine get into Tx resource error it assigns 'curr' index as
+ *	'first'. This way the function can abort Tx process of multiple
+ *	descriptors per packet.
  *
  * INPUT:
- *	struct mv64340_private   *mp   Ethernet Port Control srtuct. 
- *	struct pkt_info        *p_pkt_info       User packet buffer.
+ *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
+ *	struct pkt_info		*p_pkt_info	User packet buffer.
  *
  * OUTPUT:
- *	Tx ring 'curr' and 'first' indexes are updated. 
+ *	Tx ring 'curr' and 'first' indexes are updated.
  *
  * RETURN:
- *      ETH_QUEUE_FULL in case of Tx resource error.
+ *	ETH_QUEUE_FULL in case of Tx resource error.
  *	ETH_ERROR in case the routine can not access Tx desc ring.
  *	ETH_QUEUE_LAST_RESOURCE if the routine uses the last Tx resource.
- *      ETH_OK otherwise.
+ *	ETH_OK otherwise.
  *
  */
-#ifdef  MV64340_CHECKSUM_OFFLOAD_TX
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 /*
  * Modified to include the first descriptor pointer in case of SG
  */
-static ETH_FUNC_RET_STATUS eth_port_send(struct mv64340_private * mp,
-                                         struct pkt_info * p_pkt_info)
+static ETH_FUNC_RET_STATUS eth_port_send(struct mv643xx_private *mp,
+					 struct pkt_info *p_pkt_info)
 {
 	int tx_desc_curr, tx_desc_used, tx_first_desc, tx_next_desc;
-	volatile struct eth_tx_desc *current_descriptor;
-	volatile struct eth_tx_desc *first_descriptor;
-	u32 command_status, first_chip_ptr;
+	struct eth_tx_desc *current_descriptor;
+	struct eth_tx_desc *first_descriptor;
+	u32 command;
 
 	/* Do not process Tx ring in case of Tx ring resource error */
 	if (mp->tx_resource_err)
 		return ETH_QUEUE_FULL;
 
+	/*
+	 * The hardware requires that each buffer that is <= 8 bytes
+	 * in length must be aligned on an 8 byte boundary.
+	 */
+	if (p_pkt_info->byte_cnt <= 8 && p_pkt_info->buf_ptr & 0x7) {
+		printk(KERN_ERR
+			"mv643xx_eth port %d: packet size <= 8 problem\n",
+			mp->port_num);
+		return ETH_ERROR;
+	}
+
 	/* Get the Tx Desc ring indexes */
 	tx_desc_curr = mp->tx_curr_desc_q;
 	tx_desc_used = mp->tx_used_desc_q;
 
 	current_descriptor = &mp->p_tx_desc_area[tx_desc_curr];
-	if (current_descriptor == NULL)
-		return ETH_ERROR;
 
-	tx_next_desc = (tx_desc_curr + 1) % MV64340_TX_QUEUE_SIZE;
-	command_status = p_pkt_info->cmd_sts | ETH_ZERO_PADDING | ETH_GEN_CRC;
+	tx_next_desc = (tx_desc_curr + 1) % mp->tx_ring_size;
+
+	current_descriptor->buf_ptr = p_pkt_info->buf_ptr;
+	current_descriptor->byte_cnt = p_pkt_info->byte_cnt;
+	current_descriptor->l4i_chk = p_pkt_info->l4i_chk;
+	mp->tx_skb[tx_desc_curr] = p_pkt_info->return_info;
 
-	if (command_status & ETH_TX_FIRST_DESC) {
+	command = p_pkt_info->cmd_sts | ETH_ZERO_PADDING | ETH_GEN_CRC |
+							ETH_BUFFER_OWNED_BY_DMA;
+	if (command & ETH_TX_FIRST_DESC) {
 		tx_first_desc = tx_desc_curr;
 		mp->tx_first_desc_q = tx_first_desc;
+		first_descriptor = current_descriptor;
+		mp->tx_first_command = command;
+	} else {
+		tx_first_desc = mp->tx_first_desc_q;
+		first_descriptor = &mp->p_tx_desc_area[tx_first_desc];
+		BUG_ON(first_descriptor == NULL);
+		current_descriptor->cmd_sts = command;
+	}
 
-                /* fill first descriptor */
-                first_descriptor = &mp->p_tx_desc_area[tx_desc_curr];
-                first_descriptor->l4i_chk = p_pkt_info->l4i_chk;
-                first_descriptor->cmd_sts = command_status;
-                first_descriptor->byte_cnt = p_pkt_info->byte_cnt;
-                first_descriptor->buf_ptr = p_pkt_info->buf_ptr;
-                first_descriptor->next_desc_ptr = mp->tx_desc_dma +
-			tx_next_desc * sizeof(struct eth_tx_desc);
+	if (command & ETH_TX_LAST_DESC) {
 		wmb();
-        } else {
-                tx_first_desc = mp->tx_first_desc_q;
-                first_descriptor = &mp->p_tx_desc_area[tx_first_desc];
-                if (first_descriptor == NULL) {
-                        printk("First desc is NULL !!\n");
-                        return ETH_ERROR;
-                }
-                if (command_status & ETH_TX_LAST_DESC)
-                        current_descriptor->next_desc_ptr = 0x00000000;
-                else {
-                        command_status |= ETH_BUFFER_OWNED_BY_DMA;
-                        current_descriptor->next_desc_ptr = mp->tx_desc_dma +
-				tx_next_desc * sizeof(struct eth_tx_desc);
-                }
-        }
-
-        if (p_pkt_info->byte_cnt < 8) {
-                printk(" < 8 problem \n");
-                return ETH_ERROR;
-        }
-
-        current_descriptor->buf_ptr = p_pkt_info->buf_ptr;
-        current_descriptor->byte_cnt = p_pkt_info->byte_cnt;
-        current_descriptor->l4i_chk = p_pkt_info->l4i_chk;
-        current_descriptor->cmd_sts = command_status;
-
-        mp->tx_skb[tx_desc_curr] = (struct sk_buff*) p_pkt_info->return_info;
-
-        wmb();
-
-        /* Set last desc with DMA ownership and interrupt enable. */
-        if (command_status & ETH_TX_LAST_DESC) {
-                current_descriptor->cmd_sts = command_status |
-                                        ETH_TX_ENABLE_INTERRUPT |
-                                        ETH_BUFFER_OWNED_BY_DMA;
+		first_descriptor->cmd_sts = mp->tx_first_command;
 
-		if (!(command_status & ETH_TX_FIRST_DESC))
-			first_descriptor->cmd_sts |= ETH_BUFFER_OWNED_BY_DMA;
 		wmb();
-
-		first_chip_ptr = MV_READ(MV64340_ETH_CURRENT_SERVED_TX_DESC_PTR(mp->port_num));
-
-		/* Apply send command */
-		if (first_chip_ptr == 0x00000000)
-			MV_WRITE(MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(mp->port_num), (struct eth_tx_desc *) mp->tx_desc_dma + tx_first_desc);
-
-                ETH_ENABLE_TX_QUEUE(mp->port_num);
+		ETH_ENABLE_TX_QUEUE(mp->port_num);
 
 		/*
 		 * Finish Tx packet. Update first desc in case of Tx resource
 		 * error */
-                tx_first_desc = tx_next_desc;
-                mp->tx_first_desc_q = tx_first_desc;
-	} else {
-		if (! (command_status & ETH_TX_FIRST_DESC) ) {
-			current_descriptor->cmd_sts = command_status;
-			wmb();
-		}
+		tx_first_desc = tx_next_desc;
+		mp->tx_first_desc_q = tx_first_desc;
 	}
 
-        /* Check for ring index overlap in the Tx desc ring */
-        if (tx_next_desc == tx_desc_used) {
-                mp->tx_resource_err = 1;
-                mp->tx_curr_desc_q = tx_first_desc;
+	/* Check for ring index overlap in the Tx desc ring */
+	if (tx_next_desc == tx_desc_used) {
+		mp->tx_resource_err = 1;
+		mp->tx_curr_desc_q = tx_first_desc;
 
-                return ETH_QUEUE_LAST_RESOURCE;
+		return ETH_QUEUE_LAST_RESOURCE;
 	}
 
-        mp->tx_curr_desc_q = tx_next_desc;
-        wmb();
+	mp->tx_curr_desc_q = tx_next_desc;
 
-        return ETH_OK;
+	return ETH_OK;
 }
 #else
-static ETH_FUNC_RET_STATUS eth_port_send(struct mv64340_private * mp,
-					 struct pkt_info * p_pkt_info)
+static ETH_FUNC_RET_STATUS eth_port_send(struct mv643xx_private *mp,
+					 struct pkt_info *p_pkt_info)
 {
 	int tx_desc_curr;
 	int tx_desc_used;
-	volatile struct eth_tx_desc* current_descriptor;
+	struct eth_tx_desc *current_descriptor;
 	unsigned int command_status;
 
 	/* Do not process Tx ring in case of Tx ring resource error */
@@ -2401,39 +2592,24 @@
 	tx_desc_used = mp->tx_used_desc_q;
 	current_descriptor = &mp->p_tx_desc_area[tx_desc_curr];
 
-	if (current_descriptor == NULL)
-		return ETH_ERROR;
-
 	command_status = p_pkt_info->cmd_sts | ETH_ZERO_PADDING | ETH_GEN_CRC;
-
-/* XXX Is this for real ?!?!? */
-	/* Buffers with a payload smaller than 8 bytes must be aligned to a
-	 * 64-bit boundary. We use the memory allocated for Tx descriptor.
-	 * This memory is located in TX_BUF_OFFSET_IN_DESC offset within the
-	 * Tx descriptor. */
-	if (p_pkt_info->byte_cnt <= 8) {
-		printk(KERN_ERR
-		       "You have failed in the < 8 bytes errata - fixme\n");
-		return ETH_ERROR;
-	}
 	current_descriptor->buf_ptr = p_pkt_info->buf_ptr;
 	current_descriptor->byte_cnt = p_pkt_info->byte_cnt;
-	mp->tx_skb[tx_desc_curr] = (struct sk_buff *) p_pkt_info->return_info;
-
-	mb();
+	mp->tx_skb[tx_desc_curr] = p_pkt_info->return_info;
 
 	/* Set last desc with DMA ownership and interrupt enable. */
+	wmb();
 	current_descriptor->cmd_sts = command_status |
 			ETH_BUFFER_OWNED_BY_DMA | ETH_TX_ENABLE_INTERRUPT;
 
-	/* Apply send command */
+	wmb();
 	ETH_ENABLE_TX_QUEUE(mp->port_num);
 
 	/* Finish Tx packet. Update first desc in case of Tx resource error */
-	tx_desc_curr = (tx_desc_curr + 1) % MV64340_TX_QUEUE_SIZE;
+	tx_desc_curr = (tx_desc_curr + 1) % mp->tx_ring_size;
 
 	/* Update the current descriptor */
- 	mp->tx_curr_desc_q = tx_desc_curr;
+	mp->tx_curr_desc_q = tx_desc_curr;
 
 	/* Check for ring index overlap in the Tx desc ring */
 	if (tx_desc_curr == tx_desc_used) {
@@ -2450,62 +2626,55 @@
  *
  * DESCRIPTION:
  *	This routine returns the transmitted packet information to the caller.
- *      It uses the 'first' index to support Tx desc return in case a transmit 
- *      of a packet spanned over multiple buffer still in process.
- *      In case the Tx queue was in "resource error" condition, where there are 
- *      no available Tx resources, the function resets the resource error flag.
+ *	It uses the 'first' index to support Tx desc return in case a transmit
+ *	of a packet spanned over multiple buffer still in process.
+ *	In case the Tx queue was in "resource error" condition, where there are
+ *	no available Tx resources, the function resets the resource error flag.
  *
  * INPUT:
- *	struct mv64340_private   *mp   Ethernet Port Control srtuct. 
- *	struct pkt_info        *p_pkt_info       User packet buffer.
+ *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
+ *	struct pkt_info		*p_pkt_info	User packet buffer.
  *
  * OUTPUT:
- *	Tx ring 'first' and 'used' indexes are updated. 
+ *	Tx ring 'first' and 'used' indexes are updated.
  *
  * RETURN:
  *	ETH_ERROR in case the routine can not access Tx desc ring.
- *      ETH_RETRY in case there is transmission in process.
+ *	ETH_RETRY in case there is transmission in process.
  *	ETH_END_OF_JOB if the routine has nothing to release.
- *      ETH_OK otherwise.
+ *	ETH_OK otherwise.
  *
  */
-static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv64340_private * mp,
-					      struct pkt_info * p_pkt_info)
+static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv643xx_private *mp,
+						struct pkt_info *p_pkt_info)
 {
-	int tx_desc_used, tx_desc_curr;
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
-        int tx_first_desc;
+	int tx_desc_used;
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+	int tx_busy_desc = mp->tx_first_desc_q;
+#else
+	int tx_busy_desc = mp->tx_curr_desc_q;
 #endif
-	volatile struct eth_tx_desc *p_tx_desc_used;
+	struct eth_tx_desc *p_tx_desc_used;
 	unsigned int command_status;
 
 	/* Get the Tx Desc ring indexes */
-	tx_desc_curr = mp->tx_curr_desc_q;
 	tx_desc_used = mp->tx_used_desc_q;
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
-        tx_first_desc = mp->tx_first_desc_q;
-#endif
+
 	p_tx_desc_used = &mp->p_tx_desc_area[tx_desc_used];
 
-	/* XXX Sanity check */
+	/* Sanity check */
 	if (p_tx_desc_used == NULL)
 		return ETH_ERROR;
 
+	/* Stop release. About to overlap the current available Tx descriptor */
+	if (tx_desc_used == tx_busy_desc && !mp->tx_resource_err)
+		return ETH_END_OF_JOB;
+
 	command_status = p_tx_desc_used->cmd_sts;
 
 	/* Still transmitting... */
-#ifndef MV64340_CHECKSUM_OFFLOAD_TX
 	if (command_status & (ETH_BUFFER_OWNED_BY_DMA))
 		return ETH_RETRY;
-#endif
-	/* Stop release. About to overlap the current available Tx descriptor */
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
-	if (tx_desc_used == tx_first_desc && !mp->tx_resource_err)
-		return ETH_END_OF_JOB;
-#else
-	if (tx_desc_used == tx_desc_curr && !mp->tx_resource_err)
-		return ETH_END_OF_JOB;
-#endif
 
 	/* Pass the packet information to the caller */
 	p_pkt_info->cmd_sts = command_status;
@@ -2513,7 +2682,7 @@
 	mp->tx_skb[tx_desc_used] = NULL;
 
 	/* Update the next descriptor to release. */
-	mp->tx_used_desc_q = (tx_desc_used + 1) % MV64340_TX_QUEUE_SIZE;
+	mp->tx_used_desc_q = (tx_desc_used + 1) % mp->tx_ring_size;
 
 	/* Any Tx return cancels the Tx resource error status */
 	mp->tx_resource_err = 0;
@@ -2525,30 +2694,30 @@
  * eth_port_receive - Get received information from Rx ring.
  *
  * DESCRIPTION:
- * 	This routine returns the received data to the caller. There is no 
- *	data copying during routine operation. All information is returned 
- *	using pointer to packet information struct passed from the caller. 
- *      If the routine exhausts	Rx ring resources then the resource error flag 
- *      is set.  
+ * 	This routine returns the received data to the caller. There is no
+ *	data copying during routine operation. All information is returned
+ *	using pointer to packet information struct passed from the caller.
+ *	If the routine exhausts Rx ring resources then the resource error flag
+ *	is set.
  *
  * INPUT:
- *	struct mv64340_private   *mp   Ethernet Port Control srtuct. 
- *	struct pkt_info        *p_pkt_info       User packet buffer.
+ *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
+ *	struct pkt_info		*p_pkt_info	User packet buffer.
  *
  * OUTPUT:
- *	Rx ring current and used indexes are updated. 
+ *	Rx ring current and used indexes are updated.
  *
  * RETURN:
  *	ETH_ERROR in case the routine can not access Rx desc ring.
  *	ETH_QUEUE_FULL if Rx ring resources are exhausted.
  *	ETH_END_OF_JOB if there is no received data.
- *      ETH_OK otherwise.
+ *	ETH_OK otherwise.
  */
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv64340_private * mp,
-					    struct pkt_info * p_pkt_info)
+static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
+						struct pkt_info *p_pkt_info)
 {
 	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
-	volatile struct eth_rx_desc * p_rx_desc;
+	volatile struct eth_rx_desc *p_rx_desc;
 	unsigned int command_status;
 
 	/* Do not process Rx ring in case of Rx ring resource error */
@@ -2563,6 +2732,7 @@
 
 	/* The following parameters are used to save readings from memory */
 	command_status = p_rx_desc->cmd_sts;
+	rmb();
 
 	/* Nothing to receive... */
 	if (command_status & (ETH_BUFFER_OWNED_BY_DMA))
@@ -2575,18 +2745,17 @@
 	p_pkt_info->l4i_chk = p_rx_desc->buf_size;
 
 	/* Clean the return info field to indicate that the packet has been */
-	/* moved to the upper layers                                        */
+	/* moved to the upper layers					    */
 	mp->rx_skb[rx_curr_desc] = NULL;
 
 	/* Update current index in data structure */
-	rx_next_curr_desc = (rx_curr_desc + 1) % MV64340_RX_QUEUE_SIZE;
+	rx_next_curr_desc = (rx_curr_desc + 1) % mp->rx_ring_size;
 	mp->rx_curr_desc_q = rx_next_curr_desc;
 
 	/* Rx descriptors exhausted. Set the Rx ring resource error flag */
 	if (rx_next_curr_desc == rx_used_desc)
 		mp->rx_resource_err = 1;
 
-	mb();
 	return ETH_OK;
 }
 
@@ -2594,27 +2763,27 @@
  * eth_rx_return_buff - Returns a Rx buffer back to the Rx ring.
  *
  * DESCRIPTION:
- *	This routine returns a Rx buffer back to the Rx ring. It retrieves the 
- *      next 'used' descriptor and attached the returned buffer to it.
- *      In case the Rx ring was in "resource error" condition, where there are 
- *      no available Rx resources, the function resets the resource error flag.
+ *	This routine returns a Rx buffer back to the Rx ring. It retrieves the
+ *	next 'used' descriptor and attached the returned buffer to it.
+ *	In case the Rx ring was in "resource error" condition, where there are
+ *	no available Rx resources, the function resets the resource error flag.
  *
  * INPUT:
- *	struct mv64340_private *mp   Ethernet Port Control srtuct. 
- *      struct pkt_info        *p_pkt_info   Information on the returned buffer.
+ *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
+ *	struct pkt_info		*p_pkt_info	Information on returned buffer.
  *
  * OUTPUT:
  *	New available Rx resource in Rx descriptor ring.
  *
  * RETURN:
  *	ETH_ERROR in case the routine can not access Rx desc ring.
- *      ETH_OK otherwise.
+ *	ETH_OK otherwise.
  */
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv64340_private * mp,
-	struct pkt_info * p_pkt_info)
+static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
+						struct pkt_info *p_pkt_info)
 {
 	int used_rx_desc;	/* Where to return Rx resource */
-	volatile struct eth_rx_desc* p_used_rx_desc;
+	volatile struct eth_rx_desc *p_used_rx_desc;
 
 	/* Get 'used' Rx descriptor */
 	used_rx_desc = mp->rx_used_desc_q;
@@ -2625,20 +2794,240 @@
 	mp->rx_skb[used_rx_desc] = p_pkt_info->return_info;
 
 	/* Flush the write pipe */
-	mb();
 
 	/* Return the descriptor to DMA ownership */
+	wmb();
 	p_used_rx_desc->cmd_sts =
-		ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
-
-	/* Flush descriptor and CPU pipe */
-	mb();
+			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
+	wmb();
 
 	/* Move the used descriptor pointer to the next descriptor */
-	mp->rx_used_desc_q = (used_rx_desc + 1) % MV64340_RX_QUEUE_SIZE;
+	mp->rx_used_desc_q = (used_rx_desc + 1) % mp->rx_ring_size;
 
 	/* Any Rx return cancels the Rx resource error status */
 	mp->rx_resource_err = 0;
 
 	return ETH_OK;
 }
+
+/************* Begin ethtool support *************************/
+
+struct mv643xx_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define MV643XX_STAT(m) sizeof(((struct mv643xx_private *)0)->m), \
+		      offsetof(struct mv643xx_private, m)
+
+static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
+	{ "rx_packets", MV643XX_STAT(stats.rx_packets) },
+	{ "tx_packets", MV643XX_STAT(stats.tx_packets) },
+	{ "rx_bytes", MV643XX_STAT(stats.rx_bytes) },
+	{ "tx_bytes", MV643XX_STAT(stats.tx_bytes) },
+	{ "rx_errors", MV643XX_STAT(stats.rx_errors) },
+	{ "tx_errors", MV643XX_STAT(stats.tx_errors) },
+	{ "rx_dropped", MV643XX_STAT(stats.rx_dropped) },
+	{ "tx_dropped", MV643XX_STAT(stats.tx_dropped) },
+	{ "good_octets_received", MV643XX_STAT(mib_counters.good_octets_received) },
+	{ "bad_octets_received", MV643XX_STAT(mib_counters.bad_octets_received) },
+	{ "internal_mac_transmit_err", MV643XX_STAT(mib_counters.internal_mac_transmit_err) },
+	{ "good_frames_received", MV643XX_STAT(mib_counters.good_frames_received) },
+	{ "bad_frames_received", MV643XX_STAT(mib_counters.bad_frames_received) },
+	{ "broadcast_frames_received", MV643XX_STAT(mib_counters.broadcast_frames_received) },
+	{ "multicast_frames_received", MV643XX_STAT(mib_counters.multicast_frames_received) },
+	{ "frames_64_octets", MV643XX_STAT(mib_counters.frames_64_octets) },
+	{ "frames_65_to_127_octets", MV643XX_STAT(mib_counters.frames_65_to_127_octets) },
+	{ "frames_128_to_255_octets", MV643XX_STAT(mib_counters.frames_128_to_255_octets) },
+	{ "frames_256_to_511_octets", MV643XX_STAT(mib_counters.frames_256_to_511_octets) },
+	{ "frames_512_to_1023_octets", MV643XX_STAT(mib_counters.frames_512_to_1023_octets) },
+	{ "frames_1024_to_max_octets", MV643XX_STAT(mib_counters.frames_1024_to_max_octets) },
+	{ "good_octets_sent", MV643XX_STAT(mib_counters.good_octets_sent) },
+	{ "good_frames_sent", MV643XX_STAT(mib_counters.good_frames_sent) },
+	{ "excessive_collision", MV643XX_STAT(mib_counters.excessive_collision) },
+	{ "multicast_frames_sent", MV643XX_STAT(mib_counters.multicast_frames_sent) },
+	{ "broadcast_frames_sent", MV643XX_STAT(mib_counters.broadcast_frames_sent) },
+	{ "unrec_mac_control_received", MV643XX_STAT(mib_counters.unrec_mac_control_received) },
+	{ "fc_sent", MV643XX_STAT(mib_counters.fc_sent) },
+	{ "good_fc_received", MV643XX_STAT(mib_counters.good_fc_received) },
+	{ "bad_fc_received", MV643XX_STAT(mib_counters.bad_fc_received) },
+	{ "undersize_received", MV643XX_STAT(mib_counters.undersize_received) },
+	{ "fragments_received", MV643XX_STAT(mib_counters.fragments_received) },
+	{ "oversize_received", MV643XX_STAT(mib_counters.oversize_received) },
+	{ "jabber_received", MV643XX_STAT(mib_counters.jabber_received) },
+	{ "mac_receive_error", MV643XX_STAT(mib_counters.mac_receive_error) },
+	{ "bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event) },
+	{ "collision", MV643XX_STAT(mib_counters.collision) },
+	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
+};
+
+#define MV643XX_STATS_LEN	\
+	sizeof(mv643xx_gstrings_stats) / sizeof(struct mv643xx_stats)
+
+static int
+mv643xx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	struct mv643xx_private *mp = netdev->priv;
+	int port_num = mp->port_num;
+	int autoneg = eth_port_autoneg_supported(port_num);
+	int mode_10_bit;
+	int auto_duplex;
+	int half_duplex = 0;
+	int full_duplex = 0;
+	int auto_speed;
+	int speed_10 = 0;
+	int speed_100 = 0;
+	int speed_1000 = 0;
+
+	u32 pcs = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	u32 psr = mv_read(MV643XX_ETH_PORT_STATUS_REG(port_num));
+
+	mode_10_bit = psr & MV643XX_ETH_PORT_STATUS_MODE_10_BIT;
+
+	if (mode_10_bit) {
+		ecmd->supported = SUPPORTED_10baseT_Half;
+	} else {
+		ecmd->supported = (SUPPORTED_10baseT_Half		|
+				   SUPPORTED_10baseT_Full		|
+				   SUPPORTED_100baseT_Half		|
+				   SUPPORTED_100baseT_Full		|
+				   SUPPORTED_1000baseT_Full		|
+				   (autoneg ? SUPPORTED_Autoneg : 0)	|
+				   SUPPORTED_TP);
+
+		auto_duplex = !(pcs & MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX);
+		auto_speed = !(pcs & MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII);
+
+		ecmd->advertising = ADVERTISED_TP;
+
+		if (autoneg) {
+			ecmd->advertising |= ADVERTISED_Autoneg;
+
+			if (auto_duplex) {
+				half_duplex = 1;
+				full_duplex = 1;
+			} else {
+				if (pcs & MV643XX_ETH_SET_FULL_DUPLEX_MODE)
+					full_duplex = 1;
+				else
+					half_duplex = 1;
+			}
+
+			if (auto_speed) {
+				speed_10 = 1;
+				speed_100 = 1;
+				speed_1000 = 1;
+			} else {
+				if (pcs & MV643XX_ETH_SET_GMII_SPEED_TO_1000)
+					speed_1000 = 1;
+				else if (pcs & MV643XX_ETH_SET_MII_SPEED_TO_100)
+					speed_100 = 1;
+				else
+					speed_10 = 1;
+			}
+
+			if (speed_10 & half_duplex)
+				ecmd->advertising |= ADVERTISED_10baseT_Half;
+			if (speed_10 & full_duplex)
+				ecmd->advertising |= ADVERTISED_10baseT_Full;
+			if (speed_100 & half_duplex)
+				ecmd->advertising |= ADVERTISED_100baseT_Half;
+			if (speed_100 & full_duplex)
+				ecmd->advertising |= ADVERTISED_100baseT_Full;
+			if (speed_1000)
+				ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		}
+	}
+
+	ecmd->port = PORT_TP;
+	ecmd->phy_address = ethernet_phy_get(port_num);
+
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	if (netif_carrier_ok(netdev)) {
+		if (mode_10_bit)
+			ecmd->speed = SPEED_10;
+		else {
+			if (psr & MV643XX_ETH_PORT_STATUS_GMII_1000)
+				ecmd->speed = SPEED_1000;
+			else if (psr & MV643XX_ETH_PORT_STATUS_MII_100)
+				ecmd->speed = SPEED_100;
+			else
+				ecmd->speed = SPEED_10;
+		}
+
+		if (psr & MV643XX_ETH_PORT_STATUS_FULL_DUPLEX)
+			ecmd->duplex = DUPLEX_FULL;
+		else
+			ecmd->duplex = DUPLEX_HALF;
+	} else {
+		ecmd->speed = -1;
+		ecmd->duplex = -1;
+	}
+
+	ecmd->autoneg = autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	return 0;
+}
+
+static void
+mv643xx_get_drvinfo(struct net_device *netdev,
+                       struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver,  mv643xx_driver_name, 32);
+	strncpy(drvinfo->version, mv643xx_driver_version, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, "mv643xx", 32);
+	drvinfo->n_stats = MV643XX_STATS_LEN;
+}
+
+static int 
+mv643xx_get_stats_count(struct net_device *netdev)
+{
+	return MV643XX_STATS_LEN;
+}
+
+static void 
+mv643xx_get_ethtool_stats(struct net_device *netdev, 
+		struct ethtool_stats *stats, uint64_t *data)
+{
+	struct mv643xx_private *mp = netdev->priv;
+	int i;
+
+	eth_update_mib_counters(mp);
+
+	for(i = 0; i < MV643XX_STATS_LEN; i++) {
+		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;	
+		data[i] = (mv643xx_gstrings_stats[i].sizeof_stat == 
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+	}
+}
+
+static void 
+mv643xx_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+{
+	int i;
+
+	switch(stringset) {
+	case ETH_SS_STATS:
+		for (i=0; i < MV643XX_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN, 
+			mv643xx_gstrings_stats[i].stat_string,
+			ETH_GSTRING_LEN);
+		}
+		break;
+	}
+}
+
+static struct ethtool_ops mv643xx_ethtool_ops = {
+	.get_settings           = mv643xx_get_settings,
+	.get_drvinfo            = mv643xx_get_drvinfo,
+	.get_link               = ethtool_op_get_link,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
+	.get_strings            = mv643xx_get_strings,
+	.get_stats_count        = mv643xx_get_stats_count,
+	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
+};
+
+/************* End ethtool support *************************/
diff -Nru a/drivers/net/mv643xx_eth.h b/drivers/net/mv643xx_eth.h
--- a/drivers/net/mv643xx_eth.h	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/mv643xx_eth.h	2005-03-08 14:29:45 -05:00
@@ -1,5 +1,5 @@
-#ifndef __MV64340_ETH_H__
-#define __MV64340_ETH_H__
+#ifndef __MV643XX_ETH_H__
+#define __MV643XX_ETH_H__
 
 #include <linux/version.h>
 #include <linux/module.h>
@@ -46,17 +46,16 @@
  *  The first part is the high level driver of the gigE ethernet ports.
  */
 
-#define ETH_PORT0_IRQ_NUM 48			/* main high register, bit0 */
-#define ETH_PORT1_IRQ_NUM ETH_PORT0_IRQ_NUM+1	/* main high register, bit1 */
-#define ETH_PORT2_IRQ_NUM ETH_PORT0_IRQ_NUM+2	/* main high register, bit1 */
-
-/* Checksum offload for Tx works */
-#define  MV64340_CHECKSUM_OFFLOAD_TX
-#define	 MV64340_NAPI
-#define	 MV64340_TX_FAST_REFILL
-#undef	 MV64340_COAL
+/* Checksum offload for Tx works for most packets, but
+ * fails if previous packet sent did not use hw csum
+ */
+#undef	MV643XX_CHECKSUM_OFFLOAD_TX
+#define	MV643XX_NAPI
+#define	MV643XX_TX_FAST_REFILL
+#undef	MV643XX_RX_QUEUE_FILL_ON_TASK	/* Does not work, yet */
+#undef	MV643XX_COAL
 
-/* 
+/*
  * Number of RX / TX descriptors on RX / TX rings.
  * Note that allocating RX descriptors is done by allocating the RX
  * ring AND a preallocated RX buffers (skb's) for each descriptor.
@@ -65,89 +64,35 @@
  */
 
 /* Default TX ring size is 1000 descriptors */
-#define MV64340_TX_QUEUE_SIZE 1000
+#define MV643XX_DEFAULT_TX_QUEUE_SIZE 1000
 
 /* Default RX ring size is 400 descriptors */
-#define MV64340_RX_QUEUE_SIZE 400
+#define MV643XX_DEFAULT_RX_QUEUE_SIZE 400
 
-#define MV64340_TX_COAL 100
-#ifdef MV64340_COAL
-#define MV64340_RX_COAL 100
+#define MV643XX_TX_COAL 100
+#ifdef MV643XX_COAL
+#define MV643XX_RX_COAL 100
 #endif
 
-
 /*
- * The second part is the low level driver of the gigE ethernet ports.   *
+ * The second part is the low level driver of the gigE ethernet ports.
  */
 
-
 /*
- * Header File for : MV-643xx network interface header 
+ * Header File for : MV-643xx network interface header
  *
  * DESCRIPTION:
- *       This header file contains macros typedefs and function declaration for
- *       the Marvell Gig Bit Ethernet Controller. 
+ *	This header file contains macros typedefs and function declaration for
+ *	the Marvell Gig Bit Ethernet Controller.
  *
  * DEPENDENCIES:
- *       None.
+ *	None.
  *
  */
 
-/* Default port configuration value */
-#define PORT_CONFIG_VALUE                       \
-             ETH_UNICAST_NORMAL_MODE		|   \
-             ETH_DEFAULT_RX_QUEUE_0		|   \
-             ETH_DEFAULT_RX_ARP_QUEUE_0		|   \
-             ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|   \
-             ETH_RECEIVE_BC_IF_IP		|   \
-             ETH_RECEIVE_BC_IF_ARP 		|   \
-             ETH_CAPTURE_TCP_FRAMES_DIS		|   \
-             ETH_CAPTURE_UDP_FRAMES_DIS		|   \
-             ETH_DEFAULT_RX_TCP_QUEUE_0		|   \
-             ETH_DEFAULT_RX_UDP_QUEUE_0		|   \
-             ETH_DEFAULT_RX_BPDU_QUEUE_0
-
-/* Default port extend configuration value */
-#define PORT_CONFIG_EXTEND_VALUE		\
-             ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|   \
-             ETH_PARTITION_DISABLE
-
-
-/* Default sdma control value */
-#define PORT_SDMA_CONFIG_VALUE			\
-			 ETH_RX_BURST_SIZE_16_64BIT 	|	\
-			 GT_ETH_IPG_INT_RX(0) 		|	\
-			 ETH_TX_BURST_SIZE_16_64BIT;
-
-#define GT_ETH_IPG_INT_RX(value)                \
-            ((value & 0x3fff) << 8)
-
-/* Default port serial control value */
-#define PORT_SERIAL_CONTROL_VALUE		\
-			ETH_FORCE_LINK_PASS 			|	\
-			ETH_ENABLE_AUTO_NEG_FOR_DUPLX		|	\
-			ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL 	|	\
-			ETH_ADV_SYMMETRIC_FLOW_CTRL 		|	\
-			ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX 	|	\
-			ETH_FORCE_BP_MODE_NO_JAM 		|	\
-			BIT9 					|	\
-			ETH_DO_NOT_FORCE_LINK_FAIL 		|	\
-			ETH_RETRANSMIT_16_ATTEMPTS 		|	\
-			ETH_ENABLE_AUTO_NEG_SPEED_GMII	 	|	\
-			ETH_DTE_ADV_0 				|	\
-			ETH_DISABLE_AUTO_NEG_BYPASS		|	\
-			ETH_AUTO_NEG_NO_CHANGE 			|	\
-			ETH_MAX_RX_PACKET_9700BYTE 		|	\
-			ETH_CLR_EXT_LOOPBACK 			|	\
-			ETH_SET_FULL_DUPLEX_MODE 		|	\
-			ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
-
-#define RX_BUFFER_MAX_SIZE  0x4000000
-#define TX_BUFFER_MAX_SIZE  0x4000000
-
 /* MAC accepet/reject macros */
-#define ACCEPT_MAC_ADDR	    0
-#define REJECT_MAC_ADDR	    1
+#define ACCEPT_MAC_ADDR				0
+#define REJECT_MAC_ADDR				1
 
 /* Buffer offset from buffer pointer */
 #define RX_BUF_OFFSET				0x2
@@ -155,277 +100,132 @@
 /* Gigabit Ethernet Unit Global Registers */
 
 /* MIB Counters register definitions */
-#define ETH_MIB_GOOD_OCTETS_RECEIVED_LOW   0x0
-#define ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH  0x4
-#define ETH_MIB_BAD_OCTETS_RECEIVED        0x8
-#define ETH_MIB_INTERNAL_MAC_TRANSMIT_ERR  0xc
-#define ETH_MIB_GOOD_FRAMES_RECEIVED       0x10
-#define ETH_MIB_BAD_FRAMES_RECEIVED        0x14
-#define ETH_MIB_BROADCAST_FRAMES_RECEIVED  0x18
-#define ETH_MIB_MULTICAST_FRAMES_RECEIVED  0x1c
-#define ETH_MIB_FRAMES_64_OCTETS           0x20
-#define ETH_MIB_FRAMES_65_TO_127_OCTETS    0x24
-#define ETH_MIB_FRAMES_128_TO_255_OCTETS   0x28
-#define ETH_MIB_FRAMES_256_TO_511_OCTETS   0x2c
-#define ETH_MIB_FRAMES_512_TO_1023_OCTETS  0x30
-#define ETH_MIB_FRAMES_1024_TO_MAX_OCTETS  0x34
-#define ETH_MIB_GOOD_OCTETS_SENT_LOW       0x38
-#define ETH_MIB_GOOD_OCTETS_SENT_HIGH      0x3c
-#define ETH_MIB_GOOD_FRAMES_SENT           0x40
-#define ETH_MIB_EXCESSIVE_COLLISION        0x44
-#define ETH_MIB_MULTICAST_FRAMES_SENT      0x48
-#define ETH_MIB_BROADCAST_FRAMES_SENT      0x4c
-#define ETH_MIB_UNREC_MAC_CONTROL_RECEIVED 0x50
-#define ETH_MIB_FC_SENT                    0x54
-#define ETH_MIB_GOOD_FC_RECEIVED           0x58
-#define ETH_MIB_BAD_FC_RECEIVED            0x5c
-#define ETH_MIB_UNDERSIZE_RECEIVED         0x60
-#define ETH_MIB_FRAGMENTS_RECEIVED         0x64
-#define ETH_MIB_OVERSIZE_RECEIVED          0x68
-#define ETH_MIB_JABBER_RECEIVED            0x6c
-#define ETH_MIB_MAC_RECEIVE_ERROR          0x70
-#define ETH_MIB_BAD_CRC_EVENT              0x74
-#define ETH_MIB_COLLISION                  0x78
-#define ETH_MIB_LATE_COLLISION             0x7c
+#define ETH_MIB_GOOD_OCTETS_RECEIVED_LOW	0x0
+#define ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH	0x4
+#define ETH_MIB_BAD_OCTETS_RECEIVED		0x8
+#define ETH_MIB_INTERNAL_MAC_TRANSMIT_ERR	0xc
+#define ETH_MIB_GOOD_FRAMES_RECEIVED		0x10
+#define ETH_MIB_BAD_FRAMES_RECEIVED		0x14
+#define ETH_MIB_BROADCAST_FRAMES_RECEIVED	0x18
+#define ETH_MIB_MULTICAST_FRAMES_RECEIVED	0x1c
+#define ETH_MIB_FRAMES_64_OCTETS		0x20
+#define ETH_MIB_FRAMES_65_TO_127_OCTETS		0x24
+#define ETH_MIB_FRAMES_128_TO_255_OCTETS	0x28
+#define ETH_MIB_FRAMES_256_TO_511_OCTETS	0x2c
+#define ETH_MIB_FRAMES_512_TO_1023_OCTETS	0x30
+#define ETH_MIB_FRAMES_1024_TO_MAX_OCTETS	0x34
+#define ETH_MIB_GOOD_OCTETS_SENT_LOW		0x38
+#define ETH_MIB_GOOD_OCTETS_SENT_HIGH		0x3c
+#define ETH_MIB_GOOD_FRAMES_SENT		0x40
+#define ETH_MIB_EXCESSIVE_COLLISION		0x44
+#define ETH_MIB_MULTICAST_FRAMES_SENT		0x48
+#define ETH_MIB_BROADCAST_FRAMES_SENT		0x4c
+#define ETH_MIB_UNREC_MAC_CONTROL_RECEIVED	0x50
+#define ETH_MIB_FC_SENT				0x54
+#define ETH_MIB_GOOD_FC_RECEIVED		0x58
+#define ETH_MIB_BAD_FC_RECEIVED			0x5c
+#define ETH_MIB_UNDERSIZE_RECEIVED		0x60
+#define ETH_MIB_FRAGMENTS_RECEIVED		0x64
+#define ETH_MIB_OVERSIZE_RECEIVED		0x68
+#define ETH_MIB_JABBER_RECEIVED			0x6c
+#define ETH_MIB_MAC_RECEIVE_ERROR		0x70
+#define ETH_MIB_BAD_CRC_EVENT			0x74
+#define ETH_MIB_COLLISION			0x78
+#define ETH_MIB_LATE_COLLISION			0x7c
 
 /* Port serial status reg (PSR) */
-#define ETH_INTERFACE_GMII_MII                          0
-#define ETH_INTERFACE_PCM                               BIT0
-#define ETH_LINK_IS_DOWN                                0
-#define ETH_LINK_IS_UP                                  BIT1
-#define ETH_PORT_AT_HALF_DUPLEX                         0
-#define ETH_PORT_AT_FULL_DUPLEX                         BIT2
-#define ETH_RX_FLOW_CTRL_DISABLED                       0
-#define ETH_RX_FLOW_CTRL_ENBALED                        BIT3
-#define ETH_GMII_SPEED_100_10                           0
-#define ETH_GMII_SPEED_1000                             BIT4
-#define ETH_MII_SPEED_10                                0
-#define ETH_MII_SPEED_100                               BIT5
-#define ETH_NO_TX                                       0
-#define ETH_TX_IN_PROGRESS                              BIT7
-#define ETH_BYPASS_NO_ACTIVE                            0
-#define ETH_BYPASS_ACTIVE                               BIT8
-#define ETH_PORT_NOT_AT_PARTITION_STATE                 0
-#define ETH_PORT_AT_PARTITION_STATE                     BIT9
-#define ETH_PORT_TX_FIFO_NOT_EMPTY                      0
-#define ETH_PORT_TX_FIFO_EMPTY                          BIT10
-
-
-/* These macros describes the Port configuration reg (Px_cR) bits */
-#define ETH_UNICAST_NORMAL_MODE                         0
-#define ETH_UNICAST_PROMISCUOUS_MODE                    BIT0
-#define ETH_DEFAULT_RX_QUEUE_0                          0
-#define ETH_DEFAULT_RX_QUEUE_1                          BIT1
-#define ETH_DEFAULT_RX_QUEUE_2                          BIT2
-#define ETH_DEFAULT_RX_QUEUE_3                          (BIT2 | BIT1)
-#define ETH_DEFAULT_RX_QUEUE_4                          BIT3
-#define ETH_DEFAULT_RX_QUEUE_5                          (BIT3 | BIT1)
-#define ETH_DEFAULT_RX_QUEUE_6                          (BIT3 | BIT2)
-#define ETH_DEFAULT_RX_QUEUE_7                          (BIT3 | BIT2 | BIT1)
-#define ETH_DEFAULT_RX_ARP_QUEUE_0                      0
-#define ETH_DEFAULT_RX_ARP_QUEUE_1                      BIT4
-#define ETH_DEFAULT_RX_ARP_QUEUE_2                      BIT5
-#define ETH_DEFAULT_RX_ARP_QUEUE_3                      (BIT5 | BIT4)
-#define ETH_DEFAULT_RX_ARP_QUEUE_4                      BIT6
-#define ETH_DEFAULT_RX_ARP_QUEUE_5                      (BIT6 | BIT4)
-#define ETH_DEFAULT_RX_ARP_QUEUE_6                      (BIT6 | BIT5)
-#define ETH_DEFAULT_RX_ARP_QUEUE_7                      (BIT6 | BIT5 | BIT4)
-#define ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP                 0
-#define ETH_REJECT_BC_IF_NOT_IP_OR_ARP                  BIT7
-#define ETH_RECEIVE_BC_IF_IP                            0
-#define ETH_REJECT_BC_IF_IP                             BIT8
-#define ETH_RECEIVE_BC_IF_ARP                           0
-#define ETH_REJECT_BC_IF_ARP                            BIT9
-#define ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY               BIT12
-#define ETH_CAPTURE_TCP_FRAMES_DIS                      0
-#define ETH_CAPTURE_TCP_FRAMES_EN                       BIT14
-#define ETH_CAPTURE_UDP_FRAMES_DIS                      0
-#define ETH_CAPTURE_UDP_FRAMES_EN                       BIT15
-#define ETH_DEFAULT_RX_TCP_QUEUE_0                      0
-#define ETH_DEFAULT_RX_TCP_QUEUE_1                      BIT16
-#define ETH_DEFAULT_RX_TCP_QUEUE_2                      BIT17
-#define ETH_DEFAULT_RX_TCP_QUEUE_3                      (BIT17 | BIT16)
-#define ETH_DEFAULT_RX_TCP_QUEUE_4                      BIT18
-#define ETH_DEFAULT_RX_TCP_QUEUE_5                      (BIT18 | BIT16)
-#define ETH_DEFAULT_RX_TCP_QUEUE_6                      (BIT18 | BIT17)
-#define ETH_DEFAULT_RX_TCP_QUEUE_7                      (BIT18 | BIT17 | BIT16)
-#define ETH_DEFAULT_RX_UDP_QUEUE_0                      0
-#define ETH_DEFAULT_RX_UDP_QUEUE_1                      BIT19
-#define ETH_DEFAULT_RX_UDP_QUEUE_2                      BIT20
-#define ETH_DEFAULT_RX_UDP_QUEUE_3                      (BIT20 | BIT19)
-#define ETH_DEFAULT_RX_UDP_QUEUE_4                      (BIT21
-#define ETH_DEFAULT_RX_UDP_QUEUE_5                      (BIT21 | BIT19)
-#define ETH_DEFAULT_RX_UDP_QUEUE_6                      (BIT21 | BIT20)
-#define ETH_DEFAULT_RX_UDP_QUEUE_7                      (BIT21 | BIT20 | BIT19)
-#define ETH_DEFAULT_RX_BPDU_QUEUE_0                      0
-#define ETH_DEFAULT_RX_BPDU_QUEUE_1                     BIT22
-#define ETH_DEFAULT_RX_BPDU_QUEUE_2                     BIT23
-#define ETH_DEFAULT_RX_BPDU_QUEUE_3                     (BIT23 | BIT22)
-#define ETH_DEFAULT_RX_BPDU_QUEUE_4                     BIT24
-#define ETH_DEFAULT_RX_BPDU_QUEUE_5                     (BIT24 | BIT22)
-#define ETH_DEFAULT_RX_BPDU_QUEUE_6                     (BIT24 | BIT23)
-#define ETH_DEFAULT_RX_BPDU_QUEUE_7                     (BIT24 | BIT23 | BIT22)
-
-
-/* These macros describes the Port configuration extend reg (Px_cXR) bits*/
-#define ETH_CLASSIFY_EN                                 BIT0
-#define ETH_SPAN_BPDU_PACKETS_AS_NORMAL                 0
-#define ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7             BIT1
-#define ETH_PARTITION_DISABLE                           0
-#define ETH_PARTITION_ENABLE                            BIT2
-
-
-/* Tx/Rx queue command reg (RQCR/TQCR)*/
-#define ETH_QUEUE_0_ENABLE                              BIT0
-#define ETH_QUEUE_1_ENABLE                              BIT1
-#define ETH_QUEUE_2_ENABLE                              BIT2
-#define ETH_QUEUE_3_ENABLE                              BIT3
-#define ETH_QUEUE_4_ENABLE                              BIT4
-#define ETH_QUEUE_5_ENABLE                              BIT5
-#define ETH_QUEUE_6_ENABLE                              BIT6
-#define ETH_QUEUE_7_ENABLE                              BIT7
-#define ETH_QUEUE_0_DISABLE                             BIT8
-#define ETH_QUEUE_1_DISABLE                             BIT9
-#define ETH_QUEUE_2_DISABLE                             BIT10
-#define ETH_QUEUE_3_DISABLE                             BIT11
-#define ETH_QUEUE_4_DISABLE                             BIT12
-#define ETH_QUEUE_5_DISABLE                             BIT13
-#define ETH_QUEUE_6_DISABLE                             BIT14
-#define ETH_QUEUE_7_DISABLE                             BIT15
-
-
-/* These macros describes the Port Sdma configuration reg (SDCR) bits */
-#define ETH_RIFB                                        BIT0
-#define ETH_RX_BURST_SIZE_1_64BIT                       0
-#define ETH_RX_BURST_SIZE_2_64BIT                       BIT1
-#define ETH_RX_BURST_SIZE_4_64BIT                       BIT2
-#define ETH_RX_BURST_SIZE_8_64BIT                       (BIT2 | BIT1)
-#define ETH_RX_BURST_SIZE_16_64BIT                      BIT3
-#define ETH_BLM_RX_NO_SWAP                              BIT4
-#define ETH_BLM_RX_BYTE_SWAP                            0
-#define ETH_BLM_TX_NO_SWAP                              BIT5
-#define ETH_BLM_TX_BYTE_SWAP                            0
-#define ETH_DESCRIPTORS_BYTE_SWAP                       BIT6
-#define ETH_DESCRIPTORS_NO_SWAP                         0
-#define ETH_TX_BURST_SIZE_1_64BIT                       0
-#define ETH_TX_BURST_SIZE_2_64BIT                       BIT22
-#define ETH_TX_BURST_SIZE_4_64BIT                       BIT23
-#define ETH_TX_BURST_SIZE_8_64BIT                       (BIT23 | BIT22)
-#define ETH_TX_BURST_SIZE_16_64BIT                      BIT24
-
-
-
-/* These macros describes the Port serial control reg (PSCR) bits */
-#define ETH_SERIAL_PORT_DISABLE                         0
-#define ETH_SERIAL_PORT_ENABLE                          BIT0
-#define ETH_FORCE_LINK_PASS                             BIT1
-#define ETH_DO_NOT_FORCE_LINK_PASS                      0
-#define ETH_ENABLE_AUTO_NEG_FOR_DUPLX                   0
-#define ETH_DISABLE_AUTO_NEG_FOR_DUPLX                  BIT2
-#define ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL               0
-#define ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL              BIT3
-#define ETH_ADV_NO_FLOW_CTRL                            0
-#define ETH_ADV_SYMMETRIC_FLOW_CTRL                     BIT4
-#define ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX               0
-#define ETH_FORCE_FC_MODE_TX_PAUSE_DIS                  BIT5
-#define ETH_FORCE_BP_MODE_NO_JAM                        0
-#define ETH_FORCE_BP_MODE_JAM_TX                        BIT7
-#define ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR              BIT8
-#define ETH_FORCE_LINK_FAIL                             0
-#define ETH_DO_NOT_FORCE_LINK_FAIL                      BIT10
-#define ETH_RETRANSMIT_16_ATTEMPTS                      0
-#define ETH_RETRANSMIT_FOREVER                          BIT11
-#define ETH_DISABLE_AUTO_NEG_SPEED_GMII                 BIT13
-#define ETH_ENABLE_AUTO_NEG_SPEED_GMII                  0
-#define ETH_DTE_ADV_0                                   0
-#define ETH_DTE_ADV_1                                   BIT14
-#define ETH_DISABLE_AUTO_NEG_BYPASS                     0
-#define ETH_ENABLE_AUTO_NEG_BYPASS                      BIT15
-#define ETH_AUTO_NEG_NO_CHANGE                          0
-#define ETH_RESTART_AUTO_NEG                            BIT16
-#define ETH_MAX_RX_PACKET_1518BYTE                      0
-#define ETH_MAX_RX_PACKET_1522BYTE                      BIT17
-#define ETH_MAX_RX_PACKET_1552BYTE                      BIT18
-#define ETH_MAX_RX_PACKET_9022BYTE                      (BIT18 | BIT17)
-#define ETH_MAX_RX_PACKET_9192BYTE                      BIT19
-#define ETH_MAX_RX_PACKET_9700BYTE                      (BIT19 | BIT17)
-#define ETH_SET_EXT_LOOPBACK                            BIT20
-#define ETH_CLR_EXT_LOOPBACK                            0
-#define ETH_SET_FULL_DUPLEX_MODE                        BIT21
-#define ETH_SET_HALF_DUPLEX_MODE                        0
-#define ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX       BIT22
-#define ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX      0
-#define ETH_SET_GMII_SPEED_TO_10_100                    0
-#define ETH_SET_GMII_SPEED_TO_1000                      BIT23
-#define ETH_SET_MII_SPEED_TO_10                         0
-#define ETH_SET_MII_SPEED_TO_100                        BIT24
-
+#define ETH_INTERFACE_GMII_MII			0
+#define ETH_INTERFACE_PCM			BIT0
+#define ETH_LINK_IS_DOWN			0
+#define ETH_LINK_IS_UP				BIT1
+#define ETH_PORT_AT_HALF_DUPLEX			0
+#define ETH_PORT_AT_FULL_DUPLEX			BIT2
+#define ETH_RX_FLOW_CTRL_DISABLED		0
+#define ETH_RX_FLOW_CTRL_ENBALED		BIT3
+#define ETH_GMII_SPEED_100_10			0
+#define ETH_GMII_SPEED_1000			BIT4
+#define ETH_MII_SPEED_10			0
+#define ETH_MII_SPEED_100			BIT5
+#define ETH_NO_TX				0
+#define ETH_TX_IN_PROGRESS			BIT7
+#define ETH_BYPASS_NO_ACTIVE			0
+#define ETH_BYPASS_ACTIVE			BIT8
+#define ETH_PORT_NOT_AT_PARTITION_STATE		0
+#define ETH_PORT_AT_PARTITION_STATE		BIT9
+#define ETH_PORT_TX_FIFO_NOT_EMPTY		0
+#define ETH_PORT_TX_FIFO_EMPTY			BIT10
+
+#define ETH_DEFAULT_RX_BPDU_QUEUE_3		(BIT23 | BIT22)
+#define ETH_DEFAULT_RX_BPDU_QUEUE_4		BIT24
+#define ETH_DEFAULT_RX_BPDU_QUEUE_5		(BIT24 | BIT22)
+#define ETH_DEFAULT_RX_BPDU_QUEUE_6		(BIT24 | BIT23)
+#define ETH_DEFAULT_RX_BPDU_QUEUE_7		(BIT24 | BIT23 | BIT22)
 
 /* SMI reg */
-#define ETH_SMI_BUSY        	BIT28	/* 0 - Write, 1 - Read          */
-#define ETH_SMI_READ_VALID  	BIT27	/* 0 - Write, 1 - Read          */
+#define ETH_SMI_BUSY		BIT28	/* 0 - Write, 1 - Read		*/
+#define ETH_SMI_READ_VALID	BIT27	/* 0 - Write, 1 - Read		*/
 #define ETH_SMI_OPCODE_WRITE	0	/* Completion of Read operation */
-#define ETH_SMI_OPCODE_READ 	BIT26	/* Operation is in progress             */
+#define ETH_SMI_OPCODE_READ 	BIT26	/* Operation is in progress	*/
 
 /* SDMA command status fields macros */
 
 /* Tx & Rx descriptors status */
-#define ETH_ERROR_SUMMARY                   (BIT0)
+#define ETH_ERROR_SUMMARY			(BIT0)
 
 /* Tx & Rx descriptors command */
-#define ETH_BUFFER_OWNED_BY_DMA             (BIT31)
+#define ETH_BUFFER_OWNED_BY_DMA			(BIT31)
 
 /* Tx descriptors status */
-#define ETH_LC_ERROR                        (0	  )
-#define ETH_UR_ERROR                        (BIT1 )
-#define ETH_RL_ERROR                        (BIT2 )
-#define ETH_LLC_SNAP_FORMAT                 (BIT9 )
+#define ETH_LC_ERROR				(0    )
+#define ETH_UR_ERROR				(BIT1 )
+#define ETH_RL_ERROR				(BIT2 )
+#define ETH_LLC_SNAP_FORMAT			(BIT9 )
 
 /* Rx descriptors status */
-#define ETH_CRC_ERROR                       (0	  )
-#define ETH_OVERRUN_ERROR                   (BIT1 )
-#define ETH_MAX_FRAME_LENGTH_ERROR          (BIT2 )
-#define ETH_RESOURCE_ERROR                  ((BIT2 | BIT1))
-#define ETH_VLAN_TAGGED                     (BIT19)
-#define ETH_BPDU_FRAME                      (BIT20)
-#define ETH_TCP_FRAME_OVER_IP_V_4           (0    )
-#define ETH_UDP_FRAME_OVER_IP_V_4           (BIT21)
-#define ETH_OTHER_FRAME_TYPE                (BIT22)
-#define ETH_LAYER_2_IS_ETH_V_2              (BIT23)
-#define ETH_FRAME_TYPE_IP_V_4               (BIT24)
-#define ETH_FRAME_HEADER_OK                 (BIT25)
-#define ETH_RX_LAST_DESC                    (BIT26)
-#define ETH_RX_FIRST_DESC                   (BIT27)
-#define ETH_UNKNOWN_DESTINATION_ADDR        (BIT28)
-#define ETH_RX_ENABLE_INTERRUPT             (BIT29)
-#define ETH_LAYER_4_CHECKSUM_OK             (BIT30)
+#define ETH_CRC_ERROR				(0    )
+#define ETH_OVERRUN_ERROR			(BIT1 )
+#define ETH_MAX_FRAME_LENGTH_ERROR		(BIT2 )
+#define ETH_RESOURCE_ERROR			((BIT2 | BIT1))
+#define ETH_VLAN_TAGGED				(BIT19)
+#define ETH_BPDU_FRAME				(BIT20)
+#define ETH_TCP_FRAME_OVER_IP_V_4		(0    )
+#define ETH_UDP_FRAME_OVER_IP_V_4		(BIT21)
+#define ETH_OTHER_FRAME_TYPE			(BIT22)
+#define ETH_LAYER_2_IS_ETH_V_2			(BIT23)
+#define ETH_FRAME_TYPE_IP_V_4			(BIT24)
+#define ETH_FRAME_HEADER_OK			(BIT25)
+#define ETH_RX_LAST_DESC			(BIT26)
+#define ETH_RX_FIRST_DESC			(BIT27)
+#define ETH_UNKNOWN_DESTINATION_ADDR		(BIT28)
+#define ETH_RX_ENABLE_INTERRUPT			(BIT29)
+#define ETH_LAYER_4_CHECKSUM_OK			(BIT30)
 
 /* Rx descriptors byte count */
-#define ETH_FRAME_FRAGMENTED                (BIT2)
+#define ETH_FRAME_FRAGMENTED			(BIT2)
 
 /* Tx descriptors command */
 #define ETH_LAYER_4_CHECKSUM_FIRST_DESC		(BIT10)
-#define ETH_FRAME_SET_TO_VLAN               (BIT15)
-#define ETH_TCP_FRAME                       (0	  )
-#define ETH_UDP_FRAME                       (BIT16)
-#define ETH_GEN_TCP_UDP_CHECKSUM            (BIT17)
-#define ETH_GEN_IP_V_4_CHECKSUM             (BIT18)
-#define ETH_ZERO_PADDING                    (BIT19)
-#define ETH_TX_LAST_DESC                    (BIT20)
-#define ETH_TX_FIRST_DESC                   (BIT21)
-#define ETH_GEN_CRC                         (BIT22)
-#define ETH_TX_ENABLE_INTERRUPT             (BIT23)
-#define ETH_AUTO_MODE                       (BIT30)
+#define ETH_FRAME_SET_TO_VLAN			(BIT15)
+#define ETH_TCP_FRAME				(0    )
+#define ETH_UDP_FRAME				(BIT16)
+#define ETH_GEN_TCP_UDP_CHECKSUM		(BIT17)
+#define ETH_GEN_IP_V_4_CHECKSUM			(BIT18)
+#define ETH_ZERO_PADDING			(BIT19)
+#define ETH_TX_LAST_DESC			(BIT20)
+#define ETH_TX_FIRST_DESC			(BIT21)
+#define ETH_GEN_CRC				(BIT22)
+#define ETH_TX_ENABLE_INTERRUPT			(BIT23)
+#define ETH_AUTO_MODE				(BIT30)
 
 /* typedefs */
 
 typedef enum _eth_func_ret_status {
-	ETH_OK,			/* Returned as expected.                    */
-	ETH_ERROR,		/* Fundamental error.                       */
-	ETH_RETRY,		/* Could not process request. Try later.    */
-	ETH_END_OF_JOB,		/* Ring has nothing to process.             */
-	ETH_QUEUE_FULL,		/* Ring resource error.                     */
-	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.         */
+	ETH_OK,			/* Returned as expected.		*/
+	ETH_ERROR,		/* Fundamental error.			*/
+	ETH_RETRY,		/* Could not process request. Try later.*/
+	ETH_END_OF_JOB,		/* Ring has nothing to process.		*/
+	ETH_QUEUE_FULL,		/* Ring resource error.			*/
+	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
 } ETH_FUNC_RET_STATUS;
 
 typedef enum _eth_target {
@@ -441,66 +241,103 @@
  */
 #if defined(__BIG_ENDIAN)
 struct eth_rx_desc {
-	u16	byte_cnt;	/* Descriptor buffer byte count     */
-	u16	buf_size;	/* Buffer size                      */
-	u32	cmd_sts;	/* Descriptor command status        */
-	u32	next_desc_ptr;	/* Next descriptor pointer          */
-	u32	buf_ptr;	/* Descriptor buffer pointer        */
+	u16 byte_cnt;		/* Descriptor buffer byte count		*/
+	u16 buf_size;		/* Buffer size				*/
+	u32 cmd_sts;		/* Descriptor command status		*/
+	u32 next_desc_ptr;	/* Next descriptor pointer		*/
+	u32 buf_ptr;		/* Descriptor buffer pointer		*/
 };
 
 struct eth_tx_desc {
-	u16	byte_cnt;	/* buffer byte count */
-	u16	l4i_chk;	/* CPU provided TCP checksum */
-	u32	cmd_sts;	/* Command/status field */
-	u32	next_desc_ptr;	/* Pointer to next descriptor */
-	u32	buf_ptr;	/* pointer to buffer for this descriptor */
+	u16 byte_cnt;		/* buffer byte count			*/
+	u16 l4i_chk;		/* CPU provided TCP checksum		*/
+	u32 cmd_sts;		/* Command/status field			*/
+	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
+	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
 };
 
 #elif defined(__LITTLE_ENDIAN)
 struct eth_rx_desc {
-	u32	cmd_sts;	/* Descriptor command status        */
-	u16	buf_size;	/* Buffer size                      */
-	u16	byte_cnt;	/* Descriptor buffer byte count     */
-	u32	buf_ptr;	/* Descriptor buffer pointer        */
-	u32	next_desc_ptr;	/* Next descriptor pointer          */
+	u32 cmd_sts;		/* Descriptor command status		*/
+	u16 buf_size;		/* Buffer size				*/
+	u16 byte_cnt;		/* Descriptor buffer byte count		*/
+	u32 buf_ptr;		/* Descriptor buffer pointer		*/
+	u32 next_desc_ptr;	/* Next descriptor pointer		*/
 };
 
 struct eth_tx_desc {
-	u32	cmd_sts;	/* Command/status field */
-	u16	l4i_chk;	/* CPU provided TCP checksum */
-	u16	byte_cnt;	/* buffer byte count */
-	u32	buf_ptr;	/* pointer to buffer for this descriptor */
-	u32	next_desc_ptr;	/* Pointer to next descriptor */
+	u32 cmd_sts;		/* Command/status field			*/
+	u16 l4i_chk;		/* CPU provided TCP checksum		*/
+	u16 byte_cnt;		/* buffer byte count			*/
+	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
+	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
 };
 #else
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
 
-/* Unified struct for Rx and Tx operations. The user is not required to */
-/* be familier with neither Tx nor Rx descriptors.                       */
+/* Unified struct for Rx and Tx operations. The user is not required to	*/
+/* be familier with neither Tx nor Rx descriptors.			*/
 struct pkt_info {
-	unsigned short	byte_cnt;	/* Descriptor buffer byte count     */
-	unsigned short	l4i_chk;	/* Tx CPU provided TCP Checksum     */
-	unsigned int	cmd_sts;	/* Descriptor command status        */
-	dma_addr_t	buf_ptr;	/* Descriptor buffer pointer        */
-	struct sk_buff	* return_info;	/* User resource return information */
+	unsigned short byte_cnt;	/* Descriptor buffer byte count	*/
+	unsigned short l4i_chk;		/* Tx CPU provided TCP Checksum	*/
+	unsigned int cmd_sts;		/* Descriptor command status	*/
+	dma_addr_t buf_ptr;		/* Descriptor buffer pointer	*/
+	struct sk_buff *return_info;	/* User resource return information */
 };
 
-
 /* Ethernet port specific infomation */
 
-struct mv64340_private {
-	int	port_num;		/* User Ethernet port number */
-	u8	port_mac_addr[6];	/* User defined port MAC address. */
-	u32	port_config;		/* User port configuration value */
-	u32	port_config_extend;	/* User port config extend value */
-	u32	port_sdma_config;	/* User port SDMA config value */
-	u32	port_serial_control;	/* User port serial control value */
-	u32	port_tx_queue_command;	/* Port active Tx queues summary */
-	u32	port_rx_queue_command;	/* Port active Rx queues summary */
+struct mv643xx_mib_counters {
+	u64 good_octets_received;
+	u32 bad_octets_received;
+	u32 internal_mac_transmit_err;
+	u32 good_frames_received;
+	u32 bad_frames_received;
+	u32 broadcast_frames_received;
+	u32 multicast_frames_received;
+	u32 frames_64_octets;
+	u32 frames_65_to_127_octets;
+	u32 frames_128_to_255_octets;
+	u32 frames_256_to_511_octets;
+	u32 frames_512_to_1023_octets;
+	u32 frames_1024_to_max_octets;
+	u64 good_octets_sent;
+	u32 good_frames_sent;
+	u32 excessive_collision;
+	u32 multicast_frames_sent;
+	u32 broadcast_frames_sent;
+	u32 unrec_mac_control_received;
+	u32 fc_sent;
+	u32 good_fc_received;
+	u32 bad_fc_received;
+	u32 undersize_received;
+	u32 fragments_received;
+	u32 oversize_received;
+	u32 jabber_received;
+	u32 mac_receive_error;
+	u32 bad_crc_event;
+	u32 collision;
+	u32 late_collision;
+};
+
+struct mv643xx_private {
+	int port_num;			/* User Ethernet port number	*/
+	u8 port_mac_addr[6];		/* User defined port MAC address.*/
+	u32 port_config;		/* User port configuration value*/
+	u32 port_config_extend;		/* User port config extend value*/
+	u32 port_sdma_config;		/* User port SDMA config value	*/
+	u32 port_serial_control;	/* User port serial control value */
+	u32 port_tx_queue_command;	/* Port active Tx queues summary*/
+	u32 port_rx_queue_command;	/* Port active Rx queues summary*/
+
+	u32 rx_sram_addr;		/* Base address of rx sram area */
+	u32 rx_sram_size;		/* Size of rx sram area		*/
+	u32 tx_sram_addr;		/* Base address of tx sram area */
+	u32 tx_sram_size;		/* Size of tx sram area		*/
 
-	int	rx_resource_err;	/* Rx ring resource error flag */
-	int	tx_resource_err;	/* Tx ring resource error flag */
+	int rx_resource_err;		/* Rx ring resource error flag */
+	int tx_resource_err;		/* Tx ring resource error flag */
 
 	/* Tx/Rx rings managment indexes fields. For driver use */
 
@@ -509,30 +346,32 @@
 
 	/* Next available and first returning Tx resource */
 	int tx_curr_desc_q, tx_used_desc_q;
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
-        int tx_first_desc_q;
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+	int tx_first_desc_q;
+	u32 tx_first_command;
 #endif
 
-#ifdef MV64340_TX_FAST_REFILL
-	u32	tx_clean_threshold;
+#ifdef MV643XX_TX_FAST_REFILL
+	u32 tx_clean_threshold;
 #endif
 
-	volatile struct eth_rx_desc	* p_rx_desc_area;
-	dma_addr_t			rx_desc_dma;
-	unsigned int			rx_desc_area_size;
-	struct sk_buff			* rx_skb[MV64340_RX_QUEUE_SIZE];
-
-	volatile struct eth_tx_desc	* p_tx_desc_area;
-	dma_addr_t			tx_desc_dma;
-	unsigned int			tx_desc_area_size;
-	struct sk_buff			* tx_skb[MV64340_TX_QUEUE_SIZE];
+	struct eth_rx_desc *p_rx_desc_area;
+	dma_addr_t rx_desc_dma;
+	unsigned int rx_desc_area_size;
+	struct sk_buff **rx_skb;
+
+	struct eth_tx_desc *p_tx_desc_area;
+	dma_addr_t tx_desc_dma;
+	unsigned int tx_desc_area_size;
+	struct sk_buff **tx_skb;
 
-	struct work_struct		tx_timeout_task;
+	struct work_struct tx_timeout_task;
 
 	/*
-	 * Former struct mv64340_eth_priv members start here
+	 * Former struct mv643xx_eth_priv members start here
 	 */
 	struct net_device_stats stats;
+	struct mv643xx_mib_counters mib_counters;
 	spinlock_t lock;
 	/* Size of Tx Ring per queue */
 	unsigned int tx_ring_size;
@@ -544,13 +383,13 @@
 	unsigned int rx_ring_skbs;
 
 	/*
-	 * rx_task used to fill RX ring out of bottom half context 
+	 * rx_task used to fill RX ring out of bottom half context
 	 */
 	struct work_struct rx_task;
 
-	/* 
-	 * Used in case RX Ring is empty, which can be caused when 
-	 * system does not have resources (skb's) 
+	/*
+	 * Used in case RX Ring is empty, which can be caused when
+	 * system does not have resources (skb's)
 	 */
 	struct timer_list timeout;
 	long rx_task_busy __attribute__ ((aligned(SMP_CACHE_BYTES)));
@@ -563,9 +402,9 @@
 /* ethernet.h API list */
 
 /* Port operation control routines */
-static void eth_port_init(struct mv64340_private *mp);
+static void eth_port_init(struct mv643xx_private *mp);
 static void eth_port_reset(unsigned int eth_port_num);
-static int eth_port_start(struct mv64340_private *mp);
+static void eth_port_start(struct mv643xx_private *mp);
 
 static void ethernet_set_config_reg(unsigned int eth_port_num,
 				    unsigned int value);
@@ -576,26 +415,24 @@
 				 unsigned char *p_addr);
 
 /* PHY and MIB routines */
-static int ethernet_phy_reset(unsigned int eth_port_num);
+static void ethernet_phy_reset(unsigned int eth_port_num);
+
+static void eth_port_write_smi_reg(unsigned int eth_port_num,
+				   unsigned int phy_reg, unsigned int value);
 
-static int eth_port_write_smi_reg(unsigned int eth_port_num,
-				   unsigned int phy_reg,
-				   unsigned int value);
-
-static int eth_port_read_smi_reg(unsigned int eth_port_num,
-				  unsigned int phy_reg,
-				  unsigned int *value);
+static void eth_port_read_smi_reg(unsigned int eth_port_num,
+				  unsigned int phy_reg, unsigned int *value);
 
 static void eth_clear_mib_counters(unsigned int eth_port_num);
 
 /* Port data flow control routines */
-static ETH_FUNC_RET_STATUS eth_port_send(struct mv64340_private *mp,
-					 struct pkt_info * p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv64340_private *mp,
-					      struct pkt_info * p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv64340_private *mp,
-					    struct pkt_info * p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv64340_private *mp,
-					      struct pkt_info * p_pkt_info);
+static ETH_FUNC_RET_STATUS eth_port_send(struct mv643xx_private *mp,
+					 struct pkt_info *p_pkt_info);
+static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv643xx_private *mp,
+					      struct pkt_info *p_pkt_info);
+static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
+					    struct pkt_info *p_pkt_info);
+static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
+					      struct pkt_info *p_pkt_info);
 
-#endif  /* __MV64340_ETH_H__ */
+#endif				/* __MV643XX_ETH_H__ */
diff -Nru a/drivers/net/sis900.c b/drivers/net/sis900.c
--- a/drivers/net/sis900.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/sis900.c	2005-03-08 14:29:45 -05:00
@@ -1,6 +1,6 @@
 /* sis900.c: A SiS 900/7016 PCI Fast Ethernet driver for Linux.
    Copyright 1999 Silicon Integrated System Corporation 
-   Revision:	1.08.06 Sep. 24 2002
+   Revision:	1.08.08 Jan. 22 2005
    
    Modified from the driver which is originally written by Donald Becker.
    
@@ -16,8 +16,8 @@
    preliminary Rev. 1.0 Nov. 10, 1998
    SiS 7014 Single Chip 100BASE-TX/10BASE-T Physical Layer Solution,
    preliminary Rev. 1.0 Jan. 18, 1998
-   http://www.sis.com.tw/support/databook.htm
 
+   Rev 1.08.08 Jan. 22 2005 Daniele Venzano use netif_msg for debugging messages
    Rev 1.08.07 Nov.  2 2003 Daniele Venzano <webvenza@libero.it> add suspend/resume support
    Rev 1.08.06 Sep. 24 2002 Mufasa Yang bug fix for Tx timeout & add SiS963 support
    Rev 1.08.05 Jun.  6 2002 Mufasa Yang bug fix for read_eeprom & Tx descriptor over-boundary
@@ -74,7 +74,7 @@
 #include "sis900.h"
 
 #define SIS900_MODULE_NAME "sis900"
-#define SIS900_DRV_VERSION "v1.08.07 11/02/2003"
+#define SIS900_DRV_VERSION "v1.08.08 Jan. 22 2005"
 
 static char version[] __devinitdata =
 KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";
@@ -82,8 +82,13 @@
 static int max_interrupt_work = 40;
 static int multicast_filter_limit = 128;
 
-#define sis900_debug debug
-static int sis900_debug;
+static int sis900_debug = -1; /* Use SIS900_DEF_MSG as value */
+
+#define SIS900_DEF_MSG \
+	(NETIF_MSG_DRV		| \
+	 NETIF_MSG_LINK		| \
+	 NETIF_MSG_RX_ERR	| \
+	 NETIF_MSG_TX_ERR)
 
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (4*HZ)
@@ -160,6 +165,8 @@
 	struct timer_list timer; /* Link status detection timer. */
 	u8 autong_complete; /* 1: auto-negotiate complete  */
 
+	u32 msg_enable;
+
 	unsigned int cur_rx, dirty_rx; /* producer/comsumer pointers for Tx/Rx ring */
 	unsigned int cur_tx, dirty_tx;
 
@@ -174,6 +181,7 @@
 
 	unsigned int tx_full; /* The Tx queue is full. */
 	u8 host_bridge_rev;
+	u8 chipset_rev;
 };
 
 MODULE_AUTHOR("Jim Huang <cmhuang@sis.com.tw>, Ollie Lho <ollie@sis.com.tw>");
@@ -182,11 +190,12 @@
 
 module_param(multicast_filter_limit, int, 0444);
 module_param(max_interrupt_work, int, 0444);
-module_param(debug, int, 0444);
+module_param(sis900_debug, int, 0444);
 MODULE_PARM_DESC(multicast_filter_limit, "SiS 900/7016 maximum number of filtered multicast addresses");
 MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled per interrupt");
-MODULE_PARM_DESC(debug, "SiS 900/7016 debug level (2-4)");
+MODULE_PARM_DESC(sis900_debug, "SiS 900/7016 bitmapped debugging message level");
 
+static void sis900_poll(struct net_device *dev);
 static int sis900_open(struct net_device *net_dev);
 static int sis900_mii_probe (struct net_device * net_dev);
 static void sis900_init_rxfilter (struct net_device * net_dev);
@@ -235,7 +244,7 @@
 	/* check to see if we have sane EEPROM */
 	signature = (u16) read_eeprom(ioaddr, EEPROMSignature);    
 	if (signature == 0xffff || signature == 0x0000) {
-		printk (KERN_INFO "%s: Error EERPOM read %x\n", 
+		printk (KERN_WARNING "%s: Error EERPOM read %x\n", 
 			net_dev->name, signature);
 		return 0;
 	}
@@ -268,7 +277,7 @@
 	if (!isa_bridge)
 		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
 	if (!isa_bridge) {
-		printk("%s: Can not find ISA bridge\n", net_dev->name);
+		printk(KERN_WARNING "%s: Can not find ISA bridge\n", net_dev->name);
 		return 0;
 	}
 	pci_read_config_byte(isa_bridge, 0x48, &reg);
@@ -386,7 +395,6 @@
 	void *ring_space;
 	long ioaddr;
 	int i, ret;
-	u8 revision;
 	char *card_name = card_names[pci_id->driver_data];
 
 /* when built into the kernel, we only print version if device is found */
@@ -456,35 +464,50 @@
 	net_dev->tx_timeout = sis900_tx_timeout;
 	net_dev->watchdog_timeo = TX_TIMEOUT;
 	net_dev->ethtool_ops = &sis900_ethtool_ops;
-	
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+        net_dev->poll_controller = &sis900_poll;
+#endif
+
+	if (sis900_debug > 0)
+		sis_priv->msg_enable = sis900_debug;
+	else
+		sis_priv->msg_enable = SIS900_DEF_MSG;
+
 	ret = register_netdev(net_dev);
 	if (ret)
 		goto err_unmap_rx;
 		
 	/* Get Mac address according to the chip revision */
-	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
+	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &(sis_priv->chipset_rev));
+	if(netif_msg_probe(sis_priv))
+		printk(KERN_DEBUG "%s: detected revision %2.2x, "
+				"trying to get MAC address...\n",
+				net_dev->name, sis_priv->chipset_rev);
+	
 	ret = 0;
-
-	if (revision == SIS630E_900_REV)
+	if (sis_priv->chipset_rev == SIS630E_900_REV)
 		ret = sis630e_get_mac_addr(pci_dev, net_dev);
-	else if ((revision > 0x81) && (revision <= 0x90) )
+	else if ((sis_priv->chipset_rev > 0x81) && (sis_priv->chipset_rev <= 0x90) )
 		ret = sis635_get_mac_addr(pci_dev, net_dev);
-	else if (revision == SIS96x_900_REV)
+	else if (sis_priv->chipset_rev == SIS96x_900_REV)
 		ret = sis96x_get_mac_addr(pci_dev, net_dev);
 	else
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
 
 	if (ret == 0) {
+		printk(KERN_WARNING "%s: Cannot read MAC address.\n", net_dev->name);
 		ret = -ENODEV;
 		goto err_out_unregister;
 	}
 	
 	/* 630ET : set the mii access mode as software-mode */
-	if (revision == SIS630ET_900_REV)
+	if (sis_priv->chipset_rev == SIS630ET_900_REV)
 		outl(ACCESSMODE | inl(ioaddr + cr), ioaddr + cr);
 
 	/* probe for mii transceiver */
 	if (sis900_mii_probe(net_dev) == 0) {
+		printk(KERN_WARNING "%s: Error probing MII device.\n", net_dev->name);
 		ret = -ENODEV;
 		goto err_out_unregister;
 	}
@@ -536,7 +559,6 @@
 	u16 poll_bit = MII_STAT_LINK, status = 0;
 	unsigned long timeout = jiffies + 5 * HZ;
 	int phy_addr;
-	u8 revision;
 
 	sis_priv->mii = NULL;
 
@@ -550,12 +572,16 @@
 		for(i = 0; i < 2; i++)
 			mii_status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
-		if (mii_status == 0xffff || mii_status == 0x0000)
-			/* the mii is not accessible, try next one */
+		if (mii_status == 0xffff || mii_status == 0x0000) {
+			if (netif_msg_probe(sis_priv))
+				printk(KERN_DEBUG "%s: MII at address %d"
+						" not accessible\n",
+						net_dev->name, phy_addr);
 			continue;
+		}
 		
 		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
-			printk(KERN_INFO "Cannot allocate mem for struct mii_phy\n");
+			printk(KERN_WARNING "Cannot allocate mem for struct mii_phy\n");
 			mii_phy = sis_priv->first_mii;
 			while (mii_phy) {
 				struct mii_phy *phy;
@@ -581,9 +607,11 @@
 				if (mii_chip_table[i].phy_types == MIX)
 					mii_phy->phy_types =
 					    (mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HOME;
-				printk(KERN_INFO "%s: %s transceiver found at address %d.\n",
-				       net_dev->name, mii_chip_table[i].name,
-				       phy_addr);
+				printk(KERN_INFO "%s: %s transceiver found "
+							"at address %d.\n",
+							net_dev->name,
+							mii_chip_table[i].name,
+							phy_addr);
 				break;
 			}
 			
@@ -627,8 +655,7 @@
 		}
 	}
 
-	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
-	if (revision == SIS630E_900_REV) {
+	if (sis_priv->chipset_rev == SIS630E_900_REV) {
 		/* SiS 630E has some bugs on default value of PHY registers */
 		mdio_write(net_dev, sis_priv->cur_phy, MII_ANADV, 0x05e1);
 		mdio_write(net_dev, sis_priv->cur_phy, MII_CONFIG1, 0x22);
@@ -930,6 +957,20 @@
 	return status;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+*/
+static void sis900_poll(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	sis900_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 /**
  *	sis900_open - open sis900 device
  *	@net_dev: the net device to open
@@ -943,15 +984,13 @@
 {
 	struct sis900_private *sis_priv = net_dev->priv;
 	long ioaddr = net_dev->base_addr;
-	u8 revision;
 	int ret;
 
 	/* Soft reset the chip. */
 	sis900_reset(net_dev);
 
 	/* Equalizer workaround Rule */
-	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
-	sis630_set_eq(net_dev, revision);
+	sis630_set_eq(net_dev, sis_priv->chipset_rev);
 
 	ret = request_irq(net_dev->irq, &sis900_interrupt, SA_SHIRQ,
 						net_dev->name, net_dev);
@@ -999,6 +1038,7 @@
 static void
 sis900_init_rxfilter (struct net_device * net_dev)
 {
+	struct sis900_private *sis_priv = net_dev->priv;
 	long ioaddr = net_dev->base_addr;
 	u32 rfcrSave;
 	u32 i;
@@ -1016,8 +1056,8 @@
 		outl((i << RFADDR_shift), ioaddr + rfcr);
 		outl(w, ioaddr + rfdr);
 
-		if (sis900_debug > 2) {
-			printk(KERN_INFO "%s: Receive Filter Addrss[%d]=%x\n",
+		if (netif_msg_hw(sis_priv)) {
+			printk(KERN_DEBUG "%s: Receive Filter Addrss[%d]=%x\n",
 			       net_dev->name, i, inl(ioaddr + rfdr));
 		}
 	}
@@ -1054,8 +1094,8 @@
 
 	/* load Transmit Descriptor Register */
 	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
-	if (sis900_debug > 2)
-		printk(KERN_INFO "%s: TX descriptor register loaded with: %8.8x\n",
+	if (netif_msg_hw(sis_priv))
+		printk(KERN_DEBUG "%s: TX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + txdp));
 }
 
@@ -1108,8 +1148,8 @@
 
 	/* load Receive Descriptor Register */
 	outl(sis_priv->rx_ring_dma, ioaddr + rxdp);
-	if (sis900_debug > 2)
-		printk(KERN_INFO "%s: RX descriptor register loaded with: %8.8x\n",
+	if (netif_msg_hw(sis_priv))
+		printk(KERN_DEBUG "%s: RX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + rxdp));
 }
 
@@ -1219,7 +1259,6 @@
 	struct mii_phy *mii_phy = sis_priv->mii;
 	static int next_tick = 5*HZ;
 	u16 status;
-	u8 revision;
 
 	if (!sis_priv->autong_complete){
 		int speed, duplex = 0;
@@ -1227,9 +1266,7 @@
 		sis900_read_mode(net_dev, &speed, &duplex);
 		if (duplex){
 			sis900_set_mode(net_dev->base_addr, speed, duplex);
-			pci_read_config_byte(sis_priv->pci_dev,
-						PCI_CLASS_REVISION, &revision);
-			sis630_set_eq(net_dev, revision);
+			sis630_set_eq(net_dev, sis_priv->chipset_rev);
 			netif_start_queue(net_dev);
 		}
 
@@ -1256,16 +1293,15 @@
 	/* Link ON -> OFF */
                 if (!(status & MII_STAT_LINK)){
                 	netif_carrier_off(net_dev);
-                	printk(KERN_INFO "%s: Media Link Off\n", net_dev->name);
+			if(netif_msg_link(sis_priv))
+                		printk(KERN_INFO "%s: Media Link Off\n", net_dev->name);
 
                 	/* Change mode issue */
                 	if ((mii_phy->phy_id0 == 0x001D) && 
 			    ((mii_phy->phy_id1 & 0xFFF0) == 0x8000))
                			sis900_reset_phy(net_dev,  sis_priv->cur_phy);
   
-                	pci_read_config_byte(sis_priv->pci_dev,
-					PCI_CLASS_REVISION, &revision);
-			sis630_set_eq(net_dev, revision);
+			sis630_set_eq(net_dev, sis_priv->chipset_rev);
   
                 	goto LookForLink;
                 }
@@ -1371,7 +1407,8 @@
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	if (!(status & MII_STAT_LINK)){
-		printk(KERN_INFO "%s: Media Link Off\n", net_dev->name);
+		if(netif_msg_link(sis_priv))
+			printk(KERN_INFO "%s: Media Link Off\n", net_dev->name);
 		sis_priv->autong_complete = 1;
 		netif_carrier_off(net_dev);
 		return;
@@ -1433,7 +1470,8 @@
 			*speed = HW_SPEED_100_MBPS;
 	}
 
-	printk(KERN_INFO "%s: Media Link On %s %s-duplex \n",
+	if(netif_msg_link(sis_priv))
+		printk(KERN_INFO "%s: Media Link On %s %s-duplex \n",
 	       				net_dev->name,
 	       				*speed == HW_SPEED_100_MBPS ?
 	       					"100mbps" : "10mbps",
@@ -1456,8 +1494,9 @@
 	unsigned long flags;
 	int i;
 
-	printk(KERN_INFO "%s: Transmit timeout, status %8.8x %8.8x \n",
-	       net_dev->name, inl(ioaddr + cr), inl(ioaddr + isr));
+	if(netif_msg_tx_err(sis_priv))
+		printk(KERN_INFO "%s: Transmit timeout, status %8.8x %8.8x \n",
+	       		net_dev->name, inl(ioaddr + cr), inl(ioaddr + isr));
 
 	/* Disable interrupts by clearing the interrupt mask. */
 	outl(0x0000, ioaddr + imr);
@@ -1558,8 +1597,8 @@
 
 	net_dev->trans_start = jiffies;
 
-	if (sis900_debug > 3)
-		printk(KERN_INFO "%s: Queued Tx packet at %p size %d "
+	if (netif_msg_tx_queued(sis_priv))
+		printk(KERN_DEBUG "%s: Queued Tx packet at %p size %d "
 		       "to slot %d.\n",
 		       net_dev->name, skb->data, (int)skb->len, entry);
 
@@ -1606,20 +1645,22 @@
 
 		/* something strange happened !!! */
 		if (status & HIBERR) {
-			printk(KERN_INFO "%s: Abnormal interrupt,"
-			       "status %#8.8x.\n", net_dev->name, status);
+			if(netif_msg_intr(sis_priv))
+				printk(KERN_INFO "%s: Abnormal interrupt,"
+					"status %#8.8x.\n", net_dev->name, status);
 			break;
 		}
 		if (--boguscnt < 0) {
-			printk(KERN_INFO "%s: Too much work at interrupt, "
-			       "interrupt status = %#8.8x.\n",
-			       net_dev->name, status);
+			if(netif_msg_intr(sis_priv))
+				printk(KERN_INFO "%s: Too much work at interrupt, "
+					"interrupt status = %#8.8x.\n",
+					net_dev->name, status);
 			break;
 		}
 	} while (1);
 
-	if (sis900_debug > 3)
-		printk(KERN_INFO "%s: exiting interrupt, "
+	if(netif_msg_intr(sis_priv))
+		printk(KERN_DEBUG "%s: exiting interrupt, "
 		       "interrupt status = 0x%#8.8x.\n",
 		       net_dev->name, inl(ioaddr + isr));
 	
@@ -1644,8 +1685,8 @@
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
 
-	if (sis900_debug > 3)
-		printk(KERN_INFO "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
+	if (netif_msg_rx_status(sis_priv))
+		printk(KERN_DEBUG "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
 		       "status:0x%8.8x\n",
 		       sis_priv->cur_rx, sis_priv->dirty_rx, rx_status);
 
@@ -1656,8 +1697,8 @@
 
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
 			/* corrupted packet received */
-			if (sis900_debug > 3)
-				printk(KERN_INFO "%s: Corrupted packet "
+			if (netif_msg_rx_err(sis_priv))
+				printk(KERN_DEBUG "%s: Corrupted packet "
 				       "received, buffer status = 0x%8.8x.\n",
 				       net_dev->name, rx_status);
 			sis_priv->stats.rx_errors++;
@@ -1678,9 +1719,10 @@
 			   some unknow bugs, it is possible that
 			   we are working on NULL sk_buff :-( */
 			if (sis_priv->rx_skbuff[entry] == NULL) {
-				printk(KERN_INFO "%s: NULL pointer " 
-				       "encountered in Rx ring, skipping\n",
-				       net_dev->name);
+				if (netif_msg_rx_err(sis_priv))
+					printk(KERN_INFO "%s: NULL pointer " 
+						"encountered in Rx ring, skipping\n",
+						net_dev->name);
 				break;
 			}
 
@@ -1707,9 +1749,10 @@
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
-				printk(KERN_INFO "%s: Memory squeeze,"
-				       "deferring packet.\n",
-				       net_dev->name);
+				if (netif_msg_rx_status(sis_priv))
+					printk(KERN_INFO "%s: Memory squeeze,"
+						"deferring packet.\n",
+						net_dev->name);
 				sis_priv->rx_skbuff[entry] = NULL;
 				/* reset buffer descriptor state */
 				sis_priv->rx_ring[entry].cmdsts = 0;
@@ -1743,9 +1786,10 @@
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
-				printk(KERN_INFO "%s: Memory squeeze,"
-				       "deferring packet.\n",
-				       net_dev->name);
+				if (netif_msg_rx_err(sis_priv))
+					printk(KERN_INFO "%s: Memory squeeze,"
+						"deferring packet.\n",
+						net_dev->name);
 				sis_priv->stats.rx_dropped++;
 				break;
 			}
@@ -1794,8 +1838,8 @@
 
 		if (tx_status & (ABORT | UNDERRUN | OWCOLL)) {
 			/* packet unsuccessfully transmitted */
-			if (sis900_debug > 3)
-				printk(KERN_INFO "%s: Transmit "
+			if (netif_msg_tx_err(sis_priv))
+				printk(KERN_DEBUG "%s: Transmit "
 				       "error, Tx status %8.8x.\n",
 				       net_dev->name, tx_status);
 			sis_priv->stats.tx_errors++;
@@ -1906,8 +1950,22 @@
 	strcpy (info->bus_info, pci_name(sis_priv->pci_dev));
 }
 
+static u32 sis900_get_msglevel(struct net_device *net_dev)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	return sis_priv->msg_enable;
+}
+  
+static void sis900_set_msglevel(struct net_device *net_dev, u32 value)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	sis_priv->msg_enable = value;
+}
+
 static struct ethtool_ops sis900_ethtool_ops = {
-	.get_drvinfo =		sis900_get_drvinfo,
+	.get_drvinfo 	= sis900_get_drvinfo,
+	.get_msglevel	= sis900_get_msglevel,
+	.set_msglevel	= sis900_set_msglevel,
 };
 
 /**
@@ -2048,12 +2106,10 @@
 		case IF_PORT_AUI: /* AUI */
 		case IF_PORT_100BASEFX: /* 100BaseFx */
                 	/* These Modes are not supported (are they?)*/
-			printk(KERN_INFO "Not supported");
 			return -EOPNOTSUPP;
 			break;
             
 		default:
-			printk(KERN_INFO "Invalid");
 			return -EINVAL;
 		}
 	}
@@ -2099,11 +2155,10 @@
 	u16 mc_filter[16] = {0};	/* 256/128 bits multicast hash table */
 	int i, table_entries;
 	u32 rx_mode;
-	u8 revision;
 
 	/* 635 Hash Table entires = 256(2^16) */
-	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
-	if((revision >= SIS635A_900_REV) || (revision == SIS900B_900_REV))
+	if((sis_priv->chipset_rev >= SIS635A_900_REV) ||
+			(sis_priv->chipset_rev == SIS900B_900_REV))
 		table_entries = 16;
 	else
 		table_entries = 8;
@@ -2129,7 +2184,7 @@
 			mclist && i < net_dev->mc_count;
 			i++, mclist = mclist->next) {
 			unsigned int bit_nr =
-				sis900_mcast_bitnr(mclist->dmi_addr, revision);
+				sis900_mcast_bitnr(mclist->dmi_addr, sis_priv->chipset_rev);
 			mc_filter[bit_nr >> 4] |= (1 << (bit_nr & 0xf));
 		}
 	}
@@ -2175,7 +2230,6 @@
 	long ioaddr = net_dev->base_addr;
 	int i = 0;
 	u32 status = TxRCMP | RxRCMP;
-	u8  revision;
 
 	outl(0, ioaddr + ier);
 	outl(0, ioaddr + imr);
@@ -2188,8 +2242,8 @@
 		status ^= (inl(isr + ioaddr) & status);
 	}
 
-	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
-	if( (revision >= SIS635A_900_REV) || (revision == SIS900B_900_REV) )
+	if( (sis_priv->chipset_rev >= SIS635A_900_REV) ||
+			(sis_priv->chipset_rev == SIS900B_900_REV) )
 		outl(PESEL | RND_CNT, ioaddr + cfg);
 	else
 		outl(PESEL, ioaddr + cfg);
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/via-rhine.c	2005-03-08 14:29:45 -05:00
@@ -1197,8 +1197,10 @@
 		       dev->name, rp->pdev->irq);
 
 	rc = alloc_ring(dev);
-	if (rc)
+	if (rc) {
+		free_irq(rp->pdev->irq, dev);
 		return rc;
+	}
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
diff -Nru a/drivers/net/wireless/airport.c b/drivers/net/wireless/airport.c
--- a/drivers/net/wireless/airport.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/airport.c	2005-03-08 14:29:45 -05:00
@@ -28,7 +28,6 @@
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
-#include <linux/delay.h>
 
 #include <asm/io.h>
 #include <asm/system.h>
@@ -45,7 +44,7 @@
 
 struct airport {
 	struct macio_dev *mdev;
-	void *vaddr;
+	void __iomem *vaddr;
 	int irq_requested;
 	int ndev_registered;
 };
@@ -150,7 +149,7 @@
 	ssleep(1);
 
 	macio_set_drvdata(mdev, NULL);
-	free_netdev(dev);
+	free_orinocodev(dev);
 
 	return 0;
 }
@@ -194,14 +193,14 @@
 	hermes_t *hw;
 
 	if (macio_resource_count(mdev) < 1 || macio_irq_count(mdev) < 1) {
-		printk(KERN_ERR PFX "wrong interrupt/addresses in OF tree\n");
+		printk(KERN_ERR PFX "Wrong interrupt/addresses in OF tree\n");
 		return -ENODEV;
 	}
 
 	/* Allocate space for private device-specific data */
 	dev = alloc_orinocodev(sizeof(*card), airport_hard_reset);
 	if (! dev) {
-		printk(KERN_ERR PFX "can't allocate device datas\n");
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		return -ENODEV;
 	}
 	priv = netdev_priv(dev);
@@ -212,7 +211,7 @@
 
 	if (macio_request_resource(mdev, 0, "airport")) {
 		printk(KERN_ERR PFX "can't request IO resource !\n");
-		free_netdev(dev);
+		free_orinocodev(dev);
 		return -EBUSY;
 	}
 
@@ -224,16 +223,15 @@
 	/* Setup interrupts & base address */
 	dev->irq = macio_irq(mdev, 0);
 	phys_addr = macio_resource_start(mdev, 0);  /* Physical address */
-	printk(KERN_DEBUG PFX "Airport at physical address %lx\n", phys_addr);
+	printk(KERN_DEBUG PFX "Physical address %lx\n", phys_addr);
 	dev->base_addr = phys_addr;
 	card->vaddr = ioremap(phys_addr, AIRPORT_IO_LEN);
 	if (!card->vaddr) {
-		printk(PFX "ioremap() failed\n");
+		printk(KERN_ERR PFX "ioremap() failed\n");
 		goto failed;
 	}
 
-	hermes_struct_init(hw, (ulong)card->vaddr,
-			HERMES_MEM, HERMES_16BIT_REGSPACING);
+	hermes_struct_init(hw, card->vaddr, HERMES_16BIT_REGSPACING);
 		
 	/* Power up card */
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(mdev), 0, 1);
@@ -242,7 +240,7 @@
 	/* Reset it before we get the interrupt */
 	hermes_init(hw);
 
-	if (request_irq(dev->irq, orinoco_interrupt, 0, "Airport", dev)) {
+	if (request_irq(dev->irq, orinoco_interrupt, 0, dev->name, dev)) {
 		printk(KERN_ERR PFX "Couldn't get IRQ %d\n", dev->irq);
 		goto failed;
 	}
@@ -253,7 +251,7 @@
 		printk(KERN_ERR PFX "register_netdev() failed\n");
 		goto failed;
 	}
-	printk(KERN_DEBUG PFX "card registered for interface %s\n", dev->name);
+	printk(KERN_DEBUG PFX "Card registered for interface %s\n", dev->name);
 	card->ndev_registered = 1;
 	return 0;
  failed:
diff -Nru a/drivers/net/wireless/hermes.c b/drivers/net/wireless/hermes.c
--- a/drivers/net/wireless/hermes.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/hermes.c	2005-03-08 14:29:45 -05:00
@@ -48,6 +48,7 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/net.h>
 #include <asm/errno.h>
 
 #include "hermes.h"
@@ -67,8 +68,7 @@
  * Debugging helpers
  */
 
-#define IO_TYPE(hw)	((hw)->io_space ? "IO " : "MEM ")
-#define DMSG(stuff...) do {printk(KERN_DEBUG "hermes @ %s0x%x: " , IO_TYPE(hw), hw->iobase); \
+#define DMSG(stuff...) do {printk(KERN_DEBUG "hermes @ %p: " , hw->iobase); \
 			printk(stuff);} while (0)
 
 #undef HERMES_DEBUG
@@ -123,11 +123,9 @@
  * Function definitions
  */
 
-void hermes_struct_init(hermes_t *hw, ulong address,
-			int io_space, int reg_spacing)
+void hermes_struct_init(hermes_t *hw, void __iomem *address, int reg_spacing)
 {
 	hw->iobase = address;
-	hw->io_space = io_space;
 	hw->reg_spacing = reg_spacing;
 	hw->inten = 0x0;
 
@@ -200,9 +198,9 @@
 	}
 		
 	if (! (reg & HERMES_EV_CMD)) {
-		printk(KERN_ERR "hermes @ %s0x%lx: " 
+		printk(KERN_ERR "hermes @ %p: " 
 		       "Timeout waiting for card to reset (reg=0x%04x)!\n",
-		       IO_TYPE(hw), hw->iobase, reg);
+		       hw->iobase, reg);
 		err = -ETIMEDOUT;
 		goto out;
 	}
@@ -235,13 +233,16 @@
 	err = hermes_issue_cmd(hw, cmd, parm0);
 	if (err) {
 		if (! hermes_present(hw)) {
-			printk(KERN_WARNING "hermes @ %s0x%lx: "
-			       "Card removed while issuing command.\n",
-			       IO_TYPE(hw), hw->iobase);
+			if (net_ratelimit())
+				printk(KERN_WARNING "hermes @ %p: "
+				       "Card removed while issuing command "
+				       "0x%04x.\n", hw->iobase, cmd);
 			err = -ENODEV;
 		} else 
-			printk(KERN_ERR "hermes @ %s0x%lx: Error %d issuing command.\n",
-			       IO_TYPE(hw), hw->iobase, err);
+			if (net_ratelimit())
+				printk(KERN_ERR "hermes @ %p: "
+				       "Error %d issuing command 0x%04x.\n",
+				       hw->iobase, err, cmd);
 		goto out;
 	}
 
@@ -254,17 +255,16 @@
 	}
 
 	if (! hermes_present(hw)) {
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
-		       "Card removed while waiting for command completion.\n",
-		       IO_TYPE(hw), hw->iobase);
+		printk(KERN_WARNING "hermes @ %p: Card removed "
+		       "while waiting for command 0x%04x completion.\n",
+		       hw->iobase, cmd);
 		err = -ENODEV;
 		goto out;
 	}
 		
 	if (! (reg & HERMES_EV_CMD)) {
-		printk(KERN_ERR "hermes @ %s0x%lx: "
-		       "Timeout waiting for command completion.\n",
-		       IO_TYPE(hw), hw->iobase);
+		printk(KERN_ERR "hermes @ %p: Timeout waiting for "
+		       "command 0x%04x completion.\n", hw->iobase, cmd);
 		err = -ETIMEDOUT;
 		goto out;
 	}
@@ -309,16 +309,16 @@
 	}
 	
 	if (! hermes_present(hw)) {
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
+		printk(KERN_WARNING "hermes @ %p: "
 		       "Card removed waiting for frame allocation.\n",
-		       IO_TYPE(hw), hw->iobase);
+		       hw->iobase);
 		return -ENODEV;
 	}
 		
 	if (! (reg & HERMES_EV_ALLOC)) {
-		printk(KERN_ERR "hermes @ %s0x%lx: "
+		printk(KERN_ERR "hermes @ %p: "
 		       "Timeout waiting for frame allocation\n",
-		       IO_TYPE(hw), hw->iobase);
+		       hw->iobase);
 		return -ETIMEDOUT;
 	}
 
@@ -383,12 +383,17 @@
 		reg = hermes_read_reg(hw, oreg);
 	}
 
-	if (reg & HERMES_OFFSET_BUSY) {
-		return -ETIMEDOUT;
-	}
+	if (reg != offset) {
+		printk(KERN_ERR "hermes @ %p: BAP%d offset %s: "
+		       "reg=0x%x id=0x%x offset=0x%x\n", hw->iobase, bap,
+		       (reg & HERMES_OFFSET_BUSY) ? "timeout" : "error",
+		       reg, id, offset);
+
+		if (reg & HERMES_OFFSET_BUSY) {
+			return -ETIMEDOUT;
+		}
 
-	if (reg & HERMES_OFFSET_ERR) {
-		return -EIO;
+		return -EIO;		/* error or wrong offset */
 	}
 
 	return 0;
@@ -476,7 +481,7 @@
 	rlength = hermes_read_reg(hw, dreg);
 
 	if (! rlength)
-		return -ENOENT;
+		return -ENODATA;
 
 	rtype = hermes_read_reg(hw, dreg);
 
@@ -484,14 +489,13 @@
 		*length = rlength;
 
 	if (rtype != rid)
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
-		       "hermes_read_ltv(): rid  (0x%04x) does not match type (0x%04x)\n",
-		       IO_TYPE(hw), hw->iobase, rid, rtype);
+		printk(KERN_WARNING "hermes @ %p: %s(): "
+		       "rid (0x%04x) does not match type (0x%04x)\n",
+		       hw->iobase, __FUNCTION__, rid, rtype);
 	if (HERMES_RECLEN_TO_BYTES(rlength) > bufsize)
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
+		printk(KERN_WARNING "hermes @ %p: "
 		       "Truncating LTV record from %d to %d bytes. "
-		       "(rid=0x%04x, len=0x%04x)\n",
-		       IO_TYPE(hw), hw->iobase,
+		       "(rid=0x%04x, len=0x%04x)\n", hw->iobase,
 		       HERMES_RECLEN_TO_BYTES(rlength), bufsize, rid, rlength);
 
 	nwords = min((unsigned)rlength - 1, bufsize / 2);
diff -Nru a/drivers/net/wireless/hermes.h b/drivers/net/wireless/hermes.h
--- a/drivers/net/wireless/hermes.h	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/hermes.h	2005-03-08 14:29:45 -05:00
@@ -340,14 +340,11 @@
 #ifdef __KERNEL__
 
 /* Timeouts */
-#define HERMES_BAP_BUSY_TIMEOUT (500) /* In iterations of ~1us */
+#define HERMES_BAP_BUSY_TIMEOUT (10000) /* In iterations of ~1us */
 
 /* Basic control structure */
 typedef struct hermes {
-	unsigned long iobase;
-	int io_space; /* 1 if we IO-mapped IO, 0 for memory-mapped IO? */
-#define HERMES_IO	1
-#define HERMES_MEM	0
+	void __iomem *iobase;
 	int reg_spacing;
 #define HERMES_16BIT_REGSPACING	0
 #define HERMES_32BIT_REGSPACING	1
@@ -362,21 +359,15 @@
 } hermes_t;
 
 /* Register access convenience macros */
-#define hermes_read_reg(hw, off) ((hw)->io_space ? \
-	inw((hw)->iobase + ( (off) << (hw)->reg_spacing )) : \
-	readw((hw)->iobase + ( (off) << (hw)->reg_spacing )))
-#define hermes_write_reg(hw, off, val) do { \
-	if ((hw)->io_space) \
-		outw_p((val), (hw)->iobase + ((off) << (hw)->reg_spacing)); \
-	else \
-		writew((val), (hw)->iobase + ((off) << (hw)->reg_spacing)); \
-	} while (0)
+#define hermes_read_reg(hw, off) \
+	(ioread16((hw)->iobase + ( (off) << (hw)->reg_spacing )))
+#define hermes_write_reg(hw, off, val) \
+	(iowrite16((val), (hw)->iobase + ((off) << (hw)->reg_spacing)))
 #define hermes_read_regn(hw, name) hermes_read_reg((hw), HERMES_##name)
 #define hermes_write_regn(hw, name, val) hermes_write_reg((hw), HERMES_##name, (val))
 
 /* Function prototypes */
-void hermes_struct_init(hermes_t *hw, ulong address, int io_space,
-			int reg_spacing);
+void hermes_struct_init(hermes_t *hw, void __iomem *address, int reg_spacing);
 int hermes_init(hermes_t *hw);
 int hermes_docmd_wait(hermes_t *hw, u16 cmd, u16 parm0,
 		      struct hermes_response *resp);
@@ -430,41 +421,13 @@
 static inline void hermes_read_words(struct hermes *hw, int off, void *buf, unsigned count)
 {
 	off = off << hw->reg_spacing;
-
-	if (hw->io_space) {
-		insw(hw->iobase + off, buf, count);
-	} else {
-		unsigned i;
-		u16 *p;
-
-		/* This needs to *not* byteswap (like insw()) but
-		 * readw() does byteswap hence the conversion.  I hope
-		 * gcc is smart enough to fold away the two swaps on
-		 * big-endian platforms. */
-		for (i = 0, p = buf; i < count; i++) {
-			*p++ = cpu_to_le16(readw(hw->iobase + off));
-		}
-	}
+	ioread16_rep(hw->iobase + off, buf, count);
 }
 
 static inline void hermes_write_words(struct hermes *hw, int off, const void *buf, unsigned count)
 {
 	off = off << hw->reg_spacing;
-
-	if (hw->io_space) {
-		outsw(hw->iobase + off, buf, count);
-	} else {
-		unsigned i;
-		const u16 *p;
-
-		/* This needs to *not* byteswap (like outsw()) but
-		 * writew() does byteswap hence the conversion.  I
-		 * hope gcc is smart enough to fold away the two swaps
-		 * on big-endian platforms. */
-		for (i = 0, p = buf; i < count; i++) {
-			writew(le16_to_cpu(*p++), hw->iobase + off);
-		}
-	}
+	iowrite16_rep(hw->iobase + off, buf, count);
 }
 
 static inline void hermes_clear_words(struct hermes *hw, int off, unsigned count)
@@ -473,13 +436,8 @@
 
 	off = off << hw->reg_spacing;
 
-	if (hw->io_space) {
-		for (i = 0; i < count; i++)
-			outw(0, hw->iobase + off);
-	} else {
-		for (i = 0; i < count; i++)
-			writew(0, hw->iobase + off);
-	}
+	for (i = 0; i < count; i++)
+		iowrite16(0, hw->iobase + off);
 }
 
 #define HERMES_READ_RECORD(hw, bap, rid, buf) \
diff -Nru a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/orinoco.c	2005-03-08 14:29:45 -05:00
@@ -393,6 +393,29 @@
  *	  in the rx_dropped statistics.
  *	o Provided a module parameter to suppress linkstatus messages.
  *
+ * v0.13e -> v0.14alpha1 - 30 Sep 2003 - David Gibson
+ *	o Replaced priv->connected logic with netif_carrier_on/off()
+ *	  calls.
+ *	o Remove has_ibss_any and never set the CREATEIBSS RID when
+ *	  the ESSID is empty.  Too many firmwares break if we do.
+ *	o 2.6 merges: Replace pdev->slot_name with pci_name(), remove
+ *	  __devinitdata from PCI ID tables, use free_netdev().
+ *	o Enabled shared-key authentication for Agere firmware (from
+ *	  Robert J. Moore <Robert.J.Moore AT allanbank.com>
+ *	o Move netif_wake_queue() (back) to the Tx completion from the
+ *	  ALLOC event.  This seems to prevent/mitigate the rolling
+ *	  error -110 problems at least on some Intersil firmwares.
+ *	  Theoretically reduces performance, but I can't measure it.
+ *	  Patch from Andrew Tridgell <tridge AT samba.org>
+ *
+ * v0.14alpha1 -> v0.14alpha2 - 20 Oct 2003 - David Gibson
+ *	o Correctly turn off shared-key authentication when requested
+ *	  (bugfix from Robert J. Moore).
+ *	o Correct airport sleep interfaces for current 2.6 kernels.
+ *	o Add code for key change without disabling/enabling the MAC
+ *	  port.  This is supposed to allow 802.1x to work sanely, but
+ *	  doesn't seem to yet.
+ *
  * TODO
  *	o New wireless extensions API (patch from Moustafa
  *	  Youssef, updated by Jim Carter and Pavel Roskin).
@@ -461,12 +484,14 @@
 /* Level of debugging. Used in the macros in orinoco.h */
 #ifdef ORINOCO_DEBUG
 int orinoco_debug = ORINOCO_DEBUG;
-module_param(orinoco_debug, int, 0);
+module_param(orinoco_debug, int, 0644);
+MODULE_PARM_DESC(orinoco_debug, "Debug level");
 EXPORT_SYMBOL(orinoco_debug);
 #endif
 
 static int suppress_linkstatus; /* = 0 */
-module_param(suppress_linkstatus, bool, 0);
+module_param(suppress_linkstatus, bool, 0644);
+MODULE_PARM_DESC(suppress_linkstatus, "Don't log link status changes");
 
 /********************************************************************/
 /* Compile time configuration and compatibility stuff               */
@@ -784,7 +809,7 @@
 		return 1;
 	}
 
-	if (! priv->connected) {
+	if (! netif_carrier_ok(dev)) {
 		/* Oops, the firmware hasn't established a connection,
                    silently drop the packet (this seems to be the
                    safest approach). */
@@ -805,8 +830,9 @@
  	desc.tx_control = cpu_to_le16(HERMES_TXCTRL_TX_OK | HERMES_TXCTRL_TX_EX);
 	err = hermes_bap_pwrite(hw, USER_BAP, &desc, sizeof(desc), txfid, 0);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d writing Tx descriptor to BAP\n",
-		       dev->name, err);
+		if (net_ratelimit())
+			printk(KERN_ERR "%s: Error %d writing Tx descriptor "
+			       "to BAP\n", dev->name, err);
 		stats->tx_errors++;
 		goto fail;
 	}
@@ -836,8 +862,9 @@
 		err  = hermes_bap_pwrite(hw, USER_BAP, &hdr, sizeof(hdr),
 					 txfid, HERMES_802_3_OFFSET);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d writing packet header to BAP\n",
-			       dev->name, err);
+			if (net_ratelimit())
+				printk(KERN_ERR "%s: Error %d writing packet "
+				       "header to BAP\n", dev->name, err);
 			stats->tx_errors++;
 			goto fail;
 		}
@@ -897,8 +924,6 @@
 			printk(KERN_WARNING "%s: Allocate event on unexpected fid (%04X)\n",
 			       dev->name, fid);
 		return;
-	} else {
-		netif_wake_queue(dev);
 	}
 
 	hermes_write_regn(hw, ALLOCFID, DUMMY_FID);
@@ -911,6 +936,8 @@
 
 	stats->tx_packets++;
 
+	netif_wake_queue(dev);
+
 	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);
 }
 
@@ -937,6 +964,7 @@
 	
 	stats->tx_errors++;
 
+	netif_wake_queue(dev);
 	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);
 }
 
@@ -962,15 +990,17 @@
 
 /* Does the frame have a SNAP header indicating it should be
  * de-encapsulated to Ethernet-II? */
-static inline int is_ethersnap(struct header_struct *hdr)
+static inline int is_ethersnap(void *_hdr)
 {
+	u8 *hdr = _hdr;
+
 	/* We de-encapsulate all packets which, a) have SNAP headers
 	 * (i.e. SSAP=DSAP=0xaa and CTRL=0x3 in the 802.2 LLC header
 	 * and where b) the OUI of the SNAP header is 00:00:00 or
 	 * 00:00:f8 - we need both because different APs appear to use
 	 * different OUIs for some reason */
-	return (memcmp(&hdr->dsap, &encaps_hdr, 5) == 0)
-		&& ( (hdr->oui[2] == 0x00) || (hdr->oui[2] == 0xf8) );
+	return (memcmp(hdr, &encaps_hdr, 5) == 0)
+		&& ( (hdr[5] == 0x00) || (hdr[5] == 0xf8) );
 }
 
 static inline void orinoco_spy_gather(struct net_device *dev, u_char *mac,
@@ -1269,6 +1299,7 @@
 	case HERMES_INQ_LINKSTATUS: {
 		struct hermes_linkstatus linkstatus;
 		u16 newstatus;
+		int connected;
 
 		if (len != sizeof(linkstatus)) {
 			printk(KERN_WARNING "%s: Unexpected size for linkstatus frame (%d bytes)\n",
@@ -1280,15 +1311,14 @@
 				  len / 2);
 		newstatus = le16_to_cpu(linkstatus.linkstatus);
 
-		if ( (newstatus == HERMES_LINKSTATUS_CONNECTED)
-		     || (newstatus == HERMES_LINKSTATUS_AP_CHANGE)
-		     || (newstatus == HERMES_LINKSTATUS_AP_IN_RANGE) )
-			priv->connected = 1;
-		else if ( (newstatus == HERMES_LINKSTATUS_NOT_CONNECTED)
-			  || (newstatus == HERMES_LINKSTATUS_DISCONNECTED)
-			  || (newstatus == HERMES_LINKSTATUS_AP_OUT_OF_RANGE)
-			  || (newstatus == HERMES_LINKSTATUS_ASSOC_FAILED) )
-			priv->connected = 0;
+		connected = (newstatus == HERMES_LINKSTATUS_CONNECTED)
+			|| (newstatus == HERMES_LINKSTATUS_AP_CHANGE)
+			|| (newstatus == HERMES_LINKSTATUS_AP_IN_RANGE);
+
+		if (connected)
+			netif_carrier_on(dev);
+		else
+			netif_carrier_off(dev);
 
 		if (newstatus != priv->last_linkstatus)
 			print_linkstatus(dev, newstatus);
@@ -1297,8 +1327,8 @@
 	}
 	break;
 	default:
-		printk(KERN_DEBUG "%s: Unknown information frame received "
-		       "(type %04x).\n", dev->name, type);
+		printk(KERN_DEBUG "%s: Unknown information frame received: "
+		       "type 0x%04x, length %d\n", dev->name, type, len);
 		/* We don't actually do anything about it */
 		break;
 	}
@@ -1307,7 +1337,7 @@
 static void __orinoco_ev_infdrop(struct net_device *dev, hermes_t *hw)
 {
 	if (net_ratelimit())
-		printk(KERN_WARNING "%s: Information frame lost.\n", dev->name);
+		printk(KERN_DEBUG "%s: Information frame lost.\n", dev->name);
 }
 
 /********************************************************************/
@@ -1366,8 +1396,8 @@
 	}
 	
 	/* firmware will have to reassociate */
+	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
-	priv->connected = 0;
 
 	return 0;
 }
@@ -1430,55 +1460,46 @@
 	return err;
 }
 
-static int __orinoco_hw_setup_wep(struct orinoco_private *priv)
+/* Change the WEP keys and/or the current keys.  Can be called
+ * either from __orinoco_hw_setup_wep() or directly from
+ * orinoco_ioctl_setiwencode().  In the later case the association
+ * with the AP is not broken (if the firmware can handle it),
+ * which is needed for 802.1x implementations. */
+static int __orinoco_hw_setup_wepkeys(struct orinoco_private *priv)
 {
 	hermes_t *hw = &priv->hw;
 	int err = 0;
-	int	master_wep_flag;
-	int	auth_flag;
 
 	switch (priv->firmware_type) {
-	case FIRMWARE_TYPE_AGERE: /* Agere style WEP */
-		if (priv->wep_on) {
-			err = hermes_write_wordrec(hw, USER_BAP,
-						   HERMES_RID_CNFTXKEY_AGERE,
-						   priv->tx_key);
-			if (err)
-				return err;
-			
-			err = HERMES_WRITE_RECORD(hw, USER_BAP,
-						  HERMES_RID_CNFWEPKEYS_AGERE,
-						  &priv->keys);
-			if (err)
-				return err;
-		}
+	case FIRMWARE_TYPE_AGERE:
+		err = HERMES_WRITE_RECORD(hw, USER_BAP,
+					  HERMES_RID_CNFWEPKEYS_AGERE,
+					  &priv->keys);
+		if (err)
+			return err;
 		err = hermes_write_wordrec(hw, USER_BAP,
-					   HERMES_RID_CNFWEPENABLED_AGERE,
-					   priv->wep_on);
+					   HERMES_RID_CNFTXKEY_AGERE,
+					   priv->tx_key);
 		if (err)
 			return err;
 		break;
-
-	case FIRMWARE_TYPE_INTERSIL: /* Intersil style WEP */
-	case FIRMWARE_TYPE_SYMBOL: /* Symbol style WEP */
-		master_wep_flag = 0;		/* Off */
-		if (priv->wep_on) {
+	case FIRMWARE_TYPE_INTERSIL:
+	case FIRMWARE_TYPE_SYMBOL:
+		{
 			int keylen;
 			int i;
 
-			/* Fudge around firmware weirdness */
+			/* Force uniform key length to work around firmware bugs */
 			keylen = le16_to_cpu(priv->keys[priv->tx_key].len);
 			
+			if (keylen > LARGE_KEY_SIZE) {
+				printk(KERN_ERR "%s: BUG: Key %d has oversize length %d.\n",
+				       priv->ndev->name, priv->tx_key, keylen);
+				return -E2BIG;
+			}
+
 			/* Write all 4 keys */
 			for(i = 0; i < ORINOCO_MAX_KEYS; i++) {
-/*  				int keylen = le16_to_cpu(priv->keys[i].len); */
-				
-				if (keylen > LARGE_KEY_SIZE) {
-					printk(KERN_ERR "%s: BUG: Key %d has oversize length %d.\n",
-					       priv->ndev->name, i, keylen);
-					return -E2BIG;
-				}
-
 				err = hermes_write_ltv(hw, USER_BAP,
 						       HERMES_RID_CNFDEFAULTKEY0 + i,
 						       HERMES_BYTES_TO_RECLEN(keylen),
@@ -1493,27 +1514,63 @@
 						   priv->tx_key);
 			if (err)
 				return err;
-			
-			if (priv->wep_restrict) {
-				auth_flag = 2;
-				master_wep_flag = 3;
-			} else {
-				/* Authentication is where Intersil and Symbol
-				 * firmware differ... */
-				auth_flag = 1;
-				if (priv->firmware_type == FIRMWARE_TYPE_SYMBOL)
-					master_wep_flag = 3; /* Symbol */ 
-				else 
-					master_wep_flag = 1; /* Intersil */
-			}
+		}
+		break;
+	}
 
+	return 0;
+}
+
+static int __orinoco_hw_setup_wep(struct orinoco_private *priv)
+{
+	hermes_t *hw = &priv->hw;
+	int err = 0;
+	int master_wep_flag;
+	int auth_flag;
+
+	if (priv->wep_on)
+		__orinoco_hw_setup_wepkeys(priv);
+
+	if (priv->wep_restrict)
+		auth_flag = HERMES_AUTH_SHARED_KEY;
+	else
+		auth_flag = HERMES_AUTH_OPEN;
+
+	switch (priv->firmware_type) {
+	case FIRMWARE_TYPE_AGERE: /* Agere style WEP */
+		if (priv->wep_on) {
+			/* Enable the shared-key authentication. */
+			err = hermes_write_wordrec(hw, USER_BAP,
+						   HERMES_RID_CNFAUTHENTICATION_AGERE,
+						   auth_flag);
+		}
+		err = hermes_write_wordrec(hw, USER_BAP,
+					   HERMES_RID_CNFWEPENABLED_AGERE,
+					   priv->wep_on);
+		if (err)
+			return err;
+		break;
+
+	case FIRMWARE_TYPE_INTERSIL: /* Intersil style WEP */
+	case FIRMWARE_TYPE_SYMBOL: /* Symbol style WEP */
+		if (priv->wep_on) {
+			if (priv->wep_restrict ||
+			    (priv->firmware_type == FIRMWARE_TYPE_SYMBOL))
+				master_wep_flag = HERMES_WEP_PRIVACY_INVOKED |
+						  HERMES_WEP_EXCL_UNENCRYPTED;
+			else
+				master_wep_flag = HERMES_WEP_PRIVACY_INVOKED;
 
 			err = hermes_write_wordrec(hw, USER_BAP,
 						   HERMES_RID_CNFAUTHENTICATION,
 						   auth_flag);
 			if (err)
 				return err;
-		}
+		} else
+			master_wep_flag = 0;
+
+		if (priv->iw_mode == IW_MODE_MONITOR)
+			master_wep_flag |= HERMES_WEP_HOST_DECRYPT;
 
 		/* Master WEP setting : on/off */
 		err = hermes_write_wordrec(hw, USER_BAP,
@@ -1523,13 +1580,6 @@
 			return err;	
 
 		break;
-
-	default:
-		if (priv->wep_on) {
-			printk(KERN_ERR "%s: WEP enabled, although not supported!\n",
-			       priv->ndev->name);
-			return -EINVAL;
-		}
 	}
 
 	return 0;
@@ -1574,21 +1624,26 @@
 	}
 
 	if (priv->has_ibss) {
-		err = hermes_write_wordrec(hw, USER_BAP,
-					   HERMES_RID_CNFCREATEIBSS,
-					   priv->createibss);
-		if (err) {
-			printk(KERN_ERR "%s: Error %d setting CREATEIBSS\n", dev->name, err);
-			return err;
-		}
+		u16 createibss;
 
-		if ((strlen(priv->desired_essid) == 0) && (priv->createibss)
-		   && (!priv->has_ibss_any)) {
+		if ((strlen(priv->desired_essid) == 0) && (priv->createibss)) {
 			printk(KERN_WARNING "%s: This firmware requires an "
 			       "ESSID in IBSS-Ad-Hoc mode.\n", dev->name);
 			/* With wvlan_cs, in this case, we would crash.
 			 * hopefully, this driver will behave better...
 			 * Jean II */
+			createibss = 0;
+		} else {
+			createibss = priv->createibss;
+		}
+		
+		err = hermes_write_wordrec(hw, USER_BAP,
+					   HERMES_RID_CNFCREATEIBSS,
+					   createibss);
+		if (err) {
+			printk(KERN_ERR "%s: Error %d setting CREATEIBSS\n",
+			       dev->name, err);
+			return err;
 		}
 	}
 
@@ -1785,7 +1840,8 @@
 		}
 		
 		if (p)
-			printk(KERN_WARNING "Multicast list is longer than mc_count\n");
+			printk(KERN_WARNING "%s: Multicast list is "
+			       "longer than mc_count\n", dev->name);
 
 		err = hermes_write_ltv(hw, USER_BAP, HERMES_RID_CNFGROUPADDRESSES,
 				       HERMES_BYTES_TO_RECLEN(priv->mc_count * ETH_ALEN),
@@ -1878,7 +1934,7 @@
 
 	priv->hw_unavailable++;
 	priv->last_linkstatus = 0xffff; /* firmware will have to reassociate */
-	priv->connected = 0;
+	netif_carrier_off(dev);
 
 	orinoco_unlock(priv, &flags);
 
@@ -2014,51 +2070,81 @@
 /* Initialization                                                   */
 /********************************************************************/
 
-struct sta_id {
+struct comp_id {
 	u16 id, variant, major, minor;
 } __attribute__ ((packed));
 
-static int determine_firmware_type(struct net_device *dev, struct sta_id *sta_id)
+static inline fwtype_t determine_firmware_type(struct comp_id *nic_id)
 {
-	/* FIXME: this is fundamentally broken */
-	unsigned int firmver = ((u32)sta_id->major << 16) | sta_id->minor;
-	
-	if (sta_id->variant == 1)
+	if (nic_id->id < 0x8000)
 		return FIRMWARE_TYPE_AGERE;
-	else if ((sta_id->variant == 2) &&
-		   ((firmver == 0x10001) || (firmver == 0x20001)))
+	else if (nic_id->id == 0x8000 && nic_id->major == 0)
 		return FIRMWARE_TYPE_SYMBOL;
 	else
 		return FIRMWARE_TYPE_INTERSIL;
 }
 
-static void determine_firmware(struct net_device *dev)
+/* Set priv->firmware type, determine firmware properties */
+static int determine_firmware(struct net_device *dev)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err;
-	struct sta_id sta_id;
+	struct comp_id nic_id, sta_id;
 	unsigned int firmver;
 	char tmp[SYMBOL_MAX_VER_LEN+1];
 
+	/* Get the hardware version */
+	err = HERMES_READ_RECORD(hw, USER_BAP, HERMES_RID_NICID, &nic_id);
+	if (err) {
+		printk(KERN_ERR "%s: Cannot read hardware identity: error %d\n",
+		       dev->name, err);
+		return err;
+	}
+
+	le16_to_cpus(&nic_id.id);
+	le16_to_cpus(&nic_id.variant);
+	le16_to_cpus(&nic_id.major);
+	le16_to_cpus(&nic_id.minor);
+	printk(KERN_DEBUG "%s: Hardware identity %04x:%04x:%04x:%04x\n",
+	       dev->name, nic_id.id, nic_id.variant,
+	       nic_id.major, nic_id.minor);
+
+	priv->firmware_type = determine_firmware_type(&nic_id);
+
 	/* Get the firmware version */
 	err = HERMES_READ_RECORD(hw, USER_BAP, HERMES_RID_STAID, &sta_id);
 	if (err) {
-		printk(KERN_WARNING "%s: Error %d reading firmware info. Wildly guessing capabilities...\n",
+		printk(KERN_ERR "%s: Cannot read station identity: error %d\n",
 		       dev->name, err);
-		memset(&sta_id, 0, sizeof(sta_id));
+		return err;
 	}
 
 	le16_to_cpus(&sta_id.id);
 	le16_to_cpus(&sta_id.variant);
 	le16_to_cpus(&sta_id.major);
 	le16_to_cpus(&sta_id.minor);
-	printk(KERN_DEBUG "%s: Station identity %04x:%04x:%04x:%04x\n",
+	printk(KERN_DEBUG "%s: Station identity  %04x:%04x:%04x:%04x\n",
 	       dev->name, sta_id.id, sta_id.variant,
 	       sta_id.major, sta_id.minor);
 
-	if (! priv->firmware_type)
-		priv->firmware_type = determine_firmware_type(dev, &sta_id);
+	switch (sta_id.id) {
+	case 0x15:
+		printk(KERN_ERR "%s: Primary firmware is active\n",
+		       dev->name);
+		return -ENODEV;
+	case 0x14b:
+		printk(KERN_ERR "%s: Tertiary firmware is active\n",
+		       dev->name);
+		return -ENODEV;
+	case 0x1f:	/* Intersil, Agere, Symbol Spectrum24 */
+	case 0x21:	/* Symbol Spectrum24 Trilogy */
+		break;
+	default:
+		printk(KERN_NOTICE "%s: Unknown station ID, please report\n",
+		       dev->name);
+		break;
+	}
 
 	/* Default capabilities */
 	priv->has_sensitivity = 1;
@@ -2066,7 +2152,6 @@
 	priv->has_preamble = 0;
 	priv->has_port3 = 1;
 	priv->has_ibss = 1;
-	priv->has_ibss_any = 0;
 	priv->has_wep = 0;
 	priv->has_big_wep = 0;
 
@@ -2075,14 +2160,12 @@
 	case FIRMWARE_TYPE_AGERE:
 		/* Lucent Wavelan IEEE, Lucent Orinoco, Cabletron RoamAbout,
 		   ELSA, Melco, HP, IBM, Dell 1150, Compaq 110/210 */
-		printk(KERN_DEBUG "%s: Looks like a Lucent/Agere firmware "
-		       "version %d.%02d\n", dev->name,
-		       sta_id.major, sta_id.minor);
+		snprintf(priv->fw_name, sizeof(priv->fw_name) - 1,
+			 "Lucent/Agere %d.%02d", sta_id.major, sta_id.minor);
 
 		firmver = ((unsigned long)sta_id.major << 16) | sta_id.minor;
 
 		priv->has_ibss = (firmver >= 0x60006);
-		priv->has_ibss_any = (firmver >= 0x60010);
 		priv->has_wep = (firmver >= 0x40020);
 		priv->has_big_wep = 1; /* FIXME: this is wrong - how do we tell
 					  Gold cards from the others? */
@@ -2121,14 +2204,15 @@
 			tmp[SYMBOL_MAX_VER_LEN] = '\0';
 		}
 
-		printk(KERN_DEBUG "%s: Looks like a Symbol firmware "
-		       "version [%s] (parsing to %X)\n", dev->name,
-		       tmp, firmver);
+		snprintf(priv->fw_name, sizeof(priv->fw_name) - 1,
+			 "Symbol %s", tmp);
 
 		priv->has_ibss = (firmver >= 0x20000);
 		priv->has_wep = (firmver >= 0x15012);
 		priv->has_big_wep = (firmver >= 0x20000);
-		priv->has_pm = (firmver >= 0x20000) && (firmver < 0x22000);
+		priv->has_pm = (firmver >= 0x20000 && firmver < 0x22000) || 
+			       (firmver >= 0x29000 && firmver < 0x30000) ||
+			       firmver >= 0x31000;
 		priv->has_preamble = (firmver >= 0x20000);
 		priv->ibss_port = 4;
 		/* Tested with Intel firmware : 0x20015 => Jean II */
@@ -2140,9 +2224,9 @@
 		 * different and less well tested */
 		/* D-Link MAC : 00:40:05:* */
 		/* Addtron MAC : 00:90:D1:* */
-		printk(KERN_DEBUG "%s: Looks like an Intersil firmware "
-		       "version %d.%d.%d\n", dev->name,
-		       sta_id.major, sta_id.minor, sta_id.variant);
+		snprintf(priv->fw_name, sizeof(priv->fw_name) - 1,
+			 "Intersil %d.%d.%d", sta_id.major, sta_id.minor,
+			 sta_id.variant);
 
 		firmver = ((unsigned long)sta_id.major << 16) |
 			((unsigned long)sta_id.minor << 8) | sta_id.variant;
@@ -2160,9 +2244,11 @@
 			priv->ibss_port = 1;
 		}
 		break;
-	default:
-		break;
 	}
+	printk(KERN_DEBUG "%s: Firmware determined as %s\n", dev->name,
+	       priv->fw_name);
+
+	return 0;
 }
 
 static int orinoco_init(struct net_device *dev)
@@ -2188,7 +2274,12 @@
 		goto out;
 	}
 
-	determine_firmware(dev);
+	err = determine_firmware(dev);
+	if (err != 0) {
+		printk(KERN_ERR "%s: Incompatible firmware, aborting\n",
+		       dev->name);
+		goto out;
+	}
 
 	if (priv->has_port3)
 		printk(KERN_DEBUG "%s: Ad-hoc demo mode supported\n", dev->name);
@@ -2388,13 +2479,18 @@
 				   * hardware */
 	INIT_WORK(&priv->reset_work, (void (*)(void *))orinoco_reset, dev);
 
+	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
-	priv->connected = 0;
 
 	return dev;
 
 }
 
+void free_orinocodev(struct net_device *dev)
+{
+	free_netdev(dev);
+}
+
 /********************************************************************/
 /* Wireless extensions                                              */
 /********************************************************************/
@@ -2686,11 +2782,17 @@
 	int err = 0;
 	char keybuf[ORINOCO_MAX_KEY_SIZE];
 	unsigned long flags;
-	
+
+	if (! priv->has_wep)
+		return -EOPNOTSUPP;
+
 	if (erq->pointer) {
-		/* We actually have a key to set */
-		if ( (erq->length < SMALL_KEY_SIZE) || (erq->length > ORINOCO_MAX_KEY_SIZE) )
-			return -EINVAL;
+		/* We actually have a key to set - check its length */
+		if (erq->length > LARGE_KEY_SIZE)
+			return -E2BIG;
+
+		if ( (erq->length > SMALL_KEY_SIZE) && !priv->has_big_wep )
+			return -E2BIG;
 		
 		if (copy_from_user(keybuf, erq->pointer, erq->length))
 			return -EFAULT;
@@ -2698,19 +2800,8 @@
 
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
-	
+
 	if (erq->pointer) {
-		if (erq->length > ORINOCO_MAX_KEY_SIZE) {
-			err = -E2BIG;
-			goto out;
-		}
-		
-		if ( (erq->length > LARGE_KEY_SIZE)
-		     || ( ! priv->has_big_wep && (erq->length > SMALL_KEY_SIZE))  ) {
-			err = -EINVAL;
-			goto out;
-		}
-		
 		if ((index < 0) || (index >= ORINOCO_MAX_KEYS))
 			index = priv->tx_key;
 
@@ -2721,7 +2812,7 @@
 			xlen = SMALL_KEY_SIZE;
 		} else
 			xlen = 0;
-		
+
 		/* Switch on WEP if off */
 		if ((!enable) && (xlen > 0)) {
 			setindex = index;
@@ -2745,10 +2836,9 @@
 			setindex = index;
 		}
 	}
-	
+
 	if (erq->flags & IW_ENCODE_DISABLED)
 		enable = 0;
-	/* Only for Prism2 & Symbol cards (so far) - Jean II */
 	if (erq->flags & IW_ENCODE_OPEN)
 		restricted = 0;
 	if (erq->flags & IW_ENCODE_RESTRICTED)
@@ -2761,6 +2851,15 @@
 		memcpy(priv->keys[index].data, keybuf, erq->length);
 	}
 	priv->tx_key = setindex;
+
+	/* Try fast key change if connected and only keys are changed */
+	if (priv->wep_on && enable && (priv->wep_restrict == restricted) &&
+	    netif_carrier_ok(dev)) {
+		err = __orinoco_hw_setup_wepkeys(priv);
+		/* No need to commit if successful */
+		goto out;
+	}
+
 	priv->wep_on = enable;
 	priv->wep_restrict = restricted;
 
@@ -2778,6 +2877,9 @@
 	char keybuf[ORINOCO_MAX_KEY_SIZE];
 	unsigned long flags;
 
+	if (! priv->has_wep)
+		return -EOPNOTSUPP;
+
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
@@ -2788,23 +2890,18 @@
 	if (! priv->wep_on)
 		erq->flags |= IW_ENCODE_DISABLED;
 	erq->flags |= index + 1;
-	
-	/* Only for symbol cards - Jean II */
-	if (priv->firmware_type != FIRMWARE_TYPE_AGERE) {
-		if(priv->wep_restrict)
-			erq->flags |= IW_ENCODE_RESTRICTED;
-		else
-			erq->flags |= IW_ENCODE_OPEN;
-	}
+
+	if (priv->wep_restrict)
+		erq->flags |= IW_ENCODE_RESTRICTED;
+	else
+		erq->flags |= IW_ENCODE_OPEN;
 
 	xlen = le16_to_cpu(priv->keys[index].len);
 
 	erq->length = xlen;
 
-	if (erq->pointer) {
-		memcpy(keybuf, priv->keys[index].data, ORINOCO_MAX_KEY_SIZE);
-	}
-	
+	memcpy(keybuf, priv->keys[index].data, ORINOCO_MAX_KEY_SIZE);
+
 	orinoco_unlock(priv, &flags);
 
 	if (erq->pointer) {
@@ -3045,8 +3142,9 @@
 			priv->mwo_robust = 0;
 		else {
 			if (frq->fixed)
-				printk(KERN_WARNING "%s: Fixed fragmentation not \
-supported on this firmware. Using MWO robust instead.\n", dev->name);
+				printk(KERN_WARNING "%s: Fixed fragmentation is "
+				       "not supported on this firmware. "
+				       "Using MWO robust instead.\n", dev->name);
 			priv->mwo_robust = 1;
 		}
 	} else {
@@ -3518,7 +3616,7 @@
 		}
 		/* Copy stats */
 		/* In theory, we should disable irqs while copying the stats
-		 * because the rx path migh update it in the middle...
+		 * because the rx path might update it in the middle...
 		 * Bah, who care ? - Jean II */
 		memcpy(&spy_stat, priv->spy_stat,
 		       sizeof(struct iw_quality) * IW_MAX_SPY);
@@ -3609,22 +3707,12 @@
 		break;
 
 	case SIOCSIWENCODE:
-		if (! priv->has_wep) {
-			err = -EOPNOTSUPP;
-			break;
-		}
-
 		err = orinoco_ioctl_setiwencode(dev, &wrq->u.encoding);
 		if (! err)
 			changed = 1;
 		break;
 
 	case SIOCGIWENCODE:
-		if (! priv->has_wep) {
-			err = -EOPNOTSUPP;
-			break;
-		}
-
 		if (! capable(CAP_NET_ADMIN)) {
 			err = -EPERM;
 			break;
@@ -4127,6 +4215,7 @@
 /********************************************************************/
 
 EXPORT_SYMBOL(alloc_orinocodev);
+EXPORT_SYMBOL(free_orinocodev);
 
 EXPORT_SYMBOL(__orinoco_up);
 EXPORT_SYMBOL(__orinoco_down);
diff -Nru a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
--- a/drivers/net/wireless/orinoco.h	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/orinoco.h	2005-03-08 14:29:45 -05:00
@@ -7,7 +7,7 @@
 #ifndef _ORINOCO_H
 #define _ORINOCO_H
 
-#define DRIVER_VERSION "0.13e"
+#define DRIVER_VERSION "0.14alpha2"
 
 #include <linux/types.h>
 #include <linux/spinlock.h>
@@ -30,6 +30,12 @@
 	char data[ORINOCO_MAX_KEY_SIZE];
 } __attribute__ ((packed));
 
+typedef enum {
+	FIRMWARE_TYPE_AGERE,
+	FIRMWARE_TYPE_INTERSIL,
+	FIRMWARE_TYPE_SYMBOL
+} fwtype_t;
+
 struct orinoco_private {
 	void *card;	/* Pointer to card dependent structure */
 	int (*hard_reset)(struct orinoco_private *);
@@ -42,7 +48,6 @@
 	/* driver state */
 	int open;
 	u16 last_linkstatus;
-	int connected;
 
 	/* Net device stuff */
 	struct net_device *ndev;
@@ -54,19 +59,22 @@
 	u16 txfid;
 
 	/* Capabilities of the hardware/firmware */
-	int firmware_type;
-#define FIRMWARE_TYPE_AGERE 1
-#define FIRMWARE_TYPE_INTERSIL 2
-#define FIRMWARE_TYPE_SYMBOL 3
-	int has_ibss, has_port3, has_ibss_any, ibss_port;
-	int has_wep, has_big_wep;
-	int has_mwo;
-	int has_pm;
-	int has_preamble;
-	int has_sensitivity;
+	fwtype_t firmware_type;
+	char fw_name[32];
+	int ibss_port;
 	int nicbuf_size;
 	u16 channel_mask;
-	int broken_disableport;
+
+	/* Boolean capabilities */
+	unsigned int has_ibss:1;
+	unsigned int has_port3:1;
+	unsigned int has_wep:1;
+	unsigned int has_big_wep:1;
+	unsigned int has_mwo:1;
+	unsigned int has_pm:1;
+	unsigned int has_preamble:1;
+	unsigned int has_sensitivity:1;
+	unsigned int broken_disableport:1;
 
 	/* Configuration paramaters */
 	u32 iw_mode;
@@ -108,6 +116,7 @@
 
 extern struct net_device *alloc_orinocodev(int sizeof_card,
 					   int (*hard_reset)(struct orinoco_private *));
+extern void free_orinocodev(struct net_device *dev);
 extern int __orinoco_up(struct net_device *dev);
 extern int __orinoco_down(struct net_device *dev);
 extern int orinoco_stop(struct net_device *dev);
@@ -127,7 +136,7 @@
 {
 	spin_lock_irqsave(&priv->lock, *flags);
 	if (priv->hw_unavailable) {
-		printk(KERN_DEBUG "orinoco_lock() called with hw_unavailable (dev=%p)\n",
+		DEBUG(1, "orinoco_lock() called with hw_unavailable (dev=%p)\n",
 		       priv->ndev);
 		spin_unlock_irqrestore(&priv->lock, *flags);
 		return -EBUSY;
diff -Nru a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/orinoco_cs.c	2005-03-08 14:29:45 -05:00
@@ -57,8 +57,8 @@
 /* Some D-Link cards have buggy CIS. They do work at 5v properly, but
  * don't have any CIS entry for it. This workaround it... */
 static int ignore_cis_vcc; /* = 0 */
-
 module_param(ignore_cis_vcc, int, 0);
+MODULE_PARM_DESC(ignore_cis_vcc, "Allow voltage mismatch between card and socket");
 
 /********************************************************************/
 /* Magic constants						    */
@@ -128,6 +128,7 @@
 	if (err)
 		return err;
 
+	msleep(100);
 	clear_bit(0, &card->hard_reset_in_progress);
 
 	return 0;
@@ -166,9 +167,10 @@
 	link->priv = dev;
 
 	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
+	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
 	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
-	link->irq.Handler = NULL;
+	link->irq.Handler = orinoco_interrupt;
+	link->irq.Instance = dev; 
 
 	/* General socket configuration defaults can go here.  In this
 	 * client, we assume very little, and rely on the CIS for
@@ -235,7 +237,7 @@
 		      dev);
 		unregister_netdev(dev);
 	}
-	free_netdev(dev);
+	free_orinocodev(dev);
 }				/* orinoco_cs_detach */
 
 /*
@@ -262,6 +264,7 @@
 	cisinfo_t info;
 	tuple_t tuple;
 	cisparse_t parse;
+	void __iomem *mem;
 
 	CS_CHECK(ValidateCIS, pcmcia_validate_cis(handle, &info));
 
@@ -308,8 +311,8 @@
 		cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
 		cistpl_cftable_entry_t dflt = { .index = 0 };
 
-		if (pcmcia_get_tuple_data(handle, &tuple) != 0 ||
-				pcmcia_parse_tuple(handle, &tuple, &parse) != 0)
+		if ( (pcmcia_get_tuple_data(handle, &tuple) != 0)
+		    || (pcmcia_parse_tuple(handle, &tuple, &parse) != 0))
 			goto next_entry;
 
 		if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
@@ -348,8 +351,7 @@
 			    dflt.vpp1.param[CISTPL_POWER_VNOM] / 10000;
 		
 		/* Do we need to allocate an interrupt? */
-		if (cfg->irq.IRQInfo1 || dflt.irq.IRQInfo1)
-			link->conf.Attributes |= CONF_ENABLE_IRQ;
+		link->conf.Attributes |= CONF_ENABLE_IRQ;
 
 		/* IO window settings */
 		link->io.NumPorts1 = link->io.NumPorts2 = 0;
@@ -390,7 +392,7 @@
 		last_ret = pcmcia_get_next_tuple(handle, &tuple);
 		if (last_ret  == CS_NO_MORE_ITEMS) {
 			printk(KERN_ERR PFX "GetNextTuple(): No matching "
-			       "CIS configuration, maybe you need the "
+			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=1 parameter.\n");
 			goto cs_failed;
 		}
@@ -401,20 +403,16 @@
 	 * a handler to the interrupt, unless the 'Handler' member of
 	 * the irq structure is initialized.
 	 */
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
-		link->irq.IRQInfo1 = IRQ_LEVEL_ID;
-  		link->irq.Handler = orinoco_interrupt; 
-  		link->irq.Instance = dev; 
-		
-		CS_CHECK(RequestIRQ, pcmcia_request_irq(link->handle, &link->irq));
-	}
+	CS_CHECK(RequestIRQ, pcmcia_request_irq(link->handle, &link->irq));
 
 	/* We initialize the hermes structure before completing PCMCIA
 	 * configuration just in case the interrupt handler gets
 	 * called. */
-	hermes_struct_init(hw, link->io.BasePort1,
-				HERMES_IO, HERMES_16BIT_REGSPACING);
+	mem = ioport_map(link->io.BasePort1, link->io.NumPorts1);
+	if (!mem)
+		goto cs_failed;
+
+	hermes_struct_init(hw, mem, HERMES_16BIT_REGSPACING);
 
 	/*
 	 * This actually configures the PCMCIA socket -- setting up
@@ -430,8 +428,6 @@
 	SET_MODULE_OWNER(dev);
 	card->node.major = card->node.minor = 0;
 
-	/* register_netdev will give us an ethX name */
-	dev->name[0] = '\0';
 	SET_NETDEV_DEV(dev, &handle_to_dev(handle));
 	/* Tell the stack we exist */
 	if (register_netdev(dev) != 0) {
@@ -454,8 +450,7 @@
 	if (link->conf.Vpp1)
 		printk(", Vpp %d.%d", link->conf.Vpp1 / 10,
 		       link->conf.Vpp1 % 10);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq.AssignedIRQ);
+	printk(", irq %d", link->irq.AssignedIRQ);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1 + link->io.NumPorts1 - 1);
@@ -498,6 +493,8 @@
 	if (link->irq.AssignedIRQ)
 		pcmcia_release_irq(link->handle, &link->irq);
 	link->state &= ~DEV_CONFIG;
+	if (priv->hw.iobase)
+		ioport_unmap(priv->hw.iobase);
 }				/* orinoco_cs_release */
 
 /*
@@ -519,12 +516,12 @@
 	case CS_EVENT_CARD_REMOVAL:
 		link->state &= ~DEV_PRESENT;
 		if (link->state & DEV_CONFIG) {
-			orinoco_lock(priv, &flags);
+			unsigned long flags;
 
+			spin_lock_irqsave(&priv->lock, flags);
 			netif_device_detach(dev);
 			priv->hw_unavailable++;
-
-			orinoco_unlock(priv, &flags);
+			spin_unlock_irqrestore(&priv->lock, flags);
 		}
 		break;
 
diff -Nru a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/orinoco_pci.c
--- a/drivers/net/wireless/orinoco_pci.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/orinoco_pci.c	2005-03-08 14:29:45 -05:00
@@ -129,6 +129,11 @@
 #define HERMES_PCI_COR_OFFT	(500)		/* ms */
 #define HERMES_PCI_COR_BUSYT	(500)		/* ms */
 
+/* Orinoco PCI specific data */
+struct orinoco_pci_card {
+	void __iomem *pci_ioaddr;
+};
+
 /*
  * Do a soft reset of the PCI card using the Configuration Option Register
  * We need this to get going...
@@ -151,25 +156,11 @@
 
 	/* Assert the reset until the card notice */
 	hermes_write_regn(hw, PCI_COR, HERMES_PCI_COR_MASK);
-	printk(KERN_NOTICE "Reset done");
-	timeout = jiffies + (HERMES_PCI_COR_ONT * HZ / 1000);
-	while(time_before(jiffies, timeout)) {
-		printk(".");
-		mdelay(1);
-	}
-	printk(";\n");
-	//mdelay(HERMES_PCI_COR_ONT);
+	mdelay(HERMES_PCI_COR_ONT);
 
 	/* Give time for the card to recover from this hard effort */
 	hermes_write_regn(hw, PCI_COR, 0x0000);
-	printk(KERN_NOTICE "Clear Reset");
-	timeout = jiffies + (HERMES_PCI_COR_OFFT * HZ / 1000);
-	while(time_before(jiffies, timeout)) {
-		printk(".");
-		mdelay(1);
-	}
-	printk(";\n");
-	//mdelay(HERMES_PCI_COR_OFFT);
+	mdelay(HERMES_PCI_COR_OFFT);
 
 	/* The card is ready when it's no longer busy */
 	timeout = jiffies + (HERMES_PCI_COR_BUSYT * HZ / 1000);
@@ -178,12 +169,12 @@
 		mdelay(1);
 		reg = hermes_read_regn(hw, CMD);
 	}
-	/* Did we timeout ? */
-	if(time_after_eq(jiffies, timeout)) {
+
+	/* Still busy? */
+	if (reg & HERMES_CMD_BUSY) {
 		printk(KERN_ERR PFX "Busy timeout\n");
 		return -ETIMEDOUT;
 	}
-	printk(KERN_NOTICE "pci_cor : reg = 0x%X - %lX - %lX\n", reg, timeout, jiffies);
 
 	return 0;
 }
@@ -196,84 +187,93 @@
 {
 	int err = 0;
 	unsigned long pci_iorange;
-	u16 *pci_ioaddr = NULL;
+	u16 __iomem *pci_ioaddr = NULL;
 	unsigned long pci_iolen;
 	struct orinoco_private *priv = NULL;
+	struct orinoco_pci_card *card;
 	struct net_device *dev = NULL;
 
 	err = pci_enable_device(pdev);
-	if (err)
-		return -EIO;
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return err;
+	}
+
+	err = pci_request_regions(pdev, DRIVER_NAME);
+	if (err != 0) {
+		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		goto fail_resources;
+	}
 
 	/* Resource 0 is mapped to the hermes registers */
 	pci_iorange = pci_resource_start(pdev, 0);
 	pci_iolen = pci_resource_len(pdev, 0);
 	pci_ioaddr = ioremap(pci_iorange, pci_iolen);
-	if (! pci_iorange)
-		goto fail;
+	if (!pci_iorange) {
+		printk(KERN_ERR PFX "Cannot remap hardware registers\n");
+		goto fail_map;
+	}
 
 	/* Allocate network device */
-	dev = alloc_orinocodev(0, NULL);
+	dev = alloc_orinocodev(sizeof(*card), orinoco_pci_cor_reset);
 	if (! dev) {
 		err = -ENOMEM;
-		goto fail;
+		goto fail_alloc;
 	}
 
 	priv = netdev_priv(dev);
-	dev->base_addr = (unsigned long) pci_ioaddr;
+	card = priv->card;
+	card->pci_ioaddr = pci_ioaddr;
 	dev->mem_start = pci_iorange;
 	dev->mem_end = pci_iorange + pci_iolen - 1;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	printk(KERN_DEBUG PFX
-	       "Detected Orinoco/Prism2 PCI device at %s, mem:0x%lX to 0x%lX -> 0x%p, irq:%d\n",
-	       pci_name(pdev), dev->mem_start, dev->mem_end, pci_ioaddr, pdev->irq);
+	hermes_struct_init(&priv->hw, pci_ioaddr, HERMES_32BIT_REGSPACING);
 
-	hermes_struct_init(&priv->hw, dev->base_addr,
-			   HERMES_MEM, HERMES_32BIT_REGSPACING);
-	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG PFX "Detected device %s, mem:0x%lx-0x%lx, irq %d\n",
+	       pci_name(pdev), dev->mem_start, dev->mem_end, pdev->irq);
 
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n",
-		       pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
-		goto fail;
+		goto fail_irq;
 	}
 	dev->irq = pdev->irq;
 
 	/* Perform a COR reset to start the card */
-	if(orinoco_pci_cor_reset(priv) != 0) {
-		printk(KERN_ERR "%s: Failed to start the card\n", dev->name);
-		err = -ETIMEDOUT;
+	err = orinoco_pci_cor_reset(priv);
+	if (err) {
+		printk(KERN_ERR PFX "Initial reset failed\n");
 		goto fail;
 	}
 
-	/* Override the normal firmware detection - the Prism 2.5 PCI
-	 * cards look like Lucent firmware but are actually Intersil */
-	priv->firmware_type = FIRMWARE_TYPE_INTERSIL;
-
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR "%s: Failed to register net device\n", dev->name);
+		printk(KERN_ERR PFX "Failed to register net device\n");
 		goto fail;
 	}
 
+	pci_set_drvdata(pdev, dev);
+
 	return 0;
 
  fail:
-	if (dev) {
-		if (dev->irq)
-			free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 
-		free_netdev(dev);
-	}
+ fail_irq:
+	pci_set_drvdata(pdev, NULL);
+	free_orinocodev(dev);
 
-	if (pci_ioaddr)
-		iounmap(pci_ioaddr);
+ fail_alloc:
+	iounmap(pci_ioaddr);
 
+ fail_map:
+	pci_release_regions(pdev);
+
+ fail_resources:
 	pci_disable_device(pdev);
 
 	return err;
@@ -283,18 +283,14 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct orinoco_private *priv = netdev_priv(dev);
+	struct orinoco_pci_card *card = priv->card;
 
 	unregister_netdev(dev);
-
-	if (dev->irq)
-		free_irq(dev->irq, dev);
-
-	if (priv->hw.iobase)
-		iounmap((unsigned char *) priv->hw.iobase);
-
+	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
-	free_netdev(dev);
-
+	free_orinocodev(dev);
+	iounmap(card->pci_ioaddr);
+	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 }
 
@@ -326,6 +322,9 @@
 	
 	orinoco_unlock(priv, &flags);
 
+	pci_save_state(pdev);
+	pci_set_power_state(pdev, 3);
+
 	return 0;
 }
 
@@ -338,6 +337,9 @@
 
 	printk(KERN_DEBUG "%s: Orinoco-PCI waking up\n", dev->name);
 
+	pci_set_power_state(pdev, 0);
+	pci_restore_state(pdev);
+
 	err = orinoco_reinit_firmware(dev);
 	if (err) {
 		printk(KERN_ERR "%s: Error %d re-initializing firmware on orinoco_pci_resume()\n",
@@ -368,6 +370,8 @@
 	{0x1260, 0x3872, PCI_ANY_ID, PCI_ANY_ID,},
 	/* Intersil Prism 2.5 */
 	{0x1260, 0x3873, PCI_ANY_ID, PCI_ANY_ID,},
+	/* Samsung MagicLAN SWL-2210P */
+	{0x167d, 0xa000, PCI_ANY_ID, PCI_ANY_ID,},
 	{0,},
 };
 
diff -Nru a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/orinoco_plx.c
--- a/drivers/net/wireless/orinoco_plx.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/orinoco_plx.c	2005-03-08 14:29:45 -05:00
@@ -142,146 +142,199 @@
 #include "hermes.h"
 #include "orinoco.h"
 
-#define COR_OFFSET	(0x3e0/2) /* COR attribute offset of Prism2 PC card */
+#define COR_OFFSET	(0x3e0)	/* COR attribute offset of Prism2 PC card */
 #define COR_VALUE	(COR_LEVEL_REQ | COR_FUNC_ENA) /* Enable PC card with interrupt in level trigger */
+#define COR_RESET     (0x80)	/* reset bit in the COR register */
+#define PLX_RESET_TIME	(500)	/* milliseconds */
 
 #define PLX_INTCSR		0x4c /* Interrupt Control & Status Register */
 #define PLX_INTCSR_INTEN	(1<<6) /* Interrupt Enable bit */
 
-static const u16 cis_magic[] = {
-	0x0001, 0x0003, 0x0000, 0x0000, 0x00ff, 0x0017, 0x0004, 0x0067
+static const u8 cis_magic[] = {
+	0x01, 0x03, 0x00, 0x00, 0xff, 0x17, 0x04, 0x67
 };
 
+/* Orinoco PLX specific data */
+struct orinoco_plx_card {
+	void __iomem *attr_mem;
+};
+
+/*
+ * Do a soft reset of the card using the Configuration Option Register
+ */
+static int orinoco_plx_cor_reset(struct orinoco_private *priv)
+{
+	hermes_t *hw = &priv->hw;
+	struct orinoco_plx_card *card = priv->card;
+	u8 __iomem *attr_mem = card->attr_mem;
+	unsigned long timeout;
+	u16 reg;
+
+	writeb(COR_VALUE | COR_RESET, attr_mem + COR_OFFSET);
+	mdelay(1);
+
+	writeb(COR_VALUE, attr_mem + COR_OFFSET);
+	mdelay(1);
+
+	/* Just in case, wait more until the card is no longer busy */
+	timeout = jiffies + (PLX_RESET_TIME * HZ / 1000);
+	reg = hermes_read_regn(hw, CMD);
+	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
+		mdelay(1);
+		reg = hermes_read_regn(hw, CMD);
+	}
+
+	/* Did we timeout ? */
+	if (reg & HERMES_CMD_BUSY) {
+		printk(KERN_ERR PFX "Busy timeout\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+
 static int orinoco_plx_init_one(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	int err = 0;
-	u16 *attr_mem = NULL;
-	u32 reg, addr;
+	u8 __iomem *attr_mem = NULL;
+	u32 csr_reg, plx_addr;
 	struct orinoco_private *priv = NULL;
+	struct orinoco_plx_card *card;
 	unsigned long pccard_ioaddr = 0;
 	unsigned long pccard_iolen = 0;
 	struct net_device *dev = NULL;
+	void __iomem *mem;
 	int i;
 
 	err = pci_enable_device(pdev);
-	if (err)
-		return -EIO;
-
-	/* Resource 2 is mapped to the PCMCIA space */
-	attr_mem = ioremap(pci_resource_start(pdev, 2), PAGE_SIZE);
-	if (! attr_mem)
-		goto fail;
-
-	printk(KERN_DEBUG "orinoco_plx: CIS: ");
-	for (i = 0; i < 16; i++) {
-		printk("%02X:", (int)attr_mem[i]);
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return err;
 	}
-	printk("\n");
 
-	/* Verify whether PC card is present */
-	/* FIXME: we probably need to be smarted about this */
-	if (memcmp(attr_mem, cis_magic, sizeof(cis_magic)) != 0) {
-		printk(KERN_ERR "orinoco_plx: The CIS value of Prism2 PC card is invalid.\n");
-		err = -EIO;
-		goto fail;
+	err = pci_request_regions(pdev, DRIVER_NAME);
+	if (err != 0) {
+		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		goto fail_resources;
 	}
 
-	/* PCMCIA COR is the first byte following CIS: this write should
-	 * enable I/O mode and select level-triggered interrupts */
-	attr_mem[COR_OFFSET] = COR_VALUE;
-	mdelay(1);
-	reg = attr_mem[COR_OFFSET];
-	if (reg != COR_VALUE) {
-		printk(KERN_ERR "orinoco_plx: Error setting COR value (reg=%x)\n", reg);
-		goto fail;
-	}			
-
-	iounmap(attr_mem);
-	attr_mem = NULL; /* done with this now, it seems */
+	/* Resource 1 is mapped to PLX-specific registers */
+	plx_addr = pci_resource_start(pdev, 1);
 
-	/* bjoern: We need to tell the card to enable interrupts, in
-	   case the serial eprom didn't do this already. See the
-	   PLX9052 data book, p8-1 and 8-24 for reference. */
-	addr = pci_resource_start(pdev, 1);
-	reg = 0;
-	reg = inl(addr+PLX_INTCSR);
-	if (reg & PLX_INTCSR_INTEN)
-		printk(KERN_DEBUG "orinoco_plx: "
-		       "Local Interrupt already enabled\n");
-	else {
-		reg |= PLX_INTCSR_INTEN;
-		outl(reg, addr+PLX_INTCSR);
-		reg = inl(addr+PLX_INTCSR);
-		if(!(reg & PLX_INTCSR_INTEN)) {
-			printk(KERN_ERR "orinoco_plx: "
-			       "Couldn't enable Local Interrupts\n");
-			goto fail;
-		}
+	/* Resource 2 is mapped to the PCMCIA attribute memory */
+	attr_mem = ioremap(pci_resource_start(pdev, 2),
+			   pci_resource_len(pdev, 2));
+	if (!attr_mem) {
+		printk(KERN_ERR PFX "Cannot remap PCMCIA space\n");
+		goto fail_map_attr;
 	}
 
-	/* and 3 to the PCMCIA slot I/O address space */
+	/* Resource 3 is mapped to the PCMCIA I/O address space */
 	pccard_ioaddr = pci_resource_start(pdev, 3);
 	pccard_iolen = pci_resource_len(pdev, 3);
-	if (! request_region(pccard_ioaddr, pccard_iolen, DRIVER_NAME)) {
-		printk(KERN_ERR "orinoco_plx: I/O resource 0x%lx @ 0x%lx busy\n",
-		       pccard_iolen, pccard_ioaddr);
-		pccard_ioaddr = 0;
-		err = -EBUSY;
-		goto fail;
+
+	mem = pci_iomap(pdev, 3, 0);
+	if (!mem) {
+		err = -ENOMEM;
+		goto fail_map_io;
 	}
 
 	/* Allocate network device */
-	dev = alloc_orinocodev(0, NULL);
-	if (! dev) {
+	dev = alloc_orinocodev(sizeof(*card), orinoco_plx_cor_reset);
+	if (!dev) {
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err = -ENOMEM;
-		goto fail;
+		goto fail_alloc;
 	}
 
 	priv = netdev_priv(dev);
+	card = priv->card;
+	card->attr_mem = attr_mem;
 	dev->base_addr = pccard_ioaddr;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
+	hermes_struct_init(&priv->hw, mem, HERMES_16BIT_REGSPACING);
+
 	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 PLX device "
 	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
 	       pccard_ioaddr);
 
-	hermes_struct_init(&(priv->hw), dev->base_addr, HERMES_IO,
-			   HERMES_16BIT_REGSPACING);
-	pci_set_drvdata(pdev, dev);
-
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n", pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
-		goto fail;
+		goto fail_irq;
 	}
 	dev->irq = pdev->irq;
 
+	/* bjoern: We need to tell the card to enable interrupts, in
+	   case the serial eprom didn't do this already.  See the
+	   PLX9052 data book, p8-1 and 8-24 for reference. */
+	csr_reg = inl(plx_addr + PLX_INTCSR);
+	if (!(csr_reg & PLX_INTCSR_INTEN)) {
+		csr_reg |= PLX_INTCSR_INTEN;
+		outl(csr_reg, plx_addr + PLX_INTCSR);
+		csr_reg = inl(plx_addr + PLX_INTCSR);
+		if (!(csr_reg & PLX_INTCSR_INTEN)) {
+			printk(KERN_ERR PFX "Cannot enable interrupts\n");
+			goto fail;
+		}
+	}
+
+	err = orinoco_plx_cor_reset(priv);
+	if (err) {
+		printk(KERN_ERR PFX "Initial reset failed\n");
+		goto fail;
+	}
+
+	printk(KERN_DEBUG PFX "CIS: ");
+	for (i = 0; i < 16; i++) {
+		printk("%02X:", readb(attr_mem + 2*i));
+	}
+	printk("\n");
+
+	/* Verify whether a supported PC card is present */
+	/* FIXME: we probably need to be smarted about this */
+	for (i = 0; i < sizeof(cis_magic); i++) {
+		if (cis_magic[i] != readb(attr_mem +2*i)) {
+			printk(KERN_ERR PFX "The CIS value of Prism2 PC "
+			       "card is unexpected\n");
+			err = -EIO;
+			goto fail;
+		}
+	}
+
 	err = register_netdev(dev);
-	if (err)
+	if (err) {
+		printk(KERN_ERR PFX "Cannot register network device\n");
 		goto fail;
+	}
+
+	pci_set_drvdata(pdev, dev);
 
 	return 0;
 
  fail:
-	printk(KERN_DEBUG PFX "init_one(), FAIL!\n");
+	free_irq(pdev->irq, dev);
 
-	if (dev) {
-		if (dev->irq)
-			free_irq(dev->irq, dev);
-		
-		free_netdev(dev);
-	}
+ fail_irq:
+	pci_set_drvdata(pdev, NULL);
+	free_orinocodev(dev);
 
-	if (pccard_ioaddr)
-		release_region(pccard_ioaddr, pccard_iolen);
+ fail_alloc:
+	pci_iounmap(pdev, mem);
+
+ fail_map_io:
+	iounmap(attr_mem);
 
-	if (attr_mem)
-		iounmap(attr_mem);
+ fail_map_attr:
+	pci_release_regions(pdev);
 
+ fail_resources:
 	pci_disable_device(pdev);
 
 	return err;
@@ -290,20 +343,19 @@
 static void __devexit orinoco_plx_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct orinoco_private *priv = netdev_priv(dev);
+	struct orinoco_plx_card *card = priv->card;
+	u8 __iomem *attr_mem = card->attr_mem;
 
 	BUG_ON(! dev);
 
 	unregister_netdev(dev);
-		
-	if (dev->irq)
-		free_irq(dev->irq, dev);
-		
+	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
-
-	free_netdev(dev);
-
-	release_region(pci_resource_start(pdev, 3), pci_resource_len(pdev, 3));
-
+	free_orinocodev(dev);
+	pci_iounmap(pdev, priv->hw.iobase);
+	iounmap(attr_mem);
+	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 }
 
@@ -352,8 +404,7 @@
 static void __exit orinoco_plx_exit(void)
 {
 	pci_unregister_driver(&orinoco_plx_driver);
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	ssleep(1);
 }
 
 module_init(orinoco_plx_init);
diff -Nru a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/orinoco_tmd.c
--- a/drivers/net/wireless/orinoco_tmd.c	2005-03-08 14:29:45 -05:00
+++ b/drivers/net/wireless/orinoco_tmd.c	2005-03-08 14:29:45 -05:00
@@ -79,90 +79,137 @@
 #include "orinoco.h"
 
 #define COR_VALUE	(COR_LEVEL_REQ | COR_FUNC_ENA) /* Enable PC card with interrupt in level trigger */
+#define COR_RESET     (0x80)	/* reset bit in the COR register */
+#define TMD_RESET_TIME	(500)	/* milliseconds */
+
+/* Orinoco TMD specific data */
+struct orinoco_tmd_card {
+	u32 tmd_io;
+};
+
+
+/*
+ * Do a soft reset of the card using the Configuration Option Register
+ */
+static int orinoco_tmd_cor_reset(struct orinoco_private *priv)
+{
+	hermes_t *hw = &priv->hw;
+	struct orinoco_tmd_card *card = priv->card;
+	u32 addr = card->tmd_io;
+	unsigned long timeout;
+	u16 reg;
+
+	outb(COR_VALUE | COR_RESET, addr);
+	mdelay(1);
+
+	outb(COR_VALUE, addr);
+	mdelay(1);
+
+	/* Just in case, wait more until the card is no longer busy */
+	timeout = jiffies + (TMD_RESET_TIME * HZ / 1000);
+	reg = hermes_read_regn(hw, CMD);
+	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
+		mdelay(1);
+		reg = hermes_read_regn(hw, CMD);
+	}
+
+	/* Did we timeout ? */
+	if (reg & HERMES_CMD_BUSY) {
+		printk(KERN_ERR PFX "Busy timeout\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
 
 static int orinoco_tmd_init_one(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	int err = 0;
-	u32 reg, addr;
 	struct orinoco_private *priv = NULL;
-	unsigned long pccard_ioaddr = 0;
-	unsigned long pccard_iolen = 0;
+	struct orinoco_tmd_card *card;
 	struct net_device *dev = NULL;
+	void __iomem *mem;
 
 	err = pci_enable_device(pdev);
-	if (err)
-		return -EIO;
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return err;
+	}
 
-	printk(KERN_DEBUG PFX "TMD setup\n");
-	pccard_ioaddr = pci_resource_start(pdev, 2);
-	pccard_iolen = pci_resource_len(pdev, 2);
-	if (! request_region(pccard_ioaddr, pccard_iolen, DRIVER_NAME)) {
-		printk(KERN_ERR PFX "I/O resource at 0x%lx len 0x%lx busy\n",
-			pccard_ioaddr, pccard_iolen);
-		pccard_ioaddr = 0;
-		err = -EBUSY;
-		goto fail;
+	err = pci_request_regions(pdev, DRIVER_NAME);
+	if (err != 0) {
+		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		goto fail_resources;
 	}
-	addr = pci_resource_start(pdev, 1);
-	outb(COR_VALUE, addr);
-	mdelay(1);
-	reg = inb(addr);
-	if (reg != COR_VALUE) {
-		printk(KERN_ERR PFX "Error setting TMD COR values %x should be %x\n", reg, COR_VALUE);
-		err = -EIO;
-		goto fail;
+
+	mem = pci_iomap(pdev, 2, 0);
+	if (! mem) {
+		err = -ENOMEM;
+		goto fail_iomap;
 	}
 
 	/* Allocate network device */
-	dev = alloc_orinocodev(0, NULL);
+	dev = alloc_orinocodev(sizeof(*card), orinoco_tmd_cor_reset);
 	if (! dev) {
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err = -ENOMEM;
-		goto fail;
+		goto fail_alloc;
 	}
 
 	priv = netdev_priv(dev);
-	dev->base_addr = pccard_ioaddr;
+	card = priv->card;
+	card->tmd_io = pci_resource_start(pdev, 1);
+	dev->base_addr = pci_resource_start(pdev, 2);
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
+	hermes_struct_init(&priv->hw, mem, HERMES_16BIT_REGSPACING);
+
 	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 TMD device "
 	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
-	       pccard_ioaddr);
-
-	hermes_struct_init(&(priv->hw), dev->base_addr,
-			HERMES_IO, HERMES_16BIT_REGSPACING);
-	pci_set_drvdata(pdev, dev);
+	       dev->base_addr);
 
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n",
-		       pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
-		goto fail;
+		goto fail_irq;
 	}
 	dev->irq = pdev->irq;
 
+	err = orinoco_tmd_cor_reset(priv);
+	if (err) {
+		printk(KERN_ERR PFX "Initial reset failed\n");
+		goto fail;
+	}
+
 	err = register_netdev(dev);
-	if (err)
+	if (err) {
+		printk(KERN_ERR PFX "Cannot register network device\n");
 		goto fail;
+	}
+
+	pci_set_drvdata(pdev, dev);
 
 	return 0;
 
  fail:
-	printk(KERN_DEBUG PFX "init_one(), FAIL!\n");
+	free_irq(pdev->irq, dev);
 
-	if (dev) {
-		if (dev->irq)
-			free_irq(dev->irq, dev);
-		
-		free_netdev(dev);
-	}
+ fail_irq:
+	pci_set_drvdata(pdev, NULL);
+	free_orinocodev(dev);
+
+ fail_alloc:
+	pci_iounmap(pdev, mem);
 
-	if (pccard_ioaddr)
-		release_region(pccard_ioaddr, pccard_iolen);
+ fail_iomap:
+	pci_release_regions(pdev);
 
+ fail_resources:
 	pci_disable_device(pdev);
 
 	return err;
@@ -171,20 +218,16 @@
 static void __devexit orinoco_tmd_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct orinoco_private *priv = dev->priv;
 
 	BUG_ON(! dev);
 
 	unregister_netdev(dev);
-		
-	if (dev->irq)
-		free_irq(dev->irq, dev);
-		
+	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
-
-	free_netdev(dev);
-
-	release_region(pci_resource_start(pdev, 2), pci_resource_len(pdev, 2));
-
+	free_orinocodev(dev);
+	pci_iounmap(pdev, priv->hw.iobase);
+	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 }
 
@@ -218,8 +261,7 @@
 static void __exit orinoco_tmd_exit(void)
 {
 	pci_unregister_driver(&orinoco_tmd_driver);
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	ssleep(1);
 }
 
 module_init(orinoco_tmd_init);
diff -Nru a/include/linux/mv643xx.h b/include/linux/mv643xx.h
--- a/include/linux/mv643xx.h	2005-03-08 14:29:45 -05:00
+++ b/include/linux/mv643xx.h	2005-03-08 14:29:45 -05:00
@@ -1,5 +1,5 @@
 /*
- * mv64340.h - MV-64340 Internal registers definition file.
+ * mv643xx.h - MV-643XX Internal registers definition file.
  *
  * Copyright 2002 Momentum Computer, Inc.
  * 	Author: Matthew Dharm <mdharm@momenco.com>
@@ -10,8 +10,8 @@
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  */
-#ifndef __ASM_MV64340_H
-#define __ASM_MV64340_H
+#ifndef __ASM_MV643XX_H
+#define __ASM_MV643XX_H
 
 #ifdef __MIPS__
 #include <asm/addrspace.h>
@@ -662,116 +662,119 @@
 /*        Ethernet Unit Registers  		*/
 /****************************************/
 
-#define MV64340_ETH_PHY_ADDR_REG                                    0x2000
-#define MV64340_ETH_SMI_REG                                         0x2004
-#define MV64340_ETH_UNIT_DEFAULT_ADDR_REG                           0x2008
-#define MV64340_ETH_UNIT_DEFAULTID_REG                              0x200c
-#define MV64340_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x2080
-#define MV64340_ETH_UNIT_INTERRUPT_MASK_REG                         0x2084
-#define MV64340_ETH_UNIT_INTERNAL_USE_REG                           0x24fc
-#define MV64340_ETH_UNIT_ERROR_ADDR_REG                             0x2094
-#define MV64340_ETH_BAR_0                                           0x2200
-#define MV64340_ETH_BAR_1                                           0x2208
-#define MV64340_ETH_BAR_2                                           0x2210
-#define MV64340_ETH_BAR_3                                           0x2218
-#define MV64340_ETH_BAR_4                                           0x2220
-#define MV64340_ETH_BAR_5                                           0x2228
-#define MV64340_ETH_SIZE_REG_0                                      0x2204
-#define MV64340_ETH_SIZE_REG_1                                      0x220c
-#define MV64340_ETH_SIZE_REG_2                                      0x2214
-#define MV64340_ETH_SIZE_REG_3                                      0x221c
-#define MV64340_ETH_SIZE_REG_4                                      0x2224
-#define MV64340_ETH_SIZE_REG_5                                      0x222c
-#define MV64340_ETH_HEADERS_RETARGET_BASE_REG                       0x2230
-#define MV64340_ETH_HEADERS_RETARGET_CONTROL_REG                    0x2234
-#define MV64340_ETH_HIGH_ADDR_REMAP_REG_0                           0x2280
-#define MV64340_ETH_HIGH_ADDR_REMAP_REG_1                           0x2284
-#define MV64340_ETH_HIGH_ADDR_REMAP_REG_2                           0x2288
-#define MV64340_ETH_HIGH_ADDR_REMAP_REG_3                           0x228c
-#define MV64340_ETH_BASE_ADDR_ENABLE_REG                            0x2290
-#define MV64340_ETH_ACCESS_PROTECTION_REG(port)                    (0x2294 + (port<<2))
-#define MV64340_ETH_MIB_COUNTERS_BASE(port)                        (0x3000 + (port<<7))
-#define MV64340_ETH_PORT_CONFIG_REG(port)                          (0x2400 + (port<<10))
-#define MV64340_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x2404 + (port<<10))
-#define MV64340_ETH_MII_SERIAL_PARAMETRS_REG(port)                 (0x2408 + (port<<10))
-#define MV64340_ETH_GMII_SERIAL_PARAMETRS_REG(port)                (0x240c + (port<<10))
-#define MV64340_ETH_VLAN_ETHERTYPE_REG(port)                       (0x2410 + (port<<10))
-#define MV64340_ETH_MAC_ADDR_LOW(port)                             (0x2414 + (port<<10))
-#define MV64340_ETH_MAC_ADDR_HIGH(port)                            (0x2418 + (port<<10))
-#define MV64340_ETH_SDMA_CONFIG_REG(port)                          (0x241c + (port<<10))
-#define MV64340_ETH_DSCP_0(port)                                   (0x2420 + (port<<10))
-#define MV64340_ETH_DSCP_1(port)                                   (0x2424 + (port<<10))
-#define MV64340_ETH_DSCP_2(port)                                   (0x2428 + (port<<10))
-#define MV64340_ETH_DSCP_3(port)                                   (0x242c + (port<<10))
-#define MV64340_ETH_DSCP_4(port)                                   (0x2430 + (port<<10))
-#define MV64340_ETH_DSCP_5(port)                                   (0x2434 + (port<<10))
-#define MV64340_ETH_DSCP_6(port)                                   (0x2438 + (port<<10))
-#define MV64340_ETH_PORT_SERIAL_CONTROL_REG(port)                  (0x243c + (port<<10))
-#define MV64340_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x2440 + (port<<10))
-#define MV64340_ETH_PORT_STATUS_REG(port)                          (0x2444 + (port<<10))
-#define MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(port)               (0x2448 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_FIXED_PRIORITY(port)                  (0x244c + (port<<10))
-#define MV64340_ETH_PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x2450 + (port<<10))
-#define MV64340_ETH_MAXIMUM_TRANSMIT_UNIT(port)                    (0x2458 + (port<<10))
-#define MV64340_ETH_PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x245c + (port<<10))
-#define MV64340_ETH_INTERRUPT_CAUSE_REG(port)                      (0x2460 + (port<<10))
-#define MV64340_ETH_INTERRUPT_CAUSE_EXTEND_REG(port)               (0x2464 + (port<<10))
-#define MV64340_ETH_INTERRUPT_MASK_REG(port)                       (0x2468 + (port<<10))
-#define MV64340_ETH_INTERRUPT_EXTEND_MASK_REG(port)                (0x246c + (port<<10))
-#define MV64340_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2470 + (port<<10))
-#define MV64340_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2474 + (port<<10))
-#define MV64340_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x247c + (port<<10))
-#define MV64340_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x2484 + (port<<10)
-#define MV64340_ETH_PORT_DEBUG_0_REG(port)                         (0x248c + (port<<10))
-#define MV64340_ETH_PORT_DEBUG_1_REG(port)                         (0x2490 + (port<<10))
-#define MV64340_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x2494 + (port<<10))
-#define MV64340_ETH_INTERNAL_USE_REG(port)                         (0x24fc + (port<<10))
-#define MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(port)                (0x2680 + (port<<10))
-#define MV64340_ETH_CURRENT_SERVED_TX_DESC_PTR(port)               (0x2684 + (port<<10))      
-#define MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x260c + (port<<10))     
-#define MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x261c + (port<<10))     
-#define MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x262c + (port<<10))     
-#define MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x263c + (port<<10))     
-#define MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x264c + (port<<10))     
-#define MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x265c + (port<<10))     
-#define MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x266c + (port<<10))     
-#define MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x267c + (port<<10))     
-#define MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x26c0 + (port<<10))     
-#define MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x26c4 + (port<<10))     
-#define MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x26c8 + (port<<10))     
-#define MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x26cc + (port<<10))     
-#define MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x26d0 + (port<<10))     
-#define MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x26d4 + (port<<10))     
-#define MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x26d8 + (port<<10))     
-#define MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x26dc + (port<<10))     
-#define MV64340_ETH_TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x2700 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x2710 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x2720 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x2730 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x2740 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x2750 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x2760 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x2770 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x2704 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x2714 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x2724 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x2734 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x2744 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x2754 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x2764 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x2774 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_0_ARBITER_CONFIG(port)                (0x2708 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_1_ARBITER_CONFIG(port)                (0x2718 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_2_ARBITER_CONFIG(port)                (0x2728 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_3_ARBITER_CONFIG(port)                (0x2738 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_4_ARBITER_CONFIG(port)                (0x2748 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_5_ARBITER_CONFIG(port)                (0x2758 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_6_ARBITER_CONFIG(port)                (0x2768 + (port<<10))
-#define MV64340_ETH_TX_QUEUE_7_ARBITER_CONFIG(port)                (0x2778 + (port<<10))
-#define MV64340_ETH_PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x2780 + (port<<10))
-#define MV64340_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x3400 + (port<<10))
-#define MV64340_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x3500 + (port<<10))
-#define MV64340_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x3600 + (port<<10))
+#define MV643XX_ETH_SHARED_REGS                                     0x2000
+#define MV643XX_ETH_SHARED_REGS_SIZE                                0x2000
+
+#define MV643XX_ETH_PHY_ADDR_REG                                    0x2000
+#define MV643XX_ETH_SMI_REG                                         0x2004
+#define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x2008
+#define MV643XX_ETH_UNIT_DEFAULTID_REG                              0x200c
+#define MV643XX_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x2080
+#define MV643XX_ETH_UNIT_INTERRUPT_MASK_REG                         0x2084
+#define MV643XX_ETH_UNIT_INTERNAL_USE_REG                           0x24fc
+#define MV643XX_ETH_UNIT_ERROR_ADDR_REG                             0x2094
+#define MV643XX_ETH_BAR_0                                           0x2200
+#define MV643XX_ETH_BAR_1                                           0x2208
+#define MV643XX_ETH_BAR_2                                           0x2210
+#define MV643XX_ETH_BAR_3                                           0x2218
+#define MV643XX_ETH_BAR_4                                           0x2220
+#define MV643XX_ETH_BAR_5                                           0x2228
+#define MV643XX_ETH_SIZE_REG_0                                      0x2204
+#define MV643XX_ETH_SIZE_REG_1                                      0x220c
+#define MV643XX_ETH_SIZE_REG_2                                      0x2214
+#define MV643XX_ETH_SIZE_REG_3                                      0x221c
+#define MV643XX_ETH_SIZE_REG_4                                      0x2224
+#define MV643XX_ETH_SIZE_REG_5                                      0x222c
+#define MV643XX_ETH_HEADERS_RETARGET_BASE_REG                       0x2230
+#define MV643XX_ETH_HEADERS_RETARGET_CONTROL_REG                    0x2234
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_0                           0x2280
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_1                           0x2284
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_2                           0x2288
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_3                           0x228c
+#define MV643XX_ETH_BASE_ADDR_ENABLE_REG                            0x2290
+#define MV643XX_ETH_ACCESS_PROTECTION_REG(port)                    (0x2294 + (port<<2))
+#define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x3000 + (port<<7))
+#define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x2400 + (port<<10))
+#define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x2404 + (port<<10))
+#define MV643XX_ETH_MII_SERIAL_PARAMETRS_REG(port)                 (0x2408 + (port<<10))
+#define MV643XX_ETH_GMII_SERIAL_PARAMETRS_REG(port)                (0x240c + (port<<10))
+#define MV643XX_ETH_VLAN_ETHERTYPE_REG(port)                       (0x2410 + (port<<10))
+#define MV643XX_ETH_MAC_ADDR_LOW(port)                             (0x2414 + (port<<10))
+#define MV643XX_ETH_MAC_ADDR_HIGH(port)                            (0x2418 + (port<<10))
+#define MV643XX_ETH_SDMA_CONFIG_REG(port)                          (0x241c + (port<<10))
+#define MV643XX_ETH_DSCP_0(port)                                   (0x2420 + (port<<10))
+#define MV643XX_ETH_DSCP_1(port)                                   (0x2424 + (port<<10))
+#define MV643XX_ETH_DSCP_2(port)                                   (0x2428 + (port<<10))
+#define MV643XX_ETH_DSCP_3(port)                                   (0x242c + (port<<10))
+#define MV643XX_ETH_DSCP_4(port)                                   (0x2430 + (port<<10))
+#define MV643XX_ETH_DSCP_5(port)                                   (0x2434 + (port<<10))
+#define MV643XX_ETH_DSCP_6(port)                                   (0x2438 + (port<<10))
+#define MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port)                  (0x243c + (port<<10))
+#define MV643XX_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x2440 + (port<<10))
+#define MV643XX_ETH_PORT_STATUS_REG(port)                          (0x2444 + (port<<10))
+#define MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port)               (0x2448 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_FIXED_PRIORITY(port)                  (0x244c + (port<<10))
+#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x2450 + (port<<10))
+#define MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port)                    (0x2458 + (port<<10))
+#define MV643XX_ETH_PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x245c + (port<<10))
+#define MV643XX_ETH_INTERRUPT_CAUSE_REG(port)                      (0x2460 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port)               (0x2464 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_MASK_REG(port)                       (0x2468 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port)                (0x246c + (port<<10))
+#define MV643XX_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2470 + (port<<10))
+#define MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2474 + (port<<10))
+#define MV643XX_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x247c + (port<<10))
+#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x2484 + (port<<10)
+#define MV643XX_ETH_PORT_DEBUG_0_REG(port)                         (0x248c + (port<<10))
+#define MV643XX_ETH_PORT_DEBUG_1_REG(port)                         (0x2490 + (port<<10))
+#define MV643XX_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x2494 + (port<<10))
+#define MV643XX_ETH_INTERNAL_USE_REG(port)                         (0x24fc + (port<<10))
+#define MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port)                (0x2680 + (port<<10))
+#define MV643XX_ETH_CURRENT_SERVED_TX_DESC_PTR(port)               (0x2684 + (port<<10))      
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x260c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x261c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x262c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x263c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x264c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x265c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x266c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x267c + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x26c0 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x26c4 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x26c8 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x26cc + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x26d0 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x26d4 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x26d8 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x26dc + (port<<10))     
+#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x2700 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x2710 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x2720 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x2730 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x2740 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x2750 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x2760 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x2770 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x2704 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x2714 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x2724 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x2734 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x2744 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x2754 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x2764 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x2774 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_0_ARBITER_CONFIG(port)                (0x2708 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_ARBITER_CONFIG(port)                (0x2718 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_ARBITER_CONFIG(port)                (0x2728 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_ARBITER_CONFIG(port)                (0x2738 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_ARBITER_CONFIG(port)                (0x2748 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_ARBITER_CONFIG(port)                (0x2758 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_ARBITER_CONFIG(port)                (0x2768 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_ARBITER_CONFIG(port)                (0x2778 + (port<<10))
+#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x2780 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x3400 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x3500 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x3600 + (port<<10))
 
 /*******************************************/
 /*          CUNIT  Registers               */
@@ -1090,4 +1093,221 @@
 	u32	retries;
 };
 
-#endif /* __ASM_MV64340_H */
+/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
+#define MV643XX_ETH_UNICAST_NORMAL_MODE		0
+#define MV643XX_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_0		0
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_1		(1<<1)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_2		(1<<2)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_4		(1<<3)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_1	(1<<4)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_2	(1<<5)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_4	(1<<6)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
+#define MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	0
+#define MV643XX_ETH_REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
+#define MV643XX_ETH_RECEIVE_BC_IF_IP		0
+#define MV643XX_ETH_REJECT_BC_IF_IP		(1<<8)
+#define MV643XX_ETH_RECEIVE_BC_IF_ARP		0
+#define MV643XX_ETH_REJECT_BC_IF_ARP		(1<<9)
+#define MV643XX_ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
+#define MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	0
+#define MV643XX_ETH_CAPTURE_TCP_FRAMES_EN	(1<<14)
+#define MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	0
+#define MV643XX_ETH_CAPTURE_UDP_FRAMES_EN	(1<<15)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_1	(1<<16)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_2	(1<<17)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_4	(1<<18)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	((1<<21)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
+
+#define	MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE			\
+		MV643XX_ETH_UNICAST_NORMAL_MODE		|	\
+		MV643XX_ETH_DEFAULT_RX_QUEUE_0		|	\
+		MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	|	\
+		MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
+		MV643XX_ETH_RECEIVE_BC_IF_IP		|	\
+		MV643XX_ETH_RECEIVE_BC_IF_ARP		|	\
+		MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	|	\
+		MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	|	\
+		MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	|	\
+		MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	|	\
+		MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0
+
+/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
+#define MV643XX_ETH_CLASSIFY_EN				(1<<0)
+#define MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
+#define MV643XX_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
+#define MV643XX_ETH_PARTITION_DISABLE			0
+#define MV643XX_ETH_PARTITION_ENABLE			(1<<2)
+
+#define	MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
+		MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|	\
+		MV643XX_ETH_PARTITION_DISABLE
+
+/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
+#define MV643XX_ETH_RIFB			(1<<0)
+#define MV643XX_ETH_RX_BURST_SIZE_1_64BIT		0
+#define MV643XX_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
+#define MV643XX_ETH_RX_BURST_SIZE_4_64BIT		(1<<2)
+#define MV643XX_ETH_RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
+#define MV643XX_ETH_RX_BURST_SIZE_16_64BIT		(1<<3)
+#define MV643XX_ETH_BLM_RX_NO_SWAP			(1<<4)
+#define MV643XX_ETH_BLM_RX_BYTE_SWAP			0
+#define MV643XX_ETH_BLM_TX_NO_SWAP			(1<<5)
+#define MV643XX_ETH_BLM_TX_BYTE_SWAP			0
+#define MV643XX_ETH_DESCRIPTORS_BYTE_SWAP		(1<<6)
+#define MV643XX_ETH_DESCRIPTORS_NO_SWAP			0
+#define MV643XX_ETH_TX_BURST_SIZE_1_64BIT		0
+#define MV643XX_ETH_TX_BURST_SIZE_2_64BIT		(1<<22)
+#define MV643XX_ETH_TX_BURST_SIZE_4_64BIT		(1<<23)
+#define MV643XX_ETH_TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
+#define MV643XX_ETH_TX_BURST_SIZE_16_64BIT		(1<<24)
+
+#define	MV643XX_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
+
+#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
+		MV643XX_ETH_IPG_INT_RX(0)		|	\
+		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
+
+/* These macros describe Ethernet Port serial control reg (PSCR) bits */
+#define MV643XX_ETH_SERIAL_PORT_DISABLE			0
+#define MV643XX_ETH_SERIAL_PORT_ENABLE			(1<<0)
+#define MV643XX_ETH_FORCE_LINK_PASS			(1<<1)
+#define MV643XX_ETH_DO_NOT_FORCE_LINK_PASS		0
+#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX		0
+#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
+#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
+#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
+#define MV643XX_ETH_ADV_NO_FLOW_CTRL			0
+#define MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
+#define MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
+#define MV643XX_ETH_FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
+#define MV643XX_ETH_FORCE_BP_MODE_NO_JAM		0
+#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX		(1<<7)
+#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
+#define MV643XX_ETH_FORCE_LINK_FAIL			0
+#define MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL		(1<<10)
+#define MV643XX_ETH_RETRANSMIT_16_ATTEMPTS		0
+#define MV643XX_ETH_RETRANSMIT_FOREVER			(1<<11)
+#define MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
+#define MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII		0
+#define MV643XX_ETH_DTE_ADV_0				0
+#define MV643XX_ETH_DTE_ADV_1				(1<<14)
+#define MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS		0
+#define MV643XX_ETH_ENABLE_AUTO_NEG_BYPASS		(1<<15)
+#define MV643XX_ETH_AUTO_NEG_NO_CHANGE			0
+#define MV643XX_ETH_RESTART_AUTO_NEG			(1<<16)
+#define MV643XX_ETH_MAX_RX_PACKET_1518BYTE		0
+#define MV643XX_ETH_MAX_RX_PACKET_1522BYTE		(1<<17)
+#define MV643XX_ETH_MAX_RX_PACKET_1552BYTE		(1<<18)
+#define MV643XX_ETH_MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
+#define MV643XX_ETH_MAX_RX_PACKET_9192BYTE		(1<<19)
+#define MV643XX_ETH_MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
+#define MV643XX_ETH_SET_EXT_LOOPBACK			(1<<20)
+#define MV643XX_ETH_CLR_EXT_LOOPBACK			0
+#define MV643XX_ETH_SET_FULL_DUPLEX_MODE		(1<<21)
+#define MV643XX_ETH_SET_HALF_DUPLEX_MODE		0
+#define MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
+#define MV643XX_ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
+#define MV643XX_ETH_SET_GMII_SPEED_TO_10_100		0
+#define MV643XX_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
+#define MV643XX_ETH_SET_MII_SPEED_TO_10			0
+#define MV643XX_ETH_SET_MII_SPEED_TO_100		(1<<24)
+
+#define	MV643XX_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
+		MV643XX_ETH_DO_NOT_FORCE_LINK_PASS	|	\
+		MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX	|	\
+		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
+		MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL	|	\
+		MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
+		MV643XX_ETH_FORCE_BP_MODE_NO_JAM	|	\
+		(1<<9)	/* reserved */			|	\
+		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|	\
+		MV643XX_ETH_RETRANSMIT_16_ATTEMPTS	|	\
+		MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII	|	\
+		MV643XX_ETH_DTE_ADV_0			|	\
+		MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS	|	\
+		MV643XX_ETH_AUTO_NEG_NO_CHANGE		|	\
+		MV643XX_ETH_MAX_RX_PACKET_9700BYTE	|	\
+		MV643XX_ETH_CLR_EXT_LOOPBACK		|	\
+		MV643XX_ETH_SET_FULL_DUPLEX_MODE	|	\
+		MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
+
+/* These macros describe Ethernet Serial Status reg (PSR) bits */
+#define MV643XX_ETH_PORT_STATUS_MODE_10_BIT		(1<<0)
+#define MV643XX_ETH_PORT_STATUS_LINK_UP			(1<<1)
+#define MV643XX_ETH_PORT_STATUS_FULL_DUPLEX		(1<<2)
+#define MV643XX_ETH_PORT_STATUS_FLOW_CONTROL		(1<<3)
+#define MV643XX_ETH_PORT_STATUS_GMII_1000		(1<<4)
+#define MV643XX_ETH_PORT_STATUS_MII_100			(1<<5)
+/* PSR bit 6 is undocumented */
+#define MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS		(1<<7)
+#define MV643XX_ETH_PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
+#define MV643XX_ETH_PORT_STATUS_PARTITION		(1<<9)
+#define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
+/* PSR bits 11-31 are reserved */
+
+#define	MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
+#define	MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
+
+#define MV643XX_ETH_DESC_SIZE				64
+
+#define MV643XX_ETH_SHARED_NAME	"mv643xx_eth_shared"
+#define MV643XX_ETH_NAME	"mv643xx_eth"
+
+struct mv643xx_eth_platform_data {
+	/* 
+	 * Non-values for mac_addr, phy_addr, port_config, etc.
+	 * override the default value.  Setting the corresponding
+	 * force_* field, causes the default value to be overridden
+	 * even when zero.
+	 */
+	unsigned int	force_phy_addr:1;
+	unsigned int	force_port_config:1;
+	unsigned int	force_port_config_extend:1;
+	unsigned int	force_port_sdma_config:1;
+	unsigned int	force_port_serial_control:1;
+	int		phy_addr;
+	char		*mac_addr;	/* pointer to mac address */
+	u32		port_config;
+	u32		port_config_extend;
+	u32		port_sdma_config;
+	u32		port_serial_control;
+	u32		tx_queue_size;
+	u32		rx_queue_size;
+	u32		tx_sram_addr;
+	u32		tx_sram_size;
+	u32		rx_sram_addr;
+	u32		rx_sram_size;
+};
+
+#endif /* __ASM_MV643XX_H */

--------------040800020201020107010706--
