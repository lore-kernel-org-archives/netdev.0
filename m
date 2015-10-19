From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter fixes for net
Date: Mon, 19 Oct 2015 20:22:51 +0200
Message-ID: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37514 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754642AbbJSSP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 14:15:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains four Netfilter fixes for net, they are:

1) Fix Kconfig dependencies of new nf_dup_ipv4 and nf_dup_ipv6.

2) Remove bogus test nh_scope in IPv4 rpfilter match that is breaking
   --accept-local, from Xin Long.

3) Wait for RCU grace period after dropping the pending packets in the
   nfqueue, from Florian Westphal.

4) Fix sleeping allocation while holding spin_lock_bh, from Nikolay Borisov.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit b84f78782052ee4516903e5d0566a5eee365b771:

  net: Initialize flow flags in input path (2015-09-29 21:52:32 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 00db674bedd68ff8b5afae9030ff5e04d45d1b4a:

  netfilter: ipset: Fix sleeping memory allocation in atomic context (2015-10-17 13:01:24 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: sync with packet rx also after removing queue entries

Nikolay Borisov (1):
      netfilter: ipset: Fix sleeping memory allocation in atomic context

Pablo Neira Ayuso (1):
      netfilter: fix Kconfig dependencies for nf_dup_ipv{4,6}

lucien (1):
      netfilter: ipt_rpfilter: remove the nh_scope test in rpfilter_lookup_reverse

 net/ipv4/netfilter/Kconfig            | 1 +
 net/ipv4/netfilter/ipt_rpfilter.c     | 4 +---
 net/ipv6/netfilter/Kconfig            | 1 +
 net/netfilter/core.c                  | 2 ++
 net/netfilter/ipset/ip_set_list_set.c | 2 +-
 5 files changed, 6 insertions(+), 4 deletions(-)
