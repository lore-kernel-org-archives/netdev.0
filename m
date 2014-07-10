From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 04/33] net: set name assign type for names assigned using a static template
Date: Thu, 10 Jul 2014 10:17:09 +0200
Message-ID: <1404980258-30853-5-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This covers the trivial case:

alloc_netdev(_, "foo%d", NET_NAME_ENUM, _);

Signed-off-by: Tom Gundersen <teg@jklm.no>
---
 drivers/firewire/net.c                    | 2 +-
 drivers/hsi/clients/ssi_protocol.c        | 3 ++-
 drivers/net/caif/caif_spi.c               | 4 ++--
 drivers/net/can/dev.c                     | 2 +-
 drivers/net/ethernet/8390/lib8390.c       | 2 +-
 drivers/net/hamradio/6pack.c              | 2 +-
 drivers/net/hamradio/baycom_epp.c         | 2 +-
 drivers/net/hamradio/bpqether.c           | 4 ++--
 drivers/net/hamradio/mkiss.c              | 2 +-
 drivers/net/ieee802154/fakehard.c         | 2 +-
 drivers/net/ifb.c                         | 4 ++--
 drivers/net/usb/cdc-phonet.c              | 3 ++-
 drivers/net/usb/hso.c                     | 2 +-
 drivers/net/wan/dlci.c                    | 2 +-
 drivers/net/wan/hdlc.c                    | 4 ++--
 drivers/net/wan/hdlc_fr.c                 | 5 ++---
 drivers/net/wan/lapbether.c               | 4 ++--
 drivers/net/wan/sbni.c                    | 4 ++--
 drivers/net/wimax/i2400m/usb.c            | 4 ++--
 drivers/net/wireless/airo.c               | 2 +-
 drivers/net/wireless/ath/wil6210/netdev.c | 2 +-
 drivers/net/wireless/libertas/main.c      | 2 +-
 drivers/net/wireless/libertas/mesh.c      | 2 +-
 drivers/net/wireless/mac80211_hwsim.c     | 3 +--
 drivers/s390/net/claw.c                   | 2 +-
 drivers/s390/net/netiucv.c                | 2 +-
 drivers/s390/net/qeth_l2_main.c           | 4 ++--
 drivers/s390/net/qeth_l3_main.c           | 2 +-
 drivers/staging/cxt1e1/linux.c            | 2 +-
 drivers/staging/gdm72xx/gdm_wimax.c       | 3 +--
 drivers/staging/wlan-ng/p80211netdev.c    | 2 +-
 drivers/usb/gadget/f_phonet.c             | 2 +-
 net/802/fc.c                              | 2 +-
 net/802/fddi.c                            | 3 +--
 net/802/hippi.c                           | 3 +--
 net/appletalk/dev.c                       | 3 +--
 net/bluetooth/6lowpan.c                   | 2 +-
 net/ethernet/eth.c                        | 2 +-
 net/irda/irda_device.c                    | 2 +-
 net/phonet/pep-gprs.c                     | 3 ++-
 net/sched/sch_teql.c                      | 5 +++--
 41 files changed, 55 insertions(+), 57 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2c68da1..158266c 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1460,7 +1460,7 @@ static int fwnet_probe(struct fw_unit *unit,
 		goto have_dev;
 	}
 
