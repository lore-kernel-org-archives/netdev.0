From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 10 Sep 2015 12:42:34 -0700 (PDT)
Message-ID: <20150910.124234.719744288193220381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix out-of-bounds array access in netfilter ipset, from Jozsef
   Kadlecsik.

2) Use correct free operation on netfilter conntrack templates, from
   Daniel Borkmann.

3) Fix route leak in SCTP, from Marcelo Ricardo Leitner.

4) Fix sizeof(pointer) in mac80211, from Thierry Reding.

5) Fix cache pointer comparison in ip6mr leading to missed
   unlock of mrt_lock.  From Richard Laing.

6) rds_conn_lookup() needs to consider network namespace in key
   comparison, from Sowmini Varadhan.

7) Fix deadlock in TIPC code wrt. broadcast link wakeups, from
   Kolmakov Dmitriy.

8) Fix fd leaks in bpf syscall, from Daniel Borkmann.

9) Fix error recovery when installing ipv6 multipath routes,
   we would delete the old route before we would know if we
   could fully commit to the new set of nexthops.  Fix from
   Roopa Prabhu.

10) Fix run-time suspend problems in r8152, from Hayes Wang.

11) In fec, don't program the MAC address into the chip when
    the clocks are gated off.  From Fugang Duan.

12) Fix poll behavior for netlink sockets when using rx ring mmap,
    from Daniel Borkmann.

13) Don't allocate memory with GFP_KERNEL from get_stats64 in
    r8169 driver, from Corinna Vinschen.

14) In TCP Cubic congestion control, handle idle periods better
    where we are application limited, in order to keep cwnd from
    growing out of control.  From Eric Dumzet.

Please pull, thanks a lot!

The following changes since commit dd5cdb48edfd34401799056a9acf61078d77=
3f90:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2=
015-09-03 08:08:17 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net=20

for you to fetch changes up to 30927520dbae297182990bb21d08762bcc35ce1d=
:

  tcp_cubic: better follow cubic curve after idle period (2015-09-10 10=
:58:33 -0700)

----------------------------------------------------------------
Alexei Starovoitov (1):
      bpf: fix out of bounds access in verifier log

Alexey Brodkin (1):
      stmmac: fix check for phydev being open

Arik Nemtsov (1):
      mac80211: avoid VHT usage with no 80MHz chans allowed

Atsushi Nemoto (2):
      net: eth: altera: fix napi poll_list corruption
      net: eth: altera: Fix the initial device operstate

Avri Altman (1):
      mac80211: protect non-HT BSS when HT TDLS traffic exists

Barry Song (1):
      dm9000: fix a typo

Bernhard Thaler (1):
      netfilter: bridge: fix IPv6 packets not being bridged with CONFIG=
_IPV6=3Dn

Corinna Vinschen (1):
      r8169: Fix sleeping function called during get_stats64, v2

Daniel Borkmann (4):
      netfilter: conntrack: use nf_ct_tmpl_free in CT/synproxy error pa=
ths
      ebpf: fix fd refcount leaks related to maps in bpf syscall
      netlink, mmap: don't walk rx ring on poll if receive queue non-em=
pty
      netlink, mmap: fix edge-case leakages in nf queue zero-copy

David S. Miller (5):
      Merge branch 'sctp-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'mac80211-for-davem-2015-09-04' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'cxgb4-fixes'
      Merge branch 'r8152-autoresume'

David Vrabel (1):
      xen-netback: require fewer guest Rx slots when not using GSO

Elad Raz (1):
      netfilter: ipset: Fixing unnamed union init

Eric Dumazet (1):
      tcp_cubic: better follow cubic curve after idle period

Eugene Shatokhin (1):
      usbnet: Fix a race between usbnet_stop() and the BH

=46lorian Fainelli (2):
      net: dsa: bcm_sf2: Fix ageing conditions and operation
      net: dsa: bcm_sf2: Fix 64-bits register writes

Geert Uytterhoeven (3):
      lan78xx: Fix ladv/radv error handling in lan78xx_link_reset()
      vxlan: Refactor vxlan_udp_encap_recv() to kill compiler warning
      ethernet: synopsys: SYNOPSYS_DWC_ETH_QOS should depend on HAS_DMA

