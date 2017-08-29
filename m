From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v3 02/13] phy: add the mvebu cp110 comphy driver
Date: Tue, 29 Aug 2017 13:23:40 +0200
Message-ID: <20170829112340.GB31552@kwain>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-3-antoine.tenart@free-electrons.com>
 <50072fdd-d370-8518-a9f4-73e121114e67@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="uQr8t48UFsdbeI+V"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, andrew@lunn.ch, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50072fdd-d370-8518-a9f4-73e121114e67@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uQr8t48UFsdbeI+V
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kishon,

On Tue, Aug 29, 2017 at 04:34:17PM +0530, Kishon Vijay Abraham I wrote:
> On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
> > =20
> > +config PHY_MVEBU_CP110_COMPHY
> > +	tristate "Marvell CP110 comphy driver"
> > +	depends on ARCH_MVEBU && OF
>=20
> (ARCH_MVEBU || COMPILE_TEST) above..

Sure, I'll update.

> > +static const struct mvebu_comhy_conf mvebu_comphy_cp110_modes[] =3D {
> > +	/* lane 0 */
> > +	MVEBU_COMPHY_CONF(0, 1, PHY_MODE_SGMII, 0x1),
> > +	/* lane 1 */
> > +	MVEBU_COMPHY_CONF(1, 2, PHY_MODE_SGMII, 0x1),
> > +	/* lane 2 */
> > +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_SGMII, 0x1),
> > +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_10GKR, 0x1),
> > +	/* lane 3 */
> > +	MVEBU_COMPHY_CONF(3, 1, PHY_MODE_SGMII, 0x2),
> > +	/* lane 4 */
> > +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_SGMII, 0x2),
> > +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_10GKR, 0x2),
> > +	MVEBU_COMPHY_CONF(4, 1, PHY_MODE_SGMII, 0x1),
> > +	/* lane 5 */
> > +	MVEBU_COMPHY_CONF(5, 2, PHY_MODE_SGMII, 0x1),
> > +};
>=20
> IMHO all the lane and mode configuration should come from dt. That would =
make
> it more reusable when comphy is configured differently.

These connexions between engines and the comphy lanes are inside the
SoC. They won't change for a given SoC, and the actual configuration is
at the board level to know what is connected to the output of a given
lane, which is already described into the dt (the lane phandle).

So I think we can keep this inside the driver, and we'll had other
tables if the same comphy is ever used in another SoC.

What do you think?

> > +static const struct phy_ops mvebu_comphy_ops =3D {
> > +	.power_on	=3D mvebu_comphy_power_on,
> > +	.power_off	=3D mvebu_comphy_power_off,
> > +	.set_mode	=3D mvebu_comphy_set_mode,
>=20
> missing .owner

I'll fix that.

> > +static struct phy *mvebu_comphy_xlate(struct device *dev,
> > +				      struct of_phandle_args *args)
> > +{
> > +	struct mvebu_comphy_priv *priv =3D dev_get_drvdata(dev);
> > +	struct mvebu_comphy_lane *lane;
> > +	int i;
> > +
> > +	if (WARN_ON(args->args[0] >=3D MVEBU_COMPHY_PORTS))
> > +		return ERR_PTR(-EINVAL);
> > +
> > +	for (i =3D 0; i < MVEBU_COMPHY_LANES; i++) {
> > +		if (!priv->phys[i])
> > +			continue;
> > +
> > +		lane =3D phy_get_drvdata(priv->phys[i]);
> > +		if (priv->phys[i] && args->np =3D=3D lane->of_node)
> > +			break;
> > +	}
>=20
> You should be able to directly use of_phy_simple_xlate to get the phy poi=
nter.
> (For that to work child node pointer should be passed in devm_phy_create).

Good idea, I'll look into this and update.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--uQr8t48UFsdbeI+V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmlTrwACgkQXE2LyK3b
vNgO2Q/9GYgxxiPBetSem0o7Bph9pXaL8vxFeMYhjBNF+F3FuozeskOxW+yDJg/L
+4Q207oEp/MXiql/0pq1SQINMPSwyBvVJlTR+Vq/RU32y8E45ceyPXDND1p9reaz
pe4Fx3Tm4ttO4st5+0z6jW4rPgqGp23G56tUpvdX4O7mFEQoClo3ctam3XjuYu6w
/jDPUMvPOhj3jayK9XaUmXPrauCQX200CqdJ7PVrkJ59gXXTIYxMSpwdlRCBDtpO
HEgCjw06nEz0SRKW8utBVAF8gaW+L/77bZKiMFKjbmuCKnFFnzlnfNLPq/6v4opL
ybrjlAKlBN+TP8MklHaPIPlxupvclSy83L2w3I4aY72S+JjdK4a14WcfzDeU2uHO
miv2jZe2SGGwoor60EhaczS44M69TJSpiM2zfFYSBBSVNyc+xbz6I7dCG30aCZkZ
U+xgxDFVxTGbNVw4NTmpIJrKfAeBIrRLh1R25guUXbIGd+IrlFuFKG2vSEPe4KTx
TfSe8o+YRWr/42p72cclmvxag0UwPNkEa2Uv29q6CwscEqMStqnvLQ6MKrkLWdIU
g/BcAK3BCNzmbkCagGuurQf93EZHO0rs6FLzf+J/1/U+oACus5Rmf4ZDXylPGZat
TSokt46gMkuH/Dd+GL8ES2fS921+fo/JeUuvyP7vcmLod3FnMTo=
=hZFb
-----END PGP SIGNATURE-----

--uQr8t48UFsdbeI+V--
