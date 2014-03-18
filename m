From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2014-03-18
Date: Tue, 18 Mar 2014 08:21:25 +0100
Message-ID: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53240 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752659AbaCRHVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One patch to rename a newly introduced struct. The rest is
the rework of the IPsec virtual tunnel interface for ipv6 to
support inter address family tunneling and namespace crossing.

1) Rename the newly introduced struct xfrm_filter to avoid a
   conflict with iproute2. From Nicolas Dichtel.

2) Introduce xfrm_input_afinfo to access the address family
   dependent tunnel callback functions properly.

3) Add and use a IPsec protocol multiplexer for ipv6.

4) Remove dst_entry caching. vti can lookup multiple different
   dst entries, dependent of the configured xfrm states. Therefore
   it does not make to cache a dst_entry.

5) Remove caching of flow informations. vti6 does not use the the
   tunnel endpoint addresses to do route and xfrm lookups.

6) Update the vti6 to use its own receive hook.

7) Remove the now unused xfrm_tunnel_notifier. This was used from vti
   and is replaced by the IPsec protocol multiplexer hooks.

8) Support inter address family tunneling for vti6.

9) Check if the tunnel endpoints of the xfrm state and the vti interface
   are matching and return an error otherwise.

10) Enable namespace crossing for vti devices.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit e50287be7c007a10e6e2e3332e52466faf4b6a04:

  be2net: dma_sync each RX frag before passing it to the stack (2014-03-04 16:17:53 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 61220ab349485d911083d0b7990ccd3db6c63297:

  vti6: Enable namespace changing (2014-03-14 07:28:09 +0100)

----------------------------------------------------------------
Nicolas Dichtel (1):
      xfrm: rename struct xfrm_filter

Steffen Klassert (12):
      xfrm: Introduce xfrm_input_afinfo to access the the callbacks properly
      xfrm6: Add IPsec protocol multiplexer
      esp6: Use the IPsec protocol multiplexer API
      ah6: Use the IPsec protocol multiplexer API
      ipcomp6: Use the IPsec protocol multiplexer API
      vti6: Remove dst_entry caching
      vti6: Remove caching of flow informations.
      vti6: Update the ipv6 side to use its own receive hook.
      xfrm6: Remove xfrm_tunnel_notifier
      vti6: Support inter address family tunneling.
      vti6: Check the tunnel endpoints of the xfrm state and the vti interface
      vti6: Enable namespace changing

 include/net/xfrm.h           |   50 ++++---
 include/uapi/linux/xfrm.h    |    4 +-
 net/ipv4/xfrm4_policy.c      |    1 +
 net/ipv4/xfrm4_protocol.c    |   13 +-
 net/ipv6/Makefile            |    2 +-
 net/ipv6/ah6.c               |   24 ++--
 net/ipv6/esp6.c              |   26 ++--
 net/ipv6/ip6_vti.c           |  308 +++++++++++++++++++++++++++++-------------
 net/ipv6/ipcomp6.c           |   22 ++-
 net/ipv6/xfrm6_mode_tunnel.c |   63 ---------
 net/ipv6/xfrm6_policy.c      |    7 +
 net/ipv6/xfrm6_protocol.c    |  270 ++++++++++++++++++++++++++++++++++++
 net/key/af_key.c             |    2 +-
 net/xfrm/xfrm_input.c        |   75 ++++++++++
 net/xfrm/xfrm_state.c        |    4 +-
 net/xfrm/xfrm_user.c         |    8 +-
 16 files changed, 668 insertions(+), 211 deletions(-)
 create mode 100644 net/ipv6/xfrm6_protocol.c
