From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Sun, 25 Apr 2010 18:13:44 +0200
Message-ID: <1272212024.2069.1.camel@edumazet-laptop>
References: <1271828799.7895.1287.camel@edumazet-laptop>
	 <20100421082559.GA32475@ioremap.net>
	 <1271840535.7895.1612.camel@edumazet-laptop>
	 <20100421095812.GA14778@ioremap.net>
	 <1271849253.7895.1929.camel@edumazet-laptop>
	 <20100421182723.GA17202@ioremap.net>
	 <1271875416.7895.3033.camel@edumazet-laptop>
	 <20100421185837.GB21249@ioremap.net>
	 <1271877975.7895.3171.camel@edumazet-laptop>
	 <20100425142642.GA11411@redhat.com>  <20100425155600.GA13319@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:51491 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab0DYQNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 12:13:51 -0400
Received: by bwz19 with SMTP id 19so631059bwz.21
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 09:13:49 -0700 (PDT)
In-Reply-To: <20100425155600.GA13319@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 25 avril 2010 =C3=A0 19:56 +0400, Evgeniy Polyakov a =C3=A9=
crit :
> On Sun, Apr 25, 2010 at 05:26:42PM +0300, Michael S. Tsirkin (mst@red=
hat.com) wrote:
>=20
> > > diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_co=
nnection_sock.c
> > > index 0c5e3c3..fb6959c 100644
> > > --- a/net/ipv6/inet6_connection_sock.c
> > > +++ b/net/ipv6/inet6_connection_sock.c
> > > @@ -42,11 +42,16 @@ int inet6_csk_bind_conflict(const struct sock=
 *sk,
> > >  		if (sk !=3D sk2 &&
> > >  		    (!sk->sk_bound_dev_if ||
> > >  		     !sk2->sk_bound_dev_if ||
> > > -		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if) &&
> > > -		    (!sk->sk_reuse || !sk2->sk_reuse ||
> > > -		     sk2->sk_state =3D=3D TCP_LISTEN) &&
> > > -		     ipv6_rcv_saddr_equal(sk, sk2))
> > > -			break;
> > > +		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
> > > +			if ((!sk->sk_reuse || !sk2->sk_reuse ||
> > > +			     sk2->sk_state =3D=3D TCP_LISTEN) &&
> > > +			     ipv6_rcv_saddr_equal(sk, sk2))
> > > +				break;
> > > +			else if (sk->sk_reuse && sk2->sk_reuse &&
> > > +				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
>=20
> I suppose above line is guilty when inet6_rcv_saddr() returns NULL?
>=20

Oh its a typo

we should test ipv6_addr_any(inet6_rcv_saddr(sk))

instead of ipv6_addr_any(inet6_rcv_saddr(sk2))

(sk is AF_INET6, while sk2 could be AF_INET)

I'll submit a patch promptly


