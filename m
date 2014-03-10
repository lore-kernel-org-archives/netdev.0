From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: phy: fix uninitalized WOL parameters in
 phy_ethtool_get_wol
Date: Mon, 10 Mar 2014 23:17:57 +0000
Message-ID: <1394493477.23624.21.camel@deadeye.wl.decadent.org.uk>
References: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
	 <1394419893.15968.88.camel@deadeye.wl.decadent.org.uk>
	 <531D98D1.4000707@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ew9RqMAOgLB6XDEMN6s1"
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <531D98D1.4000707@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ew9RqMAOgLB6XDEMN6s1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-10 at 10:49 +0000, Sebastian Hesselbarth wrote:
> On 03/10/2014 02:51 AM, Ben Hutchings wrote:
> > On Mon, 2014-03-10 at 02:01 +0100, Sebastian Hesselbarth wrote:
> >> phy_ethtool_get_wol is a helper to get current WOL settings from
> >> a phy device. When using this helper on a PHY without .get_wol
> >> callback, struct ethtool_wolinfo is never set-up correctly and
> >> may contain misleading information about WOL status.
> >>
> >> To fix this, always zero relevant fields of struct ethtool_wolinfo
> >> regardless of .get_wol callback availability.
> >
> > I think it's the caller's responsibility to zero out struct
> > ethtool_wolinfo.  That is what ethtool_get_wol() does.
>=20
> Actually, phy_ethtool_get_wol is the caller here. This belongs to
> a set of helpers that deal with phy_device, not netdev.

Right, but ethtool_get_wol() is further up the stack and is responsible
for initialising the struct to defaults.

> > Maybe you could split ethtool_get_wol() like we did
> > ethtool_get_settings(), to support in-kernel invocation of ETHTOOL_GWOL=
?
>=20
> Looking at the other users of phy_ethtool_get_wol (mv643xx_eth and
> cpsw), both drivers use this helper to determine what to pass back
> on the corresponding ethtool_get_wol call.
>=20
> BTW, both drivers above do zero ethtool_wolinfo before calling
> phy_ethtool_get_wol. I can either zero it in phy_suspend too or we
> deal with it properly in phy_ethtool_get_wol instead:
>=20
> void phy_ethtool_get_wol(struct phy_device *phydev, struct=20
> ethtool_wolinfo *wol)
> {
> 	memset(wol, 0, sizeof(*wol));
>=20
> 	if (phydev && phydev->drv->get_wol)
> 		phydev->drv->get_wol(phydev, wol);
> }
[...]

This trashes wol->cmd.  Don't do that.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-ew9RqMAOgLB6XDEMN6s1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUx5IJee/yOyVhhEJAQpQHw/5AYD6blWbZPbNKk3204RIL1JdvWbOvngT
+o4FDpIWc9dz2XO9pgaHo5cgTgZSVY1S+S5YBL47AYUiQGW46/iTGw/PHTxEKfxW
bhdKse72bZRJ6jPFhQkvJfLbNQuNYJrY8+XdAZ+uWBZ/R7k7AtaaxRXyy7Xz5cPR
xGKp8dziSuNN/7ZL7kZAdpxKO6A65gMjWND6iVVx3asfluz8g7esQyJHL0R+C59+
PCmiOk9HY40zjF5+LhYWtIFVv12/mQSZZTBEpWRF4yIGXbPUWVE/pR2z8RmO0DVG
o+nRwPZxKeBS/9so48vpdfV8nHW8UxUdycMIEPhp4ndu49gcOhRDHYGl6yrgQF1e
6TH5LESm7VU867R1dJN87y9CBQIJuzx4/T6mQMH5GVi4x/x7H2m/xNL/IjhBWXZ/
afXEeUsYyr86XfmTB80jwsqHOoI/m4WRib2bEjdeVAbOKERPftaysEKAUnI96SV1
TCM0CAmyKqXJ195EviN0QesvI9Urc1v8S7D7MMQoEfb20+qV1IOT9eUVEXMpO9lN
yvmn3M4vyGfGuNJsMAw43C9WPzHNODLwt1b5cDiPO4f57b4RnE+zAg50wZ+tfRQ6
y9eLatI7rNYYG+evkMfGVSk7uaVndJAHk1Rb8UTlSpZFQkGWtUcJyZ1gyXn5jZ+2
8olcpAF6w0M=
=mM3h
-----END PGP SIGNATURE-----

--=-ew9RqMAOgLB6XDEMN6s1--
