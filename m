From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 27 Oct 2010 15:05:17 -0700 (PDT)
Message-ID: <20101027.150517.189701523.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41526
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752726Ab0J0WEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 18:04:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hey, I'll resolve the verify_iovec() issue this evening so that we can
wrap that sucker up.  But for now here's some fallout fixing changes
as well as some other misc stuff:

1) dev_can_checksum() doesn't handle nested VLAN properly, also
   generic checksum capability does not imply FCOE checksumming.
   Both from Ben Hutchings.

2) typhoon driver fails to wait for RX mode commands to finish,
   also use new VLAN accel interfaces.  From David Dillow.

3) Tunnel transmit recursion limit too low, increase to 10.

4) Fix tms380tr build failure on x86-64 due to too large udelay().

5) ipv6 TPROXY needs to check CAP_NET_ADMIN just like ipv4, from
   Balazs Scheidler.

6) Add caif-u5500 driver, from Amarnath Revanna.

7) Add tscan1 CAN driver, from Andre B. Oliveira.

8) Missed MTU updates in ip6_tunnel, from Anders Franzen.

9) Lots of missing __rcu annotations, from Eric Dumazet.

10) Fix bonding lockdep spew, from Jarek Poplawski.

11) Fix slhc double-export of symbol, from Denis Kirjanov.

12) cxgb4 too-early-queue access crash fix from Dimitris Michailidis,
    also use new VLAN accel interfaces.

13) mlx4_en out-of-bounds array access fix from Eli Cohen.

14) IPv6 temporary address handling fixes from Glenn Wurster.

15) Fix RX crashes in gianfar, from Jarek Poplawski.

16) Fix ipv6 defrag dependencies with ip6tables and tproxy, from KOVACS=
 Krisztian.

17) Missing CONFIG_SYSCTL checks in ipv6 reasm netfilter code.

18) Tunnel RCU protection fix from Pavel Emelyanov.

19) be2net bug fixes from Somnath Kotur (calling netif_carrier_off() to=
o
    early, UDP packet handling, and worker thread destruction and
    scheduling bugs).

20) qlcnic can use invalid VLAN ids, from Sony Chacko.

21) Accidental exporting of static functions in l2tp, from Stephen Roth=
well.

22) Toss lazy workqueue from connector, from Tejun Heo.

23) Final function staticization round from Stephen Hemminger.

Please pull, thanks a lot!

The following changes since commit 12ba8d1e9262ce81a695795410bd9ee5c940=
7ba1:

  fix braino in fs: do not assign default i_ino in new_inode (2010-10-2=
6 20:25:45 -0700)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amarnath Revanna (3):
      caif-u5500: Adding shared memory include
      caif-u5500: CAIF shared memory mailbox interface
      caif-u5500: Build config for CAIF shared mem driver

Anders Franzen (1):
      ip6_tunnel dont update the mtu on the route.

Andre B. Oliveira (1):
      can: tscan1: add driver for TS-CAN1 boards

Balazs Scheidler (1):
      tproxy: Add missing CAP_NET_ADMIN check to ipv6 side

Ben Greear (2):
      ath9k: Properly initialize ath_common->cc_lock.
      ath5k: Properly initialize ath_common->cc_lock.

Ben Hutchings (2):
      net: Fix some corner cases in dev_can_checksum()
      net: NETIF_F_HW_CSUM does not imply FCoE CRC offload

Breno Leitao (1):
      ehea: Fixing statistics

Christian Lamparter (4):
      carl9170: fix async command buffer leak
      mac80211: don't sanitize invalid rates
      carl9170: fix memory leak issue in async cmd macro wrappers
      carl9170: fix scheduling while atomic

David Dillow (2):
      typhoon: wait for RX mode commands to finish
      typhoon: update to new VLAN acceleration model

David S. Miller (4):
      net: Increase xmit RECURSION_LIMIT to 10.
      tms380tr: Use mdelay() in tms380tr_wait().
      netfilter: Add missing CONFIG_SYSCTL checks in ipv6's nf_conntrac=
k_reasm.c
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Denis Kirjanov (1):
      slhc: Don't export symbols twice

Dimitris Michailidis (2):
      cxgb4: fix crash due to manipulating queues before registration
      cxgb4: update to utilize the newer VLAN infrastructure

Divy Le Ray (1):
      cxgb3: fix device opening error path

Don Fry (1):
      iwlwifi: quiet a noisy printk

Eli Cohen (1):
      mlx4_en: Fix out of bounds array access

