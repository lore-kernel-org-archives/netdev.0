From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [RFC][PATCH 00/50] set addr_assign_type to NET_ADDR_RANDOM if  a random mac address get assigned to a netdevice
Date: Wed,  8 Feb 2012 22:10:07 +0100
Message-ID: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The information if a device has a random MAC address is exported
to the userspace via /sys/class/net/*/addr_assign_type, which
export net_device->addr_assign_type.

Currently only a few driver really use dev_hw_addr_random() to
set addr_assign_type correctly to NET_ADDR_RANDOM.

This patch change the drivers which set random addresses to
change also addr_assign_type to NET_ADDR_RANDOM.

To reflect if the MAC was changed from userspace via SIOCSIFHWADDR,
which means it's no longer a random address set by the kernel,
this patch remove NET_ADDR_RANDOM from addr_assign_type in this
case.

With this patch tools from userspace can now detect devices with
random MAC addresses and change them to persistent addresses if
needed (as e.g. in case of smsc95xx on PandaBoard).

Maybe it makes sense to introduce a new state for addr_assign_type
to reflect the fact, that the MAC address was changed via a ioctl
from user space, e.g, with NET_ADDR_USERSPACE ?

Danny Kukawka (50):
  eth: reset addr_assign_type if eth_mac_addr() called
  smsc95xx: use dev_hw_addr_random() instead of random_ether_addr()
  smsc75xx: se dev_hw_addr_random() instead of random_ether_addr()
  adi/blackfin: set addr_assign_type correctly if random
  UML net: set addr_assign_type if random_ether_addr() used
  dummy: use dev_hw_addr_random() instead of random_ether_addr()
  au1000_eth: use dev_hw_addr_random() instead of random_ether_addr()
  bnx2x: use dev_hw_addr_random() instead of random_ether_addr()
  Cadence MACB: use dev_hw_addr_random() instead of random_ether_addr()
  Calxeda XGMAC: use dev_hw_addr_random() instead of
    random_ether_addr()
  ep93xx: use dev_hw_addr_random() instead of random_ether_addr()
  dm9000: use dev_hw_addr_random() instead of random_ether_addr()
  dnet: use dev_hw_addr_random() instead of random_ether_addr()
  ethoc: set addr_assign_type if random_ether_addr() used
  lantiq_etop: set addr_assign_type if random_ether_addr() used
  pxa168_eth: use dev_hw_addr_random() instead of random_ether_addr()
  enc28j60: use dev_hw_addr_random() instead of random_ether_addr()
  mipsnet: use dev_hw_addr_random() instead of random_ether_addr()
  macsonic: use dev_hw_addr_random() instead of random_ether_addr()
  smsc911x: use dev_hw_addr_random() instead of random_ether_addr()
  smsc9420: use dev_hw_addr_random() instead of random_ether_addr()
  r6040: use dev_hw_addr_random() instead of random_ether_addr()
  efx: use dev_hw_addr_random() instead of random_ether_addr()
  sis900: use dev_hw_addr_random() instead of random_ether_addr()
  via-rhine: use dev_hw_addr_random() instead of random_ether_addr()
  faraday: use dev_hw_addr_random() instead of random_ether_addr()
  davinci_emac: use dev_hw_addr_random() instead of random_ether_addr()
  forcedeth: use dev_hw_addr_random() instead of random_ether_addr()
  micrel eth: use dev_hw_addr_random() instead of random_ether_addr()
  atheros eth: set addr_assign_type if random_ether_addr() used
  tc35815: use dev_hw_addr_random() instead of random_ether_addr()
  tile_net: use dev_hw_addr_random() instead of random_ether_addr()
  stmmac: use dev_hw_addr_random() instead of random_ether_addr()
  xilinx ll_temac: use dev_hw_addr_random() instead of
    random_ether_addr()
  ifb: use dev_hw_addr_random() instead of random_ether_addr()
  igbvf: reset netdevice addr_assign_type if changed from random
  usbnet: set addr_assign_type if random_ether_addr() used
  g_ether: set addr_assign_type if random_ether_addr() used
  veth: use dev_hw_addr_random() instead of random_ether_addr()
  batman-adv: use dev_hw_addr_random() instead of random_ether_addr()
  l2tp_eth: use dev_hw_addr_random() instead of random_ether_addr()
  virtio_net:  use dev_hw_addr_random() instead of random_ether_addr()
  macvlan: use dev_hw_addr_random() instead of random_ether_addr()
  team: use dev_hw_addr_random() instead of random_ether_addr()
  tun: use dev_hw_addr_random() instead of random_ether_addr()
  wan: use dev_hw_addr_random() instead of random_ether_addr()
  bridge: use dev_hw_addr_random() instead of random_ether_addr()
  ip_gre.c: use dev_hw_addr_random() instead of random_ether_addr()
  openvswitch: use dev_hw_addr_random() instead of random_ether_addr()
  use dev_hw_addr_random() instead of random_ether_addr()

 arch/blackfin/mach-bf518/boards/ezbrd.c           |    3 ++-
 arch/blackfin/mach-bf518/boards/tcm-bf518.c       |    3 ++-
 arch/blackfin/mach-bf527/boards/ad7160eval.c      |    3 ++-
 arch/blackfin/mach-bf527/boards/cm_bf527.c        |    3 ++-
 arch/blackfin/mach-bf527/boards/ezbrd.c           |    3 ++-
 arch/blackfin/mach-bf527/boards/ezkit.c           |    3 ++-
 arch/blackfin/mach-bf527/boards/tll6527m.c        |    3 ++-
 arch/blackfin/mach-bf537/boards/cm_bf537e.c       |    3 ++-
 arch/blackfin/mach-bf537/boards/cm_bf537u.c       |    3 ++-
 arch/blackfin/mach-bf537/boards/dnp5370.c         |    3 ++-
 arch/blackfin/mach-bf537/boards/pnav10.c          |    3 ++-
 arch/blackfin/mach-bf537/boards/stamp.c           |    3 ++-
 arch/blackfin/mach-bf537/boards/tcm_bf537.c       |    3 ++-
 arch/um/drivers/net_kern.c                        |   11 ++++++++---
 drivers/net/dummy.c                               |    4 +++-
 drivers/net/ethernet/adi/bfin_mac.c               |   10 +++++++---
 drivers/net/ethernet/adi/bfin_mac.h               |    2 +-
 drivers/net/ethernet/amd/au1000_eth.c             |    9 +++++----
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c     |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   |   11 ++++++-----
 drivers/net/ethernet/atheros/atlx/atl1.c          |   12 +++++++++---
 drivers/net/ethernet/atheros/atlx/atlx.c          |    3 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |    2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |    2 +-
 drivers/net/ethernet/cadence/macb.c               |    2 +-
 drivers/net/ethernet/calxeda/xgmac.c              |    4 +++-
 drivers/net/ethernet/cirrus/ep93xx_eth.c          |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c       |   13 +++++++++++--
 drivers/net/ethernet/davicom/dm9000.c             |    2 +-
 drivers/net/ethernet/dnet.c                       |    2 +-
 drivers/net/ethernet/ethoc.c                      |   11 ++++++++++-
 drivers/net/ethernet/faraday/ftgmac100.c          |    2 +-
 drivers/net/ethernet/faraday/ftmac100.c           |    2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c         |    2 ++
 drivers/net/ethernet/lantiq_etop.c                |    4 ++++
 drivers/net/ethernet/marvell/pxa168_eth.c         |    4 +++-
 drivers/net/ethernet/micrel/ks8842.c              |    4 +++-
 drivers/net/ethernet/micrel/ks8851.c              |    7 +++++--
 drivers/net/ethernet/micrel/ks8851_mll.c          |    4 +++-
 drivers/net/ethernet/microchip/enc28j60.c         |    5 ++++-
 drivers/net/ethernet/mipsnet.c                    |    2 +-
 drivers/net/ethernet/natsemi/macsonic.c           |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c           |    4 +++-
 drivers/net/ethernet/rdc/r6040.c                  |    2 +-
 drivers/net/ethernet/sfc/efx.c                    |    4 +++-
 drivers/net/ethernet/sis/sis900.c                 |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c              |    4 +++-
 drivers/net/ethernet/smsc/smsc9420.c              |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c            |    4 +++-
 drivers/net/ethernet/tile/tilepro.c               |    4 +++-
 drivers/net/ethernet/toshiba/tc35815.c            |    2 +-
 drivers/net/ethernet/via/via-rhine.c              |    2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c       |   11 +++++++++--
 drivers/net/ifb.c                                 |    2 +-
 drivers/net/macvlan.c                             |    4 +++-
 drivers/net/team/team.c                           |    5 ++++-
 drivers/net/tun.c                                 |    2 +-
 drivers/net/usb/smsc75xx.c                        |    2 +-
 drivers/net/usb/smsc95xx.c                        |    2 +-
 drivers/net/usb/usbnet.c                          |    1 +
 drivers/net/veth.c                                |    4 ++--
 drivers/net/virtio_net.c                          |    2 +-
 drivers/net/wan/hdlc_fr.c                         |    2 +-
 drivers/net/wan/hdlc_raw_eth.c                    |    2 +-
 drivers/usb/gadget/u_ether.c                      |    4 +++-
 net/batman-adv/soft-interface.c                   |    7 ++++---
 net/bridge/br_device.c                            |    6 +++++-
 net/ethernet/eth.c                                |    4 ++++
 net/ipv4/ip_gre.c                                 |    2 +-
 net/l2tp/l2tp_eth.c                               |    2 +-
 net/openvswitch/vport-internal_dev.c              |    4 +++-
 72 files changed, 196 insertions(+), 85 deletions(-)

-- 
1.7.7.3
