From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 22 Jul 2015 13:22:43 -0700 (PDT)
Message-ID: <20150722.132243.1480211616731554560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Don't use shared bluetooth antenna in iwlwifi driver for
   management frames, from Emmanuel Grumbach.

2) Fix device ID check in ath9k driver, from Felix Fietkau.

3) Off by one in xen-netback BUG checks, from Dan Carpenter.

4) Fix IFLA_VF_PORT netlink attribute validation, from Daniel
   Borkmann.

5) Fix races in setting peeked bit flag in SKBs during datagram
   receive.  If it's shared we have to clone it otherwise the
   value can easily be corrupted.  Fix from Herbert Xu.

6) Revert fec clock handling change, causes regressions.  From
   Fabio Estevam.

7) Fix use after free in fq_codel and sfq packet schedulers, from WANG
   Cong.

8) ipvlan bug fixes (memory leaks, missing rcu_dereference_bh, etc.)
   from WANG Cong and Konstantin Khlebnikov.

9) Memory leak in act_bpf packet action, from Alexei Starovoitov.

10) ARM bpf JIT bug fixes from Nicolas Schichan.

11) Fix backwards compat of ANY_LAYOUT in virtio_net driver, from
    Michael S. Tsirkin.

12) Destruction of bond with different ARP header types not handled
    correctly, fix from Nikolay Aleksandrov.

13) Revert GRO receive support in ipv6 SIT tunnel driver, causes
    regressions because the GRO packets created cannot be processed
    properly on the GSO side if we forward the frame.  From Herbert
    Xu.

14) TCCR update race and other fixes to ravb driver from Sergei
    Shtylyov.

15) Fix SKB leaks in caif_queue_rcv_skb(), from Eric Dumazet.

16) Fix panics on packet scheduler filter replace, from Daniel
    Borkmann.

17) Make sure AF_PACKET sees properly IP headers in defragmented
    frames (via PACKET_FANOUT_FLAG_DEFRAG option), from Edward
    Hyunkoo Jee.

18) AF_NETLINK cannot hold mutex in RCU callback, fix from Florian
    Westphal.

Please pull, thanks a lot!

The following changes since commit f760b87f8f12eb262f14603e65042996fe03720e:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-07-13 11:18:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to d8b48911fd249bc1a3431a9515619403c96d6af3:

  ravb: fix ring memory allocation (2015-07-21 22:34:27 -0700)

----------------------------------------------------------------
Alexei Starovoitov (1):
      tc: act_bpf: fix memory leak

Arik Nemtsov (1):
      cfg80211: use RTNL locked reg_can_beacon for IR-relaxation

Avraham Stern (1):
      iwlwifi: mvm: Add preemptive flag to scheulded scan

Bob Copeland (2):
      mac80211: correct aid location in peering frames
      mac80211: add missing length check for confirm frames

Chaitanya T K (1):
      mac80211: wowlan: enable powersave if suspend while ps-polling

Chris J Arges (1):
      openvswitch: allocate nr_node_ids flow_stats instead of num_possible_nodes

Chris Mason (1):
      Bluetooth: btbcm: allow btbcm_read_verbose_config to fail on Apple

Dan Carpenter (1):
      net/xen-netback: off by one in BUG_ON() condition

Dan Murphy (1):
      net: phy: dp83867: Fix warning check for setting the internal delay

Daniel Borkmann (4):
      rtnetlink: reject non-IFLA_VF_PORT attributes inside IFLA_VF_PORTS
      sched: cls_bpf: fix panic on filter replace
      sched: cls_flower: fix panic on filter replace
      sched: cls_flow: fix panic on filter replace

David S. Miller (9):
      Merge branch 'isdn-gigaset-fixes'
      Merge tag 'linux-can-fixes-for-4.2-20150715' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'ipvlan'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge tag 'linux-can-fixes-for-4.2-20150716' of git://git.kernel.org/.../mkl/linux-can
      Merge tag 'mac80211-for-davem-2015-07-17' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'sch_panic'
      Merge tag 'wireless-drivers-for-davem-2015-07-20' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'arm-bpf-fixes'

Dreyfuss, Haim (1):
      iwlwifi: pcie: Fix bug in NIC's PM registers access

Edward Hyunkoo Jee (1):
      inet: frags: fix defragmented packet's IP header for af_packet

Emmanuel Grumbach (4):
      iwlwifi: mvm: fix antenna selection when BT is active
      iwlwifi: pcie: don't panic if pcie transport alloc fails
      iwlwifi: pcie: prepare the device before accessing it
      Revert "iwlwifi: pcie: New RBD allocation model"

Eric Dumazet (3):
      ipv6: lock socket in ip6_datagram_connect()
      caif: fix leaks and race in caif_queue_rcv_skb()
      tcp: suppress a division by zero warning

