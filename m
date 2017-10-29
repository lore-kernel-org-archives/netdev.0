From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 29 Oct 2017 23:54:55 +0900 (KST)
Message-ID: <20171029.235455.896176125425350574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix route leak in xfrm_bundle_create().

2) In mac80211, validate user rate mask before configuring it.
   From Johannes Berg.

3) Properly enforce memory limits in fair queueing code, from
   Toke Hoiland-Jorgensen.

4) Fix lockdep splat in inet_csk_route_req(), from Eric Dumazet.

5) Fix TSO header allocation and management in mvpp2 driver, from Yan
   Markman.

6) Don't take socket lock in BH handler in strparser code, from Tom
   Herbert.

7) Don't show sockets from other namespaces in AF_UNIX code, from
   Andrei Vagin.

8) Fix double free in error path of tap_open(), from Girish
   Moodalbail.

9) Fix TX map failure path in igb and ixgbe, from Jean-Philippe
   Brucker and Alexander Duyck.

10) Fix DCB mode programming in stmmac driver, from Jose Abreu.

11) Fix err_count handling in various tunnels (ipip, ip6_gre).
    From Xin Long.

12) Properly align SKB head before building SKB in tuntap, from
    Jason Wang.

13) Avoid matching qdiscs with a zero handle during lookups, from
    Cong Wang.

14) Fix various endianness bugs in sctp, from Xin Long.

15) Fix tc filter callback races and add selftests which trigger
    the problem, from Cong Wang.

Please pull, thanks a lot!

The following changes since commit b5ac3beb5a9f0ef0ea64cd85faf94c0dc4de0e42:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-10-21 22:44:48 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 6c325f4eca9ee9eb32cf58768e6e4ebcabaa8d6e:

  Merge branch 'net_sched-fix-races-with-RCU-callbacks' (2017-10-29 22:49:32 +0900)

----------------------------------------------------------------
Aleksander Morgado (1):
      cdc_ether: flag the Huawei ME906/ME909 as WWAN

Alexander Duyck (3):
      ixgbe: Fix Tx map failure path
      i40e: Fix incorrect use of tx_itr_setting when checking for Rx ITR setup
      i40e: Add programming descriptors to cleaned_count

Andrei Vagin (1):
      net/unix: don't show information about sockets from other namespaces

Antoine Tenart (5):
      net: mvpp2: do not unmap TSO headers buffers
      net: mvpp2: do not call txq_done from the Tx path when Tx irqs are used
      net: mvpp2: fix typo in the tcam setup
      net: mvpp2: fix invalid parameters order when calling the tcam init
      net: mvpp2: do not sleep in set_rx_mode

Chris Mi (2):
      selftests: Introduce a new script to generate tc batch file
      selftests: Introduce a new test case to tc testsuite

Colin Ian King (1):
      e1000: avoid null pointer dereference on invalid stat type

Cong Wang (15):
      net_sched: avoid matching qdisc with zero handle
      net_sched: introduce a workqueue for RCU callbacks of tc filter
      net_sched: use tcf_queue_work() in basic filter
      net_sched: use tcf_queue_work() in bpf filter
      net_sched: use tcf_queue_work() in cgroup filter
      net_sched: use tcf_queue_work() in flow filter
      net_sched: use tcf_queue_work() in flower filter
      net_sched: use tcf_queue_work() in fw filter
      net_sched: use tcf_queue_work() in matchall filter
      net_sched: use tcf_queue_work() in u32 filter
      net_sched: use tcf_queue_work() in route filter
      net_sched: use tcf_queue_work() in rsvp filter
      net_sched: use tcf_queue_work() in tcindex filter
      net_sched: add rtnl assertion to tcf_exts_destroy()
      net_sched: fix call_rcu() race on act_sample module removal

David Miller (1):
      ipsec: Fix dst leak in xfrm_bundle_create().

David S. Miller (8):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge tag 'linux-can-fixes-for-4.14-20171024' of git://git.kernel.org/.../mkl/linux-can
      Merge tag 'mac80211-for-davem-2017-10-25' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'mlx5-fixes-2017-10-26' of git://git.kernel.org/.../saeed/linux
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/net-queue
      Merge branch 'sockmap-fixes'
      Merge branch 'sctp-endianness-fixes'
      Merge branch 'net_sched-fix-races-with-RCU-callbacks'

