From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/4] netlink: access functions for IP address attributes
Date: Sun, 29 Mar 2015 16:59:22 +0200
Message-ID: <cover.1427639592.git.jbenc@redhat.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Chapman <jchapman@katalix.com>,
	Paul Moore <paul@paul-moore.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458AbbC2PAC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 11:00:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many places that read or write IP addresses to netlink attributes.
With IPv6 addresses, every such place currently has to use generic nla_put
and nla_memcpy. Implementing IPv6 address access functions simplify things
and makes the code more intelligible. IPv4 address access functions has
lesser value but it would be better to be consistent between IPv6 and IPv4
and they still serve as documentation.

The conversion is straightforward and the resulting patches are not that
large, thus I kept all the changes in the patches that introduce the access
functions. If anyone prefers to split the definition of access functions and
the conversion and/or break it out by network protocols, please let me know.

While doing the conversion, I came across ugly typecasting in
inetpeer_addr_base and xfrm_address_t when dealing with IPv6 addresses.
Instead of introducing more of this, I cleaned it up. Those are the first
two patches, serving as a prerequisite to the latter two.

Jiri Benc (4):
  tcp: simplify inetpeer_addr_base use
  xfrm: simplify xfrm_address_t use
  netlink: implement nla_put_in_addr and nla_put_in6_addr
  netlink: implement nla_get_in_addr and nla_get_in6_addr

 drivers/net/vxlan.c                            | 38 ++++++++++----------
 include/linux/netfilter/ipset/ip_set.h         |  5 ++-
 include/net/inetpeer.h                         |  3 +-
 include/net/netlink.h                          | 50 ++++++++++++++++++++++++++
 include/net/xfrm.h                             |  6 ++--
 include/uapi/linux/xfrm.h                      |  2 ++
 net/ipv4/devinet.c                             | 16 ++++-----
 net/ipv4/fib_rules.c                           | 12 +++----
 net/ipv4/fib_semantics.c                       | 12 +++----
 net/ipv4/ip_gre.c                              |  8 ++---
 net/ipv4/ip_vti.c                              |  8 ++---
 net/ipv4/ipip.c                                |  8 ++---
 net/ipv4/ipmr.c                                |  4 +--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  8 ++---
 net/ipv4/route.c                               | 12 +++----
 net/ipv4/tcp_metrics.c                         | 42 ++++++++++------------
 net/ipv6/addrconf.c                            | 10 +++---
 net/ipv6/addrlabel.c                           |  2 +-
 net/ipv6/fib6_rules.c                          | 12 +++----
 net/ipv6/ip6_gre.c                             | 10 +++---
 net/ipv6/ip6_tunnel.c                          | 12 +++----
 net/ipv6/ip6_vti.c                             | 12 +++----
 net/ipv6/ip6mr.c                               |  4 +--
 net/ipv6/ndisc.c                               |  3 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 12 +++----
 net/ipv6/route.c                               | 20 +++++------
 net/ipv6/sit.c                                 | 15 ++++----
 net/ipv6/xfrm6_mode_beet.c                     |  4 +--
 net/ipv6/xfrm6_policy.c                        |  4 +--
 net/key/af_key.c                               |  2 +-
 net/l2tp/l2tp_netlink.c                        | 18 +++++-----
 net/netlabel/netlabel_mgmt.c                   | 20 +++++------
 net/netlabel/netlabel_unlabeled.c              | 28 +++++++--------
 net/openvswitch/flow_netlink.c                 | 10 +++---
 net/wireless/nl80211.c                         |  8 ++---
 net/xfrm/xfrm_state.c                          |  8 ++---
 36 files changed, 234 insertions(+), 214 deletions(-)

-- 
1.8.3.1
