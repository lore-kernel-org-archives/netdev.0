From: pablo@netfilter.org
Subject: [PATCH 0/5] netfilter updates for net (3.4) tree
Date: Fri, 23 Mar 2012 10:34:12 +0100
Message-ID: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following are five fixes for xt_LOG and the cttimeout
infrastructure that got into your tree in the previous development
cycle. This contains:

* One fix for missing symbol in xt_LOG reported by Randy Dunlap.

* Fix module dependency between cttimeout and nf_conntrack_proto_*
  friends from me. Now, we make sure that protocol trackers modules
  cannot be unloaded if there's any cttimeout object refering to
  them.

* Fix missing rcu_read_lock section in xt_CT while dereferencing
  a RCU pointer.

* Fix the assignation of a custom timeout policy for the generic
  protocol tracker.

* Fix possible inconsistencies in the application of the cttimeout
  policy by permanently attaching it to the conntrack entry. Before
  this patch, the timeout policy was attached per packet which may
  result in applying the timeout policy only in one traffic
  direction.

You can pull this changes from:

git://1984.lsi.us.es/net master

Thanks!

Pablo Neira Ayuso (5):
  netfilter: xt_LOG: use CONFIG_IP6_NF_IPTABLES instead of CONFIG_IPV6
  netfilter: cttimeout: fix dependency with l4protocol conntrack module
  netfilter: xt_CT: missing rcu_read_lock section in timeout assignment
  netfilter: xt_CT: fix assignation of the generic protocol tracker
  netfilter: nf_conntrack: permanently attach timeout policy to conntrack

 include/net/netfilter/nf_conntrack_l4proto.h |    4 ++
 include/net/netfilter/nf_conntrack_timeout.h |    2 +-
 net/netfilter/nf_conntrack_core.c            |   39 ++++++++++++----------
 net/netfilter/nf_conntrack_proto.c           |   21 ++++++++++++
 net/netfilter/nfnetlink_cttimeout.c          |   45 +++++++++++++------------
 net/netfilter/xt_CT.c                        |   31 +++++++++++++----
 net/netfilter/xt_LOG.c                       |   12 +++---
 7 files changed, 100 insertions(+), 54 deletions(-)

-- 
1.7.2.5

