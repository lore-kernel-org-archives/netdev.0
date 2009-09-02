From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/5] netdev: drivers should make ethtool_ops const
Date: Tue, 01 Sep 2009 22:25:01 -0700
Message-ID: <20090902052538.276324751@vyatta.com>
References: <20090902052500.808557262@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Dhananjay Phadke <dhananjay@netxen.com>,
	David Brownell <dbrownell@users.sourceforge.net>
To: David Miller <davem@davemloft.net>,
	Roland Dreier <rolandd@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46832 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755765AbZIBFhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 01:37:43 -0400
Content-Disposition: inline; filename=ethtool-ops-const
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to put ethtool_ops in data, they should be const.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 arch/um/drivers/net_kern.c              |    2 +-
 drivers/firewire/net.c                  |    2 +-
 drivers/ieee1394/eth1394.c              |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c     |    2 +-
 drivers/net/arm/ep93xx_eth.c            |    2 +-
 drivers/net/arm/ixp4xx_eth.c            |    2 +-
 drivers/net/arm/ks8695net.c             |    2 +-
 drivers/net/atl1c/atl1c_ethtool.c       |    2 +-
 drivers/net/atl1e/atl1e_ethtool.c       |    2 +-
 drivers/net/atlx/atl2.c                 |    2 +-
 drivers/net/benet/be.h                  |    2 +-
 drivers/net/benet/be_ethtool.c          |    2 +-
 drivers/net/bfin_mac.c                  |    2 +-
 drivers/net/bnx2x_main.c                |    2 +-
 drivers/net/enic/enic_main.c            |    2 +-
 drivers/net/igb/igb_ethtool.c           |    2 +-
 drivers/net/ipg.c                       |    2 +-
 drivers/net/korina.c                    |    2 +-
 drivers/net/ks8842.c                    |    2 +-
 drivers/net/macb.c                      |    2 +-
 drivers/net/netxen/netxen_nic.h         |    2 +-
 drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
 drivers/net/ps3_gelic_net.c             |    2 +-
 drivers/net/ps3_gelic_wireless.c        |    2 +-
 drivers/net/sfc/ethtool.c               |    2 +-
 drivers/net/tehuti.c                    |    2 +-
 drivers/net/usb/asix.c                  |    4 ++--
 drivers/net/usb/catc.c                  |    2 +-
 drivers/net/usb/dm9601.c                |    2 +-
 drivers/net/usb/hso.c                   |    2 +-
 drivers/net/usb/kaweth.c                |    2 +-
 drivers/net/usb/mcs7830.c               |    2 +-
 drivers/net/usb/pegasus.c               |    2 +-
 drivers/net/usb/rtl8150.c               |    2 +-
 drivers/net/usb/smsc95xx.c              |    2 +-
 drivers/net/usb/usbnet.c                |    2 +-
 drivers/net/veth.c                      |    2 +-
 drivers/net/virtio_net.c                |    2 +-
 drivers/net/wireless/libertas/dev.h     |    2 +-
 drivers/net/wireless/libertas/ethtool.c |    2 +-
 drivers/net/xen-netfront.c              |    4 ++--
 drivers/s390/net/qeth_l2_main.c         |    4 ++--
 drivers/s390/net/qeth_l3_main.c         |    2 +-
 drivers/staging/at76_usb/at76_usb.c     |    2 +-
 drivers/staging/octeon/ethernet-mdio.c  |    2 +-
 drivers/staging/octeon/ethernet-mdio.h  |    2 +-
 drivers/staging/sxg/sxg.h               |    2 +-
 drivers/staging/sxg/sxg_ethtool.c       |    2 +-
 drivers/usb/gadget/u_ether.c            |    2 +-
 49 files changed, 52 insertions(+), 52 deletions(-)

--- a/arch/um/drivers/net_kern.c	2009-09-01 21:23:22.140759558 -0700
+++ b/arch/um/drivers/net_kern.c	2009-09-01 21:24:04.767783955 -0700
@@ -285,7 +285,7 @@ static void uml_net_get_drvinfo(struct n
 	strcpy(info->version, "42");
 }
 
