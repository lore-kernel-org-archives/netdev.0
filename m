From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v3 net-next 1/2] ethtool: Support for configurable RSS
 hash key
Date: Sun, 09 Mar 2014 23:23:02 +0000
Message-ID: <1394407382.15968.84.camel@deadeye.wl.decadent.org.uk>
References: <1393589141-10597-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <0e1d7b54-dcbd-446d-b1c9-644086da138f@CMEXHTCAS2.ad.emulex.com>
	 <1394063979.2861.25.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C889D94@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HnQGBigPJmqENraXYzgQ"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51807 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751073AbaCIXXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 19:23:05 -0400
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C889D94@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HnQGBigPJmqENraXYzgQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-06 at 14:23 +0000, Venkata Duvvuru wrote:
> > > + * @get_rxfh: Get the contents of the RX flow hash indirection table=
 and
> > hash
> > > + *	key.
> > > + *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
> > > + *	returns zero.
> >=20
> > Shouldn't that 'and' be an 'or'?  I.e. this is only called if the drive=
r exposes both
> > the key and the indirection table.
> What about the existing drivers those support only indirection configurat=
ion.

Right, I forgot to revise this after reading further.

[...]
> > > +	rss_info->indir_size =3D user_indir_size;
> > > +	rss_info->key_size =3D user_key_size;
> > > +	ret =3D dev->ethtool_ops->get_rxfh(dev, rss_info);
> >=20
> > I think it would be better to pass the driver two separate pointers int=
o the
> > buffer, one for the indirection table and one for the key.
> The intention is to avoid changing "get_rxfh/set_rxfh" interface every
> time a new configurable parameter is introduced.

OK.

> > > +	if ((user_indir_size && ((user_indir_size !=3D 0xDEADBEEF) &&
> > > +				 user_indir_size !=3D dev_indir_size)) ||
> > > +	    (user_key_size && (user_key_size !=3D dev_key_size)))
> > > +		return -EINVAL;
> > > +
> > > +	if (user_indir_size && user_indir_size !=3D 0xDEADBEEF)
> > > +		indir_bytes =3D user_indir_size * sizeof(rss_info->rss_config[0]);
> >=20
> > Why is 0xDEADBEEF special?
> Since 0 is used as a hint to reset to default, we should have a way to
> hint that indirection table configuration is not requested in this
> context.

That's not necessary, as you can read and then write back the same
values.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-HnQGBigPJmqENraXYzgQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxz31ue/yOyVhhEJAQrJvg/5AQfg8ucmaJKG7hM4EpYthQJlcgQdFRxe
4aSlFeWT1GcdPfU0YFhj+1StSQ5LoxKyLedoehbVS+x/JRCekBM9uPQgf5SMjP4b
k99QoahHt0389L8+Trv8rYipCagCb1rH17yM9WqS7eZi3W6ZpENixde7gm1YXZTn
dGLI2uoStq6QhnDKJ5k/o0gm3soGKMn7MECJ5wQ5k30aWMNWO3B5nT6vHgGMonG5
oLHGtcCQiKUs7pXZNKLwb0r5bCCW+nOV11X+oWTayi0Kx9JpgHznpqqPlihakdsp
i7bZlZ9GF343CrCeV4JTCnQpe6nVsJnwRDV1eKNj8PO9yTlkMCR/dJUp3XO/Wng+
D2oE5LTQvIbTpjWrTiWdrrg6allpi+szo7MlWEmrivmB0FSx1q3CF+/Q5CYoI9NE
IMKGzFxz64K/HqgyWJ6akqDdvfrc015VxXo63BBPEs7CNO7Z7ZpjuUN/+MS9NPO0
nRk5sR4J8qltOOjU1rXI4mJ1Adnh13TYgpOj8Kba6tVZR+q2bB2YZGusOEPPa2D/
uzLiWeYy/tzttlOAlcKg/iPb/7dwm+0x10i0moXMgeiJzAtZmwW5yD/VYNxiZHyV
dZIjLSqjJDuw+GZRHC6d7IWXJcGbOv51kd2/CWrpwE8wLkyjddi5EPNGWGqqqY2m
jGHxEf9FxbI=
=OVD8
-----END PGP SIGNATURE-----

--=-HnQGBigPJmqENraXYzgQ--
