From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 15 Aug 2017 17:52:19 -0700 (PDT)
Message-ID: <20170815.175219.753462032002961032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix TCP checksum offload handling in iwlwifi driver, from Emmanuel
   Grumbach.

2) In ksz DSA tagging code, free SKB if skb_put_padto() fails.  From
   Vivien Didelot.

3) Fix two regressions with bonding on wireless, from Andreas Born.

4) Fix build when busypoll is disabled, from Daniel Borkmann.

5) Fix copy_linear_skb() wrt. SO_PEEK_OFF, from Eric Dumazet.

6) Set SKB cached route properly in inet_rtm_getroute(), from Florian
   Westphal.

7) Fix PCI-E relaxed ordering handling in cxgb4 driver, from Ding
   Tianhong.

8) Fix module refcnt leak in ULP code, from Sabrina Dubroca.

9) Fix use of GFP_KERNEL in atomic contexts in AF_KEY code, from Eric
   Dumazet.

10) Need to purge socket write queue in dccp_destroy_sock(), also from
    Eric Dumazet.

11) Make bpf_trace_printk() work properly on 32-bit architectures,
    from Daniel Borkmann.

Please pull, thanks a lot!

The following changes since commit 26273939ace935dd7553b31d279eab30b40f7b9a:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-08-10 10:30:29 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 88a5c690b66110ad255380d8f629c629cf6ca559:

  bpf: fix bpf_trace_printk on 32 bit archs (2017-08-15 17:32:15 -0700)

----------------------------------------------------------------
Al Viro (1):
      udp: fix linear skb reception with PEEK_OFF

Andreas Born (2):
      bonding: require speed/duplex only for 802.3ad, alb and tlb
      bonding: ratelimit failed speed/duplex update warning

Anton Vasilyev (1):
      mISDN: Fix null pointer dereference at mISDN_FsmNew

Arend Van Spriel (1):
      brcmfmac: feature check for multi-scheduled scan fails on bcm4343x devices

Avraham Stern (1):
      iwlwifi: mvm: start mac queues when deferred tx frames are purged

Bert Kenward (1):
      sfc: don't try and read ef10 data on non-ef10 NIC

Casey Leedom (2):
      net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
      net/cxgb4vf: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag

Christophe Jaillet (1):
      iwlwifi: mvm: Fix a memory leak in an error handling path in 'iwl_mvm_sar_get_wgds_table()'

Daniel Borkmann (3):
      net: fix compilation when busy poll is not enabled
      bpf: fix two missing target_size settings in bpf_convert_ctx_access
      bpf: fix bpf_trace_printk on 32 bit archs

David S. Miller (3):
      Merge branch 'bpf-Minor-fix-in-bpf_convert_ctx_access'
      Merge branch 'Add-new-PCI_DEV_FLAGS_NO_RELAXED_ORDERING-flag'
      Merge tag 'wireless-drivers-for-davem-2017-08-15' of git://git.kernel.org/.../kvalo/wireless-drivers

Emmanuel Grumbach (4):
      iwlwifi: mvm: fix TCP CSUM offload with WEP and A000 series
      iwlwifi: add TLV for MLME offload firmware capability
      iwlwifi: split the regulatory rules when the bandwidth flags require it
      iwlwifi: mvm: don't WARN when a legit race happens in A-MPDU

Eric Dumazet (6):
      udp: harden copy_linear_skb()
      af_key: do not use GFP_KERNEL in atomic contexts
      dccp: purge write queue in dccp_destroy_sock()
      tcp: fix possible deadlock in TCP stack vs BPF filter
      ipv6: fix NULL dereference in ip6_route_dev_notify()
      ipv4: fix NULL dereference in free_fib_info_rcu()

Florian Westphal (1):
      ipv4: route: fix inet_rtm_getroute induced crash

Gregory Greenman (2):
      iwlwifi: mvm: set A-MPDU bit upon empty BA notification from FW
      iwlwifi: mvm: rs: fix TLC statistics collection

Haim Dreyfuss (1):
      iwlwifi: fix fw_pre_next_step to apply also for C step

Jon Paul Maloy (2):
      tipc: accept PACKET_MULTICAST packets
      tipc: avoid inheriting msg_non_seq flag when message is returned

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2017-08-02' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge tag 'iwlwifi-for-kalle-2018-08-09' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Konstantin Khlebnikov (4):
      net/sched/hfsc: allocate tcf block for hfsc root class
      net_sched: reset pointers to tcf blocks in classful qdiscs' destructors
      net_sched/sfq: update hierarchical backlog when drop packet
      net_sched: remove warning from qdisc_hash_add

