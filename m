From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter fixes for net
Date: Fri, 22 May 2015 12:34:03 +0200
Message-ID: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38957 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161013AbbEVK3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 06:29:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contain Netfilter fixes for your net tree, they are:

1) Fix a race in nfnetlink_log and nfnetlink_queue that can lead to a crash.
   This problem is due to wrong order in the per-net registration and netlink
   socket events. Patch from Francesco Ruggeri.

2) Make sure that counters that userspace pass us are higher than 0 in all the
   x_tables frontends. Discovered via Trinity, patch from Dave Jones.

3) Revert a patch for br_netfilter to rely on the conntrack status bits. This
   breaks stateless IPv6 NAT transformations. Patch from Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 13c3ed6a92724d8c8cb148a14b0ae190ddfe7413:

  vxlan: correct typo in call to unregister_netdevice_queue (2015-05-18 16:57:09 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to faecbb45ebefb20260ad4a631e011e93c896cb73:

  Revert "netfilter: bridge: query conntrack about skb dnat" (2015-05-20 13:51:25 +0200)

----------------------------------------------------------------
Dave Jones (1):
      netfilter: ensure number of counters is >0 in do_replace()

Florian Westphal (1):
      Revert "netfilter: bridge: query conntrack about skb dnat"

Francesco Ruggeri (1):
      netfilter: nfnetlink_{log,queue}: Register pernet in first place

 include/linux/skbuff.h               |    1 +
 net/bridge/br_netfilter.c            |   27 +++++++++------------------
 net/bridge/netfilter/ebtables.c      |    4 ++++
 net/ipv4/netfilter/arp_tables.c      |    6 ++++++
 net/ipv4/netfilter/ip_tables.c       |    6 ++++++
 net/ipv6/netfilter/ip6_tables.c      |    6 ++++++
 net/netfilter/nfnetlink_log.c        |   19 ++++++++++---------
 net/netfilter/nfnetlink_queue_core.c |   18 +++++++++---------
 8 files changed, 51 insertions(+), 36 deletions(-)
