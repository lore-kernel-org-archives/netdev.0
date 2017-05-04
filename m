From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 04 May 2017 14:51:43 -0400 (EDT)
Message-ID: <20170504.145143.1293009221793578733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdEDSvr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 14:51:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) The wireless rate info fix from Johannes Berg.

2) When a RAW socket is in hdrincl mode, we need to make sure that the
   user provided at least a minimally sized ipv4/ipv6 header.  Fix from
   Alexander Potapenko.

3) We must emit IFLA_PHYS_PORT_NAME netlink attributes using
   nla_put_string() so that it is NULL terminated.

4) Fix a bug in TCP fastopen handling, wherein child sockets erroneously
   inherit the fastopen_req from the parent, and later can end up
   derefencing freed memory or doing a double free.  From Eric Dumazet.

5) Don't clear out netdev stats at close time in tg3 driver, from
   YueHaibing.

6) Fix refcount leak in xt_CT, from Gao Feng.

7) In nft_set_bitmap() don't leak dummy elements, from Liping Zhang.

8) Fix deadlock due to taking the expectation lock twice, also from
   Liping Zhang.

9) Make xt_socket work again with ipv6, from Peter Tirsek.

10) Don't allow IPV6 to be used with IPVS if ipv6.disable=1, from
    Paolo Abeni.

11) Make the BPF loader more flexible wrt. changes to the bpf MAP
    entry layout.  From Jesper Dangaard Brouer.

12) Fix ethtool reported device name in aquantia driver, from Pavel
    Belous.

13) Fix build failures due to the compile time size test not working
    in netfilter conntrack.  From Geert Uytterhoeven.

Please pull, thanks a lot!