Eric Dumazet (3):
      tcp/dccp: fix lockdep splat in inet_csk_route_req()
      tcp/dccp: fix other lockdep splats accessing ireq_opt
      tcp: refresh tp timestamp before tcp_mtu_probe()

Gerhard Bertelsmann (1):
      can: sun4i: fix loopback mode

Girish Moodalbail (2):
      tap: double-free in error path in tap_open()
      tap: reference to KVA of an unloaded module causes kernel panic

Herbert Xu (1):
      ipsec: Fix aborted xfrm policy dump crash

Huy Nguyen (2):
      net/mlx5: Delay events till mlx5 interface's add complete for pci resume
      net/mlx5e: DCBNL, Implement tc with ets type and zero bandwidth

Håkon Bugge (2):
      rds: ib: Fix uninitialized variable
      rds: Fix inaccurate accounting of unsignaled wrs

Jason A. Donenfeld (1):
      mac80211: use constant time comparison with keys

Jason Wang (1):
      tuntap: properly align skb->head before building skb

Jean-Philippe Brucker (1):
      igb: Fix TX map failure path

Jimmy Assarsson (2):
      can: kvaser_usb: Correct return value in printout
      can: kvaser_usb: Ignore CMD_FLUSH_QUEUE_REPLY messages

Johannes Berg (3):
      cfg80211: fix connect/disconnect edge cases
      mac80211: validate user rate mask before configuring driver
      mac80211: don't compare TKIP TX MIC key in reinstall prevention

John Fastabend (2):
      bpf: bpf_compute_data uses incorrect cb structure
      bpf: rename sk_actions to align with bpf infrastructure

Jose Abreu (2):
      net: stmmac: dwc-qos-eth: Fix typo in DT bindings parsing
      net: stmmac: First Queue must always be in DCB mode

Julien Gomes (1):
      tun: allow positive return values on dev_get_valid_name() call

Koichiro Den (1):
      tcp: do tcp_mstamp_refresh before retransmits on TSQ handler

Laszlo Toth (1):
      sctp: full support for ipv6 ip_nonlocal_bind & IP_FREEBIND

Moshe Shemesh (1):
      net/mlx5: Fix health work queue spin lock to IRQ safe

Or Gerlitz (1):
      net/mlx5e: Properly deal with encap flows add/del under neigh update

Pieter Jansen van Vuuren (1):
      nfp: refuse offloading filters that redirects to upper devices

Ran Wang (1):
      drivers/net/usb: add device id for TP-LINK UE300 USB 3.0 Ethernet

Toke Høiland-Jørgensen (1):
      fq_impl: Properly enforce memory limit

Tom Herbert (1):
      strparser: Use delayed work instead of timer for msg timeout

Vincenzo Maffione (1):
      e1000: fix race condition between e1000_down() and e1000_watchdog

Vivien Didelot (1):
      net: dsa: check master device before put

Xin Long (8):
      ipip: only increase err_count for some certain type icmp in ipip_err
      ip6_gre: only increase err_count for some certain type icmpv6 in ip6gre_err
      ip6_gre: update dst pmtu if dev mtu has been updated by toobig in __gre6_xmit
      sctp: reset owner sk for data chunks on out queues when migrating a sock
      sctp: fix some type cast warnings introduced by stream reconf
      sctp: fix some type cast warnings introduced by transport rhashtable
      sctp: fix a type cast warnings that causes a_rwnd gets the wrong value
      sctp: fix some type cast warnings introduced since very beginning

Yan Markman (1):
      net: mvpp2: fix TSO headers allocation and management

