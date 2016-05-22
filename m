From: Mathias Kresin <m@kresin.me>
Subject: Re: [RFC] NET: PHY: adds driver for Lantiq PHY11G
Date: Sun, 22 May 2016 22:30:48 +0200
Message-ID: <574216F8.7070300@kresin.me>
References: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms000508090004080402000806"
Cc: alexander.stein@systec-electronic.com, netdev@vger.kernel.org,
	andrew@lunn.ch, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com
To: Hauke Mehrtens <hauke@hauke-m.de>, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32803 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbcEVUax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 16:30:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id 67so9950248wmg.0
        for <netdev@vger.kernel.org>; Sun, 22 May 2016 13:30:52 -0700 (PDT)
In-Reply-To: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms000508090004080402000806
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi Hauke,

find my comments in-line.

Am 22.05.2016 um 21:33 schrieb Hauke Mehrtens:
> Supports the Lantiq / Intel CHD 11G and 22E PHYs.
> These PHYs are also named PEF 7061, PEF 7071, PEF 7072
>
> Signed-off-by: John Crispin <john@phrozen.org>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>
> This is based on a driver from OpenWrt / LEDE. This is send as a RFC
> because the merge window is open now and it adds a new driver. This
> patch was cleaned up on request of Alexander.
>
>
>   .../devicetree/bindings/phy/phy-lanitq.txt         | 216 ++++++++++++=
+++++

Looks like a typo in the filename. lantiq !=3D lanitq

>   drivers/net/phy/Kconfig                            |   6 +
>   drivers/net/phy/Makefile                           |   1 +
>   drivers/net/phy/lantiq.c                           | 269 ++++++++++++=
+++++++++
>   4 files changed, 492 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/phy/phy-lanitq.t=
xt
>   create mode 100644 drivers/net/phy/lantiq.c
>
> diff --git a/Documentation/devicetree/bindings/phy/phy-lanitq.txt b/Doc=
umentation/devicetree/bindings/phy/phy-lanitq.txt
> new file mode 100644
> index 0000000..d9746e8
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/phy/phy-lanitq.txt
> @@ -0,0 +1,216 @@
> +Lanitq PHY binding

Same typo as mentioned above.

> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +This devicetree binding controls the lantiq ethernet phys led function=
ality.
> +
> +Example:
> +	mdio@0 {
> +		#address-cells =3D <1>;
> +		#size-cells =3D <0>;
> +		compatible =3D "lantiq,xrx200-mdio";
> +			phy5: ethernet-phy@5 {
> +			reg =3D <0x1>;
> +			compatible =3D "lantiq,phy11g", "ethernet-phy-ieee802.3-c22";
> +		};
> +		phy11: ethernet-phy@11 {
> +			reg =3D <0x11>;
> +			compatible =3D "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
> +			lantiq,led2h =3D <0x00>;
> +			lantiq,led2l =3D <0x03>;
> +		};
> +		phy12: ethernet-phy@12 {
> +			reg =3D <0x12>;
> +			compatible =3D "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
> +			lantiq,led1h =3D <0x00>;
> +			lantiq,led1l =3D <0x03>;
> +		};
> +		phy13: ethernet-phy@13 {
> +			reg =3D <0x13>;
> +			compatible =3D "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
> +			lantiq,led2h =3D <0x00>;
> +			lantiq,led2l =3D <0x03>;
> +		};
> +		phy14: ethernet-phy@14 {
> +			reg =3D <0x14>;
> +			compatible =3D "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
> +			lantiq,led1h =3D <0x00>;
> +			lantiq,led1l =3D <0x03>;
> +		};
> +	};
> +
> +Register Description
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +LEDCH:
> +
> +Name	Hardware Reset Value
> +LEDCH	0x00C5
> +
> +| 15 |    |    |    |    |    |    |  8 |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +|		RES			|
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +|  7 |    |    |    |    |    |    |  0 |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +|   FBF   |   SBF   |RES |     NACS     |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Field	Bits	Type	Description
> +FBC	7:6	RW	Fast Blink Frequency
> +			---
> +			0x0 (00b) F02HZ 2 Hz blinking frequency
> +			0x1 (01b) F04HZ 4 Hz blinking frequency
> +			0x2 (10b) F08HZ 8 Hz blinking frequency
> +			0x3 (11b) F16HZ 16 Hz blinking frequency
> +
> +SBF	5:4	RW	Slow Blink Frequency
> +			---
> +			0x0 (00b) F02HZ 2 Hz blinking frequency
> +			0x1 (01b) F04HZ 4 Hz blinking frequency
> +			0x2 (10b) F08HZ 8 Hz blinking frequency
> +			0x3 (11b) F16HZ 16 Hz blinking frequency
> +
> +NACS	2:0	RW	Inverse of Scan Function
> +			---
> +			0x0 (000b) NONE No Function
> +			0x1 (001b) LINK Complex function enabled when link is up
> +			0x2 (010b) PDOWN Complex function enabled when device is powered-do=
wn
> +			0x3 (011b) EEE Complex function enabled when device is in EEE mode
> +			0x4 (100b) ANEG Complex function enabled when auto-negotiation is r=
unning
> +			0x5 (101b) ABIST Complex function enabled when analog self-test is =
running
> +			0x6 (110b) CDIAG Complex function enabled when cable diagnostics ar=
e running
> +			0x7 (111b) TEST Complex function enabled when test mode is running
> +
> +LEDCL:
> +
> +Name	Hardware Reset Value
> +LEDCL	0x0067
> +
> +| 15 |    |    |    |    |    |    |  8 |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +|		RES			|
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +|  7 |    |    |    |    |    |    |  0 |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +|RES |     SCAN     |RES |    CBLINK    |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Field	Bits	Type	Description
> +SCAN	6:4	RW	Complex Scan Configuration
> +			---
> +			000 B NONE No Function
> +			001 B LINK Complex function enabled when link is up
> +			010 B PDOWN Complex function enabled when device is powered-down
> +			011 B EEE Complex function enabled when device is in EEE mode
> +			100 B ANEG Complex function enabled when auto-negotiation is runnin=
g
> +			101 B ABIST Complex function enabled when analog self-test is runni=
ng
> +			110 B CDIAG Complex function enabled when cable diagnostics are run=
ning
> +			111 B TEST Complex function enabled when test mode is running
> +
> +CBLINK	2:0	RW	Complex Blinking Configuration
> +			---
> +			000 B NONE No Function
> +			001 B LINK Complex function enabled when link is up
> +			010 B PDOWN Complex function enabled when device is powered-down
> +			011 B EEE Complex function enabled when device is in EEE mode
> +			100 B ANEG Complex function enabled when auto-negotiation is runnin=
g
> +			101 B ABIST Complex function enabled when analog self-test is runni=
ng
> +			110 B CDIAG Complex function enabled when cable diagnostics are run=
ning
> +			111 B TEST Complex function enabled when test mode is running
> +
> +LEDxH:
> +
> +Name	Hardware Reset Value
> +LED0H	0x0070
> +LED1H	0x0020
> +LED2H	0x0040
> +LED3H	0x0040
> +
> +| 15 |    |    |    |    |    |    |  8 |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +|		RES			|
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +|  7 |    |    |    |    |    |    |  0 |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +|        CON        |       BLINKF      |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Field	Bits	Type	Description
> +CON	7:4	RW	Constant On Configuration
> +			---
> +			0x0 (0000b) NONE LED does not light up constantly
> +			0x1 (0001b) LINK10 LED is on when link is 10 Mbit/s
> +			0x2 (0010b) LINK100 LED is on when link is 100 Mbit/s
> +			0x3 (0011b) LINK10X LED is on when link is 10/100 Mbit/s
> +			0x4 (0100b) LINK1000 LED is on when link is 1000 Mbit/s
> +			0x5 (0101b) LINK10_0 LED is on when link is 10/1000 Mbit/s
> +			0x6 (0110b) LINK100X LED is on when link is 100/1000 Mbit/s
> +			0x7 (0111b) LINK10XX LED is on when link is 10/100/1000 Mbit/s
> +			0x8 (1000b) PDOWN LED is on when device is powered-down
> +			0x9 (1001b) EEE LED is on when device is in EEE mode
> +			0xA (1010b) ANEG LED is on when auto-negotiation is running
> +			0xB (1011b) ABIST LED is on when analog self-test is running
> +			0xC (1100b) CDIAG LED is on when cable diagnostics are running
> +
> +BLINKF	3:0	RW	Fast Blinking Configuration
> +			---
> +			0x0 (0000b) NONE No Blinking
> +			0x1 (0001b) LINK10 Blink when link is 10 Mbit/s
> +			0x2 (0010b) LINK100 Blink when link is 100 Mbit/s
> +			0x3 (0011b) LINK10X Blink when link is 10/100 Mbit/s
> +			0x4 (0100b) LINK1000 Blink when link is 1000 Mbit/s
> +			0x5 (0101b) LINK10_0 Blink when link is 10/1000 Mbit/s
> +			0x6 (0110b) LINK100X Blink when link is 100/1000 Mbit/s
> +			0x7 (0111b) LINK10XX Blink when link is 10/100/1000 Mbit/s
> +			0x8 (1000b) PDOWN Blink when device is powered-down
> +			0x9 (1001b) EEE Blink when device is in EEE mode
> +			0xA (1010b) ANEG Blink when auto-negotiation is running
> +			0xB (1011b) ABIST Blink when analog self-test is running
> +			0xC (1100b) CDIAG Blink when cable diagnostics are running
> +
> +LEDxL:
> +
> +Name	Hardware Reset Value
> +LED0L	0x0003
> +LED1L	0x0000
> +LED2L	0x0000
> +LED3L	0x0020
> +
> +| 15 |    |    |    |    |    |    |  8 |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +|		RES			|
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +|  7 |    |    |    |    |    |    |  0 |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +|      BLINKS       |       PULSE       |
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Field	Bits	Type	Description
> +BLINKS	7:4	RW	Slow Blinkin Configuration
> +			---
> +			0x0 (0000b) NONE No Blinking
> +			0x1 (0001b) LINK10 Blink when link is 10 Mbit/s
> +			0x2 (0010b) LINK100 Blink when link is 100 Mbit/s
> +			0x3 (0011b) LINK10X Blink when link is 10/100 Mbit/s
> +			0x4 (0100b) LINK1000 Blink when link is 1000 Mbit/s
> +			0x5 (0101b) LINK10_0 Blink when link is 10/1000 Mbit/s
> +			0x6 (0110b) LINK100X Blink when link is 100/1000 Mbit/s
> +			0x7 (0111b) LINK10XX Blink when link is 10/100/1000 Mbit/s
> +			0x8 (1000b) PDOWN Blink when device is powered-down
> +			0x9 (1001b) EEE Blink when device is in EEE mode
> +			0xA (1010b) ANEG Blink when auto-negotiation is running
> +			0xB (1011b) ABIST Blink when analog self-test is running
> +			0xC (1100b) CDIAG Blink when cable diagnostics are runningning
> +
> +PULSE	3:0	RW	Pulsing Configuration
> +			The pulse field is a mask field by which certain events can be comb=
ined
> +			---
> +			0x0 (0000b) NONE No pulsing
> +			0x1 (0001b) TXACT Transmit activity
> +			0x2 (0010b) RXACT Receive activity
> +			0x4 (0100b) COL Collision
> +			0x8 (1000b) RES Reserved
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index f0a7702..f3685ef 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -257,6 +257,12 @@ config MDIO_BCM_IPROC
>   	  This module provides a driver for the MDIO busses found in the
>   	  Broadcom iProc SoC's.
>
> +config LANTIQ_PHY
> +	tristate "Driver for Lantiq PHYs"
> +	---help---
> +	  Supports the Lantiq / Intel CHD 11G and 22E PHYs.
> +	  These PHYs are also named PEF 7061, PEF 7071 and PEF 7072
> +
>   endif # PHYLIB
>
>   config MICREL_KS8995MA
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 680e88f9..042b0ef6 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -42,3 +42,4 @@ obj-$(CONFIG_MDIO_MOXART)	+=3D mdio-moxart.o
>   obj-$(CONFIG_MDIO_BCM_UNIMAC)	+=3D mdio-bcm-unimac.o
>   obj-$(CONFIG_MICROCHIP_PHY)	+=3D microchip.o
>   obj-$(CONFIG_MDIO_BCM_IPROC)	+=3D mdio-bcm-iproc.o
> +obj-$(CONFIG_LANTIQ_PHY)	+=3D lantiq.o
> diff --git a/drivers/net/phy/lantiq.c b/drivers/net/phy/lantiq.c
> new file mode 100644
> index 0000000..65a8086
> --- /dev/null
> +++ b/drivers/net/phy/lantiq.c
> @@ -0,0 +1,269 @@
> +/*
> + * Copyright (C) 2012 Daniel Schwierzeck <daniel.schwierzeck@googlemai=
l.com>
> + * Copyright (C) 2016 Hauke Mehrtens <hauke@hauke-m.de>
> + *
> + * This program is free software; you can redistribute it and/or modif=
y
> + * it under the terms of the GNU General Public License as published b=
y
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/mdio.h>
> +#include <linux/module.h>
> +#include <linux/phy.h>
> +#include <linux/of.h>
> +
> +#define MII_VR9_11G_IMASK	0x19	/* interrupt mask */
> +#define MII_VR9_11G_ISTAT	0x1a	/* interrupt status */
> +
> +#define INT_VR9_11G_WOL		BIT(15)	/* Wake-On-LAN */
> +#define INT_VR9_11G_ANE		BIT(11)	/* Auto-Neg error */
> +#define INT_VR9_11G_ANC		BIT(10)	/* Auto-Neg complete */
> +#define INT_VR9_11G_ADSC	BIT(5)	/* Link auto-downspeed detect */
> +#define INT_VR9_11G_DXMC	BIT(2)	/* Duplex mode change */
> +#define INT_VR9_11G_LSPC	BIT(1)	/* Link speed change */
> +#define INT_VR9_11G_LSTC	BIT(0)	/* Link state change */
> +#define INT_VR9_11G_MASK	(INT_VR9_11G_LSTC | INT_VR9_11G_ADSC)
> +
> +#define ADVERTISED_MPD		BIT(10)	/* Multi-port device */
> +
> +#define PHY_ID_PHY11G_1_3	0x030260D1
> +#define PHY_ID_PHY22F_1_3	0x030260E1
> +#define PHY_ID_PHY11G_1_4	0xD565A400
> +#define PHY_ID_PHY22F_1_4	0xD565A410
> +#define PHY_ID_PHY11G_1_5	0xD565A401
> +#define PHY_ID_PHY22F_1_5	0xD565A411
> +
> +static void lantiq_gphy_of_reg_init(struct phy_device *phydev)
> +{
> +	struct device_node *node =3D phydev->mdio.dev.of_node;
> +	u32 tmp;
> +
> +	if (!IS_ENABLED(CONFIG_OF_MDIO))
> +		return;
> +
> +	/* store the led values if one was passed by the device tree */
> +	if (!of_property_read_u32(node, "lantiq,ledch", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e0, MDIO_MMD_VEND2, tmp);
> +
> +	if (!of_property_read_u32(node, "lantiq,ledcl", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e1, MDIO_MMD_VEND2, tmp);
> +
> +	if (!of_property_read_u32(node, "lantiq,led0h", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e2, MDIO_MMD_VEND2, tmp);
> +
> +	if (!of_property_read_u32(node, "lantiq,led0l", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e3, MDIO_MMD_VEND2, tmp);
> +
> +	if (!of_property_read_u32(node, "lantiq,led1h", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e4, MDIO_MMD_VEND2, tmp);
> +
> +	if (!of_property_read_u32(node, "lantiq,led1l", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e5, MDIO_MMD_VEND2, tmp);
> +
> +	if (!of_property_read_u32(node, "lantiq,led2h", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e6, MDIO_MMD_VEND2, tmp);
> +
> +	if (!of_property_read_u32(node, "lantiq,led2l", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e7, MDIO_MMD_VEND2, tmp);
> +
> +	/* The LED3 is only available in PEF 7072 package. */
> +	if (!of_property_read_u32(node, "lantiq,led3h", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e8, MDIO_MMD_VEND2, tmp);
> +
> +	if (!of_property_read_u32(node, "lantiq,led3l", &tmp))
> +		phy_write_mmd_indirect(phydev, 0x1e9, MDIO_MMD_VEND2, tmp);
> +}
> +
> +static int lantiq_gphy_config_init(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	/* Mask all interrupts */
> +	err =3D phy_write(phydev, MII_VR9_11G_IMASK, 0);
> +	if (err)
> +		return err;
> +
> +	/* Clear all pending interrupts */
> +	phy_read(phydev, MII_VR9_11G_ISTAT);
> +
> +	phy_write_mmd_indirect(phydev, 0x1e0, MDIO_MMD_VEND2, 0xc5);
> +	phy_write_mmd_indirect(phydev, 0x1e1, MDIO_MMD_VEND2, 0x67);

Any specific reason why the complex functions are enabled by default?

> +	phy_write_mmd_indirect(phydev, 0x1e2, MDIO_MMD_VEND2, 0x42);
> +	phy_write_mmd_indirect(phydev, 0x1e3, MDIO_MMD_VEND2, 0x10);
> +	phy_write_mmd_indirect(phydev, 0x1e4, MDIO_MMD_VEND2, 0x70);
> +	phy_write_mmd_indirect(phydev, 0x1e5, MDIO_MMD_VEND2, 0x03);
> +	phy_write_mmd_indirect(phydev, 0x1e6, MDIO_MMD_VEND2, 0x20);
> +	phy_write_mmd_indirect(phydev, 0x1e7, MDIO_MMD_VEND2, 0x00);
> +	phy_write_mmd_indirect(phydev, 0x1e8, MDIO_MMD_VEND2, 0x40);
> +	phy_write_mmd_indirect(phydev, 0x1e9, MDIO_MMD_VEND2, 0x20);

I would suggest to use the same blink/permanent on configuration for all =

led pins (as it is in LEDE/OpenWrt):

     Constant On: 10/100/1000MBit
     Blink Fast: None
     Blink Slow: None
     Pulse: TX/RX

I'm aware of only one CPE that uses more than one led for status=20
indication. All other have a single led attached to any of the pins.

This way it's only required to change the default configuration via the=20
device tree bindings for the minority of the devices.


> +
> +	lantiq_gphy_of_reg_init(phydev);
> +
> +	return 0;
> +}
> +
> +static int lantiq_gphy14_config_aneg(struct phy_device *phydev)
> +{
> +	int reg, err;
> +
> +	/* Advertise as multi-port device, see IEEE802.3-2002 40.5.1.1 */
> +	/* This is a workaround for an errata in rev < 1.5 devices */
> +	reg =3D phy_read(phydev, MII_CTRL1000);
> +	reg |=3D ADVERTISED_MPD;
> +	err =3D phy_write(phydev, MII_CTRL1000, reg);
> +	if (err)
> +		return err;
> +
> +	return genphy_config_aneg(phydev);
> +}
> +
> +static int lantiq_gphy_ack_interrupt(struct phy_device *phydev)
> +{
> +	int reg;
> +
> +	/**
> +	 * Possible IRQ numbers:
> +	 * - IM3_IRL18 for GPHY0
> +	 * - IM3_IRL17 for GPHY1
> +	 *
> +	 * Due to a silicon bug IRQ lines are not really independent from
> +	 * each other. Sometimes the two lines are driven at the same time
> +	 * if only one GPHY core raises the interrupt.
> +	 */
> +	reg =3D phy_read(phydev, MII_VR9_11G_ISTAT);
> +
> +	return (reg < 0) ? reg : 0;
> +}
> +
> +static int lantiq_gphy_did_interrupt(struct phy_device *phydev)
> +{
> +	int reg;
> +
> +	reg =3D phy_read(phydev, MII_VR9_11G_ISTAT);
> +
> +	return reg > 0;
> +}
> +
> +static int lantiq_gphy_config_intr(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	if (phydev->interrupts =3D=3D PHY_INTERRUPT_ENABLED)
> +		err =3D phy_write(phydev, MII_VR9_11G_IMASK, INT_VR9_11G_MASK);
> +	else
> +		err =3D phy_write(phydev, MII_VR9_11G_IMASK, 0);
> +
> +	return err;
> +}
> +
> +static struct phy_driver lantiq_gphy[] =3D {
> +	{
> +		.phy_id		=3D PHY_ID_PHY11G_1_3,
> +		.phy_id_mask	=3D 0xffffffff,
> +		.name		=3D "Lantiq XWAY PHY11G (PEF 7071/PEF 7072) v1.3",
> +		.features	=3D (PHY_GBIT_FEATURES | SUPPORTED_Pause),
> +		 /* there is an errata regarding irqs in this rev */
> +		.flags		=3D 0,
> +		.config_init	=3D lantiq_gphy_config_init,
> +		.config_aneg	=3D lantiq_gphy14_config_aneg,
> +		.read_status	=3D genphy_read_status,
> +		.ack_interrupt	=3D lantiq_gphy_ack_interrupt,
> +		.did_interrupt	=3D lantiq_gphy_did_interrupt,
> +		.config_intr	=3D lantiq_gphy_config_intr,
> +		.suspend	=3D genphy_suspend,
> +		.resume		=3D genphy_resume,
> +	}, {
> +		.phy_id		=3D PHY_ID_PHY22F_1_3,
> +		.phy_id_mask	=3D 0xffffffff,
> +		.name		=3D "Lantiq XWAY PHY22F (PEF 7061) v1.3",
> +		.features	=3D (PHY_BASIC_FEATURES | SUPPORTED_Pause),
> +		 /* there is an errata regarding irqs in this rev */
> +		.flags		=3D 0,
> +		.config_init	=3D lantiq_gphy_config_init,
> +		.config_aneg	=3D lantiq_gphy14_config_aneg,
> +		.read_status	=3D genphy_read_status,
> +		.ack_interrupt	=3D lantiq_gphy_ack_interrupt,
> +		.did_interrupt	=3D lantiq_gphy_did_interrupt,
> +		.config_intr	=3D lantiq_gphy_config_intr,
> +		.suspend	=3D genphy_suspend,
> +		.resume		=3D genphy_resume,
> +	}, {
> +		.phy_id		=3D PHY_ID_PHY11G_1_4,
> +		.phy_id_mask	=3D 0xffffffff,
> +		.name		=3D "Lantiq XWAY PHY11G (PEF 7071/PEF 7072) v1.4",
> +		.features	=3D (PHY_GBIT_FEATURES | SUPPORTED_Pause),
> +		.flags		=3D PHY_HAS_INTERRUPT,
> +		.config_init	=3D lantiq_gphy_config_init,
> +		.config_aneg	=3D lantiq_gphy14_config_aneg,
> +		.read_status	=3D genphy_read_status,
> +		.ack_interrupt	=3D lantiq_gphy_ack_interrupt,
> +		.did_interrupt	=3D lantiq_gphy_did_interrupt,
> +		.config_intr	=3D lantiq_gphy_config_intr,
> +		.suspend	=3D genphy_suspend,
> +		.resume		=3D genphy_resume,
> +	}, {
> +		.phy_id		=3D PHY_ID_PHY22F_1_4,
> +		.phy_id_mask	=3D 0xffffffff,
> +		.name		=3D "Lantiq XWAY PHY22F (PEF 7061) v1.4",
> +		.features	=3D (PHY_BASIC_FEATURES | SUPPORTED_Pause),
> +		.flags		=3D PHY_HAS_INTERRUPT,
> +		.config_init	=3D lantiq_gphy_config_init,
> +		.config_aneg	=3D lantiq_gphy14_config_aneg,
> +		.read_status	=3D genphy_read_status,
> +		.ack_interrupt	=3D lantiq_gphy_ack_interrupt,
> +		.did_interrupt	=3D lantiq_gphy_did_interrupt,
> +		.config_intr	=3D lantiq_gphy_config_intr,
> +		.suspend	=3D genphy_suspend,
> +		.resume		=3D genphy_resume,
> +	}, {
> +		.phy_id		=3D PHY_ID_PHY11G_1_5,
> +		.phy_id_mask	=3D 0xffffffff,
> +		.name		=3D "Lantiq XWAY PHY11G (PEF 7071/PEF 7072) v1.5 / v1.6",
> +		.features	=3D (PHY_GBIT_FEATURES | SUPPORTED_Pause),
> +		.flags		=3D PHY_HAS_INTERRUPT,
> +		.config_init	=3D lantiq_gphy_config_init,
> +		.config_aneg	=3D genphy_config_aneg,
> +		.read_status	=3D genphy_read_status,
> +		.ack_interrupt	=3D lantiq_gphy_ack_interrupt,
> +		.did_interrupt	=3D lantiq_gphy_did_interrupt,
> +		.config_intr	=3D lantiq_gphy_config_intr,
> +		.suspend	=3D genphy_suspend,
> +		.resume		=3D genphy_resume,
> +	}, {
> +		.phy_id		=3D PHY_ID_PHY22F_1_5,
> +		.phy_id_mask	=3D 0xffffffff,
> +		.name		=3D "Lantiq XWAY PHY22F (PEF 7061) v1.5 / v1.6",
> +		.features	=3D (PHY_BASIC_FEATURES | SUPPORTED_Pause),
> +		.flags		=3D PHY_HAS_INTERRUPT,
> +		.config_init	=3D lantiq_gphy_config_init,
> +		.config_aneg	=3D genphy_config_aneg,
> +		.read_status	=3D genphy_read_status,
> +		.ack_interrupt	=3D lantiq_gphy_ack_interrupt,
> +		.did_interrupt	=3D lantiq_gphy_did_interrupt,
> +		.config_intr	=3D lantiq_gphy_config_intr,
> +		.suspend	=3D genphy_suspend,
> +		.resume		=3D genphy_resume,
> +	},
> +};
> +module_phy_driver(lantiq_gphy);
> +
> +static struct mdio_device_id __maybe_unused lantiq_gphy_tbl[] =3D {
> +	{ PHY_ID_PHY11G_1_3, 0xffffffff },
> +	{ PHY_ID_PHY22F_1_3, 0xffffffff },
> +	{ PHY_ID_PHY11G_1_4, 0xffffffff },
> +	{ PHY_ID_PHY22F_1_4, 0xffffffff },
> +	{ PHY_ID_PHY11G_1_5, 0xffffffff },
> +	{ PHY_ID_PHY22F_1_5, 0xffffffff },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(mdio, lantiq_gphy_tbl);
> +
> +MODULE_DESCRIPTION("Lantiq PHY driver");
> +MODULE_AUTHOR("Daniel Schwierzeck <daniel.schwierzeck@googlemail.com>"=
);
> +MODULE_LICENSE("GPL");
>



--------------ms000508090004080402000806
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgMFADCABgkqhkiG9w0BBwEAAKCC
C8gwggXeMIIExqADAgECAhAQgujJuU0eWXH++N9vcV+sMA0GCSqGSIb3DQEBCwUAMHUxCzAJ
BgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSkwJwYDVQQLEyBTdGFydENvbSBD
ZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEjMCEGA1UEAxMaU3RhcnRDb20gQ2xhc3MgMSBDbGll
bnQgQ0EwHhcNMTYwMTAxMTEzNjI2WhcNMTcwMTAxMTEzNjI2WjAyMRQwEgYDVQQDDAttQGty
ZXNpbi5tZTEaMBgGCSqGSIb3DQEJARYLbUBrcmVzaW4ubWUwggIiMA0GCSqGSIb3DQEBAQUA
A4ICDwAwggIKAoICAQCwhIcqrOiuu1MAenZsA4ieYMW8JEAvin527wbKoV04sBPfY9i6Wh56
HVg9dPmQVS8VWjvsolau46gRBDBjwqTL8l5zxMy2GzAP8+3jneJ6Y5Br2osq85rUIWxSev0b
w/H8l/aqNacAtH24u+6YTYVokzi9Lzs7WS3c1ih2SeWQ8JjAAilxvtgbG8hPOZ3R7ptLLyX5
mXw3qc7PspfQXk59MzcFsRm1XjuYd4w+tE1Q3Fuk0CXytTN2wfbLW/egFI2hVu7Y+7AlWHa6
Xt4l1d/CxC4cP0NAAmL+2jTkoHkdaIwGBM6HRKFyNAPnhFTCOiUxg7BmmWtBYrQa7HKNcSJx
Tksn5enwX8zOrEa0Wno4rCfUsleM9ryOKMbFRWZUSCxsHRb9Ly/H0MxFNqy9ePIu1tGld535
PdIUHlPeOXvBYWgat8fX9rM739w5EWXUmzW/cb4F5SCouWROMc9xMTOGKigjh+gG5abGL0sq
xWlXfBFNKZ7gATF5tu1SV3HUUU0lnmeGK33HgM4c2mZ1k8FzN1gBxDiExYuoX8zD5ky3ufCs
omdfnqQV/+d7cGUQRnCtoYAHJmuHUJ12dLB83KJEme4lF5ZBwxD0OIekgWLraCI2YGZYMea6
jpF8bTGBS/vSY0WOKhmt5rZMunZEOsAMF4zZPTJt4t8ZdcMGL6b3cQIDAQABo4IBqzCCAacw
CwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDAJBgNVHRMEAjAA
MB0GA1UdDgQWBBQfrNFccfgBcnFuGdnM89UO1dBuqjAfBgNVHSMEGDAWgBQkgWw5Yb5JD4+3
G0YrySi1J0htaDBvBggrBgEFBQcBAQRjMGEwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLnN0
YXJ0c3NsLmNvbTA5BggrBgEFBQcwAoYtaHR0cDovL2FpYS5zdGFydHNzbC5jb20vY2VydHMv
c2NhLmNsaWVudDEuY3J0MDgGA1UdHwQxMC8wLaAroCmGJ2h0dHA6Ly9jcmwuc3RhcnRzc2wu
Y29tL3NjYS1jbGllbnQxLmNybDAWBgNVHREEDzANgQttQGtyZXNpbi5tZTAjBgNVHRIEHDAa
hhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wRgYDVR0gBD8wPTA7BgsrBgEEAYG1NwECBDAs
MCoGCCsGAQUFBwIBFh5odHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kwDQYJKoZIhvcN
AQELBQADggEBAERTLVk/d7phXV35MIUxDmb9nWvEOWBLuSEX45dQTlQfxsrgaWMSXQXaK+0P
i8WUAymFmSXwpMOaAQWsKbQ5WZOwzc9LoYyRihHgbHQ0I0d57lMadBUSacSnhZa2bcFRvMRb
4w0d0xzJLWhvPp9ElAkH7N9EgV2mOng4nw4anGJ43d5SGLIr84ahODWudoZnAoSOyK8BnXz1
HSv+91PC5Cl2ksHKbxYmUEVsIDbVwO9cNCbJGasbyk34d2v0ENi7gifQmp7YO9BI/CaqzdaA
6gg8Wa41bvAHsin2TiUbJYGvRlsajorKnC0yR3CN8l91eUfKTQ5bSendNgjKyjyvMt0wggXi
MIIDyqADAgECAhBrp4p9CteI1lEK+Vnk57ThMA0GCSqGSIb3DQEBCwUAMH0xCzAJBgNVBAYT
AklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBD
ZXJ0aWZpY2F0ZSBTaWduaW5nMSkwJwYDVQQDEyBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1
dGhvcml0eTAeFw0xNTEyMTYwMTAwMDVaFw0zMDEyMTYwMTAwMDVaMHUxCzAJBgNVBAYTAklM
MRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSkwJwYDVQQLEyBTdGFydENvbSBDZXJ0aWZpY2F0
aW9uIEF1dGhvcml0eTEjMCEGA1UEAxMaU3RhcnRDb20gQ2xhc3MgMSBDbGllbnQgQ0EwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9fdr3w6J9g/Zbgv3bW1+uHht1wLUZr5gk
rLtXedg17AkefMyUGwrQdvwObhajcVmnKVxhrUwkZPXRAwZZosRHfEIi5FH7x6SV/8Sp5lZE
uiMnvMFG2MzLA84J6Ws5T4NfXZ0qn4TPgnr3X2vPVS51M7Ua9nIJgn8jvTra4eyyQzxvuA/G
ZwKg7VQfDCmCS+kICslYYWgXOMt2xlsSslxLce0CGWRsT8EpMyt1iDflSjXZIsE7m1uTyHaK
ZspMLyIyz6mySu8j8BWWHpChNNeTrFuhVfrOAyDPFJVUvKZCLKBhibTLloyy+LatoWELrjdI
4a8StZY8+dIR9t4APXGzAgMBAAGjggFkMIIBYDAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0lBBYw
FAYIKwYBBQUHAwIGCCsGAQUFBwMEMBIGA1UdEwEB/wQIMAYBAf8CAQAwMgYDVR0fBCswKTAn
oCWgI4YhaHR0cDovL2NybC5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMGYGCCsGAQUFBwEBBFow
WDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Auc3RhcnRzc2wuY29tMDAGCCsGAQUFBzAChiRo
dHRwOi8vYWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9jYS5jcnQwHQYDVR0OBBYEFCSBbDlhvkkP
j7cbRivJKLUnSG1oMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mHMMo0aEPQQa7yMD8GA1UdIAQ4
MDYwNAYEVR0gADAsMCoGCCsGAQUFBwIBFh5odHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xp
Y3kwDQYJKoZIhvcNAQELBQADggIBAIvj94fsAYuErQ8BAluc4SMnIwS9NPBwAm5SH9uh2NCX
Tq7im61g7F1LIiNI/+wq37fUuaMbz4g7VarKQTgf8ubs0p7NZWcIe7Bvem2AWaXBsxsaRTYw
5kG3DN8pd1hSEUuFoTa7DmNeFe8tiK1BrL3rbA/m48jp4AiFXgvxprJrW7izsyetOrRHPbkW
4Y07v29MdhaPv3u1JELyszXqOzjIYo4sWlC8iDQXwgSW/ntvWy2n4LuiaozlCfXl149tKeqv
wlvrla2Yklue/quWp9j9ou4T/OY0CXMuY+B8wNK0ohd2D4ShgFlMSjzAFRoHGKF81snTr2d1
A7Ew02oF6UQyCkC2aNNsK5cWOojBar5c7HplX9aHYUCZouxIeU28SONJAxnATgR4cJ2jrpmY
Sz/kliUJ46S6UpVDo/ebn9c6PaM/XtDYCCaM/7XX6wc3s++sbQ7CtCn1Ax7df6ufQbwyO0V+
oFa9H0KAsjHMzcwk3EV2B2NLatidKE/m7G+rB9m+FlVgIiSp0mGlg43QO9Kh1+JqvTCIzv2b
JJkmPMLQJNuKKwHNL8F4GGp6jbAV+WL+LDeGfVcq8DHS3LrD+xyYEXQBiqZEdiPVOMxLDSUC
XsDO0uCWpaNQ8j6y6S9p0xE/Ga0peVLadVHhqf9nXqKaxnr358VgfrxzUIrvOaOjMYIE7DCC
BOgCAQEwgYkwdTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKTAnBgNV
BAsTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MSMwIQYDVQQDExpTdGFydENv
bSBDbGFzcyAxIENsaWVudCBDQQIQEILoyblNHllx/vjfb3FfrDANBglghkgBZQMEAgMFAKCC
AjMwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTYwNTIyMjAz
MDQ4WjBPBgkqhkiG9w0BCQQxQgRACkGZaMpecNfIUC6rfgaBmHR78kG0+aagwq1qnQ5Rf7YR
x0IoAnRGq0FbZpYC/eWTIvlWeN3eDG15G7HT2zcEODBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCG
SAFlAwQBKjALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqG
SIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGaBgkrBgEEAYI3EAQxgYwwgYkw
dTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKTAnBgNVBAsTIFN0YXJ0
Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MSMwIQYDVQQDExpTdGFydENvbSBDbGFzcyAx
IENsaWVudCBDQQIQEILoyblNHllx/vjfb3FfrDCBnAYLKoZIhvcNAQkQAgsxgYyggYkwdTEL
MAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKTAnBgNVBAsTIFN0YXJ0Q29t
IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MSMwIQYDVQQDExpTdGFydENvbSBDbGFzcyAxIENs
aWVudCBDQQIQEILoyblNHllx/vjfb3FfrDANBgkqhkiG9w0BAQEFAASCAgCfFWdXIjLddVCq
SZhCuIu2cfjCw2hNseqc1eo3Zd5hmRskLuHAY9fa3Q1Yeo1Pk93mp9iwfoHXCoDuHa59WZry
ENU596VHLB1/AEcWnccDcZpDcRIdLyrlUfwrlCtDEyYVdaEjdDieokybBa/S72+3piLbN6+P
X+0ePsN+Gs7ED61jIlPTZJDG4miG338NxBC3XVMcUxwOb3U+VShAVRnrivC4DhuewK5KnjQw
XgwdyGUfHF/VS/aJBmvUdGBFcEjOfXReNTSm/pZwlnZOoX1W7y3Mhl6rR4ZMoT4vlTu76UOS
uh/qJknDYI5TtHygmBSQD+X4JOFaPP4YzXAozfKHh2+qhpENdV9cERhwWjj24KICakjDnwGj
rPYM4kIUEUFGvQvCUCIRhuQcX9VDmvRzO+0Z9jYS/9FYqjfoIwppsYn9s9Np6RR06JSng9e4
LSPJhrSmF5Fi99JEiMr0FslqiR5B9UgAwk45YHRJTULtH+NoLHThtOoWWaZ32t0SqTGHO0W/
Fl4wZwUfGS7n0vothRarBZ4zIp64LsdBq/btnRwpt+VNOvevdWVNjbbyP4WyVO7gJIby7zdA
K015L2+VO5dNYeon4acTYQxf4RAU3XTCFb3RK4Rvif5k6boyeCUwzMB029jklmde/0gwdxU+
r1pu5LCqLQCGKxiEeboWOQAAAAAAAA==
--------------ms000508090004080402000806--
