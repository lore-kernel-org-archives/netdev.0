From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: DM9000 issue with mem resource management
Date: Fri, 6 Jun 2008 11:11:59 +0200
Message-ID: <200806061112.02081.laurentp@cse-semaphore.com>
References: <200806051743.00614.laurentp@cse-semaphore.com> <20080605174030.GM11277@trinity.fluff.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1691468.9So7XvMaPf";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:53200 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751406AbYFFJMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 05:12:05 -0400
In-Reply-To: <20080605174030.GM11277@trinity.fluff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1691468.9So7XvMaPf
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Ben,

On Thursday 05 June 2008 19:40, Ben Dooks wrote:
> On Thu, Jun 05, 2008 at 05:42:58PM +0200, Laurent Pinchart wrote:
> > Hi everybody,
> >=20
> > I ran into a resource-related bug in the DM9000 driver.
> >=20
> > When the platform device has only 2 resources, dm9000_probe() doesn't s=
et=20
> > db->irq_res, which results in a segfault when the pointer gets
> > dereferenced in dm9000_open().
> >=20
> > I tried to fix the issue, and found out that the resource management co=
de
> > is quite broken.
>=20
> Personally, I'm thinking about just removing the case for 2, and making it
> three resources only. The following in-kernel machines use the following
> resources:
>=20
> arch/arm/mach-at91/board-sam9261ek.c			3
> arch/arm/mach-pxa/cm-x270.c				3
> arch/arm/mach-pxa/em-x270.c				3
> arch/arm/mach-pxa/trizeps4.c				3
> arch/arm/mach-pxa/colibri.c				3
> arch/arm/mach-s3c2410/mach-bast.c			3
> arch/arm/mach-s3c2410/mach-vr1000.c			3
> arch/blackfin/mach-bf527/boards/ezkit.c			2
> arch/blackfin/mach-bf533/boards/H8606.c			2
> arch/blackfin/mach-bf533/boards/ip0x.c			3
> arch/blackfin/mach-bf537/boards/generic_board.c		2
> arch/blackfin/mach-bf537/boards/stamp.c			2
>=20
> As you can see, the #3 outweigh the #2. Unless anyone else objects, I
> will add a patch to reduce this to the case where the driver expects
> 3 resources, and ask the users of #2 to submit changes for their
> bots.

I've just had a look at the #2 boards and there's something I don't get. My=
=20
understanding is that the 2 resources case is used to pass ioremap()ed memo=
ry=20
to the driver, while the 3 resources case is used to pass physical addresse=
s.=20
This is what the driver currently does. Does it work by sheer luck due to a=
=20
global 1-to-1 mapping on arm ?

Best regards,

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1691468.9So7XvMaPf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBISP9i8y9gWxC9vpcRAq3nAKCq0XbCWyn8WyIfLKHGXh702OwVVACgj0FO
4etZ1TwRZV2QrfB1gu5GD5A=
=4wkl
-----END PGP SIGNATURE-----

--nextPart1691468.9So7XvMaPf--
