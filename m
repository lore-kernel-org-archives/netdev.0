From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 19/19] netdev: convert bulk of drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:58 -0700
Message-ID: <20090901055130.375691503@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57483 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145AbZIAF67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:59 -0400
Content-Disposition: inline; filename=netdriver-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a couple of cases collapse some extra code like:
   int retval = NETDEV_TX_OK;
   ...
   return retval;
into
   return NETDEV_TX_OK;

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
       

---
 drivers/ieee802154/fakehard.c        |    3 ++-
 drivers/net/8139cp.c                 |    3 ++-
 drivers/net/8139too.c                |    7 ++++---
 drivers/net/82596.c                  |    5 ++---
 drivers/net/8390.c                   |    2 +-
 drivers/net/8390.h                   |    4 ++--
 drivers/net/8390p.c                  |    2 +-
 drivers/net/a2065.c                  |    3 ++-
 drivers/net/acenic.c                 |    3 ++-
 drivers/net/acenic.h                 |    3 ++-
 drivers/net/amd8111e.c               |    3 ++-
 drivers/net/arcnet/arcnet.c          |    3 ++-
 drivers/net/ariadne.c                |    6 ++++--
 drivers/net/at1700.c                 |    6 ++++--
 drivers/net/atl1c/atl1c_main.c       |    3 ++-
 drivers/net/atl1e/atl1e_main.c       |    3 ++-
 drivers/net/atlx/atl1.c              |    3 ++-
 drivers/net/atlx/atl2.c              |    3 ++-
 drivers/net/atp.c                    |    6 ++++--
 drivers/net/au1000_eth.c             |    2 +-
 drivers/net/b44.c                    |    2 +-
 drivers/net/benet/be_main.c          |    3 ++-
 drivers/net/bnx2.c                   |    2 +-
 drivers/net/bnx2x_main.c             |    2 +-
 drivers/net/can/sja1000/sja1000.c    |    3 ++-
 drivers/net/cassini.c                |    2 +-
 drivers/net/chelsio/sge.c            |    2 +-
 drivers/net/chelsio/sge.h            |    2 +-
 drivers/net/cs89x0.c                 |    4 ++--
 drivers/net/cxgb3/adapter.h          |    2 +-
 drivers/net/cxgb3/sge.c              |    2 +-
 drivers/net/defxx.c                  |   10 ++++------
 drivers/net/depca.c                  |    6 ++++--
 drivers/net/dl2k.c                   |    4 ++--
 drivers/net/dnet.c                   |    2 +-
 drivers/net/eepro.c                  |    6 ++++--
 drivers/net/eexpress.c               |    5 +++--
 drivers/net/enc28j60.c               |    3 ++-
 drivers/net/enic/enic_main.c         |    3 ++-
 drivers/net/epic100.c                |    5 +++--
 drivers/net/eth16i.c                 |    4 ++--
 drivers/net/ethoc.c                  |    2 +-
 drivers/net/ewrk3.c                  |    4 ++--
 drivers/net/fealnx.c                 |    4 ++--
 drivers/net/forcedeth.c              |    5 +++--
 drivers/net/hamachi.c                |    6 ++++--
 drivers/net/hp100.c                  |   13 ++++++++-----
 drivers/net/ibmlana.c                |    2 +-
 drivers/net/ibmveth.c                |    3 ++-
 drivers/net/ipg.c                    |    3 ++-
 drivers/net/jme.c                    |    2 +-
 drivers/net/ks8842.c                 |    3 ++-
 drivers/net/ks8851.c                 |    5 +++--
 drivers/net/lance.c                  |    6 ++++--
 drivers/net/lib8390.c                |    3 ++-
 drivers/net/loopback.c               |    3 ++-
 drivers/net/lp486e.c                 |    4 ++--
 drivers/net/mlx4/en_tx.c             |    2 +-
 drivers/net/mlx4/mlx4_en.h           |    2 +-
 drivers/net/myri10ge/myri10ge.c      |   11 +++++++----
 drivers/net/natsemi.c                |    4 ++--
 drivers/net/netxen/netxen_nic_main.c |    5 +++--
 drivers/net/ni52.c                   |    5 +++--
 drivers/net/ni65.c                   |    6 ++++--
 drivers/net/niu.c                    |    3 ++-
 drivers/net/ns83820.c                |    3 ++-
 drivers/net/pcnet32.c                |    6 ++++--
 drivers/net/qla3xxx.c                |    3 ++-
 drivers/net/qlge/qlge_main.c         |    2 +-
 drivers/net/r6040.c                  |   10 +++++-----
 drivers/net/r8169.c                  |   12 ++++++------
 drivers/net/rrunner.c                |    3 ++-
 drivers/net/rrunner.h                |    3 ++-
 drivers/net/s2io.c                   |    2 +-
 drivers/net/sb1000.c                 |    5 +++--
 drivers/net/sc92031.c                |    3 ++-
 drivers/net/seeq8005.c               |    6 ++++--
 drivers/net/sfc/efx.h                |    5 +++--
 drivers/net/sfc/selftest.c           |    3 ++-
 drivers/net/sfc/tx.c                 |   18 ++++++++----------
 drivers/net/sfc/tx.h                 |    3 ++-
 drivers/net/sis190.c                 |    3 ++-
 drivers/net/sis900.c                 |    5 +++--
 drivers/net/skfp/skfddi.c            |    6 ++++--
 drivers/net/skge.c                   |    3 ++-
 drivers/net/sky2.c                   |    3 ++-
 drivers/net/smc9194.c                |    6 ++++--
 drivers/net/smsc9420.c               |    3 ++-
 drivers/net/starfire.c               |    4 ++--
 drivers/net/sundance.c               |    4 ++--
 drivers/net/sungem.c                 |    3 ++-
 drivers/net/sunhme.c                 |    3 ++-
 drivers/net/tehuti.c                 |    3 ++-
 drivers/net/tg3.c                    |    9 ++++++---
 drivers/net/tlan.c                   |    4 ++--
 drivers/net/typhoon.c                |    2 +-
 drivers/net/via-rhine.c              |    6 ++++--
 drivers/net/via-velocity.c           |    3 ++-
 drivers/net/vxge/vxge-main.c         |    2 +-
 drivers/net/yellowfin.c              |    6 ++++--
 drivers/net/znet.c                   |    5 +++--
 include/linux/arcdevice.h            |    3 ++-
 102 files changed, 253 insertions(+), 173 deletions(-)

--- a/drivers/net/8139cp.c	2009-08-31 16:17:52.021091264 -0700
+++ b/drivers/net/8139cp.c	2009-08-31 16:36:24.671092307 -0700
@@ -736,7 +736,8 @@ static void cp_tx (struct cp_private *cp
 		netif_wake_queue(cp->dev);
 }
 
-static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
+					struct net_device *dev)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned entry;
--- a/drivers/net/8139too.c	2009-08-31 16:17:51.771107041 -0700
+++ b/drivers/net/8139too.c	2009-08-31 16:36:58.033614074 -0700
@@ -628,8 +628,8 @@ static void mdio_write (struct net_devic
 static void rtl8139_start_thread(struct rtl8139_private *tp);
 static void rtl8139_tx_timeout (struct net_device *dev);
 static void rtl8139_init_ring (struct net_device *dev);
-static int rtl8139_start_xmit (struct sk_buff *skb,
-			       struct net_device *dev);
+static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
+				       struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void rtl8139_poll_controller(struct net_device *dev);
 #endif
@@ -1687,7 +1687,8 @@ static void rtl8139_tx_timeout (struct n
 	}
 }
 
-static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
+					     struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
--- a/drivers/net/82596.c	2009-08-31 16:17:51.681103561 -0700
+++ b/drivers/net/82596.c	2009-08-31 16:37:49.261564620 -0700
@@ -356,7 +356,7 @@ static char init_setup[] =
 	0x7f /*  *multi IA */ };
 
 static int i596_open(struct net_device *dev);
-static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t i596_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t i596_interrupt(int irq, void *dev_id);
 static int i596_close(struct net_device *dev);
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd);
@@ -1054,8 +1054,7 @@ static void i596_tx_timeout (struct net_
 	netif_wake_queue (dev);
 }
 
-
-static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct i596_private *lp = dev->ml_priv;
 	struct tx_cmd *tx_cmd;
--- a/drivers/net/8390.c	2009-08-31 16:17:51.591127388 -0700
+++ b/drivers/net/8390.c	2009-08-31 16:36:24.671092307 -0700
@@ -17,7 +17,7 @@ int ei_close(struct net_device *dev)
 }
 EXPORT_SYMBOL(ei_close);
 
-int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	return __ei_start_xmit(skb, dev);
 }
--- a/drivers/net/8390p.c	2009-08-31 16:17:51.791080739 -0700
+++ b/drivers/net/8390p.c	2009-08-31 16:36:24.671092307 -0700
@@ -22,7 +22,7 @@ int eip_close(struct net_device *dev)
 }
 EXPORT_SYMBOL(eip_close);
 
-int eip_start_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t eip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	return __ei_start_xmit(skb, dev);
 }
--- a/drivers/net/a2065.c	2009-08-31 16:17:51.701108128 -0700
+++ b/drivers/net/a2065.c	2009-08-31 16:38:04.931106629 -0700
@@ -547,7 +547,8 @@ static void lance_tx_timeout(struct net_
 	netif_wake_queue(dev);
 }
 
