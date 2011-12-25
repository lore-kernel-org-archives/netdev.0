From: pablo@netfilter.org
Subject: [PATCH 00/19] netfilter updates for net-next (upcoming 3.3)
Date: Sun, 25 Dec 2011 02:57:16 +0100
Message-ID: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55975 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922Ab1LYB5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:57:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi Dave,

The following patchset includes the Netfilter updates for net-next.
It contains:

- New reverse path filter matches for xtables from Florian Westphal.

- Use of atomic64_t for the conntrack packet and bytes counters, instead
  of using spinlock to protect counters updates from Eric Dumazet.

- One enhancement for the SH scheduler (IPVS) from Michael Maxim.

- Seven patches from Patrick McHardy to cleanup several aspects of the
  existing NAT code.

- The rework of the user-space expectation support by myself.

- Several updates for ctnetlink by myself.

- The new nfacct infrastructure and the corresponding xtables match
  by myself.

You can pull these changes from:

git://1984.lsi.us.es/net-next nf-next

Please, apply!
Thanks!

Eric Dumazet (1):
  netfilter: nf_conntrack: use atomic64 for accounting counters

Florian Westphal (4):
  net: ipv4: export fib_lookup and fib_table_lookup
  netfilter: add ipv4 reverse path filter match
  ipv6: add ip6_route_lookup
  netfilter: add ipv6 reverse path filter match

Michael Maxim (1):
  IPVS: Modify the SH scheduler to use weights

Pablo Neira Ayuso (6):
  netfilter: ctnetlink: use expect instead of master tuple in get operation
  netfilter: ctnetlink: support individual atomic-get-and-reset of counters
  netfilter: rework user-space expectation helper support
  netfilter: ctnetlink: get and zero operations must be atomic
  netfilter: add extended accounting infrastructure over nfnetlink
  netfilter: xtables: add nfacct match to support extended accounting

Patrick McHardy (7):
  netfilter: nf_nat: export NAT definitions to userspace
  netfilter: nf_nat: use hash random for bysource hash
  netfilter: nf_nat: add missing nla_policy entry for CTA_NAT_PROTO attribute
  netfilter: nat: remove module reference counting from NAT protocols
  netfilter: nf_nat: remove obsolete code from nf_nat_icmp_reply_translation()
  netfilter: nf_nat: remove obsolete check in nf_nat_mangle_udp_packet()
  netfilter: ctnetlink: remove dead NAT code

 include/linux/netfilter/Kbuild                     |    3 +
 include/linux/netfilter/nf_conntrack_common.h      |    4 +
 .../linux/netfilter/nf_conntrack_tuple_common.h    |   27 ++
 include/linux/netfilter/nf_nat.h                   |   25 ++
 include/linux/netfilter/nfnetlink.h                |    3 +-
 include/linux/netfilter/nfnetlink_acct.h           |   36 ++
 include/linux/netfilter/xt_CT.h                    |    3 +-
 include/linux/netfilter/xt_nfacct.h                |   13 +
 include/linux/netfilter/xt_rpfilter.h              |   23 ++
 include/linux/netfilter_ipv4/Kbuild                |    1 -
 include/linux/netfilter_ipv4/nf_nat.h              |   58 ----
 include/net/ip6_route.h                            |    2 +
 include/net/netfilter/nf_conntrack_acct.h          |    4 +-
 include/net/netfilter/nf_conntrack_expect.h        |    1 -
 include/net/netfilter/nf_conntrack_tuple.h         |    1 -
 include/net/netfilter/nf_nat.h                     |   10 +-
 include/net/netfilter/nf_nat_core.h                |    2 +-
 include/net/netfilter/nf_nat_protocol.h            |   17 +-
 net/ipv4/fib_rules.c                               |    1 +
 net/ipv4/fib_trie.c                                |    1 +
 net/ipv4/netfilter/Kconfig                         |   10 +
 net/ipv4/netfilter/Makefile                        |    1 +
 net/ipv4/netfilter/ipt_MASQUERADE.c                |   16 +-
 net/ipv4/netfilter/ipt_NETMAP.c                    |   14 +-
 net/ipv4/netfilter/ipt_REDIRECT.c                  |   16 +-
 net/ipv4/netfilter/ipt_rpfilter.c                  |  141 ++++++++
 net/ipv4/netfilter/nf_nat_core.c                   |   96 ++----
 net/ipv4/netfilter/nf_nat_h323.c                   |   20 +-
 net/ipv4/netfilter/nf_nat_helper.c                 |   16 +-
 net/ipv4/netfilter/nf_nat_pptp.c                   |   14 +-
 net/ipv4/netfilter/nf_nat_proto_common.c           |   36 +--
 net/ipv4/netfilter/nf_nat_proto_dccp.c             |    6 +-
 net/ipv4/netfilter/nf_nat_proto_gre.c              |   10 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c             |    6 +-
 net/ipv4/netfilter/nf_nat_proto_sctp.c             |    6 +-
 net/ipv4/netfilter/nf_nat_proto_tcp.c              |    6 +-
 net/ipv4/netfilter/nf_nat_proto_udp.c              |    6 +-
 net/ipv4/netfilter/nf_nat_proto_udplite.c          |    6 +-
 net/ipv4/netfilter/nf_nat_proto_unknown.c          |    3 +-
 net/ipv4/netfilter/nf_nat_rule.c                   |   22 +-
 net/ipv4/netfilter/nf_nat_sip.c                    |   10 +-
 net/ipv4/netfilter/nf_nat_standalone.c             |    2 +-
 net/ipv6/netfilter/Kconfig                         |   10 +
 net/ipv6/netfilter/Makefile                        |    1 +
 net/ipv6/netfilter/ip6t_rpfilter.c                 |  133 ++++++++
 net/ipv6/route.c                                   |    7 +
 net/netfilter/Kconfig                              |   18 +
 net/netfilter/Makefile                             |    2 +
 net/netfilter/ipvs/Kconfig                         |   15 +
 net/netfilter/ipvs/ip_vs_sh.c                      |   18 +-
 net/netfilter/nf_conntrack_acct.c                  |    4 +-
 net/netfilter/nf_conntrack_core.c                  |   15 +-
 net/netfilter/nf_conntrack_expect.c                |   63 ++---
 net/netfilter/nf_conntrack_helper.c                |   12 +
 net/netfilter/nf_conntrack_netlink.c               |   82 +++--
 net/netfilter/nfnetlink_acct.c                     |  352 ++++++++++++++++++++
 net/netfilter/xt_CT.c                              |    8 +-
 net/netfilter/xt_connbytes.c                       |   32 +-
 net/netfilter/xt_nfacct.c                          |   76 +++++
 59 files changed, 1168 insertions(+), 378 deletions(-)
 create mode 100644 include/linux/netfilter/nf_nat.h
 create mode 100644 include/linux/netfilter/nfnetlink_acct.h
 create mode 100644 include/linux/netfilter/xt_nfacct.h
 create mode 100644 include/linux/netfilter/xt_rpfilter.h
 delete mode 100644 include/linux/netfilter_ipv4/nf_nat.h
 create mode 100644 net/ipv4/netfilter/ipt_rpfilter.c
 create mode 100644 net/ipv6/netfilter/ip6t_rpfilter.c
 create mode 100644 net/netfilter/nfnetlink_acct.c
 create mode 100644 net/netfilter/xt_nfacct.c

-- 
1.7.2.5
