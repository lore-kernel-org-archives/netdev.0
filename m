From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2] Disable router anycast address for /127 prefixes
Date: Wed,  6 Jul 2011 11:04:13 +0200
Message-ID: <1309943053-21437-1-git-send-email-bjorn@mork.no>
References: <20110630104713.52e085dd@nehalam.ftrdhcpuser.net> <1309519330-16649-1-git-send-email-bjorn@mork.no> <4E0DDDA5.20401@hp.com> <87y60hsvr2.fsf@nemi.mork.no> <4E0E1B85.1080906@hp.com> <87r569rpis.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Brian Haley <brian.haley@hp.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49683 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567Ab1GFJFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2011 05:05:06 -0400
In-Reply-To: <87r569rpis.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 6164 requires that routers MUST disable Subnet-Router anycast
for the prefix when /127 prefixes are used.

No need for matching code in addrconf_leave_anycast() as it
will silently ignore any attempt to leave an unknown anycast
address.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Changes since v1:
 * removed unneeded change based on review comments from Brian Haley

Thought a bit more about this and found that adding less code
makes more sense, given that the meaning is clear enough. But I
really don't have any strong meanings about this. Please apply either=20
version 1 or version 2 depending on your preferences.


Bj=C3=B8rn


 net/ipv6/addrconf.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 498b927..fef2e2e 100644
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
--=20
1.7.2.5

