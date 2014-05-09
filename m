From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Fri,  9 May 2014 12:56:01 +0200
Message-ID: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40260 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbaEIK4O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 06:56:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following batch contains netfilter fixes for your net tree, they are:

1) Fix use after free in nfnetlink when sending a batch for some
   unsupported subsystem, from Denys Fedoryshchenko.

2) Skip autoload of the nat module if no binding is specified via
   ctnetlink, from Florian Westphal.

3) Set local_df after netfilter defragmentation to avoid a bogus ICMP
   fragmentation needed in the forwarding path, also from Florian.

4) Fix potential user after free in ip6_route_me_harder() when returning
   the error code to the upper layers, from Sergey Popovich.

5) Skip possible bogus ICMP time exceeded emitted from the router (not
   valid according to RFC) if conntrack zones are used, from Vasily Averin.

6) Fix fragment handling when nf_defrag_ipv4 is loaded but nf_conntrack
   is not present, also from Vasily.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 014f1b20108dc2c0bb0777d8383654a089c790f8:

  net: bonding: Fix format string mismatch in bond_sysfs.c (2014-04-28 14:48:16 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to a8951d5814e1373807a94f79f7ccec7041325470:

  netfilter: Fix potential use after free in ip6_route_me_harder() (2014-05-09 02:36:39 +0200)

----------------------------------------------------------------
Denys Fedoryshchenko (1):
      netfilter: nfnetlink: Fix use after free when it fails to process batch

Florian Westphal (2):
      netfilter: ctnetlink: don't add null bindings if no nat requested
      netfilter: ipv4: defrag: set local_df flag on defragmented skb

Sergey Popovich (1):
      netfilter: Fix potential use after free in ip6_route_me_harder()

Vasily Averin (2):
      ipv4: fix "conntrack zones" support for defrag user check in ip_expire
      bridge: superfluous skb->nfct check in br_nf_dev_queue_xmit

 net/bridge/br_netfilter.c            |    4 ++--
 net/ipv4/ip_fragment.c               |    5 +++--
 net/ipv4/netfilter/nf_defrag_ipv4.c  |    5 +++--
 net/ipv6/netfilter.c                 |    6 ++++--
 net/netfilter/nf_conntrack_netlink.c |    3 +++
 net/netfilter/nfnetlink.c            |    8 ++++----
 6 files changed, 19 insertions(+), 12 deletions(-)
