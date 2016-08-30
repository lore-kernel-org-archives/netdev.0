From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] Netfilter fixes for net
Date: Tue, 30 Aug 2016 13:26:16 +0200
Message-ID: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Allow nf_tables reject expression from input, forward and output hooks,
   since only there the routing information is available, otherwise we crash.

2) Fix unsafe list iteration when flushing timeout and accouting objects.

3) Fix refcount leak on timeout policy parsing failure.

4) Unlink timeout object for unconfirmed conntracks too

5) Missing validation of pkttype mangling from bridge family.

6) Fix refcount leak on ebtables on second lookup for the specific
   bridge match extension, this patch from Sabrina Dubroca.

7) Remove unnecessary ip_hdr() in nf_tables_netdev family.

Patches from 1-5 and 7 from Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 51af96b53469f3b8cfcfe0504d0ff87239175b78:

  mlxsw: router: Enable neighbors to be created on stacked devices (2016-08-24 09:39:04 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to c73c2484901139c28383b58eabcbf4d613e91518:

  netfilter: nf_tables_netdev: remove redundant ip_hdr assignment (2016-08-30 11:41:04 +0200)

----------------------------------------------------------------
Liping Zhang (6):
      netfilter: nft_reject: restrict to INPUT/FORWARD/OUTPUT
      netfilter: nfnetlink: use list_for_each_entry_safe to delete all objects
      netfilter: cttimeout: put back l4proto when replacing timeout policy
      netfilter: cttimeout: unlink timeout objs in the unconfirmed ct lists
      netfilter: nft_meta: improve the validity check of pkttype set expr
      netfilter: nf_tables_netdev: remove redundant ip_hdr assignment

Sabrina Dubroca (1):
      netfilter: ebtables: put module reference when an incorrect extension is found

 include/net/netfilter/nft_meta.h       |  4 +++
 include/net/netfilter/nft_reject.h     |  4 +++
 net/bridge/netfilter/ebtables.c        |  2 ++
 net/bridge/netfilter/nft_meta_bridge.c |  1 +
 net/ipv4/netfilter/nft_reject_ipv4.c   |  1 +
 net/ipv6/netfilter/nft_reject_ipv6.c   |  1 +
 net/netfilter/nf_tables_netdev.c       |  1 -
 net/netfilter/nfnetlink_acct.c         |  6 ++---
 net/netfilter/nfnetlink_cttimeout.c    | 49 +++++++++++++++++++---------------
 net/netfilter/nft_meta.c               | 17 +++++++++---
 net/netfilter/nft_reject.c             | 16 +++++++++++
 net/netfilter/nft_reject_inet.c        |  7 ++++-
 12 files changed, 79 insertions(+), 30 deletions(-)
