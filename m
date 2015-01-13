From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 5/6] net: davinci_emac: Fix ioremap for devices with MDIO
 within the EMAC address space
Date: Tue, 13 Jan 2015 14:21:49 -0600
Message-ID: <20150113202149.GZ16533@saruman>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-6-git-send-email-tony@atomide.com>
 <20150113195405.GU16533@saruman>
 <20150113195957.GH2419@atomide.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LG5jgFgJbJFFiAfj"
Cc: Felipe Balbi <balbi@ti.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Brian Hutchinson <b.hutchman@gmail.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150113195957.GH2419@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--LG5jgFgJbJFFiAfj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 13, 2015 at 11:59:58AM -0800, Tony Lindgren wrote:
> * Felipe Balbi <balbi@ti.com> [150113 11:57]:
> > On Tue, Jan 13, 2015 at 11:29:27AM -0800, Tony Lindgren wrote:
> > > Some devices like dm816x have the MDIO registers within the first EMAC
> > > instance address space. Let's fix the issue by allowing to pass an
> > > optional second IO range for the EMAC control register area.
> > >=20
> > > Cc: Brian Hutchinson <b.hutchman@gmail.com>
> > > Cc: Felipe Balbi <balbi@ti.com>
> > > Signed-off-by: Tony Lindgren <tony@atomide.com>
> > > ---
> > >  drivers/net/ethernet/ti/davinci_emac.c | 15 ++++++++++++---
> > >  1 file changed, 12 insertions(+), 3 deletions(-)
> > >=20
> > > diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/eth=
ernet/ti/davinci_emac.c
> > > index 4c8d82c..0342273 100644
> > > --- a/drivers/net/ethernet/ti/davinci_emac.c
> > > +++ b/drivers/net/ethernet/ti/davinci_emac.c
> > > @@ -1877,7 +1877,7 @@ davinci_emac_of_get_pdata(struct platform_devic=
e *pdev, struct emac_priv *priv)
> > >  static int davinci_emac_probe(struct platform_device *pdev)
> > >  {
> > >  	int rc =3D 0;
> > > -	struct resource *res;
> > > +	struct resource *res, *res_ctrl;
> > >  	struct net_device *ndev;
> > >  	struct emac_priv *priv;
> > >  	unsigned long hw_ram_addr;
> > > @@ -1936,11 +1936,20 @@ static int davinci_emac_probe(struct platform=
_device *pdev)
> > >  		rc =3D PTR_ERR(priv->remap_addr);
> > >  		goto no_pdata;
> > >  	}
> > > +
> > > +	res_ctrl =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
> > > +	if (res_ctrl) {
> >=20
> > devm_ioremap_resource() will check for res_ctrl being a valid pointer,
> > perhaps below would be slightly better ?
> >=20
> >=20
> > 	res_ctrl =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
> > 	priv->ctrl_base =3D devm_ioremap_resource(&pdev->dev, res_ctrl);
> > 	if (IS_ERR(priv->ctrl_base))
> > 		priv->ctrl_base =3D priv->remap_addr + pdata->ctrl_mod_reg_offset;
> >=20
>=20
> We have a pile of devices using just one ioremap area so the second
> ioremap area needs to be optional. That's why we only do it based on
> if (res_ctrl).

fair enough

--=20
balbi

--LG5jgFgJbJFFiAfj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtX5dAAoJEIaOsuA1yqRE+HAP/RMr5mCQHNBG/iQ8o68xuEWn
H/tjsHVn1Uh8LXrrUSEoJOol8jEQbbIOMyb8vo5A3iRn84RR8q3QnOTEF+EvxqC6
PKj3Z+icThq7fzSV857uWrUPcbuDEbuqWFIPVtcoALbOt9olAJOlF5aN1WnySuBV
tMIgoJF1fZBGA61IvDv1ZW8T61RJh6NQYHX+VVXzGxlLz1kg+uS9erO2SdiqQKyn
e4PQVKRFtFsq9azXXnp7wZlPe08IW+JpgoLFgmxt7NLsveC1thH+o+ErFcQMKFY6
0ZiXP07NQOOsOvpmjW/EImcdI7XQx6oaL34QK3kNOevnD3wC4eW/p8LRAvXSR/lX
LqSNkIzOnv1M3rOmQw2qeNHjCXxWw8wixfjJFzweuYG7OJvLDtoiKaqiMCnaNAIj
KKl6kWEgQjFH567tRhMm+aULptP3unKoVRv0wR4YlHF0/tYfXR6I8dKCwOS2LvnL
oj5FVy8MZtMwpGVsa8zFaoD/3hTkSoamaWNc3Yk3DRD5fhwiZATQY0TRzHP2zgMw
K8k6hpRRCr/OLgn0TpjciYoA+UXB0tOBcT4dS63BrqjWD/SJ33Vomxg0gQoofeC6
IYQDfQm5AW4ZHVpHmf25m1ozSCTxluxf5h1VcpWYZORpgfZcnxiJRpeedCJpJ4Bw
JsPuHLjktyCjmx1XHmbv
=S7Us
-----END PGP SIGNATURE-----

--LG5jgFgJbJFFiAfj--
