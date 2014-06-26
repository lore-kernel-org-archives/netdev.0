From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 25 Jun 2014 21:06:01 -0700 (PDT)
Message-ID: <20140625.210601.2158881138909512893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix crash in ipvs tot_stats estimator, from Julian Anastasov.

2) Fix OOPS in nf_nat on netns removal, from Florian Westphal.

3) Really really really fix locking issues in slip and slcan tty write
   wakeups, from Tyler Hall.

4) Fix checksum offloading in fec driver, from Fugang Duan.

5) Off by one in BPF instruction limit test, from Kees Cook.

6) Need to clear all TSO capability flags when doing software TSO
   in tg3 driver, from Prashant Sreedharan.

7) Fix memory leak in vlan_reorder_header() error path, from Li
   RongQing.

8) Fix various bugs in xen-netfront and xen-netback multiqueue
   support, from David Vrabel and Wei Liu.

9) Fix deadlock in cxgb4 driver, from Li RongQing.

10) Prevent double free of no-cache DST entries, from Eric Dumazet.

11) Bad csum_start handling in skb_segment() leads to crashes when
    forwarding, from Tom Herbert.

Please pull, thanks a lot!

The following changes since commit 7171511eaec5bf23fb06078f59784a3a0626=
b38f:

  Linux 3.16-rc1 (2014-06-15 17:45:28 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to de843723f9b989178762196fb24dd050cbe20ca3=
:

  net: fix setting csum_start in skb_segment() (2014-06-25 20:45:54 -07=
00)

----------------------------------------------------------------
Bj=A9=AArn Mork (1):
      net: huawei_cdc_ncm: increase command buffer size

Chin-Ran Lo (1):
      mwifiex: fix tx_info/rx_info overlap with PCIe dma_mapping

Chris Metcalf (1):
      net: tile: fix unused variable warning

Christian Riesch (1):
      ptp: In the testptp utility, use clock_adjtime from glibc when av=
ailable

Daniel Borkmann (2):
      net: sctp: propagate sysctl errors from proc_do* properly
      net: sctp: check proc_dointvec result in proc_sctp_do_auth

Daniel Mack (3):
      net: phylib: add link_change_notify callback to phy device
      net: phy: at803x: use #defines for supported PHY ids
      net: phy: at803x: Add support for hardware reset

Dave Jones (2):
      tcp: remove unnecessary tcp_sk assignment.
      hyperv: fix apparent cut-n-paste error in send path teardown

David S. Miller (5):
      Merge git://git.kernel.org/.../pablo/nf
      Revert "net: return actual error on register_queue_kobjects"
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'at803x'
      Merge branch 'xen-netfront'

David Vrabel (2):
      xen-netfront: fix oops when disconnected from backend
      xen-netfront: recreate queues correctly when reconnecting

Eric Dumazet (1):
      ipv4: fix dst race in sk_dst_get()

=46engguang Wu (1):
      net: phy: at803x: fix coccinelle warnings

=46lorian Westphal (2):
      netfilter: ctnetlink: fix refcnt leak in dying/unconfirmed list d=
umper
      netfilter: nf_nat: fix oops on netns removal

=46ugang Duan (1):
      net: fec: Don't clear IPV6 header checksum field when IP accelera=
tor enable

Jean Delvare (3):
      isdn: hisax: Merge Kconfig ifs
      isdn: hisax: Drop duplicate Kconfig entry
      ptp: ptp_pch depends on x86_32

Jie Liu (1):
      net: return actual error on register_queue_kobjects

Johan Hedberg (9):
      Bluetooth: Fix incorrectly overriding conn->src_type
      Bluetooth: Fix check for connection encryption
      Bluetooth: Fix SSP acceptor just-works confirmation without MITM
      Bluetooth: Add clarifying comment for conn->auth_type
      Bluetooth: Fix setting correct authentication information for SMP=
 STK
      Bluetooth: Fix indicating discovery state when canceling inquiry
      Bluetooth: Refactor discovery stopping into its own function
      Bluetooth: Reuse hci_stop_discovery function when cleaning up HCI=
 state
      Bluetooth: Fix locking of hdev when calling into SMP code

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jukka Taimisto (1):
      Bluetooth: Fix deadlock in l2cap_conn_del()

Julian Anastasov (1):
      ipvs: stop tot_stats estimator only under CONFIG_SYSCTL

Kees Cook (1):
      net: filter: fix upper BPF instruction limit

Ken-ichirou MATSUZAWA (1):
      netfilter: ctnetlink: add zone size to length

Li RongQing (2):
      8021q: fix a potential memory leak
      cxgb4: Not need to hold the adap_rcu_lock lock when read adap_rcu=
_list

Marcin Kraglak (1):
      Bluetooth: Allow change security level on ATT_CID in slave role

Maxime Ripard (1):
      net: allwinner: emac: Add missing free_irq

Michael Braun (2):
      rt2800usb:fix efuse detection
      rt2800usb:fix hang during firmware load

Mirko Lindner (1):
      skge: Added FS A8NE-FM to the list of 32bit DMA boards

Mugunthan V N (1):
      drivers: net: cpsw: fix dual EMAC stall when connected to same sw=
itch

Neal Cardwell (1):
      tcp: fix tcp_match_skb_to_sack() for unaligned SACK at end of an =
skb

Neil Horman (1):
      vmxnet3: adjust ring sizes when interface is down

Ondrej Zary (1):
      tulip: Poll link status more frequently for Comet chips

Or Gerlitz (2):
      bonding: Advertize vxlan offload features when supported
      net/mlx4_core: Fix the error flow when probing with invalid VF co=
nfiguration

Pablo Neira Ayuso (10):
      netfilter: ctnetlink: fix dumping of dying/unconfirmed conntracks
      netfilter: nf_tables: use RCU-safe list insertion when replacing =
rules
      netfilter: nf_tables: use u32 for chain use counter
      netfilter: nf_tables: decrement chain use counter when replacing =
rules
      netfilter: nf_tables: fix wrong type in transaction when replacin=
g rules
      netfilter: nft_compat: call {target, match}->destroy() to cleanup=
 entry
      netfilter: nf_tables: indicate family when dumping set elements
      netfilter: nft_nat: don't dump port information if unset
      Merge branch 'ipvs'
      MAINTAINERS: merge ebtables into netfilter entry

Phoebe Buckheister (1):
      at86rf230: fix irq setup

Prashant Sreedharan (2):
      tg3: Clear NETIF_F_TSO6 flag before doing software GSO
      tg3: Change nvram command timeout value to 50ms

Rafa=A9=A9 Mi=A9=A9ecki (3):
      b43: disable 5 GHz on G-PHY
      b43: fix typo in Kconfig (make B43_BUSES_BCMA_AND_SSB the default=
 for real)
      b43: fix frequency reported on G-PHY with /new/ firmware

Richard Retanubun (1):
      of: mdio: fixup of_phy_register_fixed_link parsing of new binding=
s

Stanislaw Gruszka (2):
      rt2x00: disable TKIP on USB
      rt2x00: fix rfkill regression on rt2500pci

Suresh Reddy (1):
      be2net: fix qnq mode detection on VFs

Thadeu Lima de Souza Cascardo (1):
      cxgb4: use dev_port to identify ports

Tobias Klauser (3):
      trivial: net: filter: Fix typo in comment
      trivial: net: filter: Change kerneldoc parameter order
      net: filter: Use kcalloc/kmalloc_array to allocate arrays

Tom Herbert (1):
      net: fix setting csum_start in skb_segment()

Tyler Hall (2):
      slip: Fix deadlock in write_wakeup
      slcan: Port write_wakeup deadlock fix from slip

Wei Liu (1):
      xen-netback: bookkeep number of active queues in our own module

 Documentation/ptp/testptp.c                     |   5 +-
 MAINTAINERS                                     |  11 +----
 drivers/isdn/hisax/Kconfig                      |  11 +----
 drivers/net/bonding/bond_main.c                 |   9 ++++
 drivers/net/can/slcan.c                         |  37 +++++++++++----
 drivers/net/ethernet/allwinner/sun4i-emac.c     |   1 +
 drivers/net/ethernet/broadcom/tg3.c             |   8 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  16 +++----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   1 +
 drivers/net/ethernet/dec/tulip/timer.c          |   2 +-
 drivers/net/ethernet/emulex/benet/be.h          |   4 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h     |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c     |   4 +-
 drivers/net/ethernet/freescale/fec_main.c       |   8 +++-
 drivers/net/ethernet/marvell/skge.c             |   7 +++
 drivers/net/ethernet/mellanox/mlx4/main.c       |   3 +-
 drivers/net/ethernet/ti/cpsw.c                  |   7 ++-
 drivers/net/ethernet/tile/tilegx.c              |   1 -
 drivers/net/hyperv/netvsc.c                     |   2 +-
 drivers/net/ieee802154/at86rf230.c              |   5 +-
 drivers/net/phy/at803x.c                        | 195 ++++++++++++++++=
++++++++++++++++++++++++++++++++++++++++++++------------------
 drivers/net/phy/phy.c                           |   3 ++
 drivers/net/slip/slip.c                         |  36 +++++++++++----
 drivers/net/slip/slip.h                         |   1 +
 drivers/net/usb/huawei_cdc_ncm.c                |   7 +--
 drivers/net/vmxnet3/vmxnet3_drv.c               |   7 ++-
 drivers/net/vmxnet3/vmxnet3_ethtool.c           |  12 +++--
 drivers/net/vmxnet3/vmxnet3_int.h               |   5 ++
 drivers/net/wireless/b43/Kconfig                |   2 +-
 drivers/net/wireless/b43/main.c                 |   1 +
 drivers/net/wireless/b43/xmit.c                 |  10 ++--
 drivers/net/wireless/mwifiex/pcie.c             |   4 +-
 drivers/net/wireless/mwifiex/util.h             |  43 +++++++++++++---=
-
 drivers/net/wireless/rt2x00/rt2500pci.c         |   7 ++-
 drivers/net/wireless/rt2x00/rt2800usb.c         |  39 ++++++++++++++--
 drivers/net/wireless/rt2x00/rt2x00.h            |   1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c         |  24 ++++++++--
 drivers/net/wireless/rt2x00/rt2x00mac.c         |   2 +
 drivers/net/wireless/rt2x00/rt2x00usb.h         |   1 +
 drivers/net/xen-netback/common.h                |   1 +
 drivers/net/xen-netback/interface.c             |  49 +++++-----------=
----
 drivers/net/xen-netback/xenbus.c                |  28 ++++++------
 drivers/net/xen-netfront.c                      | 109 ++++++++++++++++=
++++++++++++++--------------
 drivers/of/of_mdio.c                            |   8 ++--
 drivers/ptp/Kconfig                             |   2 +-
 include/linux/phy.h                             |   9 ++++
 include/net/netfilter/nf_tables.h               |   6 +--
 include/net/sock.h                              |   4 +-
 net/8021q/vlan_core.c                           |   5 +-
 net/bluetooth/hci_conn.c                        |   7 +--
 net/bluetooth/hci_event.c                       |  17 +++++--
 net/bluetooth/l2cap_core.c                      |   8 +++-
 net/bluetooth/l2cap_sock.c                      |   5 --
 net/bluetooth/mgmt.c                            | 104 ++++++++++++++++=
+++++++-------------------
 net/bluetooth/smp.c                             |   9 +++-
 net/core/dst.c                                  |  16 +++++--
 net/core/filter.c                               |  10 ++--
 net/core/skbuff.c                               |   2 +-
 net/ipv4/ip_tunnel.c                            |  14 ++----
 net/ipv4/tcp_fastopen.c                         |   2 +-
 net/ipv4/tcp_input.c                            |   2 +-
 net/netfilter/ipvs/ip_vs_ctl.c                  |   2 +-
 net/netfilter/nf_conntrack_netlink.c            |  20 +++++---
 net/netfilter/nf_nat_core.c                     |  35 +++++++++++++-
 net/netfilter/nf_tables_api.c                   |  11 +++--
 net/netfilter/nft_compat.c                      |  18 ++++++++
 net/netfilter/nft_nat.c                         |  14 +++---
 net/sctp/sysctl.c                               |  46 ++++++++++------=
---
 68 files changed, 741 insertions(+), 366 deletions(-)
