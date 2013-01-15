From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC(v2) net-next 00/13] IPv6 rt->n removal (V2)
Date: Wed, 16 Jan 2013 01:44:25 +0900
Message-ID: <50F58769.4030708@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41290 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756779Ab3AOQo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:44:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

This is RFC (Take 2).

Some unused variable / code still remain.
Need to revisit refcounting (rt->dst.dev, rt->n->dev).

--yoshfuji

YOSHIFUJI Hideaki (13):
  ndisc: Refer/Update neigh->updated with write lock.
  ndisc: Remove tbl argument for __ipv6_neigh_lookup().
  ndisc: Introduce __ipv6_neigh_lookup_noref().
  ipv6 route: Dump gateway based on RTF_GATEWAY flag and
    rt->rt6i_gateway.
  ipv6: Introduce rt6_nexthop() to select nexthop address.
  ipv6: Do not depend on rt->n in ip6_finish_output2().
  ipv6: Do not repend on rt->n in rt6_probe().
  ipv6: Do not deoend on rt->n in ip6_dst_lookup_tail().
  ipv6: Do not depend on rt->n in rt6_check_neigh().
  ipv6: Do not depend on rt->n in ip6_pol_route().
  ipv6: Use ip6_route_output() instead of icmp6_dst_alloc().
  ipv6: Remove temporary dst for icmpv6.
  ipv6: Complete neighbour entry removal from dst_entry.

 include/net/ip6_fib.h   |    2 -
 include/net/ip6_route.h |    9 ++
 include/net/ndisc.h     |   24 +++--
 net/ipv6/ip6_fib.c      |    2 +-
 net/ipv6/ip6_output.c   |   26 ++++--
 net/ipv6/mcast.c        |    5 +-
 net/ipv6/ndisc.c        |    3 +-
 net/ipv6/route.c        |  222 ++++++++---------------------------------------
 net/ipv6/xfrm6_policy.c |    1 -
 9 files changed, 86 insertions(+), 208 deletions(-)

-- 
1.7.9.5
