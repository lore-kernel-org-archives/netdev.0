From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates #2
Date: Fri, 1 Feb 2008 16:03:38 -0500
Message-ID: <20080201210338.GA11084@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43640 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbYBAVDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 16:03:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This submit is based on top of Linus's tree, since I'm not sure what's
going on with net-2.6.git and my previous (lost?) submission.

These changes do /not/ include anything from the previous submission,
which was on top of net-2.6 -- but then you rebased, which probably made
everything more difficult.  :)


Please pull from 'upstream2-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream2-davem

to receive the following updates:

 MAINTAINERS                     |   23 ----
 drivers/net/Kconfig             |    2 +-
 drivers/net/ax88796.c           |   40 ++++---
 drivers/net/e100.c              |   18 ++--
 drivers/net/e1000/e1000_main.c  |    2 +-
 drivers/net/e1000e/defines.h    |    1 +
 drivers/net/e1000e/ethtool.c    |   17 ++-
 drivers/net/e1000e/netdev.c     |   12 +-
 drivers/net/ehea/ehea.h         |    3 +
 drivers/net/ehea/ehea_ethtool.c |    4 +-
 drivers/net/ehea/ehea_hw.h      |    8 +-
 drivers/net/ehea/ehea_main.c    |  124 +++++++------------
 drivers/net/ehea/ehea_phyp.c    |  158 ++++++++++++------------
 drivers/net/ehea/ehea_phyp.h    |   22 ++--
 drivers/net/ehea/ehea_qmr.c     |   32 +++---
 drivers/net/ehea/ehea_qmr.h     |   16 ++--
 drivers/net/ibmlana.c           |    4 +-
 drivers/net/igb/igb_main.c      |    1 -
 drivers/net/macb.c              |    9 +-
 drivers/net/mipsnet.c           |  203 ++++++++++++++++++++----------
 drivers/net/mipsnet.h           |  112 -----------------
 drivers/net/pasemi_mac.c        |  259 ++++++++++++++++++++++++++++-----------
 drivers/net/pasemi_mac.h        |   16 +++
 drivers/net/phy/broadcom.c      |   20 +++
 drivers/net/s2io.c              |  128 +++++++++++---------
 drivers/net/s2io.h              |    9 +-
 drivers/net/sunbmac.c           |    2 +-
 drivers/net/sunqe.c             |    6 +-
 drivers/net/sunvnet.c           |    2 +-
 drivers/net/tokenring/olympic.c |    2 +-
 drivers/net/ucc_geth.c          |   37 +++++-
 drivers/net/usb/rtl8150.c       |    1 -
 drivers/net/via-rhine.c         |    2 +-
 drivers/net/via-velocity.c      |   70 +++++------
 drivers/net/via-velocity.h      |  224 ++++++++++++++-------------------
 35 files changed, 827 insertions(+), 762 deletions(-)
 delete mode 100644 drivers/net/mipsnet.h

Adrian Bunk (11):
      via-rhine.c:rhine_hw_init() must be __devinit
      ibmlana_adapter_names[] must be __devinitdata
      olympic_open() must be __devinit
      ibmlana_init_one() must be __devinit
      IBMLANA no longer has to depend on MCA_LEGACY
      drivers/net/sunvnet.c:print_version() must be __devinit
      net/sunqe.c section fix
      net/sunbmac.c section fix
      e1000e: make a function static
      e1000: make e1000_dump_eeprom() static
      remove obsolete tokenring maintainer information

Al Viro (1):
      big-endian support for via-velocity

Andreas Mohr (1):
      e100: fix spelling errors

Andy Gospodarek (1):
      e1000e: tweak irq allocation messages

Anton Vorontsov (2):
      ucc_geth: fix module removal
      ucc_geth: add support for netpoll

Auke Kok (1):
      igb: remove unneeded declaration shadowing earlier one

Ben Dooks (1):
      NET: AX88796 use dev_dbg() instead of printk()

Doug Maxey (5):
      ehea: fix ehea.h checkpatch complaints
      ehea: fix ethtool checkpatch complaints
      ehea: fix main checkpatch complaints
      ehea: fix phyp checkpatch complaints
      ehea: fix qmr checkpatch complaints

Haavard Skinnemoen (1):
      macb: Fix section mismatch and shrink runtime footprint

Jan-Bernd Themann (1):
      ehea: fix sysfs link compile problem

Jiri Slaby (1):
      Net: e100, fix iomap mem accesses

Lennert Buytenhek (1):
      rtl8150: use default MTU of 1500

Mitch Williams (1):
      e1000e: add new wakeup cababilities

Nate Case (1):
      PHYLIB: Add BCM5482 PHY support

Olof Johansson (3):
      pasemi_mac: Add support for changing mac address
      pasemi_mac: add support for setting MTU
      pasemi_mac: Disable interface on close

Ralf Baechle (1):
      Fix/Rewrite of the mipsnet driver]

Sreenivasa Honnur (2):
      S2io: Support for vlan_rx_kill_vid entry point
      S2io: Fix for LRO Bugs

diff --git a/MAINTAINERS b/MAINTAINERS
index 91082e6..4ef6cbc 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -84,13 +84,6 @@ S: Status, one of the following:
 			it has been replaced by a better system and you
 			should be using that.
 
-3C359 NETWORK DRIVER
-P:	Mike Phillips
-M:	mikep@linuxtr.net
-L:	netdev@vger.kernel.org
-W:	http://www.linuxtr.net
-S:	Maintained
-
 3C505 NETWORK DRIVER
 P:	Philip Blundell
 M:	philb@gnu.org
@@ -2864,15 +2857,6 @@ L:	ocfs2-devel@oss.oracle.com
 W:	http://oss.oracle.com/projects/ocfs2/
 S:	Supported
 
-OLYMPIC NETWORK DRIVER
-P:	Peter De Shrijver
-M:	p2@ace.ulyssis.student.kuleuven.ac.be
-P:	Mike Phillips
-M:	mikep@linuxtr.net
-L:	netdev@vger.kernel.org
-W:	http://www.linuxtr.net
-S:	Maintained
-
 OMNIKEY CARDMAN 4000 DRIVER
 P:	Harald Welte
 M:	laforge@gnumonks.org
@@ -3789,13 +3773,6 @@ L:	tlan-devel@lists.sourceforge.net (subscribers-only)
 W:	http://sourceforge.net/projects/tlan/
 S:	Maintained
 
-TOKEN-RING NETWORK DRIVER
-P:	Mike Phillips
-M:	mikep@linuxtr.net
-L:	netdev@vger.kernel.org
-W:	http://www.linuxtr.net
-S:	Maintained
-
 TOSHIBA ACPI EXTRAS DRIVER
 P:	John Belmonte
 M:	toshiba_acpi@memebeam.org
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 389980f..2aab62e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1199,7 +1199,7 @@ config NE2_MCA
 
 config IBMLANA
 	tristate "IBM LAN Adapter/A support"
