From: pablo@netfilter.org
Subject: [PATCH 0/6] netfilter updates for net-next
Date: Tue,  4 Dec 2012 18:31:27 +0100
Message-ID: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54407 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347Ab2LDRbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 12:31:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

If time allows, please pull the following 6 updates for your
net-next tree:

* Remove limitation in the maximum number of supported sets in ipset.
  Now ipset automagically increments the number of slots in the array
  of sets by 64 new spare slots, from Jozsef Kadlecsik.

* Partially remove the generic queue infrastructure now that ip_queue
  is gone. Its only client is nfnetlink_queue now, from Florian
  Westphal.

* Add missing attribute policy checkings in ctnetlink, from Florian
  Westphal.

* Automagically kill conntrack entries that use the wrong output
  interface for the masquerading case in case of routing changes,
  from Jozsef Kadlecsik.

* Two patches two improve ct object traceability. Now ct objects are
  always placed in any of the existing lists. This allows us to dump
  the content of unconfirmed and dying conntracks via ctnetlink as
  a way to provide more instrumentation in case you suspect leaks,
  from myself.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Florian Westphal (2):
  netfilter: kill support for per-af queue backends
  netfilter: ctnetlink: nla_policy updates

Jozsef Kadlecsik (2):
  netfilter: ipset: Increase the number of maximal sets automatically
  netfilter: nf_nat: Handle routing changes in MASQUERADE target

Pablo Neira Ayuso (2):
  netfilter: nf_conntrack: improve nf_conn object traceability
  netfilter: ctnetlink: dump entries from the dying and unconfirmed lists

 include/net/netfilter/nf_conntrack.h               |    2 +-
 include/net/netfilter/nf_nat.h                     |   15 ++
 include/net/netfilter/nf_queue.h                   |    8 +-
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |    2 +
 net/ipv4/netfilter/iptable_nat.c                   |    4 +
 net/ipv6/netfilter/ip6table_nat.c                  |    4 +
 net/netfilter/core.c                               |    2 -
 net/netfilter/ipset/ip_set_core.c                  |  243 +++++++++++++-------
 net/netfilter/nf_conntrack_core.c                  |   25 +-
 net/netfilter/nf_conntrack_netlink.c               |  118 +++++++++-
 net/netfilter/nf_conntrack_proto_tcp.c             |    2 +
 net/netfilter/nf_queue.c                           |  152 ++----------
 net/netfilter/nfnetlink_queue_core.c               |   14 +-
 13 files changed, 332 insertions(+), 259 deletions(-)

--
1.7.10.4
