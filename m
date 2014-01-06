From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: don't install anycast address for /128 addresses on routers
Date: Mon, 6 Jan 2014 17:53:14 +0100
Message-ID: <20140106165314.GC10204@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fx.lebail@yahoo.com, thaller@redhat.com, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42634 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbaAFQxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 11:53:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It does not make sense to create an anycast address for an /128-prefix.
Suppress it.

As 32019e651c6fce ("ipv6: Do not leave router anycast address for /127
prefixes.") shows we also may not leave them, because we could accident=
ally
remove an anycast address the user has allocated or got added via anoth=
er
prefix.

Cc: Fran=C3=A7ois-Xavier Le Bail <fx.lebail@yahoo.com>
Cc: Thomas Haller <thaller@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6c16345..43c8220 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1677,7 +1677,7 @@ void addrconf_leave_solict(struct inet6_dev *idev=
, const struct in6_addr *addr)
 static void addrconf_join_anycast(struct inet6_ifaddr *ifp)
 {
 	struct in6_addr addr;
-	if (ifp->prefix_len =3D=3D 127) /* RFC 6164 */
+	if (ifp->prefix_len >=3D 127) /* RFC 6164 */
 		return;
 	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
 	if (ipv6_addr_any(&addr))
@@ -1688,7 +1688,7 @@ static void addrconf_join_anycast(struct inet6_if=
addr *ifp)
 static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
 {
 	struct in6_addr addr;
-	if (ifp->prefix_len =3D=3D 127) /* RFC 6164 */
+	if (ifp->prefix_len >=3D 127) /* RFC 6164 */
 		return;
 	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
 	if (ipv6_addr_any(&addr))
--=20
1.8.4.2