-	depends on MCA && MCA_LEGACY
+	depends on MCA
 	---help---
 	  This is a Micro Channel Ethernet adapter.  You need to set
 	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 7495a9e..194949a 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -137,11 +137,12 @@ static int ax_initial_check(struct net_device *dev)
 static void ax_reset_8390(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	unsigned long reset_start_time = jiffies;
 	void __iomem *addr = (void __iomem *)dev->base_addr;
 
 	if (ei_debug > 1)
-		printk(KERN_DEBUG "resetting the 8390 t=%ld...", jiffies);
+		dev_dbg(&ax->dev->dev, "resetting the 8390 t=%ld\n", jiffies);
 
 	ei_outb(ei_inb(addr + NE_RESET), addr + NE_RESET);
 
@@ -151,7 +152,7 @@ static void ax_reset_8390(struct net_device *dev)
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
 		if (jiffies - reset_start_time > 2*HZ/100) {
-			printk(KERN_WARNING "%s: %s did not complete.\n",
+			dev_warn(&ax->dev->dev, "%s: %s did not complete.\n",
 			       __FUNCTION__, dev->name);
 			break;
 		}
@@ -165,13 +166,15 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 			    int ring_page)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk(KERN_EMERG "%s: DMAing conflict in %s [DMAstat:%d][irqlock:%d].\n",
+		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s "
+			"[DMAstat:%d][irqlock:%d].\n",
 			dev->name, __FUNCTION__,
-		       ei_status.dmaing, ei_status.irqlock);
+			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 
@@ -204,13 +207,16 @@ static void ax_block_input(struct net_device *dev, int count,
 			   struct sk_buff *skb, int ring_offset)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 	char *buf = skb->data;
 
 	if (ei_status.dmaing) {
-		printk(KERN_EMERG "%s: DMAing conflict in ax_block_input "
+		dev_err(&ax->dev->dev,
+			"%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, ei_status.dmaing, ei_status.irqlock);
+			dev->name, __FUNCTION__,
+			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 
@@ -239,6 +245,7 @@ static void ax_block_output(struct net_device *dev, int count,
 			    const unsigned char *buf, const int start_page)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 	unsigned long dma_start;
 
@@ -251,7 +258,7 @@ static void ax_block_output(struct net_device *dev, int count,
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk(KERN_EMERG "%s: DMAing conflict in %s."
+		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s."
 			"[DMAstat:%d][irqlock:%d]\n",
 			dev->name, __FUNCTION__,
 		       ei_status.dmaing, ei_status.irqlock);
@@ -281,7 +288,8 @@ static void ax_block_output(struct net_device *dev, int count,
 
 	while ((ei_inb(nic_base + EN0_ISR) & ENISR_RDC) == 0) {
 		if (jiffies - dma_start > 2*HZ/100) {		/* 20ms */
-			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
+			dev_warn(&ax->dev->dev,
+				 "%s: timeout waiting for Tx RDC.\n", dev->name);
 			ax_reset_8390(dev);
 			ax_NS8390_init(dev,1);
 			break;
@@ -424,10 +432,11 @@ static void
 ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
 {
 	struct ei_device *ei = (struct ei_device *) netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	unsigned long flags;
 
-	printk(KERN_DEBUG "%s: %p, %04x, %04x %04x\n",
-	       __FUNCTION__, dev, phy_addr, reg, value);
+	dev_dbg(&ax->dev->dev, "%s: %p, %04x, %04x %04x\n",
+		__FUNCTION__, dev, phy_addr, reg, value);
 
       	spin_lock_irqsave(&ei->page_lock, flags);
 
@@ -750,14 +759,11 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 	ax_NS8390_init(dev, 0);
 
 	if (first_init) {
-		printk("AX88796: %dbit, irq %d, %lx, MAC: ",
-		       ei_status.word16 ? 16:8, dev->irq, dev->base_addr);
-
-		for (i = 0; i < ETHER_ADDR_LEN; i++)
-			printk("%2.2x%c", dev->dev_addr[i],
-			       (i < (ETHER_ADDR_LEN-1) ? ':' : ' '));
+		DECLARE_MAC_BUF(mac);
 
-		printk("\n");
+		dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %s\n",
+			 ei_status.word16 ? 16:8, dev->irq, dev->base_addr,
+			 print_mac(mac, dev->dev_addr));
 	}
 
 	ret = register_netdev(dev);
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 51cf577..36ba6dc 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -94,7 +94,7 @@
  * 	enabled.  82557 pads with 7Eh, while the later controllers pad
  * 	with 00h.
  *
- *	IV.  Recieve
+ *	IV.  Receive
  *
  *	The Receive Frame Area (RFA) comprises a ring of Receive Frame
  *	Descriptors (RFD) + data buffer, thus forming the simplified mode
@@ -120,7 +120,7 @@
  *	and Rx indication and re-allocation happen in the same context,
  *	therefore no locking is required.  A software-generated interrupt
  *	is generated from the watchdog to recover from a failed allocation
- *	senario where all Rx resources have been indicated and none re-
+ *	scenario where all Rx resources have been indicated and none re-
  *	placed.
  *
  *	V.   Miscellaneous
@@ -954,7 +954,7 @@ static void e100_get_defaults(struct nic *nic)
 	/* Quadwords to DMA into FIFO before starting frame transmit */
 	nic->tx_threshold = 0xE0;
 
-	/* no interrupt for every tx completion, delay = 256us if not 557*/
+	/* no interrupt for every tx completion, delay = 256us if not 557 */
 	nic->tx_command = cpu_to_le16(cb_tx | cb_tx_sf |
 		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
 
@@ -1497,7 +1497,7 @@ static void e100_update_stats(struct nic *nic)
 		&s->complete;
 
 	/* Device's stats reporting may take several microseconds to
-	 * complete, so where always waiting for results of the
+	 * complete, so we're always waiting for results of the
 	 * previous command. */
 
 	if(*complete == cpu_to_le32(cuc_dump_reset_complete)) {
@@ -1958,7 +1958,7 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
 
 	if(restart_required) {
 		// ack the rnr?
-		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
+		iowrite8(stat_ack_rnr, &nic->csr->scb.stat_ack);
 		e100_start_receiver(nic, nic->rx_to_clean);
 		if(work_done)
 			(*work_done)++;
@@ -2774,7 +2774,7 @@ static void __devexit e100_remove(struct pci_dev *pdev)
 		struct nic *nic = netdev_priv(netdev);
 		unregister_netdev(netdev);
 		e100_free(nic);
-		iounmap(nic->csr);
+		pci_iounmap(pdev, nic->csr);
 		free_netdev(netdev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
@@ -2858,17 +2858,17 @@ static void e100_shutdown(struct pci_dev *pdev)
 /**
  * e100_io_error_detected - called when PCI error is detected.
  * @pdev: Pointer to PCI device
- * @state: The current pci conneection state
+ * @state: The current pci connection state
  */
 static pci_ers_result_t e100_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-	/* Similar to calling e100_down(), but avoids adpater I/O. */
+	/* Similar to calling e100_down(), but avoids adapter I/O. */
 	netdev->stop(netdev);
 
-	/* Detach; put netif into state similar to hotplug unplug. */
+	/* Detach; put netif into a state similar to hotplug unplug. */
 	napi_enable(&nic->napi);
 	netif_device_detach(netdev);
 	pci_disable_device(pdev);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8c87940..7c5b05a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -853,7 +853,7 @@ e1000_reset(struct e1000_adapter *adapter)
 /**
  *  Dump the eeprom for users having checksum issues
  **/
-void e1000_dump_eeprom(struct e1000_adapter *adapter)
+static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ethtool_eeprom eeprom;
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index f2175ea..6232c3e 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -63,6 +63,7 @@
 #define E1000_WUFC_EX   0x00000004 /* Directed Exact Wakeup Enable */
 #define E1000_WUFC_MC   0x00000008 /* Directed Multicast Wakeup Enable */
 #define E1000_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
+#define E1000_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
 
 /* Extended Device Control */
 #define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Defineable Pin 7 */
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6d9c27f..f77a742 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -690,8 +690,8 @@ err_setup:
 	return err;
 }
 
-bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data,
-			    int reg, int offset, u32 mask, u32 write)
+static bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data,
+				   int reg, int offset, u32 mask, u32 write)
 {
 	int i;
 	u32 read;
@@ -1632,7 +1632,8 @@ static void e1000_get_wol(struct net_device *netdev,
 		return;
 
 	wol->supported = WAKE_UCAST | WAKE_MCAST |
-			 WAKE_BCAST | WAKE_MAGIC;
+	                 WAKE_BCAST | WAKE_MAGIC |
+	                 WAKE_PHY | WAKE_ARP;
 
 	/* apply any specific unsupported masks here */
 	if (adapter->flags & FLAG_NO_WAKE_UCAST) {
@@ -1651,6 +1652,10 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->wolopts |= WAKE_BCAST;
 	if (adapter->wol & E1000_WUFC_MAG)
 		wol->wolopts |= WAKE_MAGIC;
+	if (adapter->wol & E1000_WUFC_LNKC)
+		wol->wolopts |= WAKE_PHY;
+	if (adapter->wol & E1000_WUFC_ARP)
+		wol->wolopts |= WAKE_ARP;
 }
 
 static int e1000_set_wol(struct net_device *netdev,
@@ -1658,7 +1663,7 @@ static int e1000_set_wol(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+	if (wol->wolopts & WAKE_MAGICSECURE)
 		return -EOPNOTSUPP;
 
 	if (!(adapter->flags & FLAG_HAS_WOL))
@@ -1675,6 +1680,10 @@ static int e1000_set_wol(struct net_device *netdev,
 		adapter->wol |= E1000_WUFC_BC;
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= E1000_WUFC_MAG;
+	if (wol->wolopts & WAKE_PHY)
+		adapter->wol |= E1000_WUFC_LNKC;
+	if (wol->wolopts & WAKE_ARP)
+		adapter->wol |= E1000_WUFC_ARP;
 
 	return 0;
 }
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0a2cb79..f58f017 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -945,11 +945,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	int irq_flags = IRQF_SHARED;
 	int err;
 
-	err = pci_enable_msi(adapter->pdev);
-	if (err) {
-		ndev_warn(netdev,
-		 "Unable to allocate MSI interrupt Error: %d\n", err);
-	} else {
+	if (!pci_enable_msi(adapter->pdev)) {
 		adapter->flags |= FLAG_MSI_ENABLED;
 		handler = e1000_intr_msi;
 		irq_flags = 0;
@@ -958,10 +954,12 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
 			  netdev);
 	if (err) {
+		ndev_err(netdev,
+		       "Unable to allocate %s interrupt (return: %d)\n",
+			adapter->flags & FLAG_MSI_ENABLED ? "MSI":"INTx",
+			err);
 		if (adapter->flags & FLAG_MSI_ENABLED)
 			pci_disable_msi(adapter->pdev);
-		ndev_err(netdev,
-		       "Unable to allocate interrupt Error: %d\n", err);
 	}
 
 	return err;
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 5f82a46..88fb53e 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -458,4 +458,7 @@ void ehea_set_ethtool_ops(struct net_device *netdev);
 int ehea_sense_port_attr(struct ehea_port *port);
 int ehea_set_portspeed(struct ehea_port *port, u32 port_speed);
 
+extern u64 ehea_driver_flags;
+extern struct work_struct ehea_rereg_mr_task;
+
 #endif	/* __EHEA_H__ */
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 679f40e..d768852 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -40,7 +40,7 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return ret;
 
 	if (netif_carrier_ok(dev)) {
-		switch(port->port_speed) {
+		switch (port->port_speed) {
 		case EHEA_SPEED_10M: cmd->speed = SPEED_10; break;
 		case EHEA_SPEED_100M: cmd->speed = SPEED_100; break;
 		case EHEA_SPEED_1G: cmd->speed = SPEED_1000; break;
@@ -78,7 +78,7 @@ static int ehea_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		goto doit;
 	}
 
-	switch(cmd->speed) {
+	switch (cmd->speed) {
 	case SPEED_10:
 		if (cmd->duplex == DUPLEX_FULL)
 			sp = H_SPEED_10M_F;
diff --git a/drivers/net/ehea/ehea_hw.h b/drivers/net/ehea/ehea_hw.h
index 1af7ca4..567981b 100644
--- a/drivers/net/ehea/ehea_hw.h
+++ b/drivers/net/ehea/ehea_hw.h
@@ -29,10 +29,10 @@
 #ifndef __EHEA_HW_H__
 #define __EHEA_HW_H__
 
-#define QPX_SQA_VALUE   EHEA_BMASK_IBM(48,63)
-#define QPX_RQ1A_VALUE  EHEA_BMASK_IBM(48,63)
-#define QPX_RQ2A_VALUE  EHEA_BMASK_IBM(48,63)
-#define QPX_RQ3A_VALUE  EHEA_BMASK_IBM(48,63)
+#define QPX_SQA_VALUE   EHEA_BMASK_IBM(48, 63)
+#define QPX_RQ1A_VALUE  EHEA_BMASK_IBM(48, 63)
+#define QPX_RQ2A_VALUE  EHEA_BMASK_IBM(48, 63)
+#define QPX_RQ3A_VALUE  EHEA_BMASK_IBM(48, 63)
 
 #define QPTEMM_OFFSET(x) offsetof(struct ehea_qptemm, x)
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 869e160..c051c7e 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -6,9 +6,9 @@
  *  (C) Copyright IBM Corp. 2006
  *
  *  Authors:
- *       Christoph Raisch <raisch@de.ibm.com>
- *       Jan-Bernd Themann <themann@de.ibm.com>
- *       Thomas Klein <tklein@de.ibm.com>
+ *	 Christoph Raisch <raisch@de.ibm.com>
+ *	 Jan-Bernd Themann <themann@de.ibm.com>
+ *	 Thomas Klein <tklein@de.ibm.com>
  *
  *
  * This program is free software; you can redistribute it and/or modify
@@ -54,11 +54,11 @@ static int rq1_entries = EHEA_DEF_ENTRIES_RQ1;
 static int rq2_entries = EHEA_DEF_ENTRIES_RQ2;
 static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
-static int use_mcs = 0;
-static int use_lro = 0;
+static int use_mcs;
+static int use_lro;
 static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
 static int num_tx_qps = EHEA_NUM_TX_QP;
-static int prop_carrier_state = 0;
+static int prop_carrier_state;
 
 module_param(msg_level, int, 0);
 module_param(rq1_entries, int, 0);
@@ -94,9 +94,9 @@ MODULE_PARM_DESC(lro_max_aggr, " LRO: Max packets to be aggregated. Default = "
 MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
 		 "Default = 0");
 
-static int port_name_cnt = 0;
+static int port_name_cnt;
 static LIST_HEAD(adapter_list);
-u64 ehea_driver_flags = 0;
+u64 ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
 
 struct semaphore dlpar_mem_lock;
@@ -121,12 +121,13 @@ static struct of_platform_driver ehea_driver = {
 	.remove = ehea_remove,
 };
 
-void ehea_dump(void *adr, int len, char *msg) {
+void ehea_dump(void *adr, int len, char *msg)
+{
 	int x;
 	unsigned char *deb = adr;
 	for (x = 0; x < len; x += 16) {
 		printk(DRV_NAME " %s adr=%p ofs=%04x %016lx %016lx\n", msg,
-			  deb, x, *((u64*)&deb[0]), *((u64*)&deb[8]));
+			  deb, x, *((u64 *)&deb[0]), *((u64 *)&deb[8]));
 		deb += 16;
 	}
 }
@@ -518,7 +519,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 		last_wqe_index = wqe_index;
 		rmb();
 		if (!ehea_check_cqe(cqe, &rq)) {
-			if (rq == 1) {	/* LL RQ1 */
+			if (rq == 1) {
+				/* LL RQ1 */
 				skb = get_skb_by_index_ll(skb_arr_rq1,
 							  skb_arr_rq1_len,
 							  wqe_index);
@@ -531,10 +533,11 @@ static int ehea_proc_rwqes(struct net_device *dev,
 					if (!skb)
 						break;
 				}
-				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
+				skb_copy_to_linear_data(skb, ((char *)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
 				ehea_fill_skb(dev, skb, cqe);
-			} else if (rq == 2) {  /* RQ2 */
+			} else if (rq == 2) {
+				/* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
 						       skb_arr_rq2_len, cqe);
 				if (unlikely(!skb)) {
@@ -544,7 +547,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 				}
 				ehea_fill_skb(dev, skb, cqe);
 				processed_rq2++;
-			} else {  /* RQ3 */
+			} else {
+				/* RQ3 */
 				skb = get_skb_by_index(skb_arr_rq3,
 						       skb_arr_rq3_len, cqe);
 				if (unlikely(!skb)) {
@@ -592,7 +596,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 	unsigned long flags;
 
 	cqe = ehea_poll_cq(send_cq);
-	while(cqe && (quota > 0)) {
+	while (cqe && (quota > 0)) {
 		ehea_inc_cq(send_cq);
 
 		cqe_counter++;
@@ -643,7 +647,8 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 
 static int ehea_poll(struct napi_struct *napi, int budget)
 {
-	struct ehea_port_res *pr = container_of(napi, struct ehea_port_res, napi);
+	struct ehea_port_res *pr = container_of(napi, struct ehea_port_res,
+						napi);
 	struct net_device *dev = pr->port->netdev;
 	struct ehea_cqe *cqe;
 	struct ehea_cqe *cqe_skb = NULL;
@@ -743,8 +748,9 @@ int ehea_sense_port_attr(struct ehea_port *port)
 	u64 hret;
 	struct hcp_ehea_port_cb0 *cb0;
 
-	cb0 = kzalloc(PAGE_SIZE, GFP_ATOMIC);   /* May be called via */
-	if (!cb0) {                             /* ehea_neq_tasklet() */
+	/* may be called via ehea_neq_tasklet() */
+	cb0 = kzalloc(PAGE_SIZE, GFP_ATOMIC);
+	if (!cb0) {
 		ehea_error("no mem for cb0");
 		ret = -ENOMEM;
 		goto out;
@@ -762,7 +768,7 @@ int ehea_sense_port_attr(struct ehea_port *port)
 	/* MAC address */
 	port->mac_addr = cb0->port_mac_addr << 16;
 
-	if (!is_valid_ether_addr((u8*)&port->mac_addr)) {
+	if (!is_valid_ether_addr((u8 *)&port->mac_addr)) {
 		ret = -EADDRNOTAVAIL;
 		goto out_free;
 	}
@@ -994,7 +1000,7 @@ static void ehea_parse_eqe(struct ehea_adapter *adapter, u64 eqe)
 
 static void ehea_neq_tasklet(unsigned long data)
 {
-	struct ehea_adapter *adapter = (struct ehea_adapter*)data;
+	struct ehea_adapter *adapter = (struct ehea_adapter *)data;
 	struct ehea_eqe *eqe;
 	u64 event_mask;
 
@@ -1204,7 +1210,7 @@ int ehea_rem_smrs(struct ehea_port_res *pr)
 
 static int ehea_init_q_skba(struct ehea_q_skb_arr *q_skba, int max_q_entries)
 {
-	int arr_size = sizeof(void*) * max_q_entries;
+	int arr_size = sizeof(void *) * max_q_entries;
 
 	q_skba->arr = vmalloc(arr_size);
 	if (!q_skba->arr)
@@ -1489,7 +1495,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 
 	nfrags = skb_shinfo(skb)->nr_frags;
 	sg1entry = &swqe->u.immdata_desc.sg_entry;
-	sg_list = (struct ehea_vsgentry*)&swqe->u.immdata_desc.sg_list;
+	sg_list = (struct ehea_vsgentry *)&swqe->u.immdata_desc.sg_list;
 	swqe->descriptors = 0;
 	sg1entry_contains_frag_data = 0;
 
@@ -1542,7 +1548,7 @@ static int ehea_broadcast_reg_helper(struct ehea_port *port, u32 hcallid)
 				     reg_type, port->mac_addr, 0, hcallid);
 	if (hret != H_SUCCESS) {
 		ehea_error("%sregistering bc address failed (tagged)",
-                           hcallid == H_REG_BCMC ? "" : "de");
+			   hcallid == H_REG_BCMC ? "" : "de");
 		ret = -EIO;
 		goto out_herr;
 	}
@@ -1732,7 +1738,7 @@ static void ehea_allmulti(struct net_device *dev, int enable)
 		}
 }
 
-static void ehea_add_multicast_entry(struct ehea_port* port, u8* mc_mac_addr)
+static void ehea_add_multicast_entry(struct ehea_port *port, u8 *mc_mac_addr)
 {
 	struct ehea_mc_list *ehea_mcl_entry;
 	u64 hret;
@@ -1791,11 +1797,10 @@ static void ehea_set_multicast_list(struct net_device *dev)
 			goto out;
 		}
 
-		for (i = 0, k_mcl_entry = dev->mc_list;
-		     i < dev->mc_count;
-		     i++, k_mcl_entry = k_mcl_entry->next) {
+		for (i = 0, k_mcl_entry = dev->mc_list; i < dev->mc_count; i++,
+			     k_mcl_entry = k_mcl_entry->next)
 			ehea_add_multicast_entry(port, k_mcl_entry->dmi_addr);
-		}
+
 	}
 out:
 	return;
@@ -1925,12 +1930,12 @@ static inline int ehea_hash_skb(struct sk_buff *skb, int num_qps)
 
 	if ((skb->protocol == htons(ETH_P_IP)) &&
 	    (ip_hdr(skb)->protocol == IPPROTO_TCP)) {
-		tcp = (struct tcphdr*)(skb_network_header(skb) + (ip_hdr(skb)->ihl * 4));
+		tcp = (struct tcphdr *)(skb_network_header(skb) +
+					(ip_hdr(skb)->ihl * 4));
 		tmp = (tcp->source + (tcp->dest << 16)) % 31;
 		tmp += ip_hdr(skb)->daddr % 31;
 		return tmp % num_qps;
-	}
-	else
+	} else
 		return 0;
 }
 
@@ -2122,7 +2127,7 @@ int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
 	u64 hret;
 	u16 dummy16 = 0;
 	u64 dummy64 = 0;
-	struct hcp_modify_qp_cb0* cb0;
+	struct hcp_modify_qp_cb0 *cb0;
 
 	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!cb0) {
@@ -2248,7 +2253,7 @@ static int ehea_clean_all_portres(struct ehea_port *port)
 	int ret = 0;
 	int i;
 
-	for(i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
 		ret |= ehea_clean_portres(port, &port->port_res[i]);
 
 	ret |= ehea_destroy_eq(port->qp_eq);
@@ -2300,7 +2305,7 @@ static int ehea_up(struct net_device *dev)
 		goto out_clean_pr;
 	}
 
-	for(i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		ret = ehea_activate_qp(port->adapter, port->port_res[i].qp);
 		if (ret) {
 			ehea_error("activate_qp failed");
@@ -2308,7 +2313,7 @@ static int ehea_up(struct net_device *dev)
 		}
 	}
 
-	for(i = 0; i < port->num_def_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		ret = ehea_fill_port_res(&port->port_res[i]);
 		if (ret) {
 			ehea_error("out_free_irqs");
@@ -2425,7 +2430,7 @@ int ehea_stop_qps(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct ehea_adapter *adapter = port->adapter;
-	struct hcp_modify_qp_cb0* cb0;
+	struct hcp_modify_qp_cb0 *cb0;
 	int ret = -EIO;
 	int dret;
 	int i;
@@ -2490,7 +2495,7 @@ out:
 	return ret;
 }
 
-void ehea_update_rqs(struct ehea_qp *orig_qp, struct ehea_port_res * pr)
+void ehea_update_rqs(struct ehea_qp *orig_qp, struct ehea_port_res *pr)
 {
 	struct ehea_qp qp = *orig_qp;
 	struct ehea_qp_init_attr *init_attr = &qp.init_attr;
@@ -2530,7 +2535,7 @@ int ehea_restart_qps(struct net_device *dev)
 	int ret = 0;
 	int i;
 
-	struct hcp_modify_qp_cb0* cb0;
+	struct hcp_modify_qp_cb0 *cb0;
 	u64 hret;
 	u64 dummy64 = 0;
 	u16 dummy16 = 0;
@@ -2804,34 +2809,6 @@ static void __devinit logical_port_release(struct device *dev)
 	of_node_put(port->ofdev.node);
 }
 
-static int ehea_driver_sysfs_add(struct device *dev,
-				 struct device_driver *driver)
-{
-	int ret;
-
-	ret = sysfs_create_link(&driver->kobj, &dev->kobj,
-				kobject_name(&dev->kobj));
-	if (ret == 0) {
-		ret = sysfs_create_link(&dev->kobj, &driver->kobj,
-					"driver");
-		if (ret)
-			sysfs_remove_link(&driver->kobj,
-					  kobject_name(&dev->kobj));
-	}
-	return ret;
-}
-
-static void ehea_driver_sysfs_remove(struct device *dev,
-				     struct device_driver *driver)
-{
-	struct device_driver *drv = driver;
-
-	if (drv) {
-		sysfs_remove_link(&drv->kobj, kobject_name(&dev->kobj));
-		sysfs_remove_link(&dev->kobj, "driver");
-	}
-}
-
 static struct device *ehea_register_port(struct ehea_port *port,
 					 struct device_node *dn)
 {
@@ -2856,16 +2833,8 @@ static struct device *ehea_register_port(struct ehea_port *port,
 		goto out_unreg_of_dev;
 	}
 
-	ret = ehea_driver_sysfs_add(&port->ofdev.dev, &ehea_driver.driver);
-	if (ret) {
-		ehea_error("failed to register sysfs driver link");
-		goto out_rem_dev_file;
-	}
-
 	return &port->ofdev.dev;
 
-out_rem_dev_file:
-	device_remove_file(&port->ofdev.dev, &dev_attr_log_port_id);
 out_unreg_of_dev:
 	of_device_unregister(&port->ofdev);
 out:
@@ -2874,7 +2843,6 @@ out:
 
 static void ehea_unregister_port(struct ehea_port *port)
 {
-	ehea_driver_sysfs_remove(&port->ofdev.dev, &ehea_driver.driver);
 	device_remove_file(&port->ofdev.dev, &dev_attr_log_port_id);
 	of_device_unregister(&port->ofdev);
 }
@@ -3109,7 +3077,7 @@ static ssize_t ehea_probe_port(struct device *dev,
 	of_node_put(eth_dn);
 
 	if (port) {
-		for (i=0; i < EHEA_MAX_PORTS; i++)
+		for (i = 0; i < EHEA_MAX_PORTS; i++)
 			if (!adapter->port[i]) {
 				adapter->port[i] = port;
 				break;
@@ -3144,7 +3112,7 @@ static ssize_t ehea_remove_port(struct device *dev,
 
 		ehea_shutdown_single_port(port);
 
-		for (i=0; i < EHEA_MAX_PORTS; i++)
+		for (i = 0; i < EHEA_MAX_PORTS; i++)
 			if (adapter->port[i] == port) {
 				adapter->port[i] = NULL;
 				break;
@@ -3313,7 +3281,7 @@ static int ehea_reboot_notifier(struct notifier_block *nb,
 }
 
 static struct notifier_block ehea_reboot_nb = {
-        .notifier_call = ehea_reboot_notifier,
+	.notifier_call = ehea_reboot_notifier,
 };
 
 static int check_module_parm(void)
diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
index 95c4a7f..156eb63 100644
--- a/drivers/net/ehea/ehea_phyp.c
+++ b/drivers/net/ehea/ehea_phyp.c
@@ -6,9 +6,9 @@
  *  (C) Copyright IBM Corp. 2006
  *
  *  Authors:
- *       Christoph Raisch <raisch@de.ibm.com>
- *       Jan-Bernd Themann <themann@de.ibm.com>
- *       Thomas Klein <tklein@de.ibm.com>
+ *	 Christoph Raisch <raisch@de.ibm.com>
+ *	 Jan-Bernd Themann <themann@de.ibm.com>
+ *	 Thomas Klein <tklein@de.ibm.com>
  *
  *
  * This program is free software; you can redistribute it and/or modify
@@ -38,11 +38,11 @@ static inline u16 get_order_of_qentries(u16 queue_entries)
 }
 
 /* Defines for H_CALL H_ALLOC_RESOURCE */
-#define H_ALL_RES_TYPE_QP        1
-#define H_ALL_RES_TYPE_CQ        2
-#define H_ALL_RES_TYPE_EQ        3
-#define H_ALL_RES_TYPE_MR        5
-#define H_ALL_RES_TYPE_MW        6
+#define H_ALL_RES_TYPE_QP	 1
+#define H_ALL_RES_TYPE_CQ	 2
+#define H_ALL_RES_TYPE_EQ	 3
+#define H_ALL_RES_TYPE_MR	 5
+#define H_ALL_RES_TYPE_MW	 6
 
 static long ehea_plpar_hcall_norets(unsigned long opcode,
 				    unsigned long arg1,
@@ -137,77 +137,77 @@ u64 ehea_h_query_ehea_qp(const u64 adapter_handle, const u8 qp_category,
 			 const u64 qp_handle, const u64 sel_mask, void *cb_addr)
 {
 	return ehea_plpar_hcall_norets(H_QUERY_HEA_QP,
-				       adapter_handle,	        /* R4 */
-				       qp_category,	        /* R5 */
-				       qp_handle,               /* R6 */
-				       sel_mask,                /* R7 */
+				       adapter_handle,		/* R4 */
+				       qp_category,		/* R5 */
+				       qp_handle,		/* R6 */
+				       sel_mask,		/* R7 */
 				       virt_to_abs(cb_addr),	/* R8 */
 				       0, 0);
 }
 
 /* input param R5 */
-#define H_ALL_RES_QP_EQPO         EHEA_BMASK_IBM(9, 11)
-#define H_ALL_RES_QP_QPP          EHEA_BMASK_IBM(12, 12)
-#define H_ALL_RES_QP_RQR          EHEA_BMASK_IBM(13, 15)
-#define H_ALL_RES_QP_EQEG         EHEA_BMASK_IBM(16, 16)
-#define H_ALL_RES_QP_LL_QP        EHEA_BMASK_IBM(17, 17)
-#define H_ALL_RES_QP_DMA128       EHEA_BMASK_IBM(19, 19)
-#define H_ALL_RES_QP_HSM          EHEA_BMASK_IBM(20, 21)
-#define H_ALL_RES_QP_SIGT         EHEA_BMASK_IBM(22, 23)
-#define H_ALL_RES_QP_TENURE       EHEA_BMASK_IBM(48, 55)
-#define H_ALL_RES_QP_RES_TYP      EHEA_BMASK_IBM(56, 63)
+#define H_ALL_RES_QP_EQPO	  EHEA_BMASK_IBM(9, 11)
+#define H_ALL_RES_QP_QPP	  EHEA_BMASK_IBM(12, 12)
+#define H_ALL_RES_QP_RQR	  EHEA_BMASK_IBM(13, 15)
+#define H_ALL_RES_QP_EQEG	  EHEA_BMASK_IBM(16, 16)
+#define H_ALL_RES_QP_LL_QP	  EHEA_BMASK_IBM(17, 17)
+#define H_ALL_RES_QP_DMA128	  EHEA_BMASK_IBM(19, 19)
+#define H_ALL_RES_QP_HSM	  EHEA_BMASK_IBM(20, 21)
+#define H_ALL_RES_QP_SIGT	  EHEA_BMASK_IBM(22, 23)
+#define H_ALL_RES_QP_TENURE	  EHEA_BMASK_IBM(48, 55)
+#define H_ALL_RES_QP_RES_TYP	  EHEA_BMASK_IBM(56, 63)
 
 /* input param R9  */
-#define H_ALL_RES_QP_TOKEN        EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_PD           EHEA_BMASK_IBM(32,63)
+#define H_ALL_RES_QP_TOKEN	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_PD		  EHEA_BMASK_IBM(32, 63)
 
 /* input param R10 */
-#define H_ALL_RES_QP_MAX_SWQE     EHEA_BMASK_IBM(4, 7)
-#define H_ALL_RES_QP_MAX_R1WQE    EHEA_BMASK_IBM(12, 15)
-#define H_ALL_RES_QP_MAX_R2WQE    EHEA_BMASK_IBM(20, 23)
-#define H_ALL_RES_QP_MAX_R3WQE    EHEA_BMASK_IBM(28, 31)
+#define H_ALL_RES_QP_MAX_SWQE	  EHEA_BMASK_IBM(4, 7)
+#define H_ALL_RES_QP_MAX_R1WQE	  EHEA_BMASK_IBM(12, 15)
+#define H_ALL_RES_QP_MAX_R2WQE	  EHEA_BMASK_IBM(20, 23)
+#define H_ALL_RES_QP_MAX_R3WQE	  EHEA_BMASK_IBM(28, 31)
 /* Max Send Scatter Gather Elements */
-#define H_ALL_RES_QP_MAX_SSGE     EHEA_BMASK_IBM(37, 39)
-#define H_ALL_RES_QP_MAX_R1SGE    EHEA_BMASK_IBM(45, 47)
+#define H_ALL_RES_QP_MAX_SSGE	  EHEA_BMASK_IBM(37, 39)
+#define H_ALL_RES_QP_MAX_R1SGE	  EHEA_BMASK_IBM(45, 47)
 /* Max Receive SG Elements RQ1 */
-#define H_ALL_RES_QP_MAX_R2SGE    EHEA_BMASK_IBM(53, 55)
-#define H_ALL_RES_QP_MAX_R3SGE    EHEA_BMASK_IBM(61, 63)
+#define H_ALL_RES_QP_MAX_R2SGE	  EHEA_BMASK_IBM(53, 55)
+#define H_ALL_RES_QP_MAX_R3SGE	  EHEA_BMASK_IBM(61, 63)
 
 /* input param R11 */
-#define H_ALL_RES_QP_SWQE_IDL     EHEA_BMASK_IBM(0, 7)
+#define H_ALL_RES_QP_SWQE_IDL	  EHEA_BMASK_IBM(0, 7)
 /* max swqe immediate data length */
-#define H_ALL_RES_QP_PORT_NUM     EHEA_BMASK_IBM(48, 63)
+#define H_ALL_RES_QP_PORT_NUM	  EHEA_BMASK_IBM(48, 63)
 
 /* input param R12 */
-#define H_ALL_RES_QP_TH_RQ2       EHEA_BMASK_IBM(0, 15)
+#define H_ALL_RES_QP_TH_RQ2	  EHEA_BMASK_IBM(0, 15)
 /* Threshold RQ2 */
-#define H_ALL_RES_QP_TH_RQ3       EHEA_BMASK_IBM(16, 31)
+#define H_ALL_RES_QP_TH_RQ3	  EHEA_BMASK_IBM(16, 31)
 /* Threshold RQ3 */
 
 /* output param R6 */
-#define H_ALL_RES_QP_ACT_SWQE     EHEA_BMASK_IBM(0, 15)
-#define H_ALL_RES_QP_ACT_R1WQE    EHEA_BMASK_IBM(16, 31)
-#define H_ALL_RES_QP_ACT_R2WQE    EHEA_BMASK_IBM(32, 47)
-#define H_ALL_RES_QP_ACT_R3WQE    EHEA_BMASK_IBM(48, 63)
+#define H_ALL_RES_QP_ACT_SWQE	  EHEA_BMASK_IBM(0, 15)
+#define H_ALL_RES_QP_ACT_R1WQE	  EHEA_BMASK_IBM(16, 31)
+#define H_ALL_RES_QP_ACT_R2WQE	  EHEA_BMASK_IBM(32, 47)
+#define H_ALL_RES_QP_ACT_R3WQE	  EHEA_BMASK_IBM(48, 63)
 
 /* output param, R7 */
-#define H_ALL_RES_QP_ACT_SSGE     EHEA_BMASK_IBM(0, 7)
-#define H_ALL_RES_QP_ACT_R1SGE    EHEA_BMASK_IBM(8, 15)
-#define H_ALL_RES_QP_ACT_R2SGE    EHEA_BMASK_IBM(16, 23)
-#define H_ALL_RES_QP_ACT_R3SGE    EHEA_BMASK_IBM(24, 31)
+#define H_ALL_RES_QP_ACT_SSGE	  EHEA_BMASK_IBM(0, 7)
+#define H_ALL_RES_QP_ACT_R1SGE	  EHEA_BMASK_IBM(8, 15)
+#define H_ALL_RES_QP_ACT_R2SGE	  EHEA_BMASK_IBM(16, 23)
+#define H_ALL_RES_QP_ACT_R3SGE	  EHEA_BMASK_IBM(24, 31)
 #define H_ALL_RES_QP_ACT_SWQE_IDL EHEA_BMASK_IBM(32, 39)
 
 /* output param R8,R9 */
-#define H_ALL_RES_QP_SIZE_SQ      EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_SIZE_RQ1     EHEA_BMASK_IBM(32, 63)
-#define H_ALL_RES_QP_SIZE_RQ2     EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_SIZE_RQ3     EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_QP_SIZE_SQ	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_SIZE_RQ1	  EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_QP_SIZE_RQ2	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_SIZE_RQ3	  EHEA_BMASK_IBM(32, 63)
 
 /* output param R11,R12 */
-#define H_ALL_RES_QP_LIOBN_SQ     EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_LIOBN_RQ1    EHEA_BMASK_IBM(32, 63)
-#define H_ALL_RES_QP_LIOBN_RQ2    EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_LIOBN_RQ3    EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_QP_LIOBN_SQ	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_LIOBN_RQ1	  EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_QP_LIOBN_RQ2	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_LIOBN_RQ3	  EHEA_BMASK_IBM(32, 63)
 
 u64 ehea_h_alloc_resource_qp(const u64 adapter_handle,
 			     struct ehea_qp_init_attr *init_attr, const u32 pd,
@@ -334,28 +334,28 @@ u64 ehea_h_alloc_resource_cq(const u64 adapter_handle,
 }
 
 /* Defines for H_CALL H_ALLOC_RESOURCE */
-#define H_ALL_RES_TYPE_QP        1
-#define H_ALL_RES_TYPE_CQ        2
-#define H_ALL_RES_TYPE_EQ        3
-#define H_ALL_RES_TYPE_MR        5
-#define H_ALL_RES_TYPE_MW        6
+#define H_ALL_RES_TYPE_QP	 1
+#define H_ALL_RES_TYPE_CQ	 2
+#define H_ALL_RES_TYPE_EQ	 3
+#define H_ALL_RES_TYPE_MR	 5
+#define H_ALL_RES_TYPE_MW	 6
 
 /*  input param R5 */
-#define H_ALL_RES_EQ_NEQ             EHEA_BMASK_IBM(0, 0)
+#define H_ALL_RES_EQ_NEQ	     EHEA_BMASK_IBM(0, 0)
 #define H_ALL_RES_EQ_NON_NEQ_ISN     EHEA_BMASK_IBM(6, 7)
 #define H_ALL_RES_EQ_INH_EQE_GEN     EHEA_BMASK_IBM(16, 16)
-#define H_ALL_RES_EQ_RES_TYPE        EHEA_BMASK_IBM(56, 63)
+#define H_ALL_RES_EQ_RES_TYPE	     EHEA_BMASK_IBM(56, 63)
 /*  input param R6 */
-#define H_ALL_RES_EQ_MAX_EQE         EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_EQ_MAX_EQE	     EHEA_BMASK_IBM(32, 63)
 
 /*  output param R6 */
-#define H_ALL_RES_EQ_LIOBN           EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_EQ_LIOBN	     EHEA_BMASK_IBM(32, 63)
 
 /*  output param R7 */
-#define H_ALL_RES_EQ_ACT_EQE         EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_EQ_ACT_EQE	     EHEA_BMASK_IBM(32, 63)
 
 /*  output param R8 */
-#define H_ALL_RES_EQ_ACT_PS          EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_EQ_ACT_PS	     EHEA_BMASK_IBM(32, 63)
 
 /*  output param R9 */
 #define H_ALL_RES_EQ_ACT_EQ_IST_C    EHEA_BMASK_IBM(30, 31)
@@ -453,12 +453,12 @@ u64 ehea_h_register_smr(const u64 adapter_handle, const u64 orig_mr_handle,
 
 	hret = ehea_plpar_hcall9(H_REGISTER_SMR,
 				 outs,
-				 adapter_handle       ,        	 /* R4 */
-				 orig_mr_handle,                 /* R5 */
-				 vaddr_in,                       /* R6 */
-				 (((u64)access_ctrl) << 32ULL),  /* R7 */
-				 pd,                             /* R8 */
-				 0, 0, 0, 0);	   		 /* R9-R12 */
+				 adapter_handle	      ,		 /* R4 */
+				 orig_mr_handle,		 /* R5 */
+				 vaddr_in,			 /* R6 */
+				 (((u64)access_ctrl) << 32ULL),	 /* R7 */
+				 pd,				 /* R8 */
+				 0, 0, 0, 0);			 /* R9-R12 */
 
 	mr->handle = outs[0];
 	mr->lkey = (u32)outs[2];
@@ -471,11 +471,11 @@ u64 ehea_h_disable_and_get_hea(const u64 adapter_handle, const u64 qp_handle)
 	u64 outs[PLPAR_HCALL9_BUFSIZE];
 
 	return ehea_plpar_hcall9(H_DISABLE_AND_GET_HEA,
-       				 outs,
+				 outs,
 				 adapter_handle,		/* R4 */
 				 H_DISABLE_GET_EHEA_WQE_P,	/* R5 */
 				 qp_handle,			/* R6 */
-				 0, 0, 0, 0, 0, 0);             /* R7-R12 */
+				 0, 0, 0, 0, 0, 0);		/* R7-R12 */
 }
 
 u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle,
@@ -483,9 +483,9 @@ u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle,
 {
 	return ehea_plpar_hcall_norets(H_FREE_RESOURCE,
 				       adapter_handle,	   /* R4 */
-				       res_handle,         /* R5 */
+				       res_handle,	   /* R5 */
 				       force_bit,
-				       0, 0, 0, 0);        /* R7-R10 */
+				       0, 0, 0, 0);	   /* R7-R10 */
 }
 
 u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
@@ -493,13 +493,13 @@ u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
 			     const u32 pd, u64 *mr_handle, u32 *lkey)
 {
 	u64 hret;
- 	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	u64 outs[PLPAR_HCALL9_BUFSIZE];
 
 	hret = ehea_plpar_hcall9(H_ALLOC_HEA_RESOURCE,
 				 outs,
 				 adapter_handle,		   /* R4 */
 				 5,				   /* R5 */
-				 vaddr,			           /* R6 */
+				 vaddr,				   /* R6 */
 				 length,			   /* R7 */
 				 (((u64) access_ctrl) << 32ULL),   /* R8 */
 				 pd,				   /* R9 */
@@ -619,8 +619,8 @@ u64 ehea_h_error_data(const u64 adapter_handle, const u64 ressource_handle,
 		      void *rblock)
 {
 	return ehea_plpar_hcall_norets(H_ERROR_DATA,
-				       adapter_handle,          /* R4 */
-				       ressource_handle,        /* R5 */
-				       virt_to_abs(rblock),     /* R6 */
-				       0, 0, 0, 0);             /* R7-R12 */
+				       adapter_handle,		/* R4 */
+				       ressource_handle,	/* R5 */
+				       virt_to_abs(rblock),	/* R6 */
+				       0, 0, 0, 0);		/* R7-R12 */
 }
diff --git a/drivers/net/ehea/ehea_phyp.h b/drivers/net/ehea/ehea_phyp.h
index faa191d..f3628c8 100644
--- a/drivers/net/ehea/ehea_phyp.h
+++ b/drivers/net/ehea/ehea_phyp.h
@@ -93,7 +93,7 @@ static inline void hcp_epas_ctor(struct h_epas *epas, u64 paddr_kernel,
 static inline void hcp_epas_dtor(struct h_epas *epas)
 {
 	if (epas->kernel.addr)
-		iounmap((void __iomem*)((u64)epas->kernel.addr & PAGE_MASK));
+		iounmap((void __iomem *)((u64)epas->kernel.addr & PAGE_MASK));
 
 	epas->user.addr = 0;
 	epas->kernel.addr = 0;
@@ -388,23 +388,23 @@ u64 ehea_h_modify_ehea_qp(const u64 adapter_handle,
 			  const u64 qp_handle,
 			  const u64 sel_mask,
 			  void *cb_addr,
-			  u64 * inv_attr_id,
-			  u64 * proc_mask, u16 * out_swr, u16 * out_rwr);
+			  u64 *inv_attr_id,
+			  u64 *proc_mask, u16 *out_swr, u16 *out_rwr);
 
 u64 ehea_h_alloc_resource_eq(const u64 adapter_handle,
-			     struct ehea_eq_attr *eq_attr, u64 * eq_handle);
+			     struct ehea_eq_attr *eq_attr, u64 *eq_handle);
 
 u64 ehea_h_alloc_resource_cq(const u64 adapter_handle,
 			     struct ehea_cq_attr *cq_attr,
-			     u64 * cq_handle, struct h_epas *epas);
+			     u64 *cq_handle, struct h_epas *epas);
 
 u64 ehea_h_alloc_resource_qp(const u64 adapter_handle,
 			     struct ehea_qp_init_attr *init_attr,
 			     const u32 pd,
-			     u64 * qp_handle, struct h_epas *h_epas);
+			     u64 *qp_handle, struct h_epas *h_epas);
 
-#define H_REG_RPAGE_PAGE_SIZE          EHEA_BMASK_IBM(48,55)
-#define H_REG_RPAGE_QT                 EHEA_BMASK_IBM(62,63)
+#define H_REG_RPAGE_PAGE_SIZE          EHEA_BMASK_IBM(48, 55)
+#define H_REG_RPAGE_QT                 EHEA_BMASK_IBM(62, 63)
 
 u64 ehea_h_register_rpage(const u64 adapter_handle,
 			  const u8 pagesize,
@@ -426,7 +426,7 @@ u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle,
 
 u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
 			     const u64 length, const u32 access_ctrl,
-			     const u32 pd, u64 * mr_handle, u32 * lkey);
+			     const u32 pd, u64 *mr_handle, u32 *lkey);
 
 u64 ehea_h_register_rpage_mr(const u64 adapter_handle, const u64 mr_handle,
 			     const u8 pagesize, const u8 queue_type,
@@ -439,8 +439,8 @@ u64 ehea_h_register_smr(const u64 adapter_handle, const u64 orig_mr_handle,
 u64 ehea_h_query_ehea(const u64 adapter_handle, void *cb_addr);
 
 /* output param R5 */
-#define H_MEHEAPORT_CAT		EHEA_BMASK_IBM(40,47)
-#define H_MEHEAPORT_PN		EHEA_BMASK_IBM(48,63)
+#define H_MEHEAPORT_CAT		EHEA_BMASK_IBM(40, 47)
+#define H_MEHEAPORT_PN		EHEA_BMASK_IBM(48, 63)
 
 u64 ehea_h_query_ehea_port(const u64 adapter_handle, const u16 port_num,
 			   const u8 cb_cat, const u64 select_mask,
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 83b7643..d522e90 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -33,8 +33,6 @@
 
 
 struct ehea_busmap ehea_bmap = { 0, 0, NULL };
-extern u64 ehea_driver_flags;
-extern struct work_struct ehea_rereg_mr_task;
 
 
 static void *hw_qpageit_get_inc(struct hw_queue *queue)
@@ -65,7 +63,7 @@ static int hw_queue_ctor(struct hw_queue *queue, const u32 nr_of_pages,
 	}
 
 	queue->queue_length = nr_of_pages * pagesize;
-	queue->queue_pages = kmalloc(nr_of_pages * sizeof(void*), GFP_KERNEL);
+	queue->queue_pages = kmalloc(nr_of_pages * sizeof(void *), GFP_KERNEL);
 	if (!queue->queue_pages) {
 		ehea_error("no mem for queue_pages");
 		return -ENOMEM;
@@ -78,11 +76,11 @@ static int hw_queue_ctor(struct hw_queue *queue, const u32 nr_of_pages,
 	 */
 	i = 0;
 	while (i < nr_of_pages) {
-		u8 *kpage = (u8*)get_zeroed_page(GFP_KERNEL);
+		u8 *kpage = (u8 *)get_zeroed_page(GFP_KERNEL);
 		if (!kpage)
 			goto out_nomem;
 		for (k = 0; k < pages_per_kpage && i < nr_of_pages; k++) {
-			(queue->queue_pages)[i] = (struct ehea_page*)kpage;
+			(queue->queue_pages)[i] = (struct ehea_page *)kpage;
 			kpage += pagesize;
 			i++;
 		}
@@ -235,8 +233,8 @@ int ehea_destroy_cq(struct ehea_cq *cq)
 		return 0;
 
 	hcp_epas_dtor(&cq->epas);
-
-	if ((hret = ehea_destroy_cq_res(cq, NORMAL_FREE)) == H_R_STATE) {
+	hret = ehea_destroy_cq_res(cq, NORMAL_FREE);
+	if (hret == H_R_STATE) {
 		ehea_error_data(cq->adapter, cq->fw_handle);
 		hret = ehea_destroy_cq_res(cq, FORCE_FREE);
 	}
@@ -301,13 +299,13 @@ struct ehea_eq *ehea_create_eq(struct ehea_adapter *adapter,
 		if (i == (eq->attr.nr_pages - 1)) {
 			/* last page */
 			vpage = hw_qpageit_get_inc(&eq->hw_queue);
-			if ((hret != H_SUCCESS) || (vpage)) {
+			if ((hret != H_SUCCESS) || (vpage))
 				goto out_kill_hwq;
-			}
+
 		} else {
-			if ((hret != H_PAGE_REGISTERED) || (!vpage)) {
+			if ((hret != H_PAGE_REGISTERED) || (!vpage))
 				goto out_kill_hwq;
-			}
+
 		}
 	}
 
@@ -331,7 +329,7 @@ struct ehea_eqe *ehea_poll_eq(struct ehea_eq *eq)
 	unsigned long flags;
 
 	spin_lock_irqsave(&eq->spinlock, flags);
-	eqe = (struct ehea_eqe*)hw_eqit_eq_get_inc_valid(&eq->hw_queue);
+	eqe = (struct ehea_eqe *)hw_eqit_eq_get_inc_valid(&eq->hw_queue);
 	spin_unlock_irqrestore(&eq->spinlock, flags);
 
 	return eqe;
@@ -364,7 +362,8 @@ int ehea_destroy_eq(struct ehea_eq *eq)
 
 	hcp_epas_dtor(&eq->epas);
 
-	if ((hret = ehea_destroy_eq_res(eq, NORMAL_FREE)) == H_R_STATE) {
+	hret = ehea_destroy_eq_res(eq, NORMAL_FREE);
+	if (hret == H_R_STATE) {
 		ehea_error_data(eq->adapter, eq->fw_handle);
 		hret = ehea_destroy_eq_res(eq, FORCE_FREE);
 	}
@@ -546,7 +545,8 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 
 	hcp_epas_dtor(&qp->epas);
 
-	if ((hret = ehea_destroy_qp_res(qp, NORMAL_FREE)) == H_R_STATE) {
+	hret = ehea_destroy_qp_res(qp, NORMAL_FREE);
+	if (hret == H_R_STATE) {
 		ehea_error_data(qp->adapter, qp->fw_handle);
 		hret = ehea_destroy_qp_res(qp, FORCE_FREE);
 	}
@@ -559,7 +559,7 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	return 0;
 }
 
-int ehea_create_busmap( void )
+int ehea_create_busmap(void)
 {
 	u64 vaddr = EHEA_BUSMAP_START;
 	unsigned long high_section_index = 0;
@@ -595,7 +595,7 @@ int ehea_create_busmap( void )
 	return 0;
 }
 
-void ehea_destroy_busmap( void )
+void ehea_destroy_busmap(void)
 {
 	vfree(ehea_bmap.vaddr);
 }
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index bc62d38..0bb6f92 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -41,8 +41,8 @@
 #define EHEA_SECTSIZE          (1UL << 24)
 #define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> EHEA_PAGESHIFT)
 
-#if (1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE
-#error eHEA module can't work if kernel sectionsize < ehea sectionsize
+#if ((1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE)
+#error eHEA module cannot work if kernel sectionsize < ehea sectionsize
 #endif
 
 /* Some abbreviations used here:
@@ -188,8 +188,8 @@ struct ehea_eqe {
 	u64 entry;
 };
 
-#define ERROR_DATA_LENGTH  EHEA_BMASK_IBM(52,63)
-#define ERROR_DATA_TYPE    EHEA_BMASK_IBM(0,7)
+#define ERROR_DATA_LENGTH  EHEA_BMASK_IBM(52, 63)
+#define ERROR_DATA_TYPE    EHEA_BMASK_IBM(0, 7)
 
 static inline void *hw_qeit_calc(struct hw_queue *queue, u64 q_offset)
 {
@@ -279,7 +279,7 @@ static inline void *hw_qeit_eq_get_inc(struct hw_queue *queue)
 static inline void *hw_eqit_eq_get_inc_valid(struct hw_queue *queue)
 {
 	void *retvalue = hw_qeit_get(queue);
-	u32 qe = *(u8*)retvalue;
+	u32 qe = *(u8 *)retvalue;
 	if ((qe >> 7) == (queue->toggle_state & 1))
 		hw_qeit_eq_get_inc(queue);
 	else
@@ -364,7 +364,7 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter, int cqe,
 
 int ehea_destroy_cq(struct ehea_cq *cq);
 
-struct ehea_qp *ehea_create_qp(struct ehea_adapter * adapter, u32 pd,
+struct ehea_qp *ehea_create_qp(struct ehea_adapter *adapter, u32 pd,
 			       struct ehea_qp_init_attr *init_attr);
 
 int ehea_destroy_qp(struct ehea_qp *qp);
@@ -378,8 +378,8 @@ int ehea_rem_mr(struct ehea_mr *mr);
 
 void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle);
 
-int ehea_create_busmap( void );
-void ehea_destroy_busmap( void );
+int ehea_create_busmap(void);
+void ehea_destroy_busmap(void);
 u64 ehea_map_vaddr(void *caddr);
 
 #endif	/* __EHEA_QMR_H__ */
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 46e2c52..95e3464 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -901,12 +901,12 @@ static short ibmlana_adapter_ids[] __initdata = {
 	0x0000
 };
 
-static char *ibmlana_adapter_names[] __initdata = {
+static char *ibmlana_adapter_names[] __devinitdata = {
 	"IBM LAN Adapter/A",
 	NULL
 };
 
-static int ibmlana_init_one(struct device *kdev)
+static int __devinit ibmlana_init_one(struct device *kdev)
 {
 	struct mca_device *mdev = to_mca_device(kdev);
 	struct net_device *dev;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f3c144d..d4eb8e2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -438,7 +438,6 @@ static int igb_request_irq(struct igb_adapter *adapter)
 	if (adapter->msix_entries) {
 		err = igb_request_msix(adapter);
 		if (!err) {
-			struct e1000_hw *hw = &adapter->hw;
 			/* enable IAM, auto-mask,
 			 * DO NOT USE EIAME or IAME in legacy mode */
 			wr32(E1000_IAM, IMS_ENABLE_MASK);
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index e10528e..81bf005 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1084,7 +1084,7 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
 }
 
-static int __devinit macb_probe(struct platform_device *pdev)
+static int __init macb_probe(struct platform_device *pdev)
 {
 	struct eth_platform_data *pdata;
 	struct resource *regs;
@@ -1248,7 +1248,7 @@ err_out:
 	return err;
 }
 
-static int __devexit macb_remove(struct platform_device *pdev)
+static int __exit macb_remove(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct macb *bp;
@@ -1276,8 +1276,7 @@ static int __devexit macb_remove(struct platform_device *pdev)
 }
 
 static struct platform_driver macb_driver = {
-	.probe		= macb_probe,
-	.remove		= __devexit_p(macb_remove),
+	.remove		= __exit_p(macb_remove),
 	.driver		= {
 		.name		= "macb",
 	},
@@ -1285,7 +1284,7 @@ static struct platform_driver macb_driver = {
 
 static int __init macb_init(void)
 {
-	return platform_driver_register(&macb_driver);
+	return platform_driver_probe(&macb_driver, macb_probe);
 }
 
 static void __exit macb_exit(void)
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index aafc3ce..6d343ef 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -4,8 +4,6 @@
  * for more details.
  */
 
-#define DEBUG
-
 #include <linux/init.h>
 #include <linux/io.h>
 #include <linux/kernel.h>
@@ -15,11 +13,93 @@
 #include <linux/platform_device.h>
 #include <asm/mips-boards/simint.h>
 
-#include "mipsnet.h"		/* actual device IO mapping */
+#define MIPSNET_VERSION "2007-11-17"
+
+/*
+ * Net status/control block as seen by sw in the core.
+ */
+struct mipsnet_regs {
+	/*
+	 * Device info for probing, reads as MIPSNET%d where %d is some
+	 * form of version.
+	 */
+	u64 devId;		/*0x00 */
 
-#define MIPSNET_VERSION "2005-06-20"
+	/*
+	 * read only busy flag.
+	 * Set and cleared by the Net Device to indicate that an rx or a tx
+	 * is in progress.
+	 */
+	u32 busy;		/*0x08 */
 
-#define mipsnet_reg_address(dev, field) (dev->base_addr + field_offset(field))
+	/*
+	 * Set by the Net Device.
+	 * The device will set it once data has been received.
+	 * The value is the number of bytes that should be read from
+	 * rxDataBuffer.  The value will decrease till 0 until all the data
+	 * from rxDataBuffer has been read.
+	 */
+	u32 rxDataCount;	/*0x0c */
+#define MIPSNET_MAX_RXTX_DATACOUNT (1 << 16)
+
+	/*
+	 * Settable from the MIPS core, cleared by the Net Device.
+	 * The core should set the number of bytes it wants to send,
+	 * then it should write those bytes of data to txDataBuffer.
+	 * The device will clear txDataCount has been processed (not
+	 * necessarily sent).
+	 */
+	u32 txDataCount;	/*0x10 */
+
+	/*
+	 * Interrupt control
+	 *
+	 * Used to clear the interrupted generated by this dev.
+	 * Write a 1 to clear the interrupt. (except bit31).
+	 *
+	 * Bit0 is set if it was a tx-done interrupt.
+	 * Bit1 is set when new rx-data is available.
+	 *    Until this bit is cleared there will be no other RXs.
+	 *
+	 * Bit31 is used for testing, it clears after a read.
+	 *    Writing 1 to this bit will cause an interrupt to be generated.
+	 *    To clear the test interrupt, write 0 to this register.
+	 */
+	u32 interruptControl;	/*0x14 */
+#define MIPSNET_INTCTL_TXDONE     (1u << 0)
+#define MIPSNET_INTCTL_RXDONE     (1u << 1)
+#define MIPSNET_INTCTL_TESTBIT    (1u << 31)
+
+	/*
+	 * Readonly core-specific interrupt info for the device to signal
+	 * the core. The meaning of the contents of this field might change.
+	 */
+	/* XXX: the whole memIntf interrupt scheme is messy: the device
+	 * should have no control what so ever of what VPE/register set is
+	 * being used.
+	 * The MemIntf should only expose interrupt lines, and something in
+	 * the config should be responsible for the line<->core/vpe bindings.
+	 */
+	u32 interruptInfo;	/*0x18 */
+
+	/*
+	 * This is where the received data is read out.
+	 * There is more data to read until rxDataReady is 0.
+	 * Only 1 byte at this regs offset is used.
+	 */
+	u32 rxDataBuffer;	/*0x1c */
+
+	/*
+	 * This is where the data to transmit is written.
+	 * Data should be written for the amount specified in the
+	 * txDataCount register.
+	 * Only 1 byte at this regs offset is used.
+	 */
+	u32 txDataBuffer;	/*0x20 */
+};
+
+#define regaddr(dev, field) \
+  (dev->base_addr + offsetof(struct mipsnet_regs, field))
 
 static char mipsnet_string[] = "mipsnet";
 
@@ -29,32 +109,27 @@ static char mipsnet_string[] = "mipsnet";
 static int ioiocpy_frommipsnet(struct net_device *dev, unsigned char *kdata,
 			int len)
 {
-	uint32_t available_len = inl(mipsnet_reg_address(dev, rxDataCount));
-
-	if (available_len < len)
-		return -EFAULT;
-
 	for (; len > 0; len--, kdata++)
-		*kdata = inb(mipsnet_reg_address(dev, rxDataBuffer));
+		*kdata = inb(regaddr(dev, rxDataBuffer));
 
-	return inl(mipsnet_reg_address(dev, rxDataCount));
+	return inl(regaddr(dev, rxDataCount));
 }
 
-static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
+static inline void mipsnet_put_todevice(struct net_device *dev,
 	struct sk_buff *skb)
 {
 	int count_to_go = skb->len;
 	char *buf_ptr = skb->data;
 
-	outl(skb->len, mipsnet_reg_address(dev, txDataCount));
+	outl(skb->len, regaddr(dev, txDataCount));
 
 	for (; count_to_go; buf_ptr++, count_to_go--)
-		outb(*buf_ptr, mipsnet_reg_address(dev, txDataBuffer));
+		outb(*buf_ptr, regaddr(dev, txDataBuffer));
 
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
-	return skb->len;
+	dev_kfree_skb(skb);
 }
 
 static int mipsnet_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -69,18 +144,20 @@ static int mipsnet_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
+static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t len)
 {
 	struct sk_buff *skb;
-	size_t len = count;
 
-	skb = alloc_skb(len + 2, GFP_KERNEL);
+	if (!len)
+		return len;
+
+	skb = dev_alloc_skb(len + NET_IP_ALIGN);
 	if (!skb) {
 		dev->stats.rx_dropped++;
 		return -ENOMEM;
 	}
 
-	skb_reserve(skb, 2);
+	skb_reserve(skb, NET_IP_ALIGN);
 	if (ioiocpy_frommipsnet(dev, skb_put(skb, len), len))
 		return -EFAULT;
 
@@ -92,50 +169,42 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
 
-	return count;
+	return len;
 }
 
 static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-
-	irqreturn_t retval = IRQ_NONE;
-	uint64_t interruptFlags;
-
-	if (irq == dev->irq) {
-		retval = IRQ_HANDLED;
-
-		interruptFlags =
-		    inl(mipsnet_reg_address(dev, interruptControl));
-
-		if (interruptFlags & MIPSNET_INTCTL_TXDONE) {
-			outl(MIPSNET_INTCTL_TXDONE,
-			     mipsnet_reg_address(dev, interruptControl));
-			/* only one packet at a time, we are done. */
-			netif_wake_queue(dev);
-		} else if (interruptFlags & MIPSNET_INTCTL_RXDONE) {
-			mipsnet_get_fromdev(dev,
-				    inl(mipsnet_reg_address(dev, rxDataCount)));
-			outl(MIPSNET_INTCTL_RXDONE,
-			     mipsnet_reg_address(dev, interruptControl));
-
-		} else if (interruptFlags & MIPSNET_INTCTL_TESTBIT) {
-			/*
-			 * TESTBIT is cleared on read.
-			 * And takes effect after a write with 0
-			 */
-			outl(0, mipsnet_reg_address(dev, interruptControl));
-		} else {
-			/* Maybe shared IRQ, just ignore, no clearing. */
-			retval = IRQ_NONE;
-		}
-
-	} else {
-		printk(KERN_INFO "%s: %s(): irq %d for unknown device\n",
-		       dev->name, __FUNCTION__, irq);
-		retval = IRQ_NONE;
+	u32 int_flags;
+	irqreturn_t ret = IRQ_NONE;
+
+	if (irq != dev->irq)
+		goto out_badirq;
+
+	/* TESTBIT is cleared on read. */
+	int_flags = inl(regaddr(dev, interruptControl));
+	if (int_flags & MIPSNET_INTCTL_TESTBIT) {
+		/* TESTBIT takes effect after a write with 0. */
+		outl(0, regaddr(dev, interruptControl));
+		ret = IRQ_HANDLED;
+	} else if (int_flags & MIPSNET_INTCTL_TXDONE) {
+		/* Only one packet at a time, we are done. */
+		dev->stats.tx_packets++;
+		netif_wake_queue(dev);
+		outl(MIPSNET_INTCTL_TXDONE,
+		     regaddr(dev, interruptControl));
+		ret = IRQ_HANDLED;
+	} else if (int_flags & MIPSNET_INTCTL_RXDONE) {
+		mipsnet_get_fromdev(dev, inl(regaddr(dev, rxDataCount)));
+		outl(MIPSNET_INTCTL_RXDONE, regaddr(dev, interruptControl));
+		ret = IRQ_HANDLED;
 	}
-	return retval;
+	return ret;
+
+out_badirq:
+	printk(KERN_INFO "%s: %s(): irq %d for unknown device\n",
+	       dev->name, __FUNCTION__, irq);
+	return ret;
 }
 
 static int mipsnet_open(struct net_device *dev)
@@ -144,18 +213,15 @@ static int mipsnet_open(struct net_device *dev)
 
 	err = request_irq(dev->irq, &mipsnet_interrupt,
 			  IRQF_SHARED, dev->name, (void *) dev);
-
 	if (err) {
-		release_region(dev->base_addr, MIPSNET_IO_EXTENT);
+		release_region(dev->base_addr, sizeof(struct mipsnet_regs));
 		return err;
 	}
 
 	netif_start_queue(dev);
 
 	/* test interrupt handler */
-	outl(MIPSNET_INTCTL_TESTBIT,
-	     mipsnet_reg_address(dev, interruptControl));
-
+	outl(MIPSNET_INTCTL_TESTBIT, regaddr(dev, interruptControl));
 
 	return 0;
 }
@@ -163,7 +229,7 @@ static int mipsnet_open(struct net_device *dev)
 static int mipsnet_close(struct net_device *dev)
 {
 	netif_stop_queue(dev);
-
+	free_irq(dev->irq, dev);
 	return 0;
 }
 
@@ -194,10 +260,11 @@ static int __init mipsnet_probe(struct device *dev)
 	 */
 	netdev->base_addr = 0x4200;
 	netdev->irq = MIPS_CPU_IRQ_BASE + MIPSCPU_INT_MB0 +
-		      inl(mipsnet_reg_address(netdev, interruptInfo));
+		      inl(regaddr(netdev, interruptInfo));
 
 	/* Get the io region now, get irq on open() */
-	if (!request_region(netdev->base_addr, MIPSNET_IO_EXTENT, "mipsnet")) {
+	if (!request_region(netdev->base_addr, sizeof(struct mipsnet_regs),
+			    "mipsnet")) {
 		err = -EBUSY;
 		goto out_free_netdev;
 	}
@@ -217,7 +284,7 @@ static int __init mipsnet_probe(struct device *dev)
 	return 0;
 
 out_free_region:
-	release_region(netdev->base_addr, MIPSNET_IO_EXTENT);
+	release_region(netdev->base_addr, sizeof(struct mipsnet_regs));
 
 out_free_netdev:
 	free_netdev(netdev);
@@ -231,7 +298,7 @@ static int __devexit mipsnet_device_remove(struct device *device)
 	struct net_device *dev = dev_get_drvdata(device);
 
 	unregister_netdev(dev);
-	release_region(dev->base_addr, MIPSNET_IO_EXTENT);
+	release_region(dev->base_addr, sizeof(struct mipsnet_regs));
 	free_netdev(dev);
 	dev_set_drvdata(device, NULL);
 
diff --git a/drivers/net/mipsnet.h b/drivers/net/mipsnet.h
deleted file mode 100644
index 0132c67..0000000
--- a/drivers/net/mipsnet.h
+++ /dev/null
@@ -1,112 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- */
-#ifndef __MIPSNET_H
-#define __MIPSNET_H
-
-/*
- *  Id of this Net device, as seen by the core.
- */
-#define MIPS_NET_DEV_ID ((uint64_t)	   \
-			     ((uint64_t) 'M' <<  0)| \
-			     ((uint64_t) 'I' <<  8)| \
-			     ((uint64_t) 'P' << 16)| \
-			     ((uint64_t) 'S' << 24)| \
-			     ((uint64_t) 'N' << 32)| \
-			     ((uint64_t) 'E' << 40)| \
-			     ((uint64_t) 'T' << 48)| \
-			     ((uint64_t) '0' << 56))
-
-/*
- * Net status/control block as seen by sw in the core.
- * (Why not use bit fields? can't be bothered with cross-platform struct
- *  packing.)
- */
-struct net_control_block {
-	/*
-	 * dev info for probing
-	 * reads as MIPSNET%d where %d is some form of version
-	 */
-	uint64_t devId;		/* 0x00 */
-
-	/*
-	 * read only busy flag.
-	 * Set and cleared by the Net Device to indicate that an rx or a tx
-	 * is in progress.
-	 */
-	uint32_t busy;		/* 0x08 */
-
-	/*
-	 * Set by the Net Device.
-	 * The device will set it once data has been received.
-	 * The value is the number of bytes that should be read from
-	 * rxDataBuffer.  The value will decrease till 0 until all the data
-	 * from rxDataBuffer has been read.
-	 */
-	uint32_t rxDataCount;	/* 0x0c */
-#define MIPSNET_MAX_RXTX_DATACOUNT (1<<16)
-
-	/*
-	 * Settable from the MIPS core, cleared by the Net Device.  The core
-	 * should set the number of bytes it wants to send, then it should
-	 * write those bytes of data to txDataBuffer.  The device will clear
-	 * txDataCount has been processed (not necessarily sent).
-	 */
-	uint32_t txDataCount;	/* 0x10 */
-
-	/*
-	 * Interrupt control
-	 *
-	 * Used to clear the interrupted generated by this dev.
-	 * Write a 1 to clear the interrupt. (except bit31).
-	 *
-	 * Bit0 is set if it was a tx-done interrupt.
-	 * Bit1 is set when new rx-data is available.
-	 *      Until this bit is cleared there will be no other RXs.
-	 *
-	 * Bit31 is used for testing, it clears after a read.
-	 *    Writing 1 to this bit will cause an interrupt to be generated.
-	 *    To clear the test interrupt, write 0 to this register.
-	 */
-	uint32_t interruptControl;	/*0x14 */
-#define MIPSNET_INTCTL_TXDONE     ((uint32_t)(1 <<  0))
-#define MIPSNET_INTCTL_RXDONE     ((uint32_t)(1 <<  1))
-#define MIPSNET_INTCTL_TESTBIT    ((uint32_t)(1 << 31))
-#define MIPSNET_INTCTL_ALLSOURCES	(MIPSNET_INTCTL_TXDONE | \
-					 MIPSNET_INTCTL_RXDONE | \
-					 MIPSNET_INTCTL_TESTBIT)
-
-	/*
-	 * Readonly core-specific interrupt info for the device to signal the
-	 * core.  The meaning of the contents of this field might change.
-	 *
-	 * TODO: the whole memIntf interrupt scheme is messy: the device should
-	 *       have no control what so ever of what VPE/register set is being
-	 *       used.  The MemIntf should only expose interrupt lines, and
-	 *       something in the config should be responsible for the
-	 *       line<->core/vpe bindings.
-	 */
-	uint32_t interruptInfo;	/* 0x18 */
-
-	/*
-	 *  This is where the received data is read out.
-	 *  There is more data to read until rxDataReady is 0.
-	 *  Only 1 byte at this regs offset is used.
-	 */
-	uint32_t rxDataBuffer;	/* 0x1c */
-
-	/*
-	 * This is where the data to transmit is written.  Data should be
-	 * written for the amount specified in the txDataCount register.  Only
-	 * 1 byte at this regs offset is used.
-	 */
-	uint32_t txDataBuffer;	/* 0x20 */
-};
-
-#define MIPSNET_IO_EXTENT 0x40	/* being generous */
-
-#define field_offset(field) (offsetof(struct net_control_block, field))
-
-#endif /* __MIPSNET_H */
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index bb88a41..2e39e02 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -62,6 +62,10 @@
 
 #define LRO_MAX_AGGR 64
 
+#define PE_MIN_MTU	64
+#define PE_MAX_MTU	1500
+#define PE_DEF_MTU	ETH_DATA_LEN
+
 #define DEFAULT_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
 	 NETIF_MSG_PROBE	| \
@@ -82,8 +86,6 @@
 				 & ((ring)->size - 1))
 #define RING_AVAIL(ring)	((ring->size) - RING_USED(ring))
 
-#define BUF_SIZE 1646 /* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
 MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
@@ -175,6 +177,24 @@ static int mac_to_intf(struct pasemi_mac *mac)
 	return -1;
 }
 
+static void pasemi_mac_intf_disable(struct pasemi_mac *mac)
+{
+	unsigned int flags;
+
+	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
+	flags &= ~PAS_MAC_CFG_PCFG_PE;
+	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
+}
+
+static void pasemi_mac_intf_enable(struct pasemi_mac *mac)
+{
+	unsigned int flags;
+
+	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
+	flags |= PAS_MAC_CFG_PCFG_PE;
+	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
+}
+
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 {
 	struct pci_dev *pdev = mac->pdev;
@@ -221,6 +241,33 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 	return 0;
 }
 
+static int pasemi_mac_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	struct sockaddr *addr = p;
+	unsigned int adr0, adr1;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	adr0 = dev->dev_addr[2] << 24 |
+	       dev->dev_addr[3] << 16 |
+	       dev->dev_addr[4] << 8 |
+	       dev->dev_addr[5];
+	adr1 = read_mac_reg(mac, PAS_MAC_CFG_ADR1);
+	adr1 &= ~0xffff;
+	adr1 |= dev->dev_addr[0] << 8 | dev->dev_addr[1];
+
+	pasemi_mac_intf_disable(mac);
+	write_mac_reg(mac, PAS_MAC_CFG_ADR0, adr0);
+	write_mac_reg(mac, PAS_MAC_CFG_ADR1, adr1);
+	pasemi_mac_intf_enable(mac);
+
+	return 0;
+}
+
 static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 		       void **tcph, u64 *hdr_flags, void *data)
 {
@@ -453,7 +500,7 @@ static void pasemi_mac_free_tx_resources(struct pasemi_mac *mac)
 
 }
 
-static void pasemi_mac_free_rx_resources(struct pasemi_mac *mac)
+static void pasemi_mac_free_rx_buffers(struct pasemi_mac *mac)
 {
 	struct pasemi_mac_rxring *rx = rx_ring(mac);
 	unsigned int i;
@@ -473,7 +520,12 @@ static void pasemi_mac_free_rx_resources(struct pasemi_mac *mac)
 	}
 
 	for (i = 0; i < RX_RING_SIZE; i++)
-		RX_DESC(rx, i) = 0;
+		RX_BUFF(rx, i) = 0;
+}
+
+static void pasemi_mac_free_rx_resources(struct pasemi_mac *mac)
+{
+	pasemi_mac_free_rx_buffers(mac);
 
 	dma_free_coherent(&mac->dma_pdev->dev, RX_RING_SIZE * sizeof(u64),
 			  rx_ring(mac)->buffers, rx_ring(mac)->buf_dma);
@@ -503,14 +555,14 @@ static void pasemi_mac_replenish_rx_ring(const struct net_device *dev,
 		/* Entry in use? */
 		WARN_ON(*buff);
 
-		skb = dev_alloc_skb(BUF_SIZE);
+		skb = dev_alloc_skb(mac->bufsz);
 		skb_reserve(skb, LOCAL_SKB_ALIGN);
 
 		if (unlikely(!skb))
 			break;
 
 		dma = pci_map_single(mac->dma_pdev, skb->data,
-				     BUF_SIZE - LOCAL_SKB_ALIGN,
+				     mac->bufsz - LOCAL_SKB_ALIGN,
 				     PCI_DMA_FROMDEVICE);
 
 		if (unlikely(dma_mapping_error(dma))) {
@@ -520,7 +572,7 @@ static void pasemi_mac_replenish_rx_ring(const struct net_device *dev,
 
 		info->skb = skb;
 		info->dma = dma;
-		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
+		*buff = XCT_RXB_LEN(mac->bufsz) | XCT_RXB_ADDR(dma);
 		fill++;
 	}
 
@@ -650,7 +702,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac_rxring *rx,
 
 		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
-		pci_unmap_single(pdev, dma, BUF_SIZE-LOCAL_SKB_ALIGN,
+		pci_unmap_single(pdev, dma, mac->bufsz - LOCAL_SKB_ALIGN,
 				 PCI_DMA_FROMDEVICE);
 
 		if (macrx & XCT_MACRX_CRC) {
@@ -874,24 +926,6 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static void pasemi_mac_intf_disable(struct pasemi_mac *mac)
-{
-	unsigned int flags;
-
-	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
-	flags &= ~PAS_MAC_CFG_PCFG_PE;
-	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
-}
-
-static void pasemi_mac_intf_enable(struct pasemi_mac *mac)
-{
-	unsigned int flags;
-
-	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
-	flags |= PAS_MAC_CFG_PCFG_PE;
-	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
-}
-
 static void pasemi_adjust_link(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
@@ -1148,11 +1182,71 @@ out_rx_resources:
 
 #define MAX_RETRIES 5000
 
+static void pasemi_mac_pause_txchan(struct pasemi_mac *mac)
+{
+	unsigned int sta, retries;
+	int txch = tx_ring(mac)->chan.chno;
+
+	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch),
+		      PAS_DMA_TXCHAN_TCMDSTA_ST);
+
+	for (retries = 0; retries < MAX_RETRIES; retries++) {
+		sta = read_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch));
+		if (!(sta & PAS_DMA_TXCHAN_TCMDSTA_ACT))
+			break;
+		cond_resched();
+	}
+
+	if (sta & PAS_DMA_TXCHAN_TCMDSTA_ACT)
+		dev_err(&mac->dma_pdev->dev,
+			"Failed to stop tx channel, tcmdsta %08x\n", sta);
+
+	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch), 0);
+}
+
+static void pasemi_mac_pause_rxchan(struct pasemi_mac *mac)
+{
+	unsigned int sta, retries;
+	int rxch = rx_ring(mac)->chan.chno;
+
+	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch),
+		      PAS_DMA_RXCHAN_CCMDSTA_ST);
+	for (retries = 0; retries < MAX_RETRIES; retries++) {
+		sta = read_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch));
+		if (!(sta & PAS_DMA_RXCHAN_CCMDSTA_ACT))
+			break;
+		cond_resched();
+	}
+
+	if (sta & PAS_DMA_RXCHAN_CCMDSTA_ACT)
+		dev_err(&mac->dma_pdev->dev,
+			"Failed to stop rx channel, ccmdsta 08%x\n", sta);
+	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch), 0);
+}
+
+static void pasemi_mac_pause_rxint(struct pasemi_mac *mac)
+{
+	unsigned int sta, retries;
+
+	write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+		      PAS_DMA_RXINT_RCMDSTA_ST);
+	for (retries = 0; retries < MAX_RETRIES; retries++) {
+		sta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+		if (!(sta & PAS_DMA_RXINT_RCMDSTA_ACT))
+			break;
+		cond_resched();
+	}
+
+	if (sta & PAS_DMA_RXINT_RCMDSTA_ACT)
+		dev_err(&mac->dma_pdev->dev,
+			"Failed to stop rx interface, rcmdsta %08x\n", sta);
+	write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
+}
+
 static int pasemi_mac_close(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int sta;
-	int retries;
 	int rxch, txch;
 
 	rxch = rx_ring(mac)->chan.chno;
@@ -1190,51 +1284,10 @@ static int pasemi_mac_close(struct net_device *dev)
 	pasemi_mac_clean_tx(tx_ring(mac));
 	pasemi_mac_clean_rx(rx_ring(mac), RX_RING_SIZE);
 
-	/* Disable interface */
-	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch),
-		      PAS_DMA_TXCHAN_TCMDSTA_ST);
-	write_dma_reg( PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-		      PAS_DMA_RXINT_RCMDSTA_ST);
-	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch),
-		      PAS_DMA_RXCHAN_CCMDSTA_ST);
-
-	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(rxch));
-		if (!(sta & PAS_DMA_TXCHAN_TCMDSTA_ACT))
-			break;
-		cond_resched();
-	}
-
-	if (sta & PAS_DMA_TXCHAN_TCMDSTA_ACT)
-		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
-
-	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch));
-		if (!(sta & PAS_DMA_RXCHAN_CCMDSTA_ACT))
-			break;
-		cond_resched();
-	}
-
-	if (sta & PAS_DMA_RXCHAN_CCMDSTA_ACT)
-		dev_err(&mac->dma_pdev->dev, "Failed to stop rx channel\n");
-
-	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
-		if (!(sta & PAS_DMA_RXINT_RCMDSTA_ACT))
-			break;
-		cond_resched();
-	}
-
-	if (sta & PAS_DMA_RXINT_RCMDSTA_ACT)
-		dev_err(&mac->dma_pdev->dev, "Failed to stop rx interface\n");
-
-	/* Then, disable the channel. This must be done separately from
-	 * stopping, since you can't disable when active.
-	 */
-
-	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch), 0);
-	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch), 0);
-	write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
+	pasemi_mac_pause_txchan(mac);
+	pasemi_mac_pause_rxint(mac);
+	pasemi_mac_pause_rxchan(mac);
+	pasemi_mac_intf_disable(mac);
 
 	free_irq(mac->tx->chan.irq, mac->tx);
 	free_irq(mac->rx->chan.irq, mac->rx);
@@ -1388,6 +1441,62 @@ static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 	return pkts;
 }
 
+static int pasemi_mac_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int reg;
+	unsigned int rcmdsta;
+	int running;
+
+	if (new_mtu < PE_MIN_MTU || new_mtu > PE_MAX_MTU)
+		return -EINVAL;
+
+	running = netif_running(dev);
+
+	if (running) {
+		/* Need to stop the interface, clean out all already
+		 * received buffers, free all unused buffers on the RX
+		 * interface ring, then finally re-fill the rx ring with
+		 * the new-size buffers and restart.
+		 */
+
+		napi_disable(&mac->napi);
+		netif_tx_disable(dev);
+		pasemi_mac_intf_disable(mac);
+
+		rcmdsta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+		pasemi_mac_pause_rxint(mac);
+		pasemi_mac_clean_rx(rx_ring(mac), RX_RING_SIZE);
+		pasemi_mac_free_rx_buffers(mac);
+	}
+
+	/* Change maxf, i.e. what size frames are accepted.
+	 * Need room for ethernet header and CRC word
+	 */
+	reg = read_mac_reg(mac, PAS_MAC_CFG_MACCFG);
+	reg &= ~PAS_MAC_CFG_MACCFG_MAXF_M;
+	reg |= PAS_MAC_CFG_MACCFG_MAXF(new_mtu + ETH_HLEN + 4);
+	write_mac_reg(mac, PAS_MAC_CFG_MACCFG, reg);
+
+	dev->mtu = new_mtu;
+	/* MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
+	mac->bufsz = new_mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
+
+	if (running) {
+		write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+			      rcmdsta | PAS_DMA_RXINT_RCMDSTA_EN);
+
+		rx_ring(mac)->next_to_fill = 0;
+		pasemi_mac_replenish_rx_ring(dev, RX_RING_SIZE-1);
+
+		napi_enable(&mac->napi);
+		netif_start_queue(dev);
+		pasemi_mac_intf_enable(mac);
+	}
+
+	return 0;
+}
+
 static int __devinit
 pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1475,6 +1584,12 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->stop = pasemi_mac_close;
 	dev->hard_start_xmit = pasemi_mac_start_tx;
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
+	dev->set_mac_address = pasemi_mac_set_mac_addr;
+	dev->mtu = PE_DEF_MTU;
+	/* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
+	mac->bufsz = dev->mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
+
+	dev->change_mtu = pasemi_mac_change_mtu;
 
 	if (err)
 		goto out;
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index 8bee2a6..99e7b93 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -59,6 +59,7 @@ struct pasemi_mac {
 	struct phy_device *phydev;
 	struct napi_struct napi;
 
+	int		bufsz; /* RX ring buffer size */
 	u8		type;
 #define MAC_TYPE_GMAC	1
 #define MAC_TYPE_XAUI	2
@@ -96,6 +97,9 @@ struct pasemi_mac_buffer {
 /* MAC CFG register offsets */
 enum {
 	PAS_MAC_CFG_PCFG = 0x80,
+	PAS_MAC_CFG_MACCFG = 0x84,
+	PAS_MAC_CFG_ADR0 = 0x8c,
+	PAS_MAC_CFG_ADR1 = 0x90,
 	PAS_MAC_CFG_TXP = 0x98,
 	PAS_MAC_IPC_CHNL = 0x208,
 };
@@ -130,6 +134,18 @@ enum {
 #define PAS_MAC_CFG_PCFG_SPD_100M	0x00000001
 #define PAS_MAC_CFG_PCFG_SPD_1G		0x00000002
 #define PAS_MAC_CFG_PCFG_SPD_10G	0x00000003
+
+#define PAS_MAC_CFG_MACCFG_TXT_M	0x70000000
+#define PAS_MAC_CFG_MACCFG_TXT_S	28
+#define PAS_MAC_CFG_MACCFG_PRES_M	0x0f000000
+#define PAS_MAC_CFG_MACCFG_PRES_S	24
+#define PAS_MAC_CFG_MACCFG_MAXF_M	0x00ffff00
+#define PAS_MAC_CFG_MACCFG_MAXF_S	8
+#define PAS_MAC_CFG_MACCFG_MAXF(x)	(((x) << PAS_MAC_CFG_MACCFG_MAXF_S) & \
+					 PAS_MAC_CFG_MACCFG_MAXF_M)
+#define PAS_MAC_CFG_MACCFG_MINF_M	0x000000ff
+#define PAS_MAC_CFG_MACCFG_MINF_S	0
+
 #define PAS_MAC_CFG_TXP_FCF		0x01000000
 #define PAS_MAC_CFG_TXP_FCE		0x00800000
 #define PAS_MAC_CFG_TXP_FC		0x00400000
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 29666c8..5b80358 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -141,6 +141,20 @@ static struct phy_driver bcm5461_driver = {
 	.driver 	= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm5482_driver = {
+    .phy_id		= 0x0143bcb0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM5482",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm54xx_ack_interrupt,
+	.config_intr	= bcm54xx_config_intr,
+	.driver 	= { .owner = THIS_MODULE },
+};
+
 static int __init broadcom_init(void)
 {
 	int ret;
@@ -154,8 +168,13 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm5461_driver);
 	if (ret)
 		goto out_5461;
+	ret = phy_driver_register(&bcm5482_driver);
+	if (ret)
+		goto out_5482;
 	return ret;
 
+out_5482:
+	phy_driver_unregister(&bcm5461_driver);
 out_5461:
 	phy_driver_unregister(&bcm5421_driver);
 out_5421:
@@ -166,6 +185,7 @@ out_5411:
 
 static void __exit broadcom_exit(void)
 {
+	phy_driver_unregister(&bcm5482_driver);
 	phy_driver_unregister(&bcm5461_driver);
 	phy_driver_unregister(&bcm5421_driver);
 	phy_driver_unregister(&bcm5411_driver);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 5fab7d7..4575d06 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -386,6 +386,19 @@ static void s2io_vlan_rx_register(struct net_device *dev,
 /* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
 static int vlan_strip_flag;
 
+/* Unregister the vlan */
+static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
+{
+	unsigned long flags;
+	struct s2io_nic *nic = dev->priv;
+
+	spin_lock_irqsave(&nic->tx_lock, flags);
+	if (nic->vlgrp)
+		vlan_group_set_device(nic->vlgrp, vid, NULL);
+
+	spin_unlock_irqrestore(&nic->tx_lock, flags);
+}
+
 /*
  * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
@@ -2948,7 +2961,7 @@ static void rx_intr_handler(struct ring_info *ring_data)
 			struct lro *lro = &nic->lro0_n[i];
 			if (lro->in_use) {
 				update_L3L4_header(nic, lro);
-				queue_rx_frame(lro->parent);
+				queue_rx_frame(lro->parent, lro->vlan_tag);
 				clear_lro_session(lro);
 			}
 		}
@@ -7371,7 +7384,8 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 					{
 						lro_append_pkt(sp, lro,
 							skb, tcp_len);
-						queue_rx_frame(lro->parent);
+						queue_rx_frame(lro->parent,
+							lro->vlan_tag);
 						clear_lro_session(lro);
 						sp->mac_control.stats_info->
 						    sw_stat.flush_max_pkts++;
@@ -7382,7 +7396,8 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 							lro->frags_len;
 						sp->mac_control.stats_info->
 						     sw_stat.sending_both++;
-						queue_rx_frame(lro->parent);
+						queue_rx_frame(lro->parent,
+							lro->vlan_tag);
 						clear_lro_session(lro);
 						goto send_up;
 					case 0: /* sessions exceeded */
@@ -7408,31 +7423,12 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 			 */
 			skb->ip_summed = CHECKSUM_NONE;
 		}
-	} else {
+	} else
 		skb->ip_summed = CHECKSUM_NONE;
-	}
+
 	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
-	if (!sp->lro) {
-		skb->protocol = eth_type_trans(skb, dev);
-		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
-			vlan_strip_flag)) {
-			/* Queueing the vlan frame to the upper layer */
-			if (napi)
-				vlan_hwaccel_receive_skb(skb, sp->vlgrp,
-					RXD_GET_VLAN_TAG(rxdp->Control_2));
-			else
-				vlan_hwaccel_rx(skb, sp->vlgrp,
-					RXD_GET_VLAN_TAG(rxdp->Control_2));
-		} else {
-			if (napi)
-				netif_receive_skb(skb);
-			else
-				netif_rx(skb);
-		}
-	} else {
 send_up:
-		queue_rx_frame(skb);
-	}
+	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
 	dev->last_rx = jiffies;
 aggregate:
 	atomic_dec(&sp->rx_bufs_left[ring_no]);
@@ -7790,6 +7786,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = s2io_vlan_rx_register;
+	dev->vlan_rx_kill_vid = (void *)s2io_vlan_rx_kill_vid;
 
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
@@ -8061,7 +8058,8 @@ module_init(s2io_starter);
 module_exit(s2io_closer);
 
 static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
-		struct tcphdr **tcp, struct RxD_t *rxdp)
+		struct tcphdr **tcp, struct RxD_t *rxdp,
+		struct s2io_nic *sp)
 {
 	int ip_off;
 	u8 l2_type = (u8)((rxdp->Control_1 >> 37) & 0x7), ip_len;
@@ -8072,19 +8070,20 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 		return -1;
 	}
 
-	/* TODO:
-	 * By default the VLAN field in the MAC is stripped by the card, if this
-	 * feature is turned off in rx_pa_cfg register, then the ip_off field
-	 * has to be shifted by a further 2 bytes
-	 */
-	switch (l2_type) {
-		case 0: /* DIX type */
-		case 4: /* DIX type with VLAN */
-			ip_off = HEADER_ETHERNET_II_802_3_SIZE;
-			break;
+	/* Checking for DIX type or DIX type with VLAN */
+	if ((l2_type == 0)
+		|| (l2_type == 4)) {
+		ip_off = HEADER_ETHERNET_II_802_3_SIZE;
+		/*
+		 * If vlan stripping is disabled and the frame is VLAN tagged,
+		 * shift the offset by the VLAN header size bytes.
+		 */
+		if ((!vlan_strip_flag) &&
+			(rxdp->Control_1 & RXD_FRAME_VLAN_TAG))
+			ip_off += HEADER_VLAN_SIZE;
+	} else {
 		/* LLC, SNAP etc are considered non-mergeable */
-		default:
-			return -1;
+		return -1;
 	}
 
 	*ip = (struct iphdr *)((u8 *)buffer + ip_off);
@@ -8111,26 +8110,27 @@ static inline int get_l4_pyld_length(struct iphdr *ip, struct tcphdr *tcp)
 }
 
 static void initiate_new_session(struct lro *lro, u8 *l2h,
-		     struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len)
+	struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len, u16 vlan_tag)
 {
 	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
 	lro->l2h = l2h;
 	lro->iph = ip;
 	lro->tcph = tcp;
 	lro->tcp_next_seq = tcp_pyld_len + ntohl(tcp->seq);
-	lro->tcp_ack = ntohl(tcp->ack_seq);
+	lro->tcp_ack = tcp->ack_seq;
 	lro->sg_num = 1;
 	lro->total_len = ntohs(ip->tot_len);
 	lro->frags_len = 0;
+	lro->vlan_tag = vlan_tag;
 	/*
 	 * check if we saw TCP timestamp. Other consistency checks have
 	 * already been done.
  	 */
 	if (tcp->doff == 8) {
-		u32 *ptr;
-		ptr = (u32 *)(tcp+1);
+		__be32 *ptr;
+		ptr = (__be32 *)(tcp+1);
 		lro->saw_ts = 1;
-		lro->cur_tsval = *(ptr+1);
+		lro->cur_tsval = ntohl(*(ptr+1));
 		lro->cur_tsecr = *(ptr+2);
 	}
 	lro->in_use = 1;
@@ -8156,7 +8156,7 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 
 	/* Update tsecr field if this session has timestamps enabled */
 	if (lro->saw_ts) {
-		u32 *ptr = (u32 *)(tcp + 1);
+		__be32 *ptr = (__be32 *)(tcp + 1);
 		*(ptr+2) = lro->cur_tsecr;
 	}
 
@@ -8181,10 +8181,10 @@ static void aggregate_new_rx(struct lro *lro, struct iphdr *ip,
 	lro->window = tcp->window;
 
 	if (lro->saw_ts) {
-		u32 *ptr;
+		__be32 *ptr;
 		/* Update tsecr and tsval from this packet */
-		ptr = (u32 *) (tcp + 1);
-		lro->cur_tsval = *(ptr + 1);
+		ptr = (__be32 *)(tcp+1);
+		lro->cur_tsval = ntohl(*(ptr+1));
 		lro->cur_tsecr = *(ptr + 2);
 	}
 }
@@ -8235,11 +8235,11 @@ static int verify_l3_l4_lro_capable(struct lro *l_lro, struct iphdr *ip,
 
 		/* Ensure timestamp value increases monotonically */
 		if (l_lro)
-			if (l_lro->cur_tsval > *((u32 *)(ptr+2)))
+			if (l_lro->cur_tsval > ntohl(*((__be32 *)(ptr+2))))
 				return -1;
 
 		/* timestamp echo reply should be non-zero */
-		if (*((u32 *)(ptr+6)) == 0)
+		if (*((__be32 *)(ptr+6)) == 0)
 			return -1;
 	}
 
@@ -8253,15 +8253,16 @@ s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 	struct iphdr *ip;
 	struct tcphdr *tcph;
 	int ret = 0, i;
+	u16 vlan_tag = 0;
 
 	if (!(ret = check_L2_lro_capable(buffer, &ip, (struct tcphdr **)tcp,
-					 rxdp))) {
+					 rxdp, sp))) {
 		DBG_PRINT(INFO_DBG,"IP Saddr: %x Daddr: %x\n",
 			  ip->saddr, ip->daddr);
-	} else {
+	} else
 		return ret;
-	}
 
+	vlan_tag = RXD_GET_VLAN_TAG(rxdp->Control_2);
 	tcph = (struct tcphdr *)*tcp;
 	*tcp_len = get_l4_pyld_length(ip, tcph);
 	for (i=0; i<MAX_LRO_SESSIONS; i++) {
@@ -8321,7 +8322,8 @@ s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 
 	switch (ret) {
 		case 3:
-			initiate_new_session(*lro, buffer, ip, tcph, *tcp_len);
+			initiate_new_session(*lro, buffer, ip, tcph, *tcp_len,
+								vlan_tag);
 			break;
 		case 2:
 			update_L3L4_header(sp, *lro);
@@ -8349,15 +8351,25 @@ static void clear_lro_session(struct lro *lro)
 	memset(lro, 0, lro_struct_size);
 }
 
-static void queue_rx_frame(struct sk_buff *skb)
+static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 {
 	struct net_device *dev = skb->dev;
+	struct s2io_nic *sp = dev->priv;
 
 	skb->protocol = eth_type_trans(skb, dev);
-	if (napi)
-		netif_receive_skb(skb);
-	else
-		netif_rx(skb);
+	if (sp->vlgrp && vlan_tag
+		&& (vlan_strip_flag)) {
+		/* Queueing the vlan frame to the upper layer */
+		if (sp->config.napi)
+			vlan_hwaccel_receive_skb(skb, sp->vlgrp, vlan_tag);
+		else
+			vlan_hwaccel_rx(skb, sp->vlgrp, vlan_tag);
+	} else {
+		if (sp->config.napi)
+			netif_receive_skb(skb);
+		else
+			netif_rx(skb);
+	}
 }
 
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 9f6016c..5b9f546 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -534,6 +534,7 @@ struct RxD_t {
 #define RXD_OWN_XENA            s2BIT(7)
 #define RXD_T_CODE              (s2BIT(12)|s2BIT(13)|s2BIT(14)|s2BIT(15))
 #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
+#define RXD_FRAME_VLAN_TAG      s2BIT(24)
 #define RXD_FRAME_PROTO_IPV4    s2BIT(27)
 #define RXD_FRAME_PROTO_IPV6    s2BIT(28)
 #define RXD_FRAME_IP_FRAG	s2BIT(29)
@@ -808,10 +809,12 @@ struct lro {
 	int		sg_num;
 	int		in_use;
 	__be16		window;
+	u16             vlan_tag;
 	u32		cur_tsval;
-	u32		cur_tsecr;
+	__be32		cur_tsecr;
 	u8		saw_ts;
-};
+} ____cacheline_aligned;
+
 
 /* These flags represent the devices temporary state */
 enum s2io_device_state_t
@@ -1087,7 +1090,7 @@ static int
 s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 		      struct RxD_t *rxdp, struct s2io_nic *sp);
 static void clear_lro_session(struct lro *lro);
-static void queue_rx_frame(struct sk_buff *skb);
+static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag);
 static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro);
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 			   struct sk_buff *skb, u32 tcp_len);
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index fe3ac6f..0e4a88d 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1075,7 +1075,7 @@ static const struct ethtool_ops bigmac_ethtool_ops = {
 	.get_link		= bigmac_get_link,
 };
 
-static int __init bigmac_ether_init(struct sbus_dev *qec_sdev)
+static int __devinit bigmac_ether_init(struct sbus_dev *qec_sdev)
 {
 	struct net_device *dev;
 	static int version_printed;
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index ff23c64..e811331 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -747,7 +747,7 @@ static inline void qec_init_once(struct sunqec *qecp, struct sbus_dev *qsdev)
 		    qecp->gregs + GLOB_RSIZE);
 }
 
-static u8 __init qec_get_burst(struct device_node *dp)
+static u8 __devinit qec_get_burst(struct device_node *dp)
 {
 	u8 bsizes, bsizes_more;
 
@@ -767,7 +767,7 @@ static u8 __init qec_get_burst(struct device_node *dp)
 	return bsizes;
 }
 
-static struct sunqec * __init get_qec(struct sbus_dev *child_sdev)
+static struct sunqec * __devinit get_qec(struct sbus_dev *child_sdev)
 {
 	struct sbus_dev *qec_sdev = child_sdev->parent;
 	struct sunqec *qecp;
@@ -823,7 +823,7 @@ fail:
 	return NULL;
 }
 
-static int __init qec_ether_init(struct sbus_dev *sdev)
+static int __devinit qec_ether_init(struct sbus_dev *sdev)
 {
 	static unsigned version_printed;
 	struct net_device *dev;
diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index 4a0035f..6415ce1 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -1130,7 +1130,7 @@ static struct vio_driver_ops vnet_vio_ops = {
 	.handshake_complete	= vnet_handshake_complete,
 };
 
-static void print_version(void)
+static void __devinit print_version(void)
 {
 	static int version_printed;
 
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index e7b4adc..433c994 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -434,7 +434,7 @@ static int __devinit olympic_init(struct net_device *dev)
 
 }
 
-static int olympic_open(struct net_device *dev) 
+static int __devinit olympic_open(struct net_device *dev) 
 {
 	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio,*init_srb;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 4ffd873..fba0811 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2084,8 +2084,10 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 	if (!ugeth)
 		return;
 
-	if (ugeth->uccf)
+	if (ugeth->uccf) {
 		ucc_fast_free(ugeth->uccf);
+		ugeth->uccf = NULL;
+	}
 
 	if (ugeth->p_thread_data_tx) {
 		qe_muram_free(ugeth->thread_dat_tx_offset);
@@ -2305,10 +2307,6 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	ug_info = ugeth->ug_info;
 	uf_info = &ug_info->uf_info;
 
-	/* Create CQs for hash tables */
-	INIT_LIST_HEAD(&ugeth->group_hash_q);
-	INIT_LIST_HEAD(&ugeth->ind_hash_q);
-
 	if (!((uf_info->bd_mem_part == MEM_PART_SYSTEM) ||
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
 		if (netif_msg_probe(ugeth))
@@ -3668,6 +3666,23 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void ucc_netpoll(struct net_device *dev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	int irq = ugeth->ug_info->uf_info.irq;
+
+	disable_irq(irq);
+	ucc_geth_irq_handler(irq, dev);
+	enable_irq(irq);
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
 /* Called when something needs to use the ethernet device */
 /* Returns 0 for success. */
 static int ucc_geth_open(struct net_device *dev)
@@ -3990,6 +4005,10 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ugeth = netdev_priv(dev);
 	spin_lock_init(&ugeth->lock);
 
+	/* Create CQs for hash tables */
+	INIT_LIST_HEAD(&ugeth->group_hash_q);
+	INIT_LIST_HEAD(&ugeth->ind_hash_q);
+
 	dev_set_drvdata(device, dev);
 
 	/* Set the dev->base_addr to the gfar reg region */
@@ -4006,6 +4025,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 #ifdef CONFIG_UGETH_NAPI
 	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT);
 #endif				/* CONFIG_UGETH_NAPI */
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = ucc_netpoll;
+#endif
 	dev->stop = ucc_geth_close;
 //    dev->change_mtu = ucc_geth_change_mtu;
 	dev->mtu = 1500;
@@ -4040,9 +4062,10 @@ static int ucc_geth_remove(struct of_device* ofdev)
 	struct net_device *dev = dev_get_drvdata(device);
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	dev_set_drvdata(device, NULL);
-	ucc_geth_memclean(ugeth);
+	unregister_netdev(dev);
 	free_netdev(dev);
+	ucc_geth_memclean(ugeth);
+	dev_set_drvdata(device, NULL);
 
 	return 0;
 }
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 33cbc30..7e1f001 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -926,7 +926,6 @@ static int rtl8150_probe(struct usb_interface *intf,
 	netdev->set_multicast_list = rtl8150_set_multicast;
 	netdev->set_mac_address = rtl8150_set_mac_address;
 	netdev->get_stats = rtl8150_netdev_stats;
-	netdev->mtu = RTL8150_MTU;
 	SET_ETHTOOL_OPS(netdev, &ops);
 	dev->intr_interval = 100;	/* 100ms */
 
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 87c180b..7c851b1 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -606,7 +606,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 }
 #endif
 
-static void rhine_hw_init(struct net_device *dev, long pioaddr)
+static void __devinit rhine_hw_init(struct net_device *dev, long pioaddr)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 35cd65d..8c9fb82 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -8,7 +8,6 @@
  * for 64bit hardware platforms.
  *
  * TODO
- *	Big-endian support
  *	rx_copybreak/alignment
  *	Scatter gather
  *	More testing
@@ -681,7 +680,7 @@ static void velocity_rx_reset(struct velocity_info *vptr)
 	 *	Init state, all RD entries belong to the NIC
 	 */
 	for (i = 0; i < vptr->options.numrx; ++i)
-		vptr->rd_ring[i].rdesc0.owner = OWNED_BY_NIC;
+		vptr->rd_ring[i].rdesc0.len |= OWNED_BY_NIC;
 
 	writew(vptr->options.numrx, &regs->RBRDU);
 	writel(vptr->rd_pool_dma, &regs->RDBaseLo);
@@ -777,7 +776,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 
 		vptr->int_mask = INT_MASK_DEF;
 
-		writel(cpu_to_le32(vptr->rd_pool_dma), &regs->RDBaseLo);
+		writel(vptr->rd_pool_dma, &regs->RDBaseLo);
 		writew(vptr->options.numrx - 1, &regs->RDCSize);
 		mac_rx_queue_run(regs);
 		mac_rx_queue_wake(regs);
@@ -785,7 +784,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 		writew(vptr->options.numtx - 1, &regs->TDCSize);
 
 		for (i = 0; i < vptr->num_txq; i++) {
-			writel(cpu_to_le32(vptr->td_pool_dma[i]), &(regs->TDBaseLo[i]));
+			writel(vptr->td_pool_dma[i], &regs->TDBaseLo[i]);
 			mac_tx_queue_run(regs, i);
 		}
 
@@ -1195,7 +1194,7 @@ static inline void velocity_give_many_rx_descs(struct velocity_info *vptr)
 	dirty = vptr->rd_dirty - unusable;
 	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {
 		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
-		vptr->rd_ring[dirty].rdesc0.owner = OWNED_BY_NIC;
+		vptr->rd_ring[dirty].rdesc0.len |= OWNED_BY_NIC;
 	}
 
 	writew(vptr->rd_filled & 0xfffc, &regs->RBRDU);
@@ -1210,7 +1209,7 @@ static int velocity_rx_refill(struct velocity_info *vptr)
 		struct rx_desc *rd = vptr->rd_ring + dirty;
 
 		/* Fine for an all zero Rx desc at init time as well */
-		if (rd->rdesc0.owner == OWNED_BY_NIC)
+		if (rd->rdesc0.len & OWNED_BY_NIC)
 			break;
 
 		if (!vptr->rd_info[dirty].skb) {
@@ -1413,7 +1412,7 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 		if (!vptr->rd_info[rd_curr].skb)
 			break;
 
-		if (rd->rdesc0.owner == OWNED_BY_NIC)
+		if (rd->rdesc0.len & OWNED_BY_NIC)
 			break;
 
 		rmb();
@@ -1421,7 +1420,7 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 		/*
 		 *	Don't drop CE or RL error frame although RXOK is off
 		 */
-		if ((rd->rdesc0.RSR & RSR_RXOK) || (!(rd->rdesc0.RSR & RSR_RXOK) && (rd->rdesc0.RSR & (RSR_CE | RSR_RL)))) {
+		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL)) {
 			if (velocity_receive_frame(vptr, rd_curr) < 0)
 				stats->rx_dropped++;
 		} else {
@@ -1433,7 +1432,7 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 			stats->rx_dropped++;
 		}
 
-		rd->inten = 1;
+		rd->size |= RX_INTEN;
 
 		vptr->dev->last_rx = jiffies;
 
@@ -1554,7 +1553,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	struct net_device_stats *stats = &vptr->stats;
 	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
 	struct rx_desc *rd = &(vptr->rd_ring[idx]);
-	int pkt_len = rd->rdesc0.len;
+	int pkt_len = le16_to_cpu(rd->rdesc0.len) & 0x3fff;
 	struct sk_buff *skb;
 
 	if (rd->rdesc0.RSR & (RSR_STP | RSR_EDP)) {
@@ -1637,8 +1636,7 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
  	 */
 
 	*((u32 *) & (rd->rdesc0)) = 0;
-	rd->len = cpu_to_le32(vptr->rx_buf_sz);
-	rd->inten = 1;
+	rd->size = cpu_to_le16(vptr->rx_buf_sz) | RX_INTEN;
 	rd->pa_low = cpu_to_le32(rd_info->skb_dma);
 	rd->pa_high = 0;
 	return 0;
@@ -1674,7 +1672,7 @@ static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
 			td = &(vptr->td_rings[qnum][idx]);
 			tdinfo = &(vptr->td_infos[qnum][idx]);
 
-			if (td->tdesc0.owner == OWNED_BY_NIC)
+			if (td->tdesc0.len & OWNED_BY_NIC)
 				break;
 
 			if ((works++ > 15))
@@ -1874,7 +1872,7 @@ static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_
 
 		for (i = 0; i < tdinfo->nskb_dma; i++) {
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
-			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], td->tdesc1.len, PCI_DMA_TODEVICE);
+			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], le16_to_cpu(td->tdesc1.len), PCI_DMA_TODEVICE);
 #else
 			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], skb->len, PCI_DMA_TODEVICE);
 #endif
@@ -2067,8 +2065,8 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct velocity_td_info *tdinfo;
 	unsigned long flags;
 	int index;
-
 	int pktlen = skb->len;
+	__le16 len = cpu_to_le16(pktlen);
 
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
@@ -2083,9 +2081,8 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	td_ptr = &(vptr->td_rings[qnum][index]);
 	tdinfo = &(vptr->td_infos[qnum][index]);
 
-	td_ptr->tdesc1.TCPLS = TCPLS_NORMAL;
 	td_ptr->tdesc1.TCR = TCR0_TIC;
-	td_ptr->td_buf[0].queue = 0;
+	td_ptr->td_buf[0].size &= ~TD_QUEUE;
 
 	/*
 	 *	Pad short frames.
@@ -2093,16 +2090,16 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (pktlen < ETH_ZLEN) {
 		/* Cannot occur until ZC support */
 		pktlen = ETH_ZLEN;
+		len = cpu_to_le16(ETH_ZLEN);
 		skb_copy_from_linear_data(skb, tdinfo->buf, skb->len);
 		memset(tdinfo->buf + skb->len, 0, ETH_ZLEN - skb->len);
 		tdinfo->skb = skb;
 		tdinfo->skb_dma[0] = tdinfo->buf_dma;
-		td_ptr->tdesc0.pktsize = pktlen;
+		td_ptr->tdesc0.len = len;
 		td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
 		td_ptr->td_buf[0].pa_high = 0;
-		td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+		td_ptr->td_buf[0].size = len;	/* queue is 0 anyway */
 		tdinfo->nskb_dma = 1;
-		td_ptr->tdesc1.CMDZ = 2;
 	} else
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 0) {
@@ -2111,36 +2108,35 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (nfrags > 6) {
 			skb_copy_from_linear_data(skb, tdinfo->buf, skb->len);
 			tdinfo->skb_dma[0] = tdinfo->buf_dma;
-			td_ptr->tdesc0.pktsize =
+			td_ptr->tdesc0.len = len;
 			td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
 			td_ptr->td_buf[0].pa_high = 0;
-			td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+			td_ptr->td_buf[0].size = len;	/* queue is 0 anyway */
 			tdinfo->nskb_dma = 1;
-			td_ptr->tdesc1.CMDZ = 2;
 		} else {
 			int i = 0;
 			tdinfo->nskb_dma = 0;
-			tdinfo->skb_dma[i] = pci_map_single(vptr->pdev, skb->data, skb->len - skb->data_len, PCI_DMA_TODEVICE);
+			tdinfo->skb_dma[i] = pci_map_single(vptr->pdev, skb->data,
+						skb_headlen(skb), PCI_DMA_TODEVICE);
 
-			td_ptr->tdesc0.pktsize = pktlen;
+			td_ptr->tdesc0.len = len;
 
 			/* FIXME: support 48bit DMA later */
 			td_ptr->td_buf[i].pa_low = cpu_to_le32(tdinfo->skb_dma);
 			td_ptr->td_buf[i].pa_high = 0;
-			td_ptr->td_buf[i].bufsize = skb->len->skb->data_len;
+			td_ptr->td_buf[i].size = cpu_to_le16(skb_headlen(skb));
 
 			for (i = 0; i < nfrags; i++) {
 				skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-				void *addr = ((void *) page_address(frag->page + frag->page_offset));
+				void *addr = (void *)page_address(frag->page) + frag->page_offset;
 
 				tdinfo->skb_dma[i + 1] = pci_map_single(vptr->pdev, addr, frag->size, PCI_DMA_TODEVICE);
 
 				td_ptr->td_buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
 				td_ptr->td_buf[i + 1].pa_high = 0;
-				td_ptr->td_buf[i + 1].bufsize = frag->size;
+				td_ptr->td_buf[i + 1].size = cpu_to_le16(frag->size);
 			}
 			tdinfo->nskb_dma = i - 1;
-			td_ptr->tdesc1.CMDZ = i;
 		}
 
 	} else
