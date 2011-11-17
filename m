From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 17:45:19 +0100
Message-ID: <1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EC2CA52.6020104@icdsoft.com>
	 <1321391355.2602.0.camel@edumazet-laptop> <4EC439F2.3080809@icdsoft.com>
	 <20111116223330.08de9e52@asterix.rh> <4EC4C160.6010804@icdsoft.com>
	 <20111117111145.252924f5@asterix.rh>
	 <1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117133724.59684d28@asterix.rh>
	 <1321547510.2751.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117144038.61b0525b@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57394 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab1KQQpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 11:45:23 -0500
Received: by wyh11 with SMTP id 11so2232432wyh.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 08:45:22 -0800 (PST)
In-Reply-To: <20111117144038.61b0525b@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 14:40 -0200, Flavio Leitner a =C3=A9cr=
it :
> On Thu, 17 Nov 2011 17:31:50 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le jeudi 17 novembre 2011 =C3=A0 13:37 -0200, Flavio Leitner a =C3=A9=
crit :
> > > On Thu, 17 Nov 2011 15:40:20 +0100
> > > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >=20
> > > > [PATCH] ping: dont increment ICMP_MIB_INERRORS
> > > >=20
> > > > ping module incorrectly increments ICMP_MIB_INERRORS if feeded
> > > > with a frame not belonging to its own sockets.
> > > >=20
> > > > RFC 2011 states that ICMP_MIB_INERRORS should count "the number=
 of
> > > > ICMP messages which the entiry received but determined as havin=
g
> > > > ICMP-specific errors (bad ICMP checksums, bad length, etc.)."
> > > >=20
> > > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > > CC: Vasiliy Kulikov <segoon@openwall.com>
> > >=20
> > > Yeah, they aren't ICMP specific errors and the callers already
> > > checked for checksum, lengths, and etc.. increasing that counter
> > > when necessary.
> > >=20
> > > Acked-by: Flavio Leitner <fbl@redhat.com>
> >=20
> > Thanks
> >=20
> > By the way, redirects dont work at all in net-next
>=20
> Could you be more specific? It seems to be working here.
>=20
> > Probably coming from your commit 7cc9150ebe8ec0
> > (route: fix ICMP redirect validation)
> >=20
> > Since calling __ip_route_output_key() will create the route with s =
=3D
> > 0, l =3D 0  (forcing saddr and dev->ifindex) selectors...
> >=20
> > We have to add a 'create' parameter to __ip_route_output_key() so t=
hat
> > ip_rt_redirect() doesnt create a route, only find the existing one =
in
> > cache ?
>=20
> It should receive redirect after sending a packet, so the route
> should be ready at this point.=20

I receive the redirect, but the rt->peer is updated on a different rout=
e
than the one used by my ping command.

Its updated on the specific route (source address forced, output device
forced), not on the wildcarded route my ping is using.

So next packets are still sent on old gateway...
