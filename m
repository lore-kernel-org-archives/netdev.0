From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH,CFT] dynamic struct mii_bus allocation
Date: Fri, 3 Oct 2008 11:49:56 +0200
Message-ID: <200810031150.00862.laurentp@cse-semaphore.com>
References: <20081002101508.GA31074@xi.wantstofly.org> <200810031136.13365.laurentp@cse-semaphore.com> <20081003094315.GA11391@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1829784.4RRkoavveI";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Michael Chan <mchan@broadcom.com>,
	Olof Johansson <olof@lixom.net>,
	Kumar Gala <galak@kernel.crashing.org>,
	Eugene Konev <ejka@imfi.kspu.ru>,
	Manuel Lauss <manuel.lauss@gmail.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Li Yang <leoli@freescale.com>,
	Scott Wood <scottwood@freescale.com>,
	Bryan Wu <cooloney@kernel.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Andy Fleming <afleming@freescale.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:3920 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbYJCJuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 05:50:04 -0400
In-Reply-To: <20081003094315.GA11391@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1829784.4RRkoavveI
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 03 October 2008, Lennert Buytenhek wrote:
> On Fri, Oct 03, 2008 at 11:36:01AM +0200, Laurent Pinchart wrote:
>=20
> > Hi Lennert,
>=20
> Hi Laurent,
>=20
>=20
> > > You're listed as maintainer of one of the network drivers in the tree
> > > that use phylib.  Available at the URL below is a change to the phylib
> > > API (dynamic allocation of struct mii_bus, which is needed for hooking
> > > up mdio buses into the device tree) that needs corresponding mdio bus
> > > driver changes.  I've patched all mdio bus drivers I could find, and
> > > tried not to break anything, but it's possible I might have
> > > inadvertently broken something, so I'd like you to test these changes
> > > and let me know if they work for you or not:
> > >=20
> > > 	git://git.marvell.com/phylib.git master
> > >=20
> > > As a side-effect of the last patch, you should end up with a list of
> > > mdio buses in your system in /sys/class/mdio_bus.
> > >=20
> > >=20
> > > thanks,
> > > Lennert
> > >=20
> > >=20
> > > The following changes since commit e69c4e0f1210450841e40716894ba6a877=
b31d52:
> > >   Vlad Yasevich (1):
> > >         sctp: correctly save sctp_adaptation from parameter.
> > >=20
> > > are available in the git repository at:
> > >=20
> > >   git://git.marvell.com/phylib.git master
> > >=20
> > > Lennert Buytenhek (5):
> > >       phylib: phy_mii_ioctl() fixes
> > >       phylib: add mdiobus_{read,write}
> > >       phylib: rename mii_bus::dev to mii_bus::parent
> > >       phylib: move to dynamic allocation of struct mii_bus
> > >       phylib: give mdio buses a device tree presence
> > >=20
> > >  arch/powerpc/platforms/82xx/ep8248e.c     |    2 +-
> > >  arch/powerpc/platforms/pasemi/gpio_mdio.c |    6 +-
> > >  drivers/net/au1000_eth.c                  |   43 ++++++---
> > >  drivers/net/au1000_eth.h                  |    2 +-
> > >  drivers/net/bfin_mac.c                    |   31 ++++---
> > >  drivers/net/bfin_mac.h                    |    2 +-
> > >  drivers/net/cpmac.c                       |   51 ++++++----
> > >  drivers/net/fec_mpc52xx_phy.c             |    8 +-
> > >  drivers/net/fs_enet/mii-bitbang.c         |    9 +-
> > >  drivers/net/fs_enet/mii-fec.c             |    8 +-
> > >  drivers/net/gianfar_mii.c                 |    9 +-
> > >  drivers/net/macb.c                        |   49 ++++++----
> > >  drivers/net/macb.h                        |    2 +-
> > >  drivers/net/mv643xx_eth.c                 |   32 ++++---
> >=20
> > Just a side note, the patch "phylib: rename mii_bus::dev to
> > mii_bus::parent" seems to do a lot more than just renaming mii_bus::dev
> > to mii_bus::parent in drivers/net/mv643xx_eth.c. You might have
> > inadvertently committed unrelated changes.
>=20
> What commit ID are you looking at?  I only see this:
>=20
> 	commit def8867a8d2a9f474262dd46179770845a420d51
> 	Author: Lennert Buytenhek <buytenh@wantstofly.org>
> 	Date:   Tue Sep 23 02:35:17 2008 +0200
>=20
> 	    phylib: rename mii_bus::dev to mii_bus::parent
> 	   =20
> 	    In preparation of giving mii_bus objects a device tree presence of
> 	    their own, rename struct mii_bus's ->dev argument to ->parent, since
> 	    having a 'struct device *dev' that points to our parent device
> 	    conflicts with introducing a 'struct device dev' representing our own
> 	    device.
> 	   =20
> 	    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> 	    Acked-by: Andy Fleming <afleming@freescale.com>
>=20
> 	[...]
>=20
> 	diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> 	index 372811a..6340081 100644
> 	--- a/drivers/net/mv643xx_eth.c
> 	+++ b/drivers/net/mv643xx_eth.c
> 	@@ -2368,7 +2368,7 @@ static int mv643xx_eth_shared_probe(struct platfor=
m_device
> 			msp->smi_bus.read =3D smi_bus_read;
> 			msp->smi_bus.write =3D smi_bus_write,
> 			snprintf(msp->smi_bus.id, MII_BUS_ID_SIZE, "%d", pdev->id);
> 	-               msp->smi_bus.dev =3D &pdev->dev;
> 	+               msp->smi_bus.parent =3D &pdev->dev;
> 			msp->smi_bus.phy_mask =3D 0xffffffff;
> 			if (mdiobus_register(&msp->smi_bus) < 0)
> 				goto out_unmap;

My bad, I was looking at my local branch which included a merge conflict re=
solution. Sorry for the noise.

> > >  drivers/net/phy/fixed.c                   |   29 ++++--
> > >  drivers/net/phy/mdio-bitbang.c            |    4 +-
> > >  drivers/net/phy/mdio-ofgpio.c             |   11 +-
> >=20
> > Works fine for me. For the mdio-ofgpio part:
> >=20
> > Acked-by: Laurent Pinchart <laurentp@cse-semaphore.com>
>=20
> Thanks!
>=20
>=20
> > BTW your "phylib: move to dynamic allocation of struct mii_bus"
> > patch fixes a double free in drivers/net/phy/mdio-ofgpio.c. Thanks
> > for catching this.
>=20
> Yeah, sorry for not reporting that separately.  (I'm not sure if it's
> worth fixing separately, since deinit probably doesn't happen very
> often.)

No worries. This is not critical, so I'm happy to let your patch fix the bu=
g.

Cheers,

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1829784.4RRkoavveI
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEABECAAYFAkjl6sgACgkQ8y9gWxC9vpe58gCgiBKLFcOHxTwQ1VTzQYVLlXKi
t/4AoLYouGUzJqbcfD4k3+dVqH3EKvyD
=k3YS
-----END PGP SIGNATURE-----

--nextPart1829784.4RRkoavveI--
