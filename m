From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v2 0/3] Compact netfilter hooks list
Date: Tue, 12 Jul 2016 11:32:18 -0400
Message-ID: <1468337541-23930-1-git-send-email-aconole@bytheb.org>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34542 "EHLO
	mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030313AbcGLPca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 11:32:30 -0400
Received: by mail-qt0-f193.google.com with SMTP id c52so677258qte.1
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 08:32:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series makes a simple change to shrink the netfilter hook list
from a double linked list, to a singly linked list.  Since the hooks
are always traversed in-order, there is no need to maintain a previous
pointer.

This was jointly developed by Florian Westphal.

It has been tested with RCU and lockdep debugging enabled.

Aaron Conole (2):
  netfilter: bridge: add and use br_nf_hook_thresh
  netfilter: replace list_head with single linked list

Florian Westphal (1):
  netfilter: call nf_hook_state_init with rcu_read_lock held

 include/linux/netdevice.h                      |   2 +-
 include/linux/netfilter.h                      |  26 +++--
 include/linux/netfilter_ingress.h              |  15 ++-
 include/net/netfilter/br_netfilter.h           |   6 ++
 include/net/netfilter/nf_queue.h               |   9 +-
 include/net/netns/netfilter.h                  |   2 +-
 net/bridge/br_netfilter_hooks.c                |  50 ++++++++--
 net/bridge/br_netfilter_ipv6.c                 |  12 +--
 net/bridge/netfilter/ebt_redirect.c            |   2 +-
 net/bridge/netfilter/ebtables.c                |   2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   2 +-
 net/netfilter/core.c                           | 132 ++++++++++++++++---------
 net/netfilter/nf_conntrack_core.c              |   2 +-
 net/netfilter/nf_conntrack_h323_main.c         |   2 +-
 net/netfilter/nf_conntrack_helper.c            |   2 +-
 net/netfilter/nf_internals.h                   |  10 +-
 net/netfilter/nf_queue.c                       |  15 ++-
 net/netfilter/nfnetlink_cthelper.c             |   2 +-
 net/netfilter/nfnetlink_log.c                  |   8 +-
 net/netfilter/nfnetlink_queue.c                |   7 +-
 net/netfilter/xt_helper.c                      |   2 +-
 24 files changed, 202 insertions(+), 114 deletions(-)

-- 
2.5.5
