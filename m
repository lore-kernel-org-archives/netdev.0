From: David Miller <davem@davemloft.net>
Subject: [GIT] Sparc
Date: Wed, 29 Jun 2016 09:06:42 -0400 (EDT)
Message-ID: <20160629.090642.304034162014728165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbcF2NJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 09:09:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've been travelling so this accumulates more than week or so of bug
fixing.  It perhaps looks a little worse than it really is.

1) Fix deadlock in ath10k driver, from Ben Greear.

2) Increase scan timeout in iwlwifi, from Luca Coelho.

3) Unbreak STP by properly reinjecting STP packets back into
   the stack.  Regression fix from Ido Schimmel.

4) Mediatek driver fixes (missing malloc failure checks, leaking of
   scratch memory, wrong indexing when mapping TX buffers, etc.) from
   John Crispin.

5) Fix endianness bug in icmpv6_err() handler, from Hannes Frederic Sowa.

6) Fix hashing of flows in UDP in the ruseport case, from Xuemin Su.

7) Fix netlink notifications in ovs for tunnels, delete link messages
   are never emitted because of how the device registry state is handled.
   From Nicolas Dichtel.

8) Conntrack module leaks kmemcache on unload, from Florian Westphal.

9) Prevent endless jump loops in nft rules, from Liping Zhang and
   Pablo Neira Ayuso.

10) Not early enough spinlock initialization in mlx4, from Eric Dumazet.

11) Bind refcount leak in act_ipt, from Cong WANG.

12) Missing RCU locking in HTB scheduler, from Florian Westphal.

13) Several small MACSEC bug fixes from Sabrina Dubroca (missing RCU barrier,
    using heap for SG and IV, and erroneous use of async flag when
    allocating AEAD conext.)

14) RCU handling fix in TIPC, from Ying Xue.

15) Pass correct protocol down into ipv4_{update_pmtu,redirect}() in SIT
    driver, from Simon Horman.

16) Socket timer deadlock fix in TIPC from Jon Paul Maloy.

17) Fix potential deadlock in team enslave, from Ido Schimmel.

18) Memory leak in KCM procfs handling, from Jiri Slaby.

19) ESN generation fix in ipv4 ESP, from Herbert Xu.

20) Fix GFP_KERNEL allocations with locks held in act_ife, from Cong
    WANG.

21) Use after free in netem, from Eric Dumazet.

22) Uninitialized last assert time in multicast router code, from Tom
    Goff.

23) Skip raw sockets in sock_diag destruction broadcast, from Willem
    de Bruijn.

24) Fix link status reporting in thunderx, from Sunil Goutham.

25) Limit resegmentation of retransmit queue so that we do not
    retransmit too large GSO frames.  From Eric Dumazet.

26) Delay bpf program release after grace period, from Daniel
    Borkmann.

Please pull, thanks a lot!

The following changes since commit 698ea54dde6768d4a96080d0fb796cb3a4eadaf8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-06-10 08:32:24 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 751ad819b0bf443ad8963eb7bfbd533e6a463973:

  Merge tag 'mac80211-for-davem-2016-06-29-v2' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2016-06-29 08:33:46 -0400)

----------------------------------------------------------------
Aaron Campbell (1):
      connector: fix out-of-order cn_proc netlink message delivery

Alexander Duyck (1):
      mlx4e: Do not attempt to offload VXLAN ports that are unrecognized

Alexei Starovoitov (2):
      bpf: fix matching of data/data_end in verifier
      bpf, trace: check event type in bpf_perf_event_read

Arnd Bergmann (3):
      net: skfb: remove obsolete -I cflag
      net: sfc: avoid -Wtype-limits warning
      net: tilegx: use correct timespec64 type

Ayala Beker (1):
      iwlwifi: mvm: set the encryption type of an IGTK key

Basil Gunn (1):
      AX.25: Close socket connection on session completion

Ben Dooks (2):
      net: diag: add missing declarations
      net: ipconfig: avoid warning by making ic_addrservaddr static

Ben Greear (2):
      ath10k: fix deadlock when peer cannot be created
      ath10k: fix crash related to printing features

Ben Hutchings (1):
      batman-adv: Fix double-put of vlan object

Chris Packham (1):
      net: vrf: replace hard tab with space in assignment

Clemens Gruber (1):
      phy: marvell: fix LED configuration via marvell,reg-init

Colin Ian King (1):
      rtl8xxxu: fix typo on variable name, compare against correct variable

Dan Carpenter (1):
      qlcnic: use the correct ring in qlcnic_83xx_process_rcv_ring_diag()

