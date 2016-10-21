From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/13] Netfilter fixes for net
Date: Fri, 21 Oct 2016 12:12:10 +0200
Message-ID: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Fix compilation warning in xt_hashlimit on m68k 32-bits, from
   Geert Uytterhoeven.

2) Fix wrong timeout in set elements added from packet path via
   nft_dynset, from Anders K. Pedersen.

3) Remove obsolete nf_conntrack_events_retry_timeout sysctl
   documentation, from Nicolas Dichtel.

4) Ensure proper initialization of log flags via xt_LOG, from
   Liping Zhang.

5) Missing alias to autoload ipcomp, also from Liping Zhang.

6) Missing NFTA_HASH_OFFSET attribute validation, again from Liping.

7) Wrong integer type in the new nft_parse_u32_check() function,
   from Dan Carpenter.

8) Another wrong integer type declaration in nft_exthdr_init, also
   from Dan Carpenter.

9) Fix insufficient mode validation in nft_range.

10) Fix compilation warning in nft_range due to possible uninitialized
    value, from Arnd Bergmann.

11) Zero nf_hook_ops allocated via xt_hook_alloc() in x_tables to
    calm down kmemcheck, from Florian Westphal.

12) Schedule gc_worker() to run again if GC_MAX_EVICTS quota is reached,
    from Nicolas Dichtel.

13) Fix nf_queue() after conversion to single-linked hook list, related
    to incorrect bypass flag handling and incorrect hook point of
    reinjection.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 6d3a4c404648e415e7d96e285d723936d4df7ed0:

  strparser: Propagate correct error code in strp_recv() (2016-10-12 01:51:49 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 7034b566a4e7d550621c2dfafd380b77b3787cd9:

  netfilter: fix nf_queue handling (2016-10-20 19:59:59 +0200)

----------------------------------------------------------------
Anders K. Pedersen (1):
      netfilter: nft_dynset: fix element timeout for HZ != 1000

Arnd Bergmann (1):
      netfilter: nf_tables: avoid uninitialized variable warning

Dan Carpenter (2):
      netfilter: nf_tables: underflow in nft_parse_u32_check()
      netfilter: nft_exthdr: fix error handling in nft_exthdr_init()

Florian Westphal (1):
      netfilter: x_tables: suppress kmemcheck warning

Geert Uytterhoeven (1):
      netfilter: xt_hashlimit: Add missing ULL suffixes for 64-bit constants

Liping Zhang (3):
      netfilter: xt_NFLOG: fix unexpected truncated packet
      netfilter: xt_ipcomp: add "ip[6]t_ipcomp" module alias name
      netfilter: nft_hash: add missing NFTA_HASH_OFFSET's nla_policy

Nicolas Dichtel (2):
      netfilter: conntrack: remove obsolete sysctl (nf_conntrack_events_retry_timeout)
      netfilter: conntrack: restart gc immediately if GC_MAX_EVICTS is reached

Pablo Neira Ayuso (2):
      netfilter: nft_range: validate operation netlink attribute
      netfilter: fix nf_queue handling

 Documentation/networking/nf_conntrack-sysctl.txt | 18 ---------
 net/netfilter/core.c                             | 13 ++-----
 net/netfilter/nf_conntrack_core.c                |  2 +-
 net/netfilter/nf_internals.h                     |  2 +-
 net/netfilter/nf_queue.c                         | 48 ++++++++++++++++--------
 net/netfilter/nf_tables_api.c                    |  2 +-
 net/netfilter/nft_dynset.c                       |  6 ++-
 net/netfilter/nft_exthdr.c                       |  3 +-
 net/netfilter/nft_hash.c                         |  1 +
 net/netfilter/nft_range.c                        | 26 +++++++++----
 net/netfilter/x_tables.c                         |  2 +-
 net/netfilter/xt_NFLOG.c                         |  1 +
 net/netfilter/xt_hashlimit.c                     |  4 +-
 net/netfilter/xt_ipcomp.c                        |  2 +
 14 files changed, 70 insertions(+), 60 deletions(-)
