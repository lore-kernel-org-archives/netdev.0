From: pablo@netfilter.org
Subject: [PATCH 0/5] netfilter updates for net-next (upcoming 3.5), batch 2
Date: Wed,  9 May 2012 13:33:03 +0200
Message-ID: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33853 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756729Ab2EILda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 07:33:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

This is a second batch of netfilter updates for net-next, they contain:

* The new HMARK target from Hans Schillstrom. It took lots of spins
  to get this into shape. This target provides a hash-based packet / flow
  pre-classifier for iptables that can be used to distribute packets
  / flows between uplinks and backend servers. It provides to modes, one
  that relies on conntrack, and one that is stateless per-packet.

* Byte-based cost calculation for the hashlimit match, to detect when
  a host consumes more bandwidth than expected. This patch from Florian
  Westphal.

You can pull these changes from:

git://1984.lsi.us.es/net-next

Thanks!

Florian Westphal (3):
  netfilter: limit, hashlimit: avoid duplicated inline
  netfilter: hashlimit: move rateinfo initialization to helper
  netfilter: hashlimit: byte-based limit mode

Hans Schillstrom (2):
  netfilter: ip6_tables: add flags parameter to ipv6_find_hdr()
  netfilter: add xt_hmark target for hash-based skb marking

 include/linux/netfilter/xt_HMARK.h        |   45 ++++
 include/linux/netfilter/xt_hashlimit.h    |   10 +-
 include/linux/netfilter_ipv6/ip6_tables.h |    7 +-
 net/ipv6/netfilter/ip6_tables.c           |   36 ++-
 net/ipv6/netfilter/ip6t_ah.c              |    4 +-
 net/ipv6/netfilter/ip6t_frag.c            |    4 +-
 net/ipv6/netfilter/ip6t_hbh.c             |    4 +-
 net/ipv6/netfilter/ip6t_rt.c              |    4 +-
 net/netfilter/Kconfig                     |   15 ++
 net/netfilter/Makefile                    |    1 +
 net/netfilter/xt_HMARK.c                  |  362 +++++++++++++++++++++++++++++
 net/netfilter/xt_TPROXY.c                 |    4 +-
 net/netfilter/xt_hashlimit.c              |  129 ++++++++--
 net/netfilter/xt_limit.c                  |    5 +-
 net/netfilter/xt_socket.c                 |    4 +-
 15 files changed, 588 insertions(+), 46 deletions(-)
 create mode 100644 include/linux/netfilter/xt_HMARK.h
 create mode 100644 net/netfilter/xt_HMARK.c

-- 
1.7.9.5