Daniel Borkmann (1):
      bpf, perf: delay release of BPF prog after grace period

David Barroso (1):
      neigh: Explicitly declare RCU-bh read side critical section in neigh_xmit()

David S. Miller (19):
      Merge branch 'mediatek-fixes'
      Revert "net: au1000_eth: fix PHY detection"
      ipconfig: Protect ic_addrservaddr with IPCONFIG_DYNAMIC.
      Merge branch 'ovs-notifications'
      Merge branch 'macsec-fixes'
      Merge branch 'bpf-fixes'
      Merge branch 'r8152-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'mlxsw-fixes'
      Merge branch 'qed-fixes'
      Merge tag 'linux-can-fixes-for-4.7-20160620' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'mlx4-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-06-21' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge tag 'linux-can-fixes-for-4.7-20160623' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'bgmac-fixes'
      Merge branch 'batman-adv-fixes'
      Merge branch 'mlx5-100G-fixes'
      Merge branch 'thunderx-fixes'
      Merge tag 'mac80211-for-davem-2016-06-29-v2' of git://git.kernel.org/.../jberg/mac80211

Eli Cohen (2):
      net/mlx5: Update command strings
      net/mlx5e: Change enum to better reflect usage

Emmanuel Grumbach (1):
      iwlwifi: mvm: fix RCU splat in TKIP's update_key

Eran Ben Elisha (1):
      net/mlx4_en: Avoid unregister_netdev at shutdown flow

Eric Dumazet (7):
      net_sched: prio: properly report out of memory errors
      net_sched: fix pfifo_head_drop behavior vs backlog
      net/mlx4_en: initialize cmd.context_lock spinlock earlier
      net_sched: prio: insure proper transactional behavior
      gre: fix error handler
      netem: fix a use after free
      tcp: do not send too big packets at retransmit time

Felix Fietkau (1):
      cfg80211: fix proto in ieee80211_data_to_8023 for frames without LLC header

Feng Tang (1):
      net: alx: Work around the DMA RX overflow issue

Florian Fainelli (4):
      net: bgmac: Fix SOF bit checking
      net: bgmac: Start transmit queue in bgmac_open
      net: bgmac: Remove superflous netif_carrier_on()
      net: phy: Manage fixed PHY address space using IDA

Florian Westphal (2):
      netfilter: conntrack: destroy kmemcache on module removal
      htb: call qdisc_root with rcu read lock held

Gal Pressman (3):
      net/mlx5e: Check for BlueFlame capability before allocating SQ uar
      net/mlx5e: Fix number of PFC counters reported to ethtool
      net/mlx5e: Reorganize ethtool statistics

Haishuang Yan (1):
      geneve: fix tx_errors statistics

Hannes Frederic Sowa (4):
      ipv6: fix endianness error in icmpv6_err
      ipv6: tcp: fix endianness annotation in tcp_v6_send_response
      ipv6: fix checksum annotation in udp6_csum_init
      ipv4: fix checksum annotation in udp4_csum_init

Harini Katakam (1):
      net: marvell: Add separate config ANEG function for Marvell 88E1111

Herbert Xu (1):
      esp: Fix ESN generation under UDP encapsulation

Ido Schimmel (2):
      bridge: Fix incorrect re-injection of STP packets
      team: Fix possible deadlock during team enslave

Ivan Khoronzhuk (1):
      net: ethernet: ti: cpsw: use destroy ctlr to destroy channels

Jakub Kicinski (1):
      nfp: use correct index to mask link state irq

Jamal Hadi Salim (1):
      net sched actions: bug fix dumping actions directly didnt produce NLMSG_DONE

Jarod Wilson (1):
      e1000e: keep VLAN interfaces functional after rxvlan off

Jason A. Donenfeld (1):
      net: Don't forget pr_fmt on net_dbg_ratelimited for CONFIG_DYNAMIC_DEBUG

Jay Vosburgh (1):
      bonding: fix 802.3ad aggregator reselection

Jeremy Linton (1):
      net: smsc911x: Fix bug where PHY interrupts are overwritten by 0

Jimmy Assarsson (1):
      can: kvaser_usb: Add support for more Kvaser Leaf v2 devices

Jiri Slaby (1):
      kcm: fix /proc memory leak

Johannes Berg (1):
      iwlwifi: mvm: fix a few firmware capability checks

