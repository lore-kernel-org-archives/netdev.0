From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 03 Mar 2014 18:28:13 -0500 (EST)
Message-ID: <20140303.182813.737613528805068450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix memory leak in ieee80211_prep_connection(), sta_info leaked on error.
   From Eytan Lifshitz.

2) Unintentional switch case fallthrough in nft_reject_inet_eval(), from
   Patrick McHardy.

3) Much check if payload lenth is a power of 2 in nft_payload_select_ops(),
   from Nikolay Aleksandrov.

4) Fix mis-checksumming in xen-netfront driver, ip_hdr() is not in the
   correct place when we invoke skb_checksum_setup().  From Wei Liu.

5) TUN driver should not advertise HW vlan offload features in
   vlan_features.  Fix from Fernando Luis Vazquez Cao.

6) IPV6_VTI needs to select NET_IPV_TUNNEL to avoid build errors, fix
   from Steffen Klassert.

7) Add missing locking in xfrm_migrade_state_find(), we must hold the
   per-namespace xfrm_state_lock while traversing the lists.  Fix from
   Steffen Klassert.

8) Missing locking in ath9k driver, access to tid->sched must be done
   under ath_txq_lock().  Fix from Stanislaw Gruszka.

9) Fix two bugs in TCP fastopen.  First respect the size argument given
   to tcp_sendmsg() in the fastopen path, and secondly prevent
   tcp_send_syn_data() from potentially using order-5 allocations.
   From Eric Dumazet.

10) Fix handling of default neigh garbage collection params, from
    Jiri Pirko.

11) Fix cwnd bloat and over-inflation of RTT when transmit segmentation
    is in use.  From Eric Dumazet.

12) Missing initialization of Realtek r8169 driver's statistics seqlocks.
    Fix from Kyle McMartin.

13) Fix RTNL assertion failures in 802.3ad and AB ARP monitor of bonding
    driver, from Ding Tianhong.

14) Bonding slave release race can cause divide by zero, fix from Nikolay
    Aleksandrov.

15) Overzealous return from neigh_periodic_work() causes reachability time
    to not be computed.  Fix from Duain Jiong.

16) Fix regression in ipv6_find_hdr(), it should not return -ENOENT when
    a specific target is specified and found.  From Hans Schillstrom.

17) Fix VLAN tag stripping regression in BNA driver, from Ivan Vecera.

18) Tail loss probe can calculate bogus RTTs due to missing packet
    marking on retransmit.  Fix from Yuchung Cheng.

19) We cannot do skb_dst_drop() in iptunnel_pull_header() because multicast
    loopback detection in later code paths need access to skb_rtable().  Fix
    from Xin Long.

20) The macvlan driver regresses in that it propagates lower device offload
    support disables into itself, causing severe slowdowns when running over
    a bridge.  Provide the software offloads always on macvlan devices to
    deal with this and the regression is gone.  From Vlad Yasevich.

Please pull, thanks a lot!

