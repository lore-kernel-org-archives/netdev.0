From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 03/33] net: set name_assign_type in alloc_netdev()
Date: Thu, 10 Jul 2014 10:17:08 +0200
Message-ID: <1404980258-30853-4-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extend alloc_netdev{,_mq{,s}}() to take name_assign_type as argument, and convert
all users to pass NET_NAME_UNKNOWN.

Coccinelle patch:

@@
expression sizeof_priv, name, setup, txqs, rxqs, count;
@@

(
-alloc_netdev_mqs(sizeof_priv, name, setup, txqs, rxqs)
+alloc_netdev_mqs(sizeof_priv, name, NET_NAME_UNKNOWN, setup, txqs, rxqs)
|
-alloc_netdev_mq(sizeof_priv, name, setup, count)
+alloc_netdev_mq(sizeof_priv, name, NET_NAME_UNKNOWN, setup, count)
|
-alloc_netdev(sizeof_priv, name, setup)
+alloc_netdev(sizeof_priv, name, NET_NAME_UNKNOWN, setup)
)

Signed-off-by: Tom Gundersen <teg@jklm.no>
Reviewed-by: David Herrmann <dh.herrmann@gmail.com>
---
 drivers/firewire/net.c                              |  3 ++-
 drivers/hsi/clients/ssi_protocol.c                  |  2 +-
 drivers/infiniband/hw/amso1100/c2_provider.c        |  2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c           |  4 ++--
 drivers/isdn/i4l/isdn_net.c                         |  3 ++-
 drivers/media/dvb-core/dvb_net.c                    |  3 ++-
 drivers/misc/sgi-xp/xpnet.c                         |  3 ++-
 drivers/net/arcnet/arcnet.c                         |  3 ++-
 drivers/net/bonding/bond_main.c                     |  2 +-
 drivers/net/caif/caif_serial.c                      |  3 ++-
 drivers/net/caif/caif_spi.c                         |  4 ++--
 drivers/net/caif/caif_virtio.c                      |  2 +-
 drivers/net/can/dev.c                               |  2 +-
 drivers/net/can/slcan.c                             |  2 +-
 drivers/net/dummy.c                                 |  2 +-
 drivers/net/eql.c                                   |  3 ++-
 drivers/net/ethernet/8390/lib8390.c                 |  2 +-
 drivers/net/ethernet/tile/tilegx.c                  |  4 ++--
 drivers/net/ethernet/tile/tilepro.c                 |  3 ++-
 drivers/net/hamradio/6pack.c                        |  3 ++-
 drivers/net/hamradio/baycom_epp.c                   |  2 +-
 drivers/net/hamradio/bpqether.c                     |  4 ++--
 drivers/net/hamradio/dmascc.c                       |  4 ++--
 drivers/net/hamradio/hdlcdrv.c                      |  2 +-
 drivers/net/hamradio/mkiss.c                        |  3 ++-
 drivers/net/hamradio/scc.c                          |  2 +-
 drivers/net/hamradio/yam.c                          |  2 +-
 drivers/net/ieee802154/fakehard.c                   |  3 ++-
 drivers/net/ifb.c                                   |  4 ++--
 drivers/net/loopback.c                              |  2 +-
 drivers/net/ppp/ppp_generic.c                       |  3 ++-
 drivers/net/slip/slip.c                             |  2 +-
 drivers/net/tun.c                                   |  3 ++-
 drivers/net/usb/cdc-phonet.c                        |  2 +-
 drivers/net/usb/hso.c                               |  3 ++-
 drivers/net/wan/dlci.c                              |  4 ++--
 drivers/net/wan/hdlc.c                              |  3 ++-
 drivers/net/wan/hdlc_fr.c                           |  5 +++--
 drivers/net/wan/lapbether.c                         |  4 ++--
 drivers/net/wan/sbni.c                              |  7 ++++---
 drivers/net/wan/sdla.c                              |  3 ++-
 drivers/net/wan/x25_asy.c                           |  4 ++--
 drivers/net/wimax/i2400m/usb.c                      |  2 +-
 drivers/net/wireless/airo.c                         |  5 +++--
 drivers/net/wireless/ath/ath6kl/cfg80211.c          |  2 +-
 drivers/net/wireless/ath/wil6210/netdev.c           |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c |  3 ++-
 drivers/net/wireless/libertas/main.c                |  2 +-
 drivers/net/wireless/libertas/mesh.c                |  2 +-
 drivers/net/wireless/mac80211_hwsim.c               |  3 ++-
 drivers/net/wireless/mwifiex/cfg80211.c             |  3 ++-
 drivers/net/xen-netback/interface.c                 |  4 ++--
 drivers/s390/net/claw.c                             |  2 +-
 drivers/s390/net/ctcm_main.c                        |  6 ++++--
 drivers/s390/net/netiucv.c                          |  2 +-
 drivers/s390/net/qeth_l2_main.c                     |  6 ++++--
 drivers/s390/net/qeth_l3_main.c                     |  3 ++-
 drivers/staging/cxt1e1/linux.c                      |  3 ++-
 drivers/staging/gdm724x/gdm_lte.c                   |  2 +-
 drivers/staging/gdm72xx/gdm_wimax.c                 |  3 ++-
 drivers/staging/vt6655/wpactl.c                     |  3 ++-
 drivers/staging/wlan-ng/p80211netdev.c              |  2 +-
 drivers/tty/n_gsm.c                                 |  5 ++---
 drivers/usb/gadget/f_phonet.c                       |  3 ++-
 include/linux/netdevice.h                           | 10 ++++++----
 net/802/fc.c                                        |  2 +-
 net/802/fddi.c                                      |  3 ++-
 net/802/hippi.c                                     |  3 ++-
 net/8021q/vlan.c                                    |  3 ++-
 net/appletalk/dev.c                                 |  3 ++-
 net/atm/br2684.c                                    |  4 ++--
 net/atm/clip.c                                      |  3 ++-
 net/batman-adv/soft-interface.c                     |  2 +-
 net/bluetooth/6lowpan.c                             |  3 ++-
 net/bluetooth/bnep/core.c                           |  5 +++--
 net/bridge/br_if.c                                  |  2 +-
 net/core/dev.c                                      |  2 ++
 net/core/rtnetlink.c                                |  4 ++--
 net/dsa/slave.c                                     |  4 ++--
 net/ethernet/eth.c                                  |  3 ++-
 net/ipv4/ip_tunnel.c                                |  2 +-
 net/ipv4/ipmr.c                                     |  2 +-
 net/ipv6/ip6_gre.c                                  |  6 ++++--
 net/ipv6/ip6_tunnel.c                               |  5 +++--
 net/ipv6/ip6_vti.c                                  |  4 ++--
 net/ipv6/ip6mr.c                                    |  2 +-
 net/ipv6/sit.c                                      |  4 +++-
 net/irda/irda_device.c                              |  3 ++-
 net/irda/irlan/irlan_eth.c                          |  2 +-
 net/l2tp/l2tp_eth.c                                 |  3 ++-
 net/mac80211/iface.c                                |  6 +++---
 net/mac802154/ieee802154_dev.c                      |  6 ++++--
 net/netrom/af_netrom.c                              |  2 +-
 net/openvswitch/vport-internal_dev.c                |  3 ++-
 net/phonet/pep-gprs.c                               |  2 +-
 net/rose/af_rose.c                                  |  2 +-
 net/sched/sch_teql.c                                |  4 ++--
 97 files changed, 180 insertions(+), 128 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index c398645..2c68da1 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1460,7 +1460,8 @@ static int fwnet_probe(struct fw_unit *unit,
 		goto have_dev;
 	}
 