-	net = alloc_netdev(sizeof(*dev), "firewire%d", NET_NAME_UNKNOWN,
+	net = alloc_netdev(sizeof(*dev), "firewire%d", NET_NAME_ENUM,
 			   fwnet_init_dev);
 	if (net == NULL) {
 		mutex_unlock(&fwnet_device_mutex);
diff --git a/drivers/hsi/clients/ssi_protocol.c b/drivers/hsi/clients/ssi_protocol.c
index 737fa2e..a0d3e99 100644
--- a/drivers/hsi/clients/ssi_protocol.c
+++ b/drivers/hsi/clients/ssi_protocol.c
@@ -1069,6 +1069,7 @@ static void ssip_pn_setup(struct net_device *dev)
 static int ssi_protocol_probe(struct device *dev)
 {
 	static const char ifname[] = "phonet%d";
+	unsigned char name_assign_type = NET_NAME_ENUM;
 	struct hsi_client *cl = to_hsi_client(dev);
 	struct ssi_protocol *ssi;
 	int err;
@@ -1115,7 +1116,7 @@ static int ssi_protocol_probe(struct device *dev)
 		goto out;
 	}
 
-	ssi->netdev = alloc_netdev(0, ifname, NET_NAME_UNKNOWN, ssip_pn_setup);
+	ssi->netdev = alloc_netdev(0, ifname, name_assign_type, ssip_pn_setup);
 	if (!ssi->netdev) {
 		dev_err(dev, "No memory for netdev\n");
 		err = -ENOMEM;
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 72ea9ff..cd5121e 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -730,8 +730,8 @@ int cfspi_spi_probe(struct platform_device *pdev)
 	int res;
 	dev = (struct cfspi_dev *)pdev->dev.platform_data;
 
-	ndev = alloc_netdev(sizeof(struct cfspi), "cfspi%d",
-			    NET_NAME_UNKNOWN, cfspi_setup);
+	ndev = alloc_netdev(sizeof(struct cfspi),
+			"cfspi%d", NET_NAME_ENUM, cfspi_setup);
 	if (!dev)
 		return -ENODEV;
 
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 9f91fcb..2441348 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -565,7 +565,7 @@ struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max)
 	else
 		size = sizeof_priv;
 
-	dev = alloc_netdev(size, "can%d", NET_NAME_UNKNOWN, can_setup);
+	dev = alloc_netdev(size, "can%d", NET_NAME_ENUM, can_setup);
 	if (!dev)
 		return NULL;
 
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index b96e885..96e9610 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -986,7 +986,7 @@ static void ethdev_setup(struct net_device *dev)
 static struct net_device *____alloc_ei_netdev(int size)
 {
 	return alloc_netdev(sizeof(struct ei_device) + size, "eth%d",
-			    NET_NAME_UNKNOWN, ethdev_setup);
+			    NET_NAME_ENUM, ethdev_setup);
 }
 
 
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index c3c4051..7d38828 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -596,7 +596,7 @@ static int sixpack_open(struct tty_struct *tty)
 	if (tty->ops->write == NULL)
 		return -EOPNOTSUPP;
 
-	dev = alloc_netdev(sizeof(struct sixpack), "sp%d", NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(struct sixpack), "sp%d", NET_NAME_ENUM,
 			   sp_setup);
 	if (!dev) {
 		err = -ENOMEM;
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index a98c153..4d3667e 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -1206,7 +1206,7 @@ static int __init init_baycomepp(void)
 		struct net_device *dev;
 		
 		dev = alloc_netdev(sizeof(struct baycom_state), "bce%d",
-				   NET_NAME_UNKNOWN, baycom_epp_dev_setup);
+				   NET_NAME_ENUM, baycom_epp_dev_setup);
 
 		if (!dev) {
 			printk(KERN_WARNING "bce%d : out of memory\n", i);
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index c2894e4..c90e7df 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -501,8 +501,8 @@ static int bpq_new_device(struct net_device *edev)
 	struct net_device *ndev;
 	struct bpqdev *bpq;
 
-	ndev = alloc_netdev(sizeof(struct bpqdev), "bpq%d", NET_NAME_UNKNOWN,
-			    bpq_setup);
+	ndev = alloc_netdev(sizeof(struct bpqdev), "bpq%d",
+			    NET_NAME_ENUM, bpq_setup);
 	if (!ndev)
 		return -ENOMEM;
 
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index f990bb1c..c216b0a 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -734,7 +734,7 @@ static int mkiss_open(struct tty_struct *tty)
 	if (tty->ops->write == NULL)
 		return -EOPNOTSUPP;
 
-	dev = alloc_netdev(sizeof(struct mkiss), "ax%d", NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(struct mkiss), "ax%d", NET_NAME_ENUM,
 			   ax_setup);
 	if (!dev) {
 		err = -ENOMEM;
diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index 9ce854f..8f9b1dd 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -344,7 +344,7 @@ static int ieee802154fake_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	dev = alloc_netdev(sizeof(struct fakehard_priv), "hardwpan%d",
-			   NET_NAME_UNKNOWN, ieee802154_fake_setup);
+			   NET_NAME_ENUM, ieee802154_fake_setup);
 	if (!dev) {
 		wpan_phy_free(phy);
 		return -ENOMEM;
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index d2d4a3d..da88b3c 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -269,8 +269,8 @@ static int __init ifb_init_one(int index)
 	struct ifb_private *dp;
 	int err;
 
-	dev_ifb = alloc_netdev(sizeof(struct ifb_private), "ifb%d",
-			       NET_NAME_UNKNOWN, ifb_setup);
+	dev_ifb = alloc_netdev(sizeof(struct ifb_private),
+			       "ifb%d", NET_NAME_ENUM, ifb_setup);
 
 	if (!dev_ifb)
 		return -ENOMEM;
diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 2ec1500..2495667 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -331,6 +331,7 @@ static struct usb_driver usbpn_driver;
 static int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
 	static const char ifname[] = "usbpn%d";
+	unsigned char name_assign_type = NET_NAME_ENUM;
 	const struct usb_cdc_union_desc *union_header = NULL;
 	const struct usb_host_interface *data_desc;
 	struct usb_interface *data_intf;
@@ -387,7 +388,7 @@ static int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *i
 		return -EINVAL;
 
 	dev = alloc_netdev(sizeof(*pnd) + sizeof(pnd->urbs[0]) * rxq_size,
-			   ifname, NET_NAME_UNKNOWN, usbpn_setup);
+			   ifname, name_assign_type, usbpn_setup);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 50b36b2..cf4691e 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2520,7 +2520,7 @@ static struct hso_device *hso_create_net_device(struct usb_interface *interface,
 
 	/* allocate our network device, then we can put in our private data */
 	/* call hso_net_init to do the basic initialization */
-	net = alloc_netdev(sizeof(struct hso_net), "hso%d", NET_NAME_UNKNOWN,
+	net = alloc_netdev(sizeof(struct hso_net), "hso%d", NET_NAME_ENUM,
 			   hso_net_init);
 	if (!net) {
 		dev_err(&interface->dev, "Unable to create ethernet device\n");
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index a463613..56e6622 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -328,7 +328,7 @@ static int dlci_add(struct dlci_add *dlci)
 
 	/* create device name */
 	master = alloc_netdev(sizeof(struct dlci_local), "dlci%d",
-			      NET_NAME_UNKNOWN, dlci_setup);
+			      NET_NAME_ENUM, dlci_setup);
 	if (!master) {
 		err = -ENOMEM;
 		goto err1;
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 51f6cee..6ff23ec 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -256,8 +256,8 @@ static void hdlc_setup(struct net_device *dev)
 struct net_device *alloc_hdlcdev(void *priv)
 {
 	struct net_device *dev;
-	dev = alloc_netdev(sizeof(struct hdlc_device), "hdlc%d",
-			   NET_NAME_UNKNOWN, hdlc_setup);
+	dev = alloc_netdev(sizeof(struct hdlc_device), "hdlc%d", NET_NAME_ENUM,
+			   hdlc_setup);
 	if (dev)
 		dev_to_hdlc(dev)->priv = priv;
 	return dev;
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 7cc64ea..5925ac8 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1075,11 +1075,10 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	used = pvc_is_used(pvc);
 
 	if (type == ARPHRD_ETHER) {
-		dev = alloc_netdev(0, "pvceth%d", NET_NAME_UNKNOWN,
-				   ether_setup);
+		dev = alloc_netdev(0, "pvceth%d", NET_NAME_ENUM, ether_setup);
 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	} else
-		dev = alloc_netdev(0, "pvc%d", NET_NAME_UNKNOWN, pvc_setup);
+		dev = alloc_netdev(0, "pvc%d", NET_NAME_ENUM, pvc_setup);
 
 	if (!dev) {
 		netdev_warn(frad, "Memory squeeze on fr_pvc()\n");
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 2f5eda8..a09f08f 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -325,8 +325,8 @@ static int lapbeth_new_device(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	ndev = alloc_netdev(sizeof(*lapbeth), "lapb%d", NET_NAME_UNKNOWN,
-			    lapbeth_setup);
+	ndev = alloc_netdev(sizeof(*lapbeth), "lapb%d", NET_NAME_ENUM,
+			   lapbeth_setup);
 	if (!ndev)
 		goto out;
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 758c4ba..a9b7e9a 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -1478,8 +1478,8 @@ int __init init_module( void )
 	int err;
 
 	while( num < SBNI_MAX_NUM_CARDS ) {
-		dev = alloc_netdev(sizeof(struct net_local), "sbni%d",
-				   NET_NAME_UNKNOWN, sbni_devsetup);
+		dev = alloc_netdev(sizeof(struct net_local),
+				   "sbni%d", NET_NAME_ENUM, sbni_devsetup);
 		if( !dev)
 			break;
 
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index e7f5910..aa51b49 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -472,8 +472,8 @@ int i2400mu_probe(struct usb_interface *iface,
 
 	/* Allocate instance [calls i2400m_netdev_setup() on it]. */
 	result = -ENOMEM;
-	net_dev = alloc_netdev(sizeof(*i2400mu), "wmx%d", NET_NAME_UNKNOWN,
-			       i2400mu_netdev_setup);
+	net_dev = alloc_netdev(sizeof(*i2400mu), "wmx%d",
+			       NET_NAME_ENUM, i2400mu_netdev_setup);
 	if (net_dev == NULL) {
 		dev_err(dev, "no memory for network device instance\n");
 		goto error_alloc_netdev;
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 29d8873..8a93e78 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2685,7 +2685,7 @@ static struct net_device *init_wifidev(struct airo_info *ai,
 					struct net_device *ethdev)
 {
 	int err;
-	struct net_device *dev = alloc_netdev(0, "wifi%d", NET_NAME_UNKNOWN,
+	struct net_device *dev = alloc_netdev(0, "wifi%d", NET_NAME_ENUM,
 					      wifi_setup);
 	if (!dev)
 		return NULL;
diff --git a/drivers/net/wireless/ath/wil6210/netdev.c b/drivers/net/wireless/ath/wil6210/netdev.c
index 7afce6e..f837d01 100644
--- a/drivers/net/wireless/ath/wil6210/netdev.c
+++ b/drivers/net/wireless/ath/wil6210/netdev.c
@@ -132,7 +132,7 @@ void *wil_if_alloc(struct device *dev, void __iomem *csr)
 	ch = wdev->wiphy->bands[IEEE80211_BAND_60GHZ]->channels;
 	cfg80211_chandef_create(&wdev->preset_chandef, ch, NL80211_CHAN_NO_HT);
 
-	ndev = alloc_netdev(0, "wlan%d", NET_NAME_UNKNOWN, ether_setup);
+	ndev = alloc_netdev(0, "wlan%d", NET_NAME_ENUM, ether_setup);
 	if (!ndev) {
 		dev_err(dev, "alloc_netdev_mqs failed\n");
 		rc = -ENOMEM;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 569b64e..ff78e91 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -981,7 +981,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
 		goto err_wdev;
 	}
 
-	dev = alloc_netdev(0, "wlan%d", NET_NAME_UNKNOWN, ether_setup);
+	dev = alloc_netdev(0, "wlan%d", NET_NAME_ENUM, ether_setup);
 	if (!dev) {
 		dev_err(dmdev, "no memory for network device instance\n");
 		goto err_adapter;
diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
index 01a67f6..8007ac4 100644
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -1000,7 +1000,7 @@ static int lbs_add_mesh(struct lbs_private *priv)
 		goto done;
 	}
 
-	mesh_dev = alloc_netdev(0, "msh%d", NET_NAME_UNKNOWN, ether_setup);
+	mesh_dev = alloc_netdev(0, "msh%d", NET_NAME_ENUM, ether_setup);
 	if (!mesh_dev) {
 		lbs_deb_mesh("init mshX device failed\n");
 		ret = -ENOMEM;
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index a000b22..916799f 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2679,8 +2679,7 @@ static int __init init_mac80211_hwsim(void)
 			goto out_free_radios;
 	}
 
-	hwsim_mon = alloc_netdev(0, "hwsim%d", NET_NAME_UNKNOWN,
-				 hwsim_mon_setup);
+	hwsim_mon = alloc_netdev(0, "hwsim%d", NET_NAME_ENUM, hwsim_mon_setup);
 	if (hwsim_mon == NULL) {
 		err = -ENOMEM;
 		goto out_free_radios;
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index fbc6701..2041966 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -2915,7 +2915,7 @@ claw_new_device(struct ccwgroup_device *cgdev)
 			"failed with error code %d\n", ret);
 		goto out;
 	}
-	dev = alloc_netdev(0, "claw%d", NET_NAME_UNKNOWN, claw_init_netdevice);
+	dev = alloc_netdev(0, "claw%d", NET_NAME_ENUM, claw_init_netdevice);
 	if (!dev) {
 		dev_warn(&cgdev->dev,
 			"Activating the CLAW device failed\n");
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 0a87809..8c07aa3 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -2015,7 +2015,7 @@ static struct net_device *netiucv_init_netdevice(char *username, char *userdata)
 	struct net_device *dev;
 
 	dev = alloc_netdev(sizeof(struct netiucv_priv), "iucv%d",
-			   NET_NAME_UNKNOWN, netiucv_setup_netdevice);
+			   NET_NAME_ENUM, netiucv_setup_netdevice);
 	if (!dev)
 		return NULL;
 	rtnl_lock();
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index c2679bf..b2d7f9d 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -952,11 +952,11 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 {
 	switch (card->info.type) {
 	case QETH_CARD_TYPE_IQD:
-		card->dev = alloc_netdev(0, "hsi%d", NET_NAME_UNKNOWN,
+		card->dev = alloc_netdev(0, "hsi%d", NET_NAME_ENUM,
 					 ether_setup);
 		break;
 	case QETH_CARD_TYPE_OSN:
-		card->dev = alloc_netdev(0, "osn%d", NET_NAME_UNKNOWN,
+		card->dev = alloc_netdev(0, "osn%d", NET_NAME_ENUM,
 					 ether_setup);
 		card->dev->flags |= IFF_NOARP;
 		break;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index f8427a2..e82a555 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3287,7 +3287,7 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 			}
 		}
 	} else if (card->info.type == QETH_CARD_TYPE_IQD) {
-		card->dev = alloc_netdev(0, "hsi%d", NET_NAME_UNKNOWN,
+		card->dev = alloc_netdev(0, "hsi%d", NET_NAME_ENUM,
 					 ether_setup);
 		if (!card->dev)
 			return -ENODEV;
diff --git a/drivers/staging/cxt1e1/linux.c b/drivers/staging/cxt1e1/linux.c
index 85d776b..35da3af 100644
--- a/drivers/staging/cxt1e1/linux.c
+++ b/drivers/staging/cxt1e1/linux.c
@@ -917,7 +917,7 @@ c4_add_dev(hdw_info_t *hi, int brdno, unsigned long f0, unsigned long f1,
 	struct net_device *ndev;
 	ci_t       *ci;
 
-	ndev = alloc_netdev(sizeof(ci_t), SBE_IFACETMPL, NET_NAME_UNKNOWN,
+	ndev = alloc_netdev(sizeof(ci_t), SBE_IFACETMPL, NET_NAME_ENUM,
 			    c4_setup);
 	if (!ndev) {
 		pr_warning("%s: no memory for struct net_device !\n",
diff --git a/drivers/staging/gdm72xx/gdm_wimax.c b/drivers/staging/gdm72xx/gdm_wimax.c
index a9a6fc5..d381d5b 100644
--- a/drivers/staging/gdm72xx/gdm_wimax.c
+++ b/drivers/staging/gdm72xx/gdm_wimax.c
@@ -886,8 +886,7 @@ int register_wimax_device(struct phy_dev *phy_dev, struct device *pdev)
 	struct net_device *dev;
 	int ret;
 
-	dev = alloc_netdev(sizeof(*nic), "wm%d", NET_NAME_UNKNOWN,
-			   ether_setup);
+	dev = alloc_netdev(sizeof(*nic), "wm%d", NET_NAME_ENUM, ether_setup);
 
 	if (dev == NULL) {
 		pr_err("alloc_etherdev failed\n");
diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index 6c78f91..a03a0c6 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -769,7 +769,7 @@ int wlan_setup(wlandevice_t *wlandev, struct device *physdev)
 
 	/* Allocate and initialize the struct device */
 	netdev = alloc_netdev(sizeof(struct wireless_dev), "wlan%d",
-			      NET_NAME_UNKNOWN, ether_setup);
+			      NET_NAME_ENUM, ether_setup);
 	if (netdev == NULL) {
 		dev_err(physdev, "Failed to alloc netdev.\n");
 		wlan_free_wiphy(wiphy);
diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phonet.c
index b9cfc15..6aa6dfa 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -721,7 +721,7 @@ struct net_device *gphonet_setup_default(void)
 	struct phonet_port *port;
 
 	/* Create net device */
-	dev = alloc_netdev(sizeof(*port), "upnlink%d", NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(*port), "upnlink%d", NET_NAME_ENUM,
 			   pn_net_setup);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
diff --git a/net/802/fc.c b/net/802/fc.c
index 7c174b6..de923d9 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -126,6 +126,6 @@ static void fc_setup(struct net_device *dev)
  */
 struct net_device *alloc_fcdev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "fc%d", NET_NAME_UNKNOWN, fc_setup);
+	return alloc_netdev(sizeof_priv, "fc%d", NET_NAME_ENUM, fc_setup);
 }
 EXPORT_SYMBOL(alloc_fcdev);
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 59e7346..d12f238 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -207,8 +207,7 @@ static void fddi_setup(struct net_device *dev)
  */
 struct net_device *alloc_fddidev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "fddi%d", NET_NAME_UNKNOWN,
-			    fddi_setup);
+	return alloc_netdev(sizeof_priv, "fddi%d", NET_NAME_ENUM, fddi_setup);
 }
 EXPORT_SYMBOL(alloc_fddidev);
 
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 2e03f82..33a6d2e 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -228,8 +228,7 @@ static void hippi_setup(struct net_device *dev)
 
 struct net_device *alloc_hippi_dev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "hip%d", NET_NAME_UNKNOWN,
-			    hippi_setup);
+	return alloc_netdev(sizeof_priv, "hip%d", NET_NAME_ENUM, hippi_setup);
 }
 
 EXPORT_SYMBOL(alloc_hippi_dev);
diff --git a/net/appletalk/dev.c b/net/appletalk/dev.c
index e4158b8..f604588 100644
--- a/net/appletalk/dev.c
+++ b/net/appletalk/dev.c
@@ -39,7 +39,6 @@ static void ltalk_setup(struct net_device *dev)
 
 struct net_device *alloc_ltalkdev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "lt%d", NET_NAME_UNKNOWN,
-			    ltalk_setup);
+	return alloc_netdev(sizeof_priv, "lt%d", NET_NAME_ENUM, ltalk_setup);
 }
 EXPORT_SYMBOL(alloc_ltalkdev);
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index faf96fc..50ecf95 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -733,7 +733,7 @@ int bt_6lowpan_add_conn(struct l2cap_conn *conn)
 		return add_peer_conn(conn, dev);
 
 	netdev = alloc_netdev(sizeof(*dev), IFACE_NAME_TEMPLATE,
-			      NET_NAME_UNKNOWN, netdev_setup);
+			      NET_NAME_ENUM, netdev_setup);
 	if (!netdev)
 		return -ENOMEM;
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index f405e05..1386afa 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -390,7 +390,7 @@ EXPORT_SYMBOL(ether_setup);
 struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 				      unsigned int rxqs)
 {
-	return alloc_netdev_mqs(sizeof_priv, "eth%d", NET_NAME_UNKNOWN,
+	return alloc_netdev_mqs(sizeof_priv, "eth%d", NET_NAME_ENUM,
 				ether_setup, txqs, rxqs);
 }
 EXPORT_SYMBOL(alloc_etherdev_mqs);
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 9e0d909..c313091 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -293,7 +293,7 @@ static void irda_device_setup(struct net_device *dev)
  */
 struct net_device *alloc_irdadev(int sizeof_priv)
 {
-	return alloc_netdev(sizeof_priv, "irda%d", NET_NAME_UNKNOWN,
+	return alloc_netdev(sizeof_priv, "irda%d", NET_NAME_ENUM,
 			    irda_device_setup);
 }
 EXPORT_SYMBOL(alloc_irdadev);
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index e9a83a6..41b51df 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -259,6 +259,7 @@ static void gprs_setup(struct net_device *dev)
 int gprs_attach(struct sock *sk)
 {
 	static const char ifname[] = "gprs%d";
+	unsigned char name_assign_type = NET_NAME_ENUM;
 	struct gprs_dev *gp;
 	struct net_device *dev;
 	int err;
@@ -267,7 +268,7 @@ int gprs_attach(struct sock *sk)
 		return -EINVAL; /* need packet boundaries */
 
 	/* Create net device */
-	dev = alloc_netdev(sizeof(*gp), ifname, NET_NAME_UNKNOWN, gprs_setup);
+	dev = alloc_netdev(sizeof(*gp), ifname, name_assign_type, gprs_setup);
 	if (!dev)
 		return -ENOMEM;
 	gp = netdev_priv(dev);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index bd33793..b1bfd06 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -485,8 +485,9 @@ static int __init teql_init(void)
 		struct net_device *dev;
 		struct teql_master *master;
 
-		dev = alloc_netdev(sizeof(struct teql_master), "teql%d",
-				   NET_NAME_UNKNOWN, teql_master_setup);
+		dev = alloc_netdev(sizeof(struct teql_master),
+				  "teql%d", NET_NAME_ENUM,
+				  teql_master_setup);
 		if (!dev) {
 			err = -ENOMEM;
 			break;
-- 
1.9.3
