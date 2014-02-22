From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 28/35] qlcnic: Use pci_enable_msix_range()
 instead of pci_enable_msix()
Date: Sat, 22 Feb 2014 00:48:47 +0000
Message-ID: <1393030127.15717.72.camel@deadeye.wl.decadent.org.uk>
References: <cover.1392717502.git.agordeev@redhat.com>
	 <cb8eb41f672c62d1149c375bdaf97ca3328703f9.1392717503.git.agordeev@redhat.com>
	 <1393029870.15717.71.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZDW2wPQKcKj24tyYwZ5l"
Cc: linux-kernel@vger.kernel.org,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1393029870.15717.71.camel@deadeye.wl.decadent.org.uk>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ZDW2wPQKcKj24tyYwZ5l
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-02-22 at 00:44 +0000, Ben Hutchings wrote:
> On Tue, 2014-02-18 at 11:11 +0100, Alexander Gordeev wrote:
> > As result of deprecation of MSI-X/MSI enablement functions
> > pci_enable_msix() and pci_enable_msi_block() all drivers
> > using these two interfaces need to be updated to use the
> > new pci_enable_msi_range() and pci_enable_msix_range()
> > interfaces.
[...]
> > --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> > +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> > @@ -701,13 +701,17 @@ enable_msix:
> >  		for (vector =3D 0; vector < num_msix; vector++)
> >  			adapter->msix_entries[vector].entry =3D vector;
> > =20
> > -		err =3D pci_enable_msix(pdev, adapter->msix_entries, num_msix);
> > -		if (err =3D=3D 0) {
> > +		err =3D pci_enable_msix_range(pdev,
> > +					    adapter->msix_entries, 1, num_msix);
> > +
> > +		if (err =3D=3D num_msix) {
> >  			adapter->flags |=3D QLCNIC_MSIX_ENABLED;
> >  			adapter->ahw->num_msix =3D num_msix;
> >  			dev_info(&pdev->dev, "using msi-x interrupts\n");
> >  			return 0;
> >  		} else if (err > 0) {
> > +			pci_disable_msix(pdev);
> > +
> >  			dev_info(&pdev->dev,
> >  				 "Unable to allocate %d MSI-X vectors, Available vectors %d\n",
> >  				 num_msix, err);
>=20
> Well this log message is nonsense - we have no idea how many vectors are
> available any more.
>=20
> You should remove this and the retry loop that is no longer needed.

Sorry, I'm confused and this does work.  But I wonder whether it is
really an improvement over using the old API.

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-ZDW2wPQKcKj24tyYwZ5l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwfz7+e/yOyVhhEJAQqschAAyOsO5JVlsbbyZ89+oPazQWdPskBs8EQW
ClvlJPUHKwql/ng5kraTcX7IBXlHIiA3z4yG/4U9dkWNwQdbcbWZGpSvUJntecx5
qf2brCMRzmG+mFGsl8nuv82eDQYsAEGisCi8zYo9bIGnBxxfqXYGz7bQ+OzXQEXj
giFEwFbporQjRCtWvdfkaaalZ4aC6O4xWTacF1N6YBgfY2lHFzp1Gfxlpw61ZMgA
s+MZ27zgV34cc57jvR3oEkDx0JO9LpC9rqrPGszm0H5BaVlBM6fRSQSbcu8g1/KY
nmk3yBPECD/nn0r48WNg9YXl0vgpEVIUi98kpYwCI3UBvYTK+NYppz5lkNrIWyMW
zHC5v8bmdduy2iauuH/kXJnyFDjcK4jJ0p6TbugYRpiffl7p7UHwBki97D36GsD5
myygu7IEysHA9KDpb6tFdqlvhfIP98I3Pni5Z0wogV1uKbvePvSti27yEzi3c5KM
L92C9yvWO8US5swybuv2tWqPntR3hhiXqm7YS/uhsKUgMDVBWovN3XEZYocwkp71
3iIoid8rLKyuk0/XSNBNPESr+XQ88mxb9xVVfcecuHZe2dochPxUFDCTqhwHvdZj
tLZyYXxtwXCRrWjvFBGI99VI3YZK3XV3Z5KujuAfkocz9zHCoJ1WB6ByFqHkGO+f
CydlmtbEyK8=
=sdKX
-----END PGP SIGNATURE-----

--=-ZDW2wPQKcKj24tyYwZ5l--
