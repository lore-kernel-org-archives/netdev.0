From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/08: Netfilter Update
Date: Thu,  3 Dec 2009 21:19:32 +0100 (MET)
Message-ID: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37689 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753265AbZLCUT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:19:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following is a small netfilter update for 2.6.32, containing:

- various cleanups by Changli Gao, Hannes Eder and Joe Perches

- a patch from Pablo to improve TCP window tracking behaviour
  when connection tracking is out-of-sync with the connection
  endpoints.

- INPUT chain support for the xt_socket match

- a fix for dumping the revision 1 data of the conntrack match
  by Florian Westphal.

- Removal of some unnecessary code by myself and Eric

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 include/linux/netfilter/nf_conntrack_tcp.h     |    3 +
 net/ipv4/netfilter/arp_tables.c                |   22 ++++----
 net/ipv4/netfilter/ip_queue.c                  |    5 +-
 net/ipv4/netfilter/ip_tables.c                 |   46 +++++++++---------
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |   20 ++++----
 net/ipv4/netfilter/ipt_ECN.c                   |    8 ++--
 net/ipv4/netfilter/ipt_LOG.c                   |   22 ++++----
 net/ipv4/netfilter/ipt_MASQUERADE.c            |    4 +-
 net/ipv4/netfilter/ipt_REJECT.c                |    4 +-
 net/ipv4/netfilter/ipt_ULOG.c                  |    6 +-
 net/ipv4/netfilter/ipt_ecn.c                   |    4 +-
 net/ipv4/netfilter/iptable_mangle.c            |    4 +-
 net/ipv4/netfilter/iptable_security.c          |    4 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   28 +++++-----
 net/ipv4/netfilter/nf_nat_helper.c             |   22 ++++-----
 net/ipv4/netfilter/nf_nat_standalone.c         |   10 ++--
 net/ipv6/netfilter/ip6_queue.c                 |    5 +-
 net/ipv6/netfilter/ip6_tables.c                |   42 ++++++++--------
 net/ipv6/netfilter/ip6t_LOG.c                  |    4 +-
 net/ipv6/netfilter/ip6t_REJECT.c               |    4 +-
 net/ipv6/netfilter/ip6t_ah.c                   |   19 +++----
 net/ipv6/netfilter/ip6t_frag.c                 |   47 ++++++++----------
 net/ipv6/netfilter/ip6t_rt.c                   |    9 +--
 net/ipv6/netfilter/ip6table_filter.c           |    4 +-
 net/ipv6/netfilter/ip6table_mangle.c           |   14 +++---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   12 ++--
 net/netfilter/nf_conntrack_core.c              |   14 ++++--
 net/netfilter/nf_conntrack_proto_tcp.c         |   51 ++++++++++++++++----
 net/netfilter/nfnetlink_log.c                  |    3 +-
 net/netfilter/nfnetlink_queue.c                |    3 +-
 net/netfilter/xt_conntrack.c                   |   61 +++++++-----------------
 net/netfilter/xt_socket.c                      |    6 ++-
 32 files changed, 253 insertions(+), 257 deletions(-)

Changli Gao (1):
      netfilter: nf_conntrack: avoid additional compare.

Eric Dumazet (1):
      netfilter: remove synchronize_net() calls in ip_queue/ip6_queue

Florian Westphal (1):
      netfilter: xtables: fix conntrack match v1 ipt-save output

Hannes Eder (1):
      netfilter: nf_nat_helper: tidy up adjust_tcp_sequence

Jan Engelhardt (1):
      netfilter: xt_socket: make module available for INPUT chain

Joe Perches (1):
      netfilter: net/ipv[46]/netfilter: Move && and || to end of previous line

Pablo Neira Ayuso (1):
      netfilter: nf_ct_tcp: improve out-of-sync situation in TCP tracking

Patrick McHardy (1):
      netfilter: remove unneccessary checks from netlink notifiers