John Crispin (11):
      net: mediatek: add missing return code check
      net: mediatek: fix missing free of scratch memory
      net: mediatek: invalid buffer lookup in mtk_tx_map()
      net: mediatek: dropped rx packets are not being counted properly
      net: mediatek: add next data pointer coherency protection
      net: mediatek: disable all interrupts during probe
      net: mediatek: fix threshold value
      net: mediatek: increase watchdog_timeo
      net: mediatek: fix off by one in the TX ring allocation
      net: mediatek: only wake the queue if it is stopped
      net: mediatek: remove superfluous queue wake up call

Jon Paul Maloy (2):
      tipc: fix socket timer deadlock
      tipc: unclone unbundled buffers before forwarding

Joshua Houghton (1):
      net: rds: fix coding style issues

Jouni Malinen (1):
      mac80211: Fix mesh estab_plinks counting in STA removal case

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2016-06-10' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge ath-current from ath.git

Kamal Heib (1):
      net/mlx4_en: Fix the return value of a failure in VLAN VID add/kill

Liping Zhang (3):
      netfilter: nf_tables: fix wrong check of NFT_SET_MAP in nf_tables_bind_set
      netfilter: nf_tables: fix wrong destroy anonymous sets if binding fails
      netfilter: nf_tables: fix a wrong check to skip the inactive rules

Luca Coelho (2):
      iwlwifi: mvm: increase scan timeout to 20 seconds
      iwlwifi: mvm: fix potential NULL-dereference in iwl_mvm_reorder()

Majd Dibbiny (1):
      net/mlx5: Add ConnectX-5 PCIe 4.0 to list of supported devices

Manfred Schlaegl (1):
      net: phy: smsc: reintroduced unconditional soft reset

Manuel Lauss (2):
      net: au1000_eth: fix PHY detection
      net: au1000_eth: fix PHY detection

Matthew Finlay (1):
      net/mlx5e: Prevent adding the same vxlan port

Maximilian Schneider (1):
      can: gs_usb: Add Basic support for the bytewerk.org candleLight interface

Miaoqing Pan (1):
      ath9k: fix GPIO mask for AR9462 and AR9565

Nicolas Dichtel (4):
      ovs/gre,geneve: fix error path when creating an iface
      ovs/vxlan: fix rtnl notifications on iface deletion
      ovs/gre: fix rtnl notifications on iface deletion
      ovs/geneve: fix rtnl notifications on iface deletion

Nikolay Aleksandrov (1):
      net: bridge: fix vlan stats continue counter

Nogah Frankel (2):
      mlxsw: spectrum: Don't count internal TX header bytes to stats
      mlxsw: switchx2: Don't count internal TX header bytes to stats

Oliver Hartkopp (2):
      can: fix handling of unmodifiable configuration options fix
      can: fix oops caused by wrong rtnl dellink usage

Or Gerlitz (1):
      MAINTAINERS: Update Mellanox's mlx4 Eth NIC driver entry

Pablo Neira Ayuso (3):
      netfilter: nf_tables: reject loops from set element jump to chain
      netfilter: xt_SYNPROXY: add missing header to Kbuild
      netfilter: xt_SYNPROXY: include missing <linux/types.h>

Paolo Abeni (1):
      ipv6: enforce egress device match in per table nexthop lookups

Rajkumar Manoharan (1):
      ath10k: fix deadlock while processing rx_in_ord_ind

Sabrina Dubroca (3):
      macsec: add rcu_barrier() on module exit
      macsec: allocate sg and iv on the heap
      macsec: fix SA initialization

Samuel Gauthier (1):
      openvswitch: fix conntrack netlink event delivery

Simon Horman (1):
      sit: correct IP protocol used in ipip6_err

Simon Wunderlich (1):
      batman-adv: replace WARN with rate limited output on non-existing VLAN

Sowmini Varadhan (1):
      RDS: TCP: rds_tcp_accept_one() should transition socket from RESETTING to UP

Stefan Hajnoczi (1):
      vsock: make listener child lock ordering explicit

Su, Xuemin (1):
      udp reuseport: fix packet of same flow hashed to different socket

Sudarsana Reddy Kalluru (1):
      qed: Protect the doorbell BAR with the write barriers.

Sunil Goutham (2):
      net: thunderx: Fix link status reporting
      net: thunderx: Fix TL4 configuration for secondary Qsets

Sven Eckelmann (3):
      batman-adv: Fix use-after-free/double-free of tt_req_node
      batman-adv: Fix ICMP RR ethernet access after skb_linearize
      batman-adv: Clean up untagged vlan when destroying via rtnl-link

Thor Thayer (1):
      can: c_can: Update D_CAN TX and RX functions to 32 bit - fix Altera Cyclone access

