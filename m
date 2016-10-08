From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH v3 net-next 2/2] net: deprecate eth_change_mtu, remove usage
Date: Fri,  7 Oct 2016 22:04:34 -0400
Message-ID: <20161008020434.9691-3-jarod@redhat.com>
References: <20161002.224322.740109807229746275.davem@davemloft.net>
 <20161008020434.9691-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38862 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933085AbcJHCEu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 22:04:50 -0400
In-Reply-To: <20161008020434.9691-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With centralized MTU checking, there's nothing productive done by
eth_change_mtu that isn't already done in dev_set_mtu, so mark it as
deprecated and remove all usage of it in the kernel. All callers have been
audited for calls to alloc_etherdev* or ether_setup directly, which means
they all have a valid dev->min_mtu and dev->max_mtu. Now eth_change_mtu
prints out a netdev_warn about being deprecated, for the benefit of
out-of-tree drivers that might be utilizing it.

Of note, dvb_net.c actually had dev->mtu = 4096, while using
eth_change_mtu, meaning that if you ever tried changing it's mtu, you
couldn't set it above 1500 anymore. It's now getting dev->max_mtu also set
to 4096 to remedy that.

v2: fix up lantiq_etop, missed breakage due to drive not compiling on x86

CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 arch/m68k/emu/nfeth.c                                 |  1 -
 drivers/isdn/hysdn/hysdn_net.c                        |  1 -
 drivers/media/dvb-core/dvb_net.c                      |  2 +-
 drivers/net/appletalk/ipddp.c                         |  1 -
 drivers/net/cris/eth_v10.c                            |  1 -
 drivers/net/ethernet/3com/3c509.c                     |  1 -
 drivers/net/ethernet/3com/3c515.c                     |  1 -
 drivers/net/ethernet/3com/3c574_cs.c                  |  1 -
 drivers/net/ethernet/3com/3c589_cs.c                  |  1 -
 drivers/net/ethernet/3com/3c59x.c                     |  2 --
 drivers/net/ethernet/3com/typhoon.c                   |  1 -
 drivers/net/ethernet/8390/8390.c                      |  1 -
 drivers/net/ethernet/8390/8390p.c                     |  1 -
 drivers/net/ethernet/8390/ax88796.c                   |  1 -
 drivers/net/ethernet/8390/axnet_cs.c                  |  1 -
 drivers/net/ethernet/8390/etherh.c                    |  1 -
 drivers/net/ethernet/8390/hydra.c                     |  1 -
 drivers/net/ethernet/8390/mac8390.c                   |  1 -
 drivers/net/ethernet/8390/mcf8390.c                   |  1 -
 drivers/net/ethernet/8390/ne2k-pci.c                  |  1 -
 drivers/net/ethernet/8390/pcnet_cs.c                  |  1 -
 drivers/net/ethernet/8390/smc-ultra.c                 |  1 -
 drivers/net/ethernet/8390/wd.c                        |  1 -
 drivers/net/ethernet/8390/zorro8390.c                 |  1 -
 drivers/net/ethernet/adaptec/starfire.c               |  1 -
 drivers/net/ethernet/adi/bfin_mac.c                   |  1 -
 drivers/net/ethernet/allwinner/sun4i-emac.c           |  1 -
 drivers/net/ethernet/amd/a2065.c                      |  1 -
 drivers/net/ethernet/amd/am79c961a.c                  |  1 -
 drivers/net/ethernet/amd/ariadne.c                    |  1 -
 drivers/net/ethernet/amd/atarilance.c                 |  1 -
 drivers/net/ethernet/amd/au1000_eth.c                 |  1 -
 drivers/net/ethernet/amd/declance.c                   |  1 -
 drivers/net/ethernet/amd/hplance.c                    |  1 -
 drivers/net/ethernet/amd/lance.c                      |  1 -
 drivers/net/ethernet/amd/mvme147.c                    |  1 -
 drivers/net/ethernet/amd/ni65.c                       |  1 -
 drivers/net/ethernet/amd/nmclan_cs.c                  |  1 -
 drivers/net/ethernet/amd/pcnet32.c                    |  1 -
 drivers/net/ethernet/amd/sun3lance.c                  |  1 -
 drivers/net/ethernet/amd/sunlance.c                   |  1 -
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c      |  1 -
 drivers/net/ethernet/apple/bmac.c                     |  1 -
 drivers/net/ethernet/apple/mace.c                     |  1 -
 drivers/net/ethernet/apple/macmace.c                  |  1 -
 drivers/net/ethernet/aurora/nb8800.c                  |  1 -
 drivers/net/ethernet/cadence/macb.c                   |  1 -
 drivers/net/ethernet/cirrus/cs89x0.c                  |  1 -
 drivers/net/ethernet/cirrus/ep93xx_eth.c              |  1 -
 drivers/net/ethernet/cirrus/mac89x0.c                 |  1 -
 drivers/net/ethernet/davicom/dm9000.c                 |  1 -
 drivers/net/ethernet/dec/tulip/de2104x.c              |  1 -
 drivers/net/ethernet/dec/tulip/de4x5.c                |  1 -
 drivers/net/ethernet/dec/tulip/dmfe.c                 |  1 -
 drivers/net/ethernet/dec/tulip/tulip_core.c           |  1 -
 drivers/net/ethernet/dec/tulip/uli526x.c              |  1 -
 drivers/net/ethernet/dec/tulip/winbond-840.c          |  1 -
 drivers/net/ethernet/dec/tulip/xircom_cb.c            |  1 -
 drivers/net/ethernet/dnet.c                           |  1 -
 drivers/net/ethernet/ec_bhf.c                         |  1 -
 drivers/net/ethernet/fealnx.c                         |  1 -
 drivers/net/ethernet/freescale/fec_main.c             |  1 -
 drivers/net/ethernet/freescale/fec_mpc52xx.c          |  1 -
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c |  1 -
 drivers/net/ethernet/freescale/ucc_geth.c             |  1 -
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c             |  1 -
 drivers/net/ethernet/hisilicon/hip04_eth.c            |  1 -
 drivers/net/ethernet/hisilicon/hisi_femac.c           |  1 -
 drivers/net/ethernet/hp/hp100.c                       |  2 --
 drivers/net/ethernet/i825xx/82596.c                   |  1 -
 drivers/net/ethernet/i825xx/ether1.c                  |  1 -
 drivers/net/ethernet/i825xx/lib82596.c                |  1 -
 drivers/net/ethernet/i825xx/sun3_82586.c              |  1 -
 drivers/net/ethernet/ibm/emac/core.c                  |  1 -
 drivers/net/ethernet/korina.c                         |  1 -
 drivers/net/ethernet/lantiq_etop.c                    | 18 ++++++++----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.c           |  1 -
 drivers/net/ethernet/micrel/ks8851.c                  |  1 -
 drivers/net/ethernet/micrel/ks8851_mll.c              |  1 -
 drivers/net/ethernet/microchip/enc28j60.c             |  1 -
 drivers/net/ethernet/moxa/moxart_ether.c              |  1 -
 drivers/net/ethernet/natsemi/jazzsonic.c              |  1 -
 drivers/net/ethernet/natsemi/macsonic.c               |  1 -
 drivers/net/ethernet/natsemi/xtsonic.c                |  1 -
 drivers/net/ethernet/netx-eth.c                       |  1 -
 drivers/net/ethernet/nuvoton/w90p910_ether.c          |  1 -
 drivers/net/ethernet/nxp/lpc_eth.c                    |  1 -
 drivers/net/ethernet/packetengines/hamachi.c          |  1 -
 drivers/net/ethernet/packetengines/yellowfin.c        |  1 -
 drivers/net/ethernet/qlogic/qla3xxx.c                 |  1 -
 drivers/net/ethernet/rdc/r6040.c                      |  1 -
 drivers/net/ethernet/realtek/atp.c                    |  1 -
 drivers/net/ethernet/renesas/ravb_main.c              |  1 -
 drivers/net/ethernet/renesas/sh_eth.c                 |  2 --
 drivers/net/ethernet/seeq/ether3.c                    |  1 -
 drivers/net/ethernet/seeq/sgiseeq.c                   |  1 -
 drivers/net/ethernet/sgi/ioc3-eth.c                   |  1 -
 drivers/net/ethernet/sgi/meth.c                       |  1 -
 drivers/net/ethernet/silan/sc92031.c                  |  1 -
 drivers/net/ethernet/sis/sis190.c                     |  1 -
 drivers/net/ethernet/sis/sis900.c                     |  1 -
 drivers/net/ethernet/smsc/epic100.c                   |  1 -
 drivers/net/ethernet/smsc/smc911x.c                   |  1 -
 drivers/net/ethernet/smsc/smc9194.c                   |  1 -
 drivers/net/ethernet/smsc/smc91c92_cs.c               |  1 -
 drivers/net/ethernet/smsc/smc91x.c                    |  1 -
 drivers/net/ethernet/smsc/smsc911x.c                  |  1 -
 drivers/net/ethernet/sun/sunbmac.c                    |  1 -
 drivers/net/ethernet/sun/sunhme.c                     |  1 -
 drivers/net/ethernet/sun/sunqe.c                      |  1 -
 drivers/net/ethernet/ti/cpmac.c                       |  1 -
 drivers/net/ethernet/ti/cpsw.c                        |  1 -
 drivers/net/ethernet/ti/tlan.c                        |  1 -
 drivers/net/ethernet/toshiba/tc35815.c                |  1 -
 drivers/net/ethernet/tundra/tsi108_eth.c              |  1 -
 drivers/net/ethernet/via/via-rhine.c                  |  1 -
 drivers/net/ethernet/wiznet/w5100.c                   |  1 -
 drivers/net/ethernet/wiznet/w5300.c                   |  1 -
 drivers/net/ethernet/xircom/xirc2ps_cs.c              |  1 -
 drivers/net/ethernet/xscale/ixp4xx_eth.c              |  1 -
 drivers/net/plip/plip.c                               |  1 -
 drivers/net/sb1000.c                                  |  1 -
 drivers/net/usb/catc.c                                |  1 -
 drivers/net/usb/kaweth.c                              |  1 -
 drivers/net/usb/pegasus.c                             |  1 -
 drivers/net/usb/r8152.c                               |  3 ++-
 drivers/net/usb/rtl8150.c                             |  1 -
 drivers/net/wan/sbni.c                                |  1 -
 drivers/net/wireless/intersil/prism54/islpci_dev.c    |  1 -
 drivers/net/wireless/mac80211_hwsim.c                 |  1 -
 drivers/net/wireless/marvell/libertas/main.c          |  1 -
 drivers/net/wireless/ray_cs.c                         |  1 -
 drivers/net/wireless/wl3501_cs.c                      |  1 -
 drivers/net/wireless/zydas/zd1201.c                   |  1 -
 drivers/staging/rtl8188eu/os_dep/mon.c                |  1 -
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c          |  1 -
 drivers/staging/rtl8192u/r8192U_core.c                |  1 -
 drivers/staging/slicoss/slicoss.c                     |  1 -
 include/uapi/linux/if_ether.h                         |  2 ++
 net/atm/br2684.c                                      |  2 --
 net/bluetooth/bnep/netdev.c                           |  1 -
 net/ethernet/eth.c                                    |  5 +++--
 net/irda/irlan/irlan_eth.c                            |  1 -
 143 files changed, 16 insertions(+), 156 deletions(-)

