From: yoshfuji@linux-ipv6.org
Subject: [PATCH] Do not leave router anycast address for /127 prefixes.
Date: Mon, 25 Jul 2011 06:44:34 +0900
Message-ID: <1311543874-16901-1-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Brian Haley <brian.haley@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45335 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752200Ab1GXVuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2011 17:50:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Original commit 2bda8a0c8af... "Disable router anycast
address for /127 prefixes" says:

|   No need for matching code in addrconf_leave_anycast() as it
|   will silently ignore any attempt to leave an unknown anycast
|   address.

After analysis, because 1) we may add two or more prefixes on the
same interface, or 2)user may have manually joined that anycast,
we may hit chances to have anycast address which as if we had
generated one by /127 prefix and we should not leave from subnet-
router anycast address unconditionally.

CC: Bj=C3=B8rn Mork <bjorn@mork.no>
CC: Brian Haley <brian.haley@hp.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a06c53c..a55500c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1481,6 +1481,8 @@ static void addrconf_join_anycast(struct inet6_if=
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
1.7.0.4

