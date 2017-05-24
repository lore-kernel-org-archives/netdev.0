From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: RE: [PATCH v2] drivers: phy: Add Cortina CS4340 driver
Date: Wed, 24 May 2017 14:34:16 +0000
Message-ID: <DB5PR04MB124053B977F50D4A68C99D7BEAFE0@DB5PR04MB1240.eurprd04.prod.outlook.com>
References: <1495617948-13435-1-git-send-email-bogdan.purcareata@nxp.com>
 <20170524125830.GB24341@lunn.ch>
 <DB5PR04MB1240541B2CFB2C99ED519CDFEAFE0@DB5PR04MB1240.eurprd04.prod.outlook.com>
 <20170524142543.GD26577@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0052.outbound.protection.outlook.com ([104.47.0.52]:56768
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1422775AbdEXOeU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 10:34:20 -0400
In-Reply-To: <20170524142543.GD26577@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, May 24, 2017 5:26 PM
> To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> Cc: f.fainelli@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH v2] drivers: phy: Add Cortina CS4340 driver
>=20
> > Yes, I can do that. However, I don't see a "phy" folder under
> Documentation/devicetree/bindings/net/.
> > Should I change the location to
> Documentation/devicetree/bindings/net/cortina.txt instead?
>=20
> Ah, sorry, my error. Yes,
> Documentation/devicetree/bindings/net/cortina.txt.
>=20
> > > I think there needs to be some explanation here. What exactly are you
> > > using to indicate link up? What does CORTINA_GPIO_GPIO_INTS mean?
> >
> > I can only assume it's the location of an interrupt status register. Th=
e
> Cortina PHYs go mostly undocumented, I've found an implementation in an o=
ld
> thread [1], that also did the job of programming the Cortina PHY microcod=
e.
> I understand that microcode programming is now part of the bootloader.
> >
> > The register seems to provide the link status properly, and based on th=
at
> the phydev is initialized with the only (currently) supported
> configuration, 10Gbps full duplex.
> >
> > I can change the register name to something more meaningful, though -
> e.g. CORTINA_LINK_STATUS.
>=20
> No, leave the name as is. The MIPS driver you gave a reference to
> seems to be using sensible names. My guess is, the boot loader is
> configuring the PHY to generate an interrupt on link up via one of its
> GPIO lines. And this code is reading that GPIO status. This is all
> very fragile, you are making a lot of assumptions.
>=20
> Have you tested pulling the cable out? And plugging it back in again?
> There is a chance this interrupt is "link change", not "link up".

No, I have not. I had it planned but it somehow slipped. Will test.

> What i do like in that mips code is the probe function verifies the
> product ID.
>=20
> +       /*
> +        * CS4312 keeps its ID values in non-standard registers, make
> +        * sure we are talking to what we think we are.
> +        */
> +       id_lsb =3D cs4321_phy_read(phydev, CS4321_GLOBAL_CHIP_ID_LSB);
> +       if (id_lsb < 0) {
> +               ret =3D id_lsb;
> +               goto err;
> +       }
> +
> +       id_msb =3D cs4321_phy_read(phydev, CS4321_GLOBAL_CHIP_ID_MSB);
> +       if (id_msb < 0) {
> +               ret =3D id_msb;
> +               goto err;
> +       }
> +
> +       if (id_lsb !=3D 0x23E5 || id_msb !=3D 0x1002) {
> +               ret =3D -ENODEV;
> +               goto err;
> +       }
>=20
> You should do that as well.

Okay, I will include this check in a probe function in v3.

Thanks a lot!
Bogdan
