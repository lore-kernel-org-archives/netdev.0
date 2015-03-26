From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/15] Netfilter updates for net-next
Date: Thu, 26 Mar 2015 13:06:47 +0100
Message-ID: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next tree.
Basically, nf_tables updates to add the set extension infrastructure and finish
the transaction for sets from Patrick McHardy. More specifically, they are:

1) Move netns to basechain and use recently added possible_net_t, from
   Patrick McHardy.

2) Use LOGLEVEL_<FOO> from nf_log infrastructure, from Joe Perches.

3) Restore nf_log_trace that was accidentally removed during conflict
   resolution.

4) nft_queue does not depend on NETFILTER_XTABLES, starting from here
   all patches from Patrick McHardy.

5) Use raw_smp_processor_id() in nft_meta.

Then, several patches to prepare ground for the new set extension
infrastructure:

6) Pass object length to the hash callback in rhashtable as needed by
   the new set extension infrastructure.

7) Cleanup patch to restore struct nft_hash as wrapper for struct
   rhashtable

8) Another small source code readability cleanup for nft_hash.

9) Convert nft_hash to rhashtable callbacks.

And finally...

10) Add the new set extension infrastructure.

11) Convert the nft_hash and nft_rbtree sets to use it.

12) Batch set element release to avoid several RCU grace period in a row
    and add new function nft_set_elem_destroy() to consolidate set element
    release.

13) Return the set extension data area from nft_lookup.

14) Refactor existing transaction code to add some helper functions
    and document it.

15) Complete the set transaction support, using similar approach to what we
    already use, to activate/deactivate elements in an atomic fashion.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 0144a81cccf7532bead90f0542f517bd028d3b3c:

  tcp: fix ipv4 mapped request socks (2015-03-25 00:57:48 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to cc02e457bb86f7b6ffee3651bab22d104b60effb:

  netfilter: nf_tables: implement set transaction support (2015-03-26 11:09:35 +0100)

----------------------------------------------------------------
Joe Perches (1):
      netfilter: Use LOGLEVEL_<FOO> defines

Pablo Neira Ayuso (1):
      netfilter: nf_tables: restore nf_log_trace() in nf_tables_core.c

Patrick McHardy (13):
      netfilter: nf_tables: move struct net pointer to base chain
      netfilter: nf_tables: nft_queue does not depend on x_tables
      netfilter: nft_meta: use raw_smp_processor_id()
      rhashtable: provide len to obj_hashfn
      netfilter: nft_hash: restore struct nft_hash
      netfilter: nft_hash: indent rhashtable parameters
      netfilter: nft_hash: convert to use rhashtable callbacks
      netfilter: nf_tables: add set extensions
      netfilter: nf_tables: convert hash and rbtree to set extensions
      netfilter: nf_tables: consolide set element destruction
      netfilter: nf_tables: return set extensions from ->lookup()
      netfilter: nf_tables: add transaction helper functions
      netfilter: nf_tables: implement set transaction support

 include/linux/rhashtable.h        |    6 +-
 include/net/netfilter/nf_tables.h |  190 ++++++++++++++++++++++++++++++++---
 lib/rhashtable.c                  |    2 +-
 net/ipv4/netfilter/nf_log_arp.c   |    4 +-
 net/ipv4/netfilter/nf_log_ipv4.c  |    4 +-
 net/ipv6/netfilter/ip6_tables.c   |    5 +-
 net/ipv6/netfilter/nf_log_ipv6.c  |    4 +-
 net/netfilter/Kconfig             |    1 -
 net/netfilter/nf_tables_api.c     |  199 ++++++++++++++++++++++++++-----------
 net/netfilter/nf_tables_core.c    |   18 ++--
 net/netfilter/nft_hash.c          |  183 +++++++++++++++++++---------------
 net/netfilter/nft_log.c           |    2 +-
 net/netfilter/nft_lookup.c        |    6 +-
 net/netfilter/nft_meta.c          |    2 +-
 net/netfilter/nft_rbtree.c        |  123 +++++++++++------------
 net/netlink/af_netlink.c          |    2 +-
 16 files changed, 513 insertions(+), 238 deletions(-)
