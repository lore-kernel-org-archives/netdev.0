From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] netfilter fixes for net
Date: Mon, 20 Oct 2014 10:10:32 +0200
Message-ID: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40033 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752809AbaJTIJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 04:09:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains netfilter fixes for your net tree,
they are:

1) Fix missing MODULE_LICENSE() in the new nf_reject_ipv{4,6} modules.

2) Restrict nat and masq expressions to the nat chain type. Otherwise,
   users may crash their kernel if they attach a nat/masq rule to a non
   nat chain.

3) Fix hook validation in nft_compat when non-base chains are used.
   Basically, initialize hook_mask to zero.

4) Make sure you use match/targets in nft_compat from the right chain
   type. The existing validation relies on the table name which can be
   avoided by

5) Better netlink attribute validation in nft_nat. This expression has
   to reject the configuration when no address and proto configurations
   are specified.

6) Interpret NFTA_NAT_REG_*_MAX if only if NFTA_NAT_REG_*_MIN is set.
   Yet another sanity check to reject incorrect configurations from
   userspace.

7) Conditional NAT attribute dumping depending on the existing
   configuration.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 01d2d484e49e9bc0ed9b5fdaf345a0e2bf35ffed:

  Merge branch 'bcmgenet_systemport' (2014-10-10 15:39:22 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 1e2d56a5d33a7e1fcd21ed3859f52596d02708b0:

  netfilter: nft_nat: dump attributes if they are set (2014-10-18 14:16:13 +0200)

----------------------------------------------------------------
Pablo Neira Ayuso (7):
      netfilter: missing module license in the nf_reject_ipvX modules
      netfilter: nf_tables: restrict nat/masq expressions to nat chain type
      netfilter: nft_compat: fix hook validation for non-base chains
      netfilter: nft_compat: validate chain type in match/target
      netfilter: nft_nat: insufficient attribute validation
      netfilter: nft_nat: NFTA_NAT_REG_ADDR_MAX depends on NFTA_NAT_REG_ADDR_MIN
      netfilter: nft_nat: dump attributes if they are set

 include/net/netfilter/nf_tables.h   |    3 ++
 include/net/netfilter/nft_masq.h    |    3 ++
 net/ipv4/netfilter/nf_reject_ipv4.c |    3 ++
 net/ipv4/netfilter/nft_masq_ipv4.c  |    1 +
 net/ipv6/netfilter/nf_reject_ipv6.c |    4 ++
 net/ipv6/netfilter/nft_masq_ipv6.c  |    1 +
 net/netfilter/nf_tables_api.c       |   14 ++++++
 net/netfilter/nft_compat.c          |   79 ++++++++++++++++++++++++++++----
 net/netfilter/nft_masq.c            |   12 +++++
 net/netfilter/nft_nat.c             |   86 ++++++++++++++++++++++-------------
 10 files changed, 165 insertions(+), 41 deletions(-)
