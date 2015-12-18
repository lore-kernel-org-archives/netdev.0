From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/23] Netfilter updates for net-next
Date: Fri, 18 Dec 2015 21:26:26 +0100
Message-ID: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57753 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932736AbbLRUdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:33:50 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 84C7D17F1B1
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:49 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1D071DA87C
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:49 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2E039D1DA5
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:35 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains the first batch of Netfilter updates for
the upcoming 4.5 kernel. This batch contains userspace netfilter header
compilation fixes, support for packet mangling in nf_tables, the new
tracing infrastructure for nf_tables and cgroup2 support for iptables.
More specifically, they are:

1) Two patches to include dependencies in our netfilter userspace
   headers to resolve compilation problems, from Mikko Rapeli.

2) Four comestic cleanup patches for the ebtables codebase, from Ian Morris.

3) Remove duplicate include in the netfilter reject infrastructure,
   from Stephen Hemminger.

4) Two patches to simplify the netfilter defragmentation code for IPv6,
   patch from Florian Westphal.

5) Fix root ownership of /proc/net netfilter for unpriviledged net
   namespaces, from Philip Whineray.

6) Get rid of unused fields in struct nft_pktinfo, from Florian Westphal.

7) Add mangling support to our nf_tables payload expression, from
   Patrick McHardy.

8) Introduce a new netlink-based tracing infrastructure for nf_tables,
   from Florian Westphal.

9) Change setter functions in nfnetlink_log to be void, from
    Rami Rosen.

10) Add netns support to the cttimeout infrastructure.

11) Add cgroup2 support to iptables, from Tejun Heo.

12) Introduce nfnl_dereference_protected() in nfnetlink, from Florian.

13) Add support for mangling pkttype in the nf_tables meta expression,
    also from Florian.