Yousuk Seung (1):
      tcp: call tcp_rate_skb_sent() when retransmit with unaligned skb->data

 drivers/net/can/sun4i_can.c                                    |   3 +-
 drivers/net/can/usb/kvaser_usb.c                               |   9 ++++-
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c               |   9 +++--
 drivers/net/ethernet/intel/e1000/e1000_main.c                  |  11 ++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c                    |   3 +-
 drivers/net/ethernet/intel/igb/igb_main.c                      |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c                  |  18 ++++------
 drivers/net/ethernet/marvell/mvpp2.c                           |  35 +++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/dev.c                  |  70 +++++++++++++++++++++---------------
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c             | 113 +++++++++++++++++++++++++++++++++++++++++++----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c                |  89 ++++++++++++++++++++++++++++------------------
 drivers/net/ethernet/mellanox/mlx5/core/health.c               |   5 +--
 drivers/net/ethernet/mellanox/mlx5/core/port.c                 |  21 +++++++++++
 drivers/net/ethernet/netronome/nfp/flower/action.c             |   2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c        |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c          |   7 ++++
 drivers/net/ipvlan/ipvtap.c                                    |   4 +--
 drivers/net/macvtap.c                                          |   4 +--
 drivers/net/tap.c                                              |  23 ++++++------
 drivers/net/tun.c                                              |   3 +-
 drivers/net/usb/cdc_ether.c                                    |  14 ++++++++
 drivers/net/usb/r8152.c                                        |   2 ++
 include/linux/if_tap.h                                         |   4 +--
 include/linux/mlx5/port.h                                      |   2 ++
 include/linux/sctp.h                                           |  34 +++++++++---------
 include/net/fq_impl.h                                          |   9 +++--
 include/net/inet_sock.h                                        |   6 ++++
 include/net/pkt_cls.h                                          |   3 ++
 include/net/sch_generic.h                                      |   2 ++
 include/net/sctp/sm.h                                          |   2 +-
 include/net/sctp/ulpevent.h                                    |   2 +-
 include/net/strparser.h                                        |   3 +-
 include/net/tcp.h                                              |   1 +
 include/uapi/linux/bpf.h                                       |   6 ++--
 include/uapi/linux/sctp.h                                      |   2 +-
 kernel/bpf/sockmap.c                                           |  15 ++++++--
 net/core/filter.c                                              |  32 +++++++++++++++--
 net/dccp/ipv4.c                                                |   2 +-
 net/dsa/dsa2.c                                                 |   7 ++--
 net/ipv4/inet_connection_sock.c                                |   3 +-
 net/ipv4/ipip.c                                                |  59 ++++++++++++++++++++++---------
 net/ipv4/tcp_ipv4.c                                            |   2 +-
 net/ipv4/tcp_output.c                                          |  10 ++++--
 net/ipv6/ip6_gre.c                                             |  20 +++++++----
 net/mac80211/cfg.c                                             |  12 +++----
 net/mac80211/key.c                                             |  37 +++++++++++++++++--
 net/rds/ib_send.c                                              |  16 ++++-----
 net/sched/act_sample.c                                         |   1 +
 net/sched/cls_api.c                                            |  69 +++++++++++++++++++++++++++---------
 net/sched/cls_basic.c                                          |  20 +++++++++--
 net/sched/cls_bpf.c                                            |  19 ++++++++--
 net/sched/cls_cgroup.c                                         |  22 +++++++++---
 net/sched/cls_flow.c                                           |  19 ++++++++--
 net/sched/cls_flower.c                                         |  19 ++++++++--
 net/sched/cls_fw.c                                             |  19 ++++++++--
 net/sched/cls_matchall.c                                       |  19 ++++++++--
 net/sched/cls_route.c                                          |  19 ++++++++--
 net/sched/cls_rsvp.h                                           |  19 ++++++++--
 net/sched/cls_tcindex.c                                        |  38 +++++++++++++++++---
 net/sched/cls_u32.c                                            |  29 +++++++++++++--
 net/sched/sch_api.c                                            |   2 ++
 net/sctp/input.c                                               |  22 ++++++------
 net/sctp/ipv6.c                                                |   8 +++--
 net/sctp/sm_make_chunk.c                                       |   9 ++---
 net/sctp/sm_sideeffect.c                                       |   8 ++---
 net/sctp/socket.c                                              |  32 +++++++++++++++++
 net/sctp/stream.c                                              |  26 +++++++++-----
 net/sctp/ulpevent.c                                            |   2 +-
 net/strparser/strparser.c                                      |  17 +++++----
 net/unix/diag.c                                                |   2 ++
 net/wireless/sme.c                                             |  50 +++++++++++++++++++++-----
 net/xfrm/xfrm_policy.c                                         |  16 ++++-----
 net/xfrm/xfrm_user.c                                           |  25 +++++++------
 tools/include/uapi/linux/bpf.h                                 |   4 +--
 tools/testing/selftests/tc-testing/tc-tests/filters/tests.json |  23 +++++++++++-
 tools/testing/selftests/tc-testing/tdc.py                      |  20 ++++++++---
 tools/testing/selftests/tc-testing/tdc_batch.py                |  62 ++++++++++++++++++++++++++++++++
 tools/testing/selftests/tc-testing/tdc_config.py               |   2 ++
 78 files changed, 1021 insertions(+), 361 deletions(-)
 create mode 100755 tools/testing/selftests/tc-testing/tdc_batch.py
