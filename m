From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Mon, 7 Dec 2015 06:34:34 -0800
Message-ID: <CAJ+vNU0bNzuDJ971VS4r0gt4+zJj4GkXWE_qzoC0bs7s4OdU1Q@mail.gmail.com>
References: <m3egeyct8o.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:32858 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932383AbbLGOee convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 09:34:34 -0500
Received: by igcmv3 with SMTP id mv3so79610543igc.0
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 06:34:34 -0800 (PST)
In-Reply-To: <m3egeyct8o.fsf@t19.piap.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2015 at 4:56 AM, Krzysztof Ha=C5=82asa <khalasa@piap.pl>=
 wrote:
> Gateworks Ventana boards seem to need "RGMII-ID" (internal delay)
> PHY mode, instead of simple "RGMII", for their Marvell 88E1510
> transceiver. Otherwise, the Ethernet MAC doesn't work with Marvell PH=
Y
> driver (TX doesn't seem to work correctly).
>
> Tested on GW5400 rev. C.
>
> This bug affects ARM Fedora 23.
>
> Signed-off-by: Krzysztof Ha=C5=82asa <khalasa@piap.pl>
>
> diff --git a/arch/arm/boot/dts/imx6q-gw5400-a.dts b/arch/arm/boot/dts=
/imx6q-gw5400-a.dts
> index 822ffb2..6c168dc 100644
> --- a/arch/arm/boot/dts/imx6q-gw5400-a.dts
> +++ b/arch/arm/boot/dts/imx6q-gw5400-a.dts
> @@ -154,7 +154,7 @@
>  &fec {
>         pinctrl-names =3D "default";
>         pinctrl-0 =3D <&pinctrl_enet>;
> -       phy-mode =3D "rgmii";
> +       phy-mode =3D "rgmii-id";
>         phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_HIGH>;
>         status =3D "okay";
>  };
> diff --git a/arch/arm/boot/dts/imx6qdl-gw51xx.dtsi b/arch/arm/boot/dt=
s/imx6qdl-gw51xx.dtsi
> index f2867c4..90496aa 100644
> --- a/arch/arm/boot/dts/imx6qdl-gw51xx.dtsi
> +++ b/arch/arm/boot/dts/imx6qdl-gw51xx.dtsi
> @@ -94,7 +94,7 @@
>  &fec {
>         pinctrl-names =3D "default";
>         pinctrl-0 =3D <&pinctrl_enet>;
> -       phy-mode =3D "rgmii";
> +       phy-mode =3D "rgmii-id";
>         phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_LOW>;
>         status =3D "okay";
>  };
> diff --git a/arch/arm/boot/dts/imx6qdl-gw52xx.dtsi b/arch/arm/boot/dt=
s/imx6qdl-gw52xx.dtsi
> index 4493f6e..0a6730b 100644
> --- a/arch/arm/boot/dts/imx6qdl-gw52xx.dtsi
> +++ b/arch/arm/boot/dts/imx6qdl-gw52xx.dtsi
> @@ -154,7 +154,7 @@
>  &fec {
>         pinctrl-names =3D "default";
>         pinctrl-0 =3D <&pinctrl_enet>;
> -       phy-mode =3D "rgmii";
> +       phy-mode =3D "rgmii-id";
>         phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_LOW>;
>         status =3D "okay";
>  };
> diff --git a/arch/arm/boot/dts/imx6qdl-gw53xx.dtsi b/arch/arm/boot/dt=
s/imx6qdl-gw53xx.dtsi
> index cfad214..2c549ad 100644
> --- a/arch/arm/boot/dts/imx6qdl-gw53xx.dtsi
> +++ b/arch/arm/boot/dts/imx6qdl-gw53xx.dtsi
> @@ -174,7 +174,7 @@
>  &fec {
>         pinctrl-names =3D "default";
>         pinctrl-0 =3D <&pinctrl_enet>;
> -       phy-mode =3D "rgmii";
> +       phy-mode =3D "rgmii-id";
>         phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_LOW>;
>         status =3D "okay";
>  };
> diff --git a/arch/arm/boot/dts/imx6qdl-gw54xx.dtsi b/arch/arm/boot/dt=
s/imx6qdl-gw54xx.dtsi
> index 535b536..b4ea087 100644
> --- a/arch/arm/boot/dts/imx6qdl-gw54xx.dtsi
> +++ b/arch/arm/boot/dts/imx6qdl-gw54xx.dtsi
> @@ -164,7 +164,7 @@
>  &fec {
>         pinctrl-names =3D "default";
>         pinctrl-0 =3D <&pinctrl_enet>;
> -       phy-mode =3D "rgmii";
> +       phy-mode =3D "rgmii-id";
>         phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_LOW>;
>         status =3D "okay";
>  };
>
> --
> Krzysztof Halasa
>
> Industrial Research Institute for Automation and Measurements PIAP
> Al. Jerozolimskie 202, 02-486 Warsaw, Poland

Krzysztof,

It sounds like your saying this controls whether the phy is in charge
of delay vs the MAC. I have never needed to set this and haven't found
where its actually used (in at least 4.3). Is this caused by something
new in the kernel I haven't seen yet or is it possible you have board
that has an Ethernet issue?

Regards,

Tim

Tim Harvey - Principal Software Engineer
Gateworks Corporation - http://www.gateworks.com/
3026 S. Higuera St. San Luis Obispo CA 93401
805-781-2000