BTW, I need that you pull net into net-next, I have another batch that
requires changes that I don't yet see in net.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit cb4396edd84ed73081635fb933d19c1410fafaf4:

  drivers/net: fix eisa_driver probe section mismatch (2015-12-14 00:24:22 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to b4aae759c22e71a3c32144f0b3bc4f2fa4aaae98:

  netfilter: meta: add support for setting skb->pkttype (2015-12-18 14:12:56 +0100)

----------------------------------------------------------------
Florian Westphal (9):
      netfilter: ipv6: nf_defrag: avoid/free clone operations
      netfilter: ipv6: avoid nf_iterate recursion
      netfilter: nf_tables: remove unused struct members
      netfilter: nf_tables: extend tracing infrastructure
      netfilter: nf_tables: wrap tracing with a static key
      netfilter: ipv6: nf_defrag: fix NULL deref panic
      netfilter: nf_tables: fix nf_log_trace based tracing
      nfnetlink: add nfnl_dereference_protected helper
      netfilter: meta: add support for setting skb->pkttype

Ian Morris (4):
      netfilter-bridge: Cleanse indentation
      netfilter-bridge: use netdev style comments
      netfilter-bridge: brace placement
      netfilter-bridge: layout of if statements

Marcelo Ricardo Leitner (1):
      netfilter: nf_ct_sctp: move ip_ct_sctp away from UAPI

Mikko Rapeli (2):
      netfilter: ebtables: use __u64 from linux/types.h
      netfilter: fix include files for compilation

Pablo Neira (1):
      netfilter: cttimeout: add netns support

Pablo Neira Ayuso (1):
      Merge branch 'master' of git://git.kernel.org/.../davem/net-next

Patrick McHardy (1):
      netfilter: nft_payload: add packet mangling support

Philip Whineray (1):
      netfilter: Set /proc/net entries owner to root in namespace

Rosen, Rami (1):
      netfilter: nfnetlink_log: Change setter functions to be void

Tejun Heo (2):
      netfilter: prepare xt_cgroup for multi revisions
      netfilter: implement xt_cgroup cgroup2 path match

stephen hemminger (1):
      netfilter: remove duplicate include

 include/linux/netfilter/nf_conntrack_sctp.h        |  13 +
 include/net/net_namespace.h                        |   3 +
 include/net/netfilter/ipv6/nf_defrag_ipv6.h        |   3 +-
 include/net/netfilter/nf_conntrack_timeout.h       |   2 +-
 include/net/netfilter/nf_tables.h                  |  34 ++-
 include/net/netfilter/nf_tables_core.h             |  10 +
 include/net/netfilter/nft_meta.h                   |   3 +
 include/uapi/linux/netfilter/ipset/ip_set_bitmap.h |   2 +
 include/uapi/linux/netfilter/ipset/ip_set_hash.h   |   2 +
 include/uapi/linux/netfilter/ipset/ip_set_list.h   |   2 +
 include/uapi/linux/netfilter/nf_conntrack_sctp.h   |  12 +-
 .../linux/netfilter/nf_conntrack_tuple_common.h    |   3 +
 include/uapi/linux/netfilter/nf_tables.h           |  69 ++++++
 include/uapi/linux/netfilter/nfnetlink.h           |   2 +
 include/uapi/linux/netfilter/xt_HMARK.h            |   1 +
 include/uapi/linux/netfilter/xt_RATEEST.h          |   1 +
 include/uapi/linux/netfilter/xt_TEE.h              |   2 +
 include/uapi/linux/netfilter/xt_TPROXY.h           |   1 +
 include/uapi/linux/netfilter/xt_cgroup.h           |  15 +-
 include/uapi/linux/netfilter/xt_hashlimit.h        |   1 +
 include/uapi/linux/netfilter/xt_ipvs.h             |   1 +
 include/uapi/linux/netfilter/xt_mac.h              |   2 +
 include/uapi/linux/netfilter/xt_osf.h              |   2 +
 include/uapi/linux/netfilter/xt_physdev.h          |   2 +-
 include/uapi/linux/netfilter/xt_policy.h           |   2 +
 include/uapi/linux/netfilter/xt_rateest.h          |   1 +
 include/uapi/linux/netfilter/xt_recent.h           |   1 +
 include/uapi/linux/netfilter/xt_sctp.h             |  12 +-
 include/uapi/linux/netfilter_arp/arp_tables.h      |   1 +
 include/uapi/linux/netfilter_bridge.h              |   1 +
 include/uapi/linux/netfilter_bridge/ebt_arp.h      |   1 +
 include/uapi/linux/netfilter_bridge/ebt_arpreply.h |   2 +
 include/uapi/linux/netfilter_bridge/ebt_ip6.h      |   1 +
 include/uapi/linux/netfilter_bridge/ebt_nat.h      |   2 +
 include/uapi/linux/netfilter_bridge/ebtables.h     |   6 +-
 include/uapi/linux/netfilter_ipv4/ip_tables.h      |   1 +
 include/uapi/linux/netfilter_ipv6/ip6_tables.h     |   1 +
 include/uapi/linux/netfilter_ipv6/ip6t_rt.h        |   2 +-
 net/bridge/netfilter/ebt_ip6.c                     |   4 +-
 net/bridge/netfilter/ebt_log.c                     |   9 +-
 net/bridge/netfilter/ebt_stp.c                     |   2 +-
 net/bridge/netfilter/ebt_vlan.c                    |  15 +-
 net/bridge/netfilter/ebtable_filter.c              |   2 +-
 net/bridge/netfilter/ebtable_nat.c                 |   2 +-
 net/bridge/netfilter/ebtables.c                    | 139 ++++++-----
 net/bridge/netfilter/nft_meta_bridge.c             |   1 +
 net/ipv4/netfilter/nf_reject_ipv4.c                |   1 -
 net/ipv6/netfilter/nf_conntrack_reasm.c            | 167 ++++++-------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c          |  20 +-
 net/ipv6/netfilter/nf_reject_ipv6.c                |   1 -
 net/netfilter/Makefile                             |   2 +-
 net/netfilter/nf_conntrack_expect.c                |   7 +
 net/netfilter/nf_conntrack_standalone.c            |   7 +
 net/netfilter/nf_conntrack_timeout.c               |   2 +-
 net/netfilter/nf_tables_api.c                      |  12 +-
 net/netfilter/nf_tables_core.c                     |  62 +++--
 net/netfilter/nf_tables_trace.c                    | 275 +++++++++++++++++++++
 net/netfilter/nfnetlink.c                          |  14 +-
 net/netfilter/nfnetlink_cttimeout.c                |  82 +++---
 net/netfilter/nfnetlink_log.c                      |  23 +-
 net/netfilter/nft_meta.c                           |  54 ++++
 net/netfilter/nft_payload.c                        | 135 +++++++++-
 net/netfilter/x_tables.c                           |  12 +
 net/netfilter/xt_CT.c                              |   2 +-
 net/netfilter/xt_cgroup.c                          | 105 ++++++--
 net/openvswitch/conntrack.c                        |  25 +-
 66 files changed, 1062 insertions(+), 342 deletions(-)
 create mode 100644 include/linux/netfilter/nf_conntrack_sctp.h
 create mode 100644 net/netfilter/nf_tables_trace.c