Hariprasad Shenai (3):
      cxgb4: Fix tx flit calculation
      cxgb4: Fix for write-combining stats configuration
      cxgb4: changes for new firmware 1.14.4.0

Henrik Austad (1):
      ether: add IEEE 1722 ethertype - TSN

Jiri Pirko (1):
      switchdev: fix return value of switchdev_port_fdb_dump in case of=
 error

Joe Stringer (1):
      openvswitch: Remove conntrack Kconfig option.

Johannes Berg (1):
      mac80211: reject software RSSI CQM with beacon filtering

Jozsef Kadlecsik (1):
      netfilter: ipset: Out of bound access in hash:net* types fixed

Jo=E3o Paulo Rechi Vita (1):
      rfkill: Copy "all" global state to other types

Julien Grall (1):
      device property: Don't overwrite addr when failing in device_get_=
mac_address

Kolmakov Dmitriy (1):
      net: tipc: fix stall during bclink wakeup procedure

Maciej S. Szmigiero (2):
      cfg80211: regulatory: restore proper user alpha2
      net: fec: normalize return value of pm_runtime_get_sync() in MDIO=
 write

Marcelo Ricardo Leitner (2):
      sctp: fix dst leak
      sctp: add routing output fallback

Neal Cardwell (1):
      tcp: generate CA_EVENT_TX_START on data frames

Nimrod Andy (1):
      net: fec: add netif status check before set mac address

Pablo Neira Ayuso (2):
      netfilter: nf_tables: Use 32 bit addressing register from nft_typ=
e_to_reg()
      netfilter: nfnetlink: work around wrong endianess in res_id field

Phil Sutter (1):
      net: ipv6: use common fib_default_rule_pref

Rasmus Villemoes (4):
      net: cavium: liquidio: use kzalloc in setup_glist()
      net: jme: use kzalloc() instead of kmalloc+memset
      net: mv643xx_eth: use kzalloc
      net: qlcnic: delete redundant memsets

Richard Laing (1):
      net/ipv6: Correct PIM6 mrt_lock handling

Roopa Prabhu (1):
      ipv6: fix multipath route replace error recovery

Sasha Levin (1):
      RDS: verify the underlying transport exists before creating a con=
nection

Sathya Perla (1):
      be2net: Revert "make the RX_FILTER command asynchronous" commit

Sergei Shtylyov (1):
      fixed_phy: pass 'irq' to fixed_phy_add()

Sowmini Varadhan (1):
      RDS: rds_conn_lookup() should factor in the struct net for a matc=
h

Sudip Mukherjee (1):
      net: wan: sbni: fix device usage count

Thierry Reding (1):
      mac80211: Do not use sizeof() on pointer type

Tobias Klauser (1):
      net: ethoc: Remove unnecessary #ifdef CONFIG_OF

Vivien Didelot (3):
      net: dsa: mv88e6171: add hardware 802.1Q support
      net: bridge: check __vlan_vid_del for error
      net: bridge: remove unnecessary switchdev include

Wei Liu (2):
      xen-netback: respect user provided max_queues
      xen-netfront: respect user provided max_queues

Woojung.Huh@microchip.com (1):
      add microchip LAN88xx phy driver

Wu Fengguang (1):
      ipv6: fix ifnullfree.cocci warnings

fran=E7ois romieu (1):
      cxgb4: fix usage of uninitialized variable

hayeswang (2):
      r8152: split DRIVER_VERSION
      r8152: fix the runtime suspend issues

 drivers/base/property.c                                  |  14 ++--
 drivers/net/dsa/bcm_sf2.c                                |  12 ++-
 drivers/net/dsa/bcm_sf2.h                                |   4 +-
 drivers/net/dsa/mv88e6171.c                              |   5 ++
 drivers/net/ethernet/altera/altera_tse_main.c            |   4 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c          |   3 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c          |  24 +++---
 drivers/net/ethernet/chelsio/cxgb4/sge.c                 |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h            |  33 +++++++=
-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h        |  12 +--
 drivers/net/ethernet/davicom/dm9000.c                    |   2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c              |   2 +-
 drivers/net/ethernet/ethoc.c                             |   7 +-
 drivers/net/ethernet/freescale/fec_main.c                |  12 ++-
 drivers/net/ethernet/jme.c                               |   8 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c               |   5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      |   2 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c          |   2 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |   2 -
 drivers/net/ethernet/realtek/r8169.c                     | 137 +++++++=
