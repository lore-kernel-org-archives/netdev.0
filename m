From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] Netfilter fixes for net
Date: Fri, 17 Jun 2016 20:25:12 +0200
Message-ID: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44624 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbcFQSZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 14:25:39 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 18178E5A56
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0AF629EBA7
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BC15D9EBA1
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:33 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are rather small patches but fixing several outstanding bugs in
nf_conntrack and nf_tables, as well as minor problems with missing
SYNPROXY header uapi installation:

1) Oneliner not to leak conntrack kmemcache on module removal, this
   problem was introduced in the previous merge window, patch from
   Florian Westphal.

2) Two fixes for insufficient ruleset loop validation, one due to
   incorrect flag check in nf_tables_bind_set() and another related to
   silly wrong generation mask logic from the walk path, from Liping
   Zhang.

3) Fix double-free of anonymous sets on error, this fix simplifies the
   code to let the abort path take care of releasing the set object,
   also from Liping Zhang.

4) The introduction of helper function for transactions broke the skip
   inactive rules logic from the nft_do_chain(), again from Liping
   Zhang.

5) Two patches to install uapi xt_SYNPROXY.h header and calm down
   kbuild robot due to missing #include <linux/types.h>.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 61e0979a497b07f5a82f3050e37ecc7093e2971d:

  Merge branch 'ovs-notifications' (2016-06-14 22:21:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 1463847e93fe693e89c52b03ab4ede6800d717c1:

  netfilter: xt_SYNPROXY: include missing <linux/types.h> (2016-06-17 13:47:40 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: conntrack: destroy kmemcache on module removal

Liping Zhang (3):
      netfilter: nf_tables: fix wrong check of NFT_SET_MAP in nf_tables_bind_set
      netfilter: nf_tables: fix wrong destroy anonymous sets if binding fails
      netfilter: nf_tables: fix a wrong check to skip the inactive rules

Pablo Neira Ayuso (3):
      netfilter: nf_tables: reject loops from set element jump to chain
      netfilter: xt_SYNPROXY: add missing header to Kbuild
      netfilter: xt_SYNPROXY: include missing <linux/types.h>

 include/net/netfilter/nf_tables.h          |  1 +
 include/uapi/linux/netfilter/Kbuild        |  1 +
 include/uapi/linux/netfilter/xt_SYNPROXY.h |  2 ++
 net/netfilter/nf_conntrack_core.c          |  2 ++
 net/netfilter/nf_tables_api.c              | 24 +++++++++++-------------
 net/netfilter/nf_tables_core.c             |  2 +-
 net/netfilter/nft_hash.c                   |  3 +--
 net/netfilter/nft_rbtree.c                 |  3 +--
 8 files changed, 20 insertions(+), 18 deletions(-)
