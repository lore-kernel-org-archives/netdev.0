From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 08 Sep 2017 22:06:57 -0700 (PDT)
Message-ID: <20170908.220657.768060952637862159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdIIFHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 01:07:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The iwlwifi firmware compat fix is in here as well as some other
stuff:

1) Fix request socket leak introduced by BPF deadlock fix, from Eric
   Dumazet.

2) Fix VLAN handling with TXQs in mac80211, from Johannes Berg.

3) Missing __qdisc_drop conversions in prio and qfq schedulers, from
   Gao Feng.

4) Use after free in netlink nlk groups handling, from Xin Long.

5) Handle MTU update properly in ipv6 gre tunnels, from Xin Long.

6) Fix leak of ipv6 fib tables on netns teardown, from Sabrina Dubroca
   with follow-on fix from Eric Dumazet.

7) Need RCU and preemption disabled during generic XDP data patch, from
   John Fastabend.

Please pull, thanks a lot!

The following changes since commit 80cee03bf1d626db0278271b505d7f5febb37bba:

  Merge branch 'linus' of git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6 (2017-09-06 15:17:17 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 9beb8bedb05c5f3a353dba62b8fa7cbbb9ec685e:

  bpf: make error reporting in bpf_warn_invalid_xdp_action more clear (2017-09-08 21:13:09 -0700)

----------------------------------------------------------------
Arnd Bergmann (1):
      isdn: isdnloop: fix logic error in isdnloop_sendbuf

Avraham Stern (1):
      mac80211: flush hw_roc_start work before cancelling the ROC

Baruch Siach (5):
      dt-binding: phy: don't confuse with Ethernet phy properties
      dt-bindings: net: don't confuse with generic PHY property
      dt-bindings: add SFF vendor prefix
      dt-binding: net: sfp binding documentation
      net: phy: sfp: rename dt properties to match the binding

Beni Lev (1):
      mac80211_hwsim: Use proper TX power

Chunho Lee (1):
      mac80211: Fix null pointer dereference with iTXQ support

Daniel Borkmann (2):
      bpf: don't select potentially stale ri->map from buggy xdp progs
      bpf: make error reporting in bpf_warn_invalid_xdp_action more clear

David S. Miller (4):
      Merge tag 'mac80211-for-davem-2017-09-07' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'wireless-drivers-for-davem-2017-09-08' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'xdp-bpf-fixes'

Emmanuel Grumbach (1):
      cfg80211: honor NL80211_RRF_NO_HT40{MINUS,PLUS}

Eric Dumazet (2):
      tcp: fix a request socket leak
      ipv6: fix typo in fib6_net_exit()

Florian Fainelli (1):
      Revert "mdio_bus: Remove unneeded gpiod NULL check"

Florian Westphal (5):
      netfilter: nf_nat: don't bug when mapping already exists
      netfilter: xtables: add scheduling opportunity in get_counters
      netfilter: nat: Revert "netfilter: nat: convert nat bysrc hash to rhashtable"
      netfilter: nat: use keyed locks
      netfilter: core: remove erroneous warn_on

Gao Feng (1):
      sched: Use __qdisc_drop instead of kfree_skb in sch_prio and sch_qfq

Haishuang Yan (2):
      ip_tunnel: fix setting ttl and tos value in collect_md mode
      ip6_tunnel: fix setting hop_limit value for ipv6 tunnel

Håkon Bugge (1):
      rds: Fix incorrect statistics counting

Ian W MORRISON (1):
      brcmfmac: feature check for multi-scheduled scan fails on bcm4345 devices

Igor Mitsyanko (1):
      nl80211: look for HT/VHT capabilities in beacon's tail

Ilan peer (1):
      mac80211: Complete ampdu work schedule during session tear down

Ivan Khoronzhuk (1):
      net: ethernet: ti: netcp_core: no need in netif_napi_del

Jiri Pirko (1):
      net: sched: fix memleak for chain zero

Johannes Berg (3):
      mac80211: fix VLAN handling with TXQs
      mac80211: agg-tx: call drv_wake_tx_queue in proper context
      mac80211: fix deadlock in driver-managed RX BA session start

John Fastabend (3):
      net: rcu lock and preempt disable missing around generic xdp
      bpf: add support for sockmap detach programs
      bpf: devmap, use cond_resched instead of cpu_relax

Kees Cook (1):
      net: tulip: Constify tulip_tbl

Kleber Sacilotto de Souza (1):
      tipc: remove unnecessary call to dev_net()

Larry Finger (2):
      rtlwifi: btcoexist: Fix breakage of ant_sel for rtl8723be
      rtlwifi: btcoexist: Fix antenna selection code

Liad Kaufman (1):
      mac80211: add MESH IE in the correct order

Luca Coelho (1):
      iwlwifi: mvm: only send LEDS_CMD when the FW supports it

Marcelo Ricardo Leitner (1):
      sctp: fix missing wake ups in some situations

Mathieu Malaterre (1):
      davicom: Display proper debug level up to 6

Paolo Abeni (1):
      udp: drop head states only when all skb references are gone

Sabrina Dubroca (1):
      ipv6: fix memory leak with multiple tables during netns destruction

Sharon Dvir (1):
      mac80211: shorten debug prints using ht_dbg() to avoid warning

Simon Dinkin (1):
      mac80211: fix incorrect assignment of reassoc value

Vishwanath Pai (1):
      netfilter: xt_hashlimit: fix build error caused by 64bit division

Xin Long (5):
      netlink: fix an use-after-free issue for nlk groups
      netlink: access nlk groups safely in netlink bind and getname
      ip6_gre: update mtu properly in ip6gre_err
      netfilter: ipvs: fix the issue that sctp_conn_schedule drops non-INIT packet
      netfilter: ipvs: do not create conn for ABORT packet in sctp_conn_schedule

Zhizhou Tian (1):
      netfilter: xt_hashlimit: alloc hashtable with right size

 Documentation/devicetree/bindings/net/ethernet.txt               |   4 +++
 Documentation/devicetree/bindings/net/sff,sfp.txt                |  76 ++++++++++++++++++++++++++++++++++++++++++++++
 Documentation/devicetree/bindings/phy/phy-bindings.txt           |   4 ++-
 Documentation/devicetree/bindings/vendor-prefixes.txt            |   1 +
 drivers/isdn/isdnloop/isdnloop.c                                 |   2 +-
 drivers/net/ethernet/davicom/dm9000.c                            |   2 +-
 drivers/net/ethernet/dec/tulip/tulip.h                           |   2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c                      |   2 +-
 drivers/net/ethernet/ti/netcp_core.c                             |   1 -
 drivers/net/phy/mdio_bus.c                                       |   6 ++--
 drivers/net/phy/sfp.c                                            |   4 +--
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/feature.c       |   3 +-
 drivers/net/wireless/intel/iwlwifi/fw/file.h                     |   1 +
 drivers/net/wireless/intel/iwlwifi/mvm/led.c                     |   3 +-
 drivers/net/wireless/mac80211_hwsim.c                            |   2 --
 drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c |   5 +++-
 drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c    |  23 +++++++++-----
 include/linux/bpf.h                                              |   8 ++---
 include/linux/skbuff.h                                           |   2 +-
 include/net/mac80211.h                                           |  15 ++--------
 include/net/netfilter/nf_conntrack.h                             |   3 +-
 include/net/netfilter/nf_nat.h                                   |   1 -
 include/uapi/linux/bpf.h                                         |   4 +--
 kernel/bpf/devmap.c                                              |   2 +-
 kernel/bpf/sockmap.c                                             |   2 +-
 kernel/bpf/syscall.c                                             |  27 ++++++++++-------
 kernel/bpf/verifier.c                                            |  16 ++++++++++
 net/core/dev.c                                                   |  25 ++++++++++------
 net/core/filter.c                                                |  27 +++++++++++++++--
 net/core/skbuff.c                                                |   9 ++----
 net/ipv4/ip_tunnel.c                                             |   4 +--
 net/ipv4/netfilter/arp_tables.c                                  |   1 +
 net/ipv4/netfilter/ip_tables.c                                   |   1 +
 net/ipv4/tcp_ipv4.c                                              |   6 ++--
 net/ipv4/udp.c                                                   |   5 +++-
 net/ipv6/ip6_fib.c                                               |  25 ++++++++++++----
 net/ipv6/ip6_gre.c                                               |   4 ++-
 net/ipv6/ip6_tunnel.c                                            |   1 +
 net/ipv6/netfilter/ip6_tables.c                                  |   1 +
 net/ipv6/tcp_ipv6.c                                              |   6 ++--
 net/mac80211/agg-rx.c                                            |  32 +++++++++++++-------
 net/mac80211/agg-tx.c                                            |   8 +++--
 net/mac80211/ht.c                                                |  24 +++++++++++++--
 net/mac80211/ieee80211_i.h                                       |   4 +++
 net/mac80211/iface.c                                             |  20 +++++++++++--
 net/mac80211/mlme.c                                              |   2 +-
 net/mac80211/offchannel.c                                        |   2 ++
 net/mac80211/tx.c                                                |  36 +++++++++++++++++-----
 net/mac80211/util.c                                              |   2 +-
 net/netfilter/core.c                                             |   2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c                            |   8 +++--
 net/netfilter/nf_nat_core.c                                      | 146 +++++++++++++++++++++++++++++++++++++++++------------------------------------------------
 net/netfilter/xt_hashlimit.c                                     |  16 +++++-----
 net/netlink/af_netlink.c                                         |  22 +++++++++-----
 net/rds/send.c                                                   |  10 +++++--
 net/sched/cls_api.c                                              |  18 +++++------
 net/sched/sch_prio.c                                             |   2 +-
 net/sched/sch_qfq.c                                              |   2 +-
 net/sctp/ulpqueue.c                                              |   3 +-
 net/tipc/bearer.c                                                |   2 +-
 net/wireless/nl80211.c                                           |   4 +--
 net/wireless/reg.c                                               |  20 +++++++++++--
 tools/testing/selftests/bpf/test_maps.c                          |  51 ++++++++++++++++++++++++++++++-
 63 files changed, 537 insertions(+), 235 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt
