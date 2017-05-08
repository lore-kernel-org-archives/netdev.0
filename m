From: Sebastian Reichel <sre@kernel.org>
Subject: Re: [PATCH 0/4] TI Bluetooth serdev support
Date: Mon, 8 May 2017 21:07:50 +0200
Message-ID: <20170508190749.sev2wtecjnaneyng@earth>
References: <20170405183005.20570-1-robh@kernel.org>
 <CAHCN7xJUxZm1qKAxT0kaK6qoDg+HWOJK7sTH-q9za4HJuUwe8Q@mail.gmail.com>
 <20170430160430.rmyuo6sdrkrjxjg6@earth>
 <CAHCN7x+Mq=b6RN-ezU0400W=H=D7DR+Es1FHtT4GyozpVd8ALA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="nk6pi2aia4evfmot"
Cc: Rob Herring <robh@kernel.org>,
        Marcel Holtmann <marcel@holtmann.org>,
        linux-bluetooth@vger.kernel.org,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Gustavo Padovan <gustavo@padovan.org>,
        Satish Patel <satish.patel@linaro.org>,
        Wei Xu <xuwei5@hisilicon.com>, Eyal Reizer <eyalr@ti.com>,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Adam Ford <aford173@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50516 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752039AbdEHTH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 15:07:57 -0400
Content-Disposition: inline
In-Reply-To: <CAHCN7x+Mq=b6RN-ezU0400W=H=D7DR+Es1FHtT4GyozpVd8ALA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nk6pi2aia4evfmot
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, May 05, 2017 at 09:51:33AM -0500, Adam Ford wrote:
> On Sun, Apr 30, 2017 at 11:04 AM, Sebastian Reichel <sre@kernel.org> wrot=
e:
> > On Sun, Apr 30, 2017 at 10:14:20AM -0500, Adam Ford wrote:
> >> On Wed, Apr 5, 2017 at 1:30 PM, Rob Herring <robh@kernel.org> wrote:
> >> > This series adds serdev support to the HCI LL protocol used on TI BT
> >> > modules and enables support on HiKey board with with the WL1835 modu=
le.
> >> > With this the custom TI UIM daemon and btattach are no longer needed.
> >>
> >> Without UIM daemon, what instruction do you use to load the BT firmwar=
e?
> >>
> >> I was thinking 'hciattach' but I was having trouble.  I was hoping you
> >> might have some insight.
> >>
> >>  hciattach -t 30 -s 115200 /dev/ttymxc1 texas 3000000 flow  Just
> >> returns a timeout.
> >>
> >> I modified my i.MX6 device tree per the binding documentation and
> >> setup the regulators and enable GPIO pins.
> >
> > If you configured everything correctly no userspace interaction is
> > required. The driver should request the firmware automatically once
> > you power up the bluetooth device.
> >
> > Apart from DT changes make sure, that the following options are
> > enabled and check dmesg for any hints.
> >
> > CONFIG_SERIAL_DEV_BUS
> > CONFIG_SERIAL_DEV_CTRL_TTYPORT
> > CONFIG_BT_HCIUART
> > CONFIG_BT_HCIUART_LL
>=20
> I have enabled those flags, and I have updated my device tree.
> I am testing this on an OMAP3630 (DM3730) board with a WL1283.  I am
> getting a lot of timeout errors.  I tested this against the original
> implemention I had in pdata-quirks.c using the ti-st driver, uim & and
> the btwilink driver.
>=20
> I pulled in some of the newer patches to enable the wl1283-st, but I
> am obviously missing something.
>=20
> I   58.717651] Bluetooth: hci0: Reading TI version information failed
> (-110)
> [   58.724853] Bluetooth: hci0: download firmware failed, retrying...
> [   60.957641] Bluetooth: hci0 command 0x1001 tx timeout
> [   68.957641] Bluetooth: hci0: Reading TI version information failed
> (-110)
> [   68.964843] Bluetooth: hci0: download firmware failed, retrying...
> [   69.132171] Bluetooth: Unknown HCI packet type 06
> [   69.138244] Bluetooth: Unknown HCI packet type 0c
> [   69.143249] Bluetooth: Unknown HCI packet type 40
> [   69.148498] Bluetooth: Unknown HCI packet type 20
> [   69.153533] Bluetooth: Data length is too large
> [   69.158569] Bluetooth: Unknown HCI packet type a0
> [   69.163574] Bluetooth: Unknown HCI packet type 00
> [   69.168731] Bluetooth: Unknown HCI packet type 00
> [   69.173736] Bluetooth: Unknown HCI packet type 34
> [   69.178924] Bluetooth: Unknown HCI packet type 91
> [   71.197631] Bluetooth: hci0 command 0x1001 tx timeout
> [   79.197662] Bluetooth: hci0: Reading TI version information failed (-1=
10)
>
> Since the pdata-quirks and original ti-st drivers work together, I
> know the hardware is fine.  The only change to the device tree is the
> addition of the Bluetooth container:
>=20
> bluetooth {
>   compatible =3D "ti,wl1283-st";
>   enable-gpios =3D <&gpio6 2 GPIO_ACTIVE_HIGH>;
> };
>=20
> Any thoughts or suggestions to try? I get similar behavior on an
> i.MX6 board with a wl1837-st module as well.

Looks like its loosing bytes. I suggest to have a look at
pinmuxing (esp. for cts & rts) and maybe add some debug
prints to see where it starts failing.

-- Sebastian

--nk6pi2aia4evfmot
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlkQwgMACgkQ2O7X88g7
+prkYg/9HPpijKg7yAvn9TUkoxzUZvv40F8eyuy5laslRSewycr8tOR2O3mHn97w
E1Zjb1uiK+4zYf7QfoR+qqvRiSn3iPTKF+170o8sScM4rhjhc/gajqhIHyHObKUs
3nvmDkwBHQ0p7thYqdNviWFauuAj6S5it568ZadAs0OwRhmoqAvoR9ltCUoE8hEC
aBVdgLMkXWGfEdbx5sRQmH3XfCZqI9LndOuoTlrT95I5QZPj5qVwLUOkAXgiDEOh
nHjMceaW1k2GJfMMEfjN+yY5/i+XvlIZ0OcWDRXJn3NRwvWn1wCnpLwEnJCVXoPv
MAd8uFMM/S8inZ9PVrUn9ZJObqBbyL/yl+D+q0wgUJNKEH+9PNSuFtyGLm8hILlR
24z1YaorF2bgEWknJNVh0XvhBTB6IMFhY4c+Vpd+dw2HexM20Cn1V7AZuC1jiCGf
hJHOJpm+TGOXx8p3Oy6XE4TXbO1SGxBlm65IDE5lklVQaUVIAqSc2eJlS+PMwceW
UaclAe5m1HWYPQPooFLcvcty59VBW+WICCBqNJ421yMYafwEqzjAuIsSEaI6L2h6
9weshLTzmyDWKdAGCcelmyNiIuj+hNFYMv1iiqEfOIh4+MrJMTkfOB6QftLHPPj0
LiGRK8E04i1Ag3uIPlqqKxCRjV6ZYk6yR6zX+Ix0/GvGOkyHmac=
=KzB2
-----END PGP SIGNATURE-----

--nk6pi2aia4evfmot--
