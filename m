From: Henrik Austad <henrik@austad.us>
Subject: Re: [TSN RFC v2 5/9] Add TSN header for the driver
Date: Sat, 17 Dec 2016 09:53:57 +0100
Message-ID: <20161217085357.GA6392@sisyphus.home.austad.us>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
 <1481911153-549-6-git-send-email-henrik@austad.us>
 <20161216220938.GB25258@netboy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="fdj2RfSjLxBAspz7"
Cc: linux-kernel@vger.kernel.org, Henrik Austad <haustad@cisco.com>,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161216220938.GB25258@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 16, 2016 at 11:09:38PM +0100, Richard Cochran wrote:
> On Fri, Dec 16, 2016 at 06:59:09PM +0100, henrik@austad.us wrote:
> > +/*
> > + * List of current subtype fields in the common header of AVTPDU
> > + *
> > + * Note: AVTPDU is a remnant of the standards from when it was AVB.
> > + *
> > + * The list has been updated with the recent values from IEEE 1722, dr=
aft 16.
> > + */
> > +enum avtp_subtype {
> > +	TSN_61883_IIDC =3D 0,	/* IEC 61883/IIDC Format */
> > +	TSN_MMA_STREAM,		/* MMA Streams */
> > +	TSN_AAF,		/* AVTP Audio Format */
> > +	TSN_CVF,		/* Compressed Video Format */
> > +	TSN_CRF,		/* Clock Reference Format */
> > +	TSN_TSCF,		/* Time-Synchronous Control Format */
> > +	TSN_SVF,		/* SDI Video Format */
> > +	TSN_RVF,		/* Raw Video Format */
> > +	/* 0x08 - 0x6D reserved */
> > +	TSN_AEF_CONTINOUS =3D 0x6e, /* AES Encrypted Format Continous */
> > +	TSN_VSF_STREAM,		/* Vendor Specific Format Stream */
> > +	/* 0x70 - 0x7e reserved */
> > +	TSN_EF_STREAM =3D 0x7f,	/* Experimental Format Stream */
> > +	/* 0x80 - 0x81 reserved */
> > +	TSN_NTSCF =3D 0x82,	/* Non Time-Synchronous Control Format */
> > +	/* 0x83 - 0xed reserved */
> > +	TSN_ESCF =3D 0xec,	/* ECC Signed Control Format */
> > +	TSN_EECF,		/* ECC Encrypted Control Format */
> > +	TSN_AEF_DISCRETE,	/* AES Encrypted Format Discrete */
> > +	/* 0xef - 0xf9 reserved */
> > +	TSN_ADP =3D 0xfa,		/* AVDECC Discovery Protocol */
> > +	TSN_AECP,		/* AVDECC Enumeration and Control Protocol */
> > +	TSN_ACMP,		/* AVDECC Connection Management Protocol */
> > +	/* 0xfd reserved */
> > +	TSN_MAAP =3D 0xfe,	/* MAAP Protocol */
> > +	TSN_EF_CONTROL,		/* Experimental Format Control */
> > +};
>=20
> The kernel shouldn't be in the business of assembling media packets.

No, but assembling the packets and shipping frames to a destination is not=
=20
neccessarily the same thing.

A nice workflow would be to signal to the shim that "I'm sending a=20
compressed video format" and then the shim/tsn_core will ship out the=20
frames over the network - and then you need to set TSN_CVF as subtype in=20
each header.

That does not that mean you should do H.264 encode/decode *in* the kernel

Perhaps this is better placed in include/uapi/tsn.h so that userspace and=
=20
kernel share the same header?

--=20
Henrik Austad

--fdj2RfSjLxBAspz7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhU/SUACgkQ6k5VT6v45lmHDACeMkLnsLQL0nZAL0QFl/X5CLat
xAkAoLS8Tw2LMtBenyJEHT3eIpBLCRDX
=3+w7
-----END PGP SIGNATURE-----

--fdj2RfSjLxBAspz7--
