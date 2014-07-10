From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 00/33] Provide netdev naming-policy via sysfs
Date: Thu, 10 Jul 2014 10:17:05 +0200
Message-ID: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This picks up the patch series where David Herrmann left off, incorporating
the feedback from David Miller.

Overview (see Patch 1 for more details):

Patch 1: Introduce the enums, documentation and userspace API
Patch 2: Hook up with device renaming
Patch 3: change the alloc_netdev*() API to take the name_assign_type

The following patches actually converts to the correct name assign type,
these can be applied in any order, and we could even delay some/all
to a subsequent release if that makes things simpler.

Patch 4-6: convert the trivial cases.
Patch 7-9: convert the netlink interfaces to pass down the assign type
Patch 10-33: convert the remaining drivers one-by-one

Cheers,

Tom

Changes since v6:
 - change alloc_netdev to take the name assign type as an argument.
 - introduce an internal assign type NET_NAME_UNKNOWN, which makes
   it simpler to split up the patches, but may eventually be dropped.
 - introduce a new assign type NET_NAME_PREDICTABLE to indicate to
   userspace that the kernel-assigned names are well-behaved.

Tom Gundersen (33):
  net: add name_assign_type netdev attribute
  net: set name assign type for renamed devices
  net: set name_assign_type in alloc_netdev()
  net: set name assign type for names assigned using a static template
  net: set name assign type for names assigned using a static string
  net: set name assign type for names passed directly from userspace
  net: rtnetlink - make create_link take name_assign_type
  net: nl80211 - make rdev_add_virtual_intf take name_assign_type
  net: nl802154 - make add_iface take name assign type
  net: dummy - set name assign type
  net: af_netrom - set name assign type
  net: af_rose - set name assign type
  net: mrt - set name assign type
  net: caif_serial - set name assign type
  net: xen-netback - set name assign type
  net: gdm_lte - set name assign type
  net: airo - set name assign type
  net: arcdev - label alloc_arcdev names
  net: isdn - set name assign type
  net: irlan - set name assign type
  net: batman-adv - set name assign type
  net: hamradio - set name assign type
  net: openvswitch - set name assign type
  net: vlan - set name assign type
  net: infiniband - steal ifname label
  net: ipoib - set name assign type
  net: tile - set name assign type
  net: dsa - set name assign type
  net: brcmfmac - set name assign type
  net: ppp - set name assign type
  net: slcan - set name assign type
  net: x25_asy - set name assign type
  net: slip - set name assign type

 Documentation/ABI/testing/sysfs-class-net            | 11 +++++++++++
 drivers/firewire/net.c                               |  3 ++-
 drivers/hsi/clients/ssi_protocol.c                   |  3 ++-
 drivers/infiniband/hw/amso1100/c2_provider.c         |  2 +-
 drivers/infiniband/ulp/ipoib/ipoib.h                 |  2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c            | 10 ++++++----
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c            |  2 +-
 drivers/isdn/i4l/isdn_common.c                       |  4 ++--
 drivers/isdn/i4l/isdn_net.c                          |  9 +++++----
 drivers/isdn/i4l/isdn_net.h                          |  4 ++--
 drivers/media/dvb-core/dvb_net.c                     |  3 ++-
 drivers/misc/sgi-xp/xpnet.c                          |  3 ++-
 drivers/net/arcnet/arc-rimi.c                        |  2 +-
 drivers/net/arcnet/arcnet.c                          |  9 +++++++--
 drivers/net/arcnet/com20020-isa.c                    |  2 +-
 drivers/net/arcnet/com20020-pci.c                    |  2 +-
 drivers/net/arcnet/com20020_cs.c                     |  2 +-
 drivers/net/arcnet/com90io.c                         |  2 +-
 drivers/net/arcnet/com90xx.c                         |  2 +-
 drivers/net/bonding/bond_main.c                      |  1 +
 drivers/net/caif/caif_serial.c                       |  3 ++-
 drivers/net/caif/caif_spi.c                          |  2 +-
 drivers/net/caif/caif_virtio.c                       |  2 +-
 drivers/net/can/dev.c                                |  2 +-
 drivers/net/can/slcan.c                              |  2 +-
 drivers/net/dummy.c                                  |  2 +-
 drivers/net/eql.c                                    |  3 ++-
 drivers/net/ethernet/8390/lib8390.c                  |  2 +-
 drivers/net/ethernet/tile/tilegx.c                   |  9 +++++----
 drivers/net/ethernet/tile/tilepro.c                  | 14 ++++++++------
 drivers/net/hamradio/6pack.c                         |  3 ++-
 drivers/net/hamradio/baycom_epp.c                    |  2 +-
 drivers/net/hamradio/baycom_par.c                    |  3 ++-
 drivers/net/hamradio/baycom_ser_fdx.c                |  3 ++-
 drivers/net/hamradio/baycom_ser_hdx.c                |  3 ++-
 drivers/net/hamradio/bpqether.c                      |  2 +-
 drivers/net/hamradio/dmascc.c                        |  5 +++--
 drivers/net/hamradio/hdlcdrv.c                       |  3 ++-
 drivers/net/hamradio/mkiss.c                         |  3 ++-
 drivers/net/hamradio/scc.c                           | 11 ++++++-----
 drivers/net/hamradio/yam.c                           |  2 +-
 drivers/net/ieee802154/fakehard.c                    |  3 ++-
 drivers/net/ifb.c                                    |  2 +-
 drivers/net/loopback.c                               |  2 +-
 drivers/net/ppp/ppp_generic.c                        |  4 +++-
 drivers/net/slip/slip.c                              |  2 +-
 drivers/net/tun.c                                    |  8 ++++++--
 drivers/net/usb/cdc-phonet.c                         |  3 ++-
 drivers/net/usb/hso.c                                |  3 ++-
 drivers/net/veth.c                                   | 11 ++++++++---
 drivers/net/wan/dlci.c                               |  4 ++--
 drivers/net/wan/hdlc.c                               |  3 ++-
 drivers/net/wan/hdlc_fr.c                            |  4 ++--
 drivers/net/wan/lapbether.c                          |  2 +-
 drivers/net/wan/sbni.c                               |  7 ++++---
 drivers/net/wan/sdla.c                               |  3 ++-
 drivers/net/wan/x25_asy.c                            |  2 +-
 drivers/net/wimax/i2400m/usb.c                       |  2 +-
 drivers/net/wireless/airo.c                          |  6 ++++--
 drivers/net/wireless/ath/ath6kl/cfg80211.c           |  6 ++++--
 drivers/net/wireless/ath/ath6kl/cfg80211.h           |  1 +
 drivers/net/wireless/ath/ath6kl/core.c               |  4 ++--
 drivers/net/wireless/ath/wil6210/netdev.c            |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h        |  3 ++-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c  | 11 +++++++----
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c       |  3 ++-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c        |  3 +++
 drivers/net/wireless/brcm80211/brcmfmac/p2p.h        |  1 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c    |  4 +++-
 drivers/net/wireless/libertas/main.c                 |  2 +-
 drivers/net/wireless/libertas/mesh.c                 |  2 +-
 drivers/net/wireless/mac80211_hwsim.c                |  2 +-
 drivers/net/wireless/mwifiex/cfg80211.c              |  6 ++++--
 drivers/net/wireless/mwifiex/main.c                  |  2 +-
 drivers/net/wireless/mwifiex/main.h                  |  1 +
 drivers/net/xen-netback/interface.c                  |  2 +-
 drivers/s390/net/claw.c                              |  2 +-
 drivers/s390/net/ctcm_main.c                         |  6 ++++--
 drivers/s390/net/netiucv.c                           |  2 +-
 drivers/s390/net/qeth_l2_main.c                      |  6 ++++--
 drivers/s390/net/qeth_l3_main.c                      |  3 ++-
 drivers/staging/cxt1e1/linux.c                       |  3 ++-
 drivers/staging/gdm724x/gdm_lte.c                    |  2 +-
 drivers/staging/gdm72xx/gdm_wimax.c                  |  2 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c    |  6 +++++-
 drivers/staging/vt6655/wpactl.c                      |  3 ++-
 drivers/staging/wlan-ng/p80211netdev.c               |  2 +-
 drivers/tty/n_gsm.c                                  |  7 +++++--
 drivers/usb/gadget/f_phonet.c                        |  3 ++-
 include/linux/arcdevice.h                            |  3 ++-
 include/linux/hdlcdrv.h                              |  1 +
 include/linux/netdevice.h                            | 12 ++++++++----
 include/net/cfg80211.h                               |  1 +
 include/net/irda/irlan_eth.h                         |  2 +-
 include/net/rtnetlink.h                              |  1 +
 include/net/wpan-phy.h                               |  4 +++-
 include/uapi/linux/netdevice.h                       |  6 ++++++
 net/802/fc.c                                         |  2 +-
 net/802/fddi.c                                       |  2 +-
 net/802/hippi.c                                      |  2 +-
 net/8021q/vlan.c                                     |  8 +++++++-
 net/appletalk/dev.c                                  |  2 +-
 net/atm/br2684.c                                     |  1 +
 net/atm/clip.c                                       |  3 ++-
 net/batman-adv/hard-interface.c                      |  5 +++--
 net/batman-adv/hard-interface.h                      |  3 ++-
 net/batman-adv/soft-interface.c                      |  7 +++++--
 net/batman-adv/soft-interface.h                      |  2 +-
 net/batman-adv/sysfs.c                               |  2 +-
 net/bluetooth/6lowpan.c                              |  3 ++-
 net/bluetooth/bnep/core.c                            |  5 +++--
 net/bridge/br_if.c                                   |  5 +++--
 net/bridge/br_ioctl.c                                |  4 ++--
 net/bridge/br_private.h                              |  2 +-
 net/core/dev.c                                       |  9 +++++++++
 net/core/net-sysfs.c                                 | 20 ++++++++++++++++++++
 net/core/rtnetlink.c                                 | 14 +++++++++-----
 net/dsa/dsa.c                                        |  3 ++-
 net/dsa/dsa_priv.h                                   |  3 ++-
 net/dsa/slave.c                                      |  4 ++--
 net/ethernet/eth.c                                   |  3 ++-
 net/ieee802154/nl-phy.c                              |  5 ++++-
 net/ipv4/ip_tunnel.c                                 |  9 ++++++---
 net/ipv4/ipmr.c                                      |  2 +-
 net/ipv6/ip6_gre.c                                   | 14 ++++++++++----
 net/ipv6/ip6_tunnel.c                                | 14 ++++++++++----
 net/ipv6/ip6_vti.c                                   | 12 ++++++++----
 net/ipv6/ip6mr.c                                     |  2 +-
 net/ipv6/sit.c                                       | 12 +++++++++---
 net/irda/irda_device.c                               |  3 ++-
 net/irda/irlan/irlan_common.c                        |  2 +-
 net/irda/irlan/irlan_eth.c                           |  5 +++--
 net/l2tp/l2tp_eth.c                                  |  9 +++++++--
 net/mac80211/cfg.c                                   |  3 ++-
 net/mac80211/ieee80211_i.h                           |  1 +
 net/mac80211/iface.c                                 |  7 ++++---
 net/mac80211/main.c                                  |  2 +-
 net/mac802154/ieee802154_dev.c                       |  9 ++++++---
 net/netrom/af_netrom.c                               |  2 +-
 net/openvswitch/datapath.c                           |  1 +
 net/openvswitch/vport-internal_dev.c                 |  3 ++-
 net/openvswitch/vport.h                              |  2 ++
 net/phonet/pep-gprs.c                                |  3 ++-
 net/rose/af_rose.c                                   |  2 +-
 net/sched/sch_teql.c                                 |  3 ++-
 net/wireless/nl80211.c                               |  3 ++-
 net/wireless/rdev-ops.h                              |  5 +++--
 147 files changed, 408 insertions(+), 203 deletions(-)

-- 
1.9.3
