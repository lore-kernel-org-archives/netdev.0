From: Jeff Garzik <jeff@garzik.org>
Subject: [git patch] net driver fixes for .26
Date: Thu, 22 May 2008 15:10:26 -0400
Message-ID: <20080522191026.GA29741@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57551 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbYEVTK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 15:10:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note there is more coming...  several "patches" in my mbox are stuff I
need to dig up from archives in the next day or so.

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upst=
ream-davem

to receive the following updates:

 drivers/net/3c509.c                |    2 +-
 drivers/net/au1000_eth.c           |    7 +-
 drivers/net/bfin_mac.c             |    1 -
 drivers/net/cpmac.c                |  234 +++++++++++++----
 drivers/net/dm9000.c               |    2 +-
 drivers/net/e1000e/netdev.c        |    4 +-
 drivers/net/ehea/ehea_main.c       |    5 +-
 drivers/net/forcedeth.c            |    1 +
 drivers/net/fs_enet/fs_enet-main.c |    2 +-
 drivers/net/hamradio/scc.c         |    3 +-
 drivers/net/myri10ge/myri10ge.c    |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c    |    4 +-
 drivers/net/pcmcia/xirc2ps_cs.c    |   12 +-
 drivers/net/pcnet32.c              |    4 +-
 drivers/net/phy/Kconfig            |    2 +-
 drivers/net/phy/phy_device.c       |    1 +
 drivers/net/s2io-regs.h            |    2 +-
 drivers/net/s2io.c                 |  494 +++++++++++++++++++++-------=
--------
 drivers/net/s2io.h                 |   22 +-
 drivers/net/sb1250-mac.c           |   67 +++---
 drivers/net/sc92031.c              |    8 +-
 drivers/net/sfc/bitfield.h         |    7 +-
 drivers/net/sfc/boards.c           |    9 +-
 drivers/net/sfc/efx.c              |   84 +++----
 drivers/net/sfc/falcon.c           |   87 +++----
 drivers/net/sfc/falcon.h           |    5 +-
 drivers/net/sfc/falcon_hwdefs.h    |    4 +-
 drivers/net/sfc/falcon_io.h        |   29 ++-
 drivers/net/sfc/falcon_xmac.c      |   10 +-
 drivers/net/sfc/net_driver.h       |   44 ++--
 drivers/net/sfc/rx.c               |   48 ++--
 drivers/net/sfc/selftest.c         |   14 +-
 drivers/net/sfc/sfe4001.c          |   14 +-
 drivers/net/sfc/tenxpress.c        |    4 +-
 drivers/net/sfc/tx.c               |   11 +-
 drivers/net/sfc/workarounds.h      |    2 +-
 drivers/net/sfc/xfp_phy.c          |    4 +-
 drivers/net/sky2.c                 |   29 ++-
 drivers/net/tokenring/3c359.h      |    2 +-
 drivers/net/tokenring/olympic.h    |    2 +-
 drivers/net/tulip/uli526x.c        |   16 +-
 drivers/net/ucc_geth.c             |    9 +-
 drivers/net/usb/asix.c             |    4 +
 drivers/net/usb/rndis_host.c       |    2 +-
 drivers/net/virtio_net.c           |    3 +-
 drivers/net/wan/hdlc.c             |   19 +-
 drivers/net/wan/hdlc_cisco.c       |   82 ++++---
 drivers/net/xen-netfront.c         |    6 +-
 48 files changed, 853 insertions(+), 576 deletions(-)

Adrian Bunk (1):
      make myri10ge_get_firmware_capabilities() static

Andrew Morton (4):
      [netdrvr] dm9000: use delayed work to update mii phy state fix
      pcnet32: fix warning
      drivers/net/tokenring/3c359.c: squish a warning
      drivers/net/tokenring/olympic.c: fix warning

Andy Fleming (1):
      ucc_geth: Fix arguments to dma map/unmap functions

Anton Vorontsov (1):
      uli526x: add support for netpoll

Aurelien Nephtali (1):
      net/usb: add support for Apple USB Ethernet Adapter

Becky Bruce (1):
      e1000e: use resource_size_t, not unsigned long, for phys addrs

Ben Hutchings (16):
      sfc: Use mod_timer() to set expiry and add_timer() together
      sfc: Removed casts to void
      sfc: Simplified efx_rx_calc_buffer_size() using get_order()
      sfc: Removed unncesssary UL suffixes on 0 literals
      sfc: Added and removed braces to comply with kernel style
      sfc: Replaced various macros with inline functions
      sfc: Merged efx_page_offset() into efx_rx_buf_offset()
      sfc: Use resource_size_t for PCI bus address
      sfc: Correct and expand some comments
      sfc: Use DMA_BIT_MASK() instead of our own DMA mask macros
      sfc: Do not define inline macro
      sfc: Use __packed macro
      sfc: Change type of efx_nic::nic_data to struct falcon_nic_data *
      sfc: Remove redundant casts to and from void *
      sfc: Added checks for heap allocation failure
      sfc: Remove sub-minor component from driver version

Brian King (1):
      ehea: Fix use after free on reboot

=46rancois Romieu (1):
      au1000_eth: remove useless check

Gerrit Renker (1):
      [SC92031] Using padto turned driver into an IPv6-only interface

Huang Weiyi (1):
      Blackfin EMAC Driver: Removed duplicated include <linux/ethtool.h=
>

Ilpo J=E4rvinen (2):
      hamradio/scc: add missing block braces to multi-statement if
      s2io: add missing block braces to multistatement if statement

Joe Perches (1):
      drivers/net/ehea - remove unnecessary memset after kzalloc

Julia Lawall (1):
      drivers/net/fs_enet: remove null pointer dereference

Komuro (2):
      xirc2ps_cs: re-initialize the multicast address in do_reset
      fmvj18x_cs: add NextCom NC5310 rev B support

Krzysztof Halasa (2):
      WAN: protect Cisco HDLC state changes with a spinlock.
      WAN: protect HDLC proto list while insmod/rmmod

Maciej W. Rozycki (1):
      PHYLIB: Kconfig: Fix the dependency on S390

Matteo Croce (1):
      cpmac bugfixes and enhancements

Paul Gortmaker (1):
      phylib: do EXPORT_SYMBOL on get_phy_id

Pierre Ynard (1):
      rndis_host: increase delay in command response loop

Sreenivasa Honnur (3):
      S2io: Move all the transmit completions to a single msi-x (alarm)=
 vector
      S2io: Added napi support when MSIX is enabled.
      S2io: Version update for napi and MSI-X patches

Stephen Hemminger (2):
      sky2: restore vlan acceleration on reset
      sb1250: use netdev_alloc_skb

Tobias Diedrich (1):
      [netdrvr] forcedeth: Restore multicast settings on resume

Wang Chen (3):
      VIRTIO: Use __skb_queue_purge()
      NETFRONT: Use __skb_queue_purge()
      3C509: rx_bytes should not be increased when alloc_skb failed

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index e6c545f..fe6d841 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -1063,7 +1063,6 @@ el3_rx(struct net_device *dev)
 			struct sk_buff *skb;
=20
 			skb =3D dev_alloc_skb(pkt_len+5);
-			dev->stats.rx_bytes +=3D pkt_len;
 			if (el3_debug > 4)
 				printk("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
@@ -1078,6 +1077,7 @@ el3_rx(struct net_device *dev)
 				skb->protocol =3D eth_type_trans(skb,dev);
 				netif_rx(skb);
 				dev->last_rx =3D jiffies;
+				dev->stats.rx_bytes +=3D pkt_len;
 				dev->stats.rx_packets++;
 				continue;
 			}
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 3634b5f..7023d77 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1239,12 +1239,7 @@ static int au1000_rx(struct net_device *dev)
  */
 static irqreturn_t au1000_interrupt(int irq, void *dev_id)
 {
-	struct net_device *dev =3D (struct net_device *) dev_id;
-
-	if (dev =3D=3D NULL) {
-		printk(KERN_ERR "%s: isr: null dev ptr\n", dev->name);
-		return IRQ_RETVAL(1);
-	}
+	struct net_device *dev =3D dev_id;
=20
 	/* Handle RX interrupts first to minimize chance of overrun */
=20
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 89c0018..4144343 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -22,7 +22,6 @@
 #include <linux/crc32.h>
 #include <linux/device.h>
 #include <linux/spinlock.h>
-#include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 2b5740b..7f3f62e 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -38,6 +38,7 @@
 #include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
 #include <asm/gpio.h>
+#include <asm/atomic.h>
=20
 MODULE_AUTHOR("Eugene Konev <ejka@imfi.kspu.ru>");
 MODULE_DESCRIPTION("TI AR7 ethernet driver (CPMAC)");
@@ -187,6 +188,7 @@ struct cpmac_desc {
 #define CPMAC_EOQ			0x1000
 	struct sk_buff *skb;
 	struct cpmac_desc *next;
+	struct cpmac_desc *prev;
 	dma_addr_t mapping;
 	dma_addr_t data_mapping;
 };
@@ -208,6 +210,7 @@ struct cpmac_priv {
 	struct work_struct reset_work;
 	struct platform_device *pdev;
 	struct napi_struct napi;
+	atomic_t reset_pending;
 };
=20
 static irqreturn_t cpmac_irq(int, void *);
@@ -241,6 +244,16 @@ static void cpmac_dump_desc(struct net_device *dev=
, struct cpmac_desc *desc)
 	printk("\n");
 }
=20
+static void cpmac_dump_all_desc(struct net_device *dev)
+{
+	struct cpmac_priv *priv =3D netdev_priv(dev);
+	struct cpmac_desc *dump =3D priv->rx_head;
+	do {
+		cpmac_dump_desc(dev, dump);
+		dump =3D dump->next;
+	} while (dump !=3D priv->rx_head);
+}
+
 static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb=
)
 {
 	int i;
@@ -412,21 +425,42 @@ static struct sk_buff *cpmac_rx_one(struct cpmac_=
priv *priv,
 static int cpmac_poll(struct napi_struct *napi, int budget)
 {
 	struct sk_buff *skb;
-	struct cpmac_desc *desc;
-	int received =3D 0;
+	struct cpmac_desc *desc, *restart;
 	struct cpmac_priv *priv =3D container_of(napi, struct cpmac_priv, nap=
i);
+	int received =3D 0, processed =3D 0;
=20
 	spin_lock(&priv->rx_lock);
 	if (unlikely(!priv->rx_head)) {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING "%s: rx: polling, but no queue\n",
 			       priv->dev->name);
+		spin_unlock(&priv->rx_lock);
 		netif_rx_complete(priv->dev, napi);
 		return 0;
 	}
=20
 	desc =3D priv->rx_head;
+	restart =3D NULL;
 	while (((desc->dataflags & CPMAC_OWN) =3D=3D 0) && (received < budget=
)) {
+		processed++;
+
+		if ((desc->dataflags & CPMAC_EOQ) !=3D 0) {
+			/* The last update to eoq->hw_next didn't happen
+			* soon enough, and the receiver stopped here.
+			*Remember this descriptor so we can restart
+			* the receiver after freeing some space.
+			*/
+			if (unlikely(restart)) {
+				if (netif_msg_rx_err(priv))
+					printk(KERN_ERR "%s: poll found a"
+						" duplicate EOQ: %p and %p\n",
+						priv->dev->name, restart, desc);
+				goto fatal_error;
+			}
+
+			restart =3D desc->next;
+		}
+
 		skb =3D cpmac_rx_one(priv, desc);
 		if (likely(skb)) {
 			netif_receive_skb(skb);
@@ -435,19 +469,90 @@ static int cpmac_poll(struct napi_struct *napi, i=
nt budget)
 		desc =3D desc->next;
 	}
=20
+	if (desc !=3D priv->rx_head) {
+		/* We freed some buffers, but not the whole ring,
+		 * add what we did free to the rx list */
+		desc->prev->hw_next =3D (u32)0;
+		priv->rx_head->prev->hw_next =3D priv->rx_head->mapping;
+	}
+
+	/* Optimization: If we did not actually process an EOQ (perhaps becau=
se
+	 * of quota limits), check to see if the tail of the queue has EOQ se=
t.
+	* We should immediately restart in that case so that the receiver can
+	* restart and run in parallel with more packet processing.
+	* This lets us handle slightly larger bursts before running
+	* out of ring space (assuming dev->weight < ring_size) */
+
+	if (!restart &&
+	     (priv->rx_head->prev->dataflags & (CPMAC_OWN|CPMAC_EOQ))
+		    =3D=3D CPMAC_EOQ &&
+	     (priv->rx_head->dataflags & CPMAC_OWN) !=3D 0) {
+		/* reset EOQ so the poll loop (above) doesn't try to
+		* restart this when it eventually gets to this descriptor.
+		*/
+		priv->rx_head->prev->dataflags &=3D ~CPMAC_EOQ;
+		restart =3D priv->rx_head;
+	}
+
+	if (restart) {
+		priv->dev->stats.rx_errors++;
+		priv->dev->stats.rx_fifo_errors++;
+		if (netif_msg_rx_err(priv) && net_ratelimit())
+			printk(KERN_WARNING "%s: rx dma ring overrun\n",
+			       priv->dev->name);
+
+		if (unlikely((restart->dataflags & CPMAC_OWN) =3D=3D 0)) {
+			if (netif_msg_drv(priv))
+				printk(KERN_ERR "%s: cpmac_poll is trying to "
+					"restart rx from a descriptor that's "
+					"not free: %p\n",
+					priv->dev->name, restart);
+				goto fatal_error;
+		}
+
+		cpmac_write(priv->regs, CPMAC_RX_PTR(0), restart->mapping);
+	}
+
 	priv->rx_head =3D desc;
 	spin_unlock(&priv->rx_lock);
 	if (unlikely(netif_msg_rx_status(priv)))
 		printk(KERN_DEBUG "%s: poll processed %d packets\n",
 		       priv->dev->name, received);
-	if (desc->dataflags & CPMAC_OWN) {
+	if (processed =3D=3D 0) {
+		/* we ran out of packets to read,
+		 * revert to interrupt-driven mode */
 		netif_rx_complete(priv->dev, napi);
-		cpmac_write(priv->regs, CPMAC_RX_PTR(0), (u32)desc->mapping);
 		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
 		return 0;
 	}
=20
 	return 1;
+
+fatal_error:
+	/* Something went horribly wrong.
+	 * Reset hardware to try to recover rather than wedging. */
+
+	if (netif_msg_drv(priv)) {
+		printk(KERN_ERR "%s: cpmac_poll is confused. "
+				"Resetting hardware\n", priv->dev->name);
+		cpmac_dump_all_desc(priv->dev);
+		printk(KERN_DEBUG "%s: RX_PTR(0)=3D0x%08x RX_ACK(0)=3D0x%08x\n",
+			priv->dev->name,
+			cpmac_read(priv->regs, CPMAC_RX_PTR(0)),
+			cpmac_read(priv->regs, CPMAC_RX_ACK(0)));
+	}
+
+	spin_unlock(&priv->rx_lock);
+	netif_rx_complete(priv->dev, napi);
+	netif_stop_queue(priv->dev);
+	napi_disable(&priv->napi);
+
+	atomic_inc(&priv->reset_pending);
+	cpmac_hw_stop(priv->dev);
+	if (!schedule_work(&priv->reset_work))
+		atomic_dec(&priv->reset_pending);
+	return 0;
+
 }
=20
 static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *de=
v)
@@ -456,6 +561,9 @@ static int cpmac_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev)
 	struct cpmac_desc *desc;
 	struct cpmac_priv *priv =3D netdev_priv(dev);
=20
+	if (unlikely(atomic_read(&priv->reset_pending)))
+		return NETDEV_TX_BUSY;
+
 	if (unlikely(skb_padto(skb, ETH_ZLEN)))
 		return NETDEV_TX_OK;
=20
@@ -621,8 +729,10 @@ static void cpmac_clear_rx(struct net_device *dev)
 			desc->dataflags =3D CPMAC_OWN;
 			dev->stats.rx_dropped++;
 		}
+		desc->hw_next =3D desc->next->mapping;
 		desc =3D desc->next;
 	}
+	priv->rx_head->prev->hw_next =3D 0;
 }
=20
 static void cpmac_clear_tx(struct net_device *dev)
@@ -635,14 +745,14 @@ static void cpmac_clear_tx(struct net_device *dev=
)
 		priv->desc_ring[i].dataflags =3D 0;
 		if (priv->desc_ring[i].skb) {
 			dev_kfree_skb_any(priv->desc_ring[i].skb);
-			if (netif_subqueue_stopped(dev, i))
-			    netif_wake_subqueue(dev, i);
+			priv->desc_ring[i].skb =3D NULL;
 		}
 	}
 }
=20
 static void cpmac_hw_error(struct work_struct *work)
 {
+	int i;
 	struct cpmac_priv *priv =3D
 		container_of(work, struct cpmac_priv, reset_work);
=20
@@ -651,8 +761,48 @@ static void cpmac_hw_error(struct work_struct *wor=
k)
 	spin_unlock(&priv->rx_lock);
 	cpmac_clear_tx(priv->dev);
 	cpmac_hw_start(priv->dev);
-	napi_enable(&priv->napi);
-	netif_start_queue(priv->dev);
+	barrier();
+	atomic_dec(&priv->reset_pending);
+
+	for (i =3D 0; i < CPMAC_QUEUES; i++)
+		netif_wake_subqueue(priv->dev, i);
+	netif_wake_queue(priv->dev);
+	cpmac_write(priv->regs, CPMAC_MAC_INT_ENABLE, 3);
+}
+
+static void cpmac_check_status(struct net_device *dev)
+{
+	struct cpmac_priv *priv =3D netdev_priv(dev);
+
+	u32 macstatus =3D cpmac_read(priv->regs, CPMAC_MAC_STATUS);
+	int rx_channel =3D (macstatus >> 8) & 7;
+	int rx_code =3D (macstatus >> 12) & 15;
+	int tx_channel =3D (macstatus >> 16) & 7;
+	int tx_code =3D (macstatus >> 20) & 15;
+
+	if (rx_code || tx_code) {
+		if (netif_msg_drv(priv) && net_ratelimit()) {
+			/* Can't find any documentation on what these
+			 *error codes actually are. So just log them and hope..
+			 */
+			if (rx_code)
+				printk(KERN_WARNING "%s: host error %d on rx "
+				     "channel %d (macstatus %08x), resetting\n",
+				     dev->name, rx_code, rx_channel, macstatus);
+			if (tx_code)
+				printk(KERN_WARNING "%s: host error %d on tx "
+				     "channel %d (macstatus %08x), resetting\n",
+				     dev->name, tx_code, tx_channel, macstatus);
+		}
+
+		netif_stop_queue(dev);
+		cpmac_hw_stop(dev);
+		if (schedule_work(&priv->reset_work))
+			atomic_inc(&priv->reset_pending);
+		if (unlikely(netif_msg_hw(priv)))
+			cpmac_dump_regs(dev);
+	}
+	cpmac_write(priv->regs, CPMAC_MAC_INT_CLEAR, 0xff);
 }
