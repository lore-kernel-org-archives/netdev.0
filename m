From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter fixes for net
Date: Wed,  1 Nov 2017 19:48:10 +0100
Message-ID: <20171101184812.4813-1-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46480 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932685AbdKASsV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 14:48:21 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 02ECF53AA25
        for <netdev@vger.kernel.org>; Wed,  1 Nov 2017 19:48:20 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EA644DA392
        for <netdev@vger.kernel.org>; Wed,  1 Nov 2017 19:48:19 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains two one-liner fixes for your net tree,
they are:

1) Disable fast hash operations for 2-bytes length keys which is leading
   to incorrect lookups in nf_tables, from Anatole Denis.

2) Reload pointer ipv4 header after ip_route_me_harder() given this may
   result in use-after-free due to skbuff header reallocation, patch
   from Tejaswi Tanikella.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 28e33f9d78eefe98ea86673ab31e988b37a9a738:

  bpf: disallow arithmetic operations on context pointer (2017-10-18 13:21:13 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 7400bb4b5800831581a82f71700af6a5e815c3c8:

  netfilter: nf_reject_ipv4: Fix use-after-free in send_reset (2017-11-01 12:15:29 +0100)

----------------------------------------------------------------
Anatole Denis (1):
      netfilter: nft_set_hash: disable fast_ops for 2-len keys

Tejaswi Tanikella (1):
      netfilter: nf_reject_ipv4: Fix use-after-free in send_reset

 net/ipv4/netfilter/nf_reject_ipv4.c | 2 ++
 net/netfilter/nft_set_hash.c        | 1 -
 2 files changed, 2 insertions(+), 1 deletion(-)
