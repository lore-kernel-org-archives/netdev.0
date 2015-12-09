From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 10/10] ipv6: add ipv6_addr_prefix_copy
Date: Wed,  9 Dec 2015 22:46:31 +0100
Message-ID: <1449697591-15991-11-git-send-email-alex.aring@gmail.com>
References: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Alexander Aring <alex.aring@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37122 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbbLIVrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 16:47:37 -0500
In-Reply-To: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a static inline function ipv6_addr_prefix_copy which
copies a ipv6 address prefix(argument pfx) into the ipv6 address prefix=
=2E
The prefix len is given by plen as bits. This function mainly based on
ipv6_addr_prefix which copies one address prefix from address into a ne=
w
ipv6 address destination and zero all other address bits.

The difference is that ipv6_addr_prefix_copy don't get a prefix from an
ipv6 address, it sets a prefix to an ipv6 address with keeping other
address bits. The use case is for context based address compression
inside 6LoWPAN IPHC header which keeping ipv6 prefixes inside a context
table to lookup address-bits without sending them.

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Acked-by: =C5=81ukasz Duda <lukasz.duda@nordicsemi.no>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/net/ipv6.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 9a5c9f0..6570f37 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -401,6 +401,21 @@ static inline void ipv6_addr_prefix(struct in6_add=
r *pfx,
 		pfx->s6_addr[o] =3D addr->s6_addr[o] & (0xff00 >> b);
 }
=20
+static inline void ipv6_addr_prefix_copy(struct in6_addr *addr,
+					 const struct in6_addr *pfx,
+					 int plen)
+{
+	/* caller must guarantee 0 <=3D plen <=3D 128 */
+	int o =3D plen >> 3,
+	    b =3D plen & 0x7;
+
+	memcpy(addr->s6_addr, pfx, o);
+	if (b !=3D 0) {
+		addr->s6_addr[o] &=3D ~(0xff00 >> b);
+		addr->s6_addr[o] |=3D (pfx->s6_addr[o] & (0xff00 >> b));
+	}
+}
+
 static inline void __ipv6_addr_set_half(__be32 *addr,
 					__be32 wh, __be32 wl)
 {
--=20
2.6.1
