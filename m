From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter/IPVS fixes for net
Date: Sat, 31 Jan 2015 21:55:07 +0100
Message-ID: <1422737711-5169-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS fixes for your net tree,
they are:

1) Validate hooks for nf_tables NAT expressions, otherwise users can
   crash the kernel when using them from the wrong hook. We already
   got one user trapped on this when configuring masquerading.

2) Fix a BUG splat in nf_tables with CONFIG_DEBUG_PREEMPT=y. Reported
   by Andreas Schultz.

3) Avoid unnecessary reroute of traffic in the local input path
   in IPVS that triggers a crash in in xfrm. Reported by Florian
   Wiessner and fixes by Julian Anastasov.

4) Fix memory and module refcount leak from the error path of
   nf_tables_newchain().

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 2061dcd6bff8b774b4fac8b0739b6be3f87bc9f2:

  net: sctp: fix race for one-to-many sockets in sendmsg's auto associate (2015-01-17 23:52:20 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to f5553c19ff9058136e7082c0b1f4268e705ea538:

  netfilter: nf_tables: fix leaks in error path of nf_tables_newchain() (2015-01-30 18:42:08 +0100)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: rerouting to local clients is not needed anymore

Pablo Neira Ayuso (3):
      netfilter: nf_tables: validate hooks in NAT expressions
      netfilter: nf_tables: disable preemption when restoring chain counters
      netfilter: nf_tables: fix leaks in error path of nf_tables_newchain()

 include/net/netfilter/nf_tables.h        |    2 ++
 net/bridge/netfilter/nft_reject_bridge.c |   29 +++++-----------------
 net/netfilter/ipvs/ip_vs_core.c          |   33 ++++++++++++++++--------
 net/netfilter/nf_tables_api.c            |   28 +++++++++++++++++++--
 net/netfilter/nft_masq.c                 |   26 ++++++++++++-------
 net/netfilter/nft_nat.c                  |   40 ++++++++++++++++++++++--------
 net/netfilter/nft_redir.c                |   25 +++++++++++++------
 7 files changed, 120 insertions(+), 63 deletions(-)