-	net = alloc_netdev(sizeof(*dev), "firewire%d", fwnet_init_dev);
+	net = alloc_netdev(sizeof(*dev), "firewire%d", NET_NAME_UNKNOWN,
+			   fwnet_init_dev);
 	if (net == NULL) {
 		mutex_unlock(&fwnet_device_mutex);
 		return -ENOMEM;
diff --git a/drivers/hsi/clients/ssi_protocol.c b/drivers/hsi/clients/ssi_protocol.c
index ce4be37..737fa2e 100644
--- a/drivers/hsi/clients/ssi_protocol.c
+++ b/drivers/hsi/clients/ssi_protocol.c
@@ -1115,7 +1115,7 @@ static int ssi_protocol_probe(struct device *dev)
 		goto out;
 	}
 
-	ssi->netdev = alloc_netdev(0, ifname, ssip_pn_setup);
+	ssi->netdev = alloc_netdev(0, ifname, NET_NAME_UNKNOWN, ssip_pn_setup);
 	if (!ssi->netdev) {
 		dev_err(dev, "No memory for netdev\n");
 		err = -ENOMEM;
diff --git a/drivers/infiniband/hw/amso1100/c2_provider.c b/drivers/infiniband/hw/amso1100/c2_provider.c
index 8af33cf..2d5cbf4 100644
--- a/drivers/infiniband/hw/amso1100/c2_provider.c
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c
@@ -734,7 +734,7 @@ static struct net_device *c2_pseudo_netdev_init(struct c2_dev *c2dev)
 	/* change ethxxx to iwxxx */
 	strcpy(name, "iw");
 	strcat(name, &c2dev->netdev->name[3]);
-	netdev = alloc_netdev(0, name, setup);
+	netdev = alloc_netdev(0, name, NET_NAME_UNKNOWN, setup);
 	if (!netdev) {
 		printk(KERN_ERR PFX "%s -  etherdev alloc failed",
 			__func__);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 5786a78..4e675f4 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1394,8 +1394,8 @@ struct ipoib_dev_priv *ipoib_intf_alloc(const char *name)
 {
 	struct net_device *dev;
 
-	dev = alloc_netdev((int) sizeof (struct ipoib_dev_priv), name,
-			   ipoib_setup);
+	dev = alloc_netdev((int)sizeof(struct ipoib_dev_priv), name,
+			   NET_NAME_UNKNOWN, ipoib_setup);
 	if (!dev)
 		return NULL;
 
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index d9aebbc..c2ed624 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -2588,7 +2588,8 @@ isdn_net_new(char *name, struct net_device *master)
 		printk(KERN_WARNING "isdn_net: Could not allocate net-device\n");
 		return NULL;
 	}
-	netdev->dev = alloc_netdev(sizeof(isdn_net_local), name, _isdn_setup);
+	netdev->dev = alloc_netdev(sizeof(isdn_net_local), name,
+				   NET_NAME_UNKNOWN, _isdn_setup);
 	if (!netdev->dev) {
 		printk(KERN_WARNING "isdn_net: Could not allocate network device\n");
 		kfree(netdev);
diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index 8a86b30..059e611 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -1276,7 +1276,8 @@ static int dvb_net_add_if(struct dvb_net *dvbnet, u16 pid, u8 feedtype)
 	if ((if_num = get_if(dvbnet)) < 0)
 		return -EINVAL;
 
-	net = alloc_netdev(sizeof(struct dvb_net_priv), "dvb", dvb_net_setup);
+	net = alloc_netdev(sizeof(struct dvb_net_priv), "dvb",
+			   NET_NAME_UNKNOWN, dvb_net_setup);
 	if (!net)
 		return -ENOMEM;
 
diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 3fac67a..557f978 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -544,7 +544,8 @@ xpnet_init(void)
 	 * use ether_setup() to init the majority of our device
 	 * structure and then override the necessary pieces.
 	 */
-	xpnet_device = alloc_netdev(0, XPNET_DEVICE_NAME, ether_setup);
+	xpnet_device = alloc_netdev(0, XPNET_DEVICE_NAME, NET_NAME_UNKNOWN,
+				    ether_setup);
 	if (xpnet_device == NULL) {
 		kfree(xpnet_broadcast_partitions);
 		return -ENOMEM;
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index a956053..3b790de 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -346,7 +346,8 @@ struct net_device *alloc_arcdev(const char *name)
 	struct net_device *dev;
 
 	dev = alloc_netdev(sizeof(struct arcnet_local),
-			   name && *name ? name : "arc%d", arcdev_setup);
+			   name && *name ? name : "arc%d", NET_NAME_UNKNOWN,
+			   arcdev_setup);
 	if(dev) {
 		struct arcnet_local *lp = netdev_priv(dev);
 		spin_lock_init(&lp->lock);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3a451b6..a2678fe 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4440,7 +4440,7 @@ int bond_create(struct net *net, const char *name)
 	rtnl_lock();
 
 	bond_dev = alloc_netdev_mq(sizeof(struct bonding),
-				   name ? name : "bond%d",
+				   name ? name : "bond%d", NET_NAME_UNKNOWN,
 				   bond_setup, tx_queues);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index fc73865..27bbc56 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -349,7 +349,8 @@ static int ldisc_open(struct tty_struct *tty)
 	result = snprintf(name, sizeof(name), "cf%s", tty->name);
 	if (result >= IFNAMSIZ)
 		return -EINVAL;
-	dev = alloc_netdev(sizeof(*ser), name, caifdev_setup);
+	dev = alloc_netdev(sizeof(*ser), name, NET_NAME_UNKNOWN,
+			   caifdev_setup);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index ff54c0e..72ea9ff 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -730,8 +730,8 @@ int cfspi_spi_probe(struct platform_device *pdev)
 	int res;
 	dev = (struct cfspi_dev *)pdev->dev.platform_data;
 
-	ndev = alloc_netdev(sizeof(struct cfspi),
-			"cfspi%d", cfspi_setup);
+	ndev = alloc_netdev(sizeof(struct cfspi), "cfspi%d",
+			    NET_NAME_UNKNOWN, cfspi_setup);
 	if (!dev)
 		return -ENODEV;
 
diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_virtio.c
index 9856086..a5fefb9 100644
--- a/drivers/net/caif/caif_virtio.c
+++ b/drivers/net/caif/caif_virtio.c
@@ -661,7 +661,7 @@ static int cfv_probe(struct virtio_device *vdev)
 	int err = -EINVAL;
 
 	netdev = alloc_netdev(sizeof(struct cfv_info), cfv_netdev_name,
-			      cfv_netdev_setup);
+			      NET_NAME_UNKNOWN, cfv_netdev_setup);
 	if (!netdev)
 		return -ENOMEM;
 
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index e318e87..9f91fcb 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -565,7 +565,7 @@ struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max)
 	else
 		size = sizeof_priv;
 
-	dev = alloc_netdev(size, "can%d", can_setup);
+	dev = alloc_netdev(size, "can%d", NET_NAME_UNKNOWN, can_setup);
 	if (!dev)
 		return NULL;
 
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index ea4d4f1..acb5b92 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -529,7 +529,7 @@ static struct slcan *slc_alloc(dev_t line)
 		return NULL;
 
 	sprintf(name, "slcan%d", i);
-	dev = alloc_netdev(sizeof(*sl), name, slc_setup);
+	dev = alloc_netdev(sizeof(*sl), name, NET_NAME_UNKNOWN, slc_setup);
 	if (!dev)
 		return NULL;
 
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 0932ffb..ff435fb 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -164,7 +164,7 @@ static int __init dummy_init_one(void)
 	struct net_device *dev_dummy;
 	int err;
 
-	dev_dummy = alloc_netdev(0, "dummy%d", dummy_setup);
+	dev_dummy = alloc_netdev(0, "dummy%d", NET_NAME_UNKNOWN, dummy_setup);
 	if (!dev_dummy)
 		return -ENOMEM;
 
diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 7a79b60..957e5c0 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -585,7 +585,8 @@ static int __init eql_init_module(void)
 
 	pr_info("%s\n", version);
 
-	dev_eql = alloc_netdev(sizeof(equalizer_t), "eql", eql_setup);
+	dev_eql = alloc_netdev(sizeof(equalizer_t), "eql", NET_NAME_UNKNOWN,
+			       eql_setup);
 	if (!dev_eql)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index 599311f..b96e885 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -986,7 +986,7 @@ static void ethdev_setup(struct net_device *dev)
 static struct net_device *____alloc_ei_netdev(int size)
 {
 	return alloc_netdev(sizeof(struct ei_device) + size, "eth%d",
-				ethdev_setup);
+			    NET_NAME_UNKNOWN, ethdev_setup);
 }
 
 
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 4c70360..69557a2 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2201,8 +2201,8 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 	/* Allocate the device structure.  Normally, "name" is a
 	 * template, instantiated by register_netdev(), but not for us.
 	 */
-	dev = alloc_netdev_mqs(sizeof(*priv), name, tile_net_setup,
-			       NR_CPUS, 1);
+	dev = alloc_netdev_mqs(sizeof(*priv), name, NET_NAME_UNKNOWN,
+			       tile_net_setup, NR_CPUS, 1);
 	if (!dev) {
 		pr_err("alloc_netdev_mqs(%s) failed\n", name);
 		return;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index e5a5c5d..88c7121 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2292,7 +2292,8 @@ static struct net_device *tile_net_dev_init(const char *name)
 	 * tile_net_setup(), and saves "name".  Normally, "name" is a
 	 * template, instantiated by register_netdev(), but not for us.
 	 */
-	dev = alloc_netdev(sizeof(*priv), name, tile_net_setup);
+	dev = alloc_netdev(sizeof(*priv), name, NET_NAME_UNKNOWN,
+			   tile_net_setup);
 	if (!dev) {
 		pr_err("alloc_netdev(%s) failed\n", name);
 		return NULL;
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 66e2b19..c3c4051 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -596,7 +596,8 @@ static int sixpack_open(struct tty_struct *tty)
 	if (tty->ops->write == NULL)
 		return -EOPNOTSUPP;
 
-	dev = alloc_netdev(sizeof(struct sixpack), "sp%d", sp_setup);
+	dev = alloc_netdev(sizeof(struct sixpack), "sp%d", NET_NAME_UNKNOWN,
+			   sp_setup);
 	if (!dev) {
 		err = -ENOMEM;
 		goto out;
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 484f77e..a98c153 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -1206,7 +1206,7 @@ static int __init init_baycomepp(void)
 		struct net_device *dev;
 		
 		dev = alloc_netdev(sizeof(struct baycom_state), "bce%d",
-				   baycom_epp_dev_setup);
+				   NET_NAME_UNKNOWN, baycom_epp_dev_setup);
 
 		if (!dev) {
 			printk(KERN_WARNING "bce%d : out of memory\n", i);
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index d50b23c..c2894e4 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -501,8 +501,8 @@ static int bpq_new_device(struct net_device *edev)
 	struct net_device *ndev;
 	struct bpqdev *bpq;
 
-	ndev = alloc_netdev(sizeof(struct bpqdev), "bpq%d",
-			   bpq_setup);
+	ndev = alloc_netdev(sizeof(struct bpqdev), "bpq%d", NET_NAME_UNKNOWN,
+			    bpq_setup);
 	if (!ndev)
 		return -ENOMEM;
 
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 6636022..0fad408 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -466,7 +466,7 @@ static int __init setup_adapter(int card_base, int type, int n)
 	if (!info)
 		goto out;
 
-	info->dev[0] = alloc_netdev(0, "", dev_setup);
+	info->dev[0] = alloc_netdev(0, "", NET_NAME_UNKNOWN, dev_setup);
 	if (!info->dev[0]) {
 		printk(KERN_ERR "dmascc: "
 		       "could not allocate memory for %s at %#3x\n",
@@ -474,7 +474,7 @@ static int __init setup_adapter(int card_base, int type, int n)
 		goto out1;
 	}
 
-	info->dev[1] = alloc_netdev(0, "", dev_setup);
+	info->dev[1] = alloc_netdev(0, "", NET_NAME_UNKNOWN, dev_setup);
 	if (!info->dev[1]) {
 		printk(KERN_ERR "dmascc: "
 		       "could not allocate memory for %s at %#3x\n",
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 5d78c1d..c67a272 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -699,7 +699,7 @@ struct net_device *hdlcdrv_register(const struct hdlcdrv_ops *ops,
 	if (privsize < sizeof(struct hdlcdrv_state))
 		privsize = sizeof(struct hdlcdrv_state);
 
-	dev = alloc_netdev(privsize, ifname, hdlcdrv_setup);
+	dev = alloc_netdev(privsize, ifname, NET_NAME_UNKNOWN, hdlcdrv_setup);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 8a6c720..f990bb1c 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -734,7 +734,8 @@ static int mkiss_open(struct tty_struct *tty)
 	if (tty->ops->write == NULL)
 		return -EOPNOTSUPP;
 
-	dev = alloc_netdev(sizeof(struct mkiss), "ax%d", ax_setup);
+	dev = alloc_netdev(sizeof(struct mkiss), "ax%d", NET_NAME_UNKNOWN,
+			   ax_setup);
 	if (!dev) {
 		err = -ENOMEM;
 		goto out;
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 4bc6ee8..57be9e0 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1515,7 +1515,7 @@ static int scc_net_alloc(const char *name, struct scc_channel *scc)
 	int err;
 	struct net_device *dev;
 
-	dev = alloc_netdev(0, name, scc_net_setup);
+	dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, scc_net_setup);
 	if (!dev) 
 		return -ENOMEM;
 
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 8190165..717433c 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -1147,7 +1147,7 @@ static int __init yam_init_driver(void)
 		sprintf(name, "yam%d", i);
 		
 		dev = alloc_netdev(sizeof(struct yam_port), name,
-				   yam_setup);
+				   NET_NAME_UNKNOWN, yam_setup);
 		if (!dev) {
 			pr_err("yam: cannot allocate net device\n");
 			err = -ENOMEM;
diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index 78f18be..9ce854f 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -343,7 +343,8 @@ static int ieee802154fake_probe(struct platform_device *pdev)
 	if (!phy)
 		return -ENOMEM;
 
-	dev = alloc_netdev(sizeof(struct fakehard_priv), "hardwpan%d", ieee802154_fake_setup);
+	dev = alloc_netdev(sizeof(struct fakehard_priv), "hardwpan%d",
+			   NET_NAME_UNKNOWN, ieee802154_fake_setup);
 	if (!dev) {
 		wpan_phy_free(phy);
 		return -ENOMEM;
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 46a7790..d2d4a3d 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -269,8 +269,8 @@ static int __init ifb_init_one(int index)
 	struct ifb_private *dp;
 	int err;
 
-	dev_ifb = alloc_netdev(sizeof(struct ifb_private),
-				 "ifb%d", ifb_setup);
+	dev_ifb = alloc_netdev(sizeof(struct ifb_private), "ifb%d",
+			       NET_NAME_UNKNOWN, ifb_setup);
 
 	if (!dev_ifb)
 		return -ENOMEM;
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index bb96409..8f22625 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -195,7 +195,7 @@ static __net_init int loopback_net_init(struct net *net)
 	int err;
 
 	err = -ENOMEM;
-	dev = alloc_netdev(0, "lo", loopback_setup);
+	dev = alloc_netdev(0, "lo", NET_NAME_UNKNOWN, loopback_setup);
 	if (!dev)
 		goto out;
 
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 91d6c12..5c002b1 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2665,7 +2665,8 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 	int ret = -ENOMEM;
 	int i;
 
-	dev = alloc_netdev(sizeof(struct ppp), "", ppp_setup);
+	dev = alloc_netdev(sizeof(struct ppp), "", NET_NAME_UNKNOWN,
+			   ppp_setup);
 	if (!dev)
 		goto out1;
 
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index 8752644..05387b1 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -749,7 +749,7 @@ static struct slip *sl_alloc(dev_t line)
 		return NULL;
 
 	sprintf(name, "sl%d", i);
-	dev = alloc_netdev(sizeof(*sl), name, sl_setup);
+	dev = alloc_netdev(sizeof(*sl), name, NET_NAME_UNKNOWN, sl_setup);
 	if (!dev)
 		return NULL;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 98bad1f..acaaf67 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1633,7 +1633,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			name = ifr->ifr_name;
 
 		dev = alloc_netdev_mqs(sizeof(struct tun_struct), name,
-				       tun_setup, queues, queues);
+				       NET_NAME_UNKNOWN, tun_setup, queues,
+				       queues);
 
 		if (!dev)
 			return -ENOMEM;
diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 6358d42..2ec1500 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -387,7 +387,7 @@ static int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *i
 		return -EINVAL;
 
 	dev = alloc_netdev(sizeof(*pnd) + sizeof(pnd->urbs[0]) * rxq_size,
-				ifname, usbpn_setup);
+			   ifname, NET_NAME_UNKNOWN, usbpn_setup);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index a3a0586..50b36b2 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2520,7 +2520,8 @@ static struct hso_device *hso_create_net_device(struct usb_interface *interface,
 
 	/* allocate our network device, then we can put in our private data */
 	/* call hso_net_init to do the basic initialization */
-	net = alloc_netdev(sizeof(struct hso_net), "hso%d", hso_net_init);
+	net = alloc_netdev(sizeof(struct hso_net), "hso%d", NET_NAME_UNKNOWN,
+			   hso_net_init);
 	if (!net) {
 		dev_err(&interface->dev, "Unable to create ethernet device\n");
 		goto exit;
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 19f7cb2..a463613 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -327,8 +327,8 @@ static int dlci_add(struct dlci_add *dlci)
 		goto err1;
 
 	/* create device name */
-	master = alloc_netdev( sizeof(struct dlci_local), "dlci%d",
-			      dlci_setup);
+	master = alloc_netdev(sizeof(struct dlci_local), "dlci%d",
+			      NET_NAME_UNKNOWN, dlci_setup);
 	if (!master) {
 		err = -ENOMEM;
 		goto err1;
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 9c33ca9..51f6cee 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -256,7 +256,8 @@ static void hdlc_setup(struct net_device *dev)
 struct net_device *alloc_hdlcdev(void *priv)
 {
 	struct net_device *dev;
-	dev = alloc_netdev(sizeof(struct hdlc_device), "hdlc%d", hdlc_setup);
+	dev = alloc_netdev(sizeof(struct hdlc_device), "hdlc%d",
+			   NET_NAME_UNKNOWN, hdlc_setup);
 	if (dev)
 		dev_to_hdlc(dev)->priv = priv;
 	return dev;
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 7c6cb4f3..7cc64ea 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1075,10 +1075,11 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	used = pvc_is_used(pvc);
 
 	if (type == ARPHRD_ETHER) {
-		dev = alloc_netdev(0, "pvceth%d", ether_setup);
+		dev = alloc_netdev(0, "pvceth%d", NET_NAME_UNKNOWN,
+				   ether_setup);
 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	} else
-		dev = alloc_netdev(0, "pvc%d", pvc_setup);
+		dev = alloc_netdev(0, "pvc%d", NET_NAME_UNKNOWN, pvc_setup);
 
 	if (!dev) {
 		netdev_warn(frad, "Memory squeeze on fr_pvc()\n");
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index a33a46f..2f5eda8 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -325,8 +325,8 @@ static int lapbeth_new_device(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	ndev = alloc_netdev(sizeof(*lapbeth), "lapb%d", 
-			   lapbeth_setup);
+	ndev = alloc_netdev(sizeof(*lapbeth), "lapb%d", NET_NAME_UNKNOWN,
+			    lapbeth_setup);
 	if (!ndev)
 		goto out;
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 1b89ecf..758c4ba 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -227,7 +227,8 @@ int __init sbni_probe(int unit)
 	struct net_device *dev;
 	int err;
 
-	dev = alloc_netdev(sizeof(struct net_local), "sbni", sbni_devsetup);
+	dev = alloc_netdev(sizeof(struct net_local), "sbni",
+			   NET_NAME_UNKNOWN, sbni_devsetup);
 	if (!dev)
 		return -ENOMEM;
 
@@ -1477,8 +1478,8 @@ int __init init_module( void )
 	int err;
 
 	while( num < SBNI_MAX_NUM_CARDS ) {
-		dev = alloc_netdev(sizeof(struct net_local), 
-				   "sbni%d", sbni_devsetup);
+		dev = alloc_netdev(sizeof(struct net_local), "sbni%d",
+				   NET_NAME_UNKNOWN, sbni_devsetup);
 		if( !dev)
 			break;
 
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index cdd45fb..421ac5f 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1631,7 +1631,8 @@ static int __init init_sdla(void)
 
 	printk("%s.\n", version);
 
-	sdla = alloc_netdev(sizeof(struct frad_local), "sdla0", setup_sdla);
+	sdla = alloc_netdev(sizeof(struct frad_local), "sdla0",
+			    NET_NAME_UNKNOWN, setup_sdla);
 	if (!sdla) 
 		return -ENOMEM;
 
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 5895f19..df6c073 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -81,8 +81,8 @@ static struct x25_asy *x25_asy_alloc(void)
 		char name[IFNAMSIZ];
 		sprintf(name, "x25asy%d", i);
 
-		dev = alloc_netdev(sizeof(struct x25_asy),
-				   name, x25_asy_setup);
+		dev = alloc_netdev(sizeof(struct x25_asy), name,
+				   NET_NAME_UNKNOWN, x25_asy_setup);
 		if (!dev)
 			return NULL;
 
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index cd15a93..e7f5910 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -472,7 +472,7 @@ int i2400mu_probe(struct usb_interface *iface,
 
 	/* Allocate instance [calls i2400m_netdev_setup() on it]. */
 	result = -ENOMEM;
-	net_dev = alloc_netdev(sizeof(*i2400mu), "wmx%d",
+	net_dev = alloc_netdev(sizeof(*i2400mu), "wmx%d", NET_NAME_UNKNOWN,
 			       i2400mu_netdev_setup);
 	if (net_dev == NULL) {
 		dev_err(dev, "no memory for network device instance\n");
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 64747d4..29d8873 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2685,7 +2685,8 @@ static struct net_device *init_wifidev(struct airo_info *ai,
 					struct net_device *ethdev)
 {
 	int err;
-	struct net_device *dev = alloc_netdev(0, "wifi%d", wifi_setup);
+	struct net_device *dev = alloc_netdev(0, "wifi%d", NET_NAME_UNKNOWN,
+					      wifi_setup);
 	if (!dev)
 		return NULL;
 	dev->ml_priv = ethdev->ml_priv;
@@ -2785,7 +2786,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	CapabilityRid cap_rid;
 
 	/* Create the network device object. */
-	dev = alloc_netdev(sizeof(*ai), "", ether_setup);
+	dev = alloc_netdev(sizeof(*ai), "", NET_NAME_UNKNOWN, ether_setup);
 	if (!dev) {
 		airo_print_err("", "Couldn't alloc_etherdev");
 		return NULL;
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 0e26f4a..1c4ce8e 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -3636,7 +3636,7 @@ struct wireless_dev *ath6kl_interface_add(struct ath6kl *ar, const char *name,
 	struct net_device *ndev;
 	struct ath6kl_vif *vif;
 
-	ndev = alloc_netdev(sizeof(*vif), name, ether_setup);
+	ndev = alloc_netdev(sizeof(*vif), name, NET_NAME_UNKNOWN, ether_setup);
 	if (!ndev)
 		return NULL;
 
diff --git a/drivers/net/wireless/ath/wil6210/netdev.c b/drivers/net/wireless/ath/wil6210/netdev.c
index 106b6dc..7afce6e 100644
--- a/drivers/net/wireless/ath/wil6210/netdev.c
+++ b/drivers/net/wireless/ath/wil6210/netdev.c
@@ -132,7 +132,7 @@ void *wil_if_alloc(struct device *dev, void __iomem *csr)
 	ch = wdev->wiphy->bands[IEEE80211_BAND_60GHZ]->channels;
 	cfg80211_chandef_create(&wdev->preset_chandef, ch, NL80211_CHAN_NO_HT);
 
-	ndev = alloc_netdev(0, "wlan%d", ether_setup);
+	ndev = alloc_netdev(0, "wlan%d", NET_NAME_UNKNOWN, ether_setup);
 	if (!ndev) {
 		dev_err(dev, "alloc_netdev_mqs failed\n");
 		rc = -ENOMEM;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 09dd8c1..2699441 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -808,7 +808,8 @@ struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bssidx, s32 ifidx,
 	} else {
 		brcmf_dbg(INFO, "allocate netdev interface\n");
 		/* Allocate netdev, including space for private structure */
-		ndev = alloc_netdev(sizeof(*ifp), name, ether_setup);
+		ndev = alloc_netdev(sizeof(*ifp), name, NET_NAME_UNKNOWN,
+				    ether_setup);
 		if (!ndev)
 			return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 0c02f04..569b64e 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -981,7 +981,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
 		goto err_wdev;
 	}
 
-	dev = alloc_netdev(0, "wlan%d", ether_setup);
+	dev = alloc_netdev(0, "wlan%d", NET_NAME_UNKNOWN, ether_setup);
 	if (!dev) {
 		dev_err(dmdev, "no memory for network device instance\n");
 		goto err_adapter;
diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
index 6fef746..01a67f6 100644
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -1000,7 +1000,7 @@ static int lbs_add_mesh(struct lbs_private *priv)
 		goto done;
 	}
 
-	mesh_dev = alloc_netdev(0, "msh%d", ether_setup);
+	mesh_dev = alloc_netdev(0, "msh%d", NET_NAME_UNKNOWN, ether_setup);
 	if (!mesh_dev) {
 		lbs_deb_mesh("init mshX device failed\n");
 		ret = -ENOMEM;
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index a312c65..a000b22 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2679,7 +2679,8 @@ static int __init init_mac80211_hwsim(void)
 			goto out_free_radios;
 	}
 
-	hwsim_mon = alloc_netdev(0, "hwsim%d", hwsim_mon_setup);
+	hwsim_mon = alloc_netdev(0, "hwsim%d", NET_NAME_UNKNOWN,
+				 hwsim_mon_setup);
 	if (hwsim_mon == NULL) {
 		err = -ENOMEM;
 		goto out_free_radios;
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index e95dec9..30e8fd9 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -2263,7 +2263,8 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 	}
 
 	dev = alloc_netdev_mqs(sizeof(struct mwifiex_private *), name,
-			       ether_setup, IEEE80211_NUM_ACS, 1);
+			       NET_NAME_UNKNOWN, ether_setup,
+			       IEEE80211_NUM_ACS, 1);
 	if (!dev) {
 		wiphy_err(wiphy, "no memory available for netdevice\n");
 		priv->bss_mode = NL80211_IFTYPE_UNSPECIFIED;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 9e97c7c..793275d 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -418,8 +418,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	 * When the guest selects the desired number, it will be updated
 	 * via netif_set_real_num_*_queues().
 	 */
-	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup,
-			      xenvif_max_queues);
+	dev = alloc_netdev_mq(sizeof(struct xenvif), name, NET_NAME_UNKNOWN,
+			      ether_setup, xenvif_max_queues);
 	if (dev == NULL) {
 		pr_warn("Could not allocate netdev for %s\n", name);
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index d837c3c..fbc6701 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -2915,7 +2915,7 @@ claw_new_device(struct ccwgroup_device *cgdev)
 			"failed with error code %d\n", ret);
 		goto out;
 	}
-	dev = alloc_netdev(0,"claw%d",claw_init_netdevice);
+	dev = alloc_netdev(0, "claw%d", NET_NAME_UNKNOWN, claw_init_netdevice);
 	if (!dev) {
 		dev_warn(&cgdev->dev,
 			"Activating the CLAW device failed\n");
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index 03b6ad0..e056dd4 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -1137,9 +1137,11 @@ static struct net_device *ctcm_init_netdevice(struct ctcm_priv *priv)
 		return NULL;
 
 	if (IS_MPC(priv))
-		dev = alloc_netdev(0, MPC_DEVICE_GENE, ctcm_dev_setup);
+		dev = alloc_netdev(0, MPC_DEVICE_GENE, NET_NAME_UNKNOWN,
+				   ctcm_dev_setup);
 	else
-		dev = alloc_netdev(0, CTC_DEVICE_GENE, ctcm_dev_setup);
+		dev = alloc_netdev(0, CTC_DEVICE_GENE, NET_NAME_UNKNOWN,
+				   ctcm_dev_setup);
 
 	if (!dev) {
 		CTCM_DBF_TEXT_(ERROR, CTC_DBF_CRIT,
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index ce16d1b..0a87809 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -2015,7 +2015,7 @@ static struct net_device *netiucv_init_netdevice(char *username, char *userdata)
 	struct net_device *dev;
 
 	dev = alloc_netdev(sizeof(struct netiucv_priv), "iucv%d",
-			   netiucv_setup_netdevice);
+			   NET_NAME_UNKNOWN, netiucv_setup_netdevice);
 	if (!dev)
 		return NULL;
 	rtnl_lock();
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 5ef5b4f..c2679bf 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -952,10 +952,12 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 {
 	switch (card->info.type) {
 	case QETH_CARD_TYPE_IQD:
-		card->dev = alloc_netdev(0, "hsi%d", ether_setup);
+		card->dev = alloc_netdev(0, "hsi%d", NET_NAME_UNKNOWN,
+					 ether_setup);
 		break;
 	case QETH_CARD_TYPE_OSN:
-		card->dev = alloc_netdev(0, "osn%d", ether_setup);
+		card->dev = alloc_netdev(0, "osn%d", NET_NAME_UNKNOWN,
+					 ether_setup);
 		card->dev->flags |= IFF_NOARP;
 		break;
 	default:
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 14e0b58..f8427a2 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3287,7 +3287,8 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 			}
 		}
 	} else if (card->info.type == QETH_CARD_TYPE_IQD) {
-		card->dev = alloc_netdev(0, "hsi%d", ether_setup);
+		card->dev = alloc_netdev(0, "hsi%d", NET_NAME_UNKNOWN,
+					 ether_setup);
 		if (!card->dev)
 			return -ENODEV;
 		card->dev->flags |= IFF_NOARP;
diff --git a/drivers/staging/cxt1e1/linux.c b/drivers/staging/cxt1e1/linux.c
index 09f3d5c..85d776b 100644
--- a/drivers/staging/cxt1e1/linux.c
+++ b/drivers/staging/cxt1e1/linux.c
@@ -917,7 +917,8 @@ c4_add_dev(hdw_info_t *hi, int brdno, unsigned long f0, unsigned long f1,
 	struct net_device *ndev;
 	ci_t       *ci;
 
-	ndev = alloc_netdev(sizeof(ci_t), SBE_IFACETMPL, c4_setup);
+	ndev = alloc_netdev(sizeof(ci_t), SBE_IFACETMPL, NET_NAME_UNKNOWN,
+			    c4_setup);
 	if (!ndev) {
 		pr_warning("%s: no memory for struct net_device !\n",
 			   hi->devname);
diff --git a/drivers/staging/gdm724x/gdm_lte.c b/drivers/staging/gdm724x/gdm_lte.c
index 64c55b9..c226852 100644
--- a/drivers/staging/gdm724x/gdm_lte.c
+++ b/drivers/staging/gdm724x/gdm_lte.c
@@ -885,7 +885,7 @@ int register_lte_device(struct phy_dev *phy_dev,
 
 		/* Allocate netdev */
 		net = alloc_netdev(sizeof(struct nic), pdn_dev_name,
-				ether_setup);
+				   NET_NAME_UNKNOWN, ether_setup);
 		if (net == NULL) {
 			pr_err("alloc_netdev failed\n");
 			ret = -ENOMEM;
diff --git a/drivers/staging/gdm72xx/gdm_wimax.c b/drivers/staging/gdm72xx/gdm_wimax.c
index e5e5115..a9a6fc5 100644
--- a/drivers/staging/gdm72xx/gdm_wimax.c
+++ b/drivers/staging/gdm72xx/gdm_wimax.c
@@ -886,7 +886,8 @@ int register_wimax_device(struct phy_dev *phy_dev, struct device *pdev)
 	struct net_device *dev;
 	int ret;
 
-	dev = alloc_netdev(sizeof(*nic), "wm%d", ether_setup);
+	dev = alloc_netdev(sizeof(*nic), "wm%d", NET_NAME_UNKNOWN,
+			   ether_setup);
 
 	if (dev == NULL) {
 		pr_err("alloc_etherdev failed\n");
diff --git a/drivers/staging/vt6655/wpactl.c b/drivers/staging/vt6655/wpactl.c
index 8392d4d..0814bfd 100644
--- a/drivers/staging/vt6655/wpactl.c
+++ b/drivers/staging/vt6655/wpactl.c
@@ -89,7 +89,8 @@ static int wpa_init_wpadev(PSDevice pDevice)
 	struct net_device *dev = pDevice->dev;
 	int ret = 0;
 
-	pDevice->wpadev = alloc_netdev(sizeof(PSDevice), "vntwpa", wpadev_setup);
+	pDevice->wpadev = alloc_netdev(sizeof(PSDevice), "vntwpa",
+				       NET_NAME_UNKNOWN, wpadev_setup);
 	if (pDevice->wpadev == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index 00b186c..6c78f91 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -769,7 +769,7 @@ int wlan_setup(wlandevice_t *wlandev, struct device *physdev)
 
 	/* Allocate and initialize the struct device */
 	netdev = alloc_netdev(sizeof(struct wireless_dev), "wlan%d",
-				ether_setup);
+			      NET_NAME_UNKNOWN, ether_setup);
 	if (netdev == NULL) {
 		dev_err(physdev, "Failed to alloc netdev.\n");
 		wlan_free_wiphy(wiphy);
diff --git a/drivers/tty/n_gsm.c b/drivers/tty/n_gsm.c
index 2ebe47b..cde3ab9 100644
--- a/drivers/tty/n_gsm.c
+++ b/drivers/tty/n_gsm.c
@@ -2789,9 +2789,8 @@ static int gsm_create_network(struct gsm_dlci *dlci, struct gsm_netconfig *nc)
 	netname = "gsm%d";
 	if (nc->if_name[0] != '\0')
 		netname = nc->if_name;
-	net = alloc_netdev(sizeof(struct gsm_mux_net),
-			netname,
-			gsm_mux_net_init);
+	net = alloc_netdev(sizeof(struct gsm_mux_net), netname,
+			   NET_NAME_UNKNOWN, gsm_mux_net_init);
 	if (!net) {
 		pr_err("alloc_netdev failed");
 		return -ENOMEM;
diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phonet.c
index f2b7817..b9cfc15 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -721,7 +721,8 @@ struct net_device *gphonet_setup_default(void)
 	struct phonet_port *port;
 
 	/* Create net device */
-	dev = alloc_netdev(sizeof(*port), "upnlink%d", pn_net_setup);
+	dev = alloc_netdev(sizeof(*port), "upnlink%d", NET_NAME_UNKNOWN,
+			   pn_net_setup);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 551e187..80d5f5f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2989,13 +2989,15 @@ void ether_setup(struct net_device *dev);
 
 /* Support for loadable net-drivers */
 struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
+				    unsigned char name_assign_type,
 				    void (*setup)(struct net_device *),
 				    unsigned int txqs, unsigned int rxqs);
-#define alloc_netdev(sizeof_priv, name, setup) \
-	alloc_netdev_mqs(sizeof_priv, name, setup, 1, 1)
+#define alloc_netdev(sizeof_priv, name, name_assign_type, setup) \
+	alloc_netdev_mqs(sizeof_priv, name, name_assign_type, setup, 1, 1)
 
-#define alloc_netdev_mq(sizeof_priv, name, setup, count) \
-	alloc_netdev_mqs(sizeof_priv, name, setup, count, count)
+#define alloc_netdev_mq(sizeof_priv, name, name_assign_type, setup, count) \
+	alloc_netdev_mqs(sizeof_priv, name, name_assign_type, setup, count, \
+			 count)
 
 int register_netdev(struct net_device *dev);
 void unregister_netdev(struct net_device *dev);
diff --git a/net/802/fc.c b/net/802/fc.c
index 05eea6b..7c174b6 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -126,6 +126,6 @@ static void fc_setup(struct net_device *dev)
  */
 struct net_device *alloc_fcdev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "fc%d", fc_setup);
+	return alloc_netdev(sizeof_priv, "fc%d", NET_NAME_UNKNOWN, fc_setup);
 }
 EXPORT_SYMBOL(alloc_fcdev);
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 9cda4066..59e7346 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -207,7 +207,8 @@ static void fddi_setup(struct net_device *dev)
  */
 struct net_device *alloc_fddidev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "fddi%d", fddi_setup);
+	return alloc_netdev(sizeof_priv, "fddi%d", NET_NAME_UNKNOWN,
+			    fddi_setup);
 }
 EXPORT_SYMBOL(alloc_fddidev);
 
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 5ff2a71..2e03f82 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -228,7 +228,8 @@ static void hippi_setup(struct net_device *dev)
 
 struct net_device *alloc_hippi_dev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "hip%d", hippi_setup);
+	return alloc_netdev(sizeof_priv, "hip%d", NET_NAME_UNKNOWN,
+			    hippi_setup);
 }
 
 EXPORT_SYMBOL(alloc_hippi_dev);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 44ebd5c..cba9c21 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -250,7 +250,8 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
 	}
 
-	new_dev = alloc_netdev(sizeof(struct vlan_dev_priv), name, vlan_setup);
+	new_dev = alloc_netdev(sizeof(struct vlan_dev_priv), name,
+			       NET_NAME_UNKNOWN, vlan_setup);
 
 	if (new_dev == NULL)
 		return -ENOBUFS;
diff --git a/net/appletalk/dev.c b/net/appletalk/dev.c
index 6c8016f..e4158b8 100644
--- a/net/appletalk/dev.c
+++ b/net/appletalk/dev.c
@@ -39,6 +39,7 @@ static void ltalk_setup(struct net_device *dev)
 
 struct net_device *alloc_ltalkdev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "lt%d", ltalk_setup);
+	return alloc_netdev(sizeof_priv, "lt%d", NET_NAME_UNKNOWN,
+			    ltalk_setup);
 }
 EXPORT_SYMBOL(alloc_ltalkdev);
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 403e71f..cc78538 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -682,8 +682,8 @@ static int br2684_create(void __user *arg)
 
 	netdev = alloc_netdev(sizeof(struct br2684_dev),
 			      ni.ifname[0] ? ni.ifname : "nas%d",
-			      (payload == p_routed) ?
-			      br2684_setup_routed : br2684_setup);
+			      NET_NAME_UNKNOWN,
+			      (payload == p_routed) ? br2684_setup_routed : br2684_setup);
 	if (!netdev)
 		return -ENOMEM;
 
diff --git a/net/atm/clip.c b/net/atm/clip.c
index ba291ce..4633904 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -520,7 +520,8 @@ static int clip_create(int number)
 			if (PRIV(dev)->number >= number)
 				number = PRIV(dev)->number + 1;
 	}
-	dev = alloc_netdev(sizeof(struct clip_priv), "", clip_setup);
+	dev = alloc_netdev(sizeof(struct clip_priv), "", NET_NAME_UNKNOWN,
+			   clip_setup);
 	if (!dev)
 		return -ENOMEM;
 	clip_priv = PRIV(dev);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e7ee65d..d551e63 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -895,7 +895,7 @@ struct net_device *batadv_softif_create(const char *name)
 	int ret;
 
 	soft_iface = alloc_netdev(sizeof(struct batadv_priv), name,
-				  batadv_softif_init_early);
+				  NET_NAME_UNKNOWN, batadv_softif_init_early);
 	if (!soft_iface)
 		return NULL;
 
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 8796ffa..faf96fc 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -732,7 +732,8 @@ int bt_6lowpan_add_conn(struct l2cap_conn *conn)
 	if (dev)
 		return add_peer_conn(conn, dev);
 
-	netdev = alloc_netdev(sizeof(*dev), IFACE_NAME_TEMPLATE, netdev_setup);
+	netdev = alloc_netdev(sizeof(*dev), IFACE_NAME_TEMPLATE,
+			      NET_NAME_UNKNOWN, netdev_setup);
 	if (!netdev)
 		return -ENOMEM;
 
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index a841d3e..85bcc21 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -538,8 +538,9 @@ int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 
 	/* session struct allocated as private part of net_device */
 	dev = alloc_netdev(sizeof(struct bnep_session),
-				(*req->device) ? req->device : "bnep%d",
-				bnep_net_setup);
+			   (*req->device) ? req->device : "bnep%d",
+			   NET_NAME_UNKNOWN,
+			   bnep_net_setup);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 3eca3fd..078d336 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -344,7 +344,7 @@ int br_add_bridge(struct net *net, const char *name)
 	struct net_device *dev;
 	int res;
 
-	dev = alloc_netdev(sizeof(struct net_bridge), name,
+	dev = alloc_netdev(sizeof(struct net_bridge), name, NET_NAME_UNKNOWN,
 			   br_dev_setup);
 
 	if (!dev)
diff --git a/net/core/dev.c b/net/core/dev.c
index 7765ec5..d4b01ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6456,6 +6456,7 @@ void netdev_freemem(struct net_device *dev)
  *	for each queue on the device.
  */
 struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
+		unsigned char name_assign_type,
 		void (*setup)(struct net_device *),
 		unsigned int txqs, unsigned int rxqs)
 {
@@ -6534,6 +6535,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 #endif
 
 	strcpy(dev->name, name);
+	dev->name_assign_type = name_assign_type;
 	dev->group = INIT_NETDEV_GROUP;
 	if (!dev->ethtool_ops)
 		dev->ethtool_ops = &default_ethtool_ops;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1063996..899de40 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1823,8 +1823,8 @@ struct net_device *rtnl_create_link(struct net *net,
 		num_rx_queues = ops->get_num_rx_queues();
 
 	err = -ENOMEM;
-	dev = alloc_netdev_mqs(ops->priv_size, ifname, ops->setup,
-			       num_tx_queues, num_rx_queues);
+	dev = alloc_netdev_mqs(ops->priv_size, ifname, NET_NAME_UNKNOWN,
+			       ops->setup, num_tx_queues, num_rx_queues);
 	if (!dev)
 		goto err;
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 64c5af0..45a1e34 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -340,8 +340,8 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	struct dsa_slave_priv *p;
 	int ret;
 
-	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv),
-				 name, ether_setup);
+	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
+				 NET_NAME_UNKNOWN, ether_setup);
 	if (slave_dev == NULL)
 		return slave_dev;
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 5dc638c..f405e05 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -390,7 +390,8 @@ EXPORT_SYMBOL(ether_setup);
 struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 				      unsigned int rxqs)
 {
-	return alloc_netdev_mqs(sizeof_priv, "eth%d", ether_setup, txqs, rxqs);
+	return alloc_netdev_mqs(sizeof_priv, "eth%d", NET_NAME_UNKNOWN,
+				ether_setup, txqs, rxqs);
 }
 EXPORT_SYMBOL(alloc_etherdev_mqs);
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 54b6731..0157a7a 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -301,7 +301,7 @@ static struct net_device *__ip_tunnel_create(struct net *net,
 	}
 
 	ASSERT_RTNL();
-	dev = alloc_netdev(ops->priv_size, name, ops->setup);
+	dev = alloc_netdev(ops->priv_size, name, NET_NAME_UNKNOWN, ops->setup);
 	if (!dev) {
 		err = -ENOMEM;
 		goto failed;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 65bcaa7..c803458 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -500,7 +500,7 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 	else
 		sprintf(name, "pimreg%u", mrt->id);
 
-	dev = alloc_netdev(0, name, reg_vif_setup);
+	dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, reg_vif_setup);
 
 	if (dev == NULL)
 		return NULL;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3873181..1b7acfb 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -322,7 +322,8 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
 	else
 		strcpy(name, "ip6gre%d");
 
-	dev = alloc_netdev(sizeof(*t), name, ip6gre_tunnel_setup);
+	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN,
+			   ip6gre_tunnel_setup);
 	if (!dev)
 		return NULL;
 
@@ -1323,7 +1324,8 @@ static int __net_init ip6gre_init_net(struct net *net)
 	int err;
 
 	ign->fb_tunnel_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6gre0",
-					   ip6gre_tunnel_setup);
+					  NET_NAME_UNKNOWN,
+					  ip6gre_tunnel_setup);
 	if (!ign->fb_tunnel_dev) {
 		err = -ENOMEM;
 		goto err_alloc_dev;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index afa0824..71bd2ad 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -315,7 +315,8 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 	else
 		sprintf(name, "ip6tnl%%d");
 
-	dev = alloc_netdev(sizeof (*t), name, ip6_tnl_dev_setup);
+	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN,
+			   ip6_tnl_dev_setup);
 	if (dev == NULL)
 		goto failed;
 
@@ -1772,7 +1773,7 @@ static int __net_init ip6_tnl_init_net(struct net *net)
 
 	err = -ENOMEM;
 	ip6n->fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
-				      ip6_tnl_dev_setup);
+					NET_NAME_UNKNOWN, ip6_tnl_dev_setup);
 
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 9aaa6bb..17ee4fc 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -204,7 +204,7 @@ static struct ip6_tnl *vti6_tnl_create(struct net *net, struct __ip6_tnl_parm *p
 	else
 		sprintf(name, "ip6_vti%%d");
 
-	dev = alloc_netdev(sizeof(*t), name, vti6_dev_setup);
+	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN, vti6_dev_setup);
 	if (dev == NULL)
 		goto failed;
 
@@ -1020,7 +1020,7 @@ static int __net_init vti6_init_net(struct net *net)
 
 	err = -ENOMEM;
 	ip6n->fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6_vti0",
-					vti6_dev_setup);
+					NET_NAME_UNKNOWN, vti6_dev_setup);
 
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 8250474..f9a3fd3 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -744,7 +744,7 @@ static struct net_device *ip6mr_reg_vif(struct net *net, struct mr6_table *mrt)
 	else
 		sprintf(name, "pim6reg%u", mrt->id);
 
-	dev = alloc_netdev(0, name, reg_vif_setup);
+	dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, reg_vif_setup);
 	if (dev == NULL)
 		return NULL;
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 4f40817..2e9ba03 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -250,7 +250,8 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	else
 		strcpy(name, "sit%d");
 
-	dev = alloc_netdev(sizeof(*t), name, ipip6_tunnel_setup);
+	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN,
+			   ipip6_tunnel_setup);
 	if (dev == NULL)
 		return NULL;
 
@@ -1729,6 +1730,7 @@ static int __net_init sit_init_net(struct net *net)
 	sitn->tunnels[3] = sitn->tunnels_r_l;
 
 	sitn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "sit0",
+					   NET_NAME_UNKNOWN,
 					   ipip6_tunnel_setup);
 	if (!sitn->fb_tunnel_dev) {
 		err = -ENOMEM;
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 365b895..9e0d909 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -293,7 +293,8 @@ static void irda_device_setup(struct net_device *dev)
  */
 struct net_device *alloc_irdadev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "irda%d", irda_device_setup);
