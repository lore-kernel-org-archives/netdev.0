From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] Netfilter fixes for net
Date: Wed,  1 Jun 2016 14:03:17 +0200
Message-ID: <1464782604-19346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52858 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757358AbcFAMDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 08:03:34 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C011911D9BCD
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 14:03:32 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A7B6C2310C3
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 14:03:32 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 65D2D2310BD
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 14:03:29 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Fix incorrect timestamp in nfnetlink_queue introduced when addressing
   y2038 safe timestamp, from Florian Westphal.

2) Get rid of leftover conntrack definition from the previous merge
   window, oneliner from Florian.

3) Make nf_queue handler pernet to resolve race on dereferencing the
   hook state structure with netns removal, from Eric Biederman.

4) Ensure clean exit on unregistered helper ports, from Taehee Yoo.

5) Restore FLOWI_FLAG_KNOWN_NH in nf_dup_ipv6. This got lost while
   generalizing xt_TEE to add packet duplication support in nf_tables,
   from Paolo Abeni.

6) Insufficient netlink NFTA_SET_TABLE attribute check in
   nf_tables_getset(), from Phil Turnbull.

7) Reject helper registration on duplicated ports via modparams.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 1b7cc307a88377b0c948f9cbc36d026b272fe6e3:

  Merge branch 'bnxt_en-fixes' (2016-05-11 23:46:09 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 893e093c786c4256d52809eed697e9d70a6f6643:

  netfilter: nf_ct_helper: bail out on duplicated helpers (2016-05-31 11:57:18 +0200)

----------------------------------------------------------------
Eric W. Biederman (1):
      netfilter: nf_queue: Make the queue_handler pernet

Florian Westphal (2):
      netfilter: nfnetlink_queue: fix timestamp attribute
      netfilter: conntrack: remove leftover binary sysctl define

Pablo Neira Ayuso (1):
      netfilter: nf_ct_helper: bail out on duplicated helpers

Paolo Abeni (1):
      netfilter: nf_dup_ipv6: set again FLOWI_FLAG_KNOWN_NH at flowi6_flags

Phil Turnbull (1):
      netfilter: nf_tables: validate NFTA_SET_TABLE parameter

Taehee Yoo (1):
      netfilter: nf_ct_helper: Fix helper unregister count.

 include/net/netfilter/nf_queue.h        |  4 ++--
 include/net/netns/netfilter.h           |  2 ++
 net/ipv6/netfilter/nf_dup_ipv6.c        |  1 +
 net/netfilter/nf_conntrack_ftp.c        |  1 +
 net/netfilter/nf_conntrack_helper.c     |  9 ++++-----
 net/netfilter/nf_conntrack_irc.c        |  1 +
 net/netfilter/nf_conntrack_sane.c       |  1 +
 net/netfilter/nf_conntrack_sip.c        |  1 +
 net/netfilter/nf_conntrack_standalone.c |  2 --
 net/netfilter/nf_conntrack_tftp.c       |  1 +
 net/netfilter/nf_queue.c                | 17 ++++++++---------
 net/netfilter/nf_tables_api.c           |  2 ++
 net/netfilter/nfnetlink_queue.c         | 20 +++++++++++++-------
 13 files changed, 37 insertions(+), 25 deletions(-)
