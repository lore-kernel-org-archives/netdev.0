From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH,CFT] dynamic struct mii_bus allocation
Date: Fri, 3 Oct 2008 11:36:01 +0200
Message-ID: <200810031136.13365.laurentp@cse-semaphore.com>
References: <20081002101508.GA31074@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1159036102=="
Cc: Eugene Konev <ejka@imfi.kspu.ru>, Bryan Wu <cooloney@kernel.org>,
	Li Yang <leoli@freescale.com>, Haavard Skinnemoen <hskinnemoen@atmel.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Scott Wood <scottwood@freescale.com>,
	Andy Fleming <afleming@freescale.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, Michael Chan <mchan@broadcom.com>,
	Olof Johansson <olof@lixom.net>, Manuel Lauss <manuel.lauss@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20081002101508.GA31074@xi.wantstofly.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============1159036102==
Content-Type: multipart/signed;
  boundary="nextPart2012623.OmE7aLVuo2";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2012623.OmE7aLVuo2
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Lennert,

On Thursday 02 October 2008, Lennert Buytenhek wrote:
> Hi *,
>=20
> You're listed as maintainer of one of the network drivers in the tree
> that use phylib.  Available at the URL below is a change to the phylib
> API (dynamic allocation of struct mii_bus, which is needed for hooking
> up mdio buses into the device tree) that needs corresponding mdio bus
> driver changes.  I've patched all mdio bus drivers I could find, and
> tried not to break anything, but it's possible I might have
> inadvertently broken something, so I'd like you to test these changes
> and let me know if they work for you or not:
>=20
> 	git://git.marvell.com/phylib.git master
>=20
> As a side-effect of the last patch, you should end up with a list of
> mdio buses in your system in /sys/class/mdio_bus.
>=20
>=20
> thanks,
> Lennert
>=20
>=20
> The following changes since commit e69c4e0f1210450841e40716894ba6a877b31d=
52:
>   Vlad Yasevich (1):
>         sctp: correctly save sctp_adaptation from parameter.
>=20
> are available in the git repository at:
>=20
>   git://git.marvell.com/phylib.git master
>=20
> Lennert Buytenhek (5):
>       phylib: phy_mii_ioctl() fixes
>       phylib: add mdiobus_{read,write}
>       phylib: rename mii_bus::dev to mii_bus::parent
>       phylib: move to dynamic allocation of struct mii_bus
>       phylib: give mdio buses a device tree presence
>=20
>  arch/powerpc/platforms/82xx/ep8248e.c     |    2 +-
>  arch/powerpc/platforms/pasemi/gpio_mdio.c |    6 +-
>  drivers/net/au1000_eth.c                  |   43 ++++++---
>  drivers/net/au1000_eth.h                  |    2 +-
>  drivers/net/bfin_mac.c                    |   31 ++++---
>  drivers/net/bfin_mac.h                    |    2 +-
>  drivers/net/cpmac.c                       |   51 ++++++----
>  drivers/net/fec_mpc52xx_phy.c             |    8 +-
>  drivers/net/fs_enet/mii-bitbang.c         |    9 +-
>  drivers/net/fs_enet/mii-fec.c             |    8 +-
>  drivers/net/gianfar_mii.c                 |    9 +-
>  drivers/net/macb.c                        |   49 ++++++----
>  drivers/net/macb.h                        |    2 +-
>  drivers/net/mv643xx_eth.c                 |   32 ++++---

Just a side note, the patch "phylib: rename mii_bus::dev to mii_bus::parent=
" seems to do a lot more than just renaming mii_bus::dev to mii_bus::parent=
 in drivers/net/mv643xx_eth.c. You might have inadvertently committed unrel=
ated changes.

>  drivers/net/phy/fixed.c                   |   29 ++++--
>  drivers/net/phy/mdio-bitbang.c            |    4 +-
>  drivers/net/phy/mdio-ofgpio.c             |   11 +-

Works fine for me. For the mdio-ofgpio part:

Acked-by: Laurent Pinchart <laurentp@cse-semaphore.com>

BTW your "phylib: move to dynamic allocation of struct mii_bus" patch fixes=
 a double free in drivers/net/phy/mdio-ofgpio.c. Thanks for catching this.

>  drivers/net/phy/mdio_bus.c                |  144 +++++++++++++++++++++++=
+++
>  drivers/net/phy/phy.c                     |   54 +----------
>  drivers/net/sb1250-mac.c                  |   36 +++++---
>  drivers/net/sh_eth.c                      |    4 +-
>  drivers/net/tc35815.c                     |   45 ++++++----
>  drivers/net/tg3.c                         |   66 +++++++-------
>  drivers/net/tg3.h                         |    2 +-
>  drivers/net/ucc_geth_mii.c                |    9 +-
>  include/linux/phy.h                       |   54 ++++++++++--
>  26 files changed, 456 insertions(+), 256 deletions(-)

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart2012623.OmE7aLVuo2
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEABECAAYFAkjl540ACgkQ8y9gWxC9vpdcMwCgkJQXknqBlqV4xGnmG5KkBINM
OM4AniqG7sXP2367SJ9C7O+qLVxH3iyp
=4LXh
-----END PGP SIGNATURE-----

--nextPart2012623.OmE7aLVuo2--

--===============1159036102==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1159036102==--