Fabio Estevam (1):
      Revert "net: fec: Ensure clocks are enabled while using mdio bus"

Felix Fietkau (1):
      ath9k_hw: fix device ID check for AR956x

Florian Fainelli (1):
      net: dsa: bcm_sf2: do not use indirect reads and writes for 7445E0

Florian Westphal (1):
      netlink: don't hold mutex in rcu callback when releasing mmapd ring

Herbert Xu (3):
      net: Clone skb before setting peeked flag
      net: Fix skb csum races when peeking
      Revert "sit: Add gro callbacks to sit_offload"

Joachim Eastwood (1):
      stmmac: fix setting of driver data in stmmac_dvr_probe

Johannes Berg (2):
      iwlwifi: mvm: check time-event vif to avoid bad deletion
      mac80211: shut down interfaces before destroying interface list

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-06-12' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Karicheri, Muralidharan (1):
      net: netcp: fix improper initialization in netcp_ndo_open()

Konstantin Khlebnikov (5):
      ipvlan: remove counters of ipv4 and ipv6 addresses
      ipvlan: plug memory leak in ipvlan_link_delete
      ipvlan: unhash addresses without synchronize_rcu
      ipvlan: ignore addresses from ipv6 autoconfiguration
      net: ratelimit warnings about dst entry refcount underflow or overflow

Liad Kaufman (1):
      iwlwifi: nvm: remove mac address byte swapping in 8000 family

Marc Kleine-Budde (12):
      can: at91_can: don't touch skb after netif_receive_skb()/netif_rx()
      can: flexcan: don't touch skb after netif_receive_skb()
      can: bfin_can: don't touch skb after netif_rx()
      can: grcan: don't touch skb after netif_rx()
      can: slcan: don't touch skb after netif_rx_ni()
      can: ti_heccn: don't touch skb after netif_rx()
      can: cc770: don't touch skb after netif_rx()
      can: sja1000: don't touch skb after netif_rx()
      can: esd_usb2: don't touch skb after netif_rx()
      can: ems_usb: don't touch skb after netif_rx()
      can: usb_8dev: don't touch skb after netif_rx()
      can: pcan_usb: don't touch skb after netif_rx()

Matti Gottlieb (1):
      iwlwifi: mvm: Avoid accessing Null pointer when setting igtk

Michael S. Tsirkin (1):
      virtio_net: don't require ANY_LAYOUT with VERSION_1

Michal Kazior (1):
      mac80211: don't clear all tx flags when requeing

Mugunthan V N (1):
      drivers: net: cpsw: remove tx event processing in rx napi poll

Nicolas Schichan (3):
      ARM: net: fix condition for load_order > 0 when translating load instructions.
      ARM: net: handle negative offsets in BPF JIT.
      ARM: net: fix vlan access instructions in ARM JIT.

Nikolay Aleksandrov (3):
      bridge: mdb: fix double add notification
      bonding: fix destruction of bond with devices different from arphrd_ether
      bonding: correctly handle bonding type change on enslave failure

Oren Givon (1):
      iwlwifi: edit the 3165 series and 8000 series PCI IDs

Reinhard Speyerer (1):
      qmi_wwan: add the second QMI/network interface for Sierra Wireless MC7305/MC7355

Richard Stearn (1):
      NET: AX.25: Stop heartbeat timer on disconnect.

Satish Ashok (1):
      bridge: multicast: treat igmpv3 report with INCLUDE and no sources as a leave

Sergei Shtylyov (3):
      ravb: do not invalidate cache for RX buffer twice
      ravb: fix race updating TCCR
      ravb: fix ring memory allocation

Shaohui Xie (1):
      net/mdio: fix mdio_bus_match for c45 PHY

Simon Guinot (1):
      net: mvneta: fix refilling for Rx DMA buffers

Stefan Agner (2):
      can: mcp251x: fix resume when device is down
      can: mcp251x: get regulators optionally

Thomas Petazzoni (1):
      wireless: regulatory: reduce log level of CRDA related messages

Tilman Schmidt (2):
      isdn/gigaset: reset tty->receive_room when attaching ser_gigaset
      isdn/gigaset: drop unused ldisc methods

Tom Hughes (1):
      mac80211: clear subdir_stations when removing debugfs

Vivien Didelot (1):
      net: dsa: mv88e6xxx: fix fid_mask when leaving bridge

WANG Cong (4):
      fq_codel: fix a use-after-free
      ipvlan: use rcu_deference_bh() in ipvlan_queue_xmit()
      net_sched: fix a use-after-free in sfq
      fq_codel: fix return value of fq_codel_drop()

Yuchung Cheng (1):
      tcp: don't use F-RTO on non-recurring timeouts

