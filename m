From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 29 Jan 2014 00:55:55 -0800 (PST)
Message-ID: <20140129.005555.1578998818751926111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several fixups, of note:

1) Fix unlock of not held spinlock in RXRPC code, from Alexey
   Khoroshilov.

2) Call pci_disable_device() from the correct shutdown path in
   bnx2x driver, from Yuval Mintz.

3) Fix qeth build on s390 for some configurations, from Eugene
   Crosser.

4) Cure locking bugs in bond_loadbalance_arp_mon(), from Ding
   Tianhong.

5) Must do netif_napi_add() before registering netdevice in sky2
   driver, from Stanislaw Gruszka.

6) Fix lost bug fix during merge due to code movement in ieee802154,
   noticed and fixed by the eagle eyed Stephen Rothwell.

7) Get rid of resource leak in xen-netfront driver, from Annie Li.

8) Bounds checks in qlcnic driver are off by one, from Manish Chopra.

9) TPROXY can leak sockets when TCP early demux is enabled, fix from
   Holger Eitzenberger.

Please pull, thanks a lot!

The following changes since commit 77d143de75812596a58d126606f42d1214e09dde:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/rw/uml (2014-01-26 11:06:16 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to c044dc2132d19d8c643cdd340f21afcec177c046:

  qeth: fix build of s390 allmodconfig (2014-01-29 00:43:33 -0800)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      RxRPC: do not unlock unheld spinlock in rxrpc_connect_exclusive()

Annie Li (1):
      xen-netfront: fix resource leak in netfront

Dave Jones (2):
      i40e: Add missing braces to i40e_dcb_need_reconfig()
      llc: remove noisy WARN from llc_mac_hdr_init

David S. Miller (4):
      Merge branch 'bonding'
      Merge branch 'qlcnic'
      Merge tag 'rxrpc-20140126' of git://git.kernel.org/.../dhowells/linux-fs
      Merge branch 'DT'

Ding Tianhong (1):
      bonding: fix locking in bond_loadbalance_arp_mon()

Duan Jiong (1):
      net: gre: use icmp_hdr() to get inner ip header

Eugene Crosser (1):
      qeth: fix build of s390 allmodconfig

Florian Westphal (1):
      net: add and use skb_gso_transport_seglen()

Geert Uytterhoeven (1):
      net/apne: Remove unused variable ei_local

Haiyang Zhang (1):
      hyperv: Add support for physically discontinuous receive buffer

Hans de Goede (2):
      net: stmmac: Silence PTP init errors on hw without PTP
      net: stmmac: Log MAC address only once

Holger Eitzenberger (1):
      net: Fix memory leak if TPROXY used with TCP early demux

Manish Chopra (1):
      qlcnic: Correct off-by-one errors in bounds checks

Martin Schwenke (1):
      net: Document promote_secondaries

Masanari Iida (1):
      net: Fix warning on make htmldocs caused by skbuff.c

Masatake YAMATO (1):
      tun: add device name(iff) field to proc fdinfo entry

Neil Horman (1):
      AF_PACKET: Add documentation for queue mapping fanout mode

Rajesh Borundia (2):
      qlcnic: Fix initialization of vlan list.
      qlcnic: Fix tx timeout.

Sachin Kamat (1):
      net: ipv4: Use PTR_ERR_OR_ZERO

Sergei Shtylyov (2):
      DT: net: davinci_emac: "ti, davinci-rmii-en" property is actually optional
      DT: net: davinci_emac: "ti, davinci-no-bd-ram" property is actually optional

Shahed Shaikh (1):
      qlcnic: Fix loopback test failure

Stanislaw Gruszka (1):
      sky2: initialize napi before registering device

Stephen Rothwell (1):
      net: 6lowpan: fixup for code movement

Tim Smith (2):
      af_rxrpc: Avoid setting up double-free on checksum error
      af_rxrpc: Handle frames delivered from another VM

Veaceslav Falico (2):
      bonding: RCUify bond_ab_arp_probe
      bonding: restructure locking of bond_ab_arp_probe()

Yaniv Rosner (1):
      bnx2x: Fix generic option settings

Yuval Mintz (1):
      bnx2x: More Shutdown revisions

 Documentation/devicetree/bindings/net/davinci_emac.txt   |  4 +-
 Documentation/networking/ip-sysctl.txt                   |  6 +++
 Documentation/networking/packet_mmap.txt                 |  1 +
 drivers/hv/channel.c                                     | 14 +++---
 drivers/net/bonding/bond_main.c                          | 96 ++++++++++++++++++++++++------------------
 drivers/net/bonding/bonding.h                            | 13 ++++++
 drivers/net/ethernet/8390/apne.c                         |  1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c      | 78 +++++++++++++++++-----------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c         |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c              |  3 +-
 drivers/net/ethernet/marvell/sky2.c                      |  4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c           | 19 ++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c         |  9 +---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c | 11 +++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c        |  6 +--
 drivers/net/hyperv/hyperv_net.h                          |  2 +-
 drivers/net/hyperv/netvsc.c                              |  7 +--
 drivers/net/tun.c                                        | 27 +++++++++++-
 drivers/net/xen-netfront.c                               | 88 ++++++++++++--------------------------
 drivers/s390/net/qeth_core.h                             |  5 +--
 drivers/s390/net/qeth_core_main.c                        | 18 +++-----
 drivers/s390/net/qeth_l2_main.c                          | 41 +++++++++++++++---
 drivers/s390/net/qeth_l3_main.c                          |  8 ++++
 include/linux/skbuff.h                                   |  1 +
 net/core/skbuff.c                                        | 27 +++++++++++-
 net/ieee802154/6lowpan_iphc.c                            |  2 +-
 net/ipv4/ip_gre.c                                        |  2 +-
 net/ipv4/ip_input.c                                      |  2 +-
 net/ipv4/ip_tunnel.c                                     |  3 +-
 net/ipv6/ip6_input.c                                     |  2 +-
 net/llc/llc_output.c                                     |  2 +-
 net/rxrpc/ar-connection.c                                |  2 +
 net/rxrpc/ar-recvmsg.c                                   |  7 ++-
 net/sched/sch_tbf.c                                      | 13 ++----
 34 files changed, 303 insertions(+), 225 deletions(-)
