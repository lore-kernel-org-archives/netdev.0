From: pablo@netfilter.org
Subject: [PATCH 00/12] netfilter fixes for 3.8-rc1
Date: Fri, 28 Dec 2012 12:52:39 +0100
Message-ID: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50977 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753212Ab2L1LxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 06:53:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following batch contains Netfilter fixes for 3.8-rc1. They are
a mixture of old bugs that have passed unnoticed (I'll pass these to
stable) and more fresh ones from the previous merge window, they are:

* Fix for MAC address in 6in4 tunnels via NFLOG that results in ulogd
  showing up wrong address, from Bob Hockney.

* Fix a comment in nf_conntrack_ipv6, from Florent Fourcot.

* Fix a leak an error path in ctnetlink while creating an expectation,
  from Jesper Juhl.

* Fix missing ICMP time exceeded in the IPv6 defragmentation code, from
  Haibo Xi.

* Fix inconsistent handling of routing changes in MASQUERADE for the
  new connections case, from Andrew Collins.

* Fix a missing skb_reset_transport in ip[6]t_REJECT that leads to
  crashes in the ixgbe driver (since it seems to access the transport
  header with TSO enabled), from Mukund Jampala.

* Recover obsoleted NOTRACK target by including it into the CT and spot
  a warning via printk about being obsoleted. Many people don't check the
  scheduled to be removal file under Documentation, so we follow some
  less agressive approach to kill this in a year or so. Spotted by Florian
  Westphal, patch from myself.

* Fix race condition in xt_hashlimit that allows to create two or more
  entries, from myself.

* Fix crash if the CT is used due to the recently added facilities to
  consult the dying and unconfirmed conntrack lists, from myself.

That's basically it, you can pull these changes from:

git://1984.lsi.us.es/nf master

Have a nice entrance for the new year. Thanks.

Andrew Collins (1):
  netfilter: nf_nat: Also handle non-ESTABLISHED routing changes in MASQUERADE

Bob Hockney (1):
  netfilter: nfnetlink_log: fix mac address for 6in4 tunnels

Florent Fourcot (1):
  netfilter: nf_conntrack_ipv6: fix comment for packets without data

Haibo Xi (1):
  netfilter: nf_ct_reasm: fix conntrack reassembly expire code

Jesper Juhl (1):
  netfilter: ctnetlink: fix leak in error path of ctnetlink_create_expect

Mukund Jampala (1):
  netfilter: ip[6]t_REJECT: fix wrong transport header pointer in TCP reset

Pablo Neira Ayuso (4):
  netfilter: xt_CT: fix crash while destroy ct templates
  netfilter: nfnetlink_log: fix possible compilation issue due to missing include
  netfilter: xt_CT: recover NOTRACK target support
  netfilter: xt_hashlimit: fix race that results in duplicated entries

Vitaly E. Lavrov (2):
  netfilter: xt_recent: fix namespace destroy path
  netfilter: xt_hashlimit: fix namespace destroy path

 include/net/netns/conntrack.h                  |    1 +
 include/net/netns/x_tables.h                   |    1 +
 net/ipv4/netfilter/ipt_REJECT.c                |    1 +
 net/ipv4/netfilter/iptable_nat.c               |   15 ++++--
 net/ipv6/netfilter/ip6t_REJECT.c               |    1 +
 net/ipv6/netfilter/ip6table_nat.c              |   15 ++++--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |    5 +-
 net/netfilter/Kconfig                          |    4 ++
 net/netfilter/nf_conntrack_core.c              |    2 +
 net/netfilter/nf_conntrack_netlink.c           |    2 +-
 net/netfilter/nfnetlink_log.c                  |   16 +++++--
 net/netfilter/xt_CT.c                          |   58 +++++++++++++++++++++++-
 net/netfilter/xt_hashlimit.c                   |   54 ++++++++++++++++++----
 net/netfilter/xt_recent.c                      |   20 ++++++--
 15 files changed, 169 insertions(+), 30 deletions(-)

-- 
1.7.10.4
