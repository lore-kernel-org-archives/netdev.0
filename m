From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .28
Date: Sat, 13 Sep 2008 22:22:36 -0400
Message-ID: <20080914022236.GA15673@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754031AbYINCXV@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

to receive the following updates:

 drivers/net/3c505.c                  |    4 +-
 drivers/net/Kconfig                  |   14 +-
 drivers/net/arcnet/arcnet.c          |   18 +-
 drivers/net/arcnet/com20020.c        |   16 +-
 drivers/net/ax88796.c                |   14 +-
 drivers/net/bfin_mac.c               |    8 +-
 drivers/net/bonding/bond_main.c      |    6 +
 drivers/net/bonding/bonding.h        |    2 +-
 drivers/net/cxgb3/cxgb3_offload.c    |    8 +-
 drivers/net/cxgb3/sge.c              |   35 -
 drivers/net/e100.c                   |    2 +-
 drivers/net/ehea/ehea.h              |    4 +-
 drivers/net/ehea/ehea_main.c         |   26 +-
 drivers/net/enc28j60.c               |   56 +-
 drivers/net/ibm_newemac/phy.c        |    2 +-
 drivers/net/ixgb/ixgb.h              |    2 +-
 drivers/net/ixgbe/ixgbe.h            |   72 +-
 drivers/net/ixgbe/ixgbe_82598.c      |  628 +++++++++++++---
 drivers/net/ixgbe/ixgbe_common.c     |  972 ++++++++++++++++---------
 drivers/net/ixgbe/ixgbe_common.h     |   62 +-
 drivers/net/ixgbe/ixgbe_ethtool.c    |  303 ++++----
 drivers/net/ixgbe/ixgbe_main.c       | 1318 +++++++++++++++++++---------------
 drivers/net/ixgbe/ixgbe_phy.c        |  244 +++----
 drivers/net/ixgbe/ixgbe_phy.h        |   63 ++-
 drivers/net/ixgbe/ixgbe_type.h       |  528 +++++++++-----
 drivers/net/meth.c                   |    2 +-
 drivers/net/mipsnet.c                |    2 +-
 drivers/net/myri10ge/myri10ge.c      |  381 +++++++++--
 drivers/net/netx-eth.c               |    2 +-
 drivers/net/netxen/netxen_nic.h      |    2 +-
 drivers/net/netxen/netxen_nic_main.c |   20 +-
 drivers/net/pci-skeleton.c           |    4 +-
 drivers/net/r6040.c                  |    4 +-
 drivers/net/r8169.c                  |    2 +-
 drivers/net/s2io.c                   |   40 +-
 drivers/net/sfc/efx.c                |   18 +-
 drivers/net/sfc/falcon.c             |  260 ++++----
 drivers/net/sfc/falcon.h             |    1 +
 drivers/net/sfc/falcon_hwdefs.h      |    1 -
 drivers/net/sfc/falcon_io.h          |    1 -
 drivers/net/sfc/falcon_xmac.c        |   88 +---
 drivers/net/sfc/net_driver.h         |    8 +-
 drivers/net/sfc/sfe4001.c            |   12 -
 drivers/net/sfc/tenxpress.c          |   69 +--
 drivers/net/sfc/tx.c                 |    2 +-
 drivers/net/sfc/workarounds.h        |    2 -
 drivers/net/sfc/xfp_phy.c            |    1 -
 drivers/net/smc911x.c                |   68 +-
 drivers/net/smc91x.c                 |   40 +-
 drivers/net/sundance.c               |   95 ++-
 drivers/net/tehuti.h                 |    8 +-
 drivers/net/tsi108_eth.c             |    6 +-
 drivers/net/ucc_geth.c               |  116 ++--
 drivers/net/usb/hso.c                |  326 ++++++---
 drivers/net/usb/mcs7830.c            |    2 +-
 drivers/net/usb/pegasus.c            |   20 +-
 drivers/net/via-velocity.h           |    2 +-
 drivers/net/wan/cycx_drv.c           |    6 +-
 drivers/net/wan/cycx_x25.c           |   12 +-
 drivers/net/wan/dscc4.c              |    2 +-
 drivers/net/wan/pc300_tty.c          |    2 +-
 include/linux/pci_ids.h              |   10 +
 62 files changed, 3684 insertions(+), 2360 deletions(-)

Alexander Duyck (3):
      ixgbe: correctly add and remove napi queues
      ixgbe: whitespace/formatting cleanup
      ixgbe: make compilation with LRO optional

Ben Hutchings (11):
      sfc: Add check for memory allocation failure in falcon_probe_nic()
      sfc: Fix memory BAR release call on error path
      sfc: Remove workaround for old firmware bug
      sfc: Serialise tenxpress_special_reset() with statistics fetches
      sfc: Make queue flushes more reliable
      sfc: Stop generating bogus events in tenxpress_check_hw()
      sfc: Insert read memory barrier after checking MAC statistics flag
      sfc: Disable interrupts after a fatal interrupt occurs until reset
      sfc: Remove obsolete comment about PCI modes
      sfc: Use CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS where appropriate
      sfc: Fix type of FALCON_SPI_MAX_LEN

Brice Goglin (5):
      myri10ge: Stop scaring people when DCA is built but absent
      myri10ge: Rename DCA-related firmware counters
      myri10ge: Add Toeplitz-hashing related routines
      myri10ge: Add multiqueue TX support
      myri10ge: use DCA if DCA is compiled as a module

Dan Nicholson (1):
      sundance: set carrier status on link change events

Denis Joseph Barrow (1):
      [netdrvr] usb/hso: throttle to prevent loss of serial data

Dhananjay Phadke (2):
      netxen: add pci ids
      netxen: enable msi-x for quad-gig boards

Divy Le Ray (1):
      cxgb3 - remove duplicate tests in lro

Florian Fainelli (1):
      r6040: fix bad usage of udelay

Francois Romieu (1):
      r8169: select MII in Kconfig

Hannes Hering (1):
      ehea: Enable DLPAR memory remove

Harvey Harrison (1):
      drivers/net: replace __FUNCTION__ with __func__

Jeff Kirsher (2):
      ixgbe: fix pci_resource allocation as in other drivers
      ixgbe: bump version

Jesse Brandeburg (23):
      ixgbe: fix bug where using wake queue instead of start
      ixgbe: fix dca defines to not have spaces
      ixgbe: fix multicast address update
      ixgbe: Update watchdog thread to accomodate longerlink_up events
      ixgbe: link change interrupt was not causing link event
      ixgbe: fix bug with shared interrupts
      ixgbe: limit small mtu to minimum for ipv4 support
      ixgbe: fix ethtool register dump
      ixgbe: fix ethtool disable csum for ipv6
      ixgbe: fix initial interrupt throttle settings
      ixgbe: fix bug with lots of tx queues
      ixgbe: recycle pages in packet split mode
      ixgbe: add device support for XF LR adapters
      ixgbe: fix ring reallocation in ethtool
      ixgbe: lro stats were not counted on first ethtool -Scall
      ixgbe: add clean rx many routine
      ixgbe: update to latest common code module
      ixgbe: refresh the ixgbe_down function
      ixgbe: move set_num_queues and call it after msix failure
      ixgbe: cleanup defines
      ixgbe: lower stack space usage
      ixgbe: xmit frame refactor
      ixgbe: fix DCA dependency in Kconfig

Magnus Damm (1):
      smc911x: remove duplicate debug printout

Peter P Waskiewicz (1):
      ixgbe: Whitespace, copyright update and version number change patch

Sebastien Dugue (1):
      ehea: fix mutex and spinlock use

Stephen Hemminger (1):
      bonding: add more ethtool support

Steve Hodgson (2):
      sfc: Don't use EFX_OWORD_FIELD on an event (64-bit, quad-word)
      sfc: Don't include net_driver.h from falcon_io.h

diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index fdfb2b2..a424869 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -130,12 +130,12 @@ static const char filename[] = __FILE__;
 
 static const char timeout_msg[] = "*** timeout at %s:%s (line %d) ***\n";
 #define TIMEOUT_MSG(lineno) \
-	printk(timeout_msg, filename,__FUNCTION__,(lineno))
+	printk(timeout_msg, filename,__func__,(lineno))
 
 static const char invalid_pcb_msg[] =
 "*** invalid pcb length %d at %s:%s (line %d) ***\n";
 #define INVALID_PCB_MSG(len) \
-	printk(invalid_pcb_msg, (len),filename,__FUNCTION__,__LINE__)
+	printk(invalid_pcb_msg, (len),filename,__func__,__LINE__)
 
 static char search_msg[] __initdata = KERN_INFO "%s: Looking for 3c505 adapter at address %#x...";
 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4a11296..91bcaa1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2046,6 +2046,7 @@ config R8169
 	tristate "Realtek 8169 gigabit ethernet support"
 	depends on PCI
 	select CRC32
+	select MII
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
 
@@ -2380,7 +2381,7 @@ config EHEA
 config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI && INET
-	select INET_LRO
+	select INTEL_IOATDMA
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
@@ -2396,6 +2397,16 @@ config IXGBE
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
+config IXGBE_LRO
+	bool "Use software LRO"
+	depends on IXGBE && INET
+	select INET_LRO
+	default y
+	---help---
+	  Say Y here if you want to use large receive offload.
+
+	  If in doubt, say N.
+
 config IXGB
 	tristate "Intel(R) PRO/10GbE support"
 	depends on PCI
@@ -2432,6 +2443,7 @@ config MYRI10GE
 	select FW_LOADER
 	select CRC32
 	select INET_LRO
+	select INTEL_IOATDMA
 	---help---
 	  This driver supports Myricom Myri-10G Dual Protocol interface in
 	  Ethernet mode. If the eeprom on your board is not recent enough,
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index bdc4c0b..a5b0769 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -442,24 +442,24 @@ static int arcnet_open(struct net_device *dev)
 		BUGMSG(D_NORMAL, "WARNING!  Station address FF may confuse "
 		       "DOS networking programs!\n");
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	if (ASTATUS() & RESETflag) {
-	  	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	  	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 		ACOMMAND(CFLAGScmd | RESETclear);
 	}
 
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	/* make sure we're ready to receive IRQ's. */
 	AINTMASK(0);
 	udelay(1);		/* give it time to set the mask before
 				 * we reset it again. (may not even be
 				 * necessary)
 				 */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->intmask = NORXflag | RECONflag;
 	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	netif_start_queue(dev);
 
@@ -670,14 +670,14 @@ static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 		freeskb = 0;
 	}
 
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__FUNCTION__,ASTATUS());
+	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__func__,ASTATUS());
 	/* make sure we didn't ignore a TX IRQ while we were in here */
 	AINTMASK(0);
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->intmask |= TXFREEflag|EXCNAKflag;
 	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__FUNCTION__,ASTATUS());
+	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__func__,ASTATUS());
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 	if (freeskb) {
@@ -798,7 +798,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
                 diagstatus = (status >> 8) & 0xFF;
 
 		BUGMSG(D_DEBUG, "%s: %d: %s: status=%x\n",
-			__FILE__,__LINE__,__FUNCTION__,status);
+			__FILE__,__LINE__,__func__,status);
 		didsomething = 0;
 
 		/*
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 8b51313..70124a9 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -238,15 +238,15 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	u_char inbyte;
 
 	BUGMSG(D_DEBUG, "%s: %d: %s: dev: %p, lp: %p, dev->name: %s\n",
-		__FILE__,__LINE__,__FUNCTION__,dev,lp,dev->name);
+		__FILE__,__LINE__,__func__,dev,lp,dev->name);
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n",
 	       dev->name, ASTATUS());
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
 	SETCONF;
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	if (really_reset) {
 		/* reset the card */
@@ -254,22 +254,22 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 		mdelay(RESETtime * 2);	/* COM20020 seems to be slower sometimes */
 	}
 	/* clear flags & end reset */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 
 	/* verify that the ARCnet signature byte is present */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	com20020_copy_from_card(dev, 0, 0, &inbyte, 1);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	if (inbyte != TESTvalue) {
-		BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+		BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 		BUGMSG(D_NORMAL, "reset failed: TESTvalue not present.\n");
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
 	ACOMMAND(CONFIGcmd | EXTconf);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	/* done!  return success. */
 	return 0;
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index a886a4b..4207d6e 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -153,7 +153,7 @@ static void ax_reset_8390(struct net_device *dev)
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
 		if (jiffies - reset_start_time > 2*HZ/100) {
 			dev_warn(&ax->dev->dev, "%s: %s did not complete.\n",
-			       __FUNCTION__, dev->name);
+			       __func__, dev->name);
 			break;
 		}
 	}
@@ -173,7 +173,7 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 	if (ei_status.dmaing) {
 		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -215,7 +215,7 @@ static void ax_block_input(struct net_device *dev, int count,
 		dev_err(&ax->dev->dev,
 			"%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -260,7 +260,7 @@ static void ax_block_output(struct net_device *dev, int count,
 	if (ei_status.dmaing) {
 		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s."
 			"[DMAstat:%d][irqlock:%d]\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 		       ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -396,7 +396,7 @@ ax_phy_issueaddr(struct net_device *dev, int phy_addr, int reg, int opc)
 {
 	if (phy_debug)
 		pr_debug("%s: dev %p, %04x, %04x, %d\n",
-			__FUNCTION__, dev, phy_addr, reg, opc);
+			__func__, dev, phy_addr, reg, opc);
 
 	ax_mii_ei_outbits(dev, 0x3f, 6);	/* pre-amble */
 	ax_mii_ei_outbits(dev, 1, 2);		/* frame-start */
@@ -422,7 +422,7 @@ ax_phy_read(struct net_device *dev, int phy_addr, int reg)
       	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	if (phy_debug)
-		pr_debug("%s: %04x.%04x => read %04x\n", __FUNCTION__,
+		pr_debug("%s: %04x.%04x => read %04x\n", __func__,
 			 phy_addr, reg, result);
 
 	return result;
@@ -436,7 +436,7 @@ ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
 	unsigned long flags;
 
 	dev_dbg(&ax->dev->dev, "%s: %p, %04x, %04x %04x\n",
-		__FUNCTION__, dev, phy_addr, reg, value);
+		__func__, dev, phy_addr, reg, value);
 
       	spin_lock_irqsave(&ei->page_lock, flags);
 
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 3db7db1..df896e2 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -811,7 +811,7 @@ static void bfin_mac_enable(void)
 {
 	u32 opmode;
 
-	pr_debug("%s: %s\n", DRV_NAME, __FUNCTION__);
+	pr_debug("%s: %s\n", DRV_NAME, __func__);
 
 	/* Set RX DMA */
 	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
@@ -847,7 +847,7 @@ static void bfin_mac_enable(void)
 /* Our watchdog timed out. Called by the networking layer */
 static void bfin_mac_timeout(struct net_device *dev)
 {
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	bfin_mac_disable();
 
@@ -949,7 +949,7 @@ static int bfin_mac_open(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	int retval;
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -989,7 +989,7 @@ static int bfin_mac_open(struct net_device *dev)
 static int bfin_mac_close(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index babe461..8e2be24 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4493,6 +4493,12 @@ static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
 
 static const struct ethtool_ops bond_ethtool_ops = {
 	.get_drvinfo		= bond_ethtool_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.get_tso		= ethtool_op_get_tso,
+	.get_ufo		= ethtool_op_get_ufo,
+	.get_flags		= ethtool_op_get_flags,
 };
 
 /*
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index fb730ec..f7b40ed 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -32,7 +32,7 @@
 #ifdef BONDING_DEBUG
 #define dprintk(fmt, args...) \
 	printk(KERN_DEBUG     \
-	       DRV_NAME ": %s() %d: " fmt, __FUNCTION__, __LINE__ , ## args )
+	       DRV_NAME ": %s() %d: " fmt, __func__, __LINE__ , ## args )
 #else
 #define dprintk(fmt, args...)
 #endif /* BONDING_DEBUG */
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index c5b3de1..0f6fd63 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -1018,7 +1018,7 @@ static void set_l2t_ix(struct t3cdev *tdev, u32 tid, struct l2t_entry *e)
 
 	skb = alloc_skb(sizeof(*req), GFP_ATOMIC);
 	if (!skb) {
-		printk(KERN_ERR "%s: cannot allocate skb!\n", __FUNCTION__);
+		printk(KERN_ERR "%s: cannot allocate skb!\n", __func__);
 		return;
 	}
 	skb->priority = CPL_PRIORITY_CONTROL;
@@ -1049,14 +1049,14 @@ void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 		return;
 	if (!is_offloading(newdev)) {
 		printk(KERN_WARNING "%s: Redirect to non-offload "
-		       "device ignored.\n", __FUNCTION__);
+		       "device ignored.\n", __func__);
 		return;
 	}
 	tdev = dev2t3cdev(olddev);
 	BUG_ON(!tdev);
 	if (tdev != dev2t3cdev(newdev)) {
 		printk(KERN_WARNING "%s: Redirect to different "
-		       "offload device ignored.\n", __FUNCTION__);
+		       "offload device ignored.\n", __func__);
 		return;
 	}
 
@@ -1064,7 +1064,7 @@ void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	e = t3_l2t_get(tdev, new->neighbour, newdev);
 	if (!e) {
 		printk(KERN_ERR "%s: couldn't allocate new l2t entry!\n",
-		       __FUNCTION__);
+		       __func__);
 		return;
 	}
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 1b0861d..f78a42c 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1937,38 +1937,6 @@ static inline int lro_frame_ok(const struct cpl_rx_pkt *p)
 		eh->h_proto == htons(ETH_P_IP) && ih->ihl == (sizeof(*ih) >> 2);
 }
 
-#define TCP_FLAG_MASK (TCP_FLAG_CWR | TCP_FLAG_ECE | TCP_FLAG_URG |\
-                       TCP_FLAG_ACK | TCP_FLAG_PSH | TCP_FLAG_RST |\
-		                       TCP_FLAG_SYN | TCP_FLAG_FIN)
-#define TSTAMP_WORD ((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |\
-                     (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP)
-
-/**
- *	lro_segment_ok - check if a TCP segment is eligible for LRO
- *	@tcph: the TCP header of the packet
- *
- *	Returns true if a TCP packet is eligible for LRO.  This requires that
- *	the packet have only the ACK flag set and no TCP options besides
- *	time stamps.
- */
-static inline int lro_segment_ok(const struct tcphdr *tcph)
-{
-	int optlen;
-
-	if (unlikely((tcp_flag_word(tcph) & TCP_FLAG_MASK) != TCP_FLAG_ACK))
-		return 0;
-
-	optlen = (tcph->doff << 2) - sizeof(*tcph);
-	if (optlen) {
-		const u32 *opt = (const u32 *)(tcph + 1);
-
-		if (optlen != TCPOLEN_TSTAMP_ALIGNED ||
-		    *opt != htonl(TSTAMP_WORD) || !opt[2])
-			return 0;
-	}
-	return 1;
-}
-
 static int t3_get_lro_header(void **eh,  void **iph, void **tcph,
 			     u64 *hdr_flags, void *priv)
 {
@@ -1981,9 +1949,6 @@ static int t3_get_lro_header(void **eh,  void **iph, void **tcph,
 	*iph = (struct iphdr *)((struct ethhdr *)*eh + 1);
 	*tcph = (struct tcphdr *)((struct iphdr *)*iph + 1);
 
-	 if (!lro_segment_ok(*tcph))
-		return -1;
-
 	*hdr_flags = LRO_IPV4 | LRO_TCP;
 	return 0;
 }
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 453115a..7d7dfa5 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -191,7 +191,7 @@ MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & nic->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, nic->netdev->name, \
-		__FUNCTION__ , ## args))
+		__func__ , ## args))
 
 #define INTEL_8255X_ETHERNET_DEVICE(device_id, ich) {\
 	PCI_VENDOR_ID_INTEL, device_id, PCI_ANY_ID, PCI_ANY_ID, \
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index e01926b..5524271 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,13 +40,13 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0092"
+#define DRV_VERSION	"EHEA_0093"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
 #define DLPAR_MEM_ADD      2
 #define DLPAR_MEM_REM      4
-#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD)
+#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD | DLPAR_MEM_REM)
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index b70c531..c765ec6 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -219,9 +219,11 @@ static void ehea_update_firmware_handles(void)
 	}
 
 out_update:
+	mutex_lock(&ehea_fw_handles.lock);
 	kfree(ehea_fw_handles.arr);
 	ehea_fw_handles.arr = arr;
 	ehea_fw_handles.num_entries = i;
+	mutex_unlock(&ehea_fw_handles.lock);
 }
 
 static void ehea_update_bcmc_registrations(void)
@@ -293,9 +295,11 @@ static void ehea_update_bcmc_registrations(void)
 	}
 
 out_update:
+	spin_lock(&ehea_bcmc_regs.lock);
 	kfree(ehea_bcmc_regs.arr);
 	ehea_bcmc_regs.arr = arr;
 	ehea_bcmc_regs.num_entries = i;
+	spin_unlock(&ehea_bcmc_regs.lock);
 }
 
 static struct net_device_stats *ehea_get_stats(struct net_device *dev)
@@ -1770,8 +1774,6 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);
 
-	spin_lock(&ehea_bcmc_regs.lock);
-
 	/* Deregister old MAC in pHYP */
 	if (port->state == EHEA_PORT_UP) {
 		ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
@@ -1792,7 +1794,6 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 out_upregs:
 	ehea_update_bcmc_registrations();
-	spin_unlock(&ehea_bcmc_regs.lock);
 out_free:
 	kfree(cb0);
 out:
@@ -1954,8 +1955,6 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 	ehea_promiscuous(dev, 0);
 
-	spin_lock(&ehea_bcmc_regs.lock);
-
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
 		goto out;
@@ -1985,7 +1984,6 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 out:
 	ehea_update_bcmc_registrations();
-	spin_unlock(&ehea_bcmc_regs.lock);
 	return;
 }
 
@@ -2466,8 +2464,6 @@ static int ehea_up(struct net_device *dev)
 	if (port->state == EHEA_PORT_UP)
 		return 0;
 
-	mutex_lock(&ehea_fw_handles.lock);
-
 	ret = ehea_port_res_setup(port, port->num_def_qps,
 				  port->num_add_tx_qps);
 	if (ret) {
@@ -2504,8 +2500,6 @@ static int ehea_up(struct net_device *dev)
 		}
 	}
 
-	spin_lock(&ehea_bcmc_regs.lock);
-
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret) {
 		ret = -EIO;
@@ -2527,10 +2521,8 @@ out:
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
 
 	ehea_update_bcmc_registrations();
-	spin_unlock(&ehea_bcmc_regs.lock);
 
 	ehea_update_firmware_handles();
-	mutex_unlock(&ehea_fw_handles.lock);
 
 	return ret;
 }
@@ -2580,9 +2572,6 @@ static int ehea_down(struct net_device *dev)
 	if (port->state == EHEA_PORT_DOWN)
 		return 0;
 
-	mutex_lock(&ehea_fw_handles.lock);
-
-	spin_lock(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 
@@ -2591,7 +2580,6 @@ static int ehea_down(struct net_device *dev)
 	port->state = EHEA_PORT_DOWN;
 
 	ehea_update_bcmc_registrations();
-	spin_unlock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_clean_all_portres(port);
 	if (ret)
@@ -2599,7 +2587,6 @@ static int ehea_down(struct net_device *dev)
 			  dev->name, ret);
 
 	ehea_update_firmware_handles();
-	mutex_unlock(&ehea_fw_handles.lock);
 
 	return ret;
 }
@@ -3378,7 +3365,6 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
-	mutex_lock(&ehea_fw_handles.lock);
 
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
@@ -3462,7 +3448,6 @@ out_free_ad:
 
 out:
 	ehea_update_firmware_handles();
-	mutex_unlock(&ehea_fw_handles.lock);
 	return ret;
 }
 
@@ -3481,8 +3466,6 @@ static int __devexit ehea_remove(struct of_device *dev)
 
 	flush_scheduled_work();
 
-	mutex_lock(&ehea_fw_handles.lock);
-
 	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
 
@@ -3492,7 +3475,6 @@ static int __devexit ehea_remove(struct of_device *dev)
 	kfree(adapter);
 
 	ehea_update_firmware_handles();
-	mutex_unlock(&ehea_fw_handles.lock);
 
 	return 0;
 }
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index aa0bf6e..e1b441e 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -110,7 +110,7 @@ spi_read_buf(struct enc28j60_net *priv, int len, u8 *data)
 	}
 	if (ret && netif_msg_drv(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__FUNCTION__, ret);
+			__func__, ret);
 
 	return ret;
 }
@@ -131,7 +131,7 @@ static int spi_write_buf(struct enc28j60_net *priv, int len,
 		ret = spi_write(priv->spi, priv->spi_transfer_buf, len + 1);
 		if (ret && netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-				__FUNCTION__, ret);
+				__func__, ret);
 	}
 	return ret;
 }
@@ -156,7 +156,7 @@ static u8 spi_read_op(struct enc28j60_net *priv, u8 op,
 	ret = spi_write_then_read(priv->spi, tx_buf, 1, rx_buf, slen);
 	if (ret)
 		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__FUNCTION__, ret);
+			__func__, ret);
 	else
 		val = rx_buf[slen - 1];
 
@@ -176,14 +176,14 @@ static int spi_write_op(struct enc28j60_net *priv, u8 op,
 	ret = spi_write(priv->spi, priv->spi_transfer_buf, 2);
 	if (ret && netif_msg_drv(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__FUNCTION__, ret);
+			__func__, ret);
 	return ret;
 }
 
 static void enc28j60_soft_reset(struct enc28j60_net *priv)
 {
 	if (netif_msg_hw(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	spi_write_op(priv, ENC28J60_SOFT_RESET, 0, ENC28J60_SOFT_RESET);
 	/* Errata workaround #1, CLKRDY check is unreliable,
@@ -357,7 +357,7 @@ static void enc28j60_mem_read(struct enc28j60_net *priv,
 		reg = nolock_regw_read(priv, ERDPTL);
 		if (reg != addr)
 			printk(KERN_DEBUG DRV_NAME ": %s() error writing ERDPT "
-				"(0x%04x - 0x%04x)\n", __FUNCTION__, reg, addr);
+				"(0x%04x - 0x%04x)\n", __func__, reg, addr);
 	}
 #endif
 	spi_read_buf(priv, len, data);
@@ -380,7 +380,7 @@ enc28j60_packet_write(struct enc28j60_net *priv, int len, const u8 *data)
 		if (reg != TXSTART_INIT)
 			printk(KERN_DEBUG DRV_NAME
 				": %s() ERWPT:0x%04x != 0x%04x\n",
-				__FUNCTION__, reg, TXSTART_INIT);
+				__func__, reg, TXSTART_INIT);
 	}
 #endif
 	/* Set the TXND pointer to correspond to the packet size given */
@@ -390,13 +390,13 @@ enc28j60_packet_write(struct enc28j60_net *priv, int len, const u8 *data)
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME
 			": %s() after control byte ERWPT:0x%04x\n",
-			__FUNCTION__, nolock_regw_read(priv, EWRPTL));
+			__func__, nolock_regw_read(priv, EWRPTL));
 	/* copy the packet into the transmit buffer */
 	spi_write_buf(priv, len, data);
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME
 			 ": %s() after write packet ERWPT:0x%04x, len=%d\n",
-			 __FUNCTION__, nolock_regw_read(priv, EWRPTL), len);
+			 __func__, nolock_regw_read(priv, EWRPTL), len);
 	mutex_unlock(&priv->lock);
 }
 
@@ -495,7 +495,7 @@ static int enc28j60_set_hw_macaddr(struct net_device *ndev)
 		if (netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME
 				": %s() Hardware must be disabled to set "
-				"Mac address\n", __FUNCTION__);
+				"Mac address\n", __func__);
 		ret = -EBUSY;
 	}
 	mutex_unlock(&priv->lock);
@@ -575,7 +575,7 @@ static void nolock_rxfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
 	if (start > 0x1FFF || end > 0x1FFF || start > end) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR DRV_NAME ": %s(%d, %d) RXFIFO "
-				"bad parameters!\n", __FUNCTION__, start, end);
+				"bad parameters!\n", __func__, start, end);
 		return;
 	}
 	/* set receive buffer start + end */
@@ -591,7 +591,7 @@ static void nolock_txfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
 	if (start > 0x1FFF || end > 0x1FFF || start > end) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR DRV_NAME ": %s(%d, %d) TXFIFO "
-				"bad parameters!\n", __FUNCTION__, start, end);
+				"bad parameters!\n", __func__, start, end);
 		return;
 	}
 	/* set transmit buffer start + end */
@@ -630,7 +630,7 @@ static int enc28j60_hw_init(struct enc28j60_net *priv)
 	u8 reg;
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() - %s\n", __FUNCTION__,
+		printk(KERN_DEBUG DRV_NAME ": %s() - %s\n", __func__,
 			priv->full_duplex ? "FullDuplex" : "HalfDuplex");
 
 	mutex_lock(&priv->lock);
@@ -661,7 +661,7 @@ static int enc28j60_hw_init(struct enc28j60_net *priv)
 	if (reg == 0x00 || reg == 0xff) {
 		if (netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME ": %s() Invalid RevId %d\n",
-				__FUNCTION__, reg);
+				__func__, reg);
 		return 0;
 	}
 
@@ -724,7 +724,7 @@ static void enc28j60_hw_enable(struct enc28j60_net *priv)
 	/* enable interrupts */
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() enabling interrupts.\n",
-			__FUNCTION__);
+			__func__);
 
 	enc28j60_phy_write(priv, PHIE, PHIE_PGEIE | PHIE_PLNKIE);
 
@@ -888,7 +888,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 		if (netif_msg_rx_err(priv))
 			dev_err(&ndev->dev,
 				"%s() Invalid packet address!! 0x%04x\n",
-				__FUNCTION__, priv->next_pk_ptr);
+				__func__, priv->next_pk_ptr);
 		/* packet address corrupted: reset RX logic */
 		mutex_lock(&priv->lock);
 		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
@@ -917,7 +917,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 	rxstat |= rsv[4];
 
 	if (netif_msg_rx_status(priv))
-		enc28j60_dump_rsv(priv, __FUNCTION__, next_packet, len, rxstat);
+		enc28j60_dump_rsv(priv, __func__, next_packet, len, rxstat);
 
 	if (!RSV_GETBIT(rxstat, RSV_RXOK)) {
 		if (netif_msg_rx_err(priv))
@@ -941,7 +941,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
 					len, skb_put(skb, len));
 			if (netif_msg_pktdata(priv))
-				dump_packet(__FUNCTION__, skb->len, skb->data);
+				dump_packet(__func__, skb->len, skb->data);
 			skb->protocol = eth_type_trans(skb, ndev);
 			/* update statistics */
 			ndev->stats.rx_packets++;
@@ -958,7 +958,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 	erxrdpt = erxrdpt_workaround(next_packet, RXSTART_INIT, RXEND_INIT);
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() ERXRDPT:0x%04x\n",
-			__FUNCTION__, erxrdpt);
+			__func__, erxrdpt);
 
 	mutex_lock(&priv->lock);
 	nolock_regw_write(priv, ERXRDPTL, erxrdpt);
@@ -968,7 +968,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 		reg = nolock_regw_read(priv, ERXRDPTL);
 		if (reg != erxrdpt)
 			printk(KERN_DEBUG DRV_NAME ": %s() ERXRDPT verify "
-				"error (0x%04x - 0x%04x)\n", __FUNCTION__,
+				"error (0x%04x - 0x%04x)\n", __func__,
 				reg, erxrdpt);
 	}
 #endif
@@ -1006,7 +1006,7 @@ static int enc28j60_get_free_rxfifo(struct enc28j60_net *priv)
 	mutex_unlock(&priv->lock);
 	if (netif_msg_rx_status(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() free_space = %d\n",
-			__FUNCTION__, free_space);
+			__func__, free_space);
 	return free_space;
 }
 
@@ -1022,7 +1022,7 @@ static void enc28j60_check_link_status(struct net_device *ndev)
 	reg = enc28j60_phy_read(priv, PHSTAT2);
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() PHSTAT1: %04x, "
-			"PHSTAT2: %04x\n", __FUNCTION__,
+			"PHSTAT2: %04x\n", __func__,
 			enc28j60_phy_read(priv, PHSTAT1), reg);
 	duplex = reg & PHSTAT2_DPXSTAT;
 
@@ -1095,7 +1095,7 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 	int intflags, loop;
 
 	if (netif_msg_intr(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 	/* disable further interrupts */
 	locked_reg_bfclr(priv, EIE, EIE_INTIE);
 
@@ -1198,7 +1198,7 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 	/* re-enable interrupts */
 	locked_reg_bfset(priv, EIE, EIE_INTIE);
 	if (netif_msg_intr(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() exit\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() exit\n", __func__);
 }
 
 /*
@@ -1213,7 +1213,7 @@ static void enc28j60_hw_tx(struct enc28j60_net *priv)
 			": Tx Packet Len:%d\n", priv->tx_skb->len);
 
 	if (netif_msg_pktdata(priv))
-		dump_packet(__FUNCTION__,
+		dump_packet(__func__,
 			    priv->tx_skb->len, priv->tx_skb->data);
 	enc28j60_packet_write(priv, priv->tx_skb->len, priv->tx_skb->data);
 
@@ -1254,7 +1254,7 @@ static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_tx_queued(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	/* If some error occurs while trying to transmit this
 	 * packet, you should return '1' from this function.
@@ -1325,7 +1325,7 @@ static int enc28j60_net_open(struct net_device *dev)
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		if (netif_msg_ifup(priv)) {
@@ -1363,7 +1363,7 @@ static int enc28j60_net_close(struct net_device *dev)
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	enc28j60_hw_disable(priv);
 	enc28j60_lowpower(priv, true);
diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ibm_newemac/phy.c
index 37bfeea..9164abb 100644
--- a/drivers/net/ibm_newemac/phy.c
+++ b/drivers/net/ibm_newemac/phy.c
@@ -321,7 +321,7 @@ static struct mii_phy_def bcm5248_phy_def = {
 
 static int m88e1111_init(struct mii_phy *phy)
 {
-	pr_debug("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);
+	pr_debug("%s: Marvell 88E1111 Ethernet\n", __func__);
 	phy_write(phy, 0x14, 0x0ce3);
 	phy_write(phy, 0x18, 0x4101);
 	phy_write(phy, 0x09, 0x0e00);
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 804698f..d85717e 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -85,7 +85,7 @@ struct ixgb_adapter;
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args))
+		__func__ , ## args))
 
 
 /* TX/RX descriptor defines */
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 90b5383..b25022f 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -32,7 +31,12 @@
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+
+#ifdef CONFIG_IXGBE_LRO
 #include <linux/inet_lro.h>
+#define IXGBE_MAX_LRO_AGGREGATE         32
+#define IXGBE_MAX_LRO_DESCRIPTORS       8
+#endif
 
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
@@ -41,13 +45,11 @@
 #include <linux/dca.h>
 #endif
 
-#define IXGBE_ERR(args...) printk(KERN_ERR "ixgbe: " args)
-
 #define PFX "ixgbe: "
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	((void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args)))
+		__func__ , ## args)))
 
 /* TX/RX descriptor defines */
 #define IXGBE_DEFAULT_TXD		   1024
@@ -58,15 +60,6 @@
 #define IXGBE_MAX_RXD			   4096
 #define IXGBE_MIN_RXD			     64
 
-#define IXGBE_DEFAULT_RXQ			   1
-#define IXGBE_MAX_RXQ				   1
-#define IXGBE_MIN_RXQ				   1
-
-#define IXGBE_DEFAULT_ITR_RX_USECS	    125  /*   8k irqs/sec */
-#define IXGBE_DEFAULT_ITR_TX_USECS	    250  /*   4k irqs/sec */
-#define IXGBE_MIN_ITR_USECS		    100  /* 500k irqs/sec */
-#define IXGBE_MAX_ITR_USECS		  10000  /* 100  irqs/sec */
-
 /* flow control */
 #define IXGBE_DEFAULT_FCRTL		0x10000
 #define IXGBE_MIN_FCRTL			   0x40
@@ -88,9 +81,6 @@
 
 #define MAXIMUM_ETHERNET_VLAN_SIZE (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 
-/* How many Tx Descriptors do we need to call netif_wake_queue? */
-#define IXGBE_TX_QUEUE_WAKE 16
-
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IXGBE_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
@@ -101,9 +91,6 @@
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
-#define IXGBE_MAX_LRO_DESCRIPTORS       8
-#define IXGBE_MAX_LRO_AGGREGATE         32
-
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
@@ -119,6 +106,7 @@ struct ixgbe_rx_buffer {
 	dma_addr_t dma;
 	struct page *page;
 	dma_addr_t page_dma;
+	unsigned int page_offset;
 };
 
 struct ixgbe_queue_stats {
@@ -154,17 +142,16 @@ struct ixgbe_ring {
 	/* cpu for tx queue */
 	int cpu;
 #endif
+#ifdef CONFIG_IXGBE_LRO
 	struct net_lro_mgr lro_mgr;
 	bool lro_used;
+#endif
 	struct ixgbe_queue_stats stats;
-	u8 v_idx; /* maps directly to the index for this ring in the hardware
-		   * vector array, can also be used for finding the bit in EICR
-		   * and friends that represents the vector for this ring */
+	u16 v_idx; /* maps directly to the index for this ring in the hardware
+	           * vector array, can also be used for finding the bit in EICR
+	           * and friends that represents the vector for this ring */
 
-	u32 eims_value;
-	u16 itr_register;
 
-	char name[IFNAMSIZ + 5];
 	u16 work_limit;                /* max work per interrupt */
 	u16 rx_buf_len;
 };
@@ -191,8 +178,8 @@ struct ixgbe_q_vector {
 	DECLARE_BITMAP(txr_idx, MAX_TX_QUEUES); /* Tx ring indices */
 	u8 rxr_count;     /* Rx ring count assigned to this vector */
 	u8 txr_count;     /* Tx ring count assigned to this vector */
-	u8 tx_eitr;
-	u8 rx_eitr;
+	u8 tx_itr;
+	u8 rx_itr;
 	u32 eitr;
 };
 
@@ -240,7 +227,9 @@ struct ixgbe_adapter {
 
 	/* TX */
 	struct ixgbe_ring *tx_ring;	/* One per active queue */
+	int num_tx_queues;
 	u64 restart_queue;
+	u64 hw_csum_tx_good;
 	u64 lsc_int;
 	u64 hw_tso_ctxt;
 	u64 hw_tso6_ctxt;
@@ -249,12 +238,10 @@ struct ixgbe_adapter {
 
 	/* RX */
 	struct ixgbe_ring *rx_ring;	/* One per active queue */
-	u64 hw_csum_tx_good;
+	int num_rx_queues;
 	u64 hw_csum_rx_error;
 	u64 hw_csum_rx_good;
 	u64 non_eop_descs;
-	int num_tx_queues;
-	int num_rx_queues;
 	int num_msix_vectors;
 	struct ixgbe_ring_feature ring_feature[3];
 	struct msix_entry *msix_entries;
@@ -301,14 +288,23 @@ struct ixgbe_adapter {
 	struct ixgbe_hw_stats stats;
 
 	/* Interrupt Throttle Rate */
-	u32 rx_eitr;
-	u32 tx_eitr;
+	u32 eitr_param;
 
 	unsigned long state;
 	u64 tx_busy;
+#ifndef IXGBE_NO_INET_LRO
 	u64 lro_aggregated;
 	u64 lro_flushed;
 	u64 lro_no_desc;
+#endif
+	unsigned int tx_ring_count;
+	unsigned int rx_ring_count;
+
+	u32 link_speed;
+	bool link_up;
+	unsigned long link_check_timeout;
+
+	struct work_struct watchdog_task;
 };
 
 enum ixbge_state_t {
@@ -330,11 +326,11 @@ extern int ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
 extern void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
 extern void ixgbe_reset(struct ixgbe_adapter *adapter);
-extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern void ixgbe_set_ethtool_ops(struct net_device *netdev);
-extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *rxdr);
-extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *txdr);
+extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern void ixgbe_free_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern void ixgbe_free_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index ba09063..7cddcfb 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -39,68 +38,59 @@
 #define IXGBE_82598_MC_TBL_SIZE  128
 #define IXGBE_82598_VFT_TBL_SIZE 128
 
-static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_get_link_settings_82598(struct ixgbe_hw *hw, u32 *speed,
-					 bool *autoneg);
-static s32 ixgbe_get_copper_link_settings_82598(struct ixgbe_hw *hw,
-						u32 *speed, bool *autoneg);
-static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
-				      bool *link_up);
-static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
-					    bool autoneg,
-					    bool autoneg_wait_to_complete);
+static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
+                                             ixgbe_link_speed *speed,
+                                             bool *autoneg);
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
-					       bool autoneg,
-					       bool autoneg_wait_to_complete);
-static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw);
-
+static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
+                                               ixgbe_link_speed speed,
+                                               bool autoneg,
+                                               bool autoneg_wait_to_complete);
 
+/**
+ */
 static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 {
-	hw->mac.num_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
-	hw->mac.num_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
-	hw->mac.mcft_size = IXGBE_82598_MC_TBL_SIZE;
-	hw->mac.vft_size = IXGBE_82598_VFT_TBL_SIZE;
-	hw->mac.num_rar_entries = IXGBE_82598_RAR_ENTRIES;
-
-	/* PHY ops are filled in by default properly for Fiber only */
-	if (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_copper) {
-		hw->mac.ops.setup_link = &ixgbe_setup_copper_link_82598;
-		hw->mac.ops.setup_link_speed = &ixgbe_setup_copper_link_speed_82598;
-		hw->mac.ops.get_link_settings =
-				&ixgbe_get_copper_link_settings_82598;
-
-		/* Call PHY identify routine to get the phy type */
-		ixgbe_identify_phy(hw);
-
-		switch (hw->phy.type) {
-		case ixgbe_phy_tn:
-			hw->phy.ops.setup_link = &ixgbe_setup_tnx_phy_link;
-			hw->phy.ops.check_link = &ixgbe_check_tnx_phy_link;
-			hw->phy.ops.setup_link_speed =
-					&ixgbe_setup_tnx_phy_link_speed;
-			break;
-		default:
-			break;
-		}
+	struct ixgbe_mac_info *mac = &hw->mac;
+	struct ixgbe_phy_info *phy = &hw->phy;
+
+	/* Call PHY identify routine to get the phy type */
+	ixgbe_identify_phy_generic(hw);
+
+	/* PHY Init */
+	switch (phy->type) {
+	default:
+		break;
 	}
 
+	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
+		mac->ops.setup_link = &ixgbe_setup_copper_link_82598;
+		mac->ops.setup_link_speed =
+		                     &ixgbe_setup_copper_link_speed_82598;
+		mac->ops.get_link_capabilities =
+		                     &ixgbe_get_copper_link_capabilities_82598;
+	}
+
+	mac->mcft_size = IXGBE_82598_MC_TBL_SIZE;
+	mac->vft_size = IXGBE_82598_VFT_TBL_SIZE;
+	mac->num_rar_entries = IXGBE_82598_RAR_ENTRIES;
+	mac->max_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
+	mac->max_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
+
 	return 0;
 }
 
 /**
- *  ixgbe_get_link_settings_82598 - Determines default link settings
+ *  ixgbe_get_link_capabilities_82598 - Determines link capabilities
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
  *  @autoneg: boolean auto-negotiation value
  *
- *  Determines the default link settings by reading the AUTOC register.
+ *  Determines the link capabilities by reading the AUTOC register.
  **/
-static s32 ixgbe_get_link_settings_82598(struct ixgbe_hw *hw, u32 *speed,
-					 bool *autoneg)
+static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
+                                             ixgbe_link_speed *speed,
+                                             bool *autoneg)
 {
 	s32 status = 0;
 	s32 autoc_reg;
@@ -149,15 +139,16 @@ static s32 ixgbe_get_link_settings_82598(struct ixgbe_hw *hw, u32 *speed,
 }
 
 /**
- *  ixgbe_get_copper_link_settings_82598 - Determines default link settings
+ *  ixgbe_get_copper_link_capabilities_82598 - Determines link capabilities
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
  *  @autoneg: boolean auto-negotiation value
  *
- *  Determines the default link settings by reading the AUTOC register.
+ *  Determines the link capabilities by reading the AUTOC register.
  **/
-static s32 ixgbe_get_copper_link_settings_82598(struct ixgbe_hw *hw,
-						u32 *speed, bool *autoneg)
+s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
+                                             ixgbe_link_speed *speed,
+                                             bool *autoneg)
 {
 	s32 status = IXGBE_ERR_LINK_SETUP;
 	u16 speed_ability;
@@ -165,9 +156,9 @@ static s32 ixgbe_get_copper_link_settings_82598(struct ixgbe_hw *hw,
 	*speed = 0;
 	*autoneg = true;
 
-	status = ixgbe_read_phy_reg(hw, IXGBE_MDIO_PHY_SPEED_ABILITY,
-				    IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-				    &speed_ability);
+	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_SPEED_ABILITY,
+	                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+	                              &speed_ability);
 
 	if (status == 0) {
 		if (speed_ability & IXGBE_MDIO_PHY_SPEED_10G)
@@ -195,11 +186,9 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
 	case IXGBE_DEV_ID_82598EB_CX4:
 	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
+	case IXGBE_DEV_ID_82598EB_XF_LR:
 		media_type = ixgbe_media_type_fiber;
 		break;
-	case IXGBE_DEV_ID_82598AT_DUAL_PORT:
-		media_type = ixgbe_media_type_copper;
-		break;
 	default:
 		media_type = ixgbe_media_type_unknown;
 		break;
@@ -209,6 +198,122 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_setup_fc_82598 - Configure flow control settings
+ *  @hw: pointer to hardware structure
+ *  @packetbuf_num: packet buffer number (0-7)
+ *
+ *  Configures the flow control settings based on SW configuration.  This
+ *  function is used for 802.3x flow control configuration only.
+ **/
+s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
+{
+	u32 frctl_reg;
+	u32 rmcs_reg;
+
+	if (packetbuf_num < 0 || packetbuf_num > 7) {
+		hw_dbg(hw, "Invalid packet buffer number [%d], expected range is"
+		          " 0-7\n", packetbuf_num);
+	}
+
+	frctl_reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+	frctl_reg &= ~(IXGBE_FCTRL_RFCE | IXGBE_FCTRL_RPFCE);
+
+	rmcs_reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
+	rmcs_reg &= ~(IXGBE_RMCS_TFCE_PRIORITY | IXGBE_RMCS_TFCE_802_3X);
+
+	/*
+	 * 10 gig parts do not have a word in the EEPROM to determine the
+	 * default flow control setting, so we explicitly set it to full.
+	 */
+	if (hw->fc.type == ixgbe_fc_default)
+		hw->fc.type = ixgbe_fc_full;
+
+	/*
+	 * We want to save off the original Flow Control configuration just in
+	 * case we get disconnected and then reconnected into a different hub
+	 * or switch with different Flow Control capabilities.
+	 */
+	hw->fc.original_type = hw->fc.type;
+
+	/*
+	 * The possible values of the "flow_control" parameter are:
+	 * 0: Flow control is completely disabled
+	 * 1: Rx flow control is enabled (we can receive pause frames but not
+	 *    send pause frames).
+	 * 2: Tx flow control is enabled (we can send pause frames but we do not
+	 *    support receiving pause frames)
+	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
+	 * other: Invalid.
+	 */
+	switch (hw->fc.type) {
+	case ixgbe_fc_none:
+		break;
+	case ixgbe_fc_rx_pause:
+		/*
+		 * Rx Flow control is enabled,
+		 * and Tx Flow control is disabled.
+		 */
+		frctl_reg |= IXGBE_FCTRL_RFCE;
+		break;
+	case ixgbe_fc_tx_pause:
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is disabled,
+		 * by a software over-ride.
+		 */
+		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
+		break;
+	case ixgbe_fc_full:
+		/*
+		 * Flow control (both Rx and Tx) is enabled by a software
+		 * over-ride.
+		 */
+		frctl_reg |= IXGBE_FCTRL_RFCE;
+		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
+		break;
+	default:
+		/* We should never get here.  The value should be 0-3. */
+		hw_dbg(hw, "Flow control param set incorrectly\n");
+		break;
+	}
+
+	/* Enable 802.3x based flow control settings. */
+	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, frctl_reg);
+	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
+
+	/*
+	 * Check for invalid software configuration, zeros are completely
+	 * invalid for all parameters used past this point, and if we enable
+	 * flow control with zero water marks, we blast flow control packets.
+	 */
+	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
+		hw_dbg(hw, "Flow control structure initialized incorrectly\n");
+		return IXGBE_ERR_INVALID_LINK_SETTINGS;
+	}
+
+	/*
+	 * We need to set up the Receive Threshold high and low water
+	 * marks as well as (optionally) enabling the transmission of
+	 * XON frames.
+	 */
+	if (hw->fc.type & ixgbe_fc_tx_pause) {
+		if (hw->fc.send_xon) {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
+			                (hw->fc.low_water | IXGBE_FCRTL_XONE));
+		} else {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
+			                hw->fc.low_water);
+		}
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num),
+		                (hw->fc.high_water)|IXGBE_FCRTH_FCEN);
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_FCTTV(0), hw->fc.pause_time);
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, (hw->fc.pause_time >> 1));
+
+	return 0;
+}
+
+/**
  *  ixgbe_setup_mac_link_82598 - Configures MAC link settings
  *  @hw: pointer to hardware structure
  *
@@ -252,8 +357,7 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
 			}
 			if (!(links_reg & IXGBE_LINKS_KX_AN_COMP)) {
 				status = IXGBE_ERR_AUTONEG_NOT_COMPLETE;
-				hw_dbg(hw,
-				       "Autonegotiation did not complete.\n");
+				hw_dbg(hw, "Autonegotiation did not complete.\n");
 			}
 		}
 	}
@@ -263,8 +367,8 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
 	 * case we get disconnected and then reconnected into a different hub
 	 * or switch with different Flow Control capabilities.
 	 */
-	hw->fc.type = hw->fc.original_type;
-	ixgbe_setup_fc(hw, 0);
+	hw->fc.original_type = hw->fc.type;
+	ixgbe_setup_fc_82598(hw, 0);
 
 	/* Add delay to filter out noises during initial link setup */
 	msleep(50);
@@ -277,20 +381,35 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
  *  @link_up: true is link is up, false otherwise
+ *  @link_up_wait_to_complete: bool used to wait for link up or not
  *
  *  Reads the links register to determine if link is up and the current speed
  **/
-static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
-				      bool *link_up)
+static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
+                                      ixgbe_link_speed *speed, bool *link_up,
+                                      bool link_up_wait_to_complete)
 {
 	u32 links_reg;
+	u32 i;
 
 	links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
-
-	if (links_reg & IXGBE_LINKS_UP)
-		*link_up = true;
-	else
-		*link_up = false;
+	if (link_up_wait_to_complete) {
+		for (i = 0; i < IXGBE_LINK_UP_TIME; i++) {
+			if (links_reg & IXGBE_LINKS_UP) {
+				*link_up = true;
+				break;
+			} else {
+				*link_up = false;
+			}
+			msleep(100);
+			links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
+		}
+	} else {
+		if (links_reg & IXGBE_LINKS_UP)
+			*link_up = true;
+		else
+			*link_up = false;
+	}
 
 	if (links_reg & IXGBE_LINKS_SPEED)
 		*speed = IXGBE_LINK_SPEED_10GB_FULL;
@@ -300,6 +419,7 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
 	return 0;
 }
 
+
 /**
  *  ixgbe_setup_mac_link_speed_82598 - Set MAC link speed
  *  @hw: pointer to hardware structure
@@ -310,18 +430,18 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
  *  Set the link speed in the AUTOC register and restarts link.
  **/
 static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
-					    u32 speed, bool autoneg,
-					    bool autoneg_wait_to_complete)
+                                            ixgbe_link_speed speed, bool autoneg,
+                                            bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
 
 	/* If speed is 10G, then check for CX4 or XAUI. */
 	if ((speed == IXGBE_LINK_SPEED_10GB_FULL) &&
-	    (!(hw->mac.link_attach_type & IXGBE_AUTOC_10G_KX4)))
+	    (!(hw->mac.link_attach_type & IXGBE_AUTOC_10G_KX4))) {
 		hw->mac.link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
-	else if ((speed == IXGBE_LINK_SPEED_1GB_FULL) && (!autoneg))
+	} else if ((speed == IXGBE_LINK_SPEED_1GB_FULL) && (!autoneg)) {
 		hw->mac.link_mode_select = IXGBE_AUTOC_LMS_1G_LINK_NO_AN;
-	else if (autoneg) {
+	} else if (autoneg) {
 		/* BX mode - Autonegotiate 1G */
 		if (!(hw->mac.link_attach_type & IXGBE_AUTOC_1G_PMA_PMD))
 			hw->mac.link_mode_select = IXGBE_AUTOC_LMS_1G_AN;
@@ -340,7 +460,7 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
 		 * ixgbe_hw This will write the AUTOC register based on the new
 		 * stored values
 		 */
-		hw->mac.ops.setup_link(hw);
+		ixgbe_setup_mac_link_82598(hw);
 	}
 
 	return status;
@@ -358,18 +478,17 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
  **/
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
 {
-	s32 status = 0;
+	s32 status;
 
 	/* Restart autonegotiation on PHY */
-	if (hw->phy.ops.setup_link)
-		status = hw->phy.ops.setup_link(hw);
+	status = hw->phy.ops.setup_link(hw);
 
-	/* Set MAC to KX/KX4 autoneg, which defaultis to Parallel detection */
+	/* Set MAC to KX/KX4 autoneg, which defaults to Parallel detection */
 	hw->mac.link_attach_type = (IXGBE_AUTOC_10G_KX4 | IXGBE_AUTOC_1G_KX);
 	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN;
 
 	/* Set up MAC */
-	hw->mac.ops.setup_link(hw);
+	ixgbe_setup_mac_link_82598(hw);
 
 	return status;
 }
@@ -383,23 +502,23 @@ static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
  *
  *  Sets the link speed in the AUTOC register in the MAC and restarts link.
  **/
-static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
-					       bool autoneg,
-					       bool autoneg_wait_to_complete)
+static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
+                                               ixgbe_link_speed speed,
+                                               bool autoneg,
+                                               bool autoneg_wait_to_complete)
 {
-	s32 status = 0;
+	s32 status;
 
 	/* Setup the PHY according to input speed */
-	if (hw->phy.ops.setup_link_speed)
-		status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
-						autoneg_wait_to_complete);
+	status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
+	                                      autoneg_wait_to_complete);
 
 	/* Set MAC to KX/KX4 autoneg, which defaults to Parallel detection */
 	hw->mac.link_attach_type = (IXGBE_AUTOC_10G_KX4 | IXGBE_AUTOC_1G_KX);
 	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN;
 
 	/* Set up MAC */
-	hw->mac.ops.setup_link(hw);
+	ixgbe_setup_mac_link_82598(hw);
 
 	return status;
 }
@@ -408,7 +527,7 @@ static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
  *  ixgbe_reset_hw_82598 - Performs hardware reset
  *  @hw: pointer to hardware structure
  *
- *  Resets the hardware by reseting the transmit and receive units, masks and
+ *  Resets the hardware by resetting the transmit and receive units, masks and
  *  clears all interrupts, performing a PHY reset, and performing a link (MAC)
  *  reset.
  **/
@@ -422,35 +541,44 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 	u8  analog_val;
 
 	/* Call adapter stop to disable tx/rx and clear interrupts */
-	ixgbe_stop_adapter(hw);
+	hw->mac.ops.stop_adapter(hw);
 
 	/*
-	 * Power up the Atlas TX lanes if they are currently powered down.
-	 * Atlas TX lanes are powered down for MAC loopback tests, but
+	 * Power up the Atlas Tx lanes if they are currently powered down.
+	 * Atlas Tx lanes are powered down for MAC loopback tests, but
 	 * they are not automatically restored on reset.
 	 */
-	ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, &analog_val);
+	hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, &analog_val);
 	if (analog_val & IXGBE_ATLAS_PDN_TX_REG_EN) {
-		/* Enable TX Atlas so packets can be transmitted again */
-		ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, &analog_val);
+		/* Enable Tx Atlas so packets can be transmitted again */
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK,
+		                             &analog_val);
 		analog_val &= ~IXGBE_ATLAS_PDN_TX_REG_EN;
-		ixgbe_write_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, analog_val);
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK,
+		                              analog_val);
 
-		ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_10G, &analog_val);
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_10G,
+		                             &analog_val);
 		analog_val &= ~IXGBE_ATLAS_PDN_TX_10G_QL_ALL;
-		ixgbe_write_analog_reg8(hw, IXGBE_ATLAS_PDN_10G, analog_val);
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_10G,
+		                              analog_val);
 
-		ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_1G, &analog_val);
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_1G,
+		                             &analog_val);
 		analog_val &= ~IXGBE_ATLAS_PDN_TX_1G_QL_ALL;
-		ixgbe_write_analog_reg8(hw, IXGBE_ATLAS_PDN_1G, analog_val);
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_1G,
+		                              analog_val);
 
-		ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_AN, &analog_val);
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_AN,
+		                             &analog_val);
 		analog_val &= ~IXGBE_ATLAS_PDN_TX_AN_QL_ALL;
-		ixgbe_write_analog_reg8(hw, IXGBE_ATLAS_PDN_AN, analog_val);
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_AN,
+		                              analog_val);
 	}
 
 	/* Reset PHY */
-	ixgbe_reset_phy(hw);
+	if (hw->phy.reset_disable == false)
+		hw->phy.ops.reset(hw);
 
 	/*
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
@@ -503,29 +631,311 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc);
 	} else {
 		hw->mac.link_attach_type =
-					 (autoc & IXGBE_AUTOC_LMS_ATTACH_TYPE);
+		                         (autoc & IXGBE_AUTOC_LMS_ATTACH_TYPE);
 		hw->mac.link_mode_select = (autoc & IXGBE_AUTOC_LMS_MASK);
 		hw->mac.link_settings_loaded = true;
 	}
 
 	/* Store the permanent mac address */
-	ixgbe_get_mac_addr(hw, hw->mac.perm_addr);
+	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
 	return status;
 }
 
+/**
+ *  ixgbe_set_vmdq_82598 - Associate a VMDq set index with a rx address
+ *  @hw: pointer to hardware struct
+ *  @rar: receive address register index to associate with a VMDq index
+ *  @vmdq: VMDq set index
+ **/
+s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+{
+	u32 rar_high;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(rar));
+	rar_high &= ~IXGBE_RAH_VIND_MASK;
+	rar_high |= ((vmdq << IXGBE_RAH_VIND_SHIFT) & IXGBE_RAH_VIND_MASK);
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(rar), rar_high);
+	return 0;
+}
+
+/**
+ *  ixgbe_clear_vmdq_82598 - Disassociate a VMDq set index from an rx address
+ *  @hw: pointer to hardware struct
+ *  @rar: receive address register index to associate with a VMDq index
+ *  @vmdq: VMDq clear index (not used in 82598, but elsewhere)
+ **/
+static s32 ixgbe_clear_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+{
+	u32 rar_high;
+	u32 rar_entries = hw->mac.num_rar_entries;
+
+	if (rar < rar_entries) {
+		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(rar));
+		if (rar_high & IXGBE_RAH_VIND_MASK) {
+			rar_high &= ~IXGBE_RAH_VIND_MASK;
+			IXGBE_WRITE_REG(hw, IXGBE_RAH(rar), rar_high);
+		}
+	} else {
+		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+	}
+
+	return 0;
+}
+
+/**
+ *  ixgbe_set_vfta_82598 - Set VLAN filter table
+ *  @hw: pointer to hardware structure
+ *  @vlan: VLAN id to write to VLAN filter
+ *  @vind: VMDq output index that maps queue to VLAN id in VFTA
+ *  @vlan_on: boolean flag to turn on/off VLAN in VFTA
+ *
+ *  Turn on/off specified VLAN in the VLAN filter table.
+ **/
+s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan, u32 vind,
+                         bool vlan_on)
+{
+	u32 regindex;
+	u32 bitindex;
+	u32 bits;
+	u32 vftabyte;
+
+	if (vlan > 4095)
+		return IXGBE_ERR_PARAM;
+
+	/* Determine 32-bit word position in array */
+	regindex = (vlan >> 5) & 0x7F;   /* upper seven bits */
+
+	/* Determine the location of the (VMD) queue index */
+	vftabyte =  ((vlan >> 3) & 0x03); /* bits (4:3) indicating byte array */
+	bitindex = (vlan & 0x7) << 2;    /* lower 3 bits indicate nibble */
+
+	/* Set the nibble for VMD queue index */
+	bits = IXGBE_READ_REG(hw, IXGBE_VFTAVIND(vftabyte, regindex));
+	bits &= (~(0x0F << bitindex));
+	bits |= (vind << bitindex);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vftabyte, regindex), bits);
+
+	/* Determine the location of the bit for this VLAN id */
+	bitindex = vlan & 0x1F;   /* lower five bits */
+
+	bits = IXGBE_READ_REG(hw, IXGBE_VFTA(regindex));
+	if (vlan_on)
+		/* Turn on this VLAN id */
+		bits |= (1 << bitindex);
+	else
+		/* Turn off this VLAN id */
+		bits &= ~(1 << bitindex);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTA(regindex), bits);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_clear_vfta_82598 - Clear VLAN filter table
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears the VLAN filer table, and the VMDq index associated with the filter
+ **/
+static s32 ixgbe_clear_vfta_82598(struct ixgbe_hw *hw)
+{
+	u32 offset;
+	u32 vlanbyte;
+
+	for (offset = 0; offset < hw->mac.vft_size; offset++)
+		IXGBE_WRITE_REG(hw, IXGBE_VFTA(offset), 0);
+
+	for (vlanbyte = 0; vlanbyte < 4; vlanbyte++)
+		for (offset = 0; offset < hw->mac.vft_size; offset++)
+			IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vlanbyte, offset),
+			                0);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_blink_led_start_82598 - Blink LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to blink
+ **/
+static s32 ixgbe_blink_led_start_82598(struct ixgbe_hw *hw, u32 index)
+{
+	ixgbe_link_speed speed = 0;
+	bool link_up = 0;
+	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	/*
+	 * Link must be up to auto-blink the LEDs on the 82598EB MAC;
+	 * force it if link is down.
+	 */
+	hw->mac.ops.check_link(hw, &speed, &link_up, false);
+
+	if (!link_up) {
+		autoc_reg |= IXGBE_AUTOC_FLU;
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+		msleep(10);
+	}
+
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg |= IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_blink_led_stop_82598 - Stop blinking LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to stop blinking
+ **/
+static s32 ixgbe_blink_led_stop_82598(struct ixgbe_hw *hw, u32 index)
+{
+	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	autoc_reg &= ~IXGBE_AUTOC_FLU;
+	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg &= ~IXGBE_LED_BLINK(index);
+	led_reg |= IXGBE_LED_LINK_ACTIVE << IXGBE_LED_MODE_SHIFT(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_read_analog_reg8_82598 - Reads 8 bit Atlas analog register
+ *  @hw: pointer to hardware structure
+ *  @reg: analog register to read
+ *  @val: read value
+ *
+ *  Performs read operation to Atlas analog register specified.
+ **/
+s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val)
+{
+	u32  atlas_ctl;
+
+	IXGBE_WRITE_REG(hw, IXGBE_ATLASCTL,
+	                IXGBE_ATLASCTL_WRITE_CMD | (reg << 8));
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(10);
+	atlas_ctl = IXGBE_READ_REG(hw, IXGBE_ATLASCTL);
+	*val = (u8)atlas_ctl;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_write_analog_reg8_82598 - Writes 8 bit Atlas analog register
+ *  @hw: pointer to hardware structure
+ *  @reg: atlas register to write
+ *  @val: value to write
+ *
+ *  Performs write operation to Atlas analog register specified.
+ **/
+s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
+{
+	u32  atlas_ctl;
+
+	atlas_ctl = (reg << 8) | val;
+	IXGBE_WRITE_REG(hw, IXGBE_ATLASCTL, atlas_ctl);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(10);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_get_supported_physical_layer_82598 - Returns physical layer type
+ *  @hw: pointer to hardware structure
+ *
+ *  Determines physical layer capabilities of the current configuration.
+ **/
+s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
+{
+	s32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82598EB_CX4:
+	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
+		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_CX4;
+		break;
+	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
+	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
+		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_SR;
+		break;
+	case IXGBE_DEV_ID_82598EB_XF_LR:
+		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
+		break;
+
+	default:
+		physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+		break;
+	}
+
+	return physical_layer;
+}
+
 static struct ixgbe_mac_operations mac_ops_82598 = {
-	.reset			= &ixgbe_reset_hw_82598,
+	.init_hw		= &ixgbe_init_hw_generic,
+	.reset_hw		= &ixgbe_reset_hw_82598,
+	.start_hw		= &ixgbe_start_hw_generic,
+	.clear_hw_cntrs		= &ixgbe_clear_hw_cntrs_generic,
 	.get_media_type		= &ixgbe_get_media_type_82598,
+	.get_supported_physical_layer = &ixgbe_get_supported_physical_layer_82598,
+	.get_mac_addr		= &ixgbe_get_mac_addr_generic,
+	.stop_adapter		= &ixgbe_stop_adapter_generic,
+	.read_analog_reg8	= &ixgbe_read_analog_reg8_82598,
+	.write_analog_reg8	= &ixgbe_write_analog_reg8_82598,
 	.setup_link		= &ixgbe_setup_mac_link_82598,
-	.check_link		= &ixgbe_check_mac_link_82598,
 	.setup_link_speed	= &ixgbe_setup_mac_link_speed_82598,
-	.get_link_settings	= &ixgbe_get_link_settings_82598,
+	.check_link		= &ixgbe_check_mac_link_82598,
+	.get_link_capabilities	= &ixgbe_get_link_capabilities_82598,
+	.led_on			= &ixgbe_led_on_generic,
+	.led_off		= &ixgbe_led_off_generic,
+	.blink_led_start	= &ixgbe_blink_led_start_82598,
+	.blink_led_stop		= &ixgbe_blink_led_stop_82598,
+	.set_rar		= &ixgbe_set_rar_generic,
+	.clear_rar		= &ixgbe_clear_rar_generic,
+	.set_vmdq		= &ixgbe_set_vmdq_82598,
+	.clear_vmdq		= &ixgbe_clear_vmdq_82598,
+	.init_rx_addrs		= &ixgbe_init_rx_addrs_generic,
+	.update_uc_addr_list	= &ixgbe_update_uc_addr_list_generic,
+	.update_mc_addr_list	= &ixgbe_update_mc_addr_list_generic,
+	.enable_mc		= &ixgbe_enable_mc_generic,
+	.disable_mc		= &ixgbe_disable_mc_generic,
+	.clear_vfta		= &ixgbe_clear_vfta_82598,
+	.set_vfta		= &ixgbe_set_vfta_82598,
+	.setup_fc		= &ixgbe_setup_fc_82598,
+};
+
+static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
+	.init_params		= &ixgbe_init_eeprom_params_generic,
+	.read			= &ixgbe_read_eeprom_generic,
+	.validate_checksum	= &ixgbe_validate_eeprom_checksum_generic,
+	.update_checksum	= &ixgbe_update_eeprom_checksum_generic,
+};
+
+static struct ixgbe_phy_operations phy_ops_82598 = {
+	.identify		= &ixgbe_identify_phy_generic,
+	/* .identify_sfp	= &ixgbe_identify_sfp_module_generic, */
+	.reset			= &ixgbe_reset_phy_generic,
+	.read_reg		= &ixgbe_read_phy_reg_generic,
+	.write_reg		= &ixgbe_write_phy_reg_generic,
+	.setup_link		= &ixgbe_setup_phy_link_generic,
+	.setup_link_speed	= &ixgbe_setup_phy_link_speed_generic,
 };
 
 struct ixgbe_info ixgbe_82598_info = {
 	.mac			= ixgbe_mac_82598EB,
 	.get_invariants		= &ixgbe_get_invariants_82598,
 	.mac_ops		= &mac_ops_82598,
+	.eeprom_ops		= &eeprom_ops_82598,
+	.phy_ops		= &phy_ops_82598,
 };
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 9c0d0a1..f67c684 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -33,20 +32,28 @@
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
-static s32 ixgbe_clear_hw_cntrs(struct ixgbe_hw *hw);
-
 static s32 ixgbe_poll_eeprom_eerd_done(struct ixgbe_hw *hw);
+static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw);
 static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw);
 static void ixgbe_release_eeprom_semaphore(struct ixgbe_hw *hw);
+static s32 ixgbe_ready_eeprom(struct ixgbe_hw *hw);
+static void ixgbe_standby_eeprom(struct ixgbe_hw *hw);
+static void ixgbe_shift_out_eeprom_bits(struct ixgbe_hw *hw, u16 data,
+                                        u16 count);
+static u16 ixgbe_shift_in_eeprom_bits(struct ixgbe_hw *hw, u16 count);
+static void ixgbe_raise_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
+static void ixgbe_lower_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
+static void ixgbe_release_eeprom(struct ixgbe_hw *hw);
 static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw);
 
-static s32 ixgbe_clear_vfta(struct ixgbe_hw *hw);
-static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw);
+static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index);
+static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index);
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
 static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr);
+static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq);
 
 /**
- *  ixgbe_start_hw - Prepare hardware for TX/RX
+ *  ixgbe_start_hw_generic - Prepare hardware for Tx/Rx
  *  @hw: pointer to hardware structure
  *
  *  Starts the hardware by filling the bus info structure and media type, clears
@@ -54,7 +61,7 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr);
  *  table, VLAN filter table, calls routine to set up link and flow control
  *  settings, and leaves transmit and receive units disabled and uninitialized
  **/
-s32 ixgbe_start_hw(struct ixgbe_hw *hw)
+s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 {
 	u32 ctrl_ext;
 
@@ -62,22 +69,22 @@ s32 ixgbe_start_hw(struct ixgbe_hw *hw)
 	hw->phy.media_type = hw->mac.ops.get_media_type(hw);
 
 	/* Identify the PHY */
-	ixgbe_identify_phy(hw);
+	hw->phy.ops.identify(hw);
 
 	/*
 	 * Store MAC address from RAR0, clear receive address registers, and
 	 * clear the multicast table
 	 */
-	ixgbe_init_rx_addrs(hw);
+	hw->mac.ops.init_rx_addrs(hw);
 
 	/* Clear the VLAN filter table */
-	ixgbe_clear_vfta(hw);
+	hw->mac.ops.clear_vfta(hw);
 
 	/* Set up link */
 	hw->mac.ops.setup_link(hw);
 
 	/* Clear statistics registers */
-	ixgbe_clear_hw_cntrs(hw);
+	hw->mac.ops.clear_hw_cntrs(hw);
 
 	/* Set No Snoop Disable */
 	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
@@ -92,34 +99,34 @@ s32 ixgbe_start_hw(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_init_hw - Generic hardware initialization
+ *  ixgbe_init_hw_generic - Generic hardware initialization
  *  @hw: pointer to hardware structure
  *
- *  Initialize the hardware by reseting the hardware, filling the bus info
+ *  Initialize the hardware by resetting the hardware, filling the bus info
  *  structure and media type, clears all on chip counters, initializes receive
  *  address registers, multicast table, VLAN filter table, calls routine to set
  *  up link and flow control settings, and leaves transmit and receive units
  *  disabled and uninitialized
  **/
-s32 ixgbe_init_hw(struct ixgbe_hw *hw)
+s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw)
 {
 	/* Reset the hardware */
-	hw->mac.ops.reset(hw);
+	hw->mac.ops.reset_hw(hw);
 
 	/* Start the HW */
-	ixgbe_start_hw(hw);
+	hw->mac.ops.start_hw(hw);
 
 	return 0;
 }
 
 /**
- *  ixgbe_clear_hw_cntrs - Generic clear hardware counters
+ *  ixgbe_clear_hw_cntrs_generic - Generic clear hardware counters
  *  @hw: pointer to hardware structure
  *
  *  Clears all hardware statistics counters by reading them from the hardware
  *  Statistics counters are clear on read.
  **/
-static s32 ixgbe_clear_hw_cntrs(struct ixgbe_hw *hw)
+s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw)
 {
 	u16 i = 0;
 
@@ -191,7 +198,36 @@ static s32 ixgbe_clear_hw_cntrs(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_get_mac_addr - Generic get MAC address
+ *  ixgbe_read_pba_num_generic - Reads part number from EEPROM
+ *  @hw: pointer to hardware structure
+ *  @pba_num: stores the part number from the EEPROM
+ *
+ *  Reads the part number from the EEPROM.
+ **/
+s32 ixgbe_read_pba_num_generic(struct ixgbe_hw *hw, u32 *pba_num)
+{
+	s32 ret_val;
+	u16 data;
+
+	ret_val = hw->eeprom.ops.read(hw, IXGBE_PBANUM0_PTR, &data);
+	if (ret_val) {
+		hw_dbg(hw, "NVM Read Error\n");
+		return ret_val;
+	}
+	*pba_num = (u32)(data << 16);
+
+	ret_val = hw->eeprom.ops.read(hw, IXGBE_PBANUM1_PTR, &data);
+	if (ret_val) {
+		hw_dbg(hw, "NVM Read Error\n");
+		return ret_val;
+	}
+	*pba_num |= data;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_get_mac_addr_generic - Generic get MAC address
  *  @hw: pointer to hardware structure
  *  @mac_addr: Adapter MAC address
  *
@@ -199,7 +235,7 @@ static s32 ixgbe_clear_hw_cntrs(struct ixgbe_hw *hw)
  *  A reset of the adapter must be performed prior to calling this function
  *  in order for the MAC address to have been loaded from the EEPROM into RAR0
  **/
-s32 ixgbe_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr)
+s32 ixgbe_get_mac_addr_generic(struct ixgbe_hw *hw, u8 *mac_addr)
 {
 	u32 rar_high;
 	u32 rar_low;
@@ -217,30 +253,8 @@ s32 ixgbe_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr)
 	return 0;
 }
 
-s32 ixgbe_read_part_num(struct ixgbe_hw *hw, u32 *part_num)
-{
-	s32 ret_val;
-	u16 data;
-
-	ret_val = ixgbe_read_eeprom(hw, IXGBE_PBANUM0_PTR, &data);
-	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
-		return ret_val;
-	}
-	*part_num = (u32)(data << 16);
-
-	ret_val = ixgbe_read_eeprom(hw, IXGBE_PBANUM1_PTR, &data);
-	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
-		return ret_val;
-	}
-	*part_num |= data;
-
-	return 0;
-}
-
 /**
- *  ixgbe_stop_adapter - Generic stop TX/RX units
+ *  ixgbe_stop_adapter_generic - Generic stop Tx/Rx units
  *  @hw: pointer to hardware structure
  *
  *  Sets the adapter_stopped flag within ixgbe_hw struct. Clears interrupts,
@@ -248,7 +262,7 @@ s32 ixgbe_read_part_num(struct ixgbe_hw *hw, u32 *part_num)
  *  the shared code and drivers to determine if the adapter is in a stopped
  *  state and should not touch the hardware.
  **/
-s32 ixgbe_stop_adapter(struct ixgbe_hw *hw)
+s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw)
 {
 	u32 number_of_queues;
 	u32 reg_val;
@@ -264,6 +278,7 @@ s32 ixgbe_stop_adapter(struct ixgbe_hw *hw)
 	reg_val = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	reg_val &= ~(IXGBE_RXCTRL_RXEN);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, reg_val);
+	IXGBE_WRITE_FLUSH(hw);
 	msleep(2);
 
 	/* Clear interrupt mask to stop from interrupts being generated */
@@ -273,7 +288,7 @@ s32 ixgbe_stop_adapter(struct ixgbe_hw *hw)
 	IXGBE_READ_REG(hw, IXGBE_EICR);
 
 	/* Disable the transmit unit.  Each queue must be disabled. */
-	number_of_queues = hw->mac.num_tx_queues;
+	number_of_queues = hw->mac.max_tx_queues;
 	for (i = 0; i < number_of_queues; i++) {
 		reg_val = IXGBE_READ_REG(hw, IXGBE_TXDCTL(i));
 		if (reg_val & IXGBE_TXDCTL_ENABLE) {
@@ -282,15 +297,22 @@ s32 ixgbe_stop_adapter(struct ixgbe_hw *hw)
 		}
 	}
 
+	/*
+	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
+	 * access and verify no pending requests
+	 */
+	if (ixgbe_disable_pcie_master(hw) != 0)
+		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
+
 	return 0;
 }
 
 /**
- *  ixgbe_led_on - Turns on the software controllable LEDs.
+ *  ixgbe_led_on_generic - Turns on the software controllable LEDs.
  *  @hw: pointer to hardware structure
  *  @index: led number to turn on
  **/
-s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index)
+s32 ixgbe_led_on_generic(struct ixgbe_hw *hw, u32 index)
 {
 	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 
@@ -304,11 +326,11 @@ s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index)
 }
 
 /**
- *  ixgbe_led_off - Turns off the software controllable LEDs.
+ *  ixgbe_led_off_generic - Turns off the software controllable LEDs.
  *  @hw: pointer to hardware structure
  *  @index: led number to turn off
  **/
-s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index)
+s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index)
 {
 	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 
@@ -321,15 +343,14 @@ s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index)
 	return 0;
 }
 
-
 /**
- *  ixgbe_init_eeprom - Initialize EEPROM params
+ *  ixgbe_init_eeprom_params_generic - Initialize EEPROM params
  *  @hw: pointer to hardware structure
  *
  *  Initializes the EEPROM parameters ixgbe_eeprom_info within the
  *  ixgbe_hw struct in order to set up EEPROM access.
  **/
-s32 ixgbe_init_eeprom(struct ixgbe_hw *hw)
+s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw)
 {
 	struct ixgbe_eeprom_info *eeprom = &hw->eeprom;
 	u32 eec;
@@ -337,6 +358,9 @@ s32 ixgbe_init_eeprom(struct ixgbe_hw *hw)
 
 	if (eeprom->type == ixgbe_eeprom_uninitialized) {
 		eeprom->type = ixgbe_eeprom_none;
+		/* Set default semaphore delay to 10ms which is a well
+		 * tested value */
+		eeprom->semaphore_delay = 10;
 
 		/*
 		 * Check for EEPROM present first.
@@ -369,18 +393,85 @@ s32 ixgbe_init_eeprom(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_read_eeprom - Read EEPROM word using EERD
+ *  ixgbe_read_eeprom_bit_bang_generic - Read EEPROM word using bit-bang
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be read
+ *  @data: read 16 bit value from EEPROM
+ *
+ *  Reads 16 bit value from EEPROM through bit-bang method
+ **/
+s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+                                       u16 *data)
+{
+	s32 status;
+	u16 word_in;
+	u8 read_opcode = IXGBE_EEPROM_READ_OPCODE_SPI;
+
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
+	}
+
+	/* Prepare the EEPROM for reading  */
+	status = ixgbe_acquire_eeprom(hw);
+
+	if (status == 0) {
+		if (ixgbe_ready_eeprom(hw) != 0) {
+			ixgbe_release_eeprom(hw);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	if (status == 0) {
+		ixgbe_standby_eeprom(hw);
+
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
+		if ((hw->eeprom.address_bits == 8) && (offset >= 128))
+			read_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+
+		/* Send the READ command (opcode + addr) */
+		ixgbe_shift_out_eeprom_bits(hw, read_opcode,
+		                            IXGBE_EEPROM_OPCODE_BITS);
+		ixgbe_shift_out_eeprom_bits(hw, (u16)(offset*2),
+		                            hw->eeprom.address_bits);
+
+		/* Read the data. */
+		word_in = ixgbe_shift_in_eeprom_bits(hw, 16);
+		*data = (word_in >> 8) | (word_in << 8);
+
+		/* End this read operation */
+		ixgbe_release_eeprom(hw);
+	}
+
+out:
+	return status;
+}
+
+/**
+ *  ixgbe_read_eeprom_generic - Read EEPROM word using EERD
  *  @hw: pointer to hardware structure
  *  @offset: offset of  word in the EEPROM to read
  *  @data: word read from the EEPROM
  *
  *  Reads a 16 bit word from the EEPROM using the EERD register.
  **/
-s32 ixgbe_read_eeprom(struct ixgbe_hw *hw, u16 offset, u16 *data)
+s32 ixgbe_read_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 *data)
 {
 	u32 eerd;
 	s32 status;
 
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
+	}
+
 	eerd = (offset << IXGBE_EEPROM_READ_ADDR_SHIFT) +
 	       IXGBE_EEPROM_READ_REG_START;
 
@@ -389,10 +480,11 @@ s32 ixgbe_read_eeprom(struct ixgbe_hw *hw, u16 offset, u16 *data)
 
 	if (status == 0)
 		*data = (IXGBE_READ_REG(hw, IXGBE_EERD) >>
-			IXGBE_EEPROM_READ_REG_DATA);
+		         IXGBE_EEPROM_READ_REG_DATA);
 	else
 		hw_dbg(hw, "Eeprom read timed out\n");
 
+out:
 	return status;
 }
 
@@ -420,6 +512,58 @@ static s32 ixgbe_poll_eeprom_eerd_done(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_acquire_eeprom - Acquire EEPROM using bit-bang
+ *  @hw: pointer to hardware structure
+ *
+ *  Prepares EEPROM for access using bit-bang method. This function should
+ *  be called before issuing a command to the EEPROM.
+ **/
+static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	u32 eec;
+	u32 i;
+
+	if (ixgbe_acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) != 0)
+		status = IXGBE_ERR_SWFW_SYNC;
+
+	if (status == 0) {
+		eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+		/* Request EEPROM Access */
+		eec |= IXGBE_EEC_REQ;
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+
+		for (i = 0; i < IXGBE_EEPROM_GRANT_ATTEMPTS; i++) {
+			eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+			if (eec & IXGBE_EEC_GNT)
+				break;
+			udelay(5);
+		}
+
+		/* Release if grant not acquired */
+		if (!(eec & IXGBE_EEC_GNT)) {
+			eec &= ~IXGBE_EEC_REQ;
+			IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+			hw_dbg(hw, "Could not acquire EEPROM grant\n");
+
+			ixgbe_release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	/* Setup EEPROM for Read/Write */
+	if (status == 0) {
+		/* Clear CS and SK */
+		eec &= ~(IXGBE_EEC_CS | IXGBE_EEC_SK);
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+		IXGBE_WRITE_FLUSH(hw);
+		udelay(1);
+	}
+	return status;
+}
+
+/**
  *  ixgbe_get_eeprom_semaphore - Get hardware semaphore
  *  @hw: pointer to hardware structure
  *
@@ -475,7 +619,7 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 		 */
 		if (i >= timeout) {
 			hw_dbg(hw, "Driver can't access the Eeprom - Semaphore "
-				 "not granted.\n");
+			       "not granted.\n");
 			ixgbe_release_eeprom_semaphore(hw);
 			status = IXGBE_ERR_EEPROM;
 		}
@@ -503,6 +647,217 @@ static void ixgbe_release_eeprom_semaphore(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_ready_eeprom - Polls for EEPROM ready
+ *  @hw: pointer to hardware structure
+ **/
+static s32 ixgbe_ready_eeprom(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	u16 i;
+	u8 spi_stat_reg;
+
+	/*
+	 * Read "Status Register" repeatedly until the LSB is cleared.  The
+	 * EEPROM will signal that the command has been completed by clearing
+	 * bit 0 of the internal status register.  If it's not cleared within
+	 * 5 milliseconds, then error out.
+	 */
+	for (i = 0; i < IXGBE_EEPROM_MAX_RETRY_SPI; i += 5) {
+		ixgbe_shift_out_eeprom_bits(hw, IXGBE_EEPROM_RDSR_OPCODE_SPI,
+		                            IXGBE_EEPROM_OPCODE_BITS);
+		spi_stat_reg = (u8)ixgbe_shift_in_eeprom_bits(hw, 8);
+		if (!(spi_stat_reg & IXGBE_EEPROM_STATUS_RDY_SPI))
+			break;
+
+		udelay(5);
+		ixgbe_standby_eeprom(hw);
+	};
+
+	/*
+	 * On some parts, SPI write time could vary from 0-20mSec on 3.3V
+	 * devices (and only 0-5mSec on 5V devices)
+	 */
+	if (i >= IXGBE_EEPROM_MAX_RETRY_SPI) {
+		hw_dbg(hw, "SPI EEPROM Status error\n");
+		status = IXGBE_ERR_EEPROM;
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_standby_eeprom - Returns EEPROM to a "standby" state
+ *  @hw: pointer to hardware structure
+ **/
+static void ixgbe_standby_eeprom(struct ixgbe_hw *hw)
+{
+	u32 eec;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	/* Toggle CS to flush commands */
+	eec |= IXGBE_EEC_CS;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+	eec &= ~IXGBE_EEC_CS;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_shift_out_eeprom_bits - Shift data bits out to the EEPROM.
+ *  @hw: pointer to hardware structure
+ *  @data: data to send to the EEPROM
+ *  @count: number of bits to shift out
+ **/
+static void ixgbe_shift_out_eeprom_bits(struct ixgbe_hw *hw, u16 data,
+                                        u16 count)
+{
+	u32 eec;
+	u32 mask;
+	u32 i;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	/*
+	 * Mask is used to shift "count" bits of "data" out to the EEPROM
+	 * one bit at a time.  Determine the starting bit based on count
+	 */
+	mask = 0x01 << (count - 1);
+
+	for (i = 0; i < count; i++) {
+		/*
+		 * A "1" is shifted out to the EEPROM by setting bit "DI" to a
+		 * "1", and then raising and then lowering the clock (the SK
+		 * bit controls the clock input to the EEPROM).  A "0" is
+		 * shifted out to the EEPROM by setting "DI" to "0" and then
+		 * raising and then lowering the clock.
+		 */
+		if (data & mask)
+			eec |= IXGBE_EEC_DI;
+		else
+			eec &= ~IXGBE_EEC_DI;
+
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+		IXGBE_WRITE_FLUSH(hw);
+
+		udelay(1);
+
+		ixgbe_raise_eeprom_clk(hw, &eec);
+		ixgbe_lower_eeprom_clk(hw, &eec);
+
+		/*
+		 * Shift mask to signify next bit of data to shift in to the
+		 * EEPROM
+		 */
+		mask = mask >> 1;
+	};
+
+	/* We leave the "DI" bit set to "0" when we leave this routine. */
+	eec &= ~IXGBE_EEC_DI;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+}
+
+/**
+ *  ixgbe_shift_in_eeprom_bits - Shift data bits in from the EEPROM
+ *  @hw: pointer to hardware structure
+ **/
+static u16 ixgbe_shift_in_eeprom_bits(struct ixgbe_hw *hw, u16 count)
+{
+	u32 eec;
+	u32 i;
+	u16 data = 0;
+
+	/*
+	 * In order to read a register from the EEPROM, we need to shift
+	 * 'count' bits in from the EEPROM. Bits are "shifted in" by raising
+	 * the clock input to the EEPROM (setting the SK bit), and then reading
+	 * the value of the "DO" bit.  During this "shifting in" process the
+	 * "DI" bit should always be clear.
+	 */
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	eec &= ~(IXGBE_EEC_DO | IXGBE_EEC_DI);
+
+	for (i = 0; i < count; i++) {
+		data = data << 1;
+		ixgbe_raise_eeprom_clk(hw, &eec);
+
+		eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+		eec &= ~(IXGBE_EEC_DI);
+		if (eec & IXGBE_EEC_DO)
+			data |= 1;
+
+		ixgbe_lower_eeprom_clk(hw, &eec);
+	}
+
+	return data;
+}
+
+/**
+ *  ixgbe_raise_eeprom_clk - Raises the EEPROM's clock input.
+ *  @hw: pointer to hardware structure
+ *  @eec: EEC register's current value
+ **/
+static void ixgbe_raise_eeprom_clk(struct ixgbe_hw *hw, u32 *eec)
+{
+	/*
+	 * Raise the clock input to the EEPROM
+	 * (setting the SK bit), then delay
+	 */
+	*eec = *eec | IXGBE_EEC_SK;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, *eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_lower_eeprom_clk - Lowers the EEPROM's clock input.
+ *  @hw: pointer to hardware structure
+ *  @eecd: EECD's current value
+ **/
+static void ixgbe_lower_eeprom_clk(struct ixgbe_hw *hw, u32 *eec)
+{
+	/*
+	 * Lower the clock input to the EEPROM (clearing the SK bit), then
+	 * delay
+	 */
+	*eec = *eec & ~IXGBE_EEC_SK;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, *eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_release_eeprom - Release EEPROM, release semaphores
+ *  @hw: pointer to hardware structure
+ **/
+static void ixgbe_release_eeprom(struct ixgbe_hw *hw)
+{
+	u32 eec;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	eec |= IXGBE_EEC_CS;  /* Pull CS high */
+	eec &= ~IXGBE_EEC_SK; /* Lower SCK */
+
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+
+	udelay(1);
+
+	/* Stop requesting EEPROM access */
+	eec &= ~IXGBE_EEC_REQ;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+
+	ixgbe_release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+}
+
+/**
  *  ixgbe_calc_eeprom_checksum - Calculates and returns the checksum
  *  @hw: pointer to hardware structure
  **/
@@ -517,7 +872,7 @@ static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw)
 
 	/* Include 0x0-0x3F in the checksum */
 	for (i = 0; i < IXGBE_EEPROM_CHECKSUM; i++) {
-		if (ixgbe_read_eeprom(hw, i, &word) != 0) {
+		if (hw->eeprom.ops.read(hw, i, &word) != 0) {
 			hw_dbg(hw, "EEPROM read failed\n");
 			break;
 		}
@@ -526,15 +881,15 @@ static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw)
 
 	/* Include all data from pointers except for the fw pointer */
 	for (i = IXGBE_PCIE_ANALOG_PTR; i < IXGBE_FW_PTR; i++) {
-		ixgbe_read_eeprom(hw, i, &pointer);
+		hw->eeprom.ops.read(hw, i, &pointer);
 
 		/* Make sure the pointer seems valid */
 		if (pointer != 0xFFFF && pointer != 0) {
-			ixgbe_read_eeprom(hw, pointer, &length);
+			hw->eeprom.ops.read(hw, pointer, &length);
 
 			if (length != 0xFFFF && length != 0) {
 				for (j = pointer+1; j <= pointer+length; j++) {
-					ixgbe_read_eeprom(hw, j, &word);
+					hw->eeprom.ops.read(hw, j, &word);
 					checksum += word;
 				}
 			}
@@ -547,14 +902,15 @@ static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_validate_eeprom_checksum - Validate EEPROM checksum
+ *  ixgbe_validate_eeprom_checksum_generic - Validate EEPROM checksum
  *  @hw: pointer to hardware structure
  *  @checksum_val: calculated checksum
  *
  *  Performs checksum calculation and validates the EEPROM checksum.  If the
  *  caller does not need checksum_val, the value can be NULL.
  **/
-s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val)
+s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
+                                           u16 *checksum_val)
 {
 	s32 status;
 	u16 checksum;
@@ -565,12 +921,12 @@ s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val)
 	 * not continue or we could be in for a very long wait while every
 	 * EEPROM read fails
 	 */
-	status = ixgbe_read_eeprom(hw, 0, &checksum);
+	status = hw->eeprom.ops.read(hw, 0, &checksum);
 
 	if (status == 0) {
 		checksum = ixgbe_calc_eeprom_checksum(hw);
 
-		ixgbe_read_eeprom(hw, IXGBE_EEPROM_CHECKSUM, &read_checksum);
+		hw->eeprom.ops.read(hw, IXGBE_EEPROM_CHECKSUM, &read_checksum);
 
 		/*
 		 * Verify read checksum from EEPROM is the same as
@@ -590,6 +946,33 @@ s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val)
 }
 
 /**
+ *  ixgbe_update_eeprom_checksum_generic - Updates the EEPROM checksum
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw)
+{
+	s32 status;
+	u16 checksum;
+
+	/*
+	 * Read the first word from the EEPROM. If this times out or fails, do
+	 * not continue or we could be in for a very long wait while every
+	 * EEPROM read fails
+	 */
+	status = hw->eeprom.ops.read(hw, 0, &checksum);
+
+	if (status == 0) {
+		checksum = ixgbe_calc_eeprom_checksum(hw);
+		status = hw->eeprom.ops.write(hw, IXGBE_EEPROM_CHECKSUM,
+		                            checksum);
+	} else {
+		hw_dbg(hw, "EEPROM read failed\n");
+	}
+
+	return status;
+}
+
+/**
  *  ixgbe_validate_mac_addr - Validate MAC address
  *  @mac_addr: pointer to MAC address.
  *
@@ -607,58 +990,137 @@ s32 ixgbe_validate_mac_addr(u8 *mac_addr)
 		status = IXGBE_ERR_INVALID_MAC_ADDR;
 	/* Reject the zero address */
 	else if (mac_addr[0] == 0 && mac_addr[1] == 0 && mac_addr[2] == 0 &&
-		 mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0)
+	         mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0)
 		status = IXGBE_ERR_INVALID_MAC_ADDR;
 
 	return status;
 }
 
 /**
- *  ixgbe_set_rar - Set RX address register
+ *  ixgbe_set_rar_generic - Set Rx address register
  *  @hw: pointer to hardware structure
- *  @addr: Address to put into receive address register
  *  @index: Receive address register to write
- *  @vind: Vind to set RAR to
+ *  @addr: Address to put into receive address register
+ *  @vmdq: VMDq "set" or "pool" index
  *  @enable_addr: set flag that address is active
  *
  *  Puts an ethernet address into a receive address register.
  **/
-s32 ixgbe_set_rar(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
-		  u32 enable_addr)
+s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
+                          u32 enable_addr)
 {
 	u32 rar_low, rar_high;
+	u32 rar_entries = hw->mac.num_rar_entries;
 
-	/*
-	 * HW expects these in little endian so we reverse the byte order from
-	 * network order (big endian) to little endian
-	 */
-	rar_low = ((u32)addr[0] |
-		   ((u32)addr[1] << 8) |
-		   ((u32)addr[2] << 16) |
-		   ((u32)addr[3] << 24));
+	/* setup VMDq pool selection before this RAR gets enabled */
+	hw->mac.ops.set_vmdq(hw, index, vmdq);
 
-	rar_high = ((u32)addr[4] |
-		    ((u32)addr[5] << 8) |
-		    ((vind << IXGBE_RAH_VIND_SHIFT) & IXGBE_RAH_VIND_MASK));
+	/* Make sure we are using a valid rar index range */
+	if (index < rar_entries) {
+		/*
+		 * HW expects these in little endian so we reverse the byte
+		 * order from network order (big endian) to little endian
+		 */
+		rar_low = ((u32)addr[0] |
+		           ((u32)addr[1] << 8) |
+		           ((u32)addr[2] << 16) |
+		           ((u32)addr[3] << 24));
+		/*
+		 * Some parts put the VMDq setting in the extra RAH bits,
+		 * so save everything except the lower 16 bits that hold part
+		 * of the address and the address valid bit.
+		 */
+		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+		rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
+		rar_high |= ((u32)addr[4] | ((u32)addr[5] << 8));
 
-	if (enable_addr != 0)
-		rar_high |= IXGBE_RAH_AV;
+		if (enable_addr != 0)
+			rar_high |= IXGBE_RAH_AV;
 
-	IXGBE_WRITE_REG(hw, IXGBE_RAL(index), rar_low);
-	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(index), rar_low);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+	} else {
+		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+	}
 
 	return 0;
 }
 
 /**
- *  ixgbe_init_rx_addrs - Initializes receive address filters.
+ *  ixgbe_clear_rar_generic - Remove Rx address register
+ *  @hw: pointer to hardware structure
+ *  @index: Receive address register to write
+ *
+ *  Clears an ethernet address from a receive address register.
+ **/
+s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index)
+{
+	u32 rar_high;
+	u32 rar_entries = hw->mac.num_rar_entries;
+
+	/* Make sure we are using a valid rar index range */
+	if (index < rar_entries) {
+		/*
+		 * Some parts put the VMDq setting in the extra RAH bits,
+		 * so save everything except the lower 16 bits that hold part
+		 * of the address and the address valid bit.
+		 */
+		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+		rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
+
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(index), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+	} else {
+		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+	}
+
+	/* clear VMDq pool/queue selection for this RAR */
+	hw->mac.ops.clear_vmdq(hw, index, IXGBE_CLEAR_VMDQ_ALL);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_enable_rar - Enable Rx address register
+ *  @hw: pointer to hardware structure
+ *  @index: index into the RAR table
+ *
+ *  Enables the select receive address register.
+ **/
+static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index)
+{
+	u32 rar_high;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+	rar_high |= IXGBE_RAH_AV;
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+}
+
+/**
+ *  ixgbe_disable_rar - Disable Rx address register
+ *  @hw: pointer to hardware structure
+ *  @index: index into the RAR table
+ *
+ *  Disables the select receive address register.
+ **/
+static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index)
+{
+	u32 rar_high;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+	rar_high &= (~IXGBE_RAH_AV);
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+}
+
+/**
+ *  ixgbe_init_rx_addrs_generic - Initializes receive address filters.
  *  @hw: pointer to hardware structure
  *
  *  Places the MAC address in receive address register 0 and clears the rest
- *  of the receive addresss registers. Clears the multicast table. Assumes
+ *  of the receive address registers. Clears the multicast table. Assumes
  *  the receiver is in reset when the routine is called.
  **/
-static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
+s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 {
 	u32 i;
 	u32 rar_entries = hw->mac.num_rar_entries;
@@ -671,29 +1133,30 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
 	if (ixgbe_validate_mac_addr(hw->mac.addr) ==
 	    IXGBE_ERR_INVALID_MAC_ADDR) {
 		/* Get the MAC address from the RAR0 for later reference */
-		ixgbe_get_mac_addr(hw, hw->mac.addr);
+		hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
 
 		hw_dbg(hw, " Keeping Current RAR0 Addr =%.2X %.2X %.2X ",
-			  hw->mac.addr[0], hw->mac.addr[1],
-			  hw->mac.addr[2]);
+		       hw->mac.addr[0], hw->mac.addr[1],
+		       hw->mac.addr[2]);
 		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
-			  hw->mac.addr[4], hw->mac.addr[5]);
+		       hw->mac.addr[4], hw->mac.addr[5]);
 	} else {
 		/* Setup the receive address. */
 		hw_dbg(hw, "Overriding MAC Address in RAR[0]\n");
 		hw_dbg(hw, " New MAC Addr =%.2X %.2X %.2X ",
-			  hw->mac.addr[0], hw->mac.addr[1],
-			  hw->mac.addr[2]);
+		       hw->mac.addr[0], hw->mac.addr[1],
+		       hw->mac.addr[2]);
 		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
-			  hw->mac.addr[4], hw->mac.addr[5]);
+		       hw->mac.addr[4], hw->mac.addr[5]);
 
-		ixgbe_set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
+		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 	}
+	hw->addr_ctrl.overflow_promisc = 0;
 
 	hw->addr_ctrl.rar_used_count = 1;
 
 	/* Zero out the other receive addresses. */
-	hw_dbg(hw, "Clearing RAR[1-15]\n");
+	hw_dbg(hw, "Clearing RAR[1-%d]\n", rar_entries - 1);
 	for (i = 1; i < rar_entries; i++) {
 		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
@@ -708,6 +1171,9 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
 	for (i = 0; i < hw->mac.mcft_size; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
 
+	if (hw->mac.ops.init_uta_tables)
+		hw->mac.ops.init_uta_tables(hw);
+
 	return 0;
 }
 
@@ -718,7 +1184,7 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
  *
  *  Adds it to unused receive address register or goes into promiscuous mode.
  **/
-void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
+static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
 {
 	u32 rar_entries = hw->mac.num_rar_entries;
 	u32 rar;
@@ -733,7 +1199,7 @@ void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
 	if (hw->addr_ctrl.rar_used_count < rar_entries) {
 		rar = hw->addr_ctrl.rar_used_count -
 		      hw->addr_ctrl.mc_addr_in_rar_count;
-		ixgbe_set_rar(hw, rar, addr, 0, IXGBE_RAH_AV);
+		hw->mac.ops.set_rar(hw, rar, addr, vmdq, IXGBE_RAH_AV);
 		hw_dbg(hw, "Added a secondary address to RAR[%d]\n", rar);
 		hw->addr_ctrl.rar_used_count++;
 	} else {
@@ -744,7 +1210,7 @@ void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
 }
 
 /**
- *  ixgbe_update_uc_addr_list - Updates MAC list of secondary addresses
+ *  ixgbe_update_uc_addr_list_generic - Updates MAC list of secondary addresses
  *  @hw: pointer to hardware structure
  *  @addr_list: the list of new addresses
  *  @addr_count: number of addresses
@@ -757,7 +1223,7 @@ void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
  *  Drivers using secondary unicast addresses must set user_set_promisc when
  *  manually putting the device into promiscuous mode.
  **/
-s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
+s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
                               u32 addr_count, ixgbe_mc_addr_itr next)
 {
 	u8 *addr;
@@ -787,7 +1253,7 @@ s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
 	for (i = 0; i < addr_count; i++) {
 		hw_dbg(hw, " Adding the secondary addresses:\n");
 		addr = next(hw, &addr_list, &vmdq);
-		ixgbe_add_uc_addr(hw, addr);
+		ixgbe_add_uc_addr(hw, addr, vmdq);
 	}
 
 	if (hw->addr_ctrl.overflow_promisc) {
@@ -808,7 +1274,7 @@ s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
 		}
 	}
 
-	hw_dbg(hw, "ixgbe_update_uc_addr_list Complete\n");
+	hw_dbg(hw, "ixgbe_update_uc_addr_list_generic Complete\n");
 	return 0;
 }
 
@@ -821,7 +1287,7 @@ s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
  *  bit-vector to set in the multicast table. The hardware uses 12 bits, from
  *  incoming rx multicast addresses, to determine the bit-vector to check in
  *  the MTA. Which of the 4 combination, of 12-bits, the hardware uses is set
- *  by the MO field of the MCSTCTRL. The MO field is set during initalization
+ *  by the MO field of the MCSTCTRL. The MO field is set during initialization
  *  to mc_filter_type.
  **/
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr)
@@ -829,19 +1295,19 @@ static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr)
 	u32 vector = 0;
 
 	switch (hw->mac.mc_filter_type) {
-	case 0:	  /* use bits [47:36] of the address */
+	case 0:   /* use bits [47:36] of the address */
 		vector = ((mc_addr[4] >> 4) | (((u16)mc_addr[5]) << 4));
 		break;
-	case 1:	  /* use bits [46:35] of the address */
+	case 1:   /* use bits [46:35] of the address */
 		vector = ((mc_addr[4] >> 3) | (((u16)mc_addr[5]) << 5));
 		break;
-	case 2:	  /* use bits [45:34] of the address */
+	case 2:   /* use bits [45:34] of the address */
 		vector = ((mc_addr[4] >> 2) | (((u16)mc_addr[5]) << 6));
 		break;
-	case 3:	  /* use bits [43:32] of the address */
+	case 3:   /* use bits [43:32] of the address */
 		vector = ((mc_addr[4]) | (((u16)mc_addr[5]) << 8));
 		break;
-	default:	 /* Invalid mc_filter_type */
+	default:  /* Invalid mc_filter_type */
 		hw_dbg(hw, "MC filter type param set incorrectly\n");
 		break;
 	}
@@ -896,20 +1362,21 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *mc_addr)
 static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 {
 	u32 rar_entries = hw->mac.num_rar_entries;
+	u32 rar;
 
 	hw_dbg(hw, " MC Addr =%.2X %.2X %.2X %.2X %.2X %.2X\n",
-		  mc_addr[0], mc_addr[1], mc_addr[2],
-		  mc_addr[3], mc_addr[4], mc_addr[5]);
+	       mc_addr[0], mc_addr[1], mc_addr[2],
+	       mc_addr[3], mc_addr[4], mc_addr[5]);
 
 	/*
 	 * Place this multicast address in the RAR if there is room,
 	 * else put it in the MTA
 	 */
 	if (hw->addr_ctrl.rar_used_count < rar_entries) {
-		ixgbe_set_rar(hw, hw->addr_ctrl.rar_used_count,
-			      mc_addr, 0, IXGBE_RAH_AV);
-		hw_dbg(hw, "Added a multicast address to RAR[%d]\n",
-			  hw->addr_ctrl.rar_used_count);
+		/* use RAR from the end up for multicast */
+		rar = rar_entries - hw->addr_ctrl.mc_addr_in_rar_count - 1;
+		hw->mac.ops.set_rar(hw, rar, mc_addr, 0, IXGBE_RAH_AV);
+		hw_dbg(hw, "Added a multicast address to RAR[%d]\n", rar);
 		hw->addr_ctrl.rar_used_count++;
 		hw->addr_ctrl.mc_addr_in_rar_count++;
 	} else {
@@ -920,19 +1387,19 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 }
 
 /**
- *  ixgbe_update_mc_addr_list - Updates MAC list of multicast addresses
+ *  ixgbe_update_mc_addr_list_generic - Updates MAC list of multicast addresses
  *  @hw: pointer to hardware structure
  *  @mc_addr_list: the list of new multicast addresses
  *  @mc_addr_count: number of addresses
  *  @next: iterator function to walk the multicast address list
  *
  *  The given list replaces any existing list. Clears the MC addrs from receive
- *  address registers and the multicast table. Uses unsed receive address
+ *  address registers and the multicast table. Uses unused receive address
  *  registers for the first multicast addresses, and hashes the rest into the
  *  multicast table.
  **/
-s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
-			      u32 mc_addr_count, ixgbe_mc_addr_itr next)
+s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
+                                      u32 mc_addr_count, ixgbe_mc_addr_itr next)
 {
 	u32 i;
 	u32 rar_entries = hw->mac.num_rar_entries;
@@ -948,7 +1415,8 @@ s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
 	hw->addr_ctrl.mta_in_use = 0;
 
 	/* Zero out the other receive addresses. */
-	hw_dbg(hw, "Clearing RAR[1-15]\n");
+	hw_dbg(hw, "Clearing RAR[%d-%d]\n", hw->addr_ctrl.rar_used_count,
+	          rar_entries - 1);
 	for (i = hw->addr_ctrl.rar_used_count; i < rar_entries; i++) {
 		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
@@ -968,190 +1436,55 @@ s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
 	/* Enable mta */
 	if (hw->addr_ctrl.mta_in_use > 0)
 		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL,
-				IXGBE_MCSTCTRL_MFE | hw->mac.mc_filter_type);
+		                IXGBE_MCSTCTRL_MFE | hw->mac.mc_filter_type);
 
-	hw_dbg(hw, "ixgbe_update_mc_addr_list Complete\n");
+	hw_dbg(hw, "ixgbe_update_mc_addr_list_generic Complete\n");
 	return 0;
 }
 
 /**
- *  ixgbe_clear_vfta - Clear VLAN filter table
+ *  ixgbe_enable_mc_generic - Enable multicast address in RAR
  *  @hw: pointer to hardware structure
  *
- *  Clears the VLAN filer table, and the VMDq index associated with the filter
+ *  Enables multicast address in RAR and the use of the multicast hash table.
  **/
-static s32 ixgbe_clear_vfta(struct ixgbe_hw *hw)
+s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw)
 {
-	u32 offset;
-	u32 vlanbyte;
+	u32 i;
+	u32 rar_entries = hw->mac.num_rar_entries;
+	struct ixgbe_addr_filter_info *a = &hw->addr_ctrl;
 
-	for (offset = 0; offset < hw->mac.vft_size; offset++)
-		IXGBE_WRITE_REG(hw, IXGBE_VFTA(offset), 0);
+	if (a->mc_addr_in_rar_count > 0)
+		for (i = (rar_entries - a->mc_addr_in_rar_count);
+		     i < rar_entries; i++)
+			ixgbe_enable_rar(hw, i);
 
-	for (vlanbyte = 0; vlanbyte < 4; vlanbyte++)
-		for (offset = 0; offset < hw->mac.vft_size; offset++)
-			IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vlanbyte, offset),
-					0);
+	if (a->mta_in_use > 0)
+		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, IXGBE_MCSTCTRL_MFE |
+		                hw->mac.mc_filter_type);
 
 	return 0;
 }
 
 /**
- *  ixgbe_set_vfta - Set VLAN filter table
+ *  ixgbe_disable_mc_generic - Disable multicast address in RAR
  *  @hw: pointer to hardware structure
- *  @vlan: VLAN id to write to VLAN filter
- *  @vind: VMDq output index that maps queue to VLAN id in VFTA
- *  @vlan_on: boolean flag to turn on/off VLAN in VFTA
  *
- *  Turn on/off specified VLAN in the VLAN filter table.
+ *  Disables multicast address in RAR and the use of the multicast hash table.
  **/
-s32 ixgbe_set_vfta(struct ixgbe_hw *hw, u32 vlan, u32 vind,
-		   bool vlan_on)
+s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw)
 {
-	u32 VftaIndex;
-	u32 BitOffset;
-	u32 VftaReg;
-	u32 VftaByte;
-
-	/* Determine 32-bit word position in array */
-	VftaIndex = (vlan >> 5) & 0x7F;   /* upper seven bits */
-
-	/* Determine the location of the (VMD) queue index */
-	VftaByte =  ((vlan >> 3) & 0x03); /* bits (4:3) indicating byte array */
-	BitOffset = (vlan & 0x7) << 2;    /* lower 3 bits indicate nibble */
-
-	/* Set the nibble for VMD queue index */
-	VftaReg = IXGBE_READ_REG(hw, IXGBE_VFTAVIND(VftaByte, VftaIndex));
-	VftaReg &= (~(0x0F << BitOffset));
-	VftaReg |= (vind << BitOffset);
-	IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(VftaByte, VftaIndex), VftaReg);
-
-	/* Determine the location of the bit for this VLAN id */
-	BitOffset = vlan & 0x1F;	   /* lower five bits */
-
-	VftaReg = IXGBE_READ_REG(hw, IXGBE_VFTA(VftaIndex));
-	if (vlan_on)
-		/* Turn on this VLAN id */
-		VftaReg |= (1 << BitOffset);
-	else
-		/* Turn off this VLAN id */
-		VftaReg &= ~(1 << BitOffset);
-	IXGBE_WRITE_REG(hw, IXGBE_VFTA(VftaIndex), VftaReg);
-
-	return 0;
-}
-
-/**
- *  ixgbe_setup_fc - Configure flow control settings
- *  @hw: pointer to hardware structure
- *  @packetbuf_num: packet buffer number (0-7)
- *
- *  Configures the flow control settings based on SW configuration.
- *  This function is used for 802.3x flow control configuration only.
- **/
-s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
-{
-	u32 frctl_reg;
-	u32 rmcs_reg;
-
-	if (packetbuf_num < 0 || packetbuf_num > 7)
-		hw_dbg(hw, "Invalid packet buffer number [%d], expected range "
-		       "is 0-7\n", packetbuf_num);
-
-	frctl_reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
-	frctl_reg &= ~(IXGBE_FCTRL_RFCE | IXGBE_FCTRL_RPFCE);
-
-	rmcs_reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
-	rmcs_reg &= ~(IXGBE_RMCS_TFCE_PRIORITY | IXGBE_RMCS_TFCE_802_3X);
-
-	/*
-	 * 10 gig parts do not have a word in the EEPROM to determine the
-	 * default flow control setting, so we explicitly set it to full.
-	 */
-	if (hw->fc.type == ixgbe_fc_default)
-		hw->fc.type = ixgbe_fc_full;
-
-	/*
-	 * We want to save off the original Flow Control configuration just in
-	 * case we get disconnected and then reconnected into a different hub
-	 * or switch with different Flow Control capabilities.
-	 */
-	hw->fc.type = hw->fc.original_type;
-
-	/*
-	 * The possible values of the "flow_control" parameter are:
-	 * 0: Flow control is completely disabled
-	 * 1: Rx flow control is enabled (we can receive pause frames but not
-	 *    send pause frames).
-	 * 2: Tx flow control is enabled (we can send pause frames but we do not
-	 *    support receiving pause frames)
-	 * 3: Both Rx and TX flow control (symmetric) are enabled.
-	 * other: Invalid.
-	 */
-	switch (hw->fc.type) {
-	case ixgbe_fc_none:
-		break;
-	case ixgbe_fc_rx_pause:
-		/*
-		 * RX Flow control is enabled,
-		 * and TX Flow control is disabled.
-		 */
-		frctl_reg |= IXGBE_FCTRL_RFCE;
-		break;
-	case ixgbe_fc_tx_pause:
-		/*
-		 * TX Flow control is enabled, and RX Flow control is disabled,
-		 * by a software over-ride.
-		 */
-		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
-		break;
-	case ixgbe_fc_full:
-		/*
-		 * Flow control (both RX and TX) is enabled by a software
-		 * over-ride.
-		 */
-		frctl_reg |= IXGBE_FCTRL_RFCE;
-		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
-		break;
-	default:
-		/* We should never get here.  The value should be 0-3. */
-		hw_dbg(hw, "Flow control param set incorrectly\n");
-		break;
-	}
+	u32 i;
+	u32 rar_entries = hw->mac.num_rar_entries;
+	struct ixgbe_addr_filter_info *a = &hw->addr_ctrl;
 
-	/* Enable 802.3x based flow control settings. */
-	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, frctl_reg);
-	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
+	if (a->mc_addr_in_rar_count > 0)
+		for (i = (rar_entries - a->mc_addr_in_rar_count);
+		     i < rar_entries; i++)
+			ixgbe_disable_rar(hw, i);
 
-	/*
-	 * Check for invalid software configuration, zeros are completely
-	 * invalid for all parameters used past this point, and if we enable
-	 * flow control with zero water marks, we blast flow control packets.
-	 */
-	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
-		hw_dbg(hw, "Flow control structure initialized incorrectly\n");
-		return IXGBE_ERR_INVALID_LINK_SETTINGS;
-	}
-
-	/*
-	 * We need to set up the Receive Threshold high and low water
-	 * marks as well as (optionally) enabling the transmission of
-	 * XON frames.
-	 */
-	if (hw->fc.type & ixgbe_fc_tx_pause) {
-		if (hw->fc.send_xon) {
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
-					(hw->fc.low_water | IXGBE_FCRTL_XONE));
-		} else {
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
-					hw->fc.low_water);
-		}
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num),
-				(hw->fc.high_water)|IXGBE_FCRTH_FCEN);
-	}
-
-	IXGBE_WRITE_REG(hw, IXGBE_FCTTV(0), hw->fc.pause_time);
-	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, (hw->fc.pause_time >> 1));
+	if (a->mta_in_use > 0)
+		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, hw->mac.mc_filter_type);
 
 	return 0;
 }
@@ -1167,13 +1500,24 @@ s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
  **/
 s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 {
-	u32 ctrl;
-	s32 i;
+	u32 i;
+	u32 reg_val;
+	u32 number_of_queues;
 	s32 status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
 
-	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-	ctrl |= IXGBE_CTRL_GIO_DIS;
-	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
+	/* Disable the receive unit by stopping each queue */
+	number_of_queues = hw->mac.max_rx_queues;
+	for (i = 0; i < number_of_queues; i++) {
+		reg_val = IXGBE_READ_REG(hw, IXGBE_RXDCTL(i));
+		if (reg_val & IXGBE_RXDCTL_ENABLE) {
+			reg_val &= ~IXGBE_RXDCTL_ENABLE;
+			IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(i), reg_val);
+		}
+	}
+
+	reg_val = IXGBE_READ_REG(hw, IXGBE_CTRL);
+	reg_val |= IXGBE_CTRL_GIO_DIS;
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, reg_val);
 
 	for (i = 0; i < IXGBE_PCI_MASTER_DISABLE_TIMEOUT; i++) {
 		if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO)) {
@@ -1188,11 +1532,11 @@ s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 
 
 /**
- *  ixgbe_acquire_swfw_sync - Aquire SWFW semaphore
+ *  ixgbe_acquire_swfw_sync - Acquire SWFW semaphore
  *  @hw: pointer to hardware structure
- *  @mask: Mask to specify wich semaphore to acquire
+ *  @mask: Mask to specify which semaphore to acquire
  *
- *  Aquires the SWFW semaphore throught the GSSR register for the specified
+ *  Acquires the SWFW semaphore thought the GSSR register for the specified
  *  function (CSR, PHY0, PHY1, EEPROM, Flash)
  **/
 s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
@@ -1234,9 +1578,9 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 /**
  *  ixgbe_release_swfw_sync - Release SWFW semaphore
  *  @hw: pointer to hardware structure
- *  @mask: Mask to specify wich semaphore to release
+ *  @mask: Mask to specify which semaphore to release
  *
- *  Releases the SWFW semaphore throught the GSSR register for the specified
+ *  Releases the SWFW semaphore thought the GSSR register for the specified
  *  function (CSR, PHY0, PHY1, EEPROM, Flash)
  **/
 void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask)
@@ -1253,45 +1597,3 @@ void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 	ixgbe_release_eeprom_semaphore(hw);
 }
 
-/**
- *  ixgbe_read_analog_reg8 - Reads 8 bit Atlas analog register
- *  @hw: pointer to hardware structure
- *  @reg: analog register to read
- *  @val: read value
- *
- *  Performs write operation to analog register specified.
- **/
-s32 ixgbe_read_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 *val)
-{
-	u32  atlas_ctl;
-
-	IXGBE_WRITE_REG(hw, IXGBE_ATLASCTL,
-			IXGBE_ATLASCTL_WRITE_CMD | (reg << 8));
-	IXGBE_WRITE_FLUSH(hw);
-	udelay(10);
-	atlas_ctl = IXGBE_READ_REG(hw, IXGBE_ATLASCTL);
-	*val = (u8)atlas_ctl;
-
-	return 0;
-}
-
-/**
- *  ixgbe_write_analog_reg8 - Writes 8 bit Atlas analog register
- *  @hw: pointer to hardware structure
- *  @reg: atlas register to write
- *  @val: value to write
- *
- *  Performs write operation to Atlas analog register specified.
- **/
-s32 ixgbe_write_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 val)
-{
-	u32  atlas_ctl;
-
-	atlas_ctl = (reg << 8) | val;
-	IXGBE_WRITE_REG(hw, IXGBE_ATLASCTL, atlas_ctl);
-	IXGBE_WRITE_FLUSH(hw);
-	udelay(10);
-
-	return 0;
-}
-
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index c75ecba..192f8d0 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -31,36 +30,45 @@
 
 #include "ixgbe_type.h"
 
-s32 ixgbe_init_hw(struct ixgbe_hw *hw);
-s32 ixgbe_start_hw(struct ixgbe_hw *hw);
-s32 ixgbe_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr);
-s32 ixgbe_stop_adapter(struct ixgbe_hw *hw);
-s32 ixgbe_read_part_num(struct ixgbe_hw *hw, u32 *part_num);
-
-s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index);
-s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index);
-
-s32 ixgbe_init_eeprom(struct ixgbe_hw *hw);
-s32 ixgbe_read_eeprom(struct ixgbe_hw *hw, u16 offset, u16 *data);
-s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val);
-
-s32 ixgbe_set_rar(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
-		  u32 enable_addr);
-s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
-			      u32 mc_addr_count, ixgbe_mc_addr_itr next);
-s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *uc_addr_list,
-			      u32 mc_addr_count, ixgbe_mc_addr_itr next);
-s32 ixgbe_set_vfta(struct ixgbe_hw *hw, u32 vlan, u32 vind, bool vlan_on);
-s32 ixgbe_validate_mac_addr(u8 *mac_addr);
-
-s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packtetbuf_num);
+s32 ixgbe_init_ops_generic(struct ixgbe_hw *hw);
+s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw);
+s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw);
+s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw);
+s32 ixgbe_read_pba_num_generic(struct ixgbe_hw *hw, u32 *pba_num);
+s32 ixgbe_get_mac_addr_generic(struct ixgbe_hw *hw, u8 *mac_addr);
+s32 ixgbe_get_bus_info_generic(struct ixgbe_hw *hw);
+s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw);
+
+s32 ixgbe_led_on_generic(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index);
+
+s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw);
+s32 ixgbe_read_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 *data);
+s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+                                       u16 *data);
+s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
+                                           u16 *checksum_val);
+s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw);
+
+s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
+                          u32 enable_addr);
+s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw);
+s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
+                                      u32 mc_addr_count,
+                                      ixgbe_mc_addr_itr func);
+s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
+                                      u32 addr_count, ixgbe_mc_addr_itr func);
+s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
+s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 
+s32 ixgbe_validate_mac_addr(u8 *mac_addr);
 s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask);
 void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask);
 s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw);
 
-s32 ixgbe_read_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 *val);
-s32 ixgbe_write_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 val);
+s32 ixgbe_read_analog_reg8_generic(struct ixgbe_hw *hw, u32 reg, u8 *val);
+s32 ixgbe_write_analog_reg8_generic(struct ixgbe_hw *hw, u32 reg, u8 val);
 
 #define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 61c000e..f7aefb5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -48,7 +47,7 @@ struct ixgbe_stats {
 };
 
 #define IXGBE_STAT(m) sizeof(((struct ixgbe_adapter *)0)->m), \
-		      offsetof(struct ixgbe_adapter, m)
+                             offsetof(struct ixgbe_adapter, m)
 static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_packets", IXGBE_STAT(net_stats.rx_packets)},
 	{"tx_packets", IXGBE_STAT(net_stats.tx_packets)},
@@ -90,19 +89,22 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_header_split", IXGBE_STAT(rx_hdr_split)},
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
+#ifdef CONFIG_IXGBE_LRO
 	{"lro_aggregated", IXGBE_STAT(lro_aggregated)},
 	{"lro_flushed", IXGBE_STAT(lro_flushed)},
+#endif
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
-		((((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
-		 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
-		 (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
-#define IXGBE_GLOBAL_STATS_LEN	ARRAY_SIZE(ixgbe_gstrings_stats)
+                ((((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
+                 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
+                 (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
+#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
+#define IXGBE_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbe_gstrings_stats)
 #define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
 
 static int ixgbe_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+                              struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -114,7 +116,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	ecmd->transceiver = XCVR_EXTERNAL;
 	if (hw->phy.media_type == ixgbe_media_type_copper) {
 		ecmd->supported |= (SUPPORTED_1000baseT_Full |
-				    SUPPORTED_TP | SUPPORTED_Autoneg);
+		                    SUPPORTED_TP | SUPPORTED_Autoneg);
 
 		ecmd->advertising = (ADVERTISED_TP | ADVERTISED_Autoneg);
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
@@ -126,14 +128,15 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	} else {
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising = (ADVERTISED_10000baseT_Full |
-				     ADVERTISED_FIBRE);
+		                     ADVERTISED_FIBRE);
 		ecmd->port = PORT_FIBRE;
+		ecmd->autoneg = AUTONEG_DISABLE;
 	}
 
-	adapter->hw.mac.ops.check_link(hw, &(link_speed), &link_up);
+	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 	if (link_up) {
 		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-				SPEED_10000 : SPEED_1000;
+		               SPEED_10000 : SPEED_1000;
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
 		ecmd->speed = -1;
@@ -144,7 +147,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 }
 
 static int ixgbe_set_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+                              struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -164,7 +167,7 @@ static int ixgbe_set_settings(struct net_device *netdev,
 }
 
 static void ixgbe_get_pauseparam(struct net_device *netdev,
-				 struct ethtool_pauseparam *pause)
+                                 struct ethtool_pauseparam *pause)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -182,7 +185,7 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 }
 
 static int ixgbe_set_pauseparam(struct net_device *netdev,
-				struct ethtool_pauseparam *pause)
+                                struct ethtool_pauseparam *pause)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -241,7 +244,7 @@ static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
 	if (data)
 		netdev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 	else
-		netdev->features &= ~NETIF_F_IP_CSUM;
+		netdev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 
 	return 0;
 }
@@ -281,7 +284,7 @@ static int ixgbe_get_regs_len(struct net_device *netdev)
 #define IXGBE_GET_STAT(_A_, _R_) _A_->stats._R_
 
 static void ixgbe_get_regs(struct net_device *netdev,
-			   struct ethtool_regs *regs, void *p)
+                           struct ethtool_regs *regs, void *p)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -315,7 +318,9 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[17] = IXGBE_READ_REG(hw, IXGBE_GRC);
 
 	/* Interrupt */
-	regs_buff[18] = IXGBE_READ_REG(hw, IXGBE_EICR);
+	/* don't read EICR because it can clear interrupt causes, instead
+	 * read EICS which is a shadow but doesn't clear EICR */
+	regs_buff[18] = IXGBE_READ_REG(hw, IXGBE_EICS);
 	regs_buff[19] = IXGBE_READ_REG(hw, IXGBE_EICS);
 	regs_buff[20] = IXGBE_READ_REG(hw, IXGBE_EIMS);
 	regs_buff[21] = IXGBE_READ_REG(hw, IXGBE_EIMC);
@@ -325,7 +330,7 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[25] = IXGBE_READ_REG(hw, IXGBE_IVAR(0));
 	regs_buff[26] = IXGBE_READ_REG(hw, IXGBE_MSIXT);
 	regs_buff[27] = IXGBE_READ_REG(hw, IXGBE_MSIXPBA);
-	regs_buff[28] = IXGBE_READ_REG(hw, IXGBE_PBACL);
+	regs_buff[28] = IXGBE_READ_REG(hw, IXGBE_PBACL(0));
 	regs_buff[29] = IXGBE_READ_REG(hw, IXGBE_GPIE);
 
 	/* Flow Control */
@@ -371,7 +376,7 @@ static void ixgbe_get_regs(struct net_device *netdev,
 		regs_buff[482 + i] = IXGBE_READ_REG(hw, IXGBE_RAL(i));
 	for (i = 0; i < 16; i++)
 		regs_buff[498 + i] = IXGBE_READ_REG(hw, IXGBE_RAH(i));
-	regs_buff[514] = IXGBE_READ_REG(hw, IXGBE_PSRTYPE);
+	regs_buff[514] = IXGBE_READ_REG(hw, IXGBE_PSRTYPE(0));
 	regs_buff[515] = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 	regs_buff[516] = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
 	regs_buff[517] = IXGBE_READ_REG(hw, IXGBE_MCSTCTRL);
@@ -419,7 +424,6 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[827] = IXGBE_READ_REG(hw, IXGBE_WUPM);
 	regs_buff[828] = IXGBE_READ_REG(hw, IXGBE_FHFT);
 
-	/* DCE */
 	regs_buff[829] = IXGBE_READ_REG(hw, IXGBE_RMCS);
 	regs_buff[830] = IXGBE_READ_REG(hw, IXGBE_DPMCS);
 	regs_buff[831] = IXGBE_READ_REG(hw, IXGBE_PDPMCS);
@@ -539,21 +543,17 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	/* Diagnostic */
 	regs_buff[1071] = IXGBE_READ_REG(hw, IXGBE_RDSTATCTL);
 	for (i = 0; i < 8; i++)
-		regs_buff[1072] = IXGBE_READ_REG(hw, IXGBE_RDSTAT(i));
+		regs_buff[1072 + i] = IXGBE_READ_REG(hw, IXGBE_RDSTAT(i));
 	regs_buff[1080] = IXGBE_READ_REG(hw, IXGBE_RDHMPN);
-	regs_buff[1081] = IXGBE_READ_REG(hw, IXGBE_RIC_DW0);
-	regs_buff[1082] = IXGBE_READ_REG(hw, IXGBE_RIC_DW1);
-	regs_buff[1083] = IXGBE_READ_REG(hw, IXGBE_RIC_DW2);
-	regs_buff[1084] = IXGBE_READ_REG(hw, IXGBE_RIC_DW3);
+	for (i = 0; i < 4; i++)
+		regs_buff[1081 + i] = IXGBE_READ_REG(hw, IXGBE_RIC_DW(i));
 	regs_buff[1085] = IXGBE_READ_REG(hw, IXGBE_RDPROBE);
 	regs_buff[1086] = IXGBE_READ_REG(hw, IXGBE_TDSTATCTL);
 	for (i = 0; i < 8; i++)
-		regs_buff[1087] = IXGBE_READ_REG(hw, IXGBE_TDSTAT(i));
+		regs_buff[1087 + i] = IXGBE_READ_REG(hw, IXGBE_TDSTAT(i));
 	regs_buff[1095] = IXGBE_READ_REG(hw, IXGBE_TDHMPN);
-	regs_buff[1096] = IXGBE_READ_REG(hw, IXGBE_TIC_DW0);
-	regs_buff[1097] = IXGBE_READ_REG(hw, IXGBE_TIC_DW1);
-	regs_buff[1098] = IXGBE_READ_REG(hw, IXGBE_TIC_DW2);
-	regs_buff[1099] = IXGBE_READ_REG(hw, IXGBE_TIC_DW3);
+	for (i = 0; i < 4; i++)
+		regs_buff[1096 + i] = IXGBE_READ_REG(hw, IXGBE_TIC_DW(i));
 	regs_buff[1100] = IXGBE_READ_REG(hw, IXGBE_TDPROBE);
 	regs_buff[1101] = IXGBE_READ_REG(hw, IXGBE_TXBUFCTRL);
 	regs_buff[1102] = IXGBE_READ_REG(hw, IXGBE_TXBUFDATA0);
@@ -566,7 +566,7 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[1109] = IXGBE_READ_REG(hw, IXGBE_RXBUFDATA2);
 	regs_buff[1110] = IXGBE_READ_REG(hw, IXGBE_RXBUFDATA3);
 	for (i = 0; i < 8; i++)
-		regs_buff[1111] = IXGBE_READ_REG(hw, IXGBE_PCIE_DIAG(i));
+		regs_buff[1111 + i] = IXGBE_READ_REG(hw, IXGBE_PCIE_DIAG(i));
 	regs_buff[1119] = IXGBE_READ_REG(hw, IXGBE_RFVAL);
 	regs_buff[1120] = IXGBE_READ_REG(hw, IXGBE_MDFTC1);
 	regs_buff[1121] = IXGBE_READ_REG(hw, IXGBE_MDFTC2);
@@ -585,7 +585,7 @@ static int ixgbe_get_eeprom_len(struct net_device *netdev)
 }
 
 static int ixgbe_get_eeprom(struct net_device *netdev,
-			    struct ethtool_eeprom *eeprom, u8 *bytes)
+                            struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -608,8 +608,8 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
 		return -ENOMEM;
 
 	for (i = 0; i < eeprom_len; i++) {
-		if ((ret_val = ixgbe_read_eeprom(hw, first_word + i,
-						 &eeprom_buff[i])))
+		if ((ret_val = hw->eeprom.ops.read(hw, first_word + i,
+		    &eeprom_buff[i])))
 			break;
 	}
 
@@ -624,7 +624,7 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
 }
 
 static void ixgbe_get_drvinfo(struct net_device *netdev,
-			      struct ethtool_drvinfo *drvinfo)
+                              struct ethtool_drvinfo *drvinfo)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
@@ -637,7 +637,7 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 }
 
 static void ixgbe_get_ringparam(struct net_device *netdev,
-				struct ethtool_ringparam *ring)
+                                struct ethtool_ringparam *ring)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring = adapter->tx_ring;
@@ -654,15 +654,12 @@ static void ixgbe_get_ringparam(struct net_device *netdev,
 }
 
 static int ixgbe_set_ringparam(struct net_device *netdev,
-			       struct ethtool_ringparam *ring)
+                               struct ethtool_ringparam *ring)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_tx_buffer *old_buf;
-	struct ixgbe_rx_buffer *old_rx_buf;
-	void *old_desc;
+	struct ixgbe_ring *temp_ring;
 	int i, err;
-	u32 new_rx_count, new_tx_count, old_size;
-	dma_addr_t old_dma;
+	u32 new_rx_count, new_tx_count;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
@@ -681,6 +678,15 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
+	if (adapter->num_tx_queues > adapter->num_rx_queues)
+		temp_ring = vmalloc(adapter->num_tx_queues *
+		                    sizeof(struct ixgbe_ring));
+	else
+		temp_ring = vmalloc(adapter->num_rx_queues *
+		                    sizeof(struct ixgbe_ring));
+	if (!temp_ring)
+		return -ENOMEM;
+
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		msleep(1);
 
@@ -693,66 +699,61 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	 * to the tx and rx ring structs.
 	 */
 	if (new_tx_count != adapter->tx_ring->count) {
+		memcpy(temp_ring, adapter->tx_ring,
+		       adapter->num_tx_queues * sizeof(struct ixgbe_ring));
+
 		for (i = 0; i < adapter->num_tx_queues; i++) {
-			/* Save existing descriptor ring */
-			old_buf = adapter->tx_ring[i].tx_buffer_info;
-			old_desc = adapter->tx_ring[i].desc;
-			old_size = adapter->tx_ring[i].size;
-			old_dma = adapter->tx_ring[i].dma;
-			/* Try to allocate a new one */
-			adapter->tx_ring[i].tx_buffer_info = NULL;
-			adapter->tx_ring[i].desc = NULL;
-			adapter->tx_ring[i].count = new_tx_count;
-			err = ixgbe_setup_tx_resources(adapter,
-						       &adapter->tx_ring[i]);
+			temp_ring[i].count = new_tx_count;
+			err = ixgbe_setup_tx_resources(adapter, &temp_ring[i]);
 			if (err) {
-				/* Restore the old one so at least
-				   the adapter still works, even if
-				   we failed the request */
-				adapter->tx_ring[i].tx_buffer_info = old_buf;
-				adapter->tx_ring[i].desc = old_desc;
-				adapter->tx_ring[i].size = old_size;
-				adapter->tx_ring[i].dma = old_dma;
+				while (i) {
+					i--;
+					ixgbe_free_tx_resources(adapter,
+					                        &temp_ring[i]);
+				}
 				goto err_setup;
 			}
-			/* Free the old buffer manually */
-			vfree(old_buf);
-			pci_free_consistent(adapter->pdev, old_size,
-					    old_desc, old_dma);
 		}
+
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			ixgbe_free_tx_resources(adapter, &adapter->tx_ring[i]);
+
+		memcpy(adapter->tx_ring, temp_ring,
+		       adapter->num_tx_queues * sizeof(struct ixgbe_ring));
+
+		adapter->tx_ring_count = new_tx_count;
 	}
 
 	if (new_rx_count != adapter->rx_ring->count) {
-		for (i = 0; i < adapter->num_rx_queues; i++) {
+		memcpy(temp_ring, adapter->rx_ring,
+		       adapter->num_rx_queues * sizeof(struct ixgbe_ring));
 
-			old_rx_buf = adapter->rx_ring[i].rx_buffer_info;
-			old_desc = adapter->rx_ring[i].desc;
-			old_size = adapter->rx_ring[i].size;
-			old_dma = adapter->rx_ring[i].dma;
-
-			adapter->rx_ring[i].rx_buffer_info = NULL;
-			adapter->rx_ring[i].desc = NULL;
-			adapter->rx_ring[i].dma = 0;
-			adapter->rx_ring[i].count = new_rx_count;
-			err = ixgbe_setup_rx_resources(adapter,
-						       &adapter->rx_ring[i]);
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			temp_ring[i].count = new_rx_count;
+			err = ixgbe_setup_rx_resources(adapter, &temp_ring[i]);
 			if (err) {
-				adapter->rx_ring[i].rx_buffer_info = old_rx_buf;
-				adapter->rx_ring[i].desc = old_desc;
-				adapter->rx_ring[i].size = old_size;
-				adapter->rx_ring[i].dma = old_dma;
+				while (i) {
+					i--;
+					ixgbe_free_rx_resources(adapter,
+					                        &temp_ring[i]);
+				}
 				goto err_setup;
 			}
-
-			vfree(old_rx_buf);
-			pci_free_consistent(adapter->pdev, old_size, old_desc,
-					    old_dma);
 		}
+
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			ixgbe_free_rx_resources(adapter, &adapter->rx_ring[i]);
+
+		memcpy(adapter->rx_ring, temp_ring,
+		       adapter->num_rx_queues * sizeof(struct ixgbe_ring));
+
+		adapter->rx_ring_count = new_rx_count;
 	}
 
+	/* success! */
 	err = 0;
 err_setup:
-	if (netif_running(adapter->netdev))
+	if (netif_running(netdev))
 		ixgbe_up(adapter);
 
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
@@ -770,20 +771,31 @@ static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 }
 
 static void ixgbe_get_ethtool_stats(struct net_device *netdev,
-				    struct ethtool_stats *stats, u64 *data)
+                                    struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u64 *queue_stat;
 	int stat_count = sizeof(struct ixgbe_queue_stats) / sizeof(u64);
 	int j, k;
 	int i;
+
+#ifdef CONFIG_IXGBE_LRO
 	u64 aggregated = 0, flushed = 0, no_desc = 0;
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		aggregated += adapter->rx_ring[i].lro_mgr.stats.aggregated;
+		flushed += adapter->rx_ring[i].lro_mgr.stats.flushed;
+		no_desc += adapter->rx_ring[i].lro_mgr.stats.no_desc;
+	}
+	adapter->lro_aggregated = aggregated;
+	adapter->lro_flushed = flushed;
+	adapter->lro_no_desc = no_desc;
+#endif
 
 	ixgbe_update_stats(adapter);
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
 		char *p = (char *)adapter + ixgbe_gstrings_stats[i].stat_offset;
 		data[i] = (ixgbe_gstrings_stats[i].sizeof_stat ==
-			   sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+		           sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 	for (j = 0; j < adapter->num_tx_queues; j++) {
 		queue_stat = (u64 *)&adapter->tx_ring[j].stats;
@@ -792,24 +804,18 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		i += k;
 	}
 	for (j = 0; j < adapter->num_rx_queues; j++) {
-		aggregated += adapter->rx_ring[j].lro_mgr.stats.aggregated;
-		flushed += adapter->rx_ring[j].lro_mgr.stats.flushed;
-		no_desc += adapter->rx_ring[j].lro_mgr.stats.no_desc;
 		queue_stat = (u64 *)&adapter->rx_ring[j].stats;
 		for (k = 0; k < stat_count; k++)
 			data[i + k] = queue_stat[k];
 		i += k;
 	}
-	adapter->lro_aggregated = aggregated;
-	adapter->lro_flushed = flushed;
-	adapter->lro_no_desc = no_desc;
 }
 
 static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
-			      u8 *data)
+                              u8 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u8 *p = data;
+	char *p = (char *)data;
 	int i;
 
 	switch (stringset) {
@@ -831,14 +837,14 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
 		}
-/*		BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
+		/* BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
 	}
 }
 
 
 static void ixgbe_get_wol(struct net_device *netdev,
-			  struct ethtool_wolinfo *wol)
+                          struct ethtool_wolinfo *wol)
 {
 	wol->supported = 0;
 	wol->wolopts = 0;
@@ -859,16 +865,17 @@ static int ixgbe_nway_reset(struct net_device *netdev)
 static int ixgbe_phys_id(struct net_device *netdev, u32 data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u32 led_reg = IXGBE_READ_REG(&adapter->hw, IXGBE_LEDCTL);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 	u32 i;
 
 	if (!data || data > 300)
 		data = 300;
 
 	for (i = 0; i < (data * 1000); i += 400) {
-		ixgbe_led_on(&adapter->hw, IXGBE_LED_ON);
+		hw->mac.ops.led_on(hw, IXGBE_LED_ON);
 		msleep_interruptible(200);
-		ixgbe_led_off(&adapter->hw, IXGBE_LED_ON);
+		hw->mac.ops.led_off(hw, IXGBE_LED_ON);
 		msleep_interruptible(200);
 	}
 
@@ -879,67 +886,75 @@ static int ixgbe_phys_id(struct net_device *netdev, u32 data)
 }
 
 static int ixgbe_get_coalesce(struct net_device *netdev,
-			      struct ethtool_coalesce *ec)
+                              struct ethtool_coalesce *ec)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
-		ec->rx_coalesce_usecs = adapter->rx_eitr;
-	else
-		ec->rx_coalesce_usecs = 1000000 / adapter->rx_eitr;
-
-	if (adapter->tx_eitr < IXGBE_MIN_ITR_USECS)
-		ec->tx_coalesce_usecs = adapter->tx_eitr;
-	else
-		ec->tx_coalesce_usecs = 1000000 / adapter->tx_eitr;
-
 	ec->tx_max_coalesced_frames_irq = adapter->tx_ring[0].work_limit;
+
+	/* only valid if in constant ITR mode */
+	switch (adapter->itr_setting) {
+	case 0:
+		/* throttling disabled */
+		ec->rx_coalesce_usecs = 0;
+		break;
+	case 1:
+		/* dynamic ITR mode */
+		ec->rx_coalesce_usecs = 1;
+		break;
+	default:
+		/* fixed interrupt rate mode */
+		ec->rx_coalesce_usecs = 1000000/adapter->eitr_param;
+		break;
+	}
 	return 0;
 }
 
 static int ixgbe_set_coalesce(struct net_device *netdev,
-			      struct ethtool_coalesce *ec)
+                              struct ethtool_coalesce *ec)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	if ((ec->rx_coalesce_usecs > IXGBE_MAX_ITR_USECS) ||
-	    ((ec->rx_coalesce_usecs != 0) &&
-	     (ec->rx_coalesce_usecs != 1) &&
-	     (ec->rx_coalesce_usecs != 3) &&
-	     (ec->rx_coalesce_usecs < IXGBE_MIN_ITR_USECS)))
-		return -EINVAL;
-	if ((ec->tx_coalesce_usecs > IXGBE_MAX_ITR_USECS) ||
-	    ((ec->tx_coalesce_usecs != 0) &&
-	     (ec->tx_coalesce_usecs != 1) &&
-	     (ec->tx_coalesce_usecs != 3) &&
-	     (ec->tx_coalesce_usecs < IXGBE_MIN_ITR_USECS)))
-		return -EINVAL;
-
-	/* convert to rate of irq's per second */
-	if (ec->rx_coalesce_usecs < IXGBE_MIN_ITR_USECS)
-		adapter->rx_eitr = ec->rx_coalesce_usecs;
-	else
-		adapter->rx_eitr = (1000000 / ec->rx_coalesce_usecs);
-
-	if (ec->tx_coalesce_usecs < IXGBE_MIN_ITR_USECS)
-		adapter->tx_eitr = ec->rx_coalesce_usecs;
-	else
-		adapter->tx_eitr = (1000000 / ec->tx_coalesce_usecs);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
 
 	if (ec->tx_max_coalesced_frames_irq)
-		adapter->tx_ring[0].work_limit =
-					ec->tx_max_coalesced_frames_irq;
+		adapter->tx_ring[0].work_limit = ec->tx_max_coalesced_frames_irq;
+
+	if (ec->rx_coalesce_usecs > 1) {
+		/* store the value in ints/second */
+		adapter->eitr_param = 1000000/ec->rx_coalesce_usecs;
+
+		/* static value of interrupt rate */
+		adapter->itr_setting = adapter->eitr_param;
+		/* clear the lower bit */
+		adapter->itr_setting &= ~1;
+	} else if (ec->rx_coalesce_usecs == 1) {
+		/* 1 means dynamic mode */
+		adapter->eitr_param = 20000;
+		adapter->itr_setting = 1;
+	} else {
+		/* any other value means disable eitr, which is best
+		 * served by setting the interrupt rate very high */
+		adapter->eitr_param = 3000000;
+		adapter->itr_setting = 0;
+	}
 
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_up(adapter);
+	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
+		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
+		if (q_vector->txr_count && !q_vector->rxr_count)
+			q_vector->eitr = (adapter->eitr_param >> 1);
+		else
+			/* rx only or mixed */
+			q_vector->eitr = adapter->eitr_param;
+		IXGBE_WRITE_REG(hw, IXGBE_EITR(i),
+		                EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
 	}
 
 	return 0;
 }
 
 
-static struct ethtool_ops ixgbe_ethtool_ops = {
+static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
 	.get_drvinfo            = ixgbe_get_drvinfo,
@@ -966,7 +981,7 @@ static struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_tso                = ixgbe_set_tso,
 	.get_strings            = ixgbe_get_strings,
 	.phys_id                = ixgbe_phys_id,
-	.get_sset_count		= ixgbe_get_sset_count,
+	.get_sset_count         = ixgbe_get_sset_count,
 	.get_ethtool_stats      = ixgbe_get_ethtool_stats,
 	.get_coalesce           = ixgbe_get_coalesce,
 	.set_coalesce           = ixgbe_set_coalesce,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 362541a..807be05 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -46,15 +45,14 @@
 
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
-	"Intel(R) 10 Gigabit PCI Express Network Driver";
+                              "Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "1.3.18-k4"
+#define DRV_VERSION "1.3.30-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
-static const char ixgbe_copyright[] =
-	 "Copyright (c) 1999-2007 Intel Corporation.";
+static char ixgbe_copyright[] = "Copyright (c) 1999-2007 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
-	[board_82598]			= &ixgbe_82598_info,
+	[board_82598] = &ixgbe_82598_info,
 };
 
 /* ixgbe_pci_tbl - PCI Device ID Table
@@ -74,15 +72,17 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_XF_LR),
+	 board_82598 },
 
 	/* required last entry */
 	{0, }
 };
 MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *, unsigned long event,
-			    void *p);
+                            void *p);
 static struct notifier_block dca_notifier = {
 	.notifier_call = ixgbe_notify_dca,
 	.next          = NULL,
@@ -104,7 +104,7 @@ static void ixgbe_release_hw_control(struct ixgbe_adapter *adapter)
 	/* Let firmware take over control of h/w */
 	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-			ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
+	                ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
 }
 
 static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
@@ -114,24 +114,11 @@ static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
 	/* Let firmware know the driver has taken over */
 	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-			ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
-}
-
-#ifdef DEBUG
-/**
- * ixgbe_get_hw_dev_name - return device name string
- * used by hardware layer to print debugging information
- **/
-char *ixgbe_get_hw_dev_name(struct ixgbe_hw *hw)
-{
-	struct ixgbe_adapter *adapter = hw->back;
-	struct net_device *netdev = adapter->netdev;
-	return netdev->name;
+	                ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
 }
-#endif
 
 static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, u16 int_alloc_entry,
-			   u8 msix_vector)
+                           u8 msix_vector)
 {
 	u32 ivar, index;
 
@@ -144,12 +131,12 @@ static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, u16 int_alloc_entry,
 }
 
 static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
-					     struct ixgbe_tx_buffer
-					     *tx_buffer_info)
+                                             struct ixgbe_tx_buffer
+                                             *tx_buffer_info)
 {
 	if (tx_buffer_info->dma) {
 		pci_unmap_page(adapter->pdev, tx_buffer_info->dma,
-			       tx_buffer_info->length, PCI_DMA_TODEVICE);
+		               tx_buffer_info->length, PCI_DMA_TODEVICE);
 		tx_buffer_info->dma = 0;
 	}
 	if (tx_buffer_info->skb) {
@@ -160,8 +147,8 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
 }
 
 static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
-				       struct ixgbe_ring *tx_ring,
-				       unsigned int eop)
+                                       struct ixgbe_ring *tx_ring,
+                                       unsigned int eop)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 head, tail;
@@ -196,14 +183,14 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 	return false;
 }
 
-#define IXGBE_MAX_TXD_PWR	14
-#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
+#define IXGBE_MAX_TXD_PWR       14
+#define IXGBE_MAX_DATA_PER_TXD  (1 << IXGBE_MAX_TXD_PWR)
 
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
 			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
 #define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)	/* for context */
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1) /* for context */
 
 #define GET_TX_HEAD_FROM_RING(ring) (\
 	*(volatile u32 *) \
@@ -309,9 +296,9 @@ done_cleaning:
 	return (total_packets ? true : false);
 }
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rx_ring)
+                                struct ixgbe_ring *rx_ring)
 {
 	u32 rxctrl;
 	int cpu = get_cpu();
@@ -330,7 +317,7 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 }
 
 static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *tx_ring)
+                                struct ixgbe_ring *tx_ring)
 {
 	u32 txctrl;
 	int cpu = get_cpu();
@@ -406,13 +393,14 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
  * @rx_desc: rx descriptor
  **/
 static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
-			      struct sk_buff *skb, u8 status,
-			      struct ixgbe_ring *ring,
+                              struct sk_buff *skb, u8 status,
+                              struct ixgbe_ring *ring,
                               union ixgbe_adv_rx_desc *rx_desc)
 {
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
+#ifdef CONFIG_IXGBE_LRO
 	if (adapter->netdev->features & NETIF_F_LRO &&
 	    skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		if (adapter->vlgrp && is_vlan)
@@ -423,6 +411,7 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
 			lro_receive_skb(&ring->lro_mgr, skb, rx_desc);
 		ring->lro_used = true;
 	} else {
+#endif
 		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 			if (adapter->vlgrp && is_vlan)
 				vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
@@ -434,7 +423,9 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
 			else
 				netif_rx(skb);
 		}
+#ifdef CONFIG_IXGBE_LRO
 	}
+#endif
 }
 
 /**
@@ -480,7 +471,6 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
                                    struct ixgbe_ring *rx_ring,
                                    int cleaned_count)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
@@ -493,20 +483,29 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	while (cleaned_count--) {
 		rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
 
-		if (!bi->page &&
+		if (!bi->page_dma &&
 		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
-			bi->page = alloc_page(GFP_ATOMIC);
 			if (!bi->page) {
-				adapter->alloc_rx_page_failed++;
-				goto no_buffers;
+				bi->page = alloc_page(GFP_ATOMIC);
+				if (!bi->page) {
+					adapter->alloc_rx_page_failed++;
+					goto no_buffers;
+				}
+				bi->page_offset = 0;
+			} else {
+				/* use a half page if we're re-using */
+				bi->page_offset ^= (PAGE_SIZE / 2);
 			}
-			bi->page_dma = pci_map_page(pdev, bi->page, 0,
-	                                            PAGE_SIZE,
-	                                            PCI_DMA_FROMDEVICE);
+
+			bi->page_dma = pci_map_page(pdev, bi->page,
+			                            bi->page_offset,
+			                            (PAGE_SIZE / 2),
+			                            PCI_DMA_FROMDEVICE);
 		}
 
 		if (!bi->skb) {
-			struct sk_buff *skb = netdev_alloc_skb(netdev, bufsz);
+			struct sk_buff *skb = netdev_alloc_skb(adapter->netdev,
+			                                       bufsz);
 
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
@@ -567,10 +566,9 @@ static inline u16 ixgbe_get_pkt_info(union ixgbe_adv_rx_desc *rx_desc)
 }
 
 static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
-	                       struct ixgbe_ring *rx_ring,
-	                       int *work_done, int work_to_do)
+                               struct ixgbe_ring *rx_ring,
+                               int *work_done, int work_to_do)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
@@ -596,7 +594,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
-	                       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
+			       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
 			if (hdr_info & IXGBE_RXDADV_SPH)
 				adapter->rx_hdr_split++;
 			if (len > IXGBE_RX_HDR_SIZE)
@@ -613,18 +611,25 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 
 		if (len && !skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-	                                 rx_ring->rx_buf_len + NET_IP_ALIGN,
-	                                 PCI_DMA_FROMDEVICE);
+			                 rx_ring->rx_buf_len + NET_IP_ALIGN,
+			                 PCI_DMA_FROMDEVICE);
 			skb_put(skb, len);
 		}
 
 		if (upper_len) {
 			pci_unmap_page(pdev, rx_buffer_info->page_dma,
-				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			               PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			rx_buffer_info->page_dma = 0;
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-					   rx_buffer_info->page, 0, upper_len);
-			rx_buffer_info->page = NULL;
+			                   rx_buffer_info->page,
+			                   rx_buffer_info->page_offset,
+			                   upper_len);
+
+			if ((rx_ring->rx_buf_len > (PAGE_SIZE / 2)) ||
+			    (page_count(rx_buffer_info->page) != 1))
+				rx_buffer_info->page = NULL;
+			else
+				get_page(rx_buffer_info->page);
 
 			skb->len += upper_len;
 			skb->data_len += upper_len;
@@ -647,6 +652,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 			rx_buffer_info->skb = next_buffer->skb;
 			rx_buffer_info->dma = next_buffer->dma;
 			next_buffer->skb = skb;
+			next_buffer->dma = 0;
 			adapter->non_eop_descs++;
 			goto next_desc;
 		}
@@ -662,9 +668,9 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		skb->protocol = eth_type_trans(skb, netdev);
+		skb->protocol = eth_type_trans(skb, adapter->netdev);
 		ixgbe_receive_skb(adapter, skb, staterr, rx_ring, rx_desc);
-		netdev->last_rx = jiffies;
+		adapter->netdev->last_rx = jiffies;
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
@@ -682,10 +688,12 @@ next_desc:
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
+#ifdef CONFIG_IXGBE_LRO
 	if (rx_ring->lro_used) {
 		lro_flush_all(&rx_ring->lro_mgr);
 		rx_ring->lro_used = false;
 	}
+#endif
 
 	rx_ring->next_to_clean = i;
 	cleaned_count = IXGBE_DESC_UNUSED(rx_ring);
@@ -724,43 +732,43 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		q_vector = &adapter->q_vector[v_idx];
 		/* XXX for_each_bit(...) */
 		r_idx = find_first_bit(q_vector->rxr_idx,
-				      adapter->num_rx_queues);
+		                       adapter->num_rx_queues);
 
 		for (i = 0; i < q_vector->rxr_count; i++) {
 			j = adapter->rx_ring[r_idx].reg_idx;
 			ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(j), v_idx);
 			r_idx = find_next_bit(q_vector->rxr_idx,
-					      adapter->num_rx_queues,
-					      r_idx + 1);
+			                      adapter->num_rx_queues,
+			                      r_idx + 1);
 		}
 		r_idx = find_first_bit(q_vector->txr_idx,
-				       adapter->num_tx_queues);
+		                       adapter->num_tx_queues);
 
 		for (i = 0; i < q_vector->txr_count; i++) {
 			j = adapter->tx_ring[r_idx].reg_idx;
 			ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(j), v_idx);
 			r_idx = find_next_bit(q_vector->txr_idx,
-					      adapter->num_tx_queues,
-					      r_idx + 1);
+			                      adapter->num_tx_queues,
+			                      r_idx + 1);
 		}
 
-		/* if this is a tx only vector use half the irq (tx) rate */
+		/* if this is a tx only vector halve the interrupt rate */
 		if (q_vector->txr_count && !q_vector->rxr_count)
-			q_vector->eitr = adapter->tx_eitr;
+			q_vector->eitr = (adapter->eitr_param >> 1);
 		else
-			/* rx only or mixed */
-			q_vector->eitr = adapter->rx_eitr;
+			/* rx only */
+			q_vector->eitr = adapter->eitr_param;
 
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx),
-				EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
+		                EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
 	}
 
 	ixgbe_set_ivar(adapter, IXGBE_IVAR_OTHER_CAUSES_INDEX, v_idx);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx), 1950);
 
-	/* set up to autoclear timer, lsc, and the vectors */
+	/* set up to autoclear timer, and the vectors */
 	mask = IXGBE_EIMS_ENABLE_MASK;
-	mask &= ~IXGBE_EIMS_OTHER;
+	mask &= ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC, mask);
 }
 
@@ -790,8 +798,8 @@ enum latency_range {
  *      parameter (see ixgbe_param.c)
  **/
 static u8 ixgbe_update_itr(struct ixgbe_adapter *adapter,
-			   u32 eitr, u8 itr_setting,
-			   int packets, int bytes)
+                           u32 eitr, u8 itr_setting,
+                           int packets, int bytes)
 {
 	unsigned int retval = itr_setting;
 	u32 timepassed_us;
@@ -838,40 +846,40 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	u32 new_itr;
 	u8 current_itr, ret_itr;
 	int i, r_idx, v_idx = ((void *)q_vector - (void *)(adapter->q_vector)) /
-			      sizeof(struct ixgbe_q_vector);
+	                       sizeof(struct ixgbe_q_vector);
 	struct ixgbe_ring *rx_ring, *tx_ring;
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->tx_eitr,
-					   tx_ring->total_packets,
-					   tx_ring->total_bytes);
+		                           q_vector->tx_itr,
+		                           tx_ring->total_packets,
+		                           tx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
-		q_vector->tx_eitr = ((q_vector->tx_eitr > ret_itr) ?
-				    q_vector->tx_eitr - 1 : ret_itr);
+		q_vector->tx_itr = ((q_vector->tx_itr > ret_itr) ?
+		                    q_vector->tx_itr - 1 : ret_itr);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
-				      r_idx + 1);
+		                      r_idx + 1);
 	}
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
 		rx_ring = &(adapter->rx_ring[r_idx]);
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->rx_eitr,
-					   rx_ring->total_packets,
-					   rx_ring->total_bytes);
+		                           q_vector->rx_itr,
+		                           rx_ring->total_packets,
+		                           rx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
-		q_vector->rx_eitr = ((q_vector->rx_eitr > ret_itr) ?
-				    q_vector->rx_eitr - 1 : ret_itr);
+		q_vector->rx_itr = ((q_vector->rx_itr > ret_itr) ?
+		                    q_vector->rx_itr - 1 : ret_itr);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
-				      r_idx + 1);
+		                      r_idx + 1);
 	}
 
-	current_itr = max(q_vector->rx_eitr, q_vector->tx_eitr);
+	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
 
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
@@ -895,13 +903,27 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
 		/* must write high and low 16 bits to reset counter */
 		DPRINTK(TX_ERR, DEBUG, "writing eitr(%d): %08X\n", v_idx,
-			itr_reg);
+		        itr_reg);
 		IXGBE_WRITE_REG(hw, IXGBE_EITR(v_idx), itr_reg | (itr_reg)<<16);
 	}
 
 	return;
 }
 
+
+static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	adapter->lsc_int++;
+	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
+	adapter->link_check_timeout = jiffies;
+	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+		IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_EIMC_LSC);
+		schedule_work(&adapter->watchdog_task);
+	}
+}
+
 static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 {
 	struct net_device *netdev = data;
@@ -909,11 +931,8 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
 
-	if (eicr & IXGBE_EICR_LSC) {
-		adapter->lsc_int++;
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			mod_timer(&adapter->watchdog_timer, jiffies);
-	}
+	if (eicr & IXGBE_EICR_LSC)
+		ixgbe_check_lsc(adapter);
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
@@ -934,7 +953,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_tx_dca(adapter, tx_ring);
 #endif
@@ -942,7 +961,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 		tx_ring->total_packets = 0;
 		ixgbe_clean_tx_irq(adapter, tx_ring);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
-				      r_idx + 1);
+		                      r_idx + 1);
 	}
 
 	return IRQ_HANDLED;
@@ -959,16 +978,24 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	struct ixgbe_adapter  *adapter = q_vector->adapter;
 	struct ixgbe_ring  *rx_ring;
 	int r_idx;
+	int i;
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	for (i = 0;  i < q_vector->rxr_count; i++) {
+		rx_ring = &(adapter->rx_ring[r_idx]);
+		rx_ring->total_bytes = 0;
+		rx_ring->total_packets = 0;
+		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		                      r_idx + 1);
+	}
+
 	if (!q_vector->rxr_count)
 		return IRQ_HANDLED;
 
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
-	rx_ring->total_bytes = 0;
-	rx_ring->total_packets = 0;
 	netif_rx_schedule(adapter->netdev, &q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -987,19 +1014,21 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
  * @napi: napi struct with our devices info in it
  * @budget: amount of work driver is allowed to do this pass, in packets
  *
+ * This function is optimized for cleaning one queue only on a single
+ * q_vector!!!
  **/
 static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector =
-			       container_of(napi, struct ixgbe_q_vector, napi);
+	                       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct ixgbe_ring *rx_ring;
+	struct ixgbe_ring *rx_ring = NULL;
 	int work_done = 0;
 	long r_idx;
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 		ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
@@ -1009,7 +1038,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(adapter->netdev, napi);
-		if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
+		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rx_ring->v_idx);
@@ -1018,8 +1047,57 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+/**
+ * ixgbe_clean_rxonly_many - msix (aka one shot) rx clean routine
+ * @napi: napi struct with our devices info in it
+ * @budget: amount of work driver is allowed to do this pass, in packets
+ *
+ * This function will clean more than one rx queue associated with a
+ * q_vector.
+ **/
+static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
+{
+	struct ixgbe_q_vector *q_vector =
+	                       container_of(napi, struct ixgbe_q_vector, napi);
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct ixgbe_ring *rx_ring = NULL;
+	int work_done = 0, i;
+	long r_idx;
+	u16 enable_mask = 0;
+
+	/* attempt to distribute budget to each queue fairly, but don't allow
+	 * the budget to go below 1 because we'll exit polling */
+	budget /= (q_vector->rxr_count ?: 1);
+	budget = max(budget, 1);
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rxr_count; i++) {
+		rx_ring = &(adapter->rx_ring[r_idx]);
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+			ixgbe_update_rx_dca(adapter, rx_ring);
+#endif
+		ixgbe_clean_rx_irq(adapter, rx_ring, &work_done, budget);
+		enable_mask |= rx_ring->v_idx;
+		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		                      r_idx + 1);
+	}
+
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	rx_ring = &(adapter->rx_ring[r_idx]);
+	/* If all Rx work done, exit the polling mode */
+	if (work_done < budget) {
+		netif_rx_complete(adapter->netdev, napi);
+		if (adapter->itr_setting & 3)
+			ixgbe_set_itr_msix(q_vector);
+		if (!test_bit(__IXGBE_DOWN, &adapter->state))
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, enable_mask);
+		return 0;
+	}
+
+	return work_done;
+}
 static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
-				     int r_idx)
+                                     int r_idx)
 {
 	a->q_vector[v_idx].adapter = a;
 	set_bit(r_idx, a->q_vector[v_idx].rxr_idx);
@@ -1028,7 +1106,7 @@ static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 }
 
 static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
-				     int r_idx)
+                                     int r_idx)
 {
 	a->q_vector[v_idx].adapter = a;
 	set_bit(r_idx, a->q_vector[v_idx].txr_idx);
@@ -1048,7 +1126,7 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
  * mapping configurations in here.
  **/
 static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter,
-				      int vectors)
+                                      int vectors)
 {
 	int v_start = 0;
 	int rxr_idx = 0, txr_idx = 0;
@@ -1125,28 +1203,28 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 		goto out;
 
 #define SET_HANDLER(_v) ((!(_v)->rxr_count) ? &ixgbe_msix_clean_tx : \
-			 (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
-			 &ixgbe_msix_clean_many)
+                         (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
+                         &ixgbe_msix_clean_many)
 	for (vector = 0; vector < q_vectors; vector++) {
 		handler = SET_HANDLER(&adapter->q_vector[vector]);
 		sprintf(adapter->name[vector], "%s:v%d-%s",
-			netdev->name, vector,
-			(handler == &ixgbe_msix_clean_rx) ? "Rx" :
-			 ((handler == &ixgbe_msix_clean_tx) ? "Tx" : "TxRx"));
+		        netdev->name, vector,
+		        (handler == &ixgbe_msix_clean_rx) ? "Rx" :
+		         ((handler == &ixgbe_msix_clean_tx) ? "Tx" : "TxRx"));
 		err = request_irq(adapter->msix_entries[vector].vector,
-				  handler, 0, adapter->name[vector],
-				  &(adapter->q_vector[vector]));
+		                  handler, 0, adapter->name[vector],
+		                  &(adapter->q_vector[vector]));
 		if (err) {
 			DPRINTK(PROBE, ERR,
-				"request_irq failed for MSIX interrupt "
-				"Error: %d\n", err);
+			        "request_irq failed for MSIX interrupt "
+			        "Error: %d\n", err);
 			goto free_queue_irqs;
 		}
 	}
 
 	sprintf(adapter->name[vector], "%s:lsc", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  &ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
+	                  &ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
 	if (err) {
 		DPRINTK(PROBE, ERR,
 			"request_irq for msix_lsc failed: %d\n", err);
@@ -1158,7 +1236,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 free_queue_irqs:
 	for (i = vector - 1; i >= 0; i--)
 		free_irq(adapter->msix_entries[--vector].vector,
-			 &(adapter->q_vector[i]));
+		         &(adapter->q_vector[i]));
 	adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
@@ -1176,16 +1254,16 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring *rx_ring = &adapter->rx_ring[0];
 	struct ixgbe_ring *tx_ring = &adapter->tx_ring[0];
 
-	q_vector->tx_eitr = ixgbe_update_itr(adapter, new_itr,
-					     q_vector->tx_eitr,
-					     tx_ring->total_packets,
-					     tx_ring->total_bytes);
-	q_vector->rx_eitr = ixgbe_update_itr(adapter, new_itr,
-					     q_vector->rx_eitr,
-					     rx_ring->total_packets,
-					     rx_ring->total_bytes);
+	q_vector->tx_itr = ixgbe_update_itr(adapter, new_itr,
+	                                    q_vector->tx_itr,
+	                                    tx_ring->total_packets,
+	                                    tx_ring->total_bytes);
+	q_vector->rx_itr = ixgbe_update_itr(adapter, new_itr,
+	                                    q_vector->rx_itr,
+	                                    rx_ring->total_packets,
+	                                    rx_ring->total_bytes);
 
-	current_itr = max(q_vector->rx_eitr, q_vector->tx_eitr);
+	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
 
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
@@ -1230,19 +1308,19 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr;
 
-
 	/* for NAPI, using EIAM to auto-mask tx/rx interrupt bits on read
 	 * therefore no explict interrupt disable is necessary */
 	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
-	if (!eicr)
+	if (!eicr) {
+		/* shared interrupt alert!
+		 * make sure interrupts are enabled because the read will
+		 * have disabled interrupts due to EIAM */
+		ixgbe_irq_enable(adapter);
 		return IRQ_NONE;	/* Not our interrupt */
-
-	if (eicr & IXGBE_EICR_LSC) {
-		adapter->lsc_int++;
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			mod_timer(&adapter->watchdog_timer, jiffies);
 	}
 
+	if (eicr & IXGBE_EICR_LSC)
+		ixgbe_check_lsc(adapter);
 
 	if (netif_rx_schedule_prep(netdev, &adapter->q_vector[0].napi)) {
 		adapter->tx_ring[0].total_packets = 0;
@@ -1285,10 +1363,10 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 		err = ixgbe_request_msix_irqs(adapter);
 	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
 		err = request_irq(adapter->pdev->irq, &ixgbe_intr, 0,
-				  netdev->name, netdev);
+		                  netdev->name, netdev);
 	} else {
 		err = request_irq(adapter->pdev->irq, &ixgbe_intr, IRQF_SHARED,
-				  netdev->name, netdev);
+		                  netdev->name, netdev);
 	}
 
 	if (err)
@@ -1312,7 +1390,7 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		i--;
 		for (; i >= 0; i--) {
 			free_irq(adapter->msix_entries[i].vector,
-				 &(adapter->q_vector[i]));
+			         &(adapter->q_vector[i]));
 		}
 
 		ixgbe_reset_q_vectors(adapter);
@@ -1359,7 +1437,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
-			EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr));
+	                EITR_INTS_PER_SEC_TO_REG(adapter->eitr_param));
 
 	ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(0), 0);
 	ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(0), 0);
@@ -1445,8 +1523,8 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 		srrctl |= IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
 		srrctl |= ((IXGBE_RX_HDR_SIZE <<
-			    IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
-			   IXGBE_SRRCTL_BSIZEHDR_MASK);
+		            IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
+		           IXGBE_SRRCTL_BSIZEHDR_MASK);
 	} else {
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
 
@@ -1460,10 +1538,11 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
 }
 
+#ifdef CONFIG_IXGBE_LRO
 /**
  * ixgbe_get_skb_hdr - helper function for LRO header processing
  * @skb: pointer to sk_buff to be added to LRO packet
- * @iphdr: pointer to tcp header structure
+ * @iphdr: pointer to ip header structure
  * @tcph: pointer to tcp header structure
  * @hdr_flags: pointer to header flags
  * @priv: private data
@@ -1487,8 +1566,9 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
 	return 0;
 }
 
+#endif /* CONFIG_IXGBE_LRO */
 #define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
-			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
+                           (((S) & (PAGE_SIZE - 1)) ? 1 : 0))
 
 /**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
@@ -1514,10 +1594,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	int rx_buf_len;
 
 	/* Decide whether to use packet split mode or not */
-	if (netdev->mtu > ETH_DATA_LEN)
-		adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
-	else
-		adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
+	adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
 
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
@@ -1561,6 +1638,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].head = IXGBE_RDH(j);
 		adapter->rx_ring[i].tail = IXGBE_RDT(j);
 		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
+#ifdef CONFIG_IXGBE_LRO
 		/* Intitial LRO Settings */
 		adapter->rx_ring[i].lro_mgr.max_aggr = IXGBE_MAX_LRO_AGGREGATE;
 		adapter->rx_ring[i].lro_mgr.max_desc = IXGBE_MAX_LRO_DESCRIPTORS;
@@ -1571,6 +1649,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].lro_mgr.dev = adapter->netdev;
 		adapter->rx_ring[i].lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
 		adapter->rx_ring[i].lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+#endif
 
 		ixgbe_configure_srrctl(adapter, j);
 	}
@@ -1638,7 +1717,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 }
 
 static void ixgbe_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
+                                   struct vlan_group *grp)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u32 ctrl;
@@ -1662,14 +1741,16 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 
 	/* add VID to filter table */
-	ixgbe_set_vfta(&adapter->hw, vid, 0, true);
+	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, true);
 }
 
 static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		ixgbe_irq_disable(adapter);
@@ -1680,7 +1761,7 @@ static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 		ixgbe_irq_enable(adapter);
 
 	/* remove VID from filter table */
-	ixgbe_set_vfta(&adapter->hw, vid, 0, false);
+	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, false);
 }
 
 static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
@@ -1756,15 +1837,15 @@ static void ixgbe_set_rx_mode(struct net_device *netdev)
 	addr_count = netdev->uc_count;
 	if (addr_count)
 		addr_list = netdev->uc_list->dmi_addr;
-	ixgbe_update_uc_addr_list(hw, addr_list, addr_count,
-	                          ixgbe_addr_list_itr);
+	hw->mac.ops.update_uc_addr_list(hw, addr_list, addr_count,
+	                                  ixgbe_addr_list_itr);
 
 	/* reprogram multicast list */
 	addr_count = netdev->mc_count;
 	if (addr_count)
 		addr_list = netdev->mc_list->dmi_addr;
-	ixgbe_update_mc_addr_list(hw, addr_list, addr_count,
-	                          ixgbe_addr_list_itr);
+	hw->mac.ops.update_mc_addr_list(hw, addr_list, addr_count,
+	                                ixgbe_addr_list_itr);
 }
 
 static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
@@ -1778,10 +1859,16 @@ static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 		q_vectors = 1;
 
 	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
+		struct napi_struct *napi;
 		q_vector = &adapter->q_vector[q_idx];
 		if (!q_vector->rxr_count)
 			continue;
-		napi_enable(&q_vector->napi);
+		napi = &q_vector->napi;
+		if ((adapter->flags & IXGBE_FLAG_MSIX_ENABLED) &&
+		    (q_vector->rxr_count > 1))
+			napi->poll = &ixgbe_clean_rxonly_many;
+
+		napi_enable(napi);
 	}
 }
 
@@ -1816,7 +1903,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_configure_rx(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		ixgbe_alloc_rx_buffers(adapter, &adapter->rx_ring[i],
-					   (adapter->rx_ring[i].count - 1));
+		                       (adapter->rx_ring[i].count - 1));
 }
 
 static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
@@ -1834,7 +1921,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	    (adapter->flags & IXGBE_FLAG_MSI_ENABLED)) {
 		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 			gpie = (IXGBE_GPIE_MSIX_MODE | IXGBE_GPIE_EIAME |
-				IXGBE_GPIE_PBA_SUPPORT | IXGBE_GPIE_OCD);
+			        IXGBE_GPIE_PBA_SUPPORT | IXGBE_GPIE_OCD);
 		} else {
 			/* MSI only */
 			gpie = 0;
@@ -1897,6 +1984,8 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	/* bring the link up in the watchdog, this could race with our first
 	 * link up interrupt but shouldn't be a problem */
+	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
+	adapter->link_check_timeout = jiffies;
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	return 0;
 }
@@ -1921,58 +2010,22 @@ int ixgbe_up(struct ixgbe_adapter *adapter)
 
 void ixgbe_reset(struct ixgbe_adapter *adapter)
 {
-	if (ixgbe_init_hw(&adapter->hw))
-		DPRINTK(PROBE, ERR, "Hardware Error\n");
+	struct ixgbe_hw *hw = &adapter->hw;
+	if (hw->mac.ops.init_hw(hw))
+		dev_err(&adapter->pdev->dev, "Hardware Error\n");
 
 	/* reprogram the RAR[0] in case user changed it. */
-	ixgbe_set_rar(&adapter->hw, 0, adapter->hw.mac.addr, 0, IXGBE_RAH_AV);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 
 }
 
-#ifdef CONFIG_PM
-static int ixgbe_resume(struct pci_dev *pdev)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u32 err;
-
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	err = pci_enable_device(pdev);
-	if (err) {
-		printk(KERN_ERR "ixgbe: Cannot enable PCI device from " \
-				"suspend\n");
-		return err;
-	}
-	pci_set_master(pdev);
-
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
-	if (netif_running(netdev)) {
-		err = ixgbe_request_irq(adapter);
-		if (err)
-			return err;
-	}
-
-	ixgbe_reset(adapter);
-
-	if (netif_running(netdev))
-		ixgbe_up(adapter);
-
-	netif_device_attach(netdev);
-
-	return 0;
-}
-#endif
-
 /**
  * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
  * @adapter: board private structure
  * @rx_ring: ring to free buffers from
  **/
 static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rx_ring)
+                                struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
@@ -1986,8 +2039,8 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-					 rx_ring->rx_buf_len,
-					 PCI_DMA_FROMDEVICE);
+			                 rx_ring->rx_buf_len,
+			                 PCI_DMA_FROMDEVICE);
 			rx_buffer_info->dma = 0;
 		}
 		if (rx_buffer_info->skb) {
@@ -1996,12 +2049,12 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		}
 		if (!rx_buffer_info->page)
 			continue;
-		pci_unmap_page(pdev, rx_buffer_info->page_dma, PAGE_SIZE,
-			       PCI_DMA_FROMDEVICE);
+		pci_unmap_page(pdev, rx_buffer_info->page_dma, PAGE_SIZE / 2,
+		               PCI_DMA_FROMDEVICE);
 		rx_buffer_info->page_dma = 0;
-
 		put_page(rx_buffer_info->page);
 		rx_buffer_info->page = NULL;
+		rx_buffer_info->page_offset = 0;
 	}
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
@@ -2023,7 +2076,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
  * @tx_ring: ring to be cleaned
  **/
 static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *tx_ring)
+                                struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned long size;
@@ -2076,33 +2129,43 @@ static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
 void ixgbe_down(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
+	u32 txdctl;
+	int i, j;
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	/* disable receives */
-	rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXCTRL);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXCTRL,
-			rxctrl & ~IXGBE_RXCTRL_RXEN);
+	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
 
 	netif_tx_disable(netdev);
 
-	/* disable transmits in the hardware */
-
-	/* flush both disables */
-	IXGBE_WRITE_FLUSH(&adapter->hw);
+	IXGBE_WRITE_FLUSH(hw);
 	msleep(10);
 
+	netif_tx_stop_all_queues(netdev);
+
 	ixgbe_irq_disable(adapter);
 
 	ixgbe_napi_disable_all(adapter);
+
 	del_timer_sync(&adapter->watchdog_timer);
+	cancel_work_sync(&adapter->watchdog_task);
+
+	/* disable transmits in the hardware now that interrupts are off */
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		j = adapter->tx_ring[i].reg_idx;
+		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j),
+		                (txdctl & ~IXGBE_TXDCTL_ENABLE));
+	}
 
 	netif_carrier_off(netdev);
-	netif_tx_stop_all_queues(netdev);
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&adapter->pdev->dev);
@@ -2114,56 +2177,18 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	/* since we reset the hardware DCA settings were cleared */
 	if (dca_add_requester(&adapter->pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
 		 * in the CB driver */
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_CTRL, 2);
 		ixgbe_setup_dca(adapter);
 	}
 #endif
 }
 
-static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-#ifdef CONFIG_PM
-	int retval = 0;
-#endif
-
-	netif_device_detach(netdev);
-
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_free_irq(adapter);
-	}
-
-#ifdef CONFIG_PM
-	retval = pci_save_state(pdev);
-	if (retval)
-		return retval;
-#endif
-
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
-	ixgbe_release_hw_control(adapter);
-
-	pci_disable_device(pdev);
-
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-
-	return 0;
-}
-
-static void ixgbe_shutdown(struct pci_dev *pdev)
-{
-	ixgbe_suspend(pdev, PMSG_SUSPEND);
-}
-
 /**
  * ixgbe_poll - NAPI Rx polling callback
  * @napi: structure for representing this polling device
@@ -2174,11 +2199,11 @@ static void ixgbe_shutdown(struct pci_dev *pdev)
 static int ixgbe_poll(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector = container_of(napi,
-					  struct ixgbe_q_vector, napi);
+	                                          struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	int tx_cleaned = 0, work_done = 0;
+	int tx_cleaned, work_done = 0;
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		ixgbe_update_tx_dca(adapter, adapter->tx_ring);
 		ixgbe_update_rx_dca(adapter, adapter->rx_ring);
@@ -2194,12 +2219,11 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(adapter->netdev, napi);
-		if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
+		if (adapter->itr_setting & 3)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable(adapter);
 	}
-
 	return work_done;
 }
 
@@ -2225,8 +2249,48 @@ static void ixgbe_reset_task(struct work_struct *work)
 	ixgbe_reinit_locked(adapter);
 }
 
+static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
+{
+	int nrq = 1, ntq = 1;
+	int feature_mask = 0, rss_i, rss_m;
+
+	/* Number of supported queues */
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
+		rss_i = adapter->ring_feature[RING_F_RSS].indices;
+		rss_m = 0;
+		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
+
+		switch (adapter->flags & feature_mask) {
+		case (IXGBE_FLAG_RSS_ENABLED):
+			rss_m = 0xF;
+			nrq = rss_i;
+			ntq = rss_i;
+			break;
+		case 0:
+		default:
+			rss_i = 0;
+			rss_m = 0;
+			nrq = 1;
+			ntq = 1;
+			break;
+		}
+
+		adapter->ring_feature[RING_F_RSS].indices = rss_i;
+		adapter->ring_feature[RING_F_RSS].mask = rss_m;
+		break;
+	default:
+		nrq = 1;
+		ntq = 1;
+		break;
+	}
+
+	adapter->num_rx_queues = nrq;
+	adapter->num_tx_queues = ntq;
+}
+
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
-				       int vectors)
+                                       int vectors)
 {
 	int err, vector_threshold;
 
@@ -2245,7 +2309,7 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 	 */
 	while (vectors >= vector_threshold) {
 		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-				      vectors);
+		                      vectors);
 		if (!err) /* Success in acquiring all requested vectors. */
 			break;
 		else if (err < 0)
@@ -2264,54 +2328,13 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-		adapter->num_tx_queues = 1;
-		adapter->num_rx_queues = 1;
+		ixgbe_set_num_queues(adapter);
 	} else {
 		adapter->flags |= IXGBE_FLAG_MSIX_ENABLED; /* Woot! */
 		adapter->num_msix_vectors = vectors;
 	}
 }
 
-static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
-{
-	int nrq, ntq;
-	int feature_mask = 0, rss_i, rss_m;
-
-	/* Number of supported queues */
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82598EB:
-		rss_i = adapter->ring_feature[RING_F_RSS].indices;
-		rss_m = 0;
-		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
-
-		switch (adapter->flags & feature_mask) {
-		case (IXGBE_FLAG_RSS_ENABLED):
-			rss_m = 0xF;
-			nrq = rss_i;
-			ntq = rss_i;
-			break;
-		case 0:
-		default:
-			rss_i = 0;
-			rss_m = 0;
-			nrq = 1;
-			ntq = 1;
-			break;
-		}
-
-		adapter->ring_feature[RING_F_RSS].indices = rss_i;
-		adapter->ring_feature[RING_F_RSS].mask = rss_m;
-		break;
-	default:
-		nrq = 1;
-		ntq = 1;
-		break;
-	}
-
-	adapter->num_rx_queues = nrq;
-	adapter->num_tx_queues = ntq;
-}
-
 /**
  * ixgbe_cache_ring_register - Descriptor ring to register mapping
  * @adapter: board private structure to initialize
@@ -2321,9 +2344,6 @@ static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
  **/
 static void __devinit ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 {
-	/* TODO: Remove all uses of the indices in the cases where multiple
-	 *       features are OR'd together, if the feature set makes sense.
-	 */
 	int feature_mask = 0, rss_i;
 	int i, txr_idx, rxr_idx;
 
@@ -2364,21 +2384,22 @@ static int __devinit ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 	int i;
 
 	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
-				   sizeof(struct ixgbe_ring), GFP_KERNEL);
+	                           sizeof(struct ixgbe_ring), GFP_KERNEL);
 	if (!adapter->tx_ring)
 		goto err_tx_ring_allocation;
 
 	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
-				   sizeof(struct ixgbe_ring), GFP_KERNEL);
+	                           sizeof(struct ixgbe_ring), GFP_KERNEL);
 	if (!adapter->rx_ring)
 		goto err_rx_ring_allocation;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		adapter->tx_ring[i].count = IXGBE_DEFAULT_TXD;
+		adapter->tx_ring[i].count = adapter->tx_ring_count;
 		adapter->tx_ring[i].queue_index = i;
 	}
+
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->rx_ring[i].count = IXGBE_DEFAULT_RXD;
+		adapter->rx_ring[i].count = adapter->rx_ring_count;
 		adapter->rx_ring[i].queue_index = i;
 	}
 
@@ -2400,25 +2421,19 @@ err_tx_ring_allocation:
  * capabilities of the hardware and the kernel.
  **/
 static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
-						    *adapter)
+                                                    *adapter)
 {
 	int err = 0;
 	int vector, v_budget;
 
 	/*
-	 * Set the default interrupt throttle rate.
-	 */
-	adapter->rx_eitr = (1000000 / IXGBE_DEFAULT_ITR_RX_USECS);
-	adapter->tx_eitr = (1000000 / IXGBE_DEFAULT_ITR_TX_USECS);
-
-	/*
 	 * It's easy to be greedy for MSI-X vectors, but it really
 	 * doesn't do us much good if we have a lot more vectors
 	 * than CPU's.  So let's be conservative and only ask for
 	 * (roughly) twice the number of vectors as there are CPU's.
 	 */
 	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
-		       (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
+	               (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
 
 	/*
 	 * At the same time, hardware can only support a maximum of
@@ -2432,7 +2447,7 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter. */
 	adapter->msix_entries = kcalloc(v_budget,
-					sizeof(struct msix_entry), GFP_KERNEL);
+	                                sizeof(struct msix_entry), GFP_KERNEL);
 	if (!adapter->msix_entries) {
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		ixgbe_set_num_queues(adapter);
@@ -2441,7 +2456,7 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 		err = ixgbe_alloc_queues(adapter);
 		if (err) {
 			DPRINTK(PROBE, ERR, "Unable to allocate memory "
-					    "for queues\n");
+			        "for queues\n");
 			goto out;
 		}
 
@@ -2462,7 +2477,7 @@ try_msi:
 		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
 	} else {
 		DPRINTK(HW, DEBUG, "Unable to allocate MSI interrupt, "
-				   "falling back to legacy.  Error: %d\n", err);
+		        "falling back to legacy.  Error: %d\n", err);
 		/* reset err */
 		err = 0;
 	}
@@ -2518,9 +2533,9 @@ static int __devinit ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 	}
 
 	DPRINTK(DRV, INFO, "Multiqueue %s: Rx Queue count = %u, "
-			   "Tx Queue count = %u\n",
-		(adapter->num_rx_queues > 1) ? "Enabled" :
-		"Disabled", adapter->num_rx_queues, adapter->num_tx_queues);
+	        "Tx Queue count = %u\n",
+	        (adapter->num_rx_queues > 1) ? "Enabled" :
+	        "Disabled", adapter->num_rx_queues, adapter->num_tx_queues);
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
@@ -2547,15 +2562,19 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned int rss;
 
+	/* PCI config space info */
+
+	hw->vendor_id = pdev->vendor;
+	hw->device_id = pdev->device;
+	hw->revision_id = pdev->revision;
+	hw->subsystem_vendor_id = pdev->subsystem_vendor;
+	hw->subsystem_device_id = pdev->subsystem_device;
+
 	/* Set capability flags */
 	rss = min(IXGBE_MAX_RSS_INDICES, (int)num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 
-	/* Enable Dynamic interrupt throttling by default */
-	adapter->rx_eitr = 1;
-	adapter->tx_eitr = 1;
-
 	/* default flow control settings */
 	hw->fc.original_type = ixgbe_fc_none;
 	hw->fc.type = ixgbe_fc_none;
@@ -2566,18 +2585,21 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 
 	/* select 10G link by default */
 	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
-	if (hw->mac.ops.reset(hw)) {
-		dev_err(&pdev->dev, "HW Init failed\n");
-		return -EIO;
-	}
-	if (hw->mac.ops.setup_link_speed(hw, IXGBE_LINK_SPEED_10GB_FULL, true,
-					 false)) {
-		dev_err(&pdev->dev, "Link Speed setup failed\n");
-		return -EIO;
-	}
+
+	/* enable itr by default in dynamic mode */
+	adapter->itr_setting = 1;
+	adapter->eitr_param = 20000;
+
+	/* set defaults for eitr in MegaBytes */
+	adapter->eitr_low = 10;
+	adapter->eitr_high = 20;
+
+	/* set default ring sizes */
+	adapter->tx_ring_count = IXGBE_DEFAULT_TXD;
+	adapter->rx_ring_count = IXGBE_DEFAULT_RXD;
 
 	/* initialize eeprom parameters */
-	if (ixgbe_init_eeprom(hw)) {
+	if (ixgbe_init_eeprom_params_generic(hw)) {
 		dev_err(&pdev->dev, "EEPROM initialization failed\n");
 		return -EIO;
 	}
@@ -2633,6 +2655,31 @@ err:
 }
 
 /**
+ * ixgbe_setup_all_tx_resources - allocate all queues Tx resources
+ * @adapter: board private structure
+ *
+ * If this function returns with an error, then it's possible one or
+ * more of the rings is populated (while the rest are not).  It is the
+ * callers duty to clean those orphaned rings.
+ *
+ * Return 0 on success, negative on failure
+ **/
+static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
+{
+	int i, err = 0;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		err = ixgbe_setup_tx_resources(adapter, &adapter->tx_ring[i]);
+		if (!err)
+			continue;
+		DPRINTK(PROBE, ERR, "Allocation for Tx Queue %u failed\n", i);
+		break;
+	}
+
+	return err;
+}
+
+/**
  * ixgbe_setup_rx_resources - allocate Rx resources (Descriptors)
  * @adapter: board private structure
  * @rx_ring:    rx descriptor ring (for a specific queue) to setup
@@ -2640,22 +2687,23 @@ err:
  * Returns 0 on success, negative on failure
  **/
 int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *rx_ring)
+                             struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
+#ifdef CONFIG_IXGBE_LRO
 	size = sizeof(struct net_lro_desc) * IXGBE_MAX_LRO_DESCRIPTORS;
 	rx_ring->lro_mgr.lro_arr = vmalloc(size);
 	if (!rx_ring->lro_mgr.lro_arr)
 		return -ENOMEM;
 	memset(rx_ring->lro_mgr.lro_arr, 0, size);
-
+#endif
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
 	rx_ring->rx_buffer_info = vmalloc(size);
 	if (!rx_ring->rx_buffer_info) {
 		DPRINTK(PROBE, ERR,
-			"vmalloc allocation failed for the rx desc ring\n");
+		        "vmalloc allocation failed for the rx desc ring\n");
 		goto alloc_failed;
 	}
 	memset(rx_ring->rx_buffer_info, 0, size);
@@ -2668,7 +2716,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 
 	if (!rx_ring->desc) {
 		DPRINTK(PROBE, ERR,
-			"Memory allocation failed for the rx desc ring\n");
+		        "Memory allocation failed for the rx desc ring\n");
 		vfree(rx_ring->rx_buffer_info);
 		goto alloc_failed;
 	}
@@ -2679,20 +2727,48 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	return 0;
 
 alloc_failed:
+#ifdef CONFIG_IXGBE_LRO
 	vfree(rx_ring->lro_mgr.lro_arr);
 	rx_ring->lro_mgr.lro_arr = NULL;
+#endif
 	return -ENOMEM;
 }
 
 /**
+ * ixgbe_setup_all_rx_resources - allocate all queues Rx resources
+ * @adapter: board private structure
+ *
+ * If this function returns with an error, then it's possible one or
+ * more of the rings is populated (while the rest are not).  It is the
+ * callers duty to clean those orphaned rings.
+ *
+ * Return 0 on success, negative on failure
+ **/
+
+static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
+{
+	int i, err = 0;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		err = ixgbe_setup_rx_resources(adapter, &adapter->rx_ring[i]);
+		if (!err)
+			continue;
+		DPRINTK(PROBE, ERR, "Allocation for Rx Queue %u failed\n", i);
+		break;
+	}
+
+	return err;
+}
+
+/**
  * ixgbe_free_tx_resources - Free Tx Resources per Queue
  * @adapter: board private structure
  * @tx_ring: Tx descriptor ring for a specific queue
  *
  * Free all transmit software resources
  **/
-static void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
-                                    struct ixgbe_ring *tx_ring)
+void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
+                             struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -2727,13 +2803,15 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
  *
  * Free all receive software resources
  **/
-static void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *rx_ring)
+void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
+                             struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
+#ifdef CONFIG_IXGBE_LRO
 	vfree(rx_ring->lro_mgr.lro_arr);
 	rx_ring->lro_mgr.lro_arr = NULL;
+#endif
 
 	ixgbe_clean_rx_ring(adapter, rx_ring);
 
@@ -2760,59 +2838,6 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_setup_all_tx_resources - allocate all queues Tx resources
- * @adapter: board private structure
- *
- * If this function returns with an error, then it's possible one or
- * more of the rings is populated (while the rest are not).  It is the
- * callers duty to clean those orphaned rings.
- *
- * Return 0 on success, negative on failure
- **/
-static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
-{
-	int i, err = 0;
-
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		err = ixgbe_setup_tx_resources(adapter, &adapter->tx_ring[i]);
-		if (err) {
-			DPRINTK(PROBE, ERR,
-				"Allocation for Tx Queue %u failed\n", i);
-			break;
-		}
-	}
-
-	return err;
-}
-
-/**
- * ixgbe_setup_all_rx_resources - allocate all queues Rx resources
- * @adapter: board private structure
- *
- * If this function returns with an error, then it's possible one or
- * more of the rings is populated (while the rest are not).  It is the
- * callers duty to clean those orphaned rings.
- *
- * Return 0 on success, negative on failure
- **/
-
-static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
-{
-	int i, err = 0;
-
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		err = ixgbe_setup_rx_resources(adapter, &adapter->rx_ring[i]);
-		if (err) {
-			DPRINTK(PROBE, ERR,
-				"Allocation for Rx Queue %u failed\n", i);
-			break;
-		}
-	}
-
-	return err;
-}
-
-/**
  * ixgbe_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -2824,12 +2849,12 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if ((max_frame < (ETH_ZLEN + ETH_FCS_LEN)) ||
-	    (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
+	/* MTU < 68 is an error and causes problems on some kernels */
+	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
 		return -EINVAL;
 
 	DPRINTK(PROBE, INFO, "changing MTU from %d to %d\n",
-		netdev->mtu, new_mtu);
+	        netdev->mtu, new_mtu);
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
@@ -2924,6 +2949,135 @@ static int ixgbe_close(struct net_device *netdev)
 }
 
 /**
+ * ixgbe_napi_add_all - prep napi structs for use
+ * @adapter: private struct
+ * helper function to napi_add each possible q_vector->napi
+ */
+static void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
+{
+	int q_idx, q_vectors;
+	int (*poll)(struct napi_struct *, int);
+
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		poll = &ixgbe_clean_rxonly;
+		/* Only enable as many vectors as we have rx queues. */
+		q_vectors = adapter->num_rx_queues;
+	} else {
+		poll = &ixgbe_poll;
+		/* only one q_vector for legacy modes */
+		q_vectors = 1;
+	}
+
+	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
+		struct ixgbe_q_vector *q_vector = &adapter->q_vector[q_idx];
+		netif_napi_add(adapter->netdev, &q_vector->napi, (*poll), 64);
+	}
+}
+
+static void ixgbe_napi_del_all(struct ixgbe_adapter *adapter)
+{
+	int q_idx;
+	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
+	/* legacy and MSI only use one vector */
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
+		q_vectors = 1;
+
+	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
+		struct ixgbe_q_vector *q_vector = &adapter->q_vector[q_idx];
+		if (!q_vector->rxr_count)
+			continue;
+		netif_napi_del(&q_vector->napi);
+	}
+}
+
+#ifdef CONFIG_PM
+static int ixgbe_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u32 err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "ixgbe: Cannot enable PCI device from "
+				"suspend\n");
+		return err;
+	}
+	pci_set_master(pdev);
+
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	err = ixgbe_init_interrupt_scheme(adapter);
+	if (err) {
+		printk(KERN_ERR "ixgbe: Cannot initialize interrupts for "
+		                "device\n");
+		return err;
+	}
+
+	ixgbe_napi_add_all(adapter);
+	ixgbe_reset(adapter);
+
+	if (netif_running(netdev)) {
+		err = ixgbe_open(adapter->netdev);
+		if (err)
+			return err;
+	}
+
+	netif_device_attach(netdev);
+
+	return 0;
+}
+
+#endif /* CONFIG_PM */
+static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_PM
+	int retval = 0;
+#endif
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev)) {
+		ixgbe_down(adapter);
+		ixgbe_free_irq(adapter);
+		ixgbe_free_all_tx_resources(adapter);
+		ixgbe_free_all_rx_resources(adapter);
+	}
+	ixgbe_reset_interrupt_capability(adapter);
+	ixgbe_napi_del_all(adapter);
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+
+#ifdef CONFIG_PM
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
+#endif
+
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	ixgbe_release_hw_control(adapter);
+
+	pci_disable_device(pdev);
+
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	return 0;
+}
+
+static void ixgbe_shutdown(struct pci_dev *pdev)
+{
+	ixgbe_suspend(pdev, PMSG_SUSPEND);
+}
+
+/**
  * ixgbe_update_stats - Update the board statistics counters.
  * @adapter: board private structure
  **/
@@ -2996,7 +3150,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 
 	/* Rx Errors */
 	adapter->net_stats.rx_errors = adapter->stats.crcerrs +
-						adapter->stats.rlec;
+	                               adapter->stats.rlec;
 	adapter->net_stats.rx_dropped = 0;
 	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
@@ -3010,27 +3164,74 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 static void ixgbe_watchdog(unsigned long data)
 {
 	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
-	struct net_device *netdev = adapter->netdev;
-	bool link_up;
-	u32 link_speed = 0;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	/* Do the watchdog outside of interrupt context due to the lovely
+	 * delays that some of the newer hardware requires */
+	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+		/* Cause software interrupt to ensure rx rings are cleaned */
+		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+			u32 eics =
+			 (1 << (adapter->num_msix_vectors - NON_Q_VECTORS)) - 1;
+			IXGBE_WRITE_REG(hw, IXGBE_EICS, eics);
+		} else {
+			/* For legacy and MSI interrupts don't set any bits that
+			 * are enabled for EIAM, because this operation would
+			 * set *both* EIMS and EICS for any bit in EIAM */
+			IXGBE_WRITE_REG(hw, IXGBE_EICS,
+                                    (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
+		}
+		/* Reset the timer */
+		mod_timer(&adapter->watchdog_timer,
+		          round_jiffies(jiffies + 2 * HZ));
+	}
 
-	adapter->hw.mac.ops.check_link(&adapter->hw, &(link_speed), &link_up);
+	schedule_work(&adapter->watchdog_task);
+}
+
+/**
+ * ixgbe_watchdog_task - worker thread to bring link up
+ * @work: pointer to work_struct containing our data
+ **/
+static void ixgbe_watchdog_task(struct work_struct *work)
+{
+	struct ixgbe_adapter *adapter = container_of(work,
+	                                             struct ixgbe_adapter,
+	                                             watchdog_task);
+	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 link_speed = adapter->link_speed;
+	bool link_up = adapter->link_up;
+
+	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
+
+	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE) {
+		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+		if (link_up ||
+		    time_after(jiffies, (adapter->link_check_timeout +
+		                         IXGBE_TRY_LINK_TIMEOUT))) {
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMC_LSC);
+			adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
+		}
+		adapter->link_up = link_up;
+		adapter->link_speed = link_speed;
+	}
 
 	if (link_up) {
 		if (!netif_carrier_ok(netdev)) {
-			u32 frctl = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
-			u32 rmcs = IXGBE_READ_REG(&adapter->hw, IXGBE_RMCS);
+			u32 frctl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+			u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
 #define FLOW_RX (frctl & IXGBE_FCTRL_RFCE)
 #define FLOW_TX (rmcs & IXGBE_RMCS_TFCE_802_3X)
 			DPRINTK(LINK, INFO, "NIC Link is Up %s, "
-				"Flow Control: %s\n",
-				(link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
-				 "10 Gbps" :
-				 (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
-				  "1 Gbps" : "unknown speed")),
-				((FLOW_RX && FLOW_TX) ? "RX/TX" :
-				 (FLOW_RX ? "RX" :
-				 (FLOW_TX ? "TX" : "None"))));
+			        "Flow Control: %s\n",
+			        (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
+			         "10 Gbps" :
+			         (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
+			          "1 Gbps" : "unknown speed")),
+			        ((FLOW_RX && FLOW_TX) ? "RX/TX" :
+			         (FLOW_RX ? "RX" :
+			         (FLOW_TX ? "TX" : "None"))));
 
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
@@ -3039,6 +3240,8 @@ static void ixgbe_watchdog(unsigned long data)
 			adapter->detect_tx_hung = true;
 		}
 	} else {
+		adapter->link_up = false;
+		adapter->link_speed = 0;
 		if (netif_carrier_ok(netdev)) {
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
@@ -3047,36 +3250,19 @@ static void ixgbe_watchdog(unsigned long data)
 	}
 
 	ixgbe_update_stats(adapter);
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
-		/* Cause software interrupt to ensure rx rings are cleaned */
-		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-			u32 eics =
-			 (1 << (adapter->num_msix_vectors - NON_Q_VECTORS)) - 1;
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, eics);
-		} else {
-			/* for legacy and MSI interrupts don't set any bits that
-			 * are enabled for EIAM, because this operation would
-			 * set *both* EIMS and EICS for any bit in EIAM */
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
-				     (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
-		}
-		/* Reset the timer */
-		mod_timer(&adapter->watchdog_timer,
-			  round_jiffies(jiffies + 2 * HZ));
-	}
+	adapter->flags &= ~IXGBE_FLAG_IN_WATCHDOG_TASK;
 }
 
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
-			 struct ixgbe_ring *tx_ring, struct sk_buff *skb,
-			 u32 tx_flags, u8 *hdr_len)
+                     struct ixgbe_ring *tx_ring, struct sk_buff *skb,
+                     u32 tx_flags, u8 *hdr_len)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	unsigned int i;
 	int err;
 	struct ixgbe_tx_buffer *tx_buffer_info;
-	u32 vlan_macip_lens = 0, type_tucmd_mlhl = 0;
-	u32 mss_l4len_idx = 0, l4len;
+	u32 vlan_macip_lens = 0, type_tucmd_mlhl;
+	u32 mss_l4len_idx, l4len;
 
 	if (skb_is_gso(skb)) {
 		if (skb_header_cloned(skb)) {
@@ -3092,16 +3278,16 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			iph->tot_len = 0;
 			iph->check = 0;
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
+			                                         iph->daddr, 0,
+			                                         IPPROTO_TCP,
+			                                         0);
 			adapter->hw_tso_ctxt++;
 		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
 			ipv6_hdr(skb)->payload_len = 0;
 			tcp_hdr(skb)->check =
 			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-					     &ipv6_hdr(skb)->daddr,
-					     0, IPPROTO_TCP, 0);
+			                     &ipv6_hdr(skb)->daddr,
+			                     0, IPPROTO_TCP, 0);
 			adapter->hw_tso6_ctxt++;
 		}
 
@@ -3115,7 +3301,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			vlan_macip_lens |=
 			    (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
 		vlan_macip_lens |= ((skb_network_offset(skb)) <<
-				    IXGBE_ADVTXD_MACLEN_SHIFT);
+		                    IXGBE_ADVTXD_MACLEN_SHIFT);
 		*hdr_len += skb_network_offset(skb);
 		vlan_macip_lens |=
 		    (skb_transport_header(skb) - skb_network_header(skb));
@@ -3125,8 +3311,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		context_desc->seqnum_seed = 0;
 
 		/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
-		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
-				    IXGBE_ADVTXD_DTYP_CTXT);
+		type_tucmd_mlhl = (IXGBE_TXD_CMD_DEXT |
+		                   IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->protocol == htons(ETH_P_IP))
 			type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
@@ -3134,7 +3320,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
 
 		/* MSS L4LEN IDX */
-		mss_l4len_idx |=
+		mss_l4len_idx =
 		    (skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT);
 		mss_l4len_idx |= (l4len << IXGBE_ADVTXD_L4LEN_SHIFT);
 		/* use index 1 for TSO */
@@ -3155,8 +3341,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 }
 
 static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
-				   struct ixgbe_ring *tx_ring,
-				   struct sk_buff *skb, u32 tx_flags)
+                          struct ixgbe_ring *tx_ring,
+                          struct sk_buff *skb, u32 tx_flags)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -3173,16 +3359,16 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 			vlan_macip_lens |=
 			    (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
 		vlan_macip_lens |= (skb_network_offset(skb) <<
-				    IXGBE_ADVTXD_MACLEN_SHIFT);
+		                    IXGBE_ADVTXD_MACLEN_SHIFT);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			vlan_macip_lens |= (skb_transport_header(skb) -
-					    skb_network_header(skb));
+			                    skb_network_header(skb));
 
 		context_desc->vlan_macip_lens = cpu_to_le32(vlan_macip_lens);
 		context_desc->seqnum_seed = 0;
 
 		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
-				    IXGBE_ADVTXD_DTYP_CTXT);
+		                    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			switch (skb->protocol) {
@@ -3190,16 +3376,14 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_TCP;
+					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				break;
-
 			case __constant_htons(ETH_P_IPV6):
 				/* XXX what about other V6 headers?? */
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_TCP;
+					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				break;
-
 			default:
 				if (unlikely(net_ratelimit())) {
 					DPRINTK(PROBE, WARNING,
@@ -3216,6 +3400,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
+
 		adapter->hw_csum_tx_good++;
 		i++;
 		if (i == tx_ring->count)
@@ -3224,12 +3409,13 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 
 		return true;
 	}
+
 	return false;
 }
 
 static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
-			struct ixgbe_ring *tx_ring,
-			struct sk_buff *skb, unsigned int first)
+                        struct ixgbe_ring *tx_ring,
+                        struct sk_buff *skb, unsigned int first)
 {
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned int len = skb->len;
@@ -3247,8 +3433,8 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 		tx_buffer_info->length = size;
 		tx_buffer_info->dma = pci_map_single(adapter->pdev,
-						  skb->data + offset,
-						  size, PCI_DMA_TODEVICE);
+		                                     skb->data + offset,
+		                                     size, PCI_DMA_TODEVICE);
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
 
@@ -3273,9 +3459,10 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 			tx_buffer_info->length = size;
 			tx_buffer_info->dma = pci_map_page(adapter->pdev,
-							frag->page,
-							offset,
-							size, PCI_DMA_TODEVICE);
+			                                   frag->page,
+			                                   offset,
+			                                   size,
+			                                   PCI_DMA_TODEVICE);
 			tx_buffer_info->time_stamp = jiffies;
 			tx_buffer_info->next_to_watch = i;
 
@@ -3298,8 +3485,8 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 }
 
 static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
-			       struct ixgbe_ring *tx_ring,
-			       int tx_flags, int count, u32 paylen, u8 hdr_len)
+                           struct ixgbe_ring *tx_ring,
+                           int tx_flags, int count, u32 paylen, u8 hdr_len)
 {
 	union ixgbe_adv_tx_desc *tx_desc = NULL;
 	struct ixgbe_tx_buffer *tx_buffer_info;
@@ -3318,17 +3505,17 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		cmd_type_len |= IXGBE_ADVTXD_DCMD_TSE;
 
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-						IXGBE_ADVTXD_POPTS_SHIFT;
+		                 IXGBE_ADVTXD_POPTS_SHIFT;
 
 		/* use index 1 context for tso */
 		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
 			olinfo_status |= IXGBE_TXD_POPTS_IXSM <<
-						IXGBE_ADVTXD_POPTS_SHIFT;
+			                 IXGBE_ADVTXD_POPTS_SHIFT;
 
 	} else if (tx_flags & IXGBE_TX_FLAGS_CSUM)
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-						IXGBE_ADVTXD_POPTS_SHIFT;
+		                 IXGBE_ADVTXD_POPTS_SHIFT;
 
 	olinfo_status |= ((paylen - hdr_len) << IXGBE_ADVTXD_PAYLEN_SHIFT);
 
@@ -3338,9 +3525,8 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
 		tx_desc->read.buffer_addr = cpu_to_le64(tx_buffer_info->dma);
 		tx_desc->read.cmd_type_len =
-			cpu_to_le32(cmd_type_len | tx_buffer_info->length);
+		        cpu_to_le32(cmd_type_len | tx_buffer_info->length);
 		tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
-
 		i++;
 		if (i == tx_ring->count)
 			i = 0;
@@ -3361,7 +3547,7 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 }
 
 static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
-				 struct ixgbe_ring *tx_ring, int size)
+                                 struct ixgbe_ring *tx_ring, int size)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
@@ -3377,61 +3563,52 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_wake_subqueue(netdev, tx_ring->queue_index);
+	netif_start_subqueue(netdev, tx_ring->queue_index);
 	++adapter->restart_queue;
 	return 0;
 }
 
 static int ixgbe_maybe_stop_tx(struct net_device *netdev,
-			       struct ixgbe_ring *tx_ring, int size)
+                              struct ixgbe_ring *tx_ring, int size)
 {
 	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
 		return 0;
 	return __ixgbe_maybe_stop_tx(netdev, tx_ring, size);
 }
 
-
 static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
-	unsigned int len = skb->len;
 	unsigned int first;
 	unsigned int tx_flags = 0;
 	u8 hdr_len = 0;
 	int r_idx = 0, tso;
-	unsigned int mss = 0;
 	int count = 0;
 	unsigned int f;
-	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
-	len -= skb->data_len;
+
 	r_idx = (adapter->num_tx_queues - 1) & skb->queue_mapping;
 	tx_ring = &adapter->tx_ring[r_idx];
 
-
-	if (skb->len <= 0) {
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
+	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+		tx_flags |= vlan_tx_tag_get(skb);
+		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
+		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
-	mss = skb_shinfo(skb)->gso_size;
-
-	if (mss)
-		count++;
-	else if (skb->ip_summed == CHECKSUM_PARTIAL)
+	/* three things can cause us to need a context descriptor */
+	if (skb_is_gso(skb) ||
+	    (skb->ip_summed == CHECKSUM_PARTIAL) ||
+	    (tx_flags & IXGBE_TX_FLAGS_VLAN))
 		count++;
 
-	count += TXD_USE_COUNT(len);
-	for (f = 0; f < nr_frags; f++)
+	count += TXD_USE_COUNT(skb_headlen(skb));
+	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
 
 	if (ixgbe_maybe_stop_tx(netdev, tx_ring, count)) {
 		adapter->tx_busy++;
 		return NETDEV_TX_BUSY;
 	}
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
-		tx_flags |= IXGBE_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT);
-	}
 
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= IXGBE_TX_FLAGS_IPV4;
@@ -3445,12 +3622,12 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (tso)
 		tx_flags |= IXGBE_TX_FLAGS_TSO;
 	else if (ixgbe_tx_csum(adapter, tx_ring, skb, tx_flags) &&
-		 (skb->ip_summed == CHECKSUM_PARTIAL))
+	         (skb->ip_summed == CHECKSUM_PARTIAL))
 		tx_flags |= IXGBE_TX_FLAGS_CSUM;
 
 	ixgbe_tx_queue(adapter, tx_ring, tx_flags,
-			   ixgbe_tx_map(adapter, tx_ring, skb, first),
-			   skb->len, hdr_len);
+	               ixgbe_tx_map(adapter, tx_ring, skb, first),
+	               skb->len, hdr_len);
 
 	netdev->trans_start = jiffies;
 
@@ -3484,15 +3661,16 @@ static struct net_device_stats *ixgbe_get_stats(struct net_device *netdev)
 static int ixgbe_set_mac(struct net_device *netdev, void *p)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(adapter->hw.mac.addr, addr->sa_data, netdev->addr_len);
+	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
-	ixgbe_set_rar(&adapter->hw, 0, adapter->hw.mac.addr, 0, IXGBE_RAH_AV);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 
 	return 0;
 }
@@ -3516,28 +3694,19 @@ static void ixgbe_netpoll(struct net_device *netdev)
 #endif
 
 /**
- * ixgbe_napi_add_all - prep napi structs for use
- * @adapter: private struct
- * helper function to napi_add each possible q_vector->napi
- */
-static void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
+ * ixgbe_link_config - set up initial link with default speed and duplex
+ * @hw: pointer to private hardware struct
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int ixgbe_link_config(struct ixgbe_hw *hw)
 {
-	int i, q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-	int (*poll)(struct napi_struct *, int);
+	u32 autoneg = IXGBE_LINK_SPEED_10GB_FULL;
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		poll = &ixgbe_clean_rxonly;
-	} else {
-		poll = &ixgbe_poll;
-		/* only one q_vector for legacy modes */
-		q_vectors = 1;
-	}
+	/* must always autoneg for both 1G and 10G link */
+	hw->mac.autoneg = true;
 
-	for (i = 0; i < q_vectors; i++) {
-		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
-		netif_napi_add(adapter->netdev, &q_vector->napi,
-			       (*poll), 64);
-	}
+	return hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
 }
 
 /**
@@ -3552,17 +3721,16 @@ static void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
  * and a hardware reset occur.
  **/
 static int __devinit ixgbe_probe(struct pci_dev *pdev,
-				 const struct pci_device_id *ent)
+                                 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct ixgbe_adapter *adapter = NULL;
 	struct ixgbe_hw *hw;
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
-	unsigned long mmio_start, mmio_len;
 	static int cards_found;
 	int i, err, pci_using_dac;
 	u16 link_status, link_speed, link_width;
-	u32 part_num;
+	u32 part_num, eec;
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -3577,7 +3745,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 			if (err) {
 				dev_err(&pdev->dev, "No usable DMA "
-					"configuration, aborting\n");
+				        "configuration, aborting\n");
 				goto err_dma;
 			}
 		}
@@ -3610,10 +3778,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	hw->back = adapter;
 	adapter->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
 
-	mmio_start = pci_resource_start(pdev, 0);
-	mmio_len = pci_resource_len(pdev, 0);
-
-	hw->hw_addr = ioremap(mmio_start, mmio_len);
+	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
+	                      pci_resource_len(pdev, 0));
 	if (!hw->hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
@@ -3643,22 +3809,23 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 #endif
 	strcpy(netdev->name, pci_name(pdev));
 
-	netdev->mem_start = mmio_start;
-	netdev->mem_end = mmio_start + mmio_len;
-
 	adapter->bd_number = cards_found;
 
-	/* PCI config space info */
-	hw->vendor_id = pdev->vendor;
-	hw->device_id = pdev->device;
-	hw->revision_id = pdev->revision;
-	hw->subsystem_vendor_id = pdev->subsystem_vendor;
-	hw->subsystem_device_id = pdev->subsystem_device;
-
 	/* Setup hw api */
 	memcpy(&hw->mac.ops, ii->mac_ops, sizeof(hw->mac.ops));
 	hw->mac.type  = ii->mac;
 
+	/* EEPROM */
+	memcpy(&hw->eeprom.ops, ii->eeprom_ops, sizeof(hw->eeprom.ops));
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+	/* If EEPROM is valid (bit 8 = 1), use default otherwise use bit bang */
+	if (!(eec & (1 << 8)))
+		hw->eeprom.ops.read = &ixgbe_read_eeprom_bit_bang_generic;
+
+	/* PHY */
+	memcpy(&hw->phy.ops, ii->phy_ops, sizeof(hw->phy.ops));
+	/* phy->sfp_type = ixgbe_sfp_type_unknown; */
+
 	err = ii->get_invariants(hw);
 	if (err)
 		goto err_hw_init;
@@ -3668,16 +3835,25 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+	/* reset_hw fills in the perm_addr as well */
+	err = hw->mac.ops.reset_hw(hw);
+	if (err) {
+		dev_err(&adapter->pdev->dev, "HW Init failed: %d\n", err);
+		goto err_sw_init;
+	}
+
 	netdev->features = NETIF_F_SG |
-			   NETIF_F_IP_CSUM |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX |
-			   NETIF_F_HW_VLAN_FILTER;
+	                   NETIF_F_IP_CSUM |
+	                   NETIF_F_HW_VLAN_TX |
+	                   NETIF_F_HW_VLAN_RX |
+	                   NETIF_F_HW_VLAN_FILTER;
 
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
+#ifdef CONFIG_IXGBE_LRO
 	netdev->features |= NETIF_F_LRO;
+#endif
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
@@ -3688,7 +3864,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	/* make sure the EEPROM is good */
-	if (ixgbe_validate_eeprom_checksum(hw, NULL) < 0) {
+	if (hw->eeprom.ops.validate_checksum(hw, NULL) < 0) {
 		dev_err(&pdev->dev, "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
@@ -3697,7 +3873,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, hw->mac.perm_addr, netdev->addr_len);
 
-	if (ixgbe_validate_mac_addr(netdev->dev_addr)) {
+	if (ixgbe_validate_mac_addr(netdev->perm_addr)) {
+		dev_err(&pdev->dev, "invalid MAC address\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -3707,6 +3884,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
+	INIT_WORK(&adapter->watchdog_task, ixgbe_watchdog_task);
 
 	err = ixgbe_init_interrupt_scheme(adapter);
 	if (err)
@@ -3717,32 +3895,39 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	link_speed = link_status & IXGBE_PCI_LINK_SPEED;
 	link_width = link_status & IXGBE_PCI_LINK_WIDTH;
 	dev_info(&pdev->dev, "(PCI Express:%s:%s) "
-		 "%02x:%02x:%02x:%02x:%02x:%02x\n",
-		((link_speed == IXGBE_PCI_LINK_SPEED_5000) ? "5.0Gb/s" :
-		 (link_speed == IXGBE_PCI_LINK_SPEED_2500) ? "2.5Gb/s" :
-		 "Unknown"),
-		((link_width == IXGBE_PCI_LINK_WIDTH_8) ? "Width x8" :
-		 (link_width == IXGBE_PCI_LINK_WIDTH_4) ? "Width x4" :
-		 (link_width == IXGBE_PCI_LINK_WIDTH_2) ? "Width x2" :
-		 (link_width == IXGBE_PCI_LINK_WIDTH_1) ? "Width x1" :
-		 "Unknown"),
-		netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
-		netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
-	ixgbe_read_part_num(hw, &part_num);
+	         "%02x:%02x:%02x:%02x:%02x:%02x\n",
+	        ((link_speed == IXGBE_PCI_LINK_SPEED_5000) ? "5.0Gb/s" :
+	         (link_speed == IXGBE_PCI_LINK_SPEED_2500) ? "2.5Gb/s" :
+	         "Unknown"),
+	        ((link_width == IXGBE_PCI_LINK_WIDTH_8) ? "Width x8" :
+	         (link_width == IXGBE_PCI_LINK_WIDTH_4) ? "Width x4" :
+	         (link_width == IXGBE_PCI_LINK_WIDTH_2) ? "Width x2" :
+	         (link_width == IXGBE_PCI_LINK_WIDTH_1) ? "Width x1" :
+	         "Unknown"),
+	        netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
+	        netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
+	ixgbe_read_pba_num_generic(hw, &part_num);
 	dev_info(&pdev->dev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
-		 hw->mac.type, hw->phy.type,
-		 (part_num >> 8), (part_num & 0xff));
+	         hw->mac.type, hw->phy.type,
+	         (part_num >> 8), (part_num & 0xff));
 
 	if (link_width <= IXGBE_PCI_LINK_WIDTH_4) {
 		dev_warn(&pdev->dev, "PCI-Express bandwidth available for "
-			 "this card is not sufficient for optimal "
-			 "performance.\n");
+		         "this card is not sufficient for optimal "
+		         "performance.\n");
 		dev_warn(&pdev->dev, "For optimal performance a x8 "
-			 "PCI-Express slot is required.\n");
+		         "PCI-Express slot is required.\n");
 	}
 
 	/* reset the hardware with the new settings */
-	ixgbe_start_hw(hw);
+	hw->mac.ops.start_hw(hw);
+
+	/* link_config depends on start_hw being called at least once */
+	err = ixgbe_link_config(hw);
+	if (err) {
+		dev_err(&pdev->dev, "setup_link_speed FAILED %d\n", err);
+		goto err_register;
+	}
 
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
@@ -3754,7 +3939,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
@@ -3804,7 +3989,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&pdev->dev);
@@ -3822,6 +4007,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 
 	DPRINTK(PROBE, INFO, "complete\n");
+	ixgbe_napi_del_all(adapter);
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 
@@ -3839,7 +4025,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
  * this device has been detected.
  */
 static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
-						pci_channel_state_t state)
+                                                pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev->priv;
@@ -3850,7 +4036,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 		ixgbe_down(adapter);
 	pci_disable_device(pdev);
 
-	/* Request a slot slot reset. */
+	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
@@ -3867,7 +4053,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 
 	if (pci_enable_device(pdev)) {
 		DPRINTK(PROBE, ERR,
-			"Cannot re-enable PCI device after reset.\n");
+		        "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
@@ -3901,7 +4087,6 @@ static void ixgbe_io_resume(struct pci_dev *pdev)
 	}
 
 	netif_device_attach(netdev);
-
 }
 
 static struct pci_error_handlers ixgbe_err_handler = {
@@ -3937,13 +4122,14 @@ static int __init ixgbe_init_module(void)
 
 	printk(KERN_INFO "%s: %s\n", ixgbe_driver_name, ixgbe_copyright);
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	dca_register_notify(&dca_notifier);
 
 #endif
 	ret = pci_register_driver(&ixgbe_driver);
 	return ret;
 }
+
 module_init(ixgbe_init_module);
 
 /**
@@ -3954,20 +4140,20 @@ module_init(ixgbe_init_module);
  **/
 static void __exit ixgbe_exit_module(void)
 {
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&ixgbe_driver);
 }
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
-			    void *p)
+                            void *p)
 {
 	int ret_val;
 
 	ret_val = driver_for_each_device(&ixgbe_driver.driver, NULL, &event,
-					 __ixgbe_notify_dca);
+	                                 __ixgbe_notify_dca);
 
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 8002931..764035a 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -33,32 +32,36 @@
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
+static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr);
 static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id);
 static s32 ixgbe_get_phy_id(struct ixgbe_hw *hw);
-static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr);
-static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
-			       u32 device_type, u16 phy_data);
 
 /**
- *  ixgbe_identify_phy - Get physical layer module
+ *  ixgbe_identify_phy_generic - Get physical layer module
  *  @hw: pointer to hardware structure
  *
  *  Determines the physical layer module found on the current adapter.
  **/
-s32 ixgbe_identify_phy(struct ixgbe_hw *hw)
+s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
 	u32 phy_addr;
 
-	for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
-		if (ixgbe_validate_phy_addr(hw, phy_addr)) {
-			hw->phy.addr = phy_addr;
-			ixgbe_get_phy_id(hw);
-			hw->phy.type = ixgbe_get_phy_type_from_id(hw->phy.id);
-			status = 0;
-			break;
+	if (hw->phy.type == ixgbe_phy_unknown) {
+		for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
+			if (ixgbe_validate_phy_addr(hw, phy_addr)) {
+				hw->phy.addr = phy_addr;
+				ixgbe_get_phy_id(hw);
+				hw->phy.type =
+				        ixgbe_get_phy_type_from_id(hw->phy.id);
+				status = 0;
+				break;
+			}
 		}
+	} else {
+		status = 0;
 	}
+
 	return status;
 }
 
@@ -73,10 +76,8 @@ static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr)
 	bool valid = false;
 
 	hw->phy.addr = phy_addr;
-	ixgbe_read_phy_reg(hw,
-			   IXGBE_MDIO_PHY_ID_HIGH,
-			   IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-			   &phy_id);
+	hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_HIGH,
+	                     IXGBE_MDIO_PMA_PMD_DEV_TYPE, &phy_id);
 
 	if (phy_id != 0xFFFF && phy_id != 0x0)
 		valid = true;
@@ -95,21 +96,18 @@ static s32 ixgbe_get_phy_id(struct ixgbe_hw *hw)
 	u16 phy_id_high = 0;
 	u16 phy_id_low = 0;
 
-	status = ixgbe_read_phy_reg(hw,
-				   IXGBE_MDIO_PHY_ID_HIGH,
-				   IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-				   &phy_id_high);
+	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_HIGH,
+	                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+	                              &phy_id_high);
 
 	if (status == 0) {
 		hw->phy.id = (u32)(phy_id_high << 16);
-		status = ixgbe_read_phy_reg(hw,
-					   IXGBE_MDIO_PHY_ID_LOW,
-					   IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-					   &phy_id_low);
+		status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_LOW,
+		                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+		                              &phy_id_low);
 		hw->phy.id |= (u32)(phy_id_low & IXGBE_PHY_REVISION_MASK);
 		hw->phy.revision = (u32)(phy_id_low & ~IXGBE_PHY_REVISION_MASK);
 	}
-
 	return status;
 }
 
@@ -123,9 +121,6 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 	enum ixgbe_phy_type phy_type;
 
 	switch (phy_id) {
-	case TN1010_PHY_ID:
-		phy_type = ixgbe_phy_tn;
-		break;
 	case QT2022_PHY_ID:
 		phy_type = ixgbe_phy_qt;
 		break;
@@ -138,32 +133,31 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 }
 
 /**
- *  ixgbe_reset_phy - Performs a PHY reset
+ *  ixgbe_reset_phy_generic - Performs a PHY reset
  *  @hw: pointer to hardware structure
  **/
-s32 ixgbe_reset_phy(struct ixgbe_hw *hw)
+s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw)
 {
 	/*
 	 * Perform soft PHY reset to the PHY_XS.
 	 * This will cause a soft reset to the PHY
 	 */
-	return ixgbe_write_phy_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
-				   IXGBE_MDIO_PHY_XS_DEV_TYPE,
-				   IXGBE_MDIO_PHY_XS_RESET);
+	return hw->phy.ops.write_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
+	                             IXGBE_MDIO_PHY_XS_DEV_TYPE,
+	                             IXGBE_MDIO_PHY_XS_RESET);
 }
 
 /**
- *  ixgbe_read_phy_reg - Reads a value from a specified PHY register
+ *  ixgbe_read_phy_reg_generic - Reads a value from a specified PHY register
  *  @hw: pointer to hardware structure
  *  @reg_addr: 32 bit address of PHY register to read
  *  @phy_data: Pointer to read data from PHY register
  **/
-s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
-		       u32 device_type, u16 *phy_data)
+s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
+                               u32 device_type, u16 *phy_data)
 {
 	u32 command;
 	u32 i;
-	u32 timeout = 10;
 	u32 data;
 	s32 status = 0;
 	u16 gssr;
@@ -179,9 +173,9 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 	if (status == 0) {
 		/* Setup and write the address cycle command */
 		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
-			   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-			   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
-			   (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
+		           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+		           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+		           (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
 
 		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
 
@@ -190,7 +184,7 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 		 * The MDI Command bit will clear when the operation is
 		 * complete
 		 */
-		for (i = 0; i < timeout; i++) {
+		for (i = 0; i < IXGBE_MDIO_COMMAND_TIMEOUT; i++) {
 			udelay(10);
 
 			command = IXGBE_READ_REG(hw, IXGBE_MSCA);
@@ -210,9 +204,9 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			 * command
 			 */
 			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
-				   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-				   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
-				   (IXGBE_MSCA_READ | IXGBE_MSCA_MDI_COMMAND));
+			           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+			           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			           (IXGBE_MSCA_READ | IXGBE_MSCA_MDI_COMMAND));
 
 			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
 
@@ -221,7 +215,7 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			 * completed. The MDI Command bit will clear when the
 			 * operation is complete
 			 */
-			for (i = 0; i < timeout; i++) {
+			for (i = 0; i < IXGBE_MDIO_COMMAND_TIMEOUT; i++) {
 				udelay(10);
 
 				command = IXGBE_READ_REG(hw, IXGBE_MSCA);
@@ -231,8 +225,7 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			}
 
 			if ((command & IXGBE_MSCA_MDI_COMMAND) != 0) {
-				hw_dbg(hw,
-				       "PHY read command didn't complete\n");
+				hw_dbg(hw, "PHY read command didn't complete\n");
 				status = IXGBE_ERR_PHY;
 			} else {
 				/*
@@ -247,22 +240,22 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 
 		ixgbe_release_swfw_sync(hw, gssr);
 	}
+
 	return status;
 }
 
 /**
- *  ixgbe_write_phy_reg - Writes a value to specified PHY register
+ *  ixgbe_write_phy_reg_generic - Writes a value to specified PHY register
  *  @hw: pointer to hardware structure
  *  @reg_addr: 32 bit PHY register to write
  *  @device_type: 5 bit device type
  *  @phy_data: Data to write to the PHY register
  **/
-static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
-			       u32 device_type, u16 phy_data)
+s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
+                                u32 device_type, u16 phy_data)
 {
 	u32 command;
 	u32 i;
-	u32 timeout = 10;
 	s32 status = 0;
 	u16 gssr;
 
@@ -280,9 +273,9 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 
 		/* Setup and write the address cycle command */
 		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
-			   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-			   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
-			   (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
+		           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+		           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+		           (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
 
 		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
 
@@ -291,19 +284,19 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 		 * The MDI Command bit will clear when the operation is
 		 * complete
 		 */
-		for (i = 0; i < timeout; i++) {
+		for (i = 0; i < IXGBE_MDIO_COMMAND_TIMEOUT; i++) {
 			udelay(10);
 
 			command = IXGBE_READ_REG(hw, IXGBE_MSCA);
 
-			if ((command & IXGBE_MSCA_MDI_COMMAND) == 0) {
-				hw_dbg(hw, "PHY address cmd didn't complete\n");
+			if ((command & IXGBE_MSCA_MDI_COMMAND) == 0)
 				break;
-			}
 		}
 
-		if ((command & IXGBE_MSCA_MDI_COMMAND) != 0)
+		if ((command & IXGBE_MSCA_MDI_COMMAND) != 0) {
+			hw_dbg(hw, "PHY address cmd didn't complete\n");
 			status = IXGBE_ERR_PHY;
+		}
 
 		if (status == 0) {
 			/*
@@ -311,9 +304,9 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			 * command
 			 */
 			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
-				   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-				   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
-				   (IXGBE_MSCA_WRITE | IXGBE_MSCA_MDI_COMMAND));
+			           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+			           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			           (IXGBE_MSCA_WRITE | IXGBE_MSCA_MDI_COMMAND));
 
 			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
 
@@ -322,20 +315,19 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			 * completed. The MDI Command bit will clear when the
 			 * operation is complete
 			 */
-			for (i = 0; i < timeout; i++) {
+			for (i = 0; i < IXGBE_MDIO_COMMAND_TIMEOUT; i++) {
 				udelay(10);
 
 				command = IXGBE_READ_REG(hw, IXGBE_MSCA);
 
-				if ((command & IXGBE_MSCA_MDI_COMMAND) == 0) {
-					hw_dbg(hw, "PHY write command did not "
-						  "complete.\n");
+				if ((command & IXGBE_MSCA_MDI_COMMAND) == 0)
 					break;
-				}
 			}
 
-			if ((command & IXGBE_MSCA_MDI_COMMAND) != 0)
+			if ((command & IXGBE_MSCA_MDI_COMMAND) != 0) {
+				hw_dbg(hw, "PHY address cmd didn't complete\n");
 				status = IXGBE_ERR_PHY;
+			}
 		}
 
 		ixgbe_release_swfw_sync(hw, gssr);
@@ -345,67 +337,54 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 }
 
 /**
- *  ixgbe_setup_tnx_phy_link - Set and restart autoneg
+ *  ixgbe_setup_phy_link_generic - Set and restart autoneg
  *  @hw: pointer to hardware structure
  *
  *  Restart autonegotiation and PHY and waits for completion.
  **/
-s32 ixgbe_setup_tnx_phy_link(struct ixgbe_hw *hw)
+s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_NOT_IMPLEMENTED;
 	u32 time_out;
 	u32 max_time_out = 10;
-	u16 autoneg_speed_selection_register = 0x10;
-	u16 autoneg_restart_mask = 0x0200;
-	u16 autoneg_complete_mask = 0x0020;
-	u16 autoneg_reg = 0;
+	u16 autoneg_reg = IXGBE_MII_AUTONEG_REG;
 
 	/*
 	 * Set advertisement settings in PHY based on autoneg_advertised
 	 * settings. If autoneg_advertised = 0, then advertise default values
-	 * txn devices cannot be "forced" to a autoneg 10G and fail.  But can
+	 * tnx devices cannot be "forced" to a autoneg 10G and fail.  But can
 	 * for a 1G.
 	 */
-	ixgbe_read_phy_reg(hw,
-		  autoneg_speed_selection_register,
-		  IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-		  &autoneg_reg);
+	hw->phy.ops.read_reg(hw, IXGBE_MII_SPEED_SELECTION_REG,
+	                     IXGBE_MDIO_AUTO_NEG_DEV_TYPE, &autoneg_reg);
 
 	if (hw->phy.autoneg_advertised == IXGBE_LINK_SPEED_1GB_FULL)
 		autoneg_reg &= 0xEFFF; /* 0 in bit 12 is 1G operation */
 	else
 		autoneg_reg |= 0x1000; /* 1 in bit 12 is 10G/1G operation */
 
-	ixgbe_write_phy_reg(hw,
-		  autoneg_speed_selection_register,
-		  IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-		  autoneg_reg);
-
+	hw->phy.ops.write_reg(hw, IXGBE_MII_SPEED_SELECTION_REG,
+	                      IXGBE_MDIO_AUTO_NEG_DEV_TYPE, autoneg_reg);
 
 	/* Restart PHY autonegotiation and wait for completion */
-	ixgbe_read_phy_reg(hw,
-		  IXGBE_MDIO_AUTO_NEG_CONTROL,
-		  IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-		  &autoneg_reg);
+	hw->phy.ops.read_reg(hw, IXGBE_MDIO_AUTO_NEG_CONTROL,
+	                     IXGBE_MDIO_AUTO_NEG_DEV_TYPE, &autoneg_reg);
 
-	autoneg_reg |= autoneg_restart_mask;
+	autoneg_reg |= IXGBE_MII_RESTART;
 
-	ixgbe_write_phy_reg(hw,
-		  IXGBE_MDIO_AUTO_NEG_CONTROL,
-		  IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-		  autoneg_reg);
+	hw->phy.ops.write_reg(hw, IXGBE_MDIO_AUTO_NEG_CONTROL,
+	                      IXGBE_MDIO_AUTO_NEG_DEV_TYPE, autoneg_reg);
 
 	/* Wait for autonegotiation to finish */
 	for (time_out = 0; time_out < max_time_out; time_out++) {
 		udelay(10);
 		/* Restart PHY autonegotiation and wait for completion */
-		status = ixgbe_read_phy_reg(hw,
-					    IXGBE_MDIO_AUTO_NEG_STATUS,
-					    IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-					    &autoneg_reg);
+		status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_AUTO_NEG_STATUS,
+		                              IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
+		                              &autoneg_reg);
 
-		autoneg_reg &= autoneg_complete_mask;
-		if (autoneg_reg == autoneg_complete_mask) {
+		autoneg_reg &= IXGBE_MII_AUTONEG_COMPLETE;
+		if (autoneg_reg == IXGBE_MII_AUTONEG_COMPLETE) {
 			status = 0;
 			break;
 		}
@@ -418,64 +397,17 @@ s32 ixgbe_setup_tnx_phy_link(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_check_tnx_phy_link - Determine link and speed status
- *  @hw: pointer to hardware structure
- *
- *  Reads the VS1 register to determine if link is up and the current speed for
- *  the PHY.
- **/
-s32 ixgbe_check_tnx_phy_link(struct ixgbe_hw *hw, u32 *speed,
-			     bool *link_up)
-{
-	s32 status = 0;
-	u32 time_out;
-	u32 max_time_out = 10;
-	u16 phy_link = 0;
-	u16 phy_speed = 0;
-	u16 phy_data = 0;
-
-	/* Initialize speed and link to default case */
-	*link_up = false;
-	*speed = IXGBE_LINK_SPEED_10GB_FULL;
-
-	/*
-	 * Check current speed and link status of the PHY register.
-	 * This is a vendor specific register and may have to
-	 * be changed for other copper PHYs.
-	 */
-	for (time_out = 0; time_out < max_time_out; time_out++) {
-		udelay(10);
-		if (phy_link == IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS) {
-			*link_up = true;
-			if (phy_speed ==
-			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS)
-				*speed = IXGBE_LINK_SPEED_1GB_FULL;
-			break;
-		} else {
-			status = ixgbe_read_phy_reg(hw,
-				     IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS,
-				     IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
-				     &phy_data);
-			phy_link = phy_data &
-				IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS;
-			phy_speed = phy_data &
-				IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS;
-		}
-	}
-
-	return status;
-}
-
-/**
- *  ixgbe_setup_tnx_phy_link_speed - Sets the auto advertised capabilities
+ *  ixgbe_setup_phy_link_speed_generic - Sets the auto advertised capabilities
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
  *  @autoneg: true if autonegotiation enabled
  **/
-s32 ixgbe_setup_tnx_phy_link_speed(struct ixgbe_hw *hw, u32 speed,
-				   bool autoneg,
-				   bool autoneg_wait_to_complete)
+s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
+                                       ixgbe_link_speed speed,
+                                       bool autoneg,
+                                       bool autoneg_wait_to_complete)
 {
+
 	/*
 	 * Clear autoneg_advertised and set new values based on input link
 	 * speed.
@@ -484,11 +416,13 @@ s32 ixgbe_setup_tnx_phy_link_speed(struct ixgbe_hw *hw, u32 speed,
 
 	if (speed & IXGBE_LINK_SPEED_10GB_FULL)
 		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_10GB_FULL;
+
 	if (speed & IXGBE_LINK_SPEED_1GB_FULL)
 		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_1GB_FULL;
 
 	/* Setup link based on the new speed settings */
-	ixgbe_setup_tnx_phy_link(hw);
+	hw->phy.ops.setup_link(hw);
 
 	return 0;
 }
+
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index aa3ea72..9bfe3f2 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -30,20 +29,52 @@
 #define _IXGBE_PHY_H_
 
 #include "ixgbe_type.h"
+#define IXGBE_I2C_EEPROM_DEV_ADDR    0xA0
 
-s32 ixgbe_setup_phy_link(struct ixgbe_hw *hw);
-s32 ixgbe_check_phy_link(struct ixgbe_hw *hw, u32 *speed, bool *link_up);
-s32 ixgbe_setup_phy_link_speed(struct ixgbe_hw *hw, u32 speed, bool autoneg,
-			       bool autoneg_wait_to_complete);
-s32 ixgbe_identify_phy(struct ixgbe_hw *hw);
-s32 ixgbe_reset_phy(struct ixgbe_hw *hw);
-s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
-			       u32 device_type, u16 *phy_data);
-
-/* PHY specific */
-s32 ixgbe_setup_tnx_phy_link(struct ixgbe_hw *hw);
-s32 ixgbe_check_tnx_phy_link(struct ixgbe_hw *hw, u32 *speed, bool *link_up);
-s32 ixgbe_setup_tnx_phy_link_speed(struct ixgbe_hw *hw, u32 speed, bool autoneg,
-				  bool autoneg_wait_to_complete);
+/* EEPROM byte offsets */
+#define IXGBE_SFF_IDENTIFIER         0x0
+#define IXGBE_SFF_IDENTIFIER_SFP     0x3
+#define IXGBE_SFF_VENDOR_OUI_BYTE0   0x25
+#define IXGBE_SFF_VENDOR_OUI_BYTE1   0x26
+#define IXGBE_SFF_VENDOR_OUI_BYTE2   0x27
+#define IXGBE_SFF_1GBE_COMP_CODES    0x6
+#define IXGBE_SFF_10GBE_COMP_CODES   0x3
+#define IXGBE_SFF_TRANSMISSION_MEDIA 0x9
+
+/* Bitmasks */
+#define IXGBE_SFF_TWIN_AX_CAPABLE            0x80
+#define IXGBE_SFF_1GBASESX_CAPABLE           0x1
+#define IXGBE_SFF_10GBASESR_CAPABLE          0x10
+#define IXGBE_SFF_10GBASELR_CAPABLE          0x20
+#define IXGBE_I2C_EEPROM_READ_MASK           0x100
+#define IXGBE_I2C_EEPROM_STATUS_MASK         0x3
+#define IXGBE_I2C_EEPROM_STATUS_NO_OPERATION 0x0
+#define IXGBE_I2C_EEPROM_STATUS_PASS         0x1
+#define IXGBE_I2C_EEPROM_STATUS_FAIL         0x2
+#define IXGBE_I2C_EEPROM_STATUS_IN_PROGRESS  0x3
+
+/* Bit-shift macros */
+#define IXGBE_SFF_VENDOR_OUI_BYTE0_SHIFT    12
+#define IXGBE_SFF_VENDOR_OUI_BYTE1_SHIFT    8
+#define IXGBE_SFF_VENDOR_OUI_BYTE2_SHIFT    4
+
+/* Vendor OUIs: format of OUI is 0x[byte0][byte1][byte2][00] */
+#define IXGBE_SFF_VENDOR_OUI_TYCO     0x00407600
+#define IXGBE_SFF_VENDOR_OUI_FTL      0x00906500
+#define IXGBE_SFF_VENDOR_OUI_AVAGO    0x00176A00
+
+
+s32 ixgbe_init_phy_ops_generic(struct ixgbe_hw *hw);
+s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw);
+s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw);
+s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
+                               u32 device_type, u16 *phy_data);
+s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
+                                u32 device_type, u16 phy_data);
+s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw);
+s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
+                                       ixgbe_link_speed speed,
+                                       bool autoneg,
+                                       bool autoneg_wait_to_complete);
 
 #endif /* _IXGBE_PHY_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 3e9c483..c6f8fa1 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -37,9 +36,9 @@
 /* Device IDs */
 #define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
-#define IXGBE_DEV_ID_82598AT_DUAL_PORT   0x10C8
 #define IXGBE_DEV_ID_82598EB_CX4         0x10DD
 #define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
+#define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
 
 /* General Registers */
 #define IXGBE_CTRL      0x00000
@@ -70,11 +69,11 @@
 #define IXGBE_EIMC      0x00888
 #define IXGBE_EIAC      0x00810
 #define IXGBE_EIAM      0x00890
-#define IXGBE_EITR(_i) (0x00820 + ((_i) * 4)) /* 0x820-0x86c */
-#define IXGBE_IVAR(_i) (0x00900 + ((_i) * 4)) /* 24 at 0x900-0x960 */
+#define IXGBE_EITR(_i)  (((_i) <= 23) ? (0x00820 + ((_i) * 4)) : (0x012300 + ((_i) * 4)))
+#define IXGBE_IVAR(_i)  (0x00900 + ((_i) * 4)) /* 24 at 0x900-0x960 */
 #define IXGBE_MSIXT     0x00000 /* MSI-X Table. 0x0000 - 0x01C */
 #define IXGBE_MSIXPBA   0x02000 /* MSI-X Pending bit array */
-#define IXGBE_PBACL     0x11068
+#define IXGBE_PBACL(_i) (((_i) == 0) ? (0x11068) : (0x110C0 + ((_i) * 4)))
 #define IXGBE_GPIE      0x00898
 
 /* Flow Control Registers */
@@ -86,20 +85,33 @@
 #define IXGBE_TFCS      0x0CE00
 
 /* Receive DMA Registers */
-#define IXGBE_RDBAL(_i) (0x01000 + ((_i) * 0x40)) /* 64 of each (0-63)*/
-#define IXGBE_RDBAH(_i) (0x01004 + ((_i) * 0x40))
-#define IXGBE_RDLEN(_i) (0x01008 + ((_i) * 0x40))
-#define IXGBE_RDH(_i)   (0x01010 + ((_i) * 0x40))
-#define IXGBE_RDT(_i)   (0x01018 + ((_i) * 0x40))
-#define IXGBE_RXDCTL(_i) (0x01028 + ((_i) * 0x40))
-#define IXGBE_RSCCTL(_i) (0x0102C + ((_i) * 0x40))
-#define IXGBE_SRRCTL(_i) (0x02100 + ((_i) * 4))
-					     /* array of 16 (0x02100-0x0213C) */
-#define IXGBE_DCA_RXCTRL(_i)    (0x02200 + ((_i) * 4))
-					     /* array of 16 (0x02200-0x0223C) */
-#define IXGBE_RDRXCTL    0x02F00
+#define IXGBE_RDBAL(_i) (((_i) < 64) ? (0x01000 + ((_i) * 0x40)) : (0x0D000 + ((_i - 64) * 0x40)))
+#define IXGBE_RDBAH(_i) (((_i) < 64) ? (0x01004 + ((_i) * 0x40)) : (0x0D004 + ((_i - 64) * 0x40)))
+#define IXGBE_RDLEN(_i) (((_i) < 64) ? (0x01008 + ((_i) * 0x40)) : (0x0D008 + ((_i - 64) * 0x40)))
+#define IXGBE_RDH(_i)   (((_i) < 64) ? (0x01010 + ((_i) * 0x40)) : (0x0D010 + ((_i - 64) * 0x40)))
+#define IXGBE_RDT(_i)   (((_i) < 64) ? (0x01018 + ((_i) * 0x40)) : (0x0D018 + ((_i - 64) * 0x40)))
+#define IXGBE_RXDCTL(_i) (((_i) < 64) ? (0x01028 + ((_i) * 0x40)) : (0x0D028 + ((_i - 64) * 0x40)))
+/*
+ * Split and Replication Receive Control Registers
+ * 00-15 : 0x02100 + n*4
+ * 16-64 : 0x01014 + n*0x40
+ * 64-127: 0x0D014 + (n-64)*0x40
+ */
+#define IXGBE_SRRCTL(_i) (((_i) <= 15) ? (0x02100 + ((_i) * 4)) : \
+                          (((_i) < 64) ? (0x01014 + ((_i) * 0x40)) : \
+                          (0x0D014 + ((_i - 64) * 0x40))))
+/*
+ * Rx DCA Control Register:
+ * 00-15 : 0x02200 + n*4
+ * 16-64 : 0x0100C + n*0x40
+ * 64-127: 0x0D00C + (n-64)*0x40
+ */
+#define IXGBE_DCA_RXCTRL(_i)    (((_i) <= 15) ? (0x02200 + ((_i) * 4)) : \
+                                 (((_i) < 64) ? (0x0100C + ((_i) * 0x40)) : \
+                                 (0x0D00C + ((_i - 64) * 0x40))))
+#define IXGBE_RDRXCTL           0x02F00
 #define IXGBE_RXPBSIZE(_i)      (0x03C00 + ((_i) * 4))
-					     /* 8 of these 0x03C00 - 0x03C1C */
+                                             /* 8 of these 0x03C00 - 0x03C1C */
 #define IXGBE_RXCTRL    0x03000
 #define IXGBE_DROPEN    0x03D04
 #define IXGBE_RXPBSIZE_SHIFT 10
@@ -107,29 +119,32 @@
 /* Receive Registers */
 #define IXGBE_RXCSUM    0x05000
 #define IXGBE_RFCTL     0x05008
+#define IXGBE_DRECCCTL  0x02F08
+#define IXGBE_DRECCCTL_DISABLE 0
+/* Multicast Table Array - 128 entries */
 #define IXGBE_MTA(_i)   (0x05200 + ((_i) * 4))
-				   /* Multicast Table Array - 128 entries */
-#define IXGBE_RAL(_i)   (0x05400 + ((_i) * 8)) /* 16 of these (0-15) */
-#define IXGBE_RAH(_i)   (0x05404 + ((_i) * 8)) /* 16 of these (0-15) */
-#define IXGBE_PSRTYPE   0x05480
-				   /* 0x5480-0x54BC Packet split receive type */
+#define IXGBE_RAL(_i)   (((_i) <= 15) ? (0x05400 + ((_i) * 8)) : (0x0A200 + ((_i) * 8)))
+#define IXGBE_RAH(_i)   (((_i) <= 15) ? (0x05404 + ((_i) * 8)) : (0x0A204 + ((_i) * 8)))
+/* Packet split receive type */
+#define IXGBE_PSRTYPE(_i)    (((_i) <= 15) ? (0x05480 + ((_i) * 4)) : (0x0EA00 + ((_i) * 4)))
+/* array of 4096 1-bit vlan filters */
 #define IXGBE_VFTA(_i)  (0x0A000 + ((_i) * 4))
-					 /* array of 4096 1-bit vlan filters */
+/*array of 4096 4-bit vlan vmdq indices */
 #define IXGBE_VFTAVIND(_j, _i)  (0x0A200 + ((_j) * 0x200) + ((_i) * 4))
-				     /*array of 4096 4-bit vlan vmdq indicies */
 #define IXGBE_FCTRL     0x05080
 #define IXGBE_VLNCTRL   0x05088
 #define IXGBE_MCSTCTRL  0x05090
 #define IXGBE_MRQC      0x05818
-#define IXGBE_VMD_CTL   0x0581C
 #define IXGBE_IMIR(_i)  (0x05A80 + ((_i) * 4))  /* 8 of these (0-7) */
 #define IXGBE_IMIREXT(_i)       (0x05AA0 + ((_i) * 4))  /* 8 of these (0-7) */
 #define IXGBE_IMIRVP    0x05AC0
+#define IXGBE_VMD_CTL   0x0581C
 #define IXGBE_RETA(_i)  (0x05C00 + ((_i) * 4))  /* 32 of these (0-31) */
 #define IXGBE_RSSRK(_i) (0x05C80 + ((_i) * 4))  /* 10 of these (0-9) */
 
+
 /* Transmit DMA registers */
-#define IXGBE_TDBAL(_i) (0x06000 + ((_i) * 0x40))/* 32 of these (0-31)*/
+#define IXGBE_TDBAL(_i) (0x06000 + ((_i) * 0x40)) /* 32 of these (0-31)*/
 #define IXGBE_TDBAH(_i) (0x06004 + ((_i) * 0x40))
 #define IXGBE_TDLEN(_i) (0x06008 + ((_i) * 0x40))
 #define IXGBE_TDH(_i)   (0x06010 + ((_i) * 0x40))
@@ -138,11 +153,10 @@
 #define IXGBE_TDWBAL(_i) (0x06038 + ((_i) * 0x40))
 #define IXGBE_TDWBAH(_i) (0x0603C + ((_i) * 0x40))
 #define IXGBE_DTXCTL    0x07E00
-#define IXGBE_DCA_TXCTRL(_i)    (0x07200 + ((_i) * 4))
-					      /* there are 16 of these (0-15) */
+
+#define IXGBE_DCA_TXCTRL(_i)    (0x07200 + ((_i) * 4)) /* 16 of these (0-15) */
 #define IXGBE_TIPG      0x0CB00
-#define IXGBE_TXPBSIZE(_i)      (0x0CC00 + ((_i) *0x04))
-						      /* there are 8 of these */
+#define IXGBE_TXPBSIZE(_i)      (0x0CC00 + ((_i) * 4)) /* 8 of these */
 #define IXGBE_MNGTXMAP  0x0CD10
 #define IXGBE_TIPG_FIBER_DEFAULT 3
 #define IXGBE_TXPBSIZE_SHIFT    10
@@ -154,6 +168,7 @@
 #define IXGBE_IPAV      0x05838
 #define IXGBE_IP4AT     0x05840 /* IPv4 table 0x5840-0x5858 */
 #define IXGBE_IP6AT     0x05880 /* IPv6 table 0x5880-0x588F */
+
 #define IXGBE_WUPL      0x05900
 #define IXGBE_WUPM      0x05A00 /* wake up pkt memory 0x5A00-0x5A7C */
 #define IXGBE_FHFT      0x09000 /* Flex host filter table 9000-93FC */
@@ -170,6 +185,8 @@
 #define IXGBE_TDPT2TCCR(_i)     (0x0CD20 + ((_i) * 4)) /* 8 of these (0-7) */
 #define IXGBE_TDPT2TCSR(_i)     (0x0CD40 + ((_i) * 4)) /* 8 of these (0-7) */
 
+
+
 /* Stats registers */
 #define IXGBE_CRCERRS   0x04000
 #define IXGBE_ILLERRC   0x04004
@@ -224,7 +241,7 @@
 #define IXGBE_XEC       0x04120
 
 #define IXGBE_RQSMR(_i) (0x02300 + ((_i) * 4)) /* 16 of these */
-#define IXGBE_TQSMR(_i) (0x07300 + ((_i) * 4)) /* 8 of these */
+#define IXGBE_TQSMR(_i) (((_i) <= 7) ? (0x07300 + ((_i) * 4)) : (0x08600 + ((_i) * 4)))
 
 #define IXGBE_QPRC(_i) (0x01030 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QPTC(_i) (0x06030 + ((_i) * 0x40)) /* 16 of these */
@@ -275,23 +292,17 @@
 #define IXGBE_DCA_CTRL  0x11074
 
 /* Diagnostic Registers */
-#define IXGBE_RDSTATCTL 0x02C20
-#define IXGBE_RDSTAT(_i) (0x02C00 + ((_i) * 4)) /* 0x02C00-0x02C1C */
-#define IXGBE_RDHMPN    0x02F08
-#define IXGBE_RIC_DW0   0x02F10
-#define IXGBE_RIC_DW1   0x02F14
-#define IXGBE_RIC_DW2   0x02F18
-#define IXGBE_RIC_DW3   0x02F1C
-#define IXGBE_RDPROBE   0x02F20
-#define IXGBE_TDSTATCTL 0x07C20
-#define IXGBE_TDSTAT(_i) (0x07C00 + ((_i) * 4)) /* 0x07C00 - 0x07C1C */
-#define IXGBE_TDHMPN    0x07F08
-#define IXGBE_TIC_DW0   0x07F10
-#define IXGBE_TIC_DW1   0x07F14
-#define IXGBE_TIC_DW2   0x07F18
-#define IXGBE_TIC_DW3   0x07F1C
-#define IXGBE_TDPROBE   0x07F20
-#define IXGBE_TXBUFCTRL 0x0C600
+#define IXGBE_RDSTATCTL   0x02C20
+#define IXGBE_RDSTAT(_i)  (0x02C00 + ((_i) * 4)) /* 0x02C00-0x02C1C */
+#define IXGBE_RDHMPN      0x02F08
+#define IXGBE_RIC_DW(_i)  (0x02F10 + ((_i) * 4))
+#define IXGBE_RDPROBE     0x02F20
+#define IXGBE_TDSTATCTL   0x07C20
+#define IXGBE_TDSTAT(_i)  (0x07C00 + ((_i) * 4)) /* 0x07C00 - 0x07C1C */
+#define IXGBE_TDHMPN      0x07F08
+#define IXGBE_TIC_DW(_i)  (0x07F10 + ((_i) * 4))
+#define IXGBE_TDPROBE     0x07F20
+#define IXGBE_TXBUFCTRL   0x0C600
 #define IXGBE_TXBUFDATA0  0x0C610
 #define IXGBE_TXBUFDATA1  0x0C614
 #define IXGBE_TXBUFDATA2  0x0C618
@@ -392,7 +403,7 @@
 
 #define IXGBE_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
 #define IXGBE_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
-#define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* TX Desc writeback RO bit */
+#define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
 #define IXGBE_DCA_MAX_QUEUES_82598   16 /* DCA regs only on 16 queues */
 
 /* MSCA Bit Masks */
@@ -416,10 +427,10 @@
 #define IXGBE_MSCA_MDI_IN_PROG_EN    0x80000000 /* MDI in progress enable */
 
 /* MSRWD bit masks */
-#define IXGBE_MSRWD_WRITE_DATA_MASK  0x0000FFFF
-#define IXGBE_MSRWD_WRITE_DATA_SHIFT 0
-#define IXGBE_MSRWD_READ_DATA_MASK   0xFFFF0000
-#define IXGBE_MSRWD_READ_DATA_SHIFT  16
+#define IXGBE_MSRWD_WRITE_DATA_MASK     0x0000FFFF
+#define IXGBE_MSRWD_WRITE_DATA_SHIFT    0
+#define IXGBE_MSRWD_READ_DATA_MASK      0xFFFF0000
+#define IXGBE_MSRWD_READ_DATA_SHIFT     16
 
 /* Atlas registers */
 #define IXGBE_ATLAS_PDN_LPBK    0x24
@@ -434,6 +445,7 @@
 #define IXGBE_ATLAS_PDN_TX_1G_QL_ALL    0xF0
 #define IXGBE_ATLAS_PDN_TX_AN_QL_ALL    0xF0
 
+
 /* Device Type definitions for new protocol MDIO commands */
 #define IXGBE_MDIO_PMA_PMD_DEV_TYPE               0x1
 #define IXGBE_MDIO_PCS_DEV_TYPE                   0x3
@@ -441,6 +453,8 @@
 #define IXGBE_MDIO_AUTO_NEG_DEV_TYPE              0x7
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE     0x1E   /* Device 30 */
 
+#define IXGBE_MDIO_COMMAND_TIMEOUT     100 /* PHY Timeout for 1 GB mode */
+
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_CONTROL      0x0    /* VS1 Control Reg */
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS       0x1    /* VS1 Status Reg */
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS  0x0008 /* 1 = Link Up */
@@ -454,23 +468,39 @@
 #define IXGBE_MDIO_PHY_XS_RESET        0x8000 /* PHY_XS Reset */
 #define IXGBE_MDIO_PHY_ID_HIGH         0x2 /* PHY ID High Reg*/
 #define IXGBE_MDIO_PHY_ID_LOW          0x3 /* PHY ID Low Reg*/
-#define IXGBE_MDIO_PHY_SPEED_ABILITY   0x4 /* Speed Abilty Reg */
+#define IXGBE_MDIO_PHY_SPEED_ABILITY   0x4 /* Speed Ability Reg */
 #define IXGBE_MDIO_PHY_SPEED_10G       0x0001 /* 10G capable */
 #define IXGBE_MDIO_PHY_SPEED_1G        0x0010 /* 1G capable */
 
+#define IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR     0xC30A /* PHY_XS SDA/SCL Address Reg */
+#define IXGBE_MDIO_PMA_PMD_SDA_SCL_DATA     0xC30B /* PHY_XS SDA/SCL Data Reg */
+#define IXGBE_MDIO_PMA_PMD_SDA_SCL_STAT     0xC30C /* PHY_XS SDA/SCL Status Reg */
+
+/* MII clause 22/28 definitions */
+#define IXGBE_MDIO_PHY_LOW_POWER_MODE  0x0800
+
+#define IXGBE_MII_SPEED_SELECTION_REG  0x10
+#define IXGBE_MII_RESTART              0x200
+#define IXGBE_MII_AUTONEG_COMPLETE     0x20
+#define IXGBE_MII_AUTONEG_REG          0x0
+
 #define IXGBE_PHY_REVISION_MASK        0xFFFFFFF0
 #define IXGBE_MAX_PHY_ADDR             32
 
 /* PHY IDs*/
-#define TN1010_PHY_ID    0x00A19410
 #define QT2022_PHY_ID    0x0043A400
 
+/* PHY Types */
+#define IXGBE_M88E1145_E_PHY_ID  0x01410CD0
+
 /* General purpose Interrupt Enable */
-#define IXGBE_GPIE_MSIX_MODE      0x00000010 /* MSI-X mode */
-#define IXGBE_GPIE_OCD            0x00000020 /* Other Clear Disable */
-#define IXGBE_GPIE_EIMEN          0x00000040 /* Immediate Interrupt Enable */
-#define IXGBE_GPIE_EIAME          0x40000000
-#define IXGBE_GPIE_PBA_SUPPORT    0x80000000
+#define IXGBE_SDP0_GPIEN         0x00000001 /* SDP0 */
+#define IXGBE_SDP1_GPIEN         0x00000002 /* SDP1 */
+#define IXGBE_GPIE_MSIX_MODE     0x00000010 /* MSI-X mode */
+#define IXGBE_GPIE_OCD           0x00000020 /* Other Clear Disable */
+#define IXGBE_GPIE_EIMEN         0x00000040 /* Immediate Interrupt Enable */
+#define IXGBE_GPIE_EIAME         0x40000000
+#define IXGBE_GPIE_PBA_SUPPORT   0x80000000
 
 /* Transmit Flow Control status */
 #define IXGBE_TFCS_TXOFF         0x00000001
@@ -531,7 +561,7 @@
 #define IXGBE_PAP_TXPAUSECNT_MASK   0x0000FFFF /* Pause counter mask */
 
 /* RMCS Bit Masks */
-#define IXGBE_RMCS_RRM          0x00000002 /* Receive Recylce Mode enable */
+#define IXGBE_RMCS_RRM          0x00000002 /* Receive Recycle Mode enable */
 /* Receive Arbitration Control: 0 Round Robin, 1 DFP */
 #define IXGBE_RMCS_RAC          0x00000004
 #define IXGBE_RMCS_DFP          IXGBE_RMCS_RAC /* Deficit Fixed Priority ena */
@@ -539,12 +569,15 @@
 #define IXGBE_RMCS_TFCE_PRIORITY 0x00000010 /* Tx Priority flow control ena */
 #define IXGBE_RMCS_ARBDIS       0x00000040 /* Arbitration disable bit */
 
+
 /* Interrupt register bitmasks */
 
 /* Extended Interrupt Cause Read */
 #define IXGBE_EICR_RTX_QUEUE    0x0000FFFF /* RTx Queue Interrupt */
 #define IXGBE_EICR_LSC          0x00100000 /* Link Status Change */
-#define IXGBE_EICR_MNG          0x00400000 /* Managability Event Interrupt */
+#define IXGBE_EICR_MNG          0x00400000 /* Manageability Event Interrupt */
+#define IXGBE_EICR_GPI_SDP0     0x01000000 /* Gen Purpose Interrupt on SDP0 */
+#define IXGBE_EICR_GPI_SDP1     0x02000000 /* Gen Purpose Interrupt on SDP1 */
 #define IXGBE_EICR_PBUR         0x10000000 /* Packet Buffer Handler Error */
 #define IXGBE_EICR_DHER         0x20000000 /* Descriptor Handler Error */
 #define IXGBE_EICR_TCP_TIMER    0x40000000 /* TCP Timer */
@@ -552,11 +585,12 @@
 
 /* Extended Interrupt Cause Set */
 #define IXGBE_EICS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
-#define IXGBE_EICS_LSC          IXGBE_EICR_LSC /* Link Status Change */
-#define IXGBE_EICR_GPI_SDP0     0x01000000 /* Gen Purpose Interrupt on SDP0 */
-#define IXGBE_EICS_MNG          IXGBE_EICR_MNG /* MNG Event Interrupt */
-#define IXGBE_EICS_PBUR         IXGBE_EICR_PBUR /* Pkt Buf Handler Error */
-#define IXGBE_EICS_DHER         IXGBE_EICR_DHER /* Desc Handler Error */
+#define IXGBE_EICS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
+#define IXGBE_EICS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
+#define IXGBE_EICS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
+#define IXGBE_EICS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EICS_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
+#define IXGBE_EICS_DHER         IXGBE_EICR_DHER      /* Desc Handler Error */
 #define IXGBE_EICS_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
 #define IXGBE_EICS_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
 
@@ -564,7 +598,9 @@
 #define IXGBE_EIMS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
 #define IXGBE_EIMS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
-#define IXGBE_EIMS_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Error */
+#define IXGBE_EIMS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
+#define IXGBE_EIMS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EIMS_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
 #define IXGBE_EIMS_DHER         IXGBE_EICR_DHER      /* Descr Handler Error */
 #define IXGBE_EIMS_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
 #define IXGBE_EIMS_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
@@ -573,18 +609,20 @@
 #define IXGBE_EIMC_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
 #define IXGBE_EIMC_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMC_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
-#define IXGBE_EIMC_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Error */
-#define IXGBE_EIMC_DHER         IXGBE_EICR_DHER      /* Desc Handler Error */
+#define IXGBE_EIMC_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
+#define IXGBE_EIMC_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EIMC_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
+#define IXGBE_EIMC_DHER         IXGBE_EICR_DHER      /* Desc Handler Err */
 #define IXGBE_EIMC_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
 #define IXGBE_EIMC_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
 
-#define IXGBE_EIMS_ENABLE_MASK (\
-				IXGBE_EIMS_RTX_QUEUE       | \
-				IXGBE_EIMS_LSC             | \
-				IXGBE_EIMS_TCP_TIMER       | \
-				IXGBE_EIMS_OTHER)
+#define IXGBE_EIMS_ENABLE_MASK ( \
+                                IXGBE_EIMS_RTX_QUEUE       | \
+                                IXGBE_EIMS_LSC             | \
+                                IXGBE_EIMS_TCP_TIMER       | \
+                                IXGBE_EIMS_OTHER)
 
-/* Immediate Interrupt RX (A.K.A. Low Latency Interrupt) */
+/* Immediate Interrupt Rx (A.K.A. Low Latency Interrupt) */
 #define IXGBE_IMIR_PORT_IM_EN     0x00010000  /* TCP port enable */
 #define IXGBE_IMIR_PORT_BP        0x00020000  /* TCP port check bypass */
 #define IXGBE_IMIREXT_SIZE_BP     0x00001000  /* Packet size bypass */
@@ -621,6 +659,7 @@
 #define IXGBE_VLNCTRL_VFE       0x40000000  /* bit 30 */
 #define IXGBE_VLNCTRL_VME       0x80000000  /* bit 31 */
 
+
 #define IXGBE_ETHERNET_IEEE_VLAN_TYPE 0x8100  /* 802.1q protocol */
 
 /* STATUS Bit Masks */
@@ -668,16 +707,16 @@
 #define IXGBE_AUTOC_AN_RESTART  0x00001000
 #define IXGBE_AUTOC_FLU         0x00000001
 #define IXGBE_AUTOC_LMS_SHIFT   13
-#define IXGBE_AUTOC_LMS_MASK   (0x7 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_1G_LINK_NO_AN  (0x0 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_10G_LINK_NO_AN (0x1 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_1G_AN  (0x2 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_KX4_AN (0x4 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_KX4_AN_1G_AN   (0x6 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_ATTACH_TYPE    (0x7 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
-
-#define IXGBE_AUTOC_1G_PMA_PMD      0x00000200
-#define IXGBE_AUTOC_10G_PMA_PMD     0x00000180
+#define IXGBE_AUTOC_LMS_MASK            (0x7 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_1G_LINK_NO_AN   (0x0 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_10G_LINK_NO_AN  (0x1 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_1G_AN           (0x2 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_AN          (0x4 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_AN_1G_AN    (0x6 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_ATTACH_TYPE     (0x7 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
+
+#define IXGBE_AUTOC_1G_PMA_PMD         0x00000200
+#define IXGBE_AUTOC_10G_PMA_PMD        0x00000180
 #define IXGBE_AUTOC_10G_PMA_PMD_SHIFT 7
 #define IXGBE_AUTOC_1G_PMA_PMD_SHIFT 9
 #define IXGBE_AUTOC_10G_XAUI   (0x0 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
@@ -703,6 +742,7 @@
 #define IXGBE_LINKS_TL_FAULT    0x00001000
 #define IXGBE_LINKS_SIGNAL      0x00000F00
 
+#define IXGBE_LINK_UP_TIME      90 /* 9.0 Seconds */
 #define IXGBE_AUTO_NEG_TIME     45 /* 4.5 Seconds */
 
 /* SW Semaphore Register bitmasks */
@@ -757,6 +797,11 @@
 #define IXGBE_PBANUM0_PTR       0x15
 #define IXGBE_PBANUM1_PTR       0x16
 
+/* Legacy EEPROM word offsets */
+#define IXGBE_ISCSI_BOOT_CAPS           0x0033
+#define IXGBE_ISCSI_SETUP_PORT_0        0x0030
+#define IXGBE_ISCSI_SETUP_PORT_1        0x0034
+
 /* EEPROM Commands - SPI */
 #define IXGBE_EEPROM_MAX_RETRY_SPI      5000 /* Max wait 5ms for RDY signal */
 #define IXGBE_EEPROM_STATUS_RDY_SPI     0x01
@@ -764,7 +809,7 @@
 #define IXGBE_EEPROM_WRITE_OPCODE_SPI   0x02  /* EEPROM write opcode */
 #define IXGBE_EEPROM_A8_OPCODE_SPI      0x08  /* opcode bit-3 = addr bit-8 */
 #define IXGBE_EEPROM_WREN_OPCODE_SPI    0x06  /* EEPROM set Write Ena latch */
-/* EEPROM reset Write Enbale latch */
+/* EEPROM reset Write Enable latch */
 #define IXGBE_EEPROM_WRDI_OPCODE_SPI    0x04
 #define IXGBE_EEPROM_RDSR_OPCODE_SPI    0x05  /* EEPROM read Status reg */
 #define IXGBE_EEPROM_WRSR_OPCODE_SPI    0x01  /* EEPROM write Status reg */
@@ -803,22 +848,20 @@
 /* Number of 100 microseconds we wait for PCI Express master disable */
 #define IXGBE_PCI_MASTER_DISABLE_TIMEOUT 800
 
-/* PHY Types */
-#define IXGBE_M88E1145_E_PHY_ID  0x01410CD0
-
 /* Check whether address is multicast.  This is little-endian specific check.*/
 #define IXGBE_IS_MULTICAST(Address) \
-		(bool)(((u8 *)(Address))[0] & ((u8)0x01))
+                (bool)(((u8 *)(Address))[0] & ((u8)0x01))
 
 /* Check whether an address is broadcast. */
 #define IXGBE_IS_BROADCAST(Address)                      \
-		((((u8 *)(Address))[0] == ((u8)0xff)) && \
-		(((u8 *)(Address))[1] == ((u8)0xff)))
+                ((((u8 *)(Address))[0] == ((u8)0xff)) && \
+                (((u8 *)(Address))[1] == ((u8)0xff)))
 
 /* RAH */
 #define IXGBE_RAH_VIND_MASK     0x003C0000
 #define IXGBE_RAH_VIND_SHIFT    18
 #define IXGBE_RAH_AV            0x80000000
+#define IXGBE_CLEAR_VMDQ_ALL    0xFFFFFFFF
 
 /* Header split receive */
 #define IXGBE_RFCTL_ISCSI_DIS       0x00000001
@@ -847,7 +890,7 @@
 #define IXGBE_MAX_FRAME_SZ      0x40040000
 
 #define IXGBE_TDWBAL_HEAD_WB_ENABLE   0x1      /* Tx head write-back enable */
-#define IXGBE_TDWBAL_SEQNUM_WB_ENABLE 0x2      /* Tx seq. # write-back enable */
+#define IXGBE_TDWBAL_SEQNUM_WB_ENABLE 0x2      /* Tx seq# write-back enable */
 
 /* Receive Config masks */
 #define IXGBE_RXCTRL_RXEN       0x00000001  /* Enable Receiver */
@@ -860,7 +903,7 @@
 #define IXGBE_FCTRL_BAM 0x00000400 /* Broadcast Accept Mode */
 #define IXGBE_FCTRL_PMCF 0x00001000 /* Pass MAC Control Frames */
 #define IXGBE_FCTRL_DPF 0x00002000 /* Discard Pause Frame */
-/* Receive Priority Flow Control Enbale */
+/* Receive Priority Flow Control Enable */
 #define IXGBE_FCTRL_RPFCE 0x00004000
 #define IXGBE_FCTRL_RFCE 0x00008000 /* Receive Flow Control Ena */
 
@@ -890,9 +933,8 @@
 /* Receive Descriptor bit definitions */
 #define IXGBE_RXD_STAT_DD       0x01    /* Descriptor Done */
 #define IXGBE_RXD_STAT_EOP      0x02    /* End of Packet */
-#define IXGBE_RXD_STAT_IXSM     0x04    /* Ignore checksum */
 #define IXGBE_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
-#define IXGBE_RXD_STAT_UDPCS    0x10    /* UDP xsum caculated */
+#define IXGBE_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define IXGBE_RXD_STAT_L4CS     0x20    /* L4 xsum calculated */
 #define IXGBE_RXD_STAT_IPCS     0x40    /* IP xsum calculated */
 #define IXGBE_RXD_STAT_PIF      0x80    /* passed in-exact filter */
@@ -908,7 +950,7 @@
 #define IXGBE_RXD_ERR_USE       0x20    /* Undersize Error */
 #define IXGBE_RXD_ERR_TCPE      0x40    /* TCP/UDP Checksum Error */
 #define IXGBE_RXD_ERR_IPE       0x80    /* IP Checksum Error */
-#define IXGBE_RXDADV_HBO        0x00800000
+#define IXGBE_RXDADV_ERR_HBO    0x00800000 /*Header Buffer Overflow */
 #define IXGBE_RXDADV_ERR_CE     0x01000000 /* CRC Error */
 #define IXGBE_RXDADV_ERR_LE     0x02000000 /* Length Error */
 #define IXGBE_RXDADV_ERR_PE     0x08000000 /* Packet Error */
@@ -922,15 +964,17 @@
 #define IXGBE_RXD_CFI_MASK      0x1000  /* CFI is bit 12 */
 #define IXGBE_RXD_CFI_SHIFT     12
 
+
 /* SRRCTL bit definitions */
-#define IXGBE_SRRCTL_BSIZEPKT_SHIFT 10     /* so many KBs */
-#define IXGBE_SRRCTL_BSIZEPKT_MASK  0x0000007F
-#define IXGBE_SRRCTL_BSIZEHDR_MASK  0x00003F00
-#define IXGBE_SRRCTL_DESCTYPE_LEGACY 0x00000000
+#define IXGBE_SRRCTL_BSIZEPKT_SHIFT     10     /* so many KBs */
+#define IXGBE_SRRCTL_BSIZEPKT_MASK      0x0000007F
+#define IXGBE_SRRCTL_BSIZEHDR_MASK      0x00003F00
+#define IXGBE_SRRCTL_DESCTYPE_LEGACY    0x00000000
 #define IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF 0x02000000
 #define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT  0x04000000
 #define IXGBE_SRRCTL_DESCTYPE_HDR_REPLICATION_LARGE_PKT 0x08000000
 #define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS 0x0A000000
+#define IXGBE_SRRCTL_DESCTYPE_MASK      0x0E000000
 
 #define IXGBE_RXDPS_HDRSTAT_HDRSP       0x00008000
 #define IXGBE_RXDPS_HDRSTAT_HDRLEN_MASK 0x000003FF
@@ -964,21 +1008,20 @@
 #define IXGBE_RXDADV_PKTTYPE_UDP        0x00000200 /* UDP hdr present */
 #define IXGBE_RXDADV_PKTTYPE_SCTP       0x00000400 /* SCTP hdr present */
 #define IXGBE_RXDADV_PKTTYPE_NFS        0x00000800 /* NFS hdr present */
-
 /* Masks to determine if packets should be dropped due to frame errors */
-#define IXGBE_RXD_ERR_FRAME_ERR_MASK (\
-				      IXGBE_RXD_ERR_CE | \
-				      IXGBE_RXD_ERR_LE | \
-				      IXGBE_RXD_ERR_PE | \
-				      IXGBE_RXD_ERR_OSE | \
-				      IXGBE_RXD_ERR_USE)
-
-#define IXGBE_RXDADV_ERR_FRAME_ERR_MASK (\
-				      IXGBE_RXDADV_ERR_CE | \
-				      IXGBE_RXDADV_ERR_LE | \
-				      IXGBE_RXDADV_ERR_PE | \
-				      IXGBE_RXDADV_ERR_OSE | \
-				      IXGBE_RXDADV_ERR_USE)
+#define IXGBE_RXD_ERR_FRAME_ERR_MASK ( \
+                                      IXGBE_RXD_ERR_CE | \
+                                      IXGBE_RXD_ERR_LE | \
+                                      IXGBE_RXD_ERR_PE | \
+                                      IXGBE_RXD_ERR_OSE | \
+                                      IXGBE_RXD_ERR_USE)
+
+#define IXGBE_RXDADV_ERR_FRAME_ERR_MASK ( \
+                                      IXGBE_RXDADV_ERR_CE | \
+                                      IXGBE_RXDADV_ERR_LE | \
+                                      IXGBE_RXDADV_ERR_PE | \
+                                      IXGBE_RXDADV_ERR_OSE | \
+                                      IXGBE_RXDADV_ERR_USE)
 
 /* Multicast bit mask */
 #define IXGBE_MCSTCTRL_MFE      0x4
@@ -994,6 +1037,7 @@
 #define IXGBE_RX_DESC_SPECIAL_PRI_SHIFT  0x000D /* Priority in upper 3 of 16 */
 #define IXGBE_TX_DESC_SPECIAL_PRI_SHIFT  IXGBE_RX_DESC_SPECIAL_PRI_SHIFT
 
+
 /* Transmit Descriptor - Legacy */
 struct ixgbe_legacy_tx_desc {
 	u64 buffer_addr;       /* Address of the descriptor's data buffer */
@@ -1008,8 +1052,8 @@ struct ixgbe_legacy_tx_desc {
 	union {
 		__le32 data;
 		struct {
-			u8 status;     /* Descriptor status */
-			u8 css;        /* Checksum start */
+			u8 status;        /* Descriptor status */
+			u8 css;           /* Checksum start */
 			__le16 vlan;
 		} fields;
 	} upper;
@@ -1018,7 +1062,7 @@ struct ixgbe_legacy_tx_desc {
 /* Transmit Descriptor - Advanced */
 union ixgbe_adv_tx_desc {
 	struct {
-		__le64 buffer_addr;       /* Address of descriptor's data buf */
+		__le64 buffer_addr;      /* Address of descriptor's data buf */
 		__le32 cmd_type_len;
 		__le32 olinfo_status;
 	} read;
@@ -1050,8 +1094,8 @@ union ixgbe_adv_rx_desc {
 			union {
 				__le32 data;
 				struct {
-					__le16 pkt_info; /* RSS type, Packet type */
-					__le16 hdr_info; /* Split Header, header len */
+					__le16 pkt_info; /* RSS, Pkt type */
+					__le16 hdr_info; /* Splithdr, hdrlen */
 				} hs_rss;
 			} lo_dword;
 			union {
@@ -1079,49 +1123,69 @@ struct ixgbe_adv_tx_context_desc {
 };
 
 /* Adv Transmit Descriptor Config Masks */
-#define IXGBE_ADVTXD_DTALEN_MASK      0x0000FFFF /* Data buffer length(bytes) */
+#define IXGBE_ADVTXD_DTALEN_MASK      0x0000FFFF /* Data buf length(bytes) */
 #define IXGBE_ADVTXD_DTYP_MASK  0x00F00000 /* DTYP mask */
 #define IXGBE_ADVTXD_DTYP_CTXT  0x00200000 /* Advanced Context Desc */
 #define IXGBE_ADVTXD_DTYP_DATA  0x00300000 /* Advanced Data Descriptor */
 #define IXGBE_ADVTXD_DCMD_EOP   IXGBE_TXD_CMD_EOP  /* End of Packet */
 #define IXGBE_ADVTXD_DCMD_IFCS  IXGBE_TXD_CMD_IFCS /* Insert FCS */
-#define IXGBE_ADVTXD_DCMD_RDMA  0x04000000 /* RDMA */
 #define IXGBE_ADVTXD_DCMD_RS    IXGBE_TXD_CMD_RS   /* Report Status */
-#define IXGBE_ADVTXD_DCMD_DDTYP_ISCSI 0x10000000     /* DDP hdr type or iSCSI */
+#define IXGBE_ADVTXD_DCMD_DDTYP_ISCSI 0x10000000    /* DDP hdr type or iSCSI */
 #define IXGBE_ADVTXD_DCMD_DEXT  IXGBE_TXD_CMD_DEXT /* Desc ext (1=Adv) */
 #define IXGBE_ADVTXD_DCMD_VLE   IXGBE_TXD_CMD_VLE  /* VLAN pkt enable */
 #define IXGBE_ADVTXD_DCMD_TSE   0x80000000 /* TCP Seg enable */
 #define IXGBE_ADVTXD_STAT_DD    IXGBE_TXD_STAT_DD  /* Descriptor Done */
-#define IXGBE_ADVTXD_STAT_SN_CRC      0x00000002 /* NXTSEQ/SEED present in WB */
+#define IXGBE_ADVTXD_STAT_SN_CRC      0x00000002 /* NXTSEQ/SEED pres in WB */
 #define IXGBE_ADVTXD_STAT_RSV   0x0000000C /* STA Reserved */
 #define IXGBE_ADVTXD_IDX_SHIFT  4 /* Adv desc Index shift */
+#define IXGBE_ADVTXD_CC         0x00000080 /* Check Context */
 #define IXGBE_ADVTXD_POPTS_SHIFT      8  /* Adv desc POPTS shift */
 #define IXGBE_ADVTXD_POPTS_IXSM (IXGBE_TXD_POPTS_IXSM << \
-				IXGBE_ADVTXD_POPTS_SHIFT)
+                                 IXGBE_ADVTXD_POPTS_SHIFT)
 #define IXGBE_ADVTXD_POPTS_TXSM (IXGBE_TXD_POPTS_TXSM << \
-				IXGBE_ADVTXD_POPTS_SHIFT)
-#define IXGBE_ADVTXD_POPTS_EOM  0x00000400 /* Enable L bit-RDMA DDP hdr */
-#define IXGBE_ADVTXD_POPTS_ISCO_1ST   0x00000000 /* 1st TSO of iSCSI PDU */
-#define IXGBE_ADVTXD_POPTS_ISCO_MDL   0x00000800 /* Middle TSO of iSCSI PDU */
-#define IXGBE_ADVTXD_POPTS_ISCO_LAST  0x00001000 /* Last TSO of iSCSI PDU */
-#define IXGBE_ADVTXD_POPTS_ISCO_FULL 0x00001800 /* 1st&Last TSO-full iSCSI PDU*/
-#define IXGBE_ADVTXD_POPTS_RSV  0x00002000 /* POPTS Reserved */
-#define IXGBE_ADVTXD_PAYLEN_SHIFT  14 /* Adv desc PAYLEN shift */
-#define IXGBE_ADVTXD_MACLEN_SHIFT  9  /* Adv ctxt desc mac len shift */
-#define IXGBE_ADVTXD_VLAN_SHIFT    16  /* Adv ctxt vlan tag shift */
-#define IXGBE_ADVTXD_TUCMD_IPV4    0x00000400  /* IP Packet Type: 1=IPv4 */
-#define IXGBE_ADVTXD_TUCMD_IPV6    0x00000000  /* IP Packet Type: 0=IPv6 */
-#define IXGBE_ADVTXD_TUCMD_L4T_UDP 0x00000000  /* L4 Packet TYPE of UDP */
-#define IXGBE_ADVTXD_TUCMD_L4T_TCP 0x00000800  /* L4 Packet TYPE of TCP */
-#define IXGBE_ADVTXD_TUCMD_MKRREQ  0x00002000 /* Req requires Markers and CRC */
-#define IXGBE_ADVTXD_L4LEN_SHIFT   8  /* Adv ctxt L4LEN shift */
-#define IXGBE_ADVTXD_MSS_SHIFT     16  /* Adv ctxt MSS shift */
-
+                                 IXGBE_ADVTXD_POPTS_SHIFT)
+#define IXGBE_ADVTXD_POPTS_ISCO_1ST  0x00000000 /* 1st TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_MDL  0x00000800 /* Middle TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_LAST 0x00001000 /* Last TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_FULL 0x00001800 /* 1st&Last TSO-full iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_RSV       0x00002000 /* POPTS Reserved */
+#define IXGBE_ADVTXD_PAYLEN_SHIFT    14 /* Adv desc PAYLEN shift */
+#define IXGBE_ADVTXD_MACLEN_SHIFT    9  /* Adv ctxt desc mac len shift */
+#define IXGBE_ADVTXD_VLAN_SHIFT      16  /* Adv ctxt vlan tag shift */
+#define IXGBE_ADVTXD_TUCMD_IPV4      0x00000400  /* IP Packet Type: 1=IPv4 */
+#define IXGBE_ADVTXD_TUCMD_IPV6      0x00000000  /* IP Packet Type: 0=IPv6 */
+#define IXGBE_ADVTXD_TUCMD_L4T_UDP   0x00000000  /* L4 Packet TYPE of UDP */
+#define IXGBE_ADVTXD_TUCMD_L4T_TCP   0x00000800  /* L4 Packet TYPE of TCP */
+#define IXGBE_ADVTXD_TUCMD_L4T_SCTP  0x00001000  /* L4 Packet TYPE of SCTP */
+#define IXGBE_ADVTXD_TUCMD_MKRREQ    0x00002000 /*Req requires Markers and CRC*/
+#define IXGBE_ADVTXD_L4LEN_SHIFT     8  /* Adv ctxt L4LEN shift */
+#define IXGBE_ADVTXD_MSS_SHIFT       16  /* Adv ctxt MSS shift */
+
+/* Autonegotiation advertised speeds */
+typedef u32 ixgbe_autoneg_advertised;
 /* Link speed */
+typedef u32 ixgbe_link_speed;
 #define IXGBE_LINK_SPEED_UNKNOWN   0
 #define IXGBE_LINK_SPEED_100_FULL  0x0008
 #define IXGBE_LINK_SPEED_1GB_FULL  0x0020
 #define IXGBE_LINK_SPEED_10GB_FULL 0x0080
+#define IXGBE_LINK_SPEED_82598_AUTONEG (IXGBE_LINK_SPEED_1GB_FULL | \
+                                        IXGBE_LINK_SPEED_10GB_FULL)
+
+/* Physical layer type */
+typedef u32 ixgbe_physical_layer;
+#define IXGBE_PHYSICAL_LAYER_UNKNOWN      0
+#define IXGBE_PHYSICAL_LAYER_10GBASE_T    0x0001
+#define IXGBE_PHYSICAL_LAYER_1000BASE_T   0x0002
+#define IXGBE_PHYSICAL_LAYER_100BASE_T    0x0004
+#define IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU  0x0008
+#define IXGBE_PHYSICAL_LAYER_10GBASE_LR   0x0010
+#define IXGBE_PHYSICAL_LAYER_10GBASE_LRM  0x0020
+#define IXGBE_PHYSICAL_LAYER_10GBASE_SR   0x0040
+#define IXGBE_PHYSICAL_LAYER_10GBASE_KX4  0x0080
+#define IXGBE_PHYSICAL_LAYER_10GBASE_CX4  0x0100
+#define IXGBE_PHYSICAL_LAYER_1000BASE_KX  0x0200
+#define IXGBE_PHYSICAL_LAYER_1000BASE_BX  0x0400
 
 
 enum ixgbe_eeprom_type {
@@ -1138,16 +1202,38 @@ enum ixgbe_mac_type {
 
 enum ixgbe_phy_type {
 	ixgbe_phy_unknown = 0,
-	ixgbe_phy_tn,
 	ixgbe_phy_qt,
-	ixgbe_phy_xaui
+	ixgbe_phy_xaui,
+	ixgbe_phy_tw_tyco,
+	ixgbe_phy_tw_unknown,
+	ixgbe_phy_sfp_avago,
+	ixgbe_phy_sfp_ftl,
+	ixgbe_phy_sfp_unknown,
+	ixgbe_phy_generic
+};
+
+/*
+ * SFP+ module type IDs:
+ *
+ * ID	Module Type
+ * =============
+ * 0	SFP_DA_CU
+ * 1	SFP_SR
+ * 2	SFP_LR
+ */
+enum ixgbe_sfp_type {
+	ixgbe_sfp_type_da_cu = 0,
+	ixgbe_sfp_type_sr = 1,
+	ixgbe_sfp_type_lr = 2,
+	ixgbe_sfp_type_unknown = 0xFFFF
 };
 
 enum ixgbe_media_type {
 	ixgbe_media_type_unknown = 0,
 	ixgbe_media_type_fiber,
 	ixgbe_media_type_copper,
-	ixgbe_media_type_backplane
+	ixgbe_media_type_backplane,
+	ixgbe_media_type_virtual
 };
 
 /* Flow Control Settings */
@@ -1245,59 +1331,114 @@ struct ixgbe_hw;
 typedef u8* (*ixgbe_mc_addr_itr) (struct ixgbe_hw *hw, u8 **mc_addr_ptr,
                                   u32 *vmdq);
 
+/* Function pointer table */
+struct ixgbe_eeprom_operations {
+	s32 (*init_params)(struct ixgbe_hw *);
+	s32 (*read)(struct ixgbe_hw *, u16, u16 *);
+	s32 (*write)(struct ixgbe_hw *, u16, u16);
+	s32 (*validate_checksum)(struct ixgbe_hw *, u16 *);
+	s32 (*update_checksum)(struct ixgbe_hw *);
+};
+
 struct ixgbe_mac_operations {
-	s32 (*reset)(struct ixgbe_hw *);
+	s32 (*init_hw)(struct ixgbe_hw *);
+	s32 (*reset_hw)(struct ixgbe_hw *);
+	s32 (*start_hw)(struct ixgbe_hw *);
+	s32 (*clear_hw_cntrs)(struct ixgbe_hw *);
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
+	s32 (*get_supported_physical_layer)(struct ixgbe_hw *);
+	s32 (*get_mac_addr)(struct ixgbe_hw *, u8 *);
+	s32 (*stop_adapter)(struct ixgbe_hw *);
+	s32 (*get_bus_info)(struct ixgbe_hw *);
+	s32 (*read_analog_reg8)(struct ixgbe_hw*, u32, u8*);
+	s32 (*write_analog_reg8)(struct ixgbe_hw*, u32, u8);
+
+	/* Link */
 	s32 (*setup_link)(struct ixgbe_hw *);
-	s32 (*check_link)(struct ixgbe_hw *, u32 *, bool *);
-	s32 (*setup_link_speed)(struct ixgbe_hw *, u32, bool, bool);
-	s32 (*get_link_settings)(struct ixgbe_hw *, u32 *, bool *);
+	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool,
+	                        bool);
+	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *, bool);
+	s32 (*get_link_capabilities)(struct ixgbe_hw *, ixgbe_link_speed *,
+	                             bool *);
+
+	/* LED */
+	s32 (*led_on)(struct ixgbe_hw *, u32);
+	s32 (*led_off)(struct ixgbe_hw *, u32);
+	s32 (*blink_led_start)(struct ixgbe_hw *, u32);
+	s32 (*blink_led_stop)(struct ixgbe_hw *, u32);
+
+	/* RAR, Multicast, VLAN */
+	s32 (*set_rar)(struct ixgbe_hw *, u32, u8 *, u32, u32);
+	s32 (*clear_rar)(struct ixgbe_hw *, u32);
+	s32 (*set_vmdq)(struct ixgbe_hw *, u32, u32);
+	s32 (*clear_vmdq)(struct ixgbe_hw *, u32, u32);
+	s32 (*init_rx_addrs)(struct ixgbe_hw *);
+	s32 (*update_uc_addr_list)(struct ixgbe_hw *, u8 *, u32,
+	                           ixgbe_mc_addr_itr);
+	s32 (*update_mc_addr_list)(struct ixgbe_hw *, u8 *, u32,
+	                           ixgbe_mc_addr_itr);
+	s32 (*enable_mc)(struct ixgbe_hw *);
+	s32 (*disable_mc)(struct ixgbe_hw *);
+	s32 (*clear_vfta)(struct ixgbe_hw *);
+	s32 (*set_vfta)(struct ixgbe_hw *, u32, u32, bool);
+	s32 (*init_uta_tables)(struct ixgbe_hw *);
+
+	/* Flow Control */
+	s32 (*setup_fc)(struct ixgbe_hw *, s32);
 };
 
 struct ixgbe_phy_operations {
+	s32 (*identify)(struct ixgbe_hw *);
+	s32 (*identify_sfp)(struct ixgbe_hw *);
+	s32 (*reset)(struct ixgbe_hw *);
+	s32 (*read_reg)(struct ixgbe_hw *, u32, u32, u16 *);
+	s32 (*write_reg)(struct ixgbe_hw *, u32, u32, u16);
 	s32 (*setup_link)(struct ixgbe_hw *);
-	s32 (*check_link)(struct ixgbe_hw *, u32 *, bool *);
-	s32 (*setup_link_speed)(struct ixgbe_hw *, u32, bool, bool);
-};
-
-struct ixgbe_mac_info {
-	struct ixgbe_mac_operations	ops;
-	enum ixgbe_mac_type		type;
-	u8				addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
-	u8				perm_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
-	s32				mc_filter_type;
-	u32				mcft_size;
-	u32				vft_size;
-	u32				num_rar_entries;
-	u32				num_rx_queues;
-	u32				num_tx_queues;
-	u32				link_attach_type;
-	u32				link_mode_select;
-	bool				link_settings_loaded;
+	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool,
+	                        bool);
+	s32 (*read_i2c_byte)(struct ixgbe_hw *, u8, u8, u8 *);
+	s32 (*write_i2c_byte)(struct ixgbe_hw *, u8, u8, u8);
+	s32 (*read_i2c_eeprom)(struct ixgbe_hw *, u8 , u8 *);
+	s32 (*write_i2c_eeprom)(struct ixgbe_hw *, u8, u8);
 };
 
 struct ixgbe_eeprom_info {
-	enum ixgbe_eeprom_type		type;
-	u16				word_size;
-	u16				address_bits;
+	struct ixgbe_eeprom_operations  ops;
+	enum ixgbe_eeprom_type          type;
+	u32				semaphore_delay;
+	u16                             word_size;
+	u16                             address_bits;
 };
 
-struct ixgbe_phy_info {
-	struct ixgbe_phy_operations	ops;
-
-	enum ixgbe_phy_type		type;
-	u32				addr;
-	u32				id;
-	u32				revision;
-	enum ixgbe_media_type		media_type;
-	u32				autoneg_advertised;
-	bool				autoneg_wait_to_complete;
+struct ixgbe_mac_info {
+	struct ixgbe_mac_operations     ops;
+	enum ixgbe_mac_type             type;
+	u8                              addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
+	u8                              perm_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
+	s32                             mc_filter_type;
+	u32                             mcft_size;
+	u32                             vft_size;
+	u32                             num_rar_entries;
+	u32                             max_tx_queues;
+	u32                             max_rx_queues;
+	u32                             link_attach_type;
+	u32                             link_mode_select;
+	bool                            link_settings_loaded;
+	bool                            autoneg;
+	bool                            autoneg_failed;
 };
 
-struct ixgbe_info {
-	enum ixgbe_mac_type		mac;
-	s32 				(*get_invariants)(struct ixgbe_hw *);
-	struct ixgbe_mac_operations	*mac_ops;
+struct ixgbe_phy_info {
+	struct ixgbe_phy_operations     ops;
+	enum ixgbe_phy_type             type;
+	u32                             addr;
+	u32                             id;
+	enum ixgbe_sfp_type             sfp_type;
+	u32                             revision;
+	enum ixgbe_media_type           media_type;
+	bool                            reset_disable;
+	ixgbe_autoneg_advertised        autoneg_advertised;
+	bool                            autoneg_wait_to_complete;
 };
 
 struct ixgbe_hw {
@@ -1316,6 +1457,15 @@ struct ixgbe_hw {
 	bool				adapter_stopped;
 };
 
+struct ixgbe_info {
+	enum ixgbe_mac_type		mac;
+	s32 				(*get_invariants)(struct ixgbe_hw *);
+	struct ixgbe_mac_operations	*mac_ops;
+	struct ixgbe_eeprom_operations	*eeprom_ops;
+	struct ixgbe_phy_operations	*phy_ops;
+};
+
+
 /* Error Codes */
 #define IXGBE_ERR_EEPROM                        -1
 #define IXGBE_ERR_EEPROM_CHECKSUM               -2
@@ -1334,6 +1484,8 @@ struct ixgbe_hw {
 #define IXGBE_ERR_RESET_FAILED                  -15
 #define IXGBE_ERR_SWFW_SYNC                     -16
 #define IXGBE_ERR_PHY_ADDR_INVALID              -17
+#define IXGBE_ERR_I2C                           -18
+#define IXGBE_ERR_SFP_NOT_SUPPORTED             -19
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF
 
 #endif /* _IXGBE_TYPE_H_ */
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 0a97c26..a1e22ed 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -41,7 +41,7 @@
 #endif
 
 #if MFE_DEBUG>=1
-#define DPRINTK(str,args...) printk(KERN_DEBUG "meth: %s: " str, __FUNCTION__ , ## args)
+#define DPRINTK(str,args...) printk(KERN_DEBUG "meth: %s: " str, __func__ , ## args)
 #define MFE_RX_DEBUG 2
 #else
 #define DPRINTK(str,args...)
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index 6d343ef..4e7a5fa 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -203,7 +203,7 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 
 out_badirq:
 	printk(KERN_INFO "%s: %s(): irq %d for unknown device\n",
-	       dev->name, __FUNCTION__, irq);
+	       dev->name, __func__, irq);
 	return ret;
 }
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index d6524db..195c397 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -102,6 +102,9 @@ MODULE_LICENSE("Dual BSD/GPL");
 #define MYRI10GE_ALLOC_SIZE ((1 << MYRI10GE_ALLOC_ORDER) * PAGE_SIZE)
 #define MYRI10GE_MAX_FRAGS_PER_FRAME (MYRI10GE_MAX_ETHER_MTU/MYRI10GE_ALLOC_SIZE + 1)
 
+#define MYRI10GE_MAX_SLICES 32
+#define MYRI10GE_TOEPLITZ_HASH (MXGEFW_RSS_HASH_TYPE_TCP_IPV4|MXGEFW_RSS_HASH_TYPE_IPV4)
+
 struct myri10ge_rx_buffer_state {
 	struct page *page;
 	int page_offset;
@@ -138,6 +141,8 @@ struct myri10ge_rx_buf {
 
 struct myri10ge_tx_buf {
 	struct mcp_kreq_ether_send __iomem *lanai;	/* lanai ptr for sendq */
+	__be32 __iomem *send_go;	/* "go" doorbell ptr */
+	__be32 __iomem *send_stop;	/* "stop" doorbell ptr */
 	struct mcp_kreq_ether_send *req_list;	/* host shadow of sendq */
 	char *req_bytes;
 	struct myri10ge_tx_buffer_state *info;
@@ -149,6 +154,7 @@ struct myri10ge_tx_buf {
 	int done ____cacheline_aligned;	/* transmit slots completed     */
 	int pkt_done;		/* packets completed */
 	int wake_queue;
+	int queue_active;
 };
 
 struct myri10ge_rx_done {
@@ -183,7 +189,7 @@ struct myri10ge_slice_state {
 	dma_addr_t fw_stats_bus;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	int cached_dca_tag;
 	int cpu;
 	__be32 __iomem *dca_tag;
@@ -215,7 +221,7 @@ struct myri10ge_priv {
 	int msi_enabled;
 	int msix_enabled;
 	struct msix_entry *msix_vectors;
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	int dca_enabled;
 #endif
 	u32 link_state;
@@ -250,6 +256,8 @@ struct myri10ge_priv {
 	u32 read_write_dma;
 	u32 link_changes;
 	u32 msg_enable;
+	u32 *toeplitz_hash_table;
+	u8 rss_key[32];
 };
 
 static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
@@ -418,6 +426,12 @@ myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
 			return -ENOSYS;
 		} else if (result == MXGEFW_CMD_ERROR_UNALIGNED) {
 			return -E2BIG;
+		} else if (result == MXGEFW_CMD_ERROR_RANGE &&
+			   cmd == MXGEFW_CMD_ENABLE_RSS_QUEUES &&
+			   (data->
+			    data1 & MXGEFW_SLICE_ENABLE_MULTIPLE_TX_QUEUES) !=
+			   0) {
+			return -ERANGE;
 		} else {
 			dev_err(&mgp->pdev->dev,
 				"command %d failed, result = %d\n",
@@ -891,7 +905,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	struct myri10ge_slice_state *ss;
 	int i, status;
 	size_t bytes;
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	unsigned long dca_tag_off;
 #endif
 
@@ -947,9 +961,24 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 		 */
 
 		cmd.data0 = mgp->num_slices;
-		cmd.data1 = 1;	/* use MSI-X */
+		cmd.data1 = MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE;
+		if (mgp->dev->real_num_tx_queues > 1)
+			cmd.data1 |= MXGEFW_SLICE_ENABLE_MULTIPLE_TX_QUEUES;
 		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
 					   &cmd, 0);
+
+		/* Firmware older than 1.4.32 only supports multiple
+		 * RX queues, so if we get an error, first retry using a
+		 * single TX queue before giving up */
+		if (status != 0 && mgp->dev->real_num_tx_queues > 1) {
+			mgp->dev->real_num_tx_queues = 1;
+			cmd.data0 = mgp->num_slices;
+			cmd.data1 = MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE;
+			status = myri10ge_send_cmd(mgp,
+						   MXGEFW_CMD_ENABLE_RSS_QUEUES,
+						   &cmd, 0);
+		}
+
 		if (status != 0) {
 			dev_err(&mgp->pdev->dev,
 				"failed to set number of slices\n");
@@ -986,7 +1015,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_DCA_OFFSET, &cmd, 0);
 	dca_tag_off = cmd.data0;
 	for (i = 0; i < mgp->num_slices; i++) {
@@ -1025,7 +1054,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	return status;
 }
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 static void
 myri10ge_write_dca(struct myri10ge_slice_state *ss, int cpu, int tag)
 {
@@ -1060,8 +1089,9 @@ static void myri10ge_setup_dca(struct myri10ge_priv *mgp)
 	}
 	err = dca_add_requester(&pdev->dev);
 	if (err) {
-		dev_err(&pdev->dev,
-			"dca_add_requester() failed, err=%d\n", err);
+		if (err != -ENODEV)
+			dev_err(&pdev->dev,
+				"dca_add_requester() failed, err=%d\n", err);
 		return;
 	}
 	mgp->dca_enabled = 1;
@@ -1316,6 +1346,7 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 {
 	struct pci_dev *pdev = ss->mgp->pdev;
 	struct myri10ge_tx_buf *tx = &ss->tx;
+	struct netdev_queue *dev_queue;
 	struct sk_buff *skb;
 	int idx, len;
 
@@ -1349,11 +1380,31 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 					       PCI_DMA_TODEVICE);
 		}
 	}
+
+	dev_queue = netdev_get_tx_queue(ss->dev, ss - ss->mgp->ss);
+	/*
+	 * Make a minimal effort to prevent the NIC from polling an
+	 * idle tx queue.  If we can't get the lock we leave the queue
+	 * active. In this case, either a thread was about to start
+	 * using the queue anyway, or we lost a race and the NIC will
+	 * waste some of its resources polling an inactive queue for a
+	 * while.
+	 */
+
+	if ((ss->mgp->dev->real_num_tx_queues > 1) &&
+	    __netif_tx_trylock(dev_queue)) {
+		if (tx->req == tx->done) {
+			tx->queue_active = 0;
+			put_be32(htonl(1), tx->send_stop);
+		}
+		__netif_tx_unlock(dev_queue);
+	}
+
 	/* start the queue if we've stopped it */
-	if (netif_queue_stopped(ss->dev)
+	if (netif_tx_queue_stopped(dev_queue)
 	    && tx->req - tx->done < (tx->mask >> 1)) {
 		tx->wake_queue++;
-		netif_wake_queue(ss->dev);
+		netif_tx_wake_queue(dev_queue);
 	}
 }
 
@@ -1457,7 +1508,7 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	if (ss->mgp->dca_enabled)
 		myri10ge_update_dca(ss);
 #endif
@@ -1481,9 +1532,9 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	u32 send_done_count;
 	int i;
 
-	/* an interrupt on a non-zero slice is implicitly valid
-	 * since MSI-X irqs are not shared */
-	if (ss != mgp->ss) {
+	/* an interrupt on a non-zero receive-only slice is implicitly
+	 * valid  since MSI-X irqs are not shared */
+	if ((mgp->dev->real_num_tx_queues == 1) && (ss != mgp->ss)) {
 		netif_rx_schedule(ss->dev, &ss->napi);
 		return (IRQ_HANDLED);
 	}
@@ -1525,7 +1576,9 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 		barrier();
 	}
 
-	myri10ge_check_statblock(mgp);
+	/* Only slice 0 updates stats */
+	if (ss == mgp->ss)
+		myri10ge_check_statblock(mgp);
 
 	put_be32(htonl(3), ss->irq_claim + 1);
 	return (IRQ_HANDLED);
@@ -1686,8 +1739,8 @@ static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
 	"tx_boundary", "WC", "irq", "MSI", "MSIX",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
-#ifdef CONFIG_DCA
-	"dca_capable", "dca_enabled",
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+	"dca_capable_firmware", "dca_device_present",
 #endif
 	"link_changes", "link_up", "dropped_link_overflow",
 	"dropped_link_error_or_filtered",
@@ -1765,7 +1818,7 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = (unsigned int)mgp->read_write_dma;
 	data[i++] = (unsigned int)mgp->serial_number;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	data[i++] = (unsigned int)(mgp->ss[0].dca_tag != NULL);
 	data[i++] = (unsigned int)(mgp->dca_enabled);
 #endif
@@ -1883,6 +1936,7 @@ static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
 	/* ensure req_list entries are aligned to 8 bytes */
 	ss->tx.req_list = (struct mcp_kreq_ether_send *)
 	    ALIGN((unsigned long)ss->tx.req_bytes, 8);
+	ss->tx.queue_active = 0;
 
 	bytes = rx_ring_entries * sizeof(*ss->rx_small.shadow);
 	ss->rx_small.shadow = kzalloc(bytes, GFP_KERNEL);
@@ -2193,6 +2247,169 @@ myri10ge_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
 	return 0;
 }
 
+static int myri10ge_init_toeplitz(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	int i, b, s, t, j;
+	int status;
+	u32 k[8];
+	u32 tmp;
+	u8 *key;
+
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RSS_KEY_OFFSET, &cmd, 0);
+	if (status != 0) {
+		printk(KERN_ERR
+		       "myri10ge: %s: failed to get rss key\n", mgp->dev->name);
+		return -EIO;
+	}
+	memcpy_fromio(mgp->rss_key, mgp->sram + cmd.data0,
+		      sizeof(mgp->rss_key));
+
+	mgp->toeplitz_hash_table = kmalloc(sizeof(u32) * 12 * 256, GFP_KERNEL);
+	if (mgp->toeplitz_hash_table == NULL)
+		return -ENOMEM;
+	key = (u8 *) mgp->rss_key;
+	t = 0;
+	for (b = 0; b < 12; b++) {
+		for (s = 0; s < 8; s++) {
+			/* Bits: b*8+s, ..., b*8+s+31 */
+			k[s] = 0;
+			for (j = 0; j < 32; j++) {
+				int bit = b * 8 + s + j;
+				bit = 0x1 & (key[bit / 8] >> (7 - (bit & 0x7)));
+				k[s] |= bit << (31 - j);
+			}
+		}
+
+		for (i = 0; i <= 0xff; i++) {
+			tmp = 0;
+			if (i & (1 << 7)) {
+				tmp ^= k[0];
+			}
+			if (i & (1 << 6)) {
+				tmp ^= k[1];
+			}
+			if (i & (1 << 5)) {
+				tmp ^= k[2];
+			}
+			if (i & (1 << 4)) {
+				tmp ^= k[3];
+			}
+			if (i & (1 << 3)) {
+				tmp ^= k[4];
+			}
+			if (i & (1 << 2)) {
+				tmp ^= k[5];
+			}
+			if (i & (1 << 1)) {
+				tmp ^= k[6];
+			}
+			if (i & (1 << 0)) {
+				tmp ^= k[7];
+			}
+			mgp->toeplitz_hash_table[t++] = tmp;
+		}
+	}
+	return 0;
+}
+
+static inline u16
+myri10ge_toeplitz_select_queue(struct net_device *dev, struct iphdr *ip)
+{
+	struct myri10ge_priv *mgp = netdev_priv(dev);
+	struct tcphdr *hdr;
+	u32 saddr, daddr;
+	u32 hash;
+	u32 *table = mgp->toeplitz_hash_table;
+	u16 src, dst;
+
+	/*
+	 * Note hashing order is reversed from how it is done
+	 * in the NIC, so as to generate the same hash value
+	 * for the connection to try to keep connections CPU local
+	 */
+
+	/* hash on IPv4 src/dst address */
+	saddr = ntohl(ip->saddr);
+	daddr = ntohl(ip->daddr);
+	hash = table[(256 * 0) + ((daddr >> 24) & 0xff)];
+	hash ^= table[(256 * 1) + ((daddr >> 16) & 0xff)];
+	hash ^= table[(256 * 2) + ((daddr >> 8) & 0xff)];
+	hash ^= table[(256 * 3) + ((daddr) & 0xff)];
+	hash ^= table[(256 * 4) + ((saddr >> 24) & 0xff)];
+	hash ^= table[(256 * 5) + ((saddr >> 16) & 0xff)];
+	hash ^= table[(256 * 6) + ((saddr >> 8) & 0xff)];
+	hash ^= table[(256 * 7) + ((saddr) & 0xff)];
+	/* hash on TCP port, if required */
+	if ((myri10ge_rss_hash & MXGEFW_RSS_HASH_TYPE_TCP_IPV4) &&
+	    ip->protocol == IPPROTO_TCP) {
+		hdr = (struct tcphdr *)(((u8 *) ip) + (ip->ihl << 2));
+		src = ntohs(hdr->source);
+		dst = ntohs(hdr->dest);
+
+		hash ^= table[(256 * 8) + ((dst >> 8) & 0xff)];
+		hash ^= table[(256 * 9) + ((dst) & 0xff)];
+		hash ^= table[(256 * 10) + ((src >> 8) & 0xff)];
+		hash ^= table[(256 * 11) + ((src) & 0xff)];
+	}
+	return (u16) (hash & (dev->real_num_tx_queues - 1));
+}
+
+static u16
+myri10ge_simple_select_queue(struct net_device *dev, struct iphdr *ip)
+{
+	struct udphdr *hdr;
+	u32 hash_val = 0;
+
+	if (ip->protocol != IPPROTO_TCP && ip->protocol != IPPROTO_UDP)
+		return (0);
+	hdr = (struct udphdr *)(((u8 *) ip) + (ip->ihl << 2));
+
+	/*
+	 * Use the second byte of the *destination* address for
+	 * MXGEFW_RSS_HASH_TYPE_SRC_PORT, so as to match NIC's hashing
+	 */
+	hash_val = ntohs(hdr->dest) & 0xff;
+	if (myri10ge_rss_hash == MXGEFW_RSS_HASH_TYPE_SRC_DST_PORT)
+		hash_val += ntohs(hdr->source) & 0xff;
+
+	return (u16) (hash_val & (dev->real_num_tx_queues - 1));
+}
+
+static u16 myri10ge_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	struct iphdr *ip;
+	struct vlan_hdr *vh;
+
+	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+		ip = ip_hdr(skb);
+	} else if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		vh = (struct vlan_hdr *)skb->data;
+		if ((vh->h_vlan_encapsulated_proto !=
+		     __constant_htons(ETH_P_IP)))
+			return 0;
+		ip = (struct iphdr *)skb->data + sizeof(*vh);
+	} else {
+		return 0;
+	}
+
+	switch (myri10ge_rss_hash) {
+	case MXGEFW_RSS_HASH_TYPE_IPV4:
+		/* fallthru */
+	case MXGEFW_RSS_HASH_TYPE_TCP_IPV4:
+		/* fallthru */
+	case (MXGEFW_RSS_HASH_TYPE_IPV4 | MXGEFW_RSS_HASH_TYPE_TCP_IPV4):
+		return (myri10ge_toeplitz_select_queue(dev, ip));
+		break;
+	case MXGEFW_RSS_HASH_TYPE_SRC_PORT:
+		/* fallthru */
+	case MXGEFW_RSS_HASH_TYPE_SRC_DST_PORT:
+		return (myri10ge_simple_select_queue(dev, ip));
+	default:
+		return (0);
+	}
+}
+
 static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
 {
 	struct myri10ge_cmd cmd;
@@ -2200,11 +2417,14 @@ static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
 	int status;
 
 	ss = &mgp->ss[slice];
-	cmd.data0 = 0;		/* single slice for now */
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
-	ss->tx.lanai = (struct mcp_kreq_ether_send __iomem *)
-	    (mgp->sram + cmd.data0);
-
+	status = 0;
+	if (slice == 0 || (mgp->dev->real_num_tx_queues > 1)) {
+		cmd.data0 = slice;
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET,
+					   &cmd, 0);
+		ss->tx.lanai = (struct mcp_kreq_ether_send __iomem *)
+		    (mgp->sram + cmd.data0);
+	}
 	cmd.data0 = slice;
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SMALL_RX_OFFSET,
 				    &cmd, 0);
@@ -2216,6 +2436,10 @@ static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
 	ss->rx_big.lanai = (struct mcp_kreq_ether_recv __iomem *)
 	    (mgp->sram + cmd.data0);
 
+	ss->tx.send_go = (__iomem __be32 *)
+	    (mgp->sram + MXGEFW_ETH_SEND_GO + 64 * slice);
+	ss->tx.send_stop = (__iomem __be32 *)
+	    (mgp->sram + MXGEFW_ETH_SEND_STOP + 64 * slice);
 	return status;
 
 }
@@ -2229,7 +2453,7 @@ static int myri10ge_set_stats(struct myri10ge_priv *mgp, int slice)
 	ss = &mgp->ss[slice];
 	cmd.data0 = MYRI10GE_LOWPART_TO_U32(ss->fw_stats_bus);
 	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(ss->fw_stats_bus);
-	cmd.data2 = sizeof(struct mcp_irq_data);
+	cmd.data2 = sizeof(struct mcp_irq_data) | (slice << 16);
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
 	if (status == -ENOSYS) {
 		dma_addr_t bus = ss->fw_stats_bus;
@@ -2270,7 +2494,9 @@ static int myri10ge_open(struct net_device *dev)
 
 	if (mgp->num_slices > 1) {
 		cmd.data0 = mgp->num_slices;
-		cmd.data1 = 1;	/* use MSI-X */
+		cmd.data1 = MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE;
+		if (mgp->dev->real_num_tx_queues > 1)
+			cmd.data1 |= MXGEFW_SLICE_ENABLE_MULTIPLE_TX_QUEUES;
 		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
 					   &cmd, 0);
 		if (status != 0) {
@@ -2291,6 +2517,7 @@ static int myri10ge_open(struct net_device *dev)
 			printk(KERN_ERR
 			       "myri10ge: %s: failed to setup rss tables\n",
 			       dev->name);
+			goto abort_with_nothing;
 		}
 
 		/* just enable an identity mapping */
@@ -2298,6 +2525,20 @@ static int myri10ge_open(struct net_device *dev)
 		for (i = 0; i < mgp->num_slices; i++)
 			__raw_writeb(i, &itable[i]);
 
+		if (mgp->dev->real_num_tx_queues > 1) {
+			if (myri10ge_rss_hash & MYRI10GE_TOEPLITZ_HASH) {
+				/* grab the rss key for use in hashing transmits */
+				status = myri10ge_init_toeplitz(mgp);
+				if (status != 0) {
+					printk(KERN_ERR
+					       "myri10ge: %s: failed to init toeplitz table\n",
+					       dev->name);
+					goto abort_with_nothing;
+				}
+			}
+			mgp->dev->select_queue = myri10ge_select_queue;
+		}
+
 		cmd.data0 = 1;
 		cmd.data1 = myri10ge_rss_hash;
 		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_RSS_ENABLE,
@@ -2306,7 +2547,7 @@ static int myri10ge_open(struct net_device *dev)
 			printk(KERN_ERR
 			       "myri10ge: %s: failed to enable slices\n",
 			       dev->name);
-			goto abort_with_nothing;
+			goto abort_with_toeplitz;
 		}
 	}
 
@@ -2361,7 +2602,11 @@ static int myri10ge_open(struct net_device *dev)
 		status = myri10ge_allocate_rings(ss);
 		if (status != 0)
 			goto abort_with_rings;
-		if (slice == 0)
+
+		/* only firmware which supports multiple TX queues
+		 * supports setting up the tx stats on non-zero
+		 * slices */
+		if (slice == 0 || mgp->dev->real_num_tx_queues > 1)
 			status = myri10ge_set_stats(mgp, slice);
 		if (status) {
 			printk(KERN_ERR
@@ -2427,7 +2672,8 @@ static int myri10ge_open(struct net_device *dev)
 	mgp->running = MYRI10GE_ETH_RUNNING;
 	mgp->watchdog_timer.expires = jiffies + myri10ge_watchdog_timeout * HZ;
 	add_timer(&mgp->watchdog_timer);
-	netif_wake_queue(dev);
+	netif_tx_wake_all_queues(dev);
+
 	return 0;
 
 abort_with_rings:
@@ -2436,6 +2682,11 @@ abort_with_rings:
 
 	myri10ge_free_irq(mgp);
 
+abort_with_toeplitz:
+	if (mgp->toeplitz_hash_table != NULL) {
+		kfree(mgp->toeplitz_hash_table);
+		mgp->toeplitz_hash_table = NULL;
+	}
 abort_with_nothing:
 	mgp->running = MYRI10GE_ETH_STOPPED;
 	return -ENOMEM;
@@ -2454,13 +2705,15 @@ static int myri10ge_close(struct net_device *dev)
 	if (mgp->ss[0].tx.req_bytes == NULL)
 		return 0;
 
+	dev->select_queue = NULL;
 	del_timer_sync(&mgp->watchdog_timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
 	for (i = 0; i < mgp->num_slices; i++) {
 		napi_disable(&mgp->ss[i].napi);
 	}
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
+
+	netif_tx_stop_all_queues(dev);
 	old_down_cnt = mgp->down_cnt;
 	mb();
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_DOWN, &cmd, 0);
@@ -2477,6 +2730,11 @@ static int myri10ge_close(struct net_device *dev)
 	for (i = 0; i < mgp->num_slices; i++)
 		myri10ge_free_rings(&mgp->ss[i]);
 
+	if (mgp->toeplitz_hash_table != NULL) {
+		kfree(mgp->toeplitz_hash_table);
+		mgp->toeplitz_hash_table = NULL;
+	}
+
 	mgp->running = MYRI10GE_ETH_STOPPED;
 	return 0;
 }
@@ -2565,18 +2823,23 @@ static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mcp_kreq_ether_send *req;
 	struct myri10ge_tx_buf *tx;
 	struct skb_frag_struct *frag;
+	struct netdev_queue *netdev_queue;
 	dma_addr_t bus;
 	u32 low;
 	__be32 high_swapped;
 	unsigned int len;
 	int idx, last_idx, avail, frag_cnt, frag_idx, count, mss, max_segments;
-	u16 pseudo_hdr_offset, cksum_offset;
+	u16 pseudo_hdr_offset, cksum_offset, queue;
 	int cum_len, seglen, boundary, rdma_count;
 	u8 flags, odd_flag;
 
-	/* always transmit through slot 0 */
-	ss = mgp->ss;
+	queue = skb_get_queue_mapping(skb);
+	queue &= (mgp->num_slices - 1);
+
+	ss = &mgp->ss[queue];
+	netdev_queue = netdev_get_tx_queue(mgp->dev, queue);
 	tx = &ss->tx;
+
 again:
 	req = tx->req_list;
 	avail = tx->mask - 1 - (tx->req - tx->done);
@@ -2592,7 +2855,7 @@ again:
 	if ((unlikely(avail < max_segments))) {
 		/* we are out of transmit resources */
 		tx->stop_queue++;
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(netdev_queue);
 		return 1;
 	}
 
@@ -2785,10 +3048,16 @@ again:
 	idx = ((count - 1) + tx->req) & tx->mask;
 	tx->info[idx].last = 1;
 	myri10ge_submit_req(tx, tx->req_list, count);
+	/* if using multiple tx queues, make sure NIC polls the
+	 * current slice */
+	if ((mgp->dev->real_num_tx_queues > 1) && tx->queue_active == 0) {
+		tx->queue_active = 1;
+		put_be32(htonl(1), tx->send_go);
+	}
 	tx->pkt_start++;
 	if ((avail - count) < MXGEFW_MAX_SEND_DESC) {
 		tx->stop_queue++;
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(netdev_queue);
 	}
 	dev->trans_start = jiffies;
 	return 0;
@@ -3366,20 +3635,21 @@ static void myri10ge_watchdog(struct work_struct *work)
 		for (i = 0; i < mgp->num_slices; i++) {
 			tx = &mgp->ss[i].tx;
 			printk(KERN_INFO
-			       "myri10ge: %s: (%d): %d %d %d %d %d\n",
-			       mgp->dev->name, i, tx->req, tx->done,
-			       tx->pkt_start, tx->pkt_done,
+			       "myri10ge: %s: (%d): %d %d %d %d %d %d\n",
+			       mgp->dev->name, i, tx->queue_active, tx->req,
+			       tx->done, tx->pkt_start, tx->pkt_done,
 			       (int)ntohl(mgp->ss[i].fw_stats->
 					  send_done_count));
 			msleep(2000);
 			printk(KERN_INFO
-			       "myri10ge: %s: (%d): %d %d %d %d %d\n",
-			       mgp->dev->name, i, tx->req, tx->done,
-			       tx->pkt_start, tx->pkt_done,
+			       "myri10ge: %s: (%d): %d %d %d %d %d %d\n",
+			       mgp->dev->name, i, tx->queue_active, tx->req,
+			       tx->done, tx->pkt_start, tx->pkt_done,
 			       (int)ntohl(mgp->ss[i].fw_stats->
 					  send_done_count));
 		}
 	}
+
 	rtnl_lock();
 	myri10ge_close(mgp->dev);
 	status = myri10ge_load_firmware(mgp, 1);
@@ -3434,10 +3704,14 @@ static void myri10ge_watchdog_timer(unsigned long arg)
 			/* nic seems like it might be stuck.. */
 			if (rx_pause_cnt != mgp->watchdog_pause) {
 				if (net_ratelimit())
-					printk(KERN_WARNING "myri10ge %s:"
+					printk(KERN_WARNING
+					       "myri10ge %s slice %d:"
 					       "TX paused, check link partner\n",
-					       mgp->dev->name);
+					       mgp->dev->name, i);
 			} else {
+				printk(KERN_WARNING
+				       "myri10ge %s slice %d stuck:",
+				       mgp->dev->name, i);
 				reset_needed = 1;
 			}
 		}
@@ -3623,6 +3897,9 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 					 mgp->num_slices);
 		if (status == 0) {
 			pci_disable_msix(pdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			mgp->features |= NETIF_F_MULTI_QUEUE;
+#endif
 			return;
 		}
 		if (status > 0)
@@ -3652,7 +3929,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int status = -ENXIO;
 	int dac_enabled;
 
-	netdev = alloc_etherdev(sizeof(*mgp));
+	netdev = alloc_etherdev_mq(sizeof(*mgp), MYRI10GE_MAX_SLICES);
 	if (netdev == NULL) {
 		dev_err(dev, "Could not allocate ethernet device\n");
 		return -ENOMEM;
@@ -3757,13 +4034,13 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "failed to alloc slice state\n");
 		goto abort_with_firmware;
 	}
-
+	netdev->real_num_tx_queues = mgp->num_slices;
 	status = myri10ge_reset(mgp);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed reset\n");
 		goto abort_with_slices;
 	}
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	myri10ge_setup_dca(mgp);
 #endif
 	pci_set_drvdata(pdev, mgp);
@@ -3781,6 +4058,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->set_multicast_list = myri10ge_set_multicast_list;
 	netdev->set_mac_address = myri10ge_set_mac_address;
 	netdev->features = mgp->features;
+
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
 
@@ -3866,7 +4144,7 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	netdev = mgp->dev;
 	unregister_netdev(netdev);
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	myri10ge_teardown_dca(mgp);
 #endif
 	myri10ge_dummy_rdma(mgp, 0);
@@ -3911,7 +4189,7 @@ static struct pci_driver myri10ge_driver = {
 #endif
 };
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 static int
 myri10ge_notify_dca(struct notifier_block *nb, unsigned long event, void *p)
 {
@@ -3936,16 +4214,17 @@ static __init int myri10ge_init_module(void)
 	printk(KERN_INFO "%s: Version %s\n", myri10ge_driver.name,
 	       MYRI10GE_VERSION_STR);
 
-	if (myri10ge_rss_hash > MXGEFW_RSS_HASH_TYPE_SRC_PORT ||
-	    myri10ge_rss_hash < MXGEFW_RSS_HASH_TYPE_IPV4) {
+	if (myri10ge_rss_hash > MXGEFW_RSS_HASH_TYPE_MAX) {
 		printk(KERN_ERR
 		       "%s: Illegal rssh hash type %d, defaulting to source port\n",
 		       myri10ge_driver.name, myri10ge_rss_hash);
 		myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
 	}
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	dca_register_notify(&myri10ge_dca_notifier);
 #endif
+	if (myri10ge_max_slices > MYRI10GE_MAX_SLICES)
+		myri10ge_max_slices = MYRI10GE_MAX_SLICES;
 
 	return pci_register_driver(&myri10ge_driver);
 }
@@ -3954,7 +4233,7 @@ module_init(myri10ge_init_module);
 
 static __exit void myri10ge_cleanup_module(void)
 {
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	dca_unregister_notify(&myri10ge_dca_notifier);
 #endif
 	pci_unregister_driver(&myri10ge_driver);
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 3f9af75..b9bed82 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -189,7 +189,7 @@ netx_eth_interrupt(int irq, void *dev_id)
 
 		if ((status & ISR_CON_HI) || (status & ISR_IND_HI))
 			printk("%s: unexpected status: 0x%08x\n",
-			    __FUNCTION__, status);
+			    __func__, status);
 
 		fill_level =
 		    readl(NETX_PFIFO_FILL_LEVEL(IND_FIFO_PORT_LO(priv->id)));
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 244ab49..f8e601c 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -742,7 +742,7 @@ extern char netxen_nic_driver_name[];
 	} while (0)
 #else
 #define DPRINTK(klevel, fmt, args...)	do { \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
+	printk(KERN_##klevel PFX "%s: %s: " fmt, __func__,\
 		(adapter != NULL && adapter->netdev != NULL) ? \
 		adapter->netdev->name : NULL, \
 		## args); } while(0)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 008fd66..6ef3f0d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -77,18 +77,18 @@ static irqreturn_t netxen_msi_intr(int irq, void *data);
 
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
-	{PCI_DEVICE(0x4040, (device)), \
+	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
 static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
-	ENTRY(0x0001),
-	ENTRY(0x0002),
-	ENTRY(0x0003),
-	ENTRY(0x0004),
-	ENTRY(0x0005),
-	ENTRY(0x0024),
-	ENTRY(0x0025),
-	ENTRY(0x0100),
+	ENTRY(PCI_DEVICE_ID_NX2031_10GXSR),
+	ENTRY(PCI_DEVICE_ID_NX2031_10GCX4),
+	ENTRY(PCI_DEVICE_ID_NX2031_4GCU),
+	ENTRY(PCI_DEVICE_ID_NX2031_IMEZ),
+	ENTRY(PCI_DEVICE_ID_NX2031_HMEZ),
+	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT),
+	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT2),
+	ENTRY(PCI_DEVICE_ID_NX3031),
 	{0,}
 };
 
@@ -241,7 +241,7 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_REF_QG:
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
-		adapter->msix_supported = 0;
+		adapter->msix_supported = !!use_msi_x;
 		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
 		break;
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 53451c3..0a575fe 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -119,7 +119,7 @@ KERN_INFO "  Support available from http://foo.com/bar/baz.html\n";
 
 #ifdef NETDRV_DEBUG
 /* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
+#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
 #else
 #  define DPRINTK(fmt, args...)
 #endif
@@ -130,7 +130,7 @@ KERN_INFO "  Support available from http://foo.com/bar/baz.html\n";
 #  define assert(expr) \
         if(!(expr)) {					\
         printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
-        #expr,__FILE__,__FUNCTION__,__LINE__);		\
+        #expr,__FILE__,__func__,__LINE__);		\
         }
 #endif
 
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 5d86281..025f526 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -370,7 +370,7 @@ static void r6040_init_mac_regs(struct net_device *dev)
 	/* Reset internal state machine */
 	iowrite16(2, ioaddr + MAC_SM);
 	iowrite16(0, ioaddr + MAC_SM);
-	udelay(5000);
+	mdelay(5);
 
 	/* MAC Bus Control Register */
 	iowrite16(MBCR_DEFAULT, ioaddr + MBCR);
@@ -806,7 +806,7 @@ static void r6040_mac_address(struct net_device *dev)
 	iowrite16(0x01, ioaddr + MCR1); /* Reset MAC */
 	iowrite16(2, ioaddr + MAC_SM); /* Reset internal state machine */
 	iowrite16(0, ioaddr + MAC_SM);
-	udelay(5000);
+	mdelay(5);
 
 	/* Restore MAC Address */
 	adrp = (u16 *) dev->dev_addr;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1822491..0b7fe84 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -36,7 +36,7 @@
 #define assert(expr) \
 	if (!(expr)) {					\
 		printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
-		#expr,__FILE__,__FUNCTION__,__LINE__);		\
+		#expr,__FILE__,__func__,__LINE__);		\
 	}
 #define dprintk(fmt, args...) \
 	do { printk(KERN_DEBUG PFX fmt, ## args); } while (0)
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 243db33..fd24de5 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3136,7 +3136,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 		if (skb == NULL) {
 			spin_unlock_irqrestore(&fifo_data->tx_lock, flags);
 			DBG_PRINT(ERR_DBG, "%s: Null skb ",
-			__FUNCTION__);
+			__func__);
 			DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");
 			return;
 		}
@@ -3496,7 +3496,7 @@ static void s2io_reset(struct s2io_nic * sp)
 	unsigned long long mem_alloc_cnt, mem_free_cnt, watchdog_cnt;
 
 	DBG_PRINT(INIT_DBG,"%s - Resetting XFrame card %s\n",
-			__FUNCTION__, sp->dev->name);
+			__func__, sp->dev->name);
 
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
@@ -3518,7 +3518,7 @@ static void s2io_reset(struct s2io_nic * sp)
 	}
 
 	if (check_pci_device_id(val16) == (u16)PCI_ANY_ID) {
-		DBG_PRINT(ERR_DBG,"%s SW_Reset failed!\n", __FUNCTION__);
+		DBG_PRINT(ERR_DBG,"%s SW_Reset failed!\n", __func__);
 	}
 
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER, pci_cmd);
@@ -3768,7 +3768,7 @@ static void restore_xmsi_data(struct s2io_nic *nic)
 		val64 = (s2BIT(7) | s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, msix_index)) {
-			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "failed in %s\n", __func__);
 			continue;
 		}
 	}
@@ -3789,7 +3789,7 @@ static void store_xmsi_data(struct s2io_nic *nic)
 		val64 = (s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, msix_index)) {
-			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "failed in %s\n", __func__);
 			continue;
 		}
 		addr = readq(&bar0->xmsi_address);
@@ -3812,7 +3812,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 			       GFP_KERNEL);
 	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
-			__FUNCTION__);
+			__func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
@@ -3826,7 +3826,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 				   GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
-			__FUNCTION__);
+			__func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
@@ -6746,7 +6746,7 @@ static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 		ret = s2io_card_up(sp);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
-				  __FUNCTION__);
+				  __func__);
 			return ret;
 		}
 		s2io_wake_all_tx_queue(sp);
@@ -7530,7 +7530,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 					default:
 						DBG_PRINT(ERR_DBG,
 							"%s: Samadhana!!\n",
-							 __FUNCTION__);
+							 __func__);
 						BUG();
 				}
 			}
@@ -7781,7 +7781,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		return -ENOMEM;
 	}
 	if ((ret = pci_request_regions(pdev, s2io_driver_name))) {
-		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __FUNCTION__, ret);
+		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __func__, ret);
 		pci_disable_device(pdev);
 		return -ENODEV;
 	}
@@ -7998,7 +7998,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_verify_pci_mode(sp);
 		if (mode < 0) {
-			DBG_PRINT(ERR_DBG, "%s: ", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "%s: ", __func__);
 			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode\n");
 			ret = -EBADSLT;
 			goto set_swap_failed;
@@ -8299,7 +8299,7 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 
 	if (!(rxdp->Control_1 & RXD_FRAME_PROTO_TCP)) {
 		DBG_PRINT(INIT_DBG,"%s: Non-TCP frames not supported for LRO\n",
-			  __FUNCTION__);
+			  __func__);
 		return -1;
 	}
 
@@ -8330,7 +8330,7 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 static int check_for_socket_match(struct lro *lro, struct iphdr *ip,
 				  struct tcphdr *tcp)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	if ((lro->iph->saddr != ip->saddr) || (lro->iph->daddr != ip->daddr) ||
 	   (lro->tcph->source != tcp->source) || (lro->tcph->dest != tcp->dest))
 		return -1;
@@ -8345,7 +8345,7 @@ static inline int get_l4_pyld_length(struct iphdr *ip, struct tcphdr *tcp)
 static void initiate_new_session(struct lro *lro, u8 *l2h,
 	struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len, u16 vlan_tag)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	lro->l2h = l2h;
 	lro->iph = ip;
 	lro->tcph = tcp;
@@ -8375,7 +8375,7 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 	struct tcphdr *tcp = lro->tcph;
 	__sum16 nchk;
 	struct stat_block *statinfo = sp->mac_control.stats_info;
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 
 	/* Update L3 header */
 	ip->tot_len = htons(lro->total_len);
@@ -8403,7 +8403,7 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 static void aggregate_new_rx(struct lro *lro, struct iphdr *ip,
 		struct tcphdr *tcp, u32 l4_pyld)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	lro->total_len += l4_pyld;
 	lro->frags_len += l4_pyld;
 	lro->tcp_next_seq += l4_pyld;
@@ -8427,7 +8427,7 @@ static int verify_l3_l4_lro_capable(struct lro *l_lro, struct iphdr *ip,
 {
 	u8 *ptr;
 
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 
 	if (!tcp_pyld_len) {
 		/* Runt frame or a pure ack */
@@ -8509,7 +8509,7 @@ s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer, u8 **tcp,
 
 			if ((*lro)->tcp_next_seq != ntohl(tcph->seq)) {
 				DBG_PRINT(INFO_DBG, "%s:Out of order. expected "
-					  "0x%x, actual 0x%x\n", __FUNCTION__,
+					  "0x%x, actual 0x%x\n", __func__,
 					  (*lro)->tcp_next_seq,
 					  ntohl(tcph->seq));
 
@@ -8549,7 +8549,7 @@ s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer, u8 **tcp,
 
 	if (ret == 0) { /* sessions exceeded */
 		DBG_PRINT(INFO_DBG,"%s:All LRO sessions already in use\n",
-			  __FUNCTION__);
+			  __func__);
 		*lro = NULL;
 		return ret;
 	}
@@ -8571,7 +8571,7 @@ s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer, u8 **tcp,
 			break;
 		default:
 			DBG_PRINT(ERR_DBG,"%s:Dont know, can't say!!\n",
-				__FUNCTION__);
+				__func__);
 			break;
 	}
 
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 0d47d6f..06ea71c 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -445,10 +445,17 @@ static void efx_fini_channels(struct efx_nic *efx)
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
+	rc = falcon_flush_queues(efx);
+	if (rc)
+		EFX_ERR(efx, "failed to flush queues\n");
+	else
+		EFX_LOG(efx, "successfully flushed all queues\n");
+
 	efx_for_each_channel(channel, efx) {
 		EFX_LOG(channel->efx, "shut down chan %d\n", channel->channel);
 
@@ -456,13 +463,6 @@ static void efx_fini_channels(struct efx_nic *efx)
 			efx_fini_rx_queue(rx_queue);
 		efx_for_each_channel_tx_queue(tx_queue, channel)
 			efx_fini_tx_queue(tx_queue);
-	}
-
-	/* Do the event queues last so that we can handle flush events
-	 * for all DMA queues. */
-	efx_for_each_channel(channel, efx) {
-		EFX_LOG(channel->efx, "shut down evq %d\n", channel->channel);
-
 		efx_fini_eventq(channel);
 	}
 }
@@ -780,7 +780,7 @@ static int efx_init_io(struct efx_nic *efx)
 	return 0;
 
  fail4:
-	release_mem_region(efx->membase_phys, efx->type->mem_map_size);
+	pci_release_region(efx->pci_dev, efx->type->mem_bar);
  fail3:
 	efx->membase_phys = 0;
  fail2:
@@ -1092,7 +1092,6 @@ static void efx_stop_all(struct efx_nic *efx)
 
 	/* Isolate the MAC from the TX and RX engines, so that queue
 	 * flushes will complete in a timely fashion. */
-	falcon_deconfigure_mac_wrapper(efx);
 	falcon_drain_tx_fifo(efx);
 
 	/* Stop the kernel transmit interface late, so the watchdog
@@ -1750,7 +1749,6 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 	.check_hw        = efx_port_dummy_op_int,
 	.fini		 = efx_port_dummy_op_void,
 	.clear_interrupt = efx_port_dummy_op_void,
-	.reset_xaui      = efx_port_dummy_op_void,
 };
 
 static struct efx_board efx_dummy_board_info = {
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e0c0b23..31ed1f4 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -108,10 +108,10 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 /* Max number of internal errors. After this resets will not be performed */
 #define FALCON_MAX_INT_ERRORS 4
 
-/* Maximum period that we wait for flush events. If the flush event
- * doesn't arrive in this period of time then we check if the queue
- * was disabled anyway. */
-#define FALCON_FLUSH_TIMEOUT 10 /* 10ms */
+/* We poll for events every FLUSH_INTERVAL ms, and check FLUSH_POLL_COUNT times
+ */
+#define FALCON_FLUSH_INTERVAL 10
+#define FALCON_FLUSH_POLL_COUNT 100
 
 /**************************************************************************
  *
@@ -452,6 +452,8 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 	efx_oword_t tx_desc_ptr;
 	struct efx_nic *efx = tx_queue->efx;
 
+	tx_queue->flushed = false;
+
 	/* Pin TX descriptor ring */
 	falcon_init_special_buffer(efx, &tx_queue->txd);
 
@@ -492,60 +494,16 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 	}
 }
 
-static int falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
+static void falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
-	struct efx_channel *channel = &efx->channel[0];
 	efx_oword_t tx_flush_descq;
-	unsigned int read_ptr, i;
 
 	/* Post a flush command */
 	EFX_POPULATE_OWORD_2(tx_flush_descq,
 			     TX_FLUSH_DESCQ_CMD, 1,
 			     TX_FLUSH_DESCQ, tx_queue->queue);
 	falcon_write(efx, &tx_flush_descq, TX_FLUSH_DESCQ_REG_KER);
-	msleep(FALCON_FLUSH_TIMEOUT);
-
-	if (EFX_WORKAROUND_7803(efx))
-		return 0;
-
-	/* Look for a flush completed event */
-	read_ptr = channel->eventq_read_ptr;
-	for (i = 0; i < FALCON_EVQ_SIZE; ++i) {
-		efx_qword_t *event = falcon_event(channel, read_ptr);
-		int ev_code, ev_sub_code, ev_queue;
-		if (!falcon_event_present(event))
-			break;
-
-		ev_code = EFX_QWORD_FIELD(*event, EV_CODE);
-		ev_sub_code = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
-		ev_queue = EFX_QWORD_FIELD(*event, DRIVER_EV_TX_DESCQ_ID);
-		if ((ev_sub_code == TX_DESCQ_FLS_DONE_EV_DECODE) &&
-		    (ev_queue == tx_queue->queue)) {
-			EFX_LOG(efx, "tx queue %d flush command succesful\n",
-				tx_queue->queue);
-			return 0;
-		}
-
-		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
-	}
-
-	if (EFX_WORKAROUND_11557(efx)) {
-		efx_oword_t reg;
-		bool enabled;
-
-		falcon_read_table(efx, &reg, efx->type->txd_ptr_tbl_base,
-				  tx_queue->queue);
-		enabled = EFX_OWORD_FIELD(reg, TX_DESCQ_EN);
-		if (!enabled) {
-			EFX_LOG(efx, "tx queue %d disabled without a "
-				"flush event seen\n", tx_queue->queue);
-			return 0;
-		}
-	}
-
-	EFX_ERR(efx, "tx queue %d flush command timed out\n", tx_queue->queue);
-	return -ETIMEDOUT;
 }
 
 void falcon_fini_tx(struct efx_tx_queue *tx_queue)
@@ -553,9 +511,8 @@ void falcon_fini_tx(struct efx_tx_queue *tx_queue)
 	struct efx_nic *efx = tx_queue->efx;
 	efx_oword_t tx_desc_ptr;
 
-	/* Stop the hardware using the queue */
-	if (falcon_flush_tx_queue(tx_queue))
-		EFX_ERR(efx, "failed to flush tx queue %d\n", tx_queue->queue);
+	/* The queue should have been flushed */
+	WARN_ON(!tx_queue->flushed);
 
 	/* Remove TX descriptor ring from card */
 	EFX_ZERO_OWORD(tx_desc_ptr);
@@ -643,6 +600,8 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 		rx_queue->queue, rx_queue->rxd.index,
 		rx_queue->rxd.index + rx_queue->rxd.entries - 1);
 
+	rx_queue->flushed = false;
+
 	/* Pin RX descriptor ring */
 	falcon_init_special_buffer(efx, &rx_queue->rxd);
 
@@ -663,11 +622,9 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 			   rx_queue->queue);
 }
 
-static int falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
+static void falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	struct efx_channel *channel = &efx->channel[0];
-	unsigned int read_ptr, i;
 	efx_oword_t rx_flush_descq;
 
 	/* Post a flush command */
@@ -675,76 +632,15 @@ static int falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 			     RX_FLUSH_DESCQ_CMD, 1,
 			     RX_FLUSH_DESCQ, rx_queue->queue);
 	falcon_write(efx, &rx_flush_descq, RX_FLUSH_DESCQ_REG_KER);
-	msleep(FALCON_FLUSH_TIMEOUT);
-
-	if (EFX_WORKAROUND_7803(efx))
-		return 0;
-
-	/* Look for a flush completed event */
-	read_ptr = channel->eventq_read_ptr;
-	for (i = 0; i < FALCON_EVQ_SIZE; ++i) {
-		efx_qword_t *event = falcon_event(channel, read_ptr);
-		int ev_code, ev_sub_code, ev_queue;
-		bool ev_failed;
-		if (!falcon_event_present(event))
-			break;
-
-		ev_code = EFX_QWORD_FIELD(*event, EV_CODE);
-		ev_sub_code = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
-		ev_queue = EFX_QWORD_FIELD(*event, DRIVER_EV_RX_DESCQ_ID);
-		ev_failed = EFX_QWORD_FIELD(*event, DRIVER_EV_RX_FLUSH_FAIL);
-
-		if ((ev_sub_code == RX_DESCQ_FLS_DONE_EV_DECODE) &&
-		    (ev_queue == rx_queue->queue)) {
-			if (ev_failed) {
-				EFX_INFO(efx, "rx queue %d flush command "
-					 "failed\n", rx_queue->queue);
-				return -EAGAIN;
-			} else {
-				EFX_LOG(efx, "rx queue %d flush command "
-					"succesful\n", rx_queue->queue);
-				return 0;
-			}
-		}
-
-		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
-	}
-
-	if (EFX_WORKAROUND_11557(efx)) {
-		efx_oword_t reg;
-		bool enabled;
-
-		falcon_read_table(efx, &reg, efx->type->rxd_ptr_tbl_base,
-				  rx_queue->queue);
-		enabled = EFX_OWORD_FIELD(reg, RX_DESCQ_EN);
-		if (!enabled) {
-			EFX_LOG(efx, "rx queue %d disabled without a "
-				"flush event seen\n", rx_queue->queue);
-			return 0;
-		}
-	}
-
-	EFX_ERR(efx, "rx queue %d flush command timed out\n", rx_queue->queue);
-	return -ETIMEDOUT;
 }
 
 void falcon_fini_rx(struct efx_rx_queue *rx_queue)
 {
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
-	int i, rc;
 
-	/* Try and flush the rx queue. This may need to be repeated */
-	for (i = 0; i < 5; i++) {
-		rc = falcon_flush_rx_queue(rx_queue);
-		if (rc == -EAGAIN)
-			continue;
-		break;
-	}
-	if (rc) {
-		EFX_ERR(efx, "failed to flush rx queue %d\n", rx_queue->queue);
-		efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
-	}
+	/* The queue should already have been flushed */
+	WARN_ON(!rx_queue->flushed);
 
 	/* Remove RX descriptor ring from card */
 	EFX_ZERO_OWORD(rx_desc_ptr);
@@ -1007,7 +903,7 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 		is_phy_event = true;
 
 	if ((falcon_rev(efx) >= FALCON_REV_B0) &&
-	    EFX_OWORD_FIELD(*event, XG_MNT_INTR_B0))
+	    EFX_QWORD_FIELD(*event, XG_MNT_INTR_B0))
 		is_phy_event = true;
 
 	if (is_phy_event) {
@@ -1255,6 +1151,121 @@ void falcon_generate_test_event(struct efx_channel *channel, unsigned int magic)
 	falcon_generate_event(channel, &test_event);
 }
 
+/**************************************************************************
+ *
+ * Flush handling
+ *
+ **************************************************************************/
+
+
+static void falcon_poll_flush_events(struct efx_nic *efx)
+{
+	struct efx_channel *channel = &efx->channel[0];
+	struct efx_tx_queue *tx_queue;
+	struct efx_rx_queue *rx_queue;
+	unsigned int read_ptr, i;
+
+	read_ptr = channel->eventq_read_ptr;
+	for (i = 0; i < FALCON_EVQ_SIZE; ++i) {
+		efx_qword_t *event = falcon_event(channel, read_ptr);
+		int ev_code, ev_sub_code, ev_queue;
+		bool ev_failed;
+		if (!falcon_event_present(event))
+			break;
+
+		ev_code = EFX_QWORD_FIELD(*event, EV_CODE);
+		if (ev_code != DRIVER_EV_DECODE)
+			continue;
+
+		ev_sub_code = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
+		switch (ev_sub_code) {
+		case TX_DESCQ_FLS_DONE_EV_DECODE:
+			ev_queue = EFX_QWORD_FIELD(*event,
+						   DRIVER_EV_TX_DESCQ_ID);
+			if (ev_queue < EFX_TX_QUEUE_COUNT) {
+				tx_queue = efx->tx_queue + ev_queue;
+				tx_queue->flushed = true;
+			}
+			break;
+		case RX_DESCQ_FLS_DONE_EV_DECODE:
+			ev_queue = EFX_QWORD_FIELD(*event,
+						   DRIVER_EV_RX_DESCQ_ID);
+			ev_failed = EFX_QWORD_FIELD(*event,
+						    DRIVER_EV_RX_FLUSH_FAIL);
+			if (ev_queue < efx->n_rx_queues) {
+				rx_queue = efx->rx_queue + ev_queue;
+
+				/* retry the rx flush */
+				if (ev_failed)
+					falcon_flush_rx_queue(rx_queue);
+				else
+					rx_queue->flushed = true;
+			}
+			break;
+		}
+
+		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
+	}
+}
+
+/* Handle tx and rx flushes at the same time, since they run in
+ * parallel in the hardware and there's no reason for us to
+ * serialise them */
+int falcon_flush_queues(struct efx_nic *efx)
+{
+	struct efx_rx_queue *rx_queue;
+	struct efx_tx_queue *tx_queue;
+	int i;
+	bool outstanding;
+
+	/* Issue flush requests */
+	efx_for_each_tx_queue(tx_queue, efx) {
+		tx_queue->flushed = false;
+		falcon_flush_tx_queue(tx_queue);
+	}
+	efx_for_each_rx_queue(rx_queue, efx) {
+		rx_queue->flushed = false;
+		falcon_flush_rx_queue(rx_queue);
+	}
+
+	/* Poll the evq looking for flush completions. Since we're not pushing
+	 * any more rx or tx descriptors at this point, we're in no danger of
+	 * overflowing the evq whilst we wait */
+	for (i = 0; i < FALCON_FLUSH_POLL_COUNT; ++i) {
+		msleep(FALCON_FLUSH_INTERVAL);
+		falcon_poll_flush_events(efx);
+
+		/* Check if every queue has been succesfully flushed */
+		outstanding = false;
+		efx_for_each_tx_queue(tx_queue, efx)
+			outstanding |= !tx_queue->flushed;
+		efx_for_each_rx_queue(rx_queue, efx)
+			outstanding |= !rx_queue->flushed;
+		if (!outstanding)
+			return 0;
+	}
+
+	/* Mark the queues as all flushed. We're going to return failure
+	 * leading to a reset, or fake up success anyway. "flushed" now
+	 * indicates that we tried to flush. */
+	efx_for_each_tx_queue(tx_queue, efx) {
+		if (!tx_queue->flushed)
+			EFX_ERR(efx, "tx queue %d flush command timed out\n",
+				tx_queue->queue);
+		tx_queue->flushed = true;
+	}
+	efx_for_each_rx_queue(rx_queue, efx) {
+		if (!rx_queue->flushed)
+			EFX_ERR(efx, "rx queue %d flush command timed out\n",
+				rx_queue->queue);
+		rx_queue->flushed = true;
+	}
+
+	if (EFX_WORKAROUND_7803(efx))
+		return 0;
+
+	return -ETIMEDOUT;
+}
 
 /**************************************************************************
  *
@@ -1363,10 +1374,11 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 			EFX_OWORD_FMT "\n", EFX_OWORD_VAL(reg));
 	}
 
-	/* Disable DMA bus mastering on both devices */
+	/* Disable both devices */
 	pci_disable_device(efx->pci_dev);
 	if (FALCON_IS_DUAL_FUNC(efx))
 		pci_disable_device(nic_data->pci_dev2);
+	falcon_disable_interrupts(efx);
 
 	if (++n_int_errors < FALCON_MAX_INT_ERRORS) {
 		EFX_ERR(efx, "SYSTEM ERROR - reset scheduled\n");
@@ -1593,7 +1605,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
  **************************************************************************
  */
 
-#define FALCON_SPI_MAX_LEN sizeof(efx_oword_t)
+#define FALCON_SPI_MAX_LEN ((unsigned) sizeof(efx_oword_t))
 
 /* Wait for SPI command completion */
 static int falcon_spi_wait(struct efx_nic *efx)
@@ -1942,8 +1954,10 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
 
 	/* Wait for transfer to complete */
 	for (i = 0; i < 400; i++) {
-		if (*(volatile u32 *)dma_done == FALCON_STATS_DONE)
+		if (*(volatile u32 *)dma_done == FALCON_STATS_DONE) {
+			rmb(); /* Ensure the stats are valid. */
 			return 0;
+		}
 		udelay(10);
 	}
 
@@ -2758,6 +2772,8 @@ int falcon_probe_nic(struct efx_nic *efx)
 
 	/* Allocate storage for hardware specific data */
 	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
+	if (!nic_data)
+		return -ENOMEM;
 	efx->nic_data = nic_data;
 
 	/* Determine number of ports etc. */
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 30d61e4..be025ba 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -86,6 +86,7 @@ extern void falcon_fini_interrupt(struct efx_nic *efx);
 extern int falcon_probe_nic(struct efx_nic *efx);
 extern int falcon_probe_resources(struct efx_nic *efx);
 extern int falcon_init_nic(struct efx_nic *efx);
+extern int falcon_flush_queues(struct efx_nic *efx);
 extern int falcon_reset_hw(struct efx_nic *efx, enum reset_type method);
 extern void falcon_remove_resources(struct efx_nic *efx);
 extern void falcon_remove_nic(struct efx_nic *efx);
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index e319fd6..5d584b0 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -117,7 +117,6 @@
 #define SF_PRST_WIDTH 1
 #define EE_PRST_LBN 8
 #define EE_PRST_WIDTH 1
-/* See pic_mode_t for decoding of this field */
 /* These bit definitions are extrapolated from the list of numerical
  * values for STRAP_PINS.
  */
diff --git a/drivers/net/sfc/falcon_io.h b/drivers/net/sfc/falcon_io.h
index 6670cdf..c16da31 100644
--- a/drivers/net/sfc/falcon_io.h
+++ b/drivers/net/sfc/falcon_io.h
@@ -13,7 +13,6 @@
 
 #include <linux/io.h>
 #include <linux/spinlock.h>
-#include "net_driver.h"
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 0d9f68f..d401231 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -78,79 +78,7 @@ static void falcon_setup_xaui(struct efx_nic *efx)
 	falcon_write(efx, &txdrv, XX_TXDRV_CTL_REG);
 }
 
-static void falcon_hold_xaui_in_rst(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-
-	EFX_ZERO_OWORD(reg);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNA_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNB_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNC_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDND_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLAB_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLCD_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETA_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETB_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETC_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETD_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-}
-
-static int _falcon_reset_xaui_a(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-
-	falcon_hold_xaui_in_rst(efx);
-	falcon_read(efx, &reg, XX_PWR_RST_REG);
-
-	/* Follow the RAMBUS XAUI data reset sequencing
-	 * Channels A and B first: power down, reset PLL, reset, clear
-	 */
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNA_EN, 0);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNB_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLAB_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	EFX_SET_OWORD_FIELD(reg, XX_RESETA_EN, 0);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETB_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	/* Channels C and D: power down, reset PLL, reset, clear */
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNC_EN, 0);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDND_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLCD_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	EFX_SET_OWORD_FIELD(reg, XX_RESETC_EN, 0);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETD_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	/* Setup XAUI */
-	falcon_setup_xaui(efx);
-	udelay(10);
-
-	/* Take XGXS out of reset */
-	EFX_ZERO_OWORD(reg);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	return 0;
-}
-
-static int _falcon_reset_xaui_b(struct efx_nic *efx)
+int falcon_reset_xaui(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 	int count;
@@ -171,20 +99,6 @@ static int _falcon_reset_xaui_b(struct efx_nic *efx)
 	return -ETIMEDOUT;
 }
 
-int falcon_reset_xaui(struct efx_nic *efx)
-{
-	int rc;
-
-	if (EFX_WORKAROUND_9388(efx)) {
-		falcon_hold_xaui_in_rst(efx);
-		efx->phy_op->reset_xaui(efx);
-		rc = _falcon_reset_xaui_a(efx);
-	} else {
-		rc = _falcon_reset_xaui_b(efx);
-	}
-	return rc;
-}
-
 static bool falcon_xgmii_status(struct efx_nic *efx)
 {
 	efx_oword_t reg;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 567df00..cdb11fa 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -160,6 +160,7 @@ struct efx_tx_buffer {
  * @channel: The associated channel
  * @buffer: The software buffer ring
  * @txd: The hardware descriptor ring
+ * @flushed: Used when handling queue flushing
  * @read_count: Current read pointer.
  *	This is the number of buffers that have been removed from both rings.
  * @stopped: Stopped count.
@@ -192,6 +193,7 @@ struct efx_tx_queue {
 	struct efx_nic *nic;
 	struct efx_tx_buffer *buffer;
 	struct efx_special_buffer txd;
+	bool flushed;
 
 	/* Members used mainly on the completion path */
 	unsigned int read_count ____cacheline_aligned_in_smp;
@@ -260,6 +262,7 @@ struct efx_rx_buffer {
  *	the remaining space in the allocation.
  * @buf_dma_addr: Page's DMA address.
  * @buf_data: Page's host address.
+ * @flushed: Use when handling queue flushing
  */
 struct efx_rx_queue {
 	struct efx_nic *efx;
@@ -285,6 +288,7 @@ struct efx_rx_queue {
 	struct page *buf_page;
 	dma_addr_t buf_dma_addr;
 	char *buf_data;
+	bool flushed;
 };
 
 /**
@@ -470,7 +474,7 @@ enum nic_state {
  * This is the equivalent of NET_IP_ALIGN [which controls the alignment
  * of the skb->head for hardware DMA].
  */
-#if defined(__i386__) || defined(__x86_64__)
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 #define EFX_PAGE_IP_ALIGN 0
 #else
 #define EFX_PAGE_IP_ALIGN NET_IP_ALIGN
@@ -503,7 +507,6 @@ enum efx_fc_type {
  * @clear_interrupt: Clear down interrupt
  * @blink: Blink LEDs
  * @check_hw: Check hardware
- * @reset_xaui: Reset XAUI side of PHY for (software sequenced reset)
  * @mmds: MMD presence mask
  * @loopbacks: Supported loopback modes mask
  */
@@ -513,7 +516,6 @@ struct efx_phy_operations {
 	void (*reconfigure) (struct efx_nic *efx);
 	void (*clear_interrupt) (struct efx_nic *efx);
 	int (*check_hw) (struct efx_nic *efx);
-	void (*reset_xaui) (struct efx_nic *efx);
 	int (*test) (struct efx_nic *efx);
 	int mmds;
 	unsigned loopbacks;
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index b7005da..fe4e3fd 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -129,18 +129,6 @@ static int sfe4001_poweron(struct efx_nic *efx)
 	unsigned int i, j;
 	int rc;
 	u8 out;
-	efx_oword_t reg;
-
-	/* Ensure that XGXS and XAUI SerDes are held in reset */
-	EFX_POPULATE_OWORD_7(reg, XX_PWRDNA_EN, 1,
-			     XX_PWRDNB_EN, 1,
-			     XX_RSTPLLAB_EN, 1,
-			     XX_RESETA_EN, 1,
-			     XX_RESETB_EN, 1,
-			     XX_RSTXGXSRX_EN, 1,
-			     XX_RSTXGXSTX_EN, 1);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
 
 	/* Clear any previous over-temperature alert */
 	rc = i2c_smbus_read_byte_data(hwmon_client, RSL);
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 8412dbe..d507c93 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -146,8 +146,6 @@ static int tenxpress_phy_check(struct efx_nic *efx)
 	return 0;
 }
 
-static void tenxpress_reset_xaui(struct efx_nic *efx);
-
 static int tenxpress_init(struct efx_nic *efx)
 {
 	int rc, reg;
@@ -216,7 +214,10 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 {
 	int rc, reg;
 
-	EFX_TRACE(efx, "%s\n", __func__);
+	/* The XGMAC clock is driven from the SFC7101/SFT9001 312MHz clock, so
+	 * a special software reset can glitch the XGMAC sufficiently for stats
+	 * requests to fail. Since we don't ofen special_reset, just lock. */
+	spin_lock(&efx->stats_lock);
 
 	/* Initiate reset */
 	reg = mdio_clause45_read(efx, efx->mii.phy_id,
@@ -225,20 +226,22 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
 			    PMA_PMD_EXT_CTRL_REG, reg);
 
-	msleep(200);
+	mdelay(200);
 
 	/* Wait for the blocks to come out of reset */
 	rc = mdio_clause45_wait_reset_mmds(efx,
 					   TENXPRESS_REQUIRED_DEVS);
 	if (rc < 0)
-		return rc;
+		goto unlock;
 
 	/* Try and reconfigure the device */
 	rc = tenxpress_init(efx);
 	if (rc < 0)
-		return rc;
+		goto unlock;
 
-	return 0;
+unlock:
+	spin_unlock(&efx->stats_lock);
+	return rc;
 }
 
 static void tenxpress_set_bad_lp(struct efx_nic *efx, bool bad_lp)
@@ -374,8 +377,7 @@ static int tenxpress_phy_check_hw(struct efx_nic *efx)
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
 	bool link_ok;
 
-	link_ok = (phy_data->phy_mode == PHY_MODE_NORMAL &&
-		   tenxpress_link_ok(efx, true));
+	link_ok = tenxpress_link_ok(efx, true);
 
 	if (link_ok != efx->link_up)
 		falcon_xmac_sim_phy_event(efx);
@@ -428,54 +430,6 @@ void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
 			    PMA_PMD_LED_OVERR_REG, reg);
 }
 
-static void tenxpress_reset_xaui(struct efx_nic *efx)
-{
-	int phy = efx->mii.phy_id;
-	int clk_ctrl, test_select, soft_rst2;
-
-	/* Real work is done on clock_ctrl other resets are thought to be
-	 * optional but make the reset more reliable
-	 */
-
-	/* Read */
-	clk_ctrl = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
-				      PCS_CLOCK_CTRL_REG);
-	test_select = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
-					 PCS_TEST_SELECT_REG);
-	soft_rst2 = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
-				       PCS_SOFT_RST2_REG);
-
-	/* Put in reset */
-	test_select &= ~(1 << CLK312_EN_LBN);
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_TEST_SELECT_REG, test_select);
-
-	soft_rst2 &= ~((1 << XGXS_RST_N_LBN) | (1 << SERDES_RST_N_LBN));
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_SOFT_RST2_REG, soft_rst2);
-
-	clk_ctrl &= ~(1 << PLL312_RST_N_LBN);
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_CLOCK_CTRL_REG, clk_ctrl);
-	udelay(10);
-
-	/* Remove reset */
-	clk_ctrl |= (1 << PLL312_RST_N_LBN);
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_CLOCK_CTRL_REG, clk_ctrl);
-	udelay(10);
-
-	soft_rst2 |= ((1 << XGXS_RST_N_LBN) | (1 << SERDES_RST_N_LBN));
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_SOFT_RST2_REG, soft_rst2);
-	udelay(10);
-
-	test_select |= (1 << CLK312_EN_LBN);
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_TEST_SELECT_REG, test_select);
-	udelay(10);
-}
-
 static int tenxpress_phy_test(struct efx_nic *efx)
 {
 	/* BIST is automatically run after a special software reset */
@@ -488,7 +442,6 @@ struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.check_hw         = tenxpress_phy_check_hw,
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = tenxpress_phy_clear_interrupt,
-	.reset_xaui       = tenxpress_reset_xaui,
 	.test             = tenxpress_phy_test,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = TENXPRESS_LOOPBACKS,
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index cdee7c2..da3e9ff 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -516,7 +516,7 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 /* Number of bytes inserted at the start of a TSO header buffer,
  * similar to NET_IP_ALIGN.
  */
-#if defined(__i386__) || defined(__x86_64__)
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 #define TSOH_OFFSET	0
 #else
 #define TSOH_OFFSET	NET_IP_ALIGN
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index a824f59..fa7b49d 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -24,8 +24,6 @@
 #define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
 /* TX pkt parser problem with <= 16 byte TXes */
 #define EFX_WORKAROUND_9141 EFX_WORKAROUND_ALWAYS
-/* XGXS and XAUI reset sequencing in SW */
-#define EFX_WORKAROUND_9388 EFX_WORKAROUND_ALWAYS
 /* Low rate CRC errors require XAUI reset */
 #define EFX_WORKAROUND_10750 EFX_WORKAROUND_ALWAYS
 /* TX_EV_PKT_ERR can be caused by a dangling TX descriptor
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index f6edecc..276151d 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -165,7 +165,6 @@ struct efx_phy_operations falcon_xfp_phy_ops = {
 	.check_hw        = xfp_phy_check_hw,
 	.fini            = xfp_phy_fini,
 	.clear_interrupt = xfp_phy_clear_interrupt,
-	.reset_xaui      = efx_port_dummy_op_void,
 	.mmds            = XFP_REQUIRED_DEVS,
 	.loopbacks       = XFP_LOOPBACKS,
 };
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index c587162..02cc064 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -183,7 +183,7 @@ static void smc911x_reset(struct net_device *dev)
 	unsigned int reg, timeout=0, resets=1;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/*	 Take out of PM setting first */
 	if ((SMC_GET_PMT_CTRL(lp) & PMT_CTRL_READY_) == 0) {
@@ -272,7 +272,7 @@ static void smc911x_enable(struct net_device *dev)
 	unsigned mask, cfg, cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	SMC_SET_MAC_ADDR(lp, dev->dev_addr);
 
@@ -329,7 +329,7 @@ static void smc911x_shutdown(struct net_device *dev)
 	unsigned cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __func__);
 
 	/* Disable IRQ's */
 	SMC_SET_INT_EN(lp, 0);
@@ -348,7 +348,7 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int fifo_count, timeout, reg;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __func__);
 	fifo_count = SMC_GET_RX_FIFO_INF(lp) & 0xFFFF;
 	if (fifo_count <= 4) {
 		/* Manually dump the packet data */
@@ -382,7 +382,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 	unsigned char *data;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 	status = SMC_GET_RX_STS_FIFO(lp);
 	DBG(SMC_DEBUG_RX, "%s: Rx pkt len %d status 0x%08x \n",
 		dev->name, (status & 0x3fff0000) >> 16, status & 0xc000ffff);
@@ -460,7 +460,7 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 	unsigned char *buf;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n", dev->name, __func__);
 	BUG_ON(lp->pending_tx_skb == NULL);
 
 	skb = lp->pending_tx_skb;
@@ -524,7 +524,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
@@ -596,7 +596,7 @@ static void smc911x_tx(struct net_device *dev)
 	unsigned int tx_status;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 
 	/* Collect the TX status */
 	while (((SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16) != 0) {
@@ -647,7 +647,7 @@ static int smc911x_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 	SMC_GET_MII(lp, phyreg, phyaddr, phydata);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%02x, phydata=0x%04x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 	return phydata;
 }
 
@@ -661,7 +661,7 @@ static void smc911x_phy_write(struct net_device *dev, int phyaddr, int phyreg,
 	struct smc911x_local *lp = netdev_priv(dev);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SET_MII(lp, phyreg, phyaddr, phydata);
 }
@@ -676,7 +676,7 @@ static void smc911x_phy_detect(struct net_device *dev)
 	int phyaddr;
 	unsigned int cfg, id1, id2;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	lp->phy_type = 0;
 
@@ -746,7 +746,7 @@ static int smc911x_phy_fixed(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int bmcr;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/* Enter Link Disable state */
 	SMC_GET_PHY_BMCR(lp, phyaddr, bmcr);
@@ -793,7 +793,7 @@ static int smc911x_phy_reset(struct net_device *dev, int phy)
 	unsigned long flags;
 	unsigned int reg;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	reg = SMC_GET_PMT_CTRL(lp);
@@ -852,7 +852,7 @@ static void smc911x_phy_check_media(struct net_device *dev, int init)
 	int phyaddr = lp->mii.phy_id;
 	unsigned int bmcr, cr;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	if (mii_check_media(&lp->mii, netif_msg_link(lp), init)) {
 		/* duplex state has changed */
@@ -892,7 +892,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 	int status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __func__);
 
 	/*
 	 * We should not be called if phy_type is zero.
@@ -985,7 +985,7 @@ static void smc911x_phy_interrupt(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int status;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	if (lp->phy_type == 0)
 		return;
@@ -1013,7 +1013,7 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	unsigned int rx_overrun=0, cr, pkts;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -1174,8 +1174,6 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	DBG(3, "%s: Interrupt done (%d loops)\n", dev->name, 8-timeout);
-
 	return IRQ_HANDLED;
 }
 
@@ -1188,7 +1186,7 @@ smc911x_tx_dma_irq(int dma, void *data)
 	struct sk_buff *skb = lp->current_tx_skb;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: TX DMA irq handler\n", dev->name);
 	/* Clear the DMA interrupt sources */
@@ -1224,7 +1222,7 @@ smc911x_rx_dma_irq(int dma, void *data)
 	unsigned long flags;
 	unsigned int pkts;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, "%s: RX DMA irq handler\n", dev->name);
 	/* Clear the DMA interrupt sources */
 	SMC_DMA_ACK_IRQ(dev, dma);
@@ -1272,7 +1270,7 @@ static void smc911x_timeout(struct net_device *dev)
 	int status, mask;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	status = SMC_GET_INT(lp);
@@ -1310,7 +1308,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	SMC_GET_MAC_CR(lp, mcr);
@@ -1412,7 +1410,7 @@ smc911x_open(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -1420,7 +1418,7 @@ smc911x_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		PRINTK("%s: no valid ethernet hw addr\n", __FUNCTION__);
+		PRINTK("%s: no valid ethernet hw addr\n", __func__);
 		return -EINVAL;
 	}
 
@@ -1449,7 +1447,7 @@ static int smc911x_close(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1483,7 +1481,7 @@ smc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret, status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
 
@@ -1621,7 +1619,7 @@ static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 	for(timeout=10;(e2p_cmd & E2P_CMD_EPC_BUSY_) && timeout; timeout--) {
 		if (e2p_cmd & E2P_CMD_EPC_TIMEOUT_) {
 			PRINTK("%s: %s timeout waiting for EEPROM to respond\n",
-				dev->name, __FUNCTION__);
+				dev->name, __func__);
 			return -EFAULT;
 		}
 		mdelay(1);
@@ -1629,7 +1627,7 @@ static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 	}
 	if (timeout == 0) {
 		PRINTK("%s: %s timeout waiting for EEPROM CMD not busy\n",
-			dev->name, __FUNCTION__);
+			dev->name, __func__);
 		return -ETIMEDOUT;
 	}
 	return 0;
@@ -1742,7 +1740,7 @@ static int __init smc911x_findirq(struct net_device *dev)
 	int timeout = 20;
 	unsigned long cookie;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 
 	cookie = probe_irq_on();
 
@@ -1808,7 +1806,7 @@ static int __init smc911x_probe(struct net_device *dev)
 	const char *version_string;
 	unsigned long irq_flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/* First, see if the endian word is recognized */
 	val = SMC_GET_BYTE_TEST(lp);
@@ -2058,7 +2056,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	unsigned int *addr;
 	int ret;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n",  __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n",  __func__);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res) {
 		ret = -ENODEV;
@@ -2129,7 +2127,7 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 	struct smc911x_local *lp = netdev_priv(ndev);
 	struct resource *res;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
@@ -2159,7 +2157,7 @@ static int smc911x_drv_suspend(struct platform_device *dev, pm_message_t state)
 	struct net_device *ndev = platform_get_drvdata(dev);
 	struct smc911x_local *lp = netdev_priv(ndev);
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	if (ndev) {
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
@@ -2177,7 +2175,7 @@ static int smc911x_drv_resume(struct platform_device *dev)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	if (ndev) {
 		struct smc911x_local *lp = netdev_priv(ndev);
 
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 24768c1..aa69937 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -270,7 +270,7 @@ static void smc_reset(struct net_device *dev)
 	unsigned int ctl, cfg;
 	struct sk_buff *pending_skb;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/* Disable all interrupts, block TX tasklet */
 	spin_lock_irq(&lp->lock);
@@ -363,7 +363,7 @@ static void smc_enable(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	int mask;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/* see the header file for options in TCR/RCR DEFAULT */
 	SMC_SELECT_BANK(lp, 0);
@@ -397,7 +397,7 @@ static void smc_shutdown(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	struct sk_buff *pending_skb;
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	/* no more interrupts for me */
 	spin_lock_irq(&lp->lock);
@@ -430,7 +430,7 @@ static inline void  smc_rcv(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	unsigned int packet_number, status, packet_len;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	packet_number = SMC_GET_RXFIFO(lp);
 	if (unlikely(packet_number & RXFIFO_REMPTY)) {
@@ -577,7 +577,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 	unsigned int packet_no, len;
 	unsigned char *buf;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	if (!smc_special_trylock(&lp->lock)) {
 		netif_stop_queue(dev);
@@ -662,7 +662,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	unsigned int numPages, poll_count, status;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
@@ -734,7 +734,7 @@ static void smc_tx(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	unsigned int saved_packet, packet_no, tx_status, pkt_len;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	/* If the TX FIFO is empty then nothing to do */
 	packet_no = SMC_GET_TXFIFO(lp);
@@ -856,7 +856,7 @@ static int smc_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 	SMC_SET_MII(lp, SMC_GET_MII(lp) & ~(MII_MCLK|MII_MDOE|MII_MDO));
 
 	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SELECT_BANK(lp, 2);
 	return phydata;
@@ -883,7 +883,7 @@ static void smc_phy_write(struct net_device *dev, int phyaddr, int phyreg,
 	SMC_SET_MII(lp, SMC_GET_MII(lp) & ~(MII_MCLK|MII_MDOE|MII_MDO));
 
 	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SELECT_BANK(lp, 2);
 }
@@ -896,7 +896,7 @@ static void smc_phy_detect(struct net_device *dev)
 	struct smc_local *lp = netdev_priv(dev);
 	int phyaddr;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	lp->phy_type = 0;
 
@@ -935,7 +935,7 @@ static int smc_phy_fixed(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int bmcr, cfg1;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	/* Enter Link Disable state */
 	cfg1 = smc_phy_read(dev, phyaddr, PHY_CFG1_REG);
@@ -1168,7 +1168,7 @@ static void smc_phy_interrupt(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int phy18;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	if (lp->phy_type == 0)
 		return;
@@ -1236,7 +1236,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 	int status, mask, timeout, card_stats;
 	int saved_pointer;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	spin_lock(&lp->lock);
 
@@ -1358,7 +1358,7 @@ static void smc_timeout(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	int status, mask, eph_st, meminfo, fifo;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	spin_lock_irq(&lp->lock);
 	status = SMC_GET_INT(lp);
@@ -1402,7 +1402,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 	unsigned char multicast_table[8];
 	int update_multicast = 0;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	if (dev->flags & IFF_PROMISC) {
 		DBG(2, "%s: RCR_PRMS\n", dev->name);
@@ -1505,7 +1505,7 @@ smc_open(struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -1513,7 +1513,7 @@ smc_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		PRINTK("%s: no valid ethernet hw addr\n", __FUNCTION__);
+		PRINTK("%s: no valid ethernet hw addr\n", __func__);
 		return -EINVAL;
 	}
 
@@ -1557,7 +1557,7 @@ static int smc_close(struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1700,7 +1700,7 @@ static int __init smc_findirq(struct smc_local *lp)
 	int timeout = 20;
 	unsigned long cookie;
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	cookie = probe_irq_on();
 
@@ -1778,7 +1778,7 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	const char *version_string;
 	DECLARE_MAC_BUF(mac);
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	/* First, see if the high byte is 0x33 */
 	val = SMC_CURRENT_BANK(lp);
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 7d5561b..f860ea1 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -409,6 +409,7 @@ static int  change_mtu(struct net_device *dev, int new_mtu);
 static int  eeprom_read(void __iomem *ioaddr, int location);
 static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
+static int  mdio_wait_link(struct net_device *dev, int wait);
 static int  netdev_open(struct net_device *dev);
 static void check_duplex(struct net_device *dev);
 static void netdev_timer(unsigned long data);
@@ -785,6 +786,24 @@ static void mdio_write(struct net_device *dev, int phy_id, int location, int val
 	return;
 }
 
+static int mdio_wait_link(struct net_device *dev, int wait)
+{
+	int bmsr;
+	int phy_id;
+	struct netdev_private *np;
+
+	np = netdev_priv(dev);
+	phy_id = np->phys[0];
+
+	do {
+		bmsr = mdio_read(dev, phy_id, MII_BMSR);
+		if (bmsr & 0x0004)
+			return 0;
+		mdelay(1);
+	} while (--wait > 0);
+	return -1;
+}
+
 static int netdev_open(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -1393,41 +1412,51 @@ static void netdev_error(struct net_device *dev, int intr_status)
 	int speed;
 
 	if (intr_status & LinkChange) {
-		if (np->an_enable) {
-			mii_advertise = mdio_read (dev, np->phys[0], MII_ADVERTISE);
-			mii_lpa= mdio_read (dev, np->phys[0], MII_LPA);
-			mii_advertise &= mii_lpa;
-			printk (KERN_INFO "%s: Link changed: ", dev->name);
-			if (mii_advertise & ADVERTISE_100FULL) {
-				np->speed = 100;
-				printk ("100Mbps, full duplex\n");
-			} else if (mii_advertise & ADVERTISE_100HALF) {
-				np->speed = 100;
-				printk ("100Mbps, half duplex\n");
-			} else if (mii_advertise & ADVERTISE_10FULL) {
-				np->speed = 10;
-				printk ("10Mbps, full duplex\n");
-			} else if (mii_advertise & ADVERTISE_10HALF) {
-				np->speed = 10;
-				printk ("10Mbps, half duplex\n");
-			} else
-				printk ("\n");
+		if (mdio_wait_link(dev, 10) == 0) {
+			printk(KERN_INFO "%s: Link up\n", dev->name);
+			if (np->an_enable) {
+				mii_advertise = mdio_read(dev, np->phys[0],
+							   MII_ADVERTISE);
+				mii_lpa = mdio_read(dev, np->phys[0], MII_LPA);
+				mii_advertise &= mii_lpa;
+				printk(KERN_INFO "%s: Link changed: ",
+					dev->name);
+				if (mii_advertise & ADVERTISE_100FULL) {
+					np->speed = 100;
+					printk("100Mbps, full duplex\n");
+				} else if (mii_advertise & ADVERTISE_100HALF) {
+					np->speed = 100;
+					printk("100Mbps, half duplex\n");
+				} else if (mii_advertise & ADVERTISE_10FULL) {
+					np->speed = 10;
+					printk("10Mbps, full duplex\n");
+				} else if (mii_advertise & ADVERTISE_10HALF) {
+					np->speed = 10;
+					printk("10Mbps, half duplex\n");
+				} else
+					printk("\n");
 
+			} else {
+				mii_ctl = mdio_read(dev, np->phys[0], MII_BMCR);
+				speed = (mii_ctl & BMCR_SPEED100) ? 100 : 10;
+				np->speed = speed;
+				printk(KERN_INFO "%s: Link changed: %dMbps ,",
+					dev->name, speed);
+				printk("%s duplex.\n",
+					(mii_ctl & BMCR_FULLDPLX) ?
+						"full" : "half");
+			}
+			check_duplex(dev);
+			if (np->flowctrl && np->mii_if.full_duplex) {
+				iowrite16(ioread16(ioaddr + MulticastFilter1+2) | 0x0200,
+					ioaddr + MulticastFilter1+2);
+				iowrite16(ioread16(ioaddr + MACCtrl0) | EnbFlowCtrl,
+					ioaddr + MACCtrl0);
+			}
+			netif_carrier_on(dev);
 		} else {
-			mii_ctl = mdio_read (dev, np->phys[0], MII_BMCR);
-			speed = (mii_ctl & BMCR_SPEED100) ? 100 : 10;
-			np->speed = speed;
-			printk (KERN_INFO "%s: Link changed: %dMbps ,",
-				dev->name, speed);
-			printk ("%s duplex.\n", (mii_ctl & BMCR_FULLDPLX) ?
-				"full" : "half");
-		}
-		check_duplex (dev);
-		if (np->flowctrl && np->mii_if.full_duplex) {
-			iowrite16(ioread16(ioaddr + MulticastFilter1+2) | 0x0200,
-				ioaddr + MulticastFilter1+2);
-			iowrite16(ioread16(ioaddr + MACCtrl0) | EnbFlowCtrl,
-				ioaddr + MACCtrl0);
+			printk(KERN_INFO "%s: Link down\n", dev->name);
+			netif_carrier_off(dev);
 		}
 	}
 	if (intr_status & StatsMax) {
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index 7db48f1..efaf84d 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -539,22 +539,22 @@ struct txd_desc {
 
 #define ERR(fmt, args...) printk(KERN_ERR fmt, ## args)
 #define DBG2(fmt, args...)	\
-	printk(KERN_ERR  "%s:%-5d: " fmt, __FUNCTION__, __LINE__, ## args)
+	printk(KERN_ERR  "%s:%-5d: " fmt, __func__, __LINE__, ## args)
 
 #define BDX_ASSERT(x) BUG_ON(x)
 
 #ifdef DEBUG
 
 #define ENTER          do { \
-	printk(KERN_ERR  "%s:%-5d: ENTER\n", __FUNCTION__, __LINE__); \
+	printk(KERN_ERR  "%s:%-5d: ENTER\n", __func__, __LINE__); \
 } while (0)
 
 #define RET(args...)   do { \
-	printk(KERN_ERR  "%s:%-5d: RETURN\n", __FUNCTION__, __LINE__); \
+	printk(KERN_ERR  "%s:%-5d: RETURN\n", __func__, __LINE__); \
 return args; } while (0)
 
 #define DBG(fmt, args...)	\
-	printk(KERN_ERR  "%s:%-5d: " fmt, __FUNCTION__, __LINE__, ## args)
+	printk(KERN_ERR  "%s:%-5d: " fmt, __func__, __LINE__, ## args)
 #else
 #define ENTER         do {  } while (0)
 #define RET(args...)   return args
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 43fde99..eb1da6f 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -263,7 +263,7 @@ static inline void tsi108_write_tbi(struct tsi108_prv_data *data,
 			return;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+	printk(KERN_ERR "%s function time out \n", __func__);
 }
 
 static int mii_speed(struct mii_if_info *mii)
@@ -1059,7 +1059,7 @@ static void tsi108_stop_ethernet(struct net_device *dev)
 			return;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+	printk(KERN_ERR "%s function time out \n", __func__);
 }
 
 static void tsi108_reset_ether(struct tsi108_prv_data * data)
@@ -1244,7 +1244,7 @@ static void tsi108_init_phy(struct net_device *dev)
 		udelay(10);
 	}
 	if (i == 0)
-		printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+		printk(KERN_ERR "%s function time out \n", __func__);
 
 	if (data->phy_type == TSI108_PHY_BCM54XX) {
 		tsi108_write_mii(data, 0x09, 0x0300);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 8f944e5..c87747b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -400,7 +400,7 @@ static struct enet_addr_container *get_enet_addr_container(void)
 	enet_addr_cont = kmalloc(sizeof(struct enet_addr_container), GFP_KERNEL);
 	if (!enet_addr_cont) {
 		ugeth_err("%s: No memory for enet_addr_container object.",
-			  __FUNCTION__);
+			  __func__);
 		return NULL;
 	}
 
@@ -427,7 +427,7 @@ static int hw_add_addr_in_paddr(struct ucc_geth_private *ugeth,
 	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
 
 	if (!(paddr_num < NUM_OF_PADDRS)) {
-		ugeth_warn("%s: Illegal paddr_num.", __FUNCTION__);
+		ugeth_warn("%s: Illegal paddr_num.", __func__);
 		return -EINVAL;
 	}
 
@@ -447,7 +447,7 @@ static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 
 	if (!(paddr_num < NUM_OF_PADDRS)) {
-		ugeth_warn("%s: Illagel paddr_num.", __FUNCTION__);
+		ugeth_warn("%s: Illagel paddr_num.", __func__);
 		return -EINVAL;
 	}
 
@@ -1441,7 +1441,7 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	u32 upsmr, maccfg2, tbiBaseAddress;
 	u16 value;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	ug_info = ugeth->ug_info;
 	ug_regs = ugeth->ug_regs;
@@ -1504,7 +1504,7 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	if (ret_val != 0) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Preamble length must be between 3 and 7 inclusive.",
-			     __FUNCTION__);
+			     __func__);
 		return ret_val;
 	}
 
@@ -1744,7 +1744,7 @@ static int ugeth_enable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+			ugeth_err("%s: ucc_num out of range.", __func__);
 		return -EINVAL;
 	}
 
@@ -1773,7 +1773,7 @@ static int ugeth_disable(struct ucc_geth_private * ugeth, enum comm_dir mode)
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+			ugeth_err("%s: ucc_num out of range.", __func__);
 		return -EINVAL;
 	}
 
@@ -2062,7 +2062,7 @@ static int ugeth_82xx_filtering_add_addr_in_paddr(struct ucc_geth_private *ugeth
 		ugeth_warn
 		    ("%s: multicast address added to paddr will have no "
 		     "effect - is this what you wanted?",
-		     __FUNCTION__);
+		     __func__);
 
 	ugeth->indAddrRegUsed[paddr_num] = 1;	/* mark this paddr as used */
 	/* store address in our database */
@@ -2278,7 +2278,7 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	struct phy_device *phydev = ugeth->phydev;
 	u32 tempval;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	/* Disable the controller */
 	ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
@@ -2315,7 +2315,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Bad memory partition value.",
-					__FUNCTION__);
+					__func__);
 		return -EINVAL;
 	}
 
@@ -2327,7 +2327,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 			if (netif_msg_probe(ugeth))
 				ugeth_err
 				    ("%s: Rx BD ring length must be multiple of 4, no smaller than 8.",
-					__FUNCTION__);
+					__func__);
 			return -EINVAL;
 		}
 	}
@@ -2338,7 +2338,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 			if (netif_msg_probe(ugeth))
 				ugeth_err
 				    ("%s: Tx BD ring length must be no smaller than 2.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2349,21 +2349,21 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		if (netif_msg_probe(ugeth))
 			ugeth_err
 			    ("%s: max_rx_buf_length must be non-zero multiple of 128.",
-			     __FUNCTION__);
+			     __func__);
 		return -EINVAL;
 	}
 
 	/* num Tx queues */
 	if (ug_info->numQueuesTx > NUM_TX_QUEUES) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: number of tx queues too large.", __FUNCTION__);
+			ugeth_err("%s: number of tx queues too large.", __func__);
 		return -EINVAL;
 	}
 
 	/* num Rx queues */
 	if (ug_info->numQueuesRx > NUM_RX_QUEUES) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: number of rx queues too large.", __FUNCTION__);
+			ugeth_err("%s: number of rx queues too large.", __func__);
 		return -EINVAL;
 	}
 
@@ -2374,7 +2374,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 				ugeth_err
 				    ("%s: VLAN priority table entry must not be"
 					" larger than number of Rx queues.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2386,7 +2386,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 				ugeth_err
 				    ("%s: IP priority table entry must not be"
 					" larger than number of Rx queues.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2394,7 +2394,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	if (ug_info->cam && !ug_info->ecamptr) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: If cam mode is chosen, must supply cam ptr.",
-				  __FUNCTION__);
+				  __func__);
 		return -EINVAL;
 	}
 
@@ -2404,7 +2404,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Number of station addresses greater than 1 "
 				  "not allowed in extended parsing mode.",
-				  __FUNCTION__);
+				  __func__);
 		return -EINVAL;
 	}
 
@@ -2418,7 +2418,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* Initialize the general fast UCC block. */
 	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
+			ugeth_err("%s: Failed to init uccf.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2448,7 +2448,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	u8 __iomem *endOfRing;
 	u8 numThreadsRxNumerical, numThreadsTxNumerical;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 	uccf = ugeth->uccf;
 	ug_info = ugeth->ug_info;
 	uf_info = &ug_info->uf_info;
@@ -2474,7 +2474,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	default:
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Bad number of Rx threads value.",
-				       	__FUNCTION__);
+				       	__func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2499,7 +2499,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	default:
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Bad number of Tx threads value.",
-				       	__FUNCTION__);
+				       	__func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2553,7 +2553,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ret_val != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: IPGIFG initialization parameter too large.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -2571,7 +2571,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ret_val != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Half Duplex initialization parameter too large.",
-			  __FUNCTION__);
+			  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -2626,7 +2626,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				    ("%s: Can not allocate memory for Tx bd rings.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2662,7 +2662,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				    ("%s: Can not allocate memory for Rx bd rings.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2678,7 +2678,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (ugeth->tx_skbuff[j] == NULL) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Could not allocate tx_skbuff",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2710,7 +2710,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (ugeth->rx_skbuff[j] == NULL) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Could not allocate rx_skbuff",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2744,7 +2744,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2767,7 +2767,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2797,7 +2797,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2841,7 +2841,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				 ("%s: Can not allocate DPRAM memory for p_scheduler.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2892,7 +2892,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				ugeth_err
 				    ("%s: Can not allocate DPRAM memory for"
 					" p_tx_fw_statistics_pram.",
-				       	__FUNCTION__);
+				       	__func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2932,7 +2932,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2954,7 +2954,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2978,7 +2978,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 					("%s: Can not allocate DPRAM memory for"
-					" p_rx_fw_statistics_pram.", __FUNCTION__);
+					" p_rx_fw_statistics_pram.", __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -3001,7 +3001,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for"
-				" p_rx_irq_coalescing_tbl.", __FUNCTION__);
+				" p_rx_irq_coalescing_tbl.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3070,7 +3070,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3147,7 +3147,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (!ug_info->extendedFilteringChainPointer) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Null Extended Filtering Chain Pointer.",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -EINVAL;
 		}
@@ -3161,7 +3161,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 					("%s: Can not allocate DPRAM memory for"
-					" p_exf_glbl_param.", __FUNCTION__);
+					" p_exf_glbl_param.", __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -3209,7 +3209,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate memory for"
-				" p_UccInitEnetParamShadows.", __FUNCTION__);
+				" p_UccInitEnetParamShadows.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3244,7 +3244,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Invalid largest External Lookup Key Size.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 	}
@@ -3271,7 +3271,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		ug_info->riscRx, 1)) != 0) {
 		if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-					__FUNCTION__);
+					__func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3287,7 +3287,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				    ug_info->riscTx, 0)) != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3297,7 +3297,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if ((ret_val = rx_bd_buffer_set(ugeth, (u8) i)) != 0) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Can not fill Rx bds with buffers.",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return ret_val;
 		}
@@ -3309,7 +3309,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3360,7 +3360,7 @@ static void ucc_geth_timeout(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	dev->stats.tx_errors++;
 
@@ -3386,7 +3386,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 bd_status;
 	u8 txQ = 0;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	spin_lock_irq(&ugeth->lock);
 
@@ -3459,7 +3459,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 	u8 *bdBuffer;
 	struct net_device *dev;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	dev = ugeth->dev;
 
@@ -3481,7 +3481,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		    (bd_status & R_ERRORS_FATAL)) {
 			if (netif_msg_rx_err(ugeth))
 				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
-					   __FUNCTION__, __LINE__, (u32) skb);
+					   __func__, __LINE__, (u32) skb);
 			if (skb)
 				dev_kfree_skb_any(skb);
 
@@ -3507,7 +3507,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		skb = get_new_skb(ugeth, bd);
 		if (!skb) {
 			if (netif_msg_rx_err(ugeth))
-				ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
+				ugeth_warn("%s: No Rx Data Buffer", __func__);
 			dev->stats.rx_dropped++;
 			break;
 		}
@@ -3613,7 +3613,7 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	register u32 tx_mask;
 	u8 i;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	uccf = ugeth->uccf;
 	ug_info = ugeth->ug_info;
@@ -3683,13 +3683,13 @@ static int ucc_geth_open(struct net_device *dev)
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	int err;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	/* Test station address */
 	if (dev->dev_addr[0] & ENET_GROUP_ADDR) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Multicast address used for station address"
-				  " - is this what you wanted?", __FUNCTION__);
+				  " - is this what you wanted?", __func__);
 		return -EINVAL;
 	}
 
@@ -3772,7 +3772,7 @@ static int ucc_geth_close(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	napi_disable(&ugeth->napi);
 
@@ -3840,7 +3840,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		PHY_INTERFACE_MODE_TBI, PHY_INTERFACE_MODE_RTBI,
 	};
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	prop = of_get_property(np, "cell-index", NULL);
 	if (!prop) {
@@ -3857,7 +3857,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	if (ug_info == NULL) {
 		if (netif_msg_probe(&debug))
 			ugeth_err("%s: [%d] Missing additional data!",
-				       	__FUNCTION__, ucc_num);
+				       	__func__, ucc_num);
 		return -ENODEV;
 	}
 
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 6e42b5a..78001f1 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -92,9 +92,6 @@
 
 #define	HSO_NET_TX_TIMEOUT		(HZ*10)
 
-/* Serial port defines and structs. */
-#define HSO_SERIAL_FLAG_RX_SENT		0
-
 #define HSO_SERIAL_MAGIC		0x48534f31
 
 /* Number of ttys to handle */
@@ -179,6 +176,12 @@ struct hso_net {
 	unsigned long flags;
 };
 
+enum rx_ctrl_state{
+	RX_IDLE,
+	RX_SENT,
+	RX_PENDING
+};
+
 struct hso_serial {
 	struct hso_device *parent;
 	int magic;
@@ -205,7 +208,7 @@ struct hso_serial {
 	struct usb_endpoint_descriptor *in_endp;
 	struct usb_endpoint_descriptor *out_endp;
 
-	unsigned long flags;
+	enum rx_ctrl_state rx_state;
 	u8 rts_state;
 	u8 dtr_state;
 	unsigned tx_urb_used:1;
@@ -216,6 +219,15 @@ struct hso_serial {
 	spinlock_t serial_lock;
 
 	int (*write_data) (struct hso_serial *serial);
+	/* Hacks required to get flow control
+	 * working on the serial receive buffers
+	 * so as not to drop characters on the floor.
+	 */
+	int  curr_rx_urb_idx;
+	u16  curr_rx_urb_offset;
+	u8   rx_urb_filled[MAX_RX_URBS];
+	struct tasklet_struct unthrottle_tasklet;
+	struct work_struct    retry_unthrottle_workqueue;
 };
 
 struct hso_device {
@@ -271,7 +283,7 @@ struct hso_device {
 static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
 			       unsigned int set, unsigned int clear);
 static void ctrl_callback(struct urb *urb);
-static void put_rxbuf_data(struct urb *urb, struct hso_serial *serial);
+static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial);
 static void hso_kick_transmit(struct hso_serial *serial);
 /* Helper functions */
 static int hso_mux_submit_intr_urb(struct hso_shared_int *mux_int,
@@ -287,6 +299,8 @@ static int hso_start_net_device(struct hso_device *hso_dev);
 static void hso_free_shared_int(struct hso_shared_int *shared_int);
 static int hso_stop_net_device(struct hso_device *hso_dev);
 static void hso_serial_ref_free(struct kref *ref);
+static void hso_std_serial_read_bulk_callback(struct urb *urb);
+static int hso_mux_serial_read(struct hso_serial *serial);
 static void async_get_intf(struct work_struct *data);
 static void async_put_intf(struct work_struct *data);
 static int hso_put_activity(struct hso_device *hso_dev);
@@ -458,6 +472,17 @@ static ssize_t hso_sysfs_show_porttype(struct device *dev,
 }
 static DEVICE_ATTR(hsotype, S_IRUGO, hso_sysfs_show_porttype, NULL);
 
+static int hso_urb_to_index(struct hso_serial *serial, struct urb *urb)
+{
+	int idx;
+
+	for (idx = 0; idx < serial->num_rx_urbs; idx++)
+		if (serial->rx_urb[idx] == urb)
+			return idx;
+	dev_err(serial->parent->dev, "hso_urb_to_index failed\n");
+	return -1;
+}
+
 /* converts mux value to a port spec value */
 static u32 hso_mux_to_port(int mux)
 {
@@ -1039,6 +1064,158 @@ static void _hso_serial_set_termios(struct tty_struct *tty,
 	return;
 }
 
+static void hso_resubmit_rx_bulk_urb(struct hso_serial *serial, struct urb *urb)
+{
+	int result;
+#ifdef CONFIG_HSO_AUTOPM
+	usb_mark_last_busy(urb->dev);
+#endif
+	/* We are done with this URB, resubmit it. Prep the USB to wait for
+	 * another frame */
+	usb_fill_bulk_urb(urb, serial->parent->usb,
+			  usb_rcvbulkpipe(serial->parent->usb,
+					  serial->in_endp->
+					  bEndpointAddress & 0x7F),
+			  urb->transfer_buffer, serial->rx_data_length,
+			  hso_std_serial_read_bulk_callback, serial);
+	/* Give this to the USB subsystem so it can tell us when more data
+	 * arrives. */
+	result = usb_submit_urb(urb, GFP_ATOMIC);
+	if (result) {
+		dev_err(&urb->dev->dev, "%s failed submit serial rx_urb %d\n",
+			__func__, result);
+	}
+}
+
+
+
+
+static void put_rxbuf_data_and_resubmit_bulk_urb(struct hso_serial *serial)
+{
+	int count;
+	struct urb *curr_urb;
+
+	while (serial->rx_urb_filled[serial->curr_rx_urb_idx]) {
+		curr_urb = serial->rx_urb[serial->curr_rx_urb_idx];
+		count = put_rxbuf_data(curr_urb, serial);
+		if (count == -1)
+			return;
+		if (count == 0) {
+			serial->curr_rx_urb_idx++;
+			if (serial->curr_rx_urb_idx >= serial->num_rx_urbs)
+				serial->curr_rx_urb_idx = 0;
+			hso_resubmit_rx_bulk_urb(serial, curr_urb);
+		}
+	}
+}
+
+static void put_rxbuf_data_and_resubmit_ctrl_urb(struct hso_serial *serial)
+{
+	int count = 0;
+	struct urb *urb;
+
+	urb = serial->rx_urb[0];
+	if (serial->open_count > 0) {
+		count = put_rxbuf_data(urb, serial);
+		if (count == -1)
+			return;
+	}
+	/* Re issue a read as long as we receive data. */
+
+	if (count == 0 && ((urb->actual_length != 0) ||
+			   (serial->rx_state == RX_PENDING))) {
+		serial->rx_state = RX_SENT;
+		hso_mux_serial_read(serial);
+	} else
+		serial->rx_state = RX_IDLE;
+}
+
+
+/* read callback for Diag and CS port */
+static void hso_std_serial_read_bulk_callback(struct urb *urb)
+{
+	struct hso_serial *serial = urb->context;
+	int status = urb->status;
+
+	/* sanity check */
+	if (!serial) {
+		D1("serial == NULL");
+		return;
+	} else if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+
+	D4("\n--- Got serial_read_bulk callback %02x ---", status);
+	D1("Actual length = %d\n", urb->actual_length);
+	DUMP1(urb->transfer_buffer, urb->actual_length);
+
+	/* Anyone listening? */
+	if (serial->open_count == 0)
+		return;
+
+	if (status == 0) {
+		if (serial->parent->port_spec & HSO_INFO_CRC_BUG) {
+			u32 rest;
+			u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
+			rest =
+			    urb->actual_length %
+			    serial->in_endp->wMaxPacketSize;
+			if (((rest == 5) || (rest == 6))
+			    && !memcmp(((u8 *) urb->transfer_buffer) +
+				       urb->actual_length - 4, crc_check, 4)) {
+				urb->actual_length -= 4;
+			}
+		}
+		/* Valid data, handle RX data */
+		spin_lock(&serial->serial_lock);
+		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 1;
+		put_rxbuf_data_and_resubmit_bulk_urb(serial);
+		spin_unlock(&serial->serial_lock);
+	} else if (status == -ENOENT || status == -ECONNRESET) {
+		/* Unlinked - check for throttled port. */
+		D2("Port %d, successfully unlinked urb", serial->minor);
+		spin_lock(&serial->serial_lock);
+		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 0;
+		hso_resubmit_rx_bulk_urb(serial, urb);
+		spin_unlock(&serial->serial_lock);
+	} else {
+		D2("Port %d, status = %d for read urb", serial->minor, status);
+		return;
+	}
+}
+
+/*
+ * This needs to be a tasklet otherwise we will
+ * end up recursively calling this function.
+ */
+void hso_unthrottle_tasklet(struct hso_serial *serial)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&serial->serial_lock, flags);
+	if ((serial->parent->port_spec & HSO_INTF_MUX))
+		put_rxbuf_data_and_resubmit_ctrl_urb(serial);
+	else
+		put_rxbuf_data_and_resubmit_bulk_urb(serial);
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+}
+
+static	void hso_unthrottle(struct tty_struct *tty)
+{
+	struct hso_serial *serial = get_serial_by_tty(tty);
+
+	tasklet_hi_schedule(&serial->unthrottle_tasklet);
+}
+
+void hso_unthrottle_workfunc(struct work_struct *work)
+{
+	struct hso_serial *serial =
+	    container_of(work, struct hso_serial,
+			 retry_unthrottle_workqueue);
+	hso_unthrottle_tasklet(serial);
+}
+
 /* open the requested serial port */
 static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 {
@@ -1064,13 +1241,18 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 	tty->driver_data = serial;
 	serial->tty = tty;
 
-	/* check for port allready opened, if not set the termios */
+	/* check for port already opened, if not set the termios */
 	serial->open_count++;
 	if (serial->open_count == 1) {
 		tty->low_latency = 1;
-		serial->flags = 0;
+		serial->rx_state = RX_IDLE;
 		/* Force default termio settings */
 		_hso_serial_set_termios(tty, NULL);
+		tasklet_init(&serial->unthrottle_tasklet,
+			     (void (*)(unsigned long))hso_unthrottle_tasklet,
+			     (unsigned long)serial);
+		INIT_WORK(&serial->retry_unthrottle_workqueue,
+			  hso_unthrottle_workfunc);
 		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
 		if (result) {
 			hso_stop_serial_device(serial->parent);
@@ -1117,9 +1299,13 @@ static void hso_serial_close(struct tty_struct *tty, struct file *filp)
 		}
 		if (!usb_gone)
 			hso_stop_serial_device(serial->parent);
+		tasklet_kill(&serial->unthrottle_tasklet);
+		cancel_work_sync(&serial->retry_unthrottle_workqueue);
 	}
+
 	if (!usb_gone)
 		usb_autopm_put_interface(serial->parent->interface);
+
 	mutex_unlock(&serial->parent->mutex);
 }
 
@@ -1422,15 +1608,21 @@ static void intr_callback(struct urb *urb)
 								   (1 << i));
 			if (serial != NULL) {
 				D1("Pending read interrupt on port %d\n", i);
-				if (!test_and_set_bit(HSO_SERIAL_FLAG_RX_SENT,
-						      &serial->flags)) {
+				spin_lock(&serial->serial_lock);
+				if (serial->rx_state == RX_IDLE) {
 					/* Setup and send a ctrl req read on
 					 * port i */
-					hso_mux_serial_read(serial);
+				if (!serial->rx_urb_filled[0]) {
+						serial->rx_state = RX_SENT;
+						hso_mux_serial_read(serial);
+					} else
+						serial->rx_state = RX_PENDING;
+
 				} else {
 					D1("Already pending a read on "
 					   "port %d\n", i);
 				}
+				spin_unlock(&serial->serial_lock);
 			}
 		}
 	}
@@ -1532,16 +1724,10 @@ static void ctrl_callback(struct urb *urb)
 	if (req->bRequestType ==
 	    (USB_DIR_IN | USB_TYPE_OPTION_VENDOR | USB_RECIP_INTERFACE)) {
 		/* response to a read command */
-		if (serial->open_count > 0) {
-			/* handle RX data the normal way */
-			put_rxbuf_data(urb, serial);
-		}
-
-		/* Re issue a read as long as we receive data. */
-		if (urb->actual_length != 0)
-			hso_mux_serial_read(serial);
-		else
-			clear_bit(HSO_SERIAL_FLAG_RX_SENT, &serial->flags);
+		serial->rx_urb_filled[0] = 1;
+		spin_lock(&serial->serial_lock);
+		put_rxbuf_data_and_resubmit_ctrl_urb(serial);
+		spin_unlock(&serial->serial_lock);
 	} else {
 		hso_put_activity(serial->parent);
 		if (serial->tty)
@@ -1552,91 +1738,42 @@ static void ctrl_callback(struct urb *urb)
 }
 
 /* handle RX data for serial port */
-static void put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
+static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
 {
 	struct tty_struct *tty = serial->tty;
-
+	int write_length_remaining = 0;
+	int curr_write_len;
 	/* Sanity check */
 	if (urb == NULL || serial == NULL) {
 		D1("serial = NULL");
-		return;
+		return -2;
 	}
 
 	/* Push data to tty */
-	if (tty && urb->actual_length) {
+	if (tty) {
+		write_length_remaining = urb->actual_length -
+			serial->curr_rx_urb_offset;
 		D1("data to push to tty");
-		tty_insert_flip_string(tty, urb->transfer_buffer,
-				       urb->actual_length);
-		tty_flip_buffer_push(tty);
-	}
-}
-
-/* read callback for Diag and CS port */
-static void hso_std_serial_read_bulk_callback(struct urb *urb)
-{
-	struct hso_serial *serial = urb->context;
-	int result;
-	int status = urb->status;
-
-	/* sanity check */
-	if (!serial) {
-		D1("serial == NULL");
-		return;
-	} else if (status) {
-		log_usb_status(status, __func__);
-		return;
-	}
-
-	D4("\n--- Got serial_read_bulk callback %02x ---", status);
-	D1("Actual length = %d\n", urb->actual_length);
-	DUMP1(urb->transfer_buffer, urb->actual_length);
-
-	/* Anyone listening? */
-	if (serial->open_count == 0)
-		return;
-
-	if (status == 0) {
-		if (serial->parent->port_spec & HSO_INFO_CRC_BUG) {
-			u32 rest;
-			u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
-			rest =
-			    urb->actual_length %
-			    serial->in_endp->wMaxPacketSize;
-			if (((rest == 5) || (rest == 6))
-			    && !memcmp(((u8 *) urb->transfer_buffer) +
-				       urb->actual_length - 4, crc_check, 4)) {
-				urb->actual_length -= 4;
-			}
+		while (write_length_remaining) {
+			if (test_bit(TTY_THROTTLED, &tty->flags))
+				return -1;
+			curr_write_len =  tty_insert_flip_string
+				(tty, urb->transfer_buffer +
+				 serial->curr_rx_urb_offset,
+				 write_length_remaining);
+			serial->curr_rx_urb_offset += curr_write_len;
+			write_length_remaining -= curr_write_len;
+			tty_flip_buffer_push(tty);
 		}
-		/* Valid data, handle RX data */
-		put_rxbuf_data(urb, serial);
-	} else if (status == -ENOENT || status == -ECONNRESET) {
-		/* Unlinked - check for throttled port. */
-		D2("Port %d, successfully unlinked urb", serial->minor);
-	} else {
-		D2("Port %d, status = %d for read urb", serial->minor, status);
-		return;
 	}
-
-	usb_mark_last_busy(urb->dev);
-
-	/* We are done with this URB, resubmit it. Prep the USB to wait for
-	 * another frame */
-	usb_fill_bulk_urb(urb, serial->parent->usb,
-			  usb_rcvbulkpipe(serial->parent->usb,
-					  serial->in_endp->
-					  bEndpointAddress & 0x7F),
-			  urb->transfer_buffer, serial->rx_data_length,
-			  hso_std_serial_read_bulk_callback, serial);
-	/* Give this to the USB subsystem so it can tell us when more data
-	 * arrives. */
-	result = usb_submit_urb(urb, GFP_ATOMIC);
-	if (result) {
-		dev_err(&urb->dev->dev, "%s failed submit serial rx_urb %d",
-			__func__, result);
+	if (write_length_remaining == 0) {
+		serial->curr_rx_urb_offset = 0;
+		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 0;
 	}
+	return write_length_remaining;
 }
 
+
 /* Base driver functions */
 
 static void hso_log_port(struct hso_device *hso_dev)
@@ -1794,9 +1931,13 @@ static int hso_stop_serial_device(struct hso_device *hso_dev)
 		return -ENODEV;
 
 	for (i = 0; i < serial->num_rx_urbs; i++) {
-		if (serial->rx_urb[i])
+		if (serial->rx_urb[i]) {
 				usb_kill_urb(serial->rx_urb[i]);
+				serial->rx_urb_filled[i] = 0;
+		}
 	}
+	serial->curr_rx_urb_idx = 0;
+	serial->curr_rx_urb_offset = 0;
 
 	if (serial->tx_urb)
 		usb_kill_urb(serial->tx_urb);
@@ -2740,6 +2881,7 @@ static const struct tty_operations hso_serial_ops = {
 	.chars_in_buffer = hso_serial_chars_in_buffer,
 	.tiocmget = hso_serial_tiocmget,
 	.tiocmset = hso_serial_tiocmset,
+	.unthrottle = hso_unthrottle
 };
 
 static struct usb_driver hso_driver = {
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index ca9d00c..b514350 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -118,7 +118,7 @@ static void mcs7830_async_cmd_callback(struct urb *urb)
 
 	if (urb->status < 0)
 		printk(KERN_DEBUG "%s() failed with %d\n",
-		       __FUNCTION__, urb->status);
+		       __func__, urb->status);
 
 	kfree(req);
 	usb_free_urb(urb);
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 8c19307..38b90e7 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -119,7 +119,7 @@ static void ctrl_callback(struct urb *urb)
 	default:
 		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_dbg(&pegasus->intf->dev, "%s, status %d\n",
-				__FUNCTION__, urb->status);
+				__func__, urb->status);
 	}
 	pegasus->flags &= ~ETH_REGS_CHANGED;
 	wake_up(&pegasus->ctrl_wait);
@@ -136,7 +136,7 @@ static int get_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 	if (!buffer) {
 		if (netif_msg_drv(pegasus))
 			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__FUNCTION__);
+					__func__);
 		return -ENOMEM;
 	}
 	add_wait_queue(&pegasus->ctrl_wait, &wait);
@@ -224,7 +224,7 @@ static int set_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 		goto out;
 	}
 
@@ -246,7 +246,7 @@ static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
 	if (!tmp) {
 		if (netif_msg_drv(pegasus))
 			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__FUNCTION__);
+					__func__);
 		return -ENOMEM;
 	}
 	memcpy(tmp, &data, 1);
@@ -277,7 +277,7 @@ static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 		goto out;
 	}
 
@@ -310,7 +310,7 @@ static int update_eth_regs_async(pegasus_t * pegasus)
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 	}
 
 	return ret;
@@ -341,7 +341,7 @@ static int read_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 * regd)
 	}
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 
 	return ret;
 }
@@ -378,7 +378,7 @@ static int write_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 regd)
 
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 
@@ -415,7 +415,7 @@ static int read_eprom_word(pegasus_t * pegasus, __u8 index, __u16 * retdata)
 
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 
@@ -463,7 +463,7 @@ static int write_eprom_word(pegasus_t * pegasus, __u8 index, __u16 data)
 		return ret;
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 #endif				/* PEGASUS_WRITE_EEPROM */
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 1b95b04..29a3309 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1381,7 +1381,7 @@ enum velocity_msg_level {
 #define ASSERT(x) { \
 	if (!(x)) { \
 		printk(KERN_ERR "assertion %s failed: file %s line %d\n", #x,\
-			__FUNCTION__, __LINE__);\
+			__func__, __LINE__);\
 		BUG(); \
 	}\
 }
diff --git a/drivers/net/wan/cycx_drv.c b/drivers/net/wan/cycx_drv.c
index d14e667..a5ddc6c 100644
--- a/drivers/net/wan/cycx_drv.c
+++ b/drivers/net/wan/cycx_drv.c
@@ -407,7 +407,7 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 	if (cfm->version != CFM_VERSION) {
 		printk(KERN_ERR "%s:%s: firmware format %u rejected! "
 				"Expecting %u.\n",
-				modname, __FUNCTION__, cfm->version, CFM_VERSION);
+				modname, __func__, cfm->version, CFM_VERSION);
 		return -EINVAL;
 	}
 
@@ -420,7 +420,7 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 */
 	if (cksum != cfm->checksum) {
 		printk(KERN_ERR "%s:%s: firmware corrupted!\n",
-				modname, __FUNCTION__);
+				modname, __func__);
 		printk(KERN_ERR " cdsize = 0x%x (expected 0x%lx)\n",
 				len - (int)sizeof(struct cycx_firmware) - 1,
 				cfm->info.codesize);
@@ -432,7 +432,7 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 	/* If everything is ok, set reset, data and code pointers */
 	img_hdr = (struct cycx_fw_header *)&cfm->image;
 #ifdef FIRMWARE_DEBUG
-	printk(KERN_INFO "%s:%s: image sizes\n", __FUNCTION__, modname);
+	printk(KERN_INFO "%s:%s: image sizes\n", __func__, modname);
 	printk(KERN_INFO " reset=%lu\n", img_hdr->reset_size);
 	printk(KERN_INFO "  data=%lu\n", img_hdr->data_size);
 	printk(KERN_INFO "  code=%lu\n", img_hdr->code_size);
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index d3b28b0..5a7303d 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -874,7 +874,7 @@ static void cycx_x25_irq_connect(struct cycx_device *card,
 		nibble_to_byte(d + (sizeloc >> 1), rem, sizerem, sizeloc & 1);
 
 	dprintk(1, KERN_INFO "%s:lcn=%d, local=%s, remote=%s\n",
-			  __FUNCTION__, lcn, loc, rem);
+			  __func__, lcn, loc, rem);
 
 	dev = cycx_x25_get_dev_by_dte_addr(wandev, rem);
 	if (!dev) {
@@ -902,7 +902,7 @@ static void cycx_x25_irq_connect_confirm(struct cycx_device *card,
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
 	cycx_peek(&card->hw, cmd->buf + 1, &key, sizeof(key));
 	dprintk(1, KERN_INFO "%s: %s:lcn=%d, key=%d\n",
-			  card->devname, __FUNCTION__, lcn, key);
+			  card->devname, __func__, lcn, key);
 
 	dev = cycx_x25_get_dev_by_lcn(wandev, -key);
 	if (!dev) {
@@ -929,7 +929,7 @@ static void cycx_x25_irq_disconnect_confirm(struct cycx_device *card,
 
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
 	dprintk(1, KERN_INFO "%s: %s:lcn=%d\n",
-			  card->devname, __FUNCTION__, lcn);
+			  card->devname, __func__, lcn);
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (!dev) {
 		/* Invalid channel, discard packet */
@@ -950,7 +950,7 @@ static void cycx_x25_irq_disconnect(struct cycx_device *card,
 	u8 lcn;
 
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
-	dprintk(1, KERN_INFO "%s:lcn=%d\n", __FUNCTION__, lcn);
+	dprintk(1, KERN_INFO "%s:lcn=%d\n", __func__, lcn);
 
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (dev) {
@@ -1381,7 +1381,7 @@ static void cycx_x25_chan_timer(unsigned long d)
 		cycx_x25_chan_disconnect(dev);
 	else
 		printk(KERN_ERR "%s: %s for svc (%s) not connected!\n",
-				chan->card->devname, __FUNCTION__, dev->name);
+				chan->card->devname, __func__, dev->name);
 }
 
 /* Set logical channel state. */
@@ -1485,7 +1485,7 @@ static void cycx_x25_chan_send_event(struct net_device *dev, u8 event)
 	unsigned char *ptr;
 
 	if ((skb = dev_alloc_skb(1)) == NULL) {
-		printk(KERN_ERR "%s: out of memory\n", __FUNCTION__);
+		printk(KERN_ERR "%s: out of memory\n", __func__);
 		return;
 	}
 
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index f5d55ad..5f1ccb2 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -647,7 +647,7 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 
 	skb = dpriv->rx_skbuff[dpriv->rx_current++%RX_RING_SIZE];
 	if (!skb) {
-		printk(KERN_DEBUG "%s: skb=0 (%s)\n", dev->name, __FUNCTION__);
+		printk(KERN_DEBUG "%s: skb=0 (%s)\n", dev->name, __func__);
 		goto refill;
 	}
 	pkt_len = TO_SIZE(le32_to_cpu(rx_fd->state2));
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index 4518d0a..4917a94 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -548,7 +548,7 @@ static int pc300_tiocmset(struct tty_struct *tty, struct file *file,
 {
 	st_cpc_tty_area    *cpc_tty; 
 
-	CPC_TTY_DBG("%s: set:%x clear:%x\n", __FUNCTION__, set, clear);
+	CPC_TTY_DBG("%s: set:%x clear:%x\n", __func__, set, clear);
 
 	if (!tty || !tty->driver_data ) {
 	   	CPC_TTY_DBG("hdlcX-tty: no TTY to chars in buffer\n");	
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index f1624b3..97dfb11 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2244,6 +2244,16 @@
 #define PCI_DEVICE_ID_3DLABS_PERMEDIA2	0x0007
 #define PCI_DEVICE_ID_3DLABS_PERMEDIA2V	0x0009
 
+#define PCI_VENDOR_ID_NETXEN		0x4040
+#define PCI_DEVICE_ID_NX2031_10GXSR	0x0001
+#define PCI_DEVICE_ID_NX2031_10GCX4	0x0002
+#define PCI_DEVICE_ID_NX2031_4GCU	0x0003
+#define PCI_DEVICE_ID_NX2031_IMEZ	0x0004
+#define PCI_DEVICE_ID_NX2031_HMEZ	0x0005
+#define PCI_DEVICE_ID_NX2031_XG_MGMT	0x0024
+#define PCI_DEVICE_ID_NX2031_XG_MGMT2	0x0025
+#define PCI_DEVICE_ID_NX3031		0x0100
+
 #define PCI_VENDOR_ID_AKS		0x416c
 #define PCI_DEVICE_ID_AKS_ALADDINCARD	0x0100
 
