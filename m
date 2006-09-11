From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 1/1] Remove more unnecessary driver printk's
Date: Mon, 11 Sep 2006 17:39:18 -0400
Message-ID: <20060911213918.GA1074@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:18149 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750923AbWIKVkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 17:40:31 -0400
To: jgarzik@pobox.com, phdm@macqel.be, ralf@linux-mips.org,
	vesok@yahoo.com, thockin@hockin.org, rl@hellgate.ch
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As I promised last week, here is the first pass at removing all
unnecessary printk's that exist in network device drivers currently in
promiscuous mode.  The duplicate messages are not needed so they have
been removed.  Some of these drivers are quite old and might not need an
update, but I did them all anyway.

I am currently auditing the remaining conditional printk's and will send
out a patch for those soon.


Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 3c59x.c              |    2 +-
 8139cp.c             |    4 +---
 8139too.c            |    5 +----
 amd8111e.c           |    5 ++---
 ariadne.c            |    2 --
 at1700.c             |    4 +---
 atarilance.c         |    2 +-
 au1000_eth.c         |    3 +--
 eepro.c              |    3 +--
 epic100.c            |    5 ++---
 fealnx.c             |    6 ++----
 fec.c                |    2 --
 gianfar.c            |    3 ---
 hamachi.c            |    6 ++----
 ioc3-eth.c           |    4 +---
 lance.c              |    4 +---
 natsemi.c            |    7 ++-----
 pci-skeleton.c       |    5 +----
 pcmcia/fmvj18x_cs.c  |    4 +---
 pcmcia/smc91c92_cs.c |    5 ++---
 sb1250-mac.c         |    9 ---------
 sis190.c             |    3 ---
 sun3lance.c          |    2 +-
 sundance.c           |    6 ++----
 tulip/tulip_core.c   |    6 ++----
 tulip/winbond-840.c  |    6 ++----
 typhoon.c            |    6 ++----
 ucc_geth.c           |    4 +---
 via-rhine.c          |    7 ++-----
 via-velocity.c       |    2 --
 via-velocity.h       |    2 +-
 yellowfin.c          |    6 ++----
 32 files changed, 38 insertions(+), 102 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 7c23813..415d081 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2928,7 +2928,7 @@ static void set_rx_mode(struct net_devic
 	int new_mode;
 
 	if (dev->flags & IFF_PROMISC) {
-		if (vortex_debug > 0)
+		if (vortex_debug > 3)
 			printk(KERN_NOTICE "%s: Setting promiscuous mode.\n", dev->name);
 		new_mode = SetRxFilter|RxStation|RxMulticast|RxBroadcast|RxProm;
 	} else	if ((dev->mc_list)  ||  (dev->flags & IFF_ALLMULTI)) {
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 4c2e763..4cdb6b2 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -48,7 +48,7 @@
  */
 
 #define DRV_NAME		"8139cp"
-#define DRV_VERSION		"1.2"
+#define DRV_VERSION		"1.3"
 #define DRV_RELDATE		"Mar 22, 2004"
 
 
@@ -942,8 +942,6 @@ static void __cp_set_rx_mode (struct net
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
-		printk (KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 2a70774..10301d3 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -90,7 +90,7 @@
 */
 
 #define DRV_NAME	"8139too"
-#define DRV_VERSION	"0.9.27"
+#define DRV_VERSION	"0.9.28"
 
 
 #include <linux/module.h>
@@ -2512,9 +2512,6 @@ static void __set_rx_mode (struct net_de
 
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		printk (KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 2ef8e55..f83df12 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -101,9 +101,9 @@ #endif
 
 #include "amd8111e.h"
 #define MODULE_NAME	"amd8111e"
-#define MODULE_VERS	"3.0.5"
+#define MODULE_VERS	"3.0.6"
 MODULE_AUTHOR("Advanced Micro Devices, Inc.");
-MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version 3.0.3");
+MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version 3.0.6");
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(pci, amd8111e_pci_tbl);
 module_param_array(speed_duplex, int, NULL, 0);
@@ -1527,7 +1527,6 @@ static void amd8111e_set_multicast_list(
 	u32 mc_filter[2] ;
 	int i,bit_num;
 	if(dev->flags & IFF_PROMISC){
-		printk(KERN_INFO "%s: Setting  promiscuous mode.\n",dev->name);
 		writel( VAL2 | PROM, lp->mmio + CMD2);
 		return;
 	}
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index cc721ad..3aef3c1 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -825,8 +825,6 @@ static void set_multicast_list(struct ne
     ariadne_init_ring(dev);
 
     if (dev->flags & IFF_PROMISC) {
-	/* Log any net taps. */
-	printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 	lance->RAP = CSR15;		/* Mode Register */
 	lance->RDP = PROM;		/* Set promiscuous mode */
     } else {
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 4ca061c..1a85451 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -58,7 +58,7 @@ #include <asm/io.h>
 #include <asm/dma.h>
 
 static char version[] __initdata =
-	"at1700.c:v1.15 4/7/98  Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
+	"at1700.c:v1.16 9/11/06  Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
 
 #define DRV_NAME "at1700"
 
@@ -851,8 +851,6 @@ set_rx_mode(struct net_device *dev)
 	int i;
 
 	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		printk("%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
 	} else if (dev->mc_count > MC_FILTERBREAK
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 91783a8..465efe7 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -1121,7 +1121,7 @@ static void set_multicast_list( struct n
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Log any net taps. */
-		DPRINTK( 1, ( "%s: Promiscuous mode enabled.\n", dev->name ));
+		DPRINTK( 2, ( "%s: Promiscuous mode enabled.\n", dev->name ));
 		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
 	} else {
 		short multicast_table[4];
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 55f6e3f..85be0e6 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -72,7 +72,7 @@ static int au1000_debug = 3;
 #endif
 
 #define DRV_NAME	"au1000_eth"
-#define DRV_VERSION	"1.5"
+#define DRV_VERSION	"1.6"
 #define DRV_AUTHOR	"Pete Popov <ppopov@embeddedalley.com>"
 #define DRV_DESC	"Au1xxx on-chip Ethernet driver"
 
@@ -1292,7 +1292,6 @@ static void set_rx_mode(struct net_devic
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		aup->mac->control |= MAC_PROMISCUOUS;
-		printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 	} else if ((dev->flags & IFF_ALLMULTI)  ||
 			   dev->mc_count > MULTICAST_FILTER_LIMIT) {
 		aup->mac->control |= MAC_PASS_ALL_MULTI;
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 8dc61d6..bf9efa7 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -154,7 +154,7 @@ #include <asm/io.h>
 #include <asm/dma.h>
 
 #define DRV_NAME "eepro"
-#define DRV_VERSION "0.13b"
+#define DRV_VERSION "0.13c"
 
 #define compat_dev_kfree_skb( skb, mode ) dev_kfree_skb( (skb) )
 /* I had reports of looong delays with SLOW_DOWN defined as udelay(2) */
@@ -1333,7 +1333,6 @@ set_multicast_list(struct net_device *de
 		mode = inb(ioaddr + REG3);
 		outb(mode, ioaddr + REG3); /* writing reg. 3 to complete the update */
 		eepro_sw2bank0(ioaddr); /* Return to BANK 0 now */
-		printk(KERN_INFO "%s: promiscuous mode enabled.\n", dev->name);
 	}
 
 	else if (dev->mc_count==0 )
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 25c4619..b885b20 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -26,8 +26,8 @@
 */
 
 #define DRV_NAME        "epic100"
-#define DRV_VERSION     "2.0"
-#define DRV_RELDATE     "June 27, 2006"
+#define DRV_VERSION     "2.1"
+#define DRV_RELDATE     "Sept 11, 2006"
 
 /* The user-configurable values.
    These may be modified when a driver module is loaded.*/
@@ -1386,7 +1386,6 @@ static void set_rx_mode(struct net_devic
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		outl(0x002C, ioaddr + RxCtrl);
 		/* Unconditionally log net taps. */
-		printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 	} else if ((dev->mc_count > 0)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* There is apparently a chip bug, so the multicast filter
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index a2121fa..56f81a2 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -25,8 +25,8 @@
 */
 
 #define DRV_NAME	"fealnx"
-#define DRV_VERSION	"2.51"
-#define DRV_RELDATE	"Nov-17-2001"
+#define DRV_VERSION	"2.52"
+#define DRV_RELDATE	"Sep-11-2006"
 
 static int debug;		/* 1-> print debug message */
 static int max_interrupt_work = 20;
@@ -1800,8 +1800,6 @@ static void __set_rx_mode(struct net_dev
 	u32 rx_mode;
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = CR_W_PROM | CR_W_AB | CR_W_AM;
 	} else if ((dev->mc_count > multicast_filter_limit)
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 9b40300..9eedb27 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -2227,8 +2227,6 @@ static void set_multicast_list(struct ne
 	ep = fep->hwp;
 
 	if (dev->flags&IFF_PROMISC) {
-		/* Log any net taps. */
-		printk("%s: Promiscuous mode enabled.\n", dev->name);
 		ep->fec_r_cntrl |= 0x0008;
 	} else {
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ebbbd6c..5130da0 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1708,9 +1708,6 @@ static void gfar_set_multi(struct net_de
 	u32 tempval;
 
 	if(dev->flags & IFF_PROMISC) {
-		if (netif_msg_drv(priv))
-			printk(KERN_INFO "%s: Entering promiscuous mode.\n",
-					dev->name);
 		/* Set RCTRL to PROM */
 		tempval = gfar_read(&regs->rctrl);
 		tempval |= RCTRL_PROM;
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 409c6aa..9927bff 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -27,8 +27,8 @@
 */
 
 #define DRV_NAME	"hamachi"
-#define DRV_VERSION	"2.0"
-#define DRV_RELDATE	"June 27, 2006"
+#define DRV_VERSION	"2.1"
+#define DRV_RELDATE	"Sept 11, 2006"
 
 
 /* A few user-configurable values. */
@@ -1851,8 +1851,6 @@ static void set_rx_mode(struct net_devic
 	void __iomem *ioaddr = hmp->base;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		writew(0x000F, ioaddr + AddrMode);
 	} else if ((dev->mc_count > 63)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 68d8af7..fbda761 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -28,7 +28,7 @@
  */
 
 #define IOC3_NAME	"ioc3-eth"
-#define IOC3_VERSION	"2.6.3-3"
+#define IOC3_VERSION	"2.6.3-4"
 
 #include <linux/init.h>
 #include <linux/delay.h>
@@ -1611,8 +1611,6 @@ static void ioc3_set_multicast_list(stru
 	netif_stop_queue(dev);				/* Lock out others. */
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous.  */
-		/* Unconditionally log net taps.  */
-		printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 		ip->emcr |= EMCR_PROMISC;
 		ioc3_w_emcr(ip->emcr);
 		(void) ioc3_r_emcr();
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 5b4dbfe..dc997be 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -42,7 +42,7 @@
 	Vesselin Kostadinov <vesok at yahoo dot com > - 22/4/2004
 */
 
-static const char version[] = "lance.c:v1.15ac 1999/11/13 dplatt@3do.com, becker@cesdis.gsfc.nasa.gov\n";
+static const char version[] = "lance.c:v1.16 2006/11/09 dplatt@3do.com, becker@cesdis.gsfc.nasa.gov\n";
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -1281,8 +1281,6 @@ static void set_multicast_list(struct ne
 	outw(0x0004, ioaddr+LANCE_DATA); /* Temporarily stop the lance.	 */
 
 	if (dev->flags&IFF_PROMISC) {
-		/* Log any net taps. */
-		printk("%s: Promiscuous mode enabled.\n", dev->name);
 		outw(15, ioaddr+LANCE_ADDR);
 		outw(0x8000, ioaddr+LANCE_DATA); /* Set promiscuous mode */
 	} else {
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 9510030..2a46777 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -54,8 +54,8 @@ #include <asm/irq.h>
 #include <asm/uaccess.h>
 
 #define DRV_NAME	"natsemi"
-#define DRV_VERSION	"2.0"
-#define DRV_RELDATE	"June 27, 2006"
+#define DRV_VERSION	"2.1"
+#define DRV_RELDATE	"Sept 11, 2006"
 
 #define RX_OFFSET	2
 
@@ -2387,9 +2387,6 @@ static void __set_rx_mode(struct net_dev
 	u32 rx_mode;
 
 	if (dev->flags & IFF_PROMISC) { /* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptAllPhys | AcceptMyPhys;
 	} else if ((dev->mc_count > multicast_filter_limit)
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index e634762..dea843a 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -98,7 +98,7 @@ #include <linux/mii.h>
 #include <linux/crc32.h>
 #include <asm/io.h>
 
-#define NETDRV_VERSION		"1.0.0"
+#define NETDRV_VERSION		"1.0.1"
 #define MODNAME			"netdrv"
 #define NETDRV_DRIVER_LOAD_MSG	"MyVendor Fast Ethernet driver " NETDRV_VERSION " loaded"
 #define PFX			MODNAME ": "
@@ -1853,9 +1853,6 @@ static void netdrv_set_rx_mode (struct n
 
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		printk (KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index ea93b8f..74211af 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -29,7 +29,7 @@
 ======================================================================*/
 
 #define DRV_NAME	"fmvj18x_cs"
-#define DRV_VERSION	"2.8"
+#define DRV_VERSION	"2.9"
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -1193,8 +1193,6 @@ static void set_rx_mode(struct net_devic
 	outb(CONFIG0_RST_1, ioaddr + CONFIG_0);
 
     if (dev->flags & IFF_PROMISC) {
-	/* Unconditionally log net taps. */
-	printk("%s: Promiscuous mode enabled.\n", dev->name);
 	memset(mc_filter, 0xff, sizeof(mc_filter));
 	outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
     } else if (dev->mc_count > MC_FILTERBREAK
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index a73d545..3fb369f 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -80,14 +80,14 @@ INT_MODULE_PARM(if_port, 0);
 #ifdef PCMCIA_DEBUG
 INT_MODULE_PARM(pc_debug, PCMCIA_DEBUG);
 static const char *version =
-"smc91c92_cs.c 0.09 1996/8/4 Donald Becker, becker@scyld.com.\n";
+"smc91c92_cs.c 1.123 2006/11/09 Donald Becker, becker@scyld.com.\n";
 #define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
 #else
 #define DEBUG(n, args...)
 #endif
 
 #define DRV_NAME	"smc91c92_cs"
-#define DRV_VERSION	"1.122"
+#define DRV_VERSION	"1.123"
 
 /*====================================================================*/
 
@@ -1780,7 +1780,6 @@ static void set_rx_mode(struct net_devic
     u_short rx_cfg_setting;
 
     if (dev->flags & IFF_PROMISC) {
-	printk(KERN_NOTICE "%s: setting Rx mode to promiscuous.\n", dev->name);
 	rx_cfg_setting = RxStripCRC | RxEnable | RxPromisc | RxAllMulti;
     } else if (dev->flags & IFF_ALLMULTI)
 	rx_cfg_setting = RxStripCRC | RxEnable | RxAllMulti;
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 9ab1618..e4c8896 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2708,7 +2708,6 @@ static struct net_device_stats *sbmac_ge
 static void sbmac_set_rx_mode(struct net_device *dev)
 {
 	unsigned long flags;
-	int msg_flag = 0;
 	struct sbmac_softc *sc = netdev_priv(dev);
 
 	spin_lock_irqsave(&sc->sbm_lock, flags);
@@ -2718,22 +2717,14 @@ static void sbmac_set_rx_mode(struct net
 		 */
 
 		if (dev->flags & IFF_PROMISC) {
-			/* Unconditionally log net taps. */
-			msg_flag = 1;
 			sbmac_promiscuous_mode(sc,1);
 		}
 		else {
-			msg_flag = 2;
 			sbmac_promiscuous_mode(sc,0);
 		}
 	}
 	spin_unlock_irqrestore(&sc->sbm_lock, flags);
 
-	if (msg_flag) {
-		printk(KERN_NOTICE "%s: Promiscuous mode %sabled.\n",
-		       dev->name,(msg_flag==1)?"en":"dis");
-	}
-
 	/*
 	 * Program the multicasts.  Do this every time.
 	 */
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 16e30d5..7c1982a 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -821,9 +821,6 @@ static void sis190_set_rx_mode(struct ne
 	u16 rx_mode;
 
 	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		net_drv(tp, KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode =
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 			AcceptAllPhys;
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 2dcadb1..0d76e22 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -914,7 +914,7 @@ static void set_multicast_list( struct n
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Log any net taps. */
-		DPRINTK( 1, ( "%s: Promiscuous mode enabled.\n", dev->name ));
+		DPRINTK( 3, ( "%s: Promiscuous mode enabled.\n", dev->name ));
 		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
 	} else {
 		short multicast_table[4];
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index c243a80..a3a7a35 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -23,8 +23,8 @@
 */
 
 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.1"
-#define DRV_RELDATE	"27-Jun-2006"
+#define DRV_VERSION	"1.2"
+#define DRV_RELDATE	"11-Sep-2006"
 
 
 /* The user-configurable values.
@@ -1464,8 +1464,6 @@ static void set_rx_mode(struct net_devic
 	int i;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptAll | AcceptMyPhys;
 	} else if ((dev->mc_count > multicast_filter_limit)
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index e1987ec..f3ac4fb 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -17,9 +17,9 @@
 
 #define DRV_NAME	"tulip"
 #ifdef CONFIG_TULIP_NAPI
-#define DRV_VERSION    "1.1.13-NAPI" /* Keep at least for test */
+#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
 #else
-#define DRV_VERSION	"1.1.13"
+#define DRV_VERSION	"1.1.14"
 #endif
 #define DRV_RELDATE	"May 11, 2002"
 
@@ -1023,8 +1023,6 @@ static void set_rx_mode(struct net_devic
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		tp->csr6 |= AcceptAllMulticast | AcceptAllPhys;
 		csr6 |= AcceptAllMulticast | AcceptAllPhys;
-		/* Unconditionally log net taps. */
-		printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 	} else if ((dev->mc_count > 1000)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well -- accept all multicasts. */
 		tp->csr6 |= AcceptAllMulticast;
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 6b82d14..e76b001 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -45,8 +45,8 @@
 */
 
 #define DRV_NAME	"winbond-840"
-#define DRV_VERSION	"1.01-d"
-#define DRV_RELDATE	"Nov-17-2001"
+#define DRV_VERSION	"1.01-e"
+#define DRV_RELDATE	"Sep-11-2006"
 
 
 /* Automatically extracted configuration info:
@@ -1378,8 +1378,6 @@ static u32 __set_rx_mode(struct net_devi
 	u32 rx_mode;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptAllPhys
 			| AcceptMyPhys;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 1014461..1084180 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -100,8 +100,8 @@ #define TX_TIMEOUT  (2*HZ)
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.7"
-#define DRV_MODULE_RELDATE	"05/01/07"
+#define DRV_MODULE_VERSION 	"1.5.8"
+#define DRV_MODULE_RELDATE	"06/11/09"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
@@ -937,8 +937,6 @@ typhoon_set_rx_mode(struct net_device *d
 
 	filter = TYPHOON_RX_FILTER_DIRECTED | TYPHOON_RX_FILTER_BROADCAST;
 	if(dev->flags & IFF_PROMISC) {
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-		       dev->name);
 		filter |= TYPHOON_RX_FILTER_PROMISCOUS;
 	} else if((dev->mc_count > multicast_filter_limit) ||
 		  (dev->flags & IFF_ALLMULTI)) {
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 47f49ef..4e188f4 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -47,7 +47,7 @@ #include "ucc_geth_phy.h"
 
 #undef DEBUG
 
-#define DRV_DESC "QE UCC Gigabit Ethernet Controller version:June 20, 2006"
+#define DRV_DESC "QE UCC Gigabit Ethernet Controller version:Sept 11, 2006"
 #define DRV_NAME "ucc_geth"
 
 #define ugeth_printk(level, format, arg...)  \
@@ -2510,8 +2510,6 @@ static void ucc_geth_set_multi(struct ne
 
 	if (dev->flags & IFF_PROMISC) {
 
-		/* Log any net taps. */
-		printk("%s: Promiscuous mode enabled.\n", dev->name);
 		uf_regs->upsmr |= UPSMR_PRO;
 
 	} else {
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index efeb10b..f7bc44f 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -30,8 +30,8 @@
 */
 
 #define DRV_NAME	"via-rhine"
-#define DRV_VERSION	"1.4.1"
-#define DRV_RELDATE	"July-24-2006"
+#define DRV_VERSION	"1.4.2"
+#define DRV_RELDATE	"Sept-11-2006"
 
 
 /* A few user-configurable values.
@@ -1679,9 +1679,6 @@ static void rhine_set_rx_mode(struct net
 	u8 rx_mode;		/* Note: 0x02=accept runt, 0x01=accept errs */
 
 	if (dev->flags & IFF_PROMISC) {		/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-		       dev->name);
 		rx_mode = 0x1C;
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index e266db1..f23d207 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2109,8 +2109,6 @@ static void velocity_set_multi(struct ne
 	struct dev_mc_list *mclist;
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
 		rx_mode = (RCR_AM | RCR_AB | RCR_PROM);
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 4665ef2..82968e4 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -29,7 +29,7 @@ #define VELOCITY_TX_CSUM_SUPPORT
 
 #define VELOCITY_NAME          "via-velocity"
 #define VELOCITY_FULL_DRV_NAM  "VIA Networking Velocity Family Gigabit Ethernet Adapter Driver"
-#define VELOCITY_VERSION       "1.13"
+#define VELOCITY_VERSION       "1.14"
 
 #define VELOCITY_IO_SIZE	256
 
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index b6b2474..8746cc7 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -24,8 +24,8 @@
 */
 
 #define DRV_NAME	"yellowfin"
-#define DRV_VERSION	"2.0"
-#define DRV_RELDATE	"Jun 27, 2006"
+#define DRV_VERSION	"2.1"
+#define DRV_RELDATE	"Sep 11, 2006"
 
 #define PFX DRV_NAME ": "
 
@@ -1307,8 +1307,6 @@ static void set_rx_mode(struct net_devic
 	/* Stop the Rx process to change any value. */
 	iowrite16(cfg_value & ~0x1000, ioaddr + Cnfg);
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		iowrite16(0x000F, ioaddr + AddrMode);
 	} else if ((dev->mc_count > 64)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well, or accept all multicasts. */
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 7c23813..415d081 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2928,7 +2928,7 @@ static void set_rx_mode(struct net_devic
 	int new_mode;
 
 	if (dev->flags & IFF_PROMISC) {
-		if (vortex_debug > 0)
+		if (vortex_debug > 3)
 			printk(KERN_NOTICE "%s: Setting promiscuous mode.\n", dev->name);
 		new_mode = SetRxFilter|RxStation|RxMulticast|RxBroadcast|RxProm;
 	} else	if ((dev->mc_list)  ||  (dev->flags & IFF_ALLMULTI)) {
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 4c2e763..4cdb6b2 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -48,7 +48,7 @@
  */
 
 #define DRV_NAME		"8139cp"
-#define DRV_VERSION		"1.2"
+#define DRV_VERSION		"1.3"
 #define DRV_RELDATE		"Mar 22, 2004"
 
 
@@ -942,8 +942,6 @@ static void __cp_set_rx_mode (struct net
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
-		printk (KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 2a70774..10301d3 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -90,7 +90,7 @@
 */
 
 #define DRV_NAME	"8139too"
-#define DRV_VERSION	"0.9.27"
+#define DRV_VERSION	"0.9.28"
 
 
 #include <linux/module.h>
@@ -2512,9 +2512,6 @@ static void __set_rx_mode (struct net_de
 
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		printk (KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 2ef8e55..f83df12 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -101,9 +101,9 @@ #endif
 
 #include "amd8111e.h"
 #define MODULE_NAME	"amd8111e"
-#define MODULE_VERS	"3.0.5"
+#define MODULE_VERS	"3.0.6"
 MODULE_AUTHOR("Advanced Micro Devices, Inc.");
-MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version 3.0.3");
+MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version 3.0.6");
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(pci, amd8111e_pci_tbl);
 module_param_array(speed_duplex, int, NULL, 0);
@@ -1527,7 +1527,6 @@ static void amd8111e_set_multicast_list(
 	u32 mc_filter[2] ;
 	int i,bit_num;
 	if(dev->flags & IFF_PROMISC){
-		printk(KERN_INFO "%s: Setting  promiscuous mode.\n",dev->name);
 		writel( VAL2 | PROM, lp->mmio + CMD2);
 		return;
 	}
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index cc721ad..3aef3c1 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -825,8 +825,6 @@ static void set_multicast_list(struct ne
     ariadne_init_ring(dev);
 
     if (dev->flags & IFF_PROMISC) {
-	/* Log any net taps. */
-	printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 	lance->RAP = CSR15;		/* Mode Register */
 	lance->RDP = PROM;		/* Set promiscuous mode */
     } else {
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 4ca061c..1a85451 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -58,7 +58,7 @@ #include <asm/io.h>
 #include <asm/dma.h>
 
 static char version[] __initdata =
-	"at1700.c:v1.15 4/7/98  Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
+	"at1700.c:v1.16 9/11/06  Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
 
 #define DRV_NAME "at1700"
 
@@ -851,8 +851,6 @@ set_rx_mode(struct net_device *dev)
 	int i;
 
 	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		printk("%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
 	} else if (dev->mc_count > MC_FILTERBREAK
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 91783a8..465efe7 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -1121,7 +1121,7 @@ static void set_multicast_list( struct n
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Log any net taps. */
-		DPRINTK( 1, ( "%s: Promiscuous mode enabled.\n", dev->name ));
+		DPRINTK( 2, ( "%s: Promiscuous mode enabled.\n", dev->name ));
 		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
 	} else {
 		short multicast_table[4];
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 55f6e3f..85be0e6 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -72,7 +72,7 @@ static int au1000_debug = 3;
 #endif
 
 #define DRV_NAME	"au1000_eth"
-#define DRV_VERSION	"1.5"
+#define DRV_VERSION	"1.6"
 #define DRV_AUTHOR	"Pete Popov <ppopov@embeddedalley.com>"
 #define DRV_DESC	"Au1xxx on-chip Ethernet driver"
 
@@ -1292,7 +1292,6 @@ static void set_rx_mode(struct net_devic
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		aup->mac->control |= MAC_PROMISCUOUS;
-		printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 	} else if ((dev->flags & IFF_ALLMULTI)  ||
 			   dev->mc_count > MULTICAST_FILTER_LIMIT) {
 		aup->mac->control |= MAC_PASS_ALL_MULTI;
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 8dc61d6..bf9efa7 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -154,7 +154,7 @@ #include <asm/io.h>
 #include <asm/dma.h>
 
 #define DRV_NAME "eepro"
-#define DRV_VERSION "0.13b"
+#define DRV_VERSION "0.13c"
 
 #define compat_dev_kfree_skb( skb, mode ) dev_kfree_skb( (skb) )
 /* I had reports of looong delays with SLOW_DOWN defined as udelay(2) */
@@ -1333,7 +1333,6 @@ set_multicast_list(struct net_device *de
 		mode = inb(ioaddr + REG3);
 		outb(mode, ioaddr + REG3); /* writing reg. 3 to complete the update */
 		eepro_sw2bank0(ioaddr); /* Return to BANK 0 now */
-		printk(KERN_INFO "%s: promiscuous mode enabled.\n", dev->name);
 	}
 
 	else if (dev->mc_count==0 )
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 25c4619..b885b20 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -26,8 +26,8 @@
 */
 
 #define DRV_NAME        "epic100"
-#define DRV_VERSION     "2.0"
-#define DRV_RELDATE     "June 27, 2006"
+#define DRV_VERSION     "2.1"
+#define DRV_RELDATE     "Sept 11, 2006"
 
 /* The user-configurable values.
    These may be modified when a driver module is loaded.*/
@@ -1386,7 +1386,6 @@ static void set_rx_mode(struct net_devic
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		outl(0x002C, ioaddr + RxCtrl);
 		/* Unconditionally log net taps. */
-		printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 	} else if ((dev->mc_count > 0)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* There is apparently a chip bug, so the multicast filter
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index a2121fa..56f81a2 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -25,8 +25,8 @@
 */
 
 #define DRV_NAME	"fealnx"
-#define DRV_VERSION	"2.51"
-#define DRV_RELDATE	"Nov-17-2001"
+#define DRV_VERSION	"2.52"
+#define DRV_RELDATE	"Sep-11-2006"
 
 static int debug;		/* 1-> print debug message */
 static int max_interrupt_work = 20;
@@ -1800,8 +1800,6 @@ static void __set_rx_mode(struct net_dev
 	u32 rx_mode;
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = CR_W_PROM | CR_W_AB | CR_W_AM;
 	} else if ((dev->mc_count > multicast_filter_limit)
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 9b40300..9eedb27 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -2227,8 +2227,6 @@ static void set_multicast_list(struct ne
 	ep = fep->hwp;
 
 	if (dev->flags&IFF_PROMISC) {
-		/* Log any net taps. */
-		printk("%s: Promiscuous mode enabled.\n", dev->name);
 		ep->fec_r_cntrl |= 0x0008;
 	} else {
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ebbbd6c..5130da0 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1708,9 +1708,6 @@ static void gfar_set_multi(struct net_de
 	u32 tempval;
 
 	if(dev->flags & IFF_PROMISC) {
-		if (netif_msg_drv(priv))
-			printk(KERN_INFO "%s: Entering promiscuous mode.\n",
-					dev->name);
 		/* Set RCTRL to PROM */
 		tempval = gfar_read(&regs->rctrl);
 		tempval |= RCTRL_PROM;
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 409c6aa..9927bff 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -27,8 +27,8 @@
 */
 
 #define DRV_NAME	"hamachi"
-#define DRV_VERSION	"2.0"
-#define DRV_RELDATE	"June 27, 2006"
+#define DRV_VERSION	"2.1"
+#define DRV_RELDATE	"Sept 11, 2006"
 
 
 /* A few user-configurable values. */
@@ -1851,8 +1851,6 @@ static void set_rx_mode(struct net_devic
 	void __iomem *ioaddr = hmp->base;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		writew(0x000F, ioaddr + AddrMode);
 	} else if ((dev->mc_count > 63)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 68d8af7..fbda761 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -28,7 +28,7 @@
  */
 
 #define IOC3_NAME	"ioc3-eth"
-#define IOC3_VERSION	"2.6.3-3"
+#define IOC3_VERSION	"2.6.3-4"
 
 #include <linux/init.h>
 #include <linux/delay.h>
@@ -1611,8 +1611,6 @@ static void ioc3_set_multicast_list(stru
 	netif_stop_queue(dev);				/* Lock out others. */
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous.  */
-		/* Unconditionally log net taps.  */
-		printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 		ip->emcr |= EMCR_PROMISC;
 		ioc3_w_emcr(ip->emcr);
 		(void) ioc3_r_emcr();
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 5b4dbfe..dc997be 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -42,7 +42,7 @@
 	Vesselin Kostadinov <vesok at yahoo dot com > - 22/4/2004
 */
 
-static const char version[] = "lance.c:v1.15ac 1999/11/13 dplatt@3do.com, becker@cesdis.gsfc.nasa.gov\n";
+static const char version[] = "lance.c:v1.16 2006/11/09 dplatt@3do.com, becker@cesdis.gsfc.nasa.gov\n";
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -1281,8 +1281,6 @@ static void set_multicast_list(struct ne
 	outw(0x0004, ioaddr+LANCE_DATA); /* Temporarily stop the lance.	 */
 
 	if (dev->flags&IFF_PROMISC) {
-		/* Log any net taps. */
-		printk("%s: Promiscuous mode enabled.\n", dev->name);
 		outw(15, ioaddr+LANCE_ADDR);
 		outw(0x8000, ioaddr+LANCE_DATA); /* Set promiscuous mode */
 	} else {
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 9510030..2a46777 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -54,8 +54,8 @@ #include <asm/irq.h>
 #include <asm/uaccess.h>
 
 #define DRV_NAME	"natsemi"
-#define DRV_VERSION	"2.0"
-#define DRV_RELDATE	"June 27, 2006"
+#define DRV_VERSION	"2.1"
+#define DRV_RELDATE	"Sept 11, 2006"
 
 #define RX_OFFSET	2
 
@@ -2387,9 +2387,6 @@ static void __set_rx_mode(struct net_dev
 	u32 rx_mode;
 
 	if (dev->flags & IFF_PROMISC) { /* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptAllPhys | AcceptMyPhys;
 	} else if ((dev->mc_count > multicast_filter_limit)
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index e634762..dea843a 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -98,7 +98,7 @@ #include <linux/mii.h>
 #include <linux/crc32.h>
 #include <asm/io.h>
 
-#define NETDRV_VERSION		"1.0.0"
+#define NETDRV_VERSION		"1.0.1"
 #define MODNAME			"netdrv"
 #define NETDRV_DRIVER_LOAD_MSG	"MyVendor Fast Ethernet driver " NETDRV_VERSION " loaded"
 #define PFX			MODNAME ": "
@@ -1853,9 +1853,6 @@ static void netdrv_set_rx_mode (struct n
 
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		printk (KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index ea93b8f..74211af 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -29,7 +29,7 @@
 ======================================================================*/
 
 #define DRV_NAME	"fmvj18x_cs"
-#define DRV_VERSION	"2.8"
+#define DRV_VERSION	"2.9"
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -1193,8 +1193,6 @@ static void set_rx_mode(struct net_devic
 	outb(CONFIG0_RST_1, ioaddr + CONFIG_0);
 
     if (dev->flags & IFF_PROMISC) {
-	/* Unconditionally log net taps. */
-	printk("%s: Promiscuous mode enabled.\n", dev->name);
 	memset(mc_filter, 0xff, sizeof(mc_filter));
 	outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
     } else if (dev->mc_count > MC_FILTERBREAK
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index a73d545..3fb369f 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -80,14 +80,14 @@ INT_MODULE_PARM(if_port, 0);
 #ifdef PCMCIA_DEBUG
 INT_MODULE_PARM(pc_debug, PCMCIA_DEBUG);
 static const char *version =
-"smc91c92_cs.c 0.09 1996/8/4 Donald Becker, becker@scyld.com.\n";
+"smc91c92_cs.c 1.123 2006/11/09 Donald Becker, becker@scyld.com.\n";
 #define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
 #else
 #define DEBUG(n, args...)
 #endif
 
 #define DRV_NAME	"smc91c92_cs"
-#define DRV_VERSION	"1.122"
+#define DRV_VERSION	"1.123"
 
 /*====================================================================*/
 
@@ -1780,7 +1780,6 @@ static void set_rx_mode(struct net_devic
     u_short rx_cfg_setting;
 
     if (dev->flags & IFF_PROMISC) {
-	printk(KERN_NOTICE "%s: setting Rx mode to promiscuous.\n", dev->name);
 	rx_cfg_setting = RxStripCRC | RxEnable | RxPromisc | RxAllMulti;
     } else if (dev->flags & IFF_ALLMULTI)
 	rx_cfg_setting = RxStripCRC | RxEnable | RxAllMulti;
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 9ab1618..e4c8896 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2708,7 +2708,6 @@ static struct net_device_stats *sbmac_ge
 static void sbmac_set_rx_mode(struct net_device *dev)
 {
 	unsigned long flags;
-	int msg_flag = 0;
 	struct sbmac_softc *sc = netdev_priv(dev);
 
 	spin_lock_irqsave(&sc->sbm_lock, flags);
@@ -2718,22 +2717,14 @@ static void sbmac_set_rx_mode(struct net
 		 */
 
 		if (dev->flags & IFF_PROMISC) {
-			/* Unconditionally log net taps. */
-			msg_flag = 1;
 			sbmac_promiscuous_mode(sc,1);
 		}
 		else {
-			msg_flag = 2;
 			sbmac_promiscuous_mode(sc,0);
 		}
 	}
 	spin_unlock_irqrestore(&sc->sbm_lock, flags);
 
-	if (msg_flag) {
-		printk(KERN_NOTICE "%s: Promiscuous mode %sabled.\n",
-		       dev->name,(msg_flag==1)?"en":"dis");
-	}
-
 	/*
 	 * Program the multicasts.  Do this every time.
 	 */
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 16e30d5..7c1982a 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -821,9 +821,6 @@ static void sis190_set_rx_mode(struct ne
 	u16 rx_mode;
 
 	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		net_drv(tp, KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			dev->name);
 		rx_mode =
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 			AcceptAllPhys;
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 2dcadb1..0d76e22 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -914,7 +914,7 @@ static void set_multicast_list( struct n
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Log any net taps. */
-		DPRINTK( 1, ( "%s: Promiscuous mode enabled.\n", dev->name ));
+		DPRINTK( 3, ( "%s: Promiscuous mode enabled.\n", dev->name ));
 		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
 	} else {
 		short multicast_table[4];
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index c243a80..a3a7a35 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -23,8 +23,8 @@
 */
 
 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.1"
-#define DRV_RELDATE	"27-Jun-2006"
+#define DRV_VERSION	"1.2"
+#define DRV_RELDATE	"11-Sep-2006"
 
 
 /* The user-configurable values.
@@ -1464,8 +1464,6 @@ static void set_rx_mode(struct net_devic
 	int i;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptAll | AcceptMyPhys;
 	} else if ((dev->mc_count > multicast_filter_limit)
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index e1987ec..f3ac4fb 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -17,9 +17,9 @@
 
 #define DRV_NAME	"tulip"
 #ifdef CONFIG_TULIP_NAPI
-#define DRV_VERSION    "1.1.13-NAPI" /* Keep at least for test */
+#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
 #else
-#define DRV_VERSION	"1.1.13"
+#define DRV_VERSION	"1.1.14"
 #endif
 #define DRV_RELDATE	"May 11, 2002"
 
@@ -1023,8 +1023,6 @@ static void set_rx_mode(struct net_devic
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		tp->csr6 |= AcceptAllMulticast | AcceptAllPhys;
 		csr6 |= AcceptAllMulticast | AcceptAllPhys;
-		/* Unconditionally log net taps. */
-		printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 	} else if ((dev->mc_count > 1000)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well -- accept all multicasts. */
 		tp->csr6 |= AcceptAllMulticast;
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 6b82d14..e76b001 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -45,8 +45,8 @@
 */
 
 #define DRV_NAME	"winbond-840"
-#define DRV_VERSION	"1.01-d"
-#define DRV_RELDATE	"Nov-17-2001"
+#define DRV_VERSION	"1.01-e"
+#define DRV_RELDATE	"Sep-11-2006"
 
 
 /* Automatically extracted configuration info:
@@ -1378,8 +1378,6 @@ static u32 __set_rx_mode(struct net_devi
 	u32 rx_mode;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptAllPhys
 			| AcceptMyPhys;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 1014461..1084180 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -100,8 +100,8 @@ #define TX_TIMEOUT  (2*HZ)
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.7"
-#define DRV_MODULE_RELDATE	"05/01/07"
+#define DRV_MODULE_VERSION 	"1.5.8"
+#define DRV_MODULE_RELDATE	"06/11/09"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
@@ -937,8 +937,6 @@ typhoon_set_rx_mode(struct net_device *d
 
 	filter = TYPHOON_RX_FILTER_DIRECTED | TYPHOON_RX_FILTER_BROADCAST;
 	if(dev->flags & IFF_PROMISC) {
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-		       dev->name);
 		filter |= TYPHOON_RX_FILTER_PROMISCOUS;
 	} else if((dev->mc_count > multicast_filter_limit) ||
 		  (dev->flags & IFF_ALLMULTI)) {
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 47f49ef..4e188f4 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -47,7 +47,7 @@ #include "ucc_geth_phy.h"
 
 #undef DEBUG
 
-#define DRV_DESC "QE UCC Gigabit Ethernet Controller version:June 20, 2006"
+#define DRV_DESC "QE UCC Gigabit Ethernet Controller version:Sept 11, 2006"
 #define DRV_NAME "ucc_geth"
 
 #define ugeth_printk(level, format, arg...)  \
@@ -2510,8 +2510,6 @@ static void ucc_geth_set_multi(struct ne
 
 	if (dev->flags & IFF_PROMISC) {
 
-		/* Log any net taps. */
-		printk("%s: Promiscuous mode enabled.\n", dev->name);
 		uf_regs->upsmr |= UPSMR_PRO;
 
 	} else {
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index efeb10b..f7bc44f 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -30,8 +30,8 @@
 */
 
 #define DRV_NAME	"via-rhine"
-#define DRV_VERSION	"1.4.1"
-#define DRV_RELDATE	"July-24-2006"
+#define DRV_VERSION	"1.4.2"
+#define DRV_RELDATE	"Sept-11-2006"
 
 
 /* A few user-configurable values.
@@ -1679,9 +1679,6 @@ static void rhine_set_rx_mode(struct net
 	u8 rx_mode;		/* Note: 0x02=accept runt, 0x01=accept errs */
 
 	if (dev->flags & IFF_PROMISC) {		/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-		       dev->name);
 		rx_mode = 0x1C;
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index e266db1..f23d207 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2109,8 +2109,6 @@ static void velocity_set_multi(struct ne
 	struct dev_mc_list *mclist;
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
 		rx_mode = (RCR_AM | RCR_AB | RCR_PROM);
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 4665ef2..82968e4 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -29,7 +29,7 @@ #define VELOCITY_TX_CSUM_SUPPORT
 
 #define VELOCITY_NAME          "via-velocity"
 #define VELOCITY_FULL_DRV_NAM  "VIA Networking Velocity Family Gigabit Ethernet Adapter Driver"
-#define VELOCITY_VERSION       "1.13"
+#define VELOCITY_VERSION       "1.14"
 
 #define VELOCITY_IO_SIZE	256
 
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index b6b2474..8746cc7 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -24,8 +24,8 @@
 */
 
 #define DRV_NAME	"yellowfin"
-#define DRV_VERSION	"2.0"
-#define DRV_RELDATE	"Jun 27, 2006"
+#define DRV_VERSION	"2.1"
+#define DRV_RELDATE	"Sep 11, 2006"
 
 #define PFX DRV_NAME ": "
 
@@ -1307,8 +1307,6 @@ static void set_rx_mode(struct net_devic
 	/* Stop the Rx process to change any value. */
 	iowrite16(cfg_value & ~0x1000, ioaddr + Cnfg);
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		iowrite16(0x000F, ioaddr + AddrMode);
 	} else if ((dev->mc_count > 64)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well, or accept all multicasts. */
