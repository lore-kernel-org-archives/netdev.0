From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] net: refactor multicast/unicast address list
Date: Sat, 13 Jun 2009 12:41:18 +0200
Message-ID: <1244889678.13033.6.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:56105 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbZFMKkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 06:40:53 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <johannes@sipsolutions.net>)
	id 1MFQf2-0005f5-Cr
	for netdev@vger.kernel.org; Sat, 13 Jun 2009 12:40:50 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to use address lists without netdevs, but as
a first step I thought it would be good to reduce the
amount duplicated code between unicast and multicast
lists.

After introducing a new 'struct address_list', we can
unify a lot between these. The next step will probably
be exporting the __dev_addr_sync and __dev_addr_unsync
functions so I can use them without a netdev, but this
cleanup can stand on its own.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
Also reduces the number of exported symbols by 4.

 arch/xtensa/platforms/iss/network.c            |    2 
 drivers/infiniband/hw/nes/nes_nic.c            |    4 
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    2 
 drivers/media/dvb/dvb-core/dvb_net.c           |   10 -
 drivers/net/3c501.c                            |    2 
 drivers/net/3c505.c                            |    8 -
 drivers/net/3c509.c                            |    8 -
 drivers/net/3c515.c                            |    2 
 drivers/net/3c523.c                            |    6 
 drivers/net/3c527.c                            |   12 -
 drivers/net/3c59x.c                            |    2 
 drivers/net/7990.c                             |    4 
 drivers/net/8139cp.c                           |    4 
 drivers/net/8139too.c                          |    4 
 drivers/net/82596.c                            |   10 -
 drivers/net/a2065.c                            |    4 
 drivers/net/acenic.c                           |    2 
 drivers/net/amd8111e.c                         |   10 -
 drivers/net/appletalk/ltpc.c                   |    2 
 drivers/net/ariadne.c                          |    2 
 drivers/net/arm/am79c961a.c                    |    2 
 drivers/net/arm/at91_ether.c                   |    6 
 drivers/net/arm/ether3.c                       |    2 
 drivers/net/arm/ixp4xx_eth.c                   |    4 
 drivers/net/arm/ks8695net.c                    |    6 
 drivers/net/at1700.c                           |    6 
 drivers/net/atarilance.c                       |    2 
 drivers/net/atl1c/atl1c_main.c                 |    2 
 drivers/net/atl1e/atl1e_main.c                 |    2 
 drivers/net/atlx/atl2.c                        |    2 
 drivers/net/atlx/atlx.c                        |    2 
 drivers/net/atp.c                              |    6 
 drivers/net/au1000_eth.c                       |    4 
 drivers/net/b44.c                              |    6 
 drivers/net/benet/be_main.c                    |    2 
 drivers/net/bfin_mac.c                         |    6 
 drivers/net/bmac.c                             |   12 -
 drivers/net/bnx2.c                             |    8 -
 drivers/net/bnx2x_main.c                       |   10 -
 drivers/net/bonding/bond_main.c                |   16 +-
 drivers/net/cassini.c                          |    2 
 drivers/net/chelsio/common.h                   |    4 
 drivers/net/chelsio/cxgb2.c                    |    2 
 drivers/net/cpmac.c                            |    2 
 drivers/net/cris/eth_v10.c                     |    4 
 drivers/net/cs89x0.c                           |    2 
 drivers/net/cxgb3/common.h                     |    2 
 drivers/net/cxgb3/cxgb3_main.c                 |    4 
 drivers/net/de620.c                            |    2 
 drivers/net/declance.c                         |    4 
 drivers/net/defxx.c                            |    6 
 drivers/net/depca.c                            |    4 
 drivers/net/dl2k.c                             |    6 
 drivers/net/dm9000.c                           |    4 
 drivers/net/e100.c                             |    8 -
 drivers/net/e1000/e1000_main.c                 |    6 
 drivers/net/e1000e/netdev.c                    |    8 -
 drivers/net/eepro.c                            |   16 +-
 drivers/net/eexpress.c                         |    8 -
 drivers/net/ehea/ehea_main.c                   |    6 
 drivers/net/enc28j60.c                         |    2 
 drivers/net/enic/enic_main.c                   |    6 
 drivers/net/epic100.c                          |    6 
 drivers/net/eth16i.c                           |    2 
 drivers/net/ethoc.c                            |    2 
 drivers/net/ewrk3.c                            |    4 
 drivers/net/fealnx.c                           |    4 
 drivers/net/fec.c                              |    4 
 drivers/net/fec_mpc52xx.c                      |    4 
 drivers/net/forcedeth.c                        |    4 
 drivers/net/fs_enet/mac-fcc.c                  |    4 
 drivers/net/fs_enet/mac-fec.c                  |    4 
 drivers/net/fs_enet/mac-scc.c                  |    4 
 drivers/net/gianfar.c                          |    4 
 drivers/net/hamachi.c                          |    6 
 drivers/net/hp100.c                            |    6 
 drivers/net/ibm_newemac/core.c                 |    8 -
 drivers/net/ibmlana.c                          |    2 
 drivers/net/ibmveth.c                          |    6 
 drivers/net/igb/igb_main.c                     |    8 -
 drivers/net/igbvf/netdev.c                     |    8 -
 drivers/net/ioc3-eth.c                         |    6 
 drivers/net/ipg.c                              |    6 
 drivers/net/isa-skeleton.c                     |    6 
 drivers/net/iseries_veth.c                     |    6 
 drivers/net/ixgb/ixgb_main.c                   |    8 -
 drivers/net/ixgbe/ixgbe_main.c                 |    8 -
 drivers/net/jme.c                              |    4 
 drivers/net/korina.c                           |    8 -
 drivers/net/lance.c                            |    2 
 drivers/net/lib82596.c                         |   10 -
 drivers/net/lib8390.c                          |    6 
 drivers/net/lp486e.c                           |   12 -
 drivers/net/mac89x0.c                          |    2 
 drivers/net/macb.c                             |    6 
 drivers/net/mace.c                             |    4 
 drivers/net/macmace.c                          |    4 
 drivers/net/mlx4/en_netdev.c                   |    2 
 drivers/net/mv643xx_eth.c                      |    4 
 drivers/net/myri10ge/myri10ge.c                |    2 
 drivers/net/natsemi.c                          |    4 
 drivers/net/netxen/netxen_nic_hw.c             |   14 -
 drivers/net/ni5010.c                           |    2 
 drivers/net/ni52.c                             |    4 
 drivers/net/ni65.c                             |    2 
 drivers/net/niu.c                              |   10 -
 drivers/net/ns83820.c                          |    2 
 drivers/net/pci-skeleton.c                     |    4 
 drivers/net/pcmcia/3c574_cs.c                  |    2 
 drivers/net/pcmcia/3c589_cs.c                  |    2 
 drivers/net/pcmcia/axnet_cs.c                  |    6 
 drivers/net/pcmcia/fmvj18x_cs.c                |    6 
 drivers/net/pcmcia/nmclan_cs.c                 |   16 +-
 drivers/net/pcmcia/smc91c92_cs.c               |    4 
 drivers/net/pcmcia/xirc2ps_cs.c                |   10 -
 drivers/net/pcnet32.c                          |    4 
 drivers/net/ps3_gelic_net.c                    |    4 
 drivers/net/qlge/qlge_main.c                   |    6 
 drivers/net/r6040.c                            |   12 -
 drivers/net/r8169.c                            |    4 
 drivers/net/s2io.c                             |    8 -
 drivers/net/sb1250-mac.c                       |    2 
 drivers/net/sc92031.c                          |    4 
 drivers/net/sfc/efx.c                          |    4 
 drivers/net/sgiseeq.c                          |    2 
 drivers/net/sis190.c                           |    4 
 drivers/net/sis900.c                           |    6 
 drivers/net/skfp/skfddi.c                      |    8 -
 drivers/net/skge.c                             |   10 -
 drivers/net/sky2.c                             |    6 
 drivers/net/smc911x.c                          |    8 -
 drivers/net/smc9194.c                          |    4 
 drivers/net/smc91x.c                           |    8 -
 drivers/net/smsc911x.c                         |    8 -
 drivers/net/smsc9420.c                         |    4 
 drivers/net/sonic.c                            |    8 -
 drivers/net/spider_net.c                       |    2 
 drivers/net/starfire.c                         |    8 -
 drivers/net/sun3_82586.c                       |    4 
 drivers/net/sun3lance.c                        |    2 
 drivers/net/sunbmac.c                          |    6 
 drivers/net/sundance.c                         |    6 
 drivers/net/sungem.c                           |    6 
 drivers/net/sunhme.c                           |   12 -
 drivers/net/sunlance.c                         |    4 
 drivers/net/sunqe.c                            |    6 
 drivers/net/sunvnet.c                          |    2 
 drivers/net/tc35815.c                          |    8 -
 drivers/net/tehuti.c                           |    6 
 drivers/net/tg3.c                              |    4 
 drivers/net/tlan.c                             |    4 
 drivers/net/tokenring/3c359.c                  |    2 
 drivers/net/tokenring/ibmtr.c                  |    4 
 drivers/net/tokenring/lanstreamer.c            |    2 
 drivers/net/tokenring/olympic.c                |    2 
 drivers/net/tokenring/tms380tr.c               |    4 
 drivers/net/tsi108_eth.c                       |    4 
 drivers/net/tulip/de2104x.c                    |    8 -
 drivers/net/tulip/de4x5.c                      |    8 -
 drivers/net/tulip/dmfe.c                       |   18 +-
 drivers/net/tulip/tulip_core.c                 |   12 -
 drivers/net/tulip/uli526x.c                    |   12 -
 drivers/net/tulip/winbond-840.c                |    4 
 drivers/net/typhoon.c                          |    6 
 drivers/net/ucc_geth.c                         |    4 
 drivers/net/usb/asix.c                         |   16 +-
 drivers/net/usb/catc.c                         |    2 
 drivers/net/usb/dm9601.c                       |    8 -
 drivers/net/usb/kaweth.c                       |    2 
 drivers/net/usb/mcs7830.c                      |    8 -
 drivers/net/usb/pegasus.c                      |    2 
 drivers/net/usb/rtl8150.c                      |    2 
 drivers/net/usb/smsc95xx.c                     |    8 -
 drivers/net/via-rhine.c                        |    4 
 drivers/net/via-velocity.c                     |    4 
 drivers/net/virtio_net.c                       |   20 +-
 drivers/net/vxge/vxge-main.c                   |    6 
 drivers/net/wireless/airo.c                    |    2 
 drivers/net/wireless/arlan-main.c              |    4 
 drivers/net/wireless/libertas/main.c           |    2 
 drivers/net/wireless/netwave_cs.c              |    8 -
 drivers/net/wireless/orinoco/main.c            |    6 
 drivers/net/wireless/ray_cs.c                  |    4 
 drivers/net/wireless/rndis_wlan.c              |    8 -
 drivers/net/wireless/wavelan.c                 |   14 -
 drivers/net/wireless/wavelan_cs.c              |   16 +-
 drivers/net/wireless/zd1201.c                  |    8 -
 drivers/net/yellowfin.c                        |    6 
 drivers/net/znet.c                             |    2 
 drivers/s390/net/qeth_l2_main.c                |    4 
 drivers/staging/et131x/et131x_netdev.c         |   14 -
 drivers/staging/slicoss/slicoss.c              |    4 
 drivers/staging/sxg/sxg.c                      |    4 
 include/linux/netdevice.h                      |  143 +++++++++++++++++--
 net/bluetooth/bnep/netdev.c                    |    6 
 net/core/dev.c                                 |  180 +++++++++----------------
 net/core/dev_mcast.c                           |   96 -------------
 net/irda/irlan/irlan_eth.c                     |    4 
 net/mac80211/main.c                            |    4 
 net/mac80211/scan.c                            |    8 -
 200 files changed, 743 insertions(+), 778 deletions(-)

--- wireless-testing.orig/include/linux/netdevice.h	2009-06-13 12:29:25.000000000 +0200
+++ wireless-testing/include/linux/netdevice.h	2009-06-13 12:30:21.000000000 +0200
@@ -200,6 +200,11 @@ struct dev_addr_list
 	int			da_gusers;
 };
 
+struct address_list {
+	struct dev_addr_list	*list;
+	int			count;
+};
+
 /*
  *	We tag multicasts with these structures.
  */
@@ -748,11 +753,9 @@ struct net_device
 	unsigned short          dev_id;		/* for shared network cards */
 
 	spinlock_t		addr_list_lock;
-	struct dev_addr_list	*uc_list;	/* Secondary unicast mac addresses */
-	int			uc_count;	/* Number of installed ucasts	*/
-	int			uc_promisc;
-	struct dev_addr_list	*mc_list;	/* Multicast mac addresses	*/
-	int			mc_count;	/* Number of installed mcasts	*/
+	struct address_list	uc;		/* secondary unicast mac addresses */
+	int			uc_promisc;	/* Multicast mac addresses */
+	struct address_list	mc;
 	unsigned int		promiscuity;
 	unsigned int		allmulti;
 
@@ -1792,24 +1795,128 @@ extern int		register_netdev(struct net_d
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for secondary unicast and multicast support */
 extern void		dev_set_rx_mode(struct net_device *dev);
-extern void		__dev_set_rx_mode(struct net_device *dev);
-extern int		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
-extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
-extern int		dev_unicast_sync(struct net_device *to, struct net_device *from);
-extern void		dev_unicast_unsync(struct net_device *to, struct net_device *from);
-extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
-extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
-extern int		dev_mc_sync(struct net_device *to, struct net_device *from);
-extern void		dev_mc_unsync(struct net_device *to, struct net_device *from);
-extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *addr, int alen, int all);
-extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
-extern int		__dev_addr_sync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
-extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
 extern int		dev_set_promiscuity(struct net_device *dev, int inc);
 extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
+
+int dev_addr_add(struct net_device *dev, struct address_list *alist,
+		 void *addr, int alen, int glbl);
+int dev_addr_delete(struct net_device *dev, struct address_list *alist,
+		    void *addr, int alen, int glbl);
+int dev_addr_sync(struct net_device *todev, struct address_list *to,
+		  struct address_list *from);
+void dev_addr_unsync(struct net_device *todev, struct net_device *fromdev,
+		     struct address_list *to, struct address_list *from);
+
+static inline int dev_mc_delete(struct net_device *dev, void *addr,
+				int alen, int glbl)
+{
+	return dev_addr_delete(dev, &dev->mc, addr, alen, glbl);
+}
+
+static inline int dev_mc_add(struct net_device *dev, void *addr,
+			     int alen, int glbl)
+{
+	return dev_addr_add(dev, &dev->mc, addr, alen, glbl);
+}
+
+/**
+ *	dev_mc_sync	- Synchronize device's multicast list to another device
+ *	@to: destination device
+ *	@from: source device
+ *
+ * 	Add newly added addresses to the destination device and release
+ * 	addresses that have no users left. The source device must be
+ * 	locked by netif_tx_lock_bh.
+ *
+ *	This function is intended to be called from the dev->set_multicast_list
+ *	or dev->set_rx_mode function of layered software devices.
+ */
+static inline int dev_mc_sync(struct net_device *to, struct net_device *from)
+{
+	return dev_addr_sync(to, &to->mc, &from->mc);
+}
+
+/**
+ * 	dev_mc_unsync	- Remove synchronized addresses from the destination
+ * 			  device
+ *	@to: destination device
+ *	@from: source device
+ *
+ * 	Remove all addresses that were added to the destination device by
+ * 	dev_mc_sync(). This function is intended to be called from the
+ * 	dev->stop function of layered software devices.
+ */
+static inline void dev_mc_unsync(struct net_device *to, struct net_device *from)
+{
+	dev_addr_unsync(to, from, &to->mc, &from->mc);
+}
+
+/**
+ *	dev_unicast_delete	- Release secondary unicast address.
+ *	@dev: device
+ *	@addr: address to delete
+ *	@alen: length of @addr
+ *
+ *	Release reference to a secondary unicast address and remove it
+ *	from the device if the reference count drops to zero.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+static inline int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
+{
+	return dev_addr_delete(dev, &dev->uc, addr, alen, 0);
+}
+
+/**
+ *	dev_unicast_add		- add a secondary unicast address
+ *	@dev: device
+ *	@addr: address to add
+ *	@alen: length of @addr
+ *
+ *	Add a secondary unicast address to the device or increase
+ *	the reference count if it already exists.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+static inline int dev_unicast_add(struct net_device *dev, void *addr, int alen)
+{
+	return dev_addr_add(dev, &dev->uc, addr, alen, 0);
+}
+
+/**
+ *	dev_unicast_sync - Synchronize device's unicast list to another device
+ *	@to: destination device
+ *	@from: source device
+ *
+ *	Add newly added addresses to the destination device and release
+ *	addresses that have no users left. The source device must be
+ *	locked by netif_tx_lock_bh.
+ *
+ *	This function is intended to be called from the dev->set_rx_mode
+ *	function of layered software devices.
+ */
+static inline int dev_unicast_sync(struct net_device *to, struct net_device *from)
+{
+	return dev_addr_sync(to, &to->uc, &from->uc);
+}
+
+/**
+ *	dev_unicast_unsync - Remove synchronized addresses from the destination device
+ *	@to: destination device
+ *	@from: source device
+ *
+ *	Remove all addresses that were added to the destination device by
+ *	dev_unicast_sync(). This function is intended to be called from the
+ *	dev->stop function of layered software devices.
+ */
+static inline void dev_unicast_unsync(struct net_device *to, struct net_device *from)
+{
+	dev_addr_unsync(to, from, &to->uc, &from->uc);
+}
+
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
 extern void		dev_mcast_init(void);
