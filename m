From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH v2 0/9] tproxy: add IPv6 support
Date: Thu, 21 Oct 2010 12:47:09 +0200
Message-ID: <20101021104709.5192.31249.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series adds IPv6 support for tproxy. The parts touching
non-Netfilter code include exporting the UDP lookup function, adding the
sockopt infrastructure for getting the original destination address and
allowing non-local binds if the IP_TRANSPARENT socket option is set.

Netfilter changes are splitting the defragmentation code off of conntrack,
adding IPv6 socket lookup helpers to the tproxy core module and updating the
socket match and the TPROXY target.

The last patch in the series tries to make it easier to use the TPROXY target
by selecting a meaningful address to redirect to in case the user did not
explicitly specify it with '--on-ip'.

v2 of the patches incorporates fixes suggested by Jan Engelhardt.

---

Balazs Scheidler (9):
      tproxy: split off ipv6 defragmentation to a separate module
      tproxy: added const specifiers to udp lookup functions
      tproxy: added udp6_lib_lookup function
      tproxy: added tproxy sockopt interface in the IPV6 layer
      tproxy: allow non-local binds of IPv6 sockets if IP_TRANSPARENT is enabled
      tproxy: added IPv6 socket lookup function to nf_tproxy_core
      tproxy: added IPv6 support to the TPROXY target
      tproxy: added IPv6 support to the socket match
      tproxy: use the interface primary IP address as a default value for --on-ip


 include/linux/in6.h                            |    4 
 include/linux/ipv6.h                           |    4 
 include/linux/netfilter/xt_TPROXY.h            |   13 +
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |    6 
 include/net/netfilter/nf_tproxy_core.h         |   72 +++++
 include/net/udp.h                              |    3 
 net/ipv6/af_inet6.c                            |    2 
 net/ipv6/datagram.c                            |   19 +
 net/ipv6/ipv6_sockglue.c                       |   23 ++
 net/ipv6/netfilter/Makefile                    |    5 
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   78 ------
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   12 +
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  131 ++++++++++
 net/ipv6/udp.c                                 |   16 +
 net/netfilter/xt_TPROXY.c                      |  328 +++++++++++++++++++++---
 net/netfilter/xt_socket.c                      |  165 +++++++++++-
 16 files changed, 743 insertions(+), 138 deletions(-)
 create mode 100644 include/net/netfilter/ipv6/nf_defrag_ipv6.h
 create mode 100644 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c

-- 
KOVACS Krisztian