@@ -2152,18 +2148,16 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		tdinfo->skb = skb;
 		tdinfo->skb_dma[0] = pci_map_single(vptr->pdev, skb->data, pktlen, PCI_DMA_TODEVICE);
-		td_ptr->tdesc0.pktsize = pktlen;
+		td_ptr->tdesc0.len = len;
 		td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
 		td_ptr->td_buf[0].pa_high = 0;
-		td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+		td_ptr->td_buf[0].size = len;
 		tdinfo->nskb_dma = 1;
-		td_ptr->tdesc1.CMDZ = 2;
 	}
+	td_ptr->tdesc1.cmd = TCPLS_NORMAL + (tdinfo->nskb_dma + 1) * 16;
 
 	if (vptr->vlgrp && vlan_tx_tag_present(skb)) {
-		td_ptr->tdesc1.pqinf.VID = vlan_tx_tag_get(skb);
-		td_ptr->tdesc1.pqinf.priority = 0;
-		td_ptr->tdesc1.pqinf.CFI = 0;
+		td_ptr->tdesc1.vlan = cpu_to_le16(vlan_tx_tag_get(skb));
 		td_ptr->tdesc1.TCR |= TCR0_VETAG;
 	}
 
@@ -2185,7 +2179,7 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		if (prev < 0)
 			prev = vptr->options.numtx - 1;
