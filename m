From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter fixes for net
Date: Sat, 16 May 2015 20:47:14 +0200
Message-ID: <1431802038-4502-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42824 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbbEPSmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 May 2015 14:42:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree, they are:

1) Fix a leak in IPVS, the sysctl table is not released accordingly when
   destroying a netns, patch from Tommi Rantala.

2) Fix a build error when TPROXY and socket are built-in but IPv6 defrag is
   compiled as module, from Florian Westphal.

3) Fix TCP tracket wrt. RFC5961 challenge ACK when in LAST_ACK state, patch
   from Jesper Dangaard Brouer.

4) Fix a bogus WARN_ON() in nf_tables when deleting a set element that stores
   a map, from Mirek Kratochvil.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 39376ccb1968ba9f83e2a880a8bf02ad5dea44e1:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2015-04-27 23:12:34 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 960bd2c26421d321e890f1936938196ead41976f:

  netfilter: nf_tables: fix bogus warning in nft_data_uninit() (2015-05-15 22:07:30 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: avoid build error if TPROXY/SOCKET=y && NF_DEFRAG_IPV6=m

Jesper Dangaard Brouer (1):
      conntrack: RFC5961 challenge ACK confuse conntrack LAST-ACK transition

Mirek Kratochvil (1):
      netfilter: nf_tables: fix bogus warning in nft_data_uninit()

Tommi Rantala (1):
      ipvs: fix memory leak in ip_vs_ctl.c

 include/uapi/linux/netfilter/nf_conntrack_tcp.h |    3 ++
 net/netfilter/Kconfig                           |    2 ++
 net/netfilter/ipvs/ip_vs_ctl.c                  |    3 ++
 net/netfilter/nf_conntrack_proto_tcp.c          |   35 +++++++++++++++++++++--
 net/netfilter/nf_tables_api.c                   |    4 +--
 5 files changed, 42 insertions(+), 5 deletions(-)
