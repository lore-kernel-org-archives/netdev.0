From: pablo@netfilter.org
Subject: [PATCH 00/18] netfilter updates for net-next (upcoming 3.6), batch 5
Date: Fri,  6 Jul 2012 13:16:50 +0200
Message-ID: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43344 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab2GFLSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:18:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset includes Netfilter updates for your net-next tree,
more specifically:

* Updates to clean-up the sysctl namespace support for nf_conntrack
  from Gao Feng and a couple of patches from myself. After these, we
  can prepare follow-up patches to reduce ifdef pollution regarding
  sysctl support in nf_conntrack_proto_*.c files.

* Check for invalid flags set via NFQA_CFG_FLAGS in nfnetlink_queue
  from Krishna Kumar.

* Allow to obtain conntrack statistics via ctnetlink from mysqlf. This
  supersedes /proc/net/stat/nf_conntrack and
  /proc/sys/net/netfilter/nf_conntrack_count.

* Don't crash if we send a message to nfnetlink and there is not defined
  callback to handle such message. Instead, nfnetlink returns -EINVAL from
  Tomasz Bursztyka. This one does not really fix anything now, that's
  why I'm passing this via net-next.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Gao feng (13):
  netfilter: nf_conntrack: fix nf_conntrack_l3proto_register
  netfilter: nf_conntrack: prepare l4proto->init_net cleanup
  netfilter: nf_conntrack: add nf_ct_kfree_compat_sysctl_table
  netfilter: nf_conntrack: use l4proto->users as refcount for per-net data
  netfilter: nf_conntrack: fix memory leak if sysctl registration fails
  netfilter: nf_ct_tcp: merge tcpv[4,6]_net_init into tcp_net_init
  netfilter: nf_ct_udp: merge udpv[4,6]_net_init into udp_net_init
  netfilter: nf_ct_udplite: add udplite_kmemdup_sysctl_table function
  netfilter: nf_ct_sctp: merge sctpv[4,6]_net_init into sctp_net_init
  netfilter: nf_ct_generic: add generic_kmemdup_sysctl_table function
  netfilter: nf_ct_dccp: add dccp_kmemdup_sysctl_table function
  netfilter: nf_ct_icmp: add icmp_kmemdup[_compat]_sysctl_table function
  netfilter: nf_ct_icmpv6: add icmpv6_kmemdup_sysctl_table function

Krishna Kumar (1):
  netfilter: nfnetlink_queue: do not allow to set unsupported flag bits

Pablo Neira Ayuso (3):
  netfilter: ctnetlink: add new messages to obtain statistics
  netfilter: nf_conntrack: generalize nf_ct_l4proto_net
  netfilter: nf_ct_tcp: missing per-net support for cttimeout

Tomasz Bursztyka (1):
  netfilter: nfnetlink: check callbacks before using those in nfnetlink_rcv_msg

 include/linux/netfilter/nfnetlink_conntrack.h  |   38 ++++
 include/linux/netfilter/nfnetlink_queue.h      |    1 +
 include/net/netfilter/nf_conntrack_l4proto.h   |   13 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   47 ++++-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   23 ++-
 net/netfilter/nf_conntrack_netlink.c           |  227 +++++++++++++++++++++++-
 net/netfilter/nf_conntrack_proto.c             |  139 ++++++++-------
 net/netfilter/nf_conntrack_proto_dccp.c        |   56 +++---
 net/netfilter/nf_conntrack_proto_generic.c     |   45 ++++-
 net/netfilter/nf_conntrack_proto_gre.c         |    2 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |   65 +++----
 net/netfilter/nf_conntrack_proto_tcp.c         |   74 +++-----
 net/netfilter/nf_conntrack_proto_udp.c         |   66 +++----
 net/netfilter/nf_conntrack_proto_udplite.c     |   43 +++--
 net/netfilter/nfnetlink.c                      |    4 +-
 net/netfilter/nfnetlink_queue_core.c           |    5 +
 16 files changed, 591 insertions(+), 257 deletions(-)

-- 
1.7.10
