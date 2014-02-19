From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Wed, 19 Feb 2014 12:41:36 +0100
Message-ID: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

* Fix nf_trace in nftables if XT_TRACE=n, from Florian Westphal.

* Don't use the fast payload operation in nf_tables if the length is
  not power of 2 or it is not aligned, from Nikolay Aleksandrov.

* Fix missing break statement the inet flavour of nft_reject, which
  results in evaluating IPv4 packets with the IPv6 evaluation routine,
  from Patrick McHardy.

* Fix wrong kconfig symbol in nft_meta to match the routing realm,
  from Paul Bolle.

* Allocate the NAT null binding when creating new conntracks via
  ctnetlink to avoid that several packets race at initializing the
  the conntrack NAT extension, original patch from Florian Westphal,
  revisited version from me.

* Fix DNAT handling in the snmp NAT helper, the same handling was being
  done for SNAT and DNAT and 2.4 already contains that fix, from
  Francois-Xavier Le Bail.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 20e7c4e80dcd01dad5e6c8b32455228b8fe9c619:

  6lowpan: fix lockdep splats (2014-02-10 17:51:29 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 0eba801b64cc8284d9024c7ece30415a2b981a72:

  netfilter: ctnetlink: force null nat binding on insert (2014-02-18 00:13:51 +0100)

----------------------------------------------------------------
FX Le Bail (1):
      netfilter: nf_nat_snmp_basic: fix duplicates in if/else branches

Florian Westphal (1):
      netfilter: nf_tables: fix nf_trace always-on with XT_TRACE=n

Nikolay Aleksandrov (1):
      netfilter: nf_tables: check if payload length is a power of 2

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: force null nat binding on insert

Patrick McHardy (1):
      netfilter: nft_reject_inet: fix unintended fall-through in switch-statatement

Paul Bolle (1):
      netfilter: nft_meta: fix typo "CONFIG_NET_CLS_ROUTE"

 include/linux/skbuff.h                 |    5 ++-
 net/core/skbuff.c                      |    3 --
 net/ipv4/ip_output.c                   |    3 --
 net/ipv4/netfilter/nf_nat_snmp_basic.c |    4 +--
 net/ipv6/ip6_output.c                  |    3 --
 net/netfilter/nf_conntrack_netlink.c   |   35 ++++++++------------
 net/netfilter/nf_nat_core.c            |   56 ++++++++++++++++++++------------
 net/netfilter/nft_meta.c               |    4 +--
 net/netfilter/nft_payload.c            |    3 +-
 net/netfilter/nft_reject_inet.c        |    4 +--
 10 files changed, 61 insertions(+), 59 deletions(-)