Eric Dumazet (17):
      netlink: fix netlink_change_ngroups()
      vlan: rcu annotations
      ipv6: ip6_ptr rcu annotations
      net/802: add __rcu annotations
      tunnels: add _rcu annotations
      rps: add __rcu annotations
      net_ns: add __rcu annotations
      net: add __rcu annotation to sk_filter
      ipv4: add __rcu annotations to ip_ra_chain
      fib: fix fib_nl_newrule()
      fib_hash: fix rcu sparse and logical errors
      ipv4: add __rcu annotations to routes.c
      net: add __rcu annotations to protocol
      tunnels: add __rcu annotations
      fib_rules: __rcu annotates ctarget
      inetpeer: __rcu annotations
      ehea: fix use after free

=46elix Fietkau (3):
      ath9k: fix crash in ath_update_survey_stats
      ath9k: fix handling of rate control probe frames
      ath9k: resume aggregation immediately after a hardware reset

Glenn Wurster (2):
      IPv6: Create temporary address if none exists.
      IPv6: Temp addresses are immediately deleted.

Grazvydas Ignotas (1):
      wl1251: fix module names

Guo-Fu Tseng (1):
      jme: Support WoL after shutdown

Harvey Harrison (3):
      vmxnet3: remove set_flag_le{16,64} helpers
      vmxnet3: annotate hwaddr members as __iomem pointers
      vmxnet3: fix typo setting confPA

Jarek Poplawski (2):
      gianfar: Fix crashes on RX path (Was Re: [Bugme-new] [Bug 19692] =
New: linux-2.6.36-rc5 crash with gianfar ethernet at full line rate tra=
ffic)
      bonding: Fix lockdep warning after bond_vlan_rx_register()

Joe Perches (1):
      drivers/atm/eni.c: Remove multiple uses of KERN_<level>

Joshua Hoke (1):
      macb: Don't re-enable interrupts while in polling mode

Julia Lawall (3):
      drivers/net/sb1000.c: delete double assignment
      drivers/net/typhoon.c: delete double assignment
      drivers/isdn: delete double assignment

KOVACS Krisztian (1):
      netfilter: fix module dependency issues with IPv6 defragmentation=
, ip6tables and xt_TPROXY

Luis R. Rodriguez (2):
      cfg80211: fix regression on processing country IEs
      ath9k_hw: Fix TX carrier leakage for IEEE compliance on AR9003 2.=
2

Marc Kleine-Budde (12):
      can: at91_can: use correct bit to enable CAN_CTRLMODE_3_SAMPLES
      can: at91_can: fix reception of extended frames
      can: at91_can: fix use after free of priv
      can: at91_can: fix compiler warning in at91_irq_err_state
      can: at91_can: fix section mismatch warning
      can: at91_can: implement and use at91_get_berr_counter
      can: at91_can: set bittiming in chip_start
      can: at91_can: convert readl, writel their __raw pendants
      can: at91_can: convert dev_<level> printing to netdev_<level>
      can: at91_can: add KBUILD_MODNAME to bittiming constant
      can: flexcan: fix use after free of priv
      can: mcp251x: fix reception of standard RTR frames

Masayuki Ohtake (1):
      can: Topcliff: Add PCH_CAN driver.

Nicolas Kaiser (1):
      drivers/net: sgiseeq: fix return on error

Paul Gortmaker (1):
      pktgen: clean up handling of local/transient counter vars

Pavel Emelyanov (1):
      tunnels: Fix tunnels change rcu protection

Rafael J. Wysocki (1):
      tg3: Do not call device_set_wakeup_enable() under spin_lock_bh

Rafa=A9=A9 Mi=A9=A9ecki (1):
      b43: N-PHY: fix infinite-loop-typo

Rajkumar Manoharan (1):
      mac80211: Fix ibss station got expired immediately

Randy Dunlap (1):
      pch_can: depends on PCI

Ron Mercer (1):
      qlge: bugfix: Restoring the vlan setting.

Senthil Balasubramanian (1):
      ath9k_hw: Fix divide by zero cases in paprd.

Somnath Kotur (3):
      be2net: Call netif_carier_off() after register_netdev()
      be2net: Fix CSO for UDP packets
      be2net: Schedule/Destroy worker thread in probe()/remove() rather=
 than open()/close()

Sony Chacko (2):
      qlcnic: reduce rx ring size
      qlcnic: define valid vlan id range

Stephen Rothwell (1):
      l2tp: static functions should not be exported

Tejun Heo (2):
      connector: remove lazy workqueue creation
      mac80211: cancel restart_work explicitly instead of depending on =
flush_scheduled_work()

Ursula Braun (1):
      ipv6: fix refcnt problem related to POSTDAD state

amit salecha (1):
      qlcnic: fix mac learning

sjur.brandeland@stericsson.com (1):
      caif-u5500: CAIF shared memory transport protocol