=20
 static irqreturn_t cpmac_irq(int irq, void *dev_id)
@@ -683,49 +833,32 @@ static irqreturn_t cpmac_irq(int irq, void *dev_i=
d)
=20
 	cpmac_write(priv->regs, CPMAC_MAC_EOI_VECTOR, 0);
=20
-	if (unlikely(status & (MAC_INT_HOST | MAC_INT_STATUS))) {
-		if (netif_msg_drv(priv) && net_ratelimit())
-			printk(KERN_ERR "%s: hw error, resetting...\n",
-			       dev->name);
-		netif_stop_queue(dev);
-		napi_disable(&priv->napi);
-		cpmac_hw_stop(dev);
-		schedule_work(&priv->reset_work);
-		if (unlikely(netif_msg_hw(priv)))
-			cpmac_dump_regs(dev);
-	}
+	if (unlikely(status & (MAC_INT_HOST | MAC_INT_STATUS)))
+		cpmac_check_status(dev);
=20
 	return IRQ_HANDLED;
 }
=20
 static void cpmac_tx_timeout(struct net_device *dev)
 {
-	struct cpmac_priv *priv =3D netdev_priv(dev);
 	int i;
+	struct cpmac_priv *priv =3D netdev_priv(dev);
=20
 	spin_lock(&priv->lock);
 	dev->stats.tx_errors++;
 	spin_unlock(&priv->lock);
 	if (netif_msg_tx_err(priv) && net_ratelimit())
 		printk(KERN_WARNING "%s: transmit timeout\n", dev->name);
-	/*=20
-	 * FIXME: waking up random queue is not the best thing to
-	 * do... on the other hand why we got here at all?
-	 */
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+
+	atomic_inc(&priv->reset_pending);
+	barrier();
+	cpmac_clear_tx(dev);
+	barrier();
+	atomic_dec(&priv->reset_pending);
+
+	netif_wake_queue(priv->dev);
 	for (i =3D 0; i < CPMAC_QUEUES; i++)
-		if (priv->desc_ring[i].skb) {
-			priv->desc_ring[i].dataflags =3D 0;
-			dev_kfree_skb_any(priv->desc_ring[i].skb);
-			netif_wake_subqueue(dev, i);
-			break;
-		}
-#else
-	priv->desc_ring[0].dataflags =3D 0;
-	if (priv->desc_ring[0].skb)
-		dev_kfree_skb_any(priv->desc_ring[0].skb);
-	netif_wake_queue(dev);
-#endif
+		netif_wake_subqueue(dev, i);
 }
=20
 static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int =
cmd)
@@ -901,9 +1034,12 @@ static int cpmac_open(struct net_device *dev)
 		desc->buflen =3D CPMAC_SKB_SIZE;
 		desc->dataflags =3D CPMAC_OWN;
 		desc->next =3D &priv->rx_head[(i + 1) % priv->ring_size];
+		desc->next->prev =3D desc;
 		desc->hw_next =3D (u32)desc->next->mapping;
 	}
=20
+	priv->rx_head->prev->hw_next =3D (u32)0;
+
 	if ((res =3D request_irq(dev->irq, cpmac_irq, IRQF_SHARED,
 			       dev->name, dev))) {
 		if (netif_msg_drv(priv))
@@ -912,6 +1048,7 @@ static int cpmac_open(struct net_device *dev)
 		goto fail_irq;
 	}
=20
+	atomic_set(&priv->reset_pending, 0);
 	INIT_WORK(&priv->reset_work, cpmac_hw_error);
 	cpmac_hw_start(dev);
=20
@@ -1007,21 +1144,10 @@ static int __devinit cpmac_probe(struct platfor=
m_device *pdev)
=20
 	if (phy_id =3D=3D PHY_MAX_ADDR) {
 		if (external_switch || dumb_switch) {
-			struct fixed_phy_status status =3D {};
-
-			/*
-			 * FIXME: this should be in the platform code!
-			 * Since there is not platform code at all (that is,
-			 * no mainline users of that driver), place it here
-			 * for now.
-			 */
-			phy_id =3D 0;
-			status.link =3D 1;
-			status.duplex =3D 1;
-			status.speed =3D 100;
-			fixed_phy_add(PHY_POLL, phy_id, &status);
+			mdio_bus_id =3D 0; /* fixed phys bus */
+			phy_id =3D pdev->id;
 		} else {
-			printk(KERN_ERR "cpmac: no PHY present\n");
+			dev_err(&pdev->dev, "no PHY present\n");
 			return -ENODEV;
 		}
 	}
@@ -1064,10 +1190,8 @@ static int __devinit cpmac_probe(struct platform=
_device *pdev)
 	priv->msg_enable =3D netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
=20
-	snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id=
);
-
-	priv->phy =3D phy_connect(dev, priv->phy_name, &cpmac_adjust_link, 0,
-				PHY_INTERFACE_MODE_MII);
+	priv->phy =3D phy_connect(dev, cpmac_mii.phy_map[phy_id]->dev.bus_id,
+				&cpmac_adjust_link, 0, PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(priv->phy)) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR "%s: Could not attach to PHY\n",
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index d45bcd2..864295e 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -903,7 +903,7 @@ dm9000_stop(struct net_device *ndev)
 	if (netif_msg_ifdown(db))
 		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
=20
-	cancel_delayed_work(&db->phy_poll);
+	cancel_delayed_work_sync(&db->phy_poll);
=20
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8cbb40f..cab1835 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4201,8 +4201,8 @@ static int __devinit e1000_probe(struct pci_dev *=
pdev,
 	struct e1000_adapter *adapter;
 	struct e1000_hw *hw;
 	const struct e1000_info *ei =3D e1000_info_tbl[ent->driver_data];
-	unsigned long mmio_start, mmio_len;
-	unsigned long flash_start, flash_len;
+	resource_size_t mmio_start, mmio_len;
+	resource_size_t flash_start, flash_len;
=20
 	static int cards_found;
 	int i, err, pci_using_dac;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.=
c
index d1b6d4e..287a619 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2213,8 +2213,6 @@ static void ehea_vlan_rx_register(struct net_devi=
ce *dev,
 		goto out;
 	}
=20
-	memset(cb1->vlan_filter, 0, sizeof(cb1->vlan_filter));
-
 	hret =3D ehea_h_modify_ehea_port(adapter->handle, port->logical_port_=
id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
 	if (hret !=3D H_SUCCESS)
@@ -3178,11 +3176,12 @@ out_err:
=20
 static void ehea_shutdown_single_port(struct ehea_port *port)
 {
+	struct ehea_adapter *adapter =3D port->adapter;
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
 	kfree(port->mc_list);
 	free_netdev(port->netdev);
-	port->adapter->active_ports--;
+	adapter->active_ports--;
 }
=20
 static int ehea_setup_ports(struct ehea_adapter *adapter)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 35f66d4..9eca97f 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5823,6 +5823,7 @@ static int nv_resume(struct pci_dev *pdev)
 	writel(txreg, base + NvRegTransmitPoll);
=20
 	rc =3D nv_open(dev);
+	nv_set_multicast(dev);
 out:
 	return rc;
 }
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/f=
s_enet-main.c
index 67b4b07..a5baaf5 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1093,7 +1093,7 @@ err:
 		if (registered)
 			unregister_netdev(ndev);
=20
-		if (fep !=3D NULL) {
+		if (fep && fep->ops) {
 			(*fep->ops->free_bd)(ndev);
 			(*fep->ops->cleanup_data)(ndev);
 		}
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index f905159..45ae9d1 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1340,9 +1340,10 @@ static unsigned int scc_set_param(struct scc_cha=
nnel *scc, unsigned int cmd, uns
 		case PARAM_RTS:=09
 			if ( !(scc->wreg[R5] & RTS) )
 			{
-				if (arg !=3D TX_OFF)
+				if (arg !=3D TX_OFF) {
 					scc_key_trx(scc, TX_ON);
 					scc_start_tx_timer(scc, t_txdelay, scc->kiss.txdelay);
+				}
 			} else {
 				if (arg =3D=3D TX_OFF)
 				{
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index c91b12e..36be6ef 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -631,7 +631,7 @@ static int myri10ge_adopt_running_firmware(struct m=
yri10ge_priv *mgp)
 	return status;
 }
=20
-int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mgp)
+static int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mg=
p)
 {
 	struct myri10ge_cmd cmd;
 	int status;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj1=
8x_cs.c
index 8f328a0..a550c9b 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -391,7 +391,9 @@ static int fmvj18x_config(struct pcmcia_device *lin=
k)
 	    cardtype =3D CONTEC;
 	    break;
 	case MANFID_FUJITSU:
-	    if (link->card_id =3D=3D PRODID_FUJITSU_MBH10302)
+	    if (link->conf.ConfigBase =3D=3D 0x0fe0)
+		cardtype =3D MBH10302;
+	    else if (link->card_id =3D=3D PRODID_FUJITSU_MBH10302)=20
                 /* RATOC REX-5588/9822/4886's PRODID are 0004(=3DMBH10=
302),
                    but these are MBH10304 based card. */=20
 		cardtype =3D MBH10304;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2=
ps_cs.c
index d041f83..f6c4698 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1461,22 +1461,25 @@ static void
 set_multicast_list(struct net_device *dev)
 {
     unsigned int ioaddr =3D dev->base_addr;
+    unsigned value;
=20
     SelectPage(0x42);
+    value =3D GetByte(XIRCREG42_SWC1) & 0xC0;
+
     if (dev->flags & IFF_PROMISC) { /* snoop */
-	PutByte(XIRCREG42_SWC1, 0x06); /* set MPE and PME */
+	PutByte(XIRCREG42_SWC1, value | 0x06); /* set MPE and PME */
     } else if (dev->mc_count > 9 || (dev->flags & IFF_ALLMULTI)) {
-	PutByte(XIRCREG42_SWC1, 0x02); /* set MPE */
+	PutByte(XIRCREG42_SWC1, value | 0x02); /* set MPE */
     } else if (dev->mc_count) {
 	/* the chip can filter 9 addresses perfectly */
-	PutByte(XIRCREG42_SWC1, 0x01);
+	PutByte(XIRCREG42_SWC1, value | 0x01);
 	SelectPage(0x40);
 	PutByte(XIRCREG40_CMD0, Offline);
 	set_addresses(dev);
 	SelectPage(0x40);
 	PutByte(XIRCREG40_CMD0, EnableRecv | Online);
     } else { /* standard usage */
-	PutByte(XIRCREG42_SWC1, 0x00);
+	PutByte(XIRCREG42_SWC1, value | 0x00);
     }
     SelectPage(0);
 }
@@ -1722,6 +1725,7 @@ do_reset(struct net_device *dev, int full)
=20
     /* enable receiver and put the mac online */
     if (full) {
+	set_multicast_list(dev);
 	SelectPage(0x40);
 	PutByte(XIRCREG40_CMD0, EnableRecv | Online);
     }
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index a1c454d..1c89b97 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -325,7 +325,7 @@ static int pcnet32_get_regs_len(struct net_device *=
dev);
 static void pcnet32_get_regs(struct net_device *dev, struct ethtool_re=
gs *regs,
 			     void *ptr);
 static void pcnet32_purge_tx_ring(struct net_device *dev);
-static int pcnet32_alloc_ring(struct net_device *dev, char *name);
+static int pcnet32_alloc_ring(struct net_device *dev, const char *name=
);
 static void pcnet32_free_ring(struct net_device *dev);
 static void pcnet32_check_media(struct net_device *dev, int verbose);
=20
@@ -1983,7 +1983,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, =
struct pci_dev *pdev)
 }
=20
 /* if any allocation fails, caller must also call pcnet32_free_ring */
-static int pcnet32_alloc_ring(struct net_device *dev, char *name)
+static int pcnet32_alloc_ring(struct net_device *dev, const char *name=
)
 {
 	struct pcnet32_private *lp =3D netdev_priv(dev);
=20
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6bf9e76..6eb2d31 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -5,7 +5,7 @@
 menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
 	depends on !S390
-	depends on NET_ETHERNET && (BROKEN || !S390)
+	depends on NET_ETHERNET
 	help
 	  Ethernet controllers are usually attached to PHY
 	  devices.  This option provides infrastructure for
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.=
c
index ac3c01d..16a0e7d 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -207,6 +207,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 *=
phy_id)
=20
 	return 0;
 }
+EXPORT_SYMBOL(get_phy_id);
=20
 /**
  * get_phy_device - reads the specified PHY device and returns its @ph=
y_device struct
diff --git a/drivers/net/s2io-regs.h b/drivers/net/s2io-regs.h
index 2109508..f8274f8 100644
--- a/drivers/net/s2io-regs.h
+++ b/drivers/net/s2io-regs.h
@@ -250,7 +250,7 @@ struct XENA_dev_config {
 	u64 tx_mat0_n[0x8];
 #define TX_MAT_SET(fifo, msi)			vBIT(msi, (8 * fifo), 8)
=20
-	u8 unused_1[0x8];
+	u64 xmsi_mask_reg;
 	u64 stat_byte_cnt;
 #define STAT_BC(n)                              vBIT(n,4,12)
=20
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 523478e..a20693e 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
=20
-#define DRV_VERSION "2.0.26.23"
+#define DRV_VERSION "2.0.26.24"
=20
 /* S2io Driver name & version. */
 static char s2io_driver_name[] =3D "Neterion";
@@ -1113,9 +1113,10 @@ static int s2io_on_nec_bridge(struct pci_dev *s2=
io_pdev)
 	struct pci_dev *tdev =3D NULL;
 	while ((tdev =3D pci_get_device(PCI_ANY_ID, PCI_ANY_ID, tdev)) !=3D N=
ULL) {
 		if (tdev->vendor =3D=3D NEC_VENID && tdev->device =3D=3D NEC_DEVID) =
{
-			if (tdev->bus =3D=3D s2io_pdev->bus->parent)
+			if (tdev->bus =3D=3D s2io_pdev->bus->parent) {
 				pci_dev_put(tdev);
 				return 1;
+			}
 		}
 	}
 	return 0;
@@ -1219,15 +1220,33 @@ static int init_tti(struct s2io_nic *nic, int l=
ink)
 				TTI_DATA1_MEM_TX_URNG_B(0x10) |
 				TTI_DATA1_MEM_TX_URNG_C(0x30) |
 				TTI_DATA1_MEM_TX_TIMER_AC_EN;
-
-		if (use_continuous_tx_intrs && (link =3D=3D LINK_UP))
-			val64 |=3D TTI_DATA1_MEM_TX_TIMER_CI_EN;
+		if (i =3D=3D 0)
+			if (use_continuous_tx_intrs && (link =3D=3D LINK_UP))
+				val64 |=3D TTI_DATA1_MEM_TX_TIMER_CI_EN;
 		writeq(val64, &bar0->tti_data1_mem);
=20
-		val64 =3D TTI_DATA2_MEM_TX_UFC_A(0x10) |
-				TTI_DATA2_MEM_TX_UFC_B(0x20) |
-				TTI_DATA2_MEM_TX_UFC_C(0x40) |
-				TTI_DATA2_MEM_TX_UFC_D(0x80);
+		if (nic->config.intr_type =3D=3D MSI_X) {
+			val64 =3D TTI_DATA2_MEM_TX_UFC_A(0x10) |
+				TTI_DATA2_MEM_TX_UFC_B(0x100) |
+				TTI_DATA2_MEM_TX_UFC_C(0x200) |
+				TTI_DATA2_MEM_TX_UFC_D(0x300);
+		} else {
+			if ((nic->config.tx_steering_type =3D=3D
+				TX_DEFAULT_STEERING) &&
+				(config->tx_fifo_num > 1) &&
+				(i >=3D nic->udp_fifo_idx) &&
+				(i < (nic->udp_fifo_idx +
+				nic->total_udp_fifos)))
+				val64 =3D TTI_DATA2_MEM_TX_UFC_A(0x50) |
+					TTI_DATA2_MEM_TX_UFC_B(0x80) |
+					TTI_DATA2_MEM_TX_UFC_C(0x100) |
+					TTI_DATA2_MEM_TX_UFC_D(0x120);
+			else
+				val64 =3D TTI_DATA2_MEM_TX_UFC_A(0x10) |
+					TTI_DATA2_MEM_TX_UFC_B(0x20) |
+					TTI_DATA2_MEM_TX_UFC_C(0x40) |
+					TTI_DATA2_MEM_TX_UFC_D(0x80);
+		}
=20
 		writeq(val64, &bar0->tti_data2_mem);
=20
@@ -2813,6 +2832,15 @@ static void free_rx_buffers(struct s2io_nic *sp)
 	}
 }
=20
+static int s2io_chk_rx_buffers(struct ring_info *ring)
+{
+	if (fill_rx_buffers(ring) =3D=3D -ENOMEM) {
+		DBG_PRINT(INFO_DBG, "%s:Out of memory", ring->dev->name);
+		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
+	}
+	return 0;
+}
+
 /**
  * s2io_poll - Rx interrupt handler for NAPI support
  * @napi : pointer to the napi structure.
@@ -2826,57 +2854,72 @@ static void free_rx_buffers(struct s2io_nic *sp=
)
  * 0 on success and 1 if there are No Rx packets to be processed.
  */
