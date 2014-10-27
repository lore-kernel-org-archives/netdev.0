From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] Netfilter fixes for net
Date: Mon, 27 Oct 2014 22:37:59 +0100
Message-ID: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35961 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309AbaJ0Vge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 17:36:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Allow to recycle a TCP port in conntrack when the change role from
   server to client, from Marcelo Leitner.

2) Fix possible off by one access in ip_set_nfnl_get_byindex(), patch
   from Dan Carpenter.

3) alloc_percpu returns NULL on error, no need for IS_ERR() in nf_tables
   chain statistic updates. From Sabrina Dubroca.

4) Don't compile ip options in bridge netfilter, this mangles the packet
   and bridge should not alter layer >= 3 headers when forwarding packets.
   Patch from Herbert Xu and tested by Florian Westphal.

5) Account the final NLMSG_DONE message when calculating the size of the
   nflog netlink batches. Patch from Florian Westphal.

6) Fix a possible netlink attribute length overflow with large packets.
   Again from Florian Westphal.

7) Release the skbuff if nfnetlink_log fails to put the final
   NLMSG_DONE message. This fixes a leak on error. This shouldn't ever
   happen though, otherwise this means we miscalculate the netlink batch
   size, so spot a warning if this ever happens so we can track down the
   problem. This patch from Houcheng Lin.

8) Look at the right list when recycling targets in the nft_compat,
   patch from Arturo Borrero.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 7c1c97d54f9bfc810908d3903cb8bcacf734df18:

  net: sched: initialize bstats syncp (2014-10-21 21:45:21 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 7965ee93719921ea5978f331da653dfa2d7b99f5:

  netfilter: nft_compat: fix wrong target lookup in nft_target_select_ops() (2014-10-27 22:17:46 +0100)

----------------------------------------------------------------
Arturo Borrero (1):
      netfilter: nft_compat: fix wrong target lookup in nft_target_select_ops()

Dan Carpenter (1):
      netfilter: ipset: off by one in ip_set_nfnl_get_byindex()

Florian Westphal (2):
      netfilter: nf_log: account for size of NLMSG_DONE attribute
      netfilter: nfnetlink_log: fix maximum packet length logged to userspace

Herbert Xu (1):
      bridge: Do not compile options in br_parse_ip_options

Houcheng Lin (1):
      netfilter: nf_log: release skbuff on nlmsg put failure

Marcelo Leitner (1):
      netfilter: nf_conntrack: allow server to become a client in TW handling

Sabrina Dubroca (1):
      netfilter: nf_tables: check for NULL in nf_tables_newchain pcpu stats allocation

 net/bridge/br_netfilter.c              |   24 +++++-------------------
 net/netfilter/ipset/ip_set_core.c      |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
 net/netfilter/nf_tables_api.c          |    4 ++--
 net/netfilter/nfnetlink_log.c          |   31 ++++++++++++++++---------------
 net/netfilter/nft_compat.c             |    2 +-
 6 files changed, 27 insertions(+), 40 deletions(-)
