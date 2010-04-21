From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 22:58:38 +0400
Message-ID: <20100421185837.GB21249@ioremap.net>
References: <4BCE3D8D.3030500@candelatech.com> <1271808314.7895.614.camel@edumazet-laptop> <20100421003022.GA3107@ioremap.net> <1271828799.7895.1287.camel@edumazet-laptop> <20100421082559.GA32475@ioremap.net> <1271840535.7895.1612.camel@edumazet-laptop> <20100421095812.GA14778@ioremap.net> <1271849253.7895.1929.camel@edumazet-laptop> <20100421182723.GA17202@ioremap.net> <1271875416.7895.3033.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:48764 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332Ab0DUS6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 14:58:39 -0400
Content-Disposition: inline
In-Reply-To: <1271875416.7895.3033.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 08:43:36PM +0200, Eric Dumazet (eric.dumazet@gm=
ail.com) wrote:
> Le mercredi 21 avril 2010 =C3=A0 22:27 +0400, Evgeniy Polyakov a =C3=A9=
crit :
> > On Wed, Apr 21, 2010 at 01:27:33PM +0200, Eric Dumazet (eric.dumaze=
t@gmail.com) wrote:
> > > Here is the patch I use now and my test application is now able t=
o open
> > > and connect 1000000 sockets (ulimit -n 1000000)
> > >=20
> > > Trick is bind_conflict() must refuse a socket to bind to a port o=
n a non
> > > null IP if another socket already uses same port on same IP.
> > >=20
> > > Plus the previous patch sent (check a conflict before exiting the=
 search
> > > loop)
> > >=20
> > > What do you think ?
> >=20
> > Looks good, but do we want to check only reused socket's address th=
ere?
> > What if one of the sockets does not have reuse option turned on, wi=
ll it
> > break?
> >=20
>=20
> Well, if one socket doesnt have reuse option turned on, the previous
> test already works ?
>=20
> if (!reuse || !sk2->sk_reuse || sk2->sk_state =3D=3D TCP_LISTEN) {
> 	if (!sk2_rcv_saddr || !sk_rcv_saddr ||
> 	    sk2_rcv_saddr =3D=3D sk_rcv_saddr)
> 		break;
> } else if (reuse && sk2->sk_reuse &&
>            sk2_rcv_saddr &&
>            sk2_rcv_saddr =3D=3D sk_rcv_saddr)
> 	break;
>=20
> I failed to factorize this complex test :(

Damn it, I tried multiple times :)
You are right of course!

--=20
	Evgeniy Polyakov