-static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t lance_start_xmit (struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
--- a/drivers/net/acenic.c	2009-08-31 16:17:52.071101739 -0700
+++ b/drivers/net/acenic.c	2009-08-31 16:38:08.682395971 -0700
@@ -2464,7 +2464,8 @@ ace_load_tx_bd(struct ace_private *ap, s
 }
 
 
-static int ace_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ace_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
--- a/drivers/net/at1700.c	2009-08-31 16:17:51.751109387 -0700
+++ b/drivers/net/at1700.c	2009-08-31 16:40:36.018425688 -0700
@@ -159,7 +159,8 @@ struct net_local {
 static int at1700_probe1(struct net_device *dev, int ioaddr);
 static int read_eeprom(long ioaddr, int location);
 static int net_open(struct net_device *dev);
-static int	net_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t net_send_packet(struct sk_buff *skb,
+				   struct net_device *dev);
 static irqreturn_t net_interrupt(int irq, void *dev_id);
 static void net_rx(struct net_device *dev);
 static int net_close(struct net_device *dev);
@@ -595,7 +596,8 @@ static void net_tx_timeout (struct net_d
 }
 
 
-static int net_send_packet (struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t net_send_packet (struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
--- a/drivers/net/ks8842.c	2009-08-31 16:17:51.691086184 -0700
+++ b/drivers/net/ks8842.c	2009-08-31 16:42:55.394438559 -0700
@@ -551,7 +551,8 @@ static int ks8842_close(struct net_devic
 	return 0;
 }
 
-static int ks8842_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t ks8842_xmit_frame(struct sk_buff *skb,
+				     struct net_device *netdev)
 {
 	int ret;
 	struct ks8842_adapter *adapter = netdev_priv(netdev);
--- a/drivers/net/lib8390.c	2009-08-31 16:17:51.861094040 -0700
+++ b/drivers/net/lib8390.c	2009-08-31 16:42:54.338438353 -0700
@@ -299,7 +299,8 @@ static void __ei_tx_timeout(struct net_d
  * Sends a packet to an 8390 network device.
  */
 
-static int __ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
+				   struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
--- a/drivers/net/skge.c	2009-08-31 16:17:51.621091253 -0700
+++ b/drivers/net/skge.c	2009-08-31 16:42:47.811106110 -0700
@@ -2746,7 +2746,8 @@ static inline int skge_avail(const struc
 		+ (ring->to_clean - ring->to_use) - 1;
 }
 
-static int skge_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
+				   struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
--- a/drivers/net/sky2.c	2009-08-31 16:17:51.821080852 -0700
+++ b/drivers/net/sky2.c	2009-08-31 16:42:47.346437068 -0700
@@ -1574,7 +1574,8 @@ static void sky2_tx_unmap(struct pci_dev
  * the number of ring elements will probably be less than the number
  * of list elements used.
  */
-static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
+				   struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
--- a/drivers/net/via-rhine.c	2009-08-31 16:17:51.651089690 -0700
+++ b/drivers/net/via-rhine.c	2009-08-31 16:43:44.834449718 -0700
@@ -408,7 +408,8 @@ static int  mdio_read(struct net_device 
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int  rhine_open(struct net_device *dev);
 static void rhine_tx_timeout(struct net_device *dev);
-static int  rhine_start_tx(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
+				  struct net_device *dev);
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
 static void rhine_tx(struct net_device *dev);
 static int rhine_rx(struct net_device *dev, int limit);
@@ -1213,7 +1214,8 @@ static void rhine_tx_timeout(struct net_
 	netif_wake_queue(dev);
 }
 
-static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
+				  struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
--- a/drivers/ieee802154/fakehard.c	2009-08-31 16:17:52.131105595 -0700
+++ b/drivers/ieee802154/fakehard.c	2009-08-31 16:36:24.681107336 -0700
@@ -257,7 +257,8 @@ static int ieee802154_fake_close(struct 
 	return 0;
 }
 
-static int ieee802154_fake_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ieee802154_fake_xmit(struct sk_buff *skb,
+					      struct net_device *dev)
 {
 	skb->iif = dev->ifindex;
 	skb->dev = dev;
--- a/drivers/net/acenic.h	2009-08-31 16:17:52.061091529 -0700
+++ b/drivers/net/acenic.h	2009-08-31 16:38:11.466407413 -0700
@@ -775,7 +775,8 @@ static void ace_load_jumbo_rx_ring(struc
 static irqreturn_t ace_interrupt(int irq, void *dev_id);
 static int ace_load_firmware(struct net_device *dev);
 static int ace_open(struct net_device *dev);
-static int ace_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ace_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev);
 static int ace_close(struct net_device *dev);
 static void ace_tasklet(unsigned long dev);
 static void ace_dump_trace(struct ace_private *ap);
--- a/drivers/net/amd8111e.c	2009-08-31 16:17:52.101081038 -0700
+++ b/drivers/net/amd8111e.c	2009-08-31 16:38:13.842397169 -0700
@@ -1300,7 +1300,8 @@ static int amd8111e_tx_queue_avail(struc
 This function will queue the transmit packets to the descriptors and will trigger the send operation. It also initializes the transmit descriptors with buffer physical address, byte count, ownership to hardware etc.
 */
 
-static int amd8111e_start_xmit(struct sk_buff *skb, struct net_device * dev)
+static netdev_tx_t amd8111e_start_xmit(struct sk_buff *skb,
+				       struct net_device * dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int tx_index;
--- a/drivers/net/ariadne.c	2009-08-31 16:17:51.851091302 -0700
+++ b/drivers/net/ariadne.c	2009-08-31 16:38:19.354407841 -0700
@@ -115,7 +115,8 @@ struct lancedata {
 
 static int ariadne_open(struct net_device *dev);
 static void ariadne_init_ring(struct net_device *dev);
-static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ariadne_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev);
 static void ariadne_tx_timeout(struct net_device *dev);
 static int ariadne_rx(struct net_device *dev);
 static void ariadne_reset(struct net_device *dev);
@@ -589,7 +590,8 @@ static void ariadne_tx_timeout(struct ne
 }
 
 
-static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ariadne_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
     struct ariadne_private *priv = netdev_priv(dev);
     volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
--- a/drivers/net/atl1c/atl1c_main.c	2009-08-31 16:17:52.101081038 -0700
+++ b/drivers/net/atl1c/atl1c_main.c	2009-08-31 16:36:24.681107336 -0700
@@ -2055,7 +2055,8 @@ static void atl1c_tx_queue(struct atl1c_
 	AT_WRITE_REG(&adapter->hw, REG_MB_PRIO_PROD_IDX, prod_data);
 }
 
-static int atl1c_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
+					  struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	unsigned long flags;
--- a/drivers/net/atl1e/atl1e_main.c	2009-08-31 16:17:52.001107231 -0700
+++ b/drivers/net/atl1e/atl1e_main.c	2009-08-31 16:36:24.691127813 -0700
@@ -1839,7 +1839,8 @@ static void atl1e_tx_queue(struct atl1e_
 	AT_WRITE_REG(&adapter->hw, REG_MB_TPD_PROD_IDX, tx_ring->next_to_use);
 }
 
-static int atl1e_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
+					  struct net_device *netdev)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 	unsigned long flags;
--- a/drivers/net/atlx/atl2.c	2009-08-31 16:17:51.631107610 -0700
+++ b/drivers/net/atlx/atl2.c	2009-08-31 16:36:24.691127813 -0700
@@ -821,7 +821,8 @@ static inline int TxdFreeBytes(struct at
 		(int) (txd_read_ptr - adapter->txd_write_ptr - 1);
 }
 
-static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t atl2_xmit_frame(struct sk_buff *skb,
+					 struct net_device *netdev)
 {
 	struct atl2_adapter *adapter = netdev_priv(netdev);
 	struct tx_pkt_header *txph;
--- a/drivers/net/atp.c	2009-08-31 16:17:51.731107333 -0700
+++ b/drivers/net/atp.c	2009-08-31 16:40:35.581127580 -0700
@@ -199,7 +199,8 @@ static int net_open(struct net_device *d
 static void hardware_init(struct net_device *dev);
 static void write_packet(long ioaddr, int length, unsigned char *packet, int pad, int mode);
 static void trigger_send(long ioaddr, int length);
-static int	atp_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t atp_send_packet(struct sk_buff *skb,
+				   struct net_device *dev);
 static irqreturn_t atp_interrupt(int irq, void *dev_id);
 static void net_rx(struct net_device *dev);
 static void read_block(long ioaddr, int length, unsigned char *buffer, int data_mode);
@@ -552,7 +553,8 @@ static void tx_timeout(struct net_device
 	dev->stats.tx_errors++;
 }
 
-static int atp_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t atp_send_packet(struct sk_buff *skb,
+				   struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
--- a/drivers/net/au1000_eth.c	2009-08-31 16:17:52.011106546 -0700
+++ b/drivers/net/au1000_eth.c	2009-08-31 16:36:24.691127813 -0700
@@ -937,7 +937,7 @@ static int au1000_close(struct net_devic
 /*
  * Au1000 transmit routine.
  */
-static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
--- a/drivers/net/b44.c	2009-08-31 16:17:51.801107922 -0700
+++ b/drivers/net/b44.c	2009-08-31 16:38:33.626404356 -0700
@@ -946,7 +946,7 @@ static void b44_tx_timeout(struct net_de
 	netif_wake_queue(dev);
 }
 
-static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
 	int rc = NETDEV_TX_OK;
--- a/drivers/net/eepro.c	2009-08-31 16:17:51.751109387 -0700
+++ b/drivers/net/eepro.c	2009-08-31 16:39:28.091106432 -0700
@@ -309,7 +309,8 @@ struct eepro_local {
 
 static int	eepro_probe1(struct net_device *dev, int autoprobe);
 static int	eepro_open(struct net_device *dev);
-static int	eepro_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t eepro_send_packet(struct sk_buff *skb,
+				     struct net_device *dev);
 static irqreturn_t eepro_interrupt(int irq, void *dev_id);
 static void 	eepro_rx(struct net_device *dev);
 static void 	eepro_transmit_interrupt(struct net_device *dev);
@@ -1133,7 +1134,8 @@ static void eepro_tx_timeout (struct net
 }
 
 
-static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t eepro_send_packet(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct eepro_local *lp = netdev_priv(dev);
 	unsigned long flags;
--- a/drivers/net/netxen/netxen_nic_main.c	2009-08-31 16:17:52.091080675 -0700
+++ b/drivers/net/netxen/netxen_nic_main.c	2009-08-31 16:36:24.691127813 -0700
@@ -63,7 +63,8 @@ static int __devinit netxen_nic_probe(st
 static void __devexit netxen_nic_remove(struct pci_dev *pdev);
 static int netxen_nic_open(struct net_device *netdev);
 static int netxen_nic_close(struct net_device *netdev);
-static int netxen_nic_xmit_frame(struct sk_buff *, struct net_device *);
+static netdev_tx_t netxen_nic_xmit_frame(struct sk_buff *,
+					       struct net_device *);
 static void netxen_tx_timeout(struct net_device *netdev);
 static void netxen_reset_task(struct work_struct *work);
 static void netxen_watchdog(unsigned long);
@@ -1599,7 +1600,7 @@ netxen_clear_cmddesc(u64 *desc)
 	desc[2] = 0ULL;
 }
 
-static int
+static netdev_tx_t
 netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
--- a/drivers/net/niu.c	2009-08-31 16:17:51.941091292 -0700
+++ b/drivers/net/niu.c	2009-08-31 16:42:52.811091094 -0700
@@ -6657,7 +6657,8 @@ static u64 niu_compute_tx_flags(struct s
 	return ret;
 }
 
-static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 	unsigned long align, headroom;
--- a/drivers/net/tg3.c	2009-08-31 16:17:52.031107202 -0700
+++ b/drivers/net/tg3.c	2009-08-31 16:42:44.842436766 -0700
@@ -5135,7 +5135,8 @@ static void tg3_set_txd(struct tg3_napi 
 /* hard_start_xmit for devices that don't have any bugs and
  * support TG3_FLG2_HW_TSO_2 only.
  */
-static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	u32 len, entry, base_flags, mss;
@@ -5251,7 +5252,8 @@ out_unlock:
 	return NETDEV_TX_OK;
 }
 
-static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
+static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *,
+					  struct net_device *);
 
 /* Use GSO to workaround a rare TSO bug that may be triggered when the
  * TSO header is greater than 80 bytes.
@@ -5290,7 +5292,8 @@ tg3_tso_bug_end:
 /* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
  * support TG3_FLG2_HW_TSO_1 or firmware TSO only.
  */
-static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
+					  struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	u32 len, entry, base_flags, mss;
--- a/drivers/net/arcnet/arcnet.c	2009-08-31 16:17:51.731107333 -0700
+++ b/drivers/net/arcnet/arcnet.c	2009-08-31 16:36:24.701106875 -0700
@@ -591,7 +591,8 @@ static int arcnet_rebuild_header(struct 
 
 
 /* Called by the kernel in order to transmit a packet. */
-int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt;
--- a/drivers/net/atlx/atl1.c	2009-08-31 16:17:51.641113072 -0700
+++ b/drivers/net/atlx/atl1.c	2009-08-31 16:36:24.701106875 -0700
@@ -2349,7 +2349,8 @@ static void atl1_tx_queue(struct atl1_ad
 	atomic_set(&tpd_ring->next_to_use, next_to_use);
 }
 
-static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
+					 struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
--- a/drivers/net/benet/be_main.c	2009-08-31 16:17:52.041117203 -0700
+++ b/drivers/net/benet/be_main.c	2009-08-31 16:36:24.701106875 -0700
@@ -427,7 +427,8 @@ static int make_tx_wrbs(struct be_adapte
 	return copied;
 }
 
-static int be_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t be_xmit(struct sk_buff *skb,
+				 struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_tx_obj *tx_obj = &adapter->tx_obj;
--- a/drivers/net/can/sja1000/sja1000.c	2009-08-31 16:17:51.741089258 -0700
+++ b/drivers/net/can/sja1000/sja1000.c	2009-08-31 16:36:24.711080559 -0700
@@ -238,7 +238,8 @@ static void chipset_init(struct net_devi
  * xx xx xx xx	 ff	 ll   00 11 22 33 44 55 66 77
  * [  can-id ] [flags] [len] [can data (up to 8 bytes]
  */
-static int sja1000_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sja1000_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
--- a/drivers/net/cs89x0.c	2009-08-31 16:17:51.911090062 -0700
+++ b/drivers/net/cs89x0.c	2009-08-31 16:38:49.481122968 -0700
@@ -246,7 +246,7 @@ struct net_local {
 
 static int cs89x0_probe1(struct net_device *dev, int ioaddr, int modular);
 static int net_open(struct net_device *dev);
-static int net_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t net_interrupt(int irq, void *dev_id);
 static void set_multicast_list(struct net_device *dev);
 static void net_timeout(struct net_device *dev);
@@ -1518,7 +1518,7 @@ static void net_timeout(struct net_devic
 	netif_wake_queue(dev);
 }
 
-static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
--- a/drivers/net/cxgb3/adapter.h	2009-08-31 16:17:51.611108000 -0700
+++ b/drivers/net/cxgb3/adapter.h	2009-08-31 16:36:24.711080559 -0700
@@ -309,7 +309,7 @@ void t3_stop_sge_timers(struct adapter *
 void t3_free_sge_resources(struct adapter *adap);
 void t3_sge_err_intr_handler(struct adapter *adapter);
 irq_handler_t t3_intr_handler(struct adapter *adap, int polling);
-int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev);
 int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p);
 int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
--- a/drivers/net/cxgb3/sge.c	2009-08-31 16:17:51.601091224 -0700
+++ b/drivers/net/cxgb3/sge.c	2009-08-31 16:36:24.711080559 -0700
@@ -1216,7 +1216,7 @@ static inline void t3_stop_tx_queue(stru
  *
  *	Add a packet to an SGE Tx queue.  Runs with softirqs disabled.
  */
-int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int qidx;
 	unsigned int ndesc, pidx, credits, gen, compl;
--- a/drivers/net/dl2k.c	2009-08-31 16:17:51.621091253 -0700
+++ b/drivers/net/dl2k.c	2009-08-31 16:39:09.146409342 -0700
@@ -59,7 +59,7 @@ static int rio_open (struct net_device *
 static void rio_timer (unsigned long data);
 static void rio_tx_timeout (struct net_device *dev);
 static void alloc_list (struct net_device *dev);
-static int start_xmit (struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t start_xmit (struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rio_interrupt (int irq, void *dev_instance);
 static void rio_free_tx (struct net_device *dev, int irq);
 static void tx_error (struct net_device *dev, int tx_status);
@@ -600,7 +600,7 @@ alloc_list (struct net_device *dev)
 	return;
 }
 
-static int
+static netdev_tx_t
 start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
--- a/drivers/net/dnet.c	2009-08-31 16:17:51.851091302 -0700
+++ b/drivers/net/dnet.c	2009-08-31 16:39:16.011085789 -0700
@@ -541,7 +541,7 @@ static inline void dnet_print_skb(struct
 #define dnet_print_skb(skb)	do {} while (0)
 #endif
 
-static int dnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t dnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 
 	struct dnet *bp = netdev_priv(dev);
--- a/drivers/net/enic/enic_main.c	2009-08-31 16:17:51.901107298 -0700
+++ b/drivers/net/enic/enic_main.c	2009-08-31 16:36:24.711080559 -0700
@@ -622,7 +622,8 @@ static inline void enic_queue_wq_skb(str
 }
 
 /* netif_tx_lock held, process context with BHs disabled, or BH */
-static int enic_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
+					      struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_wq *wq = &enic->wq[0];
--- a/drivers/net/mlx4/en_tx.c	2009-08-31 16:17:51.921107815 -0700
+++ b/drivers/net/mlx4/en_tx.c	2009-08-31 16:36:24.711080559 -0700
@@ -588,7 +588,7 @@ u16 mlx4_en_select_queue(struct net_devi
 	return skb_tx_hash(dev, skb);
 }
 
-int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
--- a/drivers/net/mlx4/mlx4_en.h	2009-08-31 16:17:51.931091627 -0700
+++ b/drivers/net/mlx4/mlx4_en.h	2009-08-31 16:36:24.711080559 -0700
@@ -518,7 +518,7 @@ int mlx4_en_arm_cq(struct mlx4_en_priv *
 void mlx4_en_poll_tx_cq(unsigned long data);
 void mlx4_en_tx_irq(struct mlx4_cq *mcq);
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb);
-int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring,
 			   u32 size, u16 stride);
--- a/drivers/net/myri10ge/myri10ge.c	2009-08-31 16:17:52.031107202 -0700
+++ b/drivers/net/myri10ge/myri10ge.c	2009-08-31 16:36:24.721107741 -0700
@@ -360,7 +360,8 @@ MODULE_PARM_DESC(myri10ge_dca, "Enable D
 #define myri10ge_pio_copy(to,from,size) __iowrite64_copy(to,from,size/8)
 
 static void myri10ge_set_multicast_list(struct net_device *dev);
-static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t myri10ge_sw_tso(struct sk_buff *skb,
+					 struct net_device *dev);
 
 static inline void put_be32(__be32 val, __be32 __iomem * p)
 {
@@ -2656,7 +2657,8 @@ myri10ge_submit_req(struct myri10ge_tx_b
  * it and try again.
  */
 
-static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t myri10ge_xmit(struct sk_buff *skb,
+				       struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_slice_state *ss;
@@ -2947,12 +2949,13 @@ drop:
 
 }
 
-static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t myri10ge_sw_tso(struct sk_buff *skb,
+					 struct net_device *dev)
 {
 	struct sk_buff *segs, *curr;
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_slice_state *ss;
-	int status;
+	netdev_tx_t status;
 
 	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO6);
 	if (IS_ERR(segs))
--- a/drivers/net/qla3xxx.c	2009-08-31 16:17:52.021091264 -0700
+++ b/drivers/net/qla3xxx.c	2009-08-31 16:42:51.402437620 -0700
@@ -2572,7 +2572,8 @@ map_error:
  * The IOCB is always the top of the chain followed by one or more
  * OALs (when necessary).
  */
-static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
+static netdev_tx_t ql3xxx_send(struct sk_buff *skb,
+			       struct net_device *ndev)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
 	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
--- a/drivers/net/qlge/qlge_main.c	2009-08-31 16:17:51.831081285 -0700
+++ b/drivers/net/qlge/qlge_main.c	2009-08-31 16:36:24.721107741 -0700
@@ -2103,7 +2103,7 @@ static void ql_hw_csum_setup(struct sk_b
 				    iph->daddr, len, iph->protocol, 0);
 }
 
-static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
+static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct tx_ring_desc *tx_ring_desc;
 	struct ob_mac_iocb_req *mac_iocb_ptr;
--- a/drivers/net/r8169.c	2009-08-31 16:17:51.871108023 -0700
+++ b/drivers/net/r8169.c	2009-08-31 16:41:54.586435235 -0700
@@ -507,7 +507,8 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 
 static int rtl8169_open(struct net_device *dev);
-static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev);
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
 static int rtl8169_init_ring(struct net_device *dev);
 static void rtl_hw_start(struct net_device *dev);
@@ -3357,7 +3358,8 @@ static inline u32 rtl8169_tso_csum(struc
 	return 0;
 }
 
-static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	unsigned int frags, entry = tp->cur_tx % NUM_TX_DESC;
@@ -3366,7 +3368,6 @@ static int rtl8169_start_xmit(struct sk_
 	dma_addr_t mapping;
 	u32 status, len;
 	u32 opts1;
-	int ret = NETDEV_TX_OK;
 
 	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
 		if (netif_msg_drv(tp)) {
@@ -3418,13 +3419,12 @@ static int rtl8169_start_xmit(struct sk_
 	}
 
 out:
-	return ret;
+	return NETDEV_TX_OK;
 
 err_stop:
 	netif_stop_queue(dev);
-	ret = NETDEV_TX_BUSY;
 	dev->stats.tx_dropped++;
-	goto out;
+	return NETDEV_TX_BUSY;
 }
 
 static void rtl8169_pcierr_interrupt(struct net_device *dev)
--- a/drivers/net/s2io.c	2009-08-31 16:17:51.591127388 -0700
+++ b/drivers/net/s2io.c	2009-08-31 16:36:24.721107741 -0700
@@ -4072,7 +4072,7 @@ static int s2io_close(struct net_device 
  *  0 on success & 1 on failure.
  */
 
-static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
 	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
--- a/drivers/net/sfc/selftest.c	2009-08-31 16:17:51.971102858 -0700
+++ b/drivers/net/sfc/selftest.c	2009-08-31 16:36:24.721107741 -0700
@@ -400,7 +400,8 @@ static int efx_begin_loopback(struct efx
 	struct efx_loopback_state *state = efx->loopback_selftest;
 	struct efx_loopback_payload *payload;
 	struct sk_buff *skb;
-	int i, rc;
+	int i;
+	netdev_tx_t rc;
 
 	/* Transmit N copies of buffer */
 	for (i = 0; i < state->packet_count; i++) {
--- a/drivers/net/sfc/tx.c	2009-08-31 16:17:51.981175158 -0700
+++ b/drivers/net/sfc/tx.c	2009-08-31 16:36:24.731107057 -0700
@@ -138,8 +138,8 @@ static void efx_tsoh_free(struct efx_tx_
  * Returns NETDEV_TX_OK or NETDEV_TX_BUSY
  * You must hold netif_tx_lock() to call this function.
  */
-static int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
-			   struct sk_buff *skb)
+static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
+					 struct sk_buff *skb)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	struct pci_dev *pci_dev = efx->pci_dev;
@@ -152,7 +152,7 @@ static int efx_enqueue_skb(struct efx_tx
 	unsigned int dma_len;
 	bool unmap_single;
 	int q_space, i = 0;
-	int rc = NETDEV_TX_OK;
+	netdev_tx_t rc = NETDEV_TX_OK;
 
 	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
 
@@ -353,14 +353,11 @@ static void efx_dequeue_buffers(struct e
  *
  * Context: netif_tx_lock held
  */
-inline int efx_xmit(struct efx_nic *efx,
-		    struct efx_tx_queue *tx_queue, struct sk_buff *skb)
+inline netdev_tx_t efx_xmit(struct efx_nic *efx,
+			   struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 {
-	int rc;
-
 	/* Map fragments for DMA and add to TX queue */
-	rc = efx_enqueue_skb(tx_queue, skb);
-	return rc;
+	return efx_enqueue_skb(tx_queue, skb);
 }
 
 /* Initiate a packet transmission.  We use one channel per CPU
@@ -372,7 +369,8 @@ inline int efx_xmit(struct efx_nic *efx,
  * Note that returning anything other than NETDEV_TX_OK will cause the
  * OS to free the skb.
  */
-int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
+netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
+				      struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_tx_queue *tx_queue;
--- a/drivers/net/skfp/skfddi.c	2009-08-31 16:17:51.741089258 -0700
+++ b/drivers/net/skfp/skfddi.c	2009-08-31 16:36:24.731107057 -0700
@@ -107,7 +107,8 @@ static void skfp_ctl_set_multicast_list(
 static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev);
 static int skfp_ctl_set_mac_address(struct net_device *dev, void *addr);
 static int skfp_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t skfp_send_pkt(struct sk_buff *skb,
+				       struct net_device *dev);
 static void send_queued_packets(struct s_smc *smc);
 static void CheckSourceAddress(unsigned char *frame, unsigned char *hw_addr);
 static void ResetAdapter(struct s_smc *smc);
@@ -1056,7 +1057,8 @@ static int skfp_ioctl(struct net_device 
  * Side Effects:
  *   None
  */
-static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t skfp_send_pkt(struct sk_buff *skb,
+				       struct net_device *dev)
 {
 	struct s_smc *smc = netdev_priv(dev);
 	skfddi_priv *bp = &smc->os;
--- a/drivers/net/vxge/vxge-main.c	2009-08-31 16:17:51.931091627 -0700
+++ b/drivers/net/vxge/vxge-main.c	2009-08-31 16:36:24.731107057 -0700
@@ -812,7 +812,7 @@ static int vxge_learn_mac(struct vxgedev
  * NOTE: when device cant queue the pkt, just the trans_start variable will
  * not be upadted.
 */
-static int
+static netdev_tx_t
 vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vxge_fifo *fifo = NULL;
--- a/drivers/net/8390.h	2009-08-31 16:17:52.131105595 -0700
+++ b/drivers/net/8390.h	2009-08-31 16:40:36.434427859 -0700
@@ -40,7 +40,7 @@ extern int ei_open(struct net_device *de
 extern int ei_close(struct net_device *dev);
 extern irqreturn_t ei_interrupt(int irq, void *dev_id);
 extern void ei_tx_timeout(struct net_device *dev);
-extern int ei_start_xmit(struct sk_buff *skb, struct net_device *dev);
+extern netdev_tx_t ei_start_xmit(struct sk_buff *skb, struct net_device *dev);
 extern void ei_set_multicast_list(struct net_device *dev);
 extern struct net_device_stats *ei_get_stats(struct net_device *dev);
 
@@ -58,7 +58,7 @@ extern int eip_open(struct net_device *d
 extern int eip_close(struct net_device *dev);
 extern irqreturn_t eip_interrupt(int irq, void *dev_id);
 extern void eip_tx_timeout(struct net_device *dev);
-extern int eip_start_xmit(struct sk_buff *skb, struct net_device *dev);
+extern netdev_tx_t eip_start_xmit(struct sk_buff *skb, struct net_device *dev);
 extern void eip_set_multicast_list(struct net_device *dev);
 extern struct net_device_stats *eip_get_stats(struct net_device *dev);
 
--- a/drivers/net/bnx2.c	2009-08-31 16:17:51.661107653 -0700
+++ b/drivers/net/bnx2.c	2009-08-31 16:36:24.731107057 -0700
@@ -6283,7 +6283,7 @@ bnx2_vlan_rx_register(struct net_device 
  * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue().
  */
-static int
+static netdev_tx_t
 bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
--- a/drivers/net/bnx2x_main.c	2009-08-31 16:17:51.891154077 -0700
+++ b/drivers/net/bnx2x_main.c	2009-08-31 16:38:39.354410495 -0700
@@ -10936,7 +10936,7 @@ exit_lbl:
  * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue()
  */
-static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	struct bnx2x_fastpath *fp, *fp_stat;
--- a/drivers/net/cassini.c	2009-08-31 16:17:51.671091953 -0700
+++ b/drivers/net/cassini.c	2009-08-31 16:38:42.266410766 -0700
@@ -2918,7 +2918,7 @@ static inline int cas_xmit_tx_ringN(stru
 	return 0;
 }
 
-static int cas_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t cas_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct cas *cp = netdev_priv(dev);
 
--- a/drivers/net/epic100.c	2009-08-31 16:17:52.091080675 -0700
+++ b/drivers/net/epic100.c	2009-08-31 16:39:51.594420051 -0700
@@ -298,7 +298,8 @@ static void epic_restart(struct net_devi
 static void epic_timer(unsigned long data);
 static void epic_tx_timeout(struct net_device *dev);
 static void epic_init_ring(struct net_device *dev);
-static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t epic_start_xmit(struct sk_buff *skb,
+				   struct net_device *dev);
 static int epic_rx(struct net_device *dev, int budget);
 static int epic_poll(struct napi_struct *napi, int budget);
 static irqreturn_t epic_interrupt(int irq, void *dev_instance);
@@ -961,7 +962,7 @@ static void epic_init_ring(struct net_de
 	return;
 }
 
-static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
 	int entry, free_count;
--- a/drivers/net/ethoc.c	2009-08-31 16:17:51.791080739 -0700
+++ b/drivers/net/ethoc.c	2009-08-31 16:40:02.458421479 -0700
@@ -802,7 +802,7 @@ static struct net_device_stats *ethoc_st
 	return &priv->stats;
 }
 
-static int ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
 	struct ethoc_bd bd;
--- a/drivers/net/fealnx.c	2009-08-31 16:17:51.681103561 -0700
+++ b/drivers/net/fealnx.c	2009-08-31 16:36:24.741106722 -0700
@@ -433,7 +433,7 @@ static void netdev_timer(unsigned long d
 static void reset_timer(unsigned long data);
 static void fealnx_tx_timeout(struct net_device *dev);
 static void init_ring(struct net_device *dev);
-static int start_tx(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
 static int netdev_rx(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
@@ -1305,7 +1305,7 @@ static void init_ring(struct net_device 
 }
 
 
-static int start_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	unsigned long flags;
--- a/drivers/net/hamachi.c	2009-08-31 16:17:51.921107815 -0700
+++ b/drivers/net/hamachi.c	2009-08-31 16:40:25.051129145 -0700
@@ -557,7 +557,8 @@ static int netdev_ioctl(struct net_devic
 static void hamachi_timer(unsigned long data);
 static void hamachi_tx_timeout(struct net_device *dev);
 static void hamachi_init_ring(struct net_device *dev);
-static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t hamachi_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev);
 static irqreturn_t hamachi_interrupt(int irq, void *dev_instance);
 static int hamachi_rx(struct net_device *dev);
 static inline int hamachi_tx(struct net_device *dev);
@@ -1263,7 +1264,8 @@ do { \
 } while (0)
 #endif
 
-static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hamachi_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct hamachi_private *hmp = netdev_priv(dev);
 	unsigned entry;
--- a/drivers/net/ibmveth.c	2009-08-31 16:17:51.861094040 -0700
+++ b/drivers/net/ibmveth.c	2009-08-31 16:42:56.026443187 -0700
@@ -887,7 +887,8 @@ static int ibmveth_ioctl(struct net_devi
 
 #define page_offset(v) ((unsigned long)(v) & ((1 << 12) - 1))
 
-static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
+				      struct net_device *netdev)
 {
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	union ibmveth_buf_desc desc;
--- a/drivers/net/ipg.c	2009-08-31 16:17:52.061091529 -0700
+++ b/drivers/net/ipg.c	2009-08-31 16:42:55.722443027 -0700
@@ -1858,7 +1858,8 @@ static int ipg_nic_stop(struct net_devic
 	return 0;
 }
 
-static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ipg_nic_hard_start_xmit(struct sk_buff *skb,
+					   struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->ioaddr;
--- a/drivers/net/jme.c	2009-08-31 16:17:51.911090062 -0700
+++ b/drivers/net/jme.c	2009-08-31 16:36:24.751080685 -0700
@@ -1931,7 +1931,7 @@ jme_stop_queue_if_full(struct jme_adapte
  * This function is already protected by netif_tx_lock()
  */
 
-static int
+static netdev_tx_t
 jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
--- a/drivers/net/ks8851.c	2009-08-31 16:17:52.001107231 -0700
+++ b/drivers/net/ks8851.c	2009-08-31 16:42:55.013622984 -0700
@@ -868,11 +868,12 @@ static int ks8851_net_stop(struct net_de
  * and secondly so we can round up more than one packet to transmit which
  * means we can try and avoid generating too many transmit done interrupts.
  */
-static int ks8851_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ks8851_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct ks8851_net *ks = netdev_priv(dev);
 	unsigned needed = calc_txlen(skb->len);
-	int ret = NETDEV_TX_OK;
+	netdev_tx_t ret = NETDEV_TX_OK;
 
 	if (netif_msg_tx_queued(ks))
 		ks_dbg(ks, "%s: skb %p, %d@%p\n", __func__,
--- a/drivers/net/loopback.c	2009-08-31 16:17:51.821080852 -0700
+++ b/drivers/net/loopback.c	2009-08-31 16:42:53.978443096 -0700
@@ -69,7 +69,8 @@ struct pcpu_lstats {
  * The higher levels take care of making this non-reentrant (it's
  * called with bh's disabled).
  */
-static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t loopback_xmit(struct sk_buff *skb,
+				 struct net_device *dev)
 {
 	struct pcpu_lstats *pcpu_lstats, *lb_stats;
 	int len;
--- a/drivers/net/natsemi.c	2009-08-31 16:17:51.811088031 -0700
+++ b/drivers/net/natsemi.c	2009-08-31 16:36:24.751080685 -0700
@@ -621,7 +621,7 @@ static void drain_ring(struct net_device
 static void free_ring(struct net_device *dev);
 static void reinit_ring(struct net_device *dev);
 static void init_registers(struct net_device *dev);
-static int start_tx(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
 static void netdev_error(struct net_device *dev, int intr_status);
 static int natsemi_poll(struct napi_struct *napi, int budget);
@@ -2079,7 +2079,7 @@ static void reinit_ring(struct net_devic
 	reinit_rx(dev);
 }
 
-static int start_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
--- a/drivers/net/ns83820.c	2009-08-31 16:17:51.711090054 -0700
+++ b/drivers/net/ns83820.c	2009-08-31 16:42:52.194444777 -0700
@@ -1077,7 +1077,8 @@ static void ns83820_cleanup_tx(struct ns
  * while trying to track down a bug in either the zero copy code or
  * the tx fifo (hence the MAX_FRAG_LEN).
  */
-static int ns83820_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
+					   struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	u32 free_idx, cmdsts, extsts;
--- a/drivers/net/pcnet32.c	2009-08-31 16:17:52.071101739 -0700
+++ b/drivers/net/pcnet32.c	2009-08-31 16:42:51.794438138 -0700
@@ -303,7 +303,8 @@ static int pcnet32_probe_pci(struct pci_
 static int pcnet32_probe1(unsigned long, int, struct pci_dev *);
 static int pcnet32_open(struct net_device *);
 static int pcnet32_init_ring(struct net_device *);
-static int pcnet32_start_xmit(struct sk_buff *, struct net_device *);
+static netdev_tx_t pcnet32_start_xmit(struct sk_buff *,
+				      struct net_device *);
 static void pcnet32_tx_timeout(struct net_device *dev);
 static irqreturn_t pcnet32_interrupt(int, void *);
 static int pcnet32_close(struct net_device *);
@@ -2481,7 +2482,8 @@ static void pcnet32_tx_timeout(struct ne
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
-static int pcnet32_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t pcnet32_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
--- a/drivers/net/r6040.c	2009-08-31 16:17:51.661107653 -0700
+++ b/drivers/net/r6040.c	2009-08-31 16:42:51.001128513 -0700
@@ -883,13 +883,13 @@ static int r6040_open(struct net_device 
 	return 0;
 }
 
-static int r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	struct r6040_descriptor *descptr;
 	void __iomem *ioaddr = lp->base;
 	unsigned long flags;
-	int ret = NETDEV_TX_OK;
 
 	/* Critical Section */
 	spin_lock_irqsave(&lp->lock, flags);
@@ -899,8 +899,7 @@ static int r6040_start_xmit(struct sk_bu
 		spin_unlock_irqrestore(&lp->lock, flags);
 		netif_stop_queue(dev);
 		printk(KERN_ERR DRV_NAME ": no tx descriptor\n");
-		ret = NETDEV_TX_BUSY;
-		return ret;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Statistic Counter */
@@ -928,7 +927,8 @@ static int r6040_start_xmit(struct sk_bu
 
 	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return ret;
+
+	return NETDEV_TX_OK;
 }
 
 static void r6040_multicast_list(struct net_device *dev)
--- a/drivers/net/rrunner.c	2009-08-31 16:17:51.671091953 -0700
+++ b/drivers/net/rrunner.c	2009-08-31 16:41:52.402435318 -0700
@@ -1401,7 +1401,8 @@ static int rr_close(struct net_device *d
 }
 
 
-static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t rr_start_xmit(struct sk_buff *skb,
+				 struct net_device *dev)
 {
 	struct rr_private *rrpriv = netdev_priv(dev);
 	struct rr_regs __iomem *regs = rrpriv->regs;
--- a/drivers/net/sfc/efx.h	2009-08-31 16:17:51.971102858 -0700
+++ b/drivers/net/sfc/efx.h	2009-08-31 16:36:24.751080685 -0700
@@ -20,8 +20,9 @@
 #define FALCON_B_P_DEVID        0x0710
 
 /* TX */
-extern int efx_xmit(struct efx_nic *efx,
-		    struct efx_tx_queue *tx_queue, struct sk_buff *skb);
+extern netdev_tx_t efx_xmit(struct efx_nic *efx,
+				  struct efx_tx_queue *tx_queue,
+				  struct sk_buff *skb);
 extern void efx_stop_queue(struct efx_nic *efx);
 extern void efx_wake_queue(struct efx_nic *efx);
 
--- a/drivers/net/sfc/tx.h	2009-08-31 16:17:51.981175158 -0700
+++ b/drivers/net/sfc/tx.h	2009-08-31 16:36:24.751080685 -0700
@@ -18,7 +18,8 @@ void efx_remove_tx_queue(struct efx_tx_q
 void efx_init_tx_queue(struct efx_tx_queue *tx_queue);
 void efx_fini_tx_queue(struct efx_tx_queue *tx_queue);
 
-int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
+netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
+				      struct net_device *net_dev);
 void efx_release_tx_buffers(struct efx_tx_queue *tx_queue);
 
 #endif /* EFX_TX_H */
--- a/drivers/net/sis190.c	2009-08-31 16:17:52.011106546 -0700
+++ b/drivers/net/sis190.c	2009-08-31 16:42:48.914443616 -0700
@@ -1168,7 +1168,8 @@ static int sis190_close(struct net_devic
 	return 0;
 }
 
-static int sis190_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sis190_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct sis190_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
--- a/drivers/net/sis900.c	2009-08-31 16:17:51.761108563 -0700
+++ b/drivers/net/sis900.c	2009-08-31 16:42:48.381106209 -0700
@@ -214,7 +214,8 @@ static void sis900_check_mode (struct ne
 static void sis900_tx_timeout(struct net_device *net_dev);
 static void sis900_init_tx_ring(struct net_device *net_dev);
 static void sis900_init_rx_ring(struct net_device *net_dev);
-static int sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
+static netdev_tx_t sis900_start_xmit(struct sk_buff *skb,
+				     struct net_device *net_dev);
 static int sis900_rx(struct net_device *net_dev);
 static void sis900_finish_xmit (struct net_device *net_dev);
 static irqreturn_t sis900_interrupt(int irq, void *dev_instance);
@@ -1571,7 +1572,7 @@ static void sis900_tx_timeout(struct net
  *	tell upper layer if the buffer is full
  */
 
-static int
+static netdev_tx_t
 sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
--- a/drivers/net/smsc9420.c	2009-08-31 16:17:51.761108563 -0700
+++ b/drivers/net/smsc9420.c	2009-08-31 16:42:46.234442667 -0700
@@ -968,7 +968,8 @@ static void smsc9420_complete_tx(struct 
 	}
 }
 
-static int smsc9420_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t smsc9420_hard_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	struct smsc9420_pdata *pd = netdev_priv(dev);
 	dma_addr_t mapping;
--- a/drivers/net/starfire.c	2009-08-31 16:17:51.761108563 -0700
+++ b/drivers/net/starfire.c	2009-08-31 16:36:24.761107239 -0700
@@ -595,7 +595,7 @@ static int	netdev_open(struct net_device
 static void	check_duplex(struct net_device *dev);
 static void	tx_timeout(struct net_device *dev);
 static void	init_ring(struct net_device *dev);
-static int	start_tx(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
 static void	netdev_error(struct net_device *dev, int intr_status);
 static int	__netdev_rx(struct net_device *dev, int *quota);
@@ -1223,7 +1223,7 @@ static void init_ring(struct net_device 
 }
 
 
-static int start_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	unsigned int entry;
--- a/drivers/net/sundance.c	2009-08-31 16:17:51.641113072 -0700
+++ b/drivers/net/sundance.c	2009-08-31 16:36:24.761107239 -0700
@@ -415,7 +415,7 @@ static void check_duplex(struct net_devi
 static void netdev_timer(unsigned long data);
 static void tx_timeout(struct net_device *dev);
 static void init_ring(struct net_device *dev);
-static int  start_tx(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev);
 static int reset_tx (struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
 static void rx_poll(unsigned long data);
@@ -1053,7 +1053,7 @@ static void tx_poll (unsigned long data)
 	return;
 }
 
-static int
+static netdev_tx_t
 start_tx (struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
--- a/drivers/net/sungem.c	2009-08-31 16:17:52.121107606 -0700
+++ b/drivers/net/sungem.c	2009-08-31 16:42:45.802436433 -0700
@@ -1015,7 +1015,8 @@ static __inline__ int gem_intme(int entr
 	return 0;
 }
 
-static int gem_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev)
 {
 	struct gem *gp = netdev_priv(dev);
 	int entry;
--- a/drivers/net/sunhme.c	2009-08-31 16:17:51.611108000 -0700
+++ b/drivers/net/sunhme.c	2009-08-31 16:42:30.306439876 -0700
@@ -2252,7 +2252,8 @@ static void happy_meal_tx_timeout(struct
 	netif_wake_queue(dev);
 }
 
-static int happy_meal_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
+					 struct net_device *dev)
 {
 	struct happy_meal *hp = netdev_priv(dev);
  	int entry;
--- a/drivers/net/tehuti.c	2009-08-31 16:17:51.691086184 -0700
+++ b/drivers/net/tehuti.c	2009-08-31 16:42:45.371105775 -0700
@@ -1622,7 +1622,8 @@ static inline int bdx_tx_space(struct bd
  *   the driver. Note: the driver must NOT put the skb in its DMA ring.
  * o NETDEV_TX_LOCKED Locking failed, please retry quickly.
  */
-static int bdx_tx_transmit(struct sk_buff *skb, struct net_device *ndev)
+static netdev_tx_t bdx_tx_transmit(struct sk_buff *skb,
+				   struct net_device *ndev)
 {
 	struct bdx_priv *priv = netdev_priv(ndev);
 	struct txd_fifo *f = &priv->txd_fifo0;
--- a/drivers/net/tlan.c	2009-08-31 16:17:51.781091061 -0700
+++ b/drivers/net/tlan.c	2009-08-31 16:43:00.411106320 -0700
@@ -289,7 +289,7 @@ static void	TLan_EisaProbe( void );
 static void	TLan_Eisa_Cleanup( void );
 static int      TLan_Init( struct net_device * );
 static int	TLan_Open( struct net_device *dev );
-static int	TLan_StartTx( struct sk_buff *, struct net_device *);
+static netdev_tx_t TLan_StartTx( struct sk_buff *, struct net_device *);
 static irqreturn_t TLan_HandleInterrupt( int, void *);
 static int	TLan_Close( struct net_device *);
 static struct	net_device_stats *TLan_GetStats( struct net_device *);
@@ -1083,7 +1083,7 @@ static void TLan_tx_timeout_work(struct 
 	 *
 	 **************************************************************/
 
-static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
+static netdev_tx_t TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	dma_addr_t	tail_list_phys;
--- a/drivers/net/typhoon.c	2009-08-31 16:17:51.771107041 -0700
+++ b/drivers/net/typhoon.c	2009-08-31 16:36:24.771091120 -0700
@@ -762,7 +762,7 @@ typhoon_tso_fill(struct sk_buff *skb, st
 	tcpd->status = 0;
 }
 
-static int
+static netdev_tx_t
 typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct typhoon *tp = netdev_priv(dev);
--- a/drivers/net/via-velocity.c	2009-08-31 16:17:52.051110024 -0700
+++ b/drivers/net/via-velocity.c	2009-08-31 16:43:44.442449061 -0700
@@ -2465,7 +2465,8 @@ static int velocity_close(struct net_dev
  *	Called by the networ layer to request a packet is queued to
  *	the velocity. Returns zero on success.
  */
-static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t velocity_xmit(struct sk_buff *skb,
+				 struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 	int qnum = 0;
--- a/drivers/net/yellowfin.c	2009-08-31 16:17:51.881097631 -0700
+++ b/drivers/net/yellowfin.c	2009-08-31 16:43:43.994451131 -0700
@@ -347,7 +347,8 @@ static int yellowfin_open(struct net_dev
 static void yellowfin_timer(unsigned long data);
 static void yellowfin_tx_timeout(struct net_device *dev);
 static void yellowfin_init_ring(struct net_device *dev);
-static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t yellowfin_start_xmit(struct sk_buff *skb,
+					struct net_device *dev);
 static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance);
 static int yellowfin_rx(struct net_device *dev);
 static void yellowfin_error(struct net_device *dev, int intr_status);
@@ -808,7 +809,8 @@ static void yellowfin_init_ring(struct n
 	return;
 }
 
-static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t yellowfin_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
 	unsigned entry;
--- a/drivers/net/forcedeth.c	2009-08-31 16:17:51.831081285 -0700
+++ b/drivers/net/forcedeth.c	2009-08-31 16:40:19.171085873 -0700
@@ -2137,7 +2137,7 @@ static void nv_gear_backoff_reseed(struc
  * nv_start_xmit: dev->hard_start_xmit function
  * Called with netif_tx_lock held.
  */
-static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 tx_flags = 0;
@@ -2257,7 +2257,8 @@ static int nv_start_xmit(struct sk_buff 
 	return NETDEV_TX_OK;
 }
 
-static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
+					   struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 tx_flags = 0;
--- a/drivers/net/chelsio/sge.c	2009-08-31 16:17:51.951107788 -0700
+++ b/drivers/net/chelsio/sge.c	2009-08-31 16:36:24.771091120 -0700
@@ -1776,7 +1776,7 @@ static inline int eth_hdr_len(const void
 /*
  * Adds the CPL header to the sk_buff and passes it to t1_sge_tx.
  */
-int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct adapter *adapter = dev->ml_priv;
 	struct sge *sge = adapter->sge;
--- a/drivers/net/chelsio/sge.h	2009-08-31 16:17:51.961089993 -0700
+++ b/drivers/net/chelsio/sge.h	2009-08-31 16:36:24.771091120 -0700
@@ -78,7 +78,7 @@ void t1_sge_destroy(struct sge *);
 irqreturn_t t1_interrupt(int irq, void *cookie);
 int t1_poll(struct napi_struct *, int);
 
-int t1_start_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev);
 void t1_set_vlan_accel(struct adapter *adapter, int on_off);
 void t1_sge_start(struct sge *);
 void t1_sge_stop(struct sge *);
--- a/include/linux/arcdevice.h	2009-08-31 16:17:52.141091361 -0700
+++ b/include/linux/arcdevice.h	2009-08-31 16:36:24.771091120 -0700
@@ -337,7 +337,8 @@ struct net_device *alloc_arcdev(const ch
 
 int arcnet_open(struct net_device *dev);
 int arcnet_close(struct net_device *dev);
-int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
+				     struct net_device *dev);
 void arcnet_timeout(struct net_device *dev);
 
 #endif				/* __KERNEL__ */
--- a/drivers/net/defxx.c	2009-08-31 16:17:51.651089690 -0700
+++ b/drivers/net/defxx.c	2009-08-31 16:38:56.194413210 -0700
@@ -300,7 +300,8 @@ static int		dfx_rcv_init(DFX_board_t *bp
 static void		dfx_rcv_queue_process(DFX_board_t *bp);
 static void		dfx_rcv_flush(DFX_board_t *bp);
 
-static int		dfx_xmt_queue_pkt(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t dfx_xmt_queue_pkt(struct sk_buff *skb,
+				     struct net_device *dev);
 static int		dfx_xmt_done(DFX_board_t *bp);
 static void		dfx_xmt_flush(DFX_board_t *bp);
 
@@ -3188,11 +3189,8 @@ static void dfx_rcv_queue_process(
  *   None
  */
 
-static int dfx_xmt_queue_pkt(
-	struct sk_buff	*skb,
-	struct net_device	*dev
-	)
-
+static netdev_tx_t dfx_xmt_queue_pkt(struct sk_buff *skb,
+				     struct net_device *dev)
 	{
 	DFX_board_t		*bp = netdev_priv(dev);
 	u8			prod;				/* local transmit producer index */
--- a/drivers/net/eexpress.c	2009-08-31 16:17:52.081095049 -0700
+++ b/drivers/net/eexpress.c	2009-08-31 16:39:35.771085661 -0700
@@ -246,7 +246,8 @@ static char mca_irqmap[] = { 12, 9, 3, 4
 static int eexp_open(struct net_device *dev);
 static int eexp_close(struct net_device *dev);
 static void eexp_timeout(struct net_device *dev);
-static int eexp_xmit(struct sk_buff *buf, struct net_device *dev);
+static netdev_tx_t eexp_xmit(struct sk_buff *buf,
+			     struct net_device *dev);
 
 static irqreturn_t eexp_irq(int irq, void *dev_addr);
 static void eexp_set_multicast(struct net_device *dev);
@@ -650,7 +651,7 @@ static void eexp_timeout(struct net_devi
  * Called to transmit a packet, or to allow us to right ourselves
  * if the kernel thinks we've died.
  */
-static int eexp_xmit(struct sk_buff *buf, struct net_device *dev)
+static netdev_tx_t eexp_xmit(struct sk_buff *buf, struct net_device *dev)
 {
 	short length = buf->len;
 #ifdef CONFIG_SMP
--- a/drivers/net/hp100.c	2009-08-31 16:17:52.111091459 -0700
+++ b/drivers/net/hp100.c	2009-08-31 16:40:42.621128055 -0700
@@ -240,9 +240,10 @@ static int hp100_probe1(struct net_devic
 
 static int hp100_open(struct net_device *dev);
 static int hp100_close(struct net_device *dev);
-static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static int hp100_start_xmit_bm(struct sk_buff *skb,
-			       struct net_device *dev);
+static netdev_tx_t hp100_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev);
+static netdev_tx_t hp100_start_xmit_bm(struct sk_buff *skb,
+				       struct net_device *dev);
 static void hp100_rx(struct net_device *dev);
 static struct net_device_stats *hp100_get_stats(struct net_device *dev);
 static void hp100_misc_interrupt(struct net_device *dev);
@@ -1483,7 +1484,8 @@ static int hp100_check_lan(struct net_de
  */
 
 /* tx function for busmaster mode */
-static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hp100_start_xmit_bm(struct sk_buff *skb,
+				       struct net_device *dev)
 {
 	unsigned long flags;
 	int i, ok_flag;
@@ -1635,7 +1637,8 @@ static void hp100_clean_txring(struct ne
 }
 
 /* tx function for slave modes */
-static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hp100_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	unsigned long flags;
 	int i, ok_flag;
--- a/drivers/net/ibmlana.c	2009-08-31 16:17:51.701108128 -0700
+++ b/drivers/net/ibmlana.c	2009-08-31 16:36:24.781108175 -0700
@@ -812,7 +812,7 @@ static int ibmlana_close(struct net_devi
 
 /* transmit a block. */
 
-static int ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	ibmlana_priv *priv = netdev_priv(dev);
 	int tmplen, addr;
--- a/drivers/net/lance.c	2009-08-31 16:17:51.721104525 -0700
+++ b/drivers/net/lance.c	2009-08-31 16:42:54.666443453 -0700
@@ -300,7 +300,8 @@ static unsigned char lance_need_isa_boun
 
 static int lance_open(struct net_device *dev);
 static void lance_init_ring(struct net_device *dev, gfp_t mode);
-static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t lance_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev);
 static int lance_rx(struct net_device *dev);
 static irqreturn_t lance_interrupt(int irq, void *dev_id);
 static int lance_close(struct net_device *dev);
@@ -949,7 +950,8 @@ static void lance_tx_timeout (struct net
 }
 
 
-static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t lance_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct lance_private *lp = dev->ml_priv;
 	int ioaddr = dev->base_addr;
--- a/drivers/net/rrunner.h	2009-08-31 16:17:51.721104525 -0700
+++ b/drivers/net/rrunner.h	2009-08-31 16:42:50.602442443 -0700
@@ -831,7 +831,8 @@ static int rr_init1(struct net_device *d
 static irqreturn_t rr_interrupt(int irq, void *dev_id);
 
 static int rr_open(struct net_device *dev);
-static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t rr_start_xmit(struct sk_buff *skb,
+				 struct net_device *dev);
 static int rr_close(struct net_device *dev);
 static int rr_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static unsigned int rr_read_eeprom(struct rr_private *rrpriv,
--- a/drivers/net/sb1000.c	2009-08-31 16:17:52.081095049 -0700
+++ b/drivers/net/sb1000.c	2009-08-31 16:42:50.181105863 -0700
@@ -82,7 +82,8 @@ struct sb1000_private {
 extern int sb1000_probe(struct net_device *dev);
 static int sb1000_open(struct net_device *dev);
 static int sb1000_dev_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd);
-static int sb1000_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t sb1000_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev);
 static irqreturn_t sb1000_interrupt(int irq, void *dev_id);
 static int sb1000_close(struct net_device *dev);
 
@@ -1080,7 +1081,7 @@ static int sb1000_dev_ioctl(struct net_d
 }
 
 /* transmit function: do nothing since SB1000 can't send anything out */
-static int
+static netdev_tx_t
 sb1000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	printk(KERN_WARNING "%s: trying to transmit!!!\n", dev->name);
--- a/drivers/net/seeq8005.c	2009-08-31 16:17:52.111091459 -0700
+++ b/drivers/net/seeq8005.c	2009-08-31 16:42:49.354442555 -0700
@@ -81,7 +81,8 @@ struct net_local {
 static int seeq8005_probe1(struct net_device *dev, int ioaddr);
 static int seeq8005_open(struct net_device *dev);
 static void seeq8005_timeout(struct net_device *dev);
-static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t seeq8005_send_packet(struct sk_buff *skb,
+					struct net_device *dev);
 static irqreturn_t seeq8005_interrupt(int irq, void *dev_id);
 static void seeq8005_rx(struct net_device *dev);
 static int seeq8005_close(struct net_device *dev);
@@ -394,7 +395,8 @@ static void seeq8005_timeout(struct net_
 	netif_wake_queue(dev);
 }
 
-static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t seeq8005_send_packet(struct sk_buff *skb,
+					struct net_device *dev)
 {
 	short length = skb->len;
 	unsigned char *buf;
--- a/drivers/net/smc9194.c	2009-08-31 16:17:51.691086184 -0700
+++ b/drivers/net/smc9194.c	2009-08-31 16:42:46.642442217 -0700
@@ -299,7 +299,8 @@ static void smc_hardware_send_packet( st
  . to store the packet, I call this routine, which either sends it
  . now, or generates an interrupt when the card is ready for the
  . packet */
-static int  smc_wait_to_send_packet( struct sk_buff * skb, struct net_device *dev );
+static netdev_tx_t  smc_wait_to_send_packet( struct sk_buff * skb,
+					     struct net_device *dev );
 
 /* this does a soft reset on the device */
 static void smc_reset( int ioaddr );
@@ -487,7 +488,8 @@ static void smc_setmulticast( int ioaddr
  . o 	(NO): Enable interrupts and let the interrupt handler deal with it.
  . o	(YES):Send it now.
 */
-static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * dev )
+static netdev_tx_t smc_wait_to_send_packet(struct sk_buff *skb,
+					   struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 	unsigned int ioaddr 	= dev->base_addr;
--- a/drivers/net/depca.c	2009-08-31 16:17:51.601091224 -0700
+++ b/drivers/net/depca.c	2009-08-31 16:39:04.691085620 -0700
@@ -516,7 +516,8 @@ struct depca_private {
 ** Public Functions
 */
 static int depca_open(struct net_device *dev);
-static int depca_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t depca_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev);
 static irqreturn_t depca_interrupt(int irq, void *dev_id);
 static int depca_close(struct net_device *dev);
 static int depca_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -928,7 +929,8 @@ static void depca_tx_timeout(struct net_
 /*
 ** Writes a socket buffer to TX descriptor ring and starts transmission
 */
-static int depca_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t depca_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
--- a/drivers/net/ewrk3.c	2009-08-31 16:17:51.581109773 -0700
+++ b/drivers/net/ewrk3.c	2009-08-31 16:40:35.114425599 -0700
@@ -298,7 +298,7 @@ struct ewrk3_private {
    ** Public Functions
  */
 static int ewrk3_open(struct net_device *dev);
-static int ewrk3_queue_pkt(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ewrk3_queue_pkt(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t ewrk3_interrupt(int irq, void *dev_id);
 static int ewrk3_close(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
@@ -764,7 +764,7 @@ static void ewrk3_timeout(struct net_dev
 /*
    ** Writes a socket buffer to the free page queue
  */
-static int ewrk3_queue_pkt (struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ewrk3_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
 	u_long iobase = dev->base_addr;
--- a/drivers/net/znet.c	2009-08-31 16:17:51.581109773 -0700
+++ b/drivers/net/znet.c	2009-08-31 16:43:21.098446543 -0700
@@ -156,7 +156,8 @@ struct netidblk {
 };
 
 static int	znet_open(struct net_device *dev);
-static int	znet_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t znet_send_packet(struct sk_buff *skb,
+				    struct net_device *dev);
 static irqreturn_t znet_interrupt(int irq, void *dev_id);
 static void	znet_rx(struct net_device *dev);
 static int	znet_close(struct net_device *dev);
@@ -534,7 +535,7 @@ static void znet_tx_timeout (struct net_
 	netif_wake_queue (dev);
 }
 
-static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
 	struct znet_private *znet = netdev_priv(dev);
--- a/drivers/net/enc28j60.c	2009-08-31 16:17:51.941091292 -0700
+++ b/drivers/net/enc28j60.c	2009-08-31 16:39:43.914413236 -0700
@@ -1276,7 +1276,8 @@ static void enc28j60_hw_tx(struct enc28j
 	locked_reg_bfset(priv, ECON1, ECON1_TXRTS);
 }
 
-static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t enc28j60_send_packet(struct sk_buff *skb,
+					struct net_device *dev)
 {
 	struct enc28j60_net *priv = netdev_priv(dev);
 
--- a/drivers/net/eth16i.c	2009-08-31 16:17:51.711090054 -0700
+++ b/drivers/net/eth16i.c	2009-08-31 16:36:24.791088913 -0700
@@ -405,7 +405,7 @@ static int     eth16i_read_eeprom_word(i
 static void    eth16i_eeprom_cmd(int ioaddr, unsigned char command);
 static int     eth16i_open(struct net_device *dev);
 static int     eth16i_close(struct net_device *dev);
-static int     eth16i_tx(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t eth16i_tx(struct sk_buff *skb, struct net_device *dev);
 static void    eth16i_rx(struct net_device *dev);
 static void    eth16i_timeout(struct net_device *dev);
 static irqreturn_t eth16i_interrupt(int irq, void *dev_id);
@@ -1053,7 +1053,7 @@ static void eth16i_timeout(struct net_de
 	netif_wake_queue(dev);
 }
 
-static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
--- a/drivers/net/ni52.c	2009-08-31 16:17:51.631107610 -0700
+++ b/drivers/net/ni52.c	2009-08-31 16:42:53.626442768 -0700
@@ -170,7 +170,7 @@ static int     ni52_probe1(struct net_de
 static irqreturn_t ni52_interrupt(int irq, void *dev_id);
 static int     ni52_open(struct net_device *dev);
 static int     ni52_close(struct net_device *dev);
-static int     ni52_send_packet(struct sk_buff *, struct net_device *);
+static netdev_tx_t ni52_send_packet(struct sk_buff *, struct net_device *);
 static struct  net_device_stats *ni52_get_stats(struct net_device *dev);
 static void    set_multicast_list(struct net_device *dev);
 static void    ni52_timeout(struct net_device *dev);
@@ -1173,7 +1173,8 @@ static void ni52_timeout(struct net_devi
  * send frame
  */
 
-static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ni52_send_packet(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	int len, i;
 #ifndef NO_NOPCOMMANDS
--- a/drivers/net/ni65.c	2009-08-31 16:17:51.651089690 -0700
+++ b/drivers/net/ni65.c	2009-08-31 16:42:53.242442567 -0700
@@ -252,7 +252,8 @@ static void ni65_xmit_intr(struct net_de
 static int  ni65_open(struct net_device *dev);
 static int  ni65_lance_reinit(struct net_device *dev);
 static void ni65_init_lance(struct priv *p,unsigned char*,int,int);
-static int  ni65_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ni65_send_packet(struct sk_buff *skb,
+				    struct net_device *dev);
 static void  ni65_timeout(struct net_device *dev);
 static int  ni65_close(struct net_device *dev);
 static int  ni65_alloc_buffer(struct net_device *dev);
@@ -1157,7 +1158,8 @@ static void ni65_timeout(struct net_devi
  *	Send a packet
  */
 
-static int ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ni65_send_packet(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct priv *p = dev->ml_priv;
 
--- a/drivers/net/sc92031.c	2009-08-31 16:17:51.841107560 -0700
+++ b/drivers/net/sc92031.c	2009-08-31 16:42:49.781105231 -0700
@@ -941,7 +941,8 @@ static struct net_device_stats *sc92031_
 	return &dev->stats;
 }
 
-static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sc92031_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct sc92031_priv *priv = netdev_priv(dev);
 	void __iomem *port_base = priv->port_base;
--- a/drivers/net/lp486e.c	2009-08-31 16:17:51.881097631 -0700
+++ b/drivers/net/lp486e.c	2009-08-31 16:36:24.791088913 -0700
@@ -377,7 +377,7 @@ static char init_setup[14] = {
 };
 
 static int i596_open(struct net_device *dev);
-static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t i596_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t i596_interrupt(int irq, void *dev_id);
 static int i596_close(struct net_device *dev);
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd);
@@ -863,7 +863,7 @@ static int i596_open(struct net_device *
 	return 0;			/* Always succeed */
 }
 
-static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
+static netdev_tx_t i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
 	struct tx_cmd *tx_cmd;
 	short length;
 

-- 

