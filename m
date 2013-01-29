From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 5/5] mv643xx_eth: convert to use the Marvell Orion MDIO driver
Date: Tue, 29 Jan 2013 21:41:03 +0100
Message-ID: <201301292141.03931.florian@openwrt.org>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org> <1359473048-26551-6-git-send-email-florian@openwrt.org> <20130129181306.GF25646@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, linux-doc@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linux-arm-kernel@lists.infradead.org,
	Rob Landley <rob@landley.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130129181306.GF25646@obsidianresearch.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 29 janvier 2013 19:13:06, Jason Gunthorpe a =E9crit :
> On Tue, Jan 29, 2013 at 04:24:08PM +0100, Florian Fainelli wrote:
> > This patch converts the Marvell MV643XX ethernet driver to use the
> > Marvell Orion MDIO driver. As a result, PowerPC and ARM platforms
> > registering the Marvell MV643XX ethernet driver are also updated to
> > register a Marvell Orion MDIO driver. This driver voluntarily overl=
aps
> > with the Marvell Ethernet shared registers because it will use a su=
bset
> > of this shared register (shared_base + 0x4 - shared_base + 0x84). T=
he
> > Ethernet driver is also updated to look up for a PHY device using t=
he
> > Orion MDIO bus driver.
>=20
> Can you finish off this job by making the mv643xx_eth driver accept
> the standard phy-handle OF property instead of using a phy address?

I can certainly do that, at the same time we need to continue supportin=
g the=20
"old" platform device style registration without breaking them (PowerPC=
 in=20
particular, and the hopefully yet to be converted orion5x). So the phy_=
scan()=20
as I modified it will probably still be there.

>=20
> Ie the end result should be something like:
>=20
>                 smi0: mdio@72000 {
>                         device_type =3D "mdio";
>                         compatible =3D "marvell,orion-mdio";
>                         reg =3D <0x72004 0x4>;
>=20
>                         #address-cells =3D <1>;
>                         #size-cells =3D <0>;
>                         PHY1: ethernet-phy@1 {
>                                 reg =3D <1>;
>                                 device_type =3D "ethernet-phy";
>                                 phy-id =3D <0x01410e90>;
>                         };
>                 };
>=20
>                 egiga0 {
>                         device_type =3D "network";
>                         compatible =3D "marvell,mv643xx-eth";
>                         reg =3D <0x72000 0x4000>;
>                         port_number =3D <0>;
>                         phy-handle =3D <&PHY1>;
>                         interrupts =3D <11>;
>                         local-mac-address =3D [000000000002];  /* Fil=
led by
> boot loader */ };
>=20
> Regards,
> Jason

--=20
=46lorian
