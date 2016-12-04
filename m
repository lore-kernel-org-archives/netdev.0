From: Erik Nordmark <nordmark@arista.com>
Subject: [PATCH net v2] ipv6: Allow IPv4-mapped address as next-hop
Date: Sat,  3 Dec 2016 20:57:09 -0800
Message-ID: <1480827429-22259-1-git-send-email-nordmark@arista.com>
Cc: netdev@vger.kernel.org, Bob Gilligan <gilligan@arista.com>
To: davem@davemloft.net, nordmark@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:43270 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752236AbcLDE5T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 23:57:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Made kernel accept IPv6 routes with IPv4-mapped address as next-hop.

It is possible to configure IP interfaces with IPv4-mapped addresses, and
one can add IPv6 routes for IPv4-mapped destinations/prefixes, yet prior
to this fix the kernel returned an EINVAL when attempting to add an IPv6
route with an IPv4-mapped address as a nexthop/gateway.

RFC 4798 (a proposed standard RFC) uses IPv4-mapped addresses as nexthops,
thus in order to support that type of address configuration the kernel
needs to allow IPv4-mapped addresses as nexthops.

Signed-off-by: Erik Nordmark <nordmark@arista.com>
Signed-off-by: Bob Gilligan <gilligan@arista.com>
---
v2 honoring minimum 1000 ft vertical separation between Thunderbird and patches (fixed whitespace issues)

 net/ipv6/route.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1b57e11..86bdb02 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1995,8 +1995,11 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 			   It is very good, but in some (rare!) circumstances
 			   (SIT, PtP, NBMA NOARP links) it is handy to allow
 			   some exceptions. --ANK
+			   We allow IPv4-mapped nexthops to support RFC4798-type
+			   addressing
 			 */
-			if (!(gwa_type & IPV6_ADDR_UNICAST))
+			if (!(gwa_type & (IPV6_ADDR_UNICAST |
+					  IPV6_ADDR_MAPPED)))
 				goto out;
 
 			if (cfg->fc_table) {
-- 
1.8.1.4
