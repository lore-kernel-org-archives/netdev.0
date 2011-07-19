From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] ipv6: all routes share same inetpeer
Date: Tue, 19 Jul 2011 20:57:50 +0200
Message-ID: <1311101870.3113.6.camel@edumazet-laptop>
References: <1311096229.2375.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110719.103724.1461298517132188126.davem@davemloft.net>
	 <1311099638.3113.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48828 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab1GSS5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 14:57:55 -0400
Received: by wyg8 with SMTP id 8so2999109wyg.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 11:57:54 -0700 (PDT)
In-Reply-To: <1311099638.3113.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 20:20 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 19 juillet 2011 =C3=A0 10:37 -0700, David Miller a =C3=A9cri=
t :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 19 Jul 2011 19:23:49 +0200
> >=20
> > > Maybe you can find the bug before me ?
> >=20
> > I think when we add the route we cow the metrics almost immediately=
=2E
> > The daddr is, unfortunately, fully prefixed at that point.
>=20
> Yes, we shall provide a second ip6_rt_copy() argument, with the
> destination address.
>=20

Hmm, or maybe just change the dst_copy_metrics(&rt->dst, &ort->dst);
call done from ip6_rt_copy(), to avoid doing the COW if not really
needed ?

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ddef80f..5403cea 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1740,7 +1740,7 @@ static struct rt6_info * ip6_rt_copy(struct rt6_i=
nfo *ort)
 		rt->dst.input =3D ort->dst.input;
 		rt->dst.output =3D ort->dst.output;
=20
-		dst_copy_metrics(&rt->dst, &ort->dst);
+		rt->dst._metrics =3D ort->dst._metrics;
 		rt->dst.error =3D ort->dst.error;
 		rt->rt6i_idev =3D ort->rt6i_idev;
 		if (rt->rt6i_idev)



