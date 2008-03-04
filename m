From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [INET]: Updates for net-2.6.26.
Date: Tue, 04 Mar 2008 15:59:46 +0900 (JST)
Message-ID: <20080304.155946.31980558.yoshfuji@linux-ipv6.org>
References: <20080303.004449.98475557.yoshfuji@linux-ipv6.org>
	<20080303.204549.82367997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53713 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbYCDG6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 01:58:44 -0500
In-Reply-To: <20080303.204549.82367997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080303.204549.82367997.davem@davemloft.net> (at Mon, 03 Mar 2008 20:45:49 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Mon, 03 Mar 2008 00:44:49 +0900 (JST)
> 
> > Please consider pulling following changesets on top of net-2.6.26
> > tree from
> >         git://git.skbuff.net/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-inet-20080302
> 
> I can't pull this in, it breaks the build in various ways:
> 
> drivers/net/cxgb3/l2t.c: In function 't3_l2t_update':
> drivers/net/cxgb3/l2t.c:410: error: implicit declaration of function 'neigh_is_connected'
> net/ipv4/udp_ipv4.c:1068: error: 'compat_udpv4_setsockopt' undeclared here (not in a function)
> net/ipv4/udp_ipv4.c:1069: error: 'compat_udpv4_getsockopt' undeclared here (not in a function)

Oh, sorry.  I've updated / rebased them and pushed at:
  git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-inet-20080304

I hope issues have gone away...

Regards,

--
HEADLINES
---------

    [TCP]: lower stack usage in cookie_hash() function
    [TCP]: Add IPv6 support to TCP SYN cookies
    [UDP]: Allow users to configure UDP-Lite.
    [IPV4]: Fix size description of CONFIG_INET.
    [IPV4] UDP: Move IPv4-specific bits to other file.
    [IPV6] UDP: Rename IPv6 UDP files.
    [IPV6]: Move packet_type{} related bits to af_inet6.c.
    [IPV6] SYSCTL: complete initialization for sysctl table in subsystem code.
    [IPV6]: Use htonl() instead of __constant_htonl() where appricable.
    [NET] NEIGHBOUR: Remove unpopular neigh_is_connected().
    [IPV6] ADDRCONF: Convert ipv6_get_saddr() to ipv6_dev_get_saddr().
    [IPV6]: Make ndisc_flow_init() common for later use.
    [IPV6]: Make ndisc_dst_alloc() common for later use.
    [IPV6] MCAST: Use standard path for sending MLD/MLDv2 messages.

DIFFSTAT
--------

 drivers/net/cxgb3/l2t.c    |    2 
 include/linux/icmpv6.h     |    8 
 include/linux/udp.h        |   11 
 include/net/addrconf.h     |   19 -
 include/net/ip6_route.h    |    8 
 include/net/ipv6.h         |    9 
 include/net/neighbour.h    |    6 
 include/net/tcp.h          |    8 
 include/net/transp_v6.h    |    5 
 include/net/udplite.h      |    9 
 net/Kconfig                |    2 
 net/ipv4/Kconfig           |   10 
 net/ipv4/Makefile          |    3 
 net/ipv4/af_inet.c         |    7 
 net/ipv4/proc.c            |    5 
 net/ipv4/syncookies.c      |   11 
 net/ipv4/tcp_input.c       |    1 
 net/ipv4/tcp_minisocks.c   |    2 
 net/ipv4/tcp_output.c      |    1 
 net/ipv4/udp.c             | 1090 ------------------------------------------
 net/ipv4/udp_ipv4.c        | 1134 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udplite.c         |  121 -----
 net/ipv4/udplite_ipv4.c    |  121 +++++
 net/ipv6/Makefile          |    4 
 net/ipv6/addrconf.c        |    9 
 net/ipv6/af_inet6.c        |  137 +++++
 net/ipv6/fib6_rules.c      |    4 
 net/ipv6/icmp.c            |   20 +
 net/ipv6/ip6_fib.c         |    2 
 net/ipv6/ip6_output.c      |    3 
 net/ipv6/ipv6_sockglue.c   |  128 -----
 net/ipv6/mcast.c           |   66 ++-
 net/ipv6/ndisc.c           |   25 -
 net/ipv6/proc.c            |    6 
 net/ipv6/route.c           |   44 +-
 net/ipv6/syncookies.c      |  267 ++++++++++
 net/ipv6/sysctl_net_ipv6.c |   15 -
 net/ipv6/tcp_ipv6.c        |   77 ++-
 net/ipv6/udp.c             | 1065 -----------------------------------------
 net/ipv6/udp_ipv6.c        | 1065 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/udplite.c         |  125 -----
 net/ipv6/udplite_ipv6.c    |  125 +++++
 net/ipv6/xfrm6_policy.c    |    5 
 net/sctp/ipv6.c            |    3 
 44 files changed, 3121 insertions(+), 2667 deletions(-)



--yoshfuji