=20
-static int s2io_poll(struct napi_struct *napi, int budget)
+static int s2io_poll_msix(struct napi_struct *napi, int budget)
 {
-	struct s2io_nic *nic =3D container_of(napi, struct s2io_nic, napi);
-	struct net_device *dev =3D nic->dev;
-	int pkt_cnt =3D 0, org_pkts_to_process;
-	struct mac_info *mac_control;
+	struct ring_info *ring =3D container_of(napi, struct ring_info, napi)=
;
+	struct net_device *dev =3D ring->dev;
 	struct config_param *config;
+	struct mac_info *mac_control;
+	int pkts_processed =3D 0;
+	u8 *addr =3D NULL, val8 =3D 0;
+	struct s2io_nic *nic =3D dev->priv;
 	struct XENA_dev_config __iomem *bar0 =3D nic->bar0;
-	int i;
+	int budget_org =3D budget;
=20
-	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
+	mac_control =3D &nic->mac_control;
=20
-	nic->pkts_to_process =3D budget;
-	org_pkts_to_process =3D nic->pkts_to_process;
+	if (unlikely(!is_s2io_card_up(nic)))
+		return 0;
=20
-	writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
-	readl(&bar0->rx_traffic_int);
+	pkts_processed =3D rx_intr_handler(ring, budget);
+	s2io_chk_rx_buffers(ring);
=20
-	for (i =3D 0; i < config->rx_ring_num; i++) {
-		rx_intr_handler(&mac_control->rings[i]);
-		pkt_cnt =3D org_pkts_to_process - nic->pkts_to_process;
-		if (!nic->pkts_to_process) {
-			/* Quota for the current iteration has been met */
-			goto no_rx;
-		}
+	if (pkts_processed < budget_org) {
+		netif_rx_complete(dev, napi);
+		/*Re Enable MSI-Rx Vector*/
+		addr =3D (u8 *)&bar0->xmsi_mask_reg;
+		addr +=3D 7 - ring->ring_no;
+		val8 =3D (ring->ring_no =3D=3D 0) ? 0x3f : 0xbf;
+		writeb(val8, addr);
+		val8 =3D readb(addr);
 	}
+	return pkts_processed;
+}
+static int s2io_poll_inta(struct napi_struct *napi, int budget)
+{
+	struct s2io_nic *nic =3D container_of(napi, struct s2io_nic, napi);
+	struct ring_info *ring;
+	struct net_device *dev =3D nic->dev;
+	struct config_param *config;
+	struct mac_info *mac_control;
+	int pkts_processed =3D 0;
+	int ring_pkts_processed, i;
+	struct XENA_dev_config __iomem *bar0 =3D nic->bar0;
+	int budget_org =3D budget;
=20
-	netif_rx_complete(dev, napi);
+	config =3D &nic->config;
+	mac_control =3D &nic->mac_control;
=20
-	for (i =3D 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(&mac_control->rings[i]) =3D=3D -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
-			break;
-		}
-	}
-	/* Re enable the Rx interrupts. */
-	writeq(0x0, &bar0->rx_traffic_mask);
-	readl(&bar0->rx_traffic_mask);
-	return pkt_cnt;
+	if (unlikely(!is_s2io_card_up(nic)))
+		return 0;
=20
-no_rx:
 	for (i =3D 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(&mac_control->rings[i]) =3D=3D -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
+		ring =3D &mac_control->rings[i];
+		ring_pkts_processed =3D rx_intr_handler(ring, budget);
+		s2io_chk_rx_buffers(ring);
+		pkts_processed +=3D ring_pkts_processed;
+		budget -=3D ring_pkts_processed;
+		if (budget <=3D 0)
 			break;
-		}
 	}
-	return pkt_cnt;
+	if (pkts_processed < budget_org) {
+		netif_rx_complete(dev, napi);
+		/* Re enable the Rx interrupts for the ring */
+		writeq(0, &bar0->rx_traffic_mask);
+		readl(&bar0->rx_traffic_mask);
+	}
+	return pkts_processed;
 }
=20
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2918,7 +2961,7 @@ static void s2io_netpoll(struct net_device *dev)
=20
 	/* check for received packet and indicate up to network */
 	for (i =3D 0; i < config->rx_ring_num; i++)
-		rx_intr_handler(&mac_control->rings[i]);
+		rx_intr_handler(&mac_control->rings[i], 0);
=20
 	for (i =3D 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(&mac_control->rings[i]) =3D=3D -ENOMEM) {
@@ -2934,7 +2977,8 @@ static void s2io_netpoll(struct net_device *dev)
=20
 /**
  *  rx_intr_handler - Rx interrupt handler
- *  @nic: device private variable.
+ *  @ring_info: per ring structure.
+ *  @budget: budget for napi processing.
  *  Description:
  *  If the interrupt is because of a received frame or if the
  *  receive ring contains fresh as yet un-processed frames,this functi=
on is
@@ -2942,15 +2986,15 @@ static void s2io_netpoll(struct net_device *dev=
)
  *  stopped and sends the skb to the OSM's Rx handler and then increme=
nts
  *  the offset.
  *  Return Value:
- *  NONE.
+ *  No. of napi packets processed.
  */
-static void rx_intr_handler(struct ring_info *ring_data)
+static int rx_intr_handler(struct ring_info *ring_data, int budget)
 {
 	int get_block, put_block;
 	struct rx_curr_get_info get_info, put_info;
 	struct RxD_t *rxdp;
 	struct sk_buff *skb;
-	int pkt_cnt =3D 0;
+	int pkt_cnt =3D 0, napi_pkts =3D 0;
 	int i;
 	struct RxD1* rxdp1;
 	struct RxD3* rxdp3;
@@ -2977,7 +3021,7 @@ static void rx_intr_handler(struct ring_info *rin=
g_data)
 			DBG_PRINT(ERR_DBG, "%s: The skb is ",
 				  ring_data->dev->name);
 			DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-			return;
+			return 0;
 		}
 		if (ring_data->rxd_mode =3D=3D RXD_MODE_1) {
 			rxdp1 =3D (struct RxD1*)rxdp;
@@ -3014,9 +3058,10 @@ static void rx_intr_handler(struct ring_info *ri=
ng_data)
 			rxdp =3D ring_data->rx_blocks[get_block].block_virt_addr;
 		}
=20
-		if(ring_data->nic->config.napi){
-			ring_data->nic->pkts_to_process -=3D 1;
-			if (!ring_data->nic->pkts_to_process)
+		if (ring_data->nic->config.napi) {
+			budget--;
+			napi_pkts++;
+			if (!budget)
 				break;
 		}
 		pkt_cnt++;
@@ -3034,6 +3079,7 @@ static void rx_intr_handler(struct ring_info *rin=
g_data)
 			}
 		}
 	}
+	return(napi_pkts);
 }
