From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v3 02/13] phy: add the mvebu cp110 comphy driver
Date: Tue, 29 Aug 2017 15:12:31 +0200
Message-ID: <20170829131231.GD31552@kwain>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-3-antoine.tenart@free-electrons.com>
 <50072fdd-d370-8518-a9f4-73e121114e67@ti.com>
 <20170829112340.GB31552@kwain>
 <d1d5212d-aa39-0b49-afb8-cc45d57717c0@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="GyRA7555PLgSTuth"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, andrew@lunn.ch, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:57726 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752648AbdH2NMd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 09:12:33 -0400
Content-Disposition: inline
In-Reply-To: <d1d5212d-aa39-0b49-afb8-cc45d57717c0@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GyRA7555PLgSTuth
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kishon,

On Tue, Aug 29, 2017 at 05:55:06PM +0530, Kishon Vijay Abraham I wrote:
> On Tuesday 29 August 2017 04:53 PM, Antoine Tenart wrote:
> > On Tue, Aug 29, 2017 at 04:34:17PM +0530, Kishon Vijay Abraham I wrote:
> >> On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
> >>> +static const struct mvebu_comhy_conf mvebu_comphy_cp110_modes[] =3D {
> >>> +	/* lane 0 */
> >>> +	MVEBU_COMPHY_CONF(0, 1, PHY_MODE_SGMII, 0x1),
> >>> +	/* lane 1 */
> >>> +	MVEBU_COMPHY_CONF(1, 2, PHY_MODE_SGMII, 0x1),
> >>> +	/* lane 2 */
> >>> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_SGMII, 0x1),
> >>> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_10GKR, 0x1),
> >>> +	/* lane 3 */
> >>> +	MVEBU_COMPHY_CONF(3, 1, PHY_MODE_SGMII, 0x2),
> >>> +	/* lane 4 */
> >>> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_SGMII, 0x2),
> >>> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_10GKR, 0x2),
> >>> +	MVEBU_COMPHY_CONF(4, 1, PHY_MODE_SGMII, 0x1),
> >>> +	/* lane 5 */
> >>> +	MVEBU_COMPHY_CONF(5, 2, PHY_MODE_SGMII, 0x1),
> >>> +};
> >>
> >> IMHO all the lane and mode configuration should come from dt. That wou=
ld make
> >> it more reusable when comphy is configured differently.
> >=20
> > These connexions between engines and the comphy lanes are inside the
> > SoC. They won't change for a given SoC, and the actual configuration is
> > at the board level to know what is connected to the output of a given
> > lane, which is already described into the dt (the lane phandle).
> >=20
> > So I think we can keep this inside the driver, and we'll had other
> > tables if the same comphy is ever used in another SoC.
> >=20
> > What do you think?
>=20
> I'd like to avoid adding tables for every SoC. These are configuration de=
tails
> and can come from dt.

Actually this is per CP design, not SoC (this one is used in both 7k and
8k SoCs from Marvell, and probably others). I'm still not convinced this
is a good idea to put this into the dt. First of all we would end up with
something like (and this is only for a single lane, out of *6*):

cpm_comphy: phy@phy@120000 {
	compatible =3D "marvell,comphy-cp110";
	reg =3D <0x120000 0x6000>;
	marvell,system-controller =3D <&cpm_syscon0>;
	#address-cells =3D <1>;
	#size-cells =3D <0>;

	cpm_comphy0: phy@0 {
		reg =3D <0>;
		#phy-cells =3D <1>;

		mode@0 {
			phy-mode =3D PHY_MODE_SGMII;
			selector =3D <0x1>;
			pipe-selector =3D <0x0>;
			port =3D <0>;
		};

		mode@1 {
			phy-mode =3D PHY_MODE_HS_SGMII;
			selector =3D <0x1>;
			pipe-selector =3D <0x0>;
			port =3D <0>;
		};

		mode@2 {
			phy-mode =3D PHY_MODE_RXAUI;
			selector =3D <0x2>;
			pipe-selector =3D <0x0>;
			port =3D <0>;
		};

		mode@3 {
			phy-mode =3D PHY_MODE_10GKR;
			selector =3D <0x2>;
			pipe-selector =3D <0x0>;
			port =3D <0>;
		};

		mode@4 {
			phy-mode =3D PHY_MODE_SATA;
			selector =3D <0x4>;
			pipe-selector =3D <0x0>;
			port =3D <1>;
		};

		mode@5 {
			phy-mode =3D PHY_MODE_USB;
			selector =3D <0x0>;
			pipe-selector =3D <0x1>;
			port =3D <2>;
		};

		mode@6 {
			phy-mode =3D PHY_MODE_USB;
			selector =3D <0x0>;
			pipe-selector =3D <0x2>;
			port =3D <0>;
		};

		... + PCIe, other ports ...
	};

	cpm_comphy1: phy@1 {
		...
	};

	...
};

And this "configuration" makes us think the comphy driver would be
somehow generic with only these parameters to update when using a
different CP. In reality we do have one other comphy in another CP, and
it requires more than just updating the above parameters: the init
functions also are SoC specific. So the table used in the patch proposed
only is a small part of this "configuration". In fact it's not a
configuration at all, but only a mode-to-bit indirection, used in the
comphy init functions.

What is proposed instead, is very close to what actually changes a lot,
and what a designer can change: the CP internals are described in the
driver as these won't change (and if they do in a future CP design, a
lot more effort would be needed than just updating the table), and the
actual lane connexions on the board are configured through the dt, which
is board specific.

Finally we do not have (yet) any example of this IP being reused as-is.
So we have no idea what other changes than the ones described above will
be needed. But for sure not only the mode and lane configurations.

Thanks,
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--GyRA7555PLgSTuth
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmlaD4ACgkQXE2LyK3b
vNh2Qw//WrrBexDLZh9PV0qGSaHv/QDTC5/XsRaPWlpvvupmD7Afs68blwM4tkea
eztUXXr7bQGcR0T4OYLsQj3Ms5HKSRn1wyoXdgM8x68QJx3Ayi54/WIx63rreR79
AmllDtf+H+/5pwaYu88Efxvx2wezSIEHQM9SuDpjpH5RE30LMOn58glh2Qc3/MAW
KdFxVGV0WuLQB7CuoNz+UiUZNlGBqHF6XKJNepow2u4ibjndcn+tnl4lCZWOyz4j
qrT31OMeSt9R+f/0nbiC3U3KoPHvoT9Q4oXS119ekONxzefFTKVyMLlqz7rO73JO
U7lnggG2jZP9YSlgpXJsy2Blt7fsoROlNyEEipH8r3exTqL5F9pE/VAYclqwaVUI
Hq5AbKOJgZKAgmFIYsYf9EEtr7QsX8lOXslf7+1tKnihmqKvtegUmuAWK8DMI8io
tU2w0g1E0aG4/GSRzsRKWrqNTd6d7LMY/QLgxAQ8KS0/vkzx6KF4lndOf7wnkvtK
hZWMc/E5FEylKQ/rWZBWYIpkHB/AunW+AnoNlYXVrT5+kzEe2+WoW3xgPKie5bTE
o4pHE9Ih9HgLYOYBUT4p3yVxypqZazkRPuw8yIXDbyBJBPHzNis15r5uEp7HvcfI
DwbBMKKSIZUdDIz/1QZfzqQRshfh168Ny1fZmWXT+dVvmdJghFA=
=tMOv
-----END PGP SIGNATURE-----

--GyRA7555PLgSTuth--
