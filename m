From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] Netfilter fixes for net
Date: Tue, 18 Jul 2017 12:13:54 +0200
Message-ID: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44240 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751411AbdGRKOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 06:14:09 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C312DA4169
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:13:56 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AFE88A7F25
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:13:56 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E663DDA840
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:13:51 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Missing netlink message sanity check in nfnetlink, patch from
   Mateusz Jurczyk.

2) We now have netfilter per-netns hooks, so let's kill global hook
   infrastructure, this infrastructure is known to be racy with netns.
   We don't care about out of tree modules. Patch from Florian Westphal.

3) find_appropriate_src() is buggy when colissions happens after the
   conversion of the nat bysource to rhashtable. Also from Florian.

4) Remove forward chain in nf_tables arp family, it's useless and it is
   causing quite a bit of confusion, from Florian Westphal.

5) nf_ct_remove_expect() is called with the wrong parameter, causing
   kernel oops, patch from Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 533da29b584de5ae0e9dafafbe52809f59cb5300:

  Merge branch 'bcmgenet-Fragmented-SKB-corrections' (2017-07-15 21:29:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 36ac344e16e04e3e55e8fed7446095a6458c64e6:

  netfilter: expect: fix crash when putting uninited expectation (2017-07-17 17:03:12 +0200)

----------------------------------------------------------------
Florian Westphal (4):
      netfilter: remove old pre-netns era hook api
      netfilter: nat: fix src map lookup
      netfilter: nf_tables: only allow in/output for arp packets
      netfilter: expect: fix crash when putting uninited expectation

Mateusz Jurczyk (1):
      netfilter: nfnetlink: Improve input length sanitization in nfnetlink_rcv

 include/linux/netfilter.h           |   9 ---
 net/ipv4/netfilter/nf_tables_arp.c  |   3 +-
 net/netfilter/core.c                | 143 ------------------------------------
 net/netfilter/nf_conntrack_expect.c |   2 +-
 net/netfilter/nf_nat_core.c         |  17 +++--
 net/netfilter/nfnetlink.c           |   6 +-
 6 files changed, 14 insertions(+), 166 deletions(-)
