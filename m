From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter fixes for net
Date: Mon, 29 May 2017 13:34:28 +0200
Message-ID: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53064 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750925AbdE2Les (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 07:34:48 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 22776303D07
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0CBD1100A6C
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CAB2710218D
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:35 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Conntrack SCTP CRC32c checksum mangling may operate on non-linear
   skbuff, patch from Davide Caratti.

2) nf_tables rb-tree set backend does not handle element re-addition
   after deletion in the same transaction, leading to infinite loop.

3) Atomically unclear the IPS_SRC_NAT_DONE_BIT on nat module removal,
   from Liping Zhang.

4) Conntrack hashtable resizing while ctnetlink dump is progress leads
   to a dead reference to released objects in the lists, also from
   Liping.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 6d18c732b95c0a9d35e9f978b4438bba15412284:

  bridge: start hello_timer when enabling KERNEL_STP in br_stp_start (2017-05-21 13:33:28 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to fefa92679dbe0c613e62b6c27235dcfbe9640ad1:

  netfilter: ctnetlink: fix incorrect nf_ct_put during hash resize (2017-05-24 11:26:01 +0200)

----------------------------------------------------------------
Davide Caratti (1):
      netfilter: conntrack: fix false CRC32c mismatch using paged skb

Liping Zhang (2):
      netfilter: nat: use atomic bit op to clear the _SRC_NAT_DONE_BIT
      netfilter: ctnetlink: fix incorrect nf_ct_put during hash resize

Pablo Neira Ayuso (1):
      netfilter: nft_set_rbtree: handle element re-addition after deletion

 net/netfilter/nf_conntrack_netlink.c    |  7 ++++++-
 net/netfilter/nf_conntrack_proto_sctp.c |  9 ++++++---
 net/netfilter/nf_nat_core.c             |  2 +-
 net/netfilter/nft_set_rbtree.c          | 22 +++++++++++-----------
 4 files changed, 24 insertions(+), 16 deletions(-)