Tom Goff (1):
      ipmr/ip6mr: Initialize the last assert time of mfc entries.

WANG Cong (3):
      act_ipt: fix a bind refcnt leak
      act_ife: only acquire tcf_lock for existing actions
      act_ife: acquire ife_mod_lock before reading ifeoplist

Wang Sheng-Hui (1):
      net/mlx5: use mlx5_buf_alloc_node instead of mlx5_buf_alloc in mlx5_wq_ll_create

Wei Yongjun (1):
      ibmvnic: fix to use list_for_each_safe() when delete items

Willem de Bruijn (1):
      sock_diag: do not broadcast raw socket destruction

Wolfgang Grandegger (1):
      can: at91_can: RX queue could get stuck at high bus load

Ying Xue (2):
      tipc: fix suspicious RCU usage
      tipc: eliminate uninitialized variable warning

Yuval Mintz (5):
      qed: Correct default vlan behavior
      qed: Prevent VF from Tx-switching 'promisc'
      qed*: Don't reset statistics on inner reload
      qed: Fix returning unlimited SPQ entries
      qed: Add missing port-mode

daniel (1):
      Bridge: Fix ipv6 mc snooping if bridge has no ipv6 address

hayeswang (3):
      r8152: disable MAC clock speed down
      r8152: reset the bmu
      r8152: correct the rx early size

 MAINTAINERS                                            |   2 +-
 drivers/connector/cn_proc.c                            |  43 ++++-----
 drivers/net/bonding/bond_3ad.c                         |  64 +++++++++----
 drivers/net/can/at91_can.c                             |   5 +-
 drivers/net/can/c_can/c_can.c                          |  38 ++++++--
 drivers/net/can/dev.c                                  |   9 ++
 drivers/net/can/usb/Kconfig                            |   5 +-
 drivers/net/can/usb/gs_usb.c                           |  14 ++-
 drivers/net/can/usb/kvaser_usb.c                       |   8 +-
 drivers/net/ethernet/amd/au1000_eth.c                  |   4 +-
 drivers/net/ethernet/atheros/alx/alx.h                 |   4 -
 drivers/net/ethernet/atheros/alx/main.c                |  61 +++----------
 drivers/net/ethernet/broadcom/bgmac.c                  |   8 +-
 drivers/net/ethernet/cavium/thunder/nic_main.c         |  16 +++-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c      |  91 +++++++++++-------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h      |   2 +
 drivers/net/ethernet/ibm/ibmvnic.c                     |  14 +--
 drivers/net/ethernet/intel/e1000e/netdev.c             |  15 ++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c            |  61 +++++++++----
 drivers/net/ethernet/mediatek/mtk_eth_soc.h            |   3 +
 drivers/net/ethernet/mellanox/mlx4/cmd.c               |   1 -
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c         |  46 +++++++---
 drivers/net/ethernet/mellanox/mlx4/main.c              |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c          |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h           |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  34 +++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c      |  35 ++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c        |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h     | 228 ++++++++++++++++++++--------------------------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c        |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c         |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c        |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.c           |  15 +--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c         |   6 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c         |   5 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c    |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h              |   1 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c               |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c             |   1 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c              |  31 +++++--
 drivers/net/ethernet/qlogic/qede/qede_main.c           |   7 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c         |   2 +-
 drivers/net/ethernet/sfc/farch.c                       |   3 +-
 drivers/net/ethernet/smsc/smsc911x.c                   |   2 -
 drivers/net/ethernet/ti/cpsw.c                         |   4 -
 drivers/net/ethernet/tile/tilegx.c                     |   6 +-
 drivers/net/fddi/skfp/Makefile                         |   2 +-
 drivers/net/geneve.c                                   |  22 +++--
 drivers/net/macsec.c                                   |  49 ++++++++--
 drivers/net/phy/fixed_phy.c                            |  22 ++---
 drivers/net/phy/marvell.c                              |  82 ++++++++++++++---
 drivers/net/phy/smsc.c                                 |  17 +---
 drivers/net/team/team.c                                |   2 +
 drivers/net/usb/r8152.c                                |  37 +++++---
 drivers/net/vrf.c                                      |   4 +-
 drivers/net/vxlan.c                                    |  58 +++++++-----
 drivers/net/wireless/ath/ath10k/core.c                 |   2 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c               |   1 -
 drivers/net/wireless/ath/ath10k/mac.c                  |   2 +-
 drivers/net/wireless/ath/ath9k/reg.h                   |   8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c      |   8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c          |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c          |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c           |  16 +++-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |   2 +-
 include/linux/bpf.h                                    |  32 ++++++-
 include/linux/inet_diag.h                              |   6 ++
 include/linux/mlx4/device.h                            |   1 +
 include/linux/net.h                                    |   3 +-
 include/linux/qed/qed_eth_if.h                         |   1 +
 include/linux/sock_diag.h                              |   6 ++
 include/net/gre.h                                      |   2 +-
 include/net/netfilter/nf_tables.h                      |   1 +
 include/net/tc_act/tc_ife.h                            |   6 +-
 include/uapi/linux/netfilter/Kbuild                    |   1 +
 include/uapi/linux/netfilter/xt_SYNPROXY.h             |   2 +
 kernel/bpf/verifier.c                                  |  41 ++-------
 kernel/events/core.c                                   |   2 +-
 kernel/trace/bpf_trace.c                               |  10 +-
 net/ax25/af_ax25.c                                     |   3 +-
 net/ax25/ax25_ds_timer.c                               |   5 +-
 net/ax25/ax25_std_timer.c                              |   5 +-
 net/ax25/ax25_subr.c                                   |   3 +-
 net/batman-adv/routing.c                               |   1 +
 net/batman-adv/soft-interface.c                        |   9 ++
 net/batman-adv/translation-table.c                     |  50 ++++++++--
 net/batman-adv/types.h                                 |   2 +
 net/bridge/br_input.c                                  |  15 ++-
 net/bridge/br_multicast.c                              |   4 +
 net/bridge/br_netlink.c                                |   2 +-
 net/bridge/br_private.h                                |  23 ++++-
 net/core/filter.c                                      |  16 +++-
 net/core/neighbour.c                                   |   6 +-
 net/ipv4/esp4.c                                        |  52 +++++++----
 net/ipv4/gre_demux.c                                   |  10 +-
 net/ipv4/ip_gre.c                                      |  26 +++---
 net/ipv4/ipconfig.c                                    |   4 +-
 net/ipv4/ipmr.c                                        |   4 +-
 net/ipv4/tcp_output.c                                  |   7 +-
 net/ipv4/udp.c                                         |  80 +++++-----------
 net/ipv6/icmp.c                                        |   2 +-
 net/ipv6/ip6_checksum.c                                |   7 +-
 net/ipv6/ip6_gre.c                                     |   2 +-
 net/ipv6/ip6mr.c                                       |   1 +
 net/ipv6/route.c                                       |   2 +-
 net/ipv6/sit.c                                         |   4 +-
 net/ipv6/tcp_ipv6.c                                    |   4 +-
 net/ipv6/udp.c                                         |  71 ++++-----------
 net/kcm/kcmproc.c                                      |   1 +
 net/mac80211/mesh.c                                    |   7 +-
 net/netfilter/nf_conntrack_core.c                      |   2 +
 net/netfilter/nf_tables_api.c                          |  24 +++--
 net/netfilter/nf_tables_core.c                         |   2 +-
 net/netfilter/nft_hash.c                               |   3 +-
 net/netfilter/nft_rbtree.c                             |   3 +-
 net/openvswitch/conntrack.c                            |  14 ++-
 net/rds/ib_cm.c                                        |   2 +-
 net/rds/loop.c                                         |   5 +-
 net/rds/sysctl.c                                       |   3 +-
 net/rds/tcp.h                                          |   2 +-
 net/rds/tcp_connect.c                                  |  26 +++---
 net/rds/tcp_listen.c                                   |   2 +-
 net/rds/tcp_recv.c                                     |   2 +-
 net/rds/tcp_send.c                                     |  14 +--
 net/rds/transport.c                                    |   3 +-
 net/sched/act_api.c                                    |   2 +-
 net/sched/act_ife.c                                    |  53 ++++++-----
 net/sched/act_ipt.c                                    |   7 +-
 net/sched/sch_fifo.c                                   |   4 +
 net/sched/sch_htb.c                                    |   2 +
 net/sched/sch_netem.c                                  |  12 +--
 net/sched/sch_prio.c                                   |  67 +++++---------
 net/sctp/sctp_diag.c                                   |   6 --
 net/tipc/bearer.c                                      |   2 +-
 net/tipc/link.c                                        |   3 +-
 net/tipc/msg.c                                         |   6 ++
 net/tipc/msg.h                                         |  11 ---
 net/tipc/socket.c                                      |  54 ++++++++---
 net/vmw_vsock/af_vsock.c                               |  12 ++-
 net/wireless/util.c                                    |   2 +-
 140 files changed, 1270 insertions(+), 893 deletions(-)