+	return alloc_netdev(sizeof_priv, "irda%d", NET_NAME_UNKNOWN,
+			    irda_device_setup);
 }
 EXPORT_SYMBOL(alloc_irdadev);
 
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index ffcec22..dc13f1a 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -96,7 +96,7 @@ static void irlan_eth_setup(struct net_device *dev)
  */
 struct net_device *alloc_irlandev(const char *name)
 {
-	return alloc_netdev(sizeof(struct irlan_cb), name,
+	return alloc_netdev(sizeof(struct irlan_cb), name, NET_NAME_UNKNOWN,
 			    irlan_eth_setup);
 }
 
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 76125c5..edb78e6 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -246,7 +246,8 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 		goto out;
 	}
 
-	dev = alloc_netdev(sizeof(*priv), name, l2tp_eth_dev_setup);
+	dev = alloc_netdev(sizeof(*priv), name, NET_NAME_UNKNOWN,
+			   l2tp_eth_dev_setup);
 	if (!dev) {
 		rc = -ENOMEM;
 		goto out_del_session;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 388b863..036eebf 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1623,9 +1623,9 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 		if (local->hw.queues >= IEEE80211_NUM_ACS)
 			txqs = IEEE80211_NUM_ACS;
 
-		ndev = alloc_netdev_mqs(sizeof(*sdata) +
-					local->hw.vif_data_size,
-					name, ieee80211_if_setup, txqs, 1);
+		ndev = alloc_netdev_mqs(sizeof(*sdata) + local->hw.vif_data_size,
+					name, NET_NAME_UNKNOWN,
+					ieee80211_if_setup, txqs, 1);
 		if (!ndev)
 			return -ENOMEM;
 		dev_net_set(ndev, wiphy_net(local->hw.wiphy));
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 2cf66d8..1a79072 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -166,11 +166,13 @@ mac802154_add_iface(struct wpan_phy *phy, const char *name, int type)
 	switch (type) {
 	case IEEE802154_DEV_MONITOR:
 		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
-				   name, mac802154_monitor_setup);
+				   name, NET_NAME_UNKNOWN,
+				   mac802154_monitor_setup);
 		break;
 	case IEEE802154_DEV_WPAN:
 		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
