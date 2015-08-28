From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/9] Netfilter updates for net-next
Date: Sat, 29 Aug 2015 00:50:08 +0200
Message-ID: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42103 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbbH1WoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 18:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter/IPVS updates for your net-next tree.
In sum, patches to address fallout from the previous round plus updates from
the IPVS folks via Simon Horman, they are:

1) Add a new scheduler to IPVS: The weighted overflow scheduling algorithm
   directs network connections to the server with the highest weight that is
   currently available and overflows to the next when active connections exceed
   the node's weight. From Raducu Deaconu.

2) Fix locking ordering in IPVS, always take rtnl_lock in first place. Patch
   from Julian Anastasov.

3) Allow to indicate the MTU to the IPVS in-kernel state sync daemon. From
   Julian Anastasov.

4) Enhance multicast configuration for the IPVS state sync daemon. Also from
   Julian.

5) Resolve sparse warnings in the nf_dup modules.

6) Fix a linking problem when CONFIG_NF_DUP_IPV6 is not set.

7) Add ICMP codes 5 and 6 to IPv6 REJECT target, they are more informative
   subsets of code 1. From Andreas Herz.

8) Revert the jumpstack size calculation from mark_source_chains due to chain
   depth miscalculations, from Florian Westphal.

9) Calm down more sparse warning around the Netfilter tree, again from Florian
   Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 81bf1c64e7fe08f956c74fe2b0f1fa6eb163bd91:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2015-08-21 06:09:05 +0200)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 851345c5bbb4644911f7c351c042559a71f57d19:

  netfilter: reduce sparse warnings (2015-08-28 21:04:12 +0200)

----------------------------------------------------------------
Andreas Herz (1):
      netfilter: ip6t_REJECT: added missing icmpv6 codes

Florian Westphal (2):
      Revert "netfilter: xtables: compute exact size needed for jumpstack"
      netfilter: reduce sparse warnings

Julian Anastasov (3):
      ipvs: call rtnl_lock early
      ipvs: add sync_maxlen parameter for the sync daemon
      ipvs: add more mcast parameters for the sync daemon

Pablo Neira Ayuso (3):
      netfilter: nf_dup: fix sparse warnings
      netfilter: xt_TEE: use IS_ENABLED(CONFIG_NF_DUP_IPV6)
      Merge tag 'ipvs2-for-v4.3' of https://git.kernel.org/.../horms/ipvs-next

Raducu Deaconu (1):
      ipvs: Add ovf scheduler

 include/net/ip_vs.h                             |   23 +-
 include/uapi/linux/ip_vs.h                      |    5 +
 include/uapi/linux/netfilter_ipv6/ip6t_REJECT.h |    4 +-
 net/bridge/netfilter/ebtables.c                 |    2 +-
 net/ipv4/netfilter/arp_tables.c                 |   19 +-
 net/ipv4/netfilter/ip_tables.c                  |   28 +--
 net/ipv4/netfilter/nft_dup_ipv4.c               |    2 +-
 net/ipv6/netfilter/ip6_tables.c                 |   23 +-
 net/ipv6/netfilter/ip6t_REJECT.c                |    6 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c              |    2 +-
 net/ipv6/netfilter/nf_dup_ipv6.c                |    4 +-
 net/netfilter/core.c                            |    3 -
 net/netfilter/ipvs/Kconfig                      |   11 +
 net/netfilter/ipvs/Makefile                     |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c                  |  143 +++++++++---
 net/netfilter/ipvs/ip_vs_ovf.c                  |   86 ++++++++
 net/netfilter/ipvs/ip_vs_sync.c                 |  269 +++++++++++++++--------
 net/netfilter/nf_synproxy_core.c                |    6 +-
 net/netfilter/xt_TEE.c                          |    4 +-
 19 files changed, 446 insertions(+), 195 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_ovf.c
