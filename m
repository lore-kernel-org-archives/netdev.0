From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Thu, 18 Aug 2016 19:29:02 +0200
Message-ID: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43976 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754344AbcHSA5m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:57:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E11E7A418A
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D1DC7FEFD1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B9DDACE155
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:16 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net tree,
they are:

1) Dump only conntrack that belong to this namespace via /proc file.
   This is some fallout from the conversion to single conntrack table
   for all netns, patch from Liping Zhang.

2) Missing MODULE_ALIAS_NF_LOGGER() for the ARP family that prevents
   module autoloading, also from Liping Zhang.

3) Report overquota event to the right netnamespace, again from Liping.

4) Fix tproxy listener sk refcount that leads to crash, from
   Eric Dumazet.

5) Fix racy refcounting on object deletion from nfnetlink and rule
   removal both for nfacct and cttimeout, from Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit a1560dd7a47f983419760aa7f6a481e3b910b54b:

  Merge branch 'mediatek-fixes' (2016-08-15 23:02:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to b75911b66ad508a3c3f006ce37d9f9ebee34da43:

  netfilter: cttimeout: fix use after free error when delete netns (2016-08-18 15:17:00 +0200)

----------------------------------------------------------------
Eric Dumazet (1):
      netfilter: tproxy: properly refcount tcp listeners

Liping Zhang (5):
      netfilter: conntrack: do not dump other netns's conntrack entries via proc
      netfilter: nfnetlink_log: add "nf-logger-3-1" module alias name
      netfilter: nfnetlink_acct: report overquota to the right netns
      netfilter: nfnetlink_acct: fix race between nfacct del and xt_nfacct destroy
      netfilter: cttimeout: fix use after free error when delete netns

 include/linux/netfilter/nfnetlink_acct.h |  4 ++--
 net/netfilter/nf_conntrack_standalone.c  |  4 ++++
 net/netfilter/nfnetlink_acct.c           | 17 +++++++++--------
 net/netfilter/nfnetlink_cttimeout.c      | 16 ++++++++++------
 net/netfilter/nfnetlink_log.c            |  1 +
 net/netfilter/xt_TPROXY.c                |  4 ++++
 net/netfilter/xt_nfacct.c                |  2 +-
 7 files changed, 31 insertions(+), 17 deletions(-)
