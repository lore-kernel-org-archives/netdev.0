From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/44] Mobile IPv6 Platform, Take 2 (for net-2.6.19)
Date: Thu, 24 Aug 2006 00:22:26 +0900 (JST)
Message-ID: <20060824.002226.121257686.yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:30728 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964969AbWHWPUj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:20:39 -0400
To: davem@davemloft.net
In-Reply-To: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> (at Thu, 24 Aug 2006 00:02:01 +0900), YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> says:

> This is the update of the "MIPv6 CN introduction" and "MIPv6 CN"
> based on the MIPL2 kernel patch.

Headlines and diffstats are:

HEADLINES
---------

    [XFRM]: Add XFRM_MODE_xxx for future use.
    [XFRM]: Introduce a helper to compare id protocol.
    [XFRM] STATE: Allow non IPsec protocol.
    [XFRM]: Expand XFRM_MAX_DEPTH for route optimization.
    [XFRM] STATE: Add source address list.
    [XFRM] STATE: Search by address using source address list.
    [XFRM] STATE: Add a hook to find offset to be inserted header in outbound.
    [XFRM] STATE: Introduce route optimization mode.
    [XFRM]: Restrict authentication algorithm only when inbound transformation protocol is IPsec.
    [XFRM] STATE: Common receive function for route optimization extension headers.
    [XFRM]: Rename secpath_has_tunnel to secpath_has_nontransport.
    [XFRM] STATE: Add a hook to obtain local/remote outbound address.
    [XFRM] STATE: Support non-fragment outbound transformation headers.
    [XFRM] STATE: Introduce care-of address.
    [XFRM] IPV6: Update outbound state timestamp for each sending.
    [XFRM] IPV6: Restrict bundle reusing
    [XFRM]: Fix message about transformation user interface.
    [IPV6]: Add Kconfig to enable Mobile IPv6.
    [IPV6] MIP6: Add routing header type 2 definition.
    [IPV6] MIP6: Add inbound interface of routing header type 2.
    [IPV6] MIP6: Add socket option and ancillary data interface of routing header type 2.
    [IPV6]: Find option offset by type.
    [IPV6]: Allow to replace skbuff by TLV parser.
    [IPV6] MIP6: Add home address option definition.
    [IPV6] MIP6: Add inbound interface of home address option.
    [IPV6] MIP6: Revert address to send ICMPv6 error.
    [IPV6] IPSEC: Support sending with Mobile IPv6 extension headers.
    [IPV6] MIP6: Add routing header type 2 transformation.
    [IPV6] MIP6: Add destination options header transformation.
    [XFRM] STATE: Add Mobile IPv6 route optimization protocols to netlink interface.
    [IPV6] MIP6: Add Mobility header definition.
    [IPV6] MIP6: Add receiving mobility header functions through raw socket.
    [IPV6] MIP6: Add sending mobility header functions through raw socket.
    [IPV6] MIP6: Transformation support mobility header.
    [XFRM]: Trace which secpath state is reject factor.
    [XFRM]: Introduce XFRM_MSG_REPORT.
    [IPV6] MIP6: Report to user-space when home address option is rejected.
    [IPV6] MIP6: Ignore to report if mobility headers is rejected.
    [XFRM] POLICY: Add Kconfig to support sub policy.
    [XFRM] POLICY: sub policy support.
    [XFRM]: Add sorting interface for state and template.
    [XFRM] POLICY: Support netlink socket interface for sub policy.
    [XFRM] IPV6: Add sort functions to combine templates/states for IPsec.
    [XFRM] IPV6: Support Mobile IPv6 extension headers sorting.

DIFFSTAT
--------

 include/linux/in6.h             |    2 
 include/linux/ipv6.h            |   26 ++
 include/linux/xfrm.h            |   36 +++
 include/net/addrconf.h          |    7 +
 include/net/dst.h               |    1 
 include/net/flow.h              |    9 +
 include/net/ipv6.h              |    5 
 include/net/mip6.h              |   61 +++++
 include/net/xfrm.h              |  149 ++++++++++-
 net/ipv4/ah4.c                  |    2 
 net/ipv4/esp4.c                 |    6 
 net/ipv4/ipcomp.c               |    8 -
 net/ipv4/xfrm4_input.c          |    2 
 net/ipv4/xfrm4_output.c         |    4 
 net/ipv4/xfrm4_policy.c         |    5 
 net/ipv4/xfrm4_state.c          |   14 +
 net/ipv4/xfrm4_tunnel.c         |    2 
 net/ipv6/Kconfig                |   16 +
 net/ipv6/Makefile               |    3 
 net/ipv6/af_inet6.c             |    9 +
 net/ipv6/ah6.c                  |  114 ++++++++-
 net/ipv6/datagram.c             |   11 +
 net/ipv6/esp6.c                 |    7 -
 net/ipv6/exthdrs.c              |  225 ++++++++++++++++-
 net/ipv6/icmp.c                 |   25 ++
 net/ipv6/ip6_input.c            |    2 
 net/ipv6/ip6_output.c           |   20 +-
 net/ipv6/ipcomp6.c              |    7 -
 net/ipv6/ipv6_sockglue.c        |   10 +
 net/ipv6/ipv6_syms.c            |    2 
 net/ipv6/mip6.c                 |  517 +++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c                  |   46 +++
 net/ipv6/xfrm6_input.c          |  110 ++++++++
 net/ipv6/xfrm6_mode_ro.c        |   94 +++++++
 net/ipv6/xfrm6_mode_transport.c |    2 
 net/ipv6/xfrm6_output.c         |   12 +
 net/ipv6/xfrm6_policy.c         |   65 ++++-
 net/ipv6/xfrm6_state.c          |  147 +++++++++++
 net/ipv6/xfrm6_tunnel.c         |    2 
 net/key/af_key.c                |   24 +-
 net/xfrm/Kconfig                |   16 +
 net/xfrm/xfrm_policy.c          |  337 ++++++++++++++++++++++---
 net/xfrm/xfrm_state.c           |  128 +++++++++-
 net/xfrm/xfrm_user.c            |  294 ++++++++++++++++++++--
 44 files changed, 2410 insertions(+), 174 deletions(-)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
