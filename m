From: pablo@netfilter.org
Subject: [PATCH 00/23] netfilter updates for net-next
Date: Thu,  8 Mar 2012 02:00:49 +0100
Message-ID: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains netfilter updates for net-next:

* Updates for ipset from Jozsef Kadlecsik and Jan Engelhardt.
* Enhancements for ctnetlink expectation support from myself.
* The new cttimeout infrastructure for fine-grain timeout for
  the connection tracking system.
* Merge of ipt_LOG and ip6t_LOG to xt_LOG from Richard Weinberger.
* A couple of cleanups for nf_ct_ecache from Tony Zelenoff.

I know, I took too long to send them, let me know if there's
some chance to get them in.

You can pull them from:

git://1984.lsi.us.es/net-next master

Thanks.

Eric Dumazet (1):
  netfilter: xt_LOG: add __printf() to sb_add()

Hans Schillstrom (1):
  netfilter: ctnetlink: fix lockep splats

Jan Engelhardt (2):
  netfilter: ipset: use NFPROTO_ constants
  netfilter: ipset: expose userspace-relevant parts in ip_set.h

Jozsef Kadlecsik (3):
  netfilter: ipset: Log warning when a hash type of set gets full
  netfilter: ipset: Exceptions support added to hash:*net* types
  netfilter: ipset: hash:net,iface timeout bug fixed

Pablo Neira Ayuso (11):
  netfilter: ctnetlink: allow to set helper for new expectations
  netfilter: ctnetlink: allow to set expectation class
  netfilter: ctnetlink: add NAT support for expectations
  netfilter: ctnetlink: allow to set expectfn for expectations
  netfilter: nf_ct_udp[lite]: convert UDP[lite] timeouts to array
  netfilter: nf_ct_tcp: move retransmission and unacknowledged timeout
    to array
  netfilter: nf_ct_gre: add unsigned int array to define timeouts
  netfilter: nf_conntrack: pass timeout array to l4->new and l4->packet
  netfilter: add cttimeout infrastructure for fine timeout tuning
  netfilter: nf_ct_ext: add timeout extension
  netfilter: xt_CT: allow to attach timeout policy + glue code

Richard Weinberger (2):
  netfilter: merge ipt_LOG and ip6_LOG into xt_LOG
  netfilter: xt_LOG: fix bogus extra layer-4 logging information

Tony Zelenoff (2):
  netfilter: nf_ct_ecache: trailing whitespace removed
  netfilter: nf_ct_ecache: refactor nf_ct_deliver_cached_events

WANG Cong (1):
  netfilter: remove ipt_SAME.h and ipt_realm.h

 include/linux/netfilter/Kbuild                 |    2 +
 include/linux/netfilter/ipset/ip_set.h         |   35 +-
 include/linux/netfilter/ipset/ip_set_ahash.h   |  119 +++-
 include/linux/netfilter/nf_conntrack_tcp.h     |    5 +-
 include/linux/netfilter/nfnetlink.h            |    3 +-
 include/linux/netfilter/nfnetlink_conntrack.h  |   11 +
 include/linux/netfilter/nfnetlink_cttimeout.h  |  114 +++
 include/linux/netfilter/xt_CT.h                |   12 +
 include/linux/netfilter/xt_LOG.h               |   19 +
 include/linux/netfilter_ipv4/Kbuild            |    2 -
 include/linux/netfilter_ipv4/ipt_LOG.h         |    2 +
 include/linux/netfilter_ipv4/ipt_SAME.h        |   20 -
 include/linux/netfilter_ipv4/ipt_realm.h       |    7 -
 include/linux/netfilter_ipv6/ip6t_LOG.h        |    2 +
 include/net/netfilter/nf_conntrack_extend.h    |    4 +
 include/net/netfilter/nf_conntrack_helper.h    |   13 +
 include/net/netfilter/nf_conntrack_l4proto.h   |   19 +-
 include/net/netfilter/nf_conntrack_timeout.h   |   78 ++
 include/net/netfilter/xt_log.h                 |    2 +-
 net/ipv4/netfilter/Kconfig                     |    9 -
 net/ipv4/netfilter/Makefile                    |    1 -
 net/ipv4/netfilter/ipt_LOG.c                   |  516 -------------
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   60 ++-
 net/ipv4/netfilter/nf_nat_core.c               |    8 +
 net/ipv4/netfilter/nf_nat_h323.c               |   14 +
 net/ipv4/netfilter/nf_nat_sip.c                |    7 +
 net/ipv6/netfilter/Kconfig                     |    9 -
 net/ipv6/netfilter/Makefile                    |    1 -
 net/ipv6/netfilter/ip6t_LOG.c                  |  527 --------------
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   60 ++-
 net/netfilter/Kconfig                          |   30 +
 net/netfilter/Makefile                         |    3 +
 net/netfilter/ipset/ip_set_bitmap_ip.c         |    4 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c      |    4 +-
 net/netfilter/ipset/ip_set_bitmap_port.c       |    4 +-
 net/netfilter/ipset/ip_set_core.c              |   16 +-
 net/netfilter/ipset/ip_set_getport.c           |    4 +-
 net/netfilter/ipset/ip_set_hash_ip.c           |   18 +-
 net/netfilter/ipset/ip_set_hash_ipport.c       |   10 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   10 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |  147 +++-
 net/netfilter/ipset/ip_set_hash_net.c          |   89 ++-
 net/netfilter/ipset/ip_set_hash_netiface.c     |   84 ++-
 net/netfilter/ipset/ip_set_hash_netport.c      |  150 +++-
 net/netfilter/ipset/ip_set_list_set.c          |    2 +-
 net/netfilter/nf_conntrack_core.c              |   34 +-
 net/netfilter/nf_conntrack_ecache.c            |   55 +-
 net/netfilter/nf_conntrack_helper.c            |   54 ++
 net/netfilter/nf_conntrack_netlink.c           |  167 ++++-
 net/netfilter/nf_conntrack_proto_dccp.c        |   86 ++-
 net/netfilter/nf_conntrack_proto_generic.c     |   77 ++-
 net/netfilter/nf_conntrack_proto_gre.c         |   82 ++-
 net/netfilter/nf_conntrack_proto_sctp.c        |   83 ++-
 net/netfilter/nf_conntrack_proto_tcp.c         |  168 ++++-
 net/netfilter/nf_conntrack_proto_udp.c         |  106 +++-
 net/netfilter/nf_conntrack_proto_udplite.c     |  103 +++-
 net/netfilter/nf_conntrack_timeout.c           |   60 ++
 net/netfilter/nfnetlink_cttimeout.c            |  429 +++++++++++
 net/netfilter/xt_CT.c                          |  220 ++++++-
 net/netfilter/xt_LOG.c                         |  925 ++++++++++++++++++++++++
 60 files changed, 3478 insertions(+), 1427 deletions(-)
 create mode 100644 include/linux/netfilter/nfnetlink_cttimeout.h
 create mode 100644 include/linux/netfilter/xt_LOG.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_SAME.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_realm.h
 create mode 100644 include/net/netfilter/nf_conntrack_timeout.h
 delete mode 100644 net/ipv4/netfilter/ipt_LOG.c
 delete mode 100644 net/ipv6/netfilter/ip6t_LOG.c
 create mode 100644 net/netfilter/nf_conntrack_timeout.c
 create mode 100644 net/netfilter/nfnetlink_cttimeout.c
 create mode 100644 net/netfilter/xt_LOG.c

-- 
1.7.7.3

