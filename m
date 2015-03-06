From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 11/14] i40e: Ioremap changes
Date: Thu, 05 Mar 2015 17:55:43 -0800
Message-ID: <1425606943.2556.149.camel@jtkirshe-mobl>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1425573992-30955-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1425600978.8804.6.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-h9N8vUOg9E3cv6X2L0Nn"
Cc: davem@davemloft.net, Anjali Singhai <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32214 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921AbbCFBz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 20:55:58 -0500
In-Reply-To: <1425600978.8804.6.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-h9N8vUOg9E3cv6X2L0Nn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-06 at 00:16 +0000, Ben Hutchings wrote:
> On Thu, 2015-03-05 at 08:46 -0800, Jeff Kirsher wrote:
> [...]
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > @@ -9459,6 +9459,7 @@ static int i40e_probe(struct pci_dev *pdev,
> const struct pci_device_id *ent)
> >       struct i40e_pf *pf;
> >       struct i40e_hw *hw;
> >       static u16 pfs_found;
> > +     u32 ioremap_len;
> >       u16 link_status;
> >       int err =3D 0;
> >       u32 len;
> > @@ -9507,8 +9508,11 @@ static int i40e_probe(struct pci_dev *pdev,
> const struct pci_device_id *ent)
> > =20
> >       hw =3D &pf->hw;
> >       hw->back =3D pf;
> > -     hw->hw_addr =3D ioremap(pci_resource_start(pdev, 0),
> > -                           pci_resource_len(pdev, 0));
> > +
> > +     ioremap_len =3D min_t(int, pci_resource_len(pdev, 0),
> > +                         I40E_MAX_CSR_SPACE);
>=20
> What type do you really want ioremap_len to be, u32 or int?  (I think
> the correct answer is unsigned long as that's the ioremap() parameter
> type.)

Yeah, I agree.  Once Dave updates his net-next tree with the patches he
has accepted, I will send out a fix.

--=-h9N8vUOg9E3cv6X2L0Nn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU+QkfAAoJEOVv75VaS+3O/+EP/2ApZh3CStlOy+kMAfch6ifK
V911sI4luOpHiT7ai2ju5m3m98Hmmu3F51LhtHXm0j5U2XoZ/WGRJYdcwPcfbXXr
Nk7NAiR7DZy1T7ldVB5N/zXRfcDy1lBv2ttW/rjmGNSBieVkvT67JZY25DREwTdG
2I7b50NIR7y7rylTVUb9dodLV5cRnFLyaAABl1GIBJeJ6psJ1Yp1Ro7cCNpF3SCb
V8Y40SCnmuNKpNeE37qP/gVb/D7uXW1vNomSMiPTurrb+VHKawvbFnhECVA7v26t
aWV6ie4hgD4/Cdgfg80Lp4imsW3FnECW7Y9BG/7w1ZHrNO/m5CEPcaxaSV4MkvqG
e+JLFMYAbW39LK0YSbBFC7/T0eSjEoTg7x/Kg0ADmDYbf8RDw9cbu6ujvWgebKfo
SnAZA+b9lDI7eN2+7E+z+3jvDMHQHyZPgzW28Kj31X4j1vq2iWHX5eEqNlV4chT7
Pu0rhxYXW9JxqVtOLt5fob3uhZdkCrs1ctgQTP2crAvBsdJI6UtqceG+epMbEhZx
6Rj98G3sAgwiotxO3mQ3U1zB1sZ9DkRgTLfiZSXqop0EaPk/84Zuods8SiTF89MY
e7SiFIWIV1RNTA53gfzTpDq5J+WR+H67q+n4vUiRFYKkXomGhyPF+I/hz2f6C+qc
SNS+05p6/KftKKJBdVET
=8uF4
-----END PGP SIGNATURE-----

--=-h9N8vUOg9E3cv6X2L0Nn--
