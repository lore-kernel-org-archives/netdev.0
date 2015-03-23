From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] Netfilter updates for net-next
Date: Mon, 23 Mar 2015 12:36:16 +0100
Message-ID: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for net-next.
Basically, more incremental updates for br_netfilter from Florian
Westphal, small nf_tables updates (including one fix for rb-tree
locking) and small two-liner to add extra validation for the REJECT6
target.

More specifically, they are:

1) Use the conntrack status flags from br_netfilter to know that DNAT is
   happening. Patch for Florian Westphal.

2) nf_bridge->physoutdev == NULL already indicates that the traffic is
   bridged, so let's get rid of the BRNF_BRIDGED flag. Also from Florian.

3) Another patch to prepare voidization of seq_printf/seq_puts/seq_putc,
   from Joe Perches.

4) Consolidation of nf_tables_newtable() error path.

5) Kill nf_bridge_pad used by br_netfilter from ip_fragment(),
   from Florian Westphal.

6) Access rb-tree root node inside the lock and remove unnecessary
   locking from the get path (we already hold nfnl_lock there), from
   Patrick McHardy.

7) You cannot use a NFT_SET_ELEM_INTERVAL_END when the set doesn't
   support interval, also from Patrick.

8) Enforce IP6T_F_PROTO from ip6t_REJECT to make sure the core is
   actually restricting matches to TCP.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 169bf9121b19dd6029e0a354d33513f61bfbe3d3:

  tipc: ensure that idle links are deleted when a bearer is disabled (2015-03-10 18:37:36 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to e35158e40110270600698f19bda5e21d8ce709d7:

  netfilter: ip6t_REJECT: check for IP6T_F_PROTO (2015-03-22 20:02:46 +0100)

----------------------------------------------------------------
Florian Westphal (3):
      netfilter: bridge: query conntrack about skb dnat
      netfilter: bridge: remove BRNF_STATE_BRIDGED flag
      netfilter: bridge: kill nf_bridge_pad

Joe Perches (1):
      netfilter: Remove uses of seq_<foo> return values

Pablo Neira Ayuso (2):
      netfilter: nf_tables: consolidate error path of nf_tables_newtable()
      netfilter: ip6t_REJECT: check for IP6T_F_PROTO

Patrick McHardy (2):
      netfilter: nft_rbtree: fix locking
      netfilter: nf_tables: reject NFT_SET_ELEM_INTERVAL_END flag for non-interval sets

 include/linux/netfilter_bridge.h                   |   29 ------------
 net/bridge/br_netfilter.c                          |   48 ++++++++++++++++----
 net/ipv4/ip_output.c                               |    5 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    4 +-
 net/ipv6/netfilter/ip6t_REJECT.c                   |    3 +-
 net/netfilter/nf_conntrack_acct.c                  |    8 ++--
 net/netfilter/nf_conntrack_expect.c                |    4 +-
 net/netfilter/nf_tables_api.c                      |   23 ++++++----
 net/netfilter/nfnetlink_log.c                      |   12 +++--
 net/netfilter/nft_rbtree.c                         |    6 +--
 net/netfilter/xt_physdev.c                         |    3 +-
 11 files changed, 77 insertions(+), 68 deletions(-)
