From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Wed, 22 Sep 2004 03:14:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922011401.GK3236@sunbeam.de.gnumonks.org>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org> <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi> <20040922.010428.104988024.yoshfuji@linux-ipv6.org> <1095784761.3934.52.camel@tim.rtg.net> <20040921173134.GC12132@wotan.suse.de> <1095789507.3934.69.camel@tim.rtg.net> <20040921181525.GB18938@wotan.suse.de> <20040921203404.GA3236@sunbeam.de.gnumonks.org> <1095800316.3934.88.camel@tim.rtg.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4oF+6Ged69J0+4/e"
Cc: Andi Kleen <ak@suse.de>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Gardner <timg@tpi.com>
Content-Disposition: inline
In-Reply-To: <1095800316.3934.88.camel@tim.rtg.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4oF+6Ged69J0+4/e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 21, 2004 at 02:58:37PM -0600, Tim Gardner wrote:
>=20
> > My personal (simplistic) favourite is still a simple threshold (absolute
> > value / percentage) for incomplete neighbour entries. This way we make
> > sure that we cannot starve 'real' (fully resolved) entries at the cost
> > of incomplete ones.
> >=20
> > > -Andi
>=20
> It's not like NUD doesn't already have an overflow policy.
> neigh_forced_gc() performs a cleanup on NUD_INCOMPLETE entries when
> gc_thresh3 is exceeded.

No, that's not what it does.  neigh_forced_gc explicitly only elects
INCOMPLETE entries that exist for at least n->parms_retrans_time in
order to avoid flooding the network with too many arp/neighbour
requests (since we could delete an incomplete one before the reply
arrives, and could do this for quite some time over and over again).

That's been my point all over this discussion...

> rtg
> timg@tpi.com http://www.tpi.com
> 406-443-5357(MT) 503-601-0234(OR)

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--4oF+6Ged69J0+4/e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBUNHZXaXGVTD0i/8RAlkMAJ9mvfHWw3RXZPVGOpP3kfaKIftRfQCgrCnl
pucwnLRJR1ReHlM2HlcPrfM=
=smO9
-----END PGP SIGNATURE-----

--4oF+6Ged69J0+4/e--
