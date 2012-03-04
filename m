From: pablo@netfilter.org
Subject: [PATCH 0/7] [RFC] cttimeout v2
Date: Sun,  4 Mar 2012 12:27:51 +0100
Message-ID: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi,

The following patchset contains the cttimeout infrastructure. It
allows you to define fine-grain timeout policies for the conntrack
system. So far, only global timeouts could be set:

1) create the timeout policy:

 nfct timeout add tcp-policy0 inet tcp \
    established 1000 close 10 time_wait 10 last_ack 10

2) attach the timeout policy to the packet:

 iptables -I PREROUTING -t raw -p tcp -j CT --timeout tcp-policy0

You have to install the following user-space software:

a) libnetfilter_cttimeout:
   git://git.netfilter.org/libnetfilter_cttimeout

b) nfct:
   git://git.netfilter.org/nfct

You also have to get iptables with -j CT --timeout support. See the
cttimeout2 branch at git://git.netfilter.org/iptables.

Pablo Neira Ayuso (7):
  netfilter: nf_ct_udp[lite]: convert UDP[lite] timeouts to array
  netfilter: nf_ct_tcp: move retransmission and unacknowledged timeout
    to array
  netfilter: nf_ct_gre: add unsigned int array to define timeouts
  netfilter: nf_conntrack: pass timeout array to l4->new and l4->packet
  netfilter: add cttimeout infrastructure for fine timeout tuning
  netfilter: nf_ct_ext: add timeout extension
  netfilter: xt_CT: allow to attach timeout policy + glue code

 include/linux/netfilter/Kbuild                 |    1 +
 include/linux/netfilter/nf_conntrack_tcp.h     |    5 +-
 include/linux/netfilter/nfnetlink.h            |    3 +-
 include/linux/netfilter/nfnetlink_cttimeout.h  |  114 +++++++
 include/linux/netfilter/xt_CT.h                |   12 +
 include/net/netfilter/nf_conntrack_extend.h    |    4 +
 include/net/netfilter/nf_conntrack_l4proto.h   |   19 +-
 include/net/netfilter/nf_conntrack_timeout.h   |   78 +++++
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   60 ++++-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   60 ++++-
 net/netfilter/Kconfig                          |   21 ++
 net/netfilter/Makefile                         |    2 +
 net/netfilter/nf_conntrack_core.c              |   34 ++-
 net/netfilter/nf_conntrack_proto_dccp.c        |   86 +++++-
 net/netfilter/nf_conntrack_proto_generic.c     |   77 ++++-
 net/netfilter/nf_conntrack_proto_gre.c         |   82 +++++-
 net/netfilter/nf_conntrack_proto_sctp.c        |   83 +++++-
 net/netfilter/nf_conntrack_proto_tcp.c         |  168 +++++++++-
 net/netfilter/nf_conntrack_proto_udp.c         |  106 ++++++-
 net/netfilter/nf_conntrack_proto_udplite.c     |  103 ++++++-
 net/netfilter/nf_conntrack_timeout.c           |   60 ++++
 net/netfilter/nfnetlink_cttimeout.c            |  419 ++++++++++++++++++++++++
 net/netfilter/xt_CT.c                          |  220 ++++++++++++-
 23 files changed, 1722 insertions(+), 95 deletions(-)
 create mode 100644 include/linux/netfilter/nfnetlink_cttimeout.h
 create mode 100644 include/net/netfilter/nf_conntrack_timeout.h
 create mode 100644 net/netfilter/nf_conntrack_timeout.c
 create mode 100644 net/netfilter/nfnetlink_cttimeout.c

-- 
1.7.7.3