The following changes since commit 960dfc4eb23a28495276b02604d7458e0e1a1ed8:

  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux (2014-02-18 16:36:07 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 8b4703e9bd1172a5f8244276ebb94302e6153e26:

  macvlan: Add support for 'always_on' offload features (2014-03-03 16:43:56 -0500)

----------------------------------------------------------------
Amir Vadai (1):
      net,IB/mlx: Bump all Mellanox driver versions

Amitkumar Karwar (3):
      mwifiex: add NULL check for PCIe Rx skb
      mwifiex: fix cmd and Tx data timeout issue for PCIe cards
      NFC: NCI: Fix NULL pointer dereference

Arend van Spriel (1):
      brcmfmac: fix txglomming scatter-gather packet transfers

Arik Nemtsov (1):
      mac80211: fix sched_scan restart on recovery

Avinash Patil (1):
      mwifiex: clean pcie ring only when device is present

Bing Zhao (2):
      mwifiex: rename usb driver name registerring to usb core
      mwifiex: do not advertise usb autosuspend support

Cristian Bercaru (1):
      phy: unmask link partner capabilities

Dan Carpenter (2):
      hsr: off by one sanity check in hsr_register_frame_in()
      qlcnic: dcb: a couple off by one bugs

Daniel Borkmann (2):
      net: sctp: rework multihoming retransmission path selection to rfc4960
      net: sctp: fix sctp_sf_do_5_1D_ce to verify if we/peer is AUTH capable

David S. Miller (9):
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      ip_tunnel: Move ip_tunnel_get_stats64 into ip_tunnel_core.c
      Merge branch 'tipc'
      Merge branch 'qlcnic'
      Merge branch 'bonding_rtnl'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless
      Merge tag 'linux-can-fixes-for-3.14-20140303' of git://gitorious.org/linux-can/linux-can
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless

Duan Fugang-B38611 (1):
      net: fec: fix potential issue to avoid fec interrupt lost and crc error

Duan Jiong (1):
      neigh: recompute reachabletime before returning from neigh_periodic_work()

Edward Cree (1):
      sfc: check for NULL efx->ptp_data in efx_ptp_event

Emmanuel Grumbach (2):
      mac80211: fix AP powersave TX vs. wakeup race
      iwlwifi: dvm: clear IWL_STA_UCODE_INPROGRESS when assoc fails

Eric Dumazet (3):
      net-tcp: fastopen: fix high order allocations
      tcp: reduce the bloat caused by tcp_is_cwnd_limited()
      net: tcp: use NET_INC_STATS()

Eytan Lifshitz (1):
      mac80211: fix memory leak

FX Le Bail (1):
      netfilter: nf_nat_snmp_basic: fix duplicates in if/else branches

Felix Fietkau (4):
      mac80211: send control port protocol frames to the VO queue
      ath9k: fix ps-poll responses under a-mpdu sessions
      ath9k: reduce baseband hang detection false positive rate
      ath9k: fix invalid descriptor discarding

Fernando Luis Vazquez Cao (1):
      tun: remove bogus hardware vlan acceleration flags from vlan_features

Florian Westphal (1):
      netfilter: nf_tables: fix nf_trace always-on with XT_TRACE=n

Freddy Xin (1):
      AX88179_178A: Add VID:DID for Lenovo OneLinkDock Gigabit LAN

Gerry Demaret (1):
      USB AX88179/178A: Support D-Link DUB-1312

Hannes Frederic Sowa (2):
      ipv6: reuse ip6_frag_id from ip6_ufo_append_data
      ipv4: ipv6: better estimate tunnel header cut for correct ufo handling

Hans Schillstrom (1):
      ipv6: ipv6_find_hdr restore prev functionality

Hauke Mehrtens (2):
      b44: add calls to phy_{start,stop}
      b44: always set duplex mode why phy changes

Hiroaki SHIMODA (1):
      sch_tbf: Fix potential memory leak in tbf_change().

Inbal Hacohen (1):
      cfg80211: bugfix in regulatory user hint process

Ivan Vecera (1):
      bna: fix vlan tag stripping and implement its toggling

James Cameron (1):
      libertas: fix scan result loss if SSID IE len 0

Janusz Dziedzic (1):
      cfg80211: regulatory: reset regdomain in case of error

Jason Wang (1):
      virtio-net: alloc big buffers also when guest can receive UFO

Jiri Bohac (1):
      bonding: disallow enslaving a bond to itself

Jiri Pirko (1):
      neigh: fix setting of default gc_* values

Joe Perches (1):
      MAINTAINERS: Intel nic drivers

Johannes Berg (5):
      mac80211: insert stations before adding to driver
      mac80211: fix station wakeup powersave race
      mac80211: don't validate unchanged AP bandwidth while tracking
      iwlwifi: fix TX status for aggregated packets
      mac80211: fix association to 20/40 MHz VHT networks

John W. Linville (7):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge tag 'nfc-fixes-3.14-1' of git://git.kernel.org/.../sameo/nfc-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Kirill Tkhai (1):
      hostap: Do not free priv until timer handler has actually stopped using it

Kyle McMartin (1):
      r8169: initialize rtl8169_stats seqlock

Lorenzo Colitti (1):
      net: ipv6: ping: Use socket mark in routing lookup

Marc Kleine-Budde (7):
      can: flexcan: fix shutdown: first disable chip, then all interrupts
      can: flexcan: flexcan_open(): fix error path if flexcan_chip_start() fails
      can: flexcan: fix transition from and to low power mode in chip_{en,dis}able
      can: flexcan: factor out transceiver {en,dis}able into seperate functions
      can: flexcan: fix transition from and to freeze mode in chip_{,un}freeze
      can: flexcan: flexcan_remove(): add missing netif_napi_del()
      can: flexcan: factor out soft reset into seperate funtion

Matija Glavinic Pecotic (1):
      net: sctp: Potentially-Failed state should not be reached from unconfirmed state

Max Filippov (1):
      net: ethoc: document OF bindings

Max Stepanov (1):
      iwlwifi: mvm: change of listen interval from 70 to 10

Michael Chan (1):
      tg3: Don't check undefined error bits in RXBD

Mike Pecovnik (1):
      net: Fix permission check in netlink_connect()

Nicolas Dichtel (1):
      sit: fix panic with route cache in ip tunnels

Nikolay Aleksandrov (2):
      netfilter: nf_tables: check if payload length is a power of 2
      bonding: fix a div error caused by the slave release path

Oliver Hartkopp (1):
      can: remove CAN FD compatibility for CAN 2.0 sockets

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: force null nat binding on insert

Patrick McHardy (1):
      netfilter: nft_reject_inet: fix unintended fall-through in switch-statatement

Paul Bolle (1):
      netfilter: nft_meta: fix typo "CONFIG_NET_CLS_ROUTE"

Rajesh Borundia (1):
      qlcnic: Fix number of rings when we fall back from msix to legacy.

Schuyler Patton (1):
      net: cpsw: fix cpdma rx descriptor leak on down interface

Shahed Shaikh (2):
      qlcnic: Fix function return error check
      qlcnic: Fix usage of use_msi and use_msi_x module parameters

Somnath Kotur (1):
      be2net: Fix to reset transparent vlan tagging

Somnath kotur (1):
      be2net: clear promiscuous bits in adapter->flags while disabling promiscuous mode

Stanislaw Gruszka (1):
      ath9k: protect tid->sched check

Steffen Klassert (5):
      ip6_vti: Fix build when NET_IP_TUNNEL is not set.
      xfrm: Fix NULL pointer dereference on sub policy usage
      xfrm: Take xfrm_state_lock in xfrm_migrate_state_find
      xfrm: Clone states properly on migration
      xfrm: Fix unlink race when policies are deleted.

Sucheta Chakraborty (1):
      qlcnic: Allow any VLAN to be configured from VF.

Sujith Manoharan (1):
      ath9k: Fix ETSI compliance for AR9462 2.0

Thadeu Lima de Souza Cascardo (1):
      net/cxgb4: use remove handler as shutdown handler

Tobias Klauser (1):
      net: stmmac: Check return value of alloc_dma_desc_resources()

Toshiaki Makita (1):
      veth: Fix vlan_features so as to be able to use stacked vlan interfaces

Ursula Braun (1):
      qeth: postpone freeing of qdio memory

Vasundhara Volam (2):
      be2net: Fix skb double free in be_xmit_wrokarounds() failure path
      be2net: isolate TX workarounds not applicable to Skyhawk-R

Vlad Yasevich (1):
      macvlan: Add support for 'always_on' offload features

Wei Liu (1):
      xen-netfront: reset skb network header before checksum

Xin Long (1):
      ip_tunnel:multicast process cause panic due to skb->_skb_refdst NULL pointer

Ying Xue (2):
      tipc: remove all enabled flags from all tipc components
      tipc: make bearer set up in module insertion stage

Yuchung Cheng (1):
      tcp: fix bogus RTT on special retransmission

Yuval Mintz (1):
      bnx2x: Add missing bit in default Tx switching

dingtianhong (2):
      bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for 802.3ad mode
      bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for ab arp monitor

 .../devicetree/bindings/net/opencores-ethoc.txt    |  22 +++
 Documentation/networking/can.txt                   |   6 -
 MAINTAINERS                                        |   1 +
 drivers/infiniband/hw/mlx4/main.c                  |   4 +-
 drivers/infiniband/hw/mlx5/main.c                  |   4 +-
 drivers/net/bonding/bond_3ad.c                     |  16 +-
 drivers/net/bonding/bond_main.c                    | 124 ++++++++-------
 drivers/net/bonding/bonding.h                      |  47 +++++-
 drivers/net/can/flexcan.c                          | 172 ++++++++++++++++-----
 drivers/net/ethernet/broadcom/b44.c                |  14 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   9 +-
 drivers/net/ethernet/broadcom/tg3.c                |   3 +-
 drivers/net/ethernet/broadcom/tg3.h                |   6 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |  40 +++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   1 +
 drivers/net/ethernet/emulex/benet/be.h             |   4 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |  84 +++++-----
 drivers/net/ethernet/freescale/fec_main.c          |  13 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    |   4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   5 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   9 --
 drivers/net/ethernet/realtek/r8169.c               |   2 +
 drivers/net/ethernet/sfc/ptp.c                     |   7 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   2 +-
 drivers/net/ethernet/ti/cpsw.c                     |   6 +
 drivers/net/macvlan.c                              |   7 +-
 drivers/net/phy/phy_device.c                       |  16 +-
 drivers/net/tun.c                                  |   4 +-
 drivers/net/usb/ax88179_178a.c                     |  34 ++++
 drivers/net/veth.c                                 |   3 +-
 drivers/net/virtio_net.c                           |   3 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |   4 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   8 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  70 ++++-----
 drivers/net/wireless/ath/ath9k/xmit.c              |  13 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  14 +-
 drivers/net/wireless/hostap/hostap_ap.c            |   2 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |   1 +
 drivers/net/wireless/iwlwifi/dvm/tx.c              |  14 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |  18 +--
 drivers/net/wireless/libertas/cfg.c                |   2 +-
 drivers/net/wireless/mwifiex/pcie.c                |  34 ++--
 drivers/net/wireless/mwifiex/usb.c                 |  12 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   3 +-
 drivers/net/xen-netfront.c                         |   1 +
 drivers/s390/net/qeth_core_main.c                  |   5 +-
 drivers/s390/net/qeth_l2_main.c                    |   3 +
 drivers/s390/net/qeth_l3_main.c                    |   3 +
 include/linux/skbuff.h                             |   5 +-
 include/net/ip_tunnels.h                           |   1 +
 include/net/tcp.h                                  |   3 +-
 include/net/xfrm.h                                 |  11 ++
 net/can/raw.c                                      |  26 +---
 net/core/neighbour.c                               |   8 +-
 net/core/skbuff.c                                  |   3 -
 net/hsr/hsr_framereg.c                             |   2 +-
 net/ipv4/af_inet.c                                 |   7 +-
 net/ipv4/ip_output.c                               |   3 -
 net/ipv4/ip_tunnel.c                               |  53 +------
 net/ipv4/ip_tunnel_core.c                          |  47 +++++-
 net/ipv4/netfilter/nf_nat_snmp_basic.c             |   4 +-
 net/ipv4/tcp.c                                     |   8 +-
 net/ipv4/tcp_cong.c                                |   3 +-
 net/ipv4/tcp_input.c                               |   3 +-
 net/ipv4/tcp_output.c                              |  22 ++-
 net/ipv6/Kconfig                                   |   1 +
 net/ipv6/exthdrs_core.c                            |   2 +-
 net/ipv6/ip6_offload.c                             |  20 ++-
 net/ipv6/ip6_output.c                              |   3 -
 net/ipv6/ping.c                                    |   1 +
 net/ipv6/sit.c                                     |  19 +++
 net/ipv6/udp_offload.c                             |   2 +-
 net/mac80211/ieee80211_i.h                         |  10 +-
 net/mac80211/mlme.c                                |  24 +++
 net/mac80211/rx.c                                  |   7 +
 net/mac80211/sta_info.c                            |  66 +++++---
 net/mac80211/sta_info.h                            |   7 +-
 net/mac80211/tx.c                                  |  15 ++
 net/mac80211/util.c                                |  48 +++---
 net/mac80211/wme.c                                 |   5 +
 net/netfilter/nf_conntrack_netlink.c               |  35 ++---
 net/netfilter/nf_nat_core.c                        |  56 ++++---
 net/netfilter/nft_meta.c                           |   4 +-
 net/netfilter/nft_payload.c                        |   3 +-
 net/netfilter/nft_reject_inet.c                    |   4 +-
 net/netlink/af_netlink.c                           |   4 +-
 net/nfc/nci/core.c                                 |   2 +-
 net/sched/sch_tbf.c                                |  24 +--
 net/sctp/associola.c                               | 129 ++++++++++------
 net/sctp/sm_sideeffect.c                           |   7 +-
 net/sctp/sm_statefuns.c                            |   7 +
 net/tipc/bearer.c                                  |   7 +-
 net/tipc/config.c                                  |   2 +-
 net/tipc/core.c                                    | 109 +++++++------
 net/tipc/core.h                                    |   1 -
 net/tipc/name_table.c                              |   3 -
 net/tipc/netlink.c                                 |   8 -
 net/tipc/ref.c                                     |   3 -
 net/tipc/server.c                                  |   5 -
 net/tipc/server.h                                  |   2 -
 net/tipc/socket.c                                  |   8 -
 net/wireless/reg.c                                 |  12 +-
 net/xfrm/xfrm_policy.c                             |   2 +-
 net/xfrm/xfrm_state.c                              |  23 ++-
 net/xfrm/xfrm_user.c                               |   5 -
 110 files changed, 1108 insertions(+), 690 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/opencores-ethoc.txt