Naftali Goldstein (3):
      iwlwifi: mvm: set the RTS_MIMO_PROT bit in flag mask when sending sta to fw
      mac80211: add api to start ba session timer expired flow
      iwlwifi: mvm: send delba upon rx ba session timeout

Romain Perier (1):
      net: stmmac: Use the right logging function in stmmac_mdio_register

Sabrina Dubroca (1):
      tcp: ulp: avoid module refcnt leak in tcp_set_ulp

Simon Horman (1):
      nfp: do not update MTU from BH in flower app

Tonghao Zhang (1):
      net: Fix a typo in comment about sock flags.

Tzipi Peres (1):
      iwlwifi: add the new 9000 series PCI IDs

Vivien Didelot (1):
      net: dsa: ksz: fix skb freeing

Wei Wang (1):
      ipv6: release rt6->rt6i_idev properly during ifdown

dingtianhong (4):
      PCI: Disable PCIe Relaxed Ordering if unsupported
      PCI: Disable Relaxed Ordering for some Intel processors
      PCI: Disable Relaxed Ordering Attributes for AMD A1100
      PCI: fix oops when try to find Root Port for a PCI device

 drivers/isdn/mISDN/fsm.c                                   |  5 ++++-
 drivers/isdn/mISDN/fsm.h                                   |  2 +-
 drivers/isdn/mISDN/layer1.c                                |  3 +--
 drivers/isdn/mISDN/layer2.c                                | 15 +++++++++++++--
 drivers/isdn/mISDN/tei.c                                   | 20 +++++++++++++++++---
 drivers/net/bonding/bond_main.c                            | 13 ++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h                 |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c            | 23 ++++++++++++++++------
 drivers/net/ethernet/chelsio/cxgb4/sge.c                   |  5 +++--
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h             |  1 +
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c        | 18 ++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c                 |  3 +++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c           |  8 ++------
 drivers/net/ethernet/sfc/mcdi_port.c                       |  8 ++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c          |  9 ++++-----
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/feature.c |  6 ++++--
 drivers/net/wireless/intel/iwlwifi/cfg/9000.c              | 14 +++++++-------
 drivers/net/wireless/intel/iwlwifi/fw/file.h               |  2 ++
 drivers/net/wireless/intel/iwlwifi/iwl-config.h            |  8 ++++----
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c               |  5 +++--
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c         | 19 +++++++++++--------
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c                |  6 ++++--
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c          | 12 +++++++++++-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c                |  8 ++++----
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c              | 10 ++++++----
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c               |  7 ++++---
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c                | 12 ++++++++++--
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c              | 20 ++++++++++++++++++++
 drivers/pci/pci.c                                          |  7 ++++---
 drivers/pci/probe.c                                        | 43 ++++++++++++++++++++++++++++++++++++++++++
 drivers/pci/quirks.c                                       | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/net.h                                        |  2 +-
 include/linux/pci.h                                        |  3 +++
 include/net/addrconf.h                                     | 10 ++++++++++
 include/net/bonding.h                                      |  5 +++++
 include/net/busy_poll.h                                    | 12 ++++++------
 include/net/mac80211.h                                     | 15 +++++++++++++++
 include/net/udp.h                                          |  7 ++++---
 kernel/trace/bpf_trace.c                                   | 34 +++++++++++++++++++++++++++++----
 net/core/filter.c                                          |  2 ++
 net/dccp/proto.c                                           |  5 +----
 net/dsa/tag_ksz.c                                          | 13 +++++++++----
 net/ipv4/fib_semantics.c                                   | 12 +++++++-----
 net/ipv4/route.c                                           |  3 ++-
 net/ipv4/tcp_ipv4.c                                        |  4 ++--
 net/ipv4/tcp_ulp.c                                         | 14 +++++++-------
 net/ipv6/route.c                                           | 19 ++++++++-----------
 net/ipv6/tcp_ipv6.c                                        |  4 ++--
 net/key/af_key.c                                           | 48 ++++++++++++++++++++++++----------------------
 net/mac80211/agg-rx.c                                      | 22 +++++++++++++++++++++-
 net/sched/sch_api.c                                        |  3 ---
 net/sched/sch_atm.c                                        |  4 +++-
 net/sched/sch_cbq.c                                        |  4 +++-
 net/sched/sch_hfsc.c                                       | 12 +++++++++++-
 net/sched/sch_htb.c                                        |  4 +++-
 net/sched/sch_sfq.c                                        |  5 ++++-
 net/tipc/bearer.c                                          |  2 +-
 net/tipc/msg.c                                             |  1 +
 58 files changed, 512 insertions(+), 159 deletions(-)
