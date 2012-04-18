From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 03/11] batman-adv: randomize initial
 seqno to avoid collision
Date: Wed, 18 Apr 2012 08:42:03 +0200
Message-ID: <20120418064202.GA27966@ritirata.org>
References: <1334663907-22725-1-git-send-email-ordex@autistici.org>
	<1334663907-22725-4-git-send-email-ordex@autistici.org>
	<20120417.224527.288514574622832184.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	lindner_marek-LWAfsSFWpa4@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120417.224527.288514574622832184.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 17, 2012 at 10:45:27 -0400, David Miller wrote:
> From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Date: Tue, 17 Apr 2012 13:58:19 +0200
>=20
> > @@ -33,6 +33,11 @@
> >  static void bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
> >  {
> >  	struct batman_ogm_packet *batman_ogm_packet;
> > +	unsigned long random_seqno;
> > +
> > +	/* randomize initial seqno to avoid collision */
> > +	get_random_bytes(&random_seqno, sizeof(unsigned long));
> > +	atomic_set(&hard_iface->seqno, (uint32_t)random_seqno);
>=20
> This is silly.
>=20
> Just use "uint32_t" for the type of random_seqno and the sizeof passed
> to get_random_bytes.
>=20
> And here comes the magic part.
>=20
> Amazing, no ugly and pointless casts needed!

I agree :-)
Thank you for the suggestion.

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJPjmI6AAoJEFMQTLzJFOZFsYIH/3zO/mM8jSc4hs3bIR6p7r3q
AwOeKTA80Xgp3lEcbX8ftNYqNUBMm/jZaOwNMlA2MnfF0h7DcPCKbmpikJ5G86GT
Xkszkz7lfk2QIXZYof260d9jzeKbGkgJxJyOQAOpjGOne5ICSiAE8ckaT1cVRzB8
bXID8WfIxUPYmInX5evQ3uQKcoEv+m8rtC+FEmOpgn8EZyR6DMDf/gV1x/rRj9i7
OcaUPk6hZynIgCoGJUr88GllPUcAH3ri0nMWtuKehHk65dkYaIZxxF58NYstHdbE
iGcAG7OyneMQ+HbzBreXbtxvAYI4gCdqK38OmvW+yuzoy8RxJ6h6mOtO43JZFVg=
=9tCz
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--
