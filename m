From: pablo@netfilter.org
Subject: [PATCH 0/5] netfilter fixes for 3.4-rc2
Date: Tue, 10 Apr 2012 14:48:56 +0200
Message-ID: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset includes netfilter fixes for 3.4-rc2, they are:

* A couple of fixes for the IPv4 connection tracker from Jozsef. One
  to behave consistently with IPv6 and to follow the conntrack policy
  (ie. don't drop, the user controls what to do by dropping invalid
  packet via iptables). The other one checks for invalid IPv4 ihl
  values that go further the packet boundary.

* Fix missing ip6t_ext_hdr symbol if ip6tables is compiled xt_LOG
  is compiled built-in and ip6tables as module by myself.

* One fix for the error path of nf_conntrack_init_net introduced by
  the recently added nf_conntrack_timeout infrastructure from Gao Feng.

* We don't want to scale the window twice for picked up connection in
  the nf_ct_tcp code, from Changli Gao.

You can pull changes these from:

git://1984.lsi.us.es/net master

Changli Gao (1):
  netfilter: nf_ct_tcp: don't scale the size of the window up twice

Gao feng (1):
  netfilter: nf_conntrack: fix incorrect logic in nf_conntrack_init_net

Jozsef Kadlecsik (2):
  netfilter: nf_ct_ipv4: handle invalid IPv4 and IPv6 packets consistently
  netfilter: nf_ct_ipv4: packets with wrong ihl are invalid

Pablo Neira Ayuso (1):
  netfilter: ip6_tables: ip6t_ext_hdr is now static inline

 include/linux/netfilter_ipv6/ip6_tables.h      |   12 +++++++++++-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   12 ++++++++++--
 net/ipv6/netfilter/ip6_tables.c                |   14 --------------
 net/netfilter/nf_conntrack_core.c              |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |    4 ++--
 5 files changed, 24 insertions(+), 20 deletions(-)

-- 
1.7.2.5