diff --git a/arch/m68k/emu/nfeth.c b/arch/m68k/emu/nfeth.c
index a0985fd..fc4be02 100644
--- a/arch/m68k/emu/nfeth.c
+++ b/arch/m68k/emu/nfeth.c
@@ -184,7 +184,6 @@ static const struct net_device_ops nfeth_netdev_ops = {
 	.ndo_start_xmit		= nfeth_xmit,
 	.ndo_tx_timeout		= nfeth_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
diff --git a/drivers/isdn/hysdn/hysdn_net.c b/drivers/isdn/hysdn/hysdn_net.c
index 5609dee..b93a4e9a 100644
--- a/drivers/isdn/hysdn/hysdn_net.c
+++ b/drivers/isdn/hysdn/hysdn_net.c
@@ -232,7 +232,6 @@ static const struct net_device_ops hysdn_netdev_ops = {
 	.ndo_open		= net_open,
 	.ndo_stop		= net_close,
 	.ndo_start_xmit		= net_send_packet,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index 9914f69..0da622f 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -1198,7 +1198,6 @@ static const struct net_device_ops dvb_netdev_ops = {
 	.ndo_start_xmit		= dvb_net_tx,
 	.ndo_set_rx_mode	= dvb_net_set_multicast_list,
 	.ndo_set_mac_address    = dvb_net_set_mac,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -1209,6 +1208,7 @@ static void dvb_net_setup(struct net_device *dev)
 	dev->header_ops		= &dvb_header_ops;
 	dev->netdev_ops		= &dvb_netdev_ops;
 	dev->mtu		= 4096;
+	dev->max_mtu		= 4096;
 
 	dev->flags |= IFF_NOARP;
 }
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index e90c6a7..31f89f1 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -59,7 +59,6 @@ static int ipddp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static const struct net_device_ops ipddp_netdev_ops = {
 	.ndo_start_xmit		= ipddp_xmit,
 	.ndo_do_ioctl   	= ipddp_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 221f5f0..e128826 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -264,7 +264,6 @@ static const struct net_device_ops e100_netdev_ops = {
 	.ndo_do_ioctl		= e100_ioctl,
 	.ndo_set_mac_address	= e100_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_config		= e100_set_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= e100_netpoll,
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 91ada52..9f9a5f4 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -508,7 +508,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_get_stats 		= el3_get_stats,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout 	= el3_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index b26e038..b9f4c46 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -570,7 +570,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_tx_timeout		= corkscrew_timeout,
 	.ndo_get_stats		= corkscrew_get_stats,
 	.ndo_set_rx_mode	= set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/3com/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
index b88afd7..9359a37 100644
--- a/drivers/net/ethernet/3com/3c574_cs.c
+++ b/drivers/net/ethernet/3com/3c574_cs.c
@@ -254,7 +254,6 @@ static const struct net_device_ops el3_netdev_ops = {
 	.ndo_get_stats		= el3_get_stats,
 	.ndo_do_ioctl		= el3_ioctl,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index 71396e4..e28254a 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -188,7 +188,6 @@ static const struct net_device_ops el3_netdev_ops = {
 	.ndo_set_config		= el3_config,
 	.ndo_get_stats		= el3_get_stats,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 9133e79..3ecf613 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1062,7 +1062,6 @@ static const struct net_device_ops boomrang_netdev_ops = {
 	.ndo_do_ioctl 		= vortex_ioctl,
 #endif
 	.ndo_set_rx_mode	= set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1080,7 +1079,6 @@ static const struct net_device_ops vortex_netdev_ops = {
 	.ndo_do_ioctl 		= vortex_ioctl,
 #endif
 	.ndo_set_rx_mode	= set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 8f8418d..506b507 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2255,7 +2255,6 @@ static const struct net_device_ops typhoon_netdev_ops = {
 	.ndo_get_stats		= typhoon_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int
diff --git a/drivers/net/ethernet/8390/8390.c b/drivers/net/ethernet/8390/8390.c
index 5db1f55..a43544a 100644
--- a/drivers/net/ethernet/8390/8390.c
+++ b/drivers/net/ethernet/8390/8390.c
@@ -64,7 +64,6 @@ const struct net_device_ops ei_netdev_ops = {
 	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ei_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/8390p.c b/drivers/net/ethernet/8390/8390p.c
index e8fc2e8..46d2257 100644
--- a/drivers/net/ethernet/8390/8390p.c
+++ b/drivers/net/ethernet/8390/8390p.c
@@ -69,7 +69,6 @@ const struct net_device_ops eip_netdev_ops = {
 	.ndo_set_rx_mode	= eip_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= eip_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 39ca935..b0a3b85 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -536,7 +536,6 @@ static const struct net_device_ops ax_netdev_ops = {
 	.ndo_set_rx_mode	= ax_ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ax_ei_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index 4ea717d..1d84a05 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -134,7 +134,6 @@ static const struct net_device_ops axnet_netdev_ops = {
 	.ndo_tx_timeout		= axnet_tx_timeout,
 	.ndo_get_stats		= get_stats,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index d686b9c..11cbf22 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -654,7 +654,6 @@ static const struct net_device_ops etherh_netdev_ops = {
 	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= __ei_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index 0fe19d6..8ae2491 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -105,7 +105,6 @@ static const struct net_device_ops hydra_netdev_ops = {
 	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= __ei_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/mac8390.c b/drivers/net/ethernet/8390/mac8390.c
index b928390..9497f18 100644
--- a/drivers/net/ethernet/8390/mac8390.c
+++ b/drivers/net/ethernet/8390/mac8390.c
@@ -483,7 +483,6 @@ static const struct net_device_ops mac8390_netdev_ops = {
 	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= __ei_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/mcf8390.c b/drivers/net/ethernet/8390/mcf8390.c
index e1c0555..4bb967b 100644
--- a/drivers/net/ethernet/8390/mcf8390.c
+++ b/drivers/net/ethernet/8390/mcf8390.c
@@ -308,7 +308,6 @@ static const struct net_device_ops mcf8390_netdev_ops = {
 	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= __ei_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index 57e9791..0735530 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -209,7 +209,6 @@ static const struct net_device_ops ne2k_netdev_ops = {
 	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = ei_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index 2f79d29..63079a6 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -227,7 +227,6 @@ static const struct net_device_ops pcnet_netdev_ops = {
 	.ndo_do_ioctl 		= ei_ioctl,
 	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_tx_timeout 	= ei_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/8390/smc-ultra.c b/drivers/net/ethernet/8390/smc-ultra.c
index 139385d..364b651 100644
--- a/drivers/net/ethernet/8390/smc-ultra.c
+++ b/drivers/net/ethernet/8390/smc-ultra.c
@@ -195,7 +195,6 @@ static const struct net_device_ops ultra_netdev_ops = {
 	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller 	= ultra_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/wd.c b/drivers/net/ethernet/8390/wd.c
index dd7d816..ad019cb 100644
--- a/drivers/net/ethernet/8390/wd.c
+++ b/drivers/net/ethernet/8390/wd.c
@@ -156,7 +156,6 @@ static const struct net_device_ops wd_netdev_ops = {
 	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller 	= ei_poll,
 #endif
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index 8308728..6d93956 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -284,7 +284,6 @@ static const struct net_device_ops zorro8390_netdev_ops = {
 	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= __ei_poll,
 #endif
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 8af2c88..4a9a16e 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -634,7 +634,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_get_stats		= get_stats,
 	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl		= netdev_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef VLAN_SUPPORT
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 00f9ee3..8816452 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1571,7 +1571,6 @@ static const struct net_device_ops bfin_mac_netdev_ops = {
 	.ndo_set_rx_mode	= bfin_mac_set_multicast_list,
 	.ndo_do_ioctl           = bfin_mac_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= bfin_mac_poll_controller,
 #endif
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 6ffdff6..af27f9d 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -773,7 +773,6 @@ static const struct net_device_ops emac_netdev_ops = {
 	.ndo_tx_timeout		= emac_timeout,
 	.ndo_set_rx_mode	= emac_set_rx_mode,
 	.ndo_do_ioctl		= emac_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= emac_set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index a83cd1c..ee4b94e 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -665,7 +665,6 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_tx_timeout		= lance_tx_timeout,
 	.ndo_set_rx_mode	= lance_set_multicast,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index fcdf5dd..b11e910 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -663,7 +663,6 @@ static const struct net_device_ops am79c961_netdev_ops = {
 	.ndo_set_rx_mode	= am79c961_setmulticastlist,
 	.ndo_tx_timeout		= am79c961_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= am79c961_poll_controller,
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index 968b7bf..5fd7b15 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -706,7 +706,6 @@ static const struct net_device_ops ariadne_netdev_ops = {
 	.ndo_get_stats		= ariadne_get_stats,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index d2bc8e5..e53ccc3 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -460,7 +460,6 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_set_mac_address	= lance_set_mac_address,
 	.ndo_tx_timeout		= lance_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static unsigned long __init lance_probe1( struct net_device *dev,
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index df66418..a3c90fe 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1103,7 +1103,6 @@ static const struct net_device_ops au1000_netdev_ops = {
 	.ndo_tx_timeout		= au1000_tx_timeout,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int au1000_probe(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index b799c7a..76e5fc7 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -1013,7 +1013,6 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_tx_timeout		= lance_tx_timeout,
 	.ndo_set_rx_mode	= lance_set_multicast,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index 6c9de11..c3dbf1c 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -72,7 +72,6 @@ static const struct net_device_ops hplance_netdev_ops = {
 	.ndo_stop		= hplance_close,
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_set_rx_mode	= lance_set_multicast,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index abb1ba2..61a641f 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -461,7 +461,6 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_get_stats		= lance_get_stats,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout		= lance_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index 0660ac5..0a92044 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -62,7 +62,6 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_set_rx_mode	= lance_set_multicast,
 	.ndo_tx_timeout		= lance_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index cda53db..5985bf2 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -407,7 +407,6 @@ static const struct net_device_ops ni65_netdev_ops = {
 	.ndo_start_xmit		= ni65_send_packet,
 	.ndo_tx_timeout		= ni65_timeout,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 2807e18..113a3b3 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -427,7 +427,6 @@ static const struct net_device_ops mace_netdev_ops = {
 	.ndo_set_config		= mace_config,
 	.ndo_get_stats		= mace_get_stats,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index c22bf52..adc7ab9 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1527,7 +1527,6 @@ static const struct net_device_ops pcnet32_netdev_ops = {
 	.ndo_get_stats		= pcnet32_get_stats,
 	.ndo_set_rx_mode	= pcnet32_set_multicast_list,
 	.ndo_do_ioctl		= pcnet32_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index 3d8c6b2..12bb4f1 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -299,7 +299,6 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address	= NULL,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 9b56b40..291ca51 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1294,7 +1294,6 @@ static const struct net_device_ops sparc_lance_ops = {
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_set_rx_mode	= lance_set_multicast,
 	.ndo_tx_timeout		= lance_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 429f18f..9665563 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1252,7 +1252,6 @@ static const struct net_device_ops xgene_ndev_ops = {
 	.ndo_start_xmit = xgene_enet_start_xmit,
 	.ndo_tx_timeout = xgene_enet_timeout,
 	.ndo_get_stats64 = xgene_enet_get_stats64,
-	.ndo_change_mtu = eth_change_mtu,
 	.ndo_set_mac_address = xgene_enet_set_mac_address,
 };
 
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index a65d7a6..2b2d870 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1237,7 +1237,6 @@ static const struct net_device_ops bmac_netdev_ops = {
 	.ndo_start_xmit		= bmac_output,
 	.ndo_set_rx_mode	= bmac_set_multicast,
 	.ndo_set_mac_address	= bmac_set_address,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index e58a7c7..96dd530 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -102,7 +102,6 @@ static const struct net_device_ops mace_netdev_ops = {
 	.ndo_start_xmit		= mace_xmit_start,
 	.ndo_set_rx_mode	= mace_set_multicast,
 	.ndo_set_mac_address	= mace_set_address,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index 89914ca..857df9c 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -186,7 +186,6 @@ static const struct net_device_ops mace_netdev_ops = {
 	.ndo_tx_timeout		= mace_tx_timeout,
 	.ndo_set_rx_mode	= mace_set_multicast,
 	.ndo_set_mac_address	= mace_set_address,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index b047fd6..453dc09 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1032,7 +1032,6 @@ static const struct net_device_ops nb8800_netdev_ops = {
 	.ndo_set_mac_address	= nb8800_set_mac_address,
 	.ndo_set_rx_mode	= nb8800_set_rx_mode,
 	.ndo_do_ioctl		= nb8800_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 63144bb..134ad24 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2793,7 +2793,6 @@ static const struct net_device_ops at91ether_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_do_ioctl		= macb_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= at91ether_poll_controller,
 #endif
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index c363b58..3647b28 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -1266,7 +1266,6 @@ static const struct net_device_ops net_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= net_poll_controller,
 #endif
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index de9f7c9..9119af0 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -749,7 +749,6 @@ static const struct net_device_ops ep93xx_netdev_ops = {
 	.ndo_start_xmit		= ep93xx_xmit,
 	.ndo_do_ioctl		= ep93xx_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index 0771967..b600fbb 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -172,7 +172,6 @@ static const struct net_device_ops mac89x0_netdev_ops = {
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address	= set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 /* Probe for the CS8900 card in slot E.  We won't bother looking
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index f45385f..f1a81c5 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1382,7 +1382,6 @@ static const struct net_device_ops dm9000_netdev_ops = {
 	.ndo_tx_timeout		= dm9000_timeout,
 	.ndo_set_rx_mode	= dm9000_hash_table,
 	.ndo_do_ioctl		= dm9000_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_features	= dm9000_set_features,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index cadcee6..90c573b 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1956,7 +1956,6 @@ static const struct net_device_ops de_netdev_ops = {
 	.ndo_start_xmit		= de_start_xmit,
 	.ndo_get_stats		= de_get_stats,
 	.ndo_tx_timeout 	= de_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 6620fc8..51fda3a 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1085,7 +1085,6 @@ static const struct net_device_ops de4x5_netdev_ops = {
     .ndo_get_stats	= de4x5_get_stats,
     .ndo_set_rx_mode	= set_multicast_list,
     .ndo_do_ioctl	= de4x5_ioctl,
-    .ndo_change_mtu	= eth_change_mtu,
     .ndo_set_mac_address= eth_mac_addr,
     .ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 8ed0fd8..df49949 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -352,7 +352,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop		= dmfe_stop,
 	.ndo_start_xmit		= dmfe_start_xmit,
 	.ndo_set_rx_mode	= dmfe_set_filter_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index bbde90b..5f13774 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1282,7 +1282,6 @@ static const struct net_device_ops tulip_netdev_ops = {
 	.ndo_get_stats		= tulip_get_stats,
 	.ndo_do_ioctl 		= private_ioctl,
 	.ndo_set_rx_mode	= set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index e750b5d..e1c4133 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -269,7 +269,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop		= uli526x_stop,
 	.ndo_start_xmit		= uli526x_start_xmit,
 	.ndo_set_rx_mode	= uli526x_set_filter_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 1f62b94..feda96d 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -353,7 +353,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl		= netdev_ioctl,
 	.ndo_tx_timeout		= tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 0e721ce..19e4ea1 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -174,7 +174,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_open		= xircom_open,
 	.ndo_stop		= xircom_close,
 	.ndo_start_xmit		= xircom_start_xmit,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index c3b64cd..2a17c59 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -767,7 +767,6 @@ static const struct net_device_ops dnet_netdev_ops = {
 	.ndo_do_ioctl		= dnet_ioctl,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int dnet_probe(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index f7b4248..5765095 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -482,7 +482,6 @@ static const struct net_device_ops ec_bhf_netdev_ops = {
 	.ndo_open		= ec_bhf_open,
 	.ndo_stop		= ec_bhf_stop,
 	.ndo_get_stats64	= ec_bhf_get_stats,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr
 };
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index c08bd76..6967b28 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -472,7 +472,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl		= mii_ioctl,
 	.ndo_tx_timeout		= fealnx_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 48a033e..4ce8179 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3055,7 +3055,6 @@ static const struct net_device_ops fec_netdev_ops = {
 	.ndo_stop		= fec_enet_close,
 	.ndo_start_xmit		= fec_enet_start_xmit,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= fec_timeout,
 	.ndo_set_mac_address	= fec_set_mac_address,
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 446ae9d..aa8cf5d2 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -802,7 +802,6 @@ static const struct net_device_ops mpc52xx_fec_netdev_ops = {
 	.ndo_set_mac_address = mpc52xx_fec_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_do_ioctl = mpc52xx_fec_ioctl,
-	.ndo_change_mtu = eth_change_mtu,
 	.ndo_tx_timeout = mpc52xx_fec_tx_timeout,
 	.ndo_get_stats = mpc52xx_fec_get_stats,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index dc120c1..925d1bc 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -912,7 +912,6 @@ static const struct net_device_ops fs_enet_netdev_ops = {
 	.ndo_do_ioctl		= fs_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= fs_enet_netpoll,
 #endif
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 186ef8f..7861824 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3681,7 +3681,6 @@ static const struct net_device_ops ucc_geth_netdev_ops = {
 	.ndo_start_xmit		= ucc_geth_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ucc_geth_set_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_rx_mode	= ucc_geth_set_multi,
 	.ndo_tx_timeout		= ucc_geth_timeout,
 	.ndo_do_ioctl		= ucc_geth_ioctl,
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index 399cfd2..51c4abc 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -225,7 +225,6 @@ static const struct net_device_ops fjn_netdev_ops = {
 	.ndo_tx_timeout 	= fjn_tx_timeout,
 	.ndo_set_config 	= fjn_config,
 	.ndo_set_rx_mode	= set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 3977889..3c99ca4 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -769,7 +769,6 @@ static const struct net_device_ops hip04_netdev_ops = {
 	.ndo_set_mac_address	= hip04_set_mac_address,
 	.ndo_tx_timeout         = hip04_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int hip04_alloc_ring(struct net_device *ndev, struct device *d)
diff --git a/drivers/net/ethernet/hisilicon/hisi_femac.c b/drivers/net/ethernet/hisilicon/hisi_femac.c
index ced1859..4986306 100644
--- a/drivers/net/ethernet/hisilicon/hisi_femac.c
+++ b/drivers/net/ethernet/hisilicon/hisi_femac.c
@@ -712,7 +712,6 @@ static const struct net_device_ops hisi_femac_netdev_ops = {
 	.ndo_do_ioctl		= hisi_femac_net_ioctl,
 	.ndo_set_mac_address	= hisi_femac_set_mac_address,
 	.ndo_set_rx_mode	= hisi_femac_net_set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static void hisi_femac_core_reset(struct hisi_femac_priv *priv)
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 631dbc7..1a31bee 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -427,7 +427,6 @@ static const struct net_device_ops hp100_bm_netdev_ops = {
 	.ndo_start_xmit		= hp100_start_xmit_bm,
 	.ndo_get_stats 		= hp100_get_stats,
 	.ndo_set_rx_mode	= hp100_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
@@ -438,7 +437,6 @@ static const struct net_device_ops hp100_netdev_ops = {
 	.ndo_start_xmit		= hp100_start_xmit,
 	.ndo_get_stats 		= hp100_get_stats,
 	.ndo_set_rx_mode	= hp100_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index ce235b7..9458838 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -1118,7 +1118,6 @@ static const struct net_device_ops i596_netdev_ops = {
 	.ndo_start_xmit		= i596_start_xmit,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout		= i596_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index 5d353c6..dc98345 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -981,7 +981,6 @@ static const struct net_device_ops ether1_netdev_ops = {
 	.ndo_set_rx_mode	= ether1_setmulticastlist,
 	.ndo_tx_timeout		= ether1_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index 3dbc53c2..e867733 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -1037,7 +1037,6 @@ static const struct net_device_ops i596_netdev_ops = {
 	.ndo_start_xmit		= i596_start_xmit,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout		= i596_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/i825xx/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
index 21c84cc..8bb15a8 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.c
+++ b/drivers/net/ethernet/i825xx/sun3_82586.c
@@ -337,7 +337,6 @@ static const struct net_device_ops sun3_82586_netdev_ops = {
 	.ndo_get_stats		= sun3_82586_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int __init sun3_82586_probe1(struct net_device *dev,int ioaddr)
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 8f13919..5d804a5 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2718,7 +2718,6 @@ static const struct net_device_ops emac_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= emac_set_mac_address,
 	.ndo_start_xmit		= emac_start_xmit,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static const struct net_device_ops emac_gige_netdev_ops = {
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 1799fe1..cbeea91 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1085,7 +1085,6 @@ static const struct net_device_ops korina_netdev_ops = {
 	.ndo_set_rx_mode	= korina_multicast_list,
 	.ndo_tx_timeout		= korina_tx_timeout,
 	.ndo_do_ioctl		= korina_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 91e09d6..1a739d7 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -519,18 +519,16 @@ ltq_etop_tx(struct sk_buff *skb, struct net_device *dev)
 static int
 ltq_etop_change_mtu(struct net_device *dev, int new_mtu)
 {
-	int ret = eth_change_mtu(dev, new_mtu);
+	struct ltq_etop_priv *priv = netdev_priv(dev);
+	unsigned long flags;
 
-	if (!ret) {
-		struct ltq_etop_priv *priv = netdev_priv(dev);
-		unsigned long flags;
+	dev->mtu = new_mtu;
 
-		spin_lock_irqsave(&priv->lock, flags);
-		ltq_etop_w32((ETOP_PLEN_UNDER << 16) | new_mtu,
-			LTQ_ETOP_IGPLEN);
-		spin_unlock_irqrestore(&priv->lock, flags);
-	}
-	return ret;
+	spin_lock_irqsave(&priv->lock, flags);
+	ltq_etop_w32((ETOP_PLEN_UNDER << 16) | new_mtu, LTQ_ETOP_IGPLEN);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
 }
 
 static int
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ad4ab97..806d4f7 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2243,7 +2243,6 @@ static const struct net_device_ops mtk_netdev_ops = {
 	.ndo_set_mac_address	= mtk_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= mtk_do_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_tx_timeout		= mtk_tx_timeout,
 	.ndo_get_stats64        = mtk_get_stats64,
 	.ndo_fix_features	= mtk_fix_features,
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 1edc973..e7e1aff 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1063,7 +1063,6 @@ static const struct net_device_ops ks8851_netdev_ops = {
 	.ndo_start_xmit		= ks8851_start_xmit,
 	.ndo_set_mac_address	= ks8851_set_mac_address,
 	.ndo_set_rx_mode	= ks8851_set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 2fc5cd5..db62807 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1285,7 +1285,6 @@ static const struct net_device_ops ks_netdev_ops = {
 	.ndo_start_xmit		= ks_start_xmit,
 	.ndo_set_mac_address	= ks_set_mac_address,
 	.ndo_set_rx_mode	= ks_set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 0a26b11..045b910 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1544,7 +1544,6 @@ static const struct net_device_ops enc28j60_netdev_ops = {
 	.ndo_set_rx_mode	= enc28j60_set_multicast_list,
 	.ndo_set_mac_address	= enc28j60_set_mac_address,
 	.ndo_tx_timeout		= enc28j60_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 4367dd6..9774b50 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -444,7 +444,6 @@ static struct net_device_ops moxart_netdev_ops = {
 	.ndo_set_rx_mode	= moxart_mac_set_rx_mode,
 	.ndo_set_mac_address	= moxart_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int moxart_mac_probe(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index acf3f11..a6caeb5 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -110,7 +110,6 @@ static const struct net_device_ops sonic_netdev_ops = {
 	.ndo_get_stats		= sonic_get_stats,
 	.ndo_set_rx_mode	= sonic_multicast_list,
 	.ndo_tx_timeout		= sonic_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index d98f5b8..3ca6ae7 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -190,7 +190,6 @@ static const struct net_device_ops macsonic_netdev_ops = {
 	.ndo_tx_timeout		= sonic_tx_timeout,
 	.ndo_get_stats		= sonic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index 7007d21..9ee0f69 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -124,7 +124,6 @@ static const struct net_device_ops xtsonic_netdev_ops = {
 	.ndo_set_rx_mode	= sonic_multicast_list,
 	.ndo_tx_timeout		= sonic_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index adbc47f..df4188cb 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -304,7 +304,6 @@ static const struct net_device_ops netx_eth_netdev_ops = {
 	.ndo_start_xmit		= netx_eth_hard_start_xmit,
 	.ndo_tx_timeout		= netx_eth_timeout,
 	.ndo_set_rx_mode	= netx_eth_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 712d8bc..119f6dc 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -915,7 +915,6 @@ static const struct net_device_ops w90p910_ether_netdev_ops = {
 	.ndo_set_mac_address	= w90p910_set_mac_address,
 	.ndo_do_ioctl		= w90p910_ether_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static void __init get_mac_address(struct net_device *dev)
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 8e13ec8..dd6b0d0 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1256,7 +1256,6 @@ static const struct net_device_ops lpc_netdev_ops = {
 	.ndo_do_ioctl		= lpc_eth_ioctl,
 	.ndo_set_mac_address	= lpc_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int lpc_eth_drv_probe(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 91be2f0..2d04679 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -568,7 +568,6 @@ static const struct net_device_ops hamachi_netdev_ops = {
 	.ndo_start_xmit		= hamachi_start_xmit,
 	.ndo_get_stats		= hamachi_get_stats,
 	.ndo_set_rx_mode	= set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_tx_timeout		= hamachi_tx_timeout,
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index fb1d103..2a2ca5f 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -360,7 +360,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop 		= yellowfin_close,
 	.ndo_start_xmit 	= yellowfin_start_xmit,
 	.ndo_set_rx_mode	= set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_do_ioctl 		= netdev_ioctl,
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index b09a6b8..5c100ab 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3755,7 +3755,6 @@ static const struct net_device_ops ql3xxx_netdev_ops = {
 	.ndo_open		= ql3xxx_open,
 	.ndo_start_xmit		= ql3xxx_send,
 	.ndo_stop		= ql3xxx_close,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ql3xxx_set_mac_address,
 	.ndo_tx_timeout		= ql3xxx_tx_timeout,
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 5ef5d72..4ff4e04 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -969,7 +969,6 @@ static const struct net_device_ops r6040_netdev_ops = {
 	.ndo_start_xmit		= r6040_start_xmit,
 	.ndo_get_stats		= r6040_get_stats,
 	.ndo_set_rx_mode	= r6040_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_do_ioctl		= r6040_ioctl,
diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index 5cb9678..570ed3b 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -245,7 +245,6 @@ static const struct net_device_ops atp_netdev_ops = {
 	.ndo_start_xmit		= atp_send_packet,
 	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_tx_timeout		= tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 630536b..27cfec3 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1780,7 +1780,6 @@ static const struct net_device_ops ravb_netdev_ops = {
 	.ndo_do_ioctl		= ravb_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 /* MDIO bus init function */
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 05b0dc5..e443695 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2914,7 +2914,6 @@ static const struct net_device_ops sh_eth_netdev_ops = {
 	.ndo_do_ioctl		= sh_eth_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static const struct net_device_ops sh_eth_netdev_ops_tsu = {
@@ -2929,7 +2928,6 @@ static const struct net_device_ops sh_eth_netdev_ops_tsu = {
 	.ndo_do_ioctl		= sh_eth_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 #ifdef CONFIG_OF
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index bdac936..244c1e1 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -745,7 +745,6 @@ static const struct net_device_ops ether3_netdev_ops = {
 	.ndo_set_rx_mode	= ether3_setmulticastlist,
 	.ndo_tx_timeout		= ether3_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index c2bd537..ed34196 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -714,7 +714,6 @@ static const struct net_device_ops sgiseeq_netdev_ops = {
 	.ndo_tx_timeout		= timeout,
 	.ndo_set_rx_mode	= sgiseeq_set_multicast,
 	.ndo_set_mac_address	= sgiseeq_set_mac_address,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 7a254da..42051ab 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1225,7 +1225,6 @@ static const struct net_device_ops ioc3_netdev_ops = {
 	.ndo_do_ioctl		= ioc3_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ioc3_set_mac_address,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index aaa80f1..69d2d30 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -815,7 +815,6 @@ static const struct net_device_ops meth_netdev_ops = {
 	.ndo_start_xmit		= meth_tx,
 	.ndo_do_ioctl		= meth_ioctl,
 	.ndo_tx_timeout		= meth_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_set_rx_mode    	= meth_set_rx_mode,
diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 7426f8b..6c2e2b3 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -1386,7 +1386,6 @@ static const struct net_device_ops sc92031_netdev_ops = {
 	.ndo_open		= sc92031_open,
 	.ndo_stop		= sc92031_stop,
 	.ndo_set_rx_mode	= sc92031_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_tx_timeout		= sc92031_tx_timeout,
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 27be6c8..210e35d 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1833,7 +1833,6 @@ static const struct net_device_ops sis190_netdev_ops = {
 	.ndo_start_xmit		= sis190_start_xmit,
 	.ndo_tx_timeout		= sis190_tx_timeout,
 	.ndo_set_rx_mode	= sis190_set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= sis190_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 6f85276..39fca6c 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -400,7 +400,6 @@ static const struct net_device_ops sis900_netdev_ops = {
 	.ndo_start_xmit		= sis900_start_xmit,
 	.ndo_set_config		= sis900_set_config,
 	.ndo_set_rx_mode	= set_rx_mode,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_do_ioctl		= mii_ioctl,
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 7186b89..fe9760f 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -313,7 +313,6 @@ static const struct net_device_ops epic_netdev_ops = {
 	.ndo_get_stats		= epic_get_stats,
 	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl 		= netdev_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index cb49c96..4f19c61 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1753,7 +1753,6 @@ static const struct net_device_ops smc911x_netdev_ops = {
 	.ndo_start_xmit		= smc911x_hard_start_xmit,
 	.ndo_tx_timeout		= smc911x_timeout,
 	.ndo_set_rx_mode	= smc911x_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index d496888..c8d8467 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -809,7 +809,6 @@ static const struct net_device_ops smc_netdev_ops = {
 	.ndo_start_xmit    	= smc_wait_to_send_packet,
 	.ndo_tx_timeout	    	= smc_timeout,
 	.ndo_set_rx_mode	= smc_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index db3c696..f1c75e2 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -294,7 +294,6 @@ static const struct net_device_ops smc_netdev_ops = {
 	.ndo_set_config 	= s9k_config,
 	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl		= smc_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 7321259..9b4780f 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1762,7 +1762,6 @@ static const struct net_device_ops smc_netdev_ops = {
 	.ndo_start_xmit		= smc_hard_start_xmit,
 	.ndo_tx_timeout		= smc_timeout,
 	.ndo_set_rx_mode	= smc_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index e9b8579..cdb343f 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2152,7 +2152,6 @@ static const struct net_device_ops smsc911x_netdev_ops = {
 	.ndo_get_stats		= smsc911x_get_stats,
 	.ndo_set_rx_mode	= smsc911x_set_multicast_list,
 	.ndo_do_ioctl		= smsc911x_do_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= smsc911x_set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index aa4f9d2..ea89ef3 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1064,7 +1064,6 @@ static const struct net_device_ops bigmac_ops = {
 	.ndo_get_stats		= bigmac_get_stats,
 	.ndo_set_rx_mode	= bigmac_set_multicast,
 	.ndo_tx_timeout		= bigmac_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index cf4dcff..ca96408 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2669,7 +2669,6 @@ static const struct net_device_ops hme_netdev_ops = {
 	.ndo_tx_timeout		= happy_meal_tx_timeout,
 	.ndo_get_stats		= happy_meal_get_stats,
 	.ndo_set_rx_mode	= happy_meal_set_multicast,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 9b825780..c5ef711 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -823,7 +823,6 @@ static const struct net_device_ops qec_ops = {
 	.ndo_start_xmit		= qe_start_xmit,
 	.ndo_set_rx_mode	= qe_set_multicast,
 	.ndo_tx_timeout		= qe_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index fa0cfda..c56e703 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1068,7 +1068,6 @@ static const struct net_device_ops cpmac_netdev_ops = {
 	.ndo_tx_timeout		= cpmac_tx_timeout,
 	.ndo_set_rx_mode	= cpmac_set_multicast_list,
 	.ndo_do_ioctl		= cpmac_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c6cff3d..7d78dee 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1883,7 +1883,6 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_set_mac_address	= cpsw_ndo_set_mac_address,
 	.ndo_do_ioctl		= cpsw_ndo_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
 	.ndo_set_rx_mode	= cpsw_ndo_set_rx_mode,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index ece0ea0..4a3eeb1 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -772,7 +772,6 @@ static const struct net_device_ops tlan_netdev_ops = {
 	.ndo_get_stats		= tlan_get_stats,
 	.ndo_set_rx_mode	= tlan_set_multicast_list,
 	.ndo_do_ioctl		= tlan_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 5b01b3f..3be61ed 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -747,7 +747,6 @@ static const struct net_device_ops tc35815_netdev_ops = {
 	.ndo_tx_timeout		= tc35815_tx_timeout,
 	.ndo_do_ioctl		= tc35815_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tc35815_poll_controller,
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 8fd1312..f153ad7 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1548,7 +1548,6 @@ static const struct net_device_ops tsi108_netdev_ops = {
 	.ndo_do_ioctl		= tsi108_do_ioctl,
 	.ndo_set_mac_address	= tsi108_set_mac,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 9d14731..ba5c542 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -890,7 +890,6 @@ static const struct net_device_ops rhine_netdev_ops = {
 	.ndo_start_xmit		 = rhine_start_tx,
 	.ndo_get_stats64	 = rhine_get_stats64,
 	.ndo_set_rx_mode	 = rhine_set_rx_mode,
-	.ndo_change_mtu		 = eth_change_mtu,
 	.ndo_validate_addr	 = eth_validate_addr,
 	.ndo_set_mac_address 	 = eth_mac_addr,
 	.ndo_do_ioctl		 = netdev_ioctl,
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 37ab46c..51a45ea 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -1046,7 +1046,6 @@ static const struct net_device_ops w5100_netdev_ops = {
 	.ndo_set_rx_mode	= w5100_set_rx_mode,
 	.ndo_set_mac_address	= w5100_set_macaddr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int w5100_mmio_probe(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 0b37ce9..32a29f3 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -537,7 +537,6 @@ static const struct net_device_ops w5300_netdev_ops = {
 	.ndo_set_rx_mode	= w5300_set_rx_mode,
 	.ndo_set_mac_address	= w5300_set_macaddr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int w5300_hw_probe(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index ddced28..3b08ec7 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -466,7 +466,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_set_config		= do_config,
 	.ndo_do_ioctl		= do_ioctl,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 7f127dc..46cc33b 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1379,7 +1379,6 @@ static const struct net_device_ops ixp4xx_netdev_ops = {
 	.ndo_start_xmit = eth_xmit,
 	.ndo_set_rx_mode = eth_set_mcast_list,
 	.ndo_do_ioctl = eth_ioctl,
-	.ndo_change_mtu = eth_change_mtu,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
 };
diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index 9c4b41a..3c55ea3 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -270,7 +270,6 @@ static const struct net_device_ops plip_netdev_ops = {
 	.ndo_stop		 = plip_close,
 	.ndo_start_xmit		 = plip_tx_packet,
 	.ndo_do_ioctl		 = plip_ioctl,
-	.ndo_change_mtu		 = eth_change_mtu,
 	.ndo_set_mac_address	 = eth_mac_addr,
 	.ndo_validate_addr	 = eth_validate_addr,
 };
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index aad0b59..8b8b532 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -141,7 +141,6 @@ static const struct net_device_ops sb1000_netdev_ops = {
 	.ndo_start_xmit		= sb1000_start_xmit,
 	.ndo_do_ioctl		= sb1000_dev_ioctl,
 	.ndo_stop		= sb1000_close,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index d9ca05d..a1f2f6f 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -761,7 +761,6 @@ static const struct net_device_ops catc_netdev_ops = {
 
 	.ndo_tx_timeout		= catc_tx_timeout,
 	.ndo_set_rx_mode	= catc_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 66b34dd..338aed5 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -982,7 +982,6 @@ static const struct net_device_ops kaweth_netdev_ops = {
 	.ndo_tx_timeout =		kaweth_tx_timeout,
 	.ndo_set_rx_mode =		kaweth_set_rx_mode,
 	.ndo_get_stats =		kaweth_netdev_stats,
-	.ndo_change_mtu =		eth_change_mtu,
 	.ndo_set_mac_address =		eth_mac_addr,
 	.ndo_validate_addr =		eth_validate_addr,
 };
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 1434e5d..399f7ee 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1273,7 +1273,6 @@ static const struct net_device_ops pegasus_netdev_ops = {
 	.ndo_set_rx_mode =		pegasus_set_multicast,
 	.ndo_get_stats =		pegasus_netdev_stats,
 	.ndo_tx_timeout =		pegasus_tx_timeout,
-	.ndo_change_mtu =		eth_change_mtu,
 	.ndo_set_mac_address =		eth_mac_addr,
 	.ndo_validate_addr =		eth_validate_addr,
 };
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 44d439f..2886946 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4113,7 +4113,8 @@ static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
 	switch (tp->version) {
 	case RTL_VER_01:
 	case RTL_VER_02:
-		return eth_change_mtu(dev, new_mtu);
+		dev->mtu = new_mtu;
+		return 0;
 	default:
 		break;
 	}
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 7c72bfa..93a1bda 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -847,7 +847,6 @@ static const struct net_device_ops rtl8150_netdev_ops = {
 	.ndo_set_rx_mode	= rtl8150_set_multicast,
 	.ndo_set_mac_address	= rtl8150_set_mac_address,
 
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 3a421ca..3f83be9 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -211,7 +211,6 @@ static const struct net_device_ops sbni_netdev_ops = {
 	.ndo_start_xmit		= sbni_start_xmit,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_do_ioctl		= sbni_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/wireless/intersil/prism54/islpci_dev.c b/drivers/net/wireless/intersil/prism54/islpci_dev.c
index 84a4201..325176d 100644
--- a/drivers/net/wireless/intersil/prism54/islpci_dev.c
+++ b/drivers/net/wireless/intersil/prism54/islpci_dev.c
@@ -808,7 +808,6 @@ static const struct net_device_ops islpci_netdev_ops = {
 	.ndo_start_xmit		= islpci_eth_transmit,
 	.ndo_tx_timeout		= islpci_eth_tx_timeout,
 	.ndo_set_mac_address 	= prism54_set_mac_address,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 431f13b..e95b79b 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2791,7 +2791,6 @@ static void mac80211_hwsim_free(void)
 
 static const struct net_device_ops hwsim_netdev_ops = {
 	.ndo_start_xmit 	= hwsim_mon_xmit,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/wireless/marvell/libertas/main.c b/drivers/net/wireless/marvell/libertas/main.c
index 8541cbe..e350020 100644
--- a/drivers/net/wireless/marvell/libertas/main.c
+++ b/drivers/net/wireless/marvell/libertas/main.c
@@ -945,7 +945,6 @@ static const struct net_device_ops lbs_netdev_ops = {
 	.ndo_start_xmit		= lbs_hard_start_xmit,
 	.ndo_set_mac_address	= lbs_set_mac_address,
 	.ndo_set_rx_mode	= lbs_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 0881ba8..4fdc722 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -272,7 +272,6 @@ static const struct net_device_ops ray_netdev_ops = {
 	.ndo_set_config		= ray_dev_config,
 	.ndo_get_stats		= ray_get_stats,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 932f3f8..d9d29ab 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1853,7 +1853,6 @@ static const struct net_device_ops wl3501_netdev_ops = {
 	.ndo_stop		= wl3501_close,
 	.ndo_start_xmit		= wl3501_hard_start_xmit,
 	.ndo_tx_timeout		= wl3501_tx_timeout,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/wireless/zydas/zd1201.c b/drivers/net/wireless/zydas/zd1201.c
index dea049b..de7ff39 100644
--- a/drivers/net/wireless/zydas/zd1201.c
+++ b/drivers/net/wireless/zydas/zd1201.c
@@ -1724,7 +1724,6 @@ static const struct net_device_ops zd1201_netdev_ops = {
 	.ndo_tx_timeout		= zd1201_tx_timeout,
 	.ndo_set_rx_mode	= zd1201_set_multicast,
 	.ndo_set_mac_address	= zd1201_set_mac_address,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/staging/rtl8188eu/os_dep/mon.c b/drivers/staging/rtl8188eu/os_dep/mon.c
index d976e5e..c9c9821 100644
--- a/drivers/staging/rtl8188eu/os_dep/mon.c
+++ b/drivers/staging/rtl8188eu/os_dep/mon.c
@@ -145,7 +145,6 @@ static netdev_tx_t mon_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static const struct net_device_ops mon_netdev_ops = {
 	.ndo_start_xmit		= mon_xmit,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
index 4c30eea..5f53fbd 100644
--- a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
+++ b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
@@ -2545,7 +2545,6 @@ static const struct net_device_ops rtl8192_netdev_ops = {
 	.ndo_set_rx_mode = _rtl92e_set_multicast,
 	.ndo_set_mac_address = _rtl92e_set_mac_adr,
 	.ndo_validate_addr = eth_validate_addr,
-	.ndo_change_mtu = eth_change_mtu,
 	.ndo_start_xmit = rtllib_xmit,
 };
 
diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
index 457eeb5..fdb03dc 100644
--- a/drivers/staging/rtl8192u/r8192U_core.c
+++ b/drivers/staging/rtl8192u/r8192U_core.c
@@ -4930,7 +4930,6 @@ static const struct net_device_ops rtl8192_netdev_ops = {
 	.ndo_set_rx_mode	= r8192_set_multicast,
 	.ndo_set_mac_address    = r8192_set_mac_adr,
 	.ndo_validate_addr      = eth_validate_addr,
-	.ndo_change_mtu         = eth_change_mtu,
 	.ndo_start_xmit         = ieee80211_xmit,
 };
 
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 062307a..2802b90 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -2880,7 +2880,6 @@ static const struct net_device_ops slic_netdev_ops = {
 	.ndo_get_stats		= slic_get_stats,
 	.ndo_set_rx_mode	= slic_mcast_set_list,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static u32 slic_card_locate(struct adapter *adapter)
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 117d02e..864d6f2 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -35,6 +35,8 @@
 #define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
 #define ETH_FCS_LEN	4		/* Octets in the FCS		 */
 
+#define ETH_MIN_MTU	68		/* Min IPv4 MTU per RFC791	*/
+
 /*
  *	These are the defined Ethernet Protocol ID's.
  */
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index aa0047c..c7d82f4 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -620,14 +620,12 @@ error:
 static const struct net_device_ops br2684_netdev_ops = {
 	.ndo_start_xmit 	= br2684_start_xmit,
 	.ndo_set_mac_address	= br2684_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
 static const struct net_device_ops br2684_netdev_ops_routed = {
 	.ndo_start_xmit 	= br2684_start_xmit,
 	.ndo_set_mac_address	= br2684_mac_addr,
-	.ndo_change_mtu		= eth_change_mtu
 };
 
 static void br2684_setup(struct net_device *netdev)
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index f4fcb4a..0f25ddc 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -211,7 +211,6 @@ static const struct net_device_ops bnep_netdev_ops = {
 	.ndo_set_rx_mode     = bnep_net_set_mc_list,
 	.ndo_set_mac_address = bnep_net_set_mac_addr,
 	.ndo_tx_timeout      = bnep_net_timeout,
-	.ndo_change_mtu	     = eth_change_mtu,
 
 };
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 66dff5e..f983c10 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -322,8 +322,7 @@ EXPORT_SYMBOL(eth_mac_addr);
  */
 int eth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu < 68 || new_mtu > ETH_DATA_LEN)
-		return -EINVAL;
+	netdev_warn(dev, "%s is deprecated\n", __func__);
 	dev->mtu = new_mtu;
 	return 0;
 }
@@ -357,6 +356,8 @@ void ether_setup(struct net_device *dev)
 	dev->type		= ARPHRD_ETHER;
 	dev->hard_header_len 	= ETH_HLEN;
 	dev->mtu		= ETH_DATA_LEN;
+	dev->min_mtu		= ETH_MIN_MTU;
+	dev->max_mtu		= ETH_DATA_LEN;
 	dev->addr_len		= ETH_ALEN;
 	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index d8b7267..8192eae 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -51,7 +51,6 @@ static const struct net_device_ops irlan_eth_netdev_ops = {
 	.ndo_stop		= irlan_eth_close,
 	.ndo_start_xmit		= irlan_eth_xmit,
 	.ndo_set_rx_mode	= irlan_eth_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-- 
2.10.0
