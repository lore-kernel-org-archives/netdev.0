From: Harald Welte <laforge@netfilter.org>
Subject: Re: [nf-failover] Re: [1/2] CARP implementation. HA master's failover.
Date: Mon, 19 Jul 2004 22:38:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040720023842.GE27487@obroa-skai.de.gnumonks.org>
References: <1089898303.6114.859.camel@uganda> <1089898595.6114.866.camel@uganda> <1089902654.1029.23.camel@jzny.localdomain> <1089905244.6114.887.camel@uganda> <1089907622.1027.48.camel@jzny.localdomain> <1089910760.6114.967.camel@uganda> <1089912285.1028.93.camel@jzny.localdomain> <20040715235313.69897131@zanzibar.2ka.mipt.ru> <1089983064.1060.1328.camel@jzny.localdomain> <1090221367.2551.27.camel@nienna.balabit>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6WlEvdN9Dv0WHSBl"
Cc: hadi@cyberus.ca, johnpol@2ka.mipt.ru, netdev@oss.sgi.com,
        Netfilter-failover list <netfilter-failover@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: KOVACS Krisztian <hidden@balabit.hu>
Content-Disposition: inline
In-Reply-To: <1090221367.2551.27.camel@nienna.balabit>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--6WlEvdN9Dv0WHSBl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 19, 2004 at 09:16:07AM +0200, KOVACS Krisztian wrote:
>   Unfortunately this is not the case, as Evgeniy already mentioned.
> ct_sync is currently an completely in-kernel solution, with all the pros
> and cons of that. (Yes, it could be done in userspace with some minimal
> kernel code, and yes, it had a few advantages over the current solution.

I strongly disagree with this.  Or, let's say - while it is doable in
userspace, it would be at a very high cost... additional latency, lots
of more per-packet data copying, and the possibility of  being starved
by some other random userspace application.

> > I think the CARP loadbalancing feature is an improvement over what is
> > being suggested by Harald.
=20
Yes, I would also be interested in what Jamal was referring to.  I
cannot really remember having anything suggested as 'cluster manager'.

> > I have to say as well i am shocked that state is just being transfered
> > blindly - but i will deal with Harald when he shows up in Ottawa ;->
>=20
>   Would it be possible to summarize your ideas here? Yes, I know it is
> easier and faster to talk about those things in person, but
> unfortunately I won't be there in Ottawa, but am of course seriously
> interested in all ideas related to ct_sync...

I was just talking to Jamal today.  His basic proposal was something
like:

more than 90% of all connections last longer than 10 seconds, so we only
replicate connections that exist for more time.   I argued that this was
not the level of synchronization that we want to achieve, and that in
such a case he could just skip any kind of sync code and live with the
existing 'connection pickup' code of ip_conntrack (ACK from both sides
being able to establish connection even if no initial SYN handshake was
seen).

Jamal apparently wasn't aware of this.

Anyway, there will be some more discussion after my presentation at OLS
later this week.  I'll keep you posted.

>  Regards,
>    Krisztian KOVACS

btw: I think we should remove netdev for further discussions on ct_sync,
since there is a more specific mailinglist.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--6WlEvdN9Dv0WHSBl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA/IWxXaXGVTD0i/8RAn5RAJ9M5vuED2YcCM92NlXtiADFT39RagCdEoQT
KpSAfgmueJ7DiJQXEgkY2kk=
=TzTJ
-----END PGP SIGNATURE-----

--6WlEvdN9Dv0WHSBl--
