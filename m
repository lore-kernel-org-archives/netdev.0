From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] netfilter fixes for net
Date: Wed, 18 Sep 2013 00:07:27 +0200
Message-ID: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34798 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab3IQWIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 18:08:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for you net tree,
they are:

* Fix ICMPv6 NAT due to wrong comparison, code instead of type, from
  Phil Oester.

* Fix RCU race in conntrack extensions release path, from Michal Kubece=
k.

* Fix missing inversion in the userspace ipset test command match if
  the nomatch option is specified, from Jozsef Kadlecsik.

* Skip layer 4 protocol matching in ipset in case of IPv6 fragments,
  also from Jozsef Kadlecsik.

* Fix sequence adjustment in nfnetlink_queue due to using the netlink
  skb instead of the network skb, from Gao feng.

* Make sure we cannot swap of sets with different layer 3 family in
  ipset, from Jozsef Kadlecsik.

* Fix possible bogus matching in ipset if hash sets with net elements
  are used, from Oliver Smith.

Gao feng (1):
  netfilter: nfnetlink_queue: use network skb for sequence adjustment

Jozsef Kadlecsik (3):
  netfilter: ipset: Skip really non-first fragments for IPv6 when getti=
ng port/protocol
  netfilter: ipset: Consistent userspace testing with nomatch flag
  netfilter: ipset: Validate the set family and not the set type family=
 at swapping

Michal Kube=C4=8Dek (1):
  netfilter: nf_conntrack: use RCU safe kfree for conntrack extensions

Oliver Smith (1):
  netfilter: ipset: Fix serious failure in CIDR tracking

Phil Oester (1):
  netfilter: nf_nat_proto_icmpv6:: fix wrong comparison in icmpv6_manip=
_pkt

 include/linux/netfilter/ipset/ip_set.h      |    6 ++++--
 include/net/netfilter/nf_conntrack_extend.h |    2 +-
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c    |    4 ++--
 net/netfilter/ipset/ip_set_core.c           |    5 ++---
 net/netfilter/ipset/ip_set_getport.c        |    4 ++--
 net/netfilter/ipset/ip_set_hash_gen.h       |   28 +++++++++++++++----=
--------
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    4 ++--
 net/netfilter/ipset/ip_set_hash_net.c       |    4 ++--
 net/netfilter/ipset/ip_set_hash_netiface.c  |    4 ++--
 net/netfilter/ipset/ip_set_hash_netport.c   |    4 ++--
 net/netfilter/nfnetlink_queue_core.c        |    2 +-
 11 files changed, 36 insertions(+), 31 deletions(-)

--=20
1.7.10.4