++++++--------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c        |   5 +-
 drivers/net/ethernet/synopsys/Kconfig                    |   2 +-
 drivers/net/phy/Kconfig                                  |   5 ++
 drivers/net/phy/Makefile                                 |   1 +
 drivers/net/phy/fixed_phy.c                              |   2 +-
 drivers/net/phy/microchip.c                              | 148 +++++++=
+++++++++++++++++++++++++++++
 drivers/net/usb/lan78xx.c                                |  11 ++-
 drivers/net/usb/r8152.c                                  |  66 +++++++=
++++++++-
 drivers/net/usb/usbnet.c                                 |  39 +++++++=
---
 drivers/net/vxlan.c                                      |   6 +-
 drivers/net/wan/sbni.c                                   |   2 +
 drivers/net/xen-netback/common.h                         |  10 ---
 drivers/net/xen-netback/netback.c                        |  30 +++++--=
-
 drivers/net/xen-netfront.c                               |   7 +-
 include/linux/microchipphy.h                             |  73 +++++++=
+++++++++++
 include/linux/netlink.h                                  |  13 +++-
 include/net/fib_rules.h                                  |   2 -
 include/net/mac80211.h                                   |   4 +-
 include/net/netfilter/br_netfilter.h                     |   2 +-
 include/net/netfilter/nf_conntrack.h                     |   1 +
 include/net/netfilter/nf_tables.h                        |   2 +-
 include/uapi/linux/if_ether.h                            |   1 +
 kernel/bpf/syscall.c                                     |  12 ++-
 kernel/bpf/verifier.c                                    |   4 +-
 net/bridge/br_netlink.c                                  |   1 -
 net/bridge/br_vlan.c                                     |  17 ++++-
 net/core/fib_rules.c                                     |  10 +--
 net/decnet/dn_rules.c                                    |   1 -
 net/ipv4/fib_rules.c                                     |   1 -
 net/ipv4/ipmr.c                                          |   1 -
 net/ipv4/tcp_cubic.c                                     |  16 ++++
 net/ipv4/tcp_output.c                                    |   6 +-
 net/ipv6/fib6_rules.c                                    |   6 --
 net/ipv6/ip6mr.c                                         |   3 +-
 net/ipv6/route.c                                         | 200 +++++++=
+++++++++++++++++++++++++++++++++++-------
 net/mac80211/cfg.c                                       |   4 +
 net/mac80211/mlme.c                                      |  16 ++++
 net/mac80211/rate.c                                      |   2 +-
 net/mac80211/tdls.c                                      |  70 +++++++=
+++++++++-
 net/mac80211/vht.c                                       |  15 ++++
 net/netfilter/ipset/ip_set_hash_gen.h                    |  12 ++-
 net/netfilter/ipset/ip_set_hash_netnet.c                 |  20 ++++-
 net/netfilter/ipset/ip_set_hash_netportnet.c             |  20 ++++-
 net/netfilter/nf_conntrack_core.c                        |   3 +-
 net/netfilter/nf_synproxy_core.c                         |   2 +-
 net/netfilter/nfnetlink.c                                |   8 +-
 net/netfilter/nfnetlink_queue_core.c                     |   5 +-
 net/netfilter/xt_CT.c                                    |   2 +-
 net/netlink/af_netlink.c                                 |  35 ++++++-=
--
 net/openvswitch/Kconfig                                  |  12 +--
 net/openvswitch/Makefile                                 |   4 +-
 net/openvswitch/conntrack.h                              |   4 +-
 net/rds/connection.c                                     |  15 +++-
 net/rfkill/core.c                                        |  10 ++-
 net/sctp/protocol.c                                      |  10 ++-
 net/switchdev/switchdev.c                                |   6 +-
 net/tipc/bcast.c                                         |  30 +++++++=
-
 net/wireless/reg.c                                       |   2 +-
 78 files changed, 994 insertions(+), 315 deletions(-)
 create mode 100644 drivers/net/phy/microchip.c
 create mode 100644 include/linux/microchipphy.h
