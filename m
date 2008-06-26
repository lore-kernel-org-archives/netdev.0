From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 2/2] fs_enet: MDIO on GPIO support
Date: Thu, 26 Jun 2008 13:21:23 +0200
Message-ID: <200806261321.24338.laurentp@cse-semaphore.com>
References: <200805261152.37636.laurentp@cse-semaphore.com> <48592322.3090201@pobox.com> <200806181716.40362.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1356336.k58zgoD23A";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Scott Wood <scottwood@freescale.com>, vbordug@ru.mvista.com,
	netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:13390 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752162AbYFZLV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 07:21:27 -0400
In-Reply-To: <200806181716.40362.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1356336.k58zgoD23A
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Jeff, Scott,

On Wednesday 18 June 2008 17:16, Laurent Pinchart wrote:
> On Wednesday 18 June 2008 17:00, Jeff Garzik wrote:
> > Laurent Pinchart wrote:
> > > Hi Scott,
> > >=20
> > > On Monday 16 June 2008 18:34, Scott Wood wrote:
> > >> On Mon, Jun 16, 2008 at 10:57:02AM +0200, Laurent Pinchart wrote:
> > >>> On Monday 26 May 2008 11:53, Laurent Pinchart wrote:
> > >>>> Port the fs_enet driver to support the MDIO on GPIO driver for PHY
> > >>>> access in addition to the mii-bitbang driver.
> > >>> Now that 1/2 has been applied by Jeff, could this one make it to=20
> > >>> powerpc-next ?
> > >> This patch should probably go through Jeff as well...
> > >=20
> > > Jeff, what's your opinion on this ?
> > >=20
> > >> Acked-by: Scott Wood <scottwood@freescale.com>
> > >>
> > >>>> -	data =3D of_get_property(phynode, "reg", &len);
> > >>>> -	if (!data || len !=3D 4)
> > >>>> -		goto out_put_mdio;
> > >>>> +	bus_id =3D of_get_gpio(mdionode, 0);
> > >>>> +	if (bus_id < 0) {
> > >>>> +		struct resource res;
> > >>>> +		ret =3D of_address_to_resource(mdionode, 0, &res);
> > >>>> +		if (ret)
> > >>>> +			goto out_put_mdio;
> > >>>> +		bus_id =3D res.start;
> > >>>> +	}
> > >>>> =20
> > >>>> -	snprintf(fpi->bus_id, 16, "%x:%02x", res.start, *data);
> > >>>> +	snprintf(fpi->bus_id, 16, "%x:%02x", bus_id, *data);
> >=20
> > What are the patch dependencies, if any?
> >=20
> > My general rule is, anytime I see 80%+ of the patch dealing with=20
> > arch-specific API functions (such as OF resource stuff), I tend to=20
> > prefer that goes via an arch tree.
> >=20
> > If it's a networking change, of course I'd prefer it came in my directi=
on.
>=20
> The patch modifies the way the Freescale SoC fs_enet driver computes the =
PHY=20
> bus_id field when it connects to a PHY.
>=20
> The 'legacy' binding method was to use the MDIO general purpose I/O regis=
ter=20
> address to identify the mii bus. My first patch (OpenFirmware GPIO based =
MDIO=20
> bitbang driver) introduces a new binding using the GPIO library.
>=20
> With this patch the mii bus is now identified by the GPIO lib I/O resourc=
e=20
> number if available and falls back to the register address when the devic=
e=20
> tree uses the legacy binding.
>=20
> There should be no dependencies. When the OF GPIO support is not selected=
=20
> linux/of_gpio.h will define of_get_gpio() as a stub, so the fs_enet drive=
r=20
> will fall back to the legacy binding.

Have we reached a consensus on which tree the patch should go to ?

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1356336.k58zgoD23A
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIY3u08y9gWxC9vpcRAifyAJ90DWnya7fYbNRJcOy5NtxjTplfvwCgxk6U
w1PNM1gpYtAmI4QsZCKc2ok=
=insJ
-----END PGP SIGNATURE-----

--nextPart1356336.k58zgoD23A--
