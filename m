From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next 0/3] Compact netfilter hooks list
Date: Thu, 30 Jun 2016 17:19:32 -0400
Message-ID: <1467321575-6107-1-git-send-email-aconole@bytheb.org>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series makes a simple change to shrink the netfilter hook list
from a double linked list, to a singly linked list.  Since the hooks
are always traversed in-order, there is no need to maintain a previous
pointer.

This series is being submitted for early feedback. This was jointly
developed by Florian Westphal.

Aaron Conole (1):
  netfilter: replace list_head with single linked list

Florian Westphal (2):
  netfilter: bridge: add and use br_nf_hook_thresh
  netfilter: call nf_hook_state_init with rcu_read_lock held

 include/linux/netdevice.h                      |   2 +-
 include/linux/netfilter.h                      |  26 ++++--
 include/linux/netfilter_ingress.h              |  15 ++--
 include/net/netfilter/br_netfilter.h           |   6 ++
 include/net/netfilter/nf_queue.h               |   9 +-
 include/net/netns/netfilter.h                  |   2 +-
 net/bridge/br_netfilter_hooks.c                |  50 +++++++++--
 net/bridge/br_netfilter_ipv6.c                 |  12 ++-
 net/bridge/netfilter/ebt_redirect.c            |   2 +-
 net/bridge/netfilter/ebtables.c                |   2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   2 +-
 net/netfilter/core.c                           | 120 +++++++++++++++----------
 net/netfilter/nf_conntrack_core.c              |   2 +-
 net/netfilter/nf_conntrack_h323_main.c         |   2 +-
 net/netfilter/nf_conntrack_helper.c            |   2 +-
 net/netfilter/nf_internals.h                   |  10 +--
 net/netfilter/nf_queue.c                       |  15 ++--
 net/netfilter/nfnetlink_cthelper.c             |   2 +-
 net/netfilter/nfnetlink_log.c                  |   8 +-
 net/netfilter/nfnetlink_queue.c                |   7 +-
 net/netfilter/xt_helper.c                      |   2 +-
 24 files changed, 193 insertions(+), 111 deletions(-)

-- 
2.5.5