dingtianhong (1):
      bonding: correct the MAC address for "follow" fail_over_mac policy

 arch/arm/net/bpf_jit_32.c                         |  57 +++++++++++---
 drivers/bluetooth/btbcm.c                         |  11 ++-
 drivers/isdn/gigaset/ser-gigaset.c                |  35 +++------
 drivers/net/bonding/bond_main.c                   |  34 +++++++-
 drivers/net/can/at91_can.c                        |   8 +-
 drivers/net/can/bfin_can.c                        |   6 +-
 drivers/net/can/cc770/cc770.c                     |   4 +-
 drivers/net/can/flexcan.c                         |   7 +-
 drivers/net/can/grcan.c                           |   3 +-
 drivers/net/can/sja1000/sja1000.c                 |   6 +-
 drivers/net/can/slcan.c                           |   2 +-
 drivers/net/can/spi/mcp251x.c                     |  17 ++--
 drivers/net/can/ti_hecc.c                         |   2 +-
 drivers/net/can/usb/ems_usb.c                     |   6 +-
 drivers/net/can/usb/esd_usb2.c                    |   6 +-
 drivers/net/can/usb/peak_usb/pcan_usb.c           |   7 +-
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c       |   4 +-
 drivers/net/can/usb/usb_8dev.c                    |   6 +-
 drivers/net/dsa/bcm_sf2.c                         |  15 +++-
 drivers/net/dsa/mv88e6xxx.c                       |   2 +-
 drivers/net/ethernet/freescale/fec_main.c         |  88 +++------------------
 drivers/net/ethernet/marvell/mvneta.c             |  22 +++---
 drivers/net/ethernet/renesas/ravb_main.c          |  74 ++++++++---------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   2 +-
 drivers/net/ethernet/ti/cpsw.c                    |   9 +--
 drivers/net/ethernet/ti/netcp_core.c              |   2 +-
 drivers/net/ipvlan/ipvlan.h                       |   9 ++-
 drivers/net/ipvlan/ipvlan_core.c                  |   6 +-
 drivers/net/ipvlan/ipvlan_main.c                  |  42 +++++-----
 drivers/net/phy/dp83867.c                         |   2 +-
 drivers/net/phy/mdio_bus.c                        |  19 ++++-
 drivers/net/usb/qmi_wwan.c                        |   1 +
 drivers/net/virtio_net.c                          |   3 +-
 drivers/net/wireless/ath/ath9k/hw.c               |   1 +
 drivers/net/wireless/iwlwifi/iwl-fh.h             |   6 ++
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c      |  12 ++-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h    |   3 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c           |   3 +
 drivers/net/wireless/iwlwifi/mvm/sta.c            |   3 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c     |   2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c             |   2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c           |   5 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h      |  51 ++----------
 drivers/net/wireless/iwlwifi/pcie/rx.c            | 414 ++++++++++++++++++++----------------------------------------------------------------------------
 drivers/net/wireless/iwlwifi/pcie/trans.c         |  52 ++++++------
 drivers/net/xen-netback/netback.c                 |   6 +-
 include/net/cfg80211.h                            |  17 ++++
 include/net/ip.h                                  |   1 +
 net/ax25/ax25_subr.c                              |   1 +
 net/bridge/br_mdb.c                               |   1 -
 net/bridge/br_multicast.c                         |  37 +++++++--
 net/caif/caif_socket.c                            |  19 ++---
 net/core/datagram.c                               |  56 ++++++++++---
 net/core/dst.c                                    |   4 +-
 net/core/rtnetlink.c                              |  11 ++-
 net/ipv4/datagram.c                               |  16 +++-
 net/ipv4/inet_hashtables.c                        |  11 ++-
 net/ipv4/ip_fragment.c                            |   6 +-
 net/ipv4/tcp_input.c                              |   3 +-
 net/ipv6/datagram.c                               |  20 +++--
 net/ipv6/ip6_offload.c                            |   2 -
 net/mac80211/debugfs_netdev.c                     |   1 +
 net/mac80211/iface.c                              |  25 +++---
 net/mac80211/mesh_plink.c                         |   5 +-
 net/mac80211/pm.c                                 |  16 ++++
 net/mac80211/tdls.c                               |   6 +-
 net/mac80211/tx.c                                 |   4 +-
 net/netlink/af_netlink.c                          |  79 +++++++++++--------
 net/openvswitch/flow_table.c                      |   2 +-
 net/sched/act_bpf.c                               |   3 +
 net/sched/cls_bpf.c                               |   2 +-
 net/sched/cls_flow.c                              |   5 +-
 net/sched/cls_flower.c                            |   2 +-
 net/sched/sch_fq_codel.c                          |  13 ++-
 net/sched/sch_sfq.c                               |   2 +-
 net/wireless/chan.c                               |  45 ++++++++---
 net/wireless/nl80211.c                            |  14 ++--
 net/wireless/reg.c                                |   8 +-
 net/wireless/trace.h                              |  11 ++-
 79 files changed, 714 insertions(+), 811 deletions(-)