-static struct ethtool_ops uml_net_ethtool_ops = {
+static const struct ethtool_ops uml_net_ethtool_ops = {
 	.get_drvinfo	= uml_net_get_drvinfo,
 	.get_link	= ethtool_op_get_link,
 };
--- a/drivers/firewire/net.c	2009-09-01 21:23:22.192204648 -0700
+++ b/drivers/firewire/net.c	2009-09-01 21:24:12.452795687 -0700
@@ -1342,7 +1342,7 @@ static void fwnet_get_drvinfo(struct net
 	strcpy(info->bus_info, "ieee1394");
 }
 
-static struct ethtool_ops fwnet_ethtool_ops = {
+static const struct ethtool_ops fwnet_ethtool_ops = {
 	.get_drvinfo = fwnet_get_drvinfo,
 };
 
--- a/drivers/ieee1394/eth1394.c	2009-09-01 21:23:22.225179879 -0700
+++ b/drivers/ieee1394/eth1394.c	2009-09-01 21:24:19.511858188 -0700
@@ -173,7 +173,7 @@ static netdev_tx_t ether1394_tx(struct s
 				struct net_device *dev);
 static void ether1394_iso(struct hpsb_iso *iso);
 
-static struct ethtool_ops ethtool_ops;
+static const struct ethtool_ops ethtool_ops;
 
 static int ether1394_write(struct hpsb_host *host, int srcid, int destid,
 			   quadlet_t *data, u64 addr, size_t len, u16 flags);
--- a/drivers/infiniband/hw/nes/nes_nic.c	2009-09-01 21:23:22.274178784 -0700
+++ b/drivers/infiniband/hw/nes/nes_nic.c	2009-09-01 21:24:33.351892895 -0700
@@ -1508,7 +1508,7 @@ static int nes_netdev_set_settings(struc
 }
 
 
-static struct ethtool_ops nes_ethtool_ops = {
+static const struct ethtool_ops nes_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_settings = nes_netdev_get_settings,
 	.set_settings = nes_netdev_set_settings,
--- a/drivers/net/arm/ep93xx_eth.c	2009-09-01 21:23:22.305179810 -0700
+++ b/drivers/net/arm/ep93xx_eth.c	2009-09-01 21:24:39.380961916 -0700
@@ -762,7 +762,7 @@ static u32 ep93xx_get_link(struct net_de
 	return mii_link_ok(&ep->mii);
 }
 
-static struct ethtool_ops ep93xx_ethtool_ops = {
+static const struct ethtool_ops ep93xx_ethtool_ops = {
 	.get_drvinfo		= ep93xx_get_drvinfo,
 	.get_settings		= ep93xx_get_settings,
 	.set_settings		= ep93xx_set_settings,
--- a/drivers/net/arm/ixp4xx_eth.c	2009-09-01 21:23:22.336175120 -0700
+++ b/drivers/net/arm/ixp4xx_eth.c	2009-09-01 21:24:45.928279805 -0700
@@ -802,7 +802,7 @@ static int ixp4xx_nway_reset(struct net_
 	return phy_start_aneg(port->phydev);
 }
 
-static struct ethtool_ops ixp4xx_ethtool_ops = {
+static const struct ethtool_ops ixp4xx_ethtool_ops = {
 	.get_drvinfo = ixp4xx_get_drvinfo,
 	.get_settings = ixp4xx_get_settings,
 	.set_settings = ixp4xx_set_settings,
--- a/drivers/net/arm/ks8695net.c	2009-09-01 21:23:22.367175272 -0700
+++ b/drivers/net/arm/ks8695net.c	2009-09-01 21:24:51.848932190 -0700
@@ -1063,7 +1063,7 @@ ks8695_get_drvinfo(struct net_device *nd
 		sizeof(info->bus_info));
 }
 
-static struct ethtool_ops ks8695_ethtool_ops = {
+static const struct ethtool_ops ks8695_ethtool_ops = {
 	.get_msglevel	= ks8695_get_msglevel,
 	.set_msglevel	= ks8695_set_msglevel,
 	.get_settings	= ks8695_get_settings,
--- a/drivers/net/atl1c/atl1c_ethtool.c	2009-09-01 21:23:22.398179343 -0700
+++ b/drivers/net/atl1c/atl1c_ethtool.c	2009-09-01 21:24:58.264953214 -0700
@@ -294,7 +294,7 @@ static int atl1c_nway_reset(struct net_d
 	return 0;
 }
 
-static struct ethtool_ops atl1c_ethtool_ops = {
+static const struct ethtool_ops atl1c_ethtool_ops = {
 	.get_settings           = atl1c_get_settings,
 	.set_settings           = atl1c_set_settings,
 	.get_drvinfo            = atl1c_get_drvinfo,
--- a/drivers/net/atl1e/atl1e_ethtool.c	2009-09-01 21:23:22.429737472 -0700
+++ b/drivers/net/atl1e/atl1e_ethtool.c	2009-09-01 21:25:06.161739683 -0700
@@ -378,7 +378,7 @@ static int atl1e_nway_reset(struct net_d
 	return 0;
 }
 
-static struct ethtool_ops atl1e_ethtool_ops = {
+static const struct ethtool_ops atl1e_ethtool_ops = {
 	.get_settings           = atl1e_get_settings,
 	.set_settings           = atl1e_set_settings,
 	.get_drvinfo            = atl1e_get_drvinfo,
--- a/drivers/net/atlx/atl2.c	2009-09-01 21:23:22.461737471 -0700
+++ b/drivers/net/atlx/atl2.c	2009-09-01 21:25:29.371737969 -0700
@@ -2094,7 +2094,7 @@ static int atl2_nway_reset(struct net_de
 	return 0;
 }
 
-static struct ethtool_ops atl2_ethtool_ops = {
+static const struct ethtool_ops atl2_ethtool_ops = {
 	.get_settings		= atl2_get_settings,
 	.set_settings		= atl2_set_settings,
 	.get_drvinfo		= atl2_get_drvinfo,
--- a/drivers/net/benet/be.h	2009-09-01 21:23:22.493739757 -0700
+++ b/drivers/net/benet/be.h	2009-09-01 21:25:44.899803221 -0700
@@ -259,7 +259,7 @@ struct be_adapter {
 	bool promiscuous;
 };
 
-extern struct ethtool_ops be_ethtool_ops;
+extern const struct ethtool_ops be_ethtool_ops;
 
 #define drvr_stats(adapter)		(&adapter->stats.drvr_stats)
 
--- a/drivers/net/benet/be_ethtool.c	2009-09-01 21:23:22.524737107 -0700
+++ b/drivers/net/benet/be_ethtool.c	2009-09-01 21:25:53.630800706 -0700
@@ -332,7 +332,7 @@ be_set_pauseparam(struct net_device *net
 	return status;
 }
 
-struct ethtool_ops be_ethtool_ops = {
+const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
 	.get_link = ethtool_op_get_link,
--- a/drivers/net/bfin_mac.c	2009-09-01 21:23:22.555737483 -0700
+++ b/drivers/net/bfin_mac.c	2009-09-01 21:26:00.102325056 -0700
@@ -491,7 +491,7 @@ static void bfin_mac_ethtool_getdrvinfo(
 	strcpy(info->bus_info, dev_name(&dev->dev));
 }
 
-static struct ethtool_ops bfin_mac_ethtool_ops = {
+static const struct ethtool_ops bfin_mac_ethtool_ops = {
 	.get_settings = bfin_mac_ethtool_getsettings,
 	.set_settings = bfin_mac_ethtool_setsettings,
 	.get_link = ethtool_op_get_link,
--- a/drivers/net/bnx2x_main.c	2009-09-01 21:23:22.587737636 -0700
+++ b/drivers/net/bnx2x_main.c	2009-09-01 21:26:08.591759739 -0700
@@ -10606,7 +10606,7 @@ static int bnx2x_phys_id(struct net_devi
 	return 0;
 }
 
-static struct ethtool_ops bnx2x_ethtool_ops = {
+static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_settings		= bnx2x_get_settings,
 	.set_settings		= bnx2x_set_settings,
 	.get_drvinfo		= bnx2x_get_drvinfo,
--- a/drivers/net/enic/enic_main.c	2009-09-01 21:23:22.618737189 -0700
+++ b/drivers/net/enic/enic_main.c	2009-09-01 21:26:14.917742055 -0700
@@ -256,7 +256,7 @@ static void enic_set_msglevel(struct net
 	enic->msg_enable = value;
 }
 
-static struct ethtool_ops enic_ethtool_ops = {
+static const struct ethtool_ops enic_ethtool_ops = {
 	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
 	.get_msglevel = enic_get_msglevel,
--- a/drivers/net/igb/igb_ethtool.c	2009-09-01 21:23:22.650737465 -0700
+++ b/drivers/net/igb/igb_ethtool.c	2009-09-01 21:26:20.874754655 -0700
@@ -2016,7 +2016,7 @@ static void igb_get_strings(struct net_d
 	}
 }
 
-static struct ethtool_ops igb_ethtool_ops = {
+static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
 	.get_drvinfo            = igb_get_drvinfo,
--- a/drivers/net/ipg.c	2009-09-01 21:23:22.713737071 -0700
+++ b/drivers/net/ipg.c	2009-09-01 21:26:30.551740998 -0700
@@ -2186,7 +2186,7 @@ static int ipg_nway_reset(struct net_dev
 	return rc;
 }
 
-static struct ethtool_ops ipg_ethtool_ops = {
+static const struct ethtool_ops ipg_ethtool_ops = {
 	.get_settings = ipg_get_settings,
 	.set_settings = ipg_set_settings,
 	.nway_reset   = ipg_nway_reset,
--- a/drivers/net/korina.c	2009-09-01 21:23:22.745739152 -0700
+++ b/drivers/net/korina.c	2009-09-01 21:26:36.337830745 -0700
@@ -743,7 +743,7 @@ static u32 netdev_get_link(struct net_de
 	return mii_link_ok(&lp->mii_if);
 }
 
-static struct ethtool_ops netdev_ethtool_ops = {
+static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo            = netdev_get_drvinfo,
 	.get_settings           = netdev_get_settings,
 	.set_settings           = netdev_set_settings,
--- a/drivers/net/ks8842.c	2009-09-01 21:23:22.776738076 -0700
+++ b/drivers/net/ks8842.c	2009-09-01 21:26:42.541748592 -0700
@@ -619,7 +619,7 @@ static const struct net_device_ops ks884
 	.ndo_validate_addr	= eth_validate_addr
 };
 
-static struct ethtool_ops ks8842_ethtool_ops = {
+static const struct ethtool_ops ks8842_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 };
 
--- a/drivers/net/macb.c	2009-09-01 21:23:22.812112323 -0700
+++ b/drivers/net/macb.c	2009-09-01 21:26:47.647878323 -0700
@@ -1079,7 +1079,7 @@ static void macb_get_drvinfo(struct net_
 	strcpy(info->bus_info, dev_name(&bp->pdev->dev));
 }
 
-static struct ethtool_ops macb_ethtool_ops = {
+static const struct ethtool_ops macb_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
 	.get_drvinfo		= macb_get_drvinfo,
--- a/drivers/net/netxen/netxen_nic.h	2009-09-01 21:23:22.844098830 -0700
+++ b/drivers/net/netxen/netxen_nic.h	2009-09-01 21:26:54.259228132 -0700
@@ -1410,6 +1410,6 @@ extern void netxen_change_ringparam(stru
 extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
 				int *valp);
 
-extern struct ethtool_ops netxen_nic_ethtool_ops;
+extern const struct ethtool_ops netxen_nic_ethtool_ops;
 
 #endif				/* __NETXEN_NIC_H_ */
--- a/drivers/net/netxen/netxen_nic_ethtool.c	2009-09-01 21:23:22.877777568 -0700
+++ b/drivers/net/netxen/netxen_nic_ethtool.c	2009-09-01 21:27:01.074946492 -0700
@@ -963,7 +963,7 @@ static int netxen_nic_set_flags(struct n
 	return 0;
 }
 
-struct ethtool_ops netxen_nic_ethtool_ops = {
+const struct ethtool_ops netxen_nic_ethtool_ops = {
 	.get_settings = netxen_nic_get_settings,
 	.set_settings = netxen_nic_set_settings,
 	.get_drvinfo = netxen_nic_get_drvinfo,
--- a/drivers/net/ps3_gelic_net.c	2009-09-01 21:23:22.909740667 -0700
+++ b/drivers/net/ps3_gelic_net.c	2009-09-01 21:27:08.779740619 -0700
@@ -1346,7 +1346,7 @@ done:
 	return status;
 }
 
-static struct ethtool_ops gelic_ether_ethtool_ops = {
+static const struct ethtool_ops gelic_ether_ethtool_ops = {
 	.get_drvinfo	= gelic_net_get_drvinfo,
 	.get_settings	= gelic_ether_get_settings,
 	.get_link	= ethtool_op_get_link,
--- a/drivers/net/ps3_gelic_wireless.c	2009-09-01 21:23:22.943207129 -0700
+++ b/drivers/net/ps3_gelic_wireless.c	2009-09-01 21:27:22.891080433 -0700
@@ -2714,7 +2714,7 @@ static const struct net_device_ops gelic
 #endif
 };
 
-static struct ethtool_ops gelic_wl_ethtool_ops = {
+static const struct ethtool_ops gelic_wl_ethtool_ops = {
 	.get_drvinfo	= gelic_net_get_drvinfo,
 	.get_link	= gelic_wl_get_link,
 	.get_tx_csum	= ethtool_op_get_tx_csum,
--- a/drivers/net/sfc/ethtool.c	2009-09-01 21:23:22.975775116 -0700
+++ b/drivers/net/sfc/ethtool.c	2009-09-01 21:27:31.123840332 -0700
@@ -731,7 +731,7 @@ static void efx_ethtool_get_pauseparam(s
 }
 
 
-struct ethtool_ops efx_ethtool_ops = {
+const struct ethtool_ops efx_ethtool_ops = {
 	.get_settings		= efx_ethtool_get_settings,
 	.set_settings		= efx_ethtool_set_settings,
 	.get_drvinfo		= efx_ethtool_get_drvinfo,
--- a/drivers/net/tehuti.c	2009-09-01 21:23:23.042174817 -0700
+++ b/drivers/net/tehuti.c	2009-09-01 21:27:52.563962512 -0700
@@ -2428,7 +2428,7 @@ static void bdx_get_ethtool_stats(struct
  */
 static void bdx_ethtool_ops(struct net_device *netdev)
 {
-	static struct ethtool_ops bdx_ethtool_ops = {
+	static const struct ethtool_ops bdx_ethtool_ops = {
 		.get_settings = bdx_get_settings,
 		.get_drvinfo = bdx_get_drvinfo,
 		.get_link = ethtool_op_get_link,
--- a/drivers/net/usb/asix.c	2009-09-01 21:23:23.075778923 -0700
+++ b/drivers/net/usb/asix.c	2009-09-01 21:28:10.900360956 -0700
@@ -731,7 +731,7 @@ static int asix_ioctl (struct net_device
 /* We need to override some ethtool_ops so we require our
    own structure so we don't interfere with other usbnet
    devices that may be connected at the same time. */
-static struct ethtool_ops ax88172_ethtool_ops = {
+static const struct ethtool_ops ax88172_ethtool_ops = {
 	.get_drvinfo		= asix_get_drvinfo,
 	.get_link		= asix_get_link,
 	.get_msglevel		= usbnet_get_msglevel,
@@ -873,7 +873,7 @@ out:
 	return ret;
 }
 
-static struct ethtool_ops ax88772_ethtool_ops = {
+static const struct ethtool_ops ax88772_ethtool_ops = {
 	.get_drvinfo		= asix_get_drvinfo,
 	.get_link		= asix_get_link,
 	.get_msglevel		= usbnet_get_msglevel,
--- a/drivers/net/usb/catc.c	2009-09-01 21:23:23.142740822 -0700
+++ b/drivers/net/usb/catc.c	2009-09-01 21:28:23.187998866 -0700
@@ -698,7 +698,7 @@ static int catc_get_settings(struct net_
 	return 0;
 }
 
-static struct ethtool_ops ops = {
+static const struct ethtool_ops ops = {
 	.get_drvinfo = catc_get_drvinfo,
 	.get_settings = catc_get_settings,
 	.get_link = ethtool_op_get_link
--- a/drivers/net/usb/dm9601.c	2009-09-01 21:23:23.174779035 -0700
+++ b/drivers/net/usb/dm9601.c	2009-09-01 21:28:27.970768780 -0700
@@ -356,7 +356,7 @@ static int dm9601_ioctl(struct net_devic
 	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
 }
 
-static struct ethtool_ops dm9601_ethtool_ops = {
+static const struct ethtool_ops dm9601_ethtool_ops = {
 	.get_drvinfo	= dm9601_get_drvinfo,
 	.get_link	= dm9601_get_link,
 	.get_msglevel	= usbnet_get_msglevel,
--- a/drivers/net/usb/hso.c	2009-09-01 21:23:23.206924285 -0700
+++ b/drivers/net/usb/hso.c	2009-09-01 21:28:32.857738210 -0700
@@ -829,7 +829,7 @@ static void hso_get_drvinfo(struct net_d
 	usb_make_path(odev->parent->usb, info->bus_info, sizeof info->bus_info);
 }
 
-static struct ethtool_ops ops = {
+static const struct ethtool_ops ops = {
 	.get_drvinfo = hso_get_drvinfo,
 	.get_link = ethtool_op_get_link
 };
--- a/drivers/net/usb/kaweth.c	2009-09-01 21:23:23.240799685 -0700
+++ b/drivers/net/usb/kaweth.c	2009-09-01 21:28:37.504884609 -0700
@@ -778,7 +778,7 @@ static u32 kaweth_get_link(struct net_de
 	return kaweth->linkstate;
 }
 
-static struct ethtool_ops ops = {
+static const struct ethtool_ops ops = {
 	.get_drvinfo	= kaweth_get_drvinfo,
 	.get_link	= kaweth_get_link
 };
--- a/drivers/net/usb/mcs7830.c	2009-09-01 21:23:23.272740317 -0700
+++ b/drivers/net/usb/mcs7830.c	2009-09-01 21:28:42.591361634 -0700
@@ -449,7 +449,7 @@ static void mcs7830_get_regs(struct net_
 	mcs7830_get_reg(dev, 0, regs->len, data);
 }
 
-static struct ethtool_ops mcs7830_ethtool_ops = {
+static const struct ethtool_ops mcs7830_ethtool_ops = {
 	.get_drvinfo		= mcs7830_get_drvinfo,
 	.get_regs_len		= mcs7830_get_regs_len,
 	.get_regs		= mcs7830_get_regs,
--- a/drivers/net/usb/pegasus.c	2009-09-01 21:23:23.305799714 -0700
+++ b/drivers/net/usb/pegasus.c	2009-09-01 21:28:51.980749292 -0700
@@ -1174,7 +1174,7 @@ static void pegasus_set_msglevel(struct 
 	pegasus->msg_enable = v;
 }
 
-static struct ethtool_ops ops = {
+static const struct ethtool_ops ops = {
 	.get_drvinfo = pegasus_get_drvinfo,
 	.get_settings = pegasus_get_settings,
 	.set_settings = pegasus_set_settings,
--- a/drivers/net/usb/rtl8150.c	2009-09-01 21:23:23.337740661 -0700
+++ b/drivers/net/usb/rtl8150.c	2009-09-01 21:28:56.895273704 -0700
@@ -865,7 +865,7 @@ static int rtl8150_get_settings(struct n
 	return 0;
 }
 
-static struct ethtool_ops ops = {
+static const struct ethtool_ops ops = {
 	.get_drvinfo = rtl8150_get_drvinfo,
 	.get_settings = rtl8150_get_settings,
 	.get_link = ethtool_op_get_link
--- a/drivers/net/usb/smsc95xx.c	2009-09-01 21:23:23.369801502 -0700
+++ b/drivers/net/usb/smsc95xx.c	2009-09-01 21:29:00.964124094 -0700
@@ -625,7 +625,7 @@ static int smsc95xx_ethtool_set_tx_csum(
 	return smsc95xx_set_csums(dev);
 }
 
-static struct ethtool_ops smsc95xx_ethtool_ops = {
+static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.get_link	= usbnet_get_link,
 	.nway_reset	= usbnet_nway_reset,
 	.get_drvinfo	= usbnet_get_drvinfo,
--- a/drivers/net/usb/usbnet.c	2009-09-01 21:23:23.401801199 -0700
+++ b/drivers/net/usb/usbnet.c	2009-09-01 21:29:08.106772310 -0700
@@ -854,7 +854,7 @@ void usbnet_set_msglevel (struct net_dev
 EXPORT_SYMBOL_GPL(usbnet_set_msglevel);
 
 /* drivers may override default ethtool_ops in their bind() routine */
-static struct ethtool_ops usbnet_ethtool_ops = {
+static const struct ethtool_ops usbnet_ethtool_ops = {
 	.get_settings		= usbnet_get_settings,
 	.set_settings		= usbnet_set_settings,
 	.get_link		= usbnet_get_link,
--- a/drivers/net/veth.c	2009-09-01 21:23:23.433800886 -0700
+++ b/drivers/net/veth.c	2009-09-01 21:29:12.191020944 -0700
@@ -129,7 +129,7 @@ static int veth_set_tx_csum(struct net_d
 	return 0;
 }
 
-static struct ethtool_ops veth_ethtool_ops = {
+static const struct ethtool_ops veth_ethtool_ops = {
 	.get_settings		= veth_get_settings,
 	.get_drvinfo		= veth_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
--- a/drivers/net/virtio_net.c	2009-09-01 21:23:23.465800230 -0700
+++ b/drivers/net/virtio_net.c	2009-09-01 21:29:16.754013613 -0700
@@ -798,7 +798,7 @@ static void virtnet_vlan_rx_kill_vid(str
 		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
 }
 
-static struct ethtool_ops virtnet_ethtool_ops = {
+static const struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
--- a/drivers/net/wireless/libertas/dev.h	2009-09-01 21:23:23.499800950 -0700
+++ b/drivers/net/wireless/libertas/dev.h	2009-09-01 21:29:21.529757543 -0700
@@ -14,7 +14,7 @@
 #include "defs.h"
 #include "hostcmd.h"
 
-extern struct ethtool_ops lbs_ethtool_ops;
+extern const struct ethtool_ops lbs_ethtool_ops;
 
 #define	MAX_BSSID_PER_CHANNEL		16
 
--- a/drivers/net/wireless/libertas/ethtool.c	2009-09-01 21:23:23.532780220 -0700
+++ b/drivers/net/wireless/libertas/ethtool.c	2009-09-01 21:29:28.396212516 -0700
@@ -183,7 +183,7 @@ static int lbs_ethtool_set_wol(struct ne
 	return lbs_host_sleep_cfg(priv, criteria, (struct wol_config *)NULL);
 }
 
-struct ethtool_ops lbs_ethtool_ops = {
+const struct ethtool_ops lbs_ethtool_ops = {
 	.get_drvinfo = lbs_ethtool_get_drvinfo,
 	.get_eeprom =  lbs_ethtool_get_eeprom,
 	.get_eeprom_len = lbs_ethtool_get_eeprom_len,
--- a/drivers/net/xen-netfront.c	2009-09-01 21:23:23.565740506 -0700
+++ b/drivers/net/xen-netfront.c	2009-09-01 21:29:39.899887569 -0700
@@ -51,7 +51,7 @@
 #include <xen/interface/memory.h>
 #include <xen/interface/grant_table.h>
 
-static struct ethtool_ops xennet_ethtool_ops;
+static const struct ethtool_ops xennet_ethtool_ops;
 
 struct netfront_cb {
 	struct page *page;
@@ -1627,7 +1627,7 @@ static void backend_changed(struct xenbu
 	}
 }
 
-static struct ethtool_ops xennet_ethtool_ops =
+static const struct ethtool_ops xennet_ethtool_ops =
 {
 	.set_tx_csum = ethtool_op_set_tx_csum,
 	.set_sg = xennet_set_sg,
--- a/drivers/s390/net/qeth_l2_main.c	2009-09-01 21:23:23.614740730 -0700
+++ b/drivers/s390/net/qeth_l2_main.c	2009-09-01 21:29:48.813744958 -0700
@@ -863,7 +863,7 @@ static void qeth_l2_remove_device(struct
 	return;
 }
 
-static struct ethtool_ops qeth_l2_ethtool_ops = {
+static const struct ethtool_ops qeth_l2_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_strings = qeth_core_get_strings,
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
@@ -872,7 +872,7 @@ static struct ethtool_ops qeth_l2_ethtoo
 	.get_settings = qeth_core_ethtool_get_settings,
 };
 
-static struct ethtool_ops qeth_l2_osn_ops = {
+static const struct ethtool_ops qeth_l2_osn_ops = {
 	.get_strings = qeth_core_get_strings,
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
 	.get_stats_count = qeth_core_get_stats_count,
--- a/drivers/s390/net/qeth_l3_main.c	2009-09-01 21:23:23.665740346 -0700
+++ b/drivers/s390/net/qeth_l3_main.c	2009-09-01 21:29:58.282953727 -0700
@@ -2946,7 +2946,7 @@ static int qeth_l3_ethtool_set_tso(struc
 	return 0;
 }
 
-static struct ethtool_ops qeth_l3_ethtool_ops = {
+static const struct ethtool_ops qeth_l3_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_tx_csum = ethtool_op_get_tx_csum,
 	.set_tx_csum = ethtool_op_set_tx_hw_csum,
--- a/drivers/staging/at76_usb/at76_usb.c	2009-09-01 21:23:23.729799604 -0700
+++ b/drivers/staging/at76_usb/at76_usb.c	2009-09-01 21:30:08.712050545 -0700
@@ -3396,7 +3396,7 @@ static u32 at76_ethtool_get_link(struct 
 	return priv->mac_state == MAC_CONNECTED;
 }
 
-static struct ethtool_ops at76_ethtool_ops = {
+static const struct ethtool_ops at76_ethtool_ops = {
 	.get_drvinfo = at76_ethtool_get_drvinfo,
 	.get_link = at76_ethtool_get_link,
 };
--- a/drivers/staging/octeon/ethernet-mdio.c	2009-09-01 21:23:23.762799959 -0700
+++ b/drivers/staging/octeon/ethernet-mdio.c	2009-09-01 21:30:12.140749658 -0700
@@ -170,7 +170,7 @@ static u32 cvm_oct_get_link(struct net_d
 	return ret;
 }
 
-struct ethtool_ops cvm_oct_ethtool_ops = {
+struct const ethtool_ops cvm_oct_ethtool_ops = {
 	.get_drvinfo = cvm_oct_get_drvinfo,
 	.get_settings = cvm_oct_get_settings,
 	.set_settings = cvm_oct_set_settings,
--- a/drivers/staging/octeon/ethernet-mdio.h	2009-09-01 21:23:23.794740804 -0700
+++ b/drivers/staging/octeon/ethernet-mdio.h	2009-09-01 21:30:16.177000766 -0700
@@ -41,6 +41,6 @@
 #include <net/xfrm.h>
 #endif /* CONFIG_XFRM */
 
-extern struct ethtool_ops cvm_oct_ethtool_ops;
+extern const struct ethtool_ops cvm_oct_ethtool_ops;
 int cvm_oct_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 int cvm_oct_mdio_setup_device(struct net_device *dev);
--- a/drivers/staging/sxg/sxg.h	2009-09-01 21:23:23.826800190 -0700
+++ b/drivers/staging/sxg/sxg.h	2009-09-01 21:30:21.450752540 -0700
@@ -782,6 +782,6 @@ struct slic_crash_info {
 #define SIOCSLICSETINTAGG        (SIOCDEVPRIVATE+10)
 #define SIOCSLICTRACEDUMP        (SIOCDEVPRIVATE+11)
 
-extern struct ethtool_ops sxg_nic_ethtool_ops;
+extern const struct ethtool_ops sxg_nic_ethtool_ops;
 #define SXG_COMPLETE_SLOW_SEND_LIMIT	128
 #endif /*  __SXG_DRIVER_H__ */
--- a/drivers/staging/sxg/sxg_ethtool.c	2009-09-01 21:23:23.858740712 -0700
+++ b/drivers/staging/sxg/sxg_ethtool.c	2009-09-01 21:30:27.490902621 -0700
@@ -300,7 +300,7 @@ static int sxg_nic_get_eeprom(struct net
 	return 0;
 }
 
-struct ethtool_ops sxg_nic_ethtool_ops = {
+const struct ethtool_ops sxg_nic_ethtool_ops = {
 	.get_settings = sxg_nic_get_settings,
 	.set_settings = sxg_nic_set_settings,
 	.get_drvinfo = sxg_nic_get_drvinfo,
--- a/drivers/usb/gadget/u_ether.c	2009-09-01 21:23:23.890775071 -0700
+++ b/drivers/usb/gadget/u_ether.c	2009-09-01 21:30:36.693948879 -0700
@@ -181,7 +181,7 @@ static void eth_get_drvinfo(struct net_d
  *   - ... probably more ethtool ops
  */
 
-static struct ethtool_ops ops = {
+static const struct ethtool_ops ops = {
 	.get_drvinfo = eth_get_drvinfo,
 	.get_link = ethtool_op_get_link,
 };

-- 

