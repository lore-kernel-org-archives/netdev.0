From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/29: Netfilter Update
Date: Thu, 27 Nov 2008 17:15:03 +0100 (MET)
Message-ID: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches contain part 1 of the netfilter updates for 2.6.29.
The highlights are:

- netns support for ebtables, ipt_addrtype and some related cleanups from
  Alexey Dobriyan

- ctnetlink updates from Pablo: automatic helper module loading, proper
  event generation for actions performed through ctnetlink, minor cleanups

- switching of xt_NFLOG to directly use nfnetlink_log as backend instead
  of the first loaded logging module, which was a constant source of
  confusion for users. From Eric Leblond. Also from Eric are two patches
  to support rerouting based on packet marks in nfnetlink_queue.

- Misc cleanups and minor fixes from myself, Andy Whitcroft, Simon Arlot
  and Ingo Molnar.


There's a trivial merge conflict in net/netfilter/nf_conntrack_netlink.c,
so the patches won't apply directly. Please pull from

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git

Thanks!


 include/linux/netfilter_bridge/ebtables.h    |    3 +-
 include/linux/netfilter_ipv4/ipt_policy.h    |    2 +
 include/linux/netfilter_ipv6/ip6t_policy.h   |    2 +
 include/net/netfilter/nf_conntrack.h         |    5 +-
 include/net/netfilter/nf_conntrack_ecache.h  |   57 +++++++-
 include/net/netfilter/nf_conntrack_expect.h  |    2 +
 include/net/netfilter/nf_conntrack_helper.h  |    5 +-
 include/net/netfilter/nf_conntrack_l4proto.h |    2 +-
 include/net/netfilter/nfnetlink_log.h        |   14 ++
 include/net/netns/x_tables.h                 |    5 +
 net/bridge/br_netfilter.c                    |    2 +-
 net/bridge/netfilter/ebtable_broute.c        |   26 +++-
 net/bridge/netfilter/ebtable_filter.c        |   41 +++++-
 net/bridge/netfilter/ebtable_nat.c           |   38 ++++--
 net/bridge/netfilter/ebtables.c              |   52 +++++---
 net/ipv4/netfilter.c                         |    3 +
 net/ipv4/netfilter/arptable_filter.c         |   12 +--
 net/ipv4/netfilter/ipt_addrtype.c            |   16 ++-
 net/ipv4/netfilter/nf_nat_rule.c             |   23 ---
 net/ipv6/netfilter.c                         |    5 +-
 net/ipv6/netfilter/ip6table_filter.c         |   17 +--
 net/netfilter/nf_conntrack_amanda.c          |    1 +
 net/netfilter/nf_conntrack_core.c            |   61 ++++-----
 net/netfilter/nf_conntrack_ecache.c          |   14 ++-
 net/netfilter/nf_conntrack_expect.c          |   43 +++++-
 net/netfilter/nf_conntrack_ftp.c             |    9 +-
 net/netfilter/nf_conntrack_h323_main.c       |    1 +
 net/netfilter/nf_conntrack_helper.c          |   32 ++++-
 net/netfilter/nf_conntrack_irc.c             |    1 +
 net/netfilter/nf_conntrack_netbios_ns.c      |    1 +
 net/netfilter/nf_conntrack_netlink.c         |  200 ++++++++++++++++++++------
 net/netfilter/nf_conntrack_pptp.c            |    1 +
 net/netfilter/nf_conntrack_proto_gre.c       |    2 +-
 net/netfilter/nf_conntrack_proto_sctp.c      |    2 +-
 net/netfilter/nf_conntrack_sane.c            |    1 +
 net/netfilter/nf_conntrack_sip.c             |    1 +
 net/netfilter/nf_conntrack_tftp.c            |    1 +
 net/netfilter/nfnetlink_log.c                |    4 +-
 net/netfilter/xt_NFLOG.c                     |    5 +-
 net/netfilter/xt_recent.c                    |   22 ++--
 40 files changed, 514 insertions(+), 220 deletions(-)
 create mode 100644 include/net/netfilter/nfnetlink_log.h

Alexey Dobriyan (12):
      netfilter: netns-aware ipt_addrtype
      netfilter: arptable_filter: merge forward hook
      netfilter: netns ebtables: part 1
      netfilter: netns ebtables: part 2
      netfilter: netns ebtables: more cleanup during ebt_unregister_table()
      netfilter: netns ebtables: ebtable_broute in netns
      netfilter: netns ebtables: ebtable_filter in netns
      netfilter: netns ebtables: ebtable_nat in netns
      netfilter: netns ebtables: br_nf_pre_routing_finish() fixup
      netfilter: xt_recent: don't save proc dirs
      netfilter: ip6table_filter: merge LOCAL_IN and FORWARD hooks
      netfilter: nf_conntrack_proto_gre: spread __exit

Andy Whitcroft (1):
      netfilter: ip{,6}t_policy.h should include xp_policy.h

Eric Leblond (3):
      netfilter: xt_NFLOG: don't call nf_log_packet in NFLOG module.
      netfilter: nfmark routing in OUTPUT, mangle, NFQUEUE
      netfilter: nfmark IPV6 routing in OUTPUT, mangle, NFQUEUE

Ingo Molnar (2):
      netfilter: fix warning in net/netfilter/nf_conntrack_proto_tcp.c
      netfilter: fix warning in net/netfilter/nf_conntrack_ftp.c

Pablo Neira Ayuso (6):
      netfilter: ctnetlink: use nf_conntrack_get instead of atomic_inc
      netfilter: ctnetlink: use EOPNOTSUPP instead of EINVAL if the conntrack	has no helper
      netfilter: ctnetlink: get rid of module refcounting in ctnetlink
      netfilter: nf_conntrack: connection tracking helper name persistent aliases
      netfilter: ctnetlink: helper modules load-on-demand support
      netfilter: ctnetlink: deliver events for conntracks changed from userspace

Patrick McHardy (4):
      netfilter: nfnetlink_log: fix warning and prototype mismatch
      netfilter: nf_conntrack: fix warning and prototype mismatch
      netfilter: nf_conntrack_proto_sctp: avoid bogus warning
      netfilter: nf_conntrack_ftp: change "partial ..." message to pr_debug()

Simon Arlott (1):
      netfilter: nf_nat: remove warn_if_extra_mangle
