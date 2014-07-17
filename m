From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH net-next v9 0/9] net: set the correct name_assign_type for more devices
Date: Thu, 17 Jul 2014 10:06:01 +0200
Message-ID: <1405584370-30054-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches give name assign types to the vast majority of outstanding devices.

Patch 1: 	give devices with static device names ("lo", etc) the type NET_NAME_PREDICTABLE
Patch 2-3: 	give devices created over netlink (in particular Wifi-P2P, which is currently
		a problem) the correct name assign type
Patch 4:	do the same for devices created via ioctls
Patch 5-9:	cover a few individual drivers

More individual drivers will be converted in a follow-up series.

Tom Gundersen (9):
  net: set name assign type for names assigned using a static string
  net: nl80211 - make rdev_add_virtual_intf take name_assign_type
  net: nl802154 - make add_iface take name assign type
  net: set name_assign_type when setting names via ioctls
  net: bond - make bond_create take name_assign_type
  net: isdn - set name assign type
  net: vlan - set name assign type
  net: openvswitch - set name assign type
  net: ppp - set name assign type

 drivers/isdn/i4l/isdn_common.c                        |  4 ++--
 drivers/isdn/i4l/isdn_net.c                           | 10 +++++-----
 drivers/isdn/i4l/isdn_net.h                           |  4 ++--
 drivers/media/dvb-core/dvb_net.c                      |  2 +-
 drivers/misc/sgi-xp/xpnet.c                           |  2 +-
 drivers/net/bonding/bond_main.c                       |  7 ++++---
 drivers/net/bonding/bond_sysfs.c                      |  2 +-
 drivers/net/bonding/bonding.h                         |  2 +-
 drivers/net/caif/caif_virtio.c                        |  2 +-
 drivers/net/eql.c                                     |  4 ++--
 drivers/net/loopback.c                                |  2 +-
 drivers/net/ppp/ppp_generic.c                         |  1 +
 drivers/net/tun.c                                     |  9 ++++++---
 drivers/net/wan/sbni.c                                |  2 +-
 drivers/net/wan/sdla.c                                |  4 ++--
 drivers/net/wireless/ath/ath6kl/cfg80211.c            |  6 ++++--
 drivers/net/wireless/ath/ath6kl/cfg80211.h            |  1 +
 drivers/net/wireless/ath/ath6kl/core.c                |  4 ++--
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h         |  3 ++-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c   | 10 ++++++----
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c        |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c         |  3 +++
 drivers/net/wireless/brcm80211/brcmfmac/p2p.h         |  1 +
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  4 +++-
 drivers/net/wireless/mwifiex/cfg80211.c               |  5 +++--
 drivers/net/wireless/mwifiex/main.c                   |  2 +-
 drivers/net/wireless/mwifiex/main.h                   |  1 +
 drivers/s390/net/ctcm_main.c                          |  4 ++--
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c     |  6 +++++-
 drivers/staging/vt6655/wpactl.c                       |  2 +-
 drivers/tty/n_gsm.c                                   | 10 +++++++---
 include/net/cfg80211.h                                |  1 +
 include/net/wpan-phy.h                                |  4 +++-
 net/8021q/vlan.c                                      |  7 ++++++-
 net/atm/br2684.c                                      |  5 +++--
 net/bluetooth/bnep/core.c                             |  2 +-
 net/bridge/br_if.c                                    |  7 ++++---
 net/bridge/br_ioctl.c                                 |  4 ++--
 net/bridge/br_private.h                               |  2 +-
 net/ieee802154/nl-phy.c                               |  5 ++++-
 net/ipv6/ip6_gre.c                                    |  2 +-
 net/ipv6/ip6_tunnel.c                                 |  3 ++-
 net/ipv6/ip6_vti.c                                    |  2 +-
 net/ipv6/sit.c                                        |  2 +-
 net/mac80211/cfg.c                                    |  3 ++-
 net/mac80211/ieee80211_i.h                            |  1 +
 net/mac80211/iface.c                                  |  3 ++-
 net/mac80211/main.c                                   |  2 +-
 net/mac802154/ieee802154_dev.c                        |  7 ++++---
 net/openvswitch/vport-internal_dev.c                  |  2 +-
 net/wireless/nl80211.c                                |  3 ++-
 net/wireless/rdev-ops.h                               |  5 +++--
 52 files changed, 120 insertions(+), 73 deletions(-)

-- 
1.9.3
