From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v3 00/17] netfilter: add namespace support for netfilter protos
Date: Mon, 14 May 2012 16:52:10 +0800
Message-ID: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the sysctl of netfilter proto is not isolated, so when
changing proto's sysctl in container will cause the host's sysctl
be changed too. it's not expected.

This patch set adds the namespace support for netfilter protos.

impletement four pernet_operations to register sysctl and initial
pernet data for proto.

-ipv4_net_ops is used to register tcp4(compat),
 udp4(compat),icmp(compat),ipv4(compat).
-ipv6_net_ops is used to register tcp6,udp6 and icmpv6.
-sctp_net_ops is used to register sctp4(compat) and sctp6.
-udplite_net_ops is used to register udplite4 and udplite6

extern l[3,4]proto (sysctl) register functions to make them support
namespace.

finailly add namespace support for cttimeout.

Changes from v2:
	re-split patchset to make compilation success.

Gao feng (17):
  netfilter: add struct nf_proto_net for register l4proto sysctl
  netfilter: add namespace support for l4proto
  netfilter: add namespace support for l3proto
  netfilter: add namespace support for l4proto_generic
  netfilter: add namespace support for l4proto_tcp
  netfilter: add namespace support for l4proto_udp
  netfilter: add namespace support for l4proto_icmp
  netfilter: add namespace support for l4proto_icmpv6
  netfilter: add namespace support for l3proto_ipv4
  netfilter: add namespace support for l3proto_ipv6
  netfilter: add namespace support for l4proto_sctp
  netfilter: add namespace support for l4proto_udplite
  netfilter: adjust l4proto_dccp to the nf_conntrack_l4proto_register
  netfilter: adjust l4proto_gre4 to the nf_conntrack_l4proto_register
  netfilter: cleanup sysctl for l4proto and l3proto
  netfilter: add namespace support for cttimeout
  netfilter: cttimeout use pernet data of l4proto

 include/net/netfilter/nf_conntrack_l3proto.h   |   11 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |   32 ++-
 include/net/netns/conntrack.h                  |   55 ++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  123 +++++---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   53 +++-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   88 ++++--
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   37 ++-
 net/netfilter/nf_conntrack_core.c              |    8 +-
 net/netfilter/nf_conntrack_proto.c             |  385 ++++++++++++++---------
 net/netfilter/nf_conntrack_proto_dccp.c        |  140 +++++-----
 net/netfilter/nf_conntrack_proto_generic.c     |   69 ++++-
 net/netfilter/nf_conntrack_proto_gre.c         |   64 +++--
 net/netfilter/nf_conntrack_proto_sctp.c        |  156 +++++++---
 net/netfilter/nf_conntrack_proto_tcp.c         |  135 ++++++---
 net/netfilter/nf_conntrack_proto_udp.c         |   88 ++++--
 net/netfilter/nf_conntrack_proto_udplite.c     |  123 ++++++--
 net/netfilter/nfnetlink_cttimeout.c            |   13 +-
 17 files changed, 1056 insertions(+), 524 deletions(-)

-- 
1.7.7.6

