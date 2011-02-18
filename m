From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] net: provide default_advmss() methods to blackhole
 dst_ops
Date: Fri, 18 Feb 2011 14:44:32 +0100
Message-ID: <1298036672.6201.65.camel@edumazet-laptop>
References: <20110218050321.10415.qmail@science.horizon.com>
	 <1298010735.2642.9.camel@edumazet-laptop>
	 <1298023023.2595.170.camel@edumazet-laptop>
	 <AANLkTi=GRPWNWZuORx1zoJJURE-drqEoMdTuKB9LZ8Ux@mail.gmail.com>
	 <1298035443.6201.51.camel@edumazet-laptop>
	 <AANLkTi=O1LZzSc8=qMX=R3rJpCVL8eWr1eo6NkiZXS0m@mail.gmail.com>
	 <1298036005.6201.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: George Spelvin <linux@horizon.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34592 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab1BRNom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 08:44:42 -0500
In-Reply-To: <1298036005.6201.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 14:33 +0100, Eric Dumazet a =C3=
=A9crit :

> I had this exact idea but found we need struct net pointer to get thi=
s
> value, not provided in parameters, so I falled back to the 256 value.
>=20
>=20

Hmm, reading again this stuff, maybe we can just use
ipv4_default_advmss() instead of a custom one.

dst->dev should be available

[PATCH] net: provide default_advmss() methods to blackhole dst_ops

Commit 0dbaee3b37e118a (net: Abstract default ADVMSS behind an
accessor.) introduced a possible crash in tcp_connect_init(), when
dst->default_advmss() is called from dst_metric_advmss()

Reported-by: George Spelvin <linux@horizon.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Roland Dreier <roland@purestorage.com>
CC: Changli Gao <xiaosuo@gmail.com>
CC: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/ipv4/route.c |    1 +
 net/ipv6/route.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 788a3e7..6ed6603 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2722,6 +2722,7 @@ static struct dst_ops ipv4_dst_blackhole_ops =3D =
{
 	.destroy		=3D	ipv4_dst_destroy,
 	.check			=3D	ipv4_blackhole_dst_check,
 	.default_mtu		=3D	ipv4_blackhole_default_mtu,
+	.default_advmss		=3D	ipv4_default_advmss,
 	.update_pmtu		=3D	ipv4_rt_blackhole_update_pmtu,
 };
=20
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1c29f95..a998db6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -128,6 +128,7 @@ static struct dst_ops ip6_dst_blackhole_ops =3D {
 	.destroy		=3D	ip6_dst_destroy,
 	.check			=3D	ip6_dst_check,
 	.default_mtu		=3D	ip6_blackhole_default_mtu,
+	.default_advmss		=3D	ip6_default_advmss,
 	.update_pmtu		=3D	ip6_rt_blackhole_update_pmtu,
 };
=20


