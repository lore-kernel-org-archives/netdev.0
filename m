From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] Netfilter updates for net-next
Date: Mon,  9 Mar 2015 18:14:23 +0100
Message-ID: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next
tree. Basically, improvements for the packet rejection infrastructure,
deprecation of CLUSTERIP, cleanups for nf_tables and some untangling for
br_netfilter. More specifically they are:

1) Send packet to reset flow if checksum is valid, from Florian Westphal.

2) Fix nf_tables reject bridge from the input chain, also from Florian.

3) Deprecate the CLUSTERIP target, the cluster match supersedes it in
   functionality and it's known to have problems.

4) A couple of cleanups for nf_tables rule tracing infrastructure, from
   Patrick McHardy.

5) Another cleanup to place transaction declarations at the bottom of
   nf_tables.h, also from Patrick.

6) Consolidate Kconfig dependencies wrt. NF_TABLES.

7) Limit table names to 32 bytes in nf_tables.

8) mac header copying in bridge netfilter is already required when
   calling ip_fragment(), from Florian Westphal.

9) move nf_bridge_update_protocol() to br_netfilter.c, also from
   Florian.

10) Small refactor in br_netfilter in the transmission path, again from
    Florian.

11) Move br_nf_pre_routing_finish_bridge_slow() to br_netfilter.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

And I'd appreciate if you can pull net into net-next, Patrick has some
pending changes that require patches already your net tree.

Thanks a lot!

----------------------------------------------------------------

The following changes since commit b898441f4ece44933af90b116b467f7864dd1ae7:

  Merge branch 'neigh_cleanups' (2015-03-02 16:43:46 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to e5de75bf88858f5b3ab11e2504b86ec059f03102:

  netfilter: bridge: move DNAT helper to br_netfilter (2015-03-09 17:56:07 +0100)

----------------------------------------------------------------
Florian Westphal (5):
      netfilter: reject: don't send icmp error if csum is invalid
      netfilter: bridge: rework reject handling
      bridge: move mac header copying into br_netfilter
      netfilter: bridge: move nf_bridge_update_protocol to where its used
      netfilter: bridge: refactor conditional in br_nf_dev_queue_xmit

Pablo Neira Ayuso (4):
      netfilter: ipt_CLUSTERIP: deprecate it in favour of xt_cluster
      netfilter: nf_tables: consolidate Kconfig options
      netfilter: nf_tables: limit maximum table name length to 32 bytes
      netfilter: bridge: move DNAT helper to br_netfilter

Patrick McHardy (3):
      netfilter: nf_tables: minor tracing cleanups
      netfilter: nf_tables: consolidate tracing invocations
      netfilter: nf_tables: cleanup nf_tables.h

 include/linux/netfilter_bridge.h         |   51 ---------
 include/net/netfilter/ipv4/nf_reject.h   |    6 +-
 include/net/netfilter/ipv6/nf_reject.h   |   11 +-
 include/net/netfilter/nf_tables.h        |  176 +++++++++++++++---------------
 include/net/netns/x_tables.h             |    1 +
 include/uapi/linux/netfilter/nf_tables.h |    1 +
 net/bridge/br_device.c                   |    5 +-
 net/bridge/br_forward.c                  |    4 +-
 net/bridge/br_netfilter.c                |   78 ++++++++++++-
 net/bridge/br_private.h                  |    5 +
 net/bridge/netfilter/nft_reject_bridge.c |   84 +++++++++++---
 net/ipv4/netfilter/Kconfig               |   38 ++++---
 net/ipv4/netfilter/ipt_CLUSTERIP.c       |    7 ++
 net/ipv4/netfilter/ipt_REJECT.c          |   17 +--
 net/ipv4/netfilter/nf_reject_ipv4.c      |   23 ++++
 net/ipv4/netfilter/nft_reject_ipv4.c     |    3 +-
 net/ipv6/netfilter/Kconfig               |   18 +--
 net/ipv6/netfilter/nf_reject_ipv6.c      |   35 ++++++
 net/netfilter/Kconfig                    |   20 +---
 net/netfilter/nf_tables_api.c            |    7 +-
 net/netfilter/nf_tables_core.c           |  105 +++++++++---------
 net/netfilter/nft_reject_inet.c          |    6 +-
 22 files changed, 412 insertions(+), 289 deletions(-)
