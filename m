From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/3] ipip/ip6tnl: allow to switch netns during encap/decap
Date: Wed,  3 Jul 2013 17:00:33 +0200
Message-ID: <1372863636-8866-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20130627.223621.1852663736303796496.davem@davemloft.net>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:60403 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883Ab3GCPDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 11:03:19 -0400
In-Reply-To: <20130627.223621.1852663736303796496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch is a follow up of the previous serie witch add this functionality
for sit tunnels.

The goal is to add x-netns support for the module ipip and ip6_tunnel, ie the
encapsulation addresses and the network device are not owned by the same
namespace.

Note that the first patch is a fix of the previous serie.

Example to configure an ipip tunnel:

modprobe ipip
ip netns add netns1
ip link add ipip1 type ipip remote 10.16.0.121 local 10.16.0.249
ip l s ipip1 netns netns1
ip netns exec netns1 ip l s lo up
ip netns exec netns1 ip l s ipip1 up
ip netns exec netns1 ip a a dev ipip1 192.168.2.123 remote 192.168.2.121

or an ip6_tunnel:

modprobe ip6_tunnel
ip netns add netns1
ip link add ip6tnl1 type ip6tnl remote 2001:660:3008:c1c3::121 local 2001:660:3008:c1c3::123
ip l s ip6tnl1 netns netns1
ip netns exec netns1 ip l s lo up
ip netns exec netns1 ip l s ip6tnl1 up
ip netns exec netns1 ip a a dev ip6tnl1 192.168.1.123 remote 192.168.1.121
ip netns exec netns1 ip -6 a a dev ip6tnl1 2001:1235::123 remote 2001:1235::121

 include/net/ip6_tunnel.h |  1 +
 include/net/ip_tunnels.h |  2 +-
 net/ipv4/ip_gre.c        |  4 ++--
 net/ipv4/ip_tunnel.c     | 42 +++++++++++++++++++++++++++---------------
 net/ipv4/ipip.c          |  3 +--
 net/ipv6/ip6_gre.c       |  5 +++++
 net/ipv6/ip6_tunnel.c    | 41 +++++++++++++++++++++++++++++++----------
 net/ipv6/sit.c           |  4 ++--
 8 files changed, 70 insertions(+), 32 deletions(-)

Comments are welcome.

Regards,
Nicolas
