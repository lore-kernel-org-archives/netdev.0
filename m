From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] Netfilter fixes for net
Date: Thu, 24 Aug 2017 16:43:26 +0200
Message-ID: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50386 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753193AbdHXOnn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 10:43:43 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BBB401BFA80
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:43:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id ACEBFDA791
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:43:24 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Fix use after free of struct proc_dir_entry in ipt_CLUSTERIP, patch
   from Sabrina Dubroca.

2) Fix spurious EINVAL errors from iptables over nft compatibility layer.

3) Reload pointer to ip header only if there is non-terminal verdict,
   ie. XT_CONTINUE, otherwise invalid memory access may happen, patch
   from Taehee Yoo.

4) Fix interaction between SYNPROXY and NAT, SYNPROXY adds sequence
   adjustment already, however from nf_nat_setup() assumes there's not.
   Patch from Xin Long.

5) Fix burst arithmetics in nft_limit as Joe Stringer mentioned during
   NFWS in Faro. Patch from Andy Zhou.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks a lot!

----------------------------------------------------------------

The following changes since commit 073dd5ad34b1d3aaadaa7e5e8cbe576d9545f163:

  netfilter: fix netfilter_net_init() return (2017-07-18 14:50:28 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to c26844eda9d4fdbd266660e3b3de2d0270e3a1ed:

  netfilter: nf_tables: Fix nft limit burst handling (2017-08-24 16:23:17 +0200)

----------------------------------------------------------------
Pablo Neira Ayuso (1):
      netfilter: nft_compat: check extension hook mask only if set

Sabrina Dubroca (1):
      netfilter: ipt_CLUSTERIP: fix use-after-free of proc entry

Taehee Yoo (1):
      netfilter: x_tables: Fix use-after-free in ipt_do_table.

Xin Long (1):
      netfilter: check for seqadj ext existence before adding it in nf_nat_setup_info

andy zhou (1):
      netfilter: nf_tables: Fix nft limit burst handling

 net/ipv4/netfilter/arp_tables.c    | 10 +++++-----
 net/ipv4/netfilter/ip_tables.c     |  9 +++++----
 net/ipv4/netfilter/ipt_CLUSTERIP.c |  4 +++-
 net/netfilter/nf_nat_core.c        |  2 +-
 net/netfilter/nft_compat.c         |  4 ++--
 net/netfilter/nft_limit.c          | 25 ++++++++++++++-----------
 6 files changed, 30 insertions(+), 24 deletions(-)
