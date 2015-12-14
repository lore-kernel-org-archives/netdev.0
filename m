From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] netfilter fixes for net
Date: Mon, 14 Dec 2015 12:25:40 +0100
Message-ID: <1450092346-3281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47834 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691AbbLNL14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 06:27:56 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9EAC4DA87B
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:27:55 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7E89AC230D
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:27:55 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 936F01B3212
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:27:02 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for you net tree,
specifically for nf_tables and nfnetlink_queue, they are:

1) Avoid a compilation warning in nfnetlink_queue that was introduced
   in the previous merge window with the simplification of the conntrack
   integration, from Arnd Bergmann.

2) nfnetlink_queue is leaking the pernet subsystem registration from
   a failure path, patch from Nikolay Borisov.

3) Pass down netns pointer to batch callback in nfnetlink, this is the
   largest patch and it is not a bugfix but it is a dependency to
   resolve a splat in the correct way.

4) Fix a splat due to incorrect socket memory accounting with nfnetlink
   skbuff clones.

5) Add missing conntrack dependencies to NFT_DUP_IPV4 and NFT_DUP_IPV6.

6) Traverse the nftables commit list in reverse order from the commit
   path, otherwise we crash when the user applies an incremental update
   via 'nft -f' that deletes an object that was just introduced in this
   batch, from Xin Long.

Regarding the compilation warning fix, many people have sent us (and
keep sending us) patches to address this, that's why I'm including this
batch even if this is not critical.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 4c6980462f32b4f282c5d8e5f7ea8070e2937725:

  net: ip6mr: fix static mfc/dev leaks on table destruction (2015-11-22 20:44:47 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to a907e36d54e0ff836e55e04531be201bf6b4d8c8:

  netfilter: nf_tables: use reverse traversal commit_list in nf_tables_abort (2015-12-13 22:47:32 +0100)

----------------------------------------------------------------
Arnd Bergmann (1):
      netfilter: nfnetlink_queue: avoid harmless unnitialized variable warnings

Nikolay Borisov (1):
      netfilter: nfnetlink_queue: Unregister pernet subsys in case of init failure

Pablo Neira Ayuso (3):
      netfilter: nfnetlink: avoid recurrent netns lookups in call_batch
      netfilter: nfnetlink: fix splat due to incorrect socket memory accounting in skbuff clones
      netfilter: nf_dup: add missing dependencies with NF_CONNTRACK

Xin Long (1):
      netfilter: nf_tables: use reverse traversal commit_list in nf_tables_abort

 include/linux/netfilter/nfnetlink.h |  2 +-
 net/ipv4/netfilter/Kconfig          |  1 +
 net/ipv6/netfilter/Kconfig          |  1 +
 net/netfilter/nf_tables_api.c       | 99 ++++++++++++++++++-------------------
 net/netfilter/nfnetlink.c           |  4 +-
 net/netfilter/nfnetlink_queue.c     |  9 ++--
 6 files changed, 57 insertions(+), 59 deletions(-)
