From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 02 Jun 2014 18:11:03 -0700 (PDT)
Message-ID: <20140602.181103.775349647844696732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Unbreak zebra and other netlink apps, from Eric W. Biederman.

2) Some new qmi_wwan device IDs, from Aleksander Morgado.

3) Fix info leak in DCB netlink handler of qlcnic driver, from Dan Carpenter.

4) inet_getid() and ipv6_select_ident() do not generate monotnically increasing
   ID numbers, fix from Eric Dumazet.

5) Fix memory leak in __sk_prepare_filter(), from Leon Yu.

6) Netlink leftover bytes warning message is user triggerable, rate
   limit it.  From Michal Schmidt.

7) Fix non-linear SKB panic in ipvs, from Peter Christensen.

8) Congestion window undo needs to be performed even if only never
   retransmitted data is SACK'd, fix from Yuching Cheng.

Please pull, thanks a lot!

The following changes since commit 1ee1ceafb572f1a925809168267a7962a4289de8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc (2014-05-23 15:41:52 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 418c96ac151a16a5094a95d14252c92c1d47ec67:

  net: filter: fix possible memory leak in __sk_prepare_filter() (2014-06-02 17:49:45 -0700)

----------------------------------------------------------------
Aleksander Morgado (3):
      net: qmi_wwan: add Netgear AirCard 341U
      net: qmi_wwan: add additional Sierra Wireless QMI devices
      net: qmi_wwan: interface #11 in Sierra Wireless MC73xx is not QMI

Bart De Schuymer (1):
      ebtables: Update MAINTAINERS entry.

Dan Carpenter (1):
      qlcnic: info leak in qlcnic_dcb_peer_app_info()

David S. Miller (4):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless
      Merge tag 'linux-can-fixes-for-3.15-20140528' of git://gitorious.org/linux-can/linux-can
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-merge

Emmanuel Grumbach (1):
      iwlwifi: mvm: disable beacon filtering

Eric Dumazet (1):
      net: fix inet_getid() and ipv6_select_ident() bugs

Eric W. Biederman (1):
      netlink: Only check file credentials for implicit destinations

Ivan Mikhaylov (2):
      emac: add missing support of 10mbit in emac/rgmii
      emac: aggregation of v1-2 PLB errors for IER register

Jack Morgenstein (1):
      net/mlx4_core: Reset RoCE VF gids when guest driver goes down

Jean Delvare (1):
      net: ec_bhf: Add runtime dependencies

Jiri Pirko (1):
      team: fix mtu setting

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Jon Maxwell (1):
      bridge: notify user space after fdb update

Kristian Evensen (1):
      ipheth: Add support for iPad 2 and iPad 3

Leon Yu (1):
      net: filter: fix possible memory leak in __sk_prepare_filter()

Marek Lindner (1):
      batman-adv: fix NULL pointer dereferences

Michal Schmidt (1):
      netlink: rate-limit leftover bytes warning and print process name

Nikolay Aleksandrov (1):
      net: fix wrong mac_len calculation for vlans

Oliver Hartkopp (1):
      can: only rename enabled led triggers when changing the netdev name

Peter Christensen (1):
      ipvs: Fix panic due to non-linear skb

Samuel Ortiz (1):
      Bluetooth: Fix L2CAP LE debugfs entries permissions

Toshiaki Makita (1):
      bridge: Prevent insertion of FDB entry with disallowed vlan

Yuchung Cheng (1):
      tcp: fix cwnd undo on DSACK in F-RTO

 MAINTAINERS                                           |   3 +-
 drivers/net/can/led.c                                 |   3 ++
 drivers/net/ethernet/Kconfig                          |   1 +
 drivers/net/ethernet/ibm/emac/mal.c                   |   5 +---
 drivers/net/ethernet/ibm/emac/mal.h                   |  20 +++++--------
 drivers/net/ethernet/ibm/emac/rgmii.c                 |   3 ++
 drivers/net/ethernet/mellanox/mlx4/main.c             |   1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h             |  20 +++++++++----
 drivers/net/ethernet/mellanox/mlx4/port.c             | 117 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |   3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c       |   1 +
 drivers/net/team/team.c                               |   7 ++++-
 drivers/net/usb/ipheth.c                              |  10 +++++++
 drivers/net/usb/qmi_wwan.c                            |   6 +++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c           |   2 +-
 include/linux/if_team.h                               |   1 +
 include/linux/netlink.h                               |   7 +++--
 include/net/inetpeer.h                                |   9 +-----
 lib/nlattr.c                                          |   4 +--
 net/batman-adv/multicast.c                            |   6 ++--
 net/bluetooth/l2cap_core.c                            |   4 +--
 net/bridge/br_fdb.c                                   |   8 ++++-
 net/bridge/br_input.c                                 |   4 +--
 net/bridge/br_private.h                               |   7 +++++
 net/bridge/br_vlan.c                                  |  28 +++++++++++++++++
 net/core/dev.c                                        |  35 +++++++++++++++-------
 net/core/filter.c                                     |   7 ++++-
 net/ipv4/tcp_input.c                                  |  11 ++++---
 net/ipv6/output_core.c                                |  11 ++-----
 net/netfilter/ipvs/ip_vs_core.c                       |  15 ++++++----
 net/netlink/af_netlink.c                              |   7 ++++-
 31 files changed, 279 insertions(+), 87 deletions(-)