stephen hemminger (12):
      mlx4: make functions local and remove dead code.
      l2tp: make local function static
      benet: remove dead code
      benet: make be_poll_rx local
      atl1c: make functions static
      atlx: make local functions/data static
      phylib: make local function static
      vxge: make functions local and remove dead code
      qlge: make local functions static
      qlge: disable unsed dump code
      bnx2x: make local function static and remove dead code
      e1000: make e1000_reinit_safe local

 Documentation/networking/phy.txt                   |   18 -
 drivers/atm/eni.c                                  |    7 +-
 drivers/connector/cn_queue.c                       |   75 +-
 drivers/connector/connector.c                      |    9 +-
 drivers/isdn/hardware/mISDN/mISDNinfineon.c        |    2 +-
 drivers/isdn/hisax/l3_1tr6.c                       |    6 +-
 drivers/net/atl1c/atl1c.h                          |    2 -
 drivers/net/atl1c/atl1c_main.c                     |    6 +-
 drivers/net/atlx/atl1.c                            |   12 +-
 drivers/net/atlx/atl1.h                            |    9 +-
 drivers/net/atlx/atlx.c                            |    4 +
 drivers/net/benet/be_cmds.c                        |   36 -
 drivers/net/benet/be_cmds.h                        |    2 -
 drivers/net/benet/be_main.c                        |   49 +-
 drivers/net/bnx2x/bnx2x.h                          |    5 -
 drivers/net/bnx2x/bnx2x_cmn.c                      |    3 +-
 drivers/net/bnx2x/bnx2x_cmn.h                      |   55 -
 drivers/net/bnx2x/bnx2x_init_ops.h                 |   34 +-
 drivers/net/bnx2x/bnx2x_link.c                     |  137 +--
 drivers/net/bnx2x/bnx2x_link.h                     |   15 -
 drivers/net/bnx2x/bnx2x_main.c                     |   55 +-
 drivers/net/bonding/bond_main.c                    |    4 +-
 drivers/net/caif/Kconfig                           |    7 +
 drivers/net/caif/Makefile                          |    4 +
 drivers/net/caif/caif_shm_u5500.c                  |  129 ++
 drivers/net/caif/caif_shmcore.c                    |  744 ++++++++++
 drivers/net/can/Kconfig                            |    8 +
 drivers/net/can/Makefile                           |    1 +
 drivers/net/can/at91_can.c                         |   95 +-
 drivers/net/can/flexcan.c                          |    3 +-
 drivers/net/can/mcp251x.c                          |    3 +
 drivers/net/can/pch_can.c                          | 1463 ++++++++++++=
