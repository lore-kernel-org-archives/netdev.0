From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
 window.
Date: Wed, 09 Dec 2009 12:55:31 -0800
Message-ID: <1260392131.5351.43.camel@Joe-Laptop.home>
References: <pvmk4wvc3eb.fsf@chavey.mtv.corp.google.com>
	 <4B20098C.8040102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chavey@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	therbert@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1057 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757751AbZLIUz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 15:55:26 -0500
In-Reply-To: <4B20098C.8040102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-12-09 at 21:33 +0100, Eric Dumazet wrote:
> Le 09/12/2009 21:13, chavey@google.com a =C3=A9crit :
> > Add a sysctl, tcp_init_rcv_wnd, to set the TCP initial receive wind=
ow
> > size advertised by passive and active TCP connections.
> > index f1813bc..7567edd 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -2248,6 +2248,11 @@ static int do_tcp_setsockopt(struct sock *sk=
, int level,
> >  		break;
> >  #endif
> > =20
> > +	case TCP_INIT_RCV_WND:
> > +		val =3D min_t(int, val, TCP_INIT_RCV_WND_MAX);
> > +		tp->rx_opt.init_rcv_wnd =3D val;
> > +		break;
> > +
>=20
> If user pass val =3D -1, you end with init_rcv_wnd =3D 255
>=20
> Is it what you want ?
> Probably not :)

I believe min_t() is superfluous now because:
+               .proc_handler   =3D proc_dointvec_minmax,
+               .extra1         =3D &zero,
+               .extra2         =3D &tcp_init_rcv_wnd_max


