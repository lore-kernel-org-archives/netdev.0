From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] netfilter fixes for net
Date: Wed, 18 Sep 2013 00:21:59 +0200
Message-ID: <1379456519-4317-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resending pull request email, previous one was missing the pull request
information itself, sorry.

--

Hi David,

The following patchset contains Netfilter fixes for you net tree,
mostly targeted to ipset, they are:

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

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit c19d65c95c6d472d69829fea7d473228493d=
5245:

  bnx2x: Fix configuration of doorbell block (2013-09-09 17:06:14 -0400=
)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 0a0d80eb39aa465b7bdf6f7754d0ba687eb3d2a7=
:

  netfilter: nfnetlink_queue: use network skb for sequence adjustment (=
2013-09-17 13:05:12 +0200)

----------------------------------------------------------------
Gao feng (1):
      netfilter: nfnetlink_queue: use network skb for sequence adjustme=
nt

Jozsef Kadlecsik (3):
      netfilter: ipset: Skip really non-first fragments for IPv6 when g=
etting port/protocol
      netfilter: ipset: Consistent userspace testing with nomatch flag
      netfilter: ipset: Validate the set family and not the set type fa=
mily at swapping

Michal Kube=C4=8Dek (1):
      netfilter: nf_conntrack: use RCU safe kfree for conntrack extensi=
ons

Oliver Smith (1):
      netfilter: ipset: Fix serious failure in CIDR tracking

Phil Oester (1):
      netfilter: nf_nat_proto_icmpv6:: fix wrong comparison in icmpv6_m=
anip_pkt

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

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