The following changes since commit 89c9fea3c8034cdb2fd745f551cde0b507fd6893:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jikos/trivial (2017-05-02 19:09:35 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 842be75c77cb72ee546a2b19da9c285fb3ded660:

  cfg80211: make RATE_INFO_BW_20 the default (2017-05-04 13:15:28 -0400)

----------------------------------------------------------------
Alexander Potapenko (1):
      ipv4, ipv6: ensure raw socket message is big enough to hold an IP header

Alexei Starovoitov (1):
      selftests/bpf: get rid of -D__x86_64__

Colin Ian King (1):
      net/sched: remove redundant null check on head

Dan Carpenter (1):
      netfilter: x_tables: unlock on error in xt_find_table_lock()

Daniel Borkmann (1):
      xdp: use common helper for netlink extended ack reporting

Daniele Palmas (1):
      net: usb: qmi_wwan: add Telit ME910 support

Dave Johnson (1):
      netfilter: Wrong icmp6 checksum for ICMPV6_TIME_EXCEED in reverse SNATv6 path

David Ahern (1):
      net: ipv6: Do not duplicate DAD on link up

David Cai (1):
      smsc911x: Adding support for Micochip LAN9250 Ethernet controller

David S. Miller (4):
      Merge branch 'sample-bpf-loader-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'ibmvnic-Updated-reset-handler-andcode-fixes'
      Merge branch 'qed-fixes'

Eric Dumazet (1):
      tcp: do not inherit fastopen_req from parent

Gao Feng (1):
      netfilter: xt_CT: fix refcnt leak on error path

Geert Uytterhoeven (2):
      test_bpf: Use ULL suffix for 64-bit constants
      netfilter: conntrack: Force inlining of build check to prevent build failure

Jarno Rajahalme (1):
      openvswitch: Delete conntrack entry clashing with an expectation.

Jesper Dangaard Brouer (4):
      samples/bpf: adjust rlimit RLIMIT_MEMLOCK for traceex2, tracex3 and tracex4
      samples/bpf: make bpf_load.c code compatible with ELF maps section changes
      samples/bpf: load_bpf.c make callback fixup more flexible
      samples/bpf: export map_data[] for more info on maps

Johannes Berg (1):
      cfg80211: make RATE_INFO_BW_20 the default

Linus Lüssing (1):
      bridge: ebtables: fix reception of frames DNAT-ed to bridge device/port

Liping Zhang (7):
      netfilter: nf_ct_helper: permit cthelpers with different names via nfnetlink
      netfilter: nft_set_bitmap: free dummy elements when destroy the set
      netfilter: ctnetlink: drop the incorrect cthelper module request
      netfilter: ctnetlink: fix deadlock due to acquire _expect_lock twice
      netfilter: ctnetlink: make it safer when updating ct->status
      netfilter: ctnetlink: acquire ct->lock before operating nf_ct_seqadj
      netfilter: nft_dynset: continue to next expr if _OP_ADD succeeded

Michal Schmidt (1):
      rtnetlink: NUL-terminate IFLA_PHYS_PORT_NAME string

Nathan Fontenot (10):
      ibmvnic: Move resource initialization to its own routine
      ibmvnic: Replace is_closed with state field
      ibmvnic: Updated reset handling
      ibmvnic: Delete napi's when releasing driver resources
      ibmvnic: Whitespace correction in release_rx_pools
      ibmvnic: Clean up tx pools when closing
      ibmvnic: Wait for any pending scrqs entries at driver close
      ibmvnic: Check for driver reset first in ibmvnic_xmit
      ibmvnic: Continue skb processing after skb completion error
      ibmvnic: Move queue restarting in ibmvnic_tx_complete

Pablo Neira Ayuso (3):
      Merge tag 'ipvs-fixes-for-v4.11' of http://git.kernel.org/.../horms/ipvs
      netfilter: update MAINTAINERS file
      netfilter: nf_tables: check if same extensions are set when adding elements

Paolo Abeni (1):
      ipvs: explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled

Pavel Belous (1):
      aquantia: Fix driver name reported by ethtool

Peter Tirsek (1):
      netfilter: xt_socket: Fix broken IPv6 handling

Thomas Falcon (1):
      ibmvnic: Record SKB RX queue during poll

WANG Cong (1):
      ipv6: initialize route null entry in addrconf_init()

Yonghong Song (1):
      selftests/bpf: add a test case to check verifier pointer arithmetic

YueHaibing (1):
      tg3: don't clear stats while tg3_close

Zhu Yanjun (1):
      forcedeth: remove unnecessary carrier status check

stephen hemminger (1):
      netvsc: make sure napi enabled before vmbus_open

sudarsana.kalluru@cavium.com (3):
      qed*: Fix possible overflow for status block id field.
      qed: Fix overriding of supported autoneg value.
      qede: Fix possible misconfiguration of advertised autoneg value.

 MAINTAINERS                                         |   4 +-
 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h     |   2 +-
 drivers/net/ethernet/broadcom/tg3.c                 |   4 -
 drivers/net/ethernet/ibm/ibmvnic.c                  | 561 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------------------------------
 drivers/net/ethernet/ibm/ibmvnic.h                  |  31 ++++--
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c |   4 +-
 drivers/net/ethernet/nvidia/forcedeth.c             |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c           |  11 ++-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h       |   4 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c          |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h           |   1 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c     |  10 +-
 drivers/net/ethernet/smsc/smsc911x.c                |  49 +++++----
 drivers/net/ethernet/smsc/smsc911x.h                |  19 ++++
 drivers/net/hyperv/netvsc.c                         |   8 +-
 drivers/net/hyperv/rndis_filter.c                   |   2 +-
 drivers/net/usb/qmi_wwan.c                          |   1 +
 drivers/net/virtio_net.c                            |   8 +-
 include/linux/netlink.h                             |  19 ++--
 include/linux/qed/qed_if.h                          |   2 +-
 include/net/cfg80211.h                              |   2 +-
 include/net/ip6_route.h                             |   1 +
 include/uapi/linux/netfilter/nf_conntrack_common.h  |  13 ++-
 lib/test_bpf.c                                      |  10 +-
 net/bridge/netfilter/ebt_dnat.c                     |  20 ++++
 net/core/rtnetlink.c                                |   2 +-
 net/ipv4/raw.c                                      |   3 +
 net/ipv4/tcp_minisocks.c                            |   1 +
 net/ipv6/addrconf.c                                 |   7 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c            |   2 +-
 net/ipv6/raw.c                                      |   2 +
 net/ipv6/route.c                                    |  26 ++---
 net/netfilter/ipvs/ip_vs_ctl.c                      |  22 ++++-
 net/netfilter/nf_conntrack_core.c                   |   2 +-
 net/netfilter/nf_conntrack_helper.c                 |  26 ++++-
 net/netfilter/nf_conntrack_netlink.c                |  89 +++++++++--------
 net/netfilter/nf_tables_api.c                       |   5 +
 net/netfilter/nft_dynset.c                          |   5 +-
 net/netfilter/nft_set_bitmap.c                      |   5 +
 net/netfilter/x_tables.c                            |   4 +-
 net/netfilter/xt_CT.c                               |  11 ++-
 net/netfilter/xt_socket.c                           |   2 +-
 net/openvswitch/conntrack.c                         |  30 +++++-
 net/sched/cls_matchall.c                            |   3 +-
 samples/bpf/bpf_load.c                              | 229 ++++++++++++++++++++++++++++--------------
 samples/bpf/bpf_load.h                              |  18 +++-
 samples/bpf/map_perf_test_user.c                    |  14 +--
 samples/bpf/tracex2_user.c                          |   7 ++
 samples/bpf/tracex3_user.c                          |   7 ++
 samples/bpf/tracex4_user.c                          |   8 ++
 tools/testing/selftests/bpf/Makefile                |   6 +-
 tools/testing/selftests/bpf/gnu/stubs.h             |   1 +
 tools/testing/selftests/bpf/test_progs.c            |  16 +++
 tools/testing/selftests/bpf/test_tcp_estats.c       | 258 +++++++++++++++++++++++++++++++++++++++++++++++
 54 files changed, 1174 insertions(+), 437 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/gnu/stubs.h
 create mode 100644 tools/testing/selftests/bpf/test_tcp_estats.c
