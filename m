From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 2/3] ethtool: Add support for DMA buffer
 settings
Date: Sat, 02 Aug 2014 14:56:22 +0100
Message-ID: <1406987782.30258.43.camel@deadeye.wl.decadent.org.uk>
References: <1406634039-15030-1-git-send-email-_govind@gmx.com>
	 <1406634039-15030-3-git-send-email-_govind@gmx.com>
	 <20140730.175306.483788306179792581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LMJvicnGmi3j76+xk5r4"
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50564 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751534AbaHBN4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 09:56:37 -0400
In-Reply-To: <20140730.175306.483788306179792581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LMJvicnGmi3j76+xk5r4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-07-30 at 17:53 -0700, David Miller wrote:
> From: Govindarajulu Varadarajan <_govind@gmx.com>
> Date: Tue, 29 Jul 2014 17:10:38 +0530
>=20
> > @@ -440,6 +440,20 @@ struct ethtool_ringparam {
> >  };
> > =20
> >  /**
> > + * struct ethtool_buffparam - DMA buffer parameters
> > + * @rx_copybreak_cur: current receive DMA buff rx_copybreak.
> > + * @rx_copybreak_min: min rx_copybreak set by driver.
> > + * @rx_copybreak_max: Max rx_copybreak set by driver.
> > + * @reserved: reserve room for future use.
> > + */
> > +struct ethtool_buffparam {
> > +	__u32	cmd;
> > +	__u32	rx_copybreak_cur;
> > +	__u32	rx_copybreak_max;
> > +	__u8	reserved[84];
> > +};
>=20
> I don't understand the reasoning behind this reserved field.
>=20
> You can't use it to add more fields later, because right now
> we'll let the user put any garbage there and thus if you add
> more fields that garbage from older apps would be interpreted
> as one of the new values.

That's OK, we can test that they're all zero.  Or add flags.

> Largely we have not been adding reserved fields to new ethtool
> structures, and this is the primary reason I guess.

Yes we have, but not consistently.

> It's a shame that when we want to add a new 32-bit knob we have
> to add an entire new struct.
>=20
> We have ethtool_value, but that's only good for one knob at a time and
> we have to allocate an entire new ethtool command value for each such
> knob.

Two commands and two function pointers!

> I really don't know what the recommend here.
>=20
> However I wonder what value that "max" thing has, I think setting the
> value to infinity is just fine, it just means every packet will be
> copied.
>=20
> So if we remove the 'max', we just have the copybreak itself, and you
> can therefore use ethtool_value and allocate the ethtool command
> numbers.
>=20
> What do you think?

How about adding a generic operation for independent tunables:

struct ethtool_get_tunable {
	u32	cmd;
	u32	id;
	u64	value, min, max;
};

struct ethtool_set_tunable {
	u32	cmd;
	u32	id;
	u64	value;
};

	int (*get_tunable)(struct net_device *, struct ethtool_get_tunable *);
	int (*set_tunable)(struct net_device *, const struct ethtool_set_tunable *=
);

The id to name mapping could be provided either through a stringset or
macros in <uapi/linux/ethtool.h>.  And perhaps we could split the id
space to allow for driver-specific tunables (while strongly discouraging
those for in-tree drivers).

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-LMJvicnGmi3j76+xk5r4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU9zuC+e/yOyVhhEJAQpI1w//R6OZDKEbLi0FHyVFNfi0j6XUraJy8FW2
YEH06F/r6TC7lEQntNdj6jJAYej8TlUzgZuTa//yhiAT0Fpo1ySvV+9f0qcbfMni
esic0dgLrl/vN7wfxaEj6qR7TrDkJZAKo1KM1XpG2tk+opaREELb/EChFxZAth18
Ky59zCbRNy89z1IT8GaFx/dU4fgFc7L74xVFfldQ02NBPR+35mmhRivdPDgkUeSZ
ot+N+ZMETuBJfjzgZOi5VE5HDtqtrSQqCZAMM+SRd8fY4efeC/y+G4ggoBFnvN5b
zqxHZY+lCCA+SG7eVYgauB33lxoPjeJhGalWMRBl4Q7B4ivJPDMgv0Ich65x7o7P
jP2UitNNmfOMOWXujr5d7gU1z/D6Zfn5mo0/PbcYIn1VEuxK3iBwSQOhGYUHDANb
MlE8QR0ErzCw9iioUjafIS136JXJLrPJ3eqBwrry5Zky1wPj4zvlKFCT0ep5P84+
TcVudMQ9a29FpFPSybvH4qC2Ntm3pDZrXUhMkwbhE3obh01Pk0KKEJC0JMoNN1rc
lXJ+YFbNnRf/MNLKEw7vlEmIQAR3eiDP60qsRIHpicEe9d5MLJrACAE60zk/zQrW
qwdZu0jgrQ4VjrcrpnnvRegyS5TKkWNaJI2Ko4Gad+2WHPB/UZNCJUIZCca5GcMP
PiEH5t4zJQE=
=MiKM
-----END PGP SIGNATURE-----

--=-LMJvicnGmi3j76+xk5r4--
