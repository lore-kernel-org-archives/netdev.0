From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Wed, 20 Jan 2016 18:03:58 +0100
Message-ID: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45467 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934626AbcATRET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 12:04:19 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 99766A7E2E
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:18 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8C8D2DA809
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:18 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 69DF8DA85D
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:16 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree, they
are:

1) Fix accidental 3-times le/be conversion for 64-bits in nft_byteorder,
   from Florian Westphal.

2) Get rid of defensive cidr = 0 check in the ipset hash:netiface set
   type which doesn't allow valid 0.0.0.0/0 elements, also from Florian.

3) Relocate #endif in nft_ct counter support, this doesn't have any
   relation with labels.

4) Fix TCPMSS target for IPv6 when skb has CHECKSUM_COMPLETE, from
   Eric Dumazet.

5) Fix netdevice notifier leak from the error path of nf_tables_netdev.

6) Safe conntrack hashtable resizing by introducing a global lock and
   synchronize all buckets to avoid going over the maximum number of
   preemption levels, from Sasha Levin.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit f1640c3ddeec12804bc9a21feee85fc15aca95f6:

  bgmac: fix a missing check for build_skb (2016-01-13 00:24:14 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to b16c29191dc89bd877af99a7b04ce4866728a3e0:

  netfilter: nf_conntrack: use safer way to lock all buckets (2016-01-20 14:15:31 +0100)

----------------------------------------------------------------
Eric Dumazet (1):
      netfilter: xt_TCPMSS: handle CHECKSUM_COMPLETE in tcpmss_tg6()

Florian Westphal (2):
      netfilter: nft_byteorder: avoid unneeded le/be conversion steps
      netfilter: ipset: allow a 0 netmask with hash_netiface type

Pablo Neira Ayuso (2):
      netfilter: nft_ct: keep counters away from CONFIG_NF_CONNTRACK_LABELS
      netfilter: nf_tables_netdev: fix error path in module initialization

Sasha Levin (1):
      netfilter: nf_conntrack: use safer way to lock all buckets

 include/net/netfilter/nf_conntrack_core.h  |  8 +++----
 net/netfilter/ipset/ip_set_hash_netiface.c |  4 ----
 net/netfilter/nf_conntrack_core.c          | 38 ++++++++++++++++++++++--------
 net/netfilter/nf_conntrack_helper.c        |  2 +-
 net/netfilter/nf_conntrack_netlink.c       |  2 +-
 net/netfilter/nf_tables_netdev.c           |  8 +++----
 net/netfilter/nfnetlink_cttimeout.c        |  4 ++--
 net/netfilter/nft_byteorder.c              |  6 ++---
 net/netfilter/nft_ct.c                     |  2 +-
 net/netfilter/xt_TCPMSS.c                  |  9 +++++--
 10 files changed, 49 insertions(+), 34 deletions(-)
