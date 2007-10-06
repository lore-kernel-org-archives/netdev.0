From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH net-2.6.24] network drivers: sparse warning fixes
Date: Fri, 5 Oct 2007 17:19:47 -0700
Message-ID: <20071005171947.340f60af@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47648 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754215AbXJFAUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 20:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix some of the easy warnings in network device drivers.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/acenic.c         |   37 +++++++++++++++++++------------------
 drivers/net/atl1/atl1_main.c |    5 +++--
 drivers/net/dl2k.c           |    8 ++++----
 drivers/net/e100.c           |    2 +-
 drivers/net/hamachi.c        |    3 +--
 drivers/net/natsemi.c        |    6 +++---
 drivers/net/tehuti.c         |    4 +---
 7 files changed, 32 insertions(+), 33 deletions(-)


drivers/net/atl1/atl1_main.c:1370:7: warning: symbol 'rrd_next_to_clean' shadows an earlier one
drivers/net/atl1/atl1_main.c:1264:6: originally declared here
drivers/net/atl1/atl1_main.c:1576:13: warning: symbol 'i' shadows an earlier one
drivers/net/atl1/atl1_main.c:1515:6: originally declared here
drivers/net/atl1/atl1_main.c:1576:16: warning: symbol 'm' shadows an earlier one
drivers/net/atl1/atl1_main.c:1515:9: originally declared here
drivers/net/tehuti.c:753:2: warning: Using plain integer as NULL pointer
drivers/net/tehuti.c:1005:2: warning: Using plain integer as NULL pointer
drivers/net/tehuti.c:1750:3: warning: Using plain integer as NULL pointer
drivers/net/e100.c:1996:22: warning: incorrect type in argument 2 (different signedness)
drivers/net/e100.c:1996:22:    expected unsigned int *work_done
drivers/net/e100.c:1996:22:    got int *<noident>
drivers/net/acenic.c:990:7: warning: symbol 'tmp' shadows an earlier one
drivers/net/acenic.c:892:27: originally declared here
drivers/net/acenic.c:1002:7: warning: symbol 'tmp' shadows an earlier one
drivers/net/acenic.c:892:27: originally declared here
drivers/net/acenic.c:2647:6: warning: symbol 'link' shadows an earlier one
drivers/net/acenic.c:409:12: originally declared here
drivers/net/acenic.c:2700:6: warning: symbol 'link' shadows an earlier one
drivers/net/acenic.c:409:12: originally declared here
drivers/net/acenic.c:1308:18: warning: cast removes address space of expression
drivers/net/acenic.c:1311:4: warning: cast adds address space to expression (<asn:2>)
drivers/net/acenic.c:2387:9: warning: cast adds address space to expression (<asn:2>)
drivers/net/acenic.c:2447:33: warning: cast adds address space to expression (<asn:2>)
drivers/net/acenic.c:2447:33: warning: cast adds address space to expression (<asn:2>)
drivers/net/acenic.c:2447:33: warning: cast adds address space to expression (<asn:2>)
drivers/net/acenic.c:2939:15: warning: symbol 'ace_load_firmware' was not declared. Should it be static?
drivers/net/natsemi.c:1618:26: warning: symbol 'np' shadows an earlier one
drivers/net/natsemi.c:1589:24: originally declared here
drivers/net/natsemi.c:2505:8: warning: symbol 'i' shadows an earlier one
drivers/net/natsemi.c:2501:7: originally declared here
drivers/net/hamachi.c:1072:7: warning: symbol 'i' shadows an earlier one
drivers/net/hamachi.c:1064:6: originally declared here
drivers/net/hamachi.c:1020:14: warning: Using plain integer as NULL pointer
drivers/net/dl2k.c:294:1: warning: symbol 'find_miiphy' was not declared. Should it be static?
drivers/net/dl2k.c:318:1: warning: symbol 'parse_eeprom' was not declared. Should it be static?
drivers/net/dl2k.c:1100:1: warning: symbol 'change_mtu' was not declared. Should it be static?
drivers/net/dl2k.c:1335:1: warning: symbol 'read_eeprom' was not declared. Should it be static?