-				   name, mac802154_wpan_setup);
+				   name, NET_NAME_UNKNOWN,
+				   mac802154_wpan_setup);
 		break;
 	default:
 		dev = NULL;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ede50d1..71cf1bf 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1418,7 +1418,7 @@ static int __init nr_proto_init(void)
 		struct net_device *dev;
 
 		sprintf(name, "nr%d", i);
-		dev = alloc_netdev(0, name, nr_setup);
+		dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, nr_setup);
 		if (!dev) {
 			printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device structure\n");
 			goto fail;
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 789af92..0a5e077 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -159,7 +159,8 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 	netdev_vport = netdev_vport_priv(vport);
 
 	netdev_vport->dev = alloc_netdev(sizeof(struct internal_dev),
-					 parms->name, do_setup);
+					 parms->name, NET_NAME_UNKNOWN,
+					 do_setup);
 	if (!netdev_vport->dev) {
 		err = -ENOMEM;
 		goto error_free_vport;
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 66dc65e..e9a83a6 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -267,7 +267,7 @@ int gprs_attach(struct sock *sk)
 		return -EINVAL; /* need packet boundaries */
 
 	/* Create net device */
-	dev = alloc_netdev(sizeof(*gp), ifname, gprs_setup);
+	dev = alloc_netdev(sizeof(*gp), ifname, NET_NAME_UNKNOWN, gprs_setup);
 	if (!dev)
 		return -ENOMEM;
 	gp = netdev_priv(dev);
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8451c8c..a85c1a0 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1538,7 +1538,7 @@ static int __init rose_proto_init(void)
 		char name[IFNAMSIZ];
 
 		sprintf(name, "rose%d", i);
-		dev = alloc_netdev(0, name, rose_setup);
+		dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, rose_setup);
 		if (!dev) {
 			printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate memory\n");
 			rc = -ENOMEM;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 4741671..bd33793 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -485,8 +485,8 @@ static int __init teql_init(void)
 		struct net_device *dev;
 		struct teql_master *master;
 
-		dev = alloc_netdev(sizeof(struct teql_master),
-				  "teql%d", teql_master_setup);
+		dev = alloc_netdev(sizeof(struct teql_master), "teql%d",
+				   NET_NAME_UNKNOWN, teql_master_setup);
 		if (!dev) {
 			err = -ENOMEM;
 			break;
-- 
1.9.3
