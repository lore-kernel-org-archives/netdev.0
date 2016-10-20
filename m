From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next v2 0/9] net: use core MTU range checking everywhere
Date: Thu, 20 Oct 2016 13:55:15 -0400
Message-ID: <20161020175524.6184-1-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47400 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752359AbcJTRze (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 13:55:34 -0400
In-Reply-To: <20161019023333.15760-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This stack of patches should get absolutely everything in the kernel
converted from doing their own MTU range checking to the core MTU range
checking. This second spin includes alterations to hopefully fix all
concerns raised with the first, as well as including some additional
changes to drivers and infrastructure where I completely missed necessary
updates.

These have all been built through the 0-day build infrastructure via the
(rebasing) master branch at https://github.com/jarodwilson/linux-muck, which
at the time of the most recent compile across 147 configs, was based on
net-next at commit 7b1536ef0aa0.

Jarod Wilson (9):
  ethernet: use net core MTU range checking in more drivers
  net: use core MTU range checking in USB NIC drivers
  net: use core MTU range checking in wireless drivers
  net: use core MTU range checking in WAN drivers
  net: use core MTU range checking in core net infra
  net: use core MTU range checking in virt drivers
  net: use core MTU range checking in misc drivers
  s390/net: use net core MTU range checking
  ipv4/6: use core net MTU range checking

CC: netdev@vger.kernel.org

 arch/um/drivers/net_kern.c                         |  8 ---
 drivers/char/pcmcia/synclink_cs.c                  |  1 -
 drivers/firewire/net.c                             | 18 ++----
 drivers/hsi/clients/ssi_protocol.c                 | 14 ++---
 drivers/infiniband/hw/nes/nes.c                    |  1 -
 drivers/infiniband/hw/nes/nes.h                    |  4 +-
 drivers/infiniband/hw/nes/nes_nic.c                | 10 +---
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |  1 +
 drivers/message/fusion/mptlan.c                    | 15 ++---
 drivers/misc/sgi-xp/xpnet.c                        | 21 ++-----
 drivers/net/ethernet/alteon/acenic.c               |  5 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c       |  9 +--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  5 --
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |  2 +
 drivers/net/ethernet/broadcom/sb1250-mac.c         | 12 +---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |  4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  6 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  6 +-
 drivers/net/ethernet/emulex/benet/be_main.c        | 22 ++------
 drivers/net/ethernet/ibm/ibmveth.c                 |  6 +-
 drivers/net/ethernet/ibm/ibmvnic.c                 | 16 ++----
 drivers/net/ethernet/jme.c                         | 12 ++--
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  7 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  3 +
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |  3 +
 drivers/net/ethernet/natsemi/ns83820.c             | 11 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c | 12 ----
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  7 +++
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |  7 +++
 drivers/net/ethernet/qualcomm/emac/emac.c          | 13 ++---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |  7 ++-
 drivers/net/fddi/skfp/skfddi.c                     |  1 -
 drivers/net/fjes/fjes_main.c                       |  2 +
 drivers/net/geneve.c                               | 48 +++++++---------
 drivers/net/hippi/rrunner.c                        |  1 -
 drivers/net/hyperv/hyperv_net.h                    |  4 +-
 drivers/net/hyperv/netvsc_drv.c                    | 14 ++---
 drivers/net/macsec.c                               |  2 +
 drivers/net/macvlan.c                              |  8 ++-
 drivers/net/ntb_netdev.c                           |  3 +
 drivers/net/rionet.c                               | 15 +----
 drivers/net/slip/slip.c                            | 11 ++--
 drivers/net/tun.c                                  | 20 ++-----
 drivers/net/usb/asix_devices.c                     |  4 +-
 drivers/net/usb/ax88179_178a.c                     |  4 +-
 drivers/net/usb/cdc-phonet.c                       | 12 +---
 drivers/net/usb/cdc_ncm.c                          |  5 +-
 drivers/net/usb/lan78xx.c                          |  8 +--
 drivers/net/usb/r8152.c                            | 15 ++++-
 drivers/net/usb/sierra_net.c                       | 13 +----
 drivers/net/usb/smsc75xx.c                         |  4 +-
 drivers/net/usb/usbnet.c                           |  4 +-
 drivers/net/veth.c                                 | 17 +-----
 drivers/net/virtio_net.c                           | 23 ++++----
 drivers/net/vmxnet3/vmxnet3_drv.c                  |  7 ++-
 drivers/net/vxlan.c                                | 64 ++++++++++++----------
 drivers/net/wan/c101.c                             |  1 -
 drivers/net/wan/cosa.c                             |  1 -
 drivers/net/wan/dscc4.c                            |  1 -
 drivers/net/wan/farsync.c                          |  1 -
 drivers/net/wan/fsl_ucc_hdlc.c                     |  1 -
 drivers/net/wan/hdlc.c                             | 11 +---
 drivers/net/wan/hdlc_fr.c                          |  3 +-
 drivers/net/wan/hostess_sv11.c                     |  1 -
 drivers/net/wan/ixp4xx_hss.c                       |  1 -
 drivers/net/wan/lmc/lmc_main.c                     |  1 -
 drivers/net/wan/n2.c                               |  1 -
 drivers/net/wan/pc300too.c                         |  1 -
 drivers/net/wan/pci200syn.c                        |  1 -
 drivers/net/wan/sealevel.c                         |  1 -
 drivers/net/wan/wanxl.c                            |  1 -
 drivers/net/wan/x25_asy.c                          |  5 +-
 drivers/net/wimax/i2400m/netdev.c                  | 22 +-------
 drivers/net/wireless/ath/wil6210/netdev.c          | 17 +-----
 drivers/net/wireless/atmel/atmel.c                 | 13 ++---
 drivers/net/wireless/cisco/airo.c                  | 14 +----
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |  3 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |  8 ++-
 drivers/net/wireless/intel/ipw2x00/libipw.h        |  1 -
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |  9 ---
 drivers/net/wireless/intersil/hostap/hostap_main.c | 15 +----
 drivers/net/wireless/intersil/orinoco/main.c       |  6 +-
 drivers/net/xen-netback/interface.c                |  5 +-
 drivers/net/xen-netfront.c                         |  2 +
 drivers/s390/net/ctcm_main.c                       |  5 +-
 drivers/s390/net/netiucv.c                         | 24 +-------
 drivers/s390/net/qeth_core_main.c                  |  4 --
 drivers/s390/net/qeth_l2_main.c                    |  2 +
 drivers/s390/net/qeth_l3_main.c                    |  2 +
 drivers/staging/unisys/include/iochannel.h         | 10 ++--
 drivers/staging/unisys/visornic/visornic_main.c    |  4 +-
 drivers/staging/wlan-ng/p80211netdev.c             | 18 ++----
 drivers/tty/n_gsm.c                                | 12 +---
 drivers/tty/synclink.c                             |  1 -
 drivers/tty/synclink_gt.c                          |  1 -
 drivers/tty/synclinkmp.c                           |  1 -
 drivers/usb/gadget/function/f_phonet.c             | 11 +---
 drivers/usb/gadget/function/u_ether.c              | 14 ++---
 include/linux/fddidevice.h                         |  1 -
 include/linux/hdlc.h                               |  2 -
 include/linux/hippidevice.h                        |  1 -
 include/uapi/linux/if_ether.h                      |  1 +
 net/802/fddi.c                                     | 11 +---
 net/802/hippi.c                                    | 14 +----
 net/8021q/vlan_dev.c                               |  3 +
 net/atm/lec.c                                      | 11 +---
 net/batman-adv/soft-interface.c                    | 13 +----
 net/bridge/br_device.c                             |  3 +-
 net/hsr/hsr_device.c                               |  1 +
 net/ipv4/ip_tunnel.c                               |  6 +-
 net/ipv6/ip6_tunnel.c                              |  4 +-
 net/ipv6/ip6_vti.c                                 | 21 +------
 net/ipv6/sit.c                                     | 14 +----
 net/mac80211/iface.c                               | 15 ++---
 net/openvswitch/vport-internal_dev.c               | 10 ----
 net/phonet/pep-gprs.c                              | 12 +---
 net/sched/sch_teql.c                               |  5 +-
 117 files changed, 316 insertions(+), 665 deletions(-)

-- 
2.10.0
