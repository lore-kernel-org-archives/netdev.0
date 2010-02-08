From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/05: netfilter fixes
Date: Mon,  8 Feb 2010 18:10:26 +0100 (MET)
Message-ID: <20100208171024.15522.8136.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38896 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab0BHRK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 12:10:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are the bugfixes for nf_conntrack discussed over the past
days, as well as a bugfix for the use of pointer to a local variable
outside the scope of the variable:

- a fix for use count initialization of the "untracked" conntrack,
  fixing freeing of memory in the data section

- a patch for per netns conntrack cache pointers to fix issues
  with SLAB_DESTROY_BY_RCU

- a patch to disable conntrack expect hash size modification at runtime

- a patch for xtables to fix out of scope usage of a local variable

- a patch to fix conntrack hash resizing with multiple namespaces by
  moving the hashsize into the per netns data

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Please note: I forgot to add "Cc: stable@kernel.org" to two of these
patches and manually added it to the patch files, so I'd appreciate
if you could apply the patches manually instead of pulling from the
git tree this time.

Thanks!


 include/net/netns/conntrack.h                      |    3 +
 include/net/netns/ipv4.h                           |    1 +
 net/ipv4/netfilter/arp_tables.c                    |    4 +-
 net/ipv4/netfilter/ip_tables.c                     |    4 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    2 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    4 +-
 net/ipv4/netfilter/nf_nat_core.c                   |   22 ++--
 net/ipv6/netfilter/ip6_tables.c                    |    4 +-
 net/netfilter/nf_conntrack_core.c                  |  116 +++++++++++---------
 net/netfilter/nf_conntrack_expect.c                |    4 +-
 net/netfilter/nf_conntrack_helper.c                |    2 +-
 net/netfilter/nf_conntrack_netlink.c               |    2 +-
 net/netfilter/nf_conntrack_standalone.c            |    7 +-
 13 files changed, 93 insertions(+), 82 deletions(-)

Alexey Dobriyan (2):
      netfilter: nf_conntrack: restrict runtime expect hashsize modifications
      netfilter: xtables: compat out of scope fix

Eric Dumazet (1):
      netfilter: nf_conntrack: per netns nf_conntrack_cachep

Patrick McHardy (2):
      netfilter: nf_conntrack: fix memory corruption with multiple namespaces
      netfilter: nf_conntrack: fix hash resizing with namespaces
