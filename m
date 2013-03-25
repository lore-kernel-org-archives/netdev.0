From: pablo@netfilter.org
Subject: [PATCH 00/12] Netfilter updates for net-next
Date: Mon, 25 Mar 2013 13:15:40 +0100
Message-ID: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains Netfilter/IPVS updates for
your net-next tree, they are:

* Better performance in nfnetlink_queue by avoiding copy from the
  packet to netlink message, from Eric Dumazet.

* Remove unnecessary locking in the exit path of ebt_ulog, from Gao Feng.

* Use new function ipv6_iface_scope_id in nf_ct_ipv6, from Hannes Frederic Sowa.

* A couple of sparse fixes for IPVS, from Julian Anastasov.

* Use xor hashing in nfnetlink_queue, as suggested by Eric Dumazet, from
  myself.

* Allow to dump expectations per master conntrack via ctnetlink, from myself.

* A couple of cleanups to use PTR_RET in module init path, from Silviu-Mihai
  Popescu.

* Remove nf_conntrack module a bit faster if netns are in use, from
  Vladimir Davydov.

* Use checksum_partial in ip6t_NPT, from YOSHIFUJI Hideaki.

* Sparse fix for nf_conntrack, from Stephen Hemminger.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Eric Dumazet (1):
  netfilter: nfnetlink_queue: zero copy support

Gao feng (1):
  netfilter: ebt_ulog: remove unnecessary spin lock protection

Hannes Frederic Sowa (1):
  netfilter: nf_ct_ipv6: use ipv6_iface_scope_id in conntrack to return scope id

Julian Anastasov (2):
  ipvs: fix hashing in ip_vs_svc_hashkey
  ipvs: fix some sparse warnings

Pablo Neira Ayuso (2):
  netfilter: nfnetlink_queue: use xor hash function to distribute instances
  netfilter: ctnetlink: allow to dump expectation per master conntrack

Silviu-Mihai Popescu (2):
  ipv4: netfilter: use PTR_RET instead of IS_ERR + PTR_ERR
  bridge: netfilter: use PTR_RET instead of IS_ERR + PTR_ERR

Vladimir Davydov (1):
  netfilter: nf_conntrack: speed up module removal path if netns in use

YOSHIFUJI Hideaki (1):
  netfilter: ip6t_NPT: Use csum_partial()

stephen hemminger (1):
  netfilter: nf_conntrack: add include to fix sparse warning

 include/net/ip_vs.h                            |    2 +-
 include/net/netfilter/nf_conntrack_core.h      |    1 +
 net/bridge/netfilter/ebt_ulog.c                |    3 +-
 net/bridge/netfilter/ebtable_broute.c          |    4 +-
 net/ipv4/netfilter/arptable_filter.c           |    4 +-
 net/ipv6/netfilter/ip6t_NPT.c                  |   11 +--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    8 +-
 net/netfilter/ipvs/ip_vs_core.c                |    8 +-
 net/netfilter/ipvs/ip_vs_ctl.c                 |    8 +-
 net/netfilter/ipvs/ip_vs_est.c                 |    2 +-
 net/netfilter/nf_conntrack_core.c              |   47 +++++++----
 net/netfilter/nf_conntrack_netlink.c           |  100 ++++++++++++++++++++++--
 net/netfilter/nf_conntrack_standalone.c        |   16 ++--
 net/netfilter/nfnetlink_queue_core.c           |   96 +++++++++++++++++------
 14 files changed, 228 insertions(+), 82 deletions(-)

-- 
1.7.10.4

