From: pablo@netfilter.org
Subject: [PATCH 00/25] netfilter updates from net-next (upcoming 3.6)
Date: Mon, 11 Jun 2012 16:43:36 +0200
Message-ID: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32787 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754981Ab2FKOon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:44:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi Davidm

The following patchset contains netfilter updates for your net-next
tree. Short summary:

* Netns support for all our nf_conntrack sysctl tweaks, including global
  timeout adjustment from Gao Feng.

* Add fail-open support to NFQUEUE, ie. don't drop packets if the kernel-space
  nfqueue gets full, instead we allow packets to go through, from Krishna Kumar.

* Remove support for connlimit revision 0, as we already scheduled, from
  Cong Wang.

* Improve load distribution in NFQUEUE if multi-queue is used from Florian
  Westphal.

* Minor cleanups from Alban Crequy to use NFPROTO_* constants instead of
  PF_* as we do in other parts of the Netfilter code.

You can pull these changes from:

git://1984.lsi.us.es/net-next master

Thanks!

Alban Crequy (5):
  netfilter: decnet: switch hook PFs to nfproto
  netfilter: bridge: switch hook PFs to nfproto
  netfilter: ipv4, defrag: switch hook PFs to nfproto
  netfilter: ipvs: switch hook PFs to nfproto
  netfilter: selinux: switch hook PFs to nfproto

Cong Wang (2):
  netfilter: remove include/linux/netfilter_ipv4/ipt_addrtype.h
  netfilter: xt_connlimit: remove revision 0

Denys Fedoryshchenko (1):
  netfilter: xt_recent: add address masking option

Florian Westphal (1):
  netfilter: NFQUEUE: don't xor src/dst ip address for load
    distribution

Gao feng (14):
  netfilter: nf_conntrack: prepare namespace support for l4 protocol trackers
  netfilter: nf_conntrack: prepare namespace support for l3 protocol trackers
  netfilter: nf_ct_generic: add namespace support
  netfilter: nf_ct_tcp: add namespace support
  netfilter: nf_ct_udp: add namespace support
  netfilter: nf_ct_icmp: add namespace support
  netfilter: nf_ct_icmp: add namespace support
  netfilter: nf_ct_ipv4: add namespace support
  netfilter: nf_ct_ipv6: add namespace support
  netfilter: nf_ct_sctp: add namespace support
  netfilter: nf_ct_udplite: add namespace support
  netfilter: nf_ct_dccp: use new namespace support
  netfilter: nf_ct_gre: use new namespace support
  netfilter: nf_conntrack: add namespace support for cttimeout

Krishna Kumar (1):
  netfilter: Add fail-open support

Pablo Neira Ayuso (1):
  netfilter: nf_conntrack: remove now unused sysctl for nf_conntrack_l[3|4]proto

 Documentation/feature-removal-schedule.txt     |   22 +-
 include/linux/netfilter.h                      |   10 +
 include/linux/netfilter/nfnetlink_queue.h      |    5 +
 include/linux/netfilter/xt_connlimit.h         |    9 +-
 include/linux/netfilter/xt_recent.h            |   10 +
 include/linux/netfilter_ipv4/Kbuild            |    1 -
 include/linux/netfilter_ipv4/ipt_addrtype.h    |   27 ---
 include/net/netfilter/nf_conntrack_core.h      |    4 +-
 include/net/netfilter/nf_conntrack_l3proto.h   |   11 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |   22 +-
 include/net/netns/conntrack.h                  |   55 +++++
 net/bridge/br_netfilter.c                      |   28 +--
 net/decnet/netfilter/dn_rtmsg.c                |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  124 +++++++----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   52 +++--
 net/ipv4/netfilter/nf_defrag_ipv4.c            |    4 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   88 +++++---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   36 +++-
 net/netfilter/ipvs/ip_vs_core.c                |   24 +--
 net/netfilter/nf_conntrack_core.c              |   17 +-
 net/netfilter/nf_conntrack_proto.c             |  273 +++++++++++++++++-------
 net/netfilter/nf_conntrack_proto_dccp.c        |  137 ++++++------
 net/netfilter/nf_conntrack_proto_generic.c     |   52 +++--
 net/netfilter/nf_conntrack_proto_gre.c         |   63 +++---
 net/netfilter/nf_conntrack_proto_sctp.c        |  196 +++++++++++++----
 net/netfilter/nf_conntrack_proto_tcp.c         |  183 ++++++++++++----
 net/netfilter/nf_conntrack_proto_udp.c         |  123 ++++++++---
 net/netfilter/nf_conntrack_proto_udplite.c     |  118 +++++++---
 net/netfilter/nfnetlink_cttimeout.c            |   13 +-
 net/netfilter/nfnetlink_queue.c                |   40 +++-
 net/netfilter/xt_NFQUEUE.c                     |   28 ++-
 net/netfilter/xt_connlimit.c                   |   35 +--
 net/netfilter/xt_recent.c                      |   62 +++++-
 security/selinux/hooks.c                       |   10 +-
 34 files changed, 1300 insertions(+), 584 deletions(-)
 delete mode 100644 include/linux/netfilter_ipv4/ipt_addrtype.h

-- 
1.7.10