--- a/drivers/net/acenic.c	2007-10-05 13:07:59.000000000 -0700
+++ b/drivers/net/acenic.c	2007-10-05 17:14:54.000000000 -0700
@@ -406,7 +406,7 @@ MODULE_DEVICE_TABLE(pci, acenic_pci_tbl)
 #define DEF_STAT		(2 * TICKS_PER_SEC)
 
 
-static int link[ACE_MAX_MOD_PARMS];
+static int link_state[ACE_MAX_MOD_PARMS];
 static int trace[ACE_MAX_MOD_PARMS];
 static int tx_coal_tick[ACE_MAX_MOD_PARMS];
 static int rx_coal_tick[ACE_MAX_MOD_PARMS];
@@ -419,7 +419,7 @@ MODULE_AUTHOR("Jes Sorensen <jes@trained
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AceNIC/3C985/GA620 Gigabit Ethernet driver");
 
-module_param_array(link, int, NULL, 0);
+module_param_array_named(link, link_state, int, NULL, 0);
 module_param_array(trace, int, NULL, 0);
 module_param_array(tx_coal_tick, int, NULL, 0);
 module_param_array(max_tx_desc, int, NULL, 0);
@@ -987,27 +987,27 @@ static int __devinit ace_init(struct net
 
 	mac1 = 0;
 	for(i = 0; i < 4; i++) {
-		int tmp;
+		int t;
 
 		mac1 = mac1 << 8;
-		tmp = read_eeprom_byte(dev, 0x8c+i);
-		if (tmp < 0) {
+		t = read_eeprom_byte(dev, 0x8c+i);
+		if (t < 0) {
 			ecode = -EIO;
 			goto init_error;
 		} else
-			mac1 |= (tmp & 0xff);
+			mac1 |= (t & 0xff);
 	}
 	mac2 = 0;
 	for(i = 4; i < 8; i++) {
-		int tmp;
+		int t;
 
 		mac2 = mac2 << 8;
-		tmp = read_eeprom_byte(dev, 0x8c+i);
-		if (tmp < 0) {
+		t = read_eeprom_byte(dev, 0x8c+i);
+		if (t < 0) {
 			ecode = -EIO;
 			goto init_error;
 		} else
-			mac2 |= (tmp & 0xff);
+			mac2 |= (t & 0xff);
 	}
 
 	writel(mac1, &regs->MacAddrHi);
@@ -1305,10 +1305,10 @@ static int __devinit ace_init(struct net
 	writel(TX_RING_BASE, &regs->WinBase);
 
 	if (ACE_IS_TIGON_I(ap)) {
-		ap->tx_ring = (struct tx_desc *) regs->Window;
+		ap->tx_ring = (__force struct tx_desc *) regs->Window;
 		for (i = 0; i < (TIGON_I_TX_RING_ENTRIES
 				 * sizeof(struct tx_desc)) / sizeof(u32); i++)
-			writel(0, (void __iomem *)ap->tx_ring  + i * 4);
+			writel(0, (__force void __iomem *)ap->tx_ring  + i * 4);
 
 		set_aceaddr(&info->tx_ctrl.rngptr, TX_RING_BASE);
 	} else {
@@ -1394,8 +1394,8 @@ static int __devinit ace_init(struct net
 	/*
 	 * Override link default parameters
 	 */
-	if ((board_idx >= 0) && link[board_idx]) {
-		int option = link[board_idx];
+	if ((board_idx >= 0) && link_state[board_idx]) {
+		int option = link_state[board_idx];
 
 		tmp = LNK_ENABLE;
 
@@ -2383,8 +2383,9 @@ static int ace_close(struct net_device *
 
 		if (mapping) {
 			if (ACE_IS_TIGON_I(ap)) {
-				struct tx_desc __iomem *tx
-					= (struct tx_desc __iomem *) &ap->tx_ring[i];
+				/* NB: TIGON_1 is special, tx_ring is in io space */
+				struct tx_desc __iomem *tx;
+				tx = (__force struct tx_desc __iomem *) &ap->tx_ring[i];
 				writel(0, &tx->addr.addrhi);
 				writel(0, &tx->addr.addrlo);
 				writel(0, &tx->flagsize);
@@ -2444,7 +2445,7 @@ ace_load_tx_bd(struct ace_private *ap, s
 #endif
 
 	if (ACE_IS_TIGON_I(ap)) {
-		struct tx_desc __iomem *io = (struct tx_desc __iomem *) desc;
+		struct tx_desc __iomem *io = (__force struct tx_desc __iomem *) desc;
 		writel(addr >> 32, &io->addr.addrhi);
 		writel(addr & 0xffffffff, &io->addr.addrlo);
 		writel(flagsize, &io->flagsize);
@@ -2936,7 +2937,7 @@ static void __devinit ace_clear(struct a
  * This operation requires the NIC to be halted and is performed with
  * interrupts disabled and with the spinlock hold.
  */
-int __devinit ace_load_firmware(struct net_device *dev)
+static int __devinit ace_load_firmware(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
--- a/drivers/net/atl1/atl1_main.c	2007-10-05 13:07:59.000000000 -0700
+++ b/drivers/net/atl1/atl1_main.c	2007-10-05 17:14:54.000000000 -0700
@@ -1367,7 +1367,6 @@ rrd_ok:
 	if (count) {
 		u32 tpd_next_to_use;
 		u32 rfd_next_to_use;
-		u32 rrd_next_to_clean;
 
 		spin_lock(&adapter->mb_lock);
 
@@ -1512,7 +1511,7 @@ static void atl1_tx_map(struct atl1_adap
 	unsigned int f;
 	u16 tpd_next_to_use;
 	u16 proto_hdr_len;
-	u16 i, m, len12;
+	u16 len12;
 
 	first_buf_len -= skb->data_len;
 	nr_frags = skb_shinfo(skb)->nr_frags;
@@ -1536,6 +1535,8 @@ static void atl1_tx_map(struct atl1_adap
 			tpd_next_to_use = 0;
 
 		if (first_buf_len > proto_hdr_len) {
+			int i, m;
+
 			len12 = first_buf_len - proto_hdr_len;
 			m = (len12 + ATL1_MAX_TX_BUF_LEN - 1) /
 				ATL1_MAX_TX_BUF_LEN;
--- a/drivers/net/e100.c	2007-10-05 13:07:59.000000000 -0700
+++ b/drivers/net/e100.c	2007-10-05 17:14:54.000000000 -0700
@@ -1990,7 +1990,7 @@ static int e100_poll(struct napi_struct 
 {
 	struct nic *nic = container_of(napi, struct nic, napi);
 	struct net_device *netdev = nic->netdev;
-	int work_done = 0;
+	unsigned int work_done = 0;
 	int tx_cleaned;
 
 	e100_rx_clean(nic, &work_done, budget);
--- a/drivers/net/natsemi.c	2007-10-05 13:07:59.000000000 -0700
+++ b/drivers/net/natsemi.c	2007-10-05 17:14:54.000000000 -0700
@@ -1615,7 +1615,7 @@ static void do_cable_magic(struct net_de
 		 * (these values all come from National)
 		 */
 		if (!(data & 0x80) || ((data >= 0xd8) && (data <= 0xff))) {
-			struct netdev_private *np = netdev_priv(dev);
+			np = netdev_priv(dev);
 
 			/* the bug has been triggered - fix the coefficient */
 			writew(TSTDAT_FIXED, ioaddr + TSTDAT);
@@ -2502,8 +2502,8 @@ static void __set_rx_mode(struct net_dev
 		memset(mc_filter, 0, sizeof(mc_filter));
 		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
 			 i++, mclist = mclist->next) {
-			int i = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
-			mc_filter[i/8] |= (1 << (i & 0x07));
+			int b = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
+			mc_filter[b/8] |= (1 << (b & 0x07));
 		}
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptMulticast | AcceptMyPhys;
--- a/drivers/net/tehuti.c	2007-10-05 13:07:59.000000000 -0700
+++ b/drivers/net/tehuti.c	2007-10-05 17:14:54.000000000 -0700
@@ -750,7 +750,6 @@ bdx_vlan_rx_register(struct net_device *
  */
 static int bdx_change_mtu(struct net_device *ndev, int new_mtu)
 {
-	BDX_ASSERT(ndev == 0);
 	ENTER;
 
 	if (new_mtu == ndev->mtu)
@@ -1002,7 +1001,7 @@ static inline void bdx_rxdb_free_elem(st
 static int bdx_rx_init(struct bdx_priv *priv)
 {
 	ENTER;
-	BDX_ASSERT(priv == 0);
+
 	if (bdx_fifo_init(priv, &priv->rxd_fifo0.m, priv->rxd_size,
 			  regRXD_CFG0_0, regRXD_CFG1_0,
 			  regRXD_RPTR_0, regRXD_WPTR_0))
@@ -1747,7 +1746,6 @@ static void bdx_tx_cleanup(struct bdx_pr
 		tx_level -= db->rptr->len;	/* '-' koz len is negative */
 
 		/* now should come skb pointer - free it */
-		BDX_ASSERT(db->rptr->addr.skb == 0);
 		dev_kfree_skb_irq(db->rptr->addr.skb);
 		bdx_tx_db_inc_rptr(db);
 	}
--- a/drivers/net/dl2k.c	2007-10-05 13:07:59.000000000 -0700
+++ b/drivers/net/dl2k.c	2007-10-05 17:14:54.000000000 -0700
@@ -290,7 +290,7 @@ rio_probe1 (struct pci_dev *pdev, const 
 	return err;
 }
 
-int
+static int
 find_miiphy (struct net_device *dev)
 {
 	int i, phy_found = 0;
@@ -314,7 +314,7 @@ find_miiphy (struct net_device *dev)
 	return 0;
 }
 
-int
+static int
 parse_eeprom (struct net_device *dev)
 {
 	int i, j;
@@ -1096,7 +1096,7 @@ clear_stats (struct net_device *dev)
 }
 
 
-int
+static int
 change_mtu (struct net_device *dev, int new_mtu)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -1331,7 +1331,7 @@ rio_ioctl (struct net_device *dev, struc
 #define EEP_BUSY 0x8000
 /* Read the EEPROM word */
 /* We use I/O instruction to read/write eeprom to avoid fail on some machines */
-int
+static int
 read_eeprom (long ioaddr, int eep_addr)
 {
 	int i = 1000;
--- a/drivers/net/hamachi.c	2007-10-05 13:07:59.000000000 -0700
+++ b/drivers/net/hamachi.c	2007-10-05 17:14:54.000000000 -0700
@@ -1017,7 +1017,7 @@ static inline int hamachi_tx(struct net_
 			break;
 		/* Free the original skb. */
 		skb = hmp->tx_skbuff[entry];
-		if (skb != 0) {
+		if (skb) {
 			pci_unmap_single(hmp->pci_dev,
 				hmp->tx_ring[entry].addr, skb->len,
 				PCI_DMA_TODEVICE);
@@ -1069,7 +1069,6 @@ static void hamachi_tx_timeout(struct ne
 		   " resetting...\n", dev->name, (int)readw(ioaddr + TxStatus));
 
 	{
-		int i;
 		printk(KERN_DEBUG "  Rx ring %p: ", hmp->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++)
 			printk(" %8.8x", (unsigned int)hmp->rx_ring[i].status_n_length);