++++++++
 drivers/net/can/sja1000/Kconfig                    |   12 +
 drivers/net/can/sja1000/Makefile                   |    1 +
 drivers/net/can/sja1000/tscan1.c                   |  216 +++
 drivers/net/cxgb3/cxgb3_main.c                     |    8 +-
 drivers/net/cxgb4/cxgb4.h                          |    1 -
 drivers/net/cxgb4/cxgb4_main.c                     |   33 +-
 drivers/net/cxgb4/sge.c                            |   23 +-
 drivers/net/e1000/e1000_main.c                     |    2 +-
 drivers/net/ehea/ehea.h                            |    2 +
 drivers/net/ehea/ehea_main.c                       |   42 +-
 drivers/net/gianfar.c                              |    6 +-
 drivers/net/jme.c                                  |   45 +-
 drivers/net/macb.c                                 |   27 +-
 drivers/net/mlx4/icm.c                             |   28 +-
 drivers/net/mlx4/icm.h                             |    2 -
 drivers/net/mlx4/port.c                            |   11 +
 drivers/net/phy/phy.c                              |   13 +-
 drivers/net/phy/phy_device.c                       |   19 +-
 drivers/net/qlcnic/qlcnic.h                        |    7 +-
 drivers/net/qlcnic/qlcnic_ethtool.c                |   23 +-
 drivers/net/qlcnic/qlcnic_main.c                   |   19 +-
 drivers/net/qlge/qlge.h                            |   12 +-
 drivers/net/qlge/qlge_main.c                       |   24 +-
 drivers/net/qlge/qlge_mpi.c                        |    6 +-
 drivers/net/sb1000.c                               |    6 +-
 drivers/net/sgiseeq.c                              |    2 +-
 drivers/net/slhc.c                                 |   15 +-
 drivers/net/tg3.c                                  |   10 +-
 drivers/net/tokenring/tms380tr.c                   |    2 +-
 drivers/net/typhoon.c                              |   92 +-
 drivers/net/vmxnet3/upt1_defs.h                    |    8 +-
 drivers/net/vmxnet3/vmxnet3_defs.h                 |    6 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                  |   22 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |   14 +-
 drivers/net/vmxnet3/vmxnet3_int.h                  |   19 +-
 drivers/net/vxge/vxge-config.c                     |  332 ++++--
 drivers/net/vxge/vxge-config.h                     |  227 +---
 drivers/net/vxge/vxge-ethtool.c                    |    2 +-
 drivers/net/vxge/vxge-main.c                       |   64 +-
 drivers/net/vxge/vxge-main.h                       |   59 +-
 drivers/net/vxge/vxge-traffic.c                    |  101 +--
 drivers/net/vxge/vxge-traffic.h                    |  134 --
 drivers/net/wireless/ath/ath5k/base.c              |    1 +
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  191 ++-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   14 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    2 +-
 drivers/net/wireless/ath/ath9k/init.c              |    1 +
 drivers/net/wireless/ath/ath9k/main.c              |    7 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    8 +-
 drivers/net/wireless/ath/carl9170/cmd.h            |   51 +-
 drivers/net/wireless/ath/carl9170/main.c           |    2 +-
 drivers/net/wireless/ath/carl9170/usb.c            |   25 +-
 drivers/net/wireless/b43/phy_n.c                   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |    3 +-
 drivers/net/wireless/wl1251/Makefile               |    8 +-
 include/linux/connector.h                          |    8 -
 include/linux/netdevice.h                          |   18 +-
 include/linux/phy.h                                |   12 -
 include/net/caif/caif_shm.h                        |   26 +
 include/net/dst.h                                  |    2 +-
 include/net/fib_rules.h                            |    2 +-
 include/net/garp.h                                 |    2 +-
 include/net/inetpeer.h                             |    2 +-
 include/net/ip.h                                   |    4 +-
 include/net/ip6_tunnel.h                           |    2 +-
 include/net/ipip.h                                 |    6 +-
 include/net/net_namespace.h                        |    2 +-
 include/net/protocol.h                             |    4 +-
 include/net/sock.h                                 |    2 +-
 include/net/xfrm.h                                 |    4 +-
 net/802/garp.c                                     |   18 +-
 net/802/stp.c                                      |    4 +-
 net/8021q/vlan.c                                   |    6 +-
 net/core/dev.c                                     |   38 +-
 net/core/fib_rules.c                               |   21 +-
 net/core/filter.c                                  |    4 +-
 net/core/net-sysfs.c                               |   20 +-
 net/core/net_namespace.c                           |    4 +-
 net/core/pktgen.c                                  |   30 +-
 net/core/sock.c                                    |    2 +-
 net/core/sysctl_net_core.c                         |    3 +-
 net/ipv4/fib_hash.c                                |   36 +-
 net/ipv4/gre.c                                     |    5 +-
 net/ipv4/inetpeer.c                                |  138 ++-
 net/ipv4/ip_gre.c                                  |    1 +
 net/ipv4/ip_sockglue.c                             |   10 +-
 net/ipv4/ipip.c                                    |    1 +
 net/ipv4/protocol.c                                |    8 +-
 net/ipv4/route.c                                   |   75 +-
 net/ipv4/tunnel4.c                                 |   29 +-
 net/ipv4/udp.c                                     |    2 +-
 net/ipv6/addrconf.c                                |   16 +-
 net/ipv6/ip6_tunnel.c                              |    2 +
 net/ipv6/ipv6_sockglue.c                           |    4 +
 net/ipv6/netfilter/Kconfig                         |    5 +
 net/ipv6/netfilter/Makefile                        |    5 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c            |    5 +-
 net/ipv6/protocol.c                                |    8 +-
 net/ipv6/raw.c                                     |    2 +-
 net/ipv6/sit.c                                     |    1 +
 net/ipv6/tunnel6.c                                 |   24 +-
 net/ipv6/udp.c                                     |    2 +-
 net/l2tp/l2tp_core.c                               |   53 +-
 net/l2tp/l2tp_core.h                               |   33 -
 net/l2tp/l2tp_ip.c                                 |    2 +-
 net/mac80211/ibss.c                                |    1 +
 net/mac80211/main.c                                |    8 +-
 net/mac80211/rate.c                                |    3 +
 net/netfilter/Kconfig                              |    2 +
 net/netfilter/xt_TPROXY.c                          |   10 +-
 net/netfilter/xt_socket.c                          |   12 +-
 net/netlink/af_netlink.c                           |   65 +-
 net/wireless/reg.c                                 |    2 +-
 145 files changed, 4008 insertions(+), 1822 deletions(-)
 create mode 100644 drivers/net/caif/caif_shm_u5500.c
 create mode 100644 drivers/net/caif/caif_shmcore.c
 create mode 100644 drivers/net/can/pch_can.c
 create mode 100644 drivers/net/can/sja1000/tscan1.c
 create mode 100644 include/net/caif/caif_shm.h