-		td_ptr->tdesc0.owner = OWNED_BY_NIC;
+		td_ptr->tdesc0.len |= OWNED_BY_NIC;
 		vptr->td_used[qnum]++;
 		vptr->td_curr[qnum] = (index + 1) % vptr->options.numtx;
 
@@ -2193,7 +2187,7 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_stop_queue(dev);
 
 		td_ptr = &(vptr->td_rings[qnum][prev]);
-		td_ptr->td_buf[0].queue = 1;
+		td_ptr->td_buf[0].size |= TD_QUEUE;
 		mac_tx_queue_wake(vptr->mac_regs, qnum);
 	}
 	dev->trans_start = jiffies;
@@ -3410,7 +3404,7 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 		velocity_save_context(vptr, &vptr->context);
 		velocity_shutdown(vptr);
 		velocity_set_wol(vptr);
-		pci_enable_wake(pdev, 3, 1);
+		pci_enable_wake(pdev, PCI_D3hot, 1);
 		pci_set_power_state(pdev, PCI_D3hot);
 	} else {
 		velocity_save_context(vptr, &vptr->context);
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index aa91796..7387be4 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -70,40 +70,27 @@
  * Bits in the RSR0 register
  */
 
-#define RSR_DETAG          0x0080
-#define RSR_SNTAG          0x0040
-#define RSR_RXER           0x0020
-#define RSR_RL             0x0010
-#define RSR_CE             0x0008
-#define RSR_FAE            0x0004
-#define RSR_CRC            0x0002
-#define RSR_VIDM           0x0001
+#define RSR_DETAG	cpu_to_le16(0x0080)
+#define RSR_SNTAG	cpu_to_le16(0x0040)
+#define RSR_RXER	cpu_to_le16(0x0020)
+#define RSR_RL		cpu_to_le16(0x0010)
+#define RSR_CE		cpu_to_le16(0x0008)
+#define RSR_FAE		cpu_to_le16(0x0004)
+#define RSR_CRC		cpu_to_le16(0x0002)
+#define RSR_VIDM	cpu_to_le16(0x0001)
 
 /*
  * Bits in the RSR1 register
  */
 
-#define RSR_RXOK           0x8000	// rx OK
-#define RSR_PFT            0x4000	// Perfect filtering address match
-#define RSR_MAR            0x2000	// MAC accept multicast address packet
-#define RSR_BAR            0x1000	// MAC accept broadcast address packet
-#define RSR_PHY            0x0800	// MAC accept physical address packet
-#define RSR_VTAG           0x0400	// 802.1p/1q tagging packet indicator
-#define RSR_STP            0x0200	// start of packet
-#define RSR_EDP            0x0100	// end of packet
-
-/*
- * Bits in the RSR1 register
- */
-
-#define RSR1_RXOK           0x80	// rx OK
-#define RSR1_PFT            0x40	// Perfect filtering address match
-#define RSR1_MAR            0x20	// MAC accept multicast address packet
-#define RSR1_BAR            0x10	// MAC accept broadcast address packet
-#define RSR1_PHY            0x08	// MAC accept physical address packet
-#define RSR1_VTAG           0x04	// 802.1p/1q tagging packet indicator
-#define RSR1_STP            0x02	// start of packet
-#define RSR1_EDP            0x01	// end of packet
+#define RSR_RXOK	cpu_to_le16(0x8000) // rx OK
+#define RSR_PFT		cpu_to_le16(0x4000) // Perfect filtering address match
+#define RSR_MAR		cpu_to_le16(0x2000) // MAC accept multicast address packet
+#define RSR_BAR		cpu_to_le16(0x1000) // MAC accept broadcast address packet
+#define RSR_PHY		cpu_to_le16(0x0800) // MAC accept physical address packet
+#define RSR_VTAG	cpu_to_le16(0x0400) // 802.1p/1q tagging packet indicator
+#define RSR_STP		cpu_to_le16(0x0200) // start of packet
+#define RSR_EDP		cpu_to_le16(0x0100) // end of packet
 
 /*
  * Bits in the CSM register
@@ -120,33 +107,21 @@
  * Bits in the TSR0 register
  */
 
-#define TSR0_ABT            0x0080	// Tx abort because of excessive collision
-#define TSR0_OWT            0x0040	// Jumbo frame Tx abort
-#define TSR0_OWC            0x0020	// Out of window collision
-#define TSR0_COLS           0x0010	// experience collision in this transmit event
-#define TSR0_NCR3           0x0008	// collision retry counter[3]
-#define TSR0_NCR2           0x0004	// collision retry counter[2]
-#define TSR0_NCR1           0x0002	// collision retry counter[1]
-#define TSR0_NCR0           0x0001	// collision retry counter[0]
-#define TSR0_TERR           0x8000	//
-#define TSR0_FDX            0x4000	// current transaction is serviced by full duplex mode
-#define TSR0_GMII           0x2000	// current transaction is serviced by GMII mode
-#define TSR0_LNKFL          0x1000	// packet serviced during link down
-#define TSR0_SHDN           0x0400	// shutdown case
-#define TSR0_CRS            0x0200	// carrier sense lost
-#define TSR0_CDH            0x0100	// AQE test fail (CD heartbeat)
-
-/*
- * Bits in the TSR1 register
- */
-
-#define TSR1_TERR           0x80	//
-#define TSR1_FDX            0x40	// current transaction is serviced by full duplex mode
-#define TSR1_GMII           0x20	// current transaction is serviced by GMII mode
-#define TSR1_LNKFL          0x10	// packet serviced during link down
-#define TSR1_SHDN           0x04	// shutdown case
-#define TSR1_CRS            0x02	// carrier sense lost
-#define TSR1_CDH            0x01	// AQE test fail (CD heartbeat)
+#define TSR0_ABT	cpu_to_le16(0x0080) // Tx abort because of excessive collision
+#define TSR0_OWT	cpu_to_le16(0x0040) // Jumbo frame Tx abort
+#define TSR0_OWC	cpu_to_le16(0x0020) // Out of window collision
+#define TSR0_COLS	cpu_to_le16(0x0010) // experience collision in this transmit event
+#define TSR0_NCR3	cpu_to_le16(0x0008) // collision retry counter[3]
+#define TSR0_NCR2	cpu_to_le16(0x0004) // collision retry counter[2]
+#define TSR0_NCR1	cpu_to_le16(0x0002) // collision retry counter[1]
+#define TSR0_NCR0	cpu_to_le16(0x0001) // collision retry counter[0]
+#define TSR0_TERR	cpu_to_le16(0x8000) //
+#define TSR0_FDX	cpu_to_le16(0x4000) // current transaction is serviced by full duplex mode
+#define TSR0_GMII	cpu_to_le16(0x2000) // current transaction is serviced by GMII mode
+#define TSR0_LNKFL	cpu_to_le16(0x1000) // packet serviced during link down
+#define TSR0_SHDN	cpu_to_le16(0x0400) // shutdown case
+#define TSR0_CRS	cpu_to_le16(0x0200) // carrier sense lost
+#define TSR0_CDH	cpu_to_le16(0x0100) // AQE test fail (CD heartbeat)
 
 //
 // Bits in the TCR0 register
@@ -197,25 +172,26 @@
  */
 
 struct rdesc0 {
-	u16 RSR;		/* Receive status */
-	u16 len:14;		/* Received packet length */
-	u16 reserved:1;
-	u16 owner:1;		/* Who owns this buffer ? */
+	__le16 RSR;		/* Receive status */
+	__le16 len;		/* bits 0--13; bit 15 - owner */
 };
 
 struct rdesc1 {
-	u16 PQTAG;
+	__le16 PQTAG;
 	u8 CSM;
 	u8 IPKT;
 };
 
+enum {
+	RX_INTEN = __constant_cpu_to_le16(0x8000)
+};
+
 struct rx_desc {
 	struct rdesc0 rdesc0;
 	struct rdesc1 rdesc1;
-	u32 pa_low;		/* Low 32 bit PCI address */
-	u16 pa_high;		/* Next 16 bit PCI address (48 total) */
-	u16 len:15;		/* Frame size */
-	u16 inten:1;		/* Enable interrupt */
+	__le32 pa_low;		/* Low 32 bit PCI address */
+	__le16 pa_high;		/* Next 16 bit PCI address (48 total) */
+	__le16 size;		/* bits 0--14 - frame size, bit 15 - enable int. */
 } __attribute__ ((__packed__));
 
 /*
@@ -223,32 +199,24 @@ struct rx_desc {
  */
 
 struct tdesc0 {
-	u16 TSR;		/* Transmit status register */
-	u16 pktsize:14;		/* Size of frame */
-	u16 reserved:1;
-	u16 owner:1;		/* Who owns the buffer */
+	__le16 TSR;		/* Transmit status register */
+	__le16 len;		/* bits 0--13 - size of frame, bit 15 - owner */
 };
 
-struct pqinf {			/* Priority queue info */
-	u16 VID:12;
-	u16 CFI:1;
-	u16 priority:3;
-} __attribute__ ((__packed__));
-
 struct tdesc1 {
-	struct pqinf pqinf;
+	__le16 vlan;
 	u8 TCR;
-	u8 TCPLS:2;
-	u8 reserved:2;
-	u8 CMDZ:4;
+	u8 cmd;			/* bits 0--1 - TCPLS, bits 4--7 - CMDZ */
 } __attribute__ ((__packed__));
 
+enum {
+	TD_QUEUE = __constant_cpu_to_le16(0x8000)
+};
+
 struct td_buf {
-	u32 pa_low;
-	u16 pa_high;
-	u16 bufsize:14;
-	u16 reserved:1;
-	u16 queue:1;
+	__le32 pa_low;
+	__le16 pa_high;
+	__le16 size;		/* bits 0--13 - size, bit 15 - queue */
 } __attribute__ ((__packed__));
 
 struct tx_desc {
@@ -276,7 +244,7 @@ struct velocity_td_info {
 
 enum  velocity_owner {
 	OWNED_BY_HOST = 0,
-	OWNED_BY_NIC = 1
+	OWNED_BY_NIC = __constant_cpu_to_le16(0x8000)
 };
 
 
@@ -1012,45 +980,45 @@ struct mac_regs {
 	volatile u8 RCR;
 	volatile u8 TCR;
 
-	volatile u32 CR0Set;		/* 0x08 */
-	volatile u32 CR0Clr;		/* 0x0C */
+	volatile __le32 CR0Set;		/* 0x08 */
+	volatile __le32 CR0Clr;		/* 0x0C */
 
 	volatile u8 MARCAM[8];		/* 0x10 */
 
-	volatile u32 DecBaseHi;		/* 0x18 */
-	volatile u16 DbfBaseHi;		/* 0x1C */
-	volatile u16 reserved_1E;
+	volatile __le32 DecBaseHi;	/* 0x18 */
+	volatile __le16 DbfBaseHi;	/* 0x1C */
+	volatile __le16 reserved_1E;
 
-	volatile u16 ISRCTL;		/* 0x20 */
+	volatile __le16 ISRCTL;		/* 0x20 */
 	volatile u8 TXESR;
 	volatile u8 RXESR;
 
-	volatile u32 ISR;		/* 0x24 */
-	volatile u32 IMR;
+	volatile __le32 ISR;		/* 0x24 */
+	volatile __le32 IMR;
 
-	volatile u32 TDStatusPort;	/* 0x2C */
+	volatile __le32 TDStatusPort;	/* 0x2C */
 
-	volatile u16 TDCSRSet;		/* 0x30 */
+	volatile __le16 TDCSRSet;	/* 0x30 */
 	volatile u8 RDCSRSet;
 	volatile u8 reserved_33;
-	volatile u16 TDCSRClr;
+	volatile __le16 TDCSRClr;
 	volatile u8 RDCSRClr;
 	volatile u8 reserved_37;
 
-	volatile u32 RDBaseLo;		/* 0x38 */
-	volatile u16 RDIdx;		/* 0x3C */
-	volatile u16 reserved_3E;
+	volatile __le32 RDBaseLo;	/* 0x38 */
+	volatile __le16 RDIdx;		/* 0x3C */
+	volatile __le16 reserved_3E;
 
-	volatile u32 TDBaseLo[4];	/* 0x40 */
+	volatile __le32 TDBaseLo[4];	/* 0x40 */
 
-	volatile u16 RDCSize;		/* 0x50 */
-	volatile u16 TDCSize;		/* 0x52 */
-	volatile u16 TDIdx[4];		/* 0x54 */
-	volatile u16 tx_pause_timer;	/* 0x5C */
-	volatile u16 RBRDU;		/* 0x5E */
+	volatile __le16 RDCSize;	/* 0x50 */
+	volatile __le16 TDCSize;	/* 0x52 */
+	volatile __le16 TDIdx[4];	/* 0x54 */
+	volatile __le16 tx_pause_timer;	/* 0x5C */
+	volatile __le16 RBRDU;		/* 0x5E */
 
-	volatile u32 FIFOTest0;		/* 0x60 */
-	volatile u32 FIFOTest1;		/* 0x64 */
+	volatile __le32 FIFOTest0;	/* 0x60 */
+	volatile __le32 FIFOTest1;	/* 0x64 */
 
 	volatile u8 CAMADDR;		/* 0x68 */
 	volatile u8 CAMCR;		/* 0x69 */
@@ -1063,18 +1031,18 @@ struct mac_regs {
 	volatile u8 PHYSR1;
 	volatile u8 MIICR;
 	volatile u8 MIIADR;
-	volatile u16 MIIDATA;
+	volatile __le16 MIIDATA;
 
-	volatile u16 SoftTimer0;	/* 0x74 */
-	volatile u16 SoftTimer1;
+	volatile __le16 SoftTimer0;	/* 0x74 */
+	volatile __le16 SoftTimer1;
 
 	volatile u8 CFGA;		/* 0x78 */
 	volatile u8 CFGB;
 	volatile u8 CFGC;
 	volatile u8 CFGD;
 
-	volatile u16 DCFG;		/* 0x7C */
-	volatile u16 MCFG;
+	volatile __le16 DCFG;		/* 0x7C */
+	volatile __le16 MCFG;
 
 	volatile u8 TBIST;		/* 0x80 */
 	volatile u8 RBIST;
@@ -1086,9 +1054,9 @@ struct mac_regs {
 	volatile u8 rev_id;
 	volatile u8 PORSTS;
 
-	volatile u32 MIBData;		/* 0x88 */
+	volatile __le32 MIBData;	/* 0x88 */
 
-	volatile u16 EEWrData;
+	volatile __le16 EEWrData;
 
 	volatile u8 reserved_8E;
 	volatile u8 BPMDWr;
@@ -1098,7 +1066,7 @@ struct mac_regs {
 	volatile u8 EECHKSUM;		/* 0x92 */
 	volatile u8 EECSR;
 
-	volatile u16 EERdData;		/* 0x94 */
+	volatile __le16 EERdData;	/* 0x94 */
 	volatile u8 EADDR;
 	volatile u8 EMBCMD;
 
@@ -1112,22 +1080,22 @@ struct mac_regs {
 	volatile u8 DEBUG;
 	volatile u8 CHIPGCR;
 
-	volatile u16 WOLCRSet;		/* 0xA0 */
+	volatile __le16 WOLCRSet;	/* 0xA0 */
 	volatile u8 PWCFGSet;
 	volatile u8 WOLCFGSet;
 
-	volatile u16 WOLCRClr;		/* 0xA4 */
+	volatile __le16 WOLCRClr;	/* 0xA4 */
 	volatile u8 PWCFGCLR;
 	volatile u8 WOLCFGClr;
 
-	volatile u16 WOLSRSet;		/* 0xA8 */
-	volatile u16 reserved_AA;
+	volatile __le16 WOLSRSet;	/* 0xA8 */
+	volatile __le16 reserved_AA;
 
-	volatile u16 WOLSRClr;		/* 0xAC */
-	volatile u16 reserved_AE;
+	volatile __le16 WOLSRClr;	/* 0xAC */
+	volatile __le16 reserved_AE;
 
-	volatile u16 PatternCRC[8];	/* 0xB0 */
-	volatile u32 ByteMask[4][4];	/* 0xC0 */
+	volatile __le16 PatternCRC[8];	/* 0xB0 */
+	volatile __le32 ByteMask[4][4];	/* 0xC0 */
 } __attribute__ ((__packed__));
 
 
@@ -1238,12 +1206,12 @@ typedef u8 MCAM_ADDR[ETH_ALEN];
 struct arp_packet {
 	u8 dest_mac[ETH_ALEN];
 	u8 src_mac[ETH_ALEN];
-	u16 type;
-	u16 ar_hrd;
-	u16 ar_pro;
+	__be16 type;
+	__be16 ar_hrd;
+	__be16 ar_pro;
 	u8 ar_hln;
 	u8 ar_pln;
-	u16 ar_op;
+	__be16 ar_op;
 	u8 ar_sha[ETH_ALEN];
 	u8 ar_sip[4];
 	u8 ar_tha[ETH_ALEN];
@@ -1253,7 +1221,7 @@ struct arp_packet {
 struct _magic_packet {
 	u8 dest_mac[6];
 	u8 src_mac[6];
-	u16 type;
+	__be16 type;
 	u8 MAC[16][6];
 	u8 password[6];
 } __attribute__ ((__packed__));
