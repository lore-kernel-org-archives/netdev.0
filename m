From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] Disable router anycast address for /127 prefixes
Date: Fri,  1 Jul 2011 13:22:10 +0200
Message-ID: <1309519330-16649-1-git-send-email-bjorn@mork.no>
References: <20110630104713.52e085dd@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48741 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755104Ab1GALmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 07:42:07 -0400
In-Reply-To: <20110630104713.52e085dd@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 6164 requires that routers MUST disable Subnet-Router anycast
for the prefix when /127 prefixes are used.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---

How about something like this?


 net/ipv6/addrconf.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 498b927..179c0f4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1470,6 +1470,8 @@ void addrconf_leave_solict(struct inet6_dev *idev=
, const struct in6_addr *addr)
 static void addrconf_join_anycast(struct inet6_ifaddr *ifp)
 {
 	struct in6_addr addr;
+	if (ifp->prefix_len =3D=3D 127) /* RFC 6164 */
+		return;
 	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
 	if (ipv6_addr_any(&addr))
 		return;
@@ -1479,6 +1481,8 @@ static void addrconf_join_anycast(struct inet6_if=
addr *ifp)
 static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
 {
 	struct in6_addr addr;
+	if (ifp->prefix_len =3D=3D 127) /* RFC 6164 */
+		return;
 	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
 	if (ipv6_addr_any(&addr))
 		return;
--=20
1.7.2.5

