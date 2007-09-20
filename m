From: Joe Perches <joe@perches.com>
Subject: [PATCH - net-2.6.24 2/2] Introduce and use print_ipv6
Date: Wed, 19 Sep 2007 23:54:54 -0700
Message-ID: <1190271294.26101.94.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2609 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbXITGy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 02:54:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes the uses of NIP6_FMT and NIP6_SEQFMT in net

IPV6 uses 2 different formats, colon separated and contiguous.
The contiguous form is used in seq_print

	"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x"
	"%04x%04x%04x%04x%04x%04x%04x%04x"	
	 
IPV6 use:

	DECLARE_IPV6_BUF(ipv6buf);
	const struct in6_addr *addr;
	print_ipv6(ipv6buf, addr);
and
	print_ipv6_nofmt(ipv6buf, addr);

Signed-off-by:  Joe Perches <joe@perches.com>

please pull from:
git pull http://repo.or.cz/r/linux-2.6/trivial-mods.git print_ipv6

stats for print_ipv6:

--

 include/linux/ipv6.h                           |    4 ++
 include/net/netfilter/nf_conntrack_tuple.h     |   17 +++++++---
 include/net/sctp/sctp.h                        |    7 +++-
 net/core/utils.c                               |   32 +++++++++++++++++
 net/ipv4/netfilter/nf_nat_pptp.c               |    1 +
 net/ipv6/addrconf.c                            |    6 ++--
 net/ipv6/ah6.c                                 |    5 ++-
 net/ipv6/anycast.c                             |    5 ++-
 net/ipv6/esp6.c                                |    5 ++-
 net/ipv6/exthdrs.c                             |    4 ++-
 net/ipv6/icmp.c                                |    7 +++-
 net/ipv6/ip6_flowlabel.c                       |    5 ++-
 net/ipv6/ipcomp6.c                             |    5 ++-
 net/ipv6/mcast.c                               |   13 ++++---
 net/ipv6/ndisc.c                               |    5 ++-
 net/ipv6/netfilter/ip6t_LOG.c                  |    4 ++-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    8 +++--
 net/ipv6/route.c                               |   13 ++++---
 net/ipv6/tcp_ipv6.c                            |   26 ++++++++-------
 net/netfilter/nf_conntrack_core.c              |    1 +
 net/netfilter/nf_conntrack_ftp.c               |   12 ++++---
 net/netfilter/nf_conntrack_h323_main.c         |   14 ++++---
 net/netfilter/nf_conntrack_proto_gre.c         |    1 +
 net/netfilter/xt_hashlimit.c                   |   10 +++--
 net/sctp/ipv6.c                                |   43 ++++++++++++++---------
 net/sctp/sm_statefuns.c                        |    6 ++--
 net/sunrpc/svcsock.c                           |    5 ++-
 net/xfrm/xfrm_policy.c                         |   18 ++++------
 net/xfrm/xfrm_state.c                          |   17 +++------
 29 files changed, 188 insertions(+), 111 deletions(-)


