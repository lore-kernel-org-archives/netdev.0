From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 0/3] net: remove ndo_set_multicast_list
Date: Tue, 16 Aug 2011 18:28:59 +0200
Message-ID: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	rdunlap@xenotime.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	mirqus@gmail.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752574Ab1HPSBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 14:01:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we have 2 callbacks exported to drivers to set rx filtering:
ndo_set_multicast_list
ndo_set_rx_mode

The second one was added with second unicast address list and only drivers
that are able to handle unicast filtering should use that. 

Having these two together is confusing and as I found out in many drivers,
developers are not using them properly. So just kill one of them.
ndo_set_multicast_list gets the bullet because I believe that name "set_rx_mode"
is more appropriate.

IFF_UNICAST_FLT flag is used so core know if driver handles unicast filtering.

applies cleanly on most recent net-next with "[patch net-next-2.6 v2] bonding: use ndo_change_rx_flags callback"

Jiri Pirko (3):
  net: introduce IFF_UNICAST_FLT private flag
  net: remove use of ndo_set_multicast_list in drivers
  net: remove ndo_set_multicast_list callback

 Documentation/networking/netdevices.txt            |    4 ++--
 arch/ia64/hp/sim/simeth.c                          |    2 +-
 arch/um/drivers/net_kern.c                         |    2 +-
 arch/xtensa/platforms/iss/network.c                |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c                |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |    2 +-
 drivers/media/dvb/dvb-core/dvb_net.c               |    2 +-
 drivers/net/appletalk/cops.c                       |    2 +-
 drivers/net/appletalk/ltpc.c                       |    2 +-
 drivers/net/arcnet/com20020.c                      |    2 +-
 drivers/net/bonding/bond_main.c                    |    2 +-
 drivers/net/cris/eth_v10.c                         |    2 +-
 drivers/net/defxx.c                                |    2 +-
 drivers/net/dummy.c                                |    2 +-
 drivers/net/ethernet/3com/3c501.c                  |    2 +-
 drivers/net/ethernet/3com/3c509.c                  |    2 +-
 drivers/net/ethernet/3com/3c515.c                  |    2 +-
 drivers/net/ethernet/3com/3c574_cs.c               |    2 +-
 drivers/net/ethernet/3com/3c589_cs.c               |    2 +-
 drivers/net/ethernet/3com/3c59x.c                  |    4 ++--
 drivers/net/ethernet/3com/typhoon.c                |    2 +-
 drivers/net/ethernet/8390/3c503.c                  |    2 +-
 drivers/net/ethernet/8390/8390.c                   |    2 +-
 drivers/net/ethernet/8390/8390p.c                  |    2 +-
 drivers/net/ethernet/8390/ac3200.c                 |    2 +-
 drivers/net/ethernet/8390/ax88796.c                |    2 +-
 drivers/net/ethernet/8390/axnet_cs.c               |    2 +-
 drivers/net/ethernet/8390/e2100.c                  |    2 +-
 drivers/net/ethernet/8390/etherh.c                 |    2 +-
 drivers/net/ethernet/8390/hp-plus.c                |    2 +-
 drivers/net/ethernet/8390/hydra.c                  |    2 +-
 drivers/net/ethernet/8390/mac8390.c                |    2 +-
 drivers/net/ethernet/8390/ne-h8300.c               |    2 +-
 drivers/net/ethernet/8390/ne2k-pci.c               |    2 +-
 drivers/net/ethernet/8390/pcnet_cs.c               |    2 +-
 drivers/net/ethernet/8390/smc-mca.c                |    2 +-
 drivers/net/ethernet/8390/smc-ultra.c              |    2 +-
 drivers/net/ethernet/8390/smc-ultra32.c            |    2 +-
 drivers/net/ethernet/8390/wd.c                     |    2 +-
 drivers/net/ethernet/8390/zorro8390.c              |    2 +-
 drivers/net/ethernet/adaptec/starfire.c            |    2 +-
 drivers/net/ethernet/adi/bfin_mac.c                |    2 +-
 drivers/net/ethernet/aeroflex/greth.c              |    2 +-
 drivers/net/ethernet/alteon/acenic.c               |    2 +-
 drivers/net/ethernet/amd/a2065.c                   |    2 +-
 drivers/net/ethernet/amd/am79c961a.c               |    2 +-
 drivers/net/ethernet/amd/amd8111e.c                |    2 +-
 drivers/net/ethernet/amd/ariadne.c                 |    2 +-
 drivers/net/ethernet/amd/atarilance.c              |    2 +-
 drivers/net/ethernet/amd/au1000_eth.c              |    2 +-
 drivers/net/ethernet/amd/declance.c                |    2 +-
 drivers/net/ethernet/amd/depca.c                   |    2 +-
 drivers/net/ethernet/amd/hplance.c                 |    2 +-
 drivers/net/ethernet/amd/lance.c                   |    2 +-
 drivers/net/ethernet/amd/mvme147.c                 |    2 +-
 drivers/net/ethernet/amd/ni65.c                    |    2 +-
 drivers/net/ethernet/amd/nmclan_cs.c               |    2 +-
 drivers/net/ethernet/amd/pcnet32.c                 |    2 +-
 drivers/net/ethernet/amd/sun3lance.c               |    2 +-
 drivers/net/ethernet/amd/sunlance.c                |    2 +-
 drivers/net/ethernet/apple/bmac.c                  |    2 +-
 drivers/net/ethernet/apple/cs89x0.c                |    2 +-
 drivers/net/ethernet/apple/mac89x0.c               |    2 +-
 drivers/net/ethernet/apple/mace.c                  |    2 +-
 drivers/net/ethernet/apple/macmace.c               |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |    2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c           |    2 +-
 drivers/net/ethernet/broadcom/b44.c                |    2 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c               |    2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    3 +++
 drivers/net/ethernet/broadcom/sb1250-mac.c         |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    2 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |    1 -
 drivers/net/ethernet/cadence/at91_ether.c          |    2 +-
 drivers/net/ethernet/cadence/macb.c                |    2 +-
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    3 +++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 ++
 drivers/net/ethernet/cisco/enic/enic_main.c        |    5 +++--
 drivers/net/ethernet/davicom/dm9000.c              |    2 +-
 drivers/net/ethernet/dec/ewrk3.c                   |    2 +-
 drivers/net/ethernet/dec/tulip/de2104x.c           |    2 +-
 drivers/net/ethernet/dec/tulip/de4x5.c             |    2 +-
 drivers/net/ethernet/dec/tulip/dmfe.c              |    2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c        |    2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c           |    2 +-
 drivers/net/ethernet/dec/tulip/winbond-840.c       |    2 +-
 drivers/net/ethernet/dlink/de620.c                 |    2 +-
 drivers/net/ethernet/dlink/dl2k.c                  |    2 +-
 drivers/net/ethernet/dlink/sundance.c              |    2 +-
 drivers/net/ethernet/ethoc.c                       |    2 +-
 drivers/net/ethernet/fealnx.c                      |    2 +-
 drivers/net/ethernet/freescale/fec.c               |    2 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    2 +-
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    2 +-
 drivers/net/ethernet/freescale/gianfar.c           |    2 +-
 drivers/net/ethernet/freescale/ucc_geth.c          |    2 +-
 drivers/net/ethernet/fujitsu/at1700.c              |    2 +-
 drivers/net/ethernet/fujitsu/eth16i.c              |    2 +-
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c          |    2 +-
 drivers/net/ethernet/hp/hp100.c                    |    4 ++--
 drivers/net/ethernet/i825xx/3c505.c                |    2 +-
 drivers/net/ethernet/i825xx/3c523.c                |    2 +-
 drivers/net/ethernet/i825xx/3c527.c                |    2 +-
 drivers/net/ethernet/i825xx/82596.c                |    2 +-
 drivers/net/ethernet/i825xx/eepro.c                |    2 +-
 drivers/net/ethernet/i825xx/eexpress.c             |    2 +-
 drivers/net/ethernet/i825xx/ether1.c               |    2 +-
 drivers/net/ethernet/i825xx/lib82596.c             |    2 +-
 drivers/net/ethernet/i825xx/lp486e.c               |    2 +-
 drivers/net/ethernet/i825xx/ni52.c                 |    2 +-
 drivers/net/ethernet/i825xx/sun3_82586.c           |    2 +-
 drivers/net/ethernet/i825xx/znet.c                 |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |    2 +-
 drivers/net/ethernet/ibm/emac/core.c               |    4 ++--
 drivers/net/ethernet/ibm/ibmveth.c                 |    2 +-
 drivers/net/ethernet/ibm/iseries_veth.c            |    2 +-
 drivers/net/ethernet/icplus/ipg.c                  |    2 +-
 drivers/net/ethernet/intel/e100.c                  |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    2 ++
 drivers/net/ethernet/intel/e1000e/netdev.c         |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    4 +++-
 drivers/net/ethernet/intel/igbvf/netdev.c          |    2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    4 +++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    4 +++-
 drivers/net/ethernet/jme.c                         |    2 +-
 drivers/net/ethernet/korina.c                      |    2 +-
 drivers/net/ethernet/lantiq_etop.c                 |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    2 ++
 drivers/net/ethernet/marvell/skge.c                |    2 +-
 drivers/net/ethernet/marvell/sky2.c                |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    2 +-
 drivers/net/ethernet/micrel/ks8695net.c            |    2 +-
 drivers/net/ethernet/microchip/enc28j60.c          |    2 +-
 drivers/net/ethernet/mipsnet.c                     |    2 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |    2 +-
 drivers/net/ethernet/natsemi/ibmlana.c             |    2 +-
 drivers/net/ethernet/natsemi/jazzsonic.c           |    2 +-
 drivers/net/ethernet/natsemi/macsonic.c            |    2 +-
 drivers/net/ethernet/natsemi/natsemi.c             |    2 +-
 drivers/net/ethernet/natsemi/ns83820.c             |    2 +-
 drivers/net/ethernet/natsemi/xtsonic.c             |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |    2 +-
 drivers/net/ethernet/netx-eth.c                    |    2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |    4 ++--
 drivers/net/ethernet/octeon/octeon_mgmt.c          |    4 +++-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    2 +-
 drivers/net/ethernet/packetengines/hamachi.c       |    2 +-
 drivers/net/ethernet/packetengines/yellowfin.c     |    2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qla3xxx.c              |    1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |    2 +-
 drivers/net/ethernet/racal/ni5010.c                |    2 +-
 drivers/net/ethernet/rdc/r6040.c                   |    2 +-
 drivers/net/ethernet/realtek/8139cp.c              |    2 +-
 drivers/net/ethernet/realtek/8139too.c             |    2 +-
 drivers/net/ethernet/realtek/atp.c                 |    2 +-
 drivers/net/ethernet/realtek/r8169.c               |    2 +-
 drivers/net/ethernet/realtek/sc92031.c             |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    2 +-
 drivers/net/ethernet/seeq/ether3.c                 |    2 +-
 drivers/net/ethernet/seeq/seeq8005.c               |    2 +-
 drivers/net/ethernet/seeq/sgiseeq.c                |    2 +-
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/ethernet/sgi/ioc3-eth.c                |    2 +-
 drivers/net/ethernet/sis/sis190.c                  |    2 +-
 drivers/net/ethernet/sis/sis900.c                  |    2 +-
 drivers/net/ethernet/smsc/epic100.c                |    2 +-
 drivers/net/ethernet/smsc/smc911x.c                |    2 +-
 drivers/net/ethernet/smsc/smc9194.c                |    2 +-
 drivers/net/ethernet/smsc/smc91c92_cs.c            |    2 +-
 drivers/net/ethernet/smsc/smc91x.c                 |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c               |    2 +-
 drivers/net/ethernet/smsc/smsc9420.c               |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   13 ++++++++-----
 drivers/net/ethernet/sun/cassini.c                 |    2 +-
 drivers/net/ethernet/sun/niu.c                     |    5 ++++-
 drivers/net/ethernet/sun/sunbmac.c                 |    2 +-
 drivers/net/ethernet/sun/sungem.c                  |    2 +-
 drivers/net/ethernet/sun/sunhme.c                  |    2 +-
 drivers/net/ethernet/sun/sunqe.c                   |    2 +-
 drivers/net/ethernet/sun/sunvnet.c                 |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c               |    2 +-
 drivers/net/ethernet/ti/cpmac.c                    |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |    2 +-
 drivers/net/ethernet/ti/tlan.c                     |    2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       |    2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |    2 +-
 drivers/net/ethernet/toshiba/spider_net.c          |    2 +-
 drivers/net/ethernet/toshiba/tc35815.c             |    2 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           |    2 +-
 drivers/net/ethernet/via/via-rhine.c               |    2 +-
 drivers/net/ethernet/via/via-velocity.c            |    2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    1 -
 drivers/net/ethernet/xircom/xirc2ps_cs.c           |    2 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |    2 +-
 drivers/net/macvlan.c                              |    2 +-
 drivers/net/skfp/skfddi.c                          |    2 +-
 drivers/net/tokenring/3c359.c                      |    2 +-
 drivers/net/tokenring/ibmtr.c                      |    2 +-
 drivers/net/tokenring/lanstreamer.c                |    2 +-
 drivers/net/tokenring/olympic.c                    |    2 +-
 drivers/net/tokenring/smctr.c                      |    2 +-
 drivers/net/tokenring/tms380tr.c                   |    2 +-
 drivers/net/tun.c                                  |    2 +-
 drivers/net/usb/asix.c                             |    6 +++---
 drivers/net/usb/catc.c                             |    2 +-
 drivers/net/usb/dm9601.c                           |    2 +-
 drivers/net/usb/int51x1.c                          |    2 +-
 drivers/net/usb/kaweth.c                           |    2 +-
 drivers/net/usb/mcs7830.c                          |    2 +-
 drivers/net/usb/pegasus.c                          |    2 +-
 drivers/net/usb/rtl8150.c                          |    2 +-
 drivers/net/usb/smsc75xx.c                         |    2 +-
 drivers/net/usb/smsc95xx.c                         |    2 +-
 drivers/net/virtio_net.c                           |    1 +
 drivers/net/vmxnet3/vmxnet3_drv.c                  |    2 +-
 drivers/net/wan/sbni.c                             |    2 +-
 drivers/net/wireless/airo.c                        |    4 ++--
 drivers/net/wireless/hostap/hostap_main.c          |    6 +++---
 drivers/net/wireless/ipw2x00/ipw2200.c             |    2 +-
 drivers/net/wireless/libertas/main.c               |    2 +-
 drivers/net/wireless/libertas/mesh.c               |    2 +-
 drivers/net/wireless/mwifiex/main.c                |    2 +-
 drivers/net/wireless/orinoco/main.c                |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    2 +-
 drivers/net/wireless/ray_cs.c                      |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |    2 +-
 drivers/net/wireless/zd1201.c                      |    2 +-
 drivers/s390/net/lcs.c                             |    2 +-
 drivers/s390/net/qeth_l2_main.c                    |    2 +-
 drivers/s390/net/qeth_l3_main.c                    |    4 ++--
 drivers/staging/ath6kl/os/linux/ar6000_drv.c       |    2 +-
 drivers/staging/brcm80211/brcmfmac/dhd_linux.c     |    2 +-
 drivers/staging/et131x/et131x_netdev.c             |    2 +-
 drivers/staging/hv/netvsc_drv.c                    |    2 +-
 drivers/staging/octeon/ethernet.c                  |   12 ++++++------
 drivers/staging/rtl8187se/r8180_core.c             |    2 +-
 drivers/staging/rtl8192e/r8192E_core.c             |    2 +-
 drivers/staging/rtl8192u/r8192U_core.c             |    2 +-
 drivers/staging/slicoss/slicoss.c                  |    2 +-
 drivers/staging/vt6655/device_main.c               |    2 +-
 drivers/staging/vt6656/main_usb.c                  |    2 +-
 drivers/staging/wlags49_h2/wl_netdev.c             |    2 +-
 drivers/staging/wlan-ng/p80211netdev.c             |    2 +-
 include/linux/if.h                                 |    1 +
 include/linux/netdevice.h                          |    6 ++----
 net/8021q/vlan_dev.c                               |    1 -
 net/atm/lec.c                                      |    2 +-
 net/bluetooth/bnep/netdev.c                        |    2 +-
 net/bridge/br_device.c                             |    2 +-
 net/core/dev.c                                     |   14 ++++++--------
 net/core/dev_addr_lists.c                          |    4 ++--
 net/dsa/slave.c                                    |    3 ---
 net/ipv4/igmp.c                                    |    2 +-
 net/irda/irlan/irlan_eth.c                         |    2 +-
 net/mac80211/iface.c                               |    4 ++--
 266 files changed, 314 insertions(+), 294 deletions(-)

-- 
1.7.6

