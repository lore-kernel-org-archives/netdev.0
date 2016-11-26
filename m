From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 26 Nov 2016 16:04:12 -0500 (EST)
Message-ID: <20161126.160412.324455365265501705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix leak in fsl/fman driver, from Dan Carpenter.

2) Call flow dissector initcall earlier than any networking driver can
   register and start to use it, from Eric Dumazet.

3) Some dup header fixes from Geliang Tang.

4) TIPC link monitoring compat fix from Jon Paul Maloy.

5) Link changes require EEE re-negotiation in bcm_sf2 driver, from
   Florian Fainelli.

6) Fix bogus handle ID passed into tfilter_notify_chain(), from
   Roman Mashak.

7) Fix dump size calculation in rtnl_calcit(), from Zhang Shengju.

Please pull, thanks a lot!

The following changes since commit 3b404a519815b9820f73f1ecf404e5546c9270ba:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security (2016-11-21 15:27:41 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 6998cc6ec23740347670da13186d2979c5401903:

  tipc: resolve connection flow control compatibility problem (2016-11-25 21:38:16 -0500)

----------------------------------------------------------------
Andrew Lunn (1):
      net: ethernet: mvneta: Remove IFF_UNICAST_FLT which is not implemented

Andy Gospodarek (1):
      bnxt: do not busy-poll when link is down

Arnd Bergmann (1):
      mvpp2: use correct size for memset

Christophe Jaillet (1):
      bnxt_en: Fix a VXLAN vs GENEVE issue

Dan Carpenter (1):
      fsl/fman: fix a leak in tgec_free()

David S. Miller (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge tag 'linux-can-fixes-for-4.9-20161123' of git://git.kernel.org/.../mkl/linux-can

Eric Dumazet (2):
      flow_dissect: call init_default_flow_dissectors() earlier
      udplite: call proper backlog handlers

Florian Fainelli (1):
      net: dsa: bcm_sf2: Ensure we re-negotiate EEE during after link change

Gao Feng (1):
      driver: macvlan: Check if need rollback multicast setting in macvlan_open

Geliang Tang (4):
      dwc_eth_qos: drop duplicate headers
      ibmvnic: drop duplicate header seq_file.h
      net: ieee802154: drop duplicate header delay.h
      net/mlx5: drop duplicate header delay.h

Johan Hedberg (1):
      Bluetooth: Fix using the correct source address type

Jon Paul Maloy (3):
      tipc: fix compatibility bug in link monitoring
      tipc: improve sanity check for received domain records
      tipc: resolve connection flow control compatibility problem

Kirill Esipov (1):
      net: phy: micrel: fix KSZ8041FTL supported value

Miroslav Lichvar (1):
      net: ethtool: don't require CAP_NET_ADMIN for ETHTOOL_GLINKSETTINGS

Oliver Hartkopp (1):
      can: bcm: fix support for CAN FD frames

Paolo Abeni (1):
      ipv6: bump genid when the IFA_F_TENTATIVE flag is clear

Randy Dunlap (1):
      netdevice.h: fix kernel-doc warning

Roman Mashak (1):
      net sched filters: fix filter handle ID in tfilter_notify_chain()

Tariq Toukan (1):
      net/mlx4_en: Free netdev resources under state lock

WANG Cong (1):
      net: revert "net: l2tp: Treat NET_XMIT_CN as success in l2tp_eth_dev_xmit"

Zhang Shengju (1):
      rtnetlink: fix the wrong minimal dump size getting from rtnl_calcit()

 drivers/net/dsa/bcm_sf2.c                       |  4 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 15 ++++++++++++---
 drivers/net/ethernet/freescale/fman/fman_tgec.c |  3 ---
 drivers/net/ethernet/ibm/ibmvnic.c              |  1 -
 drivers/net/ethernet/marvell/mvneta.c           |  2 +-
 drivers/net/ethernet/marvell/mvpp2.c            |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  5 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c  |  1 -
 drivers/net/ethernet/synopsys/dwc_eth_qos.c     |  2 --
 drivers/net/ieee802154/adf7242.c                |  1 -
 drivers/net/macvlan.c                           |  3 ++-
 drivers/net/phy/micrel.c                        |  8 ++++----
 include/linux/netdevice.h                       |  2 +-
 include/net/bluetooth/hci_core.h                |  2 +-
 net/bluetooth/6lowpan.c                         |  4 ++--
 net/bluetooth/hci_conn.c                        | 26 ++++++++++++++++++++++++--
 net/bluetooth/l2cap_core.c                      |  2 +-
 net/bluetooth/rfcomm/tty.c                      |  2 +-
 net/bluetooth/sco.c                             |  2 +-
 net/can/bcm.c                                   | 18 ++++++++++--------
 net/core/ethtool.c                              |  1 +
 net/core/flow_dissector.c                       |  2 +-
 net/core/rtnetlink.c                            |  2 +-
 net/ipv4/udp.c                                  |  2 +-
 net/ipv4/udp_impl.h                             |  2 +-
 net/ipv4/udplite.c                              |  2 +-
 net/ipv6/addrconf.c                             | 18 ++++++++++++------
 net/ipv6/udp.c                                  |  2 +-
 net/ipv6/udp_impl.h                             |  2 +-
 net/ipv6/udplite.c                              |  2 +-
 net/l2tp/l2tp_eth.c                             |  2 +-
 net/sched/cls_api.c                             |  2 +-
 net/tipc/link.c                                 |  5 +++--
 net/tipc/monitor.c                              | 10 +++++-----
 net/tipc/socket.c                               |  2 +-
 35 files changed, 101 insertions(+), 60 deletions(-)
