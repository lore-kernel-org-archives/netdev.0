From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Wed, 31 May 2006 20:05:27 +0200
Message-ID: <200605312005.31067.IvDoorn@gmail.com>
References: <200605251716.00742.IvDoorn@gmail.com> <20060530214305.GA27891@electric-eye.fr.zoreil.com> <200605311931.17910.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3901130.TK2xzg5eqK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:48676 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751767AbWEaSCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 14:02:39 -0400
Received: by nf-out-0910.google.com with SMTP id n28so148934nfc
        for <netdev@vger.kernel.org>; Wed, 31 May 2006 11:02:38 -0700 (PDT)
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <200605311931.17910.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3901130.TK2xzg5eqK
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 31 May 2006 19:31, Ivo van Doorn wrote:
> On Tuesday 30 May 2006 23:43, Francois Romieu wrote:
> > Ivo van Doorn <ivdoorn@gmail.com> :
> > [...]
> > > diff --git a/drivers/input/misc/radiobtn.c b/drivers/input/misc/radio=
btn.c
> > > new file mode 100644
> > > index 0000000..8d3b84a
> > > --- /dev/null
> > > +++ b/drivers/input/misc/radiobtn.c
> > [...]
> > > +void radiobtn_poll(unsigned long data)
> >=20
> > static ?
>=20
> Good point. Will fix this immediately.
>=20
> > [...]
> > > +int radiobtn_register_device(struct radio_button *radiobtn)
> > > +{
> > > +	int status;
> > > +
> > > +	/*
> > > +	 * Check if all mandatory fields have been set.
> > > +	 */
> > > +	if (radiobtn->poll_delay =3D=3D 0 || radiobtn->button_poll =3D=3D N=
ULL)
> > > +		return -EINVAL;
> > > +
> > > +	/*
> > > +	 * Allocate, initialize and register input device.
> > > +	 */
> > > +	radiobtn->input_dev =3D input_allocate_device();
> > > +	if (!radiobtn->input_dev) {
> > > +		printk(KERN_ERR "Failed to allocate input device %s.\n",
> > > +			radiobtn->dev_name);
> > > +		return -ENOMEM;
> > > +	}
> > > +
> > > +	radiobtn->input_dev->name =3D "Radio button";
> > > +	radiobtn->input_dev->phys =3D strcat("radiobtn/", radiobtn->dev_nam=
e);
> >=20
> > The first parameter of strcat() must be big enough to contain the whole
> > string.
>=20
> Will replace it with
> sprintf(wrqu->name, "radiobtn/", radiobtn->dev_name);

Or actually, I don't think the radiobtn/ won't be actually needed as prefix.
The name passed to the radiobtn driver by the driver should be sufficient.

Ivo

--nextPart3901130.TK2xzg5eqK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEfdrraqndE37Em0gRAny/AJ9qNBfsb9QgDJwmBAIKBl9o7kr2lwCgweBr
O5mVE2eTdKEB2zA7lD1p+uw=
=plnM
-----END PGP SIGNATURE-----

--nextPart3901130.TK2xzg5eqK--
