From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v8 00/4] Provide netdev naming-policy via sysfs
Date: Thu, 10 Jul 2014 23:01:02 +0200
Message-ID: <1405026066-2547-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resending only the core changes. These patches alone would already be
very useful to udev. The remaning ones can be reviewed and applied
individually later.

See patch 1 for details.

Cheers,

Tom

Changes since v7:
 - drop non-core changes
Changes since v6:
 - change alloc_netdev to take the name assign type as an argument.
 - introduce an internal assign type NET_NAME_UNKNOWN, which makes
   it simpler to split up the patches, but may eventually be dropped.
 - introduce a new assign type NET_NAME_PREDICTABLE to indicate to
   userspace that the kernel-assigned names are well-behaved.

Tom Gundersen (4):
  net: add name_assign_type netdev attribute
  net: set name assign type for renamed devices
  net: set name_assign_type in alloc_netdev()
  net: rtnetlink - make create_link take name_assign_type

 Documentation/ABI/testing/sysfs-class-net           | 11 +++++++++++
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
 drivers/net/veth.c                                  | 11 ++++++++---
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
 include/linux/netdevice.h                           | 12 ++++++++----
 include/net/rtnetlink.h                             |  1 +
 include/uapi/linux/netdevice.h                      |  6 ++++++
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
 net/core/dev.c                                      | 20 +++++++++++++++-----
 net/core/net-sysfs.c                                | 20 ++++++++++++++++++++
 net/core/rtnetlink.c                                | 14 +++++++++-----
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
 102 files changed, 248 insertions(+), 139 deletions(-)

-- 
1.9.3
