From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/29] Netfilter updates for net-next
Date: Fri, 30 Jun 2017 00:52:58 +0200
Message-ID: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57576 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752218AbdF2Wxu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:50 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B5E40BDF54
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:28 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A1F8ED1CAD
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:28 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 24AB1DA80E
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:22 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net-next
tree. This batch contains connection tracking updates for the cleanup
iteration path, patches from Florian Westphal:

X) Skip unconfirmed conntracks in nf_ct_iterate_cleanup_net(), just set
   dying bit to let the CPU release them.

X) Add nf_ct_iterate_destroy() to be used on module removal, to kill
   conntrack from all namespace.

X) Restart iteration on hashtable resizing, since both may occur at
   the same time.

X) Use the new nf_ct_iterate_destroy() to remove conntrack with NAT
   mapping on module removal.

X) Use nf_ct_iterate_destroy() to remove conntrack entries helper
   module removal, from Liping Zhang.

X) Use nf_ct_iterate_cleanup_net() to remove the timeout extension
   if user requests this, also from Liping.

X) Add net_ns_barrier() and use it from FTP helper, so make sure
   no concurrent namespace removal happens at the same time while
   the helper module is being removed.

X) Use NFPROTO_MAX in layer 3 conntrack protocol array, to reduce
   module size. Same thing in nf_tables.

Updates for the nf_tables infrastructure:

X) Prepare usage of the extended ACK reporting infrastructure for
   nf_tables.

X) Remove unnecessary forward declaration in nf_tables hash set.

X) Skip set size estimation if number of element is not specified.

X) Changes to accomodate a (faster) unresizable hash set implementation,
   for anonymous sets and dynamic size fixed sets with no timeouts.

X) Faster lookup function for unresizable hash table for 2 and 4
   bytes key.

And, finally, a bunch of asorted small updates and cleanups:

X) Do not hold reference to netdev from ipt_CLUSTER, instead subscribe
   to device events and look up for index from the packet path, this
   is fixing an issue that is present since the very beginning, patch
   from Xin Long.

X) Use nf_register_net_hook() in ipt_CLUSTER, from Florian Westphal.

X) Use ebt_invalid_target() whenever possible in the ebtables tree,
   from Gao Feng.

X) Calm down compilation warning in nf_dup infrastructure, patch from
   stephen hemminger.

X) Statify functions in nftables rt expression, also from stephen.

X) Update Makefile to use canonical method to specify nf_tables-objs.
   From Jike Song.

X) Use nf_conntrack_helpers_register() in amanda and H323.

X) Space cleanup for ctnetlink, from linzhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 417ccf6b5bc3f1a390505d5ef65ec17f10e8b29a:

  net: make struct request_sock_ops::obj_size unsigned (2017-05-23 11:13:19 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 04ba724b659c6808b0ca31528121bdb2f2807e00:

  netfilter: nfnetlink: extended ACK reporting (2017-06-19 19:38:24 +0200)

----------------------------------------------------------------
Florian Westphal (10):
      netfilter: ipt_CLUSTERIP: switch to nf_register_net_hook
      netfilter: conntrack: rename nf_ct_iterate_cleanup
      netfilter: conntrack: don't call iter for non-confirmed conntracks
      netfilter: conntrack: add nf_ct_iterate_destroy
      netfilter: conntrack: restart iteration on resize
      netfilter: nat: destroy nat mappings on module exit path only
      netfilter: move table iteration out of netns exit paths
      netns: add and use net_ns_barrier
      netfilter: conntrack: use NFPROTO_MAX to size array
      netfilter: nf_tables: reduce chain type table size

Gao Feng (1):
      netfilter: ebt: Use new helper ebt_invalid_target to check target

Jike Song (1):
      netfilter, kbuild: use canonical method to specify objs.

Liping Zhang (3):
      netfilter: nf_ct_helper: use nf_ct_iterate_destroy to unlink helper objs
      netfilter: cttimeout: use nf_ct_iterate_cleanup_net to unlink timeout objs
      netfilter: use nf_conntrack_helpers_register when possible

Pablo Neira Ayuso (10):
      netfilter: nft_set_hash: unnecessary forward declaration
      netfilter: nf_tables: no size estimation if number of set elements is unknown
      netfilter: nft_set_hash: use nft_rhash prefix for resizable set backend
      netfilter: nf_tables: select set backend flavour depending on description
      netfilter: nf_tables: pass set description to ->privsize
      netfilter: nft_set_hash: add nft_hash_buckets()
      netfilter: nf_tables: allow large allocations for new sets
      netfilter: nft_set_hash: add non-resizable hashtable implementation
      netfilter: nft_set_hash: add lookup variant for fixed size hashtable
      netfilter: nfnetlink: extended ACK reporting

Xin Long (1):
      netfilter: ipt_CLUSTERIP: do not hold dev

linzhang (1):
      netfilter: ctnetlink: delete extra spaces

stephen hemminger (2):
      netfilter: dup: resolve warnings about missing prototypes
      netfilter: nft_rt: make local functions static

 include/linux/netfilter/nfnetlink.h          |  10 +-
 include/linux/netfilter_bridge/ebtables.h    |   2 -
 include/net/net_namespace.h                  |   3 +
 include/net/netfilter/nf_conntrack.h         |  10 +-
 include/net/netfilter/nf_conntrack_l3proto.h |   4 +-
 include/net/netfilter/nf_tables.h            |  29 +-
 net/bridge/netfilter/ebt_dnat.c              |   2 +-
 net/bridge/netfilter/ebt_mark.c              |   2 +-
 net/bridge/netfilter/ebt_redirect.c          |   2 +-
 net/bridge/netfilter/ebt_snat.c              |   2 +-
 net/core/net_namespace.c                     |  17 +
 net/ipv4/netfilter/ipt_CLUSTERIP.c           | 115 +++++--
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c  |   4 +-
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c  |  10 +-
 net/netfilter/Makefile                       |   7 +-
 net/netfilter/ipset/ip_set_core.c            |  39 ++-
 net/netfilter/nf_conntrack_amanda.c          |  12 +-
 net/netfilter/nf_conntrack_core.c            | 149 +++++++--
 net/netfilter/nf_conntrack_h323_main.c       |  63 ++--
 net/netfilter/nf_conntrack_helper.c          |  50 +--
 net/netfilter/nf_conntrack_netlink.c         |  47 ++-
 net/netfilter/nf_conntrack_proto.c           |  44 ++-
 net/netfilter/nf_dup_netdev.c                |   1 +
 net/netfilter/nf_nat_core.c                  |  37 +--
 net/netfilter/nf_tables_api.c                | 137 +++++---
 net/netfilter/nfnetlink.c                    |  21 +-
 net/netfilter/nfnetlink_acct.c               |   9 +-
 net/netfilter/nfnetlink_cthelper.c           |   9 +-
 net/netfilter/nfnetlink_cttimeout.c          |  54 +--
 net/netfilter/nfnetlink_log.c                |   6 +-
 net/netfilter/nfnetlink_queue.c              |  12 +-
 net/netfilter/nft_compat.c                   |   3 +-
 net/netfilter/nft_rt.c                       |  16 +-
 net/netfilter/nft_set_bitmap.c               |  13 +-
 net/netfilter/nft_set_hash.c                 | 471 ++++++++++++++++++++-------
 net/netfilter/nft_set_rbtree.c               |  21 +-
 net/netfilter/xt_osf.c                       |   6 +-
 37 files changed, 945 insertions(+), 494 deletions(-)
