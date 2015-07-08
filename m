From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] Netfilter fixes for net
Date: Wed,  8 Jul 2015 11:48:13 +0200
Message-ID: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes for your net tree. This batch
mostly comes with patches to address fallout from the previous merge window
cycle, they are:

1) Use entry->state.hook_list from nf_queue() instead of the global nf_hooks
   which is not valid when used from NFPROTO_NETDEV, this should cause no
   problems though since we have no userspace queueing for that family, but
   let's fix this now for the sake of correctness. Patch from Eric W. Biederman.

2) Fix compilation breakage in bridge netfilter if CONFIG_NF_DEFRAG_IPV4 is not
   set, from Bernhard Thaler.

3) Use percpu jumpstack in arptables too, now that there's a single copy of the
   rule blob we can't store the return address there anymore. Patch from
   Florian Westphal.

4) Fix a skb leak in the xmit path of bridge netfilter, problem there since
   2.6.37 although it should be not possible to hit invalid traffic there, also
   from Florian.

5) Eric Leblond reports that when loading a large ruleset with many missing
   modules after a fresh boot, nf_tables can take long time commit it. Fix this
   by processing the full batch until the end, even on missing modules, then
   abort only once and restart processing.

6) Add bridge netfilter files to the MAINTAINER files.

7) Fix a net_device refcount leak in the new IPV6 bridge netfilter code, from
   Julien Grall.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 4da3064d1775810f10f7ddc1c34c3f1ff502a654:

  Merge tag 'devicetree-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/glikely/linux (2015-07-01 19:40:18 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 86e8971800381c3a8d8d9327f83b1f97ccb04a4f:

  netfilter: bridge: Use __in6_dev_get rather than in6_dev_get in br_validate_ipv6 (2015-07-08 11:02:16 +0200)

----------------------------------------------------------------
Bernhard Thaler (1):
      netfilter: bridge: fix CONFIG_NF_DEFRAG_IPV4/6 related warnings/errors

Eric W. Biederman (1):
      netfilter: nf_queue: Don't recompute the hook_list head

Florian Westphal (2):
      netfilter: arptables: use percpu jumpstack
      netfilter: bridge: don't leak skb in error paths

Julien Grall (1):
      netfilter: bridge: Use __in6_dev_get rather than in6_dev_get in br_validate_ipv6

Pablo Neira Ayuso (2):
      netfilter: nfnetlink: keep going batch handling on missing modules
      MAINTAINER: add bridge netfilter

 MAINTAINERS                     |    1 +
 net/bridge/br_netfilter_hooks.c |   16 +++++++++++-----
 net/bridge/br_netfilter_ipv6.c  |    2 +-
 net/ipv4/netfilter/arp_tables.c |   25 ++++++++++++++++---------
 net/netfilter/nf_queue.c        |    2 +-
 net/netfilter/nfnetlink.c       |   38 +++++++++++++++++++++++++-------------
 6 files changed, 55 insertions(+), 29 deletions(-)