--- wireless-testing.orig/net/bluetooth/bnep/netdev.c	2009-01-13 15:05:23.000000000 +0100
+++ wireless-testing/net/bluetooth/bnep/netdev.c	2009-06-13 12:29:32.000000000 +0200
@@ -64,7 +64,7 @@ static void bnep_net_set_mc_list(struct 
 	struct sk_buff *skb;
 	int size;
 
-	BT_DBG("%s mc_count %d", dev->name, dev->mc_count);
+	BT_DBG("%s mc_count %d", dev->name, dev->mc.count);
 
 	size = sizeof(*r) + (BNEP_MAX_MULTICAST_FILTERS + 1) * ETH_ALEN * 2;
 	skb  = alloc_skb(size, GFP_ATOMIC);
@@ -87,7 +87,7 @@ static void bnep_net_set_mc_list(struct 
 		memcpy(__skb_put(skb, ETH_ALEN), dev->broadcast, ETH_ALEN);
 		r->len = htons(ETH_ALEN * 2);
 	} else {
-		struct dev_mc_list *dmi = dev->mc_list;
+		struct dev_mc_list *dmi = dev->mc.list;
 		int i, len = skb->len;
 
 		if (dev->flags & IFF_BROADCAST) {
@@ -97,7 +97,7 @@ static void bnep_net_set_mc_list(struct 
 
 		/* FIXME: We should group addresses here. */
 
-		for (i = 0; i < dev->mc_count && i < BNEP_MAX_MULTICAST_FILTERS; i++) {
+		for (i = 0; i < dev->mc.count && i < BNEP_MAX_MULTICAST_FILTERS; i++) {
 			memcpy(__skb_put(skb, ETH_ALEN), dmi->dmi_addr, ETH_ALEN);
 			memcpy(__skb_put(skb, ETH_ALEN), dmi->dmi_addr, ETH_ALEN);
 			dmi = dmi->next;
--- wireless-testing.orig/net/core/dev.c	2009-06-01 22:33:04.000000000 +0200
+++ wireless-testing/net/core/dev.c	2009-06-13 12:29:32.000000000 +0200
@@ -3412,7 +3412,7 @@ int dev_set_allmulti(struct net_device *
  *	filtering it is put in promiscuous mode while unicast addresses
  *	are present.
  */
-void __dev_set_rx_mode(struct net_device *dev)
+static void __dev_set_rx_mode(struct net_device *dev)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
@@ -3429,10 +3429,10 @@ void __dev_set_rx_mode(struct net_device
 		/* Unicast addresses changes may only happen under the rtnl,
 		 * therefore calling __dev_set_promiscuity here is safe.
 		 */
-		if (dev->uc_count > 0 && !dev->uc_promisc) {
+		if (dev->uc.count > 0 && !dev->uc_promisc) {
 			__dev_set_promiscuity(dev, 1);
 			dev->uc_promisc = 1;
-		} else if (dev->uc_count == 0 && dev->uc_promisc) {
+		} else if (dev->uc.count == 0 && dev->uc_promisc) {
 			__dev_set_promiscuity(dev, -1);
 			dev->uc_promisc = 0;
 		}
@@ -3449,9 +3449,10 @@ void dev_set_rx_mode(struct net_device *
 	netif_addr_unlock_bh(dev);
 }
 
-int __dev_addr_delete(struct dev_addr_list **list, int *count,
-		      void *addr, int alen, int glbl)
+static int __dev_addr_delete(struct address_list *alist,
+			     void *addr, int alen, int glbl)
 {
+	struct dev_addr_list **list = &alist->list;
 	struct dev_addr_list *da;
 
 	for (; (da = *list) != NULL; list = &da->next) {
@@ -3468,16 +3469,32 @@ int __dev_addr_delete(struct dev_addr_li
 
 			*list = da->next;
 			kfree(da);
-			(*count)--;
+			alist->count--;
 			return 0;
 		}
 	}
 	return -ENOENT;
 }
 
-int __dev_addr_add(struct dev_addr_list **list, int *count,
-		   void *addr, int alen, int glbl)
+int dev_addr_delete(struct net_device *dev, struct address_list *alist,
+		    void *addr, int alen, int glbl)
 {
+	int err;
+
+	netif_addr_lock_bh(dev);
+	err = __dev_addr_delete(alist, addr, alen, glbl);
+	if (!err)
+		__dev_set_rx_mode(dev);
+	netif_addr_unlock_bh(dev);
+
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_delete);
+
+static int __dev_addr_add(struct address_list *alist,
+			  void *addr, int alen, int glbl)
+{
+	struct dev_addr_list **list = &alist->list;
 	struct dev_addr_list *da;
 
 	for (da = *list; da != NULL; da = da->next) {
@@ -3503,156 +3520,91 @@ int __dev_addr_add(struct dev_addr_list 
 	da->da_gusers = glbl ? 1 : 0;
 	da->next = *list;
 	*list = da;
-	(*count)++;
+	alist->count++;
 	return 0;
 }
 
-/**
- *	dev_unicast_delete	- Release secondary unicast address.
- *	@dev: device
- *	@addr: address to delete
- *	@alen: length of @addr
- *
- *	Release reference to a secondary unicast address and remove it
- *	from the device if the reference count drops to zero.
- *
- * 	The caller must hold the rtnl_mutex.
- */
-int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
+int dev_addr_add(struct net_device *dev, struct address_list *alist,
+		 void *addr, int alen, int glbl)
 {
 	int err;
 
-	ASSERT_RTNL();
-
 	netif_addr_lock_bh(dev);
-	err = __dev_addr_delete(&dev->uc_list, &dev->uc_count, addr, alen, 0);
+	err = __dev_addr_add(alist, addr, alen, glbl);
 	if (!err)
 		__dev_set_rx_mode(dev);
 	netif_addr_unlock_bh(dev);
-	return err;
-}
-EXPORT_SYMBOL(dev_unicast_delete);
-
-/**
- *	dev_unicast_add		- add a secondary unicast address
- *	@dev: device
- *	@addr: address to add
- *	@alen: length of @addr
- *
- *	Add a secondary unicast address to the device or increase
- *	the reference count if it already exists.
- *
- *	The caller must hold the rtnl_mutex.
- */
-int dev_unicast_add(struct net_device *dev, void *addr, int alen)
-{
-	int err;
-
-	ASSERT_RTNL();
 
-	netif_addr_lock_bh(dev);
-	err = __dev_addr_add(&dev->uc_list, &dev->uc_count, addr, alen, 0);
-	if (!err)
-		__dev_set_rx_mode(dev);
-	netif_addr_unlock_bh(dev);
 	return err;
 }
-EXPORT_SYMBOL(dev_unicast_add);
+EXPORT_SYMBOL(dev_addr_add);
 
-int __dev_addr_sync(struct dev_addr_list **to, int *to_count,
-		    struct dev_addr_list **from, int *from_count)
+static int __dev_addr_sync(struct address_list *to, struct address_list *from)
 {
 	struct dev_addr_list *da, *next;
 	int err = 0;
 
-	da = *from;
+	da = from->list;
 	while (da != NULL) {
 		next = da->next;
 		if (!da->da_synced) {
-			err = __dev_addr_add(to, to_count,
-					     da->da_addr, da->da_addrlen, 0);
+			err = __dev_addr_add(to, da->da_addr, da->da_addrlen, 0);
 			if (err < 0)
 				break;
 			da->da_synced = 1;
 			da->da_users++;
 		} else if (da->da_users == 1) {
-			__dev_addr_delete(to, to_count,
-					  da->da_addr, da->da_addrlen, 0);
-			__dev_addr_delete(from, from_count,
-					  da->da_addr, da->da_addrlen, 0);
+			__dev_addr_delete(to, da->da_addr, da->da_addrlen, 0);
+			__dev_addr_delete(from, da->da_addr, da->da_addrlen, 0);
 		}
 		da = next;
 	}
 	return err;
 }
 
-void __dev_addr_unsync(struct dev_addr_list **to, int *to_count,
-		       struct dev_addr_list **from, int *from_count)
+int dev_addr_sync(struct net_device *todev, struct address_list *to,
+		  struct address_list *from)
+{
+	int err = 0;
+
+	netif_addr_lock_bh(todev);
+	err = __dev_addr_sync(to, from);
+	if (!err)
+		__dev_set_rx_mode(todev);
+	netif_addr_unlock_bh(todev);
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_sync);
+
+static void __dev_addr_unsync(struct address_list *to, struct address_list *from)
 {
 	struct dev_addr_list *da, *next;
 
-	da = *from;
+	da = from->list;
 	while (da != NULL) {
 		next = da->next;
 		if (da->da_synced) {
-			__dev_addr_delete(to, to_count,
-					  da->da_addr, da->da_addrlen, 0);
+			__dev_addr_delete(to, da->da_addr, da->da_addrlen, 0);
 			da->da_synced = 0;
-			__dev_addr_delete(from, from_count,
-					  da->da_addr, da->da_addrlen, 0);
+			__dev_addr_delete(from, da->da_addr, da->da_addrlen, 0);
 		}
 		da = next;
 	}
 }
 
-/**
- *	dev_unicast_sync - Synchronize device's unicast list to another device
- *	@to: destination device
- *	@from: source device
- *
- *	Add newly added addresses to the destination device and release
- *	addresses that have no users left. The source device must be
- *	locked by netif_tx_lock_bh.
- *
- *	This function is intended to be called from the dev->set_rx_mode
- *	function of layered software devices.
- */
-int dev_unicast_sync(struct net_device *to, struct net_device *from)
-{
-	int err = 0;
-
-	netif_addr_lock_bh(to);
-	err = __dev_addr_sync(&to->uc_list, &to->uc_count,
-			      &from->uc_list, &from->uc_count);
-	if (!err)
-		__dev_set_rx_mode(to);
-	netif_addr_unlock_bh(to);
-	return err;
-}
-EXPORT_SYMBOL(dev_unicast_sync);
-
-/**
- *	dev_unicast_unsync - Remove synchronized addresses from the destination device
- *	@to: destination device
- *	@from: source device
- *
- *	Remove all addresses that were added to the destination device by
- *	dev_unicast_sync(). This function is intended to be called from the
- *	dev->stop function of layered software devices.
- */
-void dev_unicast_unsync(struct net_device *to, struct net_device *from)
+void dev_addr_unsync(struct net_device *todev, struct net_device *fromdev,
+		     struct address_list *to, struct address_list *from)
 {
-	netif_addr_lock_bh(from);
-	netif_addr_lock(to);
+	netif_addr_lock_bh(fromdev);
+	netif_addr_lock(todev);
 
-	__dev_addr_unsync(&to->uc_list, &to->uc_count,
-			  &from->uc_list, &from->uc_count);
-	__dev_set_rx_mode(to);
+	__dev_addr_unsync(to, from);
+	__dev_set_rx_mode(todev);
 
-	netif_addr_unlock(to);
-	netif_addr_unlock_bh(from);
+	netif_addr_unlock(todev);
+	netif_addr_unlock_bh(fromdev);
 }
-EXPORT_SYMBOL(dev_unicast_unsync);
+EXPORT_SYMBOL(dev_addr_unsync);
 
 static void __dev_addr_discard(struct dev_addr_list **list)
 {
@@ -3672,11 +3624,11 @@ static void dev_addr_discard(struct net_
 {
 	netif_addr_lock_bh(dev);
 
-	__dev_addr_discard(&dev->uc_list);
-	dev->uc_count = 0;
+	__dev_addr_discard(&dev->uc.list);
+	dev->uc.count = 0;
 
-	__dev_addr_discard(&dev->mc_list);
-	dev->mc_count = 0;
+	__dev_addr_discard(&dev->mc.list);
+	dev->mc.count = 0;
 
 	netif_addr_unlock_bh(dev);
 }
--- wireless-testing.orig/net/core/dev_mcast.c	2009-06-13 12:29:25.000000000 +0200
+++ wireless-testing/net/core/dev_mcast.c	2009-06-13 12:29:32.000000000 +0200
@@ -64,97 +64,6 @@
  *	We block accesses to device mc filters with netif_tx_lock.
  */
 
-/*
- *	Delete a device level multicast
- */
-
-int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
-{
-	int err;
-
-	netif_addr_lock_bh(dev);
-	err = __dev_addr_delete(&dev->mc_list, &dev->mc_count,
-				addr, alen, glbl);
-	if (!err) {
-		/*
-		 *	We have altered the list, so the card
-		 *	loaded filter is now wrong. Fix it
-		 */
-
-		__dev_set_rx_mode(dev);
-	}
-	netif_addr_unlock_bh(dev);
-	return err;
-}
-
-/*
- *	Add a device level multicast
- */
-
-int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
-{
-	int err;
-
-	netif_addr_lock_bh(dev);
-	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
-	if (!err)
-		__dev_set_rx_mode(dev);
-	netif_addr_unlock_bh(dev);
-	return err;
-}
-
-/**
- *	dev_mc_sync	- Synchronize device's multicast list to another device
- *	@to: destination device
- *	@from: source device
- *
- * 	Add newly added addresses to the destination device and release
- * 	addresses that have no users left. The source device must be
- * 	locked by netif_tx_lock_bh.
- *
- *	This function is intended to be called from the dev->set_multicast_list
- *	or dev->set_rx_mode function of layered software devices.
- */
-int dev_mc_sync(struct net_device *to, struct net_device *from)
-{
-	int err = 0;
-
-	netif_addr_lock_bh(to);
-	err = __dev_addr_sync(&to->mc_list, &to->mc_count,
-			      &from->mc_list, &from->mc_count);
-	if (!err)
-		__dev_set_rx_mode(to);
-	netif_addr_unlock_bh(to);
-
-	return err;
-}
-EXPORT_SYMBOL(dev_mc_sync);
-
-
-/**
- * 	dev_mc_unsync	- Remove synchronized addresses from the destination
- * 			  device
- *	@to: destination device
- *	@from: source device
- *
- * 	Remove all addresses that were added to the destination device by
- * 	dev_mc_sync(). This function is intended to be called from the
- * 	dev->stop function of layered software devices.
- */
-void dev_mc_unsync(struct net_device *to, struct net_device *from)
-{
-	netif_addr_lock_bh(from);
-	netif_addr_lock(to);
-
-	__dev_addr_unsync(&to->mc_list, &to->mc_count,
-			  &from->mc_list, &from->mc_count);
-	__dev_set_rx_mode(to);
-
-	netif_addr_unlock(to);
-	netif_addr_unlock_bh(from);
-}
-EXPORT_SYMBOL(dev_mc_unsync);
-
 #ifdef CONFIG_PROC_FS
 static int dev_mc_seq_show(struct seq_file *seq, void *v)
 {
@@ -165,7 +74,7 @@ static int dev_mc_seq_show(struct seq_fi
 		return 0;
 
 	netif_addr_lock_bh(dev);
-	for (m = dev->mc_list; m; m = m->next) {
+	for (m = dev->mc.list; m; m = m->next) {
 		int i;
 
 		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
@@ -224,6 +133,3 @@ void __init dev_mcast_init(void)
 {
 	register_pernet_subsys(&dev_mc_net_ops);
 }
-
-EXPORT_SYMBOL(dev_mc_add);
-EXPORT_SYMBOL(dev_mc_delete);
--- wireless-testing.orig/net/irda/irlan/irlan_eth.c	2009-04-09 10:00:39.000000000 +0200
+++ wireless-testing/net/irda/irlan/irlan_eth.c	2009-06-13 12:29:32.000000000 +0200
@@ -318,14 +318,14 @@ static void irlan_eth_set_multicast_list
 		/* Enable promiscuous mode */
 		IRDA_WARNING("Promiscuous mode not implemented by IrLAN!\n");
 	}
-	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count > HW_MAX_ADDRS) {
+	else if ((dev->flags & IFF_ALLMULTI) || dev->mc.count > HW_MAX_ADDRS) {
 		/* Disable promiscuous mode, use normal mode. */
 		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__ );
 		/* hardware_set_filter(NULL); */
 
 		irlan_set_multicast_filter(self, TRUE);
 	}
-	else if (dev->mc_count) {
+	else if (dev->mc.count) {
 		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__ );
 		/* Walk the address list, and load the filter */
 		/* hardware_set_filter(dev->mc_list); */
--- wireless-testing.orig/net/mac80211/main.c	2009-06-11 11:34:09.000000000 +0200
+++ wireless-testing/net/mac80211/main.c	2009-06-13 12:29:32.000000000 +0200
@@ -83,8 +83,8 @@ void ieee80211_configure_filter(struct i
 	new_flags |= (1<<31);
 
 	drv_configure_filter(local, changed_flags, &new_flags,
-			     local->mdev->mc_count,
-			     local->mdev->mc_list);
+			     local->mdev->mc.count,
+			     local->mdev->mc.list);
 
 	WARN_ON(new_flags & (1<<31));
 
--- wireless-testing.orig/net/mac80211/scan.c	2009-06-11 11:34:09.000000000 +0200
+++ wireless-testing/net/mac80211/scan.c	2009-06-13 12:29:32.000000000 +0200
@@ -312,8 +312,8 @@ void ieee80211_scan_completed(struct iee
 	local->filter_flags &= ~FIF_BCN_PRBRESP_PROMISC;
 	drv_configure_filter(local, FIF_BCN_PRBRESP_PROMISC,
 			     &local->filter_flags,
-			     local->mdev->mc_count,
-			     local->mdev->mc_list);
+			     local->mdev->mc.count,
+			     local->mdev->mc.list);
 
 	netif_addr_unlock(local->mdev);
 	netif_tx_unlock_bh(local->mdev);
@@ -399,8 +399,8 @@ static int ieee80211_start_sw_scan(struc
 	local->filter_flags |= FIF_BCN_PRBRESP_PROMISC;
 	drv_configure_filter(local, FIF_BCN_PRBRESP_PROMISC,
 			     &local->filter_flags,
-			     local->mdev->mc_count,
-			     local->mdev->mc_list);
+			     local->mdev->mc.count,
+			     local->mdev->mc.list);
 	netif_addr_unlock_bh(local->mdev);
 
 	/* TODO: start scan as soon as all nullfunc frames are ACKed */
--- wireless-testing.orig/drivers/infiniband/hw/nes/nes_nic.c	2009-04-16 02:16:34.000000000 +0200
+++ wireless-testing/drivers/infiniband/hw/nes/nes_nic.c	2009-06-13 12:29:33.000000000 +0200
@@ -862,10 +862,10 @@ static void nes_netdev_set_multicast_lis
 	}
 
 	nes_debug(NES_DBG_NIC_RX, "Number of MC entries = %d, Promiscous = %d, All Multicast = %d.\n",
-		  netdev->mc_count, !!(netdev->flags & IFF_PROMISC),
+		  netdev->mc.count, !!(netdev->flags & IFF_PROMISC),
 		  !!(netdev->flags & IFF_ALLMULTI));
 	if (!mc_all_on) {
-		multicast_addr = netdev->mc_list;
+		multicast_addr = netdev->mc.list;
 		perfect_filter_register_address = NES_IDX_PERFECT_FILTER_LOW +
 						pft_entries_preallocated * 0x8;
 		for (mc_index = 0; mc_index < max_pft_entries_avaiable;
--- wireless-testing.orig/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2009-01-29 20:09:53.000000000 +0100
+++ wireless-testing/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2009-06-13 12:29:33.000000000 +0200
@@ -788,7 +788,7 @@ void ipoib_mcast_restart_task(struct wor
 		clear_bit(IPOIB_MCAST_FLAG_FOUND, &mcast->flags);
 
 	/* Mark all of the entries that are found or don't exist */
-	for (mclist = dev->mc_list; mclist; mclist = mclist->next) {
+	for (mclist = dev->mc.list; mclist; mclist = mclist->next) {
 		union ib_gid mgid;
 
 		memcpy(mgid.raw, mclist->dmi_addr + 4, sizeof mgid);
--- wireless-testing.orig/drivers/media/dvb/dvb-core/dvb_net.c	2009-04-09 10:00:09.000000000 +0200
+++ wireless-testing/drivers/media/dvb/dvb-core/dvb_net.c	2009-06-13 12:29:33.000000000 +0200
@@ -1140,18 +1140,18 @@ static void wq_set_multicast_list (struc
 	} else if ((dev->flags & IFF_ALLMULTI)) {
 		dprintk("%s: allmulti mode\n", dev->name);
 		priv->rx_mode = RX_MODE_ALL_MULTI;
-	} else if (dev->mc_count) {
+	} else if (dev->mc.count) {
 		int mci;
 		struct dev_mc_list *mc;
 
 		dprintk("%s: set_mc_list, %d entries\n",
-			dev->name, dev->mc_count);
+			dev->name, dev->mc.count);
 
 		priv->rx_mode = RX_MODE_MULTI;
 		priv->multi_num = 0;
 
-		for (mci = 0, mc=dev->mc_list;
-		     mci < dev->mc_count;
+		for (mci = 0, mc=dev->mc.list;
+		     mci < dev->mc.count;
 		     mc = mc->next, mci++) {
 			dvb_set_mc_filter(dev, mc);
 		}
@@ -1238,7 +1238,7 @@ static void dvb_net_setup(struct net_dev
 	dev->header_ops		= &dvb_header_ops;
 	dev->netdev_ops		= &dvb_netdev_ops;
 	dev->mtu		= 4096;
-	dev->mc_count           = 0;
+	dev->mc.count           = 0;
 
 	dev->flags |= IFF_NOARP;
 }
--- wireless-testing.orig/drivers/net/3c501.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/3c501.c	2009-06-13 12:29:33.000000000 +0200
@@ -819,7 +819,7 @@ static void set_multicast_list(struct ne
 	if (dev->flags & IFF_PROMISC) {
 		outb(RX_PROM, RX_CMD);
 		inb(RX_STATUS);
-	} else if (dev->mc_list || dev->flags & IFF_ALLMULTI) {
+	} else if (dev->mc.list || dev->flags & IFF_ALLMULTI) {
 		/* Multicast or all multicast is the same */
 		outb(RX_MULT, RX_CMD);
 		inb(RX_STATUS);		/* Clear status. */
--- wireless-testing.orig/drivers/net/3c505.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/3c505.c	2009-06-13 12:29:33.000000000 +0200
@@ -1208,7 +1208,7 @@ static int elp_close(struct net_device *
 static void elp_set_mc_list(struct net_device *dev)
 {
 	elp_device *adapter = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_addr_list *dmi = dev->mc.list;
 	int i;
 	unsigned long flags;
 
@@ -1221,8 +1221,8 @@ static void elp_set_mc_list(struct net_d
 		/* send a "load multicast list" command to the board, max 10 addrs/cmd */
 		/* if num_addrs==0 the list will be cleared */
 		adapter->tx_pcb.command = CMD_LOAD_MULTICAST_LIST;
-		adapter->tx_pcb.length = 6 * dev->mc_count;
-		for (i = 0; i < dev->mc_count; i++) {
+		adapter->tx_pcb.length = 6 * dev->mc.count;
+		for (i = 0; i < dev->mc.count; i++) {
 			memcpy(adapter->tx_pcb.data.multicast[i], dmi->dmi_addr, 6);
 			dmi = dmi->next;
 		}
@@ -1236,7 +1236,7 @@ static void elp_set_mc_list(struct net_d
 				TIMEOUT_MSG(__LINE__);
 			}
 		}
-		if (dev->mc_count)
+		if (dev->mc.count)
 			adapter->tx_pcb.data.configure = NO_LOOPBACK | RECV_BROAD | RECV_MULTI;
 		else		/* num_addrs == 0 */
 			adapter->tx_pcb.data.configure = NO_LOOPBACK | RECV_BROAD;
--- wireless-testing.orig/drivers/net/3c509.c	2009-06-07 21:32:31.000000000 +0200
+++ wireless-testing/drivers/net/3c509.c	2009-06-13 12:29:33.000000000 +0200
@@ -1116,9 +1116,9 @@ set_multicast_list(struct net_device *de
 
 	if (el3_debug > 1) {
 		static int old;
-		if (old != dev->mc_count) {
-			old = dev->mc_count;
-			printk("%s: Setting Rx mode to %d addresses.\n", dev->name, dev->mc_count);
+		if (old != dev->mc.count) {
+			old = dev->mc.count;
+			printk("%s: Setting Rx mode to %d addresses.\n", dev->name, dev->mc.count);
 		}
 	}
 	spin_lock_irqsave(&lp->lock, flags);
@@ -1126,7 +1126,7 @@ set_multicast_list(struct net_device *de
 		outw(SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm,
 			 ioaddr + EL3_CMD);
 	}
-	else if (dev->mc_count || (dev->flags&IFF_ALLMULTI)) {
+	else if (dev->mc.count || (dev->flags&IFF_ALLMULTI)) {
 		outw(SetRxFilter | RxStation | RxMulticast | RxBroadcast, ioaddr + EL3_CMD);
 	}
 	else
--- wireless-testing.orig/drivers/net/3c515.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/3c515.c	2009-06-13 12:29:33.000000000 +0200
@@ -1537,7 +1537,7 @@ static void set_rx_mode(struct net_devic
 			printk("%s: Setting promiscuous mode.\n",
 			       dev->name);
 		new_mode = SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm;
-	} else if ((dev->mc_list) || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc.list) || (dev->flags & IFF_ALLMULTI)) {
 		new_mode = SetRxFilter | RxStation | RxMulticast | RxBroadcast;
 	} else
 		new_mode = SetRxFilter | RxStation | RxBroadcast;
--- wireless-testing.orig/drivers/net/3c523.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/3c523.c	2009-06-13 12:29:33.000000000 +0200
@@ -625,8 +625,8 @@ static int init586(struct net_device *de
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
 	volatile struct mcsetup_cmd_struct *mc_cmd;
-	struct dev_mc_list *dmi = dev->mc_list;
-	int num_addrs = dev->mc_count;
+	struct dev_mc_list *dmi = dev->mc.list;
+	int num_addrs = dev->mc.count;
 
 	ptr = (void *) ((char *) p->scb + sizeof(struct scb_struct));
 
@@ -770,7 +770,7 @@ static int init586(struct net_device *de
 	 * Multicast setup
 	 */
 
-	if (dev->mc_count) {
+	if (dev->mc.count) {
 		/* I don't understand this: do we really need memory after the init? */
 		int len = ((char *) p->iscp - (char *) ptr - 8) / 6;
 		if (len <= 0) {
--- wireless-testing.orig/drivers/net/3c527.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/3c527.c	2009-06-13 12:29:33.000000000 +0200
@@ -1528,14 +1528,14 @@ static void do_mc32_set_multicast_list(s
 
 	if ((dev->flags&IFF_PROMISC) ||
 	    (dev->flags&IFF_ALLMULTI) ||
-	    dev->mc_count > 10)
+	    dev->mc.count > 10)
 		/* Enable promiscuous mode */
 		filt |= 1;
-	else if(dev->mc_count)
+	else if(dev->mc.count)
 	{
 		unsigned char block[62];
 		unsigned char *bp;
-		struct dev_mc_list *dmc=dev->mc_list;
+		struct dev_mc_list *dmc=dev->mc.list;
 
 		int i;
 
@@ -1544,16 +1544,16 @@ static void do_mc32_set_multicast_list(s
 		if(!lp->mc_list_valid)
 		{
 			block[1]=0;
-			block[0]=dev->mc_count;
+			block[0]=dev->mc.count;
 			bp=block+2;
 
-			for(i=0;i<dev->mc_count;i++)
+			for(i=0;i<dev->mclcount;i++)
 			{
 				memcpy(bp, dmc->dmi_addr, 6);
 				bp+=6;
 				dmc=dmc->next;
 			}
-			if(mc32_command_nowait(dev, 2, block, 2+6*dev->mc_count)==-1)
+			if(mc32_command_nowait(dev, 2, block, 2+6*dev->mclcount)==-1)
 			{
 				lp->mc_reload_wait = 1;
 				return;
--- wireless-testing.orig/drivers/net/3c59x.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/3c59x.c	2009-06-13 12:29:33.000000000 +0200
@@ -2972,7 +2972,7 @@ static void set_rx_mode(struct net_devic
 		if (vortex_debug > 3)
 			printk(KERN_NOTICE "%s: Setting promiscuous mode.\n", dev->name);
 		new_mode = SetRxFilter|RxStation|RxMulticast|RxBroadcast|RxProm;
-	} else	if ((dev->mc_list)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else	if ((dev->mc.list)  ||  (dev->flags & IFF_ALLMULTI)) {
 		new_mode = SetRxFilter|RxStation|RxMulticast|RxBroadcast;
 	} else
 		new_mode = SetRxFilter | RxStation | RxBroadcast;
--- wireless-testing.orig/drivers/net/7990.c	2009-01-13 15:05:05.000000000 +0100
+++ wireless-testing/drivers/net/7990.c	2009-06-13 12:29:33.000000000 +0200
@@ -595,7 +595,7 @@ static void lance_load_multicast (struct
         struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
         volatile u16 *mcast_table = (u16 *)&ib->filter;
-        struct dev_mc_list *dmi=dev->mc_list;
+        struct dev_mc_list *dmi=dev->mc.list;
         char *addrs;
         int i;
         u32 crc;
@@ -611,7 +611,7 @@ static void lance_load_multicast (struct
         ib->filter [1] = 0;
 
         /* Add addresses */
-        for (i = 0; i < dev->mc_count; i++){
+        for (i = 0; i < dev->mc.count; i++){
                 addrs = dmi->dmi_addr;
                 dmi   = dmi->next;
 
--- wireless-testing.orig/drivers/net/8139cp.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/8139cp.c	2009-06-13 12:29:33.000000000 +0200
@@ -912,7 +912,7 @@ static void __cp_set_rx_mode (struct net
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -921,7 +921,7 @@ static void __cp_set_rx_mode (struct net
 		struct dev_mc_list *mclist;
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
--- wireless-testing.orig/drivers/net/8139too.c	2009-04-30 23:07:17.000000000 +0200
+++ wireless-testing/drivers/net/8139too.c	2009-06-13 12:29:33.000000000 +0200
@@ -2536,7 +2536,7 @@ static void __set_rx_mode (struct net_de
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -2545,7 +2545,7 @@ static void __set_rx_mode (struct net_de
 		struct dev_mc_list *mclist;
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
--- wireless-testing.orig/drivers/net/82596.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/82596.c	2009-06-13 12:29:33.000000000 +0200
@@ -1506,7 +1506,7 @@ static void set_multicast_list(struct ne
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk(KERN_DEBUG "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
-		dev->name, dev->mc_count,
+		dev->name, dev->mc.count,
 		dev->flags & IFF_PROMISC  ? "ON" : "OFF",
 		dev->flags & IFF_ALLMULTI ? "ON" : "OFF"));
 
@@ -1534,7 +1534,7 @@ static void set_multicast_list(struct ne
 		i596_add_cmd(dev, &lp->cf_cmd.cmd);
 	}
 
-	cnt = dev->mc_count;
+	cnt = dev->mc.count;
 	if (cnt > MAX_MC_CNT)
 	{
 		cnt = MAX_MC_CNT;
@@ -1542,7 +1542,7 @@ static void set_multicast_list(struct ne
 			dev->name, cnt);
 	}
 
-	if (dev->mc_count > 0) {
+	if (dev->mc.count > 0) {
 		struct dev_mc_list *dmi;
 		unsigned char *cp;
 		struct mc_cmd *cmd;
@@ -1551,9 +1551,9 @@ static void set_multicast_list(struct ne
 			return;
 		cmd = &lp->mc_cmd;
 		cmd->cmd.command = CmdMulticastList;
-		cmd->mc_cnt = dev->mc_count * 6;
+		cmd->mc_cnt = dev->mc.count * 6;
 		cp = cmd->mc_addrs;
-		for (dmi = dev->mc_list; cnt && dmi != NULL; dmi = dmi->next, cnt--, cp += 6) {
+		for (dmi = dev->mc.list; cnt && dmi != NULL; dmi = dmi->next, cnt--, cp += 6) {
 			memcpy(cp, dmi->dmi_addr, 6);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address %pM\n",
--- wireless-testing.orig/drivers/net/a2065.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/a2065.c	2009-06-13 12:29:33.000000000 +0200
@@ -610,7 +610,7 @@ static void lance_load_multicast (struct
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *)&ib->filter;
-	struct dev_mc_list *dmi=dev->mc_list;
+	struct dev_mc_list *dmi=dev->mc.list;
 	char *addrs;
 	int i;
 	u32 crc;
@@ -626,7 +626,7 @@ static void lance_load_multicast (struct
 	ib->filter [1] = 0;
 
 	/* Add addresses */
-	for (i = 0; i < dev->mc_count; i++){
+	for (i = 0; i < dev->mc.count; i++){
 		addrs = dmi->dmi_addr;
 		dmi   = dmi->next;
 
--- wireless-testing.orig/drivers/net/acenic.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/acenic.c	2009-06-13 12:29:33.000000000 +0200
@@ -2844,7 +2844,7 @@ static void ace_set_multicast_list(struc
 	 * set the entire multicast list at a time and keeping track of
 	 * it here is going to be messy.
 	 */
-	if ((dev->mc_count) && !(ap->mcast_all)) {
+	if ((dev->mc.count) && !(ap->mcast_all)) {
 		cmd.evt = C_SET_MULTICAST_MODE;
 		cmd.code = C_C_MCAST_ENABLE;
 		cmd.idx = 0;
--- wireless-testing.orig/drivers/net/amd8111e.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/amd8111e.c	2009-06-13 12:29:33.000000000 +0200
@@ -1387,15 +1387,15 @@ static void amd8111e_set_multicast_list(
 	}
 	else
 		writel( PROM, lp->mmio + CMD2);
-	if(dev->flags & IFF_ALLMULTI || dev->mc_count > MAX_FILTER_SIZE){
+	if(dev->flags & IFF_ALLMULTI || dev->mc.count > MAX_FILTER_SIZE){
 		/* get all multicast packet */
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-		lp->mc_list = dev->mc_list;
+		lp->mc_list = dev->mc.list;
 		lp->options |= OPTION_MULTICAST_ENABLE;
 		amd8111e_writeq(*(u64*)mc_filter,lp->mmio + LADRF);
 		return;
 	}
-	if( dev->mc_count == 0 ){
+	if( dev->mc.count == 0 ){
 		/* get only own packets */
 		mc_filter[1] = mc_filter[0] = 0;
 		lp->mc_list = NULL;
@@ -1407,9 +1407,9 @@ static void amd8111e_set_multicast_list(
 	}
 	/* load all the multicast addresses in the logic filter */
 	lp->options |= OPTION_MULTICAST_ENABLE;
-	lp->mc_list = dev->mc_list;
+	lp->mc_list = dev->mc.list;
 	mc_filter[1] = mc_filter[0] = 0;
-	for (i = 0, mc_ptr = dev->mc_list; mc_ptr && i < dev->mc_count;
+	for (i = 0, mc_ptr = dev->mc.list; mc_ptr && i < dev->mc.count;
 		     i++, mc_ptr = mc_ptr->next) {
 		bit_num = (ether_crc_le(ETH_ALEN, mc_ptr->dmi_addr) >> 26) & 0x3f;
 		mc_filter[bit_num >> 5] |= 1 << (bit_num & 31);
--- wireless-testing.orig/drivers/net/appletalk/ltpc.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/appletalk/ltpc.c	2009-06-13 12:29:33.000000000 +0200
@@ -1125,7 +1125,7 @@ struct net_device * __init ltpc_probe(vo
 		printk(KERN_INFO "Apple/Farallon LocalTalk-PC card at %03x, DMA%d.  Using polled mode.\n",io,dma);
 
 	dev->netdev_ops = &ltpc_netdev;
-	dev->mc_list = NULL;
+	dev->mc.list = NULL;
 	dev->base_addr = io;
 	dev->irq = irq;
 	dev->dma = dma;
--- wireless-testing.orig/drivers/net/ariadne.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/ariadne.c	2009-06-13 12:29:33.000000000 +0200
@@ -819,7 +819,7 @@ static void set_multicast_list(struct ne
 	lance->RDP = PROM;		/* Set promiscuous mode */
     } else {
 	short multicast_table[4];
-	int num_addrs = dev->mc_count;
+	int num_addrs = dev->mc.count;
 	int i;
 	/* We don't use the multicast table, but rely on upper-layer filtering. */
 	memset(multicast_table, (num_addrs == 0) ? 0 : -1,
--- wireless-testing.orig/drivers/net/arm/am79c961a.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/arm/am79c961a.c	2009-06-13 12:29:33.000000000 +0200
@@ -387,7 +387,7 @@ static void am79c961_setmulticastlist (s
 
 		memset(multi_hash, 0x00, sizeof(multi_hash));
 
-		for (dmi = dev->mc_list; dmi; dmi = dmi->next)
+		for (dmi = dev->mc.list; dmi; dmi = dmi->next)
 			am79c961_mc_hash(dmi, multi_hash);
 	}
 
--- wireless-testing.orig/drivers/net/arm/at91_ether.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/arm/at91_ether.c	2009-06-13 12:29:34.000000000 +0200
@@ -562,8 +562,8 @@ static void at91ether_sethashtable(struc
 
 	mc_filter[0] = mc_filter[1] = 0;
 
-	curr = dev->mc_list;
-	for (i = 0; i < dev->mc_count; i++, curr = curr->next) {
+	curr = dev->mc.list;
+	for (i = 0; i < dev->mc.count; i++, curr = curr->next) {
 		if (!curr) break;	/* unexpected end of list */
 
 		bitnr = hash_get_index(curr->dmi_addr);
@@ -592,7 +592,7 @@ static void at91ether_set_multicast_list
 		at91_emac_write(AT91_EMAC_HSH, -1);
 		at91_emac_write(AT91_EMAC_HSL, -1);
 		cfg |= AT91_EMAC_MTI;
-	} else if (dev->mc_count > 0) {			/* Enable specific multicasts */
+	} else if (dev->mc.count > 0) {			/* Enable specific multicasts */
 		at91ether_sethashtable(dev);
 		cfg |= AT91_EMAC_MTI;
 	} else if (dev->flags & (~IFF_ALLMULTI)) {	/* Disable all multicast mode */
--- wireless-testing.orig/drivers/net/arm/ether3.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/arm/ether3.c	2009-06-13 12:29:34.000000000 +0200
@@ -463,7 +463,7 @@ static void ether3_setmulticastlist(stru
 	if (dev->flags & IFF_PROMISC) {
 		/* promiscuous mode */
 		priv(dev)->regs.config1 |= CFG1_RECVPROMISC;
-	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
+	} else if (dev->flags & IFF_ALLMULTI || dev->mc.count) {
 		priv(dev)->regs.config1 |= CFG1_RECVSPECBRMULTI;
 	} else
 		priv(dev)->regs.config1 |= CFG1_RECVSPECBROAD;
--- wireless-testing.orig/drivers/net/arm/ixp4xx_eth.c	2009-05-18 12:02:00.000000000 +0200
+++ wireless-testing/drivers/net/arm/ixp4xx_eth.c	2009-06-13 12:29:34.000000000 +0200
@@ -733,9 +733,9 @@ static int eth_xmit(struct sk_buff *skb,
 static void eth_set_mcast_list(struct net_device *dev)
 {
 	struct port *port = netdev_priv(dev);
-	struct dev_mc_list *mclist = dev->mc_list;
+	struct dev_mc_list *mclist = dev->mc.list;
 	u8 diffs[ETH_ALEN], *addr;
-	int cnt = dev->mc_count, i;
+	int cnt = dev->mc.count, i;
 
 	if ((dev->flags & IFF_PROMISC) || !mclist || !cnt) {
 		__raw_writel(DEFAULT_RX_CNTRL0 & ~RX_CNTRL0_ADDR_FLTR_EN,
--- wireless-testing.orig/drivers/net/arm/ks8695net.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/arm/ks8695net.c	2009-06-13 12:29:34.000000000 +0200
@@ -1127,7 +1127,7 @@ ks8695_set_multicast(struct net_device *
 	if (ndev->flags & IFF_ALLMULTI) {
 		/* enable all multicast mode */
 		ctrl |= DRXC_RM;
-	} else if (ndev->mc_count > KS8695_NR_ADDRESSES) {
+	} else if (ndev->mc.count > KS8695_NR_ADDRESSES) {
 		/* more specific multicast addresses than can be
 		 * handled in hardware
 		 */
@@ -1135,8 +1135,8 @@ ks8695_set_multicast(struct net_device *
 	} else {
 		/* enable specific multicasts */
 		ctrl &= ~DRXC_RM;
-		ks8695_init_partial_multicast(ksp, ndev->mc_list,
-					      ndev->mc_count);
+		ks8695_init_partial_multicast(ksp, ndev->mc.list,
+					      ndev->mc.count);
 	}
 
 	ks8695_writereg(ksp, KS8695_DRXC, ctrl);
--- wireless-testing.orig/drivers/net/at1700.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/at1700.c	2009-06-13 12:29:34.000000000 +0200
@@ -837,12 +837,12 @@ set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
-	} else if (dev->mc_count > MC_FILTERBREAK
+	} else if (dev->mc.count > MC_FILTERBREAK
 			   ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outb(2, ioaddr + RX_MODE);	/* Use normal mode. */
-	} else if (dev->mc_count == 0) {
+	} else if (dev->mc.count == 0) {
 		memset(mc_filter, 0x00, sizeof(mc_filter));
 		outb(1, ioaddr + RX_MODE);	/* Ignore almost all multicasts. */
 	} else {
@@ -850,7 +850,7 @@ set_rx_mode(struct net_device *dev)
 		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 			 i++, mclist = mclist->next) {
 			unsigned int bit =
 				ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
--- wireless-testing.orig/drivers/net/atarilance.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/atarilance.c	2009-06-13 12:29:34.000000000 +0200
@@ -1097,7 +1097,7 @@ static void set_multicast_list( struct n
 		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
 	} else {
 		short multicast_table[4];
-		int num_addrs = dev->mc_count;
+		int num_addrs = dev->mc.count;
 		int i;
 		/* We don't use the multicast table, but rely on upper-layer
 		 * filtering. */
--- wireless-testing.orig/drivers/net/atl1c/atl1c_main.c	2009-04-16 02:16:35.000000000 +0200
+++ wireless-testing/drivers/net/atl1c/atl1c_main.c	2009-06-13 12:29:34.000000000 +0200
@@ -355,7 +355,7 @@ static void atl1c_set_multi(struct net_d
 	AT_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	for (mc_ptr = netdev->mc.list; mc_ptr; mc_ptr = mc_ptr->next) {
 		hash_value = atl1c_hash_mc_addr(hw, mc_ptr->dmi_addr);
 		atl1c_hash_set(hw, hash_value);
 	}
--- wireless-testing.orig/drivers/net/atl1e/atl1e_main.c	2009-06-07 21:32:31.000000000 +0200
+++ wireless-testing/drivers/net/atl1e/atl1e_main.c	2009-06-13 12:29:35.000000000 +0200
@@ -311,7 +311,7 @@ static void atl1e_set_multi(struct net_d
 	AT_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	for (mc_ptr = netdev->mc.list; mc_ptr; mc_ptr = mc_ptr->next) {
 		hash_value = atl1e_hash_mc_addr(hw, mc_ptr->dmi_addr);
 		atl1e_hash_set(hw, hash_value);
 	}
--- wireless-testing.orig/drivers/net/atlx/atl2.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/atlx/atl2.c	2009-06-13 12:29:35.000000000 +0200
@@ -157,7 +157,7 @@ static void atl2_set_multi(struct net_de
 	ATL2_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	for (mc_ptr = netdev->mc.list; mc_ptr; mc_ptr = mc_ptr->next) {
 		hash_value = atl2_hash_mc_addr(hw, mc_ptr->dmi_addr);
 		atl2_hash_set(hw, hash_value);
 	}
--- wireless-testing.orig/drivers/net/atlx/atlx.c	2009-01-13 15:05:05.000000000 +0100
+++ wireless-testing/drivers/net/atlx/atlx.c	2009-06-13 12:29:35.000000000 +0200
@@ -144,7 +144,7 @@ static void atlx_set_multi(struct net_de
 	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
 
 	/* compute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	for (mc_ptr = netdev->mc.list; mc_ptr; mc_ptr = mc_ptr->next) {
 		hash_value = atlx_hash_mc_addr(hw, mc_ptr->dmi_addr);
 		atlx_hash_set(hw, hash_value);
 	}
--- wireless-testing.orig/drivers/net/atp.c	2009-01-13 15:05:05.000000000 +0100
+++ wireless-testing/drivers/net/atp.c	2009-06-13 12:29:35.000000000 +0200
@@ -859,7 +859,7 @@ static void set_rx_mode_8002(struct net_
 	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
-	if (dev->mc_count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC)))
+	if (dev->mc.count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC)))
 		lp->addr_mode = CMR2h_PROMISC;
 	else
 		lp->addr_mode = CMR2h_Normal;
@@ -875,7 +875,7 @@ static void set_rx_mode_8012(struct net_
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		new_mode = CMR2h_PROMISC;
-	} else if ((dev->mc_count > 1000)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc.count > 1000)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		new_mode = CMR2h_Normal;
@@ -883,7 +883,7 @@ static void set_rx_mode_8012(struct net_
 		struct dev_mc_list *mclist;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 			 i++, mclist = mclist->next)
 		{
 			int filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
--- wireless-testing.orig/drivers/net/au1000_eth.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/au1000_eth.c	2009-06-13 12:29:35.000000000 +0200
@@ -1014,7 +1014,7 @@ static void au1000_multicast_list(struct
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		aup->mac->control |= MAC_PROMISCUOUS;
 	} else if ((dev->flags & IFF_ALLMULTI)  ||
-			   dev->mc_count > MULTICAST_FILTER_LIMIT) {
+			   dev->mc.count > MULTICAST_FILTER_LIMIT) {
 		aup->mac->control |= MAC_PASS_ALL_MULTI;
 		aup->mac->control &= ~MAC_PROMISCUOUS;
 		printk(KERN_INFO "%s: Pass all multicast\n", dev->name);
@@ -1024,7 +1024,7 @@ static void au1000_multicast_list(struct
 		u32 mc_filter[2];	/* Multicast hash filter */
 
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 			 i++, mclist = mclist->next) {
 			set_bit(ether_crc(ETH_ALEN, mclist->dmi_addr)>>26,
 					(long *)mc_filter);
--- wireless-testing.orig/drivers/net/b44.c	2009-04-09 10:00:10.000000000 +0200
+++ wireless-testing/drivers/net/b44.c	2009-06-13 12:29:35.000000000 +0200
@@ -1691,8 +1691,8 @@ static int __b44_load_mcast(struct b44 *
 	struct dev_mc_list *mclist;
 	int i, num_ents;
 
-	num_ents = min_t(int, dev->mc_count, B44_MCAST_TABLE_SIZE);
-	mclist = dev->mc_list;
+	num_ents = min_t(int, dev->mc.count, B44_MCAST_TABLE_SIZE);
+	mclist = dev->mc.list;
 	for (i = 0; mclist && i < num_ents; i++, mclist = mclist->next) {
 		__b44_cam_write(bp, mclist->dmi_addr, i + 1);
 	}
@@ -1716,7 +1716,7 @@ static void __b44_set_rx_mode(struct net
 		__b44_set_mac_addr(bp);
 
 		if ((dev->flags & IFF_ALLMULTI) ||
-		    (dev->mc_count > B44_MCAST_TABLE_SIZE))
+		    (dev->mc.count > B44_MCAST_TABLE_SIZE))
 			val |= RXCONFIG_ALLMULTI;
 		else
 			i = __b44_load_mcast(bp, dev);
--- wireless-testing.orig/drivers/net/benet/be_main.c	2009-05-30 01:38:26.000000000 +0200
+++ wireless-testing/drivers/net/benet/be_main.c	2009-06-13 12:29:35.000000000 +0200
@@ -576,7 +576,7 @@ static void be_set_multicast_filter(stru
 		return;
 	}
 
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	for (mc_ptr = netdev->mc.list; mc_ptr; mc_ptr = mc_ptr->next) {
 		memcpy(&mac_addr[i][0], mc_ptr->dmi_addr, ETH_ALEN);
 		if (++i >= 32) {
 			be_cmd_mcast_mac_set(&adapter->ctrl,
--- wireless-testing.orig/drivers/net/bfin_mac.c	2009-06-07 21:32:31.000000000 +0200
+++ wireless-testing/drivers/net/bfin_mac.c	2009-06-13 12:29:35.000000000 +0200
@@ -863,14 +863,14 @@ static void bfin_mac_timeout(struct net_
 static void bfin_mac_multicast_hash(struct net_device *dev)
 {
 	u32 emac_hashhi, emac_hashlo;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	char *addrs;
 	int i;
 	u32 crc;
 
 	emac_hashhi = emac_hashlo = 0;
 
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < dev->mc.count; i++) {
 		addrs = dmi->dmi_addr;
 		dmi = dmi->next;
 
@@ -913,7 +913,7 @@ static void bfin_mac_set_multicast_list(
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= PAM;
 		bfin_write_EMAC_OPMODE(sysctl);
-	} else if (dev->mc_count) {
+	} else if (dev->mc.count) {
 		/* set up multicast hash table */
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= HM;
--- wireless-testing.orig/drivers/net/bmac.c	2009-04-09 10:00:11.000000000 +0200
+++ wireless-testing/drivers/net/bmac.c	2009-06-13 12:29:35.000000000 +0200
@@ -972,7 +972,7 @@ static void bmac_set_multicast(struct ne
 {
 	struct dev_mc_list *dmi;
 	struct bmac_data *bp = netdev_priv(dev);
-	int num_addrs = dev->mc_count;
+	int num_addrs = dev->mc.count;
 	unsigned short rx_cfg;
 	int i;
 
@@ -981,7 +981,7 @@ static void bmac_set_multicast(struct ne
 
 	XXDEBUG(("bmac: enter bmac_set_multicast, n_addrs=%d\n", num_addrs));
 
-	if((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 64)) {
 		for (i=0; i<4; i++) bp->hash_table_mask[i] = 0xffff;
 		bmac_update_hash_table_mask(dev, bp);
 		rx_cfg = bmac_rx_on(dev, 1, 0);
@@ -999,7 +999,7 @@ static void bmac_set_multicast(struct ne
 			rx_cfg = bmac_rx_on(dev, 0, 0);
 			XXDEBUG(("bmac: multi disabled, rx_cfg=%#08x\n", rx_cfg));
 		} else {
-			for (dmi=dev->mc_list; dmi!=NULL; dmi=dmi->next)
+			for (dmi=dev->mc.list; dmi!=NULL; dmi=dmi->next)
 				bmac_addhash(bp, dmi->dmi_addr);
 			bmac_update_hash_table_mask(dev, bp);
 			rx_cfg = bmac_rx_on(dev, 1, 0);
@@ -1014,13 +1014,13 @@ static void bmac_set_multicast(struct ne
 
 static void bmac_set_multicast(struct net_device *dev)
 {
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	char *addrs;
 	int i;
 	unsigned short rx_cfg;
 	u32 crc;
 
-	if((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 64)) {
 		bmwrite(dev, BHASH0, 0xffff);
 		bmwrite(dev, BHASH1, 0xffff);
 		bmwrite(dev, BHASH2, 0xffff);
@@ -1038,7 +1038,7 @@ static void bmac_set_multicast(struct ne
 
 		for(i = 0; i < 4; i++) hash_table[i] = 0;
 
-		for(i = 0; i < dev->mc_count; i++) {
+		for(i = 0; i < dev->mc.count; i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
--- wireless-testing.orig/drivers/net/bnx2.c	2009-05-18 12:02:00.000000000 +0200
+++ wireless-testing/drivers/net/bnx2.c	2009-06-13 12:29:35.000000000 +0200
@@ -3349,7 +3349,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 
 		memset(mc_filter, 0, 4 * NUM_MC_HASH_REGISTERS);
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 
 			crc = ether_crc_le(ETH_ALEN, mclist->dmi_addr);
@@ -3368,15 +3368,15 @@ bnx2_set_rx_mode(struct net_device *dev)
 	}
 
 	uc_ptr = NULL;
-	if (dev->uc_count > BNX2_MAX_UNICAST_ADDRESSES) {
+	if (dev->uc.count > BNX2_MAX_UNICAST_ADDRESSES) {
 		rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
 		sort_mode |= BNX2_RPM_SORT_USER0_PROM_EN |
 			     BNX2_RPM_SORT_USER0_PROM_VLAN;
 	} else if (!(dev->flags & IFF_PROMISC)) {
-		uc_ptr = dev->uc_list;
+		uc_ptr = dev->uc.list;
 
 		/* Add all entries into to the match filter list */
-		for (i = 0; i < dev->uc_count; i++) {
+		for (i = 0; i < dev->uc.count; i++) {
 			bnx2_set_mac_addr(bp, uc_ptr->da_addr,
 					  i + BNX2_START_UNICAST_ADDRESS_INDEX);
 			sort_mode |= (1 <<
--- wireless-testing.orig/drivers/net/bnx2x_main.c	2009-04-09 10:00:14.000000000 +0200
+++ wireless-testing/drivers/net/bnx2x_main.c	2009-06-13 12:29:35.000000000 +0200
@@ -10655,7 +10655,7 @@ static void bnx2x_set_rx_mode(struct net
 		rx_mode = BNX2X_RX_MODE_PROMISC;
 
 	else if ((dev->flags & IFF_ALLMULTI) ||
-		 ((dev->mc_count > BNX2X_MAX_MULTICAST) && CHIP_IS_E1(bp)))
+		 ((dev->mc.count > BNX2X_MAX_MULTICAST) && CHIP_IS_E1(bp)))
 		rx_mode = BNX2X_RX_MODE_ALLMULTI;
 
 	else { /* some multicasts */
@@ -10665,8 +10665,8 @@ static void bnx2x_set_rx_mode(struct net
 			struct mac_configuration_cmd *config =
 						bnx2x_sp(bp, mcast_config);
 
-			for (i = 0, mclist = dev->mc_list;
-			     mclist && (i < dev->mc_count);
+			for (i = 0, mclist = dev->mc.list;
+			     mclist && (i < dev->mc.count);
 			     i++, mclist = mclist->next) {
 
 				config->config_table[i].
@@ -10733,8 +10733,8 @@ static void bnx2x_set_rx_mode(struct net
 
 			memset(mc_filter, 0, 4 * MC_HASH_SIZE);
 
-			for (i = 0, mclist = dev->mc_list;
-			     mclist && (i < dev->mc_count);
+			for (i = 0, mclist = dev->mc.list;
+			     mclist && (i < dev->mc.count);
 			     i++, mclist = mclist->next) {
 
 				DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
--- wireless-testing.orig/drivers/net/bonding/bond_main.c	2009-05-18 12:02:00.000000000 +0200
+++ wireless-testing/drivers/net/bonding/bond_main.c	2009-06-13 12:29:35.000000000 +0200
@@ -872,7 +872,7 @@ static void bond_resend_igmp_join_reques
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(bond->dev);
 	if (in_dev) {
-		for (im = in_dev->mc_list; im; im = im->next) {
+		for (im = in_dev->mc.list; im; im = im->next) {
 			ip_mc_rejoin_group(im);
 		}
 	}
@@ -931,7 +931,7 @@ static void bond_mc_list_flush(struct ne
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct dev_mc_list *dmi;
 
-	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
+	for (dmi = bond_dev->mc.list; dmi; dmi = dmi->next) {
 		dev_mc_delete(slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 	}
 
@@ -970,7 +970,7 @@ static void bond_mc_swap(struct bonding 
 			dev_set_allmulti(old_active->dev, -1);
 		}
 
-		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next) {
+		for (dmi = bond->dev->mc.list; dmi; dmi = dmi->next) {
 			dev_mc_delete(old_active->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
 	}
@@ -985,7 +985,7 @@ static void bond_mc_swap(struct bonding 
 			dev_set_allmulti(new_active->dev, 1);
 		}
 
-		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next) {
+		for (dmi = bond->dev->mc.list; dmi; dmi = dmi->next) {
 			dev_mc_add(new_active->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
 		bond_resend_igmp_join_requests(bond);
@@ -1578,7 +1578,7 @@ int bond_enslave(struct net_device *bond
 
 		netif_addr_lock_bh(bond_dev);
 		/* upload master's mc_list to new slave */
-		for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
+		for (dmi = bond_dev->mc.list; dmi; dmi = dmi->next) {
 			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
 		netif_addr_unlock_bh(bond_dev);
@@ -4067,7 +4067,7 @@ static void bond_set_multicast_list(stru
 	bond->flags = bond_dev->flags;
 
 	/* looking for addresses to add to slaves' mc list */
-	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
+	for (dmi = bond_dev->mc.list; dmi; dmi = dmi->next) {
 		if (!bond_mc_list_find_dmi(dmi, bond->mc_list)) {
 			bond_mc_add(bond, dmi->dmi_addr, dmi->dmi_addrlen);
 		}
@@ -4075,14 +4075,14 @@ static void bond_set_multicast_list(stru
 
 	/* looking for addresses to delete from slaves' list */
 	for (dmi = bond->mc_list; dmi; dmi = dmi->next) {
-		if (!bond_mc_list_find_dmi(dmi, bond_dev->mc_list)) {
+		if (!bond_mc_list_find_dmi(dmi, bond_dev->mc.list)) {
 			bond_mc_delete(bond, dmi->dmi_addr, dmi->dmi_addrlen);
 		}
 	}
 
 	/* save master's multicast list */
 	bond_mc_list_destroy(bond);
-	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
+	bond_mc_list_copy(bond_dev->mc.list, bond, GFP_ATOMIC);
 
 	read_unlock(&bond->lock);
 }
--- wireless-testing.orig/drivers/net/cassini.c	2009-04-09 10:00:14.000000000 +0200
+++ wireless-testing/drivers/net/cassini.c	2009-06-13 12:29:36.000000000 +0200
@@ -3016,7 +3016,7 @@ static u32 cas_setup_multicast(struct ca
 	} else {
 		u16 hash_table[16];
 		u32 crc;
-		struct dev_mc_list *dmi = cp->dev->mc_list;
+		struct dev_mc_list *dmi = cp->dev->mc.list;
 		int i;
 
 		/* use the alternate mac address registers for the
--- wireless-testing.orig/drivers/net/chelsio/common.h	2008-12-19 00:28:05.000000000 +0100
+++ wireless-testing/drivers/net/chelsio/common.h	2009-06-13 12:29:36.000000000 +0200
@@ -97,13 +97,13 @@ struct t1_rx_mode {
 
 #define t1_rx_mode_promisc(rm)	(rm->dev->flags & IFF_PROMISC)
 #define t1_rx_mode_allmulti(rm)	(rm->dev->flags & IFF_ALLMULTI)
-#define t1_rx_mode_mc_cnt(rm)	(rm->dev->mc_count)
+#define t1_rx_mode_mc_cnt(rm)	(rm->dev->mc.count)
 
 static inline u8 *t1_get_next_mcaddr(struct t1_rx_mode *rm)
 {
 	u8 *addr = NULL;
 
-	if (rm->idx++ < rm->dev->mc_count) {
+	if (rm->idx++ < rm->dev->mc.count) {
 		addr = rm->list->dmi_addr;
 		rm->list = rm->list->next;
 	}
--- wireless-testing.orig/drivers/net/chelsio/cxgb2.c	2009-04-09 10:00:14.000000000 +0200
+++ wireless-testing/drivers/net/chelsio/cxgb2.c	2009-06-13 12:29:36.000000000 +0200
@@ -126,7 +126,7 @@ static void t1_set_rxmode(struct net_dev
 
 	rm.dev = dev;
 	rm.idx = 0;
-	rm.list = dev->mc_list;
+	rm.list = dev->mc.list;
 	mac->ops->set_rx_mode(mac, &rm);
 }
 
--- wireless-testing.orig/drivers/net/cpmac.c	2009-04-09 10:00:14.000000000 +0200
+++ wireless-testing/drivers/net/cpmac.c	2009-06-13 12:29:36.000000000 +0200
@@ -340,7 +340,7 @@ static void cpmac_set_multicast_list(str
 			 * cpmac uses some strange mac address hashing
 			 * (not crc32)
 			 */
-			for (i = 0, iter = dev->mc_list; i < dev->mc_count;
+			for (i = 0, iter = dev->mc.list; i < dev->mc.count;
 			     i++, iter = iter->next) {
 				bit = 0;
 				tmp = iter->dmi_addr[0];
--- wireless-testing.orig/drivers/net/cris/eth_v10.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/cris/eth_v10.c	2009-06-13 12:29:36.000000000 +0200
@@ -1550,7 +1550,7 @@ static void
 set_multicast_list(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
-	int num_addr = dev->mc_count;
+	int num_addr = dev->mc.count;
 	unsigned long int lo_bits;
 	unsigned long int hi_bits;
 
@@ -1582,7 +1582,7 @@ set_multicast_list(struct net_device *de
 	} else {
 		/* MC mode, receive normal and MC packets */
 		char hash_ix;
-		struct dev_mc_list *dmi = dev->mc_list;
+		struct dev_mc_list *dmi = dev->mc.list;
 		int i;
 		char *baddr;
 
--- wireless-testing.orig/drivers/net/cs89x0.c	2009-04-09 10:00:14.000000000 +0200
+++ wireless-testing/drivers/net/cs89x0.c	2009-06-13 12:29:36.000000000 +0200
@@ -1788,7 +1788,7 @@ static void set_multicast_list(struct ne
 	{
 		lp->rx_mode = RX_ALL_ACCEPT;
 	}
-	else if((dev->flags&IFF_ALLMULTI)||dev->mc_list)
+	else if((dev->flags&IFF_ALLMULTI)||dev->mc.list)
 	{
 		/* The multicast-accept list is initialized to accept-all, and we
 		   rely on higher-level filtering for now. */
--- wireless-testing.orig/drivers/net/cxgb3/common.h	2009-04-09 10:00:14.000000000 +0200
+++ wireless-testing/drivers/net/cxgb3/common.h	2009-06-13 12:29:36.000000000 +0200
@@ -85,7 +85,7 @@ static inline u8 *t3_get_next_mcaddr(str
 {
 	u8 *addr = NULL;
 
-	if (rm->mclist && rm->idx < rm->dev->mc_count) {
+	if (rm->mclist && rm->idx < rm->dev->mc.count) {
 		addr = rm->mclist->dmi_addr;
 		rm->mclist = rm->mclist->next;
 		rm->idx++;
--- wireless-testing.orig/drivers/net/cxgb3/cxgb3_main.c	2009-06-07 21:32:31.000000000 +0200
+++ wireless-testing/drivers/net/cxgb3/cxgb3_main.c	2009-06-13 12:29:36.000000000 +0200
@@ -297,7 +297,7 @@ static void cxgb_set_rxmode(struct net_d
 	struct t3_rx_mode rm;
 	struct port_info *pi = netdev_priv(dev);
 
-	init_rx_mode(&rm, dev, dev->mc_list);
+	init_rx_mode(&rm, dev, dev->mc.list);
 	t3_mac_set_rx_mode(&pi->mac, &rm);
 }
 
@@ -313,7 +313,7 @@ static void link_start(struct net_device
 	struct port_info *pi = netdev_priv(dev);
 	struct cmac *mac = &pi->mac;
 
-	init_rx_mode(&rm, dev, dev->mc_list);
+	init_rx_mode(&rm, dev, dev->mc.list);
 	t3_mac_reset(mac);
 	t3_mac_set_mtu(mac, dev->mtu);
 	t3_mac_set_address(mac, 0, dev->dev_addr);
--- wireless-testing.orig/drivers/net/de620.c	2009-01-13 15:05:05.000000000 +0100
+++ wireless-testing/drivers/net/de620.c	2009-06-13 12:29:36.000000000 +0200
@@ -486,7 +486,7 @@ static int de620_close(struct net_device
 
 static void de620_set_multicast_list(struct net_device *dev)
 {
-	if (dev->mc_count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
+	if (dev->mc.count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
 	{ /* Enable promiscuous mode */
 		de620_set_register(dev, W_TCR, (TCR_DEF & ~RXPBM) | RXALL);
 	}
--- wireless-testing.orig/drivers/net/declance.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/declance.c	2009-06-13 12:29:36.000000000 +0200
@@ -935,7 +935,7 @@ static void lance_load_multicast(struct 
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile u16 *ib = (volatile u16 *)dev->mem_start;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	char *addrs;
 	int i;
 	u32 crc;
@@ -955,7 +955,7 @@ static void lance_load_multicast(struct 
 	*lib_ptr(ib, filter[3], lp->type) = 0;
 
 	/* Add addresses */
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < dev->mc.count; i++) {
 		addrs = dmi->dmi_addr;
 		dmi = dmi->next;
 
--- wireless-testing.orig/drivers/net/defxx.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/defxx.c	2009-06-13 12:29:36.000000000 +0200
@@ -2229,7 +2229,7 @@ static void dfx_ctl_set_multicast_list(s
 		 *		 perfect filtering will be used.
 		 */
 
-		if (dev->mc_count > (PI_CMD_ADDR_FILTER_K_SIZE - bp->uc_count))
+		if (dev->mc.count > (PI_CMD_ADDR_FILTER_K_SIZE - bp->uc_count))
 			{
 			bp->group_prom	= PI_FSTATE_K_PASS;		/* Enable LLC group prom mode */
 			bp->mc_count	= 0;					/* Don't add mc addrs to CAM */
@@ -2237,12 +2237,12 @@ static void dfx_ctl_set_multicast_list(s
 		else
 			{
 			bp->group_prom	= PI_FSTATE_K_BLOCK;	/* Disable LLC group prom mode */
-			bp->mc_count	= dev->mc_count;		/* Add mc addrs to CAM */
+			bp->mc_count	= dev->mc.count;		/* Add mc addrs to CAM */
 			}
 
 		/* Copy addresses to multicast address table, then update adapter CAM */
 
-		dmi = dev->mc_list;				/* point to first multicast addr */
+		dmi = dev->mc.list;				/* point to first multicast addr */
 		for (i=0; i < bp->mc_count; i++)
 			{
 			memcpy(&bp->mc_table[i*FDDI_K_ALEN], dmi->dmi_addr, FDDI_K_ALEN);
--- wireless-testing.orig/drivers/net/depca.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/depca.c	2009-06-13 12:29:36.000000000 +0200
@@ -1269,7 +1269,7 @@ static void set_multicast_list(struct ne
 static void SetMulticastFilter(struct net_device *dev)
 {
 	struct depca_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	char *addrs;
 	int i, j, bit, byte;
 	u16 hashcode;
@@ -1284,7 +1284,7 @@ static void SetMulticastFilter(struct ne
 			lp->init_block.mcast_table[i] = 0;
 		}
 		/* Add multicast addresses */
-		for (i = 0; i < dev->mc_count; i++) {	/* for each address in the list */
+		for (i = 0; i < dev->mc.count; i++) {	/* for each address in the list */
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 			if ((*addrs & 0x01) == 1) {	/* multicast address? */
--- wireless-testing.orig/drivers/net/dl2k.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/dl2k.c	2009-06-13 12:29:37.000000000 +0200
@@ -1133,17 +1133,17 @@ set_multicast (struct net_device *dev)
 		/* Receive all frames promiscuously. */
 		rx_mode = ReceiveAllFrames;
 	} else if ((dev->flags & IFF_ALLMULTI) ||
-			(dev->mc_count > multicast_filter_limit)) {
+			(dev->mc.count > multicast_filter_limit)) {
 		/* Receive broadcast and multicast frames */
 		rx_mode = ReceiveBroadcast | ReceiveMulticast | ReceiveUnicast;
-	} else if (dev->mc_count > 0) {
+	} else if (dev->mc.count > 0) {
 		int i;
 		struct dev_mc_list *mclist;
 		/* Receive broadcast frames and multicast frames filtering
 		   by Hashtable */
 		rx_mode =
 		    ReceiveBroadcast | ReceiveMulticastHash | ReceiveUnicast;
-		for (i=0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i=0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 				i++, mclist=mclist->next)
 		{
 			int bit, index = 0;
--- wireless-testing.orig/drivers/net/dm9000.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/dm9000.c	2009-06-13 12:29:37.000000000 +0200
@@ -627,8 +627,8 @@ static void
 dm9000_hash_table(struct net_device *dev)
 {
 	board_info_t *db = netdev_priv(dev);
-	struct dev_mc_list *mcptr = dev->mc_list;
-	int mc_cnt = dev->mc_count;
+	struct dev_mc_list *mcptr = dev->mc.list;
+	int mc_cnt = dev->mc.count;
 	int i, oft;
 	u32 hash_val;
 	u16 hash_table[4];
--- wireless-testing.orig/drivers/net/e100.c	2009-04-30 23:07:17.000000000 +0200
+++ wireless-testing/drivers/net/e100.c	2009-06-13 12:29:37.000000000 +0200
@@ -1375,8 +1375,8 @@ static int e100_hw_init(struct nic *nic)
 static void e100_multi(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
 	struct net_device *netdev = nic->netdev;
-	struct dev_mc_list *list = netdev->mc_list;
-	u16 i, count = min(netdev->mc_count, E100_MAX_MULTICAST_ADDRS);
+	struct dev_mc_list *list = netdev->mc.list;
+	u16 i, count = min(netdev->mc.count, E100_MAX_MULTICAST_ADDRS);
 
 	cb->command = cpu_to_le16(cb_multi);
 	cb->u.multi.count = cpu_to_le16(count * ETH_ALEN);
@@ -1390,7 +1390,7 @@ static void e100_set_multicast_list(stru
 	struct nic *nic = netdev_priv(netdev);
 
 	DPRINTK(HW, DEBUG, "mc_count=%d, flags=0x%04X\n",
-		netdev->mc_count, netdev->flags);
+		netdev->mc.count, netdev->flags);
 
 	if (netdev->flags & IFF_PROMISC)
 		nic->flags |= promiscuous;
@@ -1398,7 +1398,7 @@ static void e100_set_multicast_list(stru
 		nic->flags &= ~promiscuous;
 
 	if (netdev->flags & IFF_ALLMULTI ||
-		netdev->mc_count > E100_MAX_MULTICAST_ADDRS)
+		netdev->mc.count > E100_MAX_MULTICAST_ADDRS)
 		nic->flags |= multicast_all;
 	else
 		nic->flags &= ~multicast_all;
--- wireless-testing.orig/drivers/net/e1000/e1000_main.c	2009-06-07 21:32:31.000000000 +0200
+++ wireless-testing/drivers/net/e1000/e1000_main.c	2009-06-13 12:29:37.000000000 +0200
@@ -2367,11 +2367,11 @@ static void e1000_set_rx_mode(struct net
 	}
 
 	uc_ptr = NULL;
-	if (netdev->uc_count > rar_entries - 1) {
+	if (netdev->uc.count > rar_entries - 1) {
 		rctl |= E1000_RCTL_UPE;
 	} else if (!(netdev->flags & IFF_PROMISC)) {
 		rctl &= ~E1000_RCTL_UPE;
-		uc_ptr = netdev->uc_list;
+		uc_ptr = netdev->uc.list;
 	}
 
 	ew32(RCTL, rctl);
@@ -2389,7 +2389,7 @@ static void e1000_set_rx_mode(struct net
 	 * if there are not 14 addresses, go ahead and clear the filters
 	 * -- with 82571 controllers only 0-13 entries are filled here
 	 */
-	mc_ptr = netdev->mc_list;
+	mc_ptr = netdev->mc.list;
 
 	for (i = 1; i < rar_entries; i++) {
 		if (uc_ptr) {
--- wireless-testing.orig/drivers/net/e1000e/netdev.c	2009-04-30 23:07:17.000000000 +0200
+++ wireless-testing/drivers/net/e1000e/netdev.c	2009-06-13 12:29:37.000000000 +0200
@@ -2572,15 +2572,15 @@ static void e1000_set_multi(struct net_d
 
 	ew32(RCTL, rctl);
 
-	if (netdev->mc_count) {
-		mta_list = kmalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	if (netdev->mc.count) {
+		mta_list = kmalloc(netdev->mc.count * 6, GFP_ATOMIC);
 		if (!mta_list)
 			return;
 
 		/* prepare a packed array of only addresses. */
-		mc_ptr = netdev->mc_list;
+		mc_ptr = netdev->mc.list;
 
-		for (i = 0; i < netdev->mc_count; i++) {
+		for (i = 0; i < netdev->mc.count; i++) {
 			if (!mc_ptr)
 				break;
 			memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr,
--- wireless-testing.orig/drivers/net/eepro.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/eepro.c	2009-06-13 12:29:37.000000000 +0200
@@ -1285,9 +1285,9 @@ set_multicast_list(struct net_device *de
 	struct eepro_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	unsigned short mode;
-	struct dev_mc_list *dmi=dev->mc_list;
+	struct dev_mc_list *dmi=dev->mc.list;
 
-	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || dev->mc_count > 63)
+	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || dev->mc.count > 63)
 	{
 		eepro_sw2bank2(ioaddr); /* be CAREFUL, BANK 2 now */
 		mode = inb(ioaddr + REG2);
@@ -1297,7 +1297,7 @@ set_multicast_list(struct net_device *de
 		eepro_sw2bank0(ioaddr); /* Return to BANK 0 now */
 	}
 
-	else if (dev->mc_count==0 )
+	else if (dev->mc.count==0 )
 	{
 		eepro_sw2bank2(ioaddr); /* be CAREFUL, BANK 2 now */
 		mode = inb(ioaddr + REG2);
@@ -1327,9 +1327,9 @@ set_multicast_list(struct net_device *de
 		outw(MC_SETUP, ioaddr + IO_PORT);
 		outw(0, ioaddr + IO_PORT);
 		outw(0, ioaddr + IO_PORT);
-		outw(6*(dev->mc_count + 1), ioaddr + IO_PORT);
+		outw(6*(dev->mc.count + 1), ioaddr + IO_PORT);
 
-		for (i = 0; i < dev->mc_count; i++)
+		for (i = 0; i < dev->mc.count; i++)
 		{
 			eaddrs=(unsigned short *)dmi->dmi_addr;
 			dmi=dmi->next;
@@ -1346,7 +1346,7 @@ set_multicast_list(struct net_device *de
 		outb(MC_SETUP, ioaddr);
 
 		/* Update the transmit queue */
-		i = lp->tx_end + XMT_HEADER + 6*(dev->mc_count + 1);
+		i = lp->tx_end + XMT_HEADER + 6*(dev->mc.count + 1);
 
 		if (lp->tx_start != lp->tx_end)
 		{
@@ -1378,8 +1378,8 @@ set_multicast_list(struct net_device *de
 					break;
 				} else if ((i & 0x0f) == 0x03)	{ /* MC-Done */
 					printk(KERN_DEBUG "%s: set Rx mode to %d address%s.\n",
-						dev->name, dev->mc_count,
-						dev->mc_count > 1 ? "es":"");
+						dev->name, dev->mc.count,
+						dev->mc.count > 1 ? "es":"");
 					break;
 				}
 			}
--- wireless-testing.orig/drivers/net/eexpress.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/eexpress.c	2009-06-13 12:29:37.000000000 +0200
@@ -1577,7 +1577,7 @@ static void eexp_setup_filter(struct net
 {
 	struct dev_mc_list *dmi;
 	unsigned short ioaddr = dev->base_addr;
-	int count = dev->mc_count;
+	int count = dev->mc.count;
 	int i;
 	if (count > 8) {
 		printk(KERN_INFO "%s: too many multicast addresses (%d)\n",
@@ -1587,7 +1587,7 @@ static void eexp_setup_filter(struct net
 
 	outw(CONF_NR_MULTICAST & ~31, ioaddr+SM_PTR);
 	outw(6*count, ioaddr+SHADOW(CONF_NR_MULTICAST));
-	for (i = 0, dmi = dev->mc_list; i < count; i++, dmi = dmi->next) {
+	for (i = 0, dmi = dev->mc.list; i < count; i++, dmi = dmi->next) {
 		unsigned short *data;
 		if (!dmi) {
 			printk(KERN_INFO "%s: too few multicast addresses\n", dev->name);
@@ -1626,9 +1626,9 @@ eexp_set_multicast(struct net_device *de
         }
         if (!(dev->flags & IFF_PROMISC)) {
                 eexp_setup_filter(dev);
-                if (lp->old_mc_count != dev->mc_count) {
+                if (lp->old_mc_count != dev->mc.count) {
                         kick = 1;
-                        lp->old_mc_count = dev->mc_count;
+                        lp->old_mc_count = dev->mc.count;
                 }
         }
         if (kick) {
--- wireless-testing.orig/drivers/net/ehea/ehea_main.c	2009-05-11 21:32:39.000000000 +0200
+++ wireless-testing/drivers/net/ehea/ehea_main.c	2009-06-13 12:29:37.000000000 +0200
@@ -1977,7 +1977,7 @@ static void ehea_set_multicast_list(stru
 	}
 	ehea_allmulti(dev, 0);
 
-	if (dev->mc_count) {
+	if (dev->mc.count) {
 		ret = ehea_drop_multicast_list(dev);
 		if (ret) {
 			/* Dropping the current multicast list failed.
@@ -1986,14 +1986,14 @@ static void ehea_set_multicast_list(stru
 			ehea_allmulti(dev, 1);
 		}
 
-		if (dev->mc_count > port->adapter->max_mc_mac) {
+		if (dev->mc.count > port->adapter->max_mc_mac) {
 			ehea_info("Mcast registration limit reached (0x%llx). "
 				  "Use ALLMULTI!",
 				  port->adapter->max_mc_mac);
 			goto out;
 		}
 
-		for (i = 0, k_mcl_entry = dev->mc_list; i < dev->mc_count; i++,
+		for (i = 0, k_mcl_entry = dev->mc.list; i < dev->mc.count; i++,
 			     k_mcl_entry = k_mcl_entry->next)
 			ehea_add_multicast_entry(port, k_mcl_entry->dmi_addr);
 
--- wireless-testing.orig/drivers/net/enc28j60.c	2009-01-13 15:05:06.000000000 +0100
+++ wireless-testing/drivers/net/enc28j60.c	2009-06-13 12:29:38.000000000 +0200
@@ -1412,7 +1412,7 @@ static void enc28j60_set_multicast_list(
 		if (netif_msg_link(priv))
 			dev_info(&dev->dev, "promiscuous mode\n");
 		priv->rxfilter = RXFILTER_PROMISC;
-	} else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count) {
+	} else if ((dev->flags & IFF_ALLMULTI) || dev->mc.count) {
 		if (netif_msg_link(priv))
 			dev_info(&dev->dev, "%smulticast mode\n",
 				(dev->flags & IFF_ALLMULTI) ? "all-" : "");
--- wireless-testing.orig/drivers/net/enic/enic_main.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/enic/enic_main.c	2009-06-13 12:29:38.000000000 +0200
@@ -713,15 +713,15 @@ static int enic_set_mac_addr(struct net_
 static void enic_set_multicast_list(struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
-	struct dev_mc_list *list = netdev->mc_list;
+	struct dev_mc_list *list = netdev->mc.list;
 	int directed = 1;
 	int multicast = (netdev->flags & IFF_MULTICAST) ? 1 : 0;
 	int broadcast = (netdev->flags & IFF_BROADCAST) ? 1 : 0;
 	int promisc = (netdev->flags & IFF_PROMISC) ? 1 : 0;
 	int allmulti = (netdev->flags & IFF_ALLMULTI) ||
-	    (netdev->mc_count > ENIC_MULTICAST_PERFECT_FILTERS);
+	    (netdev->mc.count > ENIC_MULTICAST_PERFECT_FILTERS);
 	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
-	unsigned int mc_count = netdev->mc_count;
+	unsigned int mc_count = netdev->mc.count;
 	unsigned int i, j;
 
 	if (mc_count > ENIC_MULTICAST_PERFECT_FILTERS)
--- wireless-testing.orig/drivers/net/epic100.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/epic100.c	2009-06-13 12:29:38.000000000 +0200
@@ -1390,20 +1390,20 @@ static void set_rx_mode(struct net_devic
 		outl(0x002C, ioaddr + RxCtrl);
 		/* Unconditionally log net taps. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
-	} else if ((dev->mc_count > 0)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc.count > 0)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* There is apparently a chip bug, so the multicast filter
 		   is never enabled. */
 		/* Too many to filter perfectly -- accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outl(0x000C, ioaddr + RxCtrl);
-	} else if (dev->mc_count == 0) {
+	} else if (dev->mc.count == 0) {
 		outl(0x0004, ioaddr + RxCtrl);
 		return;
 	} else {					/* Never executed, for now. */
 		struct dev_mc_list *mclist;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 			 i++, mclist = mclist->next) {
 			unsigned int bit_nr =
 				ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
--- wireless-testing.orig/drivers/net/eth16i.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/eth16i.c	2009-06-13 12:29:38.000000000 +0200
@@ -1359,7 +1359,7 @@ static void eth16i_multicast(struct net_
 {
 	int ioaddr = dev->base_addr;
 
-	if(dev->mc_count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
+	if(dev->mc.count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
 	{
 		outb(3, ioaddr + RECEIVE_MODE_REG);
 	} else {
--- wireless-testing.orig/drivers/net/ethoc.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/ethoc.c	2009-06-13 12:29:38.000000000 +0200
@@ -772,7 +772,7 @@ static void ethoc_set_multicast_list(str
 		hash[0] = 0xffffffff;
 		hash[1] = 0xffffffff;
 	} else {
-		for (mc = dev->mc_list; mc; mc = mc->next) {
+		for (mc = dev->mc.list; mc; mc = mc->next) {
 			u32 crc = ether_crc(mc->dmi_addrlen, mc->dmi_addr);
 			int bit = (crc >> 26) & 0x3f;
 			hash[bit >> 5] |= 1 << (bit & 0x1f);
--- wireless-testing.orig/drivers/net/ewrk3.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/ewrk3.c	2009-06-13 12:29:38.000000000 +0200
@@ -1168,7 +1168,7 @@ static void set_multicast_list(struct ne
 static void SetMulticastFilter(struct net_device *dev)
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	u_long iobase = dev->base_addr;
 	int i;
 	char *addrs, bit, byte;
@@ -1212,7 +1212,7 @@ static void SetMulticastFilter(struct ne
 		}
 
 		/* Update table */
-		for (i = 0; i < dev->mc_count; i++) {	/* for each address in the list */
+		for (i = 0; i < dev->mc.count; i++) {	/* for each address in the list */
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 			if ((*addrs & 0x01) == 1) {	/* multicast address? */
--- wireless-testing.orig/drivers/net/fealnx.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/fealnx.c	2009-06-13 12:29:38.000000000 +0200
@@ -1782,7 +1782,7 @@ static void __set_rx_mode(struct net_dev
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = CR_W_PROM | CR_W_AB | CR_W_AM;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
@@ -1792,7 +1792,7 @@ static void __set_rx_mode(struct net_dev
 		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			unsigned int bit;
 			bit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
--- wireless-testing.orig/drivers/net/fec.c	2009-04-16 02:16:35.000000000 +0200
+++ wireless-testing/drivers/net/fec.c	2009-06-13 12:29:38.000000000 +0200
@@ -1610,9 +1610,9 @@ static void set_multicast_list(struct ne
 			ep->fec_grp_hash_table_high = 0;
 			ep->fec_grp_hash_table_low = 0;
 
-			dmi = dev->mc_list;
+			dmi = dev->mc.list;
 
-			for (j = 0; j < dev->mc_count; j++, dmi = dmi->next)
+			for (j = 0; j < dev->mc.count; j++, dmi = dmi->next)
 			{
 				/* Only support group multicast for now.
 				*/
--- wireless-testing.orig/drivers/net/fec_mpc52xx.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/fec_mpc52xx.c	2009-06-13 12:29:38.000000000 +0200
@@ -635,8 +635,8 @@ static void mpc52xx_fec_set_multicast_li
 			u32 gaddr1 = 0x00000000;
 			u32 gaddr2 = 0x00000000;
 
-			dmi = dev->mc_list;
-			for (i=0; i<dev->mc_count; i++) {
+			dmi = dev->mc.list;
+			for (i=0; i<dev->mc.count; i++) {
 				crc = ether_crc_le(6, dmi->dmi_addr) >> 26;
 				if (crc >= 32)
 					gaddr1 |= 1 << (crc-32);
--- wireless-testing.orig/drivers/net/forcedeth.c	2009-06-07 21:32:31.000000000 +0200
+++ wireless-testing/drivers/net/forcedeth.c	2009-06-13 12:29:38.000000000 +0200
@@ -3077,7 +3077,7 @@ static void nv_set_multicast(struct net_
 	} else {
 		pff |= NVREG_PFF_MYADDR;
 
-		if (dev->flags & IFF_ALLMULTI || dev->mc_list) {
+		if (dev->flags & IFF_ALLMULTI || dev->mc.list) {
 			u32 alwaysOff[2];
 			u32 alwaysOn[2];
 
@@ -3087,7 +3087,7 @@ static void nv_set_multicast(struct net_
 			} else {
 				struct dev_mc_list *walk;
 
-				walk = dev->mc_list;
+				walk = dev->mc.list;
 				while (walk != NULL) {
 					u32 a, b;
 					a = le32_to_cpu(*(__le32 *) walk->dmi_addr);
--- wireless-testing.orig/drivers/net/fs_enet/mac-fcc.c	2008-12-19 00:28:05.000000000 +0100
+++ wireless-testing/drivers/net/fs_enet/mac-fcc.c	2009-06-13 12:29:38.000000000 +0200
@@ -218,7 +218,7 @@ static void set_multicast_finish(struct 
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
-	    dev->mc_count > FCC_MAX_MULTICAST_ADDRS) {
+	    dev->mc.count > FCC_MAX_MULTICAST_ADDRS) {
 
 		W32(ep, fen_gaddrh, 0xffffffff);
 		W32(ep, fen_gaddrl, 0xffffffff);
@@ -235,7 +235,7 @@ static void set_multicast_list(struct ne
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		for (pmc = dev->mc_list; pmc != NULL; pmc = pmc->next)
+		for (pmc = dev->mc.list; pmc != NULL; pmc = pmc->next)
 			set_multicast_one(dev, pmc->dmi_addr);
 		set_multicast_finish(dev);
 	} else
--- wireless-testing.orig/drivers/net/fs_enet/mac-fec.c	2008-12-19 00:28:05.000000000 +0100
+++ wireless-testing/drivers/net/fs_enet/mac-fec.c	2009-06-13 12:29:38.000000000 +0200
@@ -220,7 +220,7 @@ static void set_multicast_finish(struct 
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
-	    dev->mc_count > FEC_MAX_MULTICAST_ADDRS) {
+	    dev->mc.count > FEC_MAX_MULTICAST_ADDRS) {
 		fep->fec.hthi = 0xffffffffU;
 		fep->fec.htlo = 0xffffffffU;
 	}
@@ -236,7 +236,7 @@ static void set_multicast_list(struct ne
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		for (pmc = dev->mc_list; pmc != NULL; pmc = pmc->next)
+		for (pmc = dev->mc.list; pmc != NULL; pmc = pmc->next)
 			set_multicast_one(dev, pmc->dmi_addr);
 		set_multicast_finish(dev);
 	} else
--- wireless-testing.orig/drivers/net/fs_enet/mac-scc.c	2008-12-19 00:28:05.000000000 +0100
+++ wireless-testing/drivers/net/fs_enet/mac-scc.c	2009-06-13 12:29:38.000000000 +0200
@@ -213,7 +213,7 @@ static void set_multicast_finish(struct 
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
-	    dev->mc_count > SCC_MAX_MULTICAST_ADDRS) {
+	    dev->mc.count > SCC_MAX_MULTICAST_ADDRS) {
 
 		W16(ep, sen_gaddr1, 0xffff);
 		W16(ep, sen_gaddr2, 0xffff);
@@ -228,7 +228,7 @@ static void set_multicast_list(struct ne
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		for (pmc = dev->mc_list; pmc != NULL; pmc = pmc->next)
+		for (pmc = dev->mc.list; pmc != NULL; pmc = pmc->next)
 			set_multicast_one(dev, pmc->dmi_addr);
 		set_multicast_finish(dev);
 	} else
--- wireless-testing.orig/drivers/net/gianfar.c	2009-06-07 21:32:31.000000000 +0200
+++ wireless-testing/drivers/net/gianfar.c	2009-06-13 12:29:38.000000000 +0200
@@ -2196,11 +2196,11 @@ static void gfar_set_multi(struct net_de
 			em_num = 0;
 		}
 
-		if(dev->mc_count == 0)
+		if(dev->mc.count == 0)
 			return;
 
 		/* Parse the list, and set the appropriate bits */
-		for(mc_ptr = dev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+		for(mc_ptr = dev->mc.list; mc_ptr; mc_ptr = mc_ptr->next) {
 			if (idx < em_num) {
 				gfar_set_mac_for_addr(dev, idx,
 						mc_ptr->dmi_addr);
--- wireless-testing.orig/drivers/net/hamachi.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/hamachi.c	2009-06-13 12:29:38.000000000 +0200
@@ -1849,13 +1849,13 @@ static void set_rx_mode(struct net_devic
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		writew(0x000F, ioaddr + AddrMode);
-	} else if ((dev->mc_count > 63)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc.count > 63)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		writew(0x000B, ioaddr + AddrMode);
-	} else if (dev->mc_count > 0) { /* Must use the CAM filter. */
+	} else if (dev->mc.count > 0) { /* Must use the CAM filter. */
 		struct dev_mc_list *mclist;
 		int i;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 			 i++, mclist = mclist->next) {
 			writel(*(u32*)(mclist->dmi_addr), ioaddr + 0x100 + i*8);
 			writel(0x20000 | (*(u16*)&mclist->dmi_addr[4]),
--- wireless-testing.orig/drivers/net/hp100.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/hp100.c	2009-06-13 12:29:39.000000000 +0200
@@ -2087,7 +2087,7 @@ static void hp100_set_multicast_list(str
 		lp->mac2_mode = HP100_MAC2MODE6;	/* promiscuous mode = get all good */
 		lp->mac1_mode = HP100_MAC1MODE6;	/* packets on the net */
 		memset(&lp->hash_bytes, 0xff, 8);
-	} else if (dev->mc_count || (dev->flags & IFF_ALLMULTI)) {
+	} else if (dev->mc.count || (dev->flags & IFF_ALLMULTI)) {
 		lp->mac2_mode = HP100_MAC2MODE5;	/* multicast mode = get packets for */
 		lp->mac1_mode = HP100_MAC1MODE5;	/* me, broadcasts and all multicasts */
 #ifdef HP100_MULTICAST_FILTER	/* doesn't work!!! */
@@ -2101,9 +2101,9 @@ static void hp100_set_multicast_list(str
 
 			memset(&lp->hash_bytes, 0x00, 8);
 #ifdef HP100_DEBUG
-			printk("hp100: %s: computing hash filter - mc_count = %i\n", dev->name, dev->mc_count);
+			printk("hp100: %s: computing hash filter - mc_count = %i\n", dev->name, dev->mc.count);
 #endif
-			for (i = 0, dmi = dev->mc_list; i < dev->mc_count; i++, dmi = dmi->next) {
+			for (i = 0, dmi = dev->mc.list; i < dev->mc.count; i++, dmi = dmi->next) {
 				addrs = dmi->dmi_addr;
 				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
 #ifdef HP100_DEBUG
--- wireless-testing.orig/drivers/net/ibm_newemac/core.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/ibm_newemac/core.c	2009-06-13 12:29:39.000000000 +0200
@@ -390,11 +390,11 @@ static void emac_hash_mc(struct emac_ins
 	struct dev_mc_list *dmi;
 	int i;
 
-	DBG(dev, "hash_mc %d" NL, dev->ndev->mc_count);
+	DBG(dev, "hash_mc %d" NL, dev->ndev->mc.count);
 
 	memset(gaht_temp, 0, sizeof (gaht_temp));
 
-	for (dmi = dev->ndev->mc_list; dmi; dmi = dmi->next) {
+	for (dmi = dev->ndev->mc.list; dmi; dmi = dmi->next) {
 		int slot, reg, mask;
 		DBG2(dev, "mc %pM" NL, dmi->dmi_addr);
 
@@ -424,9 +424,9 @@ static inline u32 emac_iff2rmr(struct ne
 	if (ndev->flags & IFF_PROMISC)
 		r |= EMAC_RMR_PME;
 	else if (ndev->flags & IFF_ALLMULTI ||
-			 (ndev->mc_count > EMAC_XAHT_SLOTS(dev)))
+			 (ndev->mc.count > EMAC_XAHT_SLOTS(dev)))
 		r |= EMAC_RMR_PMME;
-	else if (ndev->mc_count > 0)
+	else if (ndev->mc.count > 0)
 		r |= EMAC_RMR_MAE;
 
 	return r;
--- wireless-testing.orig/drivers/net/ibmlana.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/ibmlana.c	2009-06-13 12:29:39.000000000 +0200
@@ -419,7 +419,7 @@ static void InitBoard(struct net_device 
 	/* start putting the multicast addresses into the CAM list.  Stop if
 	   it is full. */
 
-	for (mcptr = dev->mc_list; mcptr != NULL; mcptr = mcptr->next) {
+	for (mcptr = dev->mc.list; mcptr != NULL; mcptr = mcptr->next) {
 		putcam(cams, &camcnt, mcptr->dmi_addr);
 		if (camcnt == 16)
 			break;
--- wireless-testing.orig/drivers/net/ibmveth.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/ibmveth.c	2009-06-13 12:29:39.000000000 +0200
@@ -1061,7 +1061,7 @@ static void ibmveth_set_multicast_list(s
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
-	if((netdev->flags & IFF_PROMISC) || (netdev->mc_count > adapter->mcastFilterSize)) {
+	if((netdev->flags & IFF_PROMISC) || (netdev->mc.count > adapter->mcastFilterSize)) {
 		lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 					   IbmVethMcastEnableRecv |
 					   IbmVethMcastDisableFiltering,
@@ -1070,7 +1070,7 @@ static void ibmveth_set_multicast_list(s
 			ibmveth_error_printk("h_multicast_ctrl rc=%ld when entering promisc mode\n", lpar_rc);
 		}
 	} else {
-		struct dev_mc_list *mclist = netdev->mc_list;
+		struct dev_mc_list *mclist = netdev->mc.list;
 		int i;
 		/* clear the filter table & disable filtering */
 		lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
@@ -1082,7 +1082,7 @@ static void ibmveth_set_multicast_list(s
 			ibmveth_error_printk("h_multicast_ctrl rc=%ld when attempting to clear filter table\n", lpar_rc);
 		}
 		/* add the addresses to the filter table */
-		for(i = 0; i < netdev->mc_count; ++i, mclist = mclist->next) {
+		for(i = 0; i < netdev->mc.count; ++i, mclist = mclist->next) {
 			// add the multicast address to the filter table
 			unsigned long mcast_addr = 0;
 			memcpy(((char *)&mcast_addr)+2, mclist->dmi_addr, 6);
--- wireless-testing.orig/drivers/net/igb/igb_main.c	2009-05-18 12:02:00.000000000 +0200
+++ wireless-testing/drivers/net/igb/igb_main.c	2009-06-13 12:29:39.000000000 +0200
@@ -2523,8 +2523,8 @@ static void igb_set_multi(struct net_dev
 	}
 	wr32(E1000_RCTL, rctl);
 
-	if (netdev->mc_count) {
-		mta_list = kzalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	if (netdev->mc.count) {
+		mta_list = kzalloc(netdev->mc.count * 6, GFP_ATOMIC);
 		if (!mta_list) {
 			dev_err(&adapter->pdev->dev,
 			        "failed to allocate multicast filter list\n");
@@ -2533,9 +2533,9 @@ static void igb_set_multi(struct net_dev
 	}
 
 	/* The shared function expects a packed array of only addresses. */
-	mc_ptr = netdev->mc_list;
+	mc_ptr = netdev->mc.list;
 
-	for (i = 0; i < netdev->mc_count; i++) {
+	for (i = 0; i < netdev->mc.count; i++) {
 		if (!mc_ptr)
 			break;
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
--- wireless-testing.orig/drivers/net/igbvf/netdev.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/igbvf/netdev.c	2009-06-13 12:29:39.000000000 +0200
@@ -1402,8 +1402,8 @@ static void igbvf_set_multi(struct net_d
 	u8  *mta_list = NULL;
 	int i;
 
-	if (netdev->mc_count) {
-		mta_list = kmalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	if (netdev->mc.count) {
+		mta_list = kmalloc(netdev->mc.count * 6, GFP_ATOMIC);
 		if (!mta_list) {
 			dev_err(&adapter->pdev->dev,
 			        "failed to allocate multicast filter list\n");
@@ -1412,9 +1412,9 @@ static void igbvf_set_multi(struct net_d
 	}
 
 	/* prepare a packed array of only addresses. */
-	mc_ptr = netdev->mc_list;
+	mc_ptr = netdev->mc.list;
 
-	for (i = 0; i < netdev->mc_count; i++) {
+	for (i = 0; i < netdev->mc.count; i++) {
 		if (!mc_ptr)
 			break;
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr,
--- wireless-testing.orig/drivers/net/ioc3-eth.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/ioc3-eth.c	2009-06-13 12:29:39.000000000 +0200
@@ -1664,7 +1664,7 @@ static int ioc3_ioctl(struct net_device 
 
 static void ioc3_set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	struct ioc3_private *ip = netdev_priv(dev);
 	struct ioc3 *ioc3 = ip->regs;
 	u64 ehar = 0;
@@ -1681,14 +1681,14 @@ static void ioc3_set_multicast_list(stru
 		ioc3_w_emcr(ip->emcr);			/* Clear promiscuous. */
 		(void) ioc3_r_emcr();
 
-		if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+		if ((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 64)) {
 			/* Too many for hashing to make sense or we want all
 			   multicast packets anyway,  so skip computing all the
 			   hashes and just accept all packets.  */
 			ip->ehar_h = 0xffffffff;
 			ip->ehar_l = 0xffffffff;
 		} else {
-			for (i = 0; i < dev->mc_count; i++) {
+			for (i = 0; i < dev->mc.count; i++) {
 				char *addr = dmi->dmi_addr;
 				dmi = dmi->next;
 
--- wireless-testing.orig/drivers/net/ipg.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/ipg.c	2009-06-13 12:29:39.000000000 +0200
@@ -585,11 +585,11 @@ static void ipg_nic_set_multicast_list(s
 		receivemode = IPG_RM_RECEIVEALLFRAMES;
 	} else if ((dev->flags & IFF_ALLMULTI) ||
 		   ((dev->flags & IFF_MULTICAST) &&
-		    (dev->mc_count > IPG_MULTICAST_HASHTABLE_SIZE))) {
+		    (dev->mc.count > IPG_MULTICAST_HASHTABLE_SIZE))) {
 		/* NIC to be configured to receive all multicast
 		 * frames. */
 		receivemode |= IPG_RM_RECEIVEMULTICAST;
-	} else if ((dev->flags & IFF_MULTICAST) && (dev->mc_count > 0)) {
+	} else if ((dev->flags & IFF_MULTICAST) && (dev->mc.count > 0)) {
 		/* NIC to be configured to receive selected
 		 * multicast addresses. */
 		receivemode |= IPG_RM_RECEIVEMULTICASTHASH;
@@ -610,7 +610,7 @@ static void ipg_nic_set_multicast_list(s
 	hashtable[1] = 0x00000000;
 
 	/* Cycle through all multicast addresses to filter. */
-	for (mc_list_ptr = dev->mc_list;
+	for (mc_list_ptr = dev->mc.list;
 	     mc_list_ptr != NULL; mc_list_ptr = mc_list_ptr->next) {
 		/* Calculate CRC result for each multicast address. */
 		hashindex = crc32_le(0xffffffff, mc_list_ptr->dmi_addr,
--- wireless-testing.orig/drivers/net/isa-skeleton.c	2009-04-23 00:20:40.000000000 +0200
+++ wireless-testing/drivers/net/isa-skeleton.c	2009-06-13 12:29:39.000000000 +0200
@@ -654,17 +654,17 @@ set_multicast_list(struct net_device *de
 		/* Enable promiscuous mode */
 		outw(MULTICAST|PROMISC, ioaddr);
 	}
-	else if((dev->flags&IFF_ALLMULTI) || dev->mc_count > HW_MAX_ADDRS)
+	else if((dev->flags&IFF_ALLMULTI) || dev->mc.count > HW_MAX_ADDRS)
 	{
 		/* Disable promiscuous mode, use normal mode. */
 		hardware_set_filter(NULL);
 
 		outw(MULTICAST, ioaddr);
 	}
-	else if(dev->mc_count)
+	else if(dev->mc.count)
 	{
 		/* Walk the address list, and load the filter */
-		hardware_set_filter(dev->mc_list);
+		hardware_set_filter(dev->mc.list);
 
 		outw(MULTICAST, ioaddr);
 	}
--- wireless-testing.orig/drivers/net/iseries_veth.c	2009-01-21 12:47:53.000000000 +0100
+++ wireless-testing/drivers/net/iseries_veth.c	2009-06-13 12:29:39.000000000 +0200
@@ -958,10 +958,10 @@ static void veth_set_multicast_list(stru
 	write_lock_irqsave(&port->mcast_gate, flags);
 
 	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI) ||
-			(dev->mc_count > VETH_MAX_MCAST)) {
+			(dev->mc.count > VETH_MAX_MCAST)) {
 		port->promiscuous = 1;
 	} else {
-		struct dev_mc_list *dmi = dev->mc_list;
+		struct dev_mc_list *dmi = dev->mc.list;
 		int i;
 
 		port->promiscuous = 0;
@@ -969,7 +969,7 @@ static void veth_set_multicast_list(stru
 		/* Update table */
 		port->num_mcast = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < dev->mc.count; i++) {
 			u8 *addr = dmi->dmi_addr;
 			u64 xaddr = 0;
 
--- wireless-testing.orig/drivers/net/ixgb/ixgb_main.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/ixgb/ixgb_main.c	2009-06-13 12:29:39.000000000 +0200
@@ -1064,7 +1064,7 @@ ixgb_set_multi(struct net_device *netdev
 		rctl |= IXGB_RCTL_VFE;
 	}
 
-	if (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
+	if (netdev->mc.count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
@@ -1073,13 +1073,13 @@ ixgb_set_multi(struct net_device *netdev
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
-		for (i = 0, mc_ptr = netdev->mc_list;
+		for (i = 0, mc_ptr = netdev->mc.list;
 		     mc_ptr;
 		     i++, mc_ptr = mc_ptr->next)
 			memcpy(&mta[i * IXGB_ETH_LENGTH_OF_ADDRESS],
 			       mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
-		ixgb_mc_addr_list_update(hw, mta, netdev->mc_count, 0);
+		ixgb_mc_addr_list_update(hw, mta, netdev->mc.count, 0);
 	}
 }
 
@@ -1593,7 +1593,7 @@ ixgb_update_stats(struct ixgb_adapter *a
 		return;
 
 	if ((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) ||
-	   (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
+	   (netdev->mc.count > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
 		u64 multi = IXGB_READ_REG(&adapter->hw, MPRCL);
 		u32 bcast_l = IXGB_READ_REG(&adapter->hw, BPRCL);
 		u32 bcast_h = IXGB_READ_REG(&adapter->hw, BPRCH);
--- wireless-testing.orig/drivers/net/ixgbe/ixgbe_main.c	2009-04-30 23:07:18.000000000 +0200
+++ wireless-testing/drivers/net/ixgbe/ixgbe_main.c	2009-06-13 12:29:40.000000000 +0200
@@ -2015,16 +2015,16 @@ static void ixgbe_set_rx_mode(struct net
 	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 
 	/* reprogram secondary unicast list */
-	addr_count = netdev->uc_count;
+	addr_count = netdev->uc.count;
 	if (addr_count)
-		addr_list = netdev->uc_list->dmi_addr;
+		addr_list = netdev->uc.list->dmi_addr;
 	hw->mac.ops.update_uc_addr_list(hw, addr_list, addr_count,
 	                                  ixgbe_addr_list_itr);
 
 	/* reprogram multicast list */
-	addr_count = netdev->mc_count;
+	addr_count = netdev->mc.count;
 	if (addr_count)
-		addr_list = netdev->mc_list->dmi_addr;
+		addr_list = netdev->mc.list->dmi_addr;
 	hw->mac.ops.update_mc_addr_list(hw, addr_list, addr_count,
 	                                ixgbe_addr_list_itr);
 }
--- wireless-testing.orig/drivers/net/jme.c	2009-04-16 02:16:35.000000000 +0200
+++ wireless-testing/drivers/net/jme.c	2009-06-13 12:29:40.000000000 +0200
@@ -1995,8 +1995,8 @@ jme_set_multi(struct net_device *netdev)
 		int bit_nr;
 
 		jme->reg_rxmcs |= RXMCS_MULFRAME | RXMCS_MULFILTERED;
-		for (i = 0, mclist = netdev->mc_list;
-			mclist && i < netdev->mc_count;
+		for (i = 0, mclist = netdev->mc.list;
+			mclist && i < netdev->mc.count;
 			++i, mclist = mclist->next) {
 
 			bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3F;
--- wireless-testing.orig/drivers/net/korina.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/korina.c	2009-06-13 12:29:40.000000000 +0200
@@ -484,7 +484,7 @@ static void korina_multicast_list(struct
 {
 	struct korina_private *lp = netdev_priv(dev);
 	unsigned long flags;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	u32 recognise = ETH_ARC_AB;	/* always accept broadcasts */
 	int i;
 
@@ -492,19 +492,19 @@ static void korina_multicast_list(struct
 	if (dev->flags & IFF_PROMISC)
 		recognise |= ETH_ARC_PRO;
 
-	else if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 4))
+	else if ((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 4))
 		/* All multicast and broadcast */
 		recognise |= ETH_ARC_AM;
 
 	/* Build the hash table */
-	if (dev->mc_count > 4) {
+	if (dev->mc.count > 4) {
 		u16 hash_table[4];
 		u32 crc;
 
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < dev->mc.count; i++) {
 			char *addrs = dmi->dmi_addr;
 
 			dmi = dmi->next;
--- wireless-testing.orig/drivers/net/lance.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/lance.c	2009-06-13 12:29:40.000000000 +0200
@@ -1286,7 +1286,7 @@ static void set_multicast_list(struct ne
 	} else {
 		short multicast_table[4];
 		int i;
-		int num_addrs=dev->mc_count;
+		int num_addrs=dev->mc.count;
 		if(dev->flags&IFF_ALLMULTI)
 			num_addrs=1;
 		/* FIXIT: We don't use the multicast table, but rely on upper-layer filtering. */
--- wireless-testing.orig/drivers/net/lib82596.c	2009-01-13 15:05:06.000000000 +0100
+++ wireless-testing/drivers/net/lib82596.c	2009-06-13 12:29:40.000000000 +0200
@@ -1342,7 +1342,7 @@ static void set_multicast_list(struct ne
 	DEB(DEB_MULTI,
 	    printk(KERN_DEBUG
 		   "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
-		   dev->name, dev->mc_count,
+		   dev->name, dev->mc.count,
 		   dev->flags & IFF_PROMISC ? "ON" : "OFF",
 		   dev->flags & IFF_ALLMULTI ? "ON" : "OFF"));
 
@@ -1378,23 +1378,23 @@ static void set_multicast_list(struct ne
 		}
 	}
 
-	cnt = dev->mc_count;
+	cnt = dev->mc.count;
 	if (cnt > MAX_MC_CNT) {
 		cnt = MAX_MC_CNT;
 		printk(KERN_NOTICE "%s: Only %d multicast addresses supported",
 			dev->name, cnt);
 	}
 
-	if (dev->mc_count > 0) {
+	if (dev->mc.count > 0) {
 		struct dev_mc_list *dmi;
 		unsigned char *cp;
 		struct mc_cmd *cmd;
 
 		cmd = &dma->mc_cmd;
 		cmd->cmd.command = SWAP16(CmdMulticastList);
-		cmd->mc_cnt = SWAP16(dev->mc_count * 6);
+		cmd->mc_cnt = SWAP16(dev->mc.count * 6);
 		cp = cmd->mc_addrs;
-		for (dmi = dev->mc_list;
+		for (dmi = dev->mc.list;
 		     cnt && dmi != NULL;
 		     dmi = dmi->next, cnt--, cp += 6) {
 			memcpy(cp, dmi->dmi_addr, 6);
--- wireless-testing.orig/drivers/net/lib8390.c	2009-01-13 15:05:06.000000000 +0100
+++ wireless-testing/drivers/net/lib8390.c	2009-06-13 12:29:40.000000000 +0200
@@ -906,7 +906,7 @@ static inline void make_mc_bits(u8 *bits
 {
 	struct dev_mc_list *dmi;
 
-	for (dmi=dev->mc_list; dmi; dmi=dmi->next)
+	for (dmi=dev->mc.list; dmi; dmi=dmi->next)
 	{
 		u32 crc;
 		if (dmi->dmi_addrlen != ETH_ALEN)
@@ -940,7 +940,7 @@ static void do_set_multicast_list(struct
 	if (!(dev->flags&(IFF_PROMISC|IFF_ALLMULTI)))
 	{
 		memset(ei_local->mcfilter, 0, 8);
-		if (dev->mc_list)
+		if (dev->mc.list)
 			make_mc_bits(ei_local->mcfilter, dev);
 	}
 	else
@@ -974,7 +974,7 @@ static void do_set_multicast_list(struct
 
   	if(dev->flags&IFF_PROMISC)
   		ei_outb_p(E8390_RXCONFIG | 0x18, e8390_base + EN0_RXCR);
-	else if(dev->flags&IFF_ALLMULTI || dev->mc_list)
+	else if(dev->flags&IFF_ALLMULTI || dev->mc.list)
   		ei_outb_p(E8390_RXCONFIG | 0x08, e8390_base + EN0_RXCR);
   	else
   		ei_outb_p(E8390_RXCONFIG, e8390_base + EN0_RXCR);
--- wireless-testing.orig/drivers/net/lp486e.c	2009-04-09 10:00:15.000000000 +0200
+++ wireless-testing/drivers/net/lp486e.c	2009-06-13 12:29:40.000000000 +0200
@@ -1253,20 +1253,20 @@ static void set_multicast_list(struct ne
 
 	if (i596_debug > 1)
 		printk ("%s: set multicast list %d\n",
-			dev->name, dev->mc_count);
+			dev->name, dev->mc.count);
 
-	if (dev->mc_count > 0) {
+	if (dev->mc.count > 0) {
 		struct dev_mc_list *dmi;
 		char *cp;
-		cmd = kmalloc(sizeof(struct i596_cmd)+2+dev->mc_count*6, GFP_ATOMIC);
+		cmd = kmalloc(sizeof(struct i596_cmd)+2+dev->mc.count*6, GFP_ATOMIC);
 		if (cmd == NULL) {
 			printk (KERN_ERR "%s: set_multicast Memory squeeze.\n", dev->name);
 			return;
 		}
 		cmd->command = CmdMulticastList;
-		*((unsigned short *) (cmd + 1)) = dev->mc_count * 6;
+		*((unsigned short *) (cmd + 1)) = dev->mc.count * 6;
 		cp = ((char *)(cmd + 1))+2;
-		for (dmi = dev->mc_list; dmi != NULL; dmi = dmi->next) {
+		for (dmi = dev->mc.list; dmi != NULL; dmi = dmi->next) {
 			memcpy(cp, dmi,6);
 			cp += 6;
 		}
@@ -1277,7 +1277,7 @@ static void set_multicast_list(struct ne
 		if (lp->set_conf.pa_next != I596_NULL) {
 			return;
 		}
-		if (dev->mc_count == 0 && !(dev->flags & (IFF_PROMISC | IFF_ALLMULTI))) {
+		if (dev->mc.count == 0 && !(dev->flags & (IFF_PROMISC | IFF_ALLMULTI))) {
 			lp->i596_config[8] &= ~0x01;
 		} else {
 			lp->i596_config[8] |= 0x01;
--- wireless-testing.orig/drivers/net/mac89x0.c	2009-04-23 00:20:41.000000000 +0200
+++ wireless-testing/drivers/net/mac89x0.c	2009-06-13 12:29:40.000000000 +0200
@@ -571,7 +571,7 @@ static void set_multicast_list(struct ne
 	{
 		lp->rx_mode = RX_ALL_ACCEPT;
 	}
-	else if((dev->flags&IFF_ALLMULTI)||dev->mc_list)
+	else if((dev->flags&IFF_ALLMULTI)||dev->mc.list)
 	{
 		/* The multicast-accept list is initialized to accept-all, and we
 		   rely on higher-level filtering for now. */
--- wireless-testing.orig/drivers/net/macb.c	2009-04-30 23:07:18.000000000 +0200
+++ wireless-testing/drivers/net/macb.c	2009-06-13 12:29:40.000000000 +0200
@@ -884,8 +884,8 @@ static void macb_sethashtable(struct net
 
 	mc_filter[0] = mc_filter[1] = 0;
 
-	curr = dev->mc_list;
-	for (i = 0; i < dev->mc_count; i++, curr = curr->next) {
+	curr = dev->mc.list;
+	for (i = 0; i < dev->mc.count; i++, curr = curr->next) {
 		if (!curr) break;	/* unexpected end of list */
 
 		bitnr = hash_get_index(curr->dmi_addr);
@@ -918,7 +918,7 @@ static void macb_set_rx_mode(struct net_
 		macb_writel(bp, HRB, -1);
 		macb_writel(bp, HRT, -1);
 		cfg |= MACB_BIT(NCFGR_MTI);
-	} else if (dev->mc_count > 0) {
+	} else if (dev->mc.count > 0) {
 		/* Enable specific multicasts */
 		macb_sethashtable(dev);
 		cfg |= MACB_BIT(NCFGR_MTI);
--- wireless-testing.orig/drivers/net/mace.c	2009-01-13 15:05:06.000000000 +0100
+++ wireless-testing/drivers/net/mace.c	2009-06-13 12:29:40.000000000 +0200
@@ -592,7 +592,7 @@ static void mace_set_multicast(struct ne
 	mp->maccc |= PROM;
     } else {
 	unsigned char multicast_filter[8];
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 
 	if (dev->flags & IFF_ALLMULTI) {
 	    for (i = 0; i < 8; i++)
@@ -600,7 +600,7 @@ static void mace_set_multicast(struct ne
 	} else {
 	    for (i = 0; i < 8; i++)
 		multicast_filter[i] = 0;
-	    for (i = 0; i < dev->mc_count; i++) {
+	    for (i = 0; i < dev->mc.count; i++) {
 	        crc = ether_crc_le(6, dmi->dmi_addr);
 		j = crc >> 26;	/* bit number in multicast_filter */
 		multicast_filter[j >> 3] |= 1 << (j & 7);
--- wireless-testing.orig/drivers/net/macmace.c	2009-01-13 15:05:06.000000000 +0100
+++ wireless-testing/drivers/net/macmace.c	2009-06-13 12:29:40.000000000 +0200
@@ -503,7 +503,7 @@ static void mace_set_multicast(struct ne
 		mb->maccc |= PROM;
 	} else {
 		unsigned char multicast_filter[8];
-		struct dev_mc_list *dmi = dev->mc_list;
+		struct dev_mc_list *dmi = dev->mc.list;
 
 		if (dev->flags & IFF_ALLMULTI) {
 			for (i = 0; i < 8; i++) {
@@ -512,7 +512,7 @@ static void mace_set_multicast(struct ne
 		} else {
 			for (i = 0; i < 8; i++)
 				multicast_filter[i] = 0;
-			for (i = 0; i < dev->mc_count; i++) {
+			for (i = 0; i < dev->mc.count; i++) {
 				crc = ether_crc_le(6, dmi->dmi_addr);
 				j = crc >> 26;	/* bit number in multicast_filter */
 				multicast_filter[j >> 3] |= 1 << (j & 7);
--- wireless-testing.orig/drivers/net/mlx4/en_netdev.c	2009-04-30 23:07:18.000000000 +0200
+++ wireless-testing/drivers/net/mlx4/en_netdev.c	2009-06-13 12:29:40.000000000 +0200
@@ -179,7 +179,7 @@ static void mlx4_en_cache_mclist(struct 
 	struct dev_mc_list *tmp;
 	struct dev_mc_list *plist = NULL;
 
-	for (mclist = dev->mc_list; mclist; mclist = mclist->next) {
+	for (mclist = dev->mc.list; mclist; mclist = mclist->next) {
 		tmp = kmalloc(sizeof(struct dev_mc_list), GFP_ATOMIC);
 		if (!tmp) {
 			mlx4_err(mdev, "failed to allocate multicast list\n");
--- wireless-testing.orig/drivers/net/mv643xx_eth.c	2009-05-30 01:38:26.000000000 +0200
+++ wireless-testing/drivers/net/mv643xx_eth.c	2009-06-13 12:29:40.000000000 +0200
@@ -1730,7 +1730,7 @@ static u32 uc_addr_filter_mask(struct ne
 		return 0;
 
 	nibbles = 1 << (dev->dev_addr[5] & 0x0f);
-	for (uc_ptr = dev->uc_list; uc_ptr != NULL; uc_ptr = uc_ptr->next) {
+	for (uc_ptr = dev->uc.list; uc_ptr != NULL; uc_ptr = uc_ptr->next) {
 		if (memcmp(dev->dev_addr, uc_ptr->da_addr, 5))
 			return 0;
 		if ((dev->dev_addr[5] ^ uc_ptr->da_addr[5]) & 0xf0)
@@ -1830,7 +1830,7 @@ oom:
 	memset(mc_spec, 0, 0x100);
 	memset(mc_other, 0, 0x100);
 
-	for (addr = dev->mc_list; addr != NULL; addr = addr->next) {
+	for (addr = dev->mc.list; addr != NULL; addr = addr->next) {
 		u8 *a = addr->da_addr;
 		u32 *table;
 		int entry;
--- wireless-testing.orig/drivers/net/myri10ge/myri10ge.c	2009-04-23 00:20:41.000000000 +0200
+++ wireless-testing/drivers/net/myri10ge/myri10ge.c	2009-06-13 12:29:40.000000000 +0200
@@ -3024,7 +3024,7 @@ static void myri10ge_set_multicast_list(
 	}
 
 	/* Walk the multicast list, and add each address */
-	for (mc_list = dev->mc_list; mc_list != NULL; mc_list = mc_list->next) {
+	for (mc_list = dev->mc.list; mc_list != NULL; mc_list = mc_list->next) {
 		memcpy(data, &mc_list->dmi_addr, 6);
 		cmd.data0 = ntohl(data[0]);
 		cmd.data1 = ntohl(data[1]);
--- wireless-testing.orig/drivers/net/natsemi.c	2009-04-09 10:00:16.000000000 +0200
+++ wireless-testing/drivers/net/natsemi.c	2009-06-13 12:29:40.000000000 +0200
@@ -2488,7 +2488,7 @@ static void __set_rx_mode(struct net_dev
 	if (dev->flags & IFF_PROMISC) { /* Set promiscuous. */
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptAllPhys | AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 	  || (dev->flags & IFF_ALLMULTI)) {
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptMyPhys;
@@ -2496,7 +2496,7 @@ static void __set_rx_mode(struct net_dev
 		struct dev_mc_list *mclist;
 		int i;
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 			 i++, mclist = mclist->next) {
 			int b = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
 			mc_filter[b/8] |= (1 << (b & 0x07));
--- wireless-testing.orig/drivers/net/netxen/netxen_nic_hw.c	2009-04-09 10:00:16.000000000 +0200
+++ wireless-testing/drivers/net/netxen/netxen_nic_hw.c	2009-06-13 12:29:41.000000000 +0200
@@ -417,7 +417,7 @@ void netxen_p2_nic_set_multi(struct net_
 		return;
 	}
 
-	if (netdev->mc_count == 0) {
+	if (netdev->mc.count == 0) {
 		adapter->set_promisc(adapter,
 				NETXEN_NIU_NON_PROMISC_MODE);
 		netxen_nic_disable_mcast_filter(adapter);
@@ -426,17 +426,17 @@ void netxen_p2_nic_set_multi(struct net_
 
 	adapter->set_promisc(adapter, NETXEN_NIU_ALLMULTI_MODE);
 	if (netdev->flags & IFF_ALLMULTI ||
-			netdev->mc_count > adapter->max_mc_count) {
+			netdev->mc.count > adapter->max_mc_count) {
 		netxen_nic_disable_mcast_filter(adapter);
 		return;
 	}
 
 	netxen_nic_enable_mcast_filter(adapter);
 
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next, index++)
+	for (mc_ptr = netdev->mc.list; mc_ptr; mc_ptr = mc_ptr->next, index++)
 		netxen_nic_set_mcast_addr(adapter, index, mc_ptr->dmi_addr);
 
-	if (index != netdev->mc_count)
+	if (index != netdev->mc.count)
 		printk(KERN_WARNING "%s: %s multicast address count mismatch\n",
 			netxen_nic_driver_name, netdev->name);
 
@@ -579,13 +579,13 @@ void netxen_p3_nic_set_multi(struct net_
 	}
 
 	if ((netdev->flags & IFF_ALLMULTI) ||
-			(netdev->mc_count > adapter->max_mc_count)) {
+			(netdev->mc.count > adapter->max_mc_count)) {
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 		goto send_fw_cmd;
 	}
 
-	if (netdev->mc_count > 0) {
-		for (mc_ptr = netdev->mc_list; mc_ptr;
+	if (netdev->mc.count > 0) {
+		for (mc_ptr = netdev->mc.list; mc_ptr;
 		     mc_ptr = mc_ptr->next) {
 			nx_p3_nic_add_mac(adapter, mc_ptr->dmi_addr,
 					  &add_list, &del_list);
--- wireless-testing.orig/drivers/net/ni5010.c	2009-04-09 10:00:16.000000000 +0200
+++ wireless-testing/drivers/net/ni5010.c	2009-06-13 12:29:41.000000000 +0200
@@ -651,7 +651,7 @@ static void ni5010_set_multicast_list(st
 
 	PRINTK2((KERN_DEBUG "%s: entering set_multicast_list\n", dev->name));
 
-	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI || dev->mc_list) {
+	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI || dev->mc.list) {
 		outb(RMD_PROMISC, EDLC_RMODE); /* Enable promiscuous mode */
 		PRINTK((KERN_DEBUG "%s: Entering promiscuous mode\n", dev->name));
 	} else {
--- wireless-testing.orig/drivers/net/ni52.c	2009-04-09 10:00:16.000000000 +0200
+++ wireless-testing/drivers/net/ni52.c	2009-06-13 12:29:41.000000000 +0200
@@ -596,8 +596,8 @@ static int init586(struct net_device *de
 	struct iasetup_cmd_struct __iomem *ias_cmd;
 	struct tdr_cmd_struct __iomem *tdr_cmd;
 	struct mcsetup_cmd_struct __iomem *mc_cmd;
-	struct dev_mc_list *dmi = dev->mc_list;
-	int num_addrs = dev->mc_count;
+	struct dev_mc_list *dmi = dev->mc.list;
+	int num_addrs = dev->mc.count;
 
 	ptr = p->scb + 1;
 
--- wireless-testing.orig/drivers/net/ni65.c	2009-04-09 10:00:16.000000000 +0200
+++ wireless-testing/drivers/net/ni65.c	2009-06-13 12:29:41.000000000 +0200
@@ -848,7 +848,7 @@ static int ni65_lance_reinit(struct net_
 
 	 if(dev->flags & IFF_PROMISC)
 		 ni65_init_lance(p,dev->dev_addr,0x00,M_PROM);
-	 else if(dev->mc_count || dev->flags & IFF_ALLMULTI)
+	 else if(dev->mc.count || dev->flags & IFF_ALLMULTI)
 		 ni65_init_lance(p,dev->dev_addr,0xff,0x0);
 	 else
 		 ni65_init_lance(p,dev->dev_addr,0x00,0x00);
--- wireless-testing.orig/drivers/net/niu.c	2009-04-16 02:16:35.000000000 +0200
+++ wireless-testing/drivers/net/niu.c	2009-06-13 12:29:41.000000000 +0200
@@ -6339,10 +6339,10 @@ static void niu_set_rx_mode(struct net_d
 	np->flags &= ~(NIU_FLAGS_MCAST | NIU_FLAGS_PROMISC);
 	if (dev->flags & IFF_PROMISC)
 		np->flags |= NIU_FLAGS_PROMISC;
-	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 0))
+	if ((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 0))
 		np->flags |= NIU_FLAGS_MCAST;
 
-	alt_cnt = dev->uc_count;
+	alt_cnt = dev->uc.count;
 	if (alt_cnt > niu_num_alt_addr(np)) {
 		alt_cnt = 0;
 		np->flags |= NIU_FLAGS_PROMISC;
@@ -6351,7 +6351,7 @@ static void niu_set_rx_mode(struct net_d
 	if (alt_cnt) {
 		int index = 0;
 
-		for (addr = dev->uc_list; addr; addr = addr->next) {
+		for (addr = dev->uc.list; addr; addr = addr->next) {
 			err = niu_set_alt_mac(np, index,
 					      addr->da_addr);
 			if (err)
@@ -6383,8 +6383,8 @@ static void niu_set_rx_mode(struct net_d
 	if (dev->flags & IFF_ALLMULTI) {
 		for (i = 0; i < 16; i++)
 			hash[i] = 0xffff;
-	} else if (dev->mc_count > 0) {
-		for (addr = dev->mc_list; addr; addr = addr->next) {
+	} else if (dev->mc.count > 0) {
+		for (addr = dev->mc.list; addr; addr = addr->next) {
 			u32 crc = ether_crc_le(ETH_ALEN, addr->da_addr);
 
 			crc >>= 24;
--- wireless-testing.orig/drivers/net/ns83820.c	2009-04-09 10:00:16.000000000 +0200
+++ wireless-testing/drivers/net/ns83820.c	2009-06-13 12:29:41.000000000 +0200
@@ -1719,7 +1719,7 @@ static void ns83820_set_multicast(struct
 	else
 		and_mask &= ~(RFCR_AAU | RFCR_AAM);
 
-	if (ndev->flags & IFF_ALLMULTI || ndev->mc_count)
+	if (ndev->flags & IFF_ALLMULTI || ndev->mc.count)
 		or_mask |= RFCR_AAM;
 	else
 		and_mask &= ~RFCR_AAM;
--- wireless-testing.orig/drivers/net/pci-skeleton.c	2009-01-13 15:05:06.000000000 +0100
+++ wireless-testing/drivers/net/pci-skeleton.c	2009-06-13 12:29:41.000000000 +0200
@@ -1820,7 +1820,7 @@ static void netdrv_set_rx_mode (struct n
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -1829,7 +1829,7 @@ static void netdrv_set_rx_mode (struct n
 		struct dev_mc_list *mclist;
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
--- wireless-testing.orig/drivers/net/pcmcia/3c574_cs.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/pcmcia/3c574_cs.c	2009-06-13 12:29:41.000000000 +0200
@@ -1152,7 +1152,7 @@ static void set_rx_mode(struct net_devic
 	if (dev->flags & IFF_PROMISC)
 		outw(SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm,
 			 ioaddr + EL3_CMD);
-	else if (dev->mc_count || (dev->flags & IFF_ALLMULTI))
+	else if (dev->mc.count || (dev->flags & IFF_ALLMULTI))
 		outw(SetRxFilter|RxStation|RxMulticast|RxBroadcast, ioaddr + EL3_CMD);
 	else
 		outw(SetRxFilter | RxStation | RxBroadcast, ioaddr + EL3_CMD);
--- wireless-testing.orig/drivers/net/pcmcia/3c589_cs.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/pcmcia/3c589_cs.c	2009-06-13 12:29:41.000000000 +0200
@@ -915,7 +915,7 @@ static void set_multicast_list(struct ne
     if (!pcmcia_dev_present(link)) return;
     if (dev->flags & IFF_PROMISC)
 	opts |= RxMulticast | RxProm;
-    else if (dev->mc_count || (dev->flags & IFF_ALLMULTI))
+    else if (dev->mc.count || (dev->flags & IFF_ALLMULTI))
 	opts |= RxMulticast;
     outw(opts, ioaddr + EL3_CMD);
 }
--- wireless-testing.orig/drivers/net/pcmcia/axnet_cs.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/pcmcia/axnet_cs.c	2009-06-13 12:29:41.000000000 +0200
@@ -1647,7 +1647,7 @@ static inline void make_mc_bits(u8 *bits
 	struct dev_mc_list *dmi;
 	u32 crc;
 
-	for (dmi=dev->mc_list; dmi; dmi=dmi->next) {
+	for (dmi=dev->mc.list; dmi; dmi=dmi->next) {
 		
 		crc = ether_crc(ETH_ALEN, dmi->dmi_addr);
 		/* 
@@ -1674,7 +1674,7 @@ static void do_set_multicast_list(struct
 
 	if (!(dev->flags&(IFF_PROMISC|IFF_ALLMULTI))) {
 		memset(ei_local->mcfilter, 0, 8);
-		if (dev->mc_list)
+		if (dev->mc.list)
 			make_mc_bits(ei_local->mcfilter, dev);
 	} else {
 		/* set to accept-all */
@@ -1690,7 +1690,7 @@ static void do_set_multicast_list(struct
 
   	if(dev->flags&IFF_PROMISC)
   		outb_p(E8390_RXCONFIG | 0x58, e8390_base + EN0_RXCR);
-	else if(dev->flags&IFF_ALLMULTI || dev->mc_list)
+	else if(dev->flags&IFF_ALLMULTI || dev->mc.list)
   		outb_p(E8390_RXCONFIG | 0x48, e8390_base + EN0_RXCR);
   	else
   		outb_p(E8390_RXCONFIG | 0x40, e8390_base + EN0_RXCR);
--- wireless-testing.orig/drivers/net/pcmcia/fmvj18x_cs.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/pcmcia/fmvj18x_cs.c	2009-06-13 12:29:41.000000000 +0200
@@ -1217,19 +1217,19 @@ static void set_rx_mode(struct net_devic
     if (dev->flags & IFF_PROMISC) {
 	memset(mc_filter, 0xff, sizeof(mc_filter));
 	outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
-    } else if (dev->mc_count > MC_FILTERBREAK
+    } else if (dev->mc.count > MC_FILTERBREAK
 	       ||  (dev->flags & IFF_ALLMULTI)) {
 	/* Too many to filter perfectly -- accept all multicasts. */
 	memset(mc_filter, 0xff, sizeof(mc_filter));
 	outb(2, ioaddr + RX_MODE);	/* Use normal mode. */
-    } else if (dev->mc_count == 0) {
+    } else if (dev->mc.count == 0) {
 	memset(mc_filter, 0x00, sizeof(mc_filter));
 	outb(1, ioaddr + RX_MODE);	/* Ignore almost all multicasts. */
     } else {
 	struct dev_mc_list *mclist;
 
 	memset(mc_filter, 0, sizeof(mc_filter));
-	for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+	for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 	     i++, mclist = mclist->next) {
 	    unsigned int bit =
 	    	ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
--- wireless-testing.orig/drivers/net/pcmcia/nmclan_cs.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/pcmcia/nmclan_cs.c	2009-06-13 12:29:41.000000000 +0200
@@ -1509,13 +1509,13 @@ static void set_multicast_list(struct ne
   mace_private *lp = netdev_priv(dev);
   int adr[ETHER_ADDR_LEN] = {0}; /* Ethernet address */
   int i;
-  struct dev_mc_list *dmi = dev->mc_list;
+  struct dev_mc_list *dmi = dev->mc.list;
 
 #ifdef PCMCIA_DEBUG
   if (pc_debug > 1) {
     static int old;
-    if (dev->mc_count != old) {
-      old = dev->mc_count;
+    if (dev->mc.count != old) {
+      old = dev->mc.count;
       DEBUG(0, "%s: setting Rx mode to %d addresses.\n",
 	    dev->name, old);
     }
@@ -1523,13 +1523,13 @@ static void set_multicast_list(struct ne
 #endif
 
   /* Set multicast_num_addrs. */
-  lp->multicast_num_addrs = dev->mc_count;
+  lp->multicast_num_addrs = dev->mc.count;
 
   /* Set multicast_ladrf. */
   if (num_addrs > 0) {
     /* Calculate multicast logical address filter */
     memset(lp->multicast_ladrf, 0, MACE_LADRF_LEN);
-    for (i = 0; i < dev->mc_count; i++) {
+    for (i = 0; i < dev->mc.count; i++) {
       memcpy(adr, dmi->dmi_addr, ETHER_ADDR_LEN);
       dmi = dmi->next;
       BuildLAF(lp->multicast_ladrf, adr);
@@ -1570,15 +1570,15 @@ static void set_multicast_list(struct ne
 #ifdef PCMCIA_DEBUG
   if (pc_debug > 1) {
     static int old;
-    if (dev->mc_count != old) {
-      old = dev->mc_count;
+    if (dev->mc.count != old) {
+      old = dev->mc.count;
       DEBUG(0, "%s: setting Rx mode to %d addresses.\n",
 	    dev->name, old);
     }
   }
 #endif
 
-  lp->multicast_num_addrs = dev->mc_count;
+  lp->multicast_num_addrs = dev->mc.count;
   restore_multicast_list(dev);
 
 } /* set_multicast_list */
--- wireless-testing.orig/drivers/net/pcmcia/smc91c92_cs.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/pcmcia/smc91c92_cs.c	2009-06-13 12:29:41.000000000 +0200
@@ -1748,8 +1748,8 @@ static void set_rx_mode(struct net_devic
     } else if (dev->flags & IFF_ALLMULTI)
 	rx_cfg_setting = RxStripCRC | RxEnable | RxAllMulti;
     else {
-	if (dev->mc_count)  {
-	    fill_multicast_tbl(dev->mc_count, dev->mc_list,
+	if (dev->mc.count)  {
+	    fill_multicast_tbl(dev->mc.count, dev->mc.list,
 			       (u_char *)multicast_table);
 	}
 	rx_cfg_setting = RxStripCRC | RxEnable;
--- wireless-testing.orig/drivers/net/pcmcia/xirc2ps_cs.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/pcmcia/xirc2ps_cs.c	2009-06-13 12:29:41.000000000 +0200
@@ -1427,7 +1427,7 @@ set_addresses(struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
     local_info_t *lp = netdev_priv(dev);
-    struct dev_mc_list *dmi = dev->mc_list;
+    struct dev_mc_list *dmi = dev->mc.list;
     unsigned char *addr;
     int i,j,k,n;
 
@@ -1437,7 +1437,7 @@ set_addresses(struct net_device *dev)
 	    if (++n > 9)
 		break;
 	    i = 0;
-	    if (n > 1 && n <= dev->mc_count && dmi) {
+	    if (n > 1 && n <= dev->mc.count && dmi) {
 	   	 dmi = dmi->next;
 	    }
 	}
@@ -1447,7 +1447,7 @@ set_addresses(struct net_device *dev)
 	    SelectPage(k);
 	}
 
-	if (n && n <= dev->mc_count && dmi)
+	if (n && n <= dev->mc.count && dmi)
 	    addr = dmi->dmi_addr;
 	else
 	    addr = dev->dev_addr;
@@ -1477,9 +1477,9 @@ set_multicast_list(struct net_device *de
 
     if (dev->flags & IFF_PROMISC) { /* snoop */
 	PutByte(XIRCREG42_SWC1, value | 0x06); /* set MPE and PME */
-    } else if (dev->mc_count > 9 || (dev->flags & IFF_ALLMULTI)) {
+    } else if (dev->mc.count > 9 || (dev->flags & IFF_ALLMULTI)) {
 	PutByte(XIRCREG42_SWC1, value | 0x02); /* set MPE */
-    } else if (dev->mc_count) {
+    } else if (dev->mc.count) {
 	/* the chip can filter 9 addresses perfectly */
 	PutByte(XIRCREG42_SWC1, value | 0x01);
 	SelectPage(0x40);
--- wireless-testing.orig/drivers/net/pcnet32.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/pcnet32.c	2009-06-13 12:29:41.000000000 +0200
@@ -2676,7 +2676,7 @@ static void pcnet32_load_multicast(struc
 	struct pcnet32_private *lp = netdev_priv(dev);
 	volatile struct pcnet32_init_block *ib = lp->init_block;
 	volatile __le16 *mcast_table = (__le16 *)ib->filter;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	unsigned long ioaddr = dev->base_addr;
 	char *addrs;
 	int i;
@@ -2697,7 +2697,7 @@ static void pcnet32_load_multicast(struc
 	ib->filter[1] = 0;
 
 	/* Add addresses */
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < dev->mc.count; i++) {
 		addrs = dmi->dmi_addr;
 		dmi = dmi->next;
 
--- wireless-testing.orig/drivers/net/ps3_gelic_net.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/ps3_gelic_net.c	2009-06-13 12:29:41.000000000 +0200
@@ -549,7 +549,7 @@ void gelic_net_set_multi(struct net_devi
 			status);
 
 	if ((netdev->flags & IFF_ALLMULTI) ||
-	    (netdev->mc_count > GELIC_NET_MC_COUNT_MAX)) {
+	    (netdev->mc.count > GELIC_NET_MC_COUNT_MAX)) {
 		status = lv1_net_add_multicast_address(bus_id(card),
 						       dev_id(card),
 						       0, 1);
@@ -561,7 +561,7 @@ void gelic_net_set_multi(struct net_devi
 	}
 
 	/* set multicast addresses */
-	for (mc = netdev->mc_list; mc; mc = mc->next) {
+	for (mc = netdev->mc.list; mc; mc = mc->next) {
 		addr = 0;
 		p = mc->dmi_addr;
 		for (i = 0; i < ETH_ALEN; i++) {
--- wireless-testing.orig/drivers/net/qlge/qlge_main.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/qlge/qlge_main.c	2009-06-13 12:29:41.000000000 +0200
@@ -3529,7 +3529,7 @@ static void qlge_set_multicast_list(stru
 	 * transition is taking place.
 	 */
 	if ((ndev->flags & IFF_ALLMULTI) ||
-	    (ndev->mc_count > MAX_MULTICAST_ENTRIES)) {
+	    (ndev->mc.count > MAX_MULTICAST_ENTRIES)) {
 		if (!test_bit(QL_ALLMULTI, &qdev->flags)) {
 			if (ql_set_routing_reg
 			    (qdev, RT_IDX_ALLMULTI_SLOT, RT_IDX_MCAST, 1)) {
@@ -3551,11 +3551,11 @@ static void qlge_set_multicast_list(stru
 		}
 	}
 
-	if (ndev->mc_count) {
+	if (ndev->mc.count) {
 		status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 		if (status)
 			goto exit;
-		for (i = 0, mc_ptr = ndev->mc_list; mc_ptr;
+		for (i = 0, mc_ptr = ndev->mc.list; mc_ptr;
 		     i++, mc_ptr = mc_ptr->next)
 			if (ql_set_mac_addr_reg(qdev, (u8 *) mc_ptr->dmi_addr,
 						MAC_ADDR_TYPE_MULTI_MAC, i)) {
--- wireless-testing.orig/drivers/net/r6040.c	2009-04-16 02:16:35.000000000 +0200
+++ wireless-testing/drivers/net/r6040.c	2009-06-13 12:29:41.000000000 +0200
@@ -931,7 +931,7 @@ static void r6040_multicast_list(struct 
 	u16 *adrp;
 	u16 reg;
 	unsigned long flags;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	int i;
 
 	/* MAC Address */
@@ -951,7 +951,7 @@ static void r6040_multicast_list(struct 
 	}
 	/* Too many multicast addresses
 	 * accept all traffic */
-	else if ((dev->mc_count > MCAST_MAX)
+	else if ((dev->mc.count > MCAST_MAX)
 		|| (dev->flags & IFF_ALLMULTI))
 		reg |= 0x0020;
 
@@ -959,14 +959,14 @@ static void r6040_multicast_list(struct 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Build the hash table */
-	if (dev->mc_count > MCAST_MAX) {
+	if (dev->mc.count > MCAST_MAX) {
 		u16 hash_table[4];
 		u32 crc;
 
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < dev->mc.count; i++) {
 			char *addrs = dmi->dmi_addr;
 
 			dmi = dmi->next;
@@ -988,14 +988,14 @@ static void r6040_multicast_list(struct 
 		iowrite16(hash_table[3], ioaddr + MAR3);
 	}
 	/* Multicast Address 1~4 case */
-	for (i = 0, dmi; (i < dev->mc_count) && (i < MCAST_MAX); i++) {
+	for (i = 0, dmi; (i < dev->mc.count) && (i < MCAST_MAX); i++) {
 		adrp = (u16 *)dmi->dmi_addr;
 		iowrite16(adrp[0], ioaddr + MID_1L + 8*i);
 		iowrite16(adrp[1], ioaddr + MID_1M + 8*i);
 		iowrite16(adrp[2], ioaddr + MID_1H + 8*i);
 		dmi = dmi->next;
 	}
-	for (i = dev->mc_count; i < MCAST_MAX; i++) {
+	for (i = dev->mc.count; i < MCAST_MAX; i++) {
 		iowrite16(0xffff, ioaddr + MID_0L + 8*i);
 		iowrite16(0xffff, ioaddr + MID_0M + 8*i);
 		iowrite16(0xffff, ioaddr + MID_0H + 8*i);
--- wireless-testing.orig/drivers/net/r8169.c	2009-06-11 11:04:46.000000000 +0200
+++ wireless-testing/drivers/net/r8169.c	2009-06-13 12:29:41.000000000 +0200
@@ -3742,7 +3742,7 @@ static void rtl_set_rx_mode(struct net_d
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -3753,7 +3753,7 @@ static void rtl_set_rx_mode(struct net_d
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
--- wireless-testing.orig/drivers/net/s2io.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/s2io.c	2009-06-13 12:29:41.000000000 +0200
@@ -5038,8 +5038,8 @@ static void s2io_set_multicast(struct ne
 	}
 
 	/*  Update individual M_CAST address list */
-	if ((!sp->m_cast_flg) && dev->mc_count) {
-		if (dev->mc_count >
+	if ((!sp->m_cast_flg) && dev->mc.count) {
+		if (dev->mc.count >
 		    (config->max_mc_addr - config->max_mac_addr)) {
 			DBG_PRINT(ERR_DBG, "%s: No more Rx filters ",
 				  dev->name);
@@ -5049,7 +5049,7 @@ static void s2io_set_multicast(struct ne
 		}
 
 		prev_cnt = sp->mc_addr_count;
-		sp->mc_addr_count = dev->mc_count;
+		sp->mc_addr_count = dev->mc.count;
 
 		/* Clear out the previous list of Mc in the H/W. */
 		for (i = 0; i < prev_cnt; i++) {
@@ -5075,7 +5075,7 @@ static void s2io_set_multicast(struct ne
 		}
 
 		/* Create the new Rx filter list and update the same in H/W. */
-		for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			memcpy(sp->usr_addrs[i].addr, mclist->dmi_addr,
 			       ETH_ALEN);
--- wireless-testing.orig/drivers/net/sb1250-mac.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/sb1250-mac.c	2009-06-13 12:29:41.000000000 +0200
@@ -2162,7 +2162,7 @@ static void sbmac_setmulti(struct sbmac_
 	 * XXX if the table overflows */
 
 	idx = 1;		/* skip station address */
-	mclist = dev->mc_list;
+	mclist = dev->mc.list;
 	while (mclist && (idx < MAC_ADDR_COUNT)) {
 		reg = sbmac_addr2reg(mclist->dmi_addr);
 		port = sc->sbm_base + R_MAC_ADDR_BASE+(idx * sizeof(uint64_t));
--- wireless-testing.orig/drivers/net/sc92031.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/sc92031.c	2009-06-13 12:29:41.000000000 +0200
@@ -429,13 +429,13 @@ static void _sc92031_set_mar(struct net_
 	u32 mar0 = 0, mar1 = 0;
 
 	if ((dev->flags & IFF_PROMISC)
-			|| dev->mc_count > multicast_filter_limit
+			|| dev->mc.count > multicast_filter_limit
 			|| (dev->flags & IFF_ALLMULTI))
 		mar0 = mar1 = 0xffffffff;
 	else if (dev->flags & IFF_MULTICAST) {
 		struct dev_mc_list *mc_list;
 
-		for (mc_list = dev->mc_list; mc_list; mc_list = mc_list->next) {
+		for (mc_list = dev->mc.list; mc_list; mc_list = mc_list->next) {
 			u32 crc;
 			unsigned bit = 0;
 
--- wireless-testing.orig/drivers/net/sfc/efx.c	2009-04-23 00:20:41.000000000 +0200
+++ wireless-testing/drivers/net/sfc/efx.c	2009-06-13 12:29:41.000000000 +0200
@@ -1526,7 +1526,7 @@ static int efx_set_mac_address(struct ne
 static void efx_set_multicast_list(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	struct dev_mc_list *mc_list = net_dev->mc_list;
+	struct dev_mc_list *mc_list = net_dev->mc.list;
 	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
 	bool promiscuous = !!(net_dev->flags & IFF_PROMISC);
 	bool changed = (efx->promiscuous != promiscuous);
@@ -1541,7 +1541,7 @@ static void efx_set_multicast_list(struc
 		memset(mc_hash, 0xff, sizeof(*mc_hash));
 	} else {
 		memset(mc_hash, 0x00, sizeof(*mc_hash));
-		for (i = 0; i < net_dev->mc_count; i++) {
+		for (i = 0; i < net_dev->mc.count; i++) {
 			crc = ether_crc_le(ETH_ALEN, mc_list->dmi_addr);
 			bit = crc & (EFX_MCAST_HASH_ENTRIES - 1);
 			set_bit_le(bit, mc_hash->byte);
--- wireless-testing.orig/drivers/net/sgiseeq.c	2009-01-13 15:05:06.000000000 +0100
+++ wireless-testing/drivers/net/sgiseeq.c	2009-06-13 12:29:41.000000000 +0200
@@ -661,7 +661,7 @@ static void sgiseeq_set_multicast(struct
 
 	if(dev->flags & IFF_PROMISC)
 		sp->mode = SEEQ_RCMD_RANY;
-	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count)
+	else if ((dev->flags & IFF_ALLMULTI) || dev->mc.count)
 		sp->mode = SEEQ_RCMD_RBMCAST;
 	else
 		sp->mode = SEEQ_RCMD_RBCAST;
--- wireless-testing.orig/drivers/net/sis190.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/sis190.c	2009-06-13 12:29:41.000000000 +0200
@@ -841,7 +841,7 @@ static void sis190_set_rx_mode(struct ne
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 			AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((dev->mc.count > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -852,7 +852,7 @@ static void sis190_set_rx_mode(struct ne
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			int bit_nr =
 				ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3f;
--- wireless-testing.orig/drivers/net/sis900.c	2009-04-09 10:00:17.000000000 +0200
+++ wireless-testing/drivers/net/sis900.c	2009-06-13 12:29:41.000000000 +0200
@@ -2288,7 +2288,7 @@ static void set_rx_mode(struct net_devic
 		rx_mode = RFPromiscuous;
 		for (i = 0; i < table_entries; i++)
 			mc_filter[i] = 0xffff;
-	} else if ((net_dev->mc_count > multicast_filter_limit) ||
+	} else if ((net_dev->mc.count > multicast_filter_limit) ||
 		   (net_dev->flags & IFF_ALLMULTI)) {
 		/* too many multicast addresses or accept all multicast packet */
 		rx_mode = RFAAB | RFAAM;
@@ -2300,8 +2300,8 @@ static void set_rx_mode(struct net_devic
 		 * packets */
 		struct dev_mc_list *mclist;
 		rx_mode = RFAAB;
-		for (i = 0, mclist = net_dev->mc_list;
-			mclist && i < net_dev->mc_count;
+		for (i = 0, mclist = net_dev->mc.list;
+			mclist && i < net_dev->mc.count;
 			i++, mclist = mclist->next) {
 			unsigned int bit_nr =
 				sis900_mcast_bitnr(mclist->dmi_addr, sis_priv->chipset_rev);
--- wireless-testing.orig/drivers/net/skfp/skfddi.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/skfp/skfddi.c	2009-06-13 12:29:41.000000000 +0200
@@ -882,14 +882,14 @@ static void skfp_ctl_set_multicast_list_
 		if (dev->flags & IFF_ALLMULTI) {
 			mac_drv_rx_mode(smc, RX_ENABLE_ALLMULTI);
 			PRINTK(KERN_INFO "ENABLE ALL MC ADDRESSES\n");
-		} else if (dev->mc_count > 0) {
-			if (dev->mc_count <= FPMAX_MULTICAST) {
+		} else if (dev->mc.count > 0) {
+			if (dev->mc.count <= FPMAX_MULTICAST) {
 				/* use exact filtering */
 
 				// point to first multicast addr
-				dmi = dev->mc_list;
+				dmi = dev->mc.list;
 
-				for (i = 0; i < dev->mc_count; i++) {
+				for (i = 0; i < dev->mc.count; i++) {
 					mac_add_multicast(smc, 
 							  (struct fddi_addr *)dmi->dmi_addr, 
 							  1);
--- wireless-testing.orig/drivers/net/skge.c	2009-04-23 00:20:41.000000000 +0200
+++ wireless-testing/drivers/net/skge.c	2009-06-13 12:29:42.000000000 +0200
@@ -2934,8 +2934,8 @@ static void genesis_set_multicast(struct
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	int i, count = dev->mc_count;
-	struct dev_mc_list *list = dev->mc_list;
+	int i, count = dev->mc.count;
+	struct dev_mc_list *list = dev->mc.list;
 	u32 mode;
 	u8 filter[8];
 
@@ -2974,7 +2974,7 @@ static void yukon_set_multicast(struct n
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	struct dev_mc_list *list = dev->mc_list;
+	struct dev_mc_list *list = dev->mc.list;
 	int rx_pause = (skge->flow_status == FLOW_STAT_REM_SEND
 			|| skge->flow_status == FLOW_STAT_SYMMETRIC);
 	u16 reg;
@@ -2989,7 +2989,7 @@ static void yukon_set_multicast(struct n
 		reg &= ~(GM_RXCR_UCF_ENA | GM_RXCR_MCF_ENA);
 	else if (dev->flags & IFF_ALLMULTI)	/* all multicast */
 		memset(filter, 0xff, sizeof(filter));
-	else if (dev->mc_count == 0 && !rx_pause)/* no multicast */
+	else if (dev->mc.count == 0 && !rx_pause)/* no multicast */
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
 		int i;
@@ -2998,7 +2998,7 @@ static void yukon_set_multicast(struct n
 		if (rx_pause)
 			yukon_add_filter(filter, pause_mc_addr);
 
-		for (i = 0; list && i < dev->mc_count; i++, list = list->next)
+		for (i = 0; list && i < dev->mc.count; i++, list = list->next)
 			yukon_add_filter(filter, list->dmi_addr);
 	}
 
--- wireless-testing.orig/drivers/net/sky2.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/sky2.c	2009-06-13 12:29:43.000000000 +0200
@@ -3380,7 +3380,7 @@ static void sky2_set_multicast(struct ne
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	struct dev_mc_list *list = dev->mc_list;
+	struct dev_mc_list *list = dev->mc.list;
 	u16 reg;
 	u8 filter[8];
 	int rx_pause;
@@ -3396,7 +3396,7 @@ static void sky2_set_multicast(struct ne
 		reg &= ~(GM_RXCR_UCF_ENA | GM_RXCR_MCF_ENA);
 	else if (dev->flags & IFF_ALLMULTI)
 		memset(filter, 0xff, sizeof(filter));
-	else if (dev->mc_count == 0 && !rx_pause)
+	else if (dev->mc.count == 0 && !rx_pause)
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
 		int i;
@@ -3405,7 +3405,7 @@ static void sky2_set_multicast(struct ne
 		if (rx_pause)
 			sky2_add_filter(filter, pause_mc_addr);
 
-		for (i = 0; list && i < dev->mc_count; i++, list = list->next)
+		for (i = 0; list && i < dev->mc.count; i++, list = list->next)
 			sky2_add_filter(filter, list->dmi_addr);
 	}
 
--- wireless-testing.orig/drivers/net/smc911x.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/smc911x.c	2009-06-13 12:29:43.000000000 +0200
@@ -1323,7 +1323,7 @@ static void smc911x_set_multicast_list(s
 	 * I don't need to zero the multicast table, because the flag is
 	 * checked before the table is
 	 */
-	else if (dev->flags & IFF_ALLMULTI || dev->mc_count > 16) {
+	else if (dev->flags & IFF_ALLMULTI || dev->mc.count > 16) {
 		DBG(SMC_DEBUG_MISC, "%s: RCR_ALMUL\n", dev->name);
 		mcr |= MAC_CR_MCPAS_;
 	}
@@ -1340,7 +1340,7 @@ static void smc911x_set_multicast_list(s
 	 * the number of the 32 bit register, while the low 5 bits are the bit
 	 * within that register.
 	 */
-	else if (dev->mc_count)  {
+	else if (dev->mc.count)  {
 		int i;
 		struct dev_mc_list *cur_addr;
 
@@ -1350,8 +1350,8 @@ static void smc911x_set_multicast_list(s
 		/* start with a table of all zeros: reject all */
 		memset(multicast_table, 0, sizeof(multicast_table));
 
-		cur_addr = dev->mc_list;
-		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
+		cur_addr = dev->mc.list;
+		for (i = 0; i < dev->mc.count; i++, cur_addr = cur_addr->next) {
 			u32 position;
 
 			/* do we have a pointer here? */
--- wireless-testing.orig/drivers/net/smc9194.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/smc9194.c	2009-06-13 12:29:43.000000000 +0200
@@ -1540,7 +1540,7 @@ static void smc_set_multicast_list(struc
 	/* We just get all multicast packets even if we only want them
 	 . from one source.  This will be changed at some future
 	 . point. */
-	else if (dev->mc_count )  {
+	else if (dev->mc.count)  {
 		/* support hardware multicasting */
 
 		/* be sure I get rid of flags I might have set */
@@ -1548,7 +1548,7 @@ static void smc_set_multicast_list(struc
 			ioaddr + RCR );
 		/* NOTE: this has to set the bank, so make sure it is the
 		   last thing called.  The bank is set to zero at the top */
-		smc_setmulticast( ioaddr, dev->mc_count, dev->mc_list );
+		smc_setmulticast( ioaddr, dev->mc.count, dev->mc.list);
 	}
 	else  {
 		outw( inw( ioaddr + RCR ) & ~(RCR_PROMISC | RCR_ALMUL),
--- wireless-testing.orig/drivers/net/smc91x.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/smc91x.c	2009-06-13 12:29:43.000000000 +0200
@@ -1391,7 +1391,7 @@ static void smc_set_multicast_list(struc
 	 * I don't need to zero the multicast table, because the flag is
 	 * checked before the table is
 	 */
-	else if (dev->flags & IFF_ALLMULTI || dev->mc_count > 16) {
+	else if (dev->flags & IFF_ALLMULTI || dev->mc.count > 16) {
 		DBG(2, "%s: RCR_ALMUL\n", dev->name);
 		lp->rcr_cur_mode |= RCR_ALMUL;
 	}
@@ -1408,7 +1408,7 @@ static void smc_set_multicast_list(struc
 	 * the number of the 8 bit register, while the low 3 bits are the bit
 	 * within that register.
 	 */
-	else if (dev->mc_count)  {
+	else if (dev->mc.count)  {
 		int i;
 		struct dev_mc_list *cur_addr;
 
@@ -1418,8 +1418,8 @@ static void smc_set_multicast_list(struc
 		/* start with a table of all zeros: reject all */
 		memset(multicast_table, 0, sizeof(multicast_table));
 
-		cur_addr = dev->mc_list;
-		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
+		cur_addr = dev->mc.list;
+		for (i = 0; i < dev->mc.count; i++, cur_addr = cur_addr->next) {
 			int position;
 
 			/* do we have a pointer here? */
--- wireless-testing.orig/drivers/net/smsc911x.c	2009-04-16 02:16:35.000000000 +0200
+++ wireless-testing/drivers/net/smsc911x.c	2009-06-13 12:29:43.000000000 +0200
@@ -1370,12 +1370,12 @@ static void smsc911x_set_multicast_list(
 		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_HPFILT_);
 		pdata->hashhi = 0;
 		pdata->hashlo = 0;
-	} else if (dev->mc_count > 0) {
+	} else if (dev->mc.count > 0) {
 		/* Enabling specific multicast addresses */
 		unsigned int hash_high = 0;
 		unsigned int hash_low = 0;
 		unsigned int count = 0;
-		struct dev_mc_list *mc_list = dev->mc_list;
+		struct dev_mc_list *mc_list = dev->mc.list;
 
 		pdata->set_bits_mask = MAC_CR_HPFILT_;
 		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_MCPAS_);
@@ -1395,8 +1395,8 @@ static void smsc911x_set_multicast_list(
 			}
 			mc_list = mc_list->next;
 		}
-		if (count != (unsigned int)dev->mc_count)
-			SMSC_WARNING(DRV, "mc_count != dev->mc_count");
+		if (count != (unsigned int)dev->mc.count)
+			SMSC_WARNING(DRV, "mc_count != dev->mc.count");
 
 		pdata->hashhi = hash_high;
 		pdata->hashlo = hash_low;
--- wireless-testing.orig/drivers/net/smsc9420.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/smsc9420.c	2009-06-13 12:29:43.000000000 +0200
@@ -1048,8 +1048,8 @@ static void smsc9420_set_multicast_list(
 		mac_cr &= (~MAC_CR_PRMS_);
 		mac_cr |= MAC_CR_MCPAS_;
 		mac_cr &= (~MAC_CR_HPFILT_);
-	} else if (dev->mc_count > 0) {
-		struct dev_mc_list *mc_list = dev->mc_list;
+	} else if (dev->mc.count > 0) {
+		struct dev_mc_list *mc_list = dev->mc.list;
 		u32 hash_lo = 0, hash_hi = 0;
 
 		smsc_dbg(HW, "Multicast filter enabled");
--- wireless-testing.orig/drivers/net/sonic.c	2009-01-13 15:05:07.000000000 +0100
+++ wireless-testing/drivers/net/sonic.c	2009-06-13 12:29:43.000000000 +0200
@@ -531,7 +531,7 @@ static void sonic_multicast_list(struct 
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	unsigned int rcr;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	unsigned char *addr;
 	int i;
 
@@ -541,13 +541,13 @@ static void sonic_multicast_list(struct 
 	if (dev->flags & IFF_PROMISC) {	/* set promiscuous mode */
 		rcr |= SONIC_RCR_PRO;
 	} else {
-		if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 15)) {
+		if ((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 15)) {
 			rcr |= SONIC_RCR_AMC;
 		} else {
 			if (sonic_debug > 2)
-				printk("sonic_multicast_list: mc_count %d\n", dev->mc_count);
+				printk("sonic_multicast_list: mc_count %d\n", dev->mc.count);
 			sonic_set_cam_enable(dev, 1);  /* always enable our own address */
-			for (i = 1; i <= dev->mc_count; i++) {
+			for (i = 1; i <= dev->mc.count; i++) {
 				addr = dmi->dmi_addr;
 				dmi = dmi->next;
 				sonic_cda_put(dev, i, SONIC_CD_CAP0, addr[1] << 8 | addr[0]);
--- wireless-testing.orig/drivers/net/spider_net.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/spider_net.c	2009-06-13 12:29:44.000000000 +0200
@@ -645,7 +645,7 @@ spider_net_set_multi(struct net_device *
 	hash = spider_net_get_multicast_hash(netdev, netdev->broadcast); */
 	set_bit(0xfd, bitmask);
 
-	for (mc = netdev->mc_list; mc; mc = mc->next) {
+	for (mc = netdev->mc.list; mc; mc = mc->next) {
 		hash = spider_net_get_multicast_hash(netdev, mc->dmi_addr);
 		set_bit(hash, bitmask);
 	}
--- wireless-testing.orig/drivers/net/starfire.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/starfire.c	2009-06-13 12:29:44.000000000 +0200
@@ -1793,15 +1793,15 @@ static void set_rx_mode(struct net_devic
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		rx_mode |= AcceptAll;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		rx_mode |= AcceptBroadcast|AcceptAllMulticast|PerfectFilter;
-	} else if (dev->mc_count <= 14) {
+	} else if (dev->mc.count <= 14) {
 		/* Use the 16 element perfect filter, skip first two entries. */
 		void __iomem *filter_addr = ioaddr + PerfFilterTable + 2 * 16;
 		__be16 *eaddrs;
-		for (i = 2, mclist = dev->mc_list; mclist && i < dev->mc_count + 2;
+		for (i = 2, mclist = dev->mc.list; mclist && i < dev->mc.count + 2;
 		     i++, mclist = mclist->next) {
 			eaddrs = (__be16 *)mclist->dmi_addr;
 			writew(be16_to_cpu(eaddrs[2]), filter_addr); filter_addr += 4;
@@ -1822,7 +1822,7 @@ static void set_rx_mode(struct net_devic
 		__le16 mc_filter[32] __attribute__ ((aligned(sizeof(long))));	/* Multicast hash filter */
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			/* The chip uses the upper 9 CRC bits
 			   as index into the hash table */
--- wireless-testing.orig/drivers/net/sun3_82586.c	2009-04-23 00:20:41.000000000 +0200
+++ wireless-testing/drivers/net/sun3_82586.c	2009-06-13 12:29:44.000000000 +0200
@@ -413,8 +413,8 @@ static int init586(struct net_device *de
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
 	volatile struct mcsetup_cmd_struct *mc_cmd;
-	struct dev_mc_list *dmi=dev->mc_list;
-	int num_addrs=dev->mc_count;
+	struct dev_mc_list *dmi=dev->mc.list;
+	int num_addrs=dev->mc.count;
 
 	ptr = (void *) ((char *)p->scb + sizeof(struct scb_struct));
 
--- wireless-testing.orig/drivers/net/sun3lance.c	2009-02-17 22:07:37.000000000 +0100
+++ wireless-testing/drivers/net/sun3lance.c	2009-06-13 12:29:44.000000000 +0200
@@ -912,7 +912,7 @@ static void set_multicast_list( struct n
 		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
 	} else {
 		short multicast_table[4];
-		int num_addrs = dev->mc_count;
+		int num_addrs = dev->mc.count;
 		int i;
 		/* We don't use the multicast table, but rely on upper-layer
 		 * filtering. */
--- wireless-testing.orig/drivers/net/sunbmac.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/sunbmac.c	2009-06-13 12:29:44.000000000 +0200
@@ -999,7 +999,7 @@ static void bigmac_set_multicast(struct 
 {
 	struct bigmac *bp = netdev_priv(dev);
 	void __iomem *bregs = bp->bregs;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	char *addrs;
 	int i;
 	u32 tmp, crc;
@@ -1013,7 +1013,7 @@ static void bigmac_set_multicast(struct 
 	while ((sbus_readl(bregs + BMAC_RXCFG) & BIGMAC_RXCFG_ENABLE) != 0)
 		udelay(20);
 
-	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if ((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 64)) {
 		sbus_writel(0xffff, bregs + BMAC_HTABLE0);
 		sbus_writel(0xffff, bregs + BMAC_HTABLE1);
 		sbus_writel(0xffff, bregs + BMAC_HTABLE2);
@@ -1028,7 +1028,7 @@ static void bigmac_set_multicast(struct 
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < dev->mc.count; i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
--- wireless-testing.orig/drivers/net/sundance.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/sundance.c	2009-06-13 12:29:44.000000000 +0200
@@ -1514,18 +1514,18 @@ static void set_rx_mode(struct net_devic
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptAll | AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 			   ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
-	} else if (dev->mc_count) {
+	} else if (dev->mc.count) {
 		struct dev_mc_list *mclist;
 		int bit;
 		int index;
 		int crc;
 		memset (mc_filter, 0, sizeof (mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			crc = ether_crc_le (ETH_ALEN, mclist->dmi_addr);
 			for (index=0, bit=0; bit < 6; bit++, crc <<= 1)
--- wireless-testing.orig/drivers/net/sungem.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/sungem.c	2009-06-13 12:29:45.000000000 +0200
@@ -1837,7 +1837,7 @@ static u32 gem_setup_multicast(struct ge
 	int i;
 
 	if ((gp->dev->flags & IFF_ALLMULTI) ||
-	    (gp->dev->mc_count > 256)) {
+	    (gp->dev->mc.count > 256)) {
 	    	for (i=0; i<16; i++)
 			writel(0xffff, gp->regs + MAC_HASH0 + (i << 2));
 		rxcfg |= MAC_RXCFG_HFE;
@@ -1846,13 +1846,13 @@ static u32 gem_setup_multicast(struct ge
 	} else {
 		u16 hash_table[16];
 		u32 crc;
-		struct dev_mc_list *dmi = gp->dev->mc_list;
+		struct dev_mc_list *dmi = gp->dev->mc.list;
 		int i;
 
 		for (i = 0; i < 16; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < gp->dev->mc_count; i++) {
+		for (i = 0; i < gp->dev->mc.count; i++) {
 			char *addrs = dmi->dmi_addr;
 
 			dmi = dmi->next;
--- wireless-testing.orig/drivers/net/sunhme.c	2009-04-01 23:46:22.000000000 +0200
+++ wireless-testing/drivers/net/sunhme.c	2009-06-13 12:29:45.000000000 +0200
@@ -1510,14 +1510,14 @@ static int happy_meal_init(struct happy_
 
 	HMD(("htable, "));
 	if ((hp->dev->flags & IFF_ALLMULTI) ||
-	    (hp->dev->mc_count > 64)) {
+	    (hp->dev->mc.count > 64)) {
 		hme_write32(hp, bregs + BMAC_HTABLE0, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE1, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE2, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE3, 0xffff);
 	} else if ((hp->dev->flags & IFF_PROMISC) == 0) {
 		u16 hash_table[4];
-		struct dev_mc_list *dmi = hp->dev->mc_list;
+		struct dev_mc_list *dmi = hp->dev->mc.list;
 		char *addrs;
 		int i;
 		u32 crc;
@@ -1525,7 +1525,7 @@ static int happy_meal_init(struct happy_
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < hp->dev->mc_count; i++) {
+		for (i = 0; i < hp->dev->mc.count; i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
@@ -2356,14 +2356,14 @@ static void happy_meal_set_multicast(str
 {
 	struct happy_meal *hp = netdev_priv(dev);
 	void __iomem *bregs = hp->bigmacregs;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	char *addrs;
 	int i;
 	u32 crc;
 
 	spin_lock_irq(&hp->happy_lock);
 
-	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if ((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 64)) {
 		hme_write32(hp, bregs + BMAC_HTABLE0, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE1, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE2, 0xffff);
@@ -2377,7 +2377,7 @@ static void happy_meal_set_multicast(str
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < dev->mc.count; i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
--- wireless-testing.orig/drivers/net/sunlance.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/sunlance.c	2009-06-13 12:29:45.000000000 +0200
@@ -1170,7 +1170,7 @@ static int lance_start_xmit(struct sk_bu
 static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	char *addrs;
 	int i;
 	u32 crc;
@@ -1196,7 +1196,7 @@ static void lance_load_multicast(struct 
 		return;
 
 	/* Add addresses */
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < dev->mc.count; i++) {
 		addrs = dmi->dmi_addr;
 		dmi   = dmi->next;
 
--- wireless-testing.orig/drivers/net/sunqe.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/sunqe.c	2009-06-13 12:29:45.000000000 +0200
@@ -627,7 +627,7 @@ static int qe_start_xmit(struct sk_buff 
 static void qe_set_multicast(struct net_device *dev)
 {
 	struct sunqe *qep = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi = dev->mc.list;
 	u8 new_mconfig = qep->mconfig;
 	char *addrs;
 	int i;
@@ -636,7 +636,7 @@ static void qe_set_multicast(struct net_
 	/* Lock out others. */
 	netif_stop_queue(dev);
 
-	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if ((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 64)) {
 		sbus_writeb(MREGS_IACONFIG_ACHNGE | MREGS_IACONFIG_LARESET,
 			    qep->mregs + MREGS_IACONFIG);
 		while ((sbus_readb(qep->mregs + MREGS_IACONFIG) & MREGS_IACONFIG_ACHNGE) != 0)
@@ -653,7 +653,7 @@ static void qe_set_multicast(struct net_
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < dev->mc.count; i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
--- wireless-testing.orig/drivers/net/sunvnet.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/sunvnet.c	2009-06-13 12:29:45.000000000 +0200
@@ -765,7 +765,7 @@ static void __update_mc_list(struct vnet
 {
 	struct dev_addr_list *p;
 
-	for (p = dev->mc_list; p; p = p->next) {
+	for (p = dev->mc.list; p; p = p->next) {
 		struct vnet_mcast_entry *m;
 
 		m = __vnet_mc_find(vp, p->dmi_addr);
--- wireless-testing.orig/drivers/net/tc35815.c	2009-04-23 00:20:41.000000000 +0200
+++ wireless-testing/drivers/net/tc35815.c	2009-06-13 12:29:45.000000000 +0200
@@ -2217,18 +2217,18 @@ tc35815_set_multicast_list(struct net_de
 		/* Enable promiscuous mode */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc | CAM_StationAcc, &tr->CAM_Ctl);
 	} else if ((dev->flags & IFF_ALLMULTI) ||
-		  dev->mc_count > CAM_ENTRY_MAX - 3) {
+		  dev->mc.count > CAM_ENTRY_MAX - 3) {
 		/* CAM 0, 1, 20 are reserved. */
 		/* Disable promiscuous mode, use normal mode. */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc, &tr->CAM_Ctl);
-	} else if (dev->mc_count) {
-		struct dev_mc_list *cur_addr = dev->mc_list;
+	} else if (dev->mc.count) {
+		struct dev_mc_list *cur_addr = dev->mc.list;
 		int i;
 		int ena_bits = CAM_Ena_Bit(CAM_ENTRY_SOURCE);
 
 		tc_writel(0, &tr->CAM_Ctl);
 		/* Walk the address list, and load the filter */
-		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
+		for (i = 0; i < dev->mc.count; i++, cur_addr = cur_addr->next) {
 			if (!cur_addr)
 				break;
 			/* entry 0,1 is reserved. */
--- wireless-testing.orig/drivers/net/tehuti.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tehuti.c	2009-06-13 12:29:45.000000000 +0200
@@ -808,7 +808,7 @@ static void bdx_setmulti(struct net_devi
 		/* set IMF to accept all multicast frmaes */
 		for (i = 0; i < MAC_MCST_HASH_NUM; i++)
 			WRITE_REG(priv, regRX_MCST_HASH0 + i * 4, ~0);
-	} else if (ndev->mc_count) {
+	} else if (ndev->mc.count) {
 		u8 hash;
 		struct dev_mc_list *mclist;
 		u32 reg, val;
@@ -826,7 +826,7 @@ static void bdx_setmulti(struct net_devi
 		/* TBD: sort addreses and write them in ascending order
 		 * into RX_MAC_MCST regs. we skip this phase now and accept ALL
 		 * multicast frames throu IMF */
-		mclist = ndev->mc_list;
+		mclist = ndev->mc.list;
 
 		/* accept the rest of addresses throu IMF */
 		for (; mclist; mclist = mclist->next) {
@@ -840,7 +840,7 @@ static void bdx_setmulti(struct net_devi
 		}
 
 	} else {
-		DBG("only own mac %d\n", ndev->mc_count);
+		DBG("only own mac %d\n", ndev->mc.count);
 		rxf_val |= GMAC_RX_FILTER_AB;
 	}
 	WRITE_REG(priv, regGMAC_RXF_A, rxf_val);
--- wireless-testing.orig/drivers/net/tg3.c	2009-04-30 23:07:18.000000000 +0200
+++ wireless-testing/drivers/net/tg3.c	2009-06-13 12:29:45.000000000 +0200
@@ -8397,7 +8397,7 @@ static void __tg3_set_rx_mode(struct net
 	} else if (dev->flags & IFF_ALLMULTI) {
 		/* Accept all multicast. */
 		tg3_set_multi (tp, 1);
-	} else if (dev->mc_count < 1) {
+	} else if (dev->mc.count < 1) {
 		/* Reject all multicast. */
 		tg3_set_multi (tp, 0);
 	} else {
@@ -8409,7 +8409,7 @@ static void __tg3_set_rx_mode(struct net
 		u32 bit;
 		u32 crc;
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 
 			crc = calc_crc (mclist->dmi_addr, ETH_ALEN);
--- wireless-testing.orig/drivers/net/tlan.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tlan.c	2009-06-13 12:29:45.000000000 +0200
@@ -1316,7 +1316,7 @@ static struct net_device_stats *TLan_Get
 
 static void TLan_SetMulticastList( struct net_device *dev )
 {
-	struct dev_mc_list	*dmi = dev->mc_list;
+	struct dev_mc_list	*dmi = dev->mc.list;
 	u32			hash1 = 0;
 	u32			hash2 = 0;
 	int			i;
@@ -1337,7 +1337,7 @@ static void TLan_SetMulticastList( struc
 			TLan_DioWrite32( dev->base_addr, TLAN_HASH_1, 0xFFFFFFFF );
 			TLan_DioWrite32( dev->base_addr, TLAN_HASH_2, 0xFFFFFFFF );
 		} else {
-			for ( i = 0; i < dev->mc_count; i++ ) {
+			for ( i = 0; i < dev->mc.count; i++ ) {
 				if ( i < 3 ) {
 					TLan_SetMac( dev, i + 1,
 						     (char *) &dmi->dmi_addr );
--- wireless-testing.orig/drivers/net/tokenring/3c359.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tokenring/3c359.c	2009-06-13 12:29:46.000000000 +0200
@@ -1409,7 +1409,7 @@ static void xl_set_rx_mode(struct net_de
 
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ;
 
-        for (i=0,dmi=dev->mc_list;i < dev->mc_count; i++,dmi = dmi->next) {
+        for (i=0,dmi=dev->mc.list;i < dev->mc.count; i++,dmi = dmi->next) {
                 dev_mc_address[0] |= dmi->dmi_addr[2] ;
                 dev_mc_address[1] |= dmi->dmi_addr[3] ;
                 dev_mc_address[2] |= dmi->dmi_addr[4] ;
--- wireless-testing.orig/drivers/net/tokenring/ibmtr.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tokenring/ibmtr.c	2009-06-13 12:29:46.000000000 +0200
@@ -993,8 +993,8 @@ static void tok_set_multicast_list(struc
 	/*BMS ifconfig tr down or hot unplug a PCMCIA card ??hownowbrowncow*/
 	if (/*BMSHELPdev->start == 0 ||*/ ti->open_status != OPEN) return;
 	address[0] = address[1] = address[2] = address[3] = 0;
-	mclist = dev->mc_list;
-	for (i = 0; i < dev->mc_count; i++) {
+	mclist = dev->mc.list;
+	for (i = 0; i < dev->mc.count; i++) {
 		address[0] |= mclist->dmi_addr[2];
 		address[1] |= mclist->dmi_addr[3];
 		address[2] |= mclist->dmi_addr[4];
--- wireless-testing.orig/drivers/net/tokenring/lanstreamer.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tokenring/lanstreamer.c	2009-06-13 12:30:14.000000000 +0200
@@ -1301,7 +1301,7 @@ static void streamer_set_rx_mode(struct 
 	writel(streamer_priv->srb,streamer_mmio+LAPA);
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ; 
   
-	for (i=0,dmi=dev->mc_list;i < dev->mc_count; i++,dmi = dmi->next) 
+	for (i=0,dmi=dev->mc.list;i < dev->mc.count; i++,dmi = dmi->next)
 	{ 
    	        dev_mc_address[0] |= dmi->dmi_addr[2] ; 
 		dev_mc_address[1] |= dmi->dmi_addr[3] ; 
--- wireless-testing.orig/drivers/net/tokenring/olympic.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tokenring/olympic.c	2009-06-13 12:30:10.000000000 +0200
@@ -1176,7 +1176,7 @@ static void olympic_set_rx_mode(struct n
 
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ; 
 
-	for (i=0,dmi=dev->mc_list;i < dev->mc_count; i++,dmi = dmi->next) { 
+	for (i=0,dmi=dev->mc.list;i < dev->mc.count; i++,dmi = dmi->next) {
 		dev_mc_address[0] |= dmi->dmi_addr[2] ; 
 		dev_mc_address[1] |= dmi->dmi_addr[3] ; 
 		dev_mc_address[2] |= dmi->dmi_addr[4] ; 
--- wireless-testing.orig/drivers/net/tokenring/tms380tr.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tokenring/tms380tr.c	2009-06-13 12:29:46.000000000 +0200
@@ -1210,8 +1210,8 @@ static void tms380tr_set_multicast_list(
 		else
 		{
 			int i;
-			struct dev_mc_list *mclist = dev->mc_list;
-			for (i=0; i< dev->mc_count; i++)
+			struct dev_mc_list *mclist = dev->mc.list;
+			for (i=0; i< dev->mc.count; i++)
 			{
 				((char *)(&tp->ocpl.FunctAddr))[0] |=
 					mclist->dmi_addr[2];
--- wireless-testing.orig/drivers/net/tsi108_eth.c	2009-04-23 00:20:42.000000000 +0200
+++ wireless-testing/drivers/net/tsi108_eth.c	2009-06-13 12:29:46.000000000 +0200
@@ -1184,9 +1184,9 @@ static void tsi108_set_rx_mode(struct ne
 
 	rxcfg &= ~(TSI108_EC_RXCFG_UFE | TSI108_EC_RXCFG_MFE);
 
-	if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
+	if (dev->flags & IFF_ALLMULTI || dev->mc.count) {
 		int i;
-		struct dev_mc_list *mc = dev->mc_list;
+		struct dev_mc_list *mc = dev->mc.list;
 		rxcfg |= TSI108_EC_RXCFG_MFE | TSI108_EC_RXCFG_MC_HASH;
 
 		memset(data->mc_hash, 0, sizeof(data->mc_hash));
--- wireless-testing.orig/drivers/net/tulip/de2104x.c	2009-02-17 22:07:37.000000000 +0100
+++ wireless-testing/drivers/net/tulip/de2104x.c	2009-06-13 12:29:46.000000000 +0200
@@ -662,7 +662,7 @@ static void build_setup_frame_hash(u16 *
 	memset(hash_table, 0, sizeof(hash_table));
 	set_bit_le(255, hash_table); 			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
-	for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+	for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 	     i++, mclist = mclist->next) {
 		int index = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x1ff;
 
@@ -691,7 +691,7 @@ static void build_setup_frame_perfect(u1
 
 	/* We have <= 14 addresses so we can use the wonderful
 	   16 address perfect filtering of the Tulip. */
-	for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+	for (i = 0, mclist = dev->mc.list; i < dev->mc.count;
 	     i++, mclist = mclist->next) {
 		eaddrs = (u16 *)mclist->dmi_addr;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
@@ -726,7 +726,7 @@ static void __de_set_rx_mode (struct net
 		goto out;
 	}
 
-	if ((dev->mc_count > 1000) || (dev->flags & IFF_ALLMULTI)) {
+	if ((dev->mc.count > 1000) || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well -- accept all multicasts. */
 		macmode |= AcceptAllMulticast;
 		goto out;
@@ -734,7 +734,7 @@ static void __de_set_rx_mode (struct net
 
 	/* Note that only the low-address shortword of setup_frame is valid!
 	   The values are doubled for big-endian architectures. */
-	if (dev->mc_count > 14)	/* Must use a multicast hash table. */
+	if (dev->mc.count > 14)	/* Must use a multicast hash table. */
 		build_setup_frame_hash (de->setup_frame, dev);
 	else
 		build_setup_frame_perfect (de->setup_frame, dev);
--- wireless-testing.orig/drivers/net/tulip/de4x5.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tulip/de4x5.c	2009-06-13 12:29:46.000000000 +0200
@@ -1952,7 +1952,7 @@ static void
 SetMulticastFilter(struct net_device *dev)
 {
     struct de4x5_private *lp = netdev_priv(dev);
-    struct dev_mc_list *dmi=dev->mc_list;
+    struct dev_mc_list *dmi=dev->mc.list;
     u_long iobase = dev->base_addr;
     int i, j, bit, byte;
     u16 hashcode;
@@ -1964,10 +1964,10 @@ SetMulticastFilter(struct net_device *de
     omr &= ~(OMR_PR | OMR_PM);
     pa = build_setup_frame(dev, ALL);        /* Build the basic frame */
 
-    if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 14)) {
+    if ((dev->flags & IFF_ALLMULTI) || (dev->mc.count > 14)) {
 	omr |= OMR_PM;                       /* Pass all multicasts */
     } else if (lp->setup_f == HASH_PERF) {   /* Hash Filtering */
-	for (i=0;i<dev->mc_count;i++) {      /* for each address in the list */
+	for (i=0;i<dev->mc.count;i++) {      /* for each address in the list */
 	    addrs=dmi->dmi_addr;
 	    dmi=dmi->next;
 	    if ((*addrs & 0x01) == 1) {      /* multicast address? */
@@ -1985,7 +1985,7 @@ SetMulticastFilter(struct net_device *de
 	    }
 	}
     } else {                                 /* Perfect filtering */
-	for (j=0; j<dev->mc_count; j++) {
+	for (j=0; j<dev->mc.count; j++) {
 	    addrs=dmi->dmi_addr;
 	    dmi=dmi->next;
 	    for (i=0; i<ETH_ALEN; i++) {
--- wireless-testing.orig/drivers/net/tulip/dmfe.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tulip/dmfe.c	2009-06-13 12:29:46.000000000 +0200
@@ -639,9 +639,9 @@ static void dmfe_init_dm910x(struct DEVI
 
 	/* Send setup frame */
 	if (db->chip_id == PCI_DM9132_ID)
-		dm9132_id_table(dev, dev->mc_count);	/* DM9132 */
+		dm9132_id_table(dev, dev->mc.count);	/* DM9132 */
 	else
-		send_filter_frame(dev, dev->mc_count);	/* DM9102/DM9102A */
+		send_filter_frame(dev, dev->mc.count);	/* DM9102/DM9102A */
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
@@ -1046,19 +1046,19 @@ static void dmfe_set_filter_mode(struct 
 		return;
 	}
 
-	if (dev->flags & IFF_ALLMULTI || dev->mc_count > DMFE_MAX_MULTICAST) {
-		DMFE_DBUG(0, "Pass all multicast address", dev->mc_count);
+	if (dev->flags & IFF_ALLMULTI || dev->mc.count > DMFE_MAX_MULTICAST) {
+		DMFE_DBUG(0, "Pass all multicast address", dev->mc.count);
 		db->cr6_data &= ~(CR6_PM | CR6_PBF);
 		db->cr6_data |= CR6_PAM;
 		spin_unlock_irqrestore(&db->lock, flags);
 		return;
 	}
 
-	DMFE_DBUG(0, "Set multicast address", dev->mc_count);
+	DMFE_DBUG(0, "Set multicast address", dev->mc.count);
 	if (db->chip_id == PCI_DM9132_ID)
-		dm9132_id_table(dev, dev->mc_count);	/* DM9132 */
+		dm9132_id_table(dev, dev->mc.count);	/* DM9132 */
 	else
-		send_filter_frame(dev, dev->mc_count); 	/* DM9102/DM9102A */
+		send_filter_frame(dev, dev->mc.count); 	/* DM9102/DM9102A */
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
@@ -1461,7 +1461,7 @@ static void dm9132_id_table(struct DEVIC
 	hash_table[3] = 0x8000;
 
 	/* the multicast address in Hash Table : 64 bits */
-	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+	for (mcptr = dev->mc.list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
 		hash_val = cal_CRC( (char *) mcptr->dmi_addr, 6, 0) & 0x3f;
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
@@ -1503,7 +1503,7 @@ static void send_filter_frame(struct DEV
 	*suptr++ = 0xffff;
 
 	/* fit the multicast address */
-	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+	for (mcptr = dev->mc.list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
 		addrptr = (u16 *) mcptr->dmi_addr;
 		*suptr++ = addrptr[0];
 		*suptr++ = addrptr[1];
--- wireless-testing.orig/drivers/net/tulip/tulip_core.c	2009-04-02 03:29:39.000000000 +0200
+++ wireless-testing/drivers/net/tulip/tulip_core.c	2009-06-13 12:29:46.000000000 +0200
@@ -980,7 +980,7 @@ static void build_setup_frame_hash(u16 *
 	memset(hash_table, 0, sizeof(hash_table));
 	set_bit_le(255, hash_table); 			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
-	for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+	for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 	     i++, mclist = mclist->next) {
 		int index = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x1ff;
 
@@ -1009,7 +1009,7 @@ static void build_setup_frame_perfect(u1
 
 	/* We have <= 14 addresses so we can use the wonderful
 	   16 address perfect filtering of the Tulip. */
-	for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+	for (i = 0, mclist = dev->mc.list; i < dev->mc.count;
 	     i++, mclist = mclist->next) {
 		eaddrs = (u16 *)mclist->dmi_addr;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
@@ -1040,7 +1040,7 @@ static void set_rx_mode(struct net_devic
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		tp->csr6 |= AcceptAllMulticast | AcceptAllPhys;
 		csr6 |= AcceptAllMulticast | AcceptAllPhys;
-	} else if ((dev->mc_count > 1000)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc.count > 1000)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well -- accept all multicasts. */
 		tp->csr6 |= AcceptAllMulticast;
 		csr6 |= AcceptAllMulticast;
@@ -1049,13 +1049,13 @@ static void set_rx_mode(struct net_devic
 		/* Should verify correctness on big-endian/__powerpc__ */
 		struct dev_mc_list *mclist;
 		int i;
-		if (dev->mc_count > 64) {		/* Arbitrary non-effective limit. */
+		if (dev->mc.count > 64) {		/* Arbitrary non-effective limit. */
 			tp->csr6 |= AcceptAllMulticast;
 			csr6 |= AcceptAllMulticast;
 		} else {
 			u32 mc_filter[2] = {0, 0};		 /* Multicast hash filter */
 			int filterbit;
-			for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+			for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 				 i++, mclist = mclist->next) {
 				if (tp->flags & COMET_MAC_ADDR)
 					filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr);
@@ -1090,7 +1090,7 @@ static void set_rx_mode(struct net_devic
 
 		/* Note that only the low-address shortword of setup_frame is valid!
 		   The values are doubled for big-endian architectures. */
-		if (dev->mc_count > 14) { /* Must use a multicast hash table. */
+		if (dev->mc.count > 14) { /* Must use a multicast hash table. */
 			build_setup_frame_hash(tp->setup_frame, dev);
 			tx_flags = 0x08400000 | 192;
 		} else {
--- wireless-testing.orig/drivers/net/tulip/uli526x.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tulip/uli526x.c	2009-06-13 12:29:46.000000000 +0200
@@ -547,7 +547,7 @@ static void uli526x_init(struct net_devi
 	update_cr6(db->cr6_data, ioaddr);
 
 	/* Send setup frame */
-	send_filter_frame(dev, dev->mc_count);	/* M5261/M5263 */
+	send_filter_frame(dev, dev->mc.count);	/* M5261/M5263 */
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
@@ -895,16 +895,16 @@ static void uli526x_set_filter_mode(stru
 		return;
 	}
 
-	if (dev->flags & IFF_ALLMULTI || dev->mc_count > ULI5261_MAX_MULTICAST) {
-		ULI526X_DBUG(0, "Pass all multicast address", dev->mc_count);
+	if (dev->flags & IFF_ALLMULTI || dev->mc.count > ULI5261_MAX_MULTICAST) {
+		ULI526X_DBUG(0, "Pass all multicast address", dev->mc.count);
 		db->cr6_data &= ~(CR6_PM | CR6_PBF);
 		db->cr6_data |= CR6_PAM;
 		spin_unlock_irqrestore(&db->lock, flags);
 		return;
 	}
 
-	ULI526X_DBUG(0, "Set multicast address", dev->mc_count);
-	send_filter_frame(dev, dev->mc_count); 	/* M5261/M5263 */
+	ULI526X_DBUG(0, "Set multicast address", dev->mc.count);
+	send_filter_frame(dev, dev->mc.count); 	/* M5261/M5263 */
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
@@ -1403,7 +1403,7 @@ static void send_filter_frame(struct net
 	*suptr++ = 0xffff << FLT_SHIFT;
 
 	/* fit the multicast address */
-	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+	for (mcptr = dev->mc.list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
 		addrptr = (u16 *) mcptr->dmi_addr;
 		*suptr++ = addrptr[0] << FLT_SHIFT;
 		*suptr++ = addrptr[1] << FLT_SHIFT;
--- wireless-testing.orig/drivers/net/tulip/winbond-840.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/tulip/winbond-840.c	2009-06-13 12:29:46.000000000 +0200
@@ -1357,7 +1357,7 @@ static u32 __set_rx_mode(struct net_devi
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = RxAcceptBroadcast | AcceptMulticast | RxAcceptAllPhys
 			| AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 			   ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
@@ -1366,7 +1366,7 @@ static u32 __set_rx_mode(struct net_devi
 		struct dev_mc_list *mclist;
 		int i;
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 			 i++, mclist = mclist->next) {
 			int filterbit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
 			filterbit &= 0x3f;
--- wireless-testing.orig/drivers/net/typhoon.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/typhoon.c	2009-06-13 12:29:46.000000000 +0200
@@ -923,16 +923,16 @@ typhoon_set_rx_mode(struct net_device *d
 	filter = TYPHOON_RX_FILTER_DIRECTED | TYPHOON_RX_FILTER_BROADCAST;
 	if(dev->flags & IFF_PROMISC) {
 		filter |= TYPHOON_RX_FILTER_PROMISCOUS;
-	} else if((dev->mc_count > multicast_filter_limit) ||
+	} else if((dev->mc.count > multicast_filter_limit) ||
 		  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		filter |= TYPHOON_RX_FILTER_ALL_MCAST;
-	} else if(dev->mc_count) {
+	} else if(dev->mc.count) {
 		struct dev_mc_list *mclist;
 		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for(i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for(i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		    i++, mclist = mclist->next) {
 			int bit = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3f;
 			mc_filter[bit >> 5] |= 1 << (bit & 0x1f);
--- wireless-testing.orig/drivers/net/ucc_geth.c	2009-04-30 23:07:18.000000000 +0200
+++ wireless-testing/drivers/net/ucc_geth.c	2009-06-13 12:29:46.000000000 +0200
@@ -1969,9 +1969,9 @@ static void ucc_geth_set_multi(struct ne
 			out_be32(&p_82xx_addr_filt->gaddr_h, 0x0);
 			out_be32(&p_82xx_addr_filt->gaddr_l, 0x0);
 
-			dmi = dev->mc_list;
+			dmi = dev->mc.list;
 
-			for (i = 0; i < dev->mc_count; i++, dmi = dmi->next) {
+			for (i = 0; i < dev->mc.count; i++, dmi = dmi->next) {
 
 				/* Only support group multicast for now.
 				 */
--- wireless-testing.orig/drivers/net/usb/asix.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/usb/asix.c	2009-06-13 12:29:46.000000000 +0200
@@ -542,23 +542,23 @@ static void asix_set_multicast(struct ne
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= AX_RX_CTL_PRO;
 	} else if (net->flags & IFF_ALLMULTI
-		   || net->mc_count > AX_MAX_MCAST) {
+		   || net->mc.count > AX_MAX_MCAST) {
 		rx_ctl |= AX_RX_CTL_AMALL;
-	} else if (net->mc_count == 0) {
+	} else if (net->mc.count == 0) {
 		/* just broadcast and directed */
 	} else {
 		/* We use the 20 byte dev->data
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list = net->mc_list;
+		struct dev_mc_list *mc_list = net->mc.list;
 		u32 crc_bits;
 		int i;
 
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < net->mc.count; i++) {
 			crc_bits =
 			    ether_crc(ETH_ALEN,
 				      mc_list->dmi_addr) >> 26;
@@ -754,23 +754,23 @@ static void ax88172_set_multicast(struct
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= 0x01;
 	} else if (net->flags & IFF_ALLMULTI
-		   || net->mc_count > AX_MAX_MCAST) {
+		   || net->mc.count > AX_MAX_MCAST) {
 		rx_ctl |= 0x02;
-	} else if (net->mc_count == 0) {
+	} else if (net->mc.count == 0) {
 		/* just broadcast and directed */
 	} else {
 		/* We use the 20 byte dev->data
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list = net->mc_list;
+		struct dev_mc_list *mc_list = net->mc.list;
 		u32 crc_bits;
 		int i;
 
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < net->mc.count; i++) {
 			crc_bits =
 			    ether_crc(ETH_ALEN,
 				      mc_list->dmi_addr) >> 26;
--- wireless-testing.orig/drivers/net/usb/catc.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/usb/catc.c	2009-06-13 12:29:46.000000000 +0200
@@ -647,7 +647,7 @@ static void catc_set_multicast_list(stru
 	if (netdev->flags & IFF_ALLMULTI) {
 		memset(catc->multicast, 0xff, 64);
 	} else {
-		for (i = 0, mc = netdev->mc_list; mc && i < netdev->mc_count; i++, mc = mc->next) {
+		for (i = 0, mc = netdev->mc.list; mc && i < netdev->mc.count; i++, mc = mc->next) {
 			u32 crc = ether_crc_le(6, mc->dmi_addr);
 			if (!catc->is_f5u011) {
 				catc->multicast[(crc >> 3) & 0x3f] |= 1 << (crc & 7);
--- wireless-testing.orig/drivers/net/usb/dm9601.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/usb/dm9601.c	2009-06-13 12:29:46.000000000 +0200
@@ -381,13 +381,13 @@ static void dm9601_set_multicast(struct 
 
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= 0x02;
-	} else if (net->flags & IFF_ALLMULTI || net->mc_count > DM_MAX_MCAST) {
+	} else if (net->flags & IFF_ALLMULTI || net->mc.count > DM_MAX_MCAST) {
 		rx_ctl |= 0x04;
-	} else if (net->mc_count) {
-		struct dev_mc_list *mc_list = net->mc_list;
+	} else if (net->mc.count) {
+		struct dev_mc_list *mc_list = net->mc.list;
 		int i;
 
-		for (i = 0; i < net->mc_count; i++, mc_list = mc_list->next) {
+		for (i = 0; i < net->mc.count; i++, mc_list = mc_list->next) {
 			u32 crc = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			hashes[crc >> 3] |= 1 << (crc & 0x7);
 		}
--- wireless-testing.orig/drivers/net/usb/kaweth.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/usb/kaweth.c	2009-06-13 12:29:46.000000000 +0200
@@ -870,7 +870,7 @@ static void kaweth_set_rx_mode(struct ne
 	if (net->flags & IFF_PROMISC) {
 		packet_filter_bitmap |= KAWETH_PACKET_FILTER_PROMISCUOUS;
 	}
-	else if ((net->mc_count) || (net->flags & IFF_ALLMULTI)) {
+	else if ((net->mc.count) || (net->flags & IFF_ALLMULTI)) {
 		packet_filter_bitmap |= KAWETH_PACKET_FILTER_ALL_MULTICAST;
 	}
 
--- wireless-testing.orig/drivers/net/usb/mcs7830.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/usb/mcs7830.c	2009-06-13 12:29:46.000000000 +0200
@@ -392,23 +392,23 @@ static void mcs7830_set_multicast(struct
 	if (net->flags & IFF_PROMISC) {
 		data->config |= HIF_REG_CONFIG_PROMISCIOUS;
 	} else if (net->flags & IFF_ALLMULTI
-		   || net->mc_count > MCS7830_MAX_MCAST) {
+		   || net->mc.count > MCS7830_MAX_MCAST) {
 		data->config |= HIF_REG_CONFIG_ALLMULTICAST;
-	} else if (net->mc_count == 0) {
+	} else if (net->mc.count == 0) {
 		/* just broadcast and directed */
 	} else {
 		/* We use the 20 byte dev->data
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list = net->mc_list;
+		struct dev_mc_list *mc_list = net->mc.list;
 		u32 crc_bits;
 		int i;
 
 		memset(data->multi_filter, 0, sizeof data->multi_filter);
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < net->mc.count; i++) {
 			crc_bits = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |= 1 << (crc_bits & 7);
 			mc_list = mc_list->next;
--- wireless-testing.orig/drivers/net/usb/pegasus.c	2009-04-30 23:07:18.000000000 +0200
+++ wireless-testing/drivers/net/usb/pegasus.c	2009-06-13 12:29:46.000000000 +0200
@@ -1214,7 +1214,7 @@ static void pegasus_set_multicast(struct
 		pegasus->eth_regs[EthCtrl2] |= RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
 			pr_info("%s: Promiscuous mode enabled.\n", net->name);
-	} else if (net->mc_count || (net->flags & IFF_ALLMULTI)) {
+	} else if (net->mc.count || (net->flags & IFF_ALLMULTI)) {
 		pegasus->eth_regs[EthCtrl0] |= RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
--- wireless-testing.orig/drivers/net/usb/rtl8150.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/usb/rtl8150.c	2009-06-13 12:29:46.000000000 +0200
@@ -711,7 +711,7 @@ static void rtl8150_set_multicast(struct
 	if (netdev->flags & IFF_PROMISC) {
 		dev->rx_creg |= cpu_to_le16(0x0001);
 		dev_info(&netdev->dev, "%s: promiscuous mode\n", netdev->name);
-	} else if (netdev->mc_count ||
+	} else if (netdev->mc.count ||
 		   (netdev->flags & IFF_ALLMULTI)) {
 		dev->rx_creg &= cpu_to_le16(0xfffe);
 		dev->rx_creg |= cpu_to_le16(0x0002);
--- wireless-testing.orig/drivers/net/usb/smsc95xx.c	2009-05-11 21:32:40.000000000 +0200
+++ wireless-testing/drivers/net/usb/smsc95xx.c	2009-06-13 12:29:46.000000000 +0200
@@ -389,8 +389,8 @@ static void smsc95xx_set_multicast(struc
 			devdbg(dev, "receive all multicast enabled");
 		pdata->mac_cr |= MAC_CR_MCPAS_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
-	} else if (dev->net->mc_count > 0) {
-		struct dev_mc_list *mc_list = dev->net->mc_list;
+	} else if (dev->net->mc.count > 0) {
+		struct dev_mc_list *mc_list = dev->net->mc.list;
 		int count = 0;
 
 		pdata->mac_cr |= MAC_CR_HPFILT_;
@@ -411,8 +411,8 @@ static void smsc95xx_set_multicast(struc
 			mc_list = mc_list->next;
 		}
 
-		if (count != ((u32)dev->net->mc_count))
-			devwarn(dev, "mc_count != dev->mc_count");
+		if (count != ((u32)dev->net->mc.count))
+			devwarn(dev, "mc_count != dev->mc.count");
 
 		if (netif_msg_drv(dev))
 			devdbg(dev, "HASHH=0x%08X, HASHL=0x%08X", hash_hi,
--- wireless-testing.orig/drivers/net/via-rhine.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/via-rhine.c	2009-06-13 12:29:46.000000000 +0200
@@ -1673,7 +1673,7 @@ static void rhine_set_rx_mode(struct net
 		rx_mode = 0x1C;
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((dev->mc.count > multicast_filter_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
@@ -1683,7 +1683,7 @@ static void rhine_set_rx_mode(struct net
 		struct dev_mc_list *mclist;
 		int i;
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
--- wireless-testing.orig/drivers/net/via-velocity.c	2009-04-23 00:20:43.000000000 +0200
+++ wireless-testing/drivers/net/via-velocity.c	2009-06-13 12:29:46.000000000 +0200
@@ -2283,7 +2283,7 @@ static void velocity_set_multi(struct ne
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
 		rx_mode = (RCR_AM | RCR_AB | RCR_PROM);
-	} else if ((dev->mc_count > vptr->multicast_limit)
+	} else if ((dev->mc.count > vptr->multicast_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
@@ -2292,7 +2292,7 @@ static void velocity_set_multi(struct ne
 		int offset = MCAM_SIZE - vptr->multicast_limit;
 		mac_get_cam_mask(regs, vptr->mCAMmask);
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count; i++, mclist = mclist->next) {
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count; i++, mclist = mclist->next) {
 			mac_set_cam(regs, i + offset, mclist->dmi_addr);
 			vptr->mCAMmask[(offset + i) / 8] |= 1 << ((offset + i) & 7);
 		}
--- wireless-testing.orig/drivers/net/virtio_net.c	2009-05-11 21:32:40.000000000 +0200
+++ wireless-testing/drivers/net/virtio_net.c	2009-06-13 12:29:46.000000000 +0200
@@ -711,7 +711,7 @@ static void virtnet_set_rx_mode(struct n
 			 allmulti ? "en" : "dis");
 
 	/* MAC filter - use one buffer for both lists */
-	mac_data = buf = kzalloc(((dev->uc_count + dev->mc_count) * ETH_ALEN) +
+	mac_data = buf = kzalloc(((dev->uc.count + dev->mc.count) * ETH_ALEN) +
 				 (2 * sizeof(mac_data->entries)), GFP_ATOMIC);
 	if (!buf) {
 		dev_warn(&dev->dev, "No memory for MAC address buffer\n");
@@ -721,24 +721,24 @@ static void virtnet_set_rx_mode(struct n
 	sg_init_table(sg, 2);
 
 	/* Store the unicast list and count in the front of the buffer */
-	mac_data->entries = dev->uc_count;
-	addr = dev->uc_list;
-	for (i = 0; i < dev->uc_count; i++, addr = addr->next)
+	mac_data->entries = dev->uc.count;
+	addr = dev->uc.list;
+	for (i = 0; i < dev->uc.count; i++, addr = addr->next)
 		memcpy(&mac_data->macs[i][0], addr->da_addr, ETH_ALEN);
 
 	sg_set_buf(&sg[0], mac_data,
-		   sizeof(mac_data->entries) + (dev->uc_count * ETH_ALEN));
+		   sizeof(mac_data->entries) + (dev->uc.count * ETH_ALEN));
 
 	/* multicast list and count fill the end */
-	mac_data = (void *)&mac_data->macs[dev->uc_count][0];
+	mac_data = (void *)&mac_data->macs[dev->uc.count][0];
 
-	mac_data->entries = dev->mc_count;
-	addr = dev->mc_list;
-	for (i = 0; i < dev->mc_count; i++, addr = addr->next)
+	mac_data->entries = dev->mc.count;
+	addr = dev->mc.list;
+	for (i = 0; i < dev->mc.count; i++, addr = addr->next)
 		memcpy(&mac_data->macs[i][0], addr->da_addr, ETH_ALEN);
 
 	sg_set_buf(&sg[1], mac_data,
-		   sizeof(mac_data->entries) + (dev->mc_count * ETH_ALEN));
+		   sizeof(mac_data->entries) + (dev->mc.count * ETH_ALEN));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
 				  VIRTIO_NET_CTRL_MAC_TABLE_SET,
--- wireless-testing.orig/drivers/net/vxge/vxge-main.c	2009-04-09 10:00:18.000000000 +0200
+++ wireless-testing/drivers/net/vxge/vxge-main.c	2009-06-13 12:29:47.000000000 +0200
@@ -1167,11 +1167,11 @@ static void vxge_set_multicast(struct ne
 
 	memset(&mac_info, 0, sizeof(struct macInfo));
 	/* Update individual M_CAST address list */
-	if ((!vdev->all_multi_flg) && dev->mc_count) {
+	if ((!vdev->all_multi_flg) && dev->mc.count) {
 
 		mcast_cnt = vdev->vpaths[0].mcast_addr_cnt;
 		list_head = &vdev->vpaths[0].mac_addr_list;
-		if ((dev->mc_count +
+		if ((dev->mc.count +
 			(vdev->vpaths[0].mac_addr_cnt - mcast_cnt)) >
 				vdev->vpaths[0].max_mac_addr_cnt)
 			goto _set_all_mcast;
@@ -1206,7 +1206,7 @@ static void vxge_set_multicast(struct ne
 		}
 
 		/* Add new ones */
-		for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; i < dev->mc.count;
 			i++, mclist = mclist->next) {
 
 			memcpy(mac_info.macaddr, mclist->dmi_addr, ETH_ALEN);
--- wireless-testing.orig/drivers/net/wireless/airo.c	2009-05-30 01:38:26.000000000 +0200
+++ wireless-testing/drivers/net/wireless/airo.c	2009-06-13 12:29:47.000000000 +0200
@@ -2303,7 +2303,7 @@ static void airo_set_multicast_list(stru
 			airo_set_promisc(ai);
 	}
 
-	if ((dev->flags&IFF_ALLMULTI)||dev->mc_count>0) {
+	if ((dev->flags&IFF_ALLMULTI)||dev->mc.count>0) {
 		/* Turn on multicast.  (Should be already setup...) */
 	}
 }
--- wireless-testing.orig/drivers/net/wireless/arlan-main.c	2009-04-09 10:00:22.000000000 +0200
+++ wireless-testing/drivers/net/wireless/arlan-main.c	2009-06-13 12:29:47.000000000 +0200
@@ -1455,10 +1455,10 @@ static void arlan_rx_interrupt(struct ne
 #ifdef ARLAN_MULTICAST
 			if (!(dev->flags & IFF_ALLMULTI) &&
 				!(dev->flags & IFF_PROMISC) &&
-				dev->mc_list)
+				dev->mc.list)
 			{
 				char hw_dst_addr[6];
-				struct dev_mc_list *dmi = dev->mc_list;
+				struct dev_mc_list *dmi = dev->mc.list;
 				int i;
 
 				memcpy_fromio(hw_dst_addr, arlan->ultimateDestAddress, 6);
--- wireless-testing.orig/drivers/net/wireless/libertas/main.c	2009-06-03 08:41:49.000000000 +0200
+++ wireless-testing/drivers/net/wireless/libertas/main.c	2009-06-13 12:29:47.000000000 +0200
@@ -638,7 +638,7 @@ static int lbs_add_mcast_addrs(struct cm
 		return nr_addrs;
 
 	netif_addr_lock_bh(dev);
-	for (mc_list = dev->mc_list; mc_list; mc_list = mc_list->next) {
+	for (mc_list = dev->mc.list; mc_list; mc_list = mc_list->next) {
 		if (mac_in_list(cmd->maclist, nr_addrs, mc_list->dmi_addr)) {
 			lbs_deb_net("mcast address %s:%pM skipped\n", dev->name,
 				    mc_list->dmi_addr);
--- wireless-testing.orig/drivers/net/wireless/netwave_cs.c	2009-04-09 10:00:22.000000000 +0200
+++ wireless-testing/drivers/net/wireless/netwave_cs.c	2009-06-13 12:29:47.000000000 +0200
@@ -1358,15 +1358,15 @@ static void set_multicast_list(struct ne
 #ifdef PCMCIA_DEBUG
     if (pc_debug > 2) {
 	static int old;
-	if (old != dev->mc_count) {
-	    old = dev->mc_count;
+	if (old != dev->mc.count) {
+	    old = dev->mc.count;
 	    DEBUG(0, "%s: setting Rx mode to %d addresses.\n",
-		  dev->name, dev->mc_count);
+		  dev->name, dev->mc.count);
 	}
     }
 #endif
 	
-    if (dev->mc_count || (dev->flags & IFF_ALLMULTI)) {
+    if (dev->mc.count || (dev->flags & IFF_ALLMULTI)) {
 	/* Multicast Mode */
 	rcvMode = rxConfRxEna + rxConfAMP + rxConfBcast;
     } else if (dev->flags & IFF_PROMISC) {
--- wireless-testing.orig/drivers/net/wireless/orinoco/main.c	2009-04-02 03:29:39.000000000 +0200
+++ wireless-testing/drivers/net/wireless/orinoco/main.c	2009-06-13 12:29:47.000000000 +0200
@@ -1854,15 +1854,15 @@ __orinoco_set_multicast_list(struct net_
 	/* The Hermes doesn't seem to have an allmulti mode, so we go
 	 * into promiscuous mode and let the upper levels deal. */
 	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI) ||
-	    (dev->mc_count > MAX_MULTICAST(priv))) {
+	    (dev->mc.count > MAX_MULTICAST(priv))) {
 		promisc = 1;
 		mc_count = 0;
 	} else {
 		promisc = 0;
-		mc_count = dev->mc_count;
+		mc_count = dev->mc.count;
 	}
 
-	err = __orinoco_hw_set_multicast_list(priv, dev->mc_list, mc_count,
+	err = __orinoco_hw_set_multicast_list(priv, dev->mc.list, mc_count,
 					      promisc);
 }
 
--- wireless-testing.orig/drivers/net/wireless/ray_cs.c	2009-04-09 10:00:22.000000000 +0200
+++ wireless-testing/drivers/net/wireless/ray_cs.c	2009-06-13 12:29:47.000000000 +0200
@@ -1906,7 +1906,7 @@ static void ray_update_multi_list(struct
 		local->num_multi = 0xff;
 	} else {
 		/* Copy the kernel's list of MC addresses to card */
-		for (dmip = &dev->mc_list; (dmi = *dmip) != NULL;
+		for (dmip = &dev->mc.list; (dmi = *dmip) != NULL;
 		     dmip = &dmi->next) {
 			memcpy_toio(p, dmi->dmi_addr, ETH_ALEN);
 			DEBUG(1,
@@ -1960,7 +1960,7 @@ static void set_multicast_list(struct ne
 	if (dev->flags & IFF_ALLMULTI)
 		ray_update_multi_list(dev, 1);
 	else {
-		if (local->num_multi != dev->mc_count)
+		if (local->num_multi != dev->mc.count)
 			ray_update_multi_list(dev, 0);
 	}
 } /* end set_multicast_list */
--- wireless-testing.orig/drivers/net/wireless/rndis_wlan.c	2009-06-07 21:32:33.000000000 +0200
+++ wireless-testing/drivers/net/wireless/rndis_wlan.c	2009-06-13 12:29:47.000000000 +0200
@@ -1173,10 +1173,10 @@ static void set_multicast_list(struct us
 		filter |= RNDIS_PACKET_TYPE_PROMISCUOUS |
 			RNDIS_PACKET_TYPE_ALL_LOCAL;
 	} else if (usbdev->net->flags & IFF_ALLMULTI ||
-		   usbdev->net->mc_count > priv->multicast_size) {
+		   usbdev->net->mc.count > priv->multicast_size) {
 		filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
-	} else if (usbdev->net->mc_count > 0) {
-		size = min(priv->multicast_size, usbdev->net->mc_count);
+	} else if (usbdev->net->mc.count > 0) {
+		size = min(priv->multicast_size, usbdev->net->mc.count);
 		buf = kmalloc(size * ETH_ALEN, GFP_KERNEL);
 		if (!buf) {
 			devwarn(usbdev,
@@ -1185,7 +1185,7 @@ static void set_multicast_list(struct us
 			return;
 		}
 
-		mclist = usbdev->net->mc_list;
+		mclist = usbdev->net->mc.list;
 		for (i = 0; i < size && mclist; mclist = mclist->next) {
 			if (mclist->dmi_addrlen != ETH_ALEN)
 				continue;
--- wireless-testing.orig/drivers/net/wireless/wavelan.c	2009-04-09 10:00:22.000000000 +0200
+++ wireless-testing/drivers/net/wireless/wavelan.c	2009-06-13 12:29:47.000000000 +0200
@@ -1367,7 +1367,7 @@ static void wavelan_set_multicast_list(s
 #ifdef DEBUG_IOCTL_INFO
 	printk(KERN_DEBUG
 	       "%s: wavelan_set_multicast_list(): setting Rx mode %02X to %d addresses.\n",
-	       dev->name, dev->flags, dev->mc_count);
+	       dev->name, dev->flags, dev->mc.count);
 #endif
 
 	/* Are we asking for promiscuous mode,
@@ -1375,7 +1375,7 @@ static void wavelan_set_multicast_list(s
 	 * or too many multicast addresses for the hardware filter? */
 	if ((dev->flags & IFF_PROMISC) ||
 	    (dev->flags & IFF_ALLMULTI) ||
-	    (dev->mc_count > I82586_MAX_MULTICAST_ADDRESSES)) {
+	    (dev->mc.count > I82586_MAX_MULTICAST_ADDRESSES)) {
 		/*
 		 * Enable promiscuous mode: receive all packets.
 		 */
@@ -1387,17 +1387,17 @@ static void wavelan_set_multicast_list(s
 		}
 	} else
 		/* Are there multicast addresses to send? */
-	if (dev->mc_list != (struct dev_mc_list *) NULL) {
+	if (dev->mc.list != (struct dev_mc_list *) NULL) {
 		/*
 		 * Disable promiscuous mode, but receive all packets
 		 * in multicast list
 		 */
 #ifdef MULTICAST_AVOID
-		if (lp->promiscuous || (dev->mc_count != lp->mc_count))
+		if (lp->promiscuous || (dev->mc.count != lp->mc_count))
 #endif
 		{
 			lp->promiscuous = 0;
-			lp->mc_count = dev->mc_count;
+			lp->mc_count = dev->mc.count;
 
 			wv_82586_reconfig(dev);
 		}
@@ -3534,7 +3534,7 @@ static void wv_82586_config(struct net_d
 
 	/* Any address to set? */
 	if (lp->mc_count) {
-		for (dmi = dev->mc_list; dmi; dmi = dmi->next)
+		for (dmi = dev->mc.list; dmi; dmi = dmi->next)
 			outsw(PIOP1(ioaddr), (u16 *) dmi->dmi_addr,
 			      WAVELAN_ADDR_SIZE >> 1);
 
@@ -3542,7 +3542,7 @@ static void wv_82586_config(struct net_d
 		printk(KERN_DEBUG
 		       "%s: wv_82586_config(): set %d multicast addresses:\n",
 		       dev->name, lp->mc_count);
-		for (dmi = dev->mc_list; dmi; dmi = dmi->next)
+		for (dmi = dev->mc.list; dmi; dmi = dmi->next)
 			printk(KERN_DEBUG " %pM\n", dmi->dmi_addr);
 #endif
 	}
--- wireless-testing.orig/drivers/net/wireless/wavelan_cs.c	2009-04-09 10:00:22.000000000 +0200
+++ wireless-testing/drivers/net/wireless/wavelan_cs.c	2009-06-13 12:29:48.000000000 +0200
@@ -1373,7 +1373,7 @@ wavelan_set_multicast_list(struct net_de
 
 #ifdef DEBUG_IOCTL_INFO
   printk(KERN_DEBUG "%s: wavelan_set_multicast_list(): setting Rx mode %02X to %d addresses.\n",
-	 dev->name, dev->flags, dev->mc_count);
+	 dev->name, dev->flags, dev->mc.count);
 #endif
 
   if(dev->flags & IFF_PROMISC)
@@ -1394,7 +1394,7 @@ wavelan_set_multicast_list(struct net_de
     /* If all multicast addresses
      * or too much multicast addresses for the hardware filter */
     if((dev->flags & IFF_ALLMULTI) ||
-       (dev->mc_count > I82593_MAX_MULTICAST_ADDRESSES))
+       (dev->mc.count > I82593_MAX_MULTICAST_ADDRESSES))
       {
 	/*
 	 * Disable promiscuous mode, but active the all multicast mode
@@ -1410,7 +1410,7 @@ wavelan_set_multicast_list(struct net_de
       }
     else
       /* If there is some multicast addresses to send */
-      if(dev->mc_list != (struct dev_mc_list *) NULL)
+      if(dev->mc.list != (struct dev_mc_list *) NULL)
 	{
 	  /*
 	   * Disable promiscuous mode, but receive all packets
@@ -1418,12 +1418,12 @@ wavelan_set_multicast_list(struct net_de
 	   */
 #ifdef MULTICAST_AVOID
 	  if(lp->promiscuous || lp->allmulticast ||
-	     (dev->mc_count != lp->mc_count))
+	     (dev->mc.count != lp->mc_count))
 #endif
 	    {
 	      lp->promiscuous = 0;
 	      lp->allmulticast = 0;
-	      lp->mc_count = dev->mc_count;
+	      lp->mc_count = dev->mc.count;
 
 	      wv_82593_reconfig(dev);
 	    }
@@ -3618,7 +3618,7 @@ wv_82593_config(struct net_device *	dev)
 #ifdef DEBUG_CONFIG_INFO
       printk(KERN_DEBUG "%s: wv_hw_config(): set %d multicast addresses:\n",
 	     dev->name, lp->mc_count);
-      for(dmi=dev->mc_list; dmi; dmi=dmi->next)
+      for(dmi=dev->mc.list; dmi; dmi=dmi->next)
 	printk(KERN_DEBUG " %pM\n", dmi->dmi_addr);
 #endif
 
@@ -3627,7 +3627,7 @@ wv_82593_config(struct net_device *	dev)
       outb(((TX_BASE >> 8) & PIORH_MASK) | PIORH_SEL_TX, PIORH(base));
       outb(addrs_len & 0xff, PIOP(base));	/* byte count lsb */
       outb((addrs_len >> 8), PIOP(base));	/* byte count msb */
-      for(dmi=dev->mc_list; dmi; dmi=dmi->next)
+      for(dmi=dev->mc.list; dmi; dmi=dmi->next)
 	outsb(PIOP(base), dmi->dmi_addr, dmi->dmi_addrlen);
 
       /* reset transmit DMA pointer */
@@ -3636,7 +3636,7 @@ wv_82593_config(struct net_device *	dev)
       if(!wv_82593_cmd(dev, "wv_82593_config(): mc-setup",
 		       OP0_MC_SETUP, SR0_MC_SETUP_DONE))
 	ret = FALSE;
-      lp->mc_count = dev->mc_count;	/* remember to avoid repeated reset */
+      lp->mc_count = dev->mc.count;	/* remember to avoid repeated reset */
     }
 
   /* Job done, clear the flag */
--- wireless-testing.orig/drivers/net/wireless/zd1201.c	2009-04-09 10:00:22.000000000 +0200
+++ wireless-testing/drivers/net/wireless/zd1201.c	2009-06-13 12:29:48.000000000 +0200
@@ -871,19 +871,19 @@ static struct iw_statistics *zd1201_get_
 static void zd1201_set_multicast(struct net_device *dev)
 {
 	struct zd1201 *zd = netdev_priv(dev);
-	struct dev_mc_list *mc = dev->mc_list;
+	struct dev_mc_list *mc = dev->mc.list;
 	unsigned char reqbuf[ETH_ALEN*ZD1201_MAXMULTI];
 	int i;
 
-	if (dev->mc_count > ZD1201_MAXMULTI)
+	if (dev->mc.count > ZD1201_MAXMULTI)
 		return;
 
-	for (i=0; i<dev->mc_count; i++) {
+	for (i=0; i<dev->mc.count; i++) {
 		memcpy(reqbuf+i*ETH_ALEN, mc->dmi_addr, ETH_ALEN);
 		mc = mc->next;
 	}
 	zd1201_setconfig(zd, ZD1201_RID_CNFGROUPADDRESS, reqbuf,
-	    dev->mc_count*ETH_ALEN, 0);
+	    dev->mc.count*ETH_ALEN, 0);
 	
 }
 
--- wireless-testing.orig/drivers/net/yellowfin.c	2009-04-09 10:00:23.000000000 +0200
+++ wireless-testing/drivers/net/yellowfin.c	2009-06-13 12:29:48.000000000 +0200
@@ -1289,15 +1289,15 @@ static void set_rx_mode(struct net_devic
 	iowrite16(cfg_value & ~0x1000, ioaddr + Cnfg);
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		iowrite16(0x000F, ioaddr + AddrMode);
-	} else if ((dev->mc_count > 64)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc.count > 64)  ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well, or accept all multicasts. */
 		iowrite16(0x000B, ioaddr + AddrMode);
-	} else if (dev->mc_count > 0) { /* Must use the multicast hash table. */
+	} else if (dev->mc.count > 0) { /* Must use the multicast hash table. */
 		struct dev_mc_list *mclist;
 		u16 hash_table[4];
 		int i;
 		memset(hash_table, 0, sizeof(hash_table));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc.list; mclist && i < dev->mc.count;
 			 i++, mclist = mclist->next) {
 			unsigned int bit;
 
--- wireless-testing.orig/drivers/net/znet.c	2009-04-09 10:00:23.000000000 +0200
+++ wireless-testing/drivers/net/znet.c	2009-06-13 12:29:48.000000000 +0200
@@ -321,7 +321,7 @@ static void znet_set_multicast_list (str
 	/* Byte D */
 	cfblk->dummy_1 = 1; 	/* set to 1 */
 	cfblk->tx_ifs_retrig = 3; /* Hmm... Disabled */
-	cfblk->mc_all = (dev->mc_list || (dev->flags&IFF_ALLMULTI));/* multicast all mode */
+	cfblk->mc_all = (dev->mc.list || (dev->flags&IFF_ALLMULTI));/* multicast all mode */
 	cfblk->rcv_mon = 0;	/* Monitor mode disabled */
 	cfblk->frag_acpt = 0;	/* Do not accept fragments */
 	cfblk->tstrttrs = 0;	/* No start transmission threshold */
--- wireless-testing.orig/drivers/s390/net/qeth_l2_main.c	2009-04-09 10:00:23.000000000 +0200
+++ wireless-testing/drivers/s390/net/qeth_l2_main.c	2009-06-13 12:29:48.000000000 +0200
@@ -626,10 +626,10 @@ static void qeth_l2_set_multicast_list(s
 		return;
 	qeth_l2_del_all_mc(card);
 	spin_lock_bh(&card->mclock);
-	for (dm = dev->mc_list; dm; dm = dm->next)
+	for (dm = dev->mc.list; dm; dm = dm->next)
 		qeth_l2_add_mc(card, dm->da_addr, 0);
 
-	for (dm = dev->uc_list; dm; dm = dm->next)
+	for (dm = dev->uc.list; dm; dm = dm->next)
 		qeth_l2_add_mc(card, dm->da_addr, 1);
 
 	spin_unlock_bh(&card->mclock);
--- wireless-testing.orig/drivers/staging/et131x/et131x_netdev.c	2009-04-23 00:20:58.000000000 +0200
+++ wireless-testing/drivers/staging/et131x/et131x_netdev.c	2009-06-13 12:29:48.000000000 +0200
@@ -465,7 +465,7 @@ void et131x_multicast(struct net_device 
 	uint32_t PacketFilter = 0;
 	uint32_t count;
 	unsigned long lockflags;
-	struct dev_mc_list *mclist = netdev->mc_list;
+	struct dev_mc_list *mclist = netdev->mc.list;
 
 	DBG_ENTER(et131x_dbginfo);
 
@@ -488,7 +488,7 @@ void et131x_multicast(struct net_device 
 	 * accordingly
 	 */
 	DBG_VERBOSE(et131x_dbginfo,
-		    "MULTICAST ADDR COUNT: %d\n", netdev->mc_count);
+		    "MULTICAST ADDR COUNT: %d\n", netdev->mc.count);
 
 	if (netdev->flags & IFF_PROMISC) {
 		DBG_VERBOSE(et131x_dbginfo, "Request: PROMISCUOUS MODE ON\n");
@@ -503,7 +503,7 @@ void et131x_multicast(struct net_device 
 		adapter->PacketFilter |= ET131X_PACKET_TYPE_ALL_MULTICAST;
 	}
 
-	if (netdev->mc_count > NIC_MAX_MCAST_LIST) {
+	if (netdev->mc.count > NIC_MAX_MCAST_LIST) {
 		DBG_WARNING(et131x_dbginfo,
 			    "ACCEPT ALL MULTICAST for now, as there's more Multicast "
 			    "addresses than the HW supports\n");
@@ -511,7 +511,7 @@ void et131x_multicast(struct net_device 
 		adapter->PacketFilter |= ET131X_PACKET_TYPE_ALL_MULTICAST;
 	}
 
-	if (netdev->mc_count < 1) {
+	if (netdev->mc.count < 1) {
 		DBG_VERBOSE(et131x_dbginfo, "Request: REJECT ALL MULTICAST\n");
 		adapter->PacketFilter &= ~ET131X_PACKET_TYPE_ALL_MULTICAST;
 		adapter->PacketFilter &= ~ET131X_PACKET_TYPE_MULTICAST;
@@ -522,14 +522,14 @@ void et131x_multicast(struct net_device 
 	}
 
 	/* Set values in the private adapter struct */
-	adapter->MCAddressCount = netdev->mc_count;
+	adapter->MCAddressCount = netdev->mc.count;
 
-	if (netdev->mc_count) {
+	if (netdev->mc.count) {
 		if (mclist->dmi_addrlen != ETH_ALEN) {
 			DBG_WARNING(et131x_dbginfo,
 				    "Multicast addrs are not ETH_ALEN in size\n");
 		} else {
-			count = netdev->mc_count - 1;
+			count = netdev->mc.count - 1;
 			memcpy(adapter->MCList[count], mclist->dmi_addr,
 			       ETH_ALEN);
 		}
--- wireless-testing.orig/drivers/staging/slicoss/slicoss.c	2009-04-23 00:20:59.000000000 +0200
+++ wireless-testing/drivers/staging/slicoss/slicoss.c	2009-06-13 12:29:48.000000000 +0200
@@ -1365,8 +1365,8 @@ static void slic_mcast_set_list(struct n
 	int status = STATUS_SUCCESS;
 	int i;
 	char *addresses;
-	struct dev_mc_list *mc_list = dev->mc_list;
-	int mc_count = dev->mc_count;
+	struct dev_mc_list *mc_list = dev->mc.list;
+	int mc_count = dev->mc.count;
 
 	ASSERT(adapter);
 
--- wireless-testing.orig/drivers/staging/sxg/sxg.c	2009-04-23 00:20:59.000000000 +0200
+++ wireless-testing/drivers/staging/sxg/sxg.c	2009-06-13 12:29:48.000000000 +0200
@@ -1984,7 +1984,7 @@ static bool sxg_mac_filter(struct adapte
 				return (TRUE);
 			}
 			if (adapter->MacFilter & MAC_MCAST) {
-				struct dev_mc_list *mclist = dev->mc_list;
+				struct dev_mc_list *mclist = dev->mc.list;
 				while (mclist) {
 					ETHER_EQ_ADDR(mclist->da_addr,
 						      EtherHdr->ether_dhost,
@@ -3611,7 +3611,7 @@ static void sxg_set_mcast_addr(struct ad
         int i;
 
         if (adapter->MacFilter & (MAC_ALLMCAST | MAC_MCAST)) {
-               for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+               for (i = 0, mclist = dev->mc.list; i < dev->mc.count;
                              i++, mclist = mclist->next) {
                         sxg_mcast_set_bit(adapter,mclist->da_addr);
                 }
--- wireless-testing.orig/arch/xtensa/platforms/iss/network.c	2009-01-13 15:04:57.000000000 +0100
+++ wireless-testing/arch/xtensa/platforms/iss/network.c	2009-06-13 12:29:48.000000000 +0200
@@ -560,7 +560,7 @@ static void iss_net_set_multicast_list(s
 #if 0
 	if (dev->flags & IFF_PROMISC)
 		return;
-	else if (dev->mc_count)
+	else if (dev->mc.count)
 		dev->flags |= IFF_ALLMULTI;
 	else
 		dev->flags &= ~IFF_ALLMULTI;


