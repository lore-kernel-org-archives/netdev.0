From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-12-19
Date: Thu, 19 Dec 2013 07:36:37 +0100
Message-ID: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48177 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447Ab3LSGhT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:37:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Use the user supplied policy index instead of a generated one
   if present. From Fan Du.

2) Make xfrm migration namespace aware. From Fan Du.

3) Make the xfrm state and policy locks namespace aware. From Fan Du.

4) Remove ancient sleeping when the SA is in acquire state,
   we now queue packets to the policy instead. This replaces the
   sleeping code.

5) Remove FLOWI_FLAG_CAN_SLEEP. This was used to notify xfrm about the
   posibility to sleep. The sleeping code is gone, so remove it.

6) Check user specified spi for IPComp. Thr spi for IPcomp is only
   16 bit wide, so check for a valid value. From Fan Du.

7) Export verify_userspi_info to check for valid user supplied spi ranges
   with pfkey and netlink. From Fan Du.

8) RFC3173 states that if the total size of a compressed payload and the IPComp
   header is not smaller than the size of the original payload, the IP datagram
   must be sent in the original non-compressed form. These packets are dropped
   by the inbound policy check because they are not transformed. Document the need
   to set 'level use' for IPcomp to receive such packets anyway. From Fan Du.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit d70f2cf520cf8c86c6b467fc5dcea524ec51dc2f:

  macvlan: Support creating macvtaps from macvlans (2013-12-05 19:59:02 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to b3c6efbc36e2c5ac820b1a800ac17cc3e040de0c:

  xfrm: Add file to document IPsec corner case (2013-12-16 12:54:05 +0100)

----------------------------------------------------------------
Fan Du (6):
      xfrm: Try to honor policy index if it's supplied by user
      xfrm: Using the right namespace to migrate key info
      xfrm: Namespacify xfrm state/policy locks
      xfrm: check user specified spi for IPComp
      xfrm: export verify_userspi_info for pkfey and netlink interface
      xfrm: Add file to document IPsec corner case

Steffen Klassert (2):
      xfrm: Remove ancient sleeping when the SA is in acquire state
      net: Remove FLOWI_FLAG_CAN_SLEEP

 Documentation/networking/ipsec.txt |   38 +++++++++
 include/net/flow.h                 |    3 +-
 include/net/ipv6.h                 |    6 +-
 include/net/netns/xfrm.h           |    6 +-
 include/net/route.h                |    8 +-
 include/net/xfrm.h                 |   14 ++--
 net/dccp/ipv4.c                    |    2 +-
 net/dccp/ipv6.c                    |    8 +-
 net/decnet/dn_route.c              |    2 -
 net/ipv4/af_inet.c                 |    2 +-
 net/ipv4/datagram.c                |    2 +-
 net/ipv4/raw.c                     |    2 +-
 net/ipv4/tcp_ipv4.c                |    2 +-
 net/ipv4/udp.c                     |    2 +-
 net/ipv6/af_inet6.c                |    2 +-
 net/ipv6/datagram.c                |    2 +-
 net/ipv6/inet6_connection_sock.c   |    4 +-
 net/ipv6/ip6_output.c              |   12 +--
 net/ipv6/ping.c                    |    2 +-
 net/ipv6/raw.c                     |    2 +-
 net/ipv6/syncookies.c              |    2 +-
 net/ipv6/tcp_ipv6.c                |    4 +-
 net/ipv6/udp.c                     |    2 +-
 net/key/af_key.c                   |   29 ++++---
 net/l2tp/l2tp_ip6.c                |    2 +-
 net/sctp/ipv6.c                    |    4 +-
 net/xfrm/xfrm_policy.c             |  151 +++++++++++++++++-------------------
 net/xfrm/xfrm_state.c              |  149 ++++++++++++++++++-----------------
 net/xfrm/xfrm_user.c               |   56 ++++++-------
 29 files changed, 277 insertions(+), 243 deletions(-)
 create mode 100644 Documentation/networking/ipsec.txt
