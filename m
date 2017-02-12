From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/21] Netfilter updates for net-next
Date: Sun, 12 Feb 2017 20:42:32 +0100
Message-ID: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60412 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751315AbdBLTnN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 14:43:13 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0CC22BA6E7
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id ED7ADDA81C
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 58E53DA804
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:04 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net-next
tree, most relevantly they are:

1) Extend nft_exthdr to allow to match TCP options bitfields, from
   Manuel Messner.

2) Allow to check if IPv6 extension header is present in nf_tables,
   from Phil Sutter.

3) Allow to set and match conntrack zone in nf_tables, patches from
   Florian Westphal.

4) Several patches for the nf_tables set infrastructure, this includes
   cleanup and preparatory patches to add the new bitmap set type.

5) Add optional ruleset generation ID check to nf_tables and allow to
   delete rules that got no public handle yet via NFTA_RULE_ID. These
   patches add the missing kernel infrastructure to support rule
   deletion by description from userspace.

6) Missing NFT_SET_OBJECT flag to select the right backend when sets
   stores an object map.

7) A couple of cleanups for the expectation and SIP helper, from Gao
   feng.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 6e7bc478c9a006c701c14476ec9d389a484b4864:

  net: skb_needs_check() accepts CHECKSUM_NONE for tx (2017-02-03 17:33:01 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 7286ff7fde9f963736c7e575572899d8e16b06b7:

  netfilter: nf_tables: honor NFT_SET_OBJECT in set backend selection (2017-02-12 14:45:14 +0100)

----------------------------------------------------------------
Florian Westphal (3):
      netfilter: nft_ct: add zone id get support
      netfilter: nft_ct: prepare for key-dependent error unwind
      netfilter: nft_ct: add zone id set support

Gao Feng (2):
      netfilter: nf_ct_sip: Use mod_timer_pending()
      netfilter: nf_ct_expect: nf_ct_expect_insert() returns void

Manuel Messner (1):
      netfilter: nft_exthdr: add TCP option matching

Pablo Neira Ayuso (14):
      netfilter: nf_tables: pass netns to set->ops->remove()
      netfilter: nf_tables: use struct nft_set_iter in set element flush
      netfilter: nf_tables: rename deactivate_one() to flush()
      netfilter: nf_tables: add flush field to struct nft_set_iter
      netfilter: nf_tables: rename struct nft_set_estimate class field
      netfilter: nf_tables: add space notation to sets
      netfilter: nf_tables: add bitmap set type
      netfilter: nfnetlink: get rid of u_intX_t types
      netfilter: nfnetlink: add nfnetlink_rcv_skb_batch()
      netfilter: nfnetlink: allow to check for generation ID
      netfilter: nf_tables: add check_genid to the nfnetlink subsystem
      netfilter: nf_tables: add NFTA_RULE_ID attribute
      netfilter: update MAINTAINERS
      netfilter: nf_tables: honor NFT_SET_OBJECT in set backend selection

Phil Sutter (1):
      netfilter: nft_exthdr: Add support for existence check

 MAINTAINERS                              |   3 +-
 include/linux/netfilter/nfnetlink.h      |   1 +
 include/net/netfilter/nf_tables.h        |  21 ++-
 include/uapi/linux/netfilter/nf_tables.h |  27 ++-
 include/uapi/linux/netfilter/nfnetlink.h |  12 ++
 net/netfilter/Kconfig                    |  10 +-
 net/netfilter/Makefile                   |   1 +
 net/netfilter/nf_conntrack_expect.c      |   8 +-
 net/netfilter/nf_conntrack_sip.c         |  12 +-
 net/netfilter/nf_tables_api.c            |  89 ++++++---
 net/netfilter/nfnetlink.c                |  90 ++++++---
 net/netfilter/nft_ct.c                   | 195 +++++++++++++++++--
 net/netfilter/nft_exthdr.c               | 139 ++++++++++++--
 net/netfilter/nft_set_bitmap.c           | 314 +++++++++++++++++++++++++++++++
 net/netfilter/nft_set_hash.c             |  16 +-
 net/netfilter/nft_set_rbtree.c           |  16 +-
 16 files changed, 832 insertions(+), 122 deletions(-)
 create mode 100644 net/netfilter/nft_set_bitmap.c
