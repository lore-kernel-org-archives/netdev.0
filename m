From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] intel: make wired ethernet driver message level
 consistent
Date: Sun, 11 Mar 2012 01:57:16 -0800
Message-ID: <1331459836.27038.7.camel@jtkirshe-mobl>
References: <20120310084921.GA4647@elgon.mountain>
	 <20120310160153.1d3e5f19@nehalam.linuxnetplumber.net>
	 <1331426337.3022.106.camel@deadeye>
	 <20120310164435.70bcd0e5@nehalam.linuxnetplumber.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9CsUwvTtv3f0nXzwrA8l"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7736 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107Ab2CKJ5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Mar 2012 05:57:18 -0400
In-Reply-To: <20120310164435.70bcd0e5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9CsUwvTtv3f0nXzwrA8l
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-03-10 at 16:44 -0800, Stephen Hemminger wrote:
> On Sun, 11 Mar 2012 00:38:57 +0000
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>=20
> > On Sat, 2012-03-10 at 16:01 -0800, Stephen Hemminger wrote:
> > > Dan Carpenter noticed that ixgbevf initial default was different than
> > > the rest. But the problem is broader than that, only one Intel driver=
 (ixgb)
> > > was doing it right.
> > >=20
> > > The convention for default debug level should be consistent among
> > > Intel drivers and follow established convention.
> > [...]
> > > --- a/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-02-27 08:43:=
02.348936997 -0800
> > > +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-03-10 15:50:=
57.199452804 -0800
> > > @@ -215,7 +215,8 @@ MODULE_DESCRIPTION("Intel(R) PRO/1000 Ne
> > >  MODULE_LICENSE("GPL");
> > >  MODULE_VERSION(DRV_VERSION);
> > > =20
> > > -static int debug =3D NETIF_MSG_DRV | NETIF_MSG_PROBE;
> > > +#define DEFAULT_DEBUG_LEVEL_SHIFT 3
> >=20
> > Wonder if this should really be 2 (enable DRV and PROBE) or 3 (enable
> > DRV, PROBE and LINK; equivalent to current behaviour)?
>=20
> That is really up to intel, the link up/down is useful, but nuisance
> with lots of devices.
>=20
> > > +static int debug =3D DEFAULT_DEBUG_LEVEL_SHIFT;
> > >  module_param(debug, int, 0);
> > >  MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
> > > =20
> > > @@ -979,7 +980,7 @@ static int __devinit e1000_probe(struct
> > >  	adapter =3D netdev_priv(netdev);
> > >  	adapter->netdev =3D netdev;
> > >  	adapter->pdev =3D pdev;
> > > -	adapter->msg_enable =3D (1 << debug) - 1;
> > > +	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_S=
HIFT);
> > [...]
> >=20
> > This works, but not the way you intended.  The first parameter is
> > supposed to be a module parameter with a default of -1.  The second
> > parameter is supposed to be the bitmask to use when that default is not
> > overridden.
>=20
> I'll fix that.
>=20
>=20

Stephen, I await you updated patch with the fix, thanks!

--=-9CsUwvTtv3f0nXzwrA8l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPXHb8AAoJEOVv75VaS+3Ow7QP/A0iyjL5khzXoU0jobLhNpIE
mB7sgKzjA6MgOMcSHobt7FDsjkccj27R217OGRItOU+4a7gmqEB3UH0cfrZYFXLp
fpeC2HlhrKLfMMxBBDEHpiYU3ZUgY4rf9QWPU0SEkNe7904YjxK2YrRdjzLy9el7
Hl0L8BFKacdVeWwMUJ6lZNv1C8ZHwWCRNouRgk96SmKKM/zRUbTrd7msNpEsKyRV
2y8HsuQg0xeiqNo+jXbBb/Syd4VmlQGkD1QQJw7vIRnUCLToRhNHSZV3yGippYyr
uNFkXtGILw+vHdFSF+osHmpRfKwiq33SBJ7HHucMSmBXIJiZVO9ZaWXPwpt4t983
ODQyg3zHrKhL/fgr+pXBiP1ySeufiN9FFm9M120FNAK050boHcVaLvgYiLcFP0gy
ajwr5WcnhtVh0iXCJWcCt0e3u5+0PXmFUemZ/oQjkt+UAjykCXejeV0kMkdS0aeA
dAsVLKnjnKhIpuAGr7L7QJ5YTbCMqrt8SoSzlMRsLSlVIZbDz3dJWVgI1Y2O0e34
e103A9kqTn/CKNtUIU+ag7IEYdlvv28WiTVI+9FBpLyzO7raI1czCYx7O9dpP6Rp
pufUqQqIATPZwJhqZ+lyn28R6gMki1XA954dG46nHq6xUt+OLFtP7s9qI5Pd/Voz
tlY+OeM8pApPOGaHdZ+A
=mG8A
-----END PGP SIGNATURE-----

--=-9CsUwvTtv3f0nXzwrA8l--
