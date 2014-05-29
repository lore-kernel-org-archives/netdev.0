From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter/IPVS updates for net-next
Date: Thu, 29 May 2014 17:54:57 +0200
Message-ID: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This small patchset contains three accumulated Netfilter/IPVS updates,
they are:

1) Refactorize common NAT code by encapsulating it into a helper
   function, similarly to what we do in other conntrack extensions,
   from Florian Westphal.

2) A minor format string mismatch fix for IPVS, from Masanari Iida.

3) Add quota support to the netfilter accounting infrastructure, now
   you can add quotas to accounting objects via the nfnetlink interface
   and use them from iptables. You can also listen to quota
   notifications from userspace. This enhancement from Mathieu Poirier.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit fd0d192be6e814495aec91f357b5801afc3b6262:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next (2014-04-22 21:47:06 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to f768e5bdefe1ec9adbf7a116dfb156b73cacb582:

  netfilter: add helper for adding nat extension (2014-04-29 20:56:22 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: add helper for adding nat extension

Masanari Iida (1):
      netfilter: Fix format string mismatch in ip_vs_proto_name()

Mathieu Poirier (1):
      netfilter: nfnetlink_acct: Adding quota support to accounting framework

 include/linux/netfilter/nfnetlink_acct.h      |    8 ++-
 include/net/netfilter/nf_nat.h                |    2 +
 include/uapi/linux/netfilter/nfnetlink.h      |    2 +
 include/uapi/linux/netfilter/nfnetlink_acct.h |    9 +++
 net/ipv4/netfilter/iptable_nat.c              |   14 +---
 net/ipv4/netfilter/nft_chain_nat_ipv4.c       |   12 +---
 net/ipv6/netfilter/ip6table_nat.c             |   14 +---
 net/ipv6/netfilter/nft_chain_nat_ipv6.c       |   12 +---
 net/netfilter/ipvs/ip_vs_core.c               |    2 +-
 net/netfilter/nf_nat_core.c                   |   24 ++++---
 net/netfilter/nfnetlink_acct.c                |   85 +++++++++++++++++++++++++
 net/netfilter/xt_nfacct.c                     |    5 +-
 12 files changed, 138 insertions(+), 51 deletions(-)
