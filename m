From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [6/6]: jenkins hash for neigh / Statistics
Date: Tue, 28 Sep 2004 00:26:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927222613.GE3236@sunbeam.de.gnumonks.org>
References: <20040925005623.2faf8faf.davem@davemloft.net> <E1CBu70-00010X-00@gondolin.me.apana.org.au> <20040927121403.767e2308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YkFcLeXky5t3pWWo"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927121403.767e2308.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YkFcLeXky5t3pWWo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 27, 2004 at 12:14:03PM -0700, David S. Miller wrote:
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>=20
> > David S. Miller <davem@davemloft.net> wrote:
> > >=20
> > > 4) The controversial/RFC patch, dorking with neigh_forced_gc()
> > >
> > > +			if (n->nud_state -=3D NUD_INCOMPLETE &&
> > > +			    reap_incomplete =3D=3D 0 &&
> > > +			    time_after(jiffies,
> > > +				       n->used + n->parms->retrans_time)) {
> > > +				num_incomplete++;
> > > +				goto next_ent;
> >=20
> > That should either be time_before, or you need to swap the arguments.
>=20
> Good catch, and it means that the code basically behaved
> as if the NUD_INCOMPLETE tests weren't even there.

which also explains why my statistics code actually never catched a
forced GC that didn't fulfill it's goal ;)

to get back at the statistics code:

As stated before, I would like to change rt_stat and ct_stat in order to
include a first 'template' line, too.  This way it is easier to write a
generic foo_stat program, that could deal with any of those statistics
files, even with new ones...  but this of course would break existing
rtstat binaries.  I personally  don't care, since it's a little-known
and little-used feature, which to my knowledge is in a lot of
distributions either non-existant [Debian] or incompatible [SuSE]. What
do you think?

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--YkFcLeXky5t3pWWo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBWJOFXaXGVTD0i/8RAttdAJ46y0WvHd7p5THuSvS2OQadK6fKtQCdH7ed
9c7s7nLPVCdrwYVGwMGb0AU=
=2OoZ
-----END PGP SIGNATURE-----

--YkFcLeXky5t3pWWo--