=20
 /**
@@ -3730,14 +3776,19 @@ static void restore_xmsi_data(struct s2io_nic *=
nic)
 {
 	struct XENA_dev_config __iomem *bar0 =3D nic->bar0;
 	u64 val64;
-	int i;
+	int i, msix_index;
+
+
+	if (nic->device_type =3D=3D XFRAME_I_DEVICE)
+		return;
=20
 	for (i=3D0; i < MAX_REQUESTED_MSI_X; i++) {
+		msix_index =3D (i) ? ((i-1) * 8 + 1): 0;
 		writeq(nic->msix_info[i].addr, &bar0->xmsi_address);
 		writeq(nic->msix_info[i].data, &bar0->xmsi_data);
-		val64 =3D (s2BIT(7) | s2BIT(15) | vBIT(i, 26, 6));
+		val64 =3D (s2BIT(7) | s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
-		if (wait_for_msix_trans(nic, i)) {
+		if (wait_for_msix_trans(nic, msix_index)) {
 			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
 			continue;
 		}
@@ -3748,13 +3799,17 @@ static void store_xmsi_data(struct s2io_nic *ni=
c)
 {
 	struct XENA_dev_config __iomem *bar0 =3D nic->bar0;
 	u64 val64, addr, data;
-	int i;
+	int i, msix_index;
+
+	if (nic->device_type =3D=3D XFRAME_I_DEVICE)
+		return;
=20
 	/* Store and display */
 	for (i=3D0; i < MAX_REQUESTED_MSI_X; i++) {
-		val64 =3D (s2BIT(15) | vBIT(i, 26, 6));
+		msix_index =3D (i) ? ((i-1) * 8 + 1): 0;
+		val64 =3D (s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
-		if (wait_for_msix_trans(nic, i)) {
+		if (wait_for_msix_trans(nic, msix_index)) {
 			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
 			continue;
 		}
@@ -3770,11 +3825,11 @@ static void store_xmsi_data(struct s2io_nic *ni=
c)
 static int s2io_enable_msi_x(struct s2io_nic *nic)
 {
 	struct XENA_dev_config __iomem *bar0 =3D nic->bar0;
-	u64 tx_mat, rx_mat;
+	u64 rx_mat;
 	u16 msi_control; /* Temp variable */
 	int ret, i, j, msix_indx =3D 1;
=20
-	nic->entries =3D kcalloc(MAX_REQUESTED_MSI_X, sizeof(struct msix_entr=
y),
+	nic->entries =3D kmalloc(nic->num_entries * sizeof(struct msix_entry)=
,
 			       GFP_KERNEL);
 	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
@@ -3783,10 +3838,12 @@ static int s2io_enable_msi_x(struct s2io_nic *n=
ic)
 		return -ENOMEM;
 	}
 	nic->mac_control.stats_info->sw_stat.mem_allocated
-		+=3D (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+		+=3D (nic->num_entries * sizeof(struct msix_entry));
+
+	memset(nic->entries, 0, nic->num_entries * sizeof(struct msix_entry))=
;
=20
 	nic->s2io_entries =3D
-		kcalloc(MAX_REQUESTED_MSI_X, sizeof(struct s2io_msix_entry),
+		kmalloc(nic->num_entries * sizeof(struct s2io_msix_entry),
 				   GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
@@ -3794,60 +3851,52 @@ static int s2io_enable_msi_x(struct s2io_nic *n=
ic)
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
-			+=3D (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+			+=3D (nic->num_entries * sizeof(struct msix_entry));
 		return -ENOMEM;
 	}
 	 nic->mac_control.stats_info->sw_stat.mem_allocated
-		+=3D (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
-
-	for (i=3D0; i< MAX_REQUESTED_MSI_X; i++) {
-		nic->entries[i].entry =3D i;
-		nic->s2io_entries[i].entry =3D i;
+		+=3D (nic->num_entries * sizeof(struct s2io_msix_entry));
+	memset(nic->s2io_entries, 0,
+		nic->num_entries * sizeof(struct s2io_msix_entry));
+
+	nic->entries[0].entry =3D 0;
+	nic->s2io_entries[0].entry =3D 0;
+	nic->s2io_entries[0].in_use =3D MSIX_FLG;
+	nic->s2io_entries[0].type =3D MSIX_ALARM_TYPE;
+	nic->s2io_entries[0].arg =3D &nic->mac_control.fifos;
+
+	for (i =3D 1; i < nic->num_entries; i++) {
+		nic->entries[i].entry =3D ((i - 1) * 8) + 1;
+		nic->s2io_entries[i].entry =3D ((i - 1) * 8) + 1;
 		nic->s2io_entries[i].arg =3D NULL;
 		nic->s2io_entries[i].in_use =3D 0;
 	}
=20
-	tx_mat =3D readq(&bar0->tx_mat0_n[0]);
-	for (i=3D0; i<nic->config.tx_fifo_num; i++, msix_indx++) {
-		tx_mat |=3D TX_MAT_SET(i, msix_indx);
-		nic->s2io_entries[msix_indx].arg =3D &nic->mac_control.fifos[i];
-		nic->s2io_entries[msix_indx].type =3D MSIX_FIFO_TYPE;
-		nic->s2io_entries[msix_indx].in_use =3D MSIX_FLG;
-	}
-	writeq(tx_mat, &bar0->tx_mat0_n[0]);
-
 	rx_mat =3D readq(&bar0->rx_mat);
-	for (j =3D 0; j < nic->config.rx_ring_num; j++, msix_indx++) {
+	for (j =3D 0; j < nic->config.rx_ring_num; j++) {
 		rx_mat |=3D RX_MAT_SET(j, msix_indx);
-		nic->s2io_entries[msix_indx].arg
-			=3D &nic->mac_control.rings[j];
-		nic->s2io_entries[msix_indx].type =3D MSIX_RING_TYPE;
-		nic->s2io_entries[msix_indx].in_use =3D MSIX_FLG;
+		nic->s2io_entries[j+1].arg =3D &nic->mac_control.rings[j];
+		nic->s2io_entries[j+1].type =3D MSIX_RING_TYPE;
+		nic->s2io_entries[j+1].in_use =3D MSIX_FLG;
+		msix_indx +=3D 8;
 	}
 	writeq(rx_mat, &bar0->rx_mat);
+	readq(&bar0->rx_mat);
=20
-	nic->avail_msix_vectors =3D 0;
-	ret =3D pci_enable_msix(nic->pdev, nic->entries, MAX_REQUESTED_MSI_X)=
;
+	ret =3D pci_enable_msix(nic->pdev, nic->entries, nic->num_entries);
 	/* We fail init if error or we get less vectors than min required */
-	if (ret >=3D (nic->config.tx_fifo_num + nic->config.rx_ring_num + 1))=
 {
-		nic->avail_msix_vectors =3D ret;
-		ret =3D pci_enable_msix(nic->pdev, nic->entries, ret);
-	}
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Enabling MSIX failed\n", nic->dev->name);
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
-			+=3D (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+			+=3D (nic->num_entries * sizeof(struct msix_entry));
 		kfree(nic->s2io_entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
-		+=3D (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+			+=3D (nic->num_entries * sizeof(struct s2io_msix_entry));
 		nic->entries =3D NULL;
 		nic->s2io_entries =3D NULL;
-		nic->avail_msix_vectors =3D 0;
 		return -ENOMEM;
 	}
-	if (!nic->avail_msix_vectors)
-		nic->avail_msix_vectors =3D MAX_REQUESTED_MSI_X;
=20
 	/*
 	 * To enable MSI-X, MSI also needs to be enabled, due to a bug
@@ -3919,7 +3968,7 @@ static void remove_msix_isr(struct s2io_nic *sp)
 	int i;
 	u16 msi_control;
=20
-	for (i =3D 0; i < MAX_REQUESTED_MSI_X; i++) {
+	for (i =3D 0; i < sp->num_entries; i++) {
 		if (sp->s2io_entries[i].in_use =3D=3D
 			MSIX_REGISTERED_SUCCESS) {
 			int vector =3D sp->entries[i].vector;
@@ -3975,29 +4024,6 @@ static int s2io_open(struct net_device *dev)
 	netif_carrier_off(dev);
 	sp->last_link_state =3D 0;
=20
-	if (sp->config.intr_type =3D=3D MSI_X) {
-		int ret =3D s2io_enable_msi_x(sp);
-
-		if (!ret) {
-			ret =3D s2io_test_msi(sp);
-			/* rollback MSI-X, will re-enable during add_isr() */
-			remove_msix_isr(sp);
-		}
-		if (ret) {
-
-			DBG_PRINT(ERR_DBG,
-			  "%s: MSI-X requested but failed to enable\n",
-			  dev->name);
-			sp->config.intr_type =3D INTA;
-		}
-	}
-
-	/* NAPI doesn't work well with MSI(X) */
-	 if (sp->config.intr_type !=3D INTA) {
-		if(sp->config.napi)
-			sp->config.napi =3D 0;
-	}
-
 	/* Initialize H/W and enable interrupts */
 	err =3D s2io_card_up(sp);
 	if (err) {
@@ -4020,12 +4046,12 @@ hw_init_failed:
 		if (sp->entries) {
 			kfree(sp->entries);
 			sp->mac_control.stats_info->sw_stat.mem_freed
-			+=3D (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+			+=3D (sp->num_entries * sizeof(struct msix_entry));
 		}
 		if (sp->s2io_entries) {
 			kfree(sp->s2io_entries);
 			sp->mac_control.stats_info->sw_stat.mem_freed
-			+=3D (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+			+=3D (sp->num_entries * sizeof(struct s2io_msix_entry));
 		}
 	}
 	return err;
@@ -4327,40 +4353,64 @@ s2io_alarm_handle(unsigned long data)
 	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
 }
=20
-static int s2io_chk_rx_buffers(struct ring_info *ring)
-{
-	if (fill_rx_buffers(ring) =3D=3D -ENOMEM) {
-		DBG_PRINT(INFO_DBG, "%s:Out of memory", ring->dev->name);
-		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
-	}
-	return 0;
-}
-
 static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 {
 	struct ring_info *ring =3D (struct ring_info *)dev_id;
 	struct s2io_nic *sp =3D ring->nic;
+	struct XENA_dev_config __iomem *bar0 =3D sp->bar0;
+	struct net_device *dev =3D sp->dev;
=20
-	if (!is_s2io_card_up(sp))
+	if (unlikely(!is_s2io_card_up(sp)))
 		return IRQ_HANDLED;
=20
-	rx_intr_handler(ring);
-	s2io_chk_rx_buffers(ring);
+	if (sp->config.napi) {
+		u8 *addr =3D NULL, val8 =3D 0;
+
+		addr =3D (u8 *)&bar0->xmsi_mask_reg;
+		addr +=3D (7 - ring->ring_no);
+		val8 =3D (ring->ring_no =3D=3D 0) ? 0x7f : 0xff;
+		writeb(val8, addr);
+		val8 =3D readb(addr);
+		netif_rx_schedule(dev, &ring->napi);
+	} else {
+		rx_intr_handler(ring, 0);
+		s2io_chk_rx_buffers(ring);
+	}
=20
 	return IRQ_HANDLED;
 }
=20
 static irqreturn_t s2io_msix_fifo_handle(int irq, void *dev_id)
 {
-	struct fifo_info *fifo =3D (struct fifo_info *)dev_id;
-	struct s2io_nic *sp =3D fifo->nic;
+	int i;
+	struct fifo_info *fifos =3D (struct fifo_info *)dev_id;
+	struct s2io_nic *sp =3D fifos->nic;
+	struct XENA_dev_config __iomem *bar0 =3D sp->bar0;
+	struct config_param *config  =3D &sp->config;
+	u64 reason;
=20
-	if (!is_s2io_card_up(sp))
+	if (unlikely(!is_s2io_card_up(sp)))
+		return IRQ_NONE;
+
+	reason =3D readq(&bar0->general_int_status);
+	if (unlikely(reason =3D=3D S2IO_MINUS_ONE))
+		/* Nothing much can be done. Get out */
 		return IRQ_HANDLED;
=20
-	tx_intr_handler(fifo);
+	writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
+
+	if (reason & GEN_INTR_TXTRAFFIC)
+		writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
+
+	for (i =3D 0; i < config->tx_fifo_num; i++)
+		tx_intr_handler(&fifos[i]);
+
+	writeq(sp->general_int_mask, &bar0->general_int_mask);
+	readl(&bar0->general_int_status);
+
 	return IRQ_HANDLED;
 }
+
 static void s2io_txpic_intr_handle(struct s2io_nic *sp)
 {
 	struct XENA_dev_config __iomem *bar0 =3D sp->bar0;
@@ -4762,14 +4812,10 @@ static irqreturn_t s2io_isr(int irq, void *dev_=
id)
=20
 		if (config->napi) {
 			if (reason & GEN_INTR_RXTRAFFIC) {
-				if (likely(netif_rx_schedule_prep(dev,
-							&sp->napi))) {
-					__netif_rx_schedule(dev, &sp->napi);
-					writeq(S2IO_MINUS_ONE,
-					       &bar0->rx_traffic_mask);
-				} else
-					writeq(S2IO_MINUS_ONE,
-					       &bar0->rx_traffic_int);
+				netif_rx_schedule(dev, &sp->napi);
+				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
+				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
+				readl(&bar0->rx_traffic_int);
 			}
 		} else {
 			/*
@@ -4781,7 +4827,7 @@ static irqreturn_t s2io_isr(int irq, void *dev_id=
)
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
=20
 			for (i =3D 0; i < config->rx_ring_num; i++)
-				rx_intr_handler(&mac_control->rings[i]);
+				rx_intr_handler(&mac_control->rings[i], 0);
 		}
=20
 		/*
@@ -6984,62 +7030,62 @@ static int s2io_add_isr(struct s2io_nic * sp)
=20
 	/* After proper initialization of H/W, register ISR */
 	if (sp->config.intr_type =3D=3D MSI_X) {
-		int i, msix_tx_cnt=3D0,msix_rx_cnt=3D0;
-
-		for (i=3D1; (sp->s2io_entries[i].in_use =3D=3D MSIX_FLG); i++) {
-			if (sp->s2io_entries[i].type =3D=3D MSIX_FIFO_TYPE) {
-				sprintf(sp->desc[i], "%s:MSI-X-%d-TX",
+		int i, msix_rx_cnt =3D 0;
+
+		for (i =3D 0; i < sp->num_entries; i++) {
+			if (sp->s2io_entries[i].in_use =3D=3D MSIX_FLG) {
+				if (sp->s2io_entries[i].type =3D=3D
+					MSIX_RING_TYPE) {
+					sprintf(sp->desc[i], "%s:MSI-X-%d-RX",
+						dev->name, i);
+					err =3D request_irq(sp->entries[i].vector,
+						s2io_msix_ring_handle, 0,
+						sp->desc[i],
+						sp->s2io_entries[i].arg);
+				} else if (sp->s2io_entries[i].type =3D=3D
+					MSIX_ALARM_TYPE) {
+					sprintf(sp->desc[i], "%s:MSI-X-%d-TX",
 					dev->name, i);
-				err =3D request_irq(sp->entries[i].vector,
-					  s2io_msix_fifo_handle, 0, sp->desc[i],
-						  sp->s2io_entries[i].arg);
-				/* If either data or addr is zero print it */
-				if(!(sp->msix_info[i].addr &&
-					sp->msix_info[i].data)) {
-					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx "
-						"Data:0x%llx\n",sp->desc[i],
-						(unsigned long long)
-						sp->msix_info[i].addr,
-						(unsigned long long)
-						sp->msix_info[i].data);
-				} else {
-					msix_tx_cnt++;
+					err =3D request_irq(sp->entries[i].vector,
+						s2io_msix_fifo_handle, 0,
+						sp->desc[i],
+						sp->s2io_entries[i].arg);
+
 				}
-			} else {
-				sprintf(sp->desc[i], "%s:MSI-X-%d-RX",
-					dev->name, i);
-				err =3D request_irq(sp->entries[i].vector,
-					  s2io_msix_ring_handle, 0, sp->desc[i],
-						  sp->s2io_entries[i].arg);
-				/* If either data or addr is zero print it */
-				if(!(sp->msix_info[i].addr &&
+				/* if either data or addr is zero print it. */
+				if (!(sp->msix_info[i].addr &&
 					sp->msix_info[i].data)) {
-					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx "
-						"Data:0x%llx\n",sp->desc[i],
+					DBG_PRINT(ERR_DBG,
+						"%s @Addr:0x%llx Data:0x%llx\n",
+						sp->desc[i],
 						(unsigned long long)
 						sp->msix_info[i].addr,
 						(unsigned long long)
-						sp->msix_info[i].data);
-				} else {
+						ntohl(sp->msix_info[i].data));
+				} else
 					msix_rx_cnt++;
+				if (err) {
+					remove_msix_isr(sp);
+
+					DBG_PRINT(ERR_DBG,
+						"%s:MSI-X-%d registration "
+						"failed\n", dev->name, i);
+
+					DBG_PRINT(ERR_DBG,
+						"%s: Defaulting to INTA\n",
+						dev->name);
+					sp->config.intr_type =3D INTA;
+					break;
 				}
+				sp->s2io_entries[i].in_use =3D
+					MSIX_REGISTERED_SUCCESS;
 			}
-			if (err) {
-				remove_msix_isr(sp);
-				DBG_PRINT(ERR_DBG,"%s:MSI-X-%d registration "
-					  "failed\n", dev->name, i);
-				DBG_PRINT(ERR_DBG, "%s: defaulting to INTA\n",
-						 dev->name);
-				sp->config.intr_type =3D INTA;
-				break;
-			}
-			sp->s2io_entries[i].in_use =3D MSIX_REGISTERED_SUCCESS;
 		}
 		if (!err) {
-			printk(KERN_INFO "MSI-X-TX %d entries enabled\n",
-				msix_tx_cnt);
 			printk(KERN_INFO "MSI-X-RX %d entries enabled\n",
-				msix_rx_cnt);
+				--msix_rx_cnt);
+			DBG_PRINT(INFO_DBG, "MSI-X-TX entries enabled"
+						" through alarm vector\n");
 		}
 	}
 	if (sp->config.intr_type =3D=3D INTA) {
@@ -7080,8 +7126,15 @@ static void do_s2io_card_down(struct s2io_nic * =
sp, int do_io)
 	clear_bit(__S2IO_STATE_CARD_UP, &sp->state);
=20
 	/* Disable napi */
-	if (config->napi)
-		napi_disable(&sp->napi);
+	if (sp->config.napi) {
+		int off =3D 0;
+		if (config->intr_type =3D=3D  MSI_X) {
+			for (; off < sp->config.rx_ring_num; off++)
+				napi_disable(&sp->mac_control.rings[off].napi);
+			}
+		else
+			napi_disable(&sp->napi);
+	}
=20
 	/* disable Tx and Rx traffic on the NIC */
 	if (do_io)
@@ -7173,8 +7226,15 @@ static int s2io_card_up(struct s2io_nic * sp)
 	}
=20
 	/* Initialise napi */
-	if (config->napi)
-		napi_enable(&sp->napi);
+	if (config->napi) {
+		int i;
+		if (config->intr_type =3D=3D  MSI_X) {
+			for (i =3D 0; i < sp->config.rx_ring_num; i++)
+				napi_enable(&sp->mac_control.rings[i].napi);
+		} else {
+			napi_enable(&sp->napi);
+		}
+	}
=20
 	/* Maintain the state prior to the open */
 	if (sp->promisc_flg)
@@ -7217,7 +7277,7 @@ static int s2io_card_up(struct s2io_nic * sp)
 	/*  Enable select interrupts */
 	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
 	if (sp->config.intr_type !=3D INTA)
-		en_dis_able_nic_intrs(sp, ENA_ALL_INTRS, DISABLE_INTRS);
+		en_dis_able_nic_intrs(sp, TX_TRAFFIC_INTR, ENABLE_INTRS);
 	else {
 		interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
 		interruptible |=3D TX_PIC_INTR;
@@ -7615,9 +7675,6 @@ static int s2io_verify_parm(struct pci_dev *pdev,=
 u8 *dev_intr_type,
 		rx_ring_num =3D MAX_RX_RINGS;
 	}
=20
-	if (*dev_intr_type !=3D INTA)
-		napi =3D 0;
-
 	if ((*dev_intr_type !=3D INTA) && (*dev_intr_type !=3D MSI_X)) {
 		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
@@ -7918,8 +7975,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct =
pci_device_id *pre)
 	 * will use eth_mac_addr() for  dev->set_mac_address
 	 * mac address will be set every time dev->open() is called
 	 */
-	netif_napi_add(dev, &sp->napi, s2io_poll, 32);
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller =3D s2io_netpoll;
 #endif
@@ -7963,6 +8018,32 @@ s2io_init_nic(struct pci_dev *pdev, const struct=
 pci_device_id *pre)
 		}
 	}
=20
+	if (sp->config.intr_type =3D=3D MSI_X) {
+		sp->num_entries =3D config->rx_ring_num + 1;
+		ret =3D s2io_enable_msi_x(sp);
+
+		if (!ret) {
+			ret =3D s2io_test_msi(sp);
+			/* rollback MSI-X, will re-enable during add_isr() */
+			remove_msix_isr(sp);
+		}
+		if (ret) {
+
+			DBG_PRINT(ERR_DBG,
+			  "%s: MSI-X requested but failed to enable\n",
+			  dev->name);
+			sp->config.intr_type =3D INTA;
+		}
+	}
+
+	if (config->intr_type =3D=3D  MSI_X) {
+		for (i =3D 0; i < config->rx_ring_num ; i++)
+			netif_napi_add(dev, &mac_control->rings[i].napi,
+				s2io_poll_msix, 64);
+	} else {
+		netif_napi_add(dev, &sp->napi, s2io_poll_inta, 64);
+	}
+
 	/* Not needed for Herc */
 	if (sp->device_type & XFRAME_I_DEVICE) {
 		/*
@@ -8013,6 +8094,11 @@ s2io_init_nic(struct pci_dev *pdev, const struct=
 pci_device_id *pre)
 	/* store mac addresses from CAM to s2io_nic structure */
 	do_s2io_store_unicast_mc(sp);
=20
+	/* Configure MSIX vector for number of rings configured plus one */
+	if ((sp->device_type =3D=3D XFRAME_II_DEVICE) &&
+		(config->intr_type =3D=3D MSI_X))
+		sp->num_entries =3D config->rx_ring_num + 1;
+
 	 /* Store the values of the MSIX table in the s2io_nic structure */
 	store_xmsi_data(sp);
 	/* reset Nic and bring it to known state */
@@ -8078,8 +8164,14 @@ s2io_init_nic(struct pci_dev *pdev, const struct=
 pci_device_id *pre)
 		    break;
 	}
=20
-	if (napi)
+	switch (sp->config.napi) {
+	case 0:
+		DBG_PRINT(ERR_DBG, "%s: NAPI disabled\n", dev->name);
+		break;
+	case 1:
 		DBG_PRINT(ERR_DBG, "%s: NAPI enabled\n", dev->name);
+		break;
+	}
=20
 	DBG_PRINT(ERR_DBG, "%s: Using %d Tx fifo(s)\n", dev->name,
 		sp->config.tx_fifo_num);
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 0709eba..4706f7f 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -706,7 +706,7 @@ struct ring_info {
 	/* per-ring buffer counter */
 	u32 rx_bufs_left;
=20
-	#define MAX_LRO_SESSIONS	32
+#define MAX_LRO_SESSIONS       32
 	struct lro lro0_n[MAX_LRO_SESSIONS];
 	u8		lro;
=20
@@ -725,6 +725,11 @@ struct ring_info {
 	/* copy of sp->pdev pointer */
 	struct pci_dev *pdev;
=20
+	/* Per ring napi struct */
+	struct napi_struct napi;
+
+	unsigned long interrupt_count;
+
 	/*
 	 *  Place holders for the virtual and physical addresses of
 	 *  all the Rx Blocks
@@ -841,7 +846,7 @@ struct usr_addr {
  * Structure to keep track of the MSI-X vectors and the corresponding
  * argument registered against each vector
  */
-#define MAX_REQUESTED_MSI_X	17
+#define MAX_REQUESTED_MSI_X	9
 struct s2io_msix_entry
 {
 	u16 vector;
@@ -849,8 +854,8 @@ struct s2io_msix_entry
 	void *arg;
=20
 	u8 type;
-#define	MSIX_FIFO_TYPE	1
-#define	MSIX_RING_TYPE	2
+#define        MSIX_ALARM_TYPE         1
+#define        MSIX_RING_TYPE          2
=20
 	u8 in_use;
 #define MSIX_REGISTERED_SUCCESS	0xAA
@@ -877,7 +882,6 @@ struct s2io_nic {
 	 */
 	int pkts_to_process;
 	struct net_device *dev;
-	struct napi_struct napi;
 	struct mac_info mac_control;
 	struct config_param config;
 	struct pci_dev *pdev;
@@ -948,6 +952,7 @@ struct s2io_nic {
 	*/
 	u8 other_fifo_idx;
=20
+	struct napi_struct napi;
 	/*  after blink, the adapter must be restored with original
 	 *  values.
 	 */
@@ -962,6 +967,7 @@ struct s2io_nic {
 	unsigned long long start_time;
 	struct vlan_group *vlgrp;
 #define MSIX_FLG                0xA5
+	int num_entries;
 	struct msix_entry *entries;
 	int msi_detected;
 	wait_queue_head_t msi_wait;
@@ -982,6 +988,7 @@ struct s2io_nic {
 	u16		lro_max_aggr_per_sess;
 	volatile unsigned long state;
 	u64		general_int_mask;
+
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];
 	u8  serial_num[VPD_STRING_LEN];
@@ -1103,7 +1110,7 @@ static void __devexit s2io_rem_nic(struct pci_dev=
 *pdev);
 static int init_shared_mem(struct s2io_nic *sp);
 static void free_shared_mem(struct s2io_nic *sp);
 static int init_nic(struct s2io_nic *nic);
-static void rx_intr_handler(struct ring_info *ring_data);
+static int rx_intr_handler(struct ring_info *ring_data, int budget);
 static void tx_intr_handler(struct fifo_info *fifo_data);
 static void s2io_handle_errors(void * dev_id);
=20
@@ -1114,7 +1121,8 @@ static void s2io_set_multicast(struct net_device =
*dev);
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * =
rxdp);
 static void s2io_link(struct s2io_nic * sp, int link);
 static void s2io_reset(struct s2io_nic * sp);
-static int s2io_poll(struct napi_struct *napi, int budget);
+static int s2io_poll_msix(struct napi_struct *napi, int budget);
+static int s2io_poll_inta(struct napi_struct *napi, int budget);
 static void s2io_init_pci(struct s2io_nic * sp);
 static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr);
 static void s2io_alarm_handle(unsigned long data);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 888b7de..33bb18f 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -179,8 +179,7 @@ enum sbmac_state {
 #define SBMAC_MAX_TXDESCR	256
 #define SBMAC_MAX_RXDESCR	256
=20
-#define ETHER_ALIGN	2
-#define ETHER_ADDR_LEN	6
+#define ETHER_ADDR_LEN		6
 #define ENET_PACKET_SIZE	1518
 /*#define ENET_PACKET_SIZE	9216 */
=20
@@ -262,8 +261,6 @@ struct sbmac_softc {
 	spinlock_t		sbm_lock;	/* spin lock */
 	int			sbm_devflags;	/* current device flags */
=20
-	int			sbm_buffersize;
-
 	/*
 	 * Controller-specific things
 	 */
@@ -305,10 +302,11 @@ struct sbmac_softc {
 static void sbdma_initctx(struct sbmacdma *d, struct sbmac_softc *s, i=
nt chan,
 			  int txrx, int maxdescr);
 static void sbdma_channel_start(struct sbmacdma *d, int rxtx);
-static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *m);
+static int sbdma_add_rcvbuffer(struct sbmac_softc *sc, struct sbmacdma=
 *d,
+			       struct sk_buff *m);
 static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *m);
 static void sbdma_emptyring(struct sbmacdma *d);
-static void sbdma_fillring(struct sbmacdma *d);
+static void sbdma_fillring(struct sbmac_softc *sc, struct sbmacdma *d)=
;
 static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d=
,
 			    int work_to_do, int poll);
 static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *=
d,
@@ -777,16 +775,13 @@ static void sbdma_channel_stop(struct sbmacdma *d=
)
 	d->sbdma_remptr =3D NULL;
 }
=20
-static void sbdma_align_skb(struct sk_buff *skb,int power2,int offset)
+static inline void sbdma_align_skb(struct sk_buff *skb,
+				   unsigned int power2, unsigned int offset)
 {
-	unsigned long addr;
-	unsigned long newaddr;
-
-	addr =3D (unsigned long) skb->data;
-
-	newaddr =3D (addr + power2 - 1) & ~(power2 - 1);
+	unsigned char *addr =3D skb->data;
+	unsigned char *newaddr =3D PTR_ALIGN(addr, power2);
=20
-	skb_reserve(skb,newaddr-addr+offset);
+	skb_reserve(skb, newaddr - addr + offset);
 }
=20
=20
@@ -797,7 +792,8 @@ static void sbdma_align_skb(struct sk_buff *skb,int=
 power2,int offset)
  *  this queues a buffer for inbound packets.
  *
  *  Input parameters:
- *  	   d - DMA channel descriptor
+ *	   sc - softc structure
+ *  	    d - DMA channel descriptor
  * 	   sb - sk_buff to add, or NULL if we should allocate one
  *
  *  Return value:
@@ -806,8 +802,10 @@ static void sbdma_align_skb(struct sk_buff *skb,in=
t power2,int offset)
  *********************************************************************=
 */
=20
=20
-static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *sb)
+static int sbdma_add_rcvbuffer(struct sbmac_softc *sc, struct sbmacdma=
 *d,
+			       struct sk_buff *sb)
 {
+	struct net_device *dev =3D sc->sbm_dev;
 	struct sbdmadscr *dsc;
 	struct sbdmadscr *nextdsc;
 	struct sk_buff *sb_new =3D NULL;
@@ -848,14 +846,16 @@ static int sbdma_add_rcvbuffer(struct sbmacdma *d=
, struct sk_buff *sb)
 	 */
=20
 	if (sb =3D=3D NULL) {
-		sb_new =3D dev_alloc_skb(ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ET=
HER_ALIGN);
+		sb_new =3D netdev_alloc_skb(dev, ENET_PACKET_SIZE +
+					       SMP_CACHE_BYTES * 2 +
+					       NET_IP_ALIGN);
 		if (sb_new =3D=3D NULL) {
 			pr_info("%s: sk_buff allocation failed\n",
 			       d->sbdma_eth->sbm_dev->name);
 			return -ENOBUFS;
 		}
=20
-		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, ETHER_ALIGN);
+		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, NET_IP_ALIGN);
 	}
 	else {
 		sb_new =3D sb;
@@ -874,10 +874,10 @@ static int sbdma_add_rcvbuffer(struct sbmacdma *d=
, struct sk_buff *sb)
 	 * Do not interrupt per DMA transfer.
 	 */
 	dsc->dscr_a =3D virt_to_phys(sb_new->data) |
-		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) | 0;
+		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize + NET_IP_ALIGN)) | 0;
 #else
 	dsc->dscr_a =3D virt_to_phys(sb_new->data) |
-		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) |
+		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize + NET_IP_ALIGN)) |
 		M_DMA_DSCRA_INTERRUPT;
 #endif
=20
@@ -1032,18 +1032,19 @@ static void sbdma_emptyring(struct sbmacdma *d)
  *  with sk_buffs
  *
  *  Input parameters:
- *  	   d - DMA channel
+ *	   sc - softc structure
+ *  	    d - DMA channel
  *
  *  Return value:
  *  	   nothing
  *********************************************************************=
 */
=20
-static void sbdma_fillring(struct sbmacdma *d)
+static void sbdma_fillring(struct sbmac_softc *sc, struct sbmacdma *d)
 {
 	int idx;
=20
-	for (idx =3D 0; idx < SBMAC_MAX_RXDESCR-1; idx++) {
-		if (sbdma_add_rcvbuffer(d,NULL) !=3D 0)
+	for (idx =3D 0; idx < SBMAC_MAX_RXDESCR - 1; idx++) {
+		if (sbdma_add_rcvbuffer(sc, d, NULL) !=3D 0)
 			break;
 	}
 }
@@ -1159,10 +1160,11 @@ again:
 			 * packet and put it right back on the receive ring.
 			 */
=20
-			if (unlikely (sbdma_add_rcvbuffer(d,NULL) =3D=3D
-				      -ENOBUFS)) {
+			if (unlikely(sbdma_add_rcvbuffer(sc, d, NULL) =3D=3D
+				     -ENOBUFS)) {
 				dev->stats.rx_dropped++;
-				sbdma_add_rcvbuffer(d,sb); /* re-add old buffer */
+				/* Re-add old buffer */
+				sbdma_add_rcvbuffer(sc, d, sb);
 				/* No point in continuing at the moment */
 				printk(KERN_ERR "dropped packet (1)\n");
 				d->sbdma_remptr =3D SBDMA_NEXTBUF(d,sbdma_remptr);
@@ -1212,7 +1214,7 @@ again:
 			 * put it back on the receive ring.
 			 */
 			dev->stats.rx_errors++;
-			sbdma_add_rcvbuffer(d,sb);
+			sbdma_add_rcvbuffer(sc, d, sb);
 		}
=20
=20
@@ -1570,7 +1572,7 @@ static void sbmac_channel_start(struct sbmac_soft=
c *s)
 	 * Fill the receive ring
 	 */
=20
-	sbdma_fillring(&(s->sbm_rxdma));
+	sbdma_fillring(s, &(s->sbm_rxdma));
=20
 	/*
 	 * Turn on the rest of the bits in the enable register
@@ -2312,13 +2314,6 @@ static int sbmac_init(struct platform_device *pl=
dev, long long base)
 		dev->dev_addr[i] =3D eaddr[i];
 	}
=20
-
-	/*
-	 * Init packet size
-	 */
-
-	sc->sbm_buffersize =3D ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ETHER=
_ALIGN;
-
 	/*
 	 * Initialize context (get pointers to registers and stuff), then
 	 * allocate the memory for the descriptor tables.
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index f64a860..b4b6380 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -953,9 +953,6 @@ static int sc92031_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
 	unsigned entry;
 	u32 tx_status;
=20
-	if (skb_padto(skb, ETH_ZLEN))
-		return NETDEV_TX_OK;
-
 	if (unlikely(skb->len > TX_BUF_SIZE)) {
 		dev->stats.tx_dropped++;
 		goto out;
@@ -975,6 +972,11 @@ static int sc92031_start_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 	skb_copy_and_csum_dev(skb, priv->tx_bufs + entry * TX_BUF_SIZE);
=20
 	len =3D skb->len;
+	if (unlikely(len < ETH_ZLEN)) {
+		memset(priv->tx_bufs + entry * TX_BUF_SIZE + len,
+				0, ETH_ZLEN - len);
+		len =3D ETH_ZLEN;
+	}
=20
 	wmb();
=20
diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index 2806201..2c79d27 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -483,7 +483,7 @@ typedef union efx_oword {
 #endif
=20
 #define EFX_SET_OWORD_FIELD_VER(efx, oword, field, value) do { \
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0) {			   \
+	if (falcon_rev(efx) >=3D FALCON_REV_B0) {			   \
 		EFX_SET_OWORD_FIELD((oword), field##_B0, (value)); \
 	} else { \
 		EFX_SET_OWORD_FIELD((oword), field##_A1, (value)); \
@@ -491,7 +491,7 @@ typedef union efx_oword {
 } while (0)
=20
 #define EFX_QWORD_FIELD_VER(efx, qword, field)	\
-	(FALCON_REV(efx) >=3D FALCON_REV_B0 ?	\
+	(falcon_rev(efx) >=3D FALCON_REV_B0 ?	\
 	 EFX_QWORD_FIELD((qword), field##_B0) :	\
 	 EFX_QWORD_FIELD((qword), field##_A1))
=20
@@ -501,8 +501,5 @@ typedef union efx_oword {
 #define DMA_ADDR_T_WIDTH	(8 * sizeof(dma_addr_t))
 #define EFX_DMA_TYPE_WIDTH(width) \
 	(((width) < DMA_ADDR_T_WIDTH) ? (width) : DMA_ADDR_T_WIDTH)
-#define EFX_DMA_MAX_MASK ((DMA_ADDR_T_WIDTH =3D=3D 64) ? \
-			  ~((u64) 0) : ~((u32) 0))
-#define EFX_DMA_MASK(mask) ((mask) & EFX_DMA_MAX_MASK)
=20
 #endif /* EFX_BITFIELD_H */
diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index eecaa6d..7fc0328 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -27,10 +27,8 @@ static void blink_led_timer(unsigned long context)
 	struct efx_blinker *bl =3D &efx->board_info.blinker;
 	efx->board_info.set_fault_led(efx, bl->state);
 	bl->state =3D !bl->state;
-	if (bl->resubmit) {
-		bl->timer.expires =3D jiffies + BLINK_INTERVAL;
-		add_timer(&bl->timer);
-	}
+	if (bl->resubmit)
+		mod_timer(&bl->timer, jiffies + BLINK_INTERVAL);
 }
=20
 static void board_blink(struct efx_nic *efx, int blink)
@@ -44,8 +42,7 @@ static void board_blink(struct efx_nic *efx, int blin=
k)
 		blinker->state =3D 0;
 		setup_timer(&blinker->timer, blink_led_timer,
 			    (unsigned long)efx);
-		blinker->timer.expires =3D jiffies + BLINK_INTERVAL;
-		add_timer(&blinker->timer);
+		mod_timer(&blinker->timer, jiffies + BLINK_INTERVAL);
 	} else {
 		blinker->resubmit =3D 0;
 		if (blinker->timer.function)
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 418f2e5..4497606 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -199,11 +199,12 @@ static inline int efx_process_channel(struct efx_=
channel *channel, int rx_quota)
  */
 static inline void efx_channel_processed(struct efx_channel *channel)
 {
-	/* Write to EVQ_RPTR_REG.  If a new event arrived in a race
-	 * with finishing processing, a new interrupt will be raised.
-	 */
+	/* The interrupt handler for this channel may set work_pending
+	 * as soon as we acknowledge the events we've seen.  Make sure
+	 * it's cleared before then. */
 	channel->work_pending =3D 0;
-	smp_wmb(); /* Ensure channel updated before any new interrupt. */
+	smp_wmb();
+
 	falcon_eventq_read_ack(channel);
 }
=20
@@ -265,7 +266,7 @@ void efx_process_channel_now(struct efx_channel *ch=
annel)
 	napi_disable(&channel->napi_str);
=20
 	/* Poll the channel */
-	(void) efx_process_channel(channel, efx->type->evq_size);
+	efx_process_channel(channel, efx->type->evq_size);
=20
 	/* Ack the eventq. This may cause an interrupt to be generated
 	 * when they are reenabled */
@@ -317,26 +318,6 @@ static void efx_remove_eventq(struct efx_channel *=
channel)
  *
  *********************************************************************=
****/
=20
-/* Setup per-NIC RX buffer parameters.
- * Calculate the rx buffer allocation parameters required to support
- * the current MTU, including padding for header alignment and overrun=
s.
- */
-static void efx_calc_rx_buffer_params(struct efx_nic *efx)
-{
-	unsigned int order, len;
-
-	len =3D (max(EFX_PAGE_IP_ALIGN, NET_IP_ALIGN) +
-	       EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
-	       efx->type->rx_buffer_padding);
-
-	/* Calculate page-order */
-	for (order =3D 0; ((1u << order) * PAGE_SIZE) < len; ++order)
-		;
-
-	efx->rx_buffer_len =3D len;
-	efx->rx_buffer_order =3D order;
-}
-
 static int efx_probe_channel(struct efx_channel *channel)
 {
 	struct efx_tx_queue *tx_queue;
@@ -387,7 +368,14 @@ static int efx_init_channels(struct efx_nic *efx)
 	struct efx_channel *channel;
 	int rc =3D 0;
=20
-	efx_calc_rx_buffer_params(efx);
+	/* Calculate the rx buffer allocation parameters required to
+	 * support the current MTU, including padding for header
+	 * alignment and overruns.
+	 */
+	efx->rx_buffer_len =3D (max(EFX_PAGE_IP_ALIGN, NET_IP_ALIGN) +
+			      EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
+			      efx->type->rx_buffer_padding);
+	efx->rx_buffer_order =3D get_order(efx->rx_buffer_len);
=20
 	/* Initialise the channels */
 	efx_for_each_channel(channel, efx) {
@@ -440,9 +428,12 @@ static void efx_start_channel(struct efx_channel *=
channel)
 		netif_napi_add(channel->napi_dev, &channel->napi_str,
 			       efx_poll, napi_weight);
=20
+	/* The interrupt handler for this channel may set work_pending
+	 * as soon as we enable it.  Make sure it's cleared before
+	 * then.  Similarly, make sure it sees the enabled flag set. */
 	channel->work_pending =3D 0;
 	channel->enabled =3D 1;
-	smp_wmb(); /* ensure channel updated before first interrupt */
+	smp_wmb();
=20
 	napi_enable(&channel->napi_str);
=20
@@ -704,7 +695,7 @@ static void efx_stop_port(struct efx_nic *efx)
 	mutex_unlock(&efx->mac_lock);
=20
 	/* Serialise against efx_set_multicast_list() */
-	if (NET_DEV_REGISTERED(efx)) {
+	if (efx_dev_registered(efx)) {
 		netif_tx_lock_bh(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
@@ -791,22 +782,23 @@ static int efx_init_io(struct efx_nic *efx)
 	efx->membase =3D ioremap_nocache(efx->membase_phys,
 				       efx->type->mem_map_size);
 	if (!efx->membase) {
-		EFX_ERR(efx, "could not map memory BAR %d at %lx+%x\n",
-			efx->type->mem_bar, efx->membase_phys,
+		EFX_ERR(efx, "could not map memory BAR %d at %llx+%x\n",
+			efx->type->mem_bar,
+			(unsigned long long)efx->membase_phys,
 			efx->type->mem_map_size);
 		rc =3D -ENOMEM;
 		goto fail4;
 	}
-	EFX_LOG(efx, "memory BAR %u at %lx+%x (virtual %p)\n",
-		efx->type->mem_bar, efx->membase_phys, efx->type->mem_map_size,
-		efx->membase);
+	EFX_LOG(efx, "memory BAR %u at %llx+%x (virtual %p)\n",
+		efx->type->mem_bar, (unsigned long long)efx->membase_phys,
+		efx->type->mem_map_size, efx->membase);
=20
 	return 0;
=20
  fail4:
 	release_mem_region(efx->membase_phys, efx->type->mem_map_size);
  fail3:
-	efx->membase_phys =3D 0UL;
+	efx->membase_phys =3D 0;
  fail2:
 	pci_disable_device(efx->pci_dev);
  fail1:
@@ -824,7 +816,7 @@ static void efx_fini_io(struct efx_nic *efx)
=20
 	if (efx->membase_phys) {
 		pci_release_region(efx->pci_dev, efx->type->mem_bar);
-		efx->membase_phys =3D 0UL;
+		efx->membase_phys =3D 0;
 	}
=20
 	pci_disable_device(efx->pci_dev);
@@ -1043,7 +1035,7 @@ static void efx_start_all(struct efx_nic *efx)
 		return;
 	if ((efx->state !=3D STATE_RUNNING) && (efx->state !=3D STATE_INIT))
 		return;
-	if (NET_DEV_REGISTERED(efx) && !netif_running(efx->net_dev))
+	if (efx_dev_registered(efx) && !netif_running(efx->net_dev))
 		return;
=20
 	/* Mark the port as enabled so port reconfigurations can start, then
@@ -1073,9 +1065,8 @@ static void efx_flush_all(struct efx_nic *efx)
 	cancel_delayed_work_sync(&efx->monitor_work);
=20
 	/* Ensure that all RX slow refills are complete. */
-	efx_for_each_rx_queue(rx_queue, efx) {
+	efx_for_each_rx_queue(rx_queue, efx)
 		cancel_delayed_work_sync(&rx_queue->work);
-	}
=20
 	/* Stop scheduled port reconfigurations */
 	cancel_work_sync(&efx->reconfigure_work);
@@ -1101,9 +1092,10 @@ static void efx_stop_all(struct efx_nic *efx)
 	falcon_disable_interrupts(efx);
 	if (efx->legacy_irq)
 		synchronize_irq(efx->legacy_irq);
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel_with_interrupt(channel, efx) {
 		if (channel->irq)
 			synchronize_irq(channel->irq);
+	}
=20
 	/* Stop all NAPI processing and synchronous rx refills */
 	efx_for_each_channel(channel, efx)
@@ -1125,7 +1117,7 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Stop the kernel transmit interface late, so the watchdog
 	 * timer isn't ticking over the flush */
 	efx_stop_queue(efx);
-	if (NET_DEV_REGISTERED(efx)) {
+	if (efx_dev_registered(efx)) {
 		netif_tx_lock_bh(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
@@ -1344,13 +1336,17 @@ static int efx_net_stop(struct net_device *net_=
dev)
 	return 0;
 }
=20
-/* Context: process, dev_base_lock held, non-blocking. */
+/* Context: process, dev_base_lock or RTNL held, non-blocking. */
 static struct net_device_stats *efx_net_stats(struct net_device *net_d=
ev)
 {
 	struct efx_nic *efx =3D net_dev->priv;
 	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
 	struct net_device_stats *stats =3D &net_dev->stats;
=20
+	/* Update stats if possible, but do not wait if another thread
+	 * is updating them (or resetting the NIC); slightly stale
+	 * stats are acceptable.
+	 */
 	if (!spin_trylock(&efx->stats_lock))
 		return stats;
 	if (efx->state =3D=3D STATE_RUNNING) {
@@ -1494,7 +1490,7 @@ static void efx_set_multicast_list(struct net_dev=
ice *net_dev)
 static int efx_netdev_event(struct notifier_block *this,
 			    unsigned long event, void *ptr)
 {
-	struct net_device *net_dev =3D (struct net_device *)ptr;
+	struct net_device *net_dev =3D ptr;
=20
 	if (net_dev->open =3D=3D efx_net_open && event =3D=3D NETDEV_CHANGENA=
ME) {
 		struct efx_nic *efx =3D net_dev->priv;
@@ -1563,7 +1559,7 @@ static void efx_unregister_netdev(struct efx_nic =
*efx)
 	efx_for_each_tx_queue(tx_queue, efx)
 		efx_release_tx_buffers(tx_queue);
=20
-	if (NET_DEV_REGISTERED(efx)) {
+	if (efx_dev_registered(efx)) {
 		strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
 		unregister_netdev(efx->net_dev);
 	}
@@ -1688,7 +1684,7 @@ static int efx_reset(struct efx_nic *efx)
 	if (method =3D=3D RESET_TYPE_DISABLE) {
 		/* Reinitialise the device anyway so the driver unload sequence
 		 * can talk to the external SRAM */
-		(void) falcon_init_nic(efx);
+		falcon_init_nic(efx);
 		rc =3D -EIO;
 		goto fail4;
 	}
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b57cc68..d3f749c 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -116,17 +116,8 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON=
 threshold");
  *********************************************************************=
*****
  */
=20
-/* DMA address mask (up to 46-bit, avoiding compiler warnings)
- *
- * Note that it is possible to have a platform with 64-bit longs and
- * 32-bit DMA addresses, or vice versa.  EFX_DMA_MASK takes care of th=
e
- * platform DMA mask.
- */
-#if BITS_PER_LONG =3D=3D 64
-#define FALCON_DMA_MASK EFX_DMA_MASK(0x00003fffffffffffUL)
-#else
-#define FALCON_DMA_MASK EFX_DMA_MASK(0x00003fffffffffffULL)
-#endif
+/* DMA address mask */
+#define FALCON_DMA_MASK DMA_BIT_MASK(46)
=20
 /* TX DMA length mask (13-bit) */
 #define FALCON_TX_DMA_MASK (4096 - 1)
@@ -145,7 +136,7 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON =
threshold");
 #define PCI_EXP_LNKSTA_LNK_WID_LBN	4
=20
 #define FALCON_IS_DUAL_FUNC(efx)		\
-	(FALCON_REV(efx) < FALCON_REV_B0)
+	(falcon_rev(efx) < FALCON_REV_B0)
=20
 /*********************************************************************=
*****
  *
@@ -465,7 +456,7 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 			      TX_DESCQ_TYPE, 0,
 			      TX_NON_IP_DROP_DIS_B0, 1);
=20
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0) {
+	if (falcon_rev(efx) >=3D FALCON_REV_B0) {
 		int csum =3D !(efx->net_dev->features & NETIF_F_IP_CSUM);
 		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_IP_CHKSM_DIS_B0, csum);
 		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_TCP_CHKSM_DIS_B0, csum);
@@ -474,7 +465,7 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 	falcon_write_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
 			   tx_queue->queue);
=20
-	if (FALCON_REV(efx) < FALCON_REV_B0) {
+	if (falcon_rev(efx) < FALCON_REV_B0) {
 		efx_oword_t reg;
=20
 		BUG_ON(tx_queue->queue >=3D 128); /* HW limit */
@@ -635,7 +626,7 @@ int falcon_init_rx(struct efx_rx_queue *rx_queue)
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx =3D rx_queue->efx;
 	int rc;
-	int is_b0 =3D FALCON_REV(efx) >=3D FALCON_REV_B0;
+	int is_b0 =3D falcon_rev(efx) >=3D FALCON_REV_B0;
 	int iscsi_digest_en =3D is_b0;
=20
 	EFX_LOG(efx, "RX queue %d ring in special buffers %d-%d\n",
@@ -822,10 +813,10 @@ static inline void falcon_handle_tx_event(struct =
efx_channel *channel,
 		tx_ev_q_label =3D EFX_QWORD_FIELD(*event, TX_EV_Q_LABEL);
 		tx_queue =3D &efx->tx_queue[tx_ev_q_label];
=20
-		if (NET_DEV_REGISTERED(efx))
+		if (efx_dev_registered(efx))
 			netif_tx_lock(efx->net_dev);
 		falcon_notify_tx_desc(tx_queue);
-		if (NET_DEV_REGISTERED(efx))
+		if (efx_dev_registered(efx))
 			netif_tx_unlock(efx->net_dev);
 	} else if (EFX_QWORD_FIELD(*event, TX_EV_PKT_ERR) &&
 		   EFX_WORKAROUND_10727(efx)) {
@@ -884,7 +875,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_q=
ueue *rx_queue,
 						   RX_EV_TCP_UDP_CHKSUM_ERR);
 	rx_ev_eth_crc_err =3D EFX_QWORD_FIELD(*event, RX_EV_ETH_CRC_ERR);
 	rx_ev_frm_trunc =3D EFX_QWORD_FIELD(*event, RX_EV_FRM_TRUNC);
-	rx_ev_drib_nib =3D ((FALCON_REV(efx) >=3D FALCON_REV_B0) ?
+	rx_ev_drib_nib =3D ((falcon_rev(efx) >=3D FALCON_REV_B0) ?
 			  0 : EFX_QWORD_FIELD(*event, RX_EV_DRIB_NIB));
 	rx_ev_pause_frm =3D EFX_QWORD_FIELD(*event, RX_EV_PAUSE_FRM_ERR);
=20
@@ -1065,7 +1056,7 @@ static void falcon_handle_global_event(struct efx=
_channel *channel,
 	    EFX_QWORD_FIELD(*event, XG_PHY_INTR))
 		is_phy_event =3D 1;
=20
-	if ((FALCON_REV(efx) >=3D FALCON_REV_B0) &&
+	if ((falcon_rev(efx) >=3D FALCON_REV_B0) &&
 	    EFX_OWORD_FIELD(*event, XG_MNT_INTR_B0))
 		is_phy_event =3D 1;
=20
@@ -1405,7 +1396,7 @@ static inline void falcon_irq_ack_a1(struct efx_n=
ic *efx)
 static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data =3D efx->nic_data;
-	efx_oword_t *int_ker =3D (efx_oword_t *) efx->irq_status.addr;
+	efx_oword_t *int_ker =3D efx->irq_status.addr;
 	efx_oword_t fatal_intr;
 	int error, mem_perr;
 	static int n_int_errors;
@@ -1451,8 +1442,8 @@ out:
  */
 static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 {
-	struct efx_nic *efx =3D (struct efx_nic *)dev_id;
-	efx_oword_t *int_ker =3D (efx_oword_t *) efx->irq_status.addr;
+	struct efx_nic *efx =3D dev_id;
+	efx_oword_t *int_ker =3D efx->irq_status.addr;
 	struct efx_channel *channel;
 	efx_dword_t reg;
 	u32 queues;
@@ -1489,8 +1480,8 @@ static irqreturn_t falcon_legacy_interrupt_b0(int=
 irq, void *dev_id)
=20
 static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 {
-	struct efx_nic *efx =3D (struct efx_nic *)dev_id;
-	efx_oword_t *int_ker =3D (efx_oword_t *) efx->irq_status.addr;
+	struct efx_nic *efx =3D dev_id;
+	efx_oword_t *int_ker =3D efx->irq_status.addr;
 	struct efx_channel *channel;
 	int syserr;
 	int queues;
@@ -1542,9 +1533,9 @@ static irqreturn_t falcon_legacy_interrupt_a1(int=
 irq, void *dev_id)
  */
 static irqreturn_t falcon_msi_interrupt(int irq, void *dev_id)
 {
-	struct efx_channel *channel =3D (struct efx_channel *)dev_id;
+	struct efx_channel *channel =3D dev_id;
 	struct efx_nic *efx =3D channel->efx;
-	efx_oword_t *int_ker =3D (efx_oword_t *) efx->irq_status.addr;
+	efx_oword_t *int_ker =3D efx->irq_status.addr;
 	int syserr;
=20
 	efx->last_irq_cpu =3D raw_smp_processor_id();
@@ -1572,7 +1563,7 @@ static void falcon_setup_rss_indir_table(struct e=
fx_nic *efx)
 	unsigned long offset;
 	efx_dword_t dword;
=20
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if (falcon_rev(efx) < FALCON_REV_B0)
 		return;
=20
 	for (offset =3D RX_RSS_INDIR_TBL_B0;
@@ -1595,7 +1586,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
=20
 	if (!EFX_INT_MODE_USE_MSI(efx)) {
 		irq_handler_t handler;
-		if (FALCON_REV(efx) >=3D FALCON_REV_B0)
+		if (falcon_rev(efx) >=3D FALCON_REV_B0)
 			handler =3D falcon_legacy_interrupt_b0;
 		else
 			handler =3D falcon_legacy_interrupt_a1;
@@ -1636,12 +1627,13 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 	efx_oword_t reg;
=20
 	/* Disable MSI/MSI-X interrupts */
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel_with_interrupt(channel, efx) {
 		if (channel->irq)
 			free_irq(channel->irq, channel);
+	}
=20
 	/* ACK legacy interrupt */
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0)
+	if (falcon_rev(efx) >=3D FALCON_REV_B0)
 		falcon_read(efx, &reg, INT_ISR0_B0);
 	else
 		falcon_irq_ack_a1(efx);
@@ -1732,7 +1724,7 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 	efx_oword_t temp;
 	int count;
=20
-	if ((FALCON_REV(efx) < FALCON_REV_B0) ||
+	if ((falcon_rev(efx) < FALCON_REV_B0) ||
 	    (efx->loopback_mode !=3D LOOPBACK_NONE))
 		return;
=20
@@ -1785,7 +1777,7 @@ void falcon_deconfigure_mac_wrapper(struct efx_ni=
c *efx)
 {
 	efx_oword_t temp;
=20
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if (falcon_rev(efx) < FALCON_REV_B0)
 		return;
=20
 	/* Isolate the MAC -> RX */
@@ -1823,7 +1815,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_ni=
c *efx)
 			     MAC_SPEED, link_speed);
 	/* On B0, MAC backpressure can be disabled and packets get
 	 * discarded. */
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0) {
+	if (falcon_rev(efx) >=3D FALCON_REV_B0) {
 		EFX_SET_OWORD_FIELD(reg, TXFIFO_DRAIN_EN_B0,
 				    !efx->link_up);
 	}
@@ -1841,7 +1833,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_ni=
c *efx)
 	EFX_SET_OWORD_FIELD_VER(efx, reg, RX_XOFF_MAC_EN, tx_fc);
=20
 	/* Unisolate the MAC -> RX */
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0)
+	if (falcon_rev(efx) >=3D FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(reg, RX_INGR_EN_B0, 1);
 	falcon_write(efx, &reg, RX_CFG_REG_KER);
 }
@@ -1856,7 +1848,7 @@ int falcon_dma_stats(struct efx_nic *efx, unsigne=
d int done_offset)
 		return 0;
=20
 	/* Statistics fetch will fail if the MAC is in TX drain */
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0) {
+	if (falcon_rev(efx) >=3D FALCON_REV_B0) {
 		efx_oword_t temp;
 		falcon_read(efx, &temp, MAC0_CTRL_REG_KER);
 		if (EFX_OWORD_FIELD(temp, TXFIFO_DRAIN_EN_B0))
@@ -1940,7 +1932,7 @@ static int falcon_gmii_wait(struct efx_nic *efx)
 static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
 			      int addr, int value)
 {
-	struct efx_nic *efx =3D (struct efx_nic *)net_dev->priv;
+	struct efx_nic *efx =3D net_dev->priv;
 	unsigned int phy_id2 =3D phy_id & FALCON_PHY_ID_ID_MASK;
 	efx_oword_t reg;
=20
@@ -2008,7 +2000,7 @@ static void falcon_mdio_write(struct net_device *=
net_dev, int phy_id,
  * could be read, -1 will be returned. */
 static int falcon_mdio_read(struct net_device *net_dev, int phy_id, in=
t addr)
 {
-	struct efx_nic *efx =3D (struct efx_nic *)net_dev->priv;
+	struct efx_nic *efx =3D net_dev->priv;
 	unsigned int phy_addr =3D phy_id & FALCON_PHY_ID_ID_MASK;
 	efx_oword_t reg;
 	int value =3D -1;
@@ -2113,7 +2105,7 @@ int falcon_probe_port(struct efx_nic *efx)
 	falcon_init_mdio(&efx->mii);
=20
 	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation=
 */
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0)
+	if (falcon_rev(efx) >=3D FALCON_REV_B0)
 		efx->flow_control =3D EFX_FC_RX | EFX_FC_TX;
 	else
 		efx->flow_control =3D EFX_FC_RX;
@@ -2373,7 +2365,7 @@ static int falcon_probe_nic_variant(struct efx_ni=
c *efx)
 		return -ENODEV;
 	}
=20
-	switch (FALCON_REV(efx)) {
+	switch (falcon_rev(efx)) {
 	case FALCON_REV_A0:
 	case 0xff:
 		EFX_ERR(efx, "Falcon rev A0 not supported\n");
@@ -2399,7 +2391,7 @@ static int falcon_probe_nic_variant(struct efx_ni=
c *efx)
 		break;
=20
 	default:
-		EFX_ERR(efx, "Unknown Falcon rev %d\n", FALCON_REV(efx));
+		EFX_ERR(efx, "Unknown Falcon rev %d\n", falcon_rev(efx));
 		return -ENODEV;
 	}
=20
@@ -2419,7 +2411,7 @@ int falcon_probe_nic(struct efx_nic *efx)
=20
 	/* Allocate storage for hardware specific data */
 	nic_data =3D kzalloc(sizeof(*nic_data), GFP_KERNEL);
-	efx->nic_data =3D (void *) nic_data;
+	efx->nic_data =3D nic_data;
=20
 	/* Determine number of ports etc. */
 	rc =3D falcon_probe_nic_variant(efx);
@@ -2489,13 +2481,10 @@ int falcon_probe_nic(struct efx_nic *efx)
  */
 int falcon_init_nic(struct efx_nic *efx)
 {
-	struct falcon_nic_data *data;
 	efx_oword_t temp;
 	unsigned thresh;
 	int rc;
=20
-	data =3D (struct falcon_nic_data *)efx->nic_data;
-
 	/* Set up the address region register. This is only needed
 	 * for the B0 FPGA, but since we are just pushing in the
 	 * reset defaults this may as well be unconditional. */
@@ -2562,7 +2551,7 @@ int falcon_init_nic(struct efx_nic *efx)
=20
 	/* Set number of RSS queues for receive path. */
 	falcon_read(efx, &temp, RX_FILTER_CTL_REG);
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0)
+	if (falcon_rev(efx) >=3D FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(temp, NUM_KER, 0);
 	else
 		EFX_SET_OWORD_FIELD(temp, NUM_KER, efx->rss_queues - 1);
@@ -2600,7 +2589,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	/* Prefetch threshold 2 =3D> fetch when descriptor cache half empty *=
/
 	EFX_SET_OWORD_FIELD(temp, TX_PREF_THRESHOLD, 2);
 	/* Squash TX of packets of 16 bytes or less */
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0 && EFX_WORKAROUND_9141(efx))
+	if (falcon_rev(efx) >=3D FALCON_REV_B0 && EFX_WORKAROUND_9141(efx))
 		EFX_SET_OWORD_FIELD(temp, TX_FLUSH_MIN_LEN_EN_B0, 1);
 	falcon_write(efx, &temp, TX_CFG2_REG_KER);
=20
@@ -2617,7 +2606,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	if (EFX_WORKAROUND_7575(efx))
 		EFX_SET_OWORD_FIELD_VER(efx, temp, RX_USR_BUF_SIZE,
 					(3 * 4096) / 32);
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0)
+	if (falcon_rev(efx) >=3D FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(temp, RX_INGR_EN_B0, 1);
=20
 	/* RX FIFO flow control thresholds */
@@ -2633,7 +2622,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	falcon_write(efx, &temp, RX_CFG_REG_KER);
=20
 	/* Set destination of both TX and RX Flush events */
-	if (FALCON_REV(efx) >=3D FALCON_REV_B0) {
+	if (falcon_rev(efx) >=3D FALCON_REV_B0) {
 		EFX_POPULATE_OWORD_1(temp, FLS_EVQ_ID, 0);
 		falcon_write(efx, &temp, DP_CTRL_REG);
 	}
@@ -2647,7 +2636,7 @@ void falcon_remove_nic(struct efx_nic *efx)
=20
 	falcon_free_buffer(efx, &efx->irq_status);
=20
-	(void) falcon_reset_hw(efx, RESET_TYPE_ALL);
+	falcon_reset_hw(efx, RESET_TYPE_ALL);
=20
 	/* Release the second function after the reset */
 	if (nic_data->pci_dev2) {
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 6117403..492f9bc 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -23,7 +23,10 @@ enum falcon_revision {
 	FALCON_REV_B0 =3D 2,
 };
=20
-#define FALCON_REV(efx) ((efx)->pci_dev->revision)
+static inline int falcon_rev(struct efx_nic *efx)
+{
+	return efx->pci_dev->revision;
+}
=20
 extern struct efx_nic_type falcon_a_nic_type;
 extern struct efx_nic_type falcon_b_nic_type;
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_h=
wdefs.h
index 06e2d68..6d00311 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -1125,7 +1125,7 @@ struct falcon_nvconfig_board_v2 {
 	u8 port1_phy_type;
 	__le16 asic_sub_revision;
 	__le16 board_revision;
-} __attribute__ ((packed));
+} __packed;
=20
 #define NVCONFIG_BASE 0x300
 #define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
@@ -1144,6 +1144,6 @@ struct falcon_nvconfig {
 	__le16 board_struct_ver;
 	__le16 board_checksum;
 	struct falcon_nvconfig_board_v2 board_v2;
-} __attribute__ ((packed));
+} __packed;
=20
 #endif /* EFX_FALCON_HWDEFS_H */
diff --git a/drivers/net/sfc/falcon_io.h b/drivers/net/sfc/falcon_io.h
index ea08184..6670cdf 100644
--- a/drivers/net/sfc/falcon_io.h
+++ b/drivers/net/sfc/falcon_io.h
@@ -56,14 +56,27 @@
 #define FALCON_USE_QWORD_IO 1
 #endif
=20
-#define _falcon_writeq(efx, value, reg) \
-	__raw_writeq((__force u64) (value), (efx)->membase + (reg))
-#define _falcon_writel(efx, value, reg) \
-	__raw_writel((__force u32) (value), (efx)->membase + (reg))
-#define _falcon_readq(efx, reg) \
-	((__force __le64) __raw_readq((efx)->membase + (reg)))
-#define _falcon_readl(efx, reg) \
-	((__force __le32) __raw_readl((efx)->membase + (reg)))
+#ifdef FALCON_USE_QWORD_IO
+static inline void _falcon_writeq(struct efx_nic *efx, __le64 value,
+				  unsigned int reg)
+{
+	__raw_writeq((__force u64)value, efx->membase + reg);
+}
+static inline __le64 _falcon_readq(struct efx_nic *efx, unsigned int r=
eg)
+{
+	return (__force __le64)__raw_readq(efx->membase + reg);
+}
+#endif
+
+static inline void _falcon_writel(struct efx_nic *efx, __le32 value,
+				  unsigned int reg)
+{
+	__raw_writel((__force u32)value, efx->membase + reg);
+}
+static inline __le32 _falcon_readl(struct efx_nic *efx, unsigned int r=
eg)
+{
+	return (__force __le32)__raw_readl(efx->membase + reg);
+}
=20
 /* Writes to a normal 16-byte Falcon register, locking as appropriate.=
 */
 static inline void falcon_write(struct efx_nic *efx, efx_oword_t *valu=
e,
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xma=
c.c
index a74b793..dbdcee4 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -221,7 +221,7 @@ static int falcon_xgmii_status(struct efx_nic *efx)
 {
 	efx_dword_t reg;
=20
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if (falcon_rev(efx) < FALCON_REV_B0)
 		return 1;
=20
 	/* The ISR latches, so clear it and re-read */
@@ -241,7 +241,7 @@ static void falcon_mask_status_intr(struct efx_nic =
*efx, int enable)
 {
 	efx_dword_t reg;
=20
-	if ((FALCON_REV(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
+	if ((falcon_rev(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
 		return;
=20
 	/* Flush the ISR */
@@ -454,7 +454,7 @@ static int falcon_check_xaui_link_up(struct efx_nic=
 *efx)
=20
 		EFX_LOG(efx, "%s Clobbering XAUI (%d tries left).\n",
 			__func__, tries);
-		(void) falcon_reset_xaui(efx);
+		falcon_reset_xaui(efx);
 		udelay(200);
 		tries--;
 	}
@@ -572,7 +572,7 @@ int falcon_check_xmac(struct efx_nic *efx)
 	xaui_link_ok =3D falcon_xaui_link_ok(efx);
=20
 	if (EFX_WORKAROUND_5147(efx) && !xaui_link_ok)
-		(void) falcon_reset_xaui(efx);
+		falcon_reset_xaui(efx);
=20
 	/* Call the PHY check_hw routine */
 	rc =3D efx->phy_op->check_hw(efx);
@@ -639,7 +639,7 @@ int falcon_xmac_set_pause(struct efx_nic *efx, enum=
 efx_fc_type flow_control)
 	reset =3D ((flow_control & EFX_FC_TX) &&
 		 !(efx->flow_control & EFX_FC_TX));
 	if (EFX_WORKAROUND_11482(efx) && reset) {
-		if (FALCON_REV(efx) >=3D FALCON_REV_B0) {
+		if (falcon_rev(efx) >=3D FALCON_REV_B0) {
 			/* Recover by resetting the EM block */
 			if (efx->link_up)
 				falcon_drain_tx_fifo(efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.=
h
index 59f261b..5e20e75 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -42,7 +42,7 @@
 #ifndef EFX_DRIVER_NAME
 #define EFX_DRIVER_NAME	"sfc"
 #endif
-#define EFX_DRIVER_VERSION	"2.2.0136"
+#define EFX_DRIVER_VERSION	"2.2"
=20
 #ifdef EFX_ENABLE_DEBUG
 #define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
@@ -52,28 +52,19 @@
 #define EFX_WARN_ON_PARANOID(x) do {} while (0)
 #endif
=20
-#define NET_DEV_REGISTERED(efx)					\
-	((efx)->net_dev->reg_state =3D=3D NETREG_REGISTERED)
-
-/* Include net device name in log messages if it has been registered.
- * Use efx->name not efx->net_dev->name so that races with (un)registr=
ation
- * are harmless.
- */
-#define NET_DEV_NAME(efx) (NET_DEV_REGISTERED(efx) ? (efx)->name : "")
-
 /* Un-rate-limited logging */
 #define EFX_ERR(efx, fmt, args...) \
-dev_err(&((efx)->pci_dev->dev), "ERR: %s " fmt, NET_DEV_NAME(efx), ##a=
rgs)
+dev_err(&((efx)->pci_dev->dev), "ERR: %s " fmt, efx_dev_name(efx), ##a=
rgs)
=20
 #define EFX_INFO(efx, fmt, args...) \
-dev_info(&((efx)->pci_dev->dev), "INFO: %s " fmt, NET_DEV_NAME(efx), #=
#args)
+dev_info(&((efx)->pci_dev->dev), "INFO: %s " fmt, efx_dev_name(efx), #=
#args)
=20
 #ifdef EFX_ENABLE_DEBUG
 #define EFX_LOG(efx, fmt, args...) \
-dev_info(&((efx)->pci_dev->dev), "DBG: %s " fmt, NET_DEV_NAME(efx), ##=
args)
+dev_info(&((efx)->pci_dev->dev), "DBG: %s " fmt, efx_dev_name(efx), ##=
args)
 #else
 #define EFX_LOG(efx, fmt, args...) \
-dev_dbg(&((efx)->pci_dev->dev), "DBG: %s " fmt, NET_DEV_NAME(efx), ##a=
rgs)
+dev_dbg(&((efx)->pci_dev->dev), "DBG: %s " fmt, efx_dev_name(efx), ##a=
rgs)
 #endif
=20
 #define EFX_TRACE(efx, fmt, args...) do {} while (0)
@@ -90,11 +81,6 @@ do {if (net_ratelimit()) EFX_INFO(efx, fmt, ##args);=
 } while (0)
 #define EFX_LOG_RL(efx, fmt, args...) \
 do {if (net_ratelimit()) EFX_LOG(efx, fmt, ##args); } while (0)
=20
-/* Kernel headers may redefine inline anyway */
-#ifndef inline
-#define inline inline __attribute__ ((always_inline))
-#endif
-
 /*********************************************************************=
*****
  *
  * Efx data structures
@@ -695,7 +681,7 @@ struct efx_nic {
 	struct workqueue_struct *workqueue;
 	struct work_struct reset_work;
 	struct delayed_work monitor_work;
-	unsigned long membase_phys;
+	resource_size_t membase_phys;
 	void __iomem *membase;
 	spinlock_t biu_lock;
 	enum efx_int_mode interrupt_mode;
@@ -719,7 +705,7 @@ struct efx_nic {
=20
 	unsigned n_rx_nodesc_drop_cnt;
=20
-	void *nic_data;
+	struct falcon_nic_data *nic_data;
=20
 	struct mutex mac_lock;
 	int port_enabled;
@@ -760,6 +746,20 @@ struct efx_nic {
 	void *loopback_selftest;
 };
=20
+static inline int efx_dev_registered(struct efx_nic *efx)
+{
+	return efx->net_dev->reg_state =3D=3D NETREG_REGISTERED;
+}
+
+/* Net device name, for inclusion in log messages if it has been regis=
tered.
+ * Use efx->name not efx->net_dev->name so that races with (un)registr=
ation
+ * are harmless.
+ */
+static inline const char *efx_dev_name(struct efx_nic *efx)
+{
+	return efx_dev_registered(efx) ? efx->name : "";
+}
+
 /**
  * struct efx_nic_type - Efx device type definition
  * @mem_bar: Memory BAR number
@@ -795,7 +795,7 @@ struct efx_nic_type {
 	unsigned int txd_ring_mask;
 	unsigned int rxd_ring_mask;
 	unsigned int evq_size;
-	dma_addr_t max_dma_mask;
+	u64 max_dma_mask;
 	unsigned int tx_dma_mask;
 	unsigned bug5391_mask;
=20
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 6706223..601b001 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -86,14 +86,17 @@ static unsigned int rx_refill_limit =3D 95;
  */
 #define EFX_RXD_HEAD_ROOM 2
=20
-/* Macros for zero-order pages (potentially) containing multiple RX bu=
ffers */
-#define RX_DATA_OFFSET(_data)				\
-	(((unsigned long) (_data)) & (PAGE_SIZE-1))
-#define RX_BUF_OFFSET(_rx_buf)				\
-	RX_DATA_OFFSET((_rx_buf)->data)
-
-#define RX_PAGE_SIZE(_efx)				\
-	(PAGE_SIZE * (1u << (_efx)->rx_buffer_order))
+static inline unsigned int efx_rx_buf_offset(struct efx_rx_buffer *buf=
)
+{
+	/* Offset is always within one page, so we don't need to consider
+	 * the page order.
+	 */
+	return (__force unsigned long) buf->data & (PAGE_SIZE - 1);
+}
+static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
+{
+	return PAGE_SIZE << efx->rx_buffer_order;
+}
=20
=20
 /*********************************************************************=
*****
@@ -106,7 +109,7 @@ static unsigned int rx_refill_limit =3D 95;
 static int efx_lro_get_skb_hdr(struct sk_buff *skb, void **ip_hdr,
 			       void **tcpudp_hdr, u64 *hdr_flags, void *priv)
 {
-	struct efx_channel *channel =3D (struct efx_channel *)priv;
+	struct efx_channel *channel =3D priv;
 	struct iphdr *iph;
 	struct tcphdr *th;
=20
@@ -131,12 +134,12 @@ static int efx_get_frag_hdr(struct skb_frag_struc=
t *frag, void **mac_hdr,
 			    void **ip_hdr, void **tcpudp_hdr, u64 *hdr_flags,
 			    void *priv)
 {
-	struct efx_channel *channel =3D (struct efx_channel *)priv;
+	struct efx_channel *channel =3D priv;
 	struct ethhdr *eh;
 	struct iphdr *iph;
=20
 	/* We support EtherII and VLAN encapsulated IPv4 */
-	eh =3D (struct ethhdr *)(page_address(frag->page) + frag->page_offset=
);
+	eh =3D page_address(frag->page) + frag->page_offset;
 	*mac_hdr =3D eh;
=20
 	if (eh->h_proto =3D=3D htons(ETH_P_IP)) {
@@ -269,7 +272,7 @@ static inline int efx_init_rx_buffer_page(struct ef=
x_rx_queue *rx_queue,
 			return -ENOMEM;
=20
 		dma_addr =3D pci_map_page(efx->pci_dev, rx_buf->page,
-					0, RX_PAGE_SIZE(efx),
+					0, efx_rx_buf_size(efx),
 					PCI_DMA_FROMDEVICE);
=20
 		if (unlikely(pci_dma_mapping_error(dma_addr))) {
@@ -280,14 +283,14 @@ static inline int efx_init_rx_buffer_page(struct =
efx_rx_queue *rx_queue,
=20
 		rx_queue->buf_page =3D rx_buf->page;
 		rx_queue->buf_dma_addr =3D dma_addr;
-		rx_queue->buf_data =3D ((char *) page_address(rx_buf->page) +
+		rx_queue->buf_data =3D (page_address(rx_buf->page) +
 				      EFX_PAGE_IP_ALIGN);
 	}
=20
-	offset =3D RX_DATA_OFFSET(rx_queue->buf_data);
 	rx_buf->len =3D bytes;
-	rx_buf->dma_addr =3D rx_queue->buf_dma_addr + offset;
 	rx_buf->data =3D rx_queue->buf_data;
+	offset =3D efx_rx_buf_offset(rx_buf);
+	rx_buf->dma_addr =3D rx_queue->buf_dma_addr + offset;
=20
 	/* Try to pack multiple buffers per page */
 	if (efx->rx_buffer_order =3D=3D 0) {
@@ -295,7 +298,7 @@ static inline int efx_init_rx_buffer_page(struct ef=
x_rx_queue *rx_queue,
 		rx_queue->buf_data +=3D ((bytes + 0x1ff) & ~0x1ff);
 		offset +=3D ((bytes + 0x1ff) & ~0x1ff);
=20
-		space =3D RX_PAGE_SIZE(efx) - offset;
+		space =3D efx_rx_buf_size(efx) - offset;
 		if (space >=3D bytes) {
 			/* Refs dropped on kernel releasing each skb */
 			get_page(rx_queue->buf_page);
@@ -344,7 +347,8 @@ static inline void efx_unmap_rx_buffer(struct efx_n=
ic *efx,
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
 		if (rx_buf->unmap_addr) {
 			pci_unmap_page(efx->pci_dev, rx_buf->unmap_addr,
-				       RX_PAGE_SIZE(efx), PCI_DMA_FROMDEVICE);
+				       efx_rx_buf_size(efx),
+				       PCI_DMA_FROMDEVICE);
 			rx_buf->unmap_addr =3D 0;
 		}
 	} else if (likely(rx_buf->skb)) {
@@ -400,9 +404,10 @@ static int __efx_fast_push_rx_descriptors(struct e=
fx_rx_queue *rx_queue,
 		return 0;
=20
 	/* Record minimum fill level */
-	if (unlikely(fill_level < rx_queue->min_fill))
+	if (unlikely(fill_level < rx_queue->min_fill)) {
 		if (fill_level)
 			rx_queue->min_fill =3D fill_level;
+	}
=20
 	/* Acquire RX add lock.  If this lock is contended, then a fast
 	 * fill must already be in progress (e.g. in the refill
@@ -552,7 +557,7 @@ static inline void efx_rx_packet_lro(struct efx_cha=
nnel *channel,
 		struct skb_frag_struct frags;
=20
 		frags.page =3D rx_buf->page;
-		frags.page_offset =3D RX_BUF_OFFSET(rx_buf);
+		frags.page_offset =3D efx_rx_buf_offset(rx_buf);
 		frags.size =3D rx_buf->len;
=20
 		lro_receive_frags(lro_mgr, &frags, rx_buf->len,
@@ -597,7 +602,7 @@ static inline struct sk_buff *efx_rx_mk_skb(struct =
efx_rx_buffer *rx_buf,
 	if (unlikely(rx_buf->len > hdr_len)) {
 		struct skb_frag_struct *frag =3D skb_shinfo(skb)->frags;
 		frag->page =3D rx_buf->page;
-		frag->page_offset =3D RX_BUF_OFFSET(rx_buf) + hdr_len;
+		frag->page_offset =3D efx_rx_buf_offset(rx_buf) + hdr_len;
 		frag->size =3D skb->len - hdr_len;
 		skb_shinfo(skb)->nr_frags =3D 1;
 		skb->data_len =3D frag->size;
@@ -851,7 +856,8 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queu=
e)
 	/* For a page that is part-way through splitting into RX buffers */
 	if (rx_queue->buf_page !=3D NULL) {
 		pci_unmap_page(rx_queue->efx->pci_dev, rx_queue->buf_dma_addr,
-			       RX_PAGE_SIZE(rx_queue->efx), PCI_DMA_FROMDEVICE);
+			       efx_rx_buf_size(rx_queue->efx),
+			       PCI_DMA_FROMDEVICE);
 		__free_pages(rx_queue->buf_page,
 			     rx_queue->efx->rx_buffer_order);
 		rx_queue->buf_page =3D NULL;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index cbda159..3b2de9f 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -290,7 +290,7 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
=20
 	payload =3D &state->payload;
 =09
-	received =3D (struct efx_loopback_payload *)(char *) buf_ptr;
+	received =3D (struct efx_loopback_payload *) buf_ptr;
 	received->ip.saddr =3D payload->ip.saddr;
 	received->ip.check =3D payload->ip.check;
 =09
@@ -424,10 +424,10 @@ static int efx_tx_loopback(struct efx_tx_queue *t=
x_queue)
 		 * interrupt handler. */
 		smp_wmb();
=20
-		if (NET_DEV_REGISTERED(efx))
+		if (efx_dev_registered(efx))
 			netif_tx_lock_bh(efx->net_dev);
 		rc =3D efx_xmit(efx, tx_queue, skb);
-		if (NET_DEV_REGISTERED(efx))
+		if (efx_dev_registered(efx))
 			netif_tx_unlock_bh(efx->net_dev);
=20
 		if (rc !=3D NETDEV_TX_OK) {
@@ -453,7 +453,7 @@ static int efx_rx_loopback(struct efx_tx_queue *tx_=
queue,
 	int tx_done =3D 0, rx_good, rx_bad;
 	int i, rc =3D 0;
=20
-	if (NET_DEV_REGISTERED(efx))
+	if (efx_dev_registered(efx))
 		netif_tx_lock_bh(efx->net_dev);
=20
 	/* Count the number of tx completions, and decrement the refcnt. Any
@@ -465,7 +465,7 @@ static int efx_rx_loopback(struct efx_tx_queue *tx_=
queue,
 		dev_kfree_skb_any(skb);
 	}
=20
-	if (NET_DEV_REGISTERED(efx))
+	if (efx_dev_registered(efx))
 		netif_tx_unlock_bh(efx->net_dev);
=20
 	/* Check TX completion and received packet counts */
@@ -517,6 +517,8 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 		state->packet_count =3D min(1 << (i << 2), state->packet_count);
 		state->skbs =3D kzalloc(sizeof(state->skbs[0]) *
 				      state->packet_count, GFP_KERNEL);
+		if (!state->skbs)
+			return -ENOMEM;
 		state->flush =3D 0;
=20
 		EFX_LOG(efx, "TX queue %d testing %s loopback with %d "
@@ -700,7 +702,7 @@ int efx_offline_test(struct efx_nic *efx,
 	 * "flushing" so all inflight packets are dropped */
 	BUG_ON(efx->loopback_selftest);
 	state->flush =3D 1;
-	efx->loopback_selftest =3D (void *)state;
+	efx->loopback_selftest =3D state;
=20
 	rc =3D efx_test_loopbacks(efx, tests, loopback_modes);
=20
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 725d1a5..66a0d14 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -116,18 +116,18 @@ void sfe4001_poweroff(struct efx_nic *efx)
=20
 	/* Turn off all power rails */
 	out =3D 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+	efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
=20
 	/* Disable port 1 outputs on IO expander */
 	cfg =3D 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P1_CONFIG, &cfg, 1);
+	efx_i2c_write(i2c, PCA9539, P1_CONFIG, &cfg, 1);
=20
 	/* Disable port 0 outputs on IO expander */
 	cfg =3D 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P0_CONFIG, &cfg, 1);
+	efx_i2c_write(i2c, PCA9539, P0_CONFIG, &cfg, 1);
=20
 	/* Clear any over-temperature alert */
-	(void) efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
+	efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
 }
=20
 /* The P0_EN_3V3X line on SFE4001 boards (from A2 onward) is connected
@@ -253,14 +253,14 @@ done:
 fail3:
 	/* Turn off all power rails */
 	out =3D 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+	efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
 	/* Disable port 1 outputs on IO expander */
 	out =3D 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P1_CONFIG, &out, 1);
+	efx_i2c_write(i2c, PCA9539, P1_CONFIG, &out, 1);
 fail2:
 	/* Disable port 0 outputs on IO expander */
 	out =3D 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P0_CONFIG, &out, 1);
+	efx_i2c_write(i2c, PCA9539, P0_CONFIG, &out, 1);
 fail1:
 	return rc;
 }
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index b1cd6de..c014606 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -211,6 +211,8 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	int rc =3D 0;
=20
 	phy_data =3D kzalloc(sizeof(*phy_data), GFP_KERNEL);
+	if (!phy_data)
+		return -ENOMEM;
 	efx->phy_data =3D phy_data;
=20
 	tenxpress_set_state(efx, TENXPRESS_STATUS_NORMAL);
@@ -376,7 +378,7 @@ static void tenxpress_phy_reconfigure(struct efx_ni=
c *efx)
 	 * perform a special software reset */
 	if ((phy_data->tx_disabled && !efx->tx_disabled) ||
 	    loop_change) {
-		(void) tenxpress_special_reset(efx);
+		tenxpress_special_reset(efx);
 		falcon_reset_xaui(efx);
 	}
=20
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 9b436f5..5cdd082 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -387,7 +387,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, u=
nsigned int index)
 	if (unlikely(tx_queue->stopped)) {
 		fill_level =3D tx_queue->insert_count - tx_queue->read_count;
 		if (fill_level < EFX_NETDEV_TX_THRESHOLD(tx_queue)) {
-			EFX_BUG_ON_PARANOID(!NET_DEV_REGISTERED(efx));
+			EFX_BUG_ON_PARANOID(!efx_dev_registered(efx));
=20
 			/* Do this under netif_tx_lock(), to avoid racing
 			 * with efx_xmit(). */
@@ -639,11 +639,12 @@ static void efx_tsoh_block_free(struct efx_tx_que=
ue *tx_queue,
 	base_dma =3D tsoh->dma_addr & PAGE_MASK;
=20
 	p =3D &tx_queue->tso_headers_free;
-	while (*p !=3D NULL)
+	while (*p !=3D NULL) {
 		if (((unsigned long)*p & PAGE_MASK) =3D=3D base_kva)
 			*p =3D (*p)->next;
 		else
 			p =3D &(*p)->next;
+	}
=20
 	pci_free_consistent(pci_dev, PAGE_SIZE, (void *)base_kva, base_dma);
 }
@@ -939,9 +940,10 @@ static inline int tso_start_new_packet(struct efx_=
tx_queue *tx_queue,
=20
 	/* Allocate a DMA-mapped header buffer. */
 	if (likely(TSOH_SIZE(st->p.header_length) <=3D TSOH_STD_SIZE)) {
-		if (tx_queue->tso_headers_free =3D=3D NULL)
+		if (tx_queue->tso_headers_free =3D=3D NULL) {
 			if (efx_tsoh_block_alloc(tx_queue))
 				return -1;
+		}
 		EFX_BUG_ON_PARANOID(!tx_queue->tso_headers_free);
 		tsoh =3D tx_queue->tso_headers_free;
 		tx_queue->tso_headers_free =3D tsoh->next;
@@ -1106,9 +1108,10 @@ static void efx_fini_tso(struct efx_tx_queue *tx=
_queue)
 {
 	unsigned i;
=20
-	if (tx_queue->buffer)
+	if (tx_queue->buffer) {
 		for (i =3D 0; i <=3D tx_queue->efx->type->txd_ring_mask; ++i)
 			efx_tsoh_free(tx_queue, &tx_queue->buffer[i]);
+	}
=20
 	while (tx_queue->tso_headers_free !=3D NULL)
 		efx_tsoh_block_free(tx_queue, tx_queue->tso_headers_free,
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workaround=
s.h
index dca62f1..35ab19c 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -16,7 +16,7 @@
  */
=20
 #define EFX_WORKAROUND_ALWAYS(efx) 1
-#define EFX_WORKAROUND_FALCON_A(efx) (FALCON_REV(efx) <=3D FALCON_REV_=
A1)
+#define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <=3D FALCON_REV_=
A1)
=20
 /* XAUI resets if link not detected */
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 3b9f9dd..f3684ad 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -85,7 +85,9 @@ static int xfp_phy_init(struct efx_nic *efx)
 	int rc;
=20
 	phy_data =3D kzalloc(sizeof(struct xfp_phy_data), GFP_KERNEL);
-	efx->phy_data =3D (void *) phy_data;
+	if (!phy_data)
+		return -ENOMEM;
+	efx->phy_data =3D phy_data;
=20
 	EFX_INFO(efx, "XFP: PHY ID reg %x (OUI %x model %x revision"
 		 " %x)\n", devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index f226bca..3bb6053 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1159,17 +1159,9 @@ static int sky2_ioctl(struct net_device *dev, st=
ruct ifreq *ifr, int cmd)
 }
=20
 #ifdef SKY2_VLAN_TAG_USED
-static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_=
group *grp)
+static void sky2_set_vlan_mode(struct sky2_hw *hw, u16 port, bool onof=
f)
 {
-	struct sky2_port *sky2 =3D netdev_priv(dev);
-	struct sky2_hw *hw =3D sky2->hw;
-	u16 port =3D sky2->port;
-
-	netif_tx_lock_bh(dev);
-	napi_disable(&hw->napi);
-
-	sky2->vlgrp =3D grp;
-	if (grp) {
+	if (onoff) {
 		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
 			     RX_VLAN_STRIP_ON);
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
@@ -1180,6 +1172,19 @@ static void sky2_vlan_rx_register(struct net_dev=
ice *dev, struct vlan_group *grp
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
 			     TX_VLAN_TAG_OFF);
 	}
+}
+
+static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_=
group *grp)
+{
+	struct sky2_port *sky2 =3D netdev_priv(dev);
+	struct sky2_hw *hw =3D sky2->hw;
+	u16 port =3D sky2->port;
+
+	netif_tx_lock_bh(dev);
+	napi_disable(&hw->napi);
+
+	sky2->vlgrp =3D grp;
+	sky2_set_vlan_mode(hw, port, grp !=3D NULL);
=20
 	sky2_read32(hw, B0_Y2_SP_LISR);
 	napi_enable(&hw->napi);
@@ -1418,6 +1423,10 @@ static int sky2_up(struct net_device *dev)
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   TX_RING_SIZE - 1);
=20
+#ifdef SKY2_VLAN_TAG_USED
+	sky2_set_vlan_mode(hw, port, sky2->vlgrp !=3D NULL);
+#endif
+
 	err =3D sky2_rx_start(sky2);
 	if (err)
 		goto err_out;
diff --git a/drivers/net/tokenring/3c359.h b/drivers/net/tokenring/3c35=
9.h
index b880cba..74cf8e1 100644
--- a/drivers/net/tokenring/3c359.h
+++ b/drivers/net/tokenring/3c359.h
@@ -264,7 +264,7 @@ struct xl_private {
 	u16 asb;
=20
 	u8 __iomem *xl_mmio;
-	char *xl_card_name;
+	const char *xl_card_name;
 	struct pci_dev *pdev ;=20
 =09
 	spinlock_t xl_lock ;=20
diff --git a/drivers/net/tokenring/olympic.h b/drivers/net/tokenring/ol=
ympic.h
index c919563..10fbba0 100644
--- a/drivers/net/tokenring/olympic.h
+++ b/drivers/net/tokenring/olympic.h
@@ -254,7 +254,7 @@ struct olympic_private {
 	u8 __iomem *olympic_mmio;
 	u8 __iomem *olympic_lap;
 	struct pci_dev *pdev ;=20
-	char *olympic_card_name ;=20
+	const char *olympic_card_name;
=20
 	spinlock_t olympic_lock ;=20
=20
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 2511ca7..e9e6286 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -225,6 +225,9 @@ static void uli526x_set_filter_mode(struct net_devi=
ce *);
 static const struct ethtool_ops netdev_ethtool_ops;
 static u16 read_srom_word(long, int);
 static irqreturn_t uli526x_interrupt(int, void *);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void uli526x_poll(struct net_device *dev);
+#endif
 static void uli526x_descriptor_init(struct uli526x_board_info *, unsig=
ned long);
 static void allocate_rx_buffer(struct uli526x_board_info *);
 static void update_cr6(u32, unsigned long);
@@ -339,6 +342,9 @@ static int __devinit uli526x_init_one (struct pci_d=
ev *pdev,
 	dev->get_stats =3D &uli526x_get_stats;
 	dev->set_multicast_list =3D &uli526x_set_filter_mode;
 	dev->ethtool_ops =3D &netdev_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =3D &uli526x_poll;
+#endif
 	spin_lock_init(&db->lock);
=20
=20
@@ -681,8 +687,9 @@ static irqreturn_t uli526x_interrupt(int irq, void =
*dev_id)
 	db->cr5_data =3D inl(ioaddr + DCR5);
 	outl(db->cr5_data, ioaddr + DCR5);
 	if ( !(db->cr5_data & 0x180c1) ) {
-		spin_unlock_irqrestore(&db->lock, flags);
+		/* Restore CR7 to enable interrupt mask */
 		outl(db->cr7_data, ioaddr + DCR7);
+		spin_unlock_irqrestore(&db->lock, flags);
 		return IRQ_HANDLED;
 	}
=20
@@ -715,6 +722,13 @@ static irqreturn_t uli526x_interrupt(int irq, void=
 *dev_id)
 	return IRQ_HANDLED;
 }
=20
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void uli526x_poll(struct net_device *dev)
+{
+	/* ISR grabs the irqsave lock, so this should be safe */
+	uli526x_interrupt(dev->irq, dev);
+}
+#endif
=20
 /*
  *	Free TX resource after TX complete
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index ca0bdac..fb0b918 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -237,7 +237,7 @@ static struct sk_buff *get_new_skb(struct ucc_geth_=
private *ugeth,
 	skb->dev =3D ugeth->dev;
=20
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
-		      dma_map_single(NULL,
+		      dma_map_single(&ugeth->dev->dev,
 				     skb->data,
 				     ugeth->ug_info->uf_info.max_rx_buf_length +
 				     UCC_GETH_RX_DATA_BUF_ALIGNMENT,
@@ -2158,7 +2158,7 @@ static void ucc_geth_memclean(struct ucc_geth_pri=
vate *ugeth)
 			continue;
 		for (j =3D 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
 			if (ugeth->tx_skbuff[i][j]) {
-				dma_unmap_single(NULL,
+				dma_unmap_single(&ugeth->dev->dev,
 						 in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						 (in_be32((u32 __iomem *)bd) &
 						  BD_LENGTH_MASK),
@@ -2186,7 +2186,7 @@ static void ucc_geth_memclean(struct ucc_geth_pri=
vate *ugeth)
 			bd =3D ugeth->p_rx_bd_ring[i];
 			for (j =3D 0; j < ugeth->ug_info->bdRingLenRx[i]; j++) {
 				if (ugeth->rx_skbuff[i][j]) {
-					dma_unmap_single(NULL,
+					dma_unmap_single(&ugeth->dev->dev,
 						in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						ugeth->ug_info->
 						uf_info.max_rx_buf_length +
@@ -3406,7 +3406,8 @@ static int ucc_geth_start_xmit(struct sk_buff *sk=
b, struct net_device *dev)
=20
 	/* set up the buffer descriptor */
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
-		      dma_map_single(NULL, skb->data, skb->len, DMA_TO_DEVICE));
+		      dma_map_single(&ugeth->dev->dev, skb->data,
+			      skb->len, DMA_TO_DEVICE));
=20
 	/* printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data); */
=20
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index dc6f097..37ecf84 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1440,6 +1440,10 @@ static const struct usb_device_id	products [] =3D=
 {
 	// Belkin F5D5055
 	USB_DEVICE(0x050d, 0x5055),
 	.driver_info =3D (unsigned long) &ax88178_info,
+}, {
+	// Apple USB Ethernet Adapter
+	USB_DEVICE(0x05ac, 0x1402),
+	.driver_info =3D (unsigned long) &ax88772_info,
 },
 	{ },		// END
 };
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.=
c
index 21a7785..e1177cc 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -194,7 +194,7 @@ int rndis_command(struct usbnet *dev, struct rndis_=
msg_hdr *buf)
 			dev_dbg(&info->control->dev,
 				"rndis response error, code %d\n", retval);
 		}
-		msleep(2);
+		msleep(20);
 	}
 	dev_dbg(&info->control->dev, "rndis response timeout\n");
 	return -ETIMEDOUT;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f926b5a..fe7cdf2 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -470,8 +470,7 @@ static void virtnet_remove(struct virtio_device *vd=
ev)
 		kfree_skb(skb);
 		vi->num--;
 	}
-	while ((skb =3D __skb_dequeue(&vi->send)) !=3D NULL)
-		kfree_skb(skb);
+	__skb_queue_purge(&vi->send);
=20
 	BUG_ON(vi->num !=3D 0);
=20
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 9a83c9d..7f98489 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -43,8 +43,7 @@ static const char* version =3D "HDLC support module r=
evision 1.22";
=20
 #undef DEBUG_LINK
=20
-static struct hdlc_proto *first_proto =3D NULL;
-
+static struct hdlc_proto *first_proto;
=20
 static int hdlc_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -314,21 +313,25 @@ void detach_hdlc_protocol(struct net_device *dev)
=20
 void register_hdlc_protocol(struct hdlc_proto *proto)
 {
+	rtnl_lock();
 	proto->next =3D first_proto;
 	first_proto =3D proto;
+	rtnl_unlock();
 }
=20
=20
 void unregister_hdlc_protocol(struct hdlc_proto *proto)
 {
-	struct hdlc_proto **p =3D &first_proto;
-	while (*p) {
-		if (*p =3D=3D proto) {
-			*p =3D proto->next;
-			return;
-		}
+	struct hdlc_proto **p;
+
+	rtnl_lock();
+	p =3D &first_proto;
+	while (*p !=3D proto) {
+		BUG_ON(!*p);
 		p =3D &((*p)->next);
 	}
+	*p =3D proto->next;
+	rtnl_unlock();
 }
=20
=20
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.=
c
index 7133c68..762d21c 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -56,6 +56,7 @@ struct cisco_state {
 	cisco_proto settings;
=20
 	struct timer_list timer;
+	spinlock_t lock;
 	unsigned long last_poll;
 	int up;
 	int request_sent;
@@ -158,6 +159,7 @@ static int cisco_rx(struct sk_buff *skb)
 {
 	struct net_device *dev =3D skb->dev;
 	hdlc_device *hdlc =3D dev_to_hdlc(dev);
+	struct cisco_state *st =3D state(hdlc);
 	struct hdlc_header *data =3D (struct hdlc_header*)skb->data;
 	struct cisco_packet *cisco_data;
 	struct in_device *in_dev;
@@ -220,11 +222,12 @@ static int cisco_rx(struct sk_buff *skb)
 			goto rx_error;
=20
 		case CISCO_KEEPALIVE_REQ:
-			state(hdlc)->rxseq =3D ntohl(cisco_data->par1);
-			if (state(hdlc)->request_sent &&
-			    ntohl(cisco_data->par2) =3D=3D state(hdlc)->txseq) {
-				state(hdlc)->last_poll =3D jiffies;
-				if (!state(hdlc)->up) {
+			spin_lock(&st->lock);
+			st->rxseq =3D ntohl(cisco_data->par1);
+			if (st->request_sent &&
+			    ntohl(cisco_data->par2) =3D=3D st->txseq) {
+				st->last_poll =3D jiffies;
+				if (!st->up) {
 					u32 sec, min, hrs, days;
 					sec =3D ntohl(cisco_data->time) / 1000;
 					min =3D sec / 60; sec -=3D min * 60;
@@ -232,12 +235,12 @@ static int cisco_rx(struct sk_buff *skb)
 					days =3D hrs / 24; hrs -=3D days * 24;
 					printk(KERN_INFO "%s: Link up (peer "
 					       "uptime %ud%uh%um%us)\n",
-					       dev->name, days, hrs,
-					       min, sec);
+					       dev->name, days, hrs, min, sec);
 					netif_dormant_off(dev);
-					state(hdlc)->up =3D 1;
+					st->up =3D 1;
 				}
 			}
+			spin_unlock(&st->lock);
=20
 			dev_kfree_skb_any(skb);
 			return NET_RX_SUCCESS;
@@ -261,24 +264,25 @@ static void cisco_timer(unsigned long arg)
 {
 	struct net_device *dev =3D (struct net_device *)arg;
 	hdlc_device *hdlc =3D dev_to_hdlc(dev);
+	struct cisco_state *st =3D state(hdlc);
=20
-	if (state(hdlc)->up &&
-	    time_after(jiffies, state(hdlc)->last_poll +
-		       state(hdlc)->settings.timeout * HZ)) {
-		state(hdlc)->up =3D 0;
+	spin_lock(&st->lock);
+	if (st->up &&
+	    time_after(jiffies, st->last_poll + st->settings.timeout * HZ)) {
+		st->up =3D 0;
 		printk(KERN_INFO "%s: Link down\n", dev->name);
 		netif_dormant_on(dev);
 	}
=20
-	cisco_keepalive_send(dev, CISCO_KEEPALIVE_REQ,
-			     htonl(++state(hdlc)->txseq),
-			     htonl(state(hdlc)->rxseq));
-	state(hdlc)->request_sent =3D 1;
-	state(hdlc)->timer.expires =3D jiffies +
-		state(hdlc)->settings.interval * HZ;
-	state(hdlc)->timer.function =3D cisco_timer;
-	state(hdlc)->timer.data =3D arg;
-	add_timer(&state(hdlc)->timer);
+	cisco_keepalive_send(dev, CISCO_KEEPALIVE_REQ, htonl(++st->txseq),
+			     htonl(st->rxseq));
+	st->request_sent =3D 1;
+	spin_unlock(&st->lock);
+
+	st->timer.expires =3D jiffies + st->settings.interval * HZ;
+	st->timer.function =3D cisco_timer;
+	st->timer.data =3D arg;
+	add_timer(&st->timer);
 }
=20
=20
@@ -286,15 +290,20 @@ static void cisco_timer(unsigned long arg)
 static void cisco_start(struct net_device *dev)
 {
 	hdlc_device *hdlc =3D dev_to_hdlc(dev);
-	state(hdlc)->up =3D 0;
-	state(hdlc)->request_sent =3D 0;
-	state(hdlc)->txseq =3D state(hdlc)->rxseq =3D 0;
-
-	init_timer(&state(hdlc)->timer);
-	state(hdlc)->timer.expires =3D jiffies + HZ; /*First poll after 1s*/
-	state(hdlc)->timer.function =3D cisco_timer;
-	state(hdlc)->timer.data =3D (unsigned long)dev;
-	add_timer(&state(hdlc)->timer);
+	struct cisco_state *st =3D state(hdlc);
+	unsigned long flags;
+
+	spin_lock_irqsave(&st->lock, flags);
+	st->up =3D 0;
+	st->request_sent =3D 0;
+	st->txseq =3D st->rxseq =3D 0;
+	spin_unlock_irqrestore(&st->lock, flags);
+
+	init_timer(&st->timer);
+	st->timer.expires =3D jiffies + HZ; /* First poll after 1 s */
+	st->timer.function =3D cisco_timer;
+	st->timer.data =3D (unsigned long)dev;
+	add_timer(&st->timer);
 }
=20
=20
@@ -302,10 +311,16 @@ static void cisco_start(struct net_device *dev)
 static void cisco_stop(struct net_device *dev)
 {
 	hdlc_device *hdlc =3D dev_to_hdlc(dev);
-	del_timer_sync(&state(hdlc)->timer);
+	struct cisco_state *st =3D state(hdlc);
+	unsigned long flags;
+
+	del_timer_sync(&st->timer);
+
+	spin_lock_irqsave(&st->lock, flags);
 	netif_dormant_on(dev);
-	state(hdlc)->up =3D 0;
-	state(hdlc)->request_sent =3D 0;
+	st->up =3D 0;
+	st->request_sent =3D 0;
+	spin_unlock_irqrestore(&st->lock, flags);
 }
=20
=20
@@ -367,6 +382,7 @@ static int cisco_ioctl(struct net_device *dev, stru=
ct ifreq *ifr)
 			return result;
=20
 		memcpy(&state(hdlc)->settings, &new_settings, size);
+		spin_lock_init(&state(hdlc)->lock);
 		dev->hard_start_xmit =3D hdlc->xmit;
 		dev->header_ops =3D &cisco_header_ops;
 		dev->type =3D ARPHRD_CISCO;
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 8bddff1..d26f69b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -946,8 +946,7 @@ err:
 		work_done++;
 	}
=20
-	while ((skb =3D __skb_dequeue(&errq)))
-		kfree_skb(skb);
+	__skb_queue_purge(&errq);
=20
 	work_done -=3D handle_incoming_queue(dev, &rxq);
=20
@@ -1079,8 +1078,7 @@ static void xennet_release_rx_bufs(struct netfron=
t_info *np)
 		}
 	}
=20
-	while ((skb =3D __skb_dequeue(&free_list)) !=3D NULL)
-		dev_kfree_skb(skb);
+	__skb_queue_purge(&free_list);
=20
 	spin_unlock_bh(&np->rx_lock);
 }
