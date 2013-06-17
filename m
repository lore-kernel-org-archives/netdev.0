From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 0/7] Fixing dma mask setting in various network drivers
Date: Mon, 17 Jun 2013 13:35:41 -0700
Message-ID: <1371501341.2133.130.camel@jtkirshe-mobl>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	 <20130611111230.000062d2@unknown>
	 <20130617140145.GH2718@n2100.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SFmV/oVaaUD7+v8N1Ru1"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Rasesh Mody <rmody@brocade.com>,
	Tushar Dave <tushar.n.dave@intel.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57720 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752587Ab3FQUfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 16:35:46 -0400
In-Reply-To: <20130617140145.GH2718@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SFmV/oVaaUD7+v8N1Ru1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-06-17 at 15:01 +0100, Russell King - ARM Linux wrote:
> On Tue, Jun 11, 2013 at 11:12:30AM -0700, Jesse Brandeburg wrote:
> > This is my proposed change to the intel drivers.  Comments?
> >=20
> > +	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> > +		pci_using_dac =3D true;
> > +		/* coherent mask for the same size will always succeed if
> > +		 * dma_set_mask does
> > +		 */
> > +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
> > +	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
> > +		pci_using_dac =3D false;
> > +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> > +	} else {
> > +		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
> > +			 __func__, err);
> > +		err =3D -EIO;
> > +		goto err_dma;
> >  	}
> >=20
>=20
> So, will you be going with this change rather than mine, which apparantly
> Jeff queued?  Please let me know what you decide so I can keep my private
> git tree in sync with what you've decided to avoid conflicting with
> further dma-mask changes which I'm working on.
>=20
> Thanks.

I thought the kernel helper function dma_set_mask_and_coherent(...) was
the best solution.

I dropped your original series of patches from my queue since it
appeared that there was a better alternative to this solution.

--=-SFmV/oVaaUD7+v8N1Ru1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRv3MdAAoJEOVv75VaS+3OBAEQAKUK+IQ7irshJMHhAW9fVOUi
9cOHUhg8R+EtuAT5Kc5b4C+RFObJHwouedIufmmTUCh1V0QPqXJKnRbHdguR9HsV
KDB6CGmDsAnGXrImRXG9fnRJEh7LKKudJwjZfL9m8PH8eIImxDwuuU8VM0iuBo0K
KUyd0eZ+L6tYs6cbm8I3b9zgvBfygIZeLKAm08wosI1qrhQcw1ohOVW9YWTSOVQT
IHHhOdSO9cRFq/6y06YufJLDEqa3/9951OeXRxQcXvQyfZiJAVbMJqYIdHh3VDF3
Bo4wI0RkeBaahYXa2GL6mSDUTxHP2kuFTaFwty7dwm0U1gPbm3glB2gjVPJcRbw1
7cvsSDWXMaTeu6lEu3WZlR08Ud64Jhv6q/EbPJPYjrayWDHHGEs/PSbicM/x7SZD
6DbYNLzffoq7ryj7VRQ95xtWtQ9UGWV5SP4lbjx9/FYY8e33EXXZ5tiyMqnknCDw
ODu7ZSv4Pitm3AkJ1NDpzo8HK9+9mZRSCQfc086yxRywpCYWOKhhLvDa1vP72SuD
dEZhQdrnsaNggtc6Stleo0guLNhcTT7Jvt7xkXH6bEN9d8pEQa/HUnVRN0DtREyy
FiyL4urNbQiSFL7VfNl2Oe6HshttVKnEgCobKkByNIYxjXAEmE2pYmYofK0vAlkN
/5zpS59UzPhs3gf5sAjU
=o92K
-----END PGP SIGNATURE-----

--=-SFmV/oVaaUD7+v8N1Ru1--
