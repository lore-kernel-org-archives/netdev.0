From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter fixes for net
Date: Fri,  3 Mar 2017 20:22:21 +0100
Message-ID: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39542 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752042AbdCCTW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 14:22:58 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 95FF51C4FFF
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8648EDA804
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 70769DA808
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:32 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Missing check for full sock in ip_route_me_harder(), from
   Florian Westphal.

2) Incorrect sip helper structure initilization that breaks it when
   several ports are used, from Christophe Leroy.

3) Fix incorrect assumption when looking up for matching with adjacent
   intervals in the nft_set_rbtree.

4) Fix broken netlink event error reporting in nf_tables that results
   in misleading ESRCH errors propagated to userspace listeners.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 2f44f75257d57f0d5668dba3a6ada0f4872132c9:

  Merge branch 'qed-fixes' (2017-02-27 09:22:10 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 25e94a997b324b5f167f56d56d7106d38b78c9de:

  netfilter: nf_tables: don't call nfnetlink_set_err() if nfnetlink_send() fails (2017-03-03 13:48:34 +0100)

----------------------------------------------------------------
Christophe Leroy (1):
      netfilter: nf_conntrack_sip: fix wrong memory initialisation

Florian Westphal (1):
      netfilter: use skb_to_full_sk in ip_route_me_harder

Pablo Neira Ayuso (2):
      netfilter: nft_set_rbtree: incorrect assumption on lower interval lookups
      netfilter: nf_tables: don't call nfnetlink_set_err() if nfnetlink_send() fails

 include/net/netfilter/nf_tables.h |   6 +-
 net/ipv4/netfilter.c              |   7 +-
 net/netfilter/nf_conntrack_sip.c  |   2 -
 net/netfilter/nf_tables_api.c     | 133 ++++++++++++++++----------------------
 net/netfilter/nft_set_rbtree.c    |   9 ++-
 5 files changed, 66 insertions(+), 91 deletions(-)
